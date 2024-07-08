/**
* Author   : Meghna@Maersk
* Purpose  : Used in CaseCollaboratorsAddition LWC for Task Creation
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-6304   21-Nov-2022   Meghna@Maersk           Used in CaseCollaboratorsAddition LWC Component
* 2.0      SC-9268   05-Dec-2023   ramadevi@maersk         searchkey has to be checked irrespective of case of the text
*/

public class CaseCollaboratorsController {
    
/*
* @description | SC-6304  Insert Tasks
* @param jsonOflistOfTasks accepts the listOfTasks
* @param caseId accepts the caseId
*/
    @AuraEnabled
    public static void insertTasks(String jsonOflistOfTasks, String caseId) {
        List<Task> lstTask = new List<Task>();
        Id caseCollaborationRecTypeId = StaticFactory.getRecordTypeIdByName('Task', 'Case Collaboration');        
        try{
            List<TaskWrapper> jsonTasks = (List<TaskWrapper>) JSON.deserialize(jsonOflistOfTasks, List<TaskWrapper>.class);
            for(TaskWrapper t:jsonTasks){
                Task newtask = new Task();
                newtask.OwnerId = t.Id;
                newtask.Description = t.Description;
                newtask.Subject = 'Case Collaboration';
                newtask.Status= 'Not Started';
                newtask.type = 'Other';
                newtask.RecordTypeId =caseCollaborationRecTypeId;
                newtask.WhatId = caseId;
                lstTask.add(newtask);
            }
            Database.SaveResult[] results = Database.insert(lstTask, false);  
            for(Database.SaveResult result: results) {
                if(!result.isSuccess()) {
                    system.debug('****err-->'+result.getErrors()[0].getMessage());
                    throw new AuraHandledException(result.getErrors()[0].getMessage());
                }
            }
        }
        catch(Exception e){
            system.debug('****e-->'+e.getMessage()+' '+e.getLineNumber());
            throw new AuraHandledException(Label.System_Error);
        }
    }
    
    
    
    /*
* @description | SC-6304  custom search
* @param searchKey accepts the searchKey
* @param sObjectApiName accepts the sObjectApiName
* @return list<sObject> containing list of records of the searched object
*/
    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey, string sObjectApiName, String caseId, List<String> selectedQueueIds) {
        system.debug('****searchKey-->'+searchKey);
        Set<String> caseVisibility = new Set<String>();        
        Set<String> queuesToSearch = new Set<String>();
        List<Group> lstQueue = new List<Group>();
        List<LinerBrand_Direction_and_Country__mdt> lstlbdc = new List<LinerBrand_Direction_and_Country__mdt>();
        List<LinerBrand_Direction_and_Country__mdt> lbdcList = LinerBrand_Direction_and_Country__mdt.getAll().values();
        Map<id,LinerBrand_Direction_and_Country__mdt> lbdcMap = new Map<id,LinerBrand_Direction_and_Country__mdt>();
        for(LinerBrand_Direction_and_Country__mdt lbdc : lbdcList){
            lbdcMap.put(lbdc.id,lbdc);
        }
        lstlbdc=[Select Id, Case_Visibility__c, QueueId__c,SF_4PL_Account__c From LinerBrand_Direction_and_Country__mdt Where QueueId__c != null];
        Case cs = [Select Id, Case_Visibility__c, Product__c, SF_4PL_Account__c From Case Where Id =: caseId];
        if(!String.isEmpty(cs.Case_Visibility__c) && cs.Case_Visibility__c == 'Multi-Carrier'){
            caseVisibility.add('Multi-Carrier');
            caseVisibility.add('4PL');
            system.debug('Visibility'+caseVisibility);
            for(LinerBrand_Direction_and_Country__mdt lbdc : lstlbdc){
                if(caseVisibility.contains(lbdc.Case_Visibility__c))
                    queuesToSearch.add(lbdc.QueueId__c);
            }
            
            //map<string,SCM_Key_Client_Country_Mapping__mdt> mapSCMKC = caserecordselector.mapAllSCMKC;
            map<string,SCM_Key_Client_Country_Mapping__mdt> mapSCMKC = SCM_Key_Client_Country_Mapping__mdt.getAll();
            for(SCM_Key_Client_Country_Mapping__mdt scmkc : mapSCMKC.values()){
                if(string.isnotblank(scmkc.QueueId__c)){
                    if(lbdcMap.get(scmkc.Relation_to_LBDC_metadata__c).Case_Visibility__c == 'Multi-Carrier'){
                        queuesToSearch.add(scmkc.QueueId__c);
                    }
                }
            }
        }
        else if(!String.isEmpty(cs.Case_Visibility__c) && cs.Case_Visibility__c == '4PL'){
            caseVisibility.add('4PL');
            for(LinerBrand_Direction_and_Country__mdt lbdc : lstlbdc){
                if(caseVisibility.contains(lbdc.Case_Visibility__c) && lbdc.SF_4PL_Account__c==cs.SF_4PL_Account__c)
                    queuesToSearch.add(lbdc.QueueId__c);
            }
        }
        
        
        List < sObject > returnList = new List < sObject > ();
        if(lstQueue.size()==0 || lstQueue.isEmpty()){
            lstQueue = [Select id,Name from Group where ID in : queuesToSearch and Type='Queue' order by createdDate];
        }

        for(Group gp:lstQueue){
            if(!selectedQueueids.contains(gp.id) && gp.name.containsIgnoreCase(searchKey)){
                returnList.add(gp);
                if(returnList.size()==5)
                    break;
            }
        }
        
        
        return returnList;
    }
    
    public class TaskWrapper{
        public String Name;
        public String Id;
        public String Description;
        public String index;
    }    
}