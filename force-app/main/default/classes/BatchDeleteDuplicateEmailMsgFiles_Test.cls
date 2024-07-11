/**
 * Test class for BatchDeleteDuplicateEmailMessageFiles
 * 
 * Version     Date         Owner                      RQ#            Description
 ******************************************************************************************************  
 * 1.0                                                 #              Code created as part of #
 * 2.0         07-06-2022   Ronnie@SF                  SPI-100        Removed brand hardcodings
 * 3.0         12-09-2022   Ronnie@SF                  CRM0000030     Improved retrieval of recordtype info + removed newly added brand hardcodings
 */
@isTest
public class BatchDeleteDuplicateEmailMsgFiles_Test {
    
    public static TestMethod void testDuplicateFileDeletion(){
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
            CreatedDate = System.now() - 2
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId, checksum FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        
        ContentDocumentLink cdl1 = new ContentDocumentLink();
        cdl1.LinkedEntityId = email.id;
        cdl1.contentdocumentid = contentVersion_2.contentdocumentid;
        cdl1.ShareType = 'V';
        insert cdl1;
        
        contentVersion_2.Checksum__c = contentVersion_2.Checksum;
        update contentVersion_2;
        
        //Today's data
        EmailMessage newEmail = new EmailMessage();
        newEmail.FromAddress = 'test@maersk.com';
        newEmail.Incoming = True;
        newEmail.ToAddress= 'test@xyz.org';
        newEmail.Subject = 'Test email';
        newEmail.HtmlBody = 'Test email body';
        newEmail.ParentId = lstCases[1].Id; 
        newEmail.CreatedDate = System.now() - 1;
        insert newEmail;
        
        ContentVersion conver2 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = bodyBlob, 
            origin = 'H',
            CreatedDate = System.now() - 1
        );
        insert conver2;
        
        ContentVersion conver3 = [SELECT Id, Title, ContentDocumentId, checksum FROM ContentVersion WHERE Id = :conver2.Id LIMIT 1];
        
        ContentDocumentLink cdl2 = new ContentDocumentLink();
        cdl2.LinkedEntityId = newEmail.id;
        cdl2.contentdocumentid = conver3.contentdocumentid;
        cdl2.ShareType = 'V';
        insert cdl2;
        
        conver3.Checksum__c = conver3.Checksum;
        update conver3;
        
        Test.startTest();
        
        BatchDeleteDuplicateEmailMessageFiles batch =   new BatchDeleteDuplicateEmailMessageFiles(System.today()-1, System.today(), null, 'less than 10KB');
        Database.executeBatch(batch, 1);
         
        BatchDeleteDuplicateEmailMessageFiles batch1 =  new BatchDeleteDuplicateEmailMessageFiles(System.today()-1, System.today(), null, '');
        Database.executeBatch(batch1, 1);
        Test.stopTest();
    }
    
    public static TestMethod void testDuplicateFileDeletionSameBatch(){
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
        
        String str = '';
        for(Integer i=0; i< 1000; i++){
            str += 'Unit Test ContentVersion Body to be insert in test class for testing the';
        }
        
        Blob bodyBlob = Blob.valueOf(str);
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = bodyBlob, 
            origin = 'H',
            CreatedDate = System.now() - 2
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId, checksum, contentsize FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        system.debug('****contentVersion_2-->'+contentVersion_2.contentsize);
        ContentDocumentLink cdl1 = new ContentDocumentLink();
        cdl1.LinkedEntityId = email.id;
        cdl1.contentdocumentid = contentVersion_2.contentdocumentid;
        cdl1.ShareType = 'V';
        insert cdl1;
        
        contentVersion_2.Checksum__c = contentVersion_2.Checksum;
        update contentVersion_2;
        
        //Today's data
        EmailMessage newEmail = new EmailMessage();
        newEmail.FromAddress = 'test@maersk.com';
        newEmail.Incoming = True;
        newEmail.ToAddress= 'test@xyz.org';
        newEmail.Subject = 'Test email';
        newEmail.HtmlBody = 'Test email body';
        newEmail.ParentId = lstCases[1].Id; 
        newEmail.CreatedDate = System.now() - 1;
        insert newEmail;
        
        ContentVersion conver2 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = bodyBlob, 
            origin = 'H',
            CreatedDate = System.now() - 1
        );
        insert conver2;
        
        ContentVersion conver3 = [SELECT Id, Title, ContentDocumentId, checksum FROM ContentVersion WHERE Id = :conver2.Id LIMIT 1];
        
        ContentDocumentLink cdl2 = new ContentDocumentLink();
        cdl2.LinkedEntityId = newEmail.id;
        cdl2.contentdocumentid = conver3.contentdocumentid;
        cdl2.ShareType = 'V';
        insert cdl2;
        
        conver3.Checksum__c = conver3.Checksum;
        update conver3;
        
        Test.startTest();
    
        BatchDeleteDuplicateEmailMessageFiles batch =  new BatchDeleteDuplicateEmailMessageFiles(System.today()-1, System.today(), null, 'Duplicate only');
        Database.executeBatch(batch, 1);

        BatchDeleteDuplicateEmailMessageFiles batch1 =  new BatchDeleteDuplicateEmailMessageFiles(System.today()-1, System.today(), null, '');
        Database.executeBatch(batch1, 1);
        Test.stopTest();
    }
    
    public static TestMethod void testDuplicateFileDeletionBatch(){
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
            CreatedDate = System.now() - 2
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId, checksum FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        
        ContentDocumentLink cdl1 = new ContentDocumentLink();
        cdl1.LinkedEntityId = email.id;
        cdl1.contentdocumentid = contentVersion_2.contentdocumentid;
        cdl1.ShareType = 'V';
        insert cdl1;
        
        contentVersion_2.Checksum__c = contentVersion_2.Checksum;
        update contentVersion_2;
        
        //Today's data
        EmailMessage newEmail = new EmailMessage();
        newEmail.FromAddress = 'test@maersk.com';
        newEmail.Incoming = True;
        newEmail.ToAddress= 'test@xyz.org';
        newEmail.Subject = 'Test email';
        newEmail.HtmlBody = 'Test email body';
        newEmail.ParentId = lstCases[1].Id; 
        newEmail.CreatedDate = System.now() - 1;
        insert newEmail;
        
        ContentVersion conver2 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = bodyBlob, 
            origin = 'H',
            CreatedDate = System.now() - 1
        );
        insert conver2;
        
        ContentVersion conver3 = [SELECT Id, Title, ContentDocumentId, checksum FROM ContentVersion WHERE Id = :conver2.Id LIMIT 1];
        
        ContentDocumentLink cdl2 = new ContentDocumentLink();
        cdl2.LinkedEntityId = newEmail.id;
        cdl2.contentdocumentid = conver3.contentdocumentid;
        cdl2.ShareType = 'V';
        insert cdl2;
        
        conver3.Checksum__c = conver3.Checksum;
        update conver3;
        
        Test.startTest();
        BatchDeleteDuplicateEmailMessageFiles batch =  new BatchDeleteDuplicateEmailMessageFiles(System.today()-1, System.today(), null, '');
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }
    
    public static TestMethod void testDuplicateFileDeletionSameBatchCondition(){
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
        
        String str = '';
        for(Integer i=0; i< 1000; i++){
            str += 'Unit Test ContentVersion Body to be insert in test class for testing the';
        }
        
        Blob bodyBlob = Blob.valueOf(str);
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = bodyBlob, 
            origin = 'H',
            CreatedDate = System.now() - 2
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId, checksum, contentsize FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        system.debug('****contentVersion_2-->'+contentVersion_2.contentsize);
        ContentDocumentLink cdl1 = new ContentDocumentLink();
        cdl1.LinkedEntityId = email.id;
        cdl1.contentdocumentid = contentVersion_2.contentdocumentid;
        cdl1.ShareType = 'V';
        insert cdl1;
        
        contentVersion_2.Checksum__c = contentVersion_2.Checksum;
        update contentVersion_2;
        
        //Today's data
        EmailMessage newEmail = new EmailMessage();
        newEmail.FromAddress = 'test@maersk.com';
        newEmail.Incoming = True;
        newEmail.ToAddress= 'test@xyz.org';
        newEmail.Subject = 'Test email';
        newEmail.HtmlBody = 'Test email body';
        newEmail.ParentId = lstCases[1].Id; 
        newEmail.CreatedDate = System.now() - 1;
        insert newEmail;
        
        ContentVersion conver2 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = bodyBlob, 
            origin = 'H',
            CreatedDate = System.now() - 1
        );
        insert conver2;
        
        ContentVersion conver3 = [SELECT Id, Title, ContentDocumentId, checksum FROM ContentVersion WHERE Id = :conver2.Id LIMIT 1];
        
        ContentDocumentLink cdl2 = new ContentDocumentLink();
        cdl2.LinkedEntityId = newEmail.id;
        cdl2.contentdocumentid = conver3.contentdocumentid;
        cdl2.ShareType = 'V';
        insert cdl2;
        
        conver3.Checksum__c = conver3.Checksum;
        update conver3;
        
        Test.startTest();
        BatchDeleteDuplicateEmailMessageFiles batch  =  new BatchDeleteDuplicateEmailMessageFiles(System.today()-1, System.today(), null, '');
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }
    
    public static TestMethod void testSchDuplicateFileDeletionSameBatchCondition(){
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
        
        String str = '';
        for(Integer i=0; i< 1000; i++){
            str += 'Unit Test ContentVersion Body to be insert in test class for testing the';
        }
        
        Blob bodyBlob = Blob.valueOf(str);
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = bodyBlob, 
            origin = 'H',
            CreatedDate = System.now() - 2
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId, checksum, contentsize FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        system.debug('****contentVersion_2-->'+contentVersion_2.contentsize);
        ContentDocumentLink cdl1 = new ContentDocumentLink();
        cdl1.LinkedEntityId = email.id;
        cdl1.contentdocumentid = contentVersion_2.contentdocumentid;
        cdl1.ShareType = 'V';
        insert cdl1;
        
        contentVersion_2.Checksum__c = contentVersion_2.Checksum;
        update contentVersion_2;
        
        //Today's data
        EmailMessage newEmail = new EmailMessage();
        newEmail.FromAddress = 'test@maersk.com';
        newEmail.Incoming = True;
        newEmail.ToAddress= 'test@xyz.org';
        newEmail.Subject = 'Test email';
        newEmail.HtmlBody = 'Test email body';
        newEmail.ParentId = lstCases[1].Id; 
        newEmail.CreatedDate = System.now() - 1;
        insert newEmail;
        
        ContentVersion conver2 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = bodyBlob, 
            origin = 'H',
            CreatedDate = System.now() - 1
        );
        insert conver2;
        
        ContentVersion conver3 = [SELECT Id, Title, ContentDocumentId, checksum FROM ContentVersion WHERE Id = :conver2.Id LIMIT 1];
        
        ContentDocumentLink cdl2 = new ContentDocumentLink();
        cdl2.LinkedEntityId = newEmail.id;
        cdl2.contentdocumentid = conver3.contentdocumentid;
        cdl2.ShareType = 'V';
        insert cdl2;
        
        conver3.Checksum__c = conver3.Checksum;
        update conver3;
        
        Test.startTest();
        BatchDeleteDuplicateEmailMessageFiles batch  =  new BatchDeleteDuplicateEmailMessageFiles(System.today()-1, System.today(), null, '');
        String sch = '0 0 2 * * ?';
        String jobID = system.schedule('BatchDeleteDuplicateEmailMessageFilesTest', sch, batch);
        Test.stopTest();
    }
    
}