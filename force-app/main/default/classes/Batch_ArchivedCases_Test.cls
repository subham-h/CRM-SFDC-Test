@isTest
public class Batch_ArchivedCases_Test{
    static testMethod void one_time_second() {  
        Odata_Batch_Case_Archiver__mdt One_Time_second=[select id,start_date__c,end_date__c,Is_Chained_From_Email_Batch__c from Odata_Batch_Case_Archiver__mdt where DeveloperName in ('One_Time_second')];
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
        caseIterator.createddate=One_Time_second.start_date__c;
        lstCases.add(caseIterator);
        insert lstCases;
        EmailMessage em = new EmailMessage();
        em.parentId=lstCases[0].id;
        insert em;
        Test.startTest();
        
        Batch_ArchivedCases bc = new Batch_ArchivedCases('One_Time_second',1);
        //database.executeBatch(bc);
        Database.executeBatch(new Batch_EmailMessageExtArchiver('One_Time_second',50),50);
        Batch_ArchivedCases bc_chain = new Batch_ArchivedCases('Chained_From_Email_Batch_Dont_Modify',1);
        database.executeBatch(bc_chain);
        System.schedule('Batch Case Archival Test', '0 0 19 ? * *', new Scheduler_Batch_ArchivedCases());
        
        Test.stopTest();
    }
    
    static testMethod void Chained_From_Email_Batch_Dont_Modify() {  
        Odata_Batch_Case_Archiver__mdt chainedbatch=[select id,start_date__c,end_date__c,Number_Of_Hours__c,Is_Chained_From_Email_Batch__c from Odata_Batch_Case_Archiver__mdt where DeveloperName in ('Chained_From_Email_Batch_Dont_Modify')];
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
        
        list<Case> lstCases1 = new list<Case>();        
        Case caseIterator1 = new Case();
        caseIterator1.Subject = 'CaseTestData Subject_';
        caseIterator1.Description = 'CaseTestData Description_';
        caseIterator1.Thread_topic__c = 'Test';            
        caseIterator1.Status = 'New';
        caseIterator1.Type = 'Prior To Booking';
        caseIterator1.Sub_Type__c = 'Cargo Restrictions/Support Enquiry';
        caseIterator1.Country__c = BDAGeographyData_Test.countryUK.Id;
        caseIterator1.Cargo_Classification__c ='US Military (USM)';
        caseIterator1.Liner_Brand__c = brandutilities.MAERSK;
        caseIterator1.Direction__c = 'Export';
        caseIterator1.Case_Channel__c = 'Chat';
        caseIterator1.SuppliedEmail = Null;
        caseIterator1.Origin = 'MSLUSEXP';
        caseIterator1.Case_Visibility__c = 'All Users';
        caseIterator1.RecordTypeId= extCaseRTId;
        caseIterator1.Resolution_Summary__c='test';
        caseIterator1.Reason_For_Case__c='Cargo Restriction/Information Not Received';
        caseIterator1.MLL__c=false;
        caseIterator1.createddate=chainedbatch.start_date__c;
        caseIterator1.Security_Code__c='test';
        lstCases1.add(caseIterator1);
        insert lstCases1;
        
        Survey__c svy = new Survey__c(); 
        svy.Case__c = lstCases[0].Id;
        svy.RecordTypeId = Schema.SObjectType.Survey__c.getRecordTypeInfosByDeveloperName().get('Case_Survey').getRecordTypeId();
        svy.Case_Security_Code__c = lstCases[0].Security_Code__c;
        insert svy;
        
        Agent_Workflow__c AW1 = new Agent_Workflow__c( Status__c = 'Approved',Sender_Email__c = 'test@test.com',Case_ID__c = lstCases1[0].Id );
        insert AW1;
        
        External_Party__c ep = new External_Party__c(); 
        ep.Claim__c = lstCases[0].Id;
        insert ep;
        
        Activity_Related_Reference__c activity1 = new Activity_Related_Reference__c();
        activity1 .AIR_Other_References__c= 'test123';
        activity1.case__c = lstCases[0].Id;
        insert activity1;
        
        Equipment_Commodity__c ec= new Equipment_Commodity__c();
        ec.Claim__c=lstCases[0].Id;
        insert ec;
        
        Test.startTest();
        Batch_ArchivedCases bc_chain = new Batch_ArchivedCases('Chained_From_Email_Batch_Dont_Modify',1);
        database.executeBatch(bc_chain);
        Test.stopTest();
    }
    
    static testMethod void test_Scheduler_Batch_ArchivedCases() {  
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
        lstCases.add(caseIterator);
        insert lstCases;
        lstCases[0].Status = 'Closed - Resolved';
        update lstCases;
        Test.startTest();
        System.schedule('Batch Case Archival Test', '0 0 19 ? * *', new Scheduler_Batch_ArchivedCases(50));
        Test.stopTest();
    }
}