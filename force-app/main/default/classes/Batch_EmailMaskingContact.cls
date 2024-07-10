/*
* Author   : Abhinav
* Purpose  : Utility Batch Class for email masking for contact object . 
*
* Version       Date            Owner                               Description
******************************************************************************************************************************************************
* v1.0      25-Feb-2019    abhinav.ankit@maersk.com    RQ-010163 -> For updating Contact email,Unique_Email__c,Duplicate_Email__c with SandboxName
------------------------------------------------------------------------------------------------------------------------------------------------------>
*/
global class Batch_EmailMaskingContact implements Database.Batchable<sObject>, Database.Stateful { 
    global Integer intsucesscounter = 0;
    global Integer interrorcounter= 0;
    global String strSandboxUnigueName;
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        String query = 'SELECT Id,Name, Email,Unique_Email_Address__c,Duplicate_Email__c FROM Contact'; 
        return Database.getQueryLocator(query);  
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) { 
        strSandboxUnigueName = URL.getSalesforceBaseUrl().getHost().substringBetween('--','.');    
        if(Test.isRunningTest()){
            strSandboxUnigueName ='Sandbox';
        }
        
        system.debug('strSandboxUnigueName'+ strSandboxUnigueName);
        for(Contact rowContactRecord : scope) 
        { 
            
            if(rowContactRecord.Email!= null &&  !rowContactRecord.Email.containsIgnoreCase(strSandboxUnigueName)) 
                rowContactRecord .Email = rowContactRecord.Email + '.'+ strSandboxUnigueName;
            
            if(rowContactRecord.Unique_Email_Address__c!=null &&  !rowContactRecord.Unique_Email_Address__c.containsIgnoreCase(strSandboxUnigueName)) 
                rowContactRecord.Unique_Email_Address__c= rowContactRecord.Unique_Email_Address__c+ '.'+ strSandboxUnigueName;
            
            if(rowContactRecord.Duplicate_Email__c !=null && !rowContactRecord.Duplicate_Email__c .containsIgnoreCase(strSandboxUnigueName))
                rowContactRecord.Duplicate_Email__c = rowContactRecord.Duplicate_Email__c + '.'+ strSandboxUnigueName; 
            
            
        }
        
        // Try updating the Cases with allOrNone set to false so the whole update isn't rolled back if just one record fails...
        if(strSandboxUnigueName!=null){
            Database.SaveResult[] lstSaveResults = Database.Update(scope, false);
            ErrorLogger.writeErrors('SFDC', 'Contact', 'Batch_EmailMaskingContact', lstSaveResults, scope);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : lstSaveResults ) 
            {
                if (sr.isSuccess()) 
                { 
                    intsucesscounter++;}
                else {
                    interrorcounter++;
                }
            } 
        }
    }
    global void finish(Database.BatchableContext BC) { 
        
        AsyncApexJob batchrecords = [Select Id, Status, TotalJobItems,CreatedBy.Email from AsyncApexJob where Id = :BC.getJobId()];
        system.debug('batchrecords.CreatedBy.Email'+ batchrecords.CreatedBy.Email);
        // Email the Batch Job's submitter that the Job is finished.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {batchrecords.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Batch_EmailMaskingContact Status: ' + batchrecords.Status);
        mail.setPlainTextBody('Postrefresh Contact Update batch Apex job is processed with' +batchrecords.TotalJobItems +' batches with '+ intSucessCounter + ' successes and ' + intErrorCounter + ' failures.' );
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } 
    
}