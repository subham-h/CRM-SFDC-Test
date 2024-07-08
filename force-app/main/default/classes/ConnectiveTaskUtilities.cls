/**
 * Author   : Chakshu Malhotra
 * Purpose  : Utility class to hold simple and reusable functionalities for Connective Task.
 * 
 * Revision     JIRA Story  Date        Owner                   Description
 * --------     ----------  ----------- -------------------     -----------
 * 1.0          SCTM-280    08/07/2020  Chakshu@Maersk          Created for implementing the CBO architecture.
 * 2.0          SC-7661     30/07/2023  Harmeet@Maersk          Mapping RelatedSoBL field with LS_TM_Related_B_Ls__c
 */
public class ConnectiveTaskUtilities {

    private static final String TASK_STATUS_CLOSED_COMPLETED = Label.LS_TM_CT_Status_Closed_Completed;
    private static final String TASK_STATUS_CLOSED_CANCELLED = Label.LS_TM_CT_Status_Closed_Cancelled;
    
    private static final List<String> COMPLETED_CANCELLED_STATUS = new List<String> {TASK_STATUS_CLOSED_COMPLETED.toLowerCase(), TASK_STATUS_CLOSED_CANCELLED.toLowerCase()};

    public static void addOrClearClosureDateOnTasks(List<LS_TM_Connective_Task__c> connectiveTasks, Map<Id, LS_TM_Connective_Task__c> oldConnectiveTaskMap) {
        for(LS_TM_Connective_Task__c connectiveTask : connectiveTasks) {
            String newStatus = connectiveTask.LS_TM_Status__c;
            String oldStatus = oldConnectiveTaskMap.get(connectiveTask.Id).LS_TM_Status__c;
            
            Boolean isStatusChange = (newStatus != oldStatus);
            Boolean isValidToAddClosureDate = isStatusChange && String.isNotBlank(newStatus) && COMPLETED_CANCELLED_STATUS.contains(newStatus.toLowerCase());
            Boolean isValidToClearClosureDate = isStatusChange && String.isNotBlank(oldStatus) && COMPLETED_CANCELLED_STATUS.contains(oldStatus.toLowerCase()) && (String.isBlank(newStatus) || !COMPLETED_CANCELLED_STATUS.contains(newStatus.toLowerCase()));

            connectiveTask.LS_TM_Closure_Date__c = isValidToAddClosureDate ? Datetime.now().dateGmt() : isValidToClearClosureDate ? null : connectiveTask.LS_TM_Closure_Date__c;
            
        }
    }
    //SC-7661
    public static void updateRelatedSOBLs(List<LS_TM_Connective_Task__c> newConnectiveTasks){
        for(LS_TM_Connective_Task__c connectiveTask : newConnectiveTasks) {
           if(connectiveTask.LS_TM_Related_B_Ls__c != null){
             connectiveTask.Related_SO_BLs__c = connectiveTask.LS_TM_Related_B_Ls__c;
           }
        }

    }




}