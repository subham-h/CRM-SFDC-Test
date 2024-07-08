/**
 * Author   : Chakshu Malhotra
 * Purpose  : Test class for ConnectiveTaskStagingTrigger.
 * 
 * Revision     JIRA Story  Date        Owner                   Description
 * --------     ----------  ----------- -------------------     -----------
 * 1.0          SCTM-280    12/06/2020  Chakshu@Maersk          Created for writing unit test cases for ConnectiveTaskStagingTrigger
 */
@isTest
private class ConnectiveTaskStagingTrigger_Test {

    private static final String TEST_CONSIGNEE_ADIDAS_QUEUE = 'Test Adidas';

    private static final String TEST_ORIGIN_COUNTRY_QUEUE = 'Test Israel';
    private static final String TEST_DESTINATION_COUNTRY_QUEUE = 'Test Spain';
    private static final String TEST_GLOBAL_TRIAGE_QUEUE = Label.LS_TM_CT_Global_Triage_Queue_Name;

    private static final String SOBJECT_TYPE_CONNECTIVE_TASK = 'LS_TM_Connective_Task__c';
    
    private static final String TEST_ISRAEL_ORIGIN_COUNTRY = 'Israel';
    private static final String TEST_SPAIN_DESTINATION_COUNTRY = 'Spain';
    private static final String TEST_APPLICABLE_BE_CODES = 'INADIDAS;USADIDAS;EUADIDAS;UKADIDAS;AUADIDAS;GEADIDAS;UKADI(001;RUADIDAS';

    private static final String TEST_CONSIGNEE_CODE = 'USAPPLE';
    private static final String TEST_ADIDAS_CONSIGNEE_CODE = 'UKADIDAS';
    private static final String TEST_SPECIAL_CONSIGNEE_CODE = 'UKADI(001';

    private static final String DIRECTION_ORIGIN = Label.LS_TM_CT_Direction_Origin;
    private static final String TEST_INTEGRATION_USER_LASTNAME = 'Test ESB Interface User';

    private static final String TASK_STATUS_NEW = Label.LS_TM_CT_Status_New;
    private static final String TASK_STATUS_CLOSED_COMPLETED = Label.LS_TM_CT_Status_Closed_Completed;
    private static final String TASK_STATUS_CLOSED_CANCELLED = Label.LS_TM_CT_Status_Closed_Cancelled;

    private static final String ASSERT_ERROR_OWNER = 'Not an expected Owner for the Task ';
    private static final String ASSERT_ERROR_STATUS = 'Not an expected Status for the Task ';
    private static final String ASSERT_ERROR_DUE_DATE = 'Not an expected Due Date for the Task ';
    private static final String ASSERT_ERROR_VISIBLE_DATE = 'Not an expected Visible Date for the Task ';
    private static final String ASSERT_ERROR_TASK_FAIL_CREATE = 'Connective task did not fail to create!';

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
                LS_TM_Processing_Country__c, LS_TM_ESSO_Created_Date__c, LS_TM_Proposed_Billing_Date__c, LS_TM_Complete_Invoicing_Date__c
                FROM LS_TM_Connective_Task__c];
    }

    private static void assertTestResults(Id originTaskOwnerId, Id destinationTaskOwnerId, String expectedStatus, String referenceType, ConnectiveTaskStagingWrappers wrapperInstance) {
        String refTypeKey = referenceType.toLowerCase();
        Map<String, Map<String, LS_TM_Connective_Task_Rule__c>> taskDefRuleMap = wrapperInstance.taskRuleWrapper.taskDefRuleMap;

        for(String countryFieldReference : wrapperInstance.refTypeToCountryRefMap.get(refTypeKey)) {
            for(LS_TM_Connective_Task__c connectiveTask : getConnectiveTasks()) {
                if(connectiveTask.get(countryFieldReference) != null) {
                    String taskName = connectiveTask.LS_TM_Task__c;

                    String countryKey = ((String)connectiveTask.get(countryFieldReference)).toLowerCase();
                    String countryRefTypeKey = countryKey + refTypeKey;

                    LS_TM_Connective_Task_Rule__c taskRule = taskDefRuleMap.get(countryRefTypeKey).get(taskName.toLowerCase());

                    if(!taskRule.LS_TM_Country_Reference__c.equalsIgnoreCase(countryFieldReference)) {
                        continue;
                    }
                    
                    Integer dueDateDays = Integer.valueOf(taskRule.LS_TM_No_of_Days_for_Due__c);
                    Integer visibleDateDays = Integer.valueOf(taskRule.LS_TM_No_of_Days_for_Visible_condition__c);

                    Date dueDateRef = (Date) connectiveTask.get(taskRule.LS_TM_Due_Date_Reference__c.toLowerCase());
                    Date visibleDateRef = (Date) connectiveTask.get(taskRule.LS_TM_Visible_Date_Reference__c.toLowerCase());
                    
                    Date expectedDueDate = (dueDateRef == null) ? null : dueDateRef.addDays(dueDateDays);
                    Date expectedVisibleDate = (visibleDateRef == null) ? null : visibleDateRef.addDays(visibleDateDays);

                    Id expectedOwnerId = taskRule.LS_TM_Direction__c.equalsIgnoreCase(DIRECTION_ORIGIN) ? originTaskOwnerId : destinationTaskOwnerId;

                    System.assertEquals(expectedOwnerId, connectiveTask.OwnerId, ASSERT_ERROR_OWNER + taskName);
                    System.assertEquals(expectedStatus, connectiveTask.LS_TM_Status__c, ASSERT_ERROR_STATUS + taskName);
                    System.assertEquals(expectedDueDate, connectiveTask.LS_TM_Due_Date__c, ASSERT_ERROR_DUE_DATE + taskName);
                    System.assertEquals(expectedVisibleDate, connectiveTask.LS_TM_Visible_Date__c, ASSERT_ERROR_VISIBLE_DATE + taskName);
                }
            }
        }
    }

    private static void updateConnectiveTasksAsCompleted() {
        List<LS_TM_Connective_Task__c> connectiveTasks = getConnectiveTasks();

        for(LS_TM_Connective_Task__c connectiveTask : connectiveTasks) {
            connectiveTask.OwnerId = UserInfo.getUserId();
            connectiveTask.LS_TM_Status__c = TASK_STATUS_CLOSED_COMPLETED;
        }

        update connectiveTasks;
    }

    @isTest
    private static void testCreateBLMessage() {
        User integrationUser = [SELECT Id FROM User WHERE LastName = :TEST_INTEGRATION_USER_LASTNAME LIMIT 1];
        LS_TM_Connective_Task_Staging__c newBLMessage = ConnectiveTaskTestUtility.getNewBLMessage(TEST_ADIDAS_CONSIGNEE_CODE, TEST_ISRAEL_ORIGIN_COUNTRY, TEST_SPAIN_DESTINATION_COUNTRY);

        Test.startTest();
        System.runAs(integrationUser) {
            insert newBLMessage;
        }
        Test.stopTest();

        ConnectiveTaskStagingWrappers wrapperInstance = ConnectiveTaskStagingWrappers.getInstance();

        Id originOwnerId = wrapperInstance.taskRuleWrapper.countryToQueueIdMap.get(TEST_ISRAEL_ORIGIN_COUNTRY.toLowerCase());
        Id destinationOwnerId = wrapperInstance.taskRuleWrapper.countryToQueueIdMap.get(TEST_SPAIN_DESTINATION_COUNTRY.toLowerCase());

        assertTestResults(originOwnerId, destinationOwnerId, TASK_STATUS_NEW, newBLMessage.LS_TM_External_Reference_Type__c, wrapperInstance);
    }

    @isTest
    private static void testCreateBLMessageWithSpecialBECode() {
        User integrationUser = [SELECT Id FROM User WHERE LastName = :TEST_INTEGRATION_USER_LASTNAME LIMIT 1];
        LS_TM_Connective_Task_Staging__c newBLMessage = ConnectiveTaskTestUtility.getNewBLMessage(TEST_SPECIAL_CONSIGNEE_CODE, TEST_ISRAEL_ORIGIN_COUNTRY, TEST_SPAIN_DESTINATION_COUNTRY);

        Test.startTest();
        System.runAs(integrationUser) {
            insert newBLMessage;
        }
        Test.stopTest();

        ConnectiveTaskStagingWrappers wrapperInstance = ConnectiveTaskStagingWrappers.getInstance();

        Id originOwnerId = wrapperInstance.taskRuleWrapper.countryToQueueIdMap.get(TEST_ISRAEL_ORIGIN_COUNTRY.toLowerCase());
        Id destinationOwnerId = wrapperInstance.taskRuleWrapper.countryToQueueIdMap.get(TEST_SPAIN_DESTINATION_COUNTRY.toLowerCase());

        assertTestResults(originOwnerId, destinationOwnerId, TASK_STATUS_NEW, newBLMessage.LS_TM_External_Reference_Type__c, wrapperInstance);
    }

    @isTest
    private static void testUpdateBLMessage() {
        User integrationUser = [SELECT Id FROM User WHERE LastName = :TEST_INTEGRATION_USER_LASTNAME LIMIT 1];
        LS_TM_Connective_Task_Staging__c newBLMessage = ConnectiveTaskTestUtility.getNewBLMessage(TEST_ADIDAS_CONSIGNEE_CODE, TEST_ISRAEL_ORIGIN_COUNTRY, TEST_SPAIN_DESTINATION_COUNTRY);
        
        System.runAs(integrationUser) {
            insert newBLMessage;
        }

        Test.startTest();
        LS_TM_Connective_Task_Staging__c updatedBLMessage = ConnectiveTaskTestUtility.getUpdatedBLMessage(TEST_ADIDAS_CONSIGNEE_CODE, TEST_ISRAEL_ORIGIN_COUNTRY, TEST_SPAIN_DESTINATION_COUNTRY);
        System.runAs(integrationUser) {
            insert updatedBLMessage;
        }
        Test.stopTest();

        ConnectiveTaskStagingWrappers wrapperInstance = ConnectiveTaskStagingWrappers.getInstance();

        Id originOwnerId = wrapperInstance.taskRuleWrapper.countryToQueueIdMap.get(TEST_ISRAEL_ORIGIN_COUNTRY.toLowerCase());
        Id destinationOwnerId = wrapperInstance.taskRuleWrapper.countryToQueueIdMap.get(TEST_SPAIN_DESTINATION_COUNTRY.toLowerCase());

        assertTestResults(originOwnerId, destinationOwnerId, TASK_STATUS_NEW, updatedBLMessage.LS_TM_External_Reference_Type__c, wrapperInstance);
    }

    @isTest
    private static void testCancelBLMessage() {
        User integrationUser = [SELECT Id FROM User WHERE LastName = :TEST_INTEGRATION_USER_LASTNAME LIMIT 1];
        LS_TM_Connective_Task_Staging__c newBLMessage = ConnectiveTaskTestUtility.getNewBLMessage(TEST_ADIDAS_CONSIGNEE_CODE, TEST_ISRAEL_ORIGIN_COUNTRY, TEST_SPAIN_DESTINATION_COUNTRY);
        
        System.runAs(integrationUser) {
            insert newBLMessage;
        }

        Test.startTest();
        LS_TM_Connective_Task_Staging__c updatedBLMessage = ConnectiveTaskTestUtility.getCancelledBLMessage(TEST_ADIDAS_CONSIGNEE_CODE, TEST_ISRAEL_ORIGIN_COUNTRY, TEST_SPAIN_DESTINATION_COUNTRY);
        System.runAs(integrationUser) {
            insert updatedBLMessage;
        }
        Test.stopTest();

        ConnectiveTaskStagingWrappers wrapperInstance = ConnectiveTaskStagingWrappers.getInstance();

        Id originOwnerId = wrapperInstance.taskRuleWrapper.countryToQueueIdMap.get(TEST_ISRAEL_ORIGIN_COUNTRY.toLowerCase());
        Id destinationOwnerId = wrapperInstance.taskRuleWrapper.countryToQueueIdMap.get(TEST_SPAIN_DESTINATION_COUNTRY.toLowerCase());
        
        assertTestResults(originOwnerId, destinationOwnerId, TASK_STATUS_CLOSED_CANCELLED, updatedBLMessage.LS_TM_External_Reference_Type__c, wrapperInstance);
    }

    @isTest
    private static void testUpdateClosedBLMessage() {
        User integrationUser = [SELECT Id FROM User WHERE LastName = :TEST_INTEGRATION_USER_LASTNAME LIMIT 1];
        LS_TM_Connective_Task_Staging__c newBLMessage = ConnectiveTaskTestUtility.getNewBLMessage(TEST_ADIDAS_CONSIGNEE_CODE, TEST_ISRAEL_ORIGIN_COUNTRY, TEST_SPAIN_DESTINATION_COUNTRY);
        
        System.runAs(integrationUser) {
            insert newBLMessage;
        }

        Test.startTest();
        updateConnectiveTasksAsCompleted();
        LS_TM_Connective_Task_Staging__c updatedBLMessage = ConnectiveTaskTestUtility.getCancelledBLMessage(TEST_ADIDAS_CONSIGNEE_CODE, TEST_ISRAEL_ORIGIN_COUNTRY, TEST_SPAIN_DESTINATION_COUNTRY);
        System.runAs(integrationUser) {
            insert updatedBLMessage;
        }
        Test.stopTest();

        ConnectiveTaskStagingWrappers wrapperInstance = ConnectiveTaskStagingWrappers.getInstance();
        Id expectedOwnerId = UserInfo.getUserId();
        
        assertTestResults(expectedOwnerId, expectedOwnerId, TASK_STATUS_CLOSED_COMPLETED, updatedBLMessage.LS_TM_External_Reference_Type__c, wrapperInstance);
    }

    @isTest
    private static void testAsyncCreateBLMessage() {
        User integrationUser = [SELECT Id FROM User WHERE LastName = :TEST_INTEGRATION_USER_LASTNAME LIMIT 1];
        LS_TM_Connective_Task_Staging__c newBLMessage = ConnectiveTaskTestUtility.getNewBLMessage(TEST_ADIDAS_CONSIGNEE_CODE, TEST_ISRAEL_ORIGIN_COUNTRY, TEST_SPAIN_DESTINATION_COUNTRY);
        ConnectiveTaskStagingUtilities.TEST_SWITCH_TO_ASYNC_EXECUTION = true;

        Test.startTest();
        System.runAs(integrationUser) {
            insert newBLMessage;
        }
        Test.stopTest();

        ConnectiveTaskStagingWrappers wrapperInstance = ConnectiveTaskStagingWrappers.getInstance();
        ConnectiveTaskRecordHandler.ConnectiveTaskStagingRecordProcessor stagingRecordProcessor = new ConnectiveTaskRecordHandler.ConnectiveTaskStagingRecordProcessor(wrapperInstance.taskStatusWrapper);
        System.enqueueJob(stagingRecordProcessor);

        Id originOwnerId = wrapperInstance.taskRuleWrapper.countryToQueueIdMap.get(TEST_ISRAEL_ORIGIN_COUNTRY.toLowerCase());
        Id destinationOwnerId = wrapperInstance.taskRuleWrapper.countryToQueueIdMap.get(TEST_SPAIN_DESTINATION_COUNTRY.toLowerCase());

        assertTestResults(originOwnerId, destinationOwnerId, TASK_STATUS_NEW, newBLMessage.LS_TM_External_Reference_Type__c, wrapperInstance);
    }

    @isTest
    private static void testFailCreateBLMessage() {
        User integrationUser = [SELECT Id FROM User WHERE LastName = :TEST_INTEGRATION_USER_LASTNAME LIMIT 1];
        LS_TM_Connective_Task_Staging__c failedBLMessage = ConnectiveTaskTestUtility.getFailedBLMessage(TEST_ADIDAS_CONSIGNEE_CODE, TEST_ISRAEL_ORIGIN_COUNTRY, TEST_SPAIN_DESTINATION_COUNTRY);

        Test.startTest();
        System.runAs(integrationUser) {
            insert failedBLMessage;
        }
        Test.stopTest();

        List<LS_TM_Connective_Task__c> connectiveTasks = getConnectiveTasks();
        System.assertEquals(true, connectiveTasks.isEmpty(), ASSERT_ERROR_TASK_FAIL_CREATE);
    }

    @isTest
    private static void testCreateCSMessage() {
        User integrationUser = [SELECT Id FROM User WHERE LastName = :TEST_INTEGRATION_USER_LASTNAME LIMIT 1];
        LS_TM_Connective_Task_Staging__c newCSMessage = ConnectiveTaskTestUtility.getNewCSMessage(TEST_ADIDAS_CONSIGNEE_CODE, TEST_ISRAEL_ORIGIN_COUNTRY, TEST_SPAIN_DESTINATION_COUNTRY);

        Test.startTest();
        System.runAs(integrationUser) {
            insert newCSMessage;
        }
        Test.stopTest();

        ConnectiveTaskStagingWrappers wrapperInstance = ConnectiveTaskStagingWrappers.getInstance();
        Id destinationOwnerId = wrapperInstance.taskRuleWrapper.countryToQueueIdMap.get(TEST_SPAIN_DESTINATION_COUNTRY.toLowerCase());

        assertTestResults(null, destinationOwnerId, TASK_STATUS_NEW, newCSMessage.LS_TM_External_Reference_Type__c, wrapperInstance);
    }

    @isTest
    private static void testUpdateCSMessage() {
        User integrationUser = [SELECT Id FROM User WHERE LastName = :TEST_INTEGRATION_USER_LASTNAME LIMIT 1];
        LS_TM_Connective_Task_Staging__c newCSMessage = ConnectiveTaskTestUtility.getNewCSMessage(TEST_ADIDAS_CONSIGNEE_CODE, TEST_ISRAEL_ORIGIN_COUNTRY, TEST_SPAIN_DESTINATION_COUNTRY);
        
        System.runAs(integrationUser) {
            insert newCSMessage;
        }

        Test.startTest();
        LS_TM_Connective_Task_Staging__c updatedCSMessage = ConnectiveTaskTestUtility.getUpdatedCSMessage(TEST_ADIDAS_CONSIGNEE_CODE, TEST_ISRAEL_ORIGIN_COUNTRY, TEST_SPAIN_DESTINATION_COUNTRY);
        System.runAs(integrationUser) {
            insert updatedCSMessage;
        }
        Test.stopTest();

        ConnectiveTaskStagingWrappers wrapperInstance = ConnectiveTaskStagingWrappers.getInstance();
        Id destinationOwnerId = wrapperInstance.taskRuleWrapper.countryToQueueIdMap.get(TEST_SPAIN_DESTINATION_COUNTRY.toLowerCase());

        assertTestResults(null, destinationOwnerId, TASK_STATUS_NEW, updatedCSMessage.LS_TM_External_Reference_Type__c, wrapperInstance);
    }

    @isTest
    private static void testCreateESSOMessage() {
        User integrationUser = [SELECT Id FROM User WHERE LastName = :TEST_INTEGRATION_USER_LASTNAME LIMIT 1];
        LS_TM_Connective_Task_Staging__c newESSOMessage = ConnectiveTaskTestUtility.getNewESSOMessage(TEST_ADIDAS_CONSIGNEE_CODE, TEST_ISRAEL_ORIGIN_COUNTRY, TEST_SPAIN_DESTINATION_COUNTRY);

        Test.startTest();
        System.runAs(integrationUser) {
            insert newESSOMessage;
        }
        Test.stopTest();

        ConnectiveTaskStagingWrappers wrapperInstance = ConnectiveTaskStagingWrappers.getInstance();
        Id originOwnerId = wrapperInstance.taskRuleWrapper.countryToQueueIdMap.get(TEST_ISRAEL_ORIGIN_COUNTRY.toLowerCase());

        assertTestResults(originOwnerId, null, TASK_STATUS_NEW, newESSOMessage.LS_TM_External_Reference_Type__c, wrapperInstance);
    }
}