/**
 * Author   : Chakshu Malhotra
 * Purpose  : Record Selector class for ConnectiveTask Trigger.
 * 
 * Revision     JIRA Story  Date        Owner                   Description
 * --------     ----------  ----------- -------------------     -----------
 * 1.0          SCTM-280    08/07/2020  Chakshu@Maersk          Created for implementing the CBO architecture.
 * 2.0          SC-7661     30/07/2023  Harmeet@Maersk          Mapping RelatedSoBL field with LS_TM_Related_B_Ls__c
 */
public class ConnectiveTaskRecordSelector {

    private static final Integer SIZE_ZERO = 0;

    public static void updateClosureDateOnTasks(List<LS_TM_Connective_Task__c> connectiveTasks, Map<Id, LS_TM_Connective_Task__c> oldConnectiveTaskMap) {
        ConnectiveTaskUtilities.addOrClearClosureDateOnTasks(connectiveTasks, oldConnectiveTaskMap);
    }

    public static void updateRelatedSOBL(List<LS_TM_Connective_Task__c> connectiveTasks) {
       ConnectiveTaskUtilities.updateRelatedSOBLs(connectiveTasks);
    }

    
}