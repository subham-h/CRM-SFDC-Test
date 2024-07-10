/**
 * Test class for RelatedCaseFieldUpdator
 * 
 * Version  Date         Owner                   RQ#           Description
 *******************************************************************************************************************
 * 1.0                                                         Class created
 * 2.0      27/06/2022   Ronnie@SF               SPI-100       Removed brand hardcoding
 */

@isTest
public class RelatedCaseFieldUpdator_Test {
    
    @isTest
    static void testUpdateCaseFields(){
        TriggerExecutionController.skipAllTriggers(true);
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createInternalContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        insert lstCases;
        TriggerExecutionController.skipAllTriggers(false);
        Test.startTest();
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'test@maersk.com', Incoming = True, ToAddress= 'hello@dummy.com', Subject = 'Test email', TextBody = '23456 ', ParentId = lstCases[0].Id,CcAddress='dummy.import@maersk.com'));
        insert newEmail;
        Case caseRec=[Select Id,CC_Flag__c,Priority from case where Id=:lstCases[0].Id];
        system.assert(caseRec.Priority=='Low');
        Test.stopTest();
    }
    
    
    @isTest
    static void testUpdateCaseFieldsCase2(){
        TriggerExecutionController.skipAllTriggers(true);
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createInternalContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        insert lstCases;
        TriggerExecutionController.skipAllTriggers(false);
        Test.startTest();
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'test@maersk.com', Incoming = True, ToAddress= 'hello.import@maersk.com', Subject = 'Test email', TextBody = '23456 ', ParentId = lstCases[0].Id,CcAddress='dummy.import@maersk.com'));
        insert newEmail;
        Case caseRec=[Select Id,Count_Emails_To_Internal_Contact__c,Contact.Email,Priority from case where Id=:lstCases[0].Id];
        system.assert(caseRec.Count_Emails_To_Internal_Contact__c>=1);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCaseFieldsCase3(){
        TriggerExecutionController.skipAllTriggers(true);
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createInternalContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        insert lstCases;
        TriggerExecutionController.skipAllTriggers(false);
        Test.startTest();
        case caseRec=[Select Id,contact.email,isClosed from case where Id=:lstCases[0].Id];
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'test@maersk.com', Incoming = false, ToAddress= caseRec.contact.email, Subject = 'Test email', TextBody = '23456 ', ParentId = lstCases[0].Id,CcAddress='dummy.import@maersk.com'));
        insert newEmail;
        case caseAfterUpdate=[select Id,Count_Emails_To_Contact__c from case where Id=:lstCases[0].Id];
        System.assert(caseAfterUpdate.Count_Emails_To_Contact__c>=1);
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testUpdateCaseFieldsCase4(){
        TriggerExecutionController.skipAllTriggers(true);
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createInternalContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        lstCases[0].status='Closed - Not a case';  
        insert lstCases;
        TriggerExecutionController.skipAllTriggers(false);
        Test.startTest();
        case caseRec=[Select Id,contact.email,isClosed from case where Id=:lstCases[0].Id];
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'test@maersk.com', Incoming = true, ToAddress= caseRec.contact.email, Subject = 'Test email', TextBody = '23456 ', ParentId = lstCases[0].Id,CcAddress='dummy.import@maersk.com',CreatedById=System.Label.System_Owner));
        insert newEmail;
        case caseAfterUpdate=[select Id,Count_Emails_To_Contact__c from case where Id=:lstCases[0].Id];
        //System.assert(caseAfterUpdate.Count_Emails_To_Contact__c>=1);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCaseFieldsCase5(){
        TriggerExecutionController.skipAllTriggers(true);
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createInternalContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 3;
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        // To cover SC-2138
        lstCases[0].status='In Progress';  
        lstCases[0].Liner_Brand__c = BrandUtilities.MAERSKLS;
        lstCases[0].Case_Visibility__c='Multi-Carrier';
        lstCases[1].status='In Progress';  
        lstCases[1].Liner_Brand__c = BrandUtilities.MAERSKLS;
        lstCases[1].Case_Visibility__c='Multi-Carrier';
        lstCases[2].status='In Progress';  
        lstCases[2].Liner_Brand__c = BrandUtilities.MAERSKLS;
        lstCases[2].Case_Visibility__c='Multi-Carrier';
        insert lstCases;
        lstCases[1].ParentId = lstCases[0].id; 
        lstCases[0].ParentId = lstCases[2].id; 
        update lstCases;
        TriggerExecutionController.skipAllTriggers(false);
        Test.startTest();
        case caseRec=[Select Id,contact.email,isClosed from case where Id=:lstCases[0].Id];
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'test@lns.maersk.com', Incoming = true, ToAddress= caseRec.contact.email, Subject = 'Test email', TextBody = '23456 ', ParentId = lstCases[0].Id,CcAddress='dummy.import@maersk.com',CreatedById=System.Label.System_Owner));
        insert newEmail;
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCaseFieldsCase6(){
        TriggerExecutionController.skipAllTriggers(true);
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createInternalContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        // To cover SC-2138
        lstCases[0].status='In Progress';  
        lstCases[0].Liner_Brand__c = BrandUtilities.MAERSKLS;
        lstCases[0].Case_Visibility__c='Multi-Carrier';
        lstCases[0].Product__c = 'SCM';
        lstCases[0].Count_Case_Emails__c = 2;
        lstCases[0].Origin = 'SCMGLOBALACT';
        insert lstCases;
        TriggerExecutionController.skipAllTriggers(false);
        Test.startTest();
        
        Custom_Email_Service__c ces = new Custom_Email_Service__c();
        ces.BA_Address__c = 'test.ces@maersk.com';
        ces.Origin__c = 'SCMGLOBALACT';
        ces.Record_Type__c = 'External';
        ces.Active__c = true;
        ces.Queue_Id__c = [Select QueueId From QueueSobject Where SobjectType = 'Task' LIMIT 1].QueueId;
        insert ces;
        
        case caseRec=[Select Id,contact.email,isClosed from case where Id=:lstCases[0].Id];
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'test@lns.maersk.com', Incoming = true, ToAddress= caseRec.contact.email+';test.ces@maersk.com', Subject = 'Test email', TextBody = '23456 ', ParentId = lstCases[0].Id,CcAddress='dummy.import@maersk.com',CreatedById=System.Label.System_Owner));
        insert newEmail;
        Test.stopTest();
    }
    
}