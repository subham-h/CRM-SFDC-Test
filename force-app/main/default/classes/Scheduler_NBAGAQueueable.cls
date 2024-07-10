/*
 * Author   : Sunil BS
 * Purpose  : Scheduler for Batch class which Pulls Data from Google Analytics for NBA back to salesforce
 *         
 * Revision Ref Number  Date                       Owner             Description
 * -------- ----------  -----------        -------------------       -----------
 * 1.0      SC - 4042   14-Jan-2021        Sunil.bs@maersk.com       Scheduler for Queaueble class which Pulls Data from Google Analytics for NBA back to salesforce
 * 
 */

global class Scheduler_NBAGAQueueable implements Schedulable {

    global void execute( SchedulableContext SC ) {  
          //Parameters Current Callout count which is 1, current token is blank since we dont have it, isfirst job true and next page token which blank as of now
          System.enqueueJob(new NBAGAQueueable(1,'',true,''));
    }
    
}