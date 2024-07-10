/*
* Author   : Ranjan 
* Purpose  : Utility test class for Artemis Producer Handler functionalities 
*
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------

*/

@isTest
public class CaseConsumerEventHandlerTest {
    
    @isTest
     public static void preparePERecordTest() {

        CaseData_Test.createEmailtoCase();
        list<Case> lstCases = [select Id, RecordTypeId, RecordType.Name, SF_4PL_Account__c, MLL__C, isclosed from Case where Subject = 'Test Case_CaseTestData.generateTestRecord' order by CreatedDate desc limit 1];
        lstCases[0].Status = 'Closed - Not a case';
        lstCases[0].Resolution_Summary__c = 'Test';
        lstCases[0].Reason_for_Case__c = 'Spam';
        update lstCases;
        
        list<EmailMessage> lstEmailMessages = new list<EmailMessage>();
        lstEmailMessages.add(new EmailMessage(FromAddress = 'test@maersk.com', Incoming = True, ToAddress = 'hello@maersk.salesforce.com', Subject = 'Test email', Status = '0', TextBody = '<b>Sample Text</b>', ParentId = lstCases[0].Id)); 
        lstEmailMessages.add(new EmailMessage(FromAddress = 'test@maersk.com', Incoming = false, ToAddress = 'hello@maersk.salesforce.com', Subject = 'Test email', Status = '0', TextBody = 'Sample Text', ParentId = lstCases[0].Id)); 
        insert lstEmailMessages;
        
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the');
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = bodyBlob, 
            origin = 'H',
            CreatedDate = System.now(),
            LastModifiedDate = System.now()
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId, checksum FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        
        
        List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = lstCases[0].Id;
            cdl.contentdocumentid = contentVersion_2.contentdocumentid;
            cdl.ShareType = 'V';
            cdList.add(cdl);
        insert cdList;

        
         Test.startTest();
         
         Case css = new Case();
         css = [select id, direction__C,Security_Code__c from case limit 1];
         Survey__c surveyObj=new Survey__c();
        surveyObj.put('Case_Security_Code__c',css.Security_Code__c);
        surveyObj.put('Ease_to_Resolve_Issue__c',1);
        surveyObj.put('Ease_to_Resolve_Issue_Description__c','Demo desc');
        surveyObj.put('Response_Actions__c','None');
        surveyObj.put('Followed_Up_Date__c',date.today());
        surveyObj.put('RecordTypeId','01257000000Qs2YAAS');
        surveyObj.put('Case__c',css.id);
        insert surveyObj;
        Casecomment ccobj=new Casecomment();
        ccobj.CommentBody='Shipment issue need support';
        ccobj.ParentId=css.id;
        insert ccobj;
         Case_Consumer_Event__e evt=new Case_Consumer_Event__e();
         evt.Json_1__c='{\"topic\":\"msk.aretmis.case.topic.confidential.dedicated.v1\",\"message\":{\"artemis_case_id\":\"427\",\"sf_case_id\":\"'+css.id+'\"},\"eventNotificationName\":\"com.case.artemis.insert\"}"}';
         Database.SaveResult results = EventBus.publish(evt);
         Test.stopTest();     
     }
     @isTest
     public static void prepareCaseCommentTest() {

        CaseData_Test.createEmailtoCase();
        list<Case> lstCases = [select Id, RecordTypeId, RecordType.Name, SF_4PL_Account__c, MLL__C, isclosed from Case where Subject = 'Test Case_CaseTestData.generateTestRecord' order by CreatedDate desc limit 1];
        lstCases[0].Status = 'Closed - Not a case';
        lstCases[0].Resolution_Summary__c = 'Test';
        lstCases[0].Reason_for_Case__c = 'Spam';
        lstCases[0].Artemis_Id__c='427';
        update lstCases;
        Test.startTest();
        Case css = new Case();
         css = [select id, direction__C,Security_Code__c from case limit 1];
        list<EmailMessage> lstEmailMessages = new list<EmailMessage>();
        lstEmailMessages.add(new EmailMessage(FromAddress = 'test@maersk.com', Incoming = True, ToAddress = 'hello@maersk.salesforce.com', Subject = 'Test email', Status = '0', TextBody = '<b>Sample Text</b>', ParentId = lstCases[0].Id)); 
        lstEmailMessages.add(new EmailMessage(FromAddress = 'test@maersk.com', Incoming = false, ToAddress = 'hello@maersk.salesforce.com', Subject = 'Test email', Status = '0', TextBody = 'Sample Text', ParentId = lstCases[0].Id)); 
        insert lstEmailMessages;
        
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the');
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = bodyBlob, 
            origin = 'H',
            CreatedDate = System.now(),
            LastModifiedDate = System.now()
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId, checksum FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        
        
        List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = lstCases[0].Id;
            cdl.contentdocumentid = contentVersion_2.contentdocumentid;
            cdl.ShareType = 'V';
            cdList.add(cdl);
        insert cdList;

        
         
         
         
         Survey__c surveyObj=new Survey__c();
        surveyObj.put('Case_Security_Code__c',css.Security_Code__c);
        surveyObj.put('Ease_to_Resolve_Issue__c',1);
        surveyObj.put('Ease_to_Resolve_Issue_Description__c','Demo desc');
        surveyObj.put('Response_Actions__c','None');
        surveyObj.put('Followed_Up_Date__c',date.today());
        surveyObj.put('RecordTypeId','01257000000Qs2YAAS');
        surveyObj.put('Case__c',css.id);
        insert surveyObj;
        Casecomment ccobj=new Casecomment();
        ccobj.CommentBody='Shipment issue need support';
        ccobj.ParentId=css.id;
        insert ccobj;
         Case_Consumer_Event__e evt=new Case_Consumer_Event__e();
         evt.Json_1__c='{\"topic\":\"msk.aretmis.case.topic.confidential.dedicated.v1\",\"message\":{\"artemis_case_id\":\"427\",\"sf_case_id\":\"'+css.id+'\"},\"eventNotificationName\":\"com.case.artemis.insert\"}"}';
         Database.SaveResult results = EventBus.publish(evt);
         Test.stopTest();     
     }

     @isTest
    public static void testCaseConsumerMergeEventsFromArtemisToSF(){
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
        
        Case cs1 = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs1.Id = null;
        cs1.Subject = 'Test Case1';
        cs1.Case_Channel__c = 'E-mail';
        cs1.Description = 'Test new case';
        cs1.Status = 'New';
        cs1.Artemis_Id__c='01HH43BRBQH651YPB1RM2NWA72';
        cs1.Artemis_Case_Number__c='AT-2312-000000014';
        insert cs1;
        
        Case cs2 = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs2.Id = null;
        cs2.Subject = 'Test Case2';
        cs2.Case_Channel__c = 'E-mail';
        cs2.Description = 'Test new case';
        cs2.Status = 'In Progress';
        cs2.parentId=cs1.Id;
        cs2.Artemis_Id__c='01HH43BRBQH651YPB1RM2NWA73';
        cs2.Artemis_Case_Number__c='AT-2312-000000015';
        insert cs2;

        TriggerExecutionController.skipAllTriggers(false);

        Account acc1=[Select Id from Account where Id=:acc.Id];
        Contact con1=[Select Id from Contact where Id=:con.Id];
        Test.startTest();
        Case_Consumer_Event__e evt = new Case_Consumer_Event__e();
        evt.Json_1__c= '{\"table_name\":\"artemis_case\",\"record_id\":1549,\"operation\":\"UPDATE\",\"message\":{\"artemis_case_id\":\"'+cs2.Artemis_Id__c+'\",\"tenant_id\":\"All Users\",\"artemis_case_number\":\"'+cs2.Artemis_Case_Number__c+'\",\"artemis_account_id\":\"'+acc1.Id+'\",\"on_behalf_account_id\":null,\"owner_user_id\":null,\"sf_case_id\":\"'+cs2.Id+'\",\"sf_case_number\":\"'+cs2.CaseNumber+'\",\"contact_id\":\"'+con1.Id+'\",\"service_relationship_id\":null,\"country_id\":\"'+geography.Id+'\",\"owner_queue_id\":\"00G0D000004BEAqUAO\",\"brand_id\":\"Maersk Line\",\"priority_id\":\"Medium\",\"cargo_type_id\":\"Dry\",\"case_channel_id\":\"E-mail\",\"case_closure_opt_out_reason_id\":null,\"record_type_id\":\"012D0000000QoomIAC\",\"direction_id\":\"Not Known\",\"case_closure_sent\":false,\"origin\":\"MSLINCOL\",\"case_reopened\":false,\"closing_date\":null,\"description\":\"sgjpsoejgvklsdmv\",\"delivery_channel_id\":null,\"parent_case_artemis_id\":\"'+cs1.Artemis_Id__c+'\",\"product_id\":\"Ocean\",\"reason_for_case_id\":\"Customer Details Update\",\"sentiment_analysis_id\":\"Neutral\",\"case_status_id\":\"Closed - Merged\",\"type_id\":\"Collections\",\"sub_type_id\":\"General Queries\",\"resolver_department_id\":null,\"requestor_id\":null,\"collaboration_reason_id\":null,\"collaboration_reason_other\":null,\"is_escalated\":false,\"resolution_summary\":null,\"response_received_flag\":false,\"send_case_closure\":\"Yes\",\"shipment_number\":null,\"subject\":\"Test Merging\",\"supplied_email\":\"ab.adityasingh2001@gmail.com\",\"supplied_name\":\"ADITYA SINGH\",\"thread_token\":\"thread::a-oYpKguBD2NH9kdjj_-ziw::\",\"owner_email\":\"\",\"owner_name\":\"MSL-India-Collection\",\"sf_parent_case_id\":\"'+cs1.Id+'\",\"sf_parent_case_number\":\"'+cs1.CaseNumber+'\",\"creation_date\":\"2023-12-08T06:55:35+00:00\",\"last_modified_date\":\"2023-12-08T06:57:49+00:00\",\"row_version\":3,\"thread_identifier\":\"ref:_00D0DD7aM._500Fg06LIHr:ref\",\"artemis_case_external_id\":\"01HH43BRBQH651YPB1RM2NWA73\",\"parent_clone_artemis_case_id\":null},\"topic\":\"msk.aretmis.case.topic.confidential.dedicated.v1\",\"eventNotificationName\":\"com.case.artemis.insert\"}';
        EventBus.publish(evt);
        Test.stopTest();    
        
        List<EmailMessage> emList = new List<EmailMessage>([Select Id From EmailMessage Where parentId =: cs2.Id]);
        Assert.isTrue(emList.isEmpty());
        Assert.areEqual(0, emList.size());
    }
    
     
    
}