/*
 * Purpose  : Test Batch_RelinkContactChilds.
 * 
 * SPI-100     23/09/2022   Ronnie@SF               Removed brand hardcoding
 */
@isTest
private class Batch_RelinkContactChilds_Test {
    
    static testMethod void test_Batch_RelinkContactChilds() {
        System.runAs(new user(ID = UserInfo.getUserID())){
                //Create Geography for Account
        Geography__c testGeo =  new Geography__c();
        testGeo.Active__c = true;
        testGeo.Type_Of_Location__c = 'Country';
        testGeo.GEO_ID__c = '10Z2W9ZTH2RUM';
        testGeo.Name = 'INDIA';
        insert testGeo;        
        }
        
        List<User> lstUser = new List<User>();
        Id profileId = [select id from profile where name='System Administrator'].id;
    	User userIterator = new User();
        userIterator.FirstName = 'Automated';
        userIterator.LastName = 'Process';
        userIterator.alias = 'tstUser';
        userIterator.ProfileId = profileId;
        // fix on production validation error, changed the email domain to maersk.com
        userIterator.email='ContactData_Test'+ '@maersk.com';
        userIterator.TimeZoneSidKey = 'America/Los_Angeles';
        userIterator.LocaleSidKey = 'en_US';
        userIterator.LanguageLocaleKey = 'en_US';
        userIterator.EmailEncodingKey = 'UTF-8';
        //userIterator.country='UNITED STATES';
        userIterator.IsActive =true;
        //userIterator.Quoting_Tool__c='AFLS';
        userIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        userIterator.MLL__C = True;
        userIterator.Country = 'INDIA';
        userIterator.Cluster__c = 'India and Bangladesh Area';    
        //userIterator.Cluster__c='Caribbean Sea Area';
        userIterator.username='userinstance'+'@noemail.com';
        userIterator.Geo_ID__c = '10Z2W9ZTH2RUM';
        lstUser.add(userIterator);
        
        User userIterator1 = new User();
        userIterator1.FirstName = 'Automated1';
        userIterator1.LastName = 'Process';
        userIterator1.alias = 'tstUser';
        userIterator1.ProfileId = profileId;
        // fix on production validation error, changed the email domain to maersk.com
        userIterator1.email='ContactData_Test1'+ '@maersk.com';
        userIterator1.TimeZoneSidKey = 'America/Los_Angeles';
        userIterator1.LocaleSidKey = 'en_US';
        userIterator1.LanguageLocaleKey = 'en_US';
        userIterator1.EmailEncodingKey = 'UTF-8';
        userIterator1.Geo_ID__c = '10Z2W9ZTH2RUM';
       // userIterator1.country='UNITED STATES';
        userIterator1.IsActive =true;
        //userIterator.Quoting_Tool__c='AFLS';
        userIterator1.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        userIterator1.MLL__C = True;
        userIterator1.Country = 'INDIA';
        userIterator1.Cluster__c = 'India and Bangladesh Area';    
        //userIterator1.Cluster__c='Caribbean Sea Area';
        userIterator1.username='userinstance1'+'@noemail.com';
        lstUser.add(userIterator1);
        insert lstUser;
        
        
        
        
        system.runAs(lstUser[0]){
       Geography__c testGeo =[Select Id from Geography__c limit 1];
        // Create Account For Contact
        Account testAcc = new Account();
        testAcc.RecordTypeId= '012D0000000kJKx';
        testAcc.name = 'TESTACC';
        testAcc.Country__c = testGeo.Id;
        testAcc.BillingCity = 'MUMBAI';
        insert testAcc;
        
        // create customer contact
        Contact testCon =  new Contact();
        testCon.LastName = 'CON';
        testCon.FirstName = 'TEST';
        testCon.AccountId = testAcc.Id;
        testCon.RecordTypeId= '012D0000000Qoon';
        testCon.Email = 'TestContact@test.com';
        testCon.Phone = '+44 123412';           
        testCon.Liner_Brands__c = BrandUtilities.MAERSKLINE;
        testCon.Country__c = testAcc.Country__c;
        testCon.Contact_Status__c = 'Active';    
    	insert testCon;
        	
    	//ContactData_Test.createCustomerContacts();
    	//list<Contact> lstContacts2 = ContactData_Test.lstContacts;
		Id masterContactId = testCon.Id;
		system.debug('AANOOFQ'+system.Limits.getQueries());
    	Id newContactId = testCon.Id;
    	Id newContactAccountId = testCon.AccountId;
    	
        //create Case Data
       Case testCase = new Case();
        testCase.AccountId = newContactAccountId ;
        testCase.ContactId = newContactId;
        testCase.Status = 'New';
        testCase.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        testCase.Country__c =  testGeo.Id; 
        testCase.Type = 'Booking';
        testCase.Sub_Type__c = 'Amend Booking Details';
        testcase.Cargo_Classification__c='US Military (USM)';
        insert testCase;
        
        //create Opp data        
        Opportunity Opp = new Opportunity(
            Name = 'OpportunityTestData',
            AccountId = newContactAccountId, 
            CloseDate = system.today(),
            Controlled__c = 'Controlled',
            Type = 'Transactional',
            Cargo_Type__c = 'Dry',
            First_Shipment_Date__c = date.today() + 10,
            Last_Shipment_Date__c = date.today() + 30,
            StageName = 'Identifying',
            Primary_Contact__c = masterContactId,
            Liner_Brand__c = BrandUtilities.MAERSKLINE,
            Opportunity_contains_Dangerous_Goods__c = 'No',
            Expected_Handling_Rounds__c = 1);
                 insert Opp;
        
            Sales_Call__c testSalesCall = new Sales_Call__c();
        	testSalesCall.Name = 'UnitTest1'; 
            testSalesCall.Contact__c = masterContactId;
            testSalesCall.RecordTypeId = '01257000000YTr1';
            testSalesCall.StartDateTime__c = system.now();
            testSalesCall.EndDateTime__c = system.now()+ 1;
            testSalesCall.Type__c = 'Service (Face-to-Face)';
            testSalesCall.OwnerId = userIterator.Id;
            testSalesCall.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            testSalesCall.Location__c = 'Trivandrum';
            testSalesCall.Event_Description__c = 'Testing';
            testSalesCall.Manager__c = UserInfo.getUserId();
            testSalesCall.Confirmation_Letter__c = 'Test Confirm';
            testSalesCall.Objective__c = 'Test Objective';
            testSalesCall.Persuasive_Selling_Pitch__c = 'Test';
            testSalesCall.Post_Call_Notes__c = 'Test with multiple invitees'; 
         	testSalesCall.Manager__c=lstUser[1].Id;
         testSalesCall.Do_Not_Create_Event__c = false;
         insert testSalesCall;
            
            
            
        ActivityData_Test.bCreate = false;
    	ActivityData_Test.createTasks();
    	list<Task> lstTasks = ActivityData_Test.lstTasks;
    	for(Task taskIterator : lstTasks) {
    		taskIterator.WhoId = masterContactId;
    		taskIterator.WhatId = newContactAccountId;
    	}
    	insert lstTasks;
    	
    	ActivityData_Test.createEvents();
    	list<Event> lstEvents = ActivityData_Test.lstEvents;
    	for(Event eventIterator : lstEvents) {
    		eventIterator.WhoId = masterContactId;
    		eventIterator.WhatId = newContactAccountId;
    	}
    	insert lstEvents;
    	
    	Relink_Contact_Childs__c relink = new Relink_Contact_Childs__c(Name = 'Batch 00001', Master_Contact_Id__c = masterContactId, New_Contact_Id__c = newContactId, New_Contacts_Account_Id__c = newContactAccountId, Status__c = 'New');
    	insert relink;
    	
        Test.startTest();
    	// Test Count
    	Database.executeBatch(new Batch_RelinkContactChilds('Count', null), 1);
    	
    	// Test Run
    	String strQuery = 'select Id, Master_Contact_Id__c, New_Contact_Id__c, New_Contacts_Account_Id__c, Cases__c, Opportunities__c, Sales_Calls__c, Tasks__c, Events__c, Status__c from Relink_Contact_Childs__c where Status__c = \'New\' order by Name';
    	Database.executeBatch(new Batch_RelinkContactChilds('Run', strQuery), 1);
    	Test.stopTest();
        
        }
        
    	/*OpportunityData_Test.bCreate = false;
    	OpportunityData_Test.createMaersklineOpportunities();
    	list<Opportunity> lstOpps = OpportunityData_Test.lstOpportunities;
    	for(Opportunity oppIterator : lstOpps) {
    		oppIterator.Primary_Contact__c = masterContactId;
    		oppIterator.AccountId = newContactAccountId;
    	}
    	insert lstOpps;*/
    	//create User for Manager
    	
        // create Sales Call Data 
            
    	/*SalesCallData_Test.bCreate = false;
    	SalesCallData_Test.createSalesCallWithOutEvent();
    	list<Sales_Call__c> lstSalesCalls = SalesCallData_Test.lstsalesCall;
    	for(Sales_Call__c scIterator : lstSalesCalls) {
    		scIterator.Contact__c = masterContactId;
    		scIterator.Account__c = newContactAccountId;
    	}
    	insert lstSalesCalls;*/
    	
    	
    }
    
}