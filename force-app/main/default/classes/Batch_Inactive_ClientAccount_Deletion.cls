/*
---------------------------------------------------------------------------------------------------------------------------------
* Author - Cognizant Technology Solutions
* Purpose - To delete inactive Client Accounts which do not have any opportunity and Activity associated with it
---------------------------------------------------------------------------------------------------------------------------------
*/


Global class Batch_Inactive_ClientAccount_Deletion implements Database.Batchable<SObject> 
{
    public string query = 'SELECT id, SCV_Code__c from Account where SCV_Status__c = \'Inactive\' and IsConcern__c = \'FALSE\' and Is_Opportunity__c = 0 ';
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext info, List<SObject> Scope)
    {
       List<Account> accList = (List<Account>)scope; // List Of Inactive Accounts w/o opportunities
       Set<String> AccountIdSet = new Set<String>();

       Set<String> AccoutsWithActivity= new Set<String>();
       List<Account> AcctTobeDeleted = new List<Account>();
       for(Account acc: accList)
       {
            AccountIdSet.add(acc.Id);
            
       }
        
       if (AccountIdSet.size() >0)
       {
           for(Event e : [Select id, AccountID from Event where AccountID in : AccountIdSet])
            {
                AccoutsWithActivity.add(e.AccountID);
            }
            
            for(Task t : [Select id, AccountID from Task where AccountID in : AccountIdSet])
            {
                AccoutsWithActivity.add(t.AccountID);
            }
            
            for(Account acc : [select id, SCV_Code__c from Account where id NOT In :AccoutsWithActivity and id IN: AccountIdSet ])
            {
                AcctTobeDeleted.add(acc);
            }
                    
            try
            {
                if(AcctTobeDeleted.size()>0)
                 Delete AcctTobeDeleted;
            }
                                
            catch (exception e)
            {
                system.debug('<<<<<<<<<<<<<<<Deletion Failed>>>>>>>>>>>>>>>>>>>');
            } 
            
       }
            
        
    }
   
   global void finish(Database.BatchableContext BC)
    {
    
    }

}