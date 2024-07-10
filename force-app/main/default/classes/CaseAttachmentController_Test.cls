@isTest
public class CaseAttachmentController_Test {
    @isTest
    static void getAttachmentByParentId_test_without_Attachments(){
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email = 'Test@test.com';
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list<Case> lstParentCse = new list<Case>();
        CaseData_Test.createExternalCases();       
        lstparentCse = CaseData_Test.lstCases;
        for(case caseObj : lstparentCse){
            caseObj.Type='Booking';
            caseObj.Sub_Type__c='New Booking Request';
            caseObj.Reason_For_Case__c = 'Booking Request';
        }
        insert lstParentCse;
        EmailMessageData_Test.iNumberOfEmailMessages = 1;
        EmailMessageData_Test.bCreate = false;
        EmailMessageData_Test.createEmailMessage();
        list<EmailMessage> lstEmailMssg = new list<EmailMessage>();
        list<EmailMessage> lstEmailMssgChild = new list<EmailMessage>();
        
        for(Case parentCseInbndAct: lstParentCse){             
            for(EmailMessage emailMessageIterator : EmailMessageData_Test.lstEmailMessages) {
                emailMessageIterator.parentid = parentCseInbndAct.Id;
                lstEmailMssg.add(emailMessageIterator);
            }   
        }
        insert lstEmailMssg;
       System.assert(CaseAttachmentsController.loadAllAttachments(lstParentCse[0].Id)!=null);
        
    }
    
   @isTest
    static void getAttachmentByParentId_test_with_Attachments_without_files(){
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email = 'Test@test.com';
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list<Case> lstParentCse = new list<Case>();
        CaseData_Test.createExternalCases();       
        lstparentCse = CaseData_Test.lstCases;
        for(case caseObj : lstparentCse){
            caseObj.Type='Booking';
            caseObj.Sub_Type__c='New Booking Request';
            caseObj.Reason_For_Case__c = 'Booking Request';
        }
        insert lstParentCse;
        EmailMessageData_Test.iNumberOfEmailMessages = 1;
        EmailMessageData_Test.bCreate = false;
        EmailMessageData_Test.createEmailMessage();
        list<EmailMessage> lstEmailMssg = new list<EmailMessage>();
        list<EmailMessage> lstEmailMssgChild = new list<EmailMessage>();
        
        for(Case parentCseInbndAct: lstParentCse){             
            for(EmailMessage emailMessageIterator : EmailMessageData_Test.lstEmailMessages) {
                emailMessageIterator.parentid = parentCseInbndAct.Id;
                lstEmailMssg.add(emailMessageIterator);
            }   
        }
        insert lstEmailMssg;
        
        Attachment attachmentEmailMessage = new Attachment(                        
            ParentId = lstEmailMssg[0].Id,                         
            Body = Blob.valueOf('Test Body'),                         
            ContentType = 'application/pdf',                         
            Name = 'attachmentFilename.pdf');
        insert attachmentEmailMessage;
        system.assert(CaseAttachmentsController.loadAllAttachments(lstParentCse[0].Id)!=null);
    }
    
    @isTest
    static void getAttachmentByParentId_test_with_Attachments_with_files(){
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email = 'Test@test.com';
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list<Case> lstParentCse = new list<Case>();
        CaseData_Test.createExternalCases();       
        lstparentCse = CaseData_Test.lstCases;
        for(case caseObj : lstparentCse){
            caseObj.Type='Booking';
            caseObj.Sub_Type__c='New Booking Request';
            caseObj.Reason_For_Case__c = 'Booking Request';
        }
        insert lstParentCse;
        EmailMessageData_Test.iNumberOfEmailMessages = 1;
        EmailMessageData_Test.bCreate = false;
        EmailMessageData_Test.createEmailMessage();
        list<EmailMessage> lstEmailMssg = new list<EmailMessage>();
        list<EmailMessage> lstEmailMssgChild = new list<EmailMessage>();
        
        for(Case parentCseInbndAct: lstParentCse){             
            for(EmailMessage emailMessageIterator : EmailMessageData_Test.lstEmailMessages) {
                emailMessageIterator.parentid = parentCseInbndAct.Id;
                lstEmailMssg.add(emailMessageIterator);
            }   
        }
        insert lstEmailMssg;
        
        Attachment attachmentEmailMessage = new Attachment(                        
            ParentId = lstEmailMssg[0].Id,                         
            Body = Blob.valueOf('Test Body'),                         
            ContentType = 'application/pdf',                         
            Name = 'attachmentFilename.pdf');
        insert attachmentEmailMessage;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = lstParentCse[0].Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        CaseAttachmentsController.loadAllAttachments(lstParentCse[0].Id);
        system.assert(CaseAttachmentsController.getAttachmentBody(JSON.serialize(new List<Id>{attachmentEmailMessage.Id}))!=null);
    }
    
    @isTest
    static void testrenamefiles(){
        
        test.startTest();
        ContentVersion conVer = new ContentVersion(
        Title = 'Test Doc',
        pathOnClient = 'TestDoc.text',
        versionData = Blob.valueOf('This is test doc')
        );
        insert conVer;
        ContentVersion cv = [Select id from contentversion where Title=:'Test Doc'];
        System.debug('Id'+cv.id);
        String draftval = '[{"Title":"test","Id":"'+cv.id+'"}]';
        CaseAttachmentsController.renameFiles(draftval);
        ContentVersion cvrenamed = [Select id,title from contentversion where id=:cv.id];
        System.assertEquals(cvrenamed.title,'test');
        test.stopTest();        
    }


    @isTest
    public static void test_deleteSelectedAttachments()
    {
        ContentVersion conVer = new ContentVersion(
        Title = 'Test Doc',
        pathOnClient = 'TestDoc.text',
        versionData = Blob.valueOf('This is test doc')
        );
        insert conVer;

        Id ContentDocumentId  = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument LIMIT 1
        ].Id;

        Test.startTest();
            CaseAttachmentsController.deleteSelectedAttachments(new List<Id> { ContentDocumentId});
        Test.stopTest();
    } 
        
    
}