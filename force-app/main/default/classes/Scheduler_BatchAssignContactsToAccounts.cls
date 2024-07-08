global class Scheduler_BatchAssignContactsToAccounts implements Schedulable {
    
    global void execute( SchedulableContext SC ) {  
        BatchAssignContactsToAccounts b = new BatchAssignContactsToAccounts();
        Database.executeBatch( b, 200);
    }
}