@isTest(SeeAllData=false)
private class Batch_ArchivedCaseDeleteBatch_Test {
    
     static testMethod void test_one_time_delete(){
          Id extCaseRTId = Schema.SObjectType.Archived_Case__c.getRecordTypeInfosByDeveloperName().get('External_Case').getRecordTypeId();
          Odata_Batch_Archived_Case_Delete__mdt One_Time_second=[select id,start_date__c,end_date__c from Odata_Batch_Archived_Case_Delete__mdt where DeveloperName in ('One_Time')];
          list<Archived_Case__c> lstArchivedCases = new list<Archived_Case__c>();
          Archived_Case__c archCase = new Archived_Case__c();
          archCase.Subject__c = 'CaseTestData Subject_';
          archCase.Description__c = 'CaseTestData Description_'; 
          archCase.Thread_topic__c = 'Test'; 
          archCase.Status__c = 'Closed - Resolved'; 
          archCase.Type__c = 'Prior To Booking'; 
          archCase.Sub_Type__c = 'Cargo Restrictions/Support Enquiry'; 
          archCase.Country__c = BDAGeographyData_Test.countryUK.Id; 
          archCase.Cargo_Classification__c ='US Military (USM)'; 
          archCase.Liner_Brand__c = brandutilities.MAERSK; 
          archCase.Direction__c = 'Export'; 
          archCase.Case_Channel__c = 'Chat'; 
          archCase.SuppliedEmail__c = Null; 
          archCase.Case_Origin__c = 'MSLUSEXP'; 
          archCase.Case_Visibility__c = 'All Users'; 
          archCase.RecordTypeId= extCaseRTId; 
          archCase.Resolution_Summary__c='test'; 
          archCase.Reason_For_Case__c='Cargo Restriction/Information Not Received'; 
          archCase.MLL__c=false; 
          archCase.createddate=One_Time_second.start_date__c; 
          archCase.createddate__c=One_Time_second.start_date__c; 
          archCase.Security_Code__c='test';
          lstArchivedCases.add(archCase);
          insert lstArchivedCases;
          
          
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
          cdl.LinkedEntityId = lstArchivedCases[0].id;
          cdl.contentdocumentid = contentVersion_2.contentdocumentid;
          cdl.ShareType = 'V';
          cdList.add(cdl);
          
          insert cdList;
          Agent_Workflow__c AW1 = new Agent_Workflow__c( Status__c = 'Approved',Sender_Email__c = 'test@test.com',Archived_Case__c = lstArchivedCases[0].Id );
          insert AW1;
          
          External_Party__c ep = new External_Party__c(); 
          ep.Archived_Case__c = lstArchivedCases[0].Id;
          insert ep;
          
          Activity_Related_Reference__c activity1 = new Activity_Related_Reference__c();
          activity1.AIR_Other_References__c= 'test123';
          activity1.Archived_Case__c = lstArchivedCases[0].Id;
          insert activity1;
          
          Equipment_Commodity__c ec= new Equipment_Commodity__c();
          ec.Archived_Case__c=lstArchivedCases[0].Id;
          insert ec;

          Test.setMock(HttpCalloutMock.class, new CaseRelatedObjDataSourceProviderMock());
          Test.startTest();
          List<Archived_Case__c> archCaseList = [select id from Archived_Case__c]; 
          System.debug('Assert'+archCaseList);
          System.assert(archCaseList!=NULL && !archCaseList.isEmpty());
          Batch_ArchivedCaseDeleteBatch batchDelete = new Batch_ArchivedCaseDeleteBatch('One_Time',50);
          database.executeBatch(batchDelete);
          Test.stopTest();
          List<Archived_Case__c> archCaseDelList = [select id from Archived_Case__c];
          System.debug('Before Assert'+archCaseDelList);
          System.assert(archCaseDelList==NULL || archCaseDelList.isEmpty());
     }
     static testMethod void test_backlog_delete(){
          Id extCaseRTId = Schema.SObjectType.Archived_Case__c.getRecordTypeInfosByDeveloperName().get('External_Case').getRecordTypeId();
          Odata_Batch_Archived_Case_Delete__mdt One_Time_second=[select id,start_date__c,end_date__c from Odata_Batch_Archived_Case_Delete__mdt where DeveloperName in ('One_Time')];
          list<Archived_Case__c> lstArchivedCases = new list<Archived_Case__c>();
          Archived_Case__c archCase = new Archived_Case__c();
          archCase.Subject__c = 'CaseTestData Subject_';
          archCase.Description__c = 'CaseTestData Description_'; 
          archCase.Thread_topic__c = 'Test'; 
          archCase.Status__c = 'Closed - Resolved'; 
          archCase.Type__c = 'Prior To Booking'; 
          archCase.Sub_Type__c = 'Cargo Restrictions/Support Enquiry'; 
          archCase.Country__c = BDAGeographyData_Test.countryUK.Id; 
          archCase.Cargo_Classification__c ='US Military (USM)'; 
          archCase.Liner_Brand__c = brandutilities.MAERSK; 
          archCase.Direction__c = 'Export'; 
          archCase.Case_Channel__c = 'Chat'; 
          archCase.SuppliedEmail__c = Null; 
          archCase.Case_Origin__c = 'MSLUSEXP'; 
          archCase.Case_Visibility__c = 'All Users'; 
          archCase.RecordTypeId= extCaseRTId; 
          archCase.Resolution_Summary__c='test'; 
          archCase.Reason_For_Case__c='Cargo Restriction/Information Not Received'; 
          archCase.MLL__c=false; 
          archCase.createddate=One_Time_second.start_date__c; 
          archCase.createddate__c=One_Time_second.start_date__c; 
          archCase.Security_Code__c='test';
          lstArchivedCases.add(archCase);
          insert lstArchivedCases;

          Odata_Batch_Case_Archiver__mdt chainedbatch=[select id,start_date__c,end_date__c,Number_Of_Hours__c,Is_Chained_From_Email_Batch__c from Odata_Batch_Case_Archiver__mdt where DeveloperName in ('Chained_From_Email_Batch_Dont_Modify')];
          Id extCaseRTId1 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('External_Case').getRecordTypeId();
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
          caseIterator.RecordTypeId= extCaseRTId1;
          caseIterator.Resolution_Summary__c='test';
          caseIterator.Reason_For_Case__c='Cargo Restriction/Information Not Received';
          caseIterator.MLL__c=false;
          caseIterator.createddate=chainedbatch.start_date__c;
          caseIterator.Security_Code__c='test';
          lstCases.add(caseIterator);
          insert lstCases;
          
          
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
          cdl.LinkedEntityId = lstArchivedCases[0].id;
          cdl.contentdocumentid = contentVersion_2.contentdocumentid;
          cdl.ShareType = 'V';
          cdList.add(cdl);
          
          insert cdList;
          
     
          Survey__c svy = new Survey__c();
          svy.Archived_Case__c = lstArchivedCases[0].Id;
          svy.Case__c=lstCases[0].Id;
          svy.RecordTypeId = Schema.SObjectType.Survey__c.getRecordTypeInfosByDeveloperName().get('Case_Survey').getRecordTypeId();
          svy.Case_Security_Code__c = lstCases[0].Security_Code__c;
          insert svy;
          
          Agent_Workflow__c AW1 = new Agent_Workflow__c( Status__c = 'Approved',Sender_Email__c = 'test@test.com',Archived_Case__c = lstArchivedCases[0].Id );
          insert AW1;
          
          External_Party__c ep = new External_Party__c(); 
          ep.Archived_Case__c = lstArchivedCases[0].Id;
          insert ep;
          
          Activity_Related_Reference__c activity1 = new Activity_Related_Reference__c();
          activity1.AIR_Other_References__c= 'test123';
          activity1.Archived_Case__c = lstArchivedCases[0].Id;
          insert activity1;
          
          Equipment_Commodity__c ec= new Equipment_Commodity__c();
          ec.Archived_Case__c=lstArchivedCases[0].Id;
          insert ec;
     
          Test.setMock(HttpCalloutMock.class, new CaseRelatedObjDataSourceProviderMock());
          Test.startTest();
          List<Archived_Case__c> archCaseList = [select id from Archived_Case__c]; 
          System.debug('Assert'+archCaseList);
          System.assert(archCaseList!=NULL && !archCaseList.isEmpty());
          ArchivedCaseDeleter.initiateScheduledArchivalCaseDeleter('', '', 50); 
          Test.stopTest();
     }
     static testMethod void test_backlog_delwithoutSize(){
          Id extCaseRTId = Schema.SObjectType.Archived_Case__c.getRecordTypeInfosByDeveloperName().get('External_Case').getRecordTypeId();
          Odata_Batch_Archived_Case_Delete__mdt One_Time_second=[select id,start_date__c,end_date__c from Odata_Batch_Archived_Case_Delete__mdt where DeveloperName in ('One_Time')];
          list<Archived_Case__c> lstArchivedCases = new list<Archived_Case__c>();
          Archived_Case__c archCase = new Archived_Case__c();
          archCase.Subject__c = 'CaseTestData Subject_';
          archCase.Description__c = 'CaseTestData Description_'; 
          archCase.Thread_topic__c = 'Test'; 
          archCase.Status__c = 'Closed - Resolved'; 
          archCase.Type__c = 'Prior To Booking'; 
          archCase.Sub_Type__c = 'Cargo Restrictions/Support Enquiry'; 
          archCase.Country__c = BDAGeographyData_Test.countryUK.Id; 
          archCase.Cargo_Classification__c ='US Military (USM)'; 
          archCase.Liner_Brand__c = brandutilities.MAERSK; 
          archCase.Direction__c = 'Export'; 
          archCase.Case_Channel__c = 'Chat'; 
          archCase.SuppliedEmail__c = Null; 
          archCase.Case_Origin__c = 'MSLUSEXP'; 
          archCase.Case_Visibility__c = 'All Users'; 
          archCase.RecordTypeId= extCaseRTId; 
          archCase.Resolution_Summary__c='test'; 
          archCase.Reason_For_Case__c='Cargo Restriction/Information Not Received'; 
          archCase.MLL__c=false; 
          archCase.createddate=One_Time_second.start_date__c; 
          archCase.createddate__c=One_Time_second.start_date__c; 
          archCase.Security_Code__c='test';
          lstArchivedCases.add(archCase);
          insert lstArchivedCases;

          Odata_Batch_Case_Archiver__mdt chainedbatch=[select id,start_date__c,end_date__c,Number_Of_Hours__c,Is_Chained_From_Email_Batch__c from Odata_Batch_Case_Archiver__mdt where DeveloperName in ('Chained_From_Email_Batch_Dont_Modify')];
          Id extCaseRTId1 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('External_Case').getRecordTypeId();
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
          caseIterator.RecordTypeId= extCaseRTId1;
          caseIterator.Resolution_Summary__c='test';
          caseIterator.Reason_For_Case__c='Cargo Restriction/Information Not Received';
          caseIterator.MLL__c=false;
          caseIterator.createddate=chainedbatch.start_date__c;
          caseIterator.Security_Code__c='test';
          lstCases.add(caseIterator);
          insert lstCases;
          
          
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
          cdl.LinkedEntityId = lstArchivedCases[0].id;
          cdl.contentdocumentid = contentVersion_2.contentdocumentid;
          cdl.ShareType = 'V';
          cdList.add(cdl);
          
          insert cdList;
          
     
          Survey__c svy = new Survey__c();
          svy.Archived_Case__c = lstArchivedCases[0].Id;
          svy.Case__c=lstCases[0].Id;
          svy.RecordTypeId = Schema.SObjectType.Survey__c.getRecordTypeInfosByDeveloperName().get('Case_Survey').getRecordTypeId();
          svy.Case_Security_Code__c = lstCases[0].Security_Code__c;
          insert svy;
          
          Agent_Workflow__c AW1 = new Agent_Workflow__c( Status__c = 'Approved',Sender_Email__c = 'test@test.com',Archived_Case__c = lstArchivedCases[0].Id );
          insert AW1;
          
          External_Party__c ep = new External_Party__c(); 
          ep.Archived_Case__c = lstArchivedCases[0].Id;
          insert ep;
          
          Activity_Related_Reference__c activity1 = new Activity_Related_Reference__c();
          activity1.AIR_Other_References__c= 'test123';
          activity1.Archived_Case__c = lstArchivedCases[0].Id;
          insert activity1;
          
          Equipment_Commodity__c ec= new Equipment_Commodity__c();
          ec.Archived_Case__c=lstArchivedCases[0].Id;
          insert ec;
     
          Test.setMock(HttpCalloutMock.class, new CaseRelatedObjDataSourceProviderMock());
          Test.startTest();
          List<Archived_Case__c> archCaseList = [select id from Archived_Case__c]; 
          System.debug('Assert'+archCaseList);
          System.assert(archCaseList!=NULL && !archCaseList.isEmpty());
          System.schedule('Batch Archived Case Deleter Test', '0 0 19 ? * *', new Scheduler_BatchArchivedCaseDeleteBatch());
          Test.stopTest();
     }
}