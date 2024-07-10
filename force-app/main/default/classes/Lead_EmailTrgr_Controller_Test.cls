/**
 * This is a test class created to cover below class :
 *                1.   bINS_bUPD_emailValidationLead.trigger
 *
 * Version   Date        Owner                                Ref Number    Description
 **************************************************************************************************************************************
 * 1.0    17/5/2014    UST                                                  Code Modified as part of Cleanup Activity
 * 2.0    12/02/2015   Ranjini.Janardhanan@ust-global.com     #RQ-000875    Removed profile Name hardcoding.   
 * 3.0    24/09/2015   meghana.gupta@ust-global.com           #RQ-002059    Increase code coverage
 * 4.0    24/03/2016   dinesh.moorthy@ust-global.com          #RQ-002098    Decommission Customer Subscription management
 * 5.0    21-02-2017   deepak.r.mahapatra@in.ibm.com          #RQ-004643    Delete Quoting Tool Field in the User object 
 * 6.0    06-04-2017   abby.abraham@ust-global.com            #RQ-004759    Modified test class to accomodate User Country Mandatory Validation Rule
 * 7.0    31-10-2017   meghana.gupta@ust-global.com           #RQ-00698     Modified test class to skip duplicate rule check
 * 8.0    01-01-2019   Junaid.Khader@ust-global.com           #RQ-007160    Test coverage Improvement
 * 9.0    10/09/2020   meghana.gupta                          SFSE-262      Changes for new Source Brand field on leads
 * 10.0   08/06/2022   Ronnie@SF                              SIP-100       Removed brand hardcoding
 */

@isTest
private class Lead_EmailTrgr_Controller_Test {
    public static  user us;
    public static  Account testAccount;
    public static  Contact testContact;
    
    static void createTestData() {
        TriggerExecutionController.skipAllTriggers(true);
        //Insert user
        
        us = new user();
        us.LastName='testuser';
        us.Email='abc2355467df@ust-global.com';
        us.Username='testusernameun892@gg.play';
        us.CommunityNickname='testcomn2286';
        us.LanguageLocaleKey='en_US';
        us.LocaleSidKey='en_GB';
        us.timezonesidkey='GMT';
        us.emailencodingkey='ISO-8859-1';
        us.liner_brand__c=BrandUtilities.MAERSKLINE;
        us.alias='tAls';
        //us.Cluster__c=CreateIntegrationUserData_Test.testBDA.Id;
        us.Cluster__c=CreateIntegrationUserData_Test.testBDA.Name;
        us.Country='Test COuntry';         
        us.Profileid=Label.TestClean_ProfileIdsSystemAdmin; //#RQ-000875
        //us.Quoting_Tool__c = 'Quote Builder';   //#RQ-004643
        insert us;
        
        //Setup a Account
        testAccount = new Account();
        testAccount.Name = 'AdamnEve';
        testAccount.Cluster_Name__c=CreateIntegrationUserData_Test.testBDA.id;
        System.runAs(CreateIntegrationUserData_Test.integrationUser) {
            insert testAccount;
        }
        
        //Create Test Data - Contact
        testContact = new Contact();
        testContact.firstname = 'test2';
        testContact.LastName ='test2';
        testContact.liner_brands__c = BrandUtilities.MAERSKLINE;
        testContact.AccountId = testAccount.id;
        testContact.Email='g@gmail.play';
        testContact.Preferred_Language__c='English';
        System.runAs(CreateIntegrationUserData_Test.integrationUser) {
            insert testContact;
        }
         TriggerExecutionController.skipAllTriggers(false);
    }
    
    static void setRecursionFlags() {
        // Commented as part of #RQ-002098
        //TriggerRecursionCounter.invokedFromSubscriptionCount = false;
        //TriggerRecursionCounter.invokedFromTradeCount = false;
        TriggerRecursionCounter.invokedFromRecUpdate = false;
        TriggerRecursionCounter.isEmailValidationOnLead = false;
    }
    
    static testMethod void BulkTest() {
        Test.StartTest();
        //insert Geography record
        Geography__c geoObj=new Geography__c();
        geoObj.Name='India';
        geoObj.Type_Of_Location__c='Country';
        geoObj.GEO_ID__c = '0QK7LWQMLOXVI';
        insert geoObj;
        
        //insert BDA record
        BDA__c BDAObj=new BDA__c();
        BDAObj.Name='Goa';
        BDAObj.BDA_Code__c='GA';
        BDAObj.Type__c='Cluster';
        BDAObj.GEO_ID__c = geoObj.GEO_ID__c;
        insert BDAObj;
        
        //insert BDA Geography record
        BDA_Geography__c BDAGeoObj=new BDA_Geography__c();
        BDAGeoObj.BDA__c=BDAObj.id;
        BDAGeoObj.Geography__c=geoObj.id;
        insert BDAGeoObj;
        
        //declare list
        List<Lead> leaList=new List<Lead>();
        Lead ld = createLead('TestLead001');
        ld.Expected_FFE__c=2.5;
        ld.Status='Open';        
        setRecursionFlags();
        insert ld;
        
        //Bulk Test
        for(integer i=0; i<=200; i++) {
            String leadName='acct'+i;
            leaList.add(createLead(leadName));
        }
        
        try {
            setRecursionFlags();
            insert leaList;
        } catch(DMLException e) {
            System.assert(true);
        }
        
        //insert Geography record
        Geography__c geoObj2=new Geography__c();
        geoObj2.Name='US';
        geoObj2.Type_Of_Location__c='Country';
        insert geoObj2;
        
        ld.Country_lk__c=geoObj2.id;
        setRecursionFlags();
        update ld;
        Test.StopTest();        
    }
    
    /*
    * Test Methods 1-7 Added to test the trigger : bINS_bUPD_emailValidationLead
    */
    
    //Test Case1 - When multiple lead with duplicate email exist in a Batch
    static testMethod void TestbINS_bUPD_emailValidationLead1() {
        Test.StartTest();    
        CreateIntegrationUserData_Test.initializeIntegrationUser();
    
        //createTestData();
        
        list <Lead> lDuplicateLead = new List <Lead>();
     	for(integer i=0; i<= 3; i++) {
            
            String leadName='acct'+i;
            Lead testLead = createLead(leadName);
            lDuplicateLead.add(testLead);
        }
        System.runAs(CreateIntegrationUserData_Test.integrationUser) {
            try {
                setRecursionFlags();
                insert lDuplicateLead;            
            } catch(exception e) {
                System.debug('SOQL used : '+Limits.getQueries());
            }
        }
        Test.StopTest();
    }
    
    //Test Case2 - When a contact exists in the system and the test tries to create a lead with duplicate email
    static testMethod void TestbINS_bUPD_emailValidationLead2() {
        Test.StartTest();
        CreateIntegrationUserData_Test.initializeIntegrationUser();
            
        createTestData();
        Lead testLead = createLead('TestLead002');
       
        System.runAs(CreateIntegrationUserData_Test.integrationUser) {
            try {
                setRecursionFlags();
                insert testLead;            
            } catch(exception e) {
                System.debug('SOQL used : '+Limits.getQueries());
            }
        }
        Test.StopTest();
    }
    
    //Test Case3 - When user tries to create a Lead with IsDuplicate = true with no other contact/lead with same email exists in System   
    static testMethod void TestbINS_bUPD_emailValidationLead3() {
        Test.StartTest();
        Lead testLead = createLead('TestLead003');
        try {
            setRecursionFlags();
            insert testLead;            
        } catch(exception e) {
            System.debug('SOQL used : '+Limits.getQueries());
        }
        Test.StopTest();
    }
    
    //Test Case4 - When user deletes a Lead that is Marked as Non-Duplicate amoung the duplicates   
    static testMethod void TestbINS_bUPD_emailValidationLead4() {
        Test.StartTest();
        TriggerExecutionController.skipAllTriggers(true);
        CreateIntegrationUserData_Test.initializeIntegrationUser();
        
        Lead testLead1 = createLead('TestLead004');
        System.runAs(CreateIntegrationUserData_Test.integrationUser) {
            try {
                setRecursionFlags();
                insert testLead1;            
            } catch(exception e) {
                System.debug('SOQL used : '+Limits.getQueries());
            }
        }
        TriggerExecutionController.skipAllTriggers(false);
        Lead testLead2 = createLead('TestLead005');
        
        System.runAs(CreateIntegrationUserData_Test.integrationUser) {
            try {
                setRecursionFlags();
                insert testLead2;   
            } catch(exception e) {
                System.debug('SOQL used : '+Limits.getQueries());
            }
        }
        createTestData();
        try {
            setRecursionFlags();
            delete testLead1;
            undelete testLead1;
        } catch(exception e) {}       
        Test.StopTest();
    }
    
    //Test Case 5 - When a User changes the email of Lead(marked as Non-Duplicate)   
    static testMethod void TestbINS_bUPD_emailValidationLead5() {
        Test.StartTest();
        TriggerExecutionCOntroller.skipAllTriggers(true);
        CreateIntegrationUserData_Test.initializeIntegrationUser();          

        Lead testLead1 = createLead('TestLead006');
   
        System.runAs(CreateIntegrationUserData_Test.integrationUser) {
            try {
                setRecursionFlags();
                insert testLead1;            
            } catch(exception e) {
                System.debug('SOQL used : '+Limits.getQueries());
            }
        }
        TriggerExecutionCOntroller.skipAllTriggers(false);
        Lead testLead = createLead('TestLead007');
        Lead testLead2 = createLead('TestLead007');
        testLead2.IsDuplicate__c = true;
        
        System.runAs(CreateIntegrationUserData_Test.SCLIntegrationUser) {
            try {
                setRecursionFlags();
                //insert testLead;   
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.DuplicateRuleHeader.AllowSave = true; 
                Database.SaveResult sr = Database.insert(testLead, dml); 
                
            } catch(exception e) {}
            setRecursionFlags();
           // insert testLead2;    
            Database.DMLOptions dml1 = new Database.DMLOptions();
            dml1.DuplicateRuleHeader.AllowSave = true; 
            Database.SaveResult sr = Database.insert(testLead2, dml1); 
        }
        
        try {
            setRecursionFlags();
            testLead1.email = 'ChangedEmail@gmail.com.play';
            update testLead1; 
         } catch(exception e) {}   
        
        System.runAs(CreateIntegrationUserData_Test.systemAdminUser) {
            try {
                setRecursionFlags();
                testLead2.IsDuplicate__c = false;
                update testLead2; 
            } catch(exception e) {}
        } 
        Test.StopTest();
    }
    
    //Test Case 6 - When a User updates a Lead as Non-Duplicate from duplicate & a Contact was Non-Duplicate Previously   
    static testMethod void TestbINS_bUPD_emailValidationLead6() {
        Test.StartTest();
        CreateIntegrationUserData_Test.initializeIntegrationUser();          
        createTestData();
    
        Lead testLead1 = createLead('TestLead008');
        testLead1.IsDuplicate__c = true;
   
        System.runAs(CreateIntegrationUserData_Test.integrationUser) {
            try {
                setRecursionFlags();
                insert testLead1;            
            } catch(exception e) {}
        }
        
        Lead testLead2 = createLead('TestLead008');
        testLead2.IsDuplicate__c = true;
   
        System.runAs(CreateIntegrationUserData_Test.integrationUser) {
            try {
                setRecursionFlags();
                insert testLead2;            
            } catch(exception e) {
                System.debug('SOQL used : '+Limits.getQueries());
            }
        }
        System.runAs(us) {
            try {
                setRecursionFlags();
                Lead utestLead = [Select Id,Email from Lead where ID = :testLead1.ID];
                utestLead.IsDuplicate__c = false;
                update utestLead; 
            } catch(exception e) {}
        }
        Test.StopTest();
    }
    
    //Test Case 7 - When a User updates a Lead as Non-Duplicate from duplicate & a Lead was Non-Duplicate Previously   
    static testMethod void TestbINS_bUPD_emailValidationLead7() {
        Test.StartTest();
        CreateIntegrationUserData_Test.initializeIntegrationUser();
        Lead testLead1 = createLead('TestLead002');
   
        System.runAs(CreateIntegrationUserData_Test.integrationUser) {
            try {
                setRecursionFlags();
                insert testLead1;            
            } catch(exception e) {}
        }
        createTestData();
        Lead testLead2 = createLead('TestLead002');
        testLead2.IsDuplicate__c = true;
   
        System.runAs(CreateIntegrationUserData_Test.integrationUser) {
            try {
                setRecursionFlags();
                insert testLead2;            
            } catch(exception e) {
                System.debug('SOQL used : '+Limits.getQueries());
            }
        }
        System.runAs(us) {
            try {
                setRecursionFlags();                
                testLead2.IsDuplicate__c = false;
                update testLead2;    
            } catch(exception e) { }
        }
        Test.StopTest();
    }
    
    static testMethod void TestbINS_bUPD_emailValidationLead8() {
        Test.StartTest();
        CreateIntegrationUserData_Test.initializeIntegrationUser();          
        
        Lead testLead1 =createLead('TestLead002');
        testLead1.Weekly_Highlights_Chosen_Language__c = 'Mandarin';
   
        try {
            insert testLead1;
            delete testLead1;
            undelete testLead1;          
        } catch(exception e) {}
        
        Lead testLead2 = createLead('TestLead002');
        testLead2.IsDuplicate__c = true;
        testLead2.Weekly_Highlights_Chosen_Language__c = 'Mandarin';
   
        try {
            setRecursionFlags();
            insert testLead2;            
        } catch(exception e) {}
        try {
            delete testLead2;
        } catch(exception e) {}
        try {
            setRecursionFlags();
            undelete testLead2;           
        } catch(exception e) {}
        
        try {
            testLead2.IsDuplicate__c = false;   
            update testLead2;
            delete testLead2;
        } catch(exception e) {}
        try {
            setRecursionFlags();                    
            undelete testLead2;           
        } catch(exception e) {}
        
        Test.StopTest();
    }
    
    static Lead createLead(String leadName) {
         Lead testLead = LeadDataGeneration.createLead(leadName, 'User123', 'TestCompany2',null, BrandUtilities.MAERSK, leadName +'abc@test.com.play', null, null,'LinkedIn');
        	testLead.Phone='123';
            testLead.Street='hhh';
            testLead.City='cc';
            testLead.State='sss';
            testLead.PostalCode='23';
            testLead.Country='ccc';
            testLead.Tax_Ref__c='wjhd';
            testLead.Expected_FFE__c = 4;
        	testLead.IsDuplicate__c = false;
        return testLead;
    }
}