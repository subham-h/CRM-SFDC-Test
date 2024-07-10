/**
 * Test class for FilesIntegrationWithIDA
 * 
 * Version  Date         Owner                   RQ#           Description
 *******************************************************************************************************************
 * 1.0                                                        
 * 2.0      05/12/2022   Vivek@Maersk          SC-5430       Test class for FilesIntegrationWithIDA class
 */

@isTest
public class FilesIntegrationWithIDATest {
    
    @isTest
    static void testUpdateCaseFields(){
        TriggerExecutionController.skipAllTriggers(true);
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createSCMCases();
        lstCases.add(CaseData_Test.lstCases[0]);
        for(Case thisCase: lstCases){
            
            thisCase.Product__c = 'SCM';
            thisCase.Case_Channel__C = 'E-mail';
            thisCase.Origin = 'SCMINSVC';
            
        }
        insert lstCases;
        TriggerExecutionController.skipAllTriggers(false);
        Test.startTest();
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'test@maersk.com', Incoming = True, ToAddress= 'hello@dummy.com', Subject = 'Test email', TextBody = '23456 ', ParentId = lstCases[0].Id,CcAddress='dummy.import@maersk.com'));
        insert newEmail;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        insert cv;  
        
        List<ContentDocument> conDocs = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = newEmail[0].Id;
        cdl.ContentDocumentId = conDocs[0].Id;
        insert cdl;
        
        Case caseRec=[Select Id,CC_Flag__c,Priority from case where Id=:lstCases[0].Id];
        
        String response = '{"statusCode":"200","statusMessage":"True"}';
        FilesIntegrationWIthIDA.filePEForIntegrationLog(response);
        Test.stopTest();
    }
    
}