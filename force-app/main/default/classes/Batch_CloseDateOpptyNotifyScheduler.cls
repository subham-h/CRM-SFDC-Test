/*
* Purpose  : This is a Schedule class that calls Batch_ClosePastOpps class.
*            This is scheduled for 2300 Hrs every day.
*
* Revision  Ref Number    Date          Owner                   Description
* --------   ----------    -----------   -------------------     -----------
* 1.0        #RQ-11001    25-sep-2023   ramya      Scheduler class for Batch_CloseDateOpptyNotification.
* 
*/

global class Batch_CloseDateOpptyNotifyScheduler implements Schedulable {
  global void execute(SchedulableContext SC) 
    {
      Id batchInstanceId = Database.executeBatch(new Batch_CloseDateOpptyNotification(null),200); 
    }
}