/*
* Author    : Aditya
* Purpose   : Schedule  the Batch_ArchivedCaseDeleteBatch batch. 
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-         3-Jan-2023 Aditya@Maersk            Created. 
* 
*
*/
global class Scheduler_BatchArchivedCaseDeleteBatch implements Schedulable {
    global final Integer iBatchSize;
	
	public Scheduler_BatchArchivedCaseDeleteBatch() {
		iBatchSize = 50;
	}
	
	public Scheduler_BatchArchivedCaseDeleteBatch(Integer batchSize) {
		iBatchSize = batchSize;
	}
	
    global void execute(SchedulableContext SC) {
    	Database.executeBatch(new Batch_ArchivedCaseDeleteBatch(iBatchSize), iBatchSize);
    }
}