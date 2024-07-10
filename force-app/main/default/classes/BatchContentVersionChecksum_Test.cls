/**
 * @description Test class for BatchContentVersionChecksum
 * 
 * Date         Owner                                     Ref Number    Description
 *********************************************************************************************************************************
 *                                                                      Class created
 * 12-09-2022	Ronnie@SF                                 CRM0000030    Removing brand hardcodings and improving retrieval of recordtype info
 */
@isTest
public class BatchContentVersionChecksum_Test {
    
    public static TestMethod void testUpdateChecksum(){
        TriggerExecutionController.skipAllTriggers(true);
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        for(Case caseIterator : lstCases) {  
            caseIterator.recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('External_Case').getRecordTypeId();
            caseIterator.Direction__c = 'Export';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Charges, Invoice & Payment'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Invoice / Payer Party';
            caseIterator.Case_Channel__c ='E-mail';
        }
        lstCases[0].CreatedDate = System.now() - 2;
        lstCases[1].CreatedDate = System.now() - 1;
        insert lstCases;
        
        //Yesterday's Data
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@maersk.com';
        email.Incoming = True;
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.ParentId = lstCases[0].Id; 
        email.CreatedDate = System.now() - 2;
        insert email;
        
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the');
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = bodyBlob, 
            origin = 'H',
            CreatedDate = System.now() - 1
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        
        ContentDocumentLink cdl1 = new ContentDocumentLink();
        cdl1.LinkedEntityId = email.id;
        cdl1.contentdocumentid = contentVersion_2.contentdocumentid;
        cdl1.ShareType = 'V';
        insert cdl1;
        
        Test.startTest();
        String sch = '0 0 2 * * ?';
        String jobID = system.schedule('BatchContentVersionChecksumTest', sch, new BatchContentVersionChecksum(null, null));
        Test.stopTest();
    }

}