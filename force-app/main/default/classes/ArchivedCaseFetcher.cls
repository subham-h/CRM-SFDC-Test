public with sharing class ArchivedCaseFetcher {
    @AuraEnabled(Cacheable = true)
    public static list<Archived_Case__c> fetchCaseDetails(String recordId) {    list<Archived_Case__c> caseArch = [select id,Name,Subject__c,Description__c,case_Id__c,Account_Name__c,Account_Id__c,CreatedDate__c,OwnerId,Owner.Name,Case_Owner_Queue_Id__c,Case_Owner_Queue_Name__c from Archived_Case__c where Account_Id__c =:recordId];     
        return caseArch;
    }
}