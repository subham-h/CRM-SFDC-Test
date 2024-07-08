/*
* Version  Date             Owner                                    RQ#           Description
***********************************************************************************************************************************************
* 1.0	   23/03/2021	Sidhartha								   SFSE-5366		
*/
global class Scheduler_BatchTerrSyncSalesOwnerSkewAcc implements Schedulable  {
  global void execute( SchedulableContext SC ) {  
        // Territory Batch run for Skewd Accounts
        BatchTerrMgmtSyncSalesOwnerOnAccount b = new BatchTerrMgmtSyncSalesOwnerOnAccount(true);
        Database.executeBatch( b, 200);
    }
    
}