/**
 * Test class for 
 *   EventTrigger, 
 *   EventTriggerHandler, 
 *   SalesCallTrigger and 
 *   SalesCallTriggerHandler.
 * 
 * Version     Date            Owner                                    RQ#                        Description
 ****************************************************************************************************************************************************************************
 * 1.0         23/06/2014      Ranjini.Janardhanan@ust-global.com       #PR-0013                   Code created 
 * 2.0         16/09/2014      Krishnamoorthi.murugesan@ust-global.com  #RQ-000204 and #RQ-000228  two test methods (populatePSMLengthFields,createEventFromExistingSalesCall)
 *                                                                                                 test methods have been created 
 * 3.0         21/10/2014      Krishnamoorthi.murugesan@ust-global.com  #RQ-000185                 Update Event with multiple Users as Invitees    
 * 4.0         12/09/2019      manjunath@maersk                         #RQ-012362                 Removed references of Account.Commercial_Leader__c and Account.Export_Rep__c
 * 5.0         08/06/2022      Ronnie@SF                                SPI-100                    Removed brand hardcoding
 */

@isTest  
private class SalesCallEvent_Test {

    static Contact c;
    static Account acctObj;
   
    static void createAccount(){
        
        UserDataGeneratorHelper_Test.initializeIntegrationUser();   
        acctObj= new Account();
        acctObj.Name = 'Test Account';
        acctObj.SCV_Code__c = 'SCV12344';   
        acctObj.MSL_Account_Owner__c=UserDataGeneratorHelper_Test.MSLIntegrationUser.Id; 
        //acctObj.SCL_Account_Owner__c=UserDataGeneratorHelper_Test.SCLIntegrationUser.id;
        System.runAs(UserDataGeneratorHelper_Test.integrationUser)
        {
            insert acctObj;
        }
    }
     
    
    static void createContact(){
        c = new Contact();
        c.AccountId = acctObj.Id;
        c.FirstName = 'first';
        c.LastName = 'last';
        c.Email = 'Qwerty@gmail.com';
        c.Liner_Brands__c = BrandUtilities.MAERSKLINE;
        insert c;
        System.debug('##### c: '+c);
    } 
    
    
    /*
    * Creating a Sales Call without creating an event
    */
    static testMethod void createSalesCallWithoutEvent() {
        
        createAccount();
        createContact();
        
        Sales_Call__c sc = new Sales_Call__c();
        sc.Do_Not_Create_Event__c = true;
        sc.Liner_Brand__c = BrandUtilities.MAERSKLINE; 
        sc.Contact__c = c.Id;
        Test.startTest();
        insert sc;
        Test.stopTest();
        List<Event> ev = [SELECT Id,WhatId FROM Event WHERE WhatId=: sc.Id];
        System.assertEquals(ev.size(), 0);
    }
    
    
    /*
    * Creating a Sales Call with  an event created by the system automatically.
    */
    static testMethod void createSalesCallWithEvent() {
        
        createAccount();
        createContact();
        System.debug('##### accObj: '+acctObj);
        
        Test.StartTest();
        DateTime dtStartDate = system.now();
        DateTime dtEndDate = system.now()+ 1;
        
        Sales_Call__c sc = new Sales_Call__c();
        sc.Do_Not_Create_Event__c = false;
        sc.Name = 'myUnitTest2';
        sc.StartDateTime__c = dtStartDate;
        sc.EndDateTime__c = dtEndDate;
        sc.Type__c = 'Service (Face-to-Face)';
        sc.Contact__c = c.Id;
        sc.OwnerId = Userinfo.getUserId();
        sc.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        sc.Location__c = 'Trivandrum';
        //sc.Contact__c
        insert sc;
        
        Event e = new Event();
        e.Subject = 'myUnitTest2';
        e.StartDateTime = dtStartDate;
        e.EndDateTime = dtEndDate;
        e.ownerId = UserInfo.getUserId();
        e.WhatId = sc.Id;
        e.Type = 'Service (Face-to-Face)';
        //e.WhoId = c.Id;
        e.Location = 'cochi';
        e.Description = 'Update Testing';
        insert e;
        Test.stopTest();
        System.debug('##### sc: '+sc);
        
        List<Event> ev = [SELECT Id,Type,Subject,StartDateTime,EndDateTime,OwnerId,WhatId FROM Event WHERE WhatId=: sc.Id];
        System.debug('##### Ev: '+ev);
        System.assertEquals(ev[0].WhatId , sc.Id);
        System.assertEquals(ev[0].Type, sc.Type__c);
        //System.assertEquals(ev[0].StartDateTime, sc.StartDateTime__c);
        System.assertEquals(ev[0].EndDateTime, sc.EndDateTime__c);
        System.assertEquals(ev[0].OwnerId, sc.OwnerId);
    }
    
    
     /*
     * updating a sales call with and event
     */
    static testMethod void updateSalesCallWithEvent() {
        
        createAccount();
        createContact();
        
        Sales_Call__c sc = new Sales_Call__c();
        sc.Do_Not_Create_Event__c = false;
        sc.Name = 'myUnitTest2';
        sc.StartDateTime__c = system.now();
        sc.EndDateTime__c = system.now()+ 1;
        sc.Type__c = 'Service (Face-to-Face)';
        sc.Contact__c = c.Id;
        sc.OwnerId = Userinfo.getUserId();
        sc.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        sc.Location__c = 'Trivandrum';
        Test.startTest();
        insert sc;
        
        Event e = new Event();
        e.Subject = 'UnitTest1';
        e.StartDateTime = system.now();
        e.EndDateTime = system.now() + 1;
        e.ownerId = UserInfo.getUserId();
        e.WhatId = sc.Id;
        e.Type = 'Service (Face-to-Face)';
        //e.WhoId = c.Id;
        e.Location = 'cochi';
        e.Description = 'Update Testing';
        insert e;
        System.debug('##### sc: '+sc);
        
        
        
        DateTime strtdt = system.now()+2;
        DateTime enddt = system.now()+3;
        sc.Name = 'myUnitTest2updated';
        sc.StartDateTime__c = strtdt;
        sc.EndDateTime__c = enddt;
        sc.Type__c = 'Service (Planned Phone)';
        Generic_TriggerHandler.clearLoopCountForAllMethod();
        TriggerExecutionController.skipSalesCallTrigger(false);
        update sc;
        Test.Stoptest();
        
        List<Event> ev = [SELECT Id,Type,Subject,StartDateTime,EndDateTime,OwnerId,WhatId FROM Event WHERE WhatId=: sc.Id];
        System.debug('##### Ev: '+ev);
        
        System.assertEquals(ev[0].Type, 'Service (Planned Phone)');
        System.assertEquals(ev[0].StartDateTime, strtdt);
        System.assertEquals(ev[0].EndDateTime, enddt);          
    }
     
     
     
     /*
     * Updating an event with sales call
     */
     static testMethod void updateEventWithSalesCall() {
        
        createAccount();
        createContact();
        
        Sales_Call__c scupdated = new Sales_Call__c();
        Sales_Call__c sc = new Sales_Call__c();
        sc.Do_Not_Create_Event__c = true;
        sc.Liner_Brand__c = BrandUtilities.MAERSKLINE; 
        sc.Contact__c = c.Id;
        
        insert sc;
        
        Test.StartTest();
        DateTime strtdt = system.now()+2;
        DateTime enddt = system.now()+3;
        Event e = new Event();
        e.Subject = 'Event created';
        e.StartDateTime = strtdt;
        e.EndDateTime = enddt;
        e.ownerId = UserInfo.getUserId();
        e.Location ='UK';
        e.WhoId = c.Id;
        e.WhatId = sc.Id;
        insert e;
        
        Event eveRecord = [Select id,WhatId,Type,Location from Event where Subject = 'Event created'];        
        eveRecord.Location = 'cochi';
        TriggerExecutionController.skipEventTrigger(false);
        update eveRecord;
        //Sales_Call__c scupdated1 = [SELECT id,Type__c,Name,StartDateTime__c,EndDateTime__c,OwnerId from Sales_call__c where Id=:sc.Id];        
        System.assertEquals(eveRecord.Location ,'cochi');
        Test.StopTest(); 
     }
     
     /*
     * #RQ-000204 Delete the corresponding Event records when Sales Call Status is "Cancelled"
     */
     /*static testMethod void deleteEventforCancelledSalesCall() {
     
        createAccount();
        createContact();
        
        Id salesCallRTID = StaticFactory.getRecordTypeIdByName('Sales_Call__c', 'Sales Call');
        Sales_Call__c sc = new Sales_Call__c();
        sc.Do_Not_Create_Event__c = false;
        sc.Name = 'myUnitTest3';
        sc.StartDateTime__c = system.now();
        sc.EndDateTime__c = system.now()+ 1;
        sc.Type__c = 'Sales Call (Face-to-Face)';
        sc.Contact__c = c.Id;
        sc.OwnerId = Userinfo.getUserId();
        sc.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        sc.Location__c = 'Trivandrum';
        sc.RecordTypeId = salesCallRTID;
        
        Test.startTest();
            insert sc;
             
            Event e = new Event();
            e.Subject = 'deleteEventforCancelledSalesCall';
            e.StartDateTime = system.now();
            e.EndDateTime = system.now() + 1;
            e.ownerId = UserInfo.getUserId();
            e.WhatId = sc.Id;
            e.Type = 'Sales Call (Face-to-Face)';
            e.Location = 'some_location';
            e.Description = 'deleteEventforCancelledSalesCall description';
            insert e;
            system.debug('@@@@' + e);
            
            List<Event> ev = [SELECT Id,WhatId FROM Event WHERE WhatId=: sc.Id];
            System.assertEquals(ev.size(), 1);
            
            sc.Status__c = 'Cancelled';
            Generic_TriggerHandler.clearLoopCountForAllMethod();
            TriggerExecutionController.skipSalesCallTrigger(false);
            update sc;
        
        Test.StopTest();
        
        List<Event> evToBeDeleted = [SELECT Id,WhatId FROM Event WHERE WhatId=: sc.Id];
        System.assertEquals(evToBeDeleted.size(), 0);
     }*/
     
     
     
     /* 
     * #RQ-000228 Create an Event from already existing Sales Call
     */
    static testMethod void createEventFromExistingSalesCall() {
        
        createAccount();
        createContact();
        Id serviceCallRecordTypeId = StaticFactory.getRecordTypeIdByName('Sales_Call__c', 'Service Call');
        Sales_Call__c sc = new Sales_Call__c();
        sc.Do_Not_Create_Event__c = true;
        sc.Liner_Brand__c = BrandUtilities.MAERSKLINE; 
        sc.Contact__c = c.Id;
        sc.RecordTypeId = serviceCallRecordTypeId;
        
        Test.startTest();
        insert sc;
        
        List<Event> ev = [SELECT Id,WhatId FROM Event WHERE WhatId=: sc.Id];
        System.assertEquals(ev.size(), 0);
        
        sc.StartDateTime__c = system.now();
        sc.EndDateTime__c = system.now()+ 1;
        sc.Type__c = 'Service (Face-to-Face)';
        sc.Do_Not_Create_Event__c = false;
        Generic_TriggerHandler.clearLoopCountForAllMethod();
        TriggerExecutionController.skipSalesCallTrigger(false);
        update sc;
        
        Test.StopTest();
        
        List<Event> evCreated = [SELECT Id,WhatId FROM Event WHERE WhatId=: sc.Id];
        System.assertEquals(evCreated.size(), 1);
    }
     
     
     /*
     * RQ-000204 Populate "Length" and "Has" fields in sales Call
     */
    static testMethod void populatePSMLengthFields() {
        
        createAccount();
        createContact();
        
        Sales_Call__c sc = new Sales_Call__c();
        sc.Type__c = 'Service (Face-to-Face)';
        sc.Liner_Brand__c = BrandUtilities.MAERSKLINE; 
        sc.Contact__c = c.Id;
        sc.StartDateTime__c = system.now();
        sc.EndDateTime__c = system.now()+ 1;
        sc.Event_Description__c = 'Testing';
        sc.Confirmation_Letter__c = 'Test Confirm';
        sc.Objective__c = 'Test Objective';
        sc.Persuasive_Selling_Pitch__c = 'Test PSP';
        sc.Post_Call_Notes__c = 'Test PCN';
        
        Test.startTest();
        insert sc;
        Test.StopTest();
        
        Sales_Call__c scupdated = [SELECT Agenda_Length__c,Has_Agenda__c,Confirmation_Letter_Length__c,Has_Confirmation_Letter__c,Objective_Length__c,Has_Objective__c from Sales_call__c where Id=:sc.Id ];
        
        System.assertEquals(scupdated.Has_Agenda__c, true);
        System.assertEquals(scupdated.Agenda_Length__c, 7);  
    }
     
    
     /*
     * RQ-000185 Update Event with Users as invitees
     */
     /*static testMethod void updateEventWithInvitees() {
        
        createAccount();
        createContact();
        Id salesCallRTID = StaticFactory.getRecordTypeIdByName('Sales_Call__c', 'Sales Call');
        
        Sales_Call__c sc = new Sales_Call__c();
        sc.Type__c = 'Sales Call (Face-to-Face)';
        sc.Liner_Brand__c = BrandUtilities.MAERSKLINE; 
        sc.Contact__c = c.Id;
        sc.StartDateTime__c = system.now();
        sc.EndDateTime__c = system.now()+ 1;
        sc.Event_Description__c = 'Testing';
        sc.Confirmation_Letter__c = 'Test Confirm';
        sc.Objective__c = 'Test Objective';
        sc.Persuasive_Selling_Pitch__c = 'Test';
        sc.Post_Call_Notes__c = 'Test with multiple invitees';
        sc.RecordTypeId = salesCallRTID;
        insert sc;
        
        Event e = new Event();
        e.Subject = 'UnitTest1';
        e.StartDateTime = system.now();
        e.EndDateTime = system.now() + 1;
        e.ownerId = UserInfo.getUserId();
        e.WhatId = sc.Id;
        e.Type = 'Sales Call (Face-to-Face)';
         //e.WhoId = c.Id;
        e.Location = 'cochi';
        e.Description = 'Update Testing';
        insert e;
        Event evCreated = [SELECT Id,WhatId, Description FROM Event WHERE WhatId =: sc.Id LIMIT 1];
        
        EventRelation er = new EventRelation();
        er.Status = 'New';
        er.EventId = evCreated.Id;
        er.RelationId = UserDataGeneratorHelper_Test.MSLIntegrationUser.Id; 
        insert er;
        
        evCreated.Description = 'Update Testing';
        
        Test.startTest();
          TriggerExecutionController.skipEventTrigger(false);
          update evCreated;
        Test.StopTest();
        
        Sales_Call__c scupdated = [SELECT Id, Event_Description__c FROM Sales_call__c WHERE Id=:sc.Id ];
        
        System.assertEquals(scupdated.Event_Description__c, 'Update Testing');  
     }*/
}