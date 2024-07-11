/*
* Author    : Ranjan
* Purpose   : Schedule  the Batch_EmailMessageExtArchiver batch. 
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-         3-Jan-2023 Ranjan@Maersk            Created. 
* 
*
*/

global class Schedule_BatchEmailMessageExtCseArchiver implements Schedulable {
    
	global final Integer iBatchSize;
	
	public Schedule_BatchEmailMessageExtCseArchiver() {
		iBatchSize = 50;
	}
	
	public Schedule_BatchEmailMessageExtCseArchiver(Integer batchSize) {
		iBatchSize = batchSize;
	}
	
    global void execute(SchedulableContext SC) {
    	Database.executeBatch(new Batch_EmailMessageExtCseArchiver(iBatchSize), iBatchSize);
    }
    
}