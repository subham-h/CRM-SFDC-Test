/**
 * Author   : Chakshu Malhotra
 * Purpose  : Utility class to create test data for ConnectiveTaskTrigger_Test & ConnectiveTaskStagingTrigger_Test.
 * 
 * Revision     JIRA Story  Date        Owner                   Description
 * --------     ----------  ----------- -------------------     -----------
 * 1.0          SCTM-280    12/06/2020  Chakshu@Maersk          Created for creating test data for ConnectiveTaskTrigger_Test & ConnectiveTaskStagingTrigger_Test
 * 2.0          SPI-100     09/06/2022  Ronnie@SF               Removed brand hardcoding
 */
 @isTest
public class ConnectiveTaskTestUtility {
    private static final Integer INDEX_ZERO = 0;

    private static final String GROUP_TYPE = 'Queue';
    private static final String INTEGRATION_USER_PROFILE = 'Integration User';

    private static final String RULES_RECORD_TYPE_OWNERSHIP = Label.LS_TM_CT_Rule_Record_Type_Ownership;
    private static final String RULES_RECORD_TYPE_TASK_DEF = Label.LS_TM_CT_Rule_Record_Type_Task_Definition;

    private static final String REFERENCE_TYPE_ESSO = 'ESSO';
    private static final String REFERENCE_TYPE_BL = Label.LS_TM_CT_Reference_Type_BL;
    private static final String REFERENCE_TYPE_CS = Label.LS_TM_CT_Reference_Type_Container_Number;

    private static final String PROCESS_GROUP_DAIC = Label.LS_TM_CT_Record_Type_DAIC;
    private static final String PROCESS_GROUP_AM = Label.LS_TM_CT_Record_Type_Arrival_Management;
    private static final String PROCESS_GROUP_RM = Label.LS_TM_CT_Record_Type_Release_Management;

    private static final String TRANSACTION_TYPE_C = Label.LS_TM_CT_Transaction_Type_C;
    private static final String TRANSACTION_TYPE_U = Label.LS_TM_CT_Transaction_Type_U;

    private static final String DIRECTION_BOTH = Label.LS_TM_CT_Direction_Both;
    private static final String DIRECTION_ORIGIN = Label.LS_TM_CT_Direction_Origin;
    private static final String DIRECTION_DESTINATION = Label.LS_TM_CT_Direction_Destination;

    private static final String BL_NUMBER = 'BLREF54321';
    private static final String BL_MORE_IDENTIFIER = 'BL54321';

    private static final String CS_NUMBER = 'CSREF54321';
    private static final String CS_MORE_IDENTIFIER = 'CS54321';

    private static final String SERVICE_TYPE_CY = 'CY';
    private static final String SERVICE_TYPE_CFS = 'CFS';

    private static final String EXTERNAL_STATUS_NA = 'NA';
    private static final String EXTERNAL_STATUS_UNKNOWN = 'Unknown';
    private static final String EXTERNAL_STATUS_RELEASED = 'Released';
    private static final String EXTERNAL_STATUS_CANCELLED = 'Cancelled';
    private static final String PROCESSING_TEAM_OPS = 'Ops';
    private static final String PROCESSING_TEAM_FINOPS = 'FinOps';

    private static final Map<String,Schema.RecordTypeInfo> TASK_RULES_RECORD_TYPES = Schema.SObjectType.LS_TM_Connective_Task_Rule__c.getRecordTypeInfosByName();
    

    public static User getTestIntegrationUser(String lastName) {
        BDA__c testBDA = getTestBDA();
        insert testBDA;

        Geography__c testGeography = getTestGeography();
        insert testGeography;

        Profile integrationUserProfile = [SELECT Id FROM Profile WHERE Name = :INTEGRATION_USER_PROFILE LIMIT 1];

        User testIntegrationUser = new User();
        testIntegrationUser.Alias = 'tuser';
        testIntegrationUser.LocaleSidKey = 'en_GB';
        testIntegrationUser.LanguageLocaleKey = 'en_US';
        testIntegrationUser.Maersk_User_id__c  = 'INT001';
        testIntegrationUser.EmailEncodingKey = 'ISO-8859-1';
        testIntegrationUser.TimeZoneSidKey = 'Europe/London';
        testIntegrationUser.CommunityNickname = 'dm1aasrsdfawr';
        testIntegrationUser.Email = 'testesbinterfaceuser@maersk.com';
        testIntegrationUser.Username = 'testesbinterfaceuser@maersk.com';
        testIntegrationUser.Liner_Brand__c = BrandUtilities.getAllBrandsString();
        testIntegrationUser.LastName = lastName;
        testIntegrationUser.Cluster__c = testBDA.Name;
        testIntegrationUser.Country = testGeography.Name;
        testIntegrationUser.ProfileId = integrationUserProfile.Id;
        testIntegrationUser.Country_Cluster_Sales_Manager__c = true;

        return testIntegrationUser;
    }

    private static BDA__c getTestBDA() {
        BDA__c testBDA = new BDA__c ();
        testBDA.Active__c = true;
        testBDA.Type__c = 'Cluster';
        testBDA.GEO_ID__c= 'dasdsaxced';
        testBDA.Name = 'Centre Function';
        testBDA.BDA_Code__c = 'dasdsaxced';
        testBDA.Default_Account_Owner__c = UserInfo.getUserId();
        return testBDA;
    }

    private static Geography__c getTestGeography() {
        Geography__c testGeography = new Geography__c();
        testGeography.Active__c = true;
        testGeography.GEO_Code__c = 'IN';
        testGeography.Is_Port__c = false;
        testGeography.Name = 'TESTCOUNTRY';
        testGeography.GEO_ID__c = '10Z2W9Zkjh3q4ab3';
        testGeography.Type_Of_Location__c = 'Country';
        return testGeography;
    }
    
    public static void bypassValidationRulesForUser(Id userId) {
        Validation_Rules_Bypass__c validationRulesBypass = new Validation_Rules_Bypass__c();
        validationRulesBypass.Active__c = true;
        validationRulesBypass.SetupOwnerId = userId;
        insert validationRulesBypass;
    }

    public static Group getTestGroup(String queueName) {
        return new Group(Name = queueName, Type = GROUP_TYPE);
    }

    public static Group getGlobalTriageGroup(String queueName) {
        return [SELECT Id, Name FROM Group WHERE Type = :GROUP_TYPE AND Name = :queueName];
    }

    public static QueuesObject getTestQueue(Id groupId, String sObjectTypeStr) {
        return new QueuesObject(QueueId = groupId, SObjectType = sObjectTypeStr);
    }

    public static List<LS_TM_Connective_Task_Rule__c> getTestTaskDefinitionRules(Boolean isOrigin, String country, String applicableBECodes) {
        List<LS_TM_Connective_Task_Rule__c> taskDefinitionRules = new List<LS_TM_Connective_Task_Rule__c>();

        if(isOrigin) {
            taskDefinitionRules.addAll(getTestTaskDefinitionRulesESSO(country, applicableBECodes));
            taskDefinitionRules.addAll(getTestTaskDefinitionRulesBLOrigin(country, applicableBECodes));
        }else {
            taskDefinitionRules.addAll(getTestTaskDefinitionRulesAM(country, applicableBECodes));
            taskDefinitionRules.addAll(getTestTaskDefinitionRulesRM(country, applicableBECodes));
            taskDefinitionRules.addAll(getTestTaskDefinitionRulesDAIC(country, applicableBECodes));
        }

        return taskDefinitionRules;
    }

    private static List<LS_TM_Connective_Task_Rule__c> getTestTaskDefinitionRulesBLOrigin(String country, String applicableBECodes) {
        List<Integer> daysForDue = new List<Integer> {-4, 1, 1, -2};
        List<Integer> daysForVisible = new List<Integer> {-7, 1, 0, -5};
        List<Integer> daysForClosure = new List<Integer> {0, null, 0, null};

        List<String> closureDateRefs = new List<String> {'LS_TM_BL_Released_Date__c', null, 'LS_TM_Document_Pouch_Released_Date__c', null};
        List<String> dueDateRefs = new List<String> {'LS_TM_ETD_Date__c', 'LS_TM_ATD_Date__c', 'LS_TM_ATD_Date__c', 'LS_TM_ETD_Date__c'};
        List<String> visibleDateRefs = new List<String> {'LS_TM_ETD_Date__c', 'LS_TM_ETD_Date__c', 'LS_TM_ETD_Date__c', 'LS_TM_ETD_Date__c'};
        
        List<String> processGroups = new List<String> {'Carrier SI', 'SWB Pre-Alert', 'SWB Pre-Alert', 'Compliance'};
        List<String> taskNames = new List<String> {'Submit SI To Carrier', 'Receive and Check draft SWB', 'Send Pre-Alert & upload documents', 'Clear Export Customs'};
        List<String> countryReferences = new List<String> {'LS_TM_POR_Country__c' ,'LS_TM_POR_Country__c', 'LS_TM_POR_Country__c', 'LS_TM_POR_Country__c'};

        List<LS_TM_Connective_Task_Rule__c> taskDefinitionRulesBLOrigin = new List<LS_TM_Connective_Task_Rule__c>();

        for(Integer ruleIndex = INDEX_ZERO; ruleIndex < taskNames.size(); ruleIndex++) {
            taskDefinitionRulesBLOrigin.add(getTestTaskDefinitionRule(country, applicableBECodes, PROCESSING_TEAM_OPS, REFERENCE_TYPE_BL, processGroups[ruleIndex], DIRECTION_ORIGIN, taskNames[ruleIndex], countryReferences[ruleIndex], visibleDateRefs[ruleIndex], daysForVisible[ruleIndex], dueDateRefs[ruleIndex], daysForDue[ruleIndex], closureDateRefs[ruleIndex], daysForClosure[ruleIndex]));
        }

        return taskDefinitionRulesBLOrigin;
    }

    private static List<LS_TM_Connective_Task_Rule__c> getTestTaskDefinitionRulesESSO(String country, String applicableBECodes) {
        List<Integer> daysForDue = new List<Integer> {1, 1, 10, -1, 9, 75};
        List<Integer> daysForVisible = new List<Integer> {0, 0, 0, -2, 5, 60};
        List<Integer> daysForClosure = new List<Integer> {null, null, null, 0, null, null};

        List<String> closureDateRefs = new List<String> {null, null, null, 'LS_TM_Complete_Invoicing_Date__c', null, null};
        List<String> dueDateRefs = new List<String> {'LS_TM_ETD_Date__c', 'LS_TM_ETD_Date__c', 'LS_TM_ETD_Date__c', 'LS_TM_Proposed_Billing_Date__c', 'LS_TM_ETD_Date__c', 'LS_TM_ETD_Date__c'};
        List<String> visibleDateRefs = new List<String> {'LS_TM_ESSO_Created_Date__c', 'LS_TM_ESSO_Created_Date__c', 'LS_TM_ESSO_Created_Date__c', 'LS_TM_Proposed_Billing_Date__c', 'LS_TM_ETD_Date__c', 'LS_TM_ETD_Date__c'};

        List<String> processGroups = new List<String> {'Origin Job Costing', 'Origin Job Costing', 'Origin Job Costing', 'Origin Job Costing', 'Origin Gross Profit Review', 'Origin Gross Profit Review'};
        List<String> taskNames = new List<String> {'Validate Revenue Charge', 'Validate Cost Charge', 'Validate Ad hoc / Non-Contracted Charges', 'Invoicing', 'Check Job Gross Profit', 'Perform Job Closure'};
        List<String> countryReferences = new List<String> {'LS_TM_Processing_Country__c', 'LS_TM_Processing_Country__c', 'LS_TM_Processing_Country__c', 'LS_TM_Processing_Country__c', 'LS_TM_Processing_Country__c', 'LS_TM_Processing_Country__c'};

        List<LS_TM_Connective_Task_Rule__c> taskDefinitionRulesESSO = new List<LS_TM_Connective_Task_Rule__c>();

        for(Integer ruleIndex = INDEX_ZERO; ruleIndex < taskNames.size(); ruleIndex++) {
            taskDefinitionRulesESSO.add(getTestTaskDefinitionRule(country, applicableBECodes, PROCESSING_TEAM_FINOPS, REFERENCE_TYPE_ESSO, processGroups[ruleIndex], DIRECTION_ORIGIN, taskNames[ruleIndex], countryReferences[ruleIndex], visibleDateRefs[ruleIndex], daysForVisible[ruleIndex], dueDateRefs[ruleIndex], daysForDue[ruleIndex], closureDateRefs[ruleIndex], daysForClosure[ruleIndex]));
        }

        return taskDefinitionRulesESSO;
    }

    private static List<LS_TM_Connective_Task_Rule__c> getTestTaskDefinitionRulesAM(String country, String applicableBECodes) {
        List<Integer> daysForDue = new List<Integer> {8, -3, 5};
        List<Integer> daysForVisible = new List<Integer> {2, -10, 4};
        List<Integer> daysForClosure = new List<Integer> {null, null, null};

        List<String> closureDateRefs = new List<String> {null, null, null};
        List<String> dueDateRefs = new List<String> {'LS_TM_ATD_Date__c' ,'LS_TM_ETA_Date__c', 'LS_TM_ETD_Date__c'};
        List<String> visibleDateRefs = new List<String> {'LS_TM_ATD_Date__c' ,'LS_TM_ETA_Date__c', 'LS_TM_ETD_Date__c'};
        
        List<String> taskNames = new List<String> {'Receive Pre-Alert and Documents', 'Receive Arrival Notice from Carrier', 'Send Arrival Report'};
        List<String> countryReferences = new List<String> {'LS_TM_Place_of_Delivery_Country__c' ,'LS_TM_Place_of_Delivery_Country__c', 'LS_TM_Place_of_Delivery_Country__c'};

        List<LS_TM_Connective_Task_Rule__c> taskDefinitionRulesAM = new List<LS_TM_Connective_Task_Rule__c>();

        for(Integer ruleIndex = INDEX_ZERO; ruleIndex < taskNames.size(); ruleIndex++) {
            taskDefinitionRulesAM.add(getTestTaskDefinitionRule(country, applicableBECodes, PROCESSING_TEAM_OPS, REFERENCE_TYPE_BL, PROCESS_GROUP_AM, DIRECTION_DESTINATION, taskNames[ruleIndex], countryReferences[ruleIndex], visibleDateRefs[ruleIndex], daysForVisible[ruleIndex], dueDateRefs[ruleIndex], daysForDue[ruleIndex], closureDateRefs[ruleIndex], daysForClosure[ruleIndex]));
        }

        return taskDefinitionRulesAM;
    }

    private static List<LS_TM_Connective_Task_Rule__c> getTestTaskDefinitionRulesRM(String country, String applicableBECodes) {
        List<Integer> daysForDue = new List<Integer> {0, 0, 0, 1};
        List<Integer> daysForVisible = new List<Integer> {-3, -5, -5, -2};
        List<Integer> daysForClosure = new List<Integer> {null, null, null, null};

        List<String> closureDateRefs = new List<String> {null, null, null, null};
        List<String> dueDateRefs = new List<String> {'LS_TM_ATA_Date__c' ,'LS_TM_ATA_Date__c', 'LS_TM_ATA_Date__c', 'LS_TM_ATA_Date__c'};
        List<String> visibleDateRefs = new List<String> {'LS_TM_ETA_Date__c' ,'LS_TM_ETA_Date__c', 'LS_TM_ETA_Date__c', 'LS_TM_ETA_Date__c'};
        
        List<String> taskNames = new List<String> {'Release SWB or OBL to consignee', 'Request Container Release', 'Release Container By Carrier', 'Clear Import Customs'};
        List<String> countryReferences = new List<String> {'LS_TM_Place_of_Delivery_Country__c' ,'LS_TM_Place_of_Delivery_Country__c', 'LS_TM_Place_of_Delivery_Country__c', 'LS_TM_Place_of_Delivery_Country__c'};

        List<LS_TM_Connective_Task_Rule__c> taskDefinitionRulesRM = new List<LS_TM_Connective_Task_Rule__c>();

        for(Integer ruleIndex = INDEX_ZERO; ruleIndex < taskNames.size(); ruleIndex++) {
            taskDefinitionRulesRM.add(getTestTaskDefinitionRule(country, applicableBECodes, PROCESSING_TEAM_OPS, REFERENCE_TYPE_BL, PROCESS_GROUP_RM, DIRECTION_DESTINATION, taskNames[ruleIndex], countryReferences[ruleIndex], visibleDateRefs[ruleIndex], daysForVisible[ruleIndex], dueDateRefs[ruleIndex], daysForDue[ruleIndex], closureDateRefs[ruleIndex], daysForClosure[ruleIndex]));
        }

        return taskDefinitionRulesRM;
    }

    private static List<LS_TM_Connective_Task_Rule__c> getTestTaskDefinitionRulesDAIC(String country, String applicableBECodes) {
        List<Integer> daysForDue = new List<Integer> {-2, -3, 0, 1, 0};
        List<Integer> daysForVisible = new List<Integer> {-5, -5, -3, -2, 1};
        List<Integer> daysForClosure = new List<Integer> {null, 0, null, null, 0};

        List<String> closureDateRefs = new List<String> {null, 'LS_TM_Planned_Delivery_Date__c', null, null, 'LS_TM_Actual_Delivery_Date__c'};
        List<String> dueDateRefs = new List<String> {'LS_TM_ETA_Date__c' ,'LS_TM_ETA_Date__c', 'LS_TM_ATA_Date__c', 'LS_TM_ATA_Date__c', 'LS_TM_Planned_Delivery_Date__c'};
        List<String> visibleDateRefs = new List<String> {'LS_TM_ETA_Date__c' ,'LS_TM_ETA_Date__c', 'LS_TM_ETA_Date__c', 'LS_TM_ETA_Date__c', 'LS_TM_Planned_Delivery_Date__c'};
        
        List<String> taskNames = new List<String> {'Deconsolidate Cargo', 'Request delivery dates from customers', 'Manage Intermodal Destination', 'Transport order confirmed', 'Confirm Delivery'};
        List<String> countryReferences = new List<String> {'LS_TM_Place_of_Delivery_Country__c' ,'LS_TM_Place_of_Delivery_Country__c', 'LS_TM_Place_of_Delivery_Country__c', 'LS_TM_Place_of_Delivery_Country__c', 'LS_TM_Place_of_Delivery_Country__c'};

        List<LS_TM_Connective_Task_Rule__c> taskDefinitionRulesDAIC = new List<LS_TM_Connective_Task_Rule__c>();

        for(Integer ruleIndex = INDEX_ZERO; ruleIndex < taskNames.size(); ruleIndex++) {
            taskDefinitionRulesDAIC.add(getTestTaskDefinitionRule(country, applicableBECodes, PROCESSING_TEAM_OPS, REFERENCE_TYPE_CS, PROCESS_GROUP_DAIC, DIRECTION_DESTINATION, taskNames[ruleIndex], countryReferences[ruleIndex], visibleDateRefs[ruleIndex], daysForVisible[ruleIndex], dueDateRefs[ruleIndex], daysForDue[ruleIndex], closureDateRefs[ruleIndex], daysForClosure[ruleIndex]));
        }
        return taskDefinitionRulesDAIC;
    }

    private static LS_TM_Connective_Task_Rule__c getTestTaskDefinitionRule(String country, String applicableBECodes, String processingTeam, String refType, String processGroup, String direction, String taskName, String countryReference, String visibleDateRef, Integer daysForVisible, String dueDateRef, Integer daysForDue, String closureDateRef, Integer daysForClosure) {        
        LS_TM_Connective_Task_Rule__c taskDefinitionRule = new LS_TM_Connective_Task_Rule__c();
        taskDefinitionRule.LS_TM_Country__c = country;
        taskDefinitionRule.LS_TM_Task_Name__c = taskName;
        taskDefinitionRule.LS_TM_Direction__c = direction;
        taskDefinitionRule.LS_TM_Reference_Type__c = refType;
        taskDefinitionRule.LS_TM_Process_Group__c = processGroup;
        taskDefinitionRule.LS_TM_Due_Date_Reference__c = dueDateRef;
        taskDefinitionRule.LS_TM_No_of_Days_for_Due__c = daysForDue;
        taskDefinitionRule.LS_TM_Processing_Team__c = processingTeam;
        taskDefinitionRule.LS_TM_Country_Reference__c = countryReference;
        taskDefinitionRule.LS_TM_Applicable_BE_Codes__c = applicableBECodes;
        taskDefinitionRule.LS_TM_Visible_Date_Reference__c = visibleDateRef;
        taskDefinitionRule.LS_TM_No_of_Days_for_Visible_condition__c = daysForVisible;
        taskDefinitionRule.LS_TM_Closure_Date_Ref__c = closureDateRef;
        taskDefinitionRule.LS_TM_No_of_Days_for_Closure__c = daysForClosure;
        taskDefinitionRule.RecordTypeId = TASK_RULES_RECORD_TYPES.get(RULES_RECORD_TYPE_TASK_DEF).getRecordTypeId();
        return taskDefinitionRule;
    }

    public static LS_TM_Connective_Task_Rule__c getTestOwnershipRule(String consigneeCodes, String country, Group testQueue) {
        LS_TM_Connective_Task_Rule__c ownershipRule = new LS_TM_Connective_Task_Rule__c();
        ownershipRule.LS_TM_Country__c = country;
        ownershipRule.LS_TM_Queue_ID__c = testQueue.Id;
        ownershipRule.LS_TM_Queue_Name__c = testQueue.Name;
        ownershipRule.RecordTypeId = TASK_RULES_RECORD_TYPES.get(RULES_RECORD_TYPE_OWNERSHIP).getRecordTypeId();
        return ownershipRule;
    }

    private static LS_TM_Connective_Task_Staging__c getNewStagingTask(Boolean isFinops, String consigneeCode, String originProcessCountry, String destinationProcessCountry, String externalStatus) {
        LS_TM_Connective_Task_Staging__c stagingTask = new LS_TM_Connective_Task_Staging__c();

        stagingTask.LS_TM_Consignee_BE_code__c = consigneeCode;
        stagingTask.LS_TM_External_Reference_Status__c = externalStatus;
        stagingTask.LS_TM_POR_Country__c = originProcessCountry;
        stagingTask.LS_TM_Place_of_Delivery_Country__c = destinationProcessCountry;
        stagingTask.LS_TM_Processing_Country__c = isFinops ? originProcessCountry : null;
        
        Date dateToday = Date.today();

        stagingTask.LS_TM_ETD_Date__c = dateToday.addDays(2);
        stagingTask.LS_TM_ATD_Date__c = dateToday.addDays(2);
        stagingTask.LS_TM_ETA_Date__c = dateToday.addDays(8);
        stagingTask.LS_TM_ATA_Date__c = dateToday.addDays(8);

        return stagingTask;
    }

    public static LS_TM_Connective_Task_Staging__c getNewBLMessage(String consigneeCode, String originProcessCountry, String destinationProcessCountry) {
        LS_TM_Connective_Task_Staging__c stagingTask = getNewStagingTask(false, consigneeCode, originProcessCountry, destinationProcessCountry, EXTERNAL_STATUS_RELEASED);
        stagingTask.LS_TM_MORE_Identifier__c = BL_MORE_IDENTIFIER;
        stagingTask.LS_TM_External_Reference_Number__c = BL_NUMBER;
        stagingTask.LS_TM_Transaction_Type__c = TRANSACTION_TYPE_C;
        stagingTask.LS_TM_Applicable_For__c = DIRECTION_BOTH;
        stagingTask.LS_TM_External_Reference_Type__c = REFERENCE_TYPE_BL;
        stagingTask.LS_TM_Service__c = SERVICE_TYPE_CFS + ' / ' + SERVICE_TYPE_CFS;
        return stagingTask;
    }

    public static LS_TM_Connective_Task_Staging__c getUpdatedBLMessage(String consigneeCode, String originProcessCountry, String destinationProcessCountry) {
        LS_TM_Connective_Task_Staging__c stagingTask = getNewStagingTask(false, consigneeCode, originProcessCountry, destinationProcessCountry, EXTERNAL_STATUS_RELEASED);
        stagingTask.LS_TM_MORE_Identifier__c = BL_MORE_IDENTIFIER;
        stagingTask.LS_TM_External_Reference_Number__c = BL_NUMBER;
        stagingTask.LS_TM_Transaction_Type__c = TRANSACTION_TYPE_U;
        stagingTask.LS_TM_Applicable_For__c = DIRECTION_BOTH;
        stagingTask.LS_TM_External_Reference_Type__c = REFERENCE_TYPE_BL;
        stagingTask.LS_TM_Service__c = SERVICE_TYPE_CFS + ' / ' + SERVICE_TYPE_CY;
        return stagingTask;
    }

    public static LS_TM_Connective_Task_Staging__c getCancelledBLMessage(String consigneeCode, String originProcessCountry, String destinationProcessCountry) {
        LS_TM_Connective_Task_Staging__c stagingTask = getNewStagingTask(false, consigneeCode, originProcessCountry, destinationProcessCountry, EXTERNAL_STATUS_CANCELLED);
        stagingTask.LS_TM_MORE_Identifier__c = BL_MORE_IDENTIFIER;
        stagingTask.LS_TM_External_Reference_Number__c = BL_NUMBER;
        stagingTask.LS_TM_Transaction_Type__c = TRANSACTION_TYPE_U;
        stagingTask.LS_TM_Applicable_For__c = DIRECTION_BOTH;
        stagingTask.LS_TM_External_Reference_Type__c = REFERENCE_TYPE_BL;
        stagingTask.LS_TM_Service__c = SERVICE_TYPE_CFS + ' / ' + SERVICE_TYPE_CFS;
        return stagingTask;
    }

    public static LS_TM_Connective_Task_Staging__c getFailedBLMessage(String consigneeCode, String originProcessCountry, String destinationProcessCountry) {
        LS_TM_Connective_Task_Staging__c stagingTask = getNewStagingTask(false, consigneeCode, originProcessCountry, destinationProcessCountry, EXTERNAL_STATUS_UNKNOWN);
        stagingTask.LS_TM_MORE_Identifier__c = BL_MORE_IDENTIFIER;
        stagingTask.LS_TM_External_Reference_Number__c = BL_NUMBER;
        stagingTask.LS_TM_Transaction_Type__c = TRANSACTION_TYPE_C;
        stagingTask.LS_TM_Applicable_For__c = DIRECTION_BOTH;
        stagingTask.LS_TM_External_Reference_Type__c = REFERENCE_TYPE_BL;
        stagingTask.LS_TM_Service__c = SERVICE_TYPE_CFS + ' / ' + SERVICE_TYPE_CFS;
        return stagingTask;
    }

    public static LS_TM_Connective_Task_Staging__c getNewCSMessage(String consigneeCode, String originProcessCountry, String destinationProcessCountry) {
        LS_TM_Connective_Task_Staging__c stagingTask = getNewStagingTask(false, consigneeCode, originProcessCountry, destinationProcessCountry, EXTERNAL_STATUS_RELEASED);
        stagingTask.LS_TM_MORE_Identifier__c = CS_MORE_IDENTIFIER;
        stagingTask.LS_TM_Transaction_Type__c = TRANSACTION_TYPE_C;
        stagingTask.LS_TM_Container_Number_Reference__c = CS_NUMBER;
        stagingTask.LS_TM_External_Reference_Type__c = REFERENCE_TYPE_CS;
        stagingTask.LS_TM_Service__c = SERVICE_TYPE_CFS + ' / ' + SERVICE_TYPE_CFS;
        return stagingTask;
    }

    public static LS_TM_Connective_Task_Staging__c getUpdatedCSMessage(String consigneeCode, String originProcessCountry, String destinationProcessCountry) {
        LS_TM_Connective_Task_Staging__c stagingTask = getNewStagingTask(false, consigneeCode, originProcessCountry, destinationProcessCountry, EXTERNAL_STATUS_RELEASED);
        stagingTask.LS_TM_MORE_Identifier__c = CS_MORE_IDENTIFIER;
        stagingTask.LS_TM_Transaction_Type__c = TRANSACTION_TYPE_U;
        stagingTask.LS_TM_Container_Number_Reference__c = CS_NUMBER;
        stagingTask.LS_TM_External_Reference_Type__c = REFERENCE_TYPE_CS;
        stagingTask.LS_TM_Service__c = SERVICE_TYPE_CFS + ' / ' + SERVICE_TYPE_CY;
        return stagingTask;
    }

    public static LS_TM_Connective_Task_Staging__c getNewESSOMessage(String consigneeCode, String originProcessCountry, String destinationProcessCountry) {
        LS_TM_Connective_Task_Staging__c stagingTask = getNewStagingTask(true, consigneeCode, originProcessCountry, destinationProcessCountry, EXTERNAL_STATUS_NA);
        stagingTask.LS_TM_MORE_Identifier__c = CS_MORE_IDENTIFIER;
        stagingTask.LS_TM_Transaction_Type__c = TRANSACTION_TYPE_C;
        stagingTask.LS_TM_Container_Number_Reference__c = CS_NUMBER;
        stagingTask.LS_TM_External_Reference_Type__c = REFERENCE_TYPE_ESSO;
        stagingTask.LS_TM_Service__c = SERVICE_TYPE_CFS + ' / ' + SERVICE_TYPE_CFS;
        return stagingTask;
    }
}