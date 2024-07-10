/**
 * Author   : Nisha
 * Purpose  : Test SalesCallUtilities
 *
 * Revision Ref Number  Date            Owner                                  Description
 * -------- ----------  -----------     -------------------                    -----------
 * 1.0      PR-0013     23/06/2014      Ranjini.Janardhanan@ust                Code created 
 * 2.0      RQ-000228   16/09/2014      Krishnamoorthi.murugesan@ust           createEventFromExistingSalesCall
 * 3.0      RQ-000185   21/10/2014      Krishnamoorthi.murugesan@ust           Update Event with multiple Users as Invitees                                                                                                                               
 * 4.0      RQ-004292   11/08/2016      Nisha.arjunan@UST                      Modified test class for CBO Architecture.
 * 5.0      RQ-004817   03/04/2017      Govindaraj.sundaram@ust-global.com     Updated the Type picklist value.
 * 6.0      RQ-005193   18/04/2017      Rathish.Rajendran@ust-global.com       Updated test class to accomodate validation rule "Validate_Internal_Contacts_Association".
 * 7.0      RQ-009006   26/09/2018      Nitin More                             Updated test_synchronizeToEvents_Cancelled method to create event
 * 8.0      RQ-012152                   Neha@TCS                               Commented method for Sales Call using Sales and Buiness review record types(test_createEvents , test_synchronizeToEvents)
 * 9.0      SPI-100     08/06/2022      Ronnie@SF                              Removed brand hardcoding
 */

@isTest
public class SalesCallUtilities_Test {
    
    //static Id salesCallRTID = StaticFactory.getRecordTypeIdByName('Sales_Call__c', 'Sales Call');
    //static Id businessReviewRTID = StaticFactory.getRecordTypeIdByName('Sales_Call__c', 'Business Review');
    
    @testSetup static void setup() {
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
        
    }
    
    static testMethod void test_createserviceCall() {
        
        list<Sales_Call__c> lstSalCall = new list<Sales_Call__c>();
        SalesCallData_Test.bCreate = true;
        SalesCallData_Test.createServiceCallWithEvent();
        lstSalCall = SalesCallData_Test.lstsalesCall;
        lstSalCall[0].Type__c = 'Service (Planned Phone)';
        update lstSalCall;
    }
    
    // Creating a Sales Call with  an event created by the system automatically.
    /*static testMethod void test_createEvents() {
        Contact cont = [select Id from Contact limit 1];
        list<Sales_Call__c> lstSalCall = new list<Sales_Call__c>();
        SalesCallData_Test.bCreate = false;
        SalesCallData_Test.createSalesCallWithEvent();
        lstSalCall = SalesCallData_Test.lstsalesCall;
        lstSalCall[0].Contact__c =  cont.Id;
        
        Test.StartTest();
        insert lstSalCall;
        Test.stopTest();
        
        Event e = new Event();
        e.Subject = 'UnitTest1';
        e.StartDateTime = system.now();
        e.EndDateTime = system.now() + 1;
        e.ownerId = UserInfo.getUserId();
        e.WhatId = lstSalCall[0].Id;
        e.Type = 'Sales Call (Face-to-Face)';
        e.Location = 'cochi';
        e.Description = 'Update Testing';
        insert e;
        System.debug('##### lstSalCall: '+lstSalCall);
        
        List<Event> evnt = [SELECT Id,Type, Subject, StartDateTime, EndDateTime, OwnerId, WhatId FROM Event WHERE WhatId=: lstSalCall[0].Id];
        System.debug('##### Evnt: '+evnt);
        System.assertEquals(evnt[0].WhatId , lstSalCall[0].Id);
        System.assertEquals(evnt[0].Type, lstSalCall[0].Type__c);
        System.assertEquals(evnt[0].Subject, lstSalCall[0].Name);
        System.assertEquals(evnt[0].OwnerId, lstSalCall[0].OwnerId);
    }*/
    
    //  updating a sales call with an event
    static testMethod void test_synchronizeToEvents () {  
    Contact cont = [select Id from Contact limit 1];
        list<Sales_Call__c> lstSalCall = new list<Sales_Call__c>();
        SalesCallData_Test.bCreate = false;
        //SalesCallData_Test.createSalesCallWithEvent();
        SalesCallData_Test.createServiceCallWithEvent();
        lstSalCall = SalesCallData_Test.lstsalesCall;
        lstSalCall[0].Contact__c =  cont.Id;
        insert lstSalCall;
        System.debug('##### lstSalCall: '+lstSalCall);
        Set<Id> evtId = new Set<Id>();
        Event e = new Event();
        e.Subject = 'UnitTest1';
        e.StartDateTime = system.now();
        e.EndDateTime = system.now() + 1;
        e.ownerId = UserInfo.getUserId();
        e.WhatId = lstSalCall[0].Id;
        e.Type = 'Sales Call (Face-to-Face)';
        e.Location = 'cochi';
        e.Description = 'Update Testing';
        insert e;
        evtId.add(e.Id);
        system.debug('@@@@' + e);
        

        DateTime strStartDate = system.now()+2;
        DateTime strEndDate = system.now()+3;
        lstSalCall[0].Name = 'UnitTest2updated';
        lstSalCall[0].StartDateTime__c = strStartDate;
        lstSalCall[0].EndDateTime__c = strEndDate;
        //lstSalCall[0].Type__c = 'Sales Call (Planned Phone)';    // #RQ-004817 - Updated the picklist value 
        lstSalCall[0].Type__c = 'Service (Face-to-Face)';    // #RQ-012152 - Updated the picklist value 
        
        map <Id,Sales_Call__c> mapSCToUpdateEvents =  new map <Id,Sales_Call__c>();
        mapSCToUpdateEvents.put(lstSalCall[0].Id,lstSalCall[0]);
        Test.startTest();
        //EventUtilities.createEventRelation(evtId);
        
            SalesCallUtilities.syncToEvtRelationManager(mapSCToUpdateEvents);
            Generic_TriggerHandler.clearLoopCountForAllMethod();
            TriggerExecutionController.skipSalesCallTrigger(false);
            update lstSalCall;
            
            List<Event> evnt = [SELECT Id,Type, Subject, StartDateTime, EndDateTime, OwnerId, WhatId FROM Event WHERE WhatId=: lstSalCall[0].Id];
            System.debug('##### Event: '+evnt);
            
            System.assertEquals(evnt[0].Type, 'Service (Face-to-Face)');  // #RQ-004817 - Updated the picklist value 
            System.assertEquals(evnt[0].StartDateTime, strStartDate);
            System.assertEquals(evnt[0].EndDateTime, strEndDate);
        Test.Stoptest();        
    }
    
    // #RQ-000204 Delete the corresponding Event records when Sales Call Status is "Cancelled"
    static testMethod void test_synchronizeToEvents_Cancelled() { 
      Contact cont = [select Id from Contact limit 1];
        list<Sales_Call__c> lstSalCall = new list<Sales_Call__c>();
        SalesCallData_Test.bCreate = false;
        //SalesCallData_Test.createSalesCallWithEvent();
        SalesCallData_Test.createServiceCallWithEvent();
        lstSalCall = SalesCallData_Test.lstsalesCall;
        lstSalCall[0].Contact__c =  cont.Id;
        insert lstSalCall;
        System.debug('##### lstSalCall: '+lstSalCall);
        
        Event e = new Event();
        e.Subject = 'test_synchronizeToEvents_Cancelled';
        e.StartDateTime = system.now();
        e.EndDateTime = system.now() + 1;
        e.ownerId = UserInfo.getUserId();
        e.WhatId = lstSalCall[0].Id;
        e.Type = 'Service (Face-to-Face)';
        e.Location = 'some_location';
        e.Description = 'test_synchronizeToEvents_Cancelled description';
        insert e;
        system.debug('@@@@' + e);
        
        List<Event> evnt = [SELECT Id,WhatId FROM Event WHERE WhatId=: lstSalCall[0].Id];
        System.assertEquals(evnt.size(), 2);
        
        lstSalCall[0].Status__c = 'Cancelled';
        
        Test.startTest();
        Generic_TriggerHandler.clearLoopCountForAllMethod();
        TriggerExecutionController.skipSalesCallTrigger(false);
        update lstSalCall;    
        Test.StopTest();
        
        List<Event> evToBeDeleted = [SELECT Id,WhatId FROM Event WHERE WhatId=: lstSalCall[0].Id];
        System.assertEquals(evToBeDeleted.size(), 0);    
    }
}