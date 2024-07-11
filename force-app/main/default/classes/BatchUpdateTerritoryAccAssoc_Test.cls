/**
 * This batch code is created to update records in Territory_Account_Association__c object as per SFSE-5588 story to update newly created fields. 
 * This class is of one-off use. Once new fields are updated in PROD then BatchUpdateTerritoryAccAssoc and BatchUpdateTerritoryAccAssoc_Test class should be deleted.
 * 
 * Version     Date         Owner                      RQ#            Description
 ******************************************************************************************************  
 * 1.0                                                 #              Code created
 * 2.0         07-06-2022   Ronnie@SF                  SPI-100        Removed brand hardcoding
 * 3.0         14-dec-2023     Bharti                 SFSE-13491     Remove hardcoding of Portfolio owner Responsibility
 */
@isTest(seeAllData=false)
public class BatchUpdateTerritoryAccAssoc_Test {
    
     @testSetup static void setup() {
         
         UserDataGeneratorHelper_Test.initializeSystemAdminUser();
         
         system.runAs(UserDataGeneratorHelper_Test.SystemAdminUser) {
         	TriggerExecutionController.skipAllTriggers(true);
             
         	// assign Liner Brand level access to user 
         	PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'APP_Territory_Management_Manage_Portfolios'];
         	PermissionSetAssignment psa = new PermissionSetAssignment();
         	psa.AssigneeId = UserDataGeneratorHelper_Test.MSLSystemAdminUser.Id;
         	psa.PermissionSetId = ps.Id;       
         	insert psa;           
            
         	TriggerExecutionController.skipAllTriggers(false);
         }

         system.runas( UserDataGeneratorHelper_Test.MSLSystemAdminUser ) {
			 List<Account> lstConcernAccounts = new List<Account>();
             List<Account> lstClientAccounts = new List<Account>();
        	 
             AccountData_Test.iNumberOfAccounts = 1;
        	 AccountData_Test.createConcernAccounts();
        	 lstConcernAccounts =AccountData_Test.lstAccounts;
             lstConcernAccounts[0].SCV_Code__c = '***0112233';
             update lstConcernAccounts;
             
             AccountData_Test.iNumberOfAccounts = 1;
        	 AccountData_Test.createClientAccounts();
             lstClientAccounts = AccountData_Test.lstAccounts;
             lstClientAccounts[0].ParentId = lstConcernAccounts[0].Id;
             lstClientAccounts[0].Represents_Concern__c = TRUE;
             lstClientAccounts[0].SCV_Status__c = 'Active';
             update lstClientAccounts;
             
             List<Territory__c> lstInsertTerritory = new List<Territory__c>();
        	 lstInsertTerritory.add(TerritoryDataGeneration_Test.createPortfolio('MSLTest1-PortfolioTerritory', UserInfo.getUserId()));
             insert(lstInsertTerritory); 
             
             List<Territory_Account_Association__c> lstInsert = new List<Territory_Account_Association__c>();
             lstInsert.add( TerritoryDataGeneration_Test.addAccountToPortfolio(lstInsertTerritory[0].Id, lstClientAccounts[0].Id, BrandUtilities.MAERSKLINE, TAASettingConstants.POR_SALES_CONTROL));
             insert lstInsert;
         }
    }
    
    @isTest static void testBatch() {
        
        Test.startTest();
        BatchUpdateTerritoryAccAssoc batchTest = new BatchUpdateTerritoryAccAssoc();
        Database.executeBatch(batchTest); 
        Test.stopTest();
        
        List<Territory_Account_Association__c> lstTAA = [SELECT Id, Account_Concern_Code__c FROM Territory_Account_Association__c WHERE Account_Concern_Code__c = null];
        System.assertEquals(lstTAA.size(), 0);
    }
}