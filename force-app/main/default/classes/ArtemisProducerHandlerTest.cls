/*
* Author   : Vivek 
* Purpose  : Utility test class for Artemis Producer Handler functionalities 
*
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------

*/

@isTest
public class ArtemisProducerHandlerTest {
    
    @isTest
     public static void preparePERecordTest() {

         TriggerExecutionController.skipAllTriggers(true);
         Geography__c geography = TestBusinessHelper.createGeography('Denmark', 'Country', null, true);
        
         Account acc = TestBusinessHelper.createAccount('Unassigned', false);
         acc.Id = null;
         acc.Name = 'Test Account Artemis';
         acc.SCV_Code__c ='331s4019201';
         acc.Country__c = geography.Id;
         insert acc;
         
        Contact conInstance = TestBusinessHelper.createContact(acc, 'Customer_Contact', BrandUtilities.MAERSKLINE, false);
        conInstance.Id = null;
        conInstance.Country__c = acc.Country__c;
        insert conInstance;
         
        Contact conInstance2 =[select id, contact_status__c from contact limit 1];
        conInstance2.Contact_Status__c = 'Inactive';
         
        Case cs = TestBusinessHelper.createCase(acc, conInstance, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Parent Case Test Booking';
        cs.Description = 'Parent Case Test Booking Description_1';
        cs.Thread_topic__c = 'Test'; // RQ-004464 
        cs.Cargo_Classification__c ='US Military (USM)';
        cs.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        cs.Direction__c = 'Export';
        cs.Case_Channel__c = 'Email';
        cs.Origin = 'TestCaseArtemis';
        cs.Case_Visibility__c = 'All Users';
        cs.Type = 'Non-Case';
        cs.Requestor_Dept__c = 'Single Carrier';
        cs.Resolver_Dept__c = 'Ocean: Sales';
        cs.Sub_Type__c = 'Spam/Case Created in Error';
                
         Test.startTest();

         insert cs;

         update conInstance2;

         Case css = TestBusinessHelper.createCase(acc,conInstance, 'External_Case', false);
         cs.Id = null;
         css = [select id, direction__C from case limit 1];
         css.Direction__c = 'Import';
         update css;
         Test.stopTest();     
         TriggerExecutionController.skipAllTriggers(false);

     }
    
}