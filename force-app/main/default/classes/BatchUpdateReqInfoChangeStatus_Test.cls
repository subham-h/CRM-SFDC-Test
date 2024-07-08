/**
 * Version       Date              Owner             Ref Number      Description
 *******************************************************************************************************
 * v1.0          28/04/2018        Nitin                             Code created
 * v2.0          12/02/2019        Junaid            #RQ-010053      Removed Request_Route__c(deprecated) related code
 * v3.0          15/10/2020        Meghana           SFSE-4767       Deprecate Safmarine brand, replace reference to other brand
 * v4.0          07/06/2022        Ronnie@SF         SPI-100         Removed brand hardcodings
 */
@isTest
private class BatchUpdateReqInfoChangeStatus_Test {

    @testSetup static void setup() {
        
        if (UserDataGeneratorHelper_Test.SystemAdminUser == null) {
            UserDataGeneratorHelper_Test.initializeSystemAdminUser(); 
        }
        
        System.runAs(UserDataGeneratorHelper_Test.SystemAdminUser) {
            RateSheetData_Test.assignGSCPermissionSet(UserDataGeneratorHelper_Test.SystemAdminUser.Id);
            RateSheetData_Test.assignPricingManagerPermissionSet(UserDataGeneratorHelper_Test.SCLSystemAdminUser.Id);
        }
        
        User mslSystemAdmin = UserDataGeneratorHelper_Test.MSLSystemAdminUser;
        Map<String, String> GeoCountryList = new Map<String, String> ();
        GeoCountryList.put('Denmark', 'Country');
        GeoCountryList.put('China', 'Country');       
        List<Geography__c> geoList = DataGeneratorHelper1_Test.createGeography ( GeoCountryList );
        
        Account testClientAccount = AccountDataHelper_Test.createClientAccount();
        Contact testContact1 = ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MAERSKLINE, testClientAccount.Id, 'testuser1@testuser.com', mslSystemAdmin);
        List<Product2> prodList = DataGeneratorHelper1_Test.createProduct2WithEquipsAndCommodities( 1, 'B', 'DE', 'Ocean');
        
        Pricing_Management__c pmRec = RateSheetData_Test.preparePricingMgmtRec(prodList[0].Id, 'FAK', '20DRY;20REEF', '1 Month', '1', true, '20DRY;20REEF', '1 Month', '1', true);
        System.runAs(UserDataGeneratorHelper_Test.SCLSystemAdminUser) {
            insert pmRec;
        }
        
        Request__c req1 = RateSheetData_Test.createRequest(testClientAccount.id, BrandUtilities.MAERSKLINE, 'No', 'Merged LQB & CL', System.Label.FWD , 'No', 'Customised', 'Both', 'New', pmRec.Id, pmRec.Commodity__c, '20DRY;40DRY' );
        Request__c req2 = RateSheetData_Test.createRequest(testClientAccount.id, BrandUtilities.SEAGO, 'No', 'Merged LQB & CL', System.Label.BCO, 'No', 'Customised', 'Both', 'New', pmRec.Id, pmRec.Commodity__c, '20DRY;' );
        
        req1.Legacy_Request_Number__c = null;
        req1.Migrated_From_Request_Route_Id__c = 'something1';
        update req1;

        req2.Legacy_Request_Number__c = req1.Id;
        req2.Migrated_From_Request_Route_Id__c = 'something2';
        update req2;
        
        List<Request_Information__c> lstReqInfo = new List<Request_Information__c>();
        lstReqInfo.add(new Request_Information__c(Request__c=req1.Id, User__c=mslSystemAdmin.Id, Change_Status__c='Remove'));
        lstReqInfo.add(new Request_Information__c(Request__c=req1.Id, Contact__c=testContact1.Id, Change_Status__c='Remove'));
        lstReqInfo.add(new Request_Information__c(Request__c=req2.Id, User__c=mslSystemAdmin.Id, Change_Status__c='New'));
        lstReqInfo.add(new Request_Information__c(Request__c=req2.Id, Contact__c=testContact1.Id, Change_Status__c='New'));
        insert lstReqInfo;
    }
    
    @isTest static void testBatchChagneStatusUpdate() {
        
        Test.startTest();
        BatchUpdateReqInfoChangeStatus batchTest = new BatchUpdateReqInfoChangeStatus();
        Database.executeBatch( batchTest); 
        Test.stopTest();
        
        List<Request_Information__c> lstReqInfo = [SELECT Id, RecordTypeId FROM Request_Information__c WHERE Change_Status__c in ('Remove')];
        System.assertEquals(4, lstReqInfo.size(), 'Request Information Contact Change Status is not updated');
    }
}