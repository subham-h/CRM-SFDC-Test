@isTest
public class lwcCMDNSPContactCreateCtrlTest {

    @isTest
    static void testCreateNSPContact() {
        
        TriggerExecutionController.skipAllTriggers(true);
        
        Account nspAcc = AccountDataHelper_Test.createNonShippingPartyAccount();
        Geography__c geography = TestBusinessHelper.createGeography('Denmark', 'Country', null, true);
        
        // Test data
        String jsonString = '{"sobjectType":"Contact","LastName":"NSPCont","FirstName":"Test","Contact_Status__c":"Active","AccountId":"'+nspAcc.Id+'","Liner_Brands__c":"Maersk Line","Country__c":"'+geography.Id+'","Email":"NSPTestContact1@testingcontact3.com","Salutation":"Mr.","SCM_on_behalf_of__c":null,"Deduped_Contact__c":false,"First_Name_English__c":null,"Deduped_Date__c":null,"Last_Name_English__c":null,"Phone":null,"Extension_Number__c":null,"Duplicate_Email__c":null,"MobilePhone":null,"Preferred_Language__c":"English","OtherPhone":null,"Fax":null,"Title":null,"Team_Contact__c":"No"}';
        
        // Call the method
        String result;
        System.runAs(UserDataGeneratorHelper_Test.integrationUser){
             result = lwcCMDNSPContactCreateCtrl.createNSPContact(jsonString);
        }

        // Verify the result
        lwcCMDNSPContactCreateCtrl.responsewrap response = (lwcCMDNSPContactCreateCtrl.responsewrap)JSON.deserialize(result, lwcCMDNSPContactCreateCtrl.responsewrap.class);
        System.assertEquals('success', response.status, 'Status should be success');
        System.assertEquals('Contact successfully created', response.description, 'Description should be Contact successfully created');
        System.assertNotEquals(null, response.contid, 'Contact ID should not be null');
    }

    @isTest
    static void testCreateNSPContactWithInvalidData() {
        // Test data with missing required fields
        String jsonString = '{"FirstName": "John", "Email": "john.doe@example.com"}';

        // Call the method
        String result = lwcCMDNSPContactCreateCtrl.createNSPContact(jsonString);

        // Verify the result
        lwcCMDNSPContactCreateCtrl.responsewrap response = (lwcCMDNSPContactCreateCtrl.responsewrap)JSON.deserialize(result, lwcCMDNSPContactCreateCtrl.responsewrap.class);
        System.assertEquals('error', response.status, 'Status should be error');
        System.assertNotEquals(null, response.description, 'Error description should not be null');
    }
}