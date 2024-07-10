/*
* Author    : Ranjan
* Purpose   : Schedule  the Batch_EmailMessageExtArchiver batch. 
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-5245     16-Aug-2022 Ranjan@Maersk            Created. 
* 
*
*/

global class Scheduler_BatchEmailMessageExtArchiver implements Schedulable {
    
	global final Integer iBatchSize;
    global string metaDataDevName;
	
	public Scheduler_BatchEmailMessageExtArchiver() {
		iBatchSize = 50;
	}
	
	public Scheduler_BatchEmailMessageExtArchiver(Integer batchSize) {
		iBatchSize = batchSize;
	}
    
    public Scheduler_BatchEmailMessageExtArchiver(string metaDataDevName, Integer batchSize) {
		iBatchSize = batchSize;
        this.metaDataDevName = metaDataDevName;
	}
	
    global void execute(SchedulableContext SC) {
        if(String.isBlank(metaDataDevName)){
    		Database.executeBatch(new Batch_EmailMessageExtArchiver(), iBatchSize);
        }else{
            Database.executeBatch(new Batch_EmailMessageExtArchiver(metaDataDevName,true), iBatchSize);
        }
    }
    
}