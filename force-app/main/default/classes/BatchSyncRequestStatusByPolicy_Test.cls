/**
 *
 * test class for BatchSyncRequestStatusByPolicy
 * 
 * Version  Date          Owner                               RQ#           Description
 ***********************************************************************************************************************************************
 * 1.0    11/03/2018      meghana.gupta@ust-global.com        RQ-008054     Batch job to sync the status of Request based on pricing management based policy settings
 * 1.1    04/04/2018      Nitin More                          RQ-008277     Corrected parameters passed to preparePricingMgmtRec method 
 * 1.2    28/10/2020      Meghana Gupta						  SFSE-4767		Permission set assignee fetched could be actual inactive user, so added code to get active user
 * 1.3    07/06/2022      Ronnie@SF                           SPI-100       Removed brand hardcodings
 */
@isTest
public class BatchSyncRequestStatusByPolicy_Test {

    @testSetup static void setup() {
              
        if (UserDataGeneratorHelper_Test.SystemAdminUser == null) {
            UserDataGeneratorHelper_Test.initializeSystemAdminUser(); 
        }
        
        System.runAs(UserDataGeneratorHelper_Test.SystemAdminUser) {
            RateSheetData_Test.assignGSCPermissionSet(UserDataGeneratorHelper_Test.SystemAdminUser.Id);
             RateSheetData_Test.assignPricingManagerPermissionSet(UserDataGeneratorHelper_Test.SCLSystemAdminUser.Id);
        }
        
        Map<String, String> GeoCountryList = new Map<String, String> ();
        GeoCountryList.put('Denmark', 'Country');
        GeoCountryList.put('China', 'Country');       
        List<Geography__c> geoList = DataGeneratorHelper1_Test.createGeography (GeoCountryList);
        
        Account clientAcc = AccountDataHelper_Test.createClientAccount();    
        List<Product2> prodList = DataGeneratorHelper1_Test.createProduct2WithEquipsAndCommodities( 1,'B','DE','Ocean');
    
        List<Pricing_Management__c> lstPricingMgmt = new List<Pricing_Management__c>();
        lstPricingMgmt.add(RateSheetData_Test.preparePricingMgmtRec(prodList[0].Id, 'FAK', '20DRY;20REEF', '1 Month', '1', true, '20DRY;20REEF', '1 Month', '1', true));
        lstPricingMgmt.add(RateSheetData_Test.preparePricingMgmtRec(prodList[0].Id, 'Scrap Metal', '20DRY;20REEF;40HREF', '1 Month', '1', true, '20DRY;20REEF;20DRY', '1 Month', '1', true));
        lstPricingMgmt.add(RateSheetData_Test.preparePricingMgmtRec(prodList[0].Id, 'Animal Fodder', '20DRY;20REEF', '1 Month', '1', true, '20DRY;20REEF', '1 Month', '1', true));
       
        System.runAs(UserDataGeneratorHelper_Test.SCLSystemAdminUser) {
            insert lstPricingMgmt;
        }
        
        Request__c req1 = RateSheetData_Test.createRequest(clientAcc.id, BrandUtilities.MAERSKLINE, 'No', 'Merged LQB & CL', System.Label.FWD, 'No', 'Customised', 'Both', 'New', lstPricingMgmt[0].Id, lstPricingMgmt[0].Commodity__c, '20DRY;40DRY' );
        Request__c req4 = RateSheetData_Test.createRequest(clientAcc.id, BrandUtilities.SEALAND, 'No', 'Merged LQB & CL', System.Label.BCO, 'No', 'Customised', 'Both', 'New', lstPricingMgmt[0].Id, lstPricingMgmt[0].Commodity__c, '20DRY;' );
        Request__c req5 = RateSheetData_Test.createRequest(clientAcc.id, BrandUtilities.SEAGO, 'No', 'Merged LQB & CL', System.Label.BCO, 'No', 'Customised', 'Both', 'New', lstPricingMgmt[0].Id, lstPricingMgmt[0].Commodity__c, '20DRY;' );
        
        Request__c req2 = RateSheetData_Test.createRequest(clientAcc.id, BrandUtilities.MAERSKLINE, 'No', 'Merged LQB & CL', System.Label.FWD, 'No', 'Customised', 'Both', 'New', lstPricingMgmt[1].Id, lstPricingMgmt[1].Commodity__c, '20DRY;40DRY' );
        Request__c req3 = RateSheetData_Test.createRequest(clientAcc.id, BrandUtilities.MAERSKLINE, 'No', 'Merged LQB & CL', System.Label.BCO, 'No', 'Customised', 'Both', 'New', lstPricingMgmt[2].Id, lstPricingMgmt[2].Commodity__c, '20DRY;40DRY' );
        
        System.runAs(UserDataGeneratorHelper_Test.SystemAdminUser) {
            req1.Status__c = 'Active';
            req1.Team__c = 'GSC';
            update req1;
            
            req2.Status__c = System.Label.Request_Status_Inactive;
            req2.Team__c = 'GSC';
            update req2;
            
            req3.Status__c = 'Active';
            req3.Team__c = 'GSC';
            update req3;
            
            req4.Status__c = 'Active';
            req4.Team__c = 'GSC';
            update req4;
            
            req5.Status__c = 'Inactive due to Policy Change';
            //req5.Team__c = 'Rate Sheet Governance';
            update req5;
        }
        lstPricingMgmt[0].Active_FWD__c = true;
        lstPricingMgmt[0].Active_BCO__c = true;
        lstPricingMgmt[0].Equipment_Types_BCO__c = '20DRY';
        
        lstPricingMgmt[1].Active_FWD__c = true;
        lstPricingMgmt[2].Equipment_Types_BCO__c = '20DRY';
        
        System.runAs(UserDataGeneratorHelper_Test.SCLSystemAdminUser) {
            update lstPricingMgmt;
        }
    }
    
    @isTest static void testBatchRun1() {
        
        Test.startTest();
        BatchSyncRequestStatusByPolicy batchTest = new BatchSyncRequestStatusByPolicy();
        Database.executeBatch( batchTest); 
        Test.stopTest();
        
        List<Request__c> lstRequestAfterBatch = [SELECT Id, Status__c FROM Request__c WHERE Status__c = :System.Label.Request_Status_Inactive];
        System.assertEquals(lstRequestAfterBatch[0].Status__c, System.Label.Request_Status_Inactive);
    }
    
      @isTest static void testBatchRun2() {
           
          PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Request_Pricing_Manager'];
          List<PermissionSetAssignment> lstPSA = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id];
          
          List<Id> lstAssigneeIds = new List<Id>();
          for (PermissionSetAssignment psa : lstPSA ) {
              lstAssigneeIds.add(psa.AssigneeId);
          }
          List<User> lstUser = [SELECT Id FROM User WHERE Id in :lstAssigneeIds AND isActive = true LIMIT 1];
          
          List<Pricing_Management__c> lst = [SELECT Id, Equipment_Types_FWD__c, Active_FWD__c FROM Pricing_Management__c];
          lst[0].Active_FWD__c = true;
          lst[0].Equipment_Types_FWD__c = '40DRY;40HDRY';
          
          lst[1].Active_FWD__c = true;
          lst[1].Equipment_Types_FWD__c = '20REEF';
          
          lst[2].Active_FWD__c = true;
          lst[2].Equipment_Types_FWD__c = '20DRY;40DRY;40HDRY';
          
          System.runAs(lstUser[0]) {
              update lst;
          }
          
          Test.startTest();
          BatchSyncRequestStatusByPolicy batchTest = new BatchSyncRequestStatusByPolicy();
          Database.executeBatch( batchTest); 
          Test.stopTest();
          
          List<Request__c> lstRequestAfterBatch = [SELECT Id, Status__c FROM Request__c WHERE Status__c = :System.Label.Request_Status_Inactive];
          System.assertEquals(lstRequestAfterBatch[0].Status__c, System.Label.Request_Status_Inactive);
      }
    
     @isTest static void testScheduler() {
         
         Test.startTest();
         Scheduler_BatchSyncRequestStatusByPolicy schClass = new Scheduler_BatchSyncRequestStatusByPolicy();
         string timeinterval = '0 0 1 * * ?';
         System.schedule( 'Scheduler_BatchSyncRequestStatusByPolicy', timeinterval , schClass );
         Test.stopTest();
     }
}