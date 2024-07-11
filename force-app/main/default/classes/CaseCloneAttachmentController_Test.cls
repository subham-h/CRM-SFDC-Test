@isTest
public class CaseCloneAttachmentController_Test {
    @isTest
    static void testcloneRecord(){
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        List<Case> lstCases = new List<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        Test.startTest();
        for(Case c: lstCases){
            c.Description = 'Cloned';
        }
        insert lstCases;
        Case parentCase =[SELECT Id, Description  FROM Case WHERE Id =:lstCases[0].id];
        TriggerExecutionController.skipCaseTrigger(true);
        parentCase.New_Mail__c = true;
        update parentCase;
        TriggerExecutionController.skipCaseTrigger(false);
        String clonecaseid = CaseCloneAttachmentController.cloneCaseRecord(parentCase.id);
        Case clonecase = [Select id,Description from case where id=:clonecaseid];
        System.assertEquals(clonecase.Description,parentCase.Description,'Case fields are clones');
        Test.stopTest();
    }
    
    @isTest
    static  void testcloneAttachmentRecord()
    {
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        List<Case> lstCases = new List<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
            Test.startTest();
            for(Case c: lstCases)
        	{
            	c.Description = 'Cloned';
                
        	}
        insert lstCases;
        Case parentCase =[SELECT Id, Description  FROM Case WHERE Id =:lstCases[0].id];
        String clonecaseid = CaseCloneAttachmentController.cloneCaseRecord(parentCase.id);
        
        	Attachment attachmentRecord = new Attachment(                        
            ParentId = parentCase.Id,                         
            Body = Blob.valueOf('Test Body'),                         
            ContentType = 'application/pdf',                         
            Name = 'attachmentFilename.pdf');
        	insert attachmentRecord;
        	String atId=attachmentRecord.Id;
        	String attachmentIds = '[\"'+atId+'\"]';
        	CaseCloneAttachmentController.cloneAttachmentRecord(attachmentIds,clonecaseid);
        	System.assertEquals(CaseCloneAttachmentController.attachmentlist[0].ParentId,clonecaseid,'Attachment linked to cloned case');
        Test.stopTest();
    }
    
    @isTest
    static  void testcloneContentVersionRecord()
    {
         CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        List<Case> lstCases = new List<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
            Test.startTest();
            for(Case c: lstCases)
        	{
            	c.Description = 'Cloned';
                
        	}
        insert lstCases;
        Case parentCase =[SELECT Id, Description  FROM Case WHERE Id =:lstCases[0].id];
        String clonecaseid = CaseCloneAttachmentController.cloneCaseRecord(parentCase.id);
        ContentVersion conVer = new ContentVersion(
        Title = 'Test Doc',
        pathOnClient = 'TestDoc.text',
        versionData = Blob.valueOf('This is test doc')
        );
        insert conVer;
        List<ContentVersion> cv = [Select id, contentDocumentId from contentversion where id=: conVer.Id];
        String contentDocumentIds = '[\"'+cv[0].contentDocumentId+'\"]';
        CaseCloneAttachmentController.cloneContentDocumentRecord(contentDocumentIds,clonecaseid);
        System.assertEquals(CaseCloneAttachmentController.cdlList[0].LinkedEntityId,clonecaseid,'Attachment linked to cloned case');
        
        Test.stopTest();
        
    }
    
    @isTest
    public static void testEmailClone(){
        Geography__c geography = TestBusinessHelper.createGeography('United Kingdom', 'Country', null, true);
        Geography__c indGeography = TestBusinessHelper.createGeography('India', 'Country', null, true);
        
        Account acc = TestBusinessHelper.createAccount('Unassigned', false);
        acc.Id = null;
        acc.Name = 'Test Account';
        acc.Country__c = geography.Id;
        insert acc;
        
        Contact con = TestBusinessHelper.createContact(acc, 'Internal_Contact', BrandUtilities.MAERSKLINE, false);
        con.Id = null;
        con.Country__c = acc.Country__c;
        insert con;
        
        Contact con1 = TestBusinessHelper.createContact(acc, 'Internal_Contact', BrandUtilities.MAERSKLINE, false);
        con1.Id = null;
        con1.LastName = 'Test Con 2';
        con1.Email = 'test2@maersk.com';
        con1.Country__c = acc.Country__c;
        insert con1;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 224069341';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        insert cs;
        list<EmailMessage> lstEmailMessages = new list<EmailMessage>();
        lstEmailMessages.add(new EmailMessage(FromAddress = 'test@maersk.com', Incoming = True, ToAddress = 'hello@maersk.salesforce.com', Subject = 'Test email', Status = '0', TextBody = '<b>Sample Text</b>', ParentId = cs.Id)); 
        lstEmailMessages.add(new EmailMessage(FromAddress = 'test@maersk.com', Incoming = false, ToAddress = 'hello@maersk.salesforce.com', Subject = 'Test email', Status = '0', TextBody = 'Sample Text', ParentId = cs.Id)); 
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
        for(Integer iterator=0; iterator<lstEmailMessages.size(); iterator++) {
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = lstEmailMessages[iterator].id;
            cdl.contentdocumentid = contentVersion_2.contentdocumentid;
            cdl.ShareType = 'V';
            cdList.add(cdl);
        }
        insert cdList;
        

       
        
        Test.startTest();
        String clonecaseid = CaseCloneAttachmentController.cloneCaseRecord(cs.id); 
        String emailId=[select id from EmailMessage].get(0).id;
        String emailIdStrArray = '[\"'+emailId+'\"]';
        CaseCloneAttachmentController.cloneEmailRecords(emailIdStrArray,clonecaseid);
        Test.stopTest();
    }
    
}