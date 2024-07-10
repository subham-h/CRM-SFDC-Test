/**
* Test class for three batches BatchFCRCaseDetails, BatchFCRTaskDetails
* 
* Version     Date         Owner                                     RQ#                 Description
******************************************************************************************************************  
* 1.0         8/07/2015    Sandhya.Sambasivan@ust-global.com         #RQ-001479          Code created as part of #RQ-001479
* 2.0         23/07/2015   Sandhya.Sambasivan@ust-global.com         #RQ-001740          Fix for Case FCR Batch Apex test class           
* 3.0         01/09/2015   Sunu.Paul@ust-global.com                  #RQ-002004          Increased Code Coverage
* 4.0         04/11/2015   Sandhya.Sambasivan@ust-global.com         #RQ-001016          Changed Case Channel ML.com to Website
* 5.0         08/04/2016   Sandhya.Sambasivan@ust-global.com         #RQ-003320          Replace MessageDate with CreatedDate for email message
* 6.0         23/12/2016   Nisha.Arjunan@ust-global.com              #RQ-004570          Removed email related enteries             
* 7.0         04/06/2017   Hitha.Vasudevan@UST                       #RQ-004653          Added valid country and city in to increase code coverage 
* 8.0         07/06/2022   Ronnie@SF                                 SPI-100             Removed brand hardcodings
*/

@isTest
private class BatchFCR_Test {
    
    static Account testAccount;
    static Account testAccount2;
    static Entitlement ent1, ent2, ent3;
    static Geography__c geoRec;
    static Geography__c geoCity;
    static BDA__c clu;
    //static BDA_Geography__c BDAGeo;
    public static BDA__c testCluster = new BDA__C ();
    public static Geography__c testCountry = new Geography__c();
    public static BDA_Geography__c bdaGeo = new BDA_Geography__c();
    
    //Call method to create Test Users
    static 
    {
        UserDataGeneratorHelper_Test.initializeIntegrationUser();  
        
    }
    
    static
    {
        //Insert Geography
        
        testCluster.Name = 'Asia';
        testCluster.Type__c = 'Cluster';
        testCluster.BDA_Code__c = 'dsaewet67';
        testCluster.GEO_ID__c= 'dsaewetwer';
        testCluster.Active__c  =  true;
        insert testCluster;
        
        testCountry.Name = 'India';
        testCountry.Active__c =true;
        testCountry.GEO_Code__c = 'IN';
        testCountry.GEO_ID__c = '10Z2W9Zkjh3q4cf6';
        testCountry.Is_Port__c = false;
        testCountry.Type_Of_Location__c = 'Country';
        Database.insert(testCountry);
        
        geoCity = new Geography__c();
        geoCity.Name = 'Kochi';
        geoCity.Type_Of_Location__c = 'City';
        geoCity.GEO_ID__c = '0KJFDUGMMEEF3';
        geoCity.Parent_Geography__c = testCountry.Id;
        Database.Insert(geoCity);
        
        bdaGeo.BDA__c = testCluster.Id;
        bdaGeo.Geography__c = testCountry.Id;
        insert bdaGeo;
    }
    
    static 
    {
        //Create test account data
        testAccount = new Account(Name = 'UniteTestAccountName',
                                  BillingStreet = '403 McAdoo St',
                                  BillingCity = 'Kochi',
                                  BillingState = 'NM',
                                  BillingPostalCode = '87901',
                                  BillingCountry = 'India',
                                  //Cluster_Name__c = clu.ID,
                                  Country__c=testCountry.id);
        Database.Insert(testAccount);
        Id unassignedRTId = StaticFactory.getRecordTypeIdByName('Account', 'Unassigned');
        testAccount2=new Account(Name = 'Test Account',
                                 Country__c=testCountry.id,
                                 RecordTypeId=unassignedRTId);
        Database.Insert(testAccount2);
    }
    
    static 
    {
        List <Entitlement> entList = new List <Entitlement>();
        ent1 = new Entitlement(Name = 'Default Entitlement', Liner_Brand_Logic__c = 'Default',
                               AccountId = testAccount.Id, StartDate = system.today(), EndDate = system.today()+30);
        entList.add(ent1);
        ent2 = new Entitlement(Name = 'Brand Entitlement', Liner_Brand_Logic__c = BrandUtilities.MAERSKLINE,
                               AccountId = testAccount.Id, StartDate = system.today(), EndDate = system.today()+30);
        entList.add(ent2);
        ent3 = new Entitlement(Name = 'Brand Entitlement', Liner_Brand_Logic__c = BrandUtilities.MAERSKLINE,
                               AccountId = testAccount2.Id, StartDate = system.today(), EndDate = system.today()+30);
        
        entList.add(ent3);
        Database.Insert(entList);
    }
    
    /* Test scenario : Case Channel : Telephone and incoming Email and Task interactions.
Before Case is set as Closed Resolved, inbound interaction happens. The counters should 
get the count of email and call interactions*/
    static testmethod void testInboundInteractionForSingleCase() {  //FCR Fix
        
        System.runAs(UserDataGeneratorHelper_Test.integrationUser){
            Test.StartTest();
            
            //Create test contact data
            Contact con = new Contact();
            con.FirstName = 'UnitTestContactFName';
            con.LastName ='UnitTestContactLName';
            con.AccountId = testAccount2.id;
            con.Unique_User_ID__c='ZZZ000';
            con.Liner_Brands__c = BrandUtilities.MAERSKLINE;
            con.Email= 'TestFCRone@maersk.com';
            con.IsDuplicate__c=FALSE;  
            con.Country__c = testCountry.Id;      
            Database.insert(con);
            
            //Create test case data
            Case TestCase = new Case();
            TestCase.Subject= 'Test';
            TestCase.Case_Visibility__c='Multi-Carrier';
            Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
            TestCase.RecordTypeId = extCaseRTId;
            TestCase.Liner_Brand__c= BrandUtilities.MAERSKLINE;
            TestCase.SuppliedEmail= 'TestFCRone@maersk.com';
            TestCase.Status ='New';
            TestCase.Description= 'Test';
            TestCase.Direction__c= 'Export';
            TestCase.Case_Channel__c= 'Telephone';
            TestCase.Origin='MSLUSEXP';
            TestCase.ContactId= con.id;
            TestCase.Country__c=testCountry.Id; 
            TestCase.Cluster__c =testCluster.Id; 
            TestCase.type='Booking';
            TestCase.Sub_Type__c='New Booking Request'; 
            Database.insert(TestCase);
            
            //FCR Fix
            List<EmailMessage> emList = new List<EmailMessage>();
            for(Integer i = 0; i < 2; i++){
                EmailMessage email = new EmailMessage();
                email.FromAddress = 'TestFCRone@maersk.com';
                email.Incoming = true;
                email.ParentId = TestCase.Id;
                email.Status = '0';
                email.Subject = 'Test';
                email.MessageDate = System.today() ;
                emList.add(email);
            }
            
            Database.insert(emList);
            
            //Create a call activity
            Task taskCreate = new Task(Type = 'Call',Direction__c='Inbound',WhatId = TestCase.Id,Status = 'In Progress',Priority = 'Normal',Subject = 'Dummy subject' ,ActivityDate = system.today());
            Database.Insert(taskCreate);
            taskCreate.Type ='Call';
            Database.Update(taskCreate);
            
            //Case status is set as 'Closed - Resolved'
            TestCase.Resolution_Summary__c = 'Solved';
            TestCase.Status = 'Closed - Resolved';
            TestCase.Reason_For_Case__c = 'Booking Request';
            TestCase.OwnerId = UserInfo.getUserId();
            Database.update(TestCase);      
            
            // Execute the batch
            BatchFCRCaseDetails c = new BatchFCRCaseDetails();
            Database.executeBatch(c);
            Test.stopTest();
            
            //Verify that the count of email and calls are equal to the FCR_Inbound_Calls__c and FCR_Inbound_Contact_Emails__c field in Case.
            Case caseRec = [SELECT Id, FCR_Inbound_Contact_Emails__c,FCR_Inbound_Calls__c FROM Case WHERE Id =: TestCase.Id];
            System.assertEquals(1, caseRec.FCR_Inbound_Calls__c);
            System.assertEquals(2, caseRec.FCR_Inbound_Contact_Emails__c);  
        }
    }
    
    // Test scenario : Case Channel : Email and no incoming Email and Task interactions.Counters should remain zero
    static testmethod void testCaseWithNoInteractions() {
        
        System.runAs(UserDataGeneratorHelper_Test.integrationUser){
            Test.StartTest();
            
            //Insert Geography
            Geography__c geo = new Geography__c();
            geo.Name = 'TestGeography';
            geo.Type_Of_Location__c='Country';
            Database.insert(geo);
            
            //Insert contact 
            Contact con = new Contact();
            con.FirstName = 'UnitTestContactFName';
            con.LastName ='UnitTestContactLName';
            con.AccountId = testAccount.id;
            con.Liner_Brands__c = BrandUtilities.MAERSKLINE;
            con.Email= 'TestFCRone@gmail.com';
            con.IsDuplicate__c=FALSE;  
            con.Country__c = geo.Id;      
            Database.insert(con);
            
            //Insert Case
            Case TestCase = new Case();
            TestCase.Case_Visibility__c='Multi-Carrier';
            TestCase.Subject= 'Test';
            Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
            TestCase.RecordTypeId = extCaseRTId;
            TestCase.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            TestCase.SuppliedEmail= 'TestFCRone@gmail.com';
            TestCase.Status ='New';
            TestCase.Description= 'Test';
            TestCase.Direction__c= 'Export';
            TestCase.Case_Channel__c= 'Email';
            TestCase.Origin='MSLUSEXP';
            TestCase.Reason_For_Case__c = 'Booking Request';
            TestCase.ContactId= con.id;
            TestCase.Country__c=testCountry.Id;
            TestCase.Cluster__c = testCluster.Id;   
            TestCase.type='Booking';
            TestCase.Sub_Type__c='New Booking Request'; 
            Database.insert(TestCase);
            
            // Case status is updated to 'Closed - Resolved'
            TestCase.Resolution_Summary__c = 'Solved';
            TestCase.Status = 'Closed - Resolved';
            Database.Update(TestCase);  
            
            // Execute Batch
            BatchFCRCaseDetails c = new BatchFCRCaseDetails();
            Database.executeBatch(c);
            
            //Verify the that the counters remain zero
            Case caseRec = [SELECT Id, FCR_Inbound_Contact_Emails__c,FCR_Inbound_Calls__c FROM Case WHERE Id =: TestCase.Id];
            System.assertEquals(0, caseRec.FCR_Inbound_Calls__c);
            System.assertEquals(0, caseRec.FCR_Inbound_Contact_Emails__c );
            TestCase.FCR_Process_Date__c = null;
            Database.update(TestCase);
            Delete geo;
            
            // Execute Batch
            BatchFCRCaseDetails errorCaseUpdate = new BatchFCRCaseDetails();
            Database.executeBatch(errorCaseUpdate);
            Test.stopTest();
        }
    }
    
    /* Test scenario: Case Channel : Website and one inbound call interaction and no email activity on batch run date*/    
    static testmethod void testForMLChannel() {
        System.runAs(UserDataGeneratorHelper_Test.integrationUser) {
            //Insert Contact
            Contact con = new Contact();
            con.FirstName = 'UnitTestContactFName';
            con.LastName ='UnitTestContactLName';
            con.AccountId = testAccount.id;
            con.Liner_Brands__c = BrandUtilities.MAERSKLINE;
            con.Email= 'TestFCRone@gmail.com';
            con.IsDuplicate__c=FALSE;  
            con.Country__c = testCountry.Id;      
            Database.insert(con);
            
            //Insert Case 
            Case TestCase = new Case();
            TestCase.Case_Visibility__c='Multi-Carrier';
            TestCase.Subject= 'Test';
            Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
            TestCase.RecordTypeId = extCaseRTId;
            TestCase.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            TestCase.SuppliedEmail= 'TestFCRone@gmail.com';
            TestCase.Status ='New';
            TestCase.Description= 'Test';
            TestCase.Direction__c= 'Export';
            TestCase.Case_Channel__c= 'Website'; //#RQ-001016 - Changed ML.com to Website
            TestCase.Origin='MSLUSEXP';
            TestCase.Reason_For_Case__c = 'Booking Request';
            TestCase.ContactId= con.id;
            TestCase.Country__c=testCountry.Id;
            TestCase.Cluster__c =testCluster.Id;   
            TestCase.type='Booking';
            TestCase.Sub_Type__c='New Booking Request'; 
            
            Database.Insert(TestCase);
            
            
            //Insert Task for 3 days starting today
            List<Task>taskInsertList = new List<Task>();
            for (Integer i = 0; i<3; i++) {
                Task taskCreate = new Task(Type = 'Call',
                                           Direction__c = 'Inbound',
                                           WhatId = TestCase.Id,
                                           Status = 'In Progress',
                                           Priority = 'Normal',
                                           Subject = 'Dummy subject',
                                           ActivityDate = System.today()+i);
                taskInsertList.add(taskCreate);
            }
            Database.Insert(taskInsertList); 
            Test.StartTest();
            //Case Status is updated to 'Closed - Resolved'
            TestCase.Resolution_Summary__c = 'Solved';
            TestCase.Status = 'Closed - Resolved';
            Database.update(TestCase);     
            
            //Create an inbound email activity with future date
            EmailMessage email = new EmailMessage();
            email.FromAddress = 'TestFCRone@maersk.com';
            email.Incoming = true;
            email.ParentId = TestCase.Id;
            email.Status = '0';
            email.Subject = 'Test';
            email.MessageDate = System.today(); // Create an email message that was sent 8 days ago...
            email.CreatedDate = System.today();
            Database.insert(email);
            //Test.setCreatedDate(email.Id, System.today()+3); 
            
            for (Task t : taskInsertList){
                t.Type = 'Call';   
            }
            Database.Update(taskInsertList);
            
            //Execute batch
            BatchFCRCaseDetails c = new BatchFCRCaseDetails();
            Database.executeBatch(c);
            Test.stopTest();
            
            //Verify that the call count shows 1 since rest of tasks created on a later date and no inbound email count
            /*Case caseRec = [SELECT Id, FCR_Inbound_Calls__c,FCR_Inbound_Contact_Emails__c FROM Case WHERE Id =: TestCase.Id limit 1];
System.assertEquals(0, caseRec.FCR_Inbound_Contact_Emails__c);
System.assertEquals(3, caseRec.FCR_Inbound_Calls__c);*/
        }
    }
    
    /* Test scenario: Case Channel : Website and one inbound call interaction and no email activity on batch run date*/    
    static testmethod void testBulkForMLChannel() {
        
        System.runAs(UserDataGeneratorHelper_Test.integrationUser) {
            Set<Id>caseIds = new Set<Id>();
            
            //Insert Contact
            Contact con = new Contact();
            con.FirstName = 'UnitTestContactFName';
            con.LastName ='UnitTestContactLName';
            con.AccountId = testAccount.id;
            con.Liner_Brands__c = BrandUtilities.MAERSKLINE;
            con.Email= 'TestFCRone@gmail.com';
            con.IsDuplicate__c=FALSE;  
            con.Country__c = testCountry.Id;      
            Database.insert(con);
            
            //Insert Case 
            List<Case>caseList = new List<Case>();
            for (Integer i = 0 ; i < 10 ; i++){
                Case TestCase = new Case();
                TestCase.Case_Visibility__c='Multi-Carrier';
                TestCase.Subject= 'Test';
                Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
                TestCase.RecordTypeId = extCaseRTId;
                TestCase.Liner_Brand__c = BrandUtilities.MAERSKLINE;
                TestCase.SuppliedEmail= 'TestFCRone@gmail.com';
                TestCase.Status ='New';
                TestCase.Description= 'Test';
                TestCase.Direction__c= 'Export';
                TestCase.Case_Channel__c= 'Website'; //#RQ-001016 - Changed ML.com to Website
                TestCase.Origin='MSLUSEXP';
                TestCase.ContactId= con.id;
                TestCase.Country__c=testCountry.Id; 
                TestCase.Cluster__c =testCluster.Id;  
                TestCase.type='Booking';
                TestCase.Sub_Type__c='New Booking Request';  
                TestCase.Reason_For_Case__c = 'Booking Request';
                caseList.add(TestCase);
            }
            Database.Insert(caseList);
            //Insert Task for 3 days starting today
            List<Task>taskInsertList = new List<Task>();
            for (Integer i = 0; i< 10; i++) {
                Task taskCreate = new Task(Type = 'Call',
                                           Direction__c = 'Inbound',
                                           WhatId = caseList[i].Id,
                                           Status = 'In Progress',
                                           Priority = 'Normal',
                                           Subject = 'Dummy subject',
                                           ActivityDate = system.today());
                taskInsertList.add(taskCreate);
            }
            Test.StartTest();
            Database.Insert(taskInsertList); 
            
            //Case Status is updated to 'Closed - Resolved'
            for (Case c : caseList) {
                c.Resolution_Summary__c = 'Solved';
                c.Status = 'Closed - Resolved';
                caseIds.add(c.Id);
            }
            //Database.Update(caseList);     
            
            //Create an inbound email activity for future date
            List<EmailMessage>emList = new List<EmailMessage>();
            for (Integer j = 0; j < 10 ; j++) {
                EmailMessage email = new EmailMessage();
                email.FromAddress = 'TestFCRone@maersk.com';
                email.Incoming = true;
                email.ParentId = caseList[j].Id;
                email.Status = '0';
                email.Subject = 'Test';
                email.MessageDate = System.today()+3 ; // Create an email message that was sent 8 days ago...
                emList.add(email);
            } 
            Database.insert(emList);
            for (Task t : taskInsertList){
                t.Type = 'Call';
            }
            Database.update(taskInsertList);
            
            //Execute batch
            BatchFCRCaseDetails c = new BatchFCRCaseDetails();
            Database.executeBatch(c);
            Test.stopTest();
            
            //Verify that the call count shows 1 since rest of tasks created on a later date and no inbound email count
            for (Case caseRec : [SELECT Id, FCR_Inbound_Calls__c,FCR_Inbound_Contact_Emails__c FROM Case WHERE Id IN :caseIds]) {
                //System.assertEquals(0, caseRec.FCR_Inbound_Contact_Emails__c);
                //System.assertEquals(1, caseRec.FCR_Inbound_Calls__c);
            }
        }   
    }
    
    /* Test scenario : Customer calls in after the Case is closed */    
    static testmethod void logCallWithNoPreviousActivity() {
        
        Set<Id>caseIds = new Set<Id>();
        System.runAs(UserDataGeneratorHelper_Test.integrationUser) {
            
            //create test contact data
            Contact con = new Contact();
            con.FirstName = 'UnitTestContactFName';
            con.LastName ='UnitTestContactLName';
            con.AccountId = testAccount.id;
            con.Liner_Brands__c = BrandUtilities.MAERSKLINE;
            con.Email= 'TestFCRone@gmail.com';
            con.IsDuplicate__c=FALSE;  
            con.Country__c = testCountry.Id;      
            Database.insert(con);
            
            List<Case>caseList = new List<Case>();
            //create test case data
            for (Integer k = 0; k < 10 ; k++){
                Case TestCase = new Case();
                TestCase.Case_Visibility__c='Multi-Carrier';
                TestCase.Subject= 'Test';
                Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
                TestCase.RecordTypeId = extCaseRTId;
                TestCase.Liner_Brand__c = BrandUtilities.MAERSKLINE;
                TestCase.SuppliedEmail= 'TestFCRone@gmail.com';
                TestCase.Status ='New';
                TestCase.Description= 'Test';
                TestCase.Direction__c= 'Export';
                TestCase.Case_Channel__c= 'Telephone';
                TestCase.Origin='MSLUSEXP';
                TestCase.ContactId= con.id;
                TestCase.Country__c=testCountry.Id;
                TestCase.Cluster__c =testCluster.Id;   
                TestCase.type='Booking';
                TestCase.Sub_Type__c='New Booking Request'; 
                TestCase.FCR_Process_Date__c = System.now();
                TestCase.FCR_Inbound_Contact_Emails__c = 0;
                TestCase.FCR_Inbound_Calls__c = 0;
                TestCase.Reason_For_Case__c = 'Booking Request';
                caseList.add(TestCase);
            }
            
            Database.Insert(caseList);
            
            for (Integer n = 0 ; n < 10 ; n++){
                caseList[n].Resolution_Summary__c = 'Solved';
                caseList[n].Status = 'Closed - Resolved';
                caseList[n].Date_First_Resolved__c = System.now()-1;  
                caseIds.add(caseList[n].Id);
            }
            Test.StartTest();
            
            Database.Update(caseList);  
            
            List<Task> taskList = new List<Task>();         
            for (Integer i=0 ; i< 10; i++) {
                Task createTask = new Task(Type = 'Call',
                                           Direction__c='Inbound',
                                           WhatId = caseList[i].Id,
                                           Status = 'In Progress',
                                           Priority = 'Normal',
                                           Subject = 'Dummy subject',
                                           ActivityDate = system.today()+i);
                taskList.add(createTask);
            }
            Database.insert(taskList); 
            
            BatchFCRTaskDetails e = new BatchFCRTaskDetails ();
            Database.executeBatch(e);
            Test.stopTest();
            
            //Verify that the FCR_Post_Closure_Activity_Date__c is the email with earliest MessageDate
            Task t = [SELECT Id, CreatedDate FROM Task WHERE Id = :taskList[0].Id];
            for (Case caseRec : [SELECT Id, FCR_Post_Closure_Activity_Date__c FROM Case WHERE Id IN: caseIds]){
                System.assertEquals(t.CreatedDate, caseRec.FCR_Post_Closure_Activity_Date__c);
            }
        }
    }
    
    /* Test scenario : Customer calls in after the Case is closed and a previous activity already exists */    
    static testmethod void logCallWithPreviousActivity() {
        
        System.runAs(UserDataGeneratorHelper_Test.integrationUser){
            Test.startTest();
            
            //create test contact data
            Contact con = new Contact();
            con.FirstName = 'UnitTestContactFName';
            con.LastName ='UnitTestContactLName';
            con.AccountId = testAccount.id;
            con.Liner_Brands__c = BrandUtilities.MAERSKLINE;
            con.Email= 'TestFCRone@gmail.com';
            con.IsDuplicate__c=FALSE;  
            con.Country__c = testCountry.Id;      
            Database.insert(con);
            
            //create test case data
            Case TestCase = new Case();
            TestCase.Subject= 'Test';
            TestCase.Case_Visibility__c='Multi-Carrier';
            Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
            TestCase.RecordTypeId = extCaseRTId;
            TestCase.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            TestCase.SuppliedEmail= 'TestFCRone@gmail.com';
            TestCase.Status ='New';
            TestCase.Description= 'Test';
            TestCase.Direction__c= 'Export';
            TestCase.Case_Channel__c= 'Telephone';
            TestCase.Origin='MSLUSEXP';
            TestCase.ContactId= con.id;
            TestCase.Country__c=testCountry.Id;
            TestCase.Cluster__c =testCluster.Id;   
            TestCase.type='Booking';
            TestCase.Sub_Type__c='New Booking Request'; 
            TestCase.FCR_Process_Date__c = System.today();
            TestCase.Reason_For_Case__c = 'Booking Request';
            TestCase.FCR_Post_Closure_Activity_Date__c = System.today()+10;
            
            Database.insert(TestCase);
            
            //Insert Case to 'Closed - Resolved'
            TestCase.Resolution_Summary__c = 'Solved';
            TestCase.Status = 'Closed - Resolved';
            TestCase.Date_First_Resolved__c = System.Now().addMinutes(-7) ; 
            Database.update(TestCase); 
            
            //Insert task records
            Task createTask = new Task(Type = 'Call',
                                       Direction__c='Inbound',
                                       WhatId = TestCase.Id,
                                       Status = 'In Progress',
                                       Priority = 'Normal',
                                       Subject = 'Dummy subject');
            Database.insert(createTask);
            List<Task> taskList = new List<Task>();
            for (Integer m = 0; m <4 ; m++){
                Task taskOther = new Task(Type = 'Call',
                                          Direction__c='Inbound',
                                          WhatId = TestCase.Id,
                                          Status = 'In Progress',
                                          Priority = 'Normal',
                                          Subject = 'Dummy subject' ,
                                          ActivityDate = system.today()+m);
                taskList.add(taskOther);
            }
            Database.insert(taskList);
            //Execute Batch 
            BatchFCRTaskDetails e = new BatchFCRTaskDetails ();
            Database.executeBatch(e);
            
            Test.stopTest();
            
            //Verify the results
            Case caseRec = [SELECT Id, FCR_Post_Closure_Activity_Date__c FROM Case WHERE Id = :TestCase.Id];
            Task t = [SELECT Id, CreatedDate FROM Task WHERE Id =:createTask.Id];
            //System.assertEquals(t.CreatedDate, caseRec.FCR_Post_Closure_Activity_Date__c);
        }
    }
    
    //FCR Fix
    static testmethod void emailActivityWithPreviousActivity() {
        
        Set<Id>caseIds = new Set<Id>();
        System.runAs(UserDataGeneratorHelper_Test.integrationUser){
            
            //Insert contact
            Contact con = new Contact();
            con.FirstName = 'UnitTestContactFName';
            con.LastName ='UnitTestContactLName';
            con.AccountId = testAccount.id;
            con.Liner_Brands__c = BrandUtilities.MAERSKLINE;
            con.Email= 'TestFCRone@gmail.com';
            con.IsDuplicate__c=FALSE;  
            con.Country__c = testCountry.Id;    
            Database.insert(con);
            
            //Insert case
            List<Case>caseList = new List<Case>();
            for (Integer i = 0 ; i < 1 ; i++){
                Case TestCase = new Case();
                TestCase.Case_Visibility__c='Multi-Carrier';
                TestCase.Subject= 'Test';
                TestCase.Liner_Brand__c = BrandUtilities.MAERSKLINE;
                TestCase.SuppliedEmail= 'TestFCRone@gmail.com';
                TestCase.Status ='New';
                TestCase.Description= 'Test';
                TestCase.Direction__c= 'Export';
                TestCase.Case_Channel__c= 'Website'; //#RQ-001016 - Changed ML.com to Website
                TestCase.Origin='MSLUSEXP';
                TestCase.ContactId= con.id;
                TestCase.Country__c=testCountry.Id;   
                TestCase.type='Booking';
                TestCase.Sub_Type__c='Amend Booking Details';
                TestCase.Reason_For_Case__c = 'Booking Instructions Not Followed/Incorrect Booking';
                TestCase.FCR_Process_Date__c = System.today(); 
                //TestCase.FCR_Post_Closure_Activity_Date__c = System.today()+8;
                caseList.add(TestCase);
            }
            test.startTest();
            Database.insert(caseList);
            test.stopTest();
            
            //Case Status is updated to 'Closed - Resolved'
            for (Case c : caseList){
                c.Resolution_Summary__c = 'Solved';
                c.Status = 'Closed - Resolved';
                caseIds.add(c.Id);
            }
            Database.update(caseList);
            
            
            //Create an inbound email activity for today
            List<EmailMessage>emList = new List<EmailMessage>();
            for (Integer j = 0; j <1 ; j++){
                EmailMessage email = new EmailMessage();
                email.FromAddress = 'TestFCRone@maersk.com';
                email.Incoming = true;
                email.ParentId = caseList[0].Id;
                email.Status = '0';
                email.Subject = 'Test';
                email.MessageDate = System.Now().addMinutes(7) ; // Create an email message that was sent 8 days ago...
                emList.add(email);
            } 
            Database.insert(emList);
            /*for (EmailMessage e :emList) {
Test.setCreatedDate(e.Id, System.Now().addMinutes(7));
}*/
            
            //Create an inbound email activity for future date
            List<EmailMessage>emListForFuture = new List<EmailMessage>();
            for (Integer k = 0; k <1 ; k++){
                EmailMessage email = new EmailMessage();
                email.FromAddress = 'TestFCRone@maersk.com';
                email.Incoming = true;
                email.ParentId = caseList[0].Id;
                email.Status = '0';
                email.Subject = 'Test';
                email.MessageDate = System.today()+3; // Create an email message that was sent 8 days ago...
                emListForFuture.add(email);
            } 
            Database.insert(emListForFuture);
            for (EmailMessage e :emListForFuture) {
                Test.setCreatedDate(e.Id, System.today()+3);
            }
            
            Case cUpdated = [SELECT Id, FCR_Post_Closure_Activity_Date__c FROM Case WHERE Id = :caseList[0].Id];
            EmailMessage emUpdated = [Select Id, CreatedDate from EmailMessage Where Id =:emList[0].Id];
            //System.assertEquals(cUpdated.FCR_Post_Closure_Activity_Date__c, emUpdated.CreatedDate);
        }
    }
    
}