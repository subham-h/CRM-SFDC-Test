global class Batch_AccountDenCategory implements Database.batchable<sObject>,Database.stateful  
{
    Public string query;
    global integer queryOption;
    global integer count;


    global Database.queryLocator start(Database.batchableContext bc)
    
    {
         query = 'SELECT Id,Account_DEN_Category__c FROM Account WHERE RecordType.Name = \'Client Account\' AND Account_DEN_Category__c != \'New\' ';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.batchableContext bc, list<sObject> scope)
    {

            list<Account> accList = new list<Account>();
            for(sObject acc : scope)
            {
                Account a = (Account) acc;
                a.Account_DEN_Category__c ='New';
                accList.add(a);

            }
            
                TriggerExecutionController.skipAccountTrigger(true);
                Update accList;
                TriggerExecutionController.skipAccountTrigger(false);

    }

    global void finish(Database.batchableContext bc)
    {
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email    from AsyncApexJob where Id =:BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'govindaraj.sundaram@ust-global.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Batch status: ' + a.Status);
        mail.setPlainTextBody('Records processed:' + a.TotalJobItems +   'with:'+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
    }
}