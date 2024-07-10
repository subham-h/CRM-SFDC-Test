/*
* Author    : Ranjan
* Purpose   : Test class for Batch_EmailMessageExtCseArchiver
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-5245     20-Jan-2023  Ranjan@Maersk            Created. 
* 
*
*/
@isTest(SeeAllData=false)
private class Batch_EmailMessageExtCseArchiver_Test {
    
    static testMethod void test_scheduledBatchEmailMessageArchiver() {
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
        
        List<attachment> attList = new List<attachment>();
        for(Integer iterator=0; iterator<lstEmailMessages.size(); iterator++) {
            Attachment attach=new Attachment();   	
            attach.Name='Unit Test Attachment';
            Blob bdyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bdyBlob;
            attach.parentId=lstEmailMessages[iterator].id;
            attList.add(attach);
        }
        insert attList;
        
        Test.startTest();
        Batch_EmailMessageExtCseArchiver batchEmailMessageArchiver = new Batch_EmailMessageExtCseArchiver(100);
        Database.executeBatch(batchEmailMessageArchiver, 200); // RQ-004464
        Test.stopTest();
    }

    static testMethod void test_oneTimeBatchEmailMessageArchiver() {        
        CaseData_Test.createEmailtoCase();
        list<Case> lstCases = [select Id from Case where Subject = 'Test Case_CaseTestData.generateTestRecord' order by CreatedDate desc limit 1];
        TriggerExecutionController.skipCaseTrigger(true);
        lstCases[0].Status = 'Closed - Not a case';
        lstCases[0].OwnerId = userinfo.getUserId();
        lstCases[0].Resolution_Summary__c = 'Test';
        lstCases[0].Reason_for_Case__c = 'Spam';
        update lstCases;
        
        update lstCases;
        Set<id> setCaseId = new set<id>();
        setCaseId.add(lstCases[0].id);
        TriggerExecutionController.skipCaseTrigger(false);

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
        for(Integer iterator=0; iterator<lstEmailMessages.size(); iterator++) {            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = lstEmailMessages[iterator].id;
            cdl.contentdocumentid = contentVersion_2.contentdocumentid;
            cdl.ShareType = 'V';
            cdList.add(cdl);
        }
        insert cdList;

        Test.startTest(); 
        System.schedule('casearchivaltest', '0 0 19 ? * *', new Schedule_BatchEmailMessageExtCseArchiver());
        Test.stopTest();
    }
    
    static testMethod void test_oneAttachmentArchiver() {
        CaseData_Test.createEmailtoCase();
        list<Case> lstCases = [select Id from Case where Subject = 'Test Case_CaseTestData.generateTestRecord' order by CreatedDate desc limit 1];
        TriggerExecutionController.skipCaseTrigger(true);
        lstCases[0].Status = 'Closed - Not a case';
        lstCases[0].OwnerId = userinfo.getUserId();
        lstCases[0].Resolution_Summary__c = 'Test';
        lstCases[0].Reason_for_Case__c = 'Spam';
        update lstCases;
        
        update lstCases;
        Set<id> setCaseId = new set<id>();
        setCaseId.add(lstCases[0].id);
        TriggerExecutionController.skipCaseTrigger(false);

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
        
        List<attachment> attList = new List<attachment>();
        for(Integer iterator=0; iterator<lstEmailMessages.size(); iterator++) {
            Attachment attach=new Attachment();   	
            attach.Name='Unit Test Attachment';
            Blob bdyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bdyBlob;
            attach.parentId=lstEmailMessages[iterator].id;
            attList.add(attach);
        }
        insert attList;

        Test.startTest(); 
        CaseEmailMessageSender.initiateScheduledEMSExtArchival('','',100);
        Test.stopTest();
    }
    
    static testMethod void test_Scheduler_BatchEmailMessageExtArchiver() {
        CaseData_Test.createEmailtoCase();
        list<Case> lstCases = [select Id from Case where Subject = 'Test Case_CaseTestData.generateTestRecord' order by CreatedDate desc limit 1];
        TriggerExecutionController.skipCaseTrigger(true);
        lstCases[0].Status = 'Closed - Not a case';
        lstCases[0].OwnerId = userinfo.getUserId();
        lstCases[0].Resolution_Summary__c = 'Test';
        lstCases[0].Reason_for_Case__c = 'Spam';
        update lstCases;
        
        Set<id> setCaseId = new set<id>();
        setCaseId.add(lstCases[0].id);
        TriggerExecutionController.skipCaseTrigger(false);

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
        for(Integer iterator=0; iterator<lstEmailMessages.size(); iterator++) {
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = lstEmailMessages[iterator].id;
            cdl.contentdocumentid = contentVersion_2.contentdocumentid;
            cdl.ShareType = 'V';
            cdList.add(cdl);
        }
        insert cdList;
        SingleRelatedListCtrl.fetchInitData(lstEmailMessages.get(0).id,'Title;ContentModifiedDate;OwnerId;ContentSize;Createdby.Name');
        Test.startTest(); 
        System.schedule('Batch EmailMessage External Archival Test', '0 0 19 ? * *', new Scheduler_BatchEmailMessageExtArchiver());
        Test.stopTest();
    }
    
    static testMethod void test_OneTimeBatch() {
        Odata_Batch_EmailMessage_Case_Archiver__mdt chainedbatch=[select id,start_date__c,end_date__c,Number_Of_Hours__c from Odata_Batch_EmailMessage_Case_Archiver__mdt where DeveloperName in ('One_Time')];
        Id extCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('External_Case').getRecordTypeId();
        list<Case> lstCases = new list<Case>();
        Case caseIterator = new Case();
        caseIterator.Subject = 'CaseTestData Subject_';
        caseIterator.Description = 'CaseTestData Description_';
        caseIterator.Thread_topic__c = 'Test';            
        caseIterator.Status = 'Closed - Resolved';
        caseIterator.Type = 'Prior To Booking';
        caseIterator.Sub_Type__c = 'Cargo Restrictions/Support Enquiry';
        caseIterator.Country__c = BDAGeographyData_Test.countryUK.Id;
        caseIterator.Cargo_Classification__c ='US Military (USM)';
        caseIterator.Liner_Brand__c = brandutilities.MAERSK;
        caseIterator.Direction__c = 'Export';
        caseIterator.Case_Channel__c = 'Chat';
        caseIterator.SuppliedEmail = Null;
        caseIterator.Origin = 'MSLUSEXP';
        caseIterator.Case_Visibility__c = 'All Users';
        caseIterator.RecordTypeId= extCaseRTId;
        caseIterator.Resolution_Summary__c='test';
        caseIterator.Reason_For_Case__c='Cargo Restriction/Information Not Received';
        caseIterator.MLL__c=false;
        caseIterator.createddate=chainedbatch.start_date__c;
        caseIterator.Security_Code__c='test';
        lstCases.add(caseIterator);
        insert lstCases;
        
        Set<id> setCaseId = new set<id>();
        setCaseId.add(lstCases[0].id);
        TriggerExecutionController.skipCaseTrigger(false);

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
        for(Integer iterator=0; iterator<lstEmailMessages.size(); iterator++) {            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = lstEmailMessages[iterator].id;
            cdl.contentdocumentid = contentVersion_2.contentdocumentid;
            cdl.ShareType = 'V';
            cdList.add(cdl);
        }
        insert cdList;
        SingleRelatedListCtrl.fetchInitData(lstEmailMessages.get(0).id,'Title;ContentModifiedDate;OwnerId;ContentSize;Createdby.Name');
        Test.startTest(); 
        Database.executeBatch(new Batch_EmailMessageExtCseArchiver('One_Time',50),50);
        Test.stopTest();
    }
    
    static testMethod void test_Exception() {
        Batch_EmailMessageExtCseArchiver batch = new Batch_EmailMessageExtCseArchiver(100);
        batch.performBatchActions(null);
    }
    
    static testMethod void test_CaseEmailMessageSender() {
        CaseData_Test.createEmailtoCase();
        list<Case> lstCases = [select Id from Case where Subject = 'Test Case_CaseTestData.generateTestRecord' order by CreatedDate desc limit 1];
        TriggerExecutionController.skipCaseTrigger(true);
        lstCases[0].Status = 'Closed - Not a case';
        lstCases[0].OwnerId = userinfo.getUserId();
        lstCases[0].Resolution_Summary__c = 'Test';
        lstCases[0].Reason_for_Case__c = 'Spam';
        update lstCases;
        
        update lstCases;
        Set<id> setCaseId = new set<id>();
        setCaseId.add(lstCases[0].id);
        TriggerExecutionController.skipCaseTrigger(false);

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
        for(Integer iterator=0; iterator<lstEmailMessages.size(); iterator++) {            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = lstEmailMessages[iterator].id;
            cdl.contentdocumentid = contentVersion_2.contentdocumentid;
            cdl.ShareType = 'V';
            cdList.add(cdl);
        }
        insert cdList;

        Test.startTest(); 
        Map<Id, emailmessagearchival__x> mapOldNewEmailIds=new Map<Id, emailmessagearchival__x> ();
        mapOldNewEmailIds.put([select id from emailmessage limit 1].id,new emailmessagearchival__x() );
        Map<Id,EmailMessage> emailMessageToFinDelMap=new Map<Id,EmailMessage> ();
        EmailMessage emobj=[select id from emailmessage limit 1];
        emailMessageToFinDelMap.put(emobj.id,emobj);
        try{
            CaseEmailMessageSender.createContentDocLinks(mapOldNewEmailIds);
        }catch(Exception e){
        }
        Test.stopTest();
    }
         
}