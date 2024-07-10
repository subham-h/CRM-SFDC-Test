/**
 * Author   : Chakshu Malhotra
 * Purpose  : Create and delete methods with synchronous and Queueable job logic to switch using custom label.
 * 
 * Revision     JIRA Story  Date        Owner                   Description
 * --------     ----------  ----------- -------------------     -----------
 * 1.0          SCTM-280    12/06/2020  Chakshu@Maersk          Created for implementing the CBO architecture.
 * 2.0			SC-4174		20/12/2021	Avinash@Maersk			Connective Task Management (CTM) Performance Issue
 */
public class ConnectiveTaskRecordHandler {

    private static final Integer INDEX_ZERO = 0;

    private static final String CLASS_METHOD_SEPARATOR = '.';
    private static final String EXCEPTION_SOURCE_SYSTEM = 'SFDC';
    private static final String EXCEPTION_SOBJECT_CONNECTIVE_TASK = 'LS_TM_Connective_Task__c';
    private static final String EXCEPTION_UPSERT_CONNECTIVE_TASKS_METHOD = 'bulkUpsertConnectiveTasks';

    public static void bulkUpsertConnectiveTasks(Set<Id> stagingTaskIds, List<LS_TM_Connective_Task__c> upsertConnectiveTasks, Map<String, ConnectiveTaskStagingWrappers.TaskWrapper> taskWrapperMap) {
        List<Database.UpsertResult> taskUpsertResultList = Database.upsert(upsertConnectiveTasks, LS_TM_Connective_Task__c.LS_TM_Key_Identifier__c, false);
        populateTaskStatusWrapper(stagingTaskIds, upsertConnectiveTasks, taskUpsertResultList, taskWrapperMap);
    }

    private static void populateTaskStatusWrapper(Set<Id> deleteStagingRecordIds, List<LS_TM_Connective_Task__c> upsertConnectiveTasks, List<Database.UpsertResult> taskUpsertResultList, Map<String, ConnectiveTaskStagingWrappers.TaskWrapper> taskWrapperMap) {
        Map<Id, String> failedStagingRecordMap = new Map<Id, String>();
        populateStagingRecordFailures(upsertConnectiveTasks, taskUpsertResultList, taskWrapperMap, deleteStagingRecordIds, failedStagingRecordMap);

        ConnectiveTaskStagingWrappers.TaskStatusWrapper taskStatusWrapper = new ConnectiveTaskStagingWrappers.TaskStatusWrapper();
        taskStatusWrapper.deleteStagingRecordIds = deleteStagingRecordIds;
        taskStatusWrapper.failedStagingRecordMap = failedStagingRecordMap;

        ConnectiveTaskStagingWrappers stagingWrapperInstance = ConnectiveTaskStagingWrappers.getInstance();
        stagingWrapperInstance.taskStatusWrapper = taskStatusWrapper;

        if(!failedStagingRecordMap.isEmpty()) {
            logErrorsForFailedConnectiveTasks(upsertConnectiveTasks, taskUpsertResultList);
        }
    }

    private static void logErrorsForFailedConnectiveTasks(List<LS_TM_Connective_Task__c> upsertConnectiveTasks, List<Database.UpsertResult> taskUpsertResultList) {
        String exMethodName = ConnectiveTaskRecordHandler.class.getName() + CLASS_METHOD_SEPARATOR + EXCEPTION_UPSERT_CONNECTIVE_TASKS_METHOD;
        ErrorLogger.writeErrors(EXCEPTION_SOURCE_SYSTEM, EXCEPTION_SOBJECT_CONNECTIVE_TASK, exMethodName, taskUpsertResultList, upsertConnectiveTasks);
    }

    private static void populateStagingRecordFailures(List<LS_TM_Connective_Task__c> connectiveTasks, List<Database.UpsertResult> taskUpsertResultList, Map<String, ConnectiveTaskStagingWrappers.TaskWrapper> taskWrapperMap, Set<Id> deleteStagingRecordIds, Map<Id, String> failedStagingRecordMap) {
        for(Integer srIndex=INDEX_ZERO; srIndex < taskUpsertResultList.size(); srIndex++) {
            String moreIdentifier = connectiveTasks[srIndex].LS_TM_MORE_Identifier__c;
            LS_TM_Connective_Task_Staging__c stagingTask = taskWrapperMap.get(moreIdentifier).stagingTask;

            if(!taskUpsertResultList[srIndex].isSuccess()) {
                deleteStagingRecordIds.remove(stagingTask.Id);
                failedStagingRecordMap.put(stagingTask.Id, JSON.serialize(taskUpsertResultList[srIndex].getErrors()));
                System.debug('populateStagingRecordFailures : ' + JSON.serialize(taskUpsertResultList[srIndex].getErrors()));
            }
        }
    }

    public static void bulkProcessConnectiveTaskStagingRecords(ConnectiveTaskStagingWrappers.TaskStatusWrapper taskStatusWrapper) {
        //#SC-4174 -- Commented below line as part of this RQ
        //bulkDeleteStagingRecords(taskStatusWrapper.deleteStagingRecordIds);        

        if(!taskStatusWrapper.failedStagingRecordMap.isEmpty()) {
            bulkUpdateFailedStagingRecords(taskStatusWrapper.failedStagingRecordMap);
        }
    }

    //#SC-4174 -- Commented this method as part of this RQ
    /*private static void bulkDeleteStagingRecords(Set<Id> deleteStagingRecordIds) {
        List<LS_TM_Connective_Task_Staging__c> deleteStagingTasks = [SELECT Id FROM LS_TM_Connective_Task_Staging__c WHERE Id IN :deleteStagingRecordIds];

        if(!deleteStagingTasks.isEmpty()) {
            List<Database.DeleteResult> stagingDeleteResultList = Database.delete(deleteStagingTasks, false);
            DataBase.emptyRecycleBin(deleteStagingTasks);
        }
    }*/

    private static void bulkUpdateFailedStagingRecords(Map<Id, String> failedStagingRecordMap) {
        List<LS_TM_Connective_Task_Staging__c> updateStagingTasks = [SELECT Id, LS_TM_Has_Error__c, LS_TM_Error_Message__c 
                                                                     FROM LS_TM_Connective_Task_Staging__c 
                                                                     WHERE Id IN :failedStagingRecordMap.keySet()];

        for(LS_TM_Connective_Task_Staging__c stagingTask : updateStagingTasks) {
            stagingTask.LS_TM_Has_Error__c = true;
            stagingTask.LS_TM_Error_Message__c = failedStagingRecordMap.get(stagingTask.Id);
        }

        if(!updateStagingTasks.isEmpty()) {
            List<Database.SaveResult> stagingSaveResultList = Database.update(updateStagingTasks, false);
        }
    }

    public class ConnectiveTaskRecordProcessor implements Queueable {

        private Set<Id> stagingTaskIds;
        private List<LS_TM_Connective_Task__c> upsertConnectiveTasks;
        private Map<String, ConnectiveTaskStagingWrappers.TaskWrapper> taskWrapperMap;

        public ConnectiveTaskRecordProcessor(Set<Id> stagingTaskIds, List<LS_TM_Connective_Task__c> upsertConnectiveTasks, Map<String, ConnectiveTaskStagingWrappers.TaskWrapper> taskWrapperMap) {
            this.stagingTaskIds = stagingTaskIds;
            this.taskWrapperMap = taskWrapperMap;
            this.upsertConnectiveTasks = upsertConnectiveTasks;
        }

        public void execute(QueueableContext context) {
            ConnectiveTaskRecordHandler.bulkUpsertConnectiveTasks(stagingTaskIds, upsertConnectiveTasks, taskWrapperMap);
            ConnectiveTaskStagingWrappers.TaskStatusWrapper taskStatusWrapper = ConnectiveTaskStagingWrappers.getInstance().taskStatusWrapper;
            
            if(taskStatusWrapper != null) {
                ConnectiveTaskStagingRecordProcessor stagingRecordProcessor = new ConnectiveTaskStagingRecordProcessor(taskStatusWrapper); 
                Id stagingRecordProcessorJobId = Test.isRunningTest() ? null : System.enqueueJob(stagingRecordProcessor);
            }
        }
    }

    public class ConnectiveTaskStagingRecordProcessor implements Queueable {

        private ConnectiveTaskStagingWrappers.TaskStatusWrapper taskStatusWrapper;

        public ConnectiveTaskStagingRecordProcessor(ConnectiveTaskStagingWrappers.TaskStatusWrapper taskStatusWrapper) {
            this.taskStatusWrapper = taskStatusWrapper;
        }

        public void execute(QueueableContext context) {
            ConnectiveTaskRecordHandler.bulkProcessConnectiveTaskStagingRecords(taskStatusWrapper);
        }
    }
}