@isTest
public class lwcCMDContactCreateCtrlTest {  

    
    @isTest static void testAccessToken() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CMD_ServiceHttpCallOutMock());
        string accessToken = lwcCMDContactCreateCtrl.getAccessToken();
        Test.stopTest();
    }
    
    @isTest static void testvalidateContact() {
        lwcCMDContactCreateCtrl lll = new lwcCMDContactCreateCtrl();
        TriggerExecutionController.skipAllTriggers(true);
        Account clientAcc = AccountDataHelper_Test.createClientAccount();
        clientAcc.Customer_Code__c = 'VN00829521';
        update clientAcc;
        Contact CustContact = ContactDataGeneratorHelper_Test.createCustomerContact(clientAcc.Id, BrandUtilities.MAERSKLINE);
        TriggerExecutionController.skipAllTriggers(false);
          
        List<Map<String, String>> phonenumbers = new List<Map<String, String>>{
            new Map<String, String>{'TEL'=> '+91 7259158751', 'MOB'=>'+91 7259158751'}
        };
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CMD_ServiceHttpCallOutMock());
        string accessToken = lwcCMDContactCreateCtrl.getAccessToken();
        HttpResponse contCreate = lwcCMDContactCreateCtrl.runValidateAPI(JSON.serialize(CustContact), 'VN00829521');
        Test.stopTest();
    }
    
    @isTest static void testDuplicateContact() {
        lwcCMDContactCreateCtrl lll = new lwcCMDContactCreateCtrl();
        lwcCMDContactCreateCtrl.oldcontactTypes = 'PORTAL;FINANCE';
        List<Map<String, String>> phonenumbers = new List<Map<String, String>>{
            new Map<String, String>{'TEL'=> '+91 7259158751', 'MOB'=>'+91 7259158751'}
        };
        TriggerExecutionController.skipAllTriggers(true);
        Account clientAcc = AccountDataHelper_Test.createClientAccount();
        clientAcc.Customer_Code__c = 'VN00829521';
        update clientAcc;
        Contact CustContact = ContactDataGeneratorHelper_Test.createCustomerContact(clientAcc.Id, BrandUtilities.MAERSKLINE);
        CustContact.Phone = '+91 7548765490';
        TriggerExecutionController.skipAllTriggers(false);
        Test.startTest();
        lwcCMDContactCreateCtrl.createValidateWrapper(CustContact, clientAcc.Customer_Code__c , phonenumbers);
		lwcCMDContactCreateCtrl.createContactTypes('EDI_TECHNICAL');
        Test.setMock(HttpCalloutMock.class, new CMD_ServiceHttpCallOutMock());
        string accessToken = lwcCMDContactCreateCtrl.getAccessToken();
        String contCreate = lwcCMDContactCreateCtrl.runDuplicateCheckAPI(CustContact);
        lwcCMDContactCreateCtrl.validateAndSaveContact(CustContact, phonenumbers, 'new');
        Test.stopTest();
    }
    
     @isTest static void testReassignmentContact() {
         TriggerExecutionController.skipAllTriggers(true);
         Account clientAcc = AccountDataHelper_Test.createClientAccount();
         clientAcc.Customer_Code__c = 'VN00829521';
         update clientAcc;
         Contact CustContact = ContactDataGeneratorHelper_Test.createCustomerContact(clientAcc.Id, BrandUtilities.MAERSKLINE);
         CustContact.Phone = '+91 7548765490';
         TriggerExecutionController.skipAllTriggers(false);   
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new CMD_ServiceHttpCallOutMock());    
      lwcCMDContactCreateCtrl.runContactAssignmentAPI(clientAcc.Id, 'IN00527582', CustContact);
         lwcCMDContactCreateCtrl.preventcontactstoConcern(clientAcc.Id);
         Test.stopTest();
     }
    
    
     @isTest static void testCreateContact() {
       lwcCMDContactCreateCtrl.DuplicateContacts kkk = new lwcCMDContactCreateCtrl.DuplicateContacts();
         kkk.customerCode = '11111111';
         kkk.firstName = 'test';
         kkk.lastName = 'test';
         kkk.role = 'Dev';
         kkk.primaryEmailId = 'test@gmail.com';
         kkk.statusCode = 'Active';
         kkk.isMasterContact = true;
       lwcCMDContactCreateCtrl.oldcontactTypes = 'PORTAL;FINANCE';
        List<Map<String, String>> phonenumbers = new List<Map<String, String>>{
            new Map<String, String>{'TEL'=> '+91 7259158751', 'MOB'=>'+91 7259158751'}
        };
        TriggerExecutionController.skipAllTriggers(true);
        Account clientAcc = AccountDataHelper_Test.createClientAccount();
        clientAcc.Customer_Code__c = 'VN00829521';
        update clientAcc;
        Contact CustContact = ContactDataGeneratorHelper_Test.createCustomerContact(clientAcc.Id, BrandUtilities.MAERSKLINE);
        CustContact.Phone = '+91 7548765490';
        TriggerExecutionController.skipAllTriggers(false);
        Test.setMock(HttpCalloutMock.class, new CMD_ServiceHttpCallOutMock()); 
        system.debug('@@@@ ' + CustContact);
        lwcCMDContactCreateCtrl.createContactWrapperData(CustContact,'VN00829521', phonenumbers, 'POST');
        lwcCMDContactCreateCtrl.updateContact(CustContact, phonenumbers, clientAcc.Id, false, lwcCMDContactCreateCtrl.oldcontactTypes);
     }
}