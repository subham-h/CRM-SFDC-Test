/*              
 * Revision 	Ref Number	Date			Owner					Description
 * -------- 	----------	-----------		-----------------		-----------
 * 1.0      	SFSE-11495	04/10/2023		Kiran@maersk			test class for ApiCalloutCMDQueueable
 * 
*/
@isTest
public class ApiCalloutCMDQueueableTest {
    
    
   static testmethod void Setup()  {
        Test.startTest();
        TriggerExecutionController.skipAllTriggers(true);
        //User
        TestBusinessHelper.createUser('Integration User', BrandUtilities.MAERSKLINE + ';' + BrandUtilities.MAERSKLS, true);
        //Accounts
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', false);
        clientAccount.Id = null;
        clientAccount.Customer_Group__c = '';
        clientAccount.Customer_Code__c = 'VN00829521';
        insert new List<Account>{clientAccount};
   
        TriggerExecutionController.skipAllTriggers(false);
        
        Test.stopTest();
    }
    
    @isTest
    private static void testApiCMDQueableCalluout(){
                TriggerExecutionController.skipAllTriggers(true);
        //User
        TestBusinessHelper.createUser('Integration User', BrandUtilities.MAERSKLINE + ';' + BrandUtilities.MAERSKLS, true);
        //Accounts
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', false);
        clientAccount.Id = null;
        clientAccount.Customer_Group__c = '';
        clientAccount.Customer_Code__c = 'VN00829521';
        insert new List<Account>{clientAccount};
   
        TriggerExecutionController.skipAllTriggers(false);
        Account clientAcc = [SELECT Id, Customer_Group__c, Customer_Code__c, Name, Country__c  FROM Account WHERE RecordType.DeveloperName = 'Client_Account' LIMIT 1];
        Contact customerContactMaersk = TestBusinessHelper.createContact(clientAcc, 'Customer_Contact', BrandUtilities.MAERSKLINE, false);
        customerContactMaersk.Id = null;
        customerContactMaersk.Email = 'CustomerContact@test.com';
        customerContactMaersk.LastName = 'CustomerContactMaersk';
        customerContactMaersk.Phone = '+44 123456';
        customerContactMaersk.MobilePhone = '+44 123456';
        customerContactMaersk.OtherPhone = '+44 123456';
        customerContactMaersk.Fax = '+44 123456';
        insert customerContactMaersk;
        
        List<Sync_Contact_CMD_Event__e > events = new List<Sync_Contact_CMD_Event__e >();
        Sync_Contact_CMD_Event__e event;
        Map<Id,Contact> mapofIdtoContact = new Map<Id,Contact>();
        Contact jsondt;
        String jsonString;
        event = new Sync_Contact_CMD_Event__e(JSON_Payload__c = JSON.serialize(customerContactMaersk));
        jsonString = event.JSON_Payload__c;
        jsondt = (Contact)JSON.deserialize(jsonString, Contact.class);
        mapofIdtoContact.put(jsondt.Id, jsondt);
        
        System.debug('@@mapofIdtoContact '+mapofIdtoContact);
        
        If( !mapofIdtoContact.isEmpty() ) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CMD_ServiceHttpCallOutMock());
            //string accessToken = lwcCMDContactCreateCtrl.getAccessToken();
            //HttpResponse contCreate = lwcCMDContactCreateCtrl.runValidateAPI(JSON.serialize(customerContactMaersk), 'VN00829521');
            System.enqueueJob(new ApiCalloutCMDQueueable (mapofIdtoContact));
            Test.stopTest();
        }
        
    }
    
    @isTest
    private static void testApiCMDQueableCalluout2(){
                TriggerExecutionController.skipAllTriggers(true);
        //User
        TestBusinessHelper.createUser('Integration User', BrandUtilities.MAERSKLINE + ';' + BrandUtilities.MAERSKLS, true);
        //Accounts
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', false);
        clientAccount.Id = null;
        clientAccount.Customer_Group__c = '';
        clientAccount.Customer_Code__c = 'VN00829521';
        insert new List<Account>{clientAccount};
   
        TriggerExecutionController.skipAllTriggers(false);
        Account clientAcc = [SELECT Id, Customer_Group__c, Customer_Code__c, Name, Country__c  FROM Account WHERE RecordType.DeveloperName = 'Client_Account' LIMIT 1];
        //clientAccount.Customer_Code__c = 'IN00527582';
        //update clientAccount;
        Contact customerContactMaersk = TestBusinessHelper.createContact(clientAcc, 'Customer_Contact', BrandUtilities.MAERSKLINE, false);
        customerContactMaersk.Email = 'CustomerContactML@test.com';
        customerContactMaersk.Id = null;
        customerContactMaersk.FirstName = 'FirstName';
        customerContactMaersk.LastName = 'CustomerContact';
        customerContactMaersk.Phone = '+44 123456';
        customerContactMaersk.MobilePhone = '+44 123456';
        customerContactMaersk.OtherPhone = '+44 123456';
        customerContactMaersk.Fax = '+44 123456';
        insert customerContactMaersk;
        
        List<Sync_Contact_CMD_Event__e > events = new List<Sync_Contact_CMD_Event__e >();
        Sync_Contact_CMD_Event__e event;
        Map<Id,Contact> mapofIdtoContact = new Map<Id,Contact>();
        Contact jsondt;
        String jsonString;
        event = new Sync_Contact_CMD_Event__e(JSON_Payload__c = JSON.serialize(customerContactMaersk));
        jsonString = event.JSON_Payload__c;
        jsondt = (Contact)JSON.deserialize(jsonString, Contact.class);
        mapofIdtoContact.put(jsondt.Id, jsondt);
        
        System.debug('@@mapofIdtoContact '+mapofIdtoContact);
        
        If( !mapofIdtoContact.isEmpty() ) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CMD_ServiceHttpCallOutMock());
            System.enqueueJob(new ApiCalloutCMDQueueable (mapofIdtoContact));
            Test.stopTest();
        }
        
    }

    
    // Mock implementation for ConnectApi callouts
    private class MockConnectApi implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock HTTP response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id": "mocked_response_id"}');
            res.setStatusCode(200);
            return res;
        }
    } 
    @IsTest(SeeAllData=true)
    static void testCreateChatterFeed() {
        // Retrieve the test Contact record
         Account clientAccount = [SELECT Id, Customer_Group__c, Customer_Code__c, Name, Country__c  FROM Account WHERE RecordType.DeveloperName = 'Client_Account' LIMIT 1];
        Contact customerContact = TestBusinessHelper.createContact(clientAccount, 'Customer_Contact', BrandUtilities.MAERSKLINE, false);
        customerContact.Id = null;
        customerContact.Email = 'CustomerContact@test.com';
        customerContact.LastName = 'Customer-(Contact)';
        customerContact.Phone = '+91 7676590548';
        customerContact.MobilePhone = '+91 7654897065';
        customerContact.OtherPhone = '+91 7865489763';
        customerContact.Fax = '+91 7684389076';
        insert customerContact;

        // Create test data
        String errorMessage = 'Test Error Message';
        String messageBodyInput = '[{"field": "Test Field", "message": "Test Message"}]';
        
        // Set up mock for ConnectApi
        Test.setMock(HttpCalloutMock.class, new MockConnectApi());
        // Call the method
        Test.startTest();
        ApiCalloutCMDQueueable.createChatterFeed(messageBodyInput, customerContact.Id, customerContact.OwnerId,false);
        Test.stopTest();


    }
    
}