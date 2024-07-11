/*
* Version  Date             Owner                                    RQ#           Description
***********************************************************************************************************************************************
* 1.0    11/03/2018       meghana.gupta@ust-global.com        RQ-008054     Scheduler for Batch job to sync the status of Request based on pricing management based policy settings
*/

global class Scheduler_BatchSyncRequestStatusByPolicy implements Schedulable {
        
    global void execute( SchedulableContext sc ) {

        BatchSyncRequestStatusByPolicy b = new BatchSyncRequestStatusByPolicy();
        Database.ExecuteBatch( b);

    }

}