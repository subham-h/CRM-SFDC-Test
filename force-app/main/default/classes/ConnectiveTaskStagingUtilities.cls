/**
 * Author   : Chakshu Malhotra
 * Purpose  : Utility class to hold simple and reusable functionalities for Connective Task Staging.
 * 
 * Revision     JIRA Story  Date        Owner                   Description
 * --------     ----------  ----------- -------------------     -----------
 * 1.0          SCTM-280    12/06/2020  Chakshu@Maersk          Created for implementing the CBO architecture.
 */
public class ConnectiveTaskStagingUtilities {

    private static final Integer INDEX_ONE = 1;
    private static final Integer INDEX_ZERO = 0;

    private static final String SERVICE_SEPARATOR = ' / ';
    private static final String CONSIGNEE_CODE_SEPARATOR = ';';

    private static final String CUSTOM_FIELD_SUFFIX = '__c';
    private static final String EXCEPTION_SOURCE_SYSTEM = 'SFDC';
    private static final String EXCEPTION_SOBJECT_STAGING = 'LS_TM_Connective_Task_Staging__c';
    private static final String EXCEPTION_TIME_PARSING_METHOD = 'populateMessageTimeInMicroseconds';

    private static final String TRANSACTION_TYPE_C = Label.LS_TM_CT_Transaction_Type_C;
    private static final String TRANSACTION_TYPE_U = Label.LS_TM_CT_Transaction_Type_U;

    private static final String DIRECTION_BOTH = Label.LS_TM_CT_Direction_Both;
    private static final String DIRECTION_ORIGIN = Label.LS_TM_CT_Direction_Origin;
    private static final String DIRECTION_DESTINATION = Label.LS_TM_CT_Direction_Destination;

    private static final String PROCESS_GROUP_DAIC = Label.LS_TM_CT_Record_Type_DAIC;
    private static final String PROCESS_GROUP_RM = Label.LS_TM_CT_Record_Type_Release_Management;

    private static final String TASK_STATUS_NEW = Label.LS_TM_CT_Status_New;
    private static final String TASK_STATUS_CLOSED_COMPLETED = Label.LS_TM_CT_Status_Closed_Completed;
    private static final String TASK_STATUS_CLOSED_CANCELLED = Label.LS_TM_CT_Status_Closed_Cancelled;

    private static final String REFERENCE_TYPE_BL = Label.LS_TM_CT_Reference_Type_BL;
    private static final String REFERENCE_TYPE_CS = Label.LS_TM_CT_Reference_Type_Container_Number;

    private static final String PROCESSING_TEAM_OPS = Label.LS_TM_CT_Processing_Team_Ops;

    private static final String SERVICE_CY_AT_DESTINATION = Label.LS_TM_CT_Service_CY_At_Destination;
    private static final Boolean SWITCH_TO_ASYNC_EXECUTION = Boolean.valueOf(Label.LS_TM_CT_Switch_to_Asynchronous_Execution);
    
    @TestVisible private static Boolean TEST_SWITCH_TO_ASYNC_EXECUTION = false;
    
    private static final String CONFIRM_DELIVERY_TASK = Label.LS_TM_CT_Confirm_Delivery_Task;
    private static final String REQUEST_DELIVERY_DATES_TASK = Label.LS_TM_CT_Request_Delivery_Dates_From_Customers_Task;

    private static final List<String> TASK_EXTERNAL_STATUS_CANCELLED = Label.LS_TM_CT_External_Status_Cancelled.toLowerCase().split(CONSIGNEE_CODE_SEPARATOR);
    private static final List<String> CY_DESTINATION_TASKS = Label.LS_TM_CT_Service_At_Destination_Milestone_Task.toLowerCase().split(CONSIGNEE_CODE_SEPARATOR);

    public static Map<String, String> getMoreToSapCountryMap() {
        List<LS_TM_CTM_MORE_SAP_Country_Mapping__mdt> moreSapCountriesMapping = [SELECT LS_TM_Country_Name_In_MORE__c, LS_TM_Country_Name_In_SAP__c
                                                                                 FROM LS_TM_CTM_MORE_SAP_Country_Mapping__mdt];

        Map<String, String> moreToSapCountryMap = new Map<String, String>();

        for(LS_TM_CTM_MORE_SAP_Country_Mapping__mdt moreSapCountryMapping : moreSapCountriesMapping) {
            moreToSapCountryMap.put(moreSapCountryMapping.LS_TM_Country_Name_In_SAP__c.toLowerCase(), moreSapCountryMapping.LS_TM_Country_Name_In_MORE__c);
        }

        return moreToSapCountryMap;
    }

    public static void updateMismatchedCountryNameFields(Map<String, String> moreToSapCountryMap, LS_TM_Connective_Task_Staging__c stagingTask, String porCountry, String processingCountry, String portOfLoadingCountry, String portOfDischargeCountry, String placeOfDeliveryCountry) {
        stagingTask.LS_TM_POR_Country__c = (porCountry <> null && moreToSapCountryMap.containsKey(porCountry.toLowerCase())) ? moreToSapCountryMap.get(porCountry.toLowerCase()) : porCountry;
        stagingTask.LS_TM_Processing_Country__c = (processingCountry <> null && moreToSapCountryMap.containsKey(processingCountry.toLowerCase())) ? moreToSapCountryMap.get(processingCountry.toLowerCase()) : processingCountry;
        stagingTask.LS_TM_Port_of_Loading_Country__c = (portOfLoadingCountry <> null && moreToSapCountryMap.containsKey(portOfLoadingCountry.toLowerCase())) ? moreToSapCountryMap.get(portOfLoadingCountry.toLowerCase()) : portOfLoadingCountry;
        stagingTask.LS_TM_Port_of_Discharge_Country__c = (portOfDischargeCountry <> null && moreToSapCountryMap.containsKey(portOfDischargeCountry.toLowerCase())) ? moreToSapCountryMap.get(portOfDischargeCountry.toLowerCase()) : portOfDischargeCountry;
        stagingTask.LS_TM_Place_of_Delivery_Country__c = (placeOfDeliveryCountry <> null && moreToSapCountryMap.containsKey(placeOfDeliveryCountry.toLowerCase())) ? moreToSapCountryMap.get(placeOfDeliveryCountry.toLowerCase()) : placeOfDeliveryCountry;
    }
    
    public static Map<String, List<String>> getReferenceTypeToCountryReferenceMap() {
        List<LS_TM_Connective_Task_Country_Mapping__mdt> countriesMapping = [SELECT LS_TM_Country_Reference__c, LS_TM_External_Reference_Type__c
                                                                             FROM LS_TM_Connective_Task_Country_Mapping__mdt];
        
        Map<String, List<String>> refTypeToCountryRefMap = new Map<String, List<String>>();

        for(LS_TM_Connective_Task_Country_Mapping__mdt countryMapping : countriesMapping) {
            refTypeToCountryRefMap.put(countryMapping.LS_TM_External_Reference_Type__c.toLowerCase(), countryMapping.LS_TM_Country_Reference__c.toLowerCase().split(CONSIGNEE_CODE_SEPARATOR));
        }

        return refTypeToCountryRefMap;
    }
    
    public static void populateTaskWrapper(ConnectiveTaskStagingWrappers.TaskWrapper taskWrapper, LS_TM_Connective_Task_Staging__c stagingTask) {
        LS_TM_Connective_Task_Staging__c wrappedStagingTask = taskWrapper.stagingTask;

        String transactionType = (wrappedStagingTask == null) ? stagingTask.LS_TM_Transaction_Type__c.trim() : taskWrapper.transactionType;
        Boolean isTransactionTypeC =  transactionType.equalsIgnoreCase(TRANSACTION_TYPE_C) || stagingTask.LS_TM_Transaction_Type__c.trim().equalsIgnoreCase(TRANSACTION_TYPE_C);
        
        taskWrapper.stagingTask = stagingTask;
        taskWrapper.transactionType = isTransactionTypeC ? TRANSACTION_TYPE_C : transactionType;
    }

    public static Set<String> getExisitingMoreIdentifiers(Map<String, ConnectiveTaskStagingWrappers.TaskWrapper> taskWrapperMap) {
        Set<String> existingMoreIdentifiers = new Set<String>();

        for(String moreIdentifier : taskWrapperMap.keySet()) {
            ConnectiveTaskStagingWrappers.TaskWrapper taskWrapper = taskWrapperMap.get(moreIdentifier);
            if(taskWrapper.transactionType.equalsIgnoreCase(TRANSACTION_TYPE_U)) {
                existingMoreIdentifiers.add(moreIdentifier);
            }
        }

        return existingMoreIdentifiers;
    }

    public static List<LS_TM_Connective_Task__c> getExistingTasks(Set<String> moreIdentifiers) {
        return [SELECT Id, OwnerId, RecordTypeId, LS_TM_MORE_Identifier__c, LS_TM_Key_Identifier__c, LS_TM_External_Reference_Type__c, 
                LS_TM_Task__c, LS_TM_Status__c, LS_TM_Due_Date__c, LS_TM_Visible_Date__c, LS_TM_Service__c, LS_TM_External_Reference_Number__c, 
                LS_TM_External_Reference_Status__c, LS_TM_Related_B_Ls__c, LS_TM_Consignee_BE_Code__c, LS_TM_Consignee_Name__c, 
                LS_TM_Shipper_BE_Code__c, LS_TM_Shipper_Name__c, LS_TM_CBL_Number__c, LS_TM_Carrier_Details__c, LS_TM_Container_Details__c, 
                LS_TM_Document_Pouch_Released_Date__c, LS_TM_ETA_Date__c, LS_TM_ATA_Date__c, LS_TM_ETD_Date__c, LS_TM_ATD_Date__c, 
                LS_TM_Planned_Delivery_Date__c, LS_TM_Actual_Delivery_Date__c, LS_TM_Port_of_Loading_City__c, LS_TM_Port_of_Loading_Country__c, 
                LS_TM_Port_of_Discharge_City__c, LS_TM_Port_of_Discharge_Country__c, LS_TM_Place_of_Delivery_City__c, LS_TM_Place_of_Delivery_Country__c, 
                LS_TM_Multiple_Consignee_Shipper__c, LS_TM_ARD__c, LS_TM_Booking_Source__c, LS_TM_Carrier_BCD__c, LS_TM_CS_Stuffed_Date__c, 
                LS_TM_ERD__c, LS_TM_ESD__c, LS_TM_SO_Booked_Date__c, LS_TM_SO_Confirmed_Date__c, LS_TM_FCR_Pending_Date__c, 
                LS_TM_FCR_Invoiced_Date__c, LS_TM_FCR_Released_Date__c, LS_TM_BL_Released_Date__c, LS_TM_POR_City__c, LS_TM_POR_Country__c, 
                LS_TM_SI_Status__c, LS_TM_Closure_Date__c, LS_TM_FCR_Status_Date__c, LS_TM_ETS_Created_Date__c, LS_TM_Consignee_FACT_Code__c, 
                LS_TM_Shipper_FACT_Code__c, LS_TM_Processing_Country__c, LS_TM_Complete_Invoicing_Date__c, LS_TM_Proposed_Billing_Date__c, 
                LS_TM_ESSO_Created_Date__c, LS_TM_ISSO_Created_Date__c, LS_TM_Sales_Order__c, LS_TM_Actual_Billing_Date__c
                FROM LS_TM_Connective_Task__c
                WHERE LS_TM_MORE_Identifier__c IN :moreIdentifiers];
    }

    public static List<LS_TM_Connective_Task_Rule__c> getConnectiveTaskRules(Id ownershipRecordTypeId, Id taskDefRuleRecordTypeId, String globalTriageQueue) {
        ConnectiveTaskStagingWrappers stagingWrapperInstance = ConnectiveTaskStagingWrappers.getInstance();

        Set<String> referenceTypes = stagingWrapperInstance.referenceTypes;
        Set<String> processCountries = stagingWrapperInstance.processCountries;

        return [SELECT Id, RecordTypeId, LS_TM_Task_Name__c, LS_TM_Reference_Type__c, LS_TM_Processing_Team__c, LS_TM_Country__c, 
                LS_TM_Process_Group__c, LS_TM_Queue_Name__c, LS_TM_Queue_ID__c, LS_TM_Due_Date_Reference__c, LS_TM_No_of_Days_for_Due__c, 
                LS_TM_Visible_Date_Reference__c, LS_TM_No_of_Days_for_Visible_condition__c, LS_TM_Direction__c, LS_TM_Country_Reference__c, 
                LS_TM_Closure_Date_Ref__c, LS_TM_No_of_Days_for_Closure__c, LS_TM_Applicable_BE_Codes__c
                FROM LS_TM_Connective_Task_Rule__c
                WHERE (RecordTypeId = :taskDefRuleRecordTypeId AND LS_TM_Country__c IN :processCountries AND LS_TM_Reference_Type__c IN :referenceTypes) OR
                (RecordTypeId = :ownershipRecordTypeId AND (LS_TM_Country__c IN :processCountries OR LS_TM_Queue_Name__c = :globalTriageQueue))];
    }

    public static void populateTaskDefRuleMap(String refType, LS_TM_Connective_Task_Rule__c taskRule, Map<String, Map<String, LS_TM_Connective_Task_Rule__c>> taskDefRuleMap) {
        String taskKey = taskRule.LS_TM_Task_Name__c.toLowerCase();
        String countryRefTypeKey = (taskRule.LS_TM_Country__c + refType).toLowerCase();
        Boolean containsCountryRefTypeKey = taskDefRuleMap.containsKey(countryRefTypeKey);
        Map<String, LS_TM_Connective_Task_Rule__c> taskNameToRuleMap = containsCountryRefTypeKey ? taskDefRuleMap.get(countryRefTypeKey) : new Map<String, LS_TM_Connective_Task_Rule__c>();
        taskNameToRuleMap.put(taskKey, taskRule);
        taskDefRuleMap.put(countryRefTypeKey, taskNameToRuleMap);
    }

    public static void populateCountryToQueueIdMap(String country, String countryQueueId, Map<String, Id> countryToQueueIdMap) {
        if(String.isNotBlank(country)) {
            countryToQueueIdMap.put(country.toLowerCase(), Id.valueOf(countryQueueId));
        }
    }

    public static Map<String, Id> getTaskRecordTypeMap() {
        Map<String, Id> taskRecordTypeMap = new Map<String, Id>();
        Map<String, Schema.RecordTypeInfo> taskRecordTypeInfoMap = Schema.SObjectType.LS_TM_Connective_Task__c.getRecordTypeInfosByName();

        for(String recordTypeName : taskRecordTypeInfoMap.keySet()) {
            taskRecordTypeMap.put(recordTypeName.toLowerCase(), taskRecordTypeInfoMap.get(recordTypeName).getRecordTypeId());
        }

        return taskRecordTypeMap;
    }

    public static Set<String> getStagingFieldsToIgnoreComparison() {
        Set<String> stagingFields = new Set<String>();
        stagingFields.add(LS_TM_Connective_Task_Staging__c.LS_TM_Status__c.getDescribe().getName().toLowerCase());
        stagingFields.add(LS_TM_Connective_Task_Staging__c.LS_TM_External_Reference_Number__c.getDescribe().getName().toLowerCase());
        return stagingFields;
    }

    public static void populateConnectiveTasks(String moreIdentifier, ConnectiveTaskStagingWrappers.TaskWrapper taskWrapper, ConnectiveTaskStagingWrappers stagingWrapperInstance) {
        String refTypeKey = taskWrapper.stagingTask.LS_TM_External_Reference_Type__c.toLowerCase();

        for(String countryFieldReference : stagingWrapperInstance.refTypeToCountryRefMap.get(refTypeKey)) {
            if(taskWrapper.stagingTask.get(countryFieldReference) != null) {
                String countryKey = ((String)taskWrapper.stagingTask.get(countryFieldReference)).trim().toLowerCase();

                if(taskWrapper.transactionType.equalsIgnoreCase(TRANSACTION_TYPE_C)) {
                    populateConnectiveTasksForTransactionTypeCreate(moreIdentifier, refTypeKey, countryKey, countryFieldReference, taskWrapper, stagingWrapperInstance);
                }else if(taskWrapper.transactionType.equalsIgnoreCase(TRANSACTION_TYPE_U)) {
                    populateConnectiveTasksForTransactionTypeUpdate(moreIdentifier, refTypeKey, countryKey, countryFieldReference, taskWrapper, stagingWrapperInstance);
                }
            }
        }
    }

    private static void populateConnectiveTasksForTransactionTypeCreate(String moreIdentifier, String refTypeKey, String countryKey, String countryFieldReference, ConnectiveTaskStagingWrappers.TaskWrapper taskWrapper, ConnectiveTaskStagingWrappers stagingWrapperInstance) {
        String countryRefTypeKey = countryKey + refTypeKey;
        LS_TM_Connective_Task_Staging__c stagingTask = taskWrapper.stagingTask;

        Boolean containsCountryRefTypeKey = stagingWrapperInstance.taskRuleWrapper.taskDefRuleMap.containsKey(countryRefTypeKey);
        Map<String, LS_TM_Connective_Task_Rule__c> taskNameToRuleMap = containsCountryRefTypeKey ? stagingWrapperInstance.taskRuleWrapper.taskDefRuleMap.get(countryRefTypeKey) : new Map<String, LS_TM_Connective_Task_Rule__c>();
        Map<String, Boolean> dependentTaskValidityMap = getDependentTaskValidityMap(refTypeKey, stagingTask, taskNameToRuleMap);

        for(String taskNameKey : taskNameToRuleMap.keySet()) {
            LS_TM_Connective_Task_Rule__c taskRule = taskNameToRuleMap.get(taskNameKey);
            Boolean isTaskApplicable = isTaskApplicableForOpsOrFinops(countryFieldReference, stagingTask.LS_TM_Consignee_BE_Code__c, taskRule);
            
            if(isTaskApplicable && isValidConnectiveTask(true, null, stagingTask, taskRule, dependentTaskValidityMap)) {
                String keyIdentifier = moreIdentifier + taskNameKey;
                Id taskOwnerId = getQueueIdForTask(stagingWrapperInstance.taskRuleWrapper.globalTriageQueueId, stagingWrapperInstance.taskRuleWrapper.countryToQueueIdMap, stagingTask, taskRule);
                stagingWrapperInstance.upsertTasksMap.put(keyIdentifier, getConnectiveTask(taskOwnerId, true, keyIdentifier, moreIdentifier, null, stagingTask, taskRule));
            }
        }
    }

    private static Map<String, Boolean> getDependentTaskValidityMap(String refTypeKey, LS_TM_Connective_Task_Staging__c stagingTask, Map<String, LS_TM_Connective_Task_Rule__c> taskNameToRuleMap) {
        Map<String, Boolean> dependentTaskValidityMap = new Map<String, Boolean>();

        if(refTypeKey.equalsIgnoreCase(REFERENCE_TYPE_CS)) {
            String confirmDeliveryTaskKey = CONFIRM_DELIVERY_TASK.toLowerCase();
            String requestDeliveryTaskKey = REQUEST_DELIVERY_DATES_TASK.toLowerCase();
            Boolean containsConfirmDeliveryTask = taskNameToRuleMap.containsKey(confirmDeliveryTaskKey);
            Boolean containsRequestDeliveryTask = taskNameToRuleMap.containsKey(requestDeliveryTaskKey);

            if(containsConfirmDeliveryTask && containsRequestDeliveryTask) {
                Date dateGmtToday = Datetime.now().dateGmt();
                String compositeKey = refTypeKey + confirmDeliveryTaskKey;
                LS_TM_Connective_Task_Rule__c taskRule = taskNameToRuleMap.get(requestDeliveryTaskKey);                
                dependentTaskValidityMap.put(compositeKey, isValidForAutoClosure(dateGmtToday, stagingTask, taskRule));
            }
        }

        return dependentTaskValidityMap;
    }

    private static Boolean isTaskApplicableForOpsOrFinops(String countryFieldReference, String beCode, LS_TM_Connective_Task_Rule__c taskRule) {
        String applicableBECodes = taskRule.LS_TM_Applicable_BE_Codes__c;
        Boolean isApplicableTask = countryFieldReference.equalsIgnoreCase(taskRule.LS_TM_Country_Reference__c);
        isApplicableTask = isApplicableTask && (taskRule.LS_TM_Processing_Team__c.equalsIgnoreCase(PROCESSING_TEAM_OPS) ? (beCode <> null && applicableBECodes <> null && isBECodeApplicable(beCode, applicableBECodes)) : true);
        return isApplicableTask;
    }

    private static Boolean isBECodeApplicable(String beCode, String applicableBECodes) {
        Boolean isBECodeApplicable = false;

        try {
            String beCodePattern = '((?<=;)|(?<=^))(' + beCode + ')((?=;)|(?=$))';
            isBECodeApplicable = Pattern.compile(beCodePattern).matcher(applicableBECodes).find();
        }catch(Exception ex) {
            isBECodeApplicable = containsSpecialBECode(beCode, applicableBECodes);
        }

        return isBECodeApplicable;
    }

    private static Boolean containsSpecialBECode(String beCode, String applicableBECodes) {
        Boolean containsSpecialBECode = false;
        Integer nextIndex = 0;
        Integer beCodeIndex = 0;
        Integer beCodeLength = beCode.length();
        Integer lastIndex = applicableBECodes.length() - 1;

        while(nextIndex <= lastIndex && beCodeIndex != -1 && !containsSpecialBECode) {
            beCodeIndex = applicableBECodes.indexOf(beCode, nextIndex);
            nextIndex = beCodeIndex + beCodeLength;
            Boolean charBeforeMatch = (beCodeIndex != -1 && (beCodeIndex == 0 || applicableBECodes.charAt(beCodeIndex - 1) == 59)) ? true : false;
            Boolean charAfterMatch = (beCodeIndex != -1 && (nextIndex == (lastIndex + 1) || applicableBECodes.charAt(nextIndex) == 59)) ? true : false;
            containsSpecialBECode = (charBeforeMatch && charAfterMatch);
        }

        return containsSpecialBECode;
    }

    private static Id getQueueIdForTask(Id globalTriageQueueId, Map<String, Id> countryToQueueIdMap, LS_TM_Connective_Task_Staging__c stagingTask, LS_TM_Connective_Task_Rule__c taskRule) {
        String direction = taskRule.LS_TM_Direction__c;
        String countryReference = taskRule.LS_TM_Country_Reference__c;
        String processCountry = String.isBlank(countryReference) ? '' : (String)stagingTask.get(countryReference.toLowerCase().trim());
        Boolean containsCountry = (String.isNotBlank(processCountry) && countryToQueueIdMap.containsKey(processCountry.toLowerCase()));
        return containsCountry ? countryToQueueIdMap.get(processCountry.toLowerCase()) : globalTriageQueueId;
    }

    private static Boolean isValidConnectiveTask(Boolean isNewTask, LS_TM_Connective_Task__c existingTask, LS_TM_Connective_Task_Staging__c stagingTask, LS_TM_Connective_Task_Rule__c taskRule, Map<String, Boolean> dependentTaskValidityMap) {
        String taskName = taskRule.LS_TM_Task_Name__c;
        String refType = taskRule.LS_TM_Reference_Type__c;
        String processGroup = taskRule.LS_TM_Process_Group__c;

        String dueDateRef = taskRule.LS_TM_Due_Date_Reference__c.toLowerCase();
        String visibleDateRef = taskRule.LS_TM_Visible_Date_Reference__c.toLowerCase();

        Set<String> stagingTaskFields = ConnectiveTaskStagingWrappers.getInstance().stagingTaskFields;
        Boolean isValidTask = stagingTaskFields.contains(dueDateRef) && stagingTaskFields.contains(visibleDateRef) && (isNewTask || existingTask.LS_TM_Status__c != TASK_STATUS_CLOSED_COMPLETED);

        if(isValidTask && refType.equalsIgnoreCase(REFERENCE_TYPE_BL)) {
            isValidTask = isTaskApplicableForBL(stagingTask, taskRule);

            if(isValidTask && processGroup.equalsIgnoreCase(PROCESS_GROUP_RM) && CY_DESTINATION_TASKS.contains(taskName.toLowerCase())) {
                Boolean isValidStagingService = isValidServiceAtDestination(stagingTask.LS_TM_Service__c);
                Boolean isValidTaskService = isNewTask ? true : isValidServiceAtDestination(existingTask.LS_TM_Service__c);
                isValidTask = isValidTask && isNewTask ? isValidStagingService : (isValidStagingService || isValidTaskService);
            }
        }

        String compositeKey = (refType + taskName).toLowerCase();
        isValidTask = (isValidTask && isNewTask && dependentTaskValidityMap.containsKey(compositeKey)) ? dependentTaskValidityMap.get(compositeKey) : isValidTask;

        return isValidTask;
    }

    private static Boolean isTaskApplicableForBL(LS_TM_Connective_Task_Staging__c stagingTask, LS_TM_Connective_Task_Rule__c taskRule) {
        String direction = taskRule.LS_TM_Direction__c;
        String applicableFor = stagingTask.LS_TM_Applicable_For__c;
        return String.isBlank(applicableFor) ? direction.equalsIgnoreCase(DIRECTION_DESTINATION) : (direction.equalsIgnoreCase(applicableFor) || applicableFor.equalsIgnoreCase(DIRECTION_BOTH));
        //return String.isNotBlank(applicableFor) && (direction.equalsIgnoreCase(applicableFor) || applicableFor.equalsIgnoreCase(DIRECTION_BOTH));
    }

    private static Boolean isValidServiceAtDestination(String service) {
        return String.isNotBlank(service) && service.split(SERVICE_SEPARATOR)[INDEX_ONE].equalsIgnoreCase(SERVICE_CY_AT_DESTINATION);
    }

    private static LS_TM_Connective_Task__c getConnectiveTask(Id taskOwnerId, Boolean isNewTask, String keyIdentifier, String moreIdentifier, LS_TM_Connective_Task__c existingTask, LS_TM_Connective_Task_Staging__c stagingTask, LS_TM_Connective_Task_Rule__c taskRule) {
        ConnectiveTaskStagingWrappers stagingWrapperInstance = ConnectiveTaskStagingWrappers.getInstance();
        
        Set<String> taskFields = stagingWrapperInstance.taskFields;
        LS_TM_Connective_Task__c connectiveTask = new LS_TM_Connective_Task__c(LS_TM_Key_Identifier__c = keyIdentifier);

        for(String stagingTaskField : stagingWrapperInstance.stagingTaskFields) {            
            if(stagingTaskField.endsWith(CUSTOM_FIELD_SUFFIX) && taskFields.contains(stagingTaskField) && (isNewTask || existingTask.get(stagingTaskField) != stagingTask.get(stagingTaskField))) {
                connectiveTask.put(stagingTaskField, stagingTask.get(stagingTaskField));
            }
        }

        Boolean isValidUpdate = isNewTask ? true : (connectiveTask.getPopulatedFieldsAsMap().size() > INDEX_ONE);

        if(isValidUpdate) {
            String processGroup = taskRule.LS_TM_Process_Group__c.toLowerCase();
            String externalStatus = stagingTask.LS_TM_External_Reference_Status__c;
            Boolean isCancelledStatus = String.isNotBlank(externalStatus) && TASK_EXTERNAL_STATUS_CANCELLED.contains(externalStatus.toLowerCase());

            Integer dueDateDays = Integer.valueOf(taskRule.LS_TM_No_of_Days_for_Due__c);
            Date dueDateRef = (Date) stagingTask.get(taskRule.LS_TM_Due_Date_Reference__c.toLowerCase());

            Integer visibleDateDays = Integer.valueOf(taskRule.LS_TM_No_of_Days_for_Visible_condition__c);
            Date visibleDateRef = (Date) stagingTask.get(taskRule.LS_TM_Visible_Date_Reference__c.toLowerCase());

            Date dateGmtToday = Datetime.now().dateGmt();
            Boolean isAutoClosureValid = isValidForAutoClosure(dateGmtToday, stagingTask, taskRule);
            
            connectiveTask.LS_TM_MORE_Identifier__c = moreIdentifier;
            connectiveTask.LS_TM_Task__c = taskRule.LS_TM_Task_Name__c;
            connectiveTask.OwnerId = isNewTask ? taskOwnerId : existingTask.OwnerId;
            connectiveTask.LS_TM_Closure_Date__c = isAutoClosureValid ? dateGmtToday : null;
            connectiveTask.RecordTypeId = stagingWrapperInstance.taskRecordTypeMap.get(processGroup);
            connectiveTask.LS_TM_Due_Date__c = (dueDateRef != null) ? dueDateRef.addDays(dueDateDays) : null;
            connectiveTask.LS_TM_Visible_Date__c = (visibleDateRef != null) ? visibleDateRef.addDays(visibleDateDays) : null;
            connectiveTask.LS_TM_Status__c = isAutoClosureValid ? TASK_STATUS_CLOSED_COMPLETED : isNewTask ? TASK_STATUS_NEW : isCancelledStatus ? TASK_STATUS_CLOSED_CANCELLED : existingTask.LS_TM_Status__c;
            connectiveTask.LS_TM_External_Reference_Number__c = processGroup.equalsIgnoreCase(PROCESS_GROUP_DAIC) ? stagingTask.LS_TM_Container_Number_Reference__c : stagingTask.LS_TM_External_Reference_Number__c;
        }
        
        return isValidUpdate ? connectiveTask : null;
    }

    private static Boolean isValidForAutoClosure(Date dateGmtToday, LS_TM_Connective_Task_Staging__c stagingTask, LS_TM_Connective_Task_Rule__c taskRule) {
        Boolean hasClosureDateRef = String.isNotBlank(taskRule.LS_TM_Closure_Date_Ref__c);
        Integer closureDateDays = hasClosureDateRef ? Integer.valueOf(taskRule.LS_TM_No_of_Days_for_Closure__c) : INDEX_ZERO;

        Date closureDateRef = hasClosureDateRef ? ((Date) stagingTask.get(taskRule.LS_TM_Closure_Date_Ref__c.toLowerCase())) : null;
        Date closureDate = (closureDateRef != null) ? closureDateRef.addDays(closureDateDays) : null;
        return (hasClosureDateRef && closureDate != null && closureDate <= dateGmtToday);
    }

    private static void populateConnectiveTasksForTransactionTypeUpdate(String moreIdentifier, String refTypeKey, String countryKey, String countryFieldReference, ConnectiveTaskStagingWrappers.TaskWrapper taskWrapper, ConnectiveTaskStagingWrappers stagingWrapperInstance) {
        String countryRefTypeKey = countryKey + refTypeKey;
        LS_TM_Connective_Task_Staging__c stagingTask = taskWrapper.stagingTask;

        Boolean containsCountryRefTypeKey = stagingWrapperInstance.taskRuleWrapper.taskDefRuleMap.containsKey(countryRefTypeKey);
        Map<String, LS_TM_Connective_Task_Rule__c> taskNameToRuleMap = containsCountryRefTypeKey ? stagingWrapperInstance.taskRuleWrapper.taskDefRuleMap.get(countryRefTypeKey) : new Map<String, LS_TM_Connective_Task_Rule__c>();
        Map<String, Boolean> dependentTaskValidityMap = getDependentTaskValidityMap(refTypeKey, stagingTask, taskNameToRuleMap);

        taskWrapper.existingTasksMap = (taskWrapper.existingTasksMap == null) ? new Map<String, LS_TM_Connective_Task__c>() : taskWrapper.existingTasksMap;

        for(String taskNameKey : taskNameToRuleMap.keySet()) {
            LS_TM_Connective_Task_Rule__c taskRule = taskNameToRuleMap.get(taskNameKey);

            Boolean isNewTask = !(taskWrapper.existingTasksMap.containsKey(taskNameKey));
            LS_TM_Connective_Task__c existingTask = isNewTask ? null : taskWrapper.existingTasksMap.get(taskNameKey);

            Boolean isTaskApplicable = isTaskApplicableForOpsOrFinops(countryFieldReference, stagingTask.LS_TM_Consignee_BE_Code__c, taskRule);

            if(isTaskApplicable && isValidConnectiveTask(isNewTask, existingTask, stagingTask, taskRule, dependentTaskValidityMap)) {
                String keyIdentifier = moreIdentifier + taskNameKey;
                Id taskOwnerId = getQueueIdForTask(stagingWrapperInstance.taskRuleWrapper.globalTriageQueueId, stagingWrapperInstance.taskRuleWrapper.countryToQueueIdMap, stagingTask, taskRule);
                LS_TM_Connective_Task__c connectiveTask = getConnectiveTask(taskOwnerId, isNewTask, keyIdentifier, moreIdentifier, existingTask, stagingTask, taskRule);
                
                if(connectiveTask != null) {
                    stagingWrapperInstance.upsertTasksMap.put(keyIdentifier, connectiveTask);
                }
            }
        }
    }

    public static void upsertConnectiveTasks(Set<Id> stagingTaskIds, List<LS_TM_Connective_Task__c> upsertConnectiveTasks) {
        ConnectiveTaskStagingWrappers stagingWrapperInstance = ConnectiveTaskStagingWrappers.getInstance();
        Map<String, ConnectiveTaskStagingWrappers.TaskWrapper> taskWrapperMap = stagingWrapperInstance.taskWrapperMap;

        Boolean swtichToAsyncExecution = Test.isRunningTest() ? TEST_SWITCH_TO_ASYNC_EXECUTION : SWITCH_TO_ASYNC_EXECUTION;

        if(swtichToAsyncExecution) {
            ConnectiveTaskRecordHandler.ConnectiveTaskRecordProcessor taskRecordProcessor = new ConnectiveTaskRecordHandler.ConnectiveTaskRecordProcessor(stagingTaskIds, upsertConnectiveTasks, taskWrapperMap);
            Id taskRecordProcessorJobId = System.enqueueJob(taskRecordProcessor);
        }else {
            ConnectiveTaskRecordHandler.bulkUpsertConnectiveTasks(stagingTaskIds, upsertConnectiveTasks, taskWrapperMap);
            ConnectiveTaskRecordHandler.bulkProcessConnectiveTaskStagingRecords(stagingWrapperInstance.taskStatusWrapper);
        }
    }
}