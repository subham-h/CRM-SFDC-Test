/****
 * Story Number      Date        Owner                        Description
***********************************************************************************************
*  SFSE-9733        13/01/2023    Bharti&Aditi            Code Created
*/


global class Batch_Escalation_Approval_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc){
       Batch_Escalation_ApprovalProcess b = new Batch_Escalation_ApprovalProcess(null);
             database.executebatch(b,Integer.valueOf(System.Label.BtachSizeForEscalationApprovalClass));
    }

}