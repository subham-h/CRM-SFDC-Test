/**
* -------------------------------------------------------------------------------------------------------------------------------------------------------
* Rev  Story       Name            Date                Comments
* 1. SFSE-12445   Bharti           20/09/2023          Test class Created for this batch 'BatchUpdateTAAPortfolioOwnerSalesJobFunc'.  
**/



@isTest
public class BatchUpdateTAAPortfolioOwnerSalesJobTest {
     @testSetup
    static void dataSetup(){
        
        List<Account> childAccounts = new List<Account>();
         User salesUser1 = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, true);
        salesUser1.Sales_Job_Function__c ='other';
        update salesUser1;
        
        if (UserDataGeneratorHelper_Test.MSLSystemAdminUser == null) {
            UserDataGeneratorHelper_Test.initializeSystemAdminUser();
        }
        
        System.runAs(UserDataGeneratorHelper_Test.MSLSystemAdminUser) {
            insert new PermissionSetAssignment (
                AssigneeId = salesUser1.id,
                PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'APP_Territory_Management_Manage_Portfolios'][0].Id);
        } 
        
        Territory__c ter1 = new Territory__c();
        System.RunAs(salesUser1){                       
            ter1 = TestBusinessHelper.createTerritory(salesUser1, TRUE);
            ter1.Portfolio_Owner__c= salesUser1.Id;
            update ter1;
        }
       
         Account Acc1 = TestBusinessHelper.createAccount('Client_Account',TRUE);
        Acc1.Customer_Code__c='TEST445654';
             
       update acc1; 
        System.RunAs(salesUser1){  
            Territory_Account_Association__c TAA1 = TestBusinessHelper.createTerritoryAccountAssociation(ter1, Acc1, TAASettingConstants.POR_SALES_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.MAERSKLINE, TRUE);
            TAA1.Portfolio_Owner_Sales_Job_Function__c ='Sales Manager';
            TAA1.End_Date__c = null;
            update TAA1;
        }
       
       }
    
   
    @isTest
    static void updatePotfolioJobOnTAA() 
    {
        Set<Id> userId = new Set<Id>();
        Map<Id,String> mapUserOfSalesJob = new Map<Id,String>();
        Set<Id> setOfterr = new Set<Id>();
               Territory__c terr = [Select id,Portfolio_Owner__c from Territory__c LIMIT 1 ];

        User user = [Select Id,Sales_Job_Function__c from User where id =:terr.Portfolio_Owner__c AND Sales_Job_Function__c = 'other' LIMIT 1 ];

         userId.add(user.Id);
         mapUserOfSalesJob.put(user.Id,user.Sales_Job_Function__c);
        system.debug('mapUserOfSalesJob'+mapUserOfSalesJob);
       // Territory__c terr = [Select id,Portfolio_Owner__c from Territory__c where Portfolio_Owner__c IN :userId];
        setOfterr.add(terr.Id);
        List<Territory_Account_Association__c> taas = [SELECT Id, Territory__r.Portfolio_Owner__c, Portfolio_Owner_Sales_Job_Function__c FROM Territory_Account_Association__c where Territory__c IN :setOfterr];
      
        System.assertEquals(1, taas.size());
      
        Test.startTest();  
       BatchUpdateTAAPortfolioOwnerSalesJobFunc batchInstance = new BatchUpdateTAAPortfolioOwnerSalesJobFunc(userId, mapUserOfSalesJob, setOfterr);
        
        // Execute the batch
        Database.executeBatch(batchInstance);
       Test.stopTest();  
        
    }
    

}