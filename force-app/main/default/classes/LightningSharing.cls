/* 
* version       Date                Owner                                       Description
*********************************************************************************************************************************************
* V1.0          20/05/2019          Meghana Gupta        #RQ-010312:Code created
*/

global without sharing class LightningSharing {
    
    global class SharingPermsException extends Exception{}
    
    // check if logged in user has permission to share records,
    @AuraEnabled
    global static boolean canIEditPerms(Id recordId){
        
        try {
            String query = 'SELECT RecordId, HasDeleteAccess, HasAllAccess FROM UserRecordAccess WHERE RecordId = \'' + String.escapeSingleQuotes(String.valueOf(recordId)) + '\' AND UserId = \'' + UserInfo.getUserId() + '\'';
            sObject objUserAccess = Database.query(query);
            if ((Boolean)objUserAccess.get('HasDeleteAccess') || (Boolean)objUserAccess.get('HasAllAccess')){
                System.Debug('Edit allowed because user has full acesss or modify all permissions');
                return true;
            }
        } catch (System.queryException e){
            return false;
        }
        return false;
    }
    
    @AuraEnabled
    global static void deletePerm(Id UserOrGroupID, Id recordId){
        
        Schema.DescribeSObjectResult describe = getSharingDescribe(recordId);
        
        if (!canIEditPerms(recordId) || !describe.isDeletable() || !describe.isAccessible()){
            throw new AuraHandledException(Label.LackingPermissions);
        }
                
       /* // special handling for role => groups
        if (UserOrGroupID.getSobjectType()==Schema.UserRole.SObjectType){
            //it's a role...find the matching group?
            list<group> matchingGroups = [select id, name, type from group where RelatedId =: UserOrGroupID and type = 'Role'];
            if (matchingGroups.size()>1){
                throw new AuraHandledException(Label.MultipleGroupsForRole);
            }
            UserOrGroupID = matchingGroups[0].Id;
        }*/
        
        String query = buildQuery(recordId);
        query = query + ' and UserOrGroupID =\''+String.escapeSingleQuotes(UserOrGroupID)+'\'';
        System.debug(query);
        
        list<sObject> existing = database.query(query);
        System.debug(existing);
        delete existing;        
    }
    
    @AuraEnabled
    global static String upsertPerm (Id UserOrGroupID, Id recordId, String level){
        
        Schema.DescribeSObjectResult describe = getSharingDescribe(recordId);
        level = String.escapeSingleQuotes(level);
        
        if (!canIEditPerms(recordId)){
            throw new AuraHandledException(Label.LackingPermissions);
        }
        System.debug('doing perm upsert');
        
       /* // special handling for role => groups
        if (UserOrGroupID.getSobjectType()==Schema.UserRole.SObjectType){
            //it's a role...find the matching group?
            list<group> matchingGroups = [select id, name, type from group where RelatedId =: UserOrGroupID and type = 'Role'];
            if (matchingGroups.size()>1){
                throw new AuraHandledException(Label.MultipleGroupsForRole);
            }
            UserOrGroupID = matchingGroups[0].Id;
        }
        */
        
        String query = buildQuery(recordId);
        query = query + ' and UserOrGroupID =\''+String.escapeSingleQuotes(String.valueOf(UserOrGroupID))+'\'';
        System.debug(query);
        
        list<sObject> existing = database.query(query);
        String sobj = objectTypeFromId(recordId);
        
        if (existing.size() > 0){
            System.debug('already existing. will update');
            //can I update this thing?
            
            if (!describe.isUpdateable() ||
                !describe.fields.getMap().get(getAccessLevelField(sobj)).getDescribe().isUpdateable()
               ){
                   throw new AuraHandledException(Label.OwnerAdminModify);
               }
            
            existing[0].put(getAccessLevelField(sobj), level);
            
            try {
                update existing;
            } catch (exception e){
                throw new AuraHandledException(e.getMessage());
            }
            
            return JSON.serialize(existing);
        }else{
            System.debug('not already existing. will create');
            //are we even allowed to insert this?  for these specific fields that we'll set?
            if (!describe.isCreateable() ||
                !describe.fields.getMap().get(getAccessLevelField(sobj)).getDescribe().isCreateable() ||
                !describe.fields.getMap().get(getLookupField(sobj)).getDescribe().isCreateable() ||
                !describe.fields.getMap().get('UserOrGroupId').getDescribe().isCreateable()
               ){
                   throw new AuraHandledException(Label.OwnerAdminModify);
               }
            //create a new SObject dynamically and insert
            Schema.SObjectType newObj = Schema.getGlobalDescribe().get(getSharingTableName(sobj));
            sobject share = newObj.newSObject();
            
            share.put(getAccessLevelField(sobj), level);
            share.put(getLookupField(sobj), recordId);
            share.put('UserOrGroupId', String.escapeSingleQuotes(String.valueOf(UserOrGroupID)));
            
            try {
                insert share;
            } catch (exception e){    
                system.debug('$$$ error: '+ e.getMessage());
                throw new AuraHandledException(e.getMessage());
            }
            return JSON.serialize(share);
        }
    }
    
    @AuraEnabled(cacheable=true)
    global static String doSOSL(String searchString, String objectType){
        
        searchString = String.escapeSingleQuotes(searchString);
        objectType = String.escapeSingleQuotes(objectType);
        
        //check CRUD/FLS
        Schema.DescribeSObjectResult describe = Schema.getGlobalDescribe().get(objectType).getDescribe();
        
        if (!describe.isQueryable() || !describe.isAccessible()){
            throw new AuraHandledException(Label.LackingPermissions);
        }
        
        Map<String, Schema.SObjectField> fieldMap = describe.fields.getMap();
        for (Schema.SObjectField field:fieldMap.values()){
            if (field.getDescribe().isNameField()){
                if (!field.getDescribe().isAccessible()){
                    throw new AuraHandledException(Label.LackingPermissions);
                }
            }
        }
        
        // limit rows returned for performance reasons
        String sosl = 'FIND \'*' + searchString + '*\' IN NAME FIELDS RETURNING ' + getReturning(objectType) + ' limit 200';
        list<list<sobject>> results = search.query(sosl);
        
        list<sObject> output = new list<sobject>();
        for (list<sObject> result:results){
            output.addAll(result);
        }
        system.debug('$$$ output: '+ output);
        return JSON.serialize(output);
    }
    
    @TestVisible
    private static String getReturning (String objectType){
        //assert that we can use these fields as the current user
        if (!User.Id.getDescribe().isAccessible() || !User.Name.getDescribe().isAccessible() ||  !User.UserType.getDescribe().isAccessible() 
            //!Group.Id.getDescribe().isAccessible() ||  !Group.Name.getDescribe().isAccessible()
           ){
               throw new AuraHandledException(Label.LackingPermissions);
           }
        
        
        //filter out user types that don't have sharing!
        if (objectType == 'User'){
            return 'User(Id, Name, UserType WHERE UserType in (\'Standard\', \'PowerCustomerSuccess\', \'PowerPartner\'))';
        }
       /* if (objectType == 'Group'){
            return objectType + '(Id, Name, Type)';
        } */else {
            return objectType + '(Id, Name)';
        }
    }
    
    global static String objectTypeFromId(Id recordId){
        
        Schema.SObjectType token = recordId.getSObjectType();
        Schema.DescribeSObjectResult dr = token.getDescribe();
        return dr.getName();
    }
    
    @AuraEnabled(cacheable=true)
    global static String getSharings(Id recordId){
        
        if (!sharingExists(objectTypeFromId(recordId))){
            throw new AuraHandledException(Label.OWDReadWrite);
        }
        
        list<sObject> results = database.query(buildQuery(recordId));
        list<sharingHolder> output = new list<sharingHolder>();
        
        set<id> groupAndUserIDs = new set<id>();
        set<id> RoleIds = new set<id>();
        
        for (sobject so:results){
            sharingHolder sh = new sharingHolder();
            sh.RowCause = String.valueOf(so.get('RowCause'));
            sh.AccessLevel = String.valueOf(so.get(getAccessLevelField(objectTypeFromId(recordId))));
            sh.UserOrGroupID = String.valueOf(so.get('UserOrGroupID'));
            groupAndUserIDs.add(sh.UserOrGroupID);
            output.add(sh);
        }
        
        if (!User.Id.getDescribe().isAccessible() || !User.Name.getDescribe().isAccessible() || !User.UserType.getDescribe().isAccessible() ||
            !Group.Id.getDescribe().isAccessible() ||  !Group.Name.getDescribe().isAccessible() ||  !Group.Type.getDescribe().isAccessible()
           ){
               throw new AuraHandledException(Label.LackingPermissions);
           }
        map<Id, User> UserMap = new map<Id, User>([Select Name, UserType from User where Id in: groupAndUserIDs]);
        map<Id, Group> GroupMap = new map<Id, Group>([Select Name, Type, RelatedId from Group where Id in: groupAndUserIDs]);
        for (group g:GroupMap.values()){
            if (g.RelatedId != null){
                RoleIds.add(g.RelatedId);
            }
        }
        map<Id, UserRole> RoleMap = new map<Id, UserRole>([Select Name from UserRole where Id in: RoleIDs]);
        
        for (sharingHolder sh:output){
            if (UserMap.get(sh.UserOrGroupID)!=null){
                
                sh.UserOrGroupType = 'User';
                sh.UserOrGroupName = UserMap.get(sh.UserOrGroupID).Name;
                //sh.SubType = huh(UserMap.get(sh.UserOrGroupID).UserType);
                
            } else if (GroupMap.get(sh.UserOrGroupID)!=null){
                sh.UserOrGroupType = 'Group';
               // sh.SubType = GroupMap.get(sh.UserOrGroupID).Type;
                sh.UserOrGroupName = GroupMap.get(sh.UserOrGroupID).Name;
                //special handling for roles
                /*if (sh.SubType.contains('Role')){
                    sh.UserOrGroupName = RoleMap.get(GroupMap.get(sh.UserOrGroupID).RelatedId).Name;
                    sh.RoleId = GroupMap.get(sh.UserOrGroupID).RelatedId;
                }*/
            }
        }
        
        return JSON.serialize(output);
    }
    
    @TestVisible private static String buildQuery(Id recordId){
        String sobj = objectTypeFromId(recordId);
        
        schema.DescribeSObjectResult describe = getSharingDescribe (recordId);
        
        if (!describe.isAccessible() ||
            !describe.fields.getMap().get('Id').getDescribe().isAccessible() ||
            !describe.fields.getMap().get('RowCause').getDescribe().isAccessible() ||
            !describe.fields.getMap().get('UserOrGroupId').getDescribe().isAccessible() ||
            !describe.fields.getMap().get(getAccessLevelField(sobj)).getDescribe().isAccessible() ||
            !describe.fields.getMap().get(getLookupField(sobj)).getDescribe().isAccessible()
           ){
               throw new AuraHandledException(Label.LackingPermissions);
           }
        
        String query = 'select Id, RowCause, UserOrGroupId, ' + getAccessLevelField(sobj) + ' from ' +getSharingTableName(sobj)+ ' where ' + getLookupField(sobj)+ ' = \'' + String.escapeSingleQuotes(String.valueOf(recordId)) + '\'';
        System.debug(query);
        return query;
    }
    
    global class sharingHolder {
        global String UserOrGroupName {get;set;}
        //global String SubType {get;set;}
        global String UserOrGroupType {get;set;}
        global String UserOrGroupID {get;set;}
        global String AccessLevel {get;set;}
        global String RowCause {get;set;}
        global String RoleId {get;set;}
    }
    
    private static boolean isStandard (String sobj){
        if (sobj=='Account' || sobj=='Asset' || sobj=='Campaign' || sobj =='Case' || sobj=='Contact' || sobj=='Lead' || sobj=='Opportunity' || sobj=='User' ){
            return true;
        }
        return false;
    }
    
    @TestVisible
    private static String getLookupField (String sobj){
        if (isStandard(sobj)){
            return sobj + 'Id';
        } else {
            return 'ParentId';
        }
    }
    
    @TestVisible
    private static String getSharingTableName (String sobj){
        if (sobj.contains('__c')){
            return sobj.replace('__c','__Share');
        } else {
            return sobj+'Share';
        }
    }
    
    @TestVisible
    private static schema.DescribeSObjectResult getSharingDescribe (Id recordId){
        try{
            String sharingName = getSharingTableName(objectTypeFromId(recordId));
            return Schema.getGlobalDescribe().get(sharingName).getDescribe();
        } catch (exception e){
            throw new AuraHandledException(Label.OWDReadWrite);
        }
    }
    
    @TestVisible
    private static boolean sharingExists(String sobj){
        
        String strTableName = getSharingTableName(sobj).toLowerCase() ;
        if (sobj.contains('__c')){
            Map<String, Schema.SObjectType> tokens = Schema.getGlobalDescribe();
            if (  tokens.containsKey(strTableName ) || tokens.containsKey('ltngsharing__' + strTableName) ) {
                return true;
            }
        } else {			
            String query = 'select count() from ' + strTableName;
            try {
                integer count = database.countQuery(query);
                if (count > 0) {
                    return true;
                } else {
                    return false;
                }
            } catch (exception e){
                System.debug(e);
            }
            return false;
        }
        
        return false;
    }
    
    @TestVisible
	private static String getAccessLevelField (String sobj){
		System.debug('accesslevelField received sobject type :' + sobj);
		if (isStandard(sobj)){			
			return sobj + 'AccessLevel';
		} else {
			return 'AccessLevel';
		}
	}
    
}