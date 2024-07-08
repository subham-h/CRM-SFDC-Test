/*
* Author    : Ranjan
* Purpose   : Test class for ExtDataSourceUtility
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-5245     20-Jan-2023 Ranjan@Maersk            Created. 
* 
*
*/
@isTest(SeeAllData=false)
public with sharing class ExtDataSourceUtility_Test {
    static testMethod void test_globalError() { 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CaseRelatedObjDataSourceProviderMock());
        ExtDataSourceUtility.getGlobalErrorLogger( 'strSourceSystem', 'strObjectName', 'strMethodName', 'strExceptionCode','strExceptionSummary','strExceptionDetails');
        DataSource.QueryContext context = new DataSource.QueryContext();
        context.tableSelection = new DataSource.TableSelection();
        context.tableSelection.tableSelected = 'casehistoryarchival';
        context.tableSelection.filter = new DataSource.Filter();
        context.tableSelection.filter.columnName = 'SfId';
        context.tableSelection.filter.columnValue = '012345678919';
        context.tableSelection.filter.type = DataSource.FilterType.EQUALS;

        CaseRelatedObjectsDataSourceConnection aConnObj = new CaseRelatedObjectsDataSourceConnection (null);
        DataSource.TableResult tableObj=aConnObj.query(context);

        Test.stopTest();
        ExtDataSourceUtility.createInfoErrRec( 'strSourceSystem', 'strObjectName', 'strMethodName', 'strExceptionCode','strExceptionSummary');
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
        cdl.LinkedEntityId = lstCases[0].id;
        cdl.contentdocumentid = contentVersion_2.contentdocumentid;
        cdl.ShareType = 'V';
        cdList.add(cdl);
        
        insert cdList;
        Map<Id, Archived_case__c> mapOldNewArchIds=new Map<Id, Archived_case__c> ();
        mapOldNewArchIds.put(lstCases[0].id,lstArchivedCases[0]);
        ExtDataSourceUtility.createContentDocLinks(mapOldNewArchIds);
    }
}