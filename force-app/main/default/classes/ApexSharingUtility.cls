/*
* Author   : Richa@Maersk
* Purpose  : Generic Utility class for apex sharing 
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-4859     07-04-2022  Richa@Maersk            Create share record for sObject and delete existing on recalculation
* 2.0      SC-5492     28-06-2022  Richa@Maersk            Handle 4pl sharing for portal cases
* 3.0      SC-7243     27-02-2023  Saradha@UST             Synchoronous ISR Sharing
*/
public class ApexSharingUtility {
	//SC-7243 - Synchoronous ISR Sharing - CaseDetails from caseRecordSelector to reduce query.
    public static List<sObject> lst4PLISRCasesForShare = new List<sObject>();
    //SC-4859 4PL visibility
    public static void updateSharing(Set<Id> setRecordIds, String objName,String key, String accessLevel, String rowCause, Boolean isUpdate) {
        General_Settings__c gs =General_Settings__c.getInstance();
        Integer count = 0;
        if(gs.Apex_Sharing_Retry_status__c){
            System.enqueueJob(new ApexSharingRetryQueueable(setRecordIds,objName,key,accessLevel,rowCause,isUpdate,count));
        }
    }
    
    //SC-5492: 4PL visibility for Portal Cases
    public static void updateSharingPortal(Set<Id> setRecordIds,Boolean isUpdate) {
        try{
            List<SF_4PL_Case_Sharing_Event__e> lstShareEvents = new List<SF_4PL_Case_Sharing_Event__e>(); 
            SF_4PL_Case_Sharing_Event__e evt = new SF_4PL_Case_Sharing_Event__e();       
            String setString = string.valueof(setRecordIds).replace('{', '').replace('}', '').replace(' ', '');
            evt.RecordIds__c = setString;
            evt.IsUpdate__c = isUpdate;
            lstShareEvents.add(evt);
            List<Database.SaveResult> results = EventBus.publish(lstShareEvents);
            for (Database.SaveResult sr : results) {           
                if (!sr.isSuccess()){
                    Database.Error err = sr.getErrors()[0];
                    ErrorLogger.writeError('SFDC', 'Case', 'ApexSharingUtility.updateSharingPortal',JSON.serialize(err.getFields()),err.getMessage(),JSON.serialize(setRecordIds));
                }       
            }
        }catch(Exception ex){
            ErrorLogger.writeError( 'SFDC', 'Case', 'ApexSharingUtility.updateSharingPortal',ex.getTypeName(),ex.getMessage(),JSON.serialize(setRecordIds));
        }
    }
    //SC-7243 - synchoronous sharing for ISR cases
    public static void createShareRecordForISR(Set<Id> setRecordIds, String objName,String key, String accessLevel, String rowCause, Boolean isUpdate,List<Case> caseDetails) {
        if(caseDetails != null  && caseDetails.size() > 0){
            lst4PLISRCasesForShare = new List<sObject>();
			lst4PLISRCasesForShare.addAll((List<sObject>)caseDetails);
            createShareRecord(setRecordIds, objName,key, accessLevel, rowCause, isUpdate);
        }
    }
    //create new share records
    public static Boolean createShareRecord(Set<Id> setRecordIds, String objName,String key, String accessLevel, String rowCause, Boolean isUpdate) {
        String shareObjName;
        String parentIdField;
        String accessLevelFieldName;
        Boolean isFailed = false;
        Set<SObject> setShareObjects = new Set<SObject>();
        List<SObject> lstShareObjects = new List<SObject>();
        Map<Id,String> mapObjKeyValue = new Map<Id,String>();
        Map<String, User_Group_Assignment__c> mapPublicGroup = new Map<String, User_Group_Assignment__c>();
        Map<Id,Set<Id>> mapShareRecords = new Map<Id,Set<Id>>();
        try{
            if(objName.endsWithIgnoreCase('__c')){ 
                shareObjName = objName.replace('__c','__Share');   
                parentIdField = 'ParentId';
                accessLevelFieldName = 'AccessLevel';   
            }else{
                shareObjName = objName+'Share';  
                parentIdField = objName+'Id';
                accessLevelFieldName = objName+'AccessLevel';  
            }
            
            mapPublicGroup = User_Group_Assignment__c.getAll();
            List<sObject> lstObj = null;
            
            if(lst4PLISRCasesForShare != null && lst4PLISRCasesForShare.size() > 0){
                lstObj = lst4PLISRCasesForShare;
            }else if(setRecordIds != null){
                String objQuery = 'SELECT SF_4PL_Account__c,'+ key + ' FROM ' + objName + ' WHERE Id IN ';
                objQuery += ':setRecordIds';
                lstObj= Database.query(objQuery); 
            }
            
            
            String shareQuery = 'SELECT Id,UserorGroupId,'+ parentIdField+ ' FROM ' + shareObjName + ' WHERE ' + parentIdField+ ' IN ';
            shareQuery += ':setRecordIds'; 
            shareQuery += ' AND RowCause = '; 
            shareQuery += ':rowCause';
            
            List<SObject> lstShareRecords  = Database.query(shareQuery);
            
            for(sObject objShare : lstShareRecords){
                if(mapShareRecords.get((String)objShare.get(parentIdField))==null){
                    mapShareRecords.put((String)objShare.get(parentIdField),new Set<Id>{(String)objShare.get('UserOrGroupId')});
                }
                else{
                    mapShareRecords.get((String)objShare.get(parentIdField)).add((String)objShare.get('UserOrGroupId'));
                }                
            }            
            
            SObjectType objectType = Schema.getGlobalDescribe().get(shareObjName);
            
            for(sObject obj : lstObj) {
                Set<Id> setAssignedIds = new Set<Id>();
                if(!mapShareRecords.isEmpty() && mapShareRecords.containsKey(obj.Id)){
                    setAssignedIds = mapShareRecords.get(obj.Id);
                }                   
                if((String)obj.get('SF_4PL_Account__c') != null){
                    mapObjKeyValue.put(obj.Id,(String)obj.get('SF_4PL_Account__c'));                        
                    if((mapPublicGroup.containsKey((String)obj.get('SF_4PL_Account__c')) && mapPublicGroup.get((String)obj.get('SF_4PL_Account__c')) != null && !setAssignedIds.contains(mapPublicGroup.get((String)obj.get('SF_4PL_Account__c')).Public_Group_Ids__c)) || setAssignedIds.isEmpty()){
                        setShareObjects.add(newShareRecord(objectType,parentIdField,obj.Id,accessLevelFieldName,accessLevel,mapPublicGroup.get((String)obj.get('SF_4PL_Account__c')).Public_Group_Ids__c,rowCause));
                    }
                }
                else if((String)obj.get('SF_4PL_Account__c') == null){
                    mapObjKeyValue.put(obj.Id,'All 4PL Users');  
                    if((mapPublicGroup.containsKey('All 4PL Users') && mapPublicGroup.get('All 4PL Users') != null && !setAssignedIds.contains(mapPublicGroup.get('All 4PL Users').Public_Group_Ids__c)) || setAssignedIds.isEmpty()){
                        setShareObjects.add(newShareRecord(objectType,parentIdField,obj.Id,accessLevelFieldName,accessLevel,mapPublicGroup.get('All 4PL Users').Public_Group_Ids__c,rowCause));
                    }
                }
            }
            
            if(isUpdate ){
                isFailed = deleteShareRecords(setRecordIds,objName,parentIdField,lstShareRecords,mapObjKeyValue,mapPublicGroup);
            }
            
            if(!setShareObjects.isEmpty()){
                lstShareObjects.addAll(setShareObjects);
                String newShareQuery = 'SELECT Id,UserorGroupId,'+ parentIdField+ ' FROM ' + shareObjName + ' WHERE ' + parentIdField+ ' IN ';
                newShareQuery += ':setRecordIds'; 
                List<SObject> shareRecordsList = Database.query(newShareQuery);
                Map<Id, Set<Id>> parentIdToUserGroupIdsMap = new Map<Id, Set<Id>>();
                for(SObject obj : shareRecordsList){
                    if(parentIdToUserGroupIdsMap.isEmpty() || !parentIdToUserGroupIdsMap.containsKey((Id)obj.get(parentIdField))){
                        parentIdToUserGroupIdsMap.put((Id)obj.get(parentIdField), new Set<Id>{(Id)obj.get('UserorGroupId')});
                    }
                    else{
                        parentIdToUserGroupIdsMap.get((Id)obj.get(parentIdField)).add((Id)obj.get('UserorGroupId'));
                    }
                }
                List<SObject> finalListToInsert = new List<SObject>();
                for(SObject obj : lstShareObjects){
                    if(parentIdToUserGroupIdsMap.isEmpty() || (parentIdToUserGroupIdsMap.containsKey((Id)obj.get(parentIdField)) && !parentIdToUserGroupIdsMap.get((Id)obj.get(parentIdField)).contains((Id)obj.get('UserorGroupId')))){
                        finalListToInsert.add(obj);
                    }
                }
                insert finalListToInsert;
            }
            return isFailed;
        } catch(Exception ex) { 
            if(!String.isBlank(ex.getMessage()) && !ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') && !ex.getMessage().containsIgnoreCase('duplicate value found')){
                ErrorLogger.writeError( 'SFDC', objName, 'ApexSharingUtility.createShareRecord',ex.getTypeName(),ex.getMessage()+ex.getLineNumber(),JSON.serialize(setRecordIds)+'\n'+ex.getStackTraceString()); 
            }
            isFailed = true;
            return isFailed;
        }
    } 
    
    
    public static sObject newShareRecord(SObjectType objectType,String parentIdField,Id objId,String accessLevelFieldName,String accessLevel,Id groupId,String rowCause) {
        SObject shareRecord = objectType.newsObject();
        shareRecord.put(parentIdField, objId);
        shareRecord.put(accessLevelFieldName, accessLevel); 
        shareRecord.put('UserOrGroupId',groupId); 
        shareRecord.put('RowCause', rowCause);
        return shareRecord;
    }
    
    
    //delete old share records
    public static Boolean deleteShareRecords(Set<Id> setRecordIds, String objName, String parentIdField, List<sObject> lstShareRecords, Map<Id,String> mapObjKeyValue,Map<String, User_Group_Assignment__c> mapPublicGroup) {
        
        Set<SObject> setOldShareRecordsToDelete = new Set<SObject>();
        List<SObject> lstOldShareRecordsToDelete = new List<SObject>();
        Boolean isFailed = false; 
        try{          
            System.debug('mapPublicGroup++'+mapPublicGroup);
            for(sObject sh: lstShareRecords){
                if(mapPublicGroup.containsKey(mapObjKeyValue.get((String)sh.get(parentIdField))) && mapPublicGroup.get(mapObjKeyValue.get((String)sh.get(parentIdField))).Public_Group_Ids__c != (String)sh.get('UserOrGroupId')){
                    setOldShareRecordsToDelete.add(sh);               
                }                
            }
            if(!setOldShareRecordsToDelete.isEmpty()) {    
                lstOldShareRecordsToDelete.addAll(setOldShareRecordsToDelete);
                Database.DeleteResult[] oldShareRecordDelete = Database.delete(lstOldShareRecordsToDelete,false);
                for(Database.DeleteResult dr : oldShareRecordDelete){
                    if(!dr.isSuccess()){
                        Database.Error err = dr.getErrors()[0];                          
                        isFailed = true;
                        ErrorLogger.writeError( 'SFDC', objName, 'ApexSharingUtility.deleteShareRecord',JSON.serialize(err.getFields()),err.getMessage(),JSON.serialize(setRecordIds)); 
                        break;
                    }                   
                } 
            } 
            return isFailed;
        }
        catch(Exception ex) {           
            ErrorLogger.writeError( 'SFDC', objName, 'ApexSharingUtility.deleteShareRecord',ex.getTypeName(),ex.getMessage(),JSON.serialize(setRecordIds)); 
            isFailed = true;
            return isFailed;
        }        
    }
    
}