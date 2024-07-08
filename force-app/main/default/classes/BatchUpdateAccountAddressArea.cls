/*
 * Note: BatchUpdateAccountAddressArea class has been created to update newly created Account_Address_Area__c field as per SFSE-6116 story
 *       Use of this class is one-off and need to be deprecated once Account_Address_Area__c field is populated.
 * 
 *       Batch size should not be more than 20 to keep record-level lock contention low.
 *
 * Revision Ref Number  Date        Owner                           Description
 * -------- ----------  ----------- -------------------             -----------
 * 1.0      SFSE-6116   24-Jun-2021 Nitin@Maersk                    Class Created 
 * 2.0      SFSE-6116   06-Jul-2021 Neha@TCS                        Extended the class for inactive accounts
 * 2.1      SFSE-6116   11-Aug-2021 Nitin@Maersk                    Added parameter blnProcessSkewedAccts 
*/
public class BatchUpdateAccountAddressArea implements Database.Batchable<SObject>, Database.Stateful {
    private Boolean blnProcessSkewedAccounts;
    
    public BatchUpdateAccountAddressArea(Boolean blnProcessSkewedAccts){
        this.blnProcessSkewedAccounts = blnProcessSkewedAccts;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Id clientAccountRecTypeId =  (Id) Schema.SObjectType.Account.getRecordTypeInfosByName().get( Label.ClientAccountRecordType).getRecordTypeId();
        Id inactiveAccountRecTypeId =(Id) Schema.SObjectType.Account.getRecordTypeInfosByName().get('Inactive Account').getRecordTypeId();
        
        List<Account_Skew__mdt> lstAccountSkew = Account_Skew__mdt.getall().values();
        Set<Id> setAccountIdToExclude = new Set<Id>();
		for (Account_Skew__mdt recAS : lstAccountSkew){
   			setAccountIdToExclude.add(recAS.Account_Skew_Id__c);
		}
        
        //Query to fetch the accounts to be processed
        String strQuery = 'SELECT Id, Country__c, Account_Address_Area__c ';
            strQuery += ' FROM Account '; 
	        strQuery += ' WHERE RecordTypeId in (\'' + inactiveAccountRecTypeId + '\',\''+clientAccountRecTypeId+'\') AND Country__c != null AND Account_Address_Area__c = null ';
        	if (setAccountIdToExclude.size() > 0){
            	strQuery += (blnProcessSkewedAccounts) ? ' AND Id in :setAccountIdToExclude ' : ' AND Id not in :setAccountIdToExclude ';
        	}
                    
        //System.debug(' $$$ strQuery : ' + strQuery);
        return Database.getQueryLocator(strQuery);
    }

    public void execute( Database.BatchableContext bc, List<sObject> scope ) {
        List<Account> lstAccount = ( List<Account> ) scope;
        Set<Id> setCountryId = new Set<Id>();
        Map<Id, Id> mapCountryToAreaCluster = new Map<Id, Id>();

        for (Account recAcc : lstAccount){
                setCountryId.add(recAcc.Country__c);
        }

        if (setCountryId.size() > 0){
            //Get Cluster for Account country from BDA Geography 
            for( BDA_Geography__c bdaGeoRec : [ SELECT Id, Geography__c, BDA__c FROM BDA_Geography__c WHERE Geography__c IN :setCountryId AND BDA__r.Type__c = 'Cluster' AND BDA__r.Active__c = True ]){

                mapCountryToAreaCluster.put(bdaGeoRec.Geography__c, bdaGeoRec.BDA__c);
            }            
        }

        for (Account recAcc2 : lstAccount){
          
            if (mapCountryToAreaCluster.get(recAcc2.Country__c) != null){
                recAcc2.Account_Address_Area__c = mapCountryToAreaCluster.get(recAcc2.Country__c);
            }
        }

        List<Database.SaveResult> lstAccountSaveResult = Database.Update(lstAccount, false);
        ErrorLogger.writeErrors('SFDC', 'Account', 'BatchUpdateAccountAddressArea', lstAccountSaveResult, lstAccount);
    }

    public void finish(Database.BatchableContext bc) {

    }
}