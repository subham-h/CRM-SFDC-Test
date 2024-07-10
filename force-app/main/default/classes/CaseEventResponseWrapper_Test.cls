/*              
* Revision Date        Owner                    Description
* -------- ----------  -----------              ------------
* 1.0     08-May-2024  Richa@maersk.com     Test Class for CaseEventResponseWrapper.cls and SerializeCustomEventDataToJSON.cls
*/
@isTest
public class CaseEventResponseWrapper_Test {
    @testSetup static void setup() {
        TriggerExecutionController.skipAllTriggers(true);
        Geography__c geography = TestBusinessHelper.createGeography('Denmark', 'Country', null, true);
        Account acc = TestBusinessHelper.createAccount('Unassigned', false);
        acc.Id = null;
        acc.Name = 'Test Account';
        acc.Country__c = geography.Id;
        insert acc;
        Contact con = TestBusinessHelper.createContact(acc, 'Internal_Contact', BrandUtilities.MAERSKLINE, false);
        con.Id = null;
        con.Country__c = acc.Country__c;
        insert con;   
        TriggerExecutionController.skipAllTriggers(false);
    }
         
   @isTest 
    static void testCaseEventWrapper(){ 
        Test.startTest();
        Contact conInstance = [Select Id, Country__c From Contact LIMIT 1];
        Account acc = [Select Id, Country__c From Account LIMIT 1];
		
        Case dispCase = TestBusinessHelper.createCase(acc, conInstance, 'Dispute',false);
       	dispCase.id=null;
        dispCase.Disputed_Invoice_Number__c = '1234467891';        
        insert dispCase;
        
        dispCase.OwnerId = UserInfo.getUserId();
        dispCase.Status = 'Closed - Resolved';
        dispCase.Type = 'Charges, Invoice & Payment';
        dispCase.Sub_Type__c = 'Dispute';
        dispCase.Reason_For_Case__c = 'Case Reason Updated in OHP';
        update dispCase;
         List<Custom_Event__c> lstCusEvt = [Select Id, Name,Status__c,Topic__c,Event_Type__c,Publishing_Record_Id__c,Publisher_LastModifiedDate__c,Retry_Attempted__c,Notification_Name__c,Transaction_Type__c,Direction__c,Key__c,JSON_1__c,JSON_2__c,JSON_3__c,JSON_4__c,JSON_5__c,JSON_6__c from Custom_Event__c];
        Assert.areEqual(1,lstCusEvt.size());
        SerializeCustomEventDataToJSON.Requests firstInput = new SerializeCustomEventDataToJSON.Requests();
        firstInput.inputSObject = lstCusEvt[0];
        firstInput.inputSObjectName = 'Custom_Event__c';
        SerializeCustomEventDataToJSON.serialize(new List<SerializeCustomEventDataToJSON.Requests>{firstInput});
        Test.stopTest();
    }
    
       @isTest 
    static void testCaseEventPublishRetry(){ 
        Test.startTest();
        Contact conInstance = [Select Id, Country__c From Contact LIMIT 1];
        Account acc = [Select Id, Country__c From Account LIMIT 1];
        Case dispCase = TestBusinessHelper.createCase(acc, conInstance, 'Dispute',false);
       	dispCase.id=null;
        dispCase.Disputed_Invoice_Number__c = '1234467891';        
        insert dispCase;
        
        dispCase.OwnerId = UserInfo.getUserId();
        dispCase.Status = 'Closed - Resolved';
        dispCase.Type = 'Charges, Invoice & Payment';
        dispCase.Sub_Type__c = 'Dispute';
        dispCase.Reason_For_Case__c = 'Case Reason Updated in OHP';
        update dispCase;
        List<Custom_Event__c> lstCusEvt = [Select Id, Name,Status__c,Topic__c,Event_Type__c,Publishing_Record_Id__c,Publisher_LastModifiedDate__c,Retry_Attempted__c,Notification_Name__c,Transaction_Type__c,Direction__c,Key__c,JSON_1__c,JSON_2__c,JSON_3__c,JSON_4__c,JSON_5__c,JSON_6__c from Custom_Event__c];
        Assert.areEqual(1,lstCusEvt.size());        
        CustomEventUtility.retryRequests firstInput = new CustomEventUtility.retryRequests();
        firstInput.retryEventId = lstCusEvt[0].Id;
        firstInput.retryRecordKey = lstCusEvt[0].Key__c;
        CustomEventUtility.retryPublish(new List<CustomEventUtility.retryRequests>{firstInput});
        lstCusEvt[0].Status__c = 'Failed';
        update lstCusEvt[0];
        CustomEventUtility.retryPublish(new List<CustomEventUtility.retryRequests>{firstInput});
        Test.stopTest();
    }

}