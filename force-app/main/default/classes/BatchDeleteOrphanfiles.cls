/**
* @author partha
* @description Batch for deleting Archived Case and related objects. 
Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-5488     27-Nov-2023 partha@Maersk            Created. 
*/

global class BatchDeleteOrphanfiles implements Database.Batchable<sObject>,Schedulable {
    global String strObjectName;
    global Purge_Configuration__c purgeCriteria;
    global BatchDeleteOrphanfiles(String strObjectName) {
        this.strObjectName = strObjectName;    
        purgeCriteria= [SELECT Object_Name__c, Field_Name__c, Operation__c, Value__c,Order__c,Days_To_Skip__c, No_Of_Days_To_Delete__c FROM Purge_Configuration__c WHERE Object_Name__c = :strObjectName Limit 1][0];       
          
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        string strQuery = 'select Id, LinkedEntityId, ContentDocumentId from contentdocumentlink where ';
        if(purgeCriteria.Days_To_Skip__c != NULL && purgeCriteria.No_Of_Days_To_Delete__c != NULL){
            Date strtDate = Date.Today().addDays(- Integer.valueOf(purgeCriteria.Days_To_Skip__c)); 
            system.debug('strtDate :'+strtDate);
            Date endDate = Date.Today().addDays(- Integer.valueOf((purgeCriteria.Days_To_Skip__c - purgeCriteria.No_Of_Days_To_Delete__c)));
            system.debug('endDate :'+endDate);
            strQuery = strQuery+ 'contentdocument.CreatedDate >=: strtDate AND contentdocument.CreatedDate <=: endDate AND ' + purgeCriteria.Field_Name__c +' '+purgeCriteria.Operation__c +' \''+purgeCriteria.Value__c+'\'';
        }        
        system.debug(strQuery);
        return Database.getQueryLocator(strQuery);
    }
    global void execute(Database.BatchableContext BC, list<sObject> scope) {
        List<contentdocumentlink> conDocLinkList = (contentdocumentlink[])scope;
        set<id> conDocSet = new set<id>();
        for(ContentDocumentLink conObj : conDocLinkList){
            conDocSet.add(conObj.ContentDocumentId);
        }
        List<ContentDocumentLink> conDocLinkExustList=new List<ContentDocumentLink>();
        //query all the content document related links
        conDocLinkExustList = [Select Id, LinkedEntityId, ContentDocumentId From ContentDocumentLink Where ContentDocumentId =: conDocSet];
        Map<Id,List<ContentDocumentLink>> condocIdLinkListMap=new Map<Id,List<ContentDocumentLink>>();
        for(ContentDocumentLink conObj:conDocLinkExustList){
            if(!condocIdLinkListMap.containsKey(conObj.ContentDocumentId)){
                condocIdLinkListMap.put(conObj.ContentDocumentId,new List<ContentDocumentLink>());
            }
            //check other than the record id and users if any other object is associated with the file
            if(conObj.LinkedEntityId != purgeCriteria.Value__c){
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
        ArchivedCaseDeleter.deleteContentDocument(delList);
    }
    global void finish(Database.BatchableContext BC) {
        
    }
    global void execute(SchedulableContext sc) {
        BatchDeleteOrphanfiles dFiles = new BatchDeleteOrphanfiles(strObjectName);
        Id batchId = Database.executeBatch(dFiles);
        
    }
}