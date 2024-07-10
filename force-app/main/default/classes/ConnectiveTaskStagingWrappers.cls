/**
 * Author   : Chakshu Malhotra
 * Purpose  : Includes wrapper classes involved for processing Connective Task Staging Records.
 * 
 * Revision     JIRA Story  Date        Owner                   Description
 * --------     ----------  ----------- -------------------     -----------
 * 1.0          SCTM-280    12/06/2020  Chakshu@Maersk          Created for implementing the CBO architecture.
 */
public class ConnectiveTaskStagingWrappers {

    private static ConnectiveTaskStagingWrappers instance;

    public Set<String> referenceTypes {get; set;}
    public Set<String> processCountries {get; set;} // For assigning country queue ownership
    
    public Map<String, List<String>> refTypeToCountryRefMap {get; set;}

    public Set<String> taskFields {get; set;}
    public Set<String> stagingTaskFields {get; set;}
    public Map<String, Id> taskRecordTypeMap {get; set;}
    public Map<String, LS_TM_Connective_Task__c> upsertTasksMap {get; set;}

    public TaskRuleWrapper taskRuleWrapper {get; set;}
    public TaskStatusWrapper taskStatusWrapper {get; set;}
    public Map<String, ConnectiveTaskStagingWrappers.TaskWrapper> taskWrapperMap {get; set;}

    private ConnectiveTaskStagingWrappers() {
        // Private Constructor : Enforcing Singleton Design
    }

    public static ConnectiveTaskStagingWrappers getInstance() {
        if(instance == null) {
            instance = new ConnectiveTaskStagingWrappers();
        }
        return instance;
    }
    
    public class TaskWrapper {
        public String transactionType {get; set;}
        public LS_TM_Connective_Task_Staging__c stagingTask {get; set;}
        public Map<String, LS_TM_Connective_Task__c> existingTasksMap {get; set;}
    }

    public class TaskRuleWrapper {
        public Id globalTriageQueueId {get; set;}
        public Map<String, Id> countryToQueueIdMap {get; set;}
        public Map<String, Map<String, LS_TM_Connective_Task_Rule__c>> taskDefRuleMap {get; set;}
    }

    public class TaskStatusWrapper {
        public Set<Id> deleteStagingRecordIds {get; set;}
        public Map<Id, String> failedStagingRecordMap {get; set;}
    }
}