/**
 * Author   : Nisha
 * Purpose  : Test SalesCallFieldPopulator
 *
 * Revision Ref Number  Date        Owner                        Description
 * -------- ----------  ----------- -------------------          -----------
 * 1.0      RQ-000204   16/09/2014  Krishnamoorthi.murugesan@ust populateSalescallLenghtFields 
 * 2.0      RQ-004292   11/08/2016  Nisha.arjunan@UST            Modified test class for CBO Architecture.
 * 3.0      RQ-012152   05-10-2019  Neha@TCS                     Remove reference of Sales and Business review call record type so method invocation is changed from sales to service
 * 4.0		SC-1662	    05-01-2020  Sreya					     CSAT onboarding for Service Call.
 * 5.0      SPI-100     08-06-2022  Ronnie@SF                    Removed brand hardcoding
 */

@isTest
public class SalesCallFieldPopulator_Test {
    public static testMethod void test_populateLenghtAndHasFields () {
        Account acc =  new Account();
        AccountData_Test.iNumberOfAccounts = 1;
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.createDraftAccounts();
        TriggerExecutionController.skipAllTriggers(false);
        acc =AccountData_Test.lstAccounts[0];  
        
        Contact cont = new Contact();
        cont.AccountId = acc.Id;
        cont.FirstName = 'first';
        cont.LastName = 'last';
        cont.Email = 'Qwerty@gmail.com';
        cont.Liner_Brands__c = BrandUtilities.MAERSKLINE;
        TriggerExecutionController.skipAllTriggers(true);
        insert cont;
        TriggerExecutionController.skipAllTriggers(false);
        
        List<Sales_Call__c> lstSalCall = new List<Sales_Call__c>();
        SalesCallData_Test.bCreate = false;
        //SalesCallData_Test.createSalesCallWithEvent();
        SalesCallData_Test.createServiceCallWithEvent();
        lstSalCall = SalesCallData_Test.lstsalesCall;
        lstSalCall[0].Contact__c =  cont.Id;
        
        Test.startTest();
        insert lstSalCall;
        Test.StopTest();
        
        Sales_Call__c salesCallUpdated = [SELECT Agenda_Length__c, Has_Agenda__c, Confirmation_Letter_Length__c, Has_Confirmation_Letter__c, Objective_Length__c, Has_Objective__c, Persuasive_Selling_Pitch_length__c, Has_Persuasive_Selling_Pitch__c, Post_Call_Notes_length__c, Has_Post_Call_Notes__c 
                                          FROM Sales_call__c 
                                          WHERE Id = :lstSalCall[0].Id];
        
        System.assertEquals(salesCallUpdated .Has_Agenda__c, true);
        System.assertEquals(salesCallUpdated .Agenda_Length__c, 7);
        System.assertEquals(salesCallUpdated .Has_Confirmation_Letter__c, true);
        System.assertEquals(salesCallUpdated .Confirmation_Letter_Length__c, 12);  
        System.assertEquals(salesCallUpdated .Has_Objective__c, true);
        System.assertEquals(salesCallUpdated .Objective_Length__c, 14);  
        System.assertEquals(salesCallUpdated .Has_Persuasive_Selling_Pitch__c, true);
        System.assertEquals(salesCallUpdated .Persuasive_Selling_Pitch_length__c, 4);  
        System.assertEquals(salesCallUpdated .Has_Post_Call_Notes__c, true);
        System.assertEquals(salesCallUpdated .Post_Call_Notes_length__c, 27);      
    }
    
    // test method for populateEncryptedId method
    public static testMethod void test_populateEncryptedId () {
        Account acc =  new Account();
        AccountData_Test.iNumberOfAccounts = 1;
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.createDraftAccounts();
        TriggerExecutionController.skipAllTriggers(false);
        acc =AccountData_Test.lstAccounts[0];  
        
        Contact cont = new Contact();
        cont.AccountId = acc.Id;
        cont.FirstName = 'first';
        cont.LastName = 'last';
        cont.Email = 'Qwerty@gmail.com';
        cont.Liner_Brands__c = BrandUtilities.MAERSKLINE;
        TriggerExecutionController.skipAllTriggers(true);
        insert cont;       
        
        List<Sales_Call__c> lstSalCall = new List<Sales_Call__c>();
        SalesCallData_Test.bCreate = false;
        SalesCallData_Test.createServiceCallWithEvent();
        lstSalCall = SalesCallData_Test.lstsalesCall;
        lstSalCall[0].Contact__c =  cont.Id;
        lstSalCall[0].Service_Type__c = 'Onboarding';
        lstSalCall[0].StartDateTime__c = System.now() - 2;
        lstSalCall[0].EndDateTime__c = System.now() - 1;
        
        Service_Call_Survey_Key__c key = new Service_Call_Survey_Key__c();
        key.Crypto_Key__c = 'cj67pKL+Pa7qr8K6Ul/HFep33jQC8gnoEPnUxCXhdYk=';
        insert key;
        
        Test.startTest();
        TriggerExecutionController.skipAllTriggers(true);
        insert lstSalCall;
        Test.StopTest();
        
        Sales_Call__c salesCallUpdated = [SELECT Id, Status__c, Service_Type__c, RecordType.name, liner_brand__c 
                                          FROM Sales_Call__c 
                                          WHERE Id = :lstSalCall[0].Id];

        salesCallUpdated.Status__c = 'Completed';
        TriggerExecutionController.skipAllTriggers(false);
        update salesCallUpdated;
    }
}