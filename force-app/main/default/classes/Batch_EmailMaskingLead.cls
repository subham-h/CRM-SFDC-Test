/*
* Author   : Abhinav
* Purpose  : Utility Batch Class for email masking for lead object . 
*
* Version       Date            Owner                               Description
******************************************************************************************************************************************************
* v1.0      25-Feb-2019    abhinav.ankit@maersk.com    RQ-010163 -> For updating Lead email,Unique_Email__c with SandboxName
------------------------------------------------------------------------------------------------------------------------------------------------------>
*/

global class Batch_EmailMaskingLead implements Database.Batchable<sObject>, Database.Stateful { 
    global Integer intSucessCounter = 0;
    global Integer intErrorCounter= 0;
    global String  strSandboxUnigueName;
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        String query = 'SELECT Id,Name, Email,Unique_Email__c FROM lead ';  
        return Database.getQueryLocator(query);  
    }
    
    // For updating Lead email,Unique_Email__c with .preprod2
    
    global void execute(Database.BatchableContext BC, List<lead> scope) {
        strSandboxUnigueName = URL.getSalesforceBaseUrl().getHost().substringBetween('--','.');
        if(Test.isRunningTest()){
            strSandboxUnigueName ='Sandbox';
        }
        
        for(lead rowLeadRecords : scope) 
        { 
            if(rowLeadRecords.Email!= null && !rowLeadRecords.Email.containsIgnoreCase(strSandboxUnigueName)) 
                rowLeadRecords.Email = rowLeadRecords.Email + '.'+strSandboxUnigueName;
            
            if(rowLeadRecords.Unique_Email__c !=null &&  !rowLeadRecords.Unique_Email__c .containsIgnoreCase(strSandboxUnigueName)) 
                rowLeadRecords.Unique_Email__c = rowLeadRecords.Unique_Email__c + '.'+strSandboxUnigueName;
            
        } 
        
        // Try updating the Cases with allOrNone set to false so the whole update isn't rolled back if just one record fails...
        if(strSandboxUnigueName!=null){
            Database.SaveResult[] lstSaveResults = Database.Update(scope, false);
            ErrorLogger.writeErrors('SFDC', 'Lead', 'Batch_EmailMaskingLead', lstSaveResults, scope);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : lstSaveResults ) 
            {
                if (sr.isSuccess()) 
                { 
                    intSucessCounter++;}
                else {
                    intErrorCounter++;
                }
            } 
        }
    }
    global void finish(Database.BatchableContext BC) { 
        
        AsyncApexJob batchrecords = [Select Id, Status, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :BC.getJobId()];
        
        // Email the Batch Job's submitter that the Job is finished.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {batchrecords.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Batch_EmailMaskingLead Status: ' + batchrecords.Status);
        mail.setPlainTextBody('Postrefresh Lead Update batch Apex job is processed with' + batchrecords.TotalJobItems +' batches with '+ intSucessCounter + 'successes and ' + intErrorCounter + ' failures. ' );
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } 
    
}