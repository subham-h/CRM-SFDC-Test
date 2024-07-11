/** Author   : Ranjan 
* Purpose  : Utility test class for Artemis Consumer Handler functionalities 
*
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------

*/

@isTest
public class SurveyConsumerEventHandler_Test {
    
    @isTest
    public static void preparePERecordTest() {
        
        CaseData_Test.createEmailtoCase();
        list<Case> lstCases = [select Id, RecordTypeId, RecordType.Name, SF_4PL_Account__c, MLL__C, isclosed from Case where Subject = 'Test Case_CaseTestData.generateTestRecord' order by CreatedDate desc limit 1];
        lstCases[0].Status = 'Closed - Not a case';
        lstCases[0].Resolution_Summary__c = 'Test';
        lstCases[0].Reason_for_Case__c = 'Spam';
        lstCases[0].Artemis_Id__c='459';
        update lstCases;
        Test.startTest();
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
            CreatedDate = System.now()
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
        Survey_Consumer_Event__e evt=new Survey_Consumer_Event__e();
        evt.Json_1__c='{\"topic\":\"msk.aretmis.survey.topic.confidential.dedicated.v1\",\"message\":{\"survey_id\":\"427\",\"sf_survey_id\":\"'+surveyObj.id+'\"},\"eventNotificationName\":\"com.case.artemis.insert\"}"}';
        Database.SaveResult results = EventBus.publish(evt);
        Test.stopTest();     
    }
    
}