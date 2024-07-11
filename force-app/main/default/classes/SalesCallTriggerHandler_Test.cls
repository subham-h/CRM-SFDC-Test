/**
 * Author   : Sidhartha
 * Test Class for SalesCallRecordSelector
 * 
 * Ver   Author     Ref Number    Comment
 * ---   ------     ----------    -------
 * 2.0   Neha@TCS   RQ-012152     Removed the reference of Sales and Business call record type
 * 3.0   Ronnie@SF  SPI-100       Removred brand hardcoding
 */

@isTest()
public class SalesCallTriggerHandler_Test {
    
    public static boolean bCreate = true;
    public static integer iNumberOfSalesCall = 1;
    public static list<Sales_Call__c> lstsalesCall;
    //public static Id salesCallRTID = StaticFactory.getRecordTypeIdByName('Sales_Call__c', 'Sales Call');
    //public static Id businessReviewRTID = StaticFactory.getRecordTypeIdByName('Sales_Call__c', 'Business Review');
    public static Id serviceCallRecordTypeId = StaticFactory.getRecordTypeIdByName('Sales_Call__c', 'Service Call');
    
    public static testMethod void createServiceCallWithoutEvent() {
        
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
        lstsalesCall = new list<Sales_Call__c>();
        Sales_Call__c salCall = new Sales_Call__c();
        salCall.Name = 'UnitTest2';
        salCall.RecordTypeId = serviceCallRecordTypeId;
        salCall.Do_Not_Create_Event__c = true; 
        salCall.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        salCall.Contact__c = cont.Id;
        lstsalesCall.add(salCall);
        insert lstsalesCall;
        lstsalesCall[0].Name = 'UnitTest12';
        lstsalesCall[0].StartDateTime__c = system.now()+3;
        lstsalesCall[0].EndDateTime__c = system.now()+ 5;
        lstsalesCall[0].Do_Not_Create_Event__c = false;
        lstsalesCall[0].Type__c = 'Service (Face-to-Face)';
        lstsalesCall[0].Event_Description__c = 'Test123';
        Generic_TriggerHandler.clearLoopCountForAllMethod();
        TriggerExecutionController.skipSalesCallTrigger(false);
        update lstsalesCall;
        List<Event> evt = [select Id from Event where WhatId =:lstsalesCall[0].Id];
        system.assertEquals(1, evt.size());
    }
    
    public static testMethod void createServiceCallWithoutEvent1() {
        
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
        lstsalesCall = new list<Sales_Call__c>();
        Sales_Call__c salCall = new Sales_Call__c();
        salCall.Name = 'UnitTest2';
        salCall.RecordTypeId = serviceCallRecordTypeId;
        salCall.Do_Not_Create_Event__c = true; 
        salCall.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        salCall.Contact__c = cont.Id;
        lstsalesCall.add(salCall);
        insert lstsalesCall;
        lstsalesCall[0].Name = 'UnitTest12';
        Generic_TriggerHandler.clearLoopCountForAllMethod();
        TriggerExecutionController.skipSalesCallTrigger(false);
        update lstsalesCall;
        List<Event> evt = [select Id from Event where WhatId =:lstsalesCall[0].Id];
        system.assertEquals(0, evt.size());
    }
    
    public static testMethod void createServiceCallWithEvent() {
        UserDataGeneratorHelper_Test.initializeSystemAdminUser();  
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
        cont.Email = 'QwertyMynewContact@gmail.com';
        cont.Liner_Brands__c = BrandUtilities.MAERSKLINE;
        TriggerExecutionController.skipAllTriggers(true);
        insert cont;
        TriggerExecutionController.skipAllTriggers(false);
        lstsalesCall = new list<Sales_Call__c>();
        
        Sales_Call__c salCall = new Sales_Call__c();
        salCall.Do_Not_Create_Event__c = false;
        salCall.Name = 'UnitTest1'; 
        salCall.Contact__c = cont.Id;
        salCall.RecordTypeId = serviceCallRecordTypeId;
        salCall.StartDateTime__c = system.now();
        salCall.EndDateTime__c = system.now()+ 1;
        salCall.Type__c = 'Service (Face-to-Face)';
        salCall.OwnerId = Userinfo.getUserId();
        salCall.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        salCall.Location__c = 'Trivandrum';
        salCall.Event_Description__c = 'Testing';
        salCall.Confirmation_Letter__c = 'Test Confirm';
        salCall.Objective__c = 'Test Objective';
        salCall.Persuasive_Selling_Pitch__c = 'Test';
        salCall.Post_Call_Notes__c = 'Test with multiple invitees';
        lstsalesCall.add(salCall);            
        insert lstsalesCall;
        
        List<Event> evt = [select Id from Event where WhatId =:lstsalesCall[0].Id];
        system.assertEquals(1, evt.size());
    }

        /*public static testMethod void createSalesCall() {
        
            UserDataGeneratorHelper_Test.initializeSystemAdminUser();  
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
            cont.Email = 'QwertyMynewContact@gmail.com';
            cont.Liner_Brands__c = BrandUtilities.MAERSKLINE;
            TriggerExecutionController.skipAllTriggers(true);
            insert cont;
            TriggerExecutionController.skipAllTriggers(false);
            lstsalesCall = new list<Sales_Call__c>();
            
            Sales_Call__c salCall = new Sales_Call__c();
            salCall.Name = 'UnitTest1'; 
            salCall.Contact__c = cont.Id;
            salCall.RecordTypeId = salesCallRTID;
            salCall.StartDateTime__c = system.now();
            salCall.EndDateTime__c = system.now()+ 1;
            salCall.Type__c = 'Sales Call (Face-to-Face)';
            salCall.OwnerId = Userinfo.getUserId();
            salCall.Manager__c = UserDataGeneratorHelper_Test.SCLSystemAdminUser.id;
            salCall.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            salCall.Location__c = 'Trivandrum';
            salCall.Event_Description__c = 'Testing';
            salCall.Confirmation_Letter__c = 'Test Confirm';
            salCall.Objective__c = 'Test Objective';
            salCall.Persuasive_Selling_Pitch__c = 'Test';
            salCall.Post_Call_Notes__c = 'Test with multiple invitees';
            lstsalesCall.add(salCall);            
            insert lstsalesCall;
            
            lstsalesCall[0].Name = 'UnitTest123';
            lstsalesCall[0].StartDateTime__c = system.now()+3;
            lstsalesCall[0].EndDateTime__c = system.now()+ 5;
            Generic_TriggerHandler.clearLoopCountForAllMethod();
            TriggerExecutionController.skipSalesCallTrigger(false);
            update lstsalesCall;  
            List<Event> evt = [select Id from Event where WhatId =:lstsalesCall[0].Id];
            system.assertEquals(0, evt.size());
    	}
    
        public static testMethod void createSalesCall1() {
        
            UserDataGeneratorHelper_Test.initializeSystemAdminUser();  
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
            cont.Email = 'QwertyMynewContact@gmail.com';
            cont.Liner_Brands__c = BrandUtilities.MAERSKLINE;
            TriggerExecutionController.skipAllTriggers(true);
            insert cont;
            TriggerExecutionController.skipAllTriggers(false);
            lstsalesCall = new list<Sales_Call__c>();
            
            Sales_Call__c salCall = new Sales_Call__c();
            salCall.Do_Not_Create_Event__c = false;
            salCall.Name = 'UnitTest1'; 
            salCall.Contact__c = cont.Id;
            salCall.RecordTypeId = salesCallRTID;
            salCall.StartDateTime__c = system.now();
            salCall.EndDateTime__c = system.now()+ 1;
            salCall.Type__c = 'Sales Call (Face-to-Face)';
            salCall.OwnerId = Userinfo.getUserId();
            salCall.Manager__c = UserDataGeneratorHelper_Test.SCLSystemAdminUser.id;
            salCall.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            salCall.Location__c = 'Trivandrum';
            salCall.Event_Description__c = 'Testing';
            salCall.Confirmation_Letter__c = 'Test Confirm';
            salCall.Objective__c = 'Test Objective';
            salCall.Persuasive_Selling_Pitch__c = 'Test';
            salCall.Post_Call_Notes__c = 'Test with multiple invitees';
            lstsalesCall.add(salCall);            
            insert lstsalesCall;

            lstsalesCall[0].Status__c = 'Cancelled';
            Generic_TriggerHandler.clearLoopCountForAllMethod();
            TriggerExecutionController.skipSalesCallTrigger(false);
            update lstsalesCall; 
            List<Event> evt = [select Id from Event where WhatId =:lstsalesCall[0].Id];
            system.assertEquals(0, evt.size());
    } */
}