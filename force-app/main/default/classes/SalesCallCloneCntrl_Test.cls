/**
 * Version       Date                Owner                                Ref Number       Description
 *******************************************************************************************************
 * v1.0          04/09/2018          meghana.gupta@ust-global.com         #RQ-008979       Code created
 * v2.0          15/06/2022          Ronnie@SF                            SPI-100          Removed brand hardcoding
 */ 

@isTest
public class SalesCallCloneCntrl_Test {
    
    @testSetup static void setup() {
        
        Account clientAcc = AccountDataHelper_Test.createClientAccount();          
        Contact MSLContact = ContactDataGeneratorHelper_Test.createCustomerContact( clientAcc.Id, BrandUtilities.MAERSKLINE);                                                                                        
        
        SalesCallData_Test.createSalesCallsWithType( 1, clientAcc, MSLContact, BrandUtilities.MAERSKLINE, 'Other');
   }
    
    @isTest
    static void TestClone() {
        
        Sales_Call__c rec = [SELECT Id FROM Sales_Call__c LIMIT 1];
        
        Test.startTest();  
        SalesCallCloneCntrl.responseWrapper response = SalesCallCloneCntrl.cloneCustomerCall (rec.Id);
        SalesCallCloneCntrl.saveClonedRecord(response.recSalesCall);
        
        SalesCallCloneCntrl.responseWrapper response1 = SalesCallCloneCntrl.cloneCustomerCall (rec.Id);
        response1.recSalesCall.Manager__c = response1.recSalesCall.OwnerId;
        SalesCallCloneCntrl.saveClonedRecord(response1.recSalesCall);
        
        Test.stopTest(); 
    }
}