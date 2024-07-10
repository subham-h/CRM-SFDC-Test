/*
* Version	Date			Owner					RQ#					Description
***********************************************************************************************************************************************
* 1.0		8/8/23      Samarpreet@maers.com     SFSE-10236          This batch would be used to send sync events for the Opportunity V4 Events
* 
*/
global  class Opportunity_Event_Scheduler  implements Schedulable{
    global final String jobName;
    global Integer batchSize = 100;

    public Opportunity_Event_Scheduler(String jobName) {
        this.jobName = jobName;
    }

    global void execute(SchedulableContext sc){
        if(jobName == 'sync - daily' || jobName == 'sync - monthly' ){
            OpportunityEventBatch be = new OpportunityEventBatch( jobName, new set<Id>{});
            database.executeBatch(be,batchSize);
        }else if (jobName == 'sync - monthly closed' ){
            ClosedOpportunityEventBatch be = new ClosedOpportunityEventBatch('sync - monthly');
            database.executeBatch(be,batchSize);
        }
    }
 
}