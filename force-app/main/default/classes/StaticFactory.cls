/*
* Author   : Ragu@UST
* Purpose  : Contains members which can be used in static context across the execution.
*          Please do not add any members which cannot be stored in a static context and served across the execution.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-002633   18-Feb-2016 Ragu@UST                Created for implementing CBO (Centralized By Org) trigger architecture.
* 2.0      RQ-004058   07-Jun-2016 Sandhya@UST             Assign ISR Queues based on Case Liner Brand
* 3.0      RQ-004350   06/12/2016  Nirmal@ust              To Populate account and contact Id  from logged in user
* 4.0      RQ-003805   12/21/2016  Nirmal@UST              Added method to know whether current user is community user or not.
* 5.0      RQ-010042   12/02/2019  abhinav.ankit@maersk    Added 2 Methods for making the query static ,getLinerBrandDirectionandCountrymdt  (Metadata query was taking long time to query the result .),getGetGeoListValues (Before query was runnig multiple times )
* 6.0      RQ-010061   06/03/2019  Naved@maersk            Cluster and Region fields to change automatically with change in Country 
* 7.0      RQ-010755   06/06/2019  Naved@maersk            While case creation via automate process need to change the owner 
* 8.0      SC-390      10-06-2020  Sreya@Maersk            Case Visibility update for Email to Case and Portal cases.
* 9.0     SC-400      11-06-2030  sriram@maersk           Case Visibility - ISR
* 10.0    SC-394      15-6-2020    ramadevi@ust            Added On_Behalf_of_Account_ID__c,On_Behalf_of_Account_Name__c to query
* 11.0    SC-825      24-08-2020  Nivedita@ust             User 'Manager' Fields as a filter on CM
* 12.0    SC-5414	   11-Jan-2023 Saradha@UST             Reduced SOQL querying from calling again and again
* 13.0    SC-8791     2-Sep-2023   Vivek@Maersk				Added static method to get queue developer name list based on sobject
* 14.0    SC-9661     23-01-2024   Vivek@Maersk             added new method getCaseOwnerBasedonPermissionSet to fetch all the users based on permissionsetassignment
*/

public class StaticFactory {
    
    // Current User Related Details
    private static User currentUser;
    private static list<User> lstcurrentUser;
    Public static Boolean isGeoDefined = false;
    public static List<Geography__c> lstgeoList;
    Public static Boolean LinerBrandmdt = false;
    public static set<String> setOriginsForE2CStatic;
    public static map<String, LinerBrand_Direction_and_Country__mdt> mapLinerBDCs =new map<String, LinerBrand_Direction_and_Country__mdt>() ;
    public static List<General_Key_Value_Configurations__mdt> lstGeneralkeyValueConfigmdt = new List<General_Key_Value_Configurations__mdt>();
    public static String oldKey;
    public static List<String> artemisQueueList = new List<String>();

    //Sc- 400 Get Case Visibility Matrix metadata 
    public static Map<String, Case_Visibility_Matrices__c> getCaseVisibilityMatrixValue(String Type) {
        Map<String, Case_Visibility_Matrices__c> visibilityMapping = new Map<String, Case_Visibility_Matrices__c>();
        
        // Field details
        for (Case_Visibility_Matrices__c fieldRow : [SELECT Name, Type__c, Case_Visibility__c, Requester_CM_Visibility__c, Resolver_Dept_Prefix__c 
                                                     FROM Case_Visibility_Matrices__c WHERE Type__c = :Type]) {
                                                         visibilityMapping.put(fieldRow.Name, fieldRow);
                                                     }   
        return visibilityMapping;
    }
    
    public static User getCurrentUserDetails() {
        //if(currentUser == null) {
        /*lstcurrentUser = new list<User>();
system.debug('UserInfo.getUserId()'+UserInfo.getName());
lstcurrentUser = [select Id, Name,CM_Visibility__c,Liner_Brand__c, Liner_Brand_Logic__c, MLL__c, AccountId, Contact.Account.Name, ContactId, UserType, ProfileId, Profile.Name,SF_4PL_Account__c
from User where Id = :UserInfo.getUserId()];*/
        // }
        // SC-5414 Added this if condition to avoid querying same user again and again.
        if(lstcurrentUser == null || lstcurrentUser.isEmpty() || (lstcurrentUser != null && lstcurrentUser[0].Id != null && lstcurrentUser[0].Id !=UserInfo.getUserId()) ){
            lstcurrentUser = new list<User>();
            system.debug('UserInfo.getUserId()'+UserInfo.getName());
            lstcurrentUser = [select Id, Name,CM_Visibility__c,Liner_Brand__c, Liner_Brand_Logic__c, MLL__c, AccountId, Contact.Account.Name, ContactId, UserType, ProfileId, Profile.Name,SF_4PL_Account__c,Multi_Carrier_Restricted_Account__c
                              from User where Id = :UserInfo.getUserId()];
        }
        System.debug('lstcurrentUser++'+lstcurrentUser[0].CM_Visibility__c);
        //Put UserInfo.getUserId() in the above query.It is removed only for test
        if(!lstcurrentUser.isEmpty()){
            return lstcurrentUser[0];
        }
        else{
            //System Owner
            return [select Id, Name,CM_Visibility__c, Liner_Brand__c, Liner_Brand_Logic__c, MLL__c, AccountId, Contact.Account.Name, ContactId, UserType, ProfileId, Profile.Name,SF_4PL_Account__c
                    from User where Name = 'System Owner'];
        }
        //return currentUser;
    }
    
    // RQ-003805. Added below method to know whether current user is community user or not.//V4.0
    private static Boolean isCommunityUser = null;
    private static set<String> setCommunityUserTypes = new set<String>{'CspLitePortal', 'PowerCustomerSuccess'};
        public static Boolean isCommunityUser() {
            if(isCommunityUser == null) {
                // Below condition check is case sensitive
                if(setCommunityUserTypes.contains(getCurrentUserDetails().UserType)) {
                    isCommunityUser = true;
                }
                else {
                    isCommunityUser = false;
                }
            }
            return isCommunityUser;
        }
    
    private static map<Id, User> mapUsers = new map<Id, User>();
    public static User getUserDetails(Id userId) {
        User userInstance = mapUsers.get(userId);
        if(userInstance == null) {
            userInstance = [select Id, Name, Liner_Brand_Logic__c, MLL__c
                            from User where Id = :userId];
            mapUsers.put(userInstance.Id, userInstance);
        }
        return userInstance;
    }
    
	public static List<String> getArtemisQueueList(){
        if(artemisQueueList.isEmpty()){
            for(General_Key_Value_Configurations__mdt gen : [Select Key__c, First_Field_Value__c, Second_Field_Value__c From General_Key_Value_Configurations__mdt Where Key__c = 'ArtemisQueue']){
                if(!String.isEmpty(gen.First_Field_Value__c)){
                    artemisQueueList.addAll(gen.First_Field_Value__c.replace(' ','').split(','));
                }
                if(!String.isEmpty(gen.Second_Field_Value__c)){
                    artemisQueueList.addAll(gen.Second_Field_Value__c.replace(' ','').split(','));
                }
            }
        }
        return artemisQueueList;
    }
    
    // Current Environment (Sandbox / Production)
    private static Organization orgDetail;
    public static Organization getOrgDetail() {
        if(orgDetail == null) {
            orgDetail = [select Id, IsSandbox from Organization limit 1];
        }
        return orgDetail;
    }
    public static String getEnvironment() {
        String strEnvironment = 'Production';
        if(getOrgDetail().IsSandbox) {
            strEnvironment = 'Sandbox';
        }
        return strEnvironment;
    }
    
    
    // Record Types Related Utilities - SOQL
    private static map<string, map<Id, RecordType>> mapAllRecordTypes;
    private static map<string, map<Id, RecordType>> loadRecordTypes(string objectName) {
        if(mapAllRecordTypes == null) {
            mapAllRecordTypes = new map<string, map<Id, RecordType>>();
        }
        
        if(!mapAllRecordTypes.containsKey(objectName)) {
            map<Id, Schema.RecordType> mapRecordType = new map<Id, Schema.RecordType>();
            for(RecordType recType : [select Id, Name, DeveloperName, SobjectType from RecordType where sObjectType = :objectName]) {
                mapRecordType.put(recType.Id, recType);
            }
            mapAllRecordTypes.put(objectName, mapRecordType);
        }
        return mapAllRecordTypes;
    }
    
    public static map<Id, RecordType> getRecordTypes(string objectName) {
        return (loadRecordTypes(objectName)).get(objectName);
    }
    
    public static map<Id, string> getRecordTypeIdNameMapByNames(string objectName, set<string> setRecordTypeNames) {
        map<Id, string> mapRecordTypes = new map<Id, string>();
        for(RecordType recType : (loadRecordTypes(objectName)).get(objectName).values()) {
            if(setRecordTypeNames.contains(recType.Name)) {
                mapRecordTypes.put(recType.Id, recType.Name);
            }
        }
        return mapRecordTypes;
    }
    
    public static map<string, Id> getRecordTypeNameIdMapByNames(string objectName, set<string> setRecordTypeNames) {
        map<string, Id> mapRecordTypes = new map<string, Id>();
        for(RecordType recType : (loadRecordTypes(objectName)).get(objectName).values()) {
            if(setRecordTypeNames.contains(recType.Name)) {
                mapRecordTypes.put(recType.Name, recType.Id);
            }
        }
        return mapRecordTypes;
    }
    
    public static map<Id, string> getRecordTypeIdNameMapByIds(string objectName, set<Id> setRecordTypeIds) {
        map<Id, string> mapRecordTypes = new map<Id, string>();
        for(RecordType recType : (loadRecordTypes(objectName)).get(objectName).values()) {
            if(setRecordTypeIds.contains(recType.Id)) {
                mapRecordTypes.put(recType.Id, recType.Name);
            }
        }
        return mapRecordTypes;
    }
    
    public static map<string, Id> getRecordTypeNameIdMapByIds(string objectName, set<Id> setRecordTypeIds) {
        map<string, Id> mapRecordTypes = new map<string, Id>();
        for(RecordType recType : (loadRecordTypes(objectName)).get(objectName).values()) {
            if(setRecordTypeIds.contains(recType.Id)) {
                mapRecordTypes.put(recType.Name, recType.Id);
            }
        }
        return mapRecordTypes;
    }
    
    public static set<Id> getRecordTypeIds(string objectName) {
        set<Id> setRecordTypeIds = new set<Id>();
        for(RecordType recType : (loadRecordTypes(objectName)).get(objectName).values()) {
            setRecordTypeIds.add(recType.Id);
        }
        return setRecordTypeIds;
    }
    
    public static set<string> getRecordTypeNames(string objectName) {
        set<string> setRecordTypeNames = new set<string>();
        for(RecordType recType : (loadRecordTypes(objectName)).get(objectName).values()) {
            setRecordTypeNames.add(recType.Name);
        }
        return setRecordTypeNames;
    }
    
    public static Id getRecordTypeIdByName(string objectName, string recordTypeName) {
        Id recordTypeId;
        for(RecordType recType : (loadRecordTypes(objectName)).get(objectName).values()) {
            if(recType.Name == recordTypeName) {
                recordTypeId = recType.Id;
                break;
            }
        }
        return recordTypeId;
    }
    public static Id getRecordTypeIdByDevName(string objectName, string recordTypeName) {
        Id recordTypeId;
        for(RecordType recType : (loadRecordTypes(objectName)).get(objectName).values()) {
            
            if(recType.DeveloperName == recordTypeName) {
                recordTypeId = recType.Id;
                break;
            }
        }
        return recordTypeId;
    }
    
    public static string getRecordTypeNameById(string objectName, Id recordTypeId) {
        return ((loadRecordTypes(objectName)).get(objectName)).get(recordTypeId).Name;
    }
    
    public static set<Id> getRecordTypeIdsByNames(string objectName, set<string> setRecordTypeNames) {
        set<Id> setRecordTypeIds = new set<Id>();
        for(RecordType recType : (loadRecordTypes(objectName)).get(objectName).values()) {
            if(setRecordTypeNames.contains(recType.Name)) {
                setRecordTypeIds.add(recType.Id);
            }
        }
        return setRecordTypeIds;
    }
    public static set<Id> getRecordTypeIdsByDevNames(string objectName, set<string> setRecordTypeDevNames) {
        set<Id> setRecordTypeIds = new set<Id>();
        for(RecordType recType : (loadRecordTypes(objectName)).get(objectName).values()) {
            if(setRecordTypeDevNames.contains(recType.DeveloperName)) {
                setRecordTypeIds.add(recType.Id);
            }
        }
        return setRecordTypeIds;
    }
    
    public static set<string> getRecordTypeNamesByIds(string objectName, set<Id> setRecordTypeIds) {
        set<string> setRecordTypeNames = new set<string>();
        for(RecordType recType : (loadRecordTypes(objectName)).get(objectName).values()) {
            if(setRecordTypeIds.contains(recType.Id)) {
                setRecordTypeNames.add(recType.Name);
            }
        }
        return setRecordTypeNames;
    }
    
    
    // Record Types Related Utilities - Describe
    private static map<string, map<Id, RecordTypeInfo>> mapAllRecordTypesDESC;
    private static map<string, map<Id, RecordTypeInfo>> loadRecordTypesDESC(string objectName) {
        if(mapAllRecordTypesDESC == null) {
            mapAllRecordTypesDESC = new map<string, map<Id, RecordTypeInfo>>();
        }
        if(!mapAllRecordTypesDESC.containsKey(objectName)) {
            list<Schema.DescribeSObjectResult> descSObjectResults = Schema.describeSObjects(new string[] {objectName});
            map<Id, Schema.RecordTypeInfo> mapRecordType = new map<id, Schema.RecordTypeInfo>();
            for(Schema.RecordTypeInfo recordType : descSObjectResults[0].getRecordTypeInfos()) {
                mapRecordType.put(recordType.getRecordTypeId(), recordType);
            }
            mapAllRecordTypesDESC.put(objectName, mapRecordType);
        }
        return mapAllRecordTypesDESC;
    }
    
    public static map<Id, RecordTypeInfo> getRecordTypesDESC(string objectName) {
        return (loadRecordTypesDESC(objectName)).get(objectName);
    }
    
    public static map<Id, string> getRecordTypeIdNameMapByNamesDESC(string objectName, set<string> setRecordTypeNames) {
        map<Id, string> mapRecordTypes = new map<Id, string>();
        for(RecordTypeInfo rTypeInfo : (loadRecordTypesDESC(objectName)).get(objectName).values()) {
            if(setRecordTypeNames.contains(rTypeInfo.getName())) {
                mapRecordTypes.put(rTypeInfo.getRecordTypeId(), rTypeInfo.getName());
            }
        }
        return mapRecordTypes;
    }
    
    public static map<string, Id> getRecordTypeNameIdMapByNamesDESC(string objectName, set<string> setRecordTypeNames) {
        map<string, Id> mapRecordTypes = new map<string, Id>();
        for(RecordTypeInfo rTypeInfo : (loadRecordTypesDESC(objectName)).get(objectName).values()) {
            if(setRecordTypeNames.contains(rTypeInfo.getName())) {
                mapRecordTypes.put(rTypeInfo.getName(), rTypeInfo.getRecordTypeId());
            }
        }
        return mapRecordTypes;
    }
    
    public static map<Id, string> getRecordTypeIdNameMapByIdsDESC(string objectName, set<Id> setRecordTypeIds) {
        map<Id, string> mapRecordTypes = new map<Id, string>();
        for(RecordTypeInfo rTypeInfo : (loadRecordTypesDESC(objectName)).get(objectName).values()) {
            if(setRecordTypeIds.contains(rTypeInfo.getRecordTypeId())) {
                mapRecordTypes.put(rTypeInfo.getRecordTypeId(), rTypeInfo.getName());
            }
        }
        return mapRecordTypes;
    }
    
    public static map<string, Id> getRecordTypeNameIdMapByIdsDESC(string objectName, set<Id> setRecordTypeIds) {
        map<string, Id> mapRecordTypes = new map<string, Id>();
        for(RecordTypeInfo rTypeInfo : (loadRecordTypesDESC(objectName)).get(objectName).values()) {
            if(setRecordTypeIds.contains(rTypeInfo.getRecordTypeId())) {
                mapRecordTypes.put(rTypeInfo.getName(), rTypeInfo.getRecordTypeId());
            }
        }
        return mapRecordTypes;
    }
    
    public static set<Id> getRecordTypeIdsDESC(string objectName) {
        set<Id> setRecordTypeIds = new set<Id>();
        for(RecordTypeInfo rTypeInfo : (loadRecordTypesDESC(objectName)).get(objectName).values()) {
            setRecordTypeIds.add(rTypeInfo.getRecordTypeId());
        }
        return setRecordTypeIds;
    }
    
    public static set<string> getRecordTypeNamesDESC(string objectName) {
        set<string> setRecordTypeNames = new set<string>();
        for(RecordTypeInfo rTypeInfo : (loadRecordTypesDESC(objectName)).get(objectName).values()) {
            setRecordTypeNames.add(rTypeInfo.getName());
        }
        return setRecordTypeNames;
    }  
    
    public static Id getRecordTypeIdByNameDESC(string objectName, string recordTypeName) {
        Id recordTypeId;
        for(RecordTypeInfo rTypeInfo : (loadRecordTypesDESC(objectName)).get(objectName).values()) {
            if(rTypeInfo.getName() == recordTypeName) {
                recordTypeId = rTypeInfo.getRecordTypeId();
                break;
            }
        }
        return recordTypeId;
    }
    
    public static string getRecordTypeNameByIdDESC(string objectName, Id recordTypeId) {
        return ((loadRecordTypesDESC(objectName)).get(objectName)).get(recordTypeId).getName();
    }
    
    public static set<Id> getRecordTypeIdsByNamesDESC(string objectName, set<string> setRecordTypeNames) {
        set<Id> setRecordTypeIds = new set<Id>();
        for(RecordTypeInfo rTypeInfo : (loadRecordTypesDESC(objectName)).get(objectName).values()) {
            System.debug('rTypeInfo.getName():'+rTypeInfo.getName());           
            if(setRecordTypeNames.contains(rTypeInfo.getName())) {
                setRecordTypeIds.add(rTypeInfo.getRecordTypeId());
            }
        }
        return setRecordTypeIds;
    }
    
    public static set<string> getRecordTypeNamesByIdsDESC(string objectName, set<Id> setRecordTypeIds) {
        set<string> setRecordTypeNames = new set<string>();
        for(RecordTypeInfo rTypeInfo : (loadRecordTypesDESC(objectName)).get(objectName).values()) {
            if(setRecordTypeIds.contains(rTypeInfo.getRecordTypeId())) {
                setRecordTypeNames.add(rTypeInfo.getName());
            }
        }
        return setRecordTypeNames;
    }
    
    
    // Queue Related Methods
    private static map<Id, Group> mapQueues;
    public static map<Id, Group> getQueueMap() {
        if(mapQueues == null || mapQueues.isEmpty()) {
            mapQueues = new map<Id, Group>([select Id, Name, Email, DoesSendEmailToMembers from Group where Type = 'Queue' limit 50000]);
        }
        return mapQueues;
    }
    
    public static Group getQueueById(Id queueId) {
        return (getQueueMap()).get(queueId);
    }
    
    public static map<Id, string> getQueueIdNameMap() {
        map<Id, string> mapQueueIdName = new map<Id, string>();
        for(Group queueIterator : (getQueueMap()).values()) {
            mapQueueIdName.put(queueIterator.Id, queueIterator.Name);
        }
        return mapQueueIdName;
    }
    
    public static string getQueueNameById(Id queueId) {
        return (getQueueIdNameMap()).get(queueId);
    }
    
    public static map<string, Id> getQueueNameIdMap() {
        map<string, Id> mapQueueNameId = new map<string, Id>();
        for(Group queueIterator : (getQueueMap()).values()) {
            mapQueueNameId.put(queueIterator.Name, queueIterator.Id);
        }
        return mapQueueNameId;
    }
    
    public static string getQueueIdByName(string queueName) {
        return (getQueueNameIdMap()).get(queueName);
    }
    
    // v2.0 : From Map of QueueName to QueueId
    private static map<String, Id> mapQueueNameId;
    public static map<String, Id> getQueueNameIdMapByNames(string sObjectName, set<String> queueNameList) {
        if(mapQueueNameId == null || !mapQueueNameId.keySet().containsAll(queueNameList)) {
            mapQueueNameId = new map<String, Id>();
            for(QueueSobject queueObj : [SELECT Id, QueueId, Queue.Name 
                                         FROM QueueSobject
                                         WHERE SobjectType = :sObjectName AND Queue.Name IN :queueNameList]){
                                             System.debug('##### queueObj' + queueObj);
                                             mapQueueNameId.put(queueObj.Queue.Name, queueObj.QueueId);
                                         }
        }
        return mapQueueNameId;
    }
    
    // Public Group Related Methods
    private static map<Id, Group> mapGroups;
    public static map<Id, Group> getGroupMap() {
        if(mapGroups == null || mapGroups.isEmpty()) {
            mapGroups = new map<Id, Group>([select Id, Name from Group where Type = 'Regular' limit 50000]);
        }
        return mapGroups;
    }
    
    public static Group getGroupById(Id groupId) {
        return (getGroupMap()).get(groupId);
    }
    
    public static map<Id, string> getGroupIdNameMap() {
        map<Id, string> mapGroupIdName = new map<Id, string>();
        for(Group groupIterator : (getGroupMap()).values()) {
            mapGroupIdName.put(groupIterator.Id, groupIterator.Name);
        }
        return mapGroupIdName;
    }
    
    public static string getGroupNameById(Id groupId) {
        return (getGroupIdNameMap()).get(groupId);
    }
    
    public static map<string, Id> getGroupNameIdMap() {
        map<string, Id> mapGroupNameId = new map<string, Id>();
        for(Group groupIterator : (getGroupMap()).values()) {
            mapGroupNameId.put(groupIterator.Name, groupIterator.Id);
        }
        return mapGroupNameId;
    }
    
    public static string getGroupIdByName(string groupName) {
        return (getGroupNameIdMap()).get(groupName);
    }
    public static list<Geography__c> getGetGeoListValues(){
        
        System.debug('counter');
        if(isGeoDefined == false){
            isGeoDefined = true;
            try{
                //Part of RQ-010061- Calling the cache method
                lstgeoList = (list<Geography__c >)Cache.Org.get(defaultCache.class, 'Country');
            }
            catch(Exception ex) {
                ErrorLogger.writeErrors( 'SFDC', 'Case', 'StaticFactory.getGetGeoListValues', new list<Exception>{ex});  
                lstgeoList = new list<Geography__c>();
                lstgeoList =[ SELECT Id, Name, GEO_ID__c FROM Geography__c WHERE Type_of_location__c = 'Country'];              
            }
            
        } 
        return lstgeoList ;
    }
    public static  map<String, LinerBrand_Direction_and_Country__mdt> getLinerBrandDirectionandCountrymdt(set<String> setOriginsForE2C){
        if(setOriginsForE2CStatic==null) {
            setOriginsForE2CStatic = new set<String>();
            setOriginsForE2CStatic.addAll(setOriginsForE2C);}
        if(LinerBrandmdt==true){
            Boolean result2 = setOriginsForE2CStatic.containsAll(setOriginsForE2C);
            if(result2==false)
            {
                LinerBrandmdt=false;
            }
        }
        if(LinerBrandmdt == false){
            LinerBrandmdt = true;
            //SC-390 - Getting Case Visibility field.
            for(LinerBrand_Direction_and_Country__mdt LBDC : [select MasterLabel, Cluster__c, Country__c, Direction__c, Liner_Brand__c, Business_Hours__c,Case_Visibility__c,On_Behalf_of_Account_ID__c,On_Behalf_of_Account_Name__c,Product__c,SF_4PL_Account__c,Type__c from LinerBrand_Direction_and_Country__mdt where MasterLabel in :setOriginsForE2C]) {
                mapLinerBDCs.put(LBDC.MasterLabel, LBDC);
            }
        }
        return mapLinerBDCs ;
    }
    
    /**
* To get User's Manager name 
*/
    /*  public static Map<Id,string> getUsersManagerName(set<Id> caseOwnerId) {
Map<Id,string> usrMgrMap =new Map<Id,string>();
for(User usr : [select id,manager.Name from user where Id in :caseOwnerId]){
usrMgrMap.put(usr.Id,usr.Manager.Name);				
}
return usrMgrMap;
}*/
    
    public static Map<Id,User> getCaseOwnerDetails(set<Id> caseOwnerId) {
        Map<Id,User> mapCaseOwnerDetails =new Map<Id,User>();
        for(User usr : [select id,manager.Name,UserRole.Name from user where Id in :caseOwnerId]){
            mapCaseOwnerDetails.put(usr.Id,usr);				
        }
        return mapCaseOwnerDetails;
    }
     
    //SC-9661
      public static Map<String ,PermissionSetAssignment> getCaseOwnerBasedonPermissionSet(List<Id> permissionSetIds) {
        Map<String, PermissionSetAssignment> aiPermissionUsers = new Map<String, PermissionSetAssignment>();
         
        for(PermissionSetAssignment thisPE : [Select Id , AssigneeId,PermissionSetId, permissionSet.Name from PermissionSetAssignment where PermissionSetId != '' and permissionSetId In: permissionSetIds]){
                aiPermissionUsers.put(thisPE.assigneeId+'--'+thisPE.permissionSet.name, thisPE);
        }
        
        return aiPermissionUsers;
      }
    
    //SC-5414 Generic method to get General_Key_Value_Configurations__mdt records based on key
    public static List<General_Key_Value_Configurations__mdt> getGeneralkeyValueConfigmdt(String newkey){
        String queryMDT = 'SELECT DeveloperName,First_Field_Name__c,First_Field_Value__c,Id,Key__c,Label,Language,MasterLabel,NamespacePrefix,QualifiedApiName,Second_Field_Name__c,Second_Field_Value__c,Sobject_Name__c FROM  General_Key_Value_Configurations__mdt WHERE Key__c =';
        if(newkey!= null && oldKey != newkey){
            queryMDT += '\''+newkey+'\'';
            lstGeneralkeyValueConfigmdt = Database.query(queryMDT);
            oldKey = newkey;
            return lstGeneralkeyValueConfigmdt;  
        }else if(newkey!= null && oldKey == newkey){
            oldKey = newkey;
            return lstGeneralkeyValueConfigmdt;  
        }else{
            oldKey = newkey;
            return new List<General_Key_Value_Configurations__mdt>();  
        }    
    }
    
    //SC-8791
    public static string getrelatedContactEmail(string contactid){
        string caseContactEmail = '';
        if(string.isNotBlank(contactid)){
            list<contact> conInstance = [select email from contact where id=:contactid];
            if(!conInstance.isEmpty()){
                if(string.isNotBlank(conInstance[0].email)){
                    caseContactEmail = conInstance[0].email;
                }
            }
        }
        return caseContactEmail;
    }
    
    //SC-8791
    public static string getrelatedUserEmail(string ownerid){
        string caseUserEmail = '';
        if(string.isNotBlank(ownerid)){
            if(String.valueOf(OwnerId).startsWith('005')){
                list<User> userInstance = [select email from user where id=:ownerid];
                if(!userInstance.isEmpty()){
                    if(string.isNotBlank(userInstance[0].email)){
                        caseUserEmail = userInstance[0].email;
                    }
                }
            }
        }
        return caseUserEmail;
    }
    
    public static String generateRandomNumber(Integer length) {
        String result = '';
        while(result.length() < length){
           //Math.abs used to cast Crypto.getRandomLong() to a positive number
           result += String.valueOf(Math.abs(Crypto.getRandomLong()));
        }
        return result.substring(0,length);
    }
    
}