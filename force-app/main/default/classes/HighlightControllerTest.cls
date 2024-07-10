@isTest
public class HighlightControllerTest {
    
    @isTest
    public static void testGetRecordHighlights(){
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        CaseData_Test.conInstance = conInstance;
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {  
            caseIterator.recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('External_Case').getRecordTypeId();
            caseIterator.Direction__c = 'Export';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Documentation'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Amend SI/BL/VC';
            caseIterator.Case_Channel__c ='E-mail';
        }
        TriggerExecutionController.skipCaseTrigger(true);
        insert lstCases;
        TriggerExecutionController.skipCaseTrigger(false);
        
        HighlightController.getRecordHighlights(lstCases[0].Id);
        HighlightController.getRecordHighlights(lstCases[0].Id);
    }
    
    @isTest
    public static void testHighlightsWithExistingUserHighlight(){
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        CaseData_Test.conInstance = conInstance;
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {  
            caseIterator.recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('External_Case').getRecordTypeId();
            caseIterator.Direction__c = 'Export';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Documentation'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Amend SI/BL/VC';
            caseIterator.Case_Channel__c ='E-mail';
        }
        TriggerExecutionController.skipCaseTrigger(true);
        insert lstCases;
        TriggerExecutionController.skipCaseTrigger(false);
        
        Highlight__c hRec = new Highlight__c();
        hRec.Agent_Name__c = UserInfo.getUserId();
        hRec.Object_Name__c = 'Case';
        hRec.Record_Type__c = 'External_Case';
        hRec.Selected_Fields__c = 'CaseNumber';
        insert hRec;
        
        HighlightController.getRecordHighlights(lstCases[0].Id);
        HighlightController.saveHighlightDetails('Case', 'External_Case', 'CaseNumber,AccountId,ContactId,Status');
    }
    
    @isTest
    public static void testHighlightsWithoutExistingUserHighlight(){
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        CaseData_Test.conInstance = conInstance;
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {  
            caseIterator.recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('External_Case').getRecordTypeId();
            caseIterator.Direction__c = 'Export';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Documentation'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Amend SI/BL/VC';
            caseIterator.Case_Channel__c ='E-mail';
        }
        TriggerExecutionController.skipCaseTrigger(true);
        insert lstCases;
        TriggerExecutionController.skipCaseTrigger(false);
        
        HighlightController.getRecordHighlights(lstCases[0].Id);
        HighlightController.saveHighlightDetails('Case', 'External_Case', 'CaseNumber,AccountId,ContactId,Status');
    }
    
}