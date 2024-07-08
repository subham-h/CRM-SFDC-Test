/*
* Version  Date             Owner                                    RQ#           Description
***********************************************************************************************************************************************
* 1.0      17/03/2021		Sidhartha@Maersk.com					SFSE-5366
* 
*/


public class BatchTerrMgmtSyncSalesOwnerOnAccount implements Database.Batchable<SObject>, Database.Stateful {
    public Set<Id> accountIds = new Set<Id>();
    private Boolean blnProcessSkewedAccounts;
    private Integer scopeSize;
    
    //private static final String POR_SALES_CONTROL = 'Sales Owner';
    //private static final String POR_GLOBAL_ACCOUNT_OWNER = 'Global Account Owner';
    String ptRecordTypeID = Schema.SObjectType.Territory__c.getRecordTypeInfosByDeveloperName().get('Portfolio').getRecordTypeId();
    
    public BatchTerrMgmtSyncSalesOwnerOnAccount(Boolean blnProcessSkewedAccts){
        this.blnProcessSkewedAccounts = blnProcessSkewedAccts;
        scopeSize = this.blnProcessSkewedAccounts ? 1 : 20;
    }

    public Database.QueryLocator start( Database.BatchableContext BC ){ 
       
        String soqlQuery = '';
        String strDate;
        
        if(!Test.isRunningTest()){
            strDate = System.Label.AccBrandOwnerDateRange;
        }else{
            strDate = null;
        }
        
        List<Account_Skew__mdt> lstAccountSkew = Account_Skew__mdt.getall().values();
        Set<Id> setAccountIdToExclude = new Set<Id>();
		for (Account_Skew__mdt recAS : lstAccountSkew){
   			setAccountIdToExclude.add(recAS.Account_Skew_Id__c);
		}
        
            If(strDate != null) {
                soqlQuery = 'SELECT Id, Account__c FROM Territory_Account_Association__c WHERE (CreatedDate =' +strDate+' OR LastModifiedDate = '+strDate+' OR Start_Date__c = Today ) AND Territory__r.RecordTypeId = :ptRecordTypeID' ; 
                if (setAccountIdToExclude.size() > 0){
                    soqlQuery += (blnProcessSkewedAccounts) ? ' AND Account__c in :setAccountIdToExclude ' : ' AND Account__c not in :setAccountIdToExclude ';
                }
                soqlQuery += ' ALL ROWS';
            } else{
                soqlQuery = 'SELECT Id, Account__c FROM Territory_Account_Association__c WHERE Territory__r.RecordTypeId = :ptRecordTypeID ';
                if (setAccountIdToExclude.size() > 0){
            		soqlQuery += (blnProcessSkewedAccounts) ? ' AND Account__c in :setAccountIdToExclude ' : ' AND Account__c not in :setAccountIdToExclude ';
        		}
            } 
        return Database.getQueryLocator(soqlQuery);
    }

    public void execute( Database.BatchableContext info,  List<SObject> Scope ){ 
        List<Territory_Account_Association__c> lstTAAtobeIterated = ( List<Territory_Account_Association__c> ) Scope;
        for(Territory_Account_Association__c taaObj  : lstTAAtobeIterated){  
            accountIds.add(taaObj.Account__c);
        } 
    }

    public void finish( Database.BatchableContext BC ) {
       Database.executeBatch(new BatchTerrMgmtSyncTerritoryOwnerOnAccount(accountIds, false),scopeSize);
    }
    
}