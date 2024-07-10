/* This batch code is created to update records in Territory_Account_Association__c object
 * as per SFSE-5588 story to update newly created fields. 
 * 
 * This class is of one-off use. Once new fields are updated in PROD then BatchUpdateTerritoryAccAssoc 
 * and BatchUpdateTerritoryAccAssoc_Test class should be deleted.
 * 
*/
global class BatchUpdateTerritoryAccAssoc implements Database.Batchable<SObject> {
	global Database.queryLocator start( Database.BatchableContext ctx ) {
        String strRecordTypeIdPortfolio = Schema.SObjectType.Territory__c.getRecordTypeInfosByName().get('Portfolio').getRecordTypeId();
        
        //get Territory Account Association records to update
        String strQuery = 'SELECT Id, Name, Account__c, Account_Concern_Code__c, Represents_Concern__c';
        	strQuery += ' FROM Territory_Account_Association__c';
        	strQuery += ' WHERE Territory__r.RecordTypeId = \'' + strRecordTypeIdPortfolio +'\'';
        	strQuery += ' AND (Account__r.Concern_Code__c != null OR Account__r.Represents_Concern__c = true)';
        
        System.debug(' # strQuery: ' + strQuery);
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute( Database.BatchableContext BC, List<Territory_Account_Association__c> scope ) {
        Set<Id> setAccountId = new Set<Id>();
        
        for (Territory_Account_Association__c recTAAAccountId : scope ) {
            setAccountId.add(recTAAAccountId.Account__c);
        }
        
        Map<Id, Account> mapAccount = new Map<Id, Account>([SELECT Id, Name, RecordTypeId, Parent.SCV_Code__c, Represents_Concern__c FROM Account Where Id in :setAccountId]);
        List<Territory_Account_Association__c> lstTAAToUpdate = new List<Territory_Account_Association__c>();
        
        for (Territory_Account_Association__c recTAA : scope ) {
            Account recAccount = mapAccount.get(recTAA.Account__c);
            
            if (recAccount != null){
                recTAA.Account_Concern_Code__c = (recAccount.ParentId != null) ? recAccount.Parent.SCV_Code__c : null;
                recTAA.Represents_Concern__c = recAccount.Represents_Concern__c;
                
                lstTAAToUpdate.add(recTAA);
            }
        }
        
        database.update(lstTAAToUpdate, false);
    }
    
    global void finish(Database.BatchableContext BC){
    }
}