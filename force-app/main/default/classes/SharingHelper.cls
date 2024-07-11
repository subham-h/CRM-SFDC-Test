public without sharing class SharingHelper {
    public static Boolean sharingFailed = false;
    public static void shareRecords(Map<Id, String> mapAccessLevelByRecordId, Map<Id, List<Id>> mapUserOrGrpByRecordId) {
        // RETURN RECORD IDs FOR WHICH SHARE RECORDS FAILED
        Set<Id> retVal = mapAccessLevelByRecordId.keySet(); 
        Map<Id, DescribeSObjectResult> mapDescribeSObjectResultByParentId = new Map<Id, DescribeSObjectResult>();
        List<SObject> listInsertShare = new List<SObject>();
        system.debug(mapAccessLevelByRecordId);
        system.debug(mapUserOrGrpByRecordId);
        system.debug(mapUserOrGrpByRecordId);
        for (Id eachId :mapAccessLevelByRecordId.keySet()) {
            // GET SHARE RECORD FOR EACH ID
            for (Id eachUserOrGroupId :mapUserOrGrpByRecordId.get(eachId)) {
                listInsertShare.add(createShareRecord(
                    SharingHelper.getShareObjectName(eachId)
						, eachId, eachUserOrGroupId, mapAccessLevelByRecordId.get(eachId)));
            }
        }
		
        List<Database.upsertResult > listSaveResult = Database.upsert(listInsertShare, false);
        // REMOVE PROECESSED RECORDS FROM RETURNED SET
        Integer iterator = 0;
        for (Database.upsertResult  eachSr :listSaveResult) {
            if (eachSr.isSuccess()) {
                retVal.remove((Id) listInsertShare.get(iterator).get('ParentId'));
            } else{
                sharingFailed = true;
            }
            iterator++;
        }
        ErrorLogger.writeErrors('SFDC', 'Item Sharing Update', 'SharingHelper', listSaveResult, listInsertShare);
    }
    
    public static String getShareObjectName(Id incomingId) {
        // DESCRIBE OBJECT FROM ID
        DescribeSObjectResult describeResult = incomingId.getSobjectType().getDescribe(SObjectDescribeOptions.DEFERRED);
        // GET SHARE OBJECT NAME
        if (describeResult.isCustom()){
            system.debug(describeResult.getName().substringBefore('__c') + '__Share');
           return describeResult.getName().substringBefore('__c') + '__Share'; 
        } 
        else {
            return describeResult.getName() + 'Share';
        }
    }
    
    public static SObject createShareRecord(String shareObjectName, String parentId, String userGrpId, String accessLevel) {
        // GET NEW INSTANCE FOR THE SHARE OBJECT
        SObject retVal = Schema.getGlobalDescribe().get(shareObjectName).getDescribe(SObjectDescribeOptions.DEFERRED).getSobjectType().newSObject();
        // UPDATE SHARE FIELDS
        retVal.put('ParentId', parentId);
        retVal.put('UserOrGroupId', userGrpId);
        retVal.put('AccessLevel', accessLevel);
        
        return retVal;
    }
        
    public static SObject createShareRecord(SObject iSObject, String parentId, String userGrpId, String accessLevel) {
        // UPDATE SHARE FIELDS
        iSObject.put('ParentId', parentId);
        iSObject.put('UserOrGroupId', userGrpId);
        iSObject.put('AccessLevel', accessLevel);
        
        return iSObject;
    } 
    
     public static List<SObject> createShareRecordList(SObject iSObject, String parentId, Set<Id> setUserGrpId, String accessLevel) {
        // UPDATE SHARE FIELDS
        List<Sobject> lstObjectToCreate = new List<Sobject> ();
         for( Id userId : setUserGrpId){
             iSObject = new Target_Item__Share();
             lstObjectToCreate.add(createShareRecord(iSObject,parentId,userId,accessLevel));
         }
        return lstObjectToCreate;
    } 
    
    public static List<SObject> createShareRecordList(Budget_Group__c iSObject, String parentId, Set<Id> setUserGrpId, String accessLevel) {
        // UPDATE SHARE FIELDS
        List<Sobject> lstObjectToCreate = new List<Sobject> ();
        
         for( Id userId : setUserGrpId){
             iSObject = new Budget_Group__c();
             lstObjectToCreate.add(createShareRecord(iSObject,parentId,userId,accessLevel));
         }
        return lstObjectToCreate;
    } 
}