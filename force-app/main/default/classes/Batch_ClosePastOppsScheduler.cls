/*
* Purpose  : This is a Schedule class that calls Batch_ClosePastOpps class.
*            This is scheduled for 2300 Hrs every day.
*
* Revision  Ref Number    Date          Owner                   Description
* --------   ----------    -----------   -------------------     -----------
* 1.0        #RQ-003238    16-Jun-2016   Anisa Bhatnagar      Scheduler class for Batch_ClosePastOpps.
* 
*/

global class Batch_ClosePastOppsScheduler implements Schedulable {
  global void execute(SchedulableContext SC) 
    {
      Id batchInstanceId = Database.executeBatch(new Batch_ClosePastOpps(null),200); 
    }
}