/*
* Author    : Raksha
* Purpose   : Schedule the Batch_ArchivedCases batch. 
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-4508     10-Jan-2023 Raksha@Maersk            Created. 
* 
*
*/
global class Scheduler_Batch_ArchivedCases implements Schedulable {
  global final Integer iBatchSize;
  public Scheduler_Batch_ArchivedCases () {
      iBatchSize = 50;
  }
  
  public Scheduler_Batch_ArchivedCases (Integer batchSize) {
      iBatchSize = batchSize;
  }
  
  global void execute(SchedulableContext SC) {
      Database.executeBatch(new Batch_ArchivedCases(), iBatchSize);
  }
    
}