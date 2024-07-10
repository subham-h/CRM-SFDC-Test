/*
* Author   : Ayush.k@Maersk
* Purpose  : Utility test class for Integration Log Event Handler and Integration Log Trigger.
* Revision Ref Number  Date           Owner                   Description
* -------- ----------  -----------    -------------------     -----------
* 1.0       SS-5430    16-Nov-2022     Ayush.k@Maersk        To test the creation and updation of integration log for Non KC Case from platform event   
*/
@isTest
public class IntegrationLogEventHandler_Test {
	
    public static list<Case> lstCases = new list<Case>();
    public static list<Account> lstAccs = new list<Account>();
    public static list<LS_TM_Connective_Task__c> lstCTask = new list<LS_TM_Connective_Task__c>();
    
	@TestSetup
    public static void setupTestData() {
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        CaseData_Test.createExternalCasesII();
        lstCases.addAll(CaseData_Test.lstCases);
        lstCases[0].Origin = 'SCMSISVC';       
        insert lstCases;  
        
        AccountData_Test.iNumberOfAccounts = 1; 
        AccountData_Test.createClientAccounts();
		lstAccs.addAll(AccountData_Test.lstAccounts);
        
        Integer iNumberOfCTask = 1;
        for(integer j=0; j<iNumberOfCTask; j++) {
        	LS_TM_Connective_Task__c cTaskIterator = new LS_TM_Connective_Task__c();
            cTaskIterator.RecordTypeId = StaticFactory.getRecordTypeIdByName('LS_TM_Connective_Task__c', 'Cargo Stuffing');
         	cTaskIterator.LS_TM_External_Reference_Number__c = 'Ayu1234567';
            cTaskIterator.LS_TM_External_Reference_Type__c = 'SO';
            cTaskIterator.LS_TM_Consignee_Name__c = lstAccs[0].name;
            lstCTask.add(cTaskIterator);
  		}
        insert lstCTask;
        
    }
    
        @isTest
    private static void testInitalResponse(){
        
        Integration_Log_Event__e thisEvent = new Integration_Log_Event__e();
        String jsonResponse = '{\"status\": \"true\", \"request_id\": \"02s7748349-5001X00000KsTk0QAF-2022-12-21 08:27:40.131428\",\"message\":\"Information extraction initiated\"}';
       	thisEvent.JSON_Response__c = jsonResponse;
        
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(thisEvent);
        System.assertEquals(true, sr.isSuccess(),'Success');
        Test.stopTest();
    }
    
	@isTest
    private static void testUpdateResponse(){
        
    	list<Case> lstCases = new list<Case>([SELECT id FROM case Limit 1]);
        list<Account> lstAccs = new list<Account>([SELECT Id, name FROM account Limit 1]);
        list<LS_TM_Connective_Task__c> lstCTask = new list<LS_TM_Connective_Task__c>([SELECT Id,LS_TM_External_Reference_Number__c,LS_TM_Consignee_Name__c FROM LS_TM_Connective_Task__c limit 1]);
        
        Integration_Log_Event__e thisEvent = new Integration_Log_Event__e();
        String jsonResponse = '{\"caseId\":\"'+lstCases[0].id+'\",\"CustomerName\": \"'+lstAccs[0].name+'\",\"SoNumber\":\"'+lstCTask[0].LS_TM_External_Reference_Number__c+'\",\"customerNameExtracted\":\"'+lstAccs[0].name+'\"}';
        thisEvent.JSON_Response__c = jsonResponse;
        
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(thisEvent);
        System.assertEquals(true, sr.isSuccess(),'Success');
        Test.stopTest();
    }
    
    @isTest
    private static void testErrorResponse(){
        
        list<Case> lstCases = new list<Case>([SELECT id FROM case Limit 1]);
        
        Integration_Log_Event__e thisEvent = new Integration_Log_Event__e();
        String jsonResponse = '{\"status\":\"Update Fields\",\"caseId\":\"'+lstCases[0].id+'\"}';
        thisEvent.JSON_Response__c = jsonResponse;
        
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(thisEvent);
        System.assertEquals(true, sr.isSuccess(),'Success');
        Test.stopTest();
    }    
}