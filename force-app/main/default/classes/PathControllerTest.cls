@isTest
public class PathControllerTest {
    
    @isTest
    public static void testKeyFields(){
        PathController.getPathKeyFields('Case', 'External_Case');
    }
    
    @isTest
    public static void testExceptionFields(){
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
        insert lstCases;
        PathController.getExceptionFields(lstCases[0].Id, 'Case', 'External_Case');
    }

}