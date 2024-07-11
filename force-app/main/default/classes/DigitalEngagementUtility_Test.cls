@isTest
public class DigitalEngagementUtility_Test {

    @isTest
    static void testSendSFMCDigitalEngRequest() {
        // Test data setup
        String contactId = '0032o00002T7PaRAAV';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DigitalEngagementUtilityMock());
        String response = DigitalEngagementUtility.sendSFMCDigitalEngRequest(contactId);
        Test.stopTest();

        // Verify results
        System.assertNotEquals(null, response);
    }
}