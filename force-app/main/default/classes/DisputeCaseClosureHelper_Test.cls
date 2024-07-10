@isTest
public class DisputeCaseClosureHelper_Test {
    
    public static Geography__c countryIN, citySterling;
    
    @isTest
    public static void test_validateParentDISPCaseClosure(){
        TriggerExecutionController.skipAllTriggers(true);
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 3;
        CaseData_Test.conInstance = conInstance;
        
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createDisputecases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        TriggerExecutionController.skipAllTriggers(false);
        insert lstCases; 
        
        List<case> parentCase = [select Id,status from case where Id =: lstCases[0].Id]; 
        List<Case> childList = [select Id, ParentId from Case where Id in(:lstCases[1].Id,:lstCases[2].Id)];
        for(Case cs : childlist){
            cs.parentId = parentCase[0].Id;
        }
        update childList;
        
        Case cs = [select Id,status from Case where Id = :childList[0].ParentId ];
        system.assertNotEquals(cs.status, 'Closed - Resolved');     
    }
    
    @isTest
    public static void test_updateParentDISPCaseStatus(){
        TriggerExecutionController.skipAllTriggers(true);
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 3;
        CaseData_Test.conInstance = conInstance;
        
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createDisputecases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        TriggerExecutionController.skipAllTriggers(false);
        insert lstCases; 
        
        Case parentCase = [select Id,status from case where Id =: lstCases[0].Id];
        parentCase.Bulk_Dispute__c = 'True';
        parentCase.Disputed_Invoice_Number__c = '';
        update parentCase;
        
        List<Case> childList = [select Id, ParentId from Case where Id in(:lstCases[1].Id,:lstCases[2].Id)];
        for(Case cs : childlist){
            cs.parentId = parentCase.Id;
            cs.status = 'Closed - Resolved';
        }  
        
        test.startTest();
        update childList;
        test.StopTest();
        
        Case c = [select Id,status from Case where Id = :parentCase.Id ];
        system.assertEquals(c.status, 'Closed - Resolved');
    }
    
    @isTest
    public static void testDisputeEmailNotificationPayer(){
        TriggerExecutionController.skipAllTriggers(true);
        countryIN = new Geography__c(Name = 'India', GEO_Code__c = 'IN', GEO_ID__c = '10Z2W9Zkjh3q4a3', Type_Of_Location__c = 'Country', Active__c = true);
        insert countryIN;
        Account accIterator = new Account();
        accIterator.Name = 'Test Account_' + Math.round(Math.random()*1000);
        accIterator.Country__c = countryIN.Id;
        //accIterator.City_Name__c = BDAGeographyData_Test.citySterling.Id;
        //accIterator.BillingCity = citySterling.Name;
        insert accIterator;     
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.accountid=accIterator.id;
        update conInstance;
        Case caseIterator = new Case();
        caseIterator.Description = 'CaseTestData Description_';
        caseIterator.Thread_topic__c = 'Test'; // RQ-004464 
        caseIterator.ContactId = conInstance.Id;
        caseIterator.AccountId = conInstance.AccountId;
        caseIterator.Status = 'New';
        caseIterator.Type = 'Charges, Invoice & Payment';
        caseIterator.Sub_Type__c = 'Dispute';
        caseIterator.Country__c = accIterator.Country__c;
        caseIterator.Direction__c = 'Export';
        caseIterator.Case_Channel__c = 'E-mail';
        caseIterator.Status = 'Closed - Not a case';
        caseIterator.OwnerId = userinfo.getUserId();
        caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        caseIterator.Product__c = '4PL';
        caseIterator.RecordTypeId = StaticFactory.getRecordTypeIdByName('Case', 'Dispute');
        caseIterator.Subject = 'Test';
        caseIterator.SuppliedEmail = 'test@gmail.com';
        caseIterator.BusinessHoursId = '01mD0000000XzBlIAK';  
        caseIterator.Case_Visibility__c = 'All Users';
        caseIterator.Disputed_Invoice_Number__c = '1234567891'; 
        caseIterator.Department__c = 'Disputes';
        caseIterator.Invoice_Type__c = 'Export D&D';
        caseIterator.Nature_of_Dispute_case__c = 'InCorrect Rates';
        insert  caseIterator;
        list<Case> lstCases = new list<Case>();
        lstCases.add(caseIterator);
        TriggerExecutionController.skipAllTriggers(false);
        
        Test.StartTest();
        lstCases[0].RecordTypeId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
        lstCases[0].Dispute_Email_Trigger_Condition__c = 'Payer';
        lstCases[0].Case_Channel__c = 'E-mail';
        lstCases[0].Product__c = 'Ocean'; 
        lstCases[0].Type = 'Cargo/Container'; 
        lstCases[0].Sub_Type__c = 'Container Status';
        lstCases[0].Reason_For_Case__c = 'Container Maritime Tracking Request';
        update lstCases;
        Test.StopTest();
    }
    
    @isTest
    public static void testDisputeEmailNotification(){
        TriggerExecutionController.skipAllTriggers(true);
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 3;
        CaseData_Test.conInstance = conInstance;
        
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createDisputecases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        TriggerExecutionController.skipAllTriggers(false);
        insert lstCases; 
        
        lstCases[0].Dispute_Email_Trigger_Condition__c = 'Credit Note';
        lstCases[0].Status = 'Closed - Not a case';
        lstCases[0].Case_Channel__c = 'E-mail';
        update lstCases;      
    } 
    
    @isTest
    public static void testDisputeEmailNotificationAccept(){
        TriggerExecutionController.skipAllTriggers(true);
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 3;
        CaseData_Test.conInstance = conInstance;
        
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createDisputecases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        TriggerExecutionController.skipAllTriggers(false);
        insert lstCases; 
        
        Test.StartTest();        
        lstCases[0].Dispute_Email_Trigger_Condition__c = 'Acceptance';
        lstCases[0].Case_Channel__c = 'E-mail';
        update lstCases;
        Test.StopTest();
    } 
    
}