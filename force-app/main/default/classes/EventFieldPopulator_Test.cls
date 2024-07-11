/**
 * Version    Date               Owner                               RQ#              Description
 ****************************************************************************************************************************************************************************
 * 1.0                           Neha@tcs                            RQ-012152        Corrected the test class for RQ-012152 with removing the reference of Sales CallCode created 
 * 2.0        12-Nov-2019        Manjunath@maersk                    RQ-012362        Removed references of Account.Commercial_Leader__c and Account.Export_Rep__c
 * 3.0        08-Jun-2022        Ronnie@SF                           SPI-100          Removed brand hardcoding
 */

@isTest
public class EventFieldPopulator_Test {
    
    static Contact c;
    static Account acctObj;
    //static Id salesCallRTID = StaticFactory.getRecordTypeIdByName('Sales_Call__c', 'Sales Call');
    
    @testSetup static void setup() { 
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
        
        c = new Contact();
        c.AccountId = acctObj.Id;
        c.FirstName = 'first';
        c.LastName = 'last';
        c.Email = 'Qwerty@gmail.com';
        c.Liner_Brands__c = BrandUtilities.MAERSKLINE;
        insert c;
        System.debug('##### c: '+c);
    }
    
    public static testMethod void test_eventpopulator() {
        UserDataGeneratorHelper_Test.initializeSystemAdminUser();  
        Contact c = [select id from Contact limit 1];
        system.debug('@@@@@' + c.Id);
        Sales_Call__c sc = new Sales_Call__c();
        sc.Name = 'myUnitTest3';
        sc.Type__c = 'Service (Face-to-Face)';
        sc.Contact__c = c.Id;
        sc.StartDateTime__c = system.now();
        sc.EndDateTime__c =system.now() + 1;
        sc.OwnerId = Userinfo.getUserId();
        sc.Manager__c =  UserDataGeneratorHelper_Test.MSLSystemAdminUser.id;
        sc.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        sc.Location__c = 'Trivandrum';
        insert sc;
        
        List<Event> elist = new List<Event>();
        Set<Id> whatIds = new  Set<Id>();
        Event e = new Event();
        e.Subject = 'Event created';
        e.StartDateTime = system.now();
        e.EndDateTime = system.now() + 1;
        e.ownerId = UserInfo.getUserId();
        e.WhoId = sc.contact__c;
        e.Type = 'Service (Face-to-Face)';
        e.WhatId = sc.Id;
        e.Location = 'cochi';
        elist.add(e);
        insert elist;
        whatIds.add(elist[0].WhatId);
        
        EventRelation eR = new EventRelation();
        eR.EventId = elist[0].Id;
        eR.RelationId = elist[0].WhoId;
        insert eR;
        Test.startTest();
        EventFieldPopulator.populatecontact(elist,whatIds);
        Test.stopTest();
        List<Event> ev = [SELECT Id,Type,WhoId,Subject,StartDateTime,EndDateTime,OwnerId,WhatId FROM Event WHERE WhatId=: sc.Id];
        system.assertEquals(ev[0].Whoid, sc.Contact__c);
    }
    
    /*public static testMethod void test_subjecteventpopulator() {
        UserDataGeneratorHelper_Test.initializeSystemAdminUser();  
        Contact c = [select id from Contact limit 1];
        system.debug('@@@@@' + c.Id);
        Sales_Call__c sc = new Sales_Call__c();
        sc.Name = 'myUnitTest3';
        sc.Type__c = 'Sales Call (Face-to-Face)';
        sc.Contact__c = c.Id;
        sc.RecordTypeId = salesCallRTID;
        sc.OwnerId = Userinfo.getUserId();
        sc.Manager__c =  UserDataGeneratorHelper_Test.MSLSystemAdminUser.id;
        sc.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        sc.Location__c = 'Trivandrum';
        insert sc;
        
        List<Event> elist = new List<Event>();
        Set<Id> whatIds = new  Set<Id>();
        Event e = new Event();
        e.StartDateTime = system.now();
        e.EndDateTime = system.now() + 1;
        e.ownerId = UserInfo.getUserId();
        e.WhoId = sc.contact__c;
        e.Type = 'Sales Call (Face-to-Face)';
        e.WhatId = sc.Id;
        e.Location = 'cochi';
        elist.add(e);
        insert elist;
        whatIds.add(elist[0].WhatId);
        
        EventRelation eR = new EventRelation();
        eR.EventId = elist[0].Id;
        eR.RelationId = elist[0].WhoId;
        insert eR;
       // Test.startTest();
        EventFieldPopulator.populatecontact(elist,whatIds);
       // Test.stopTest();
        List<Event> ev = [SELECT Id,Type,WhoId,Subject,StartDateTime,EndDateTime,OwnerId,WhatId FROM Event WHERE WhatId=: sc.Id];
        system.assertEquals(ev[0].subject, sc.Name);
    }*/
    
    /*public static testMethod void test_eventdelete() {
        
    Contact c = [select id from Contact limit 1];
        
        Sales_Call__c sc = new Sales_Call__c();
        sc.Name = 'myUnitTest3';
        sc.Type__c = 'Sales Call (Face-to-Face)';
        sc.Contact__c = c.Id;
        sc.OwnerId = Userinfo.getUserId();
        sc.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        sc.Location__c = 'Trivandrum';
        insert sc;
        
        List<Event> elist = new List<Event>();
        Set<Id> whatIds = new  Set<Id>();
        Event e = new Event();
        e.Subject = 'Event created';
        e.StartDateTime = system.now();
        e.EndDateTime = system.now() + 1;
        e.ownerId = UserInfo.getUserId();
        e.Type = 'Sales Call (Face-to-Face)';
        e.WhatId = sc.Id;
        e.Location = 'cochi';
        elist.add(e);
        insert elist;
    whatIds.add(elist[0].WhatId);
        Test.startTest();
        EventFieldPopulator.MakeSalescallstartdateNull(elist);
        Test.stopTest();
        List<Event> ev = [SELECT Id,Type,WhoId,Subject,StartDateTime,EndDateTime,OwnerId,WhatId FROM Event WHERE WhatId=: sc.Id];
        System.assertEquals(sc.Contact__c, ev[0].WhoId);
    }*/
}