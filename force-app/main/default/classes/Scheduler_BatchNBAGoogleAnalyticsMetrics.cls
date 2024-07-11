/*
 * Author   : Sunil BS
 * Purpose  : Scheduler for Batch class which Pulls Data from Google Analytics for NBA back to salesforce
 *         
 * Revision Ref Number  Date                       Owner             Description
 * -------- ----------  -----------        -------------------       -----------
 * 1.0      SC - 4042   14-Jan-2021        Sunil.bs@maersk.com       Scheduler for Batch class which Pulls Data from Google Analytics for NBA back to salesforce
 * 
 */

public class Scheduler_BatchNBAGoogleAnalyticsMetrics implements Schedulable {

    public void execute( SchedulableContext SC ) {  
       
        BatchNBAGoogleAnalyticsMetrics b = new BatchNBAGoogleAnalyticsMetrics();
        Database.executeBatch( b, 200);
    }
    
}