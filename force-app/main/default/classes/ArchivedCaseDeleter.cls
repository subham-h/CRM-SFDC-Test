/**
* @author Ranjan Kumar
* @description Batch for deleting Archived Case and related objects. 
Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-7165     17-Mar-2023 Ranjan@Maersk            Created. 
* 2.0       SC-7165     20-Mar-2023 Aditya@Maersk            Added the deleteCaseRelRec method
* 3.0       SC-7165     20-Mar-2023 Rohan@Maersk             Added the deleteFiles method
*/
public without sharing class ArchivedCaseDeleter {
    public static void initiateScheduledArchivalCaseDeleter(String strName, String strSchedule, Integer iBatchSize) {
        if(String.isBlank(strName) && !Test.isRunningTest()) {
            strName = 'Batch Archived Case Deleter';
        }else if(String.isBlank(strName) && Test.isRunningTest()){
            strName = 'Batch Archived Case Deleter Test';
        }
        if(String.isBlank(strSchedule)) {
            strSchedule = '0 0 19 ? * *';
        }
        System.schedule(strName, strSchedule, new Scheduler_BatchArchivedCaseDeleteBatch(iBatchSize));
    }
    /*delete the archived case Related Objects*/
    public static void deleteCaseRelRec(Map<id,Archived_Case__c> archCaseMap){
        Set<Id> archCaseIds=archCaseMap.keySet();
        String failedRec='';
        TriggerExecutionController.skipAllTriggers(true);
        Database.DeleteResult[] delSurveyResList=new List<Database.DeleteResult>();
        List<Survey__c> surveyDelList=[SELECT Id FROM Survey__c WHERE Archived_Case__c IN :archCaseIds];
        if(!surveyDelList.isEmpty()){
            delSurveyResList=Database.delete(surveyDelList,false);
            Database.emptyRecycleBin(surveyDelList);
        }
        Database.DeleteResult[] delAgentWorkFlowResList=new List<Database.DeleteResult>();
        List<Agent_Workflow__c> agentWorkFlowDelList=[SELECT Id FROM Agent_Workflow__c WHERE Archived_Case__c IN :archCaseIds];
        if(!agentWorkFlowDelList.isEmpty()){
            delAgentWorkFlowResList=Database.delete(agentWorkFlowDelList,false);
            Database.emptyRecycleBin(agentWorkFlowDelList);

        }
        Database.DeleteResult[] delExternalPartyResList=new List<Database.DeleteResult>();
        List<External_Party__c> externalPartyDelList=[SELECT Id FROM External_Party__c WHERE Archived_Case__c IN :archCaseIds];
        if(!externalPartyDelList.isEmpty()){
            delExternalPartyResList=Database.delete(externalPartyDelList,false);
            Database.emptyRecycleBin(externalPartyDelList);

        }
        Database.DeleteResult[] delActivityRelatedResList=new List<Database.DeleteResult>();
        List<Activity_Related_Reference__c> activityRelatedDelList=[SELECT Id FROM Activity_Related_Reference__c WHERE Archived_Case__c IN :archCaseIds];
        if(!activityRelatedDelList.isEmpty()){
            delActivityRelatedResList=Database.delete(activityRelatedDelList,false);
            Database.emptyRecycleBin(activityRelatedDelList);

        }
        Database.DeleteResult[] delEquipmentCommodityResList=new List<Database.DeleteResult>();
        List<Equipment_Commodity__c> equipmentCommodityDelList=[SELECT Id FROM Equipment_Commodity__c WHERE Archived_Case__c IN :archCaseIds];
        if(!equipmentCommodityDelList.isEmpty()){
            delEquipmentCommodityResList=Database.delete(equipmentCommodityDelList,false);
            Database.emptyRecycleBin(equipmentCommodityDelList);

        }
        for(Database.DeleteResult drObj : delSurveyResList) {
            if (!drObj.isSuccess()) {
                failedRec=failedRec+'Id: '+drObj.getId()+'Reason: '+drObj.getErrors()+';';
            }
        }
        for(Database.DeleteResult drObj : delAgentWorkFlowResList) {
            if (!drObj.isSuccess()) {
                failedRec=failedRec+'Id: '+drObj.getId()+'Reason: '+drObj.getErrors()+';';
            }
        }
        for(Database.DeleteResult drObj : delExternalPartyResList) {
            if (!drObj.isSuccess()) {
                failedRec=failedRec+'Id: '+drObj.getId()+'Reason: '+drObj.getErrors()+';';
            }
        }
        for(Database.DeleteResult drObj : delActivityRelatedResList) {
            if (!drObj.isSuccess()) {
                failedRec=failedRec+'Id: '+drObj.getId()+'Reason: '+drObj.getErrors()+';';
            }
        }
        for(Database.DeleteResult drObj : delEquipmentCommodityResList) {
            if (!drObj.isSuccess()) {
                failedRec=failedRec+'Id: '+drObj.getId()+'Reason: '+drObj.getErrors()+';';
            }
        }
        Database.DeleteResult[] delArchCaseResList=Database.delete(archCaseMap.values(),false);
        for(Database.DeleteResult drObj : delArchCaseResList) {
            if (!drObj.isSuccess()) {
                failedRec=failedRec+'Id: '+drObj.getId()+'Reason: '+drObj.getErrors()+';';
            }
        }
        Database.emptyRecycleBin(archCaseMap.values());
        if(!failedRec.equalsIgnoreCase('')){
            ErrorLogger.writeError('SFDC', 
            'ArchivedCaseDeleter', 
            'ArchivedCaseDeleter.deleteRecordsFromObject',
            'Warning', 
            'Deletion Failure for Case Related Object: ', failedRec);
        }
        TriggerExecutionController.skipAllTriggers(false);

     }

     public static Set<Id> retrieveExtEmailIds(Set<Id> archCaseIds){
        Set<Id> conDocSet=new Set<Id>();
        Map<Id,emailmessagearchival__x> emailMap=new Map<Id,emailmessagearchival__x>([select Id,emailid__c from emailmessagearchival__x where parentid__c in :archCaseIds]);
        return emailMap.keySet();
    }


     public static void deleteFiles(Set<Id> archCaseIds){
        List<ContentDocumentLink> conDocLinkList=new List<ContentDocumentLink>();
        conDocLinkList = [Select Id, LinkedEntityId, ContentDocumentId,Visibility,ShareType From ContentDocumentLink Where LinkedEntityId =: archCaseIds];
        if(conDocLinkList.isEmpty()){
            return;
        }
        Set<Id> conDocSet=new Set<Id>();
        for(ContentDocumentLink conObj : conDocLinkList){
            conDocSet.add(conObj.ContentDocumentId);
        }
        List<ContentDocumentLink> conDocLinkExustList=new List<ContentDocumentLink>();
        //query all the content document related links
        conDocLinkExustList = [Select Id, LinkedEntityId, ContentDocumentId,Visibility,ShareType From ContentDocumentLink Where ContentDocumentId =: conDocSet];
        Map<Id,List<ContentDocumentLink>> condocIdLinkListMap=new Map<Id,List<ContentDocumentLink>>();
		for(ContentDocumentLink conObj:conDocLinkExustList){
            if(!condocIdLinkListMap.containsKey(conObj.ContentDocumentId)){
                condocIdLinkListMap.put(conObj.ContentDocumentId,new List<ContentDocumentLink>());
            }
            //check other than the record id and users if any other object is associated with the file
            if(!archCaseIds.contains((conObj.LinkedEntityId)) && (!checkString(conObj.LinkedEntityId))){
                condocIdLinkListMap.get(conObj.ContentDocumentId).add(conObj);
            }
        }
        List<Id> delList=new List<Id>();
        for(Id ConDocId:condocIdLinkListMap.keySet()){
            List<ContentDocumentLink> delLinkList=condocIdLinkListMap.get(ConDocId);
            if(delLinkList.isEmpty()){
                delList.add(ConDocId);
            }
        }
        deleteContentDocument(delList);
    }
    public static void deleteContentDocument(List<Id> contentDocIds){
        String failedRec='';
        TriggerExecutionController.skipAllTriggers(true);
        Database.DeleteResult[] delOrphanFileList=Database.delete(contentDocIds, false);
        for(Database.DeleteResult drObj : delOrphanFileList) {
            if (!drObj.isSuccess()) {
                failedRec=failedRec+'Id: '+drObj.getId()+'Reason: '+drObj.getErrors()+';';
            }
        }
        if(!failedRec.equalsIgnoreCase('')){
            ErrorLogger.writeError('SFDC', 
            'DeleteOrphanfiles', 
            'DeleteOrphanfiles.deleteFiles',
            'Warning', 
            'Deletion Failure for Orphan Files: ', failedRec);
        }
        TriggerExecutionController.skipAllTriggers(false);
    }
    /*Check if the id belongs to an user*/
    public static boolean checkString(Id linkEId){
        String str=String.valueOf(linkEId);
        if(str.startsWith('005')){
        	return True;
        }else{
            return False;
        }
    }
}