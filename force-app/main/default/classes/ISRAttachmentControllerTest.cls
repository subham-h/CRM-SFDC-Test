@isTest
public class ISRAttachmentControllerTest {
    
    @isTest
    public static void testCaseSearchAndForm(){
        TriggerExecutionController.skipAllTriggers(true);        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCasesII();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {
            caseIterator.Direction__c = 'Export';
            caseIterator.status = 'Triaged';
            caseIterator.Type = 'Prior To Booking'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Cargo Restrictions/Support Enquiry';
        }  
        
        insert lstCases[0];        
        
        Test.startTest();
        ISRAttachmentController.fetchLookupData('', 'Case', new List<String>());
        ISRAttachmentController.getForm(lstCases[0].Id, 'Case', 'ISR_Field_Set');
        ISRAttachmentController.getRecordTypeName(lstCases[0].Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testFilesAndContentDocument(){
        TriggerExecutionController.skipAllTriggers(true);        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCasesII();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {
            caseIterator.Direction__c = 'Export';
            caseIterator.status = 'Triaged';
            caseIterator.Type = 'Prior To Booking'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Cargo Restrictions/Support Enquiry';
        }  
        
        insert lstCases[0];  
        
        EmailMessage emsg = new EmailMessage();
        emsg.FromAddress = 'test1@maersk.com';
        emsg.ToAddress = 'test2@gmail.com';
        emsg.CcAddress = 'test3@gmail.com';
        emsg.Subject = 'Test 1';
        emsg.TextBody = 'Test 2';
        emsg.ParentId = lstCases[0].Id;
        emsg.Incoming = true;
        insert emsg;
        
        List<ContentVersion> conVerList = new List<ContentVersion>();
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test Document';
        cv1.PathOnClient = 'TestDocument.pdf';
        cv1.VersionData = Blob.valueOf('Test Content');
        cv1.IsMajorVersion = true;
        conVerList.add(cv1);
        
        ContentVersion cv2 = new ContentVersion();
        cv2.Title = 'Test Document';
        cv2.PathOnClient = 'TestDocument.pdf';
        cv2.VersionData = Blob.valueOf('Test Content');
        cv2.IsMajorVersion = true;
        conVerList.add(cv2);
        
         ContentVersion cv3 = new ContentVersion();
        cv3.Title = 'Test Document';
        cv3.PathOnClient = 'TestDocument.pdf';
        cv3.VersionData = Blob.valueOf('Test Content');
        cv3.IsMajorVersion = true;
        conVerList.add(cv3);
        
        ContentVersion cv4 = new ContentVersion();
        cv4.Title = 'Test Document';
        cv4.PathOnClient = 'TestDocument.pdf';
        cv4.VersionData = Blob.valueOf('Test Content');
        cv4.IsMajorVersion = true;
        conVerList.add(cv4);
        
        insert conVerList;
        
        List<ContentVersion> newConVerList = [Select Id, ContentDocumentId From ContentVersion Where Id =: conVerList];
        List<String> conDocIds = new List<String>();
        for(ContentVersion con : newConVerList){
            conDocIds.add(con.ContentDocumentId);
        }
        
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        ContentDocumentLink cdl1 = new ContentDocumentLink();
        cdl1.LinkedEntityId = lstCases[0].Id;
        cdl1.ContentDocumentId = conDocIds[0];
        cdlList.add(cdl1);
        
        ContentDocumentLink cdl2 = new ContentDocumentLink();
        cdl2.LinkedEntityId = lstCases[0].Id;
        cdl2.ContentDocumentId = conDocIds[1];
        cdlList.add(cdl2);
        
        ContentDocumentLink cdl3 = new ContentDocumentLink();
        cdl3.LinkedEntityId = emsg.Id;
        cdl3.ContentDocumentId = conDocIds[2];
        cdlList.add(cdl3);
        
        ContentDocumentLink cdl4 = new ContentDocumentLink();
        cdl4.LinkedEntityId = emsg.Id;
        cdl4.ContentDocumentId = conDocIds[3];
        cdlList.add(cdl4);
        
        insert cdlList;
        Test.startTest();
        ISRAttachmentController.getFilesList(new List<String>{lstCases[0].Id});
        ISRAttachmentController.fileSizeToString(2048L);
        ISRAttachmentController.fileSizeToString(1048576L);
        ISRAttachmentController.fileSizeToString(1073741824L);
        
        ContentVersion cv5 = new ContentVersion();
        cv5.Title = 'Test Document';
        cv5.PathOnClient = 'TestDocument.pdf';
        cv5.VersionData = Blob.valueOf('Test Content');
        cv5.IsMajorVersion = true;
        insert cv5;
        
        ContentVersion cv6 = new ContentVersion();
        cv6.Title = 'Test Document';
        cv6.PathOnClient = 'TestDocument.pdf';
        cv6.VersionData = Blob.valueOf('Test Content');
        cv6.IsMajorVersion = true;
        insert cv6;
        
        List<ContentVersion> conDocIdList = [Select ContentDocumentId From ContentVersion Where Id =: cv5.Id or Id =: cv6.Id];
        
        ISRAttachmentController.attachFiles(lstCases[0].Id, new List<String>{conDocIdList[0].ContentDocumentId});        
        ISRAttachmentController.getEmailMessagesFromCase(lstCases[0].Id);
        ISRAttachmentController.cloneCase(lstCases[0].Id, new List<String>{conDocIdList[0].ContentDocumentId}, conDocIdList[1].ContentDocumentId,false, '');
        
        ISRAttachmentController.EmailContent eml = new ISRAttachmentController.EmailContent();
        eml.bodyHTML = 'Test';
        eml.subject = 'Test Subject';
        eml.to = 'test1@gmail.com';
        eml.cc = 'test2@gmail.com';
        
        ISRAttachmentController.cloneCase(lstCases[0].Id, new List<String>{conDocIdList[0].ContentDocumentId}, conDocIdList[1].ContentDocumentId, true, JSON.serialize(eml));
        Test.stopTest();
    }
    
}