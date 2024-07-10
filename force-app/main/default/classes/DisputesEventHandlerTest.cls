/**
* Author   : Vivek.agrawal@maersk
* Purpose  : Test Class for Dispute Event Handler and Dispute Trigger
 *
* Revision Ref Number  Date         Owner                   Description
* -------- ----------  -----------  -------------------     -----------
 * 1.0      SS-4473     05-March-2022 Vivek.agrawal@Maersk    Test Class DisputeEventHandlerTest created to test the creation of disputes cases from platform event
 * 2.0      SPI-100     13-06-2022    Ronnie@SF               Removed brand hardcoding
*/


@isTest 
public class DisputesEventHandlerTest {

    public static testmethod void testDisputeCasesInsert() {

        Disputes_Event__e thisEvent = new Disputes_Event__e(Json_1__c = '{"ohpDispute_id":"0932","statuscode" : "10","createdSource" : "OHP","alternateMailId":"","statusCode":"10","statusDescription":"Re","companyCode":"1000","contactPerson":"kamala kannan","contactEmail":"hunt1@gmail.com","invoiceNumber":"4813052074","eventType":"Insert"}');

        Test.startTest();
                
        // Publish test event
        Database.SaveResult sr = EventBus.publish(thisEvent);
            
        Test.stopTest();
    }

    public static testmethod void testDisputeCasesUpdate() {

        TriggerExecutionController.skipAllTriggers(true);
        
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account accInstance =AccountData_Test.lstAccounts[0];
        //ContactData_Test.populateCommonContactFields();
         Id customerRTId = StaticFactory.getRecordTypeIdByName('Contact', 'Customer Contact');
         Contact conInstance = new Contact();
           conInstance.AccountId = accInstance.Id;
            conInstance.LastName = 'Test Contact Dispute'; 
            conInstance.RecordTypeId = customerRTId;
            conInstance.Email = DateTime.now().millisecond() + 'TestContact' + Math.random() + '@test.com';
            conInstance.Phone = '+44 123412' ;
            conInstance.FirstName = 'Test' + Math.random() + DateTime.now().millisecond();
        conInstance.Liner_Brands__c = BrandUtilities.MAERSK;
            conInstance.Country__c = accInstance.Country__c;
            conInstance.Contact_Status__c = 'Active';
       
        insert conInstance;
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 3;
        CaseData_Test.conInstance = conInstance;
        
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createDisputecases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        TriggerExecutionController.skipAllTriggers(false);
        insert lstCases; 
        system.debug('--lstCases'+lstCases[1].status);

        Test.startTest();

        List<Case> childList = [select Id, Disputed_Invoice_Number__c, ParentId from Case where Id in(:lstCases[1].Id)];
       
        String invoiceNumber = childList[0].Disputed_Invoice_Number__c;
        system.debug('--invoice Number'+invoiceNumber);

        Disputes_Event__e thisEvent2 = new Disputes_Event__e(Json_1__c = '{"ohpDispute_id":"0932","statusCode":"20","alternateMailId":"","statusDescription":"Re","companyCode":"1000","contactPerson":"kamala kannan","contactEmail":"hunt1@gmail.com","invoiceNumber":"'+invoiceNumber+'","eventType":"Update", "noteDescription":"test","changedTs":"2022-05-25T15:12:17Z"}');
        Disputes_Event__e thisEvent3 = new Disputes_Event__e(Json_1__c = '{"ohpDispute_id":"0933","statusCode":"63","alternateMailId":"","statusDescription":"Re","companyCode":"1000","contactPerson":"kamala kannan","contactEmail":"hunt1@gmail.com","invoiceNumber":"'+invoiceNumber+'","eventType":"Update", "noteDescription":"test","changedTs":"2022-05-25T15:14:17Z"}');
        Disputes_Event__e thisEvent4 = new Disputes_Event__e(Json_1__c = '{"ohpDispute_id":"0934","statusCode":"75","alternateMailId":"","statusDescription":"Re","companyCode":"1000","contactPerson":"kamala kannan","contactEmail":"hunt1@gmail.com","invoiceNumber":"'+invoiceNumber+'","eventType":"Update", "noteDescription":"test","changedTs":"2022-05-25T15:13:17Z"}');
        
        // Publish test event
        Database.SaveResult sr2 = EventBus.publish(thisEvent2);
        Database.SaveResult sr3 = EventBus.publish(thisEvent3);
        Database.SaveResult sr4 = EventBus.publish(thisEvent4);

        Test.stopTest();
    }
    
    public static testmethod void testDisputeCasesUpdate2() {

        TriggerExecutionController.skipAllTriggers(true);
        
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account accInstance =AccountData_Test.lstAccounts[0];
        //ContactData_Test.populateCommonContactFields();
         Id customerRTId = StaticFactory.getRecordTypeIdByName('Contact', 'Customer Contact');
         Contact conInstance = new Contact();
           conInstance.AccountId = accInstance.Id;
            conInstance.LastName = 'Test Contact Dispute'; 
            conInstance.RecordTypeId = customerRTId;
            conInstance.Email = DateTime.now().millisecond() + 'TestContact' + Math.random() + '@test.com';
            conInstance.Phone = '+44 123412' ;
            conInstance.FirstName = 'Test' + Math.random() + DateTime.now().millisecond();
        conInstance.Liner_Brands__c = BrandUtilities.MAERSK;
            conInstance.Country__c = accInstance.Country__c;
            conInstance.Contact_Status__c = 'Active';
       
        insert conInstance;
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 3;
        CaseData_Test.conInstance = conInstance;
        
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createDisputecases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        TriggerExecutionController.skipAllTriggers(false);
        insert lstCases; 
        system.debug('--lstCases'+lstCases[1].status);
        CaseComment ccom =  new CaseComment(commentBody = 'Test 1', parentId = lstCases[1].Id);
        insert ccom;

        Test.startTest();

        List<Case> childList = [select Id, Disputed_Invoice_Number__c, ParentId from Case where Id in(:lstCases[1].Id)];
       
        String invoiceNumber = childList[0].Disputed_Invoice_Number__c;
        system.debug('--invoice Number'+invoiceNumber);

        Disputes_Event__e thisEvent3 = new Disputes_Event__e(Json_1__c = '{"ohpDispute_id":"0933","statusCode":"63","alternateMailId":"","statusDescription":"Re","companyCode":"1000","contactPerson":"kamala kannan","contactEmail":"hunt1@gmail.com","invoiceNumber":"'+invoiceNumber+'","eventType":"Update", "noteDescription":"test","changedTs":"2022-05-25T15:14:17Z"}');
        Disputes_Event__e thisEvent4 = new Disputes_Event__e(Json_1__c = '{"ohpDispute_id":"0934","statusCode":"75","alternateMailId":"","statusDescription":"Re","companyCode":"1000","contactPerson":"kamala kannan","contactEmail":"hunt1@gmail.com","invoiceNumber":"'+invoiceNumber+'","eventType":"Update", "noteDescription":"test","changedTs":"2022-05-25T15:13:17Z"}');
        
        // Publish test event
        Database.SaveResult sr3 = EventBus.publish(thisEvent3);
        Database.SaveResult sr4 = EventBus.publish(thisEvent4);

        Test.stopTest();
    }
 
    @isTest
     static void testgetUserOwner(){
      
         Map<String, String> processorMap = new Map<String, String>{'CCP008' => '2345678101'};
         Test.startTest();
          DisputesEventHandler.getUserOwner(processorMap);
         Test.stopTest();
     }



}