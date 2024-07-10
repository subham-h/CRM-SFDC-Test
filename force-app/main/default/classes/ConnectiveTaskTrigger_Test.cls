/**
 * Author   : Chakshu Malhotra
 * Purpose  : Test class for ConnectiveTaskTrigger.
 * 
 * Revision     JIRA Story  Date        Owner                   Description
 * --------     ----------  ----------- -------------------     -----------
 * 1.0          SCTM-280    13/07/2020  Chakshu@Maersk          Created for writing unit test cases for ConnectiveTaskTrigger
 */
@isTest
public class ConnectiveTaskTrigger_Test {

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
    
    @TestSetup
    private static void setupTestData() {
        User testIntegrationUser = ConnectiveTaskTestUtility.getTestIntegrationUser(TEST_INTEGRATION_USER_LASTNAME);
        insert testIntegrationUser;

        ConnectiveTaskTestUtility.bypassValidationRulesForUser(testIntegrationUser.Id);

        Group testIsraelGroup = ConnectiveTaskTestUtility.getTestGroup(TEST_ORIGIN_COUNTRY_QUEUE);
        Group testAdidasGroup = ConnectiveTaskTestUtility.getTestGroup(TEST_CONSIGNEE_ADIDAS_QUEUE);
        Group testSpainGroup = ConnectiveTaskTestUtility.getTestGroup(TEST_DESTINATION_COUNTRY_QUEUE);
        Group testGlobalTriageGroup = ConnectiveTaskTestUtility.getGlobalTriageGroup(TEST_GLOBAL_TRIAGE_QUEUE);

        List<Group> testGroups = new List<Group> {testAdidasGroup, testSpainGroup, testIsraelGroup};
        insert testGroups;

        List<QueueSobject> testQueues = new List<QueueSobject>();
        
        for(Group testGroup : testGroups) {
            testQueues.add(ConnectiveTaskTestUtility.getTestQueue(testGroup.Id, SOBJECT_TYPE_CONNECTIVE_TASK));
        }

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testQueues;
        }

        List<LS_TM_Connective_Task_Rule__c> taskRules = new List<LS_TM_Connective_Task_Rule__c>();
        taskRules.addAll(ConnectiveTaskTestUtility.getTestTaskDefinitionRules(true, TEST_ISRAEL_ORIGIN_COUNTRY, TEST_APPLICABLE_BE_CODES));
        taskRules.addAll(ConnectiveTaskTestUtility.getTestTaskDefinitionRules(false, TEST_ISRAEL_ORIGIN_COUNTRY, TEST_APPLICABLE_BE_CODES));
        taskRules.addAll(ConnectiveTaskTestUtility.getTestTaskDefinitionRules(true, TEST_SPAIN_DESTINATION_COUNTRY, TEST_APPLICABLE_BE_CODES));
        taskRules.addAll(ConnectiveTaskTestUtility.getTestTaskDefinitionRules(false, TEST_SPAIN_DESTINATION_COUNTRY, TEST_APPLICABLE_BE_CODES));
        taskRules.add(ConnectiveTaskTestUtility.getTestOwnershipRule(null, null, testGlobalTriageGroup));
        taskRules.add(ConnectiveTaskTestUtility.getTestOwnershipRule(null, TEST_ISRAEL_ORIGIN_COUNTRY, testIsraelGroup));
        taskRules.add(ConnectiveTaskTestUtility.getTestOwnershipRule(null, TEST_SPAIN_DESTINATION_COUNTRY, testSpainGroup));
        insert taskRules;
    }

    private static List<LS_TM_Connective_Task__c> getConnectiveTasks() {
        return [SELECT Id, OwnerId, LS_TM_Task__c, LS_TM_Status__c, LS_TM_Due_Date__c, LS_TM_Visible_Date__c, LS_TM_External_Reference_Type__c, 
                LS_TM_ETD_Date__c, LS_TM_ATD_Date__c, LS_TM_ETA_Date__c, LS_TM_ATA_Date__c, LS_TM_POR_Country__c, LS_TM_Place_of_Delivery_Country__c, 
                LS_TM_Processing_Country__c
                FROM LS_TM_Connective_Task__c];
    }

    private static LS_TM_Connective_Task__c getConfirmDeliveryConnectiveTask(List<LS_TM_Connective_Task__c> connectiveTasks) {
        LS_TM_Connective_Task__c confirmDeliveryTask = null;

        for(LS_TM_Connective_Task__c connectiveTask : connectiveTasks) {
            if(connectiveTask.LS_TM_Task__c.equalsIgnoreCase(CONFIRM_DELIVERY_TASK)) {
                confirmDeliveryTask = connectiveTask;
            }
        }

        return confirmDeliveryTask;
    }

    private static LS_TM_Connective_Task__c getRequestDeliveryDatesConnectiveTask(List<LS_TM_Connective_Task__c> connectiveTasks) {
        LS_TM_Connective_Task__c requestDeliveryDatesTask = null;

        for(LS_TM_Connective_Task__c connectiveTask : connectiveTasks) {
            if(connectiveTask.LS_TM_Task__c.equalsIgnoreCase(REQUEST_DELIVERY_DATES_TASK)) {
                requestDeliveryDatesTask = connectiveTask;
            }
        }

        return requestDeliveryDatesTask;
    }

    private static void updateRequestDeliveryDatesTask(Boolean isValid, List<LS_TM_Connective_Task__c> connectiveTasks) {
        LS_TM_Connective_Task__c requestDeliveryDatesTask = getRequestDeliveryDatesConnectiveTask(connectiveTasks);
        requestDeliveryDatesTask.OwnerId = UserInfo.getUserId();
        requestDeliveryDatesTask.LS_TM_Planned_Delivery_Date__c = Date.today().addDays(10);
        requestDeliveryDatesTask.LS_TM_Status__c = isValid ? TASK_STATUS_CLOSED_COMPLETED : requestDeliveryDatesTask.LS_TM_Status__c;
        update requestDeliveryDatesTask;
    }

    @isTest
    private static void testProcessInvalidRequestDeliveryDatesTasks() {
        User integrationUser = [SELECT Id FROM User WHERE LastName = :TEST_INTEGRATION_USER_LASTNAME LIMIT 1];
        LS_TM_Connective_Task_Staging__c newCSMessage = ConnectiveTaskTestUtility.getNewCSMessage(TEST_ADIDAS_CONSIGNEE_CODE, TEST_ISRAEL_ORIGIN_COUNTRY, TEST_SPAIN_DESTINATION_COUNTRY);
        
        System.runAs(integrationUser) {
            insert newCSMessage;
        }

        Test.startTest();
        List<LS_TM_Connective_Task__c> connectiveTasks = getConnectiveTasks();
        LS_TM_Connective_Task__c confirmDeliveryTask = getConfirmDeliveryConnectiveTask(connectiveTasks);

        System.assertEquals(null, confirmDeliveryTask, ASSERT_ERROR_CONFIRM_DELIVERY_TASK_FOUND + CONFIRM_DELIVERY_TASK);
        
        updateRequestDeliveryDatesTask(false, connectiveTasks);
        Test.stopTest();

        confirmDeliveryTask = getConfirmDeliveryConnectiveTask(getConnectiveTasks());
        System.assertEquals(null, confirmDeliveryTask, ASSERT_ERROR_CONFIRM_DELIVERY_TASK_FOUND + CONFIRM_DELIVERY_TASK);
    }
}