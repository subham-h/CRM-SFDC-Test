/**
 * Author   : Nisha
 * Purpose  : Test EventUtilities
 *
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-004102   15/7/2016   Nisha.arjunan@UST       Created.
 * 2.0      RQ-009006   28/09/2018  Sidhartha               Updated 
 * 3.0      RQ-012152   05/10/2019  Neha@TCS                Remove reference of Sales Call and Business Review record type and created new method to cover exception scenario
 * 4.0      SPI-100     27/06/2022  Ronnie@SF               Removed brand hardcoding
 */


@isTest
public class EventUtilities_Test {
    
    @testSetup static void setup() {
        //Id salesCallRTID = StaticFactory.getRecordTypeIdByName('Sales_Call__c', 'Sales Call');
        //Id businessReviewRTID = StaticFactory.getRecordTypeIdByName('Sales_Call__c', 'Business Review');
        UserDataGeneratorHelper_Test.initializeIntegrationUser();  
        Account acc= new Account();
        acc.Name = 'Test Account';
        acc.SCV_Code__c = 'SCV12344';  
        TriggerExecutionController.skipAllTriggers(true);
        insert acc;
        TriggerExecutionController.skipAllTriggers(false);
        
        Contact cont = new Contact();
        cont.AccountId = acc.Id;
        cont.FirstName = 'first';
        cont.LastName = 'last';
        cont.Email = 'Qwerty@gmail.com';
        cont.Liner_Brands__c = BrandUtilities.MAERSKLINE;
        TriggerExecutionController.skipAllTriggers(true);
        insert cont;
        TriggerExecutionController.skipAllTriggers(false);

        Sales_Call__c salesCl = new Sales_Call__c();
        salesCl.Do_Not_Create_Event__c = false;
        salesCl.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        salesCl.Contact__c = cont.Id;
        //salesCl.RecordTypeId = salesCallRTID;
        salesCl.Manager__c = UserDataGeneratorHelper_Test.MSLIntegrationUser.Id;
        salesCl.StartDateTime__c = system.now();
        salesCl.EndDateTime__c = system.now()+ 1;
        salesCl.Type__c = 'Service (Face-to-Face)';
        salesCl.Event_Description__c = 'test Description';
        salesCl.Location__c = 'cochi';
        insert salesCl;  

        /*List<Event> elist = new List<Event>();
        Event e = new Event();
        e.Subject = 'Event created';
        e.StartDateTime = system.now();
        e.EndDateTime = system.now();
        e.ownerId = UserInfo.getUserId();
        e.WhoId = salesCl.contact__c;
        e.Type = 'Service (Face-to-Face)';
        e.WhatId = salesCl.Id;
        e.Location = 'cochi';
        e.Description='Test';
        elist.add(e);
        insert elist;*/
    }
    
    public static testMethod void test_updateSalesCallOnEventUpdation () {
        Test.startTest();
            //Set<Id> evtId = new Set<Id>();
            list<Event> evnList = new list<Event>();
            Sales_Call__c salesCl = [Select Id from Sales_Call__c limit 1]; 
            //List<Event> eVn = [Select Id from Event limit 1];
            //evtId.add(eVn[0].Id);
            Event evnt = [select StartDateTime,EndDateTime,Type,WhatId,Location,Description,ownerId from Event where WhatId =: salesCl.id];
                evnt.StartDateTime = system.now() + 2;
                evnt.EndDateTime = system.now() + 2;
                evnt.Subject = 'Event Updated'; 
                evnt.Type ='Service (Planned Phone)';                   
                
            update evnt;                                     
            Sales_Call__c salesCallUpdated = [SELECT Id, StartDateTime__c,Type__c FROM Sales_Call__c where Id =: salesCl.id ];
            Event updatedEv = [SELECT Id, StartDateTime, WhatId,Type FROM Event WHERE WhatId =: salesCl.id];
            system.assertEquals(updatedEv.Type, salesCallUpdated.Type__c);
        Test.Stoptest();
    }  
    
    public static testMethod void test_exceptionConditon () {
        Boolean exceptionThrown = false;
        Test.startTest();
            Sales_Call__c salesCl = [Select Id,contact__c from Sales_Call__c limit 1];
            // Create new EVent with the sales Call
            Event e = new Event();
            e.Subject = 'Event created';
            e.StartDateTime = system.now();
            e.EndDateTime = system.now();
            e.ownerId = UserInfo.getUserId();
            e.WhoId = salesCl.contact__c;
            e.Type = 'Service (Face-to-Face)';
            e.WhatId = salesCl.Id;
            e.Location = 'cochi';
            e.Description='Test';
            try{
                insert e; // We cannot have more than 1 event associated to Sales Call since one event will be created in set up method when service call is created
            }
            catch(Exception ex){
                exceptionThrown = true; 
                Boolean expectedExceptionThrown =  (ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) ? true : false;
                System.AssertEquals(true, expectedExceptionThrown, ex.getMessage());
            }       
        Test.Stoptest();        
    }
}