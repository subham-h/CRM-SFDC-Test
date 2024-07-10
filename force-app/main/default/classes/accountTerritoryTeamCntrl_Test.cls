/*
 *  Story Number     Date           Owner                  Description
 ************************************************************************************************************
 *  SFSE-5365        26/05/2021     Meghana Gupta          Code Created
 *  SFSE-6116        24/06/2021     Neha@TCS               Updated the method to invoke fetchOneTeamDetails()
 *  SPI-100          07/06/2022     Ronnie@SF              Removing brand hardcodings
 *  SFSE-13491       14-dec-2023    Bharti           Remove hardcoding of Portfolio owner Responsibility
 */

@isTest
public class accountTerritoryTeamCntrl_Test {
    @testSetup static void setup() {
        
         if (UserDataGeneratorHelper_Test.salesUser == null) {
            UserDataGeneratorHelper_Test.initializeSalesUser();
        }
        if (UserDataGeneratorHelper_Test.MSLSystemAdminUser == null) {
            UserDataGeneratorHelper_Test.initializeSystemAdminUser();
        }
         TriggerExecutionController.skipAllTriggers(true);
        Account clientAcc1 = AccountDataHelper_Test.createClientAccount();  
              
        Account clientAcc2 = AccountDataHelper_Test.createClientAccount(null, 'Active', 'TEST12345');   
        Account concernAcc = AccountDataHelper_Test.createConcernAccount();
       
        List <PermissionSet> lstPS = [SELECT Id FROM PermissionSet WHERE Name = 'APP_Territory_Management_Manage_Portfolios' ];
        // assign manage portfolio permission set to user 
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = UserDataGeneratorHelper_Test.MSLSystemAdminUser.Id;
        psa.PermissionSetId = lstPS[0].Id;  
        
        System.runAs(UserDataGeneratorHelper_Test.SystemAdminUser) {
            insert psa;           
        }
         TriggerExecutionController.skipAllTriggers(true);
        List<Territory__c> lstInsertTerritory = new List<Territory__c>();
        lstInsertTerritory.add(TerritoryDataGeneration_Test.createPortfolio('testPortfolio1',UserDataGeneratorHelper_Test.salesUser.Id));
        lstInsertTerritory.add(TerritoryDataGeneration_Test.createPortfolio('testPortfolio2',UserDataGeneratorHelper_Test.MSLsalesUser.Id));
         Test.startTest();
        insert(lstInsertTerritory);
         
         TriggerExecutionController.skipAllTriggers(true);
       
        List<Territory_Account_Association__c> lstInsert = new List<Territory_Account_Association__c>();
        lstInsert.add( TerritoryDataGeneration_Test.addAccountToPortfolio(lstInsertTerritory[0].Id, clientAcc1.Id, BrandUtilities.SEAGO, TAASettingConstants.POR_SALES_CONTROL));  
        lstInsert.add( TerritoryDataGeneration_Test.addAccountToPortfolio(lstInsertTerritory[0].Id, clientAcc2.Id, BrandUtilities.SEAGO, TAASettingConstants.POR_SALES_CONTROL)); 
        //lstInsert.add( TerritoryDataGeneration_Test.addAccountToPortfolio(lstInsertTerritory[1].Id, RC1.Id, BrandUtilities.MAERSKLINE, 'Global Account Owner'));  
        //lstInsert.add( TerritoryDataGeneration_Test.addAccountToPortfolio(lstInsertTerritory[1].Id, RC1.Id, BrandUtilities.MAERSKLINE, 'Global Account Owner'));
        //lstInsert.add( TerritoryDataGeneration_Test.addAccountToPortfolio(lstInsertTerritory[1].Id, concernAcc.Id, BrandUtilities.MAERSKLINE, 'Sales Owner'));  

        System.runAs(UserDataGeneratorHelper_Test.MSLSystemAdminUser){
               TriggerExecutionController.skipAllTriggers(true);
            insert(lstInsert);
        }
          TriggerExecutionController.skipAllTriggers(true);
        AccountDataHelper_Test.createAccountTeamMember(clientAcc1.Id, UserDataGeneratorHelper_Test.MSLSystemAdminUser.Id, 'Finance');
        Test.stopTest();
    }
    
     static testMethod void testCntrl() {
         
        Id clientRecType = StaticFactory.getRecordTypeIdByName('Account', 'Client Account');
        List<Account> lstAccount = [SELECT id FROM Account WHERE RecordTypeId = :clientRecType LIMIT 2]; 
        
        
        Test.startTest();
          TriggerExecutionController.skipAllTriggers(true);
         accountTerritoryTeamCntrl.getDataRows(lstAccount[0].Id);
         accountTerritoryTeamCntrl.getDataRows(lstAccount[1].Id);
         Test.stopTest();
     }
    
    static testMethod void testCntrl2 () {
         
        Id clientRecType = StaticFactory.getRecordTypeIdByName('Account', 'Client Account');
        List<Account> lstAccount = [SELECT id, parentId FROM Account WHERE RecordTypeId = :clientRecType LIMIT 2]; 
        List<Account> lstConcernAccount = [SELECT id, parentId FROM Account WHERE RecordTypeId != :clientRecType LIMIT 1]; 
        lstAccount[0].parentId = lstConcernAccount[0].Id;
        lstAccount[1].parentId = lstConcernAccount[0].Id;
        update(lstAccount);
        
        
        List<Territory__c> lstTerritory = [SELECT Portfolio_Owner__c FROM Territory__c LIMIT 1];
        User userRec = [SELECT Id FROM USER WHERE Id = :lstTerritory[0].Portfolio_Owner__c ];
        
        Test.startTest();
         System.runAs(userRec){
             TriggerExecutionController.skipAllTriggers(true);
             accountTerritoryTeamCntrl.getDataRows(lstAccount[0].Id);
             accountTerritoryTeamCntrl.getDataRows(lstAccount[1].Id);     
        }
         
        
        accountTerritoryTeamCntrl.addEditTeamMember(lstAccount[0].Id, userRec.Id, 'Finance', null );
        List<AccountTeamMember> lstTeamMember = [SELECT Id, UserId, AccountId , TeamMemberRole From AccountTeamMember LIMIT 1];
        accountTerritoryTeamCntrl.addEditTeamMember(lstTeamMember[0].AccountId, lstTeamMember[0].UserId, 'Solutions Engineer', lstTeamMember[0].Id );
        accountTerritoryTeamCntrl.deleteTeamMember(lstTeamMember[0].Id);
        accountTerritoryTeamCntrl.fetchOneTeamDetails(lstAccount[0].Id);

        
         Test.stopTest();
    }   

}