/*              
 * Revision Ref Number  Date            Owner                           Description
 * -------- ----------  -----------     -------------------             -----------
 * 1.0      RQ-004102   08/07/2016      nisha.arjunan@UST               Created for implementing CBO (Centralized By Org) trigger architecture.
 * 2.0      RQ-004103   05/07/2017      Ranjini@ust                     Updates as part of CBO refactoring.(Moved some methods to other classes).
 */
public class AccountUtilities {
    
    //#RQ-004102
    public static void populateLastActivityDate(Set<Id> setAccountIds){
        if(!setAccountIds.isEmpty()) {
            // Query and update the Last Activity Date on Account
            list<Account> lstAccounts = new list<Account>();
            for(Id accountId : setAccountIds) {
                lstAccounts.add(new Account(Id = accountId, Last_Activity_Date__c = System.today()));
            }
            try {
                TriggerExecutionController.skipAccountTrigger(true);
                update lstAccounts;
                TriggerExecutionController.skipAccountTrigger(false);
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
    	
}