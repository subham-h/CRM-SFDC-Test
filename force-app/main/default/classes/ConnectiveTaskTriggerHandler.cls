/**
 * Author   : Chakshu Malhotra
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on Connective Task Trigger.
 * 
 * Revision     JIRA Story  Date        Owner                   Description
 * --------     ----------  ----------- -------------------     -----------
 * 1.0          SCTM-280    08/07/2020  Chakshu@Maersk          Created for implementing the CBO architecture.
 */
public class ConnectiveTaskTriggerHandler extends TriggerHandler {

    private List<LS_TM_Connective_Task__c> m_newConnectiveTasks;
    private Map<Id, LS_TM_Connective_Task__c> m_oldConnectiveTaskMap;

    public ConnectiveTaskTriggerHandler() {
        m_newConnectiveTasks = (List<LS_TM_Connective_Task__c>) Trigger.New;
        m_oldConnectiveTaskMap = (Map<Id, LS_TM_Connective_Task__c>) Trigger.OldMap;
    }

    protected override void onBeforeUpdate() {
        ConnectiveTaskRecordSelector.updateClosureDateOnTasks(m_newConnectiveTasks, m_oldConnectiveTaskMap);
    }

    protected override void onBeforeInsert() {
       ConnectiveTaskRecordSelector.updateRelatedSOBL(m_newConnectiveTasks);
    }


}