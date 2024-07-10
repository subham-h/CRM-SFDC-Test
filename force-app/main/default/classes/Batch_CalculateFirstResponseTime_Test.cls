/**
* Purpose  : Test Batch_CalculateFirstResponseTime4PL. 
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-4507   
 * 2.0      SPI-100     27-06-2022  Ronnie@SF               Removed brand hardcoding
*/
@isTest(SeeAllData=false)
public class Batch_CalculateFirstResponseTime_Test {
    
    @testSetup static void DataSetUp() 
    {
        //BatchEmailMessageArchiverData_Test.createTestData();
        
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        Case caseIterator = new Case();
        caseIterator.Description = 'CaseTestData Description_';
        caseIterator.Thread_topic__c = 'Test'; // RQ-004464 
        caseIterator.ContactId = conInstance.Id;
        caseIterator.AccountId = conInstance.AccountId;
        caseIterator.Status = 'New';
        caseIterator.Type = 'Carrier Booking';
        caseIterator.Sub_Type__c = 'New Booking Request';
        caseIterator.Country__c = conInstance.Country__c;
        caseIterator.Cargo_Classification__c ='US Military (USM)';
        caseIterator.Direction__c = 'Export';
        caseIterator.Case_Channel__c = 'Portal';
        caseIterator.Status = 'Closed - Not a case';
        caseIterator.OwnerId = userinfo.getUserId();
        caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLS;
        caseIterator.Product__c = '4PL';
        caseIterator.RecordTypeId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
        caseIterator.Subject = 'Test Case_CaseTestData.generateTestRecord';
        caseIterator.SuppliedEmail = 'aravinda@gmail.com';
        caseIterator.BusinessHoursId = '01mD0000000XzBlIAK';  
       
        insert  caseIterator;
     
        Datetime lastday = Datetime.now().addDays(-2);
        Test.setCreatedDate(caseIterator.Id, lastday);
        
        Set<id> setCaseId = new set<id>();
        setCaseId.add(caseIterator.id);
        TriggerExecutionController.skipCaseTrigger(false);
        
        Attachment testAttachment = new Attachment(Name = 'Test Image', Body = Blob.valueOf('Test Image'), ParentId = caseIterator.Id);
        insert testAttachment;
        
        list<EmailMessage> lstEmailMessages = new list<EmailMessage>();
        lstEmailMessages.add(new EmailMessage(FromAddress = 'test@lns.maersk.com', Incoming = false, ToAddress = 'hello@maersk.salesforce.com', Subject = 'Test email', Status = '0', TextBody = 'Sample Text', ParentId = caseIterator.Id)); 
        lstEmailMessages.add(new EmailMessage(FromAddress = 'test@lns.maersk.com', Incoming = True, ToAddress = 'hello@maersk.salesforce.com', Subject = 'Test email', Status = '0', HtmlBody = '<meta content="text/html; charset=utf-8" http-equiv="Content-Type"><b>Sample Text</b><img src="https://maersk.my.salesforce.com/servlet/servlet.FileDownload?file=' + testAttachment.Id + '">', ParentId = caseIterator.Id)); 
        lstEmailMessages.add(new EmailMessage(FromAddress = 'test@lns.maersk.com', Incoming = True, ToAddress = 'hello@maersk.salesforce.com', Subject = 'Test email', Status = '0', TextBody = '<b>Sample Text</b>', ParentId = caseIterator.Id)); 
        insert lstEmailMessages;

        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(lstEmailMessages[0].Id, yesterday);
        
    }
    
    @isTest
    static void test_oneTimeBatchEmailMessageArchiver1() {

        List<Case> caseList = [select Id,Createddate,BusinessHoursId,Agent_First_Response_Time__c,(Select Id,ParentId,FromName, CreatedDate from 
                                EmailMessages where Incoming = false order by createddate asc limit 1) from case where 
                                Case_Channel__c IN ('E-mail', 'Portal') AND SuppliedEmail = 'aravinda@gmail.com'];

        DateTime dt1 = caseList[0].EmailMessages[0].CreatedDate;
        DateTime dt2 = caseList[0].CreatedDate;
        
      //  Long difference = BusinessHours.diff(caseList[0].BusinessHoursId, dt2, dt1);
      //  Long minutes = difference/60000;
        
         Decimal difference = BusinessHours.diff(caseList[0].BusinessHoursId, dt2, dt1);
         Decimal hours = difference/(3600000);
         
        Test.startTest();
         Batch_CalculateFirstResponseTime4PL obj = new Batch_CalculateFirstResponseTime4PL(system.today().addDays(-3),200);
         DataBase.executeBatch(obj); 
        Test.stopTest();
        list<Case> updatecase = [select Id,Createddate,BusinessHoursId,Agent_First_Response_Time__c from Case WHERE Case_Channel__c = 'Portal' AND SuppliedEmail = 'aravinda@gmail.com' Limit 1];
        //system.assertEquals(updatecase[0].Agent_First_Response_Time__c, hours);


    }
    
    @isTest
    static void test_oneTimeBatchEmailMessageArchiver() {

        List<Case> caseList = [select Id,Createddate,BusinessHoursId,Agent_First_Response_Time__c,(Select Id,ParentId,FromName, CreatedDate from 
                                EmailMessages where Incoming = false order by createddate asc limit 1) from case where 
                                Case_Channel__c IN ('E-mail', 'Portal') AND SuppliedEmail = 'aravinda@gmail.com'];

        DateTime dt1 = caseList[0].EmailMessages[0].CreatedDate;
        DateTime dt2 = caseList[0].CreatedDate;
        
       // Long difference = BusinessHours.diff(caseList[0].BusinessHoursId, dt2, dt1);
      //  Long minutes = difference/60000;
        
       Decimal difference = BusinessHours.diff(caseList[0].BusinessHoursId, dt2, dt1);
       Decimal hours = difference/(3600000);  
     
        Test.startTest();
         Batch_CalculateFirstResponseTime4PL obj = new Batch_CalculateFirstResponseTime4PL(null,null);
         DataBase.executeBatch(obj); 
        Test.stopTest();
        list<Case> updatecase = [select Id,Createddate,BusinessHoursId,Agent_First_Response_Time__c from Case WHERE Case_Channel__c = 'Portal' AND SuppliedEmail = 'aravinda@gmail.com' Limit 1];
        //system.assertEquals(updatecase[0].Agent_First_Response_Time__c, minutes);


    }
    
    @isTest
    static void test_oneTimeBatchEmailMessageScheduler() {  

        Test.startTest();
         String sch = '0 25 9 * * ?';
         String jobID = system.schedule('Batch_CalculateFirstResponseTime4PLTest', sch, new Batch_CalculateFirstResponseTime4PL(system.today().addDays(-3),200)); 
         CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];           
        Test.stopTest();

        System.assertEquals(sch, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
   

    }
}