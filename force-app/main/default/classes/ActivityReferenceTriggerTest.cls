@isTest
public class ActivityReferenceTriggerTest{
    
    public static testMethod void test_populateFieldsOnBeforeInsertUpdate() {
        TriggerExecutionController.skipAllTriggers(true);
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        
        list<Case> lstCases = new list<Case>();
        
        CaseData_Test.createClaimCases();
        lstCases.addAll(CaseData_Test.lstCases);
        insert lstCases;        
        TriggerExecutionController.skipAllTriggers(false);
        Activity_Related_Reference__c activity1 = new Activity_Related_Reference__c();
        activity1 .AIR_Other_References__c= 'test123';
        activity1.case__c = lstCases[0].Id;
        insert activity1;
        
        Test.startTest();
        try{
            Activity_Related_Reference__c activity2 = new Activity_Related_Reference__c();
            activity2 .AIR_Other_References__c = 'test123';
            activity2.case__c = lstCases[0].Id;
            insert activity2;
        }catch(Exception ex){
            Assert.isTrue(ex.getMessage().contains('Cannot create Activity Related Reference. Case can have only one Activity Related Reference'));
        }
        Test.stopTest();
    }
    
}