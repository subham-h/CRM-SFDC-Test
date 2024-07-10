/**
 * Author   : Chakshu Malhotra
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on Connective Task Staging Trigger.
 * 
 * Revision     JIRA Story  Date        Owner                   Description
 * --------     ----------  ----------- -------------------     -----------
 * 1.0          SCTM-280    12/06/2020  Chakshu@Maersk          Created for implementing the CBO architecture.
 * 2.0      	SC-4174    	20/12/2021  Avinash@Maersk      	Connective Task Management (CTM) Performance Issue
 */
public class ConnectiveTaskStagingTriggerHandler extends TriggerHandler {
    
    private List<LS_TM_Connective_Task_Staging__c> m_newStagingTasks;
    private Map<Id, LS_TM_Connective_Task_Staging__c> m_newStagingTaskMap;

    public ConnectiveTaskStagingTriggerHandler() {
        m_newStagingTasks = (List<LS_TM_Connective_Task_Staging__c>) Trigger.New;
        m_newStagingTaskMap = (Map<Id, LS_TM_Connective_Task_Staging__c>) Trigger.NewMap;
    }

    //#SC-4174
    protected override void onBeforeUpdate() {
        ConnectiveTaskStagingRecordSelector.updateCountryNameMismatch(m_newStagingTasks);
    }
    
    //#SC-4174
    protected override void onAfterUpdate() {
        ConnectiveTaskStagingRecordSelector.populateStagingWrapperMembers(m_newStagingTasks);
        ConnectiveTaskStagingRecordSelector.populateExistingTasksForTransactionTypeUpdate();
        ConnectiveTaskStagingRecordSelector.populateTaskRuleWrapper();
        ConnectiveTaskStagingRecordSelector.populateConnectiveTasksInTaskWrapper();
        ConnectiveTaskStagingRecordSelector.processConnectiveTasks(m_newStagingTaskMap.keySet());
    }
    
    protected override void onBeforeInsert() {
        ConnectiveTaskStagingRecordSelector.updateCountryNameMismatch(m_newStagingTasks);
    }

    protected override void onAfterInsert() {
        ConnectiveTaskStagingRecordSelector.populateStagingWrapperMembers(m_newStagingTasks);
        ConnectiveTaskStagingRecordSelector.populateExistingTasksForTransactionTypeUpdate();
        ConnectiveTaskStagingRecordSelector.populateTaskRuleWrapper();
        ConnectiveTaskStagingRecordSelector.populateConnectiveTasksInTaskWrapper();
        ConnectiveTaskStagingRecordSelector.processConnectiveTasks(m_newStagingTaskMap.keySet());
    }

}