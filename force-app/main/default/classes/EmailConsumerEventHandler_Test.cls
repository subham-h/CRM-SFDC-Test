/** Author   : Ranjan 
* Purpose  : Utility test class for Artemis Consumer Handler functionalities 
*
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* @description Utility test class for Artemis Consumer Handler functionalities 
*/

@isTest
public class EmailConsumerEventHandler_Test {
    
    @isTest
    public static void testEmailConsumerEventsFromArtemisToSF(){
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
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 224069341';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        insert cs;
        TriggerExecutionController.skipAllTriggers(false);
        
        Case newCs = [Select Id, CaseNumber From Case Where Id =: cs.Id];
        Test.startTest();
        Email_Consumer_Event__e evt = new Email_Consumer_Event__e();
        evt.Json_1__c= '{\"table_name\":\"email_message\",\"record_id\":3896,\"operation\":\"UPDATE\",\"message\":{\"subject\":\"Testing email\",\"incoming\":false,\"from_name\":\"Aditya Singh\",\"tenant_id\":\"All Users\",\"cc_address\":\"\",\"to_address\":\"aditya.singh.2@maersk.com\",\"bcc_address\":null,\"from_address\":\"autoreply@maersk.com\",\"message_date\":\"2023-12-20T10:23:32.838+00:00\",\"creation_date\":\"2023-12-20T10:23:32.838+00:00\",\"has_attachment\":false,\"email_status_id\":\"0\",\"email_message_id\":3896,\"parent_case_artemis_id\":1588,\"email_message_identifier\":null,\"email_message_external_id\":\"01HJ3C0BYWKSGF63DRYQQV1PPN\",\"sf_parent_case_id\":\"'+newCs.Id+'\",\"sf_parent_case_number\":\"'+newCs.CaseNumber+'\"},\"topic\":\"msk.aretmis.email.topic.confidential.dedicated.v1\",\"eventNotificationName\":\"com.email.artemis.insert\"}';
        EventBus.publish(evt);
        Test.stopTest();
        
        List<Emailmessage> emList = new List<Emailmessage>([Select Id From EmailMessage Where ParentId =: cs.Id]);
        Assert.isTrue(!emList.isEmpty(), 'Email message present.');
        Assert.areEqual(1, emList.size(), '1 Email message present.');
    }
    
    @isTest
    public static void testEmailConsumerEventsFromSFToArtemis(){
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
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 224069341';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        insert cs;
        
        EmailMessage em1 = TestBusinessHelper.createEmailMessage(cs.Id, true, true);
        EmailMessage em2 = TestBusinessHelper.createEmailMessage(cs.Id, false, true);
        
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the');
        ContentVersion cv1 = TestBusinessHelper.createContentVersion(bodyBlob, true);
        
        ContentVersion cv2 = [Select Id, ContentDocumentId From ContentVersion Where Id =: cv1.Id];
        ContentDocumentLink cdl = TestBusinessHelper.createContentDocumentLink(cv2.ContentDocumentId, em1.Id, true);
        
        TriggerExecutionController.skipAllTriggers(false);
        
        Test.startTest();
        Email_Consumer_Event__e evt = new Email_Consumer_Event__e();
        evt.Json_1__c= '{"topic":"msk.aretmis.email.topic.confidential.dedicated.v1","message":{"email_message_external_id":"01HJ0JK1J99QMM4DGWHWNZMGKT","sf_email_id":"'+em1.Id+'"},"eventNotificationName":"com.email.artemis.insert"}';
        EventBus.publish(evt);
        Test.stopTest();
        
        List<Emailmessage> emList = new List<Emailmessage>([Select Id, Artemis_Id__c From EmailMessage Where Id =: em1.Id]);
        Assert.areEqual('01HJ0JK1J99QMM4DGWHWNZMGKT', emList[0].Artemis_Id__c, 'Artemis Id matches for email.');
    }
}