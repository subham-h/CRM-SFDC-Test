/*
* version       Date                Owner                                       Description
*******************************************************************************************************
* V1.0          08/Aug/2018       John.Christopher@ust-global.com        #RQ-008412 -Code Created
* V2.0          11/Jul/2019       Junaid.Khader@ust-global.com           #RQ-010654: Removed reference of deprecated object Target__c
* V3.0          17/Sep/2019       Neha- TCS                              #RQ-007086: Code is modified to make it configurable using custom metadaat and delete inactive accounts with customer reason as duplicate for last 30 days with no related items
*v4.0          18/Dec/2023       Arpitha                                #13446: Tech Debt story to optimize the logic.
*/

global class Batch_InactiveAccounts_Deletion implements Database.Batchable<SObject> {    
    
    // start method of the batch to create records 
    global Database.queryLocator start( Database.BatchableContext ctx ) {
        
        List<String> customerStatusReasonList= Label.Customer_Status_Reason.split(','); // List to contain the status reason. This is done post code review since we might have more reason in future
        
        // Using the same label BatchInActiveAccDeletion_IsPartialRun which was created for this batch, however using it differently here
        String strQuery = 'SELECT Id FROM Account where SCV_Status__c = \'Inactive\' AND Is_Opportunity__c = 0 AND Customer_Status_Reason__c in : customerStatusReasonList AND LastModifiedDate <= '+ Label.BatchInActiveAccDeletion_IsPartialRun; 
        return Database.getQueryLocator(strQuery);            
    }
    
    // execute method to write business logic and refine the accouns here to determine which needs to be deleted
    global void execute( Database.BatchableContext BC, List<sObject> scope ) {        
        List<Account> lstAccount = ( List<Account> )scope; // List Of Inactive Accounts
        List<Database.deleteResult> lstDeleteResult;   
        List<Id> finalaccountlisttoDelete; // this will hold the ids of account which are refined and needs to be deleted
        try{
            Set<Id> accountIds = new Set<Id>(); //list to store the accountid in scope for removing duplicates        
            for(Account acc : lstAccount){
                accountIds.add(acc.Id);
            }
            Set<Id> accountIdSetToRemove = new Set<Id>(); // this will hold the set of accounts id which have the related accounts, which should not be deleted
            // Query the metadata to check to iterate over objects for which related records needs to be checked
            List<Check_Object_for_Account_Deletion__mdt> excludeAccRecord =[Select DeveloperName,Object_name__c,Field_Name__c from Check_Object_for_Account_Deletion__mdt]; 
            for(Check_Object_for_Account_Deletion__mdt associatedObject :excludeAccRecord){
                String soqlquery = 'select '+associatedObject.Field_Name__c+' from '+associatedObject.Object_name__c+' where '+associatedObject.Field_Name__c+' in :accountIds';            
                list<sobject> sobjectQueryResult = Database.query(soqlquery);
                if(sobjectQueryResult != null){
                    for(sObject sobj : sobjectQueryResult){                   
                        Id accountidFromChildObject = (Id)sobj.get(associatedObject.Field_Name__c); // get the ids to remove from scope which are not to be deleted.
                        accountIdSetToRemove.add(accountidFromChildObject);
                    }
                }
            }
            accountIds.removeAll(accountIdSetToRemove); // remove the ids which have related objects
            finalaccountlisttoDelete = new List<Id>(accountIds); // convert the set to list to pass for deletion
            
            if(!finalaccountlisttoDelete.isEmpty()){  
                TriggerExecutionController.skipAccountTrigger(true);
                lstDeleteResult = Database.Delete(finalaccountlisttoDelete ,false);
                TriggerExecutionController.skipAccountTrigger(false);               
                database.emptyRecycleBin(finalaccountlisttoDelete); //Remove the deleted items from Recycle bin as well.           
                
            }
        }
        catch(Exception e){
            ErrorLogger.writeErrors('SFDC', 'Account', 'Batch_InactiveAccounts_Deletion', lstDeleteResult, lstAccount);
        }
        
    }         
        
    global void finish(Database.BatchableContext BC){
        
    }
    
}