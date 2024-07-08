/*
* Version  Date             Owner                                    RQ#           Description
***********************************************************************************************************************************************
* 1.0	   23/03/2021	Sidhartha								   SFSE-5366		
*/

global class Scheduler_BatchTerrMgmtSyncSalesOwner implements Schedulable {

    global void execute( SchedulableContext SC ) {  
        // Invoke the Account Liner brand ownership sync based on Territory Sales owner user change of each territory seperately
        // Territory Batch run for Non Skewd Accounts
        BatchTerrMgmtSyncSalesOwnerOnAccount b = new BatchTerrMgmtSyncSalesOwnerOnAccount(false);
        Database.executeBatch( b, 200);
    }
    
}