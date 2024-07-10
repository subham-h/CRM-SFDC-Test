/*
 * Note: BatchUpdatePortfolioSalesJobFunction class has been created to update newly created Portfolio_Owner_Sales_Job_Function__c field as per SFSE-6116 story
 *       Use of this class is one-off and need to be deprecated once Portfolio_Owner_Sales_Job_Function__c field is populated.
 * 
 *
 * Revision Ref Number  Date        Owner                           Description
 * -------- ----------  ----------- -------------------             -----------
 * 1.0      SFSE-6116   23-Jun-2021 Neha@Maersk                    Class Created. 
*/
global class BatchUpdatePortfolioSalesJobFunction implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id portfolioRecTypeId =  (Id) Schema.SObjectType.Territory__c.getRecordTypeInfosByName().get('Portfolio').getRecordTypeId();
        
        //Query to fetch the TAA 
        String strQuery = 'SELECT Id, Territory__c, Territory__r.Portfolio_Owner_Sales_Job_Function__c,Portfolio_Owner_Sales_Job_Function__c ';
            strQuery += ' FROM Territory_Account_Association__c '; 
            strQuery += ' WHERE Territory__r.RecordTypeId = \'' + portfolioRecTypeId +'\'' ;
        
        System.debug(' $$$ strQuery : ' + strQuery);
        return Database.getQueryLocator(strQuery);
    }

    global void execute( Database.BatchableContext bc, List<sObject> scope ) {
        List<Territory_Account_Association__c> lstTAA = ( List<Territory_Account_Association__c> ) scope;
        
        for (Territory_Account_Association__c recTAA : lstTAA){
            recTAA.Portfolio_Owner_Sales_Job_Function__c = recTAA.Territory__r.Portfolio_Owner_Sales_Job_Function__c;           
        }        

        List<Database.SaveResult> lstTAASaveResult = Database.Update(lstTAA, false);
        System.debug('lstTAASaveResult:::'+ lstTAASaveResult);
        ErrorLogger.writeErrors('SFDC', 'Territory_Account_Association__c', 'BatchUpdatePortfolioSalesJobFunction', lstTAASaveResult, lstTAA);
    }

    global void finish(Database.BatchableContext bc) {
        
    }
}