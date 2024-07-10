/*
* Author   : Nisha
* Purpose  : Test Batch_GenericPurgerSchedulerHelper
*
* Revision Ref Number   Date          Owner                   				       Description
* -------- ----------   -----------   -------------------     					   -----------
* 1.0      RQ-003324    14-Jun-2016   Nisha.arjunan@UST       					   Created.
* 2.0 	   RQ-007205	30-Jan-2018	  Madhubharathi.Gopalakrishnan@ust-global.com  Remove the Eloqua managed package now moved to SFMC.
* 3.0      RQ-012850    10-Jan-2020   manjunath@maersk                             Cover new method, 'purgeOppSplitSch', in 'Batch_GenericPurgerSchedulerHelper' class
* 3.1      RQ-012849    14-Jan-2020   Amritesh@UST                                 Add test_purgeQuoteDocument method
* 4.0	   SC-2929		24-Aug-2021   meghna@maersk								   Cover new method 'purgeOOOCase' in 'Batch_GenericPurgerSchedulerHelper' class
* 5.0	   SFSE-14271	04-June-2024  Seba@Maersk								   Test coverage for new method 'purgeTAA' in 'Batch_GenericPurgerSchedulerHelper' class
*/

@isTest  
public class Batch_GenericPurgerSchedulerHelper_Test {
    
    //SFSE-14271
    @testSetup 
    static void dataSetup() {
        TriggerExecutionController.skipAccountTrigger(true);
        Account concernAccount = TestBusinessHelper.createAccount('Concern_Account',False);
        concernAccount.Customer_Code__c='TEST44565CONCERNCODE';
        concernAccount.Id=NULL;
        concernAccount.SCV_Status__c = 'Active';
        insert concernAccount;
        Assert.isNotNull(concernAccount.Id);
        
        Account Acc2 = TestBusinessHelper.createAccount('Client_Account',False);
        Acc2.Customer_Code__c='TEST445652';
        Acc2.ParentId=concernAccount.Id;
        Acc2.SCV_Status__c = 'Active';
        Acc2.Id=NULL;
        insert Acc2; 
        Assert.isNotNull(Acc2.Id);
        
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null,'IN',TRUE); 
        Assert.isNotNull(country.Id);
        
        User adminUser = TestBusinessHelper.createUser('System Administrator', BrandUtilities.MAERSKLINE, false);   
        adminUser.Id = null;
        adminUser.IsActive=true;
        adminUser.country = 'India';
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert adminUser;
        } 
        Assert.isNotNull(adminUser.Id); 
        
        User salesUser1 = new User();
        System.runAs(adminUser){
            salesUser1 = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
            salesUser1.Id = null;
            salesUser1.IsActive=true;
            salesUser1.country = 'India';
            salesUser1.Cluster__c = 'GSC';
            salesUser1.Industry_Focus__c='Retail';
            salesUser1.Segment_Focus__c='Advancement';
            salesUser1.Sales_Job_Function__c='Other'; 
            insert salesUser1;
            
            Id managePortfolioPermissionSetId = [SELECT Id,Name FROM PermissionSet WHERE NAME ='APP_Territory_Management_Manage_Portfolios' LIMIT 1].Id;
            List<PermissionSetAssignment> ps =[SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId=:managePortfolioPermissionSetId AND AssigneeId=:UserInfo.getUserId()];
            if(ps.isEmpty()){
                insert new PermissionSetAssignment(AssigneeId=UserInfo.getUserId(), PermissionSetId=managePortfolioPermissionSetId);
            }
        }
        
        User sysAdminUsr = [SELECT Id FROM User WHERE EMail =:'systemadministratormaerskline@maersk.com' LIMIT 1];
        Assert.isNotNull(sysAdminUsr);
        
        Territory__c ter1 = TestBusinessHelper.createTerritory(salesUser1, TRUE);
        Territory_Account_Association__c TAA = TestBusinessHelper.createTerritoryAccountAssociation(ter1, Acc2, TAASettingConstants.POR_SALES_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
        TAA.Id = NULL; 
        TAA.Start_Date__c = System.today().addDays(-900);
        TAA.End_Date__c = System.today().addDays(-850);  
        
        System.runAs(sysAdminUsr){          
            insert TAA;
        }  
        
         //Inserting 'Purge Configuration' list custom setting
        Purge_Configuration__c pc = new Purge_Configuration__c(Name = 'Territory Account Association',Object_Name__c = 'Territory_Account_Association__c',Job_Number__c = 1,Operation__c = '<',Order__c = 1,Value__c = 'LAST_N_FISCAL_QUARTERS:4 AND End_Date__c!= null',Field_Name__c = 'End_Date__c');
        insert pc;
        
    }
    public static testMethod void test_batchPurgerSchedulerHelper() {
        Batch_GenericPurgerSchedulerHelper helper =new Batch_GenericPurgerSchedulerHelper();
        
        Test.startTest();
        helper.purgeGlobalErrorLogger();
        helper.purgeOppSplitSch();
        Test.stopTest();     
    }
    
    public static testMethod void test_purgeQuoteDocument() {
        Batch_GenericPurgerSchedulerHelper helper =new Batch_GenericPurgerSchedulerHelper();
        
        Test.startTest();
        helper.purgeQuoteDocument();
        Test.stopTest();     
    }
    public static testMethod void test_purgeOOOCase() {
        Batch_GenericPurgerSchedulerHelper helper =new Batch_GenericPurgerSchedulerHelper();
        
        Test.startTest();
        helper.purgeOOOCase();
        Test.stopTest();     
    }
    public static testMethod void test_purgeOOOCase2() {
        Batch_GenericPurgerSchedulerHelper helper =new Batch_GenericPurgerSchedulerHelper();
        
        Test.startTest();
        Batch_GenericPurgerScheduler bgs = new Batch_GenericPurgerScheduler('Case',1,true,true); 
        String sch ='0 48 * * * ?'; 
        System.schedule('Schedule', sch,bgs);
        Test.stopTest();   
        
        
    }
    public static testMethod void test_purgeOOOCase3() {
        Batch_GenericPurgerSchedulerHelper helper =new Batch_GenericPurgerSchedulerHelper();
        
        Test.startTest();
        Batch_GenericPurgerScheduler bgs = new Batch_GenericPurgerScheduler('Case',1,false); 
        String sch ='0 48 * * * ?'; 
        System.schedule('Schedule', sch,bgs);
        Test.stopTest();   
        
        
    }
    
    @isTest
    static void testShipmentCargoPurge(){
        
        Batch_GenericPurgerSchedulerHelper helper =new Batch_GenericPurgerSchedulerHelper();
        Test.startTest();
        helper.purgeCargo();
        helper.purgeEquipment();
        helper.purgeEquipmentStuffing();
        helper.purgeParty();
        helper.purgeShipment();
        Test.stopTest();
        
    }
    
    //SFSE-14271
    @isTest
    static void testTAAPurge(){  
        Test.startTest();  
        Batch_GenericPurgerSchedulerHelper helper = new Batch_GenericPurgerSchedulerHelper(); 
        helper.purgeTAA(); 
        Test.stopTest();
      }  
}