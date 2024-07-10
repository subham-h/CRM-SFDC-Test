/**
* Test class for :  BatchTerrMgmtSyncSalesOwnerOnAccount

* Date         Owner                                                    Description
*************************************************************************************************************************************
* 06/25/2018    JOhn.Christopher@ust-global.com                     Territory Management V2
* 07/12/2019    Neha TCS                                            Changed for RQ011197
* 15-Oct-2020   meghana.gupta@ust                                   #SFSE-4767 Deprecate Safmarine brand, hence remove refernces to safmarine
* 23-03-2021    sidhartha                                           Test class for BatchTerrMgmtSyncSalesOwnerOnAccount
* 28-Sep-2021   Kiran@Maersk                                        #SFSE-6066 Removing Territory references
* 25-Jul-2023   Shubham@Maersk                                      #SFSE-11833 Increase code coverage by creating TAA for Sales Owner - Non-Control Only
* 11-Oct-2023   Seba@Maersk                                         #SFSE-12234 Modified code for test class failure and increasing code coverage
* 26-Oct-2023   Seba@Maersk                                         #SFSE-12234 Modified code for test class failure in UAT
* 14-dec-2023   Bharti@Maersk                                      Remove hardcoding of Portfolio owner Responsibility/Brand
* 09-Feb-2023   Arpitha@Maersk                                     Added method Scheduler_BatchTerrSyncSalesOwnerSkewAcc to cover Scheduler_BatchTerrSyncSalesOwnerSkewAcc Scheduler Class
* */

@isTest
public class BatchTerrMgmtSyncSalesOwnerOnAcct_Test {
    
    @testSetup static void setup() {
        //TriggerExecutionController.skipAccountTrigger(true);
        //TerritoryDataGeneration_Test.createTerritoryData(); 
        //TriggerExecutionController.skipAccountTrigger(false); 
        Geography__c country1 = TestBusinessHelper.createGeography('India', 'Country', NULL,'IN',FALSE); country1.Id = null;  
        insert country1;
        TriggerExecutionController.skipUserTrigger(true); 
        User adminUser = TestBusinessHelper.createUser('System Administrator', BrandUtilities.MAERSKLINE, false);   
        adminUser.Id = null;
        adminUser.IsActive=true;
        adminUser.country = 'India';
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert adminUser;
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'APP_Territory_Management_Manage_Portfolios' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id); 
        }  
        TriggerExecutionController.skipAllTriggers(true);
        TestBusinessHelper.createTerritory(adminUser, true);
        TriggerExecutionController.skipAccountTrigger(true);
        Account concernAccount = TestBusinessHelper.createAccount('Concern_Account',False);
        concernAccount.Customer_Code__c='TEST4876CONCERNCODE';
        concernAccount.Id=NULL;
        TriggerExecutionController.skipAccountTrigger(true);
        insert concernAccount; 
        Account acc = TestBusinessHelper.createAccount('Client_Account',false);
        acc.parentId = concernAccount.Id;
        acc.Id=NULL;
        TriggerExecutionController.skipAccountTrigger(true);
        insert acc; 
    }
    
    testmethod static void batchTerrMgmtSyncSalesOwnerOnAccount() {
        Test.startTest();
        BatchTerrMgmtSyncSalesOwnerOnAccount batchTest = new BatchTerrMgmtSyncSalesOwnerOnAccount(false);
        Database.executeBatch( batchTest); 
        Test.stopTest();
    }
    
    static testMethod void scheduler_BatchTerrMgmtSyncSalesOwner() {        
        test.starttest();
        Scheduler_BatchTerrMgmtSyncSalesOwner sch = new Scheduler_BatchTerrMgmtSyncSalesOwner ();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, sch);
        test.stopTest();
    }
    
    static testMethod void Scheduler_BatchTerrSyncSalesOwnerSkewAcc() {        
        test.starttest();
        SchedulableContext sc;
        Scheduler_BatchTerrSyncSalesOwnerSkewAcc sch = new Scheduler_BatchTerrSyncSalesOwnerSkewAcc();   
        sch.execute(sc);
        test.stopTest();
    }
    
    static testMethod void scheduler_BatchTerrMgmtSyncSalesOwner1() {
        Validation_Rules_Bypass__c  setting = new Validation_Rules_Bypass__c ();
        setting.Active__c  = true; 
        insert setting;
        Account acc = [select id from account where Recordtype.developerName = 'Client_Account' limit 1];
        Territory__c trr = [select id from Territory__c limit 1];
        Territory_Account_Association__c taa = new Territory_Account_Association__c();
        taa.Portfolio_Owner_Responsibility__c = TAASettingConstants.POR_SALES_NON_CONTROL_ONLY;
        taa.Brand__c = BrandUtilities.SEAGO;
        taa.Start_Date__c = System.today();
        taa.Account__c  = acc.Id; 
        taa.Represents_Concern__c = true;
        taa.Territory__c = trr.Id;
        taa.Id = null;
        TriggerExecutionController.skipAccountTrigger(true); 
        insert taa;   
        TriggerExecutionController.skipAccountTrigger(false);
        
        Test.starttest();
        BatchTerrMgmtSyncSalesOwnerOnAccount batchTest = new BatchTerrMgmtSyncSalesOwnerOnAccount(false);
        Database.executeBatch( batchTest);
        Test.stopTest();
    } 
    static testMethod void scheduler_BatchTerrMgmtSyncSalesOwner2() {
        Validation_Rules_Bypass__c  setting = new Validation_Rules_Bypass__c ();
        setting.Active__c  = true; 
        insert setting; 
        
        List<Territory_Account_Association__c> territoryList = new List<Territory_Account_Association__c>();
        //delete territoryList; Commented to fix test class failure
        Account acc = [select id from account where Recordtype.developerName = 'Client_Account' limit 1];
        Territory__c trr = [select id from Territory__c limit 1];
        Territory_Account_Association__c taa = new Territory_Account_Association__c();
        taa.Portfolio_Owner_Responsibility__c = TAASettingConstants.POR_SALES_CONTROL;
        taa.Brand__c = BrandUtilities.SEAGO;
        taa.Start_Date__c = System.today();
        taa.Account__c  = acc.Id; 
        taa.Represents_Concern__c = true;
        taa.Territory__c = trr.Id; 
        taa.Id = null;
        
        Territory_Account_Association__c taa2 = new Territory_Account_Association__c();
        taa2.Portfolio_Owner_Responsibility__c = TAASettingConstants.POR_SALES_CONTROL_ONLY;
        taa2.Brand__c =BrandUtilities.SEAGO;
        taa2.Start_Date__c = System.today();
        taa2.Account__c  = acc.Id; 
        taa2.Represents_Concern__c = true;
        taa2.Territory__c = trr.Id; 
        taa2.Id = null;
        
        territoryList.add(taa);territoryList.add(taa2); 
        TriggerExecutionController.skipAllTriggers(true); 
        insert territoryList; 
        
        Territory_Account_Association__c  territoryAA = [SELECT Id,Portfolio_Owner_Responsibility__c FROM Territory_Account_Association__c LIMIT 1];
        delete territoryAA;
        
        Test.starttest();
        BatchTerrMgmtSyncSalesOwnerOnAccount batchTest = new BatchTerrMgmtSyncSalesOwnerOnAccount(false);
        Database.executeBatch( batchTest);
        Test.stopTest();
    }   
}