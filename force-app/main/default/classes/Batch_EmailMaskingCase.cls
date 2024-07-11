/*
* Author   : Abhinav
* Purpose  : Utility Batch Class for email masking for Case object . 
*
* Version       Date            Owner                               Description
******************************************************************************************************************************************************
* v1.0      25-Feb-2019    abhinav.ankit@maersk.com    RQ-010163 -> For updating Case SuppliedEmail with SandboxName
------------------------------------------------------------------------------------------------------------------------------------------------------>
*/
global class Batch_EmailMaskingCase implements Database.Batchable<sObject>, Database.Stateful { 
    global Integer intSucessCounter = 0;
    global Integer intErrorCounter= 0;
    global String strSandboxUnigueName;
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        String query = 'select id,SuppliedEmail,CreatedDate from case where CreatedDate < LAST_QUARTER '; 
        return Database.getQueryLocator(query);  
    }
    
    // For updating Lead email,Unique_Email__c with .preprod2
    
    global void execute(Database.BatchableContext BC, List<case> scope) { 
        strSandboxUnigueName = URL.getSalesforceBaseUrl().getHost().substringBetween('--','.');
        if(Test.isRunningTest()){
            strSandboxUnigueName ='Sandbox';
        }
        
        for(case rowCaseRecords : scope) 
        { 
            if(rowCaseRecords.SuppliedEmail!= null && !rowCaseRecords.SuppliedEmail.containsIgnoreCase(strSandboxUnigueName) && rowCaseRecords.SuppliedEmail.length()<71) 
                rowCaseRecords.SuppliedEmail= rowCaseRecords.SuppliedEmail +  '.'+strSandboxUnigueName;
            
            
        } 
        
        // Try updating the Cases with allOrNone set to false so the whole update isn't rolled back if just one record fails...
        if(strSandboxUnigueName!=null){
            Database.SaveResult[] lstSaveResults = Database.Update(scope, false);
            ErrorLogger.writeErrors('SFDC', 'Case', 'Batch_EmailMaskingCase', lstSaveResults, scope);
            
            
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
        mail.setSubject('Batch_EmailMaskingCase Status: ' + batchrecords.Status);
        mail.setPlainTextBody('Postrefresh Case Update batch Apex job is processed with ' + batchrecords.TotalJobItems +' batches with ' + intSucessCounter + ' successes and ' + intErrorCounter + ' failures.' );
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } 
    
}