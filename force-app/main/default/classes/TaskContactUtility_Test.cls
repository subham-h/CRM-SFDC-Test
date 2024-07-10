@isTest
public class TaskContactUtility_Test {
    
    public static integer iNumberOfTask = 5;
    public static list<Task> lstTasks;
    public static list<Case> lstCases;
    
    public static testMethod void populateContactTest(){
        lstCases = new List<Case>();
        TriggerExecutionController.skipAllTriggers(true);
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.conInstance = conInstance;
        
        
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        TriggerExecutionController.skipAllTriggers(false);
        insert lstCases; 
        
        Case caseId = [select Id,contactId from Case where id =: lstCases[0].Id];
        system.debug('@@@@@case'+caseId);
        lstTasks = new List<Task>();            
        for( Integer i=0; i < iNumberOfTask; i++ ){
            Task tsk = new Task();
            tsk.Subject = 'Call';
            tsk.Status = 'Not Started';
            tsk.Priority = 'Normal';
            tsk.ActivityDate = date.today();
            tsk.Notify_Assignee__c = true;
            tsk.type = 'Call';
            tsk.WhatId = caseId.Id;
            tsk.WhoId = null;
            lstTasks.add( tsk );
        }
        
        TriggerExecutionController.skipTaskTrigger(false);
        insert lstTasks;
        
        Task t = [select Id,WhoId,WhatId from task where Id =: lstTasks[0].Id];
        Case caseId1 = [select Id,contactId from Case where id =: lstCases[1].Id];
        
        t.WhoId = null;
        t.WhatId = caseId1.Id;
        TriggerExecutionController.skipTaskTrigger(false);
        update t;
             
    }
}