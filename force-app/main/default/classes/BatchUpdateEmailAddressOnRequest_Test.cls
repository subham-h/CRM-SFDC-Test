/**
 * Test Class for BatchUpdateEmailAddressOnRequest and ScheduleBatchUpdateEmailAddressOnRequest
 * 
 * Date         Owner                                       Ref Number      Description
 **************************************************************************************************************************************
 * 11/03/2016   ramadevi.palaniswamy@ust-global.com         RQ-005348       Batch apex job to update contact and user email address on Request object
 * 10/03/2018   Nitin More                                  #RQ-008055      Refactord test class by adding testSetup annotation
 * 04/04/2018   Nitin More                                  #RQ-008277      Corrected parameters passed to preparePricingMgmtRec method
 * 13/09/2019   manjunath.c.holekade@maersk.com             RQ-011903       Updated to improve the code coverage of BatchUpdateEmailAddressOnRequest class
 * 07/06/2022   Ronnie@SF                                   SPI-100         Removed brand hardcodings
 */

@isTest
private class BatchUpdateEmailAddressOnRequest_Test {
    
     @testSetup static void setupTestData(){
        TriggerExecutionController.skipAllTriggers(true);
       
        if (UserDataGeneratorHelper_Test.SystemAdminUser == null){
            UserDataGeneratorHelper_Test.initializeSystemAdminUser(); 
            
        }
        
         System.runAs(UserDataGeneratorHelper_Test.SystemAdminUser){
             RateSheetData_Test.assignGSCPermissionSet(UserDataGeneratorHelper_Test.SystemAdminUser.Id);
             RateSheetData_Test.assignPricingManagerPermissionSet(UserDataGeneratorHelper_Test.SCLSystemAdminUser.Id);
         }
         Map<String, String> GeoCountryList = new Map<String, String> ();
         GeoCountryList.put('Denmark', 'Country');
         GeoCountryList.put('China', 'Country');       
         List<Geography__c> geoList = DataGeneratorHelper1_Test.createGeography ( GeoCountryList );
         
         Account testClientAccount = AccountDataHelper_Test.createClientAccount();
         Contact testContact1 = ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MAERSKLINE,testClientAccount.Id,'testuser1@testuser.com',UserDataGeneratorHelper_Test.MSLSystemAdminUser );
         Contact testContact2 = ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MAERSKLINE,testClientAccount.Id,'testuser2@testuser.com',UserDataGeneratorHelper_Test.MSLSystemAdminUser );    
         List<Product2> prodList = DataGeneratorHelper1_Test.createProduct2WithEquipsAndCommodities( 1,'B','DE','Ocean');
         
         List<Pricing_Management__c> lstPricingMgmt = new List<Pricing_Management__c>();
         lstPricingMgmt.add(RateSheetData_Test.preparePricingMgmtRec(prodList[0].Id, 'Animal Fodder', '20DRY;20REEF', '1 Month', '1', true, '20DRY;20REEF', '1 Month', '1', true));
         lstPricingMgmt.add(RateSheetData_Test.preparePricingMgmtRec(prodList[0].Id, 'Scrap Metal', '20DRY;20REEF;40HREF', '1 Month', '1', true, '20DRY;20REEF;20DRY', '1 Month', '1', true));
         lstPricingMgmt.add(RateSheetData_Test.preparePricingMgmtRec(prodList[0].Id, 'FAK', '20DRY;20REEF', '1 Month', '1', true, '20DRY;20REEF', '1 Month', '1', true));
         lstPricingMgmt.add(RateSheetData_Test.preparePricingMgmtRec(prodList[0].Id, 'Beverages - Dry', '20DRY;20REEF', '1 Month', '1', true, '20DRY;20REEF', '1 Month', '1', true));
         lstPricingMgmt.add(RateSheetData_Test.preparePricingMgmtRec(prodList[0].Id, 'Cashew Nuts, Coconuts And Brazil Nuts', '20DRY;20REEF', '1 Month', '1', true, '20DRY;20REEF', '1 Month', '1', true));
         
         System.runAs(UserDataGeneratorHelper_Test.SCLSystemAdminUser){
             insert lstPricingMgmt;
         }
         List<Request__c> lstRequest = new List<Request__c>();
         lstRequest.add( RateSheetData_Test.createRequest(testClientAccount.id, BrandUtilities.MAERSKLINE, 'No', 'Merged LQB & CL', 'BCO', 'No', 'Customised', 'Both', 'New', lstPricingMgmt[0].Id, lstPricingMgmt[0].Commodity__c, lstPricingMgmt[0].Equipment_Types_BCO__c) );
         lstRequest.add( RateSheetData_Test.createRequest(testClientAccount.id, BrandUtilities.MAERSKLINE, 'No', 'Merged LQB & CL', 'FWD', 'No', 'Customised', 'Both', 'New', lstPricingMgmt[1].Id, lstPricingMgmt[1].Commodity__c, lstPricingMgmt[0].Equipment_Types_FWD__c) );
         lstRequest.add( RateSheetData_Test.createRequest(testClientAccount.id, BrandUtilities.MAERSKLINE, 'No', 'Merged LQB & CL', 'BCO', 'No', 'Customised', 'Both', 'New', lstPricingMgmt[2].Id, lstPricingMgmt[2].Commodity__c, lstPricingMgmt[0].Equipment_Types_BCO__c) );
         lstRequest.add( RateSheetData_Test.createRequest(testClientAccount.id, BrandUtilities.MAERSKLINE, 'No', 'Merged LQB & CL', 'FWD', 'No', 'Customised', 'Both', 'New', lstPricingMgmt[3].Id, lstPricingMgmt[3].Commodity__c, lstPricingMgmt[0].Equipment_Types_FWD__c) );
         lstRequest.add( RateSheetData_Test.createRequest(testClientAccount.id, BrandUtilities.MAERSKLINE, 'No', 'Merged LQB & CL', 'BCO', 'No', 'Customised', 'Both', 'New', lstPricingMgmt[4].Id, lstPricingMgmt[4].Commodity__c, lstPricingMgmt[0].Equipment_Types_BCO__c) );
         
         Integer intCount=0;
         for (Request__c r : lstRequest){
             if (intCount<=1) { 
                 r.Mail_Send_To__c = 'Customer';
                 r.Migrated_Emails__c = '1@testuser.com';
                 r.All_Email_Updated_by_Batch_Date__c = (intCount==0) ? null : System.Today();
             }
             if (intCount==2) {
                 r.Mail_Send_To__c = 'Sales';
                 r.All_Email_Updated_by_Batch_Date__c = System.Today();
             }
             if (intCount>=3) { 
                 r.Mail_Send_To__c = 'Both';
                 r.Migrated_Emails__c = '1@testuser.com';
                 r.All_Email_Updated_by_Batch_Date__c = (intCount==3) ? null : System.Today();
             }
             intCount++;
         }
         
         update lstRequest;
         
         List<Request_Information__c> lstReqInformation = new List<Request_Information__c>();
         for (Request__c req : lstRequest){
             
             if (req.Mail_Send_To__c == 'Sales' || req.Mail_Send_To__c == 'Both' ){
                 lstReqInformation.add(new Request_Information__c(Request__c = req.Id, User__c = UserDataGeneratorHelper_Test.SystemAdminUser.id, Contact__c = null));
             }
             
             if (req.Mail_Send_To__c == 'Customer' || req.Mail_Send_To__c == 'Both'){
                 lstReqInformation.add(new Request_Information__c(Request__c = req.Id, User__c = null, Contact__c = testContact1.Id));
                 lstReqInformation.add(new Request_Information__c(Request__c = req.Id, User__c = null, Contact__c = testContact2.Id));
             }
         }
         
         insert lstReqInformation;
         
         testContact1.Email = 'test.user@nodmain.com';
         update testContact1;
        
        TriggerExecutionController.skipAllTriggers(false);
        
     }
     
     static testMethod void test_BatchUpdateEmailAddressOnRequest(){
        
        Test.startTest();
            BatchUpdateEmailAddressOnRequest batchUpdEmailOnRequest = new BatchUpdateEmailAddressOnRequest();
            Database.executeBatch( batchUpdEmailOnRequest ); 
        Test.StopTest();
        
        Contact testContact = [SELECT Id, Email FROM Contact Limit 1];
        Request__c testRequest = [SELECT Id, All_Customer_Email_Addresses__c,All_Internal_Email_Addresses__c FROM Request__c WHERE Mail_Send_To__c = 'Customer' LIMIT 1];
        
        System.assertEquals(true, testRequest.All_Customer_Email_Addresses__c.contains(testContact.Email), 'Contact is not updated on Request');
    }
    
    static testMethod void test_ScheduleClass(){
        Test.startTest();
            ScheduleBatchUpdateEmailAddressOnRequest schClass = new ScheduleBatchUpdateEmailAddressOnRequest();
            string timeinterval = '0 0 1 * * ?';
            System.schedule( 'BatchUpdateEmailAddressOnRequest', timeinterval , schClass );
        Test.stopTest();
        
        System.assert(true);
    }
}