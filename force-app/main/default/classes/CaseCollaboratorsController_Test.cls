@isTest
public class CaseCollaboratorsController_Test {
    
    @testSetup static void setup() {
        Group gp = [Select id From Group Where Type = 'Queue' AND DeveloperName LIKE 'Case%' Order By DeveloperName DESC LIMIT 1];
        QueueSobject queObj = new QueueSobject();
        queObj.QueueId = gp.Id;
        queObj.SobjectType = 'Task';
        insert queObj;
    }
    
    @isTest
    static void testfetchLookupData1(){
        Group g = new Group(Type='Queue', Name='Queue Keyword:Qwerty');
        Test.startTest();
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        List<Case> lstCases = new List<Case>();
        CaseData_Test.createExternalCases();
        CaseData_Test.lstCases[0].case_visibility__c='Multi-Carrier';
        lstCases.addAll(CaseData_Test.lstCases);
        insert lstCases;
        insert g;
        String searchKey='Qwerty';
        String sObjectApiName = 'Group';
        List<String> selectedQueueIds = new List<String>();
        List<sObject> lstQueue = CaseCollaboratorsController.fetchLookupData(searchKey,sObjectApiName,lstCases[0].id,selectedQueueIds);
        System.assertEquals(0,lstQueue.size());
        Test.stopTest();
        
    }
    
    @isTest
    static void testfetchLookupData2(){
        Group g = new Group(Type='Queue', Name='Queue Keyword:Qwerty');
        Test.startTest();
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        List<Case> lstCases = new List<Case>();
        CaseData_Test.createExternalCases();
        CaseData_Test.lstCases[0].case_visibility__c='Multi-Carrier';
        lstCases.addAll(CaseData_Test.lstCases);
        insert lstCases;
        insert g;
        String searchKey='Qwerty';
        //String searchKey='SCM - Amazon - Europe';
        String sObjectApiName = 'Group';
        List<String> selectedQueueIds = new List<String>();
        List<sObject> lstQueue = CaseCollaboratorsController.fetchLookupData(searchKey,sObjectApiName,lstCases[0].id,selectedQueueIds);
        //system.debug('queue'+lstQueue[0]);
        //system.debug('Name'+lstQueue[0].get('Name'));
        System.assertEquals(0,lstQueue.size());
        Test.stopTest();
        
    }
    
    @isTest
    static void testinsertTask(){
        
        Group gp = [Select id From Group Where Type = 'Queue' AND DeveloperName LIKE 'Case%' Order By DeveloperName DESC LIMIT 1];
        Test.startTest();
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        List<Case> lstCases = new List<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        String tasks='[{"index":1,"Description":"hh","Id":"'+gp.id+'","Name":"Test"}]';
        system.debug('String'+tasks);
        insert lstCases;
		CaseCollaboratorsController.insertTasks(tasks,lstCases[0].id);
        List<Task> lsttask =[Select id from task where whatid=:lstCases[0].id];
        system.assertEquals(1,lsttask.size());
            
        Test.stopTest();
        
    }

}