/*
* test class CTM Module.
* 
 Date        Owner                         Description
*********************************************************************************************************************************  
3/1/2022    kusum.jha@maersk.com          Code created
3/1/2022    kusum.jha@maersk.com          testCreateConnectiveStaggingTask : testing the creation of connective task staging
3/2/2022    kusum.jha@maersk.com          testCreateConnectiveTask : testing the creation of connective task

*/

@isTest
public class CTMModuleTest {  

    private static final String TEST_CONSIGNEE_ADIDAS_QUEUE = 'Test Adidas';
    private static final String TEST_ORIGIN_COUNTRY_QUEUE = 'Test Israel';
    private static final String TEST_DESTINATION_COUNTRY_QUEUE = 'Test Spain';
    private static final String TEST_GLOBAL_TRIAGE_QUEUE = Label.LS_TM_CT_Global_Triage_Queue_Name;
    private static final String SOBJECT_TYPE_CONNECTIVE_TASK = 'LS_TM_Connective_Task__c';
    private static final String TEST_ISRAEL_ORIGIN_COUNTRY = 'Israel';
    private static final String TEST_SPAIN_DESTINATION_COUNTRY = 'Spain';
    private static final String TEST_APPLICABLE_BE_CODES = 'INADIDAS;USADIDAS;EUADIDAS;UKADIDAS;AUADIDAS;GEADIDAS;RUADIDAS';
    private static final String TEST_CONSIGNEE_CODE = 'USAPPLE';
    private static final String TEST_ADIDAS_CONSIGNEE_CODE = 'UKADIDAS';
    private static final String TEST_INTEGRATION_USER_LASTNAME = 'Test ESB Interface User';
    private static final String TASK_STATUS_CLOSED_COMPLETED = Label.LS_TM_CT_Status_Closed_Completed;
    private static final String CONFIRM_DELIVERY_TASK = Label.LS_TM_CT_Confirm_Delivery_Task;
    private static final String REQUEST_DELIVERY_DATES_TASK = Label.LS_TM_CT_Request_Delivery_Dates_From_Customers_Task;
    private static final String ASSERT_ERROR_CONFIRM_DELIVERY_TASK_FOUND = 'Record found for Connective Task ';
    private static final String ASSERT_ERROR_CONFIRM_DELIVERY_TASK_NOT_FOUND = 'Record not found for Connective Task ';
    
    private static final String CS_MORE_IDENTIFIER = 'CS54321';
    private static final String TRANSACTION_TYPE_C = Label.LS_TM_CT_Transaction_Type_C;
    private static final String CS_NUMBER = 'CSREF54321';
    private static final String SERVICE_TYPE_CFS = 'CFS';
    private static final String REFERENCE_TYPE_CS = Label.LS_TM_CT_Reference_Type_Container_Number;
    private static final String EXTERNAL_STATUS_RELEASED = 'Released';
    
    @TestSetup
    private static void testDataSetup() {
        User createdUser = TestDataFactoryHelper.createUser();
        System.runAs(CreatedUser)
        {
            User testIntegrationUser = ConnectiveTaskTestUtility.getTestIntegrationUser(TEST_INTEGRATION_USER_LASTNAME);
            Test.startTest();
            insert testIntegrationUser;

        ConnectiveTaskTestUtility.bypassValidationRulesForUser(testIntegrationUser.Id);

        Group testIsraelGroup = ConnectiveTaskTestUtility.getTestGroup(TEST_ORIGIN_COUNTRY_QUEUE);
        Group testAdidasGroup = ConnectiveTaskTestUtility.getTestGroup(TEST_CONSIGNEE_ADIDAS_QUEUE);
        Group testSpainGroup = ConnectiveTaskTestUtility.getTestGroup(TEST_DESTINATION_COUNTRY_QUEUE);
        Group testGlobalTriageGroup = ConnectiveTaskTestUtility.getGlobalTriageGroup(TEST_GLOBAL_TRIAGE_QUEUE);

        List<Group> lstTestGroups = new List<Group> {testAdidasGroup, testSpainGroup, testIsraelGroup};
        insert lstTestGroups;

        List<QueueSobject> lstTestQueues = new List<QueueSobject>();
        
        for(Group testGroup : lstTestGroups) {
            lstTestQueues.add(ConnectiveTaskTestUtility.getTestQueue(testGroup.Id, SOBJECT_TYPE_CONNECTIVE_TASK));
        }

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert lstTestQueues;
        }

        List<LS_TM_Connective_Task_Rule__c> lstTaskRules = new List<LS_TM_Connective_Task_Rule__c>();
        lstTaskRules.addAll(ConnectiveTaskTestUtility.getTestTaskDefinitionRules(true, TEST_ISRAEL_ORIGIN_COUNTRY, TEST_APPLICABLE_BE_CODES));
        lstTaskRules.addAll(ConnectiveTaskTestUtility.getTestTaskDefinitionRules(false, TEST_ISRAEL_ORIGIN_COUNTRY, TEST_APPLICABLE_BE_CODES));
        lstTaskRules.addAll(ConnectiveTaskTestUtility.getTestTaskDefinitionRules(true, TEST_SPAIN_DESTINATION_COUNTRY, TEST_APPLICABLE_BE_CODES));
        lstTaskRules.addAll(ConnectiveTaskTestUtility.getTestTaskDefinitionRules(false, TEST_SPAIN_DESTINATION_COUNTRY, TEST_APPLICABLE_BE_CODES));
        lstTaskRules.add(ConnectiveTaskTestUtility.getTestOwnershipRule(null, null, testGlobalTriageGroup));
        lstTaskRules.add(ConnectiveTaskTestUtility.getTestOwnershipRule(null, TEST_ISRAEL_ORIGIN_COUNTRY, testIsraelGroup));
        lstTaskRules.add(ConnectiveTaskTestUtility.getTestOwnershipRule(null, TEST_SPAIN_DESTINATION_COUNTRY, testSpainGroup));
        insert lstTaskRules;
        Test.stopTest();
        }
    }

   
	 @isTest
    public static void testCreateConnectiveStaggingTask()
    {
         
        Date dateToday = Date.today();
      	//creating a Connective Stagging Task
      	Test.startTest();
		LS_TM_Connective_Task_Staging__c connectiveStaggingTask =  new LS_TM_Connective_Task_Staging__c();
        
        connectiveStaggingTask.LS_TM_Consignee_BE_code__c = TEST_ADIDAS_CONSIGNEE_CODE;
        connectiveStaggingTask.LS_TM_External_Reference_Status__c = EXTERNAL_STATUS_RELEASED;
        connectiveStaggingTask.LS_TM_POR_Country__c = TEST_ISRAEL_ORIGIN_COUNTRY;
        connectiveStaggingTask.LS_TM_Place_of_Delivery_Country__c = TEST_SPAIN_DESTINATION_COUNTRY ;
        connectiveStaggingTask.LS_TM_Processing_Country__c = false ? TEST_ISRAEL_ORIGIN_COUNTRY : null;
        connectiveStaggingTask.LS_TM_ETD_Date__c = dateToday.addDays(2);
        connectiveStaggingTask.LS_TM_ATD_Date__c = dateToday.addDays(2);
        connectiveStaggingTask.LS_TM_ETA_Date__c = dateToday.addDays(8);
        connectiveStaggingTask.LS_TM_ATA_Date__c = dateToday.addDays(8);                
        connectiveStaggingTask.LS_TM_MORE_Identifier__c = CS_MORE_IDENTIFIER;
        connectiveStaggingTask.LS_TM_Transaction_Type__c = TRANSACTION_TYPE_C;
        connectiveStaggingTask.LS_TM_Container_Number_Reference__c = CS_NUMBER;
        connectiveStaggingTask.LS_TM_External_Reference_Type__c = REFERENCE_TYPE_CS;
        connectiveStaggingTask.LS_TM_Service__c = SERVICE_TYPE_CFS + ' / ' + SERVICE_TYPE_CFS;
        insert connectiveStaggingTask;        
       
        //quering the created Connective Stagging Task
        List<LS_TM_Connective_Task_Staging__c> lstCreatedConnectiveStaggingTask = [SELECT id from LS_TM_Connective_Task_Staging__c ];
        Test.stopTest();
        //testing the created Connective Stagging Task
        System.assertEquals(lstCreatedConnectiveStaggingTask.size(), 1,'create Connective Stagging Task');
                       
    }
   
    @isTest
    private static void testCreateConnectiveTask() {
        User integrationUser = [SELECT Id FROM User WHERE LastName = :TEST_INTEGRATION_USER_LASTNAME LIMIT 1];
        LS_TM_Connective_Task_Staging__c newCSMessage = ConnectiveTaskTestUtility.getNewCSMessage(TEST_ADIDAS_CONSIGNEE_CODE, TEST_ISRAEL_ORIGIN_COUNTRY, TEST_SPAIN_DESTINATION_COUNTRY);
        Test.startTest();
        System.runAs(integrationUser) {
            insert newCSMessage;
        }
       
        List<LS_TM_Connective_Task__c> lstConnectiveTasks = TestDataFactoryHelper.getConnectiveTasks();
        
         //quering the created Connective Stagging Task
        Test.stopTest();
        //testing the created Connective Stagging Task
        System.assertEquals(lstConnectiveTasks.size(), 4,'Connective Task size should be 4');
        System.assertEquals(TEST_ISRAEL_ORIGIN_COUNTRY, lstConnectiveTasks[0].LS_TM_POR_Country__c,'POR country should be same');
        System.assertEquals(TEST_SPAIN_DESTINATION_COUNTRY , lstConnectiveTasks[0].LS_TM_Place_of_Delivery_Country__c,'POD country should be same');
                
    }   
    
}