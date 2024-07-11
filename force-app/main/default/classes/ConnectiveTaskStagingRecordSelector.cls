/**
 * Author   : Chakshu Malhotra
 * Purpose  : Record Selector class for ConnectiveTaskStaging Trigger.
 * 
 * Revision     JIRA Story  Date        Owner                   Description
 * --------     ----------  ----------- -------------------     -----------
 * 1.0          SCTM-280    12/06/2020  Chakshu@Maersk          Created for implementing the CBO architecture.
 */
public class ConnectiveTaskStagingRecordSelector {

    private static final Integer SIZE_ZERO = 0;

    private static final String SEARCH_TEXT_WILDCARD = '%';
    private static final String REFERENCE_TYPE_SEPARATOR = ';';

    private static final String CT_GLOBAL_TRIAGE_QUEUE = Label.LS_TM_CT_Global_Triage_Queue_Name;
    private static final String RULES_RECORD_TYPE_OWNERSHIP = Label.LS_TM_CT_Rule_Record_Type_Ownership;
    private static final String RULES_RECORD_TYPE_TASK_DEF = Label.LS_TM_CT_Rule_Record_Type_Task_Definition;

    private static final List<String> SAP_FINOPS_REFERENCE_TYPES = Label.LS_TM_CT_Message_Type_Finops.toLowerCase().split(REFERENCE_TYPE_SEPARATOR);
    private static final Map<String,Schema.RecordTypeInfo> TASK_RULES_RECORD_TYPES = Schema.SObjectType.LS_TM_Connective_Task_Rule__c.getRecordTypeInfosByName();

    public static void updateCountryNameMismatch(List<LS_TM_Connective_Task_Staging__c> stagingTasks) {
        Map<String, String> moreToSapCountryMap = ConnectiveTaskStagingUtilities.getMoreToSapCountryMap();

        for(LS_TM_Connective_Task_Staging__c stagingTask : stagingTasks) {
            String referenceType = stagingTask.LS_TM_External_Reference_Type__c.trim().toLowerCase();

            if(SAP_FINOPS_REFERENCE_TYPES.contains(referenceType)) {
                String porCountry = stagingTask.LS_TM_POR_Country__c;
                String processingCountry = stagingTask.LS_TM_Processing_Country__c;
                String portOfLoadingCountry = stagingTask.LS_TM_Port_of_Loading_Country__c;
                String portOfDischargeCountry = stagingTask.LS_TM_Port_of_Discharge_Country__c;
                String placeOfDeliveryCountry = stagingTask.LS_TM_Place_of_Delivery_Country__c;
                ConnectiveTaskStagingUtilities.updateMismatchedCountryNameFields(moreToSapCountryMap, stagingTask, porCountry, processingCountry, portOfLoadingCountry, portOfDischargeCountry, placeOfDeliveryCountry);
            }
        }
    }
    
    public static void populateStagingWrapperMembers(List<LS_TM_Connective_Task_Staging__c> stagingTasks) {
        Set<String> processCountries = new Set<String>();
        Map<String, String> referenceTypeMap = new Map<String, String>();
        Map<String, String> originProcessCountryMap = new Map<String, String>();
        Map<String, String> destinationProcessCountryMap = new Map<String, String>();
        Map<String, ConnectiveTaskStagingWrappers.TaskWrapper> taskWrapperMap = new Map<String, ConnectiveTaskStagingWrappers.TaskWrapper>();
        
        Map<String, List<String>> refTypeToCountryRefMap = ConnectiveTaskStagingUtilities.getReferenceTypeToCountryReferenceMap();

        for(LS_TM_Connective_Task_Staging__c stagingTask : stagingTasks) {
            if(!stagingTask.LS_TM_Has_Error__c) {
                String moreIdentifier = stagingTask.LS_TM_MORE_Identifier__c.trim();
                String refType = stagingTask.LS_TM_External_Reference_Type__c.trim();
                Boolean containsIdentifier = taskWrapperMap.containsKey(moreIdentifier);

                ConnectiveTaskStagingWrappers.TaskWrapper taskWrapper = containsIdentifier ? taskWrapperMap.get(moreIdentifier) : new ConnectiveTaskStagingWrappers.TaskWrapper();
                ConnectiveTaskStagingUtilities.populateTaskWrapper(taskWrapper, stagingTask);
                taskWrapperMap.put(moreIdentifier, taskWrapper);
                
                referenceTypeMap.put(moreIdentifier, refType);
                
                if(refTypeToCountryRefMap.containsKey(refType.toLowerCase())) {
                    for(String countryFieldReference : refTypeToCountryRefMap.get(refType.toLowerCase())) {
                        if(stagingTask.get(countryFieldReference) != null) {
                            processCountries.add(((String)stagingTask.get(countryFieldReference)).trim());
                        }
                    }
                }
            }
        }

        ConnectiveTaskStagingWrappers stagingWrapperInstance = ConnectiveTaskStagingWrappers.getInstance();
        stagingWrapperInstance.taskWrapperMap = taskWrapperMap;
        stagingWrapperInstance.processCountries = processCountries;
        stagingWrapperInstance.refTypeToCountryRefMap = refTypeToCountryRefMap;
        stagingWrapperInstance.referenceTypes = new Set<String>(referenceTypeMap.values());
    }
    
    public static void populateExistingTasksForTransactionTypeUpdate() {
        ConnectiveTaskStagingWrappers stagingWrapperInstance = ConnectiveTaskStagingWrappers.getInstance();
        Map<String, ConnectiveTaskStagingWrappers.TaskWrapper> taskWrapperMap = stagingWrapperInstance.taskWrapperMap;
        
        Set<String> existingMoreIdentifiers = ConnectiveTaskStagingUtilities.getExisitingMoreIdentifiers(taskWrapperMap);
        List<LS_TM_Connective_Task__c> existingTasks = ConnectiveTaskStagingUtilities.getExistingTasks(existingMoreIdentifiers);

        for(LS_TM_Connective_Task__c existingTask : existingTasks) {
            String taskKey = existingTask.LS_TM_Task__c.toLowerCase();
            String moreIdentifier = existingTask.LS_TM_MORE_Identifier__c;

            ConnectiveTaskStagingWrappers.TaskWrapper taskWrapper = taskWrapperMap.get(moreIdentifier);
            Map<String, LS_TM_Connective_Task__c> existingTasksMap = (taskWrapper.existingTasksMap == null) ? new Map<String, LS_TM_Connective_Task__c>() : taskWrapper.existingTasksMap;            
            
            existingTasksMap.put(taskKey, existingTask);
            taskWrapper.existingTasksMap = existingTasksMap;
        }

        System.debug('stagingWrapperInstance : ' + JSON.serialize(stagingWrapperInstance));
    }

    public static void populateTaskRuleWrapper() {
        Id ownershipRecordTypeId = TASK_RULES_RECORD_TYPES.get(RULES_RECORD_TYPE_OWNERSHIP).getRecordTypeId();
        Id taskDefRuleRecordTypeId = TASK_RULES_RECORD_TYPES.get(RULES_RECORD_TYPE_TASK_DEF).getRecordTypeId();
        List<LS_TM_Connective_Task_Rule__c> taskRules = ConnectiveTaskStagingUtilities.getConnectiveTaskRules(ownershipRecordTypeId, taskDefRuleRecordTypeId, CT_GLOBAL_TRIAGE_QUEUE);
        
        System.debug('taskRules : ' + JSON.serialize(taskRules));

        Map<String, Id> countryToQueueIdMap = new Map<String, Id>();
        Map<String, Map<String, LS_TM_Connective_Task_Rule__c>> taskDefRuleMap = new Map<String, Map<String, LS_TM_Connective_Task_Rule__c>>();

        ConnectiveTaskStagingWrappers.TaskRuleWrapper taskRuleWrapper = new ConnectiveTaskStagingWrappers.TaskRuleWrapper();

        for(LS_TM_Connective_Task_Rule__c taskRule : taskRules) {
            Id recordTypeId = taskRule.RecordTypeId;
            String country = taskRule.LS_TM_Country__c;
            String queueId = taskRule.LS_TM_Queue_ID__c;
            String queueName = taskRule.LS_TM_Queue_Name__c;
            String refType = taskRule.LS_TM_Reference_Type__c;

            if(recordTypeId == taskDefRuleRecordTypeId && String.isNotBlank(refType)) {
                ConnectiveTaskStagingUtilities.populateTaskDefRuleMap(refType, taskRule, taskDefRuleMap);
            }else if(recordTypeId == ownershipRecordTypeId && String.isNotBlank(queueId) && queueName.equalsIgnoreCase(CT_GLOBAL_TRIAGE_QUEUE)){
                taskRuleWrapper.globalTriageQueueId = Id.valueOf(queueId);
            }else if(recordTypeId == ownershipRecordTypeId && String.isNotBlank(queueId) && String.isNotBlank(country)) {
                ConnectiveTaskStagingUtilities.populateCountryToQueueIdMap(country, queueId, countryToQueueIdMap);
            }
        }

        taskRuleWrapper.taskDefRuleMap = taskDefRuleMap;
        taskRuleWrapper.countryToQueueIdMap = countryToQueueIdMap;
        ConnectiveTaskStagingWrappers.getInstance().taskRuleWrapper = taskRuleWrapper;

        System.debug('taskRuleWrapper : ' + JSON.serialize(taskRuleWrapper));
    }

    public static void populateConnectiveTasksInTaskWrapper() {
        ConnectiveTaskStagingWrappers stagingWrapperInstance = ConnectiveTaskStagingWrappers.getInstance();
        ConnectiveTaskStagingWrappers.TaskRuleWrapper taskRuleWrapper = stagingWrapperInstance.taskRuleWrapper;
        Map<String, ConnectiveTaskStagingWrappers.TaskWrapper> taskWrapperMap = stagingWrapperInstance.taskWrapperMap;

        stagingWrapperInstance.upsertTasksMap = new Map<String, LS_TM_Connective_Task__c>();
        stagingWrapperInstance.taskRecordTypeMap = ConnectiveTaskStagingUtilities.getTaskRecordTypeMap();
        stagingWrapperInstance.taskFields = Schema.SObjectType.LS_TM_Connective_Task__c.fields.getMap().keySet();
        stagingWrapperInstance.stagingTaskFields = Schema.SObjectType.LS_TM_Connective_Task_Staging__c.fields.getMap().keySet();
        stagingWrapperInstance.stagingTaskFields.removeAll(ConnectiveTaskStagingUtilities.getStagingFieldsToIgnoreComparison());

        for(String moreIdentifier : taskWrapperMap.keySet()) {
            ConnectiveTaskStagingWrappers.TaskWrapper taskWrapper = taskWrapperMap.get(moreIdentifier);
            ConnectiveTaskStagingUtilities.populateConnectiveTasks(moreIdentifier, taskWrapper, stagingWrapperInstance);
        }

        System.debug('populateConnectiveTasksInTaskWrapper taskWrapperMap : ' + JSON.serialize(taskWrapperMap));
        System.debug('populateConnectiveTasksInTaskWrapper upsertTasksMap : ' + JSON.serialize(stagingWrapperInstance.upsertTasksMap));
    }

    public static void processConnectiveTasks(Set<Id> stagingTaskIds) {
        ConnectiveTaskStagingWrappers stagingWrapperInstance = ConnectiveTaskStagingWrappers.getInstance();
        Map<String, LS_TM_Connective_Task__c> upsertConnectiveTasksMap = stagingWrapperInstance.upsertTasksMap;
        List<LS_TM_Connective_Task__c> upsertConnectiveTasks = (upsertConnectiveTasksMap != null && upsertConnectiveTasksMap.size() > SIZE_ZERO) ? upsertConnectiveTasksMap.values() : new List<LS_TM_Connective_Task__c>();

        System.debug('upsertConnectiveTasks : ' + JSON.serialize(upsertConnectiveTasks));
        ConnectiveTaskStagingUtilities.upsertConnectiveTasks(stagingTaskIds, upsertConnectiveTasks);
    }
}