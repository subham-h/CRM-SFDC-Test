/**
 * Author   : Ananth
 * Purpose  : Test class to cover CaseBusinessHours. 
 *        
 * Revision Ref Number  Date         Owner                   Description
 * -------- ----------  -----------  -------------------     -----------
 * 1.0      RQ-002633   22-Feb-2016  Ragu@UST                Created for implementing CBO (Centralized By Org) trigger architecture.
 * 2.0      Rq-008811   10-Aug-2018  Meenakshi@UST           Included Dispute case records to test
 * 3.0      SPI-100     13-Jun-2022  Ronnie@SF               Removed brand hardcoding
 */
 
@isTest
private class CaseBusinessHours_Test {
    
    static testMethod void test_setBusinessHours() {
        CaseData_Test.iNumberOfCases = 4;
        CaseData_Test.bCreate = false;
        CaseData_Test.createExternalCases();
        list<Case> lstExternalCases = CaseData_Test.lstCases;
        
        ContactData_Test.iNumberOfContacts = 3;
        ContactData_Test.createInternalContacts();

        Test.startTest();
        lstExternalCases[0].Status = 'New';
        lstExternalCases[1].Status = 'Triaged';
        lstExternalCases[1].ContactId = ContactData_Test.lstContacts[0].Id;
        lstExternalCases[1].Liner_Brand__c = BrandUtilities.MAERSKLINE;
        
        lstExternalCases[2].Status = 'New';
        lstExternalCases[2].Liner_Brand__c = BrandUtilities.MAERSKLINE;
        lstExternalCases[2].ContactId = ContactData_Test.lstContacts[1].Id;
        lstExternalCases[2].MLL__c = true;
        lstExternalCases[2].Cargo_Classification__c = 'US Military (USM)';
        
        lstExternalCases[3].Status = 'Qualified';
        lstExternalCases[3].Liner_Brand__c = BrandUtilities.USFLAG;
        lstExternalCases[3].ContactId = ContactData_Test.lstContacts[2].Id;
        lstExternalCases[3].Cargo_Classification__c = 'US Military (USM)';
        lstExternalCases[3].MLL__c = true;
    
        Geography__c cityUS = new Geography__c();
        cityUS.Name = 'Sterling';
        cityUS.Type_Of_Location__c = 'City';
        cityUS.GEO_ID__c = '0VHW5VGS4HJ0F';
        insert cityUS;
        lstExternalCases[3].city__c=cityUs.id;
                
        BDA__c BDAS = new BDA__c();
        BDAS.Name = 'US Region';
        BDAS.GEO_ID__c = '22ad321ww222';
        BDAS.Type__c = 'Trade Region'; 
        insert BDAS;
        lstExternalCases[3].cluster__c=BDAS.id;

        try {
            Database.insert(lstExternalCases);
        }
        catch(exception e){ }
        Test.stopTest();
    }
    
    static testMethod void test_setBusinessHoursDispute() {
        CaseData_Test.iNumberOfCases = 4;
        CaseData_Test.bCreate = false;
        CaseData_Test.createDisputecases();
        list<Case> lstDisputeCases = CaseData_Test.lstCases;
        
        ContactData_Test.iNumberOfContacts = 3;
        ContactData_Test.createCustomerContacts();

        Test.startTest();
        lstDisputeCases[0].Status = 'New';
        lstDisputeCases[1].Status = 'Triaged';
        lstDisputeCases[1].ContactId = ContactData_Test.lstContacts[0].Id;
        lstDisputeCases[1].Liner_Brand__c = BrandUtilities.MAERSKLINE;
        
        lstDisputeCases[2].Status = 'New';
        lstDisputeCases[2].Liner_Brand__c = BrandUtilities.MAERSKLINE;
        lstDisputeCases[2].ContactId = ContactData_Test.lstContacts[1].Id;
        lstDisputeCases[2].MLL__c = true;
        lstDisputeCases[2].Cargo_Classification__c = 'US Military (USM)';
        
        lstDisputeCases[3].Status = 'Qualified';
        lstDisputeCases[3].Liner_Brand__c = BrandUtilities.USFLAG;
        lstDisputeCases[3].ContactId = ContactData_Test.lstContacts[2].Id;
        lstDisputeCases[3].Cargo_Classification__c = 'US Military (USM)';
        lstDisputeCases[3].MLL__c = true;
    
        Geography__c cityUS = new Geography__c();
        cityUS.Name = 'Sterling';
        cityUS.Type_Of_Location__c = 'City';
        cityUS.GEO_ID__c = '0VHW5VGS4HJ0F';
        insert cityUS;
        lstDisputeCases[3].city__c=cityUs.id;
                
        BDA__c BDAS = new BDA__c();
        BDAS.Name = 'US Region';
        BDAS.GEO_ID__c = '22ad321ww222';
        BDAS.Type__c = 'Trade Region'; 
        insert BDAS;
        lstDisputeCases[3].cluster__c=BDAS.id;

        try {
            Database.insert(lstDisputeCases);
        }
        catch(exception e){ }
        Test.stopTest();   
    }
}