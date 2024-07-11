/*
Date			Story			Developer	Description
24-May-2023		SFSE-10894		Aditi		Code created; Test class for OneClickSendOfferCntrl
*/

@isTest
public class OneClickSendOfferCtrlTest {

    private class One_Click_Error_Code_Mock {
        public String DeveloperName { get; public set; }
        public String MasterLabel { get; public set; }
        public String ErrorCode { get; public set; }
        public String ErrorMessage { get; public set; }

        public One_Click_Error_Code_Mock(String developerName, String masterLabel, String errorCode, String errorMessage) {
            DeveloperName = developerName;
            MasterLabel = masterLabel;
            ErrorCode = errorCode;
            ErrorMessage = errorMessage;
        }
    }
    
    @testSetup static void setup() {
        // Create test data
        Account ClientAccount = TestBusinessHelper.createAccount('Client_Account', true);
        
        Opportunity opp = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
    
        update opp;
    }
    
    @isTest
    static void testFetchErrorCodes() {
        
       	Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        // Create metadata records
        One_Click_Error_Code_Mock mdtRecord1 = new One_Click_Error_Code_Mock('Error1', 'Error1', 'Error1', 'Error Message 1');
        One_Click_Error_Code_Mock mdtRecord2 = new One_Click_Error_Code_Mock('Error2', 'Error2', 'Error2', 'Error Message 2');
        
        // Call the method to test
        Test.startTest();
        List<OneClickSendOfferCtrl.validationError> result = simulateFetchErrorCodes(opp.Id, new One_Click_Error_Code_Mock[]{mdtRecord1, mdtRecord2});
        Test.stopTest();
    }
    
    @isTest
    static void testRetrieveMetadata() {
        // Create metadata records
        One_Click_Error_Code_Mock mdtRecord1 = new One_Click_Error_Code_Mock('Error1', 'Error1', 'Error1', 'Error Message 1');
        One_Click_Error_Code_Mock mdtRecord2 = new One_Click_Error_Code_Mock('Error2', 'Error2', 'Error2', 'Error Message 2');
        
        // Call the method to test
        Test.startTest();
        Map<String, String> result = simulateRetrieveMetadata(new One_Click_Error_Code_Mock[]{mdtRecord1, mdtRecord2});
        Test.stopTest();
        
    }
    
    // Simulates the fetchErrorCodes method by accepting the mocked metadata records
    private static List<OneClickSendOfferCtrl.validationError> simulateFetchErrorCodes(Id oppId, List<One_Click_Error_Code_Mock> mockRecords) {
        // Store the original metadata map and replace it with the mock records
        Map<String, String> originalMetadata = OneClickSendOfferCtrl.oneClickErrorCode_mtdt;
        OneClickSendOfferCtrl.oneClickErrorCode_mtdt = new Map<String, String>();
        
        // Populate the mock metadata map with the provided mock records
        for (One_Click_Error_Code_Mock mockRecord : mockRecords) {
            OneClickSendOfferCtrl.oneClickErrorCode_mtdt.put(mockRecord.ErrorCode, mockRecord.ErrorMessage);
        }
        
        // Call the actual method
        List<OneClickSendOfferCtrl.validationError> result = OneClickSendOfferCtrl.fetchErrorCodes(oppId);
        
        // Restore the original metadata map
        OneClickSendOfferCtrl.oneClickErrorCode_mtdt = originalMetadata;
        
        return result;
    }
    
    // Simulates the retrieveMetadata method by accepting the mocked metadata records
    private static Map<String, String> simulateRetrieveMetadata(List<One_Click_Error_Code_Mock> mockRecords) {
        // Store the original metadata map and replace it with the mock records
        Map<String, String> originalMetadata = OneClickSendOfferCtrl.oneClickErrorCode_mtdt;
        OneClickSendOfferCtrl.oneClickErrorCode_mtdt = new Map<String, String>();
        
        // Populate the mock metadata map with the provided mock records
        for (One_Click_Error_Code_Mock mockRecord : mockRecords) {
            OneClickSendOfferCtrl.oneClickErrorCode_mtdt.put(mockRecord.ErrorCode, mockRecord.ErrorMessage);
        }
        
        // Call the actual method
        Map<String, String> result = OneClickSendOfferCtrl.retrieveMetadata();
        
        // Restore the original metadata map
        OneClickSendOfferCtrl.oneClickErrorCode_mtdt = originalMetadata;
        
        return result;
    }
}