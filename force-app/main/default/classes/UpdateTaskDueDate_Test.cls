/************************************************************************************************************************************************************************
 * Name        : UpdateTaskDueDateTest 
 * Description: This is a test class created to cover below class :
 *                 1.  UpdateTaskDueDate.trigger 
 *                       
 * --------------------------------------------------------------------------------------------------------------------------------------------------* 
 * Rev       Name                                              Date                        RQ#                       Description                                       
 * 
 * 1.0       Krishnamoorthi.murugesan@ust-global.com           08/12/2014                  #RQ-000828                Removed PPVVC from Opportunity  
 * 2.0       Madhava.kotte@ust-global.com                      11/12/2014                  #PR-00031_2               Named Account functionality for Sealand Opportunities   
 * 3.0       Madhava.kotte@ust-global.com                      12/05/2015                  #PR-0042                  Named Account functionality for MCC opportunities    
 * 4.0       Jiji@UST                                          12/08/2016                  #RQ-004057                Remove reference to Survey_Me__c, Primary_Contact__c field
 * 5.0       manjunath.c.holekade@maersk.com                   06-Jun-2019                 #RQ-010819                Removal of references of deprecated fields 
 * 6.0       manjunath.c.holekade@maersk.com                   12-Nov-2019                 #RQ-012362                Removal of references of deprecated Account fields 
 * 7.0       Meghana@UST						               16-Oct-2020                 #SFSE-4767                Removal of references to Safmarine brand related method 
 * 8.0       Ronnie@SF                                         27-Jun-2022                 SPI-100                   Removed brand hardcoding
 *************************************************************************************************************************************************************************/
@isTest
private class UpdateTaskDueDate_Test {

    public static testMethod void testUpdateTaskDueDateTriggerDualBranded() {
         Test.StartTest();
        List<Opportunity> oppList=new list<Opportunity>();
        List<User> lstuser = new List<User>();
         TriggerExecutionController.skipAllTriggers(true);
        User integrationUser = TestBusinessHelper.createUser('Integration User', BrandUtilities.SEALAND, false);
        integrationUser.ID=null;
      	lstuser.add(integrationUser);
        User MSLintegrationUser = TestBusinessHelper.createUser('Integration User', BrandUtilities.SEAGO, false);
        MSLintegrationUser.ID=null;
        MSLintegrationUser.MLL__c =true;
       	lstuser.add(MSLintegrationUser);
        
		system.runas(new user(id = userinfo.getuserid())){
        
            insert lstuser;
        }
         TriggerExecutionController.skipAllTriggers(false);
        //setup a Account Export_Rep Dual branded
       
        Account acct=new Account();
        
        System.runAs(integrationUser)
        {
            acct.Name='Test Account';
            //acct.MSL_Account_Owner__c=Userinfo.getUserId();
            acct.SCV_Code__c = '2242348789';                 
            acct.MSL_Account_Owner__c= integrationUser.Id;
            acct.MLL_Account_Owner__c= MSLintegrationUser.Id;  
            insert acct;
        }
        
        
        Contact cont= TestBusinessHelper.createContact(acct, 'Customer_Contact', BrandUtilities.MAERSKLINE, true);
        /*cont.LastName  ='testsdf';
        cont.AccountId= acct.id;
        cont.Email='cvghfdg@gmail.play';
        //cont.Primary_Contact__c=true;
        //cont.Survey_Me__c=true; ver4.0
        cont.Liner_Brands__c = BrandUtilities.MAERSKLINE;
        cont.Preferred_Language__c='English';
        insert cont;
        */
        //set up opportunity
        Opportunity opp=TestBusinessHelper.createOpportunity(acct, cont, integrationUser, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
		 /*
        opp.name='testop';
        opp.CloseDate=date.today();
        opp.AccountId=acct.id; 
        opp.StageName= Label.LeadLabel;
        opp.Cargo_Type__c='DRY';
        opp.type='Transactional';
        opp.Primary_contact__c=cont.id;
        opp.Named_Account__c=acct.id;
        opp.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        insert opp; 
        */
        opp = [select id from opportunity where Id=:opp.id];
       
        Task tsk = new Task();
        tsk.Subject='Opportunity Expiration Notification';
        tsk.Status='Not Started';
        tsk.Priority='Normal';
        tsk.WhatID=opp.id;
        tsk.ActivityDate=date.today();
        tsk.ReminderDateTime=date.today(); 
        insert tsk;  
        
        update opp; 
        
        opp = [select id from opportunity where Id=:opp.id];  
        
        Task tsk1 = new Task();
        tsk1.Subject='Opportunity Expiration Notification';
        tsk1.Status='Not Started';
        tsk1.Priority='Normal';
        tsk1.WhatID=opp.id;
        tsk1.ActivityDate=date.today()+1;
        tsk1.ReminderDateTime=date.today()+1; 
        insert tsk1; 
         Test.StopTest(); 
    }
    
    public static testMethod void testUpdateTaskDueDateTriggerSingleBranded() {
        Test.StartTest();
        List<Opportunity> oppList=new list<Opportunity>();
      
        List<User> lstuser = new List<User>();
         TriggerExecutionController.skipAllTriggers(true);
        User integrationUser = TestBusinessHelper.createUser('Integration User', BrandUtilities.SEALAND, false);
        integrationUser.ID=null;
      	lstuser.add(integrationUser);
        User SCLIntegrationUser = TestBusinessHelper.createUser('Integration User', BrandUtilities.SEAGO, false);
        SCLIntegrationUser.ID=null;
        SCLIntegrationUser.MLL__c =true;
       	lstuser.add(SCLIntegrationUser);
        
		system.runas(new user(id = userinfo.getuserid())){
        
            insert lstuser;
        }
        Account acct=new Account();
        
        System.runAs(integrationUser)
        {
            acct.Name='Test Account';
            acct.SCV_Code__c = '2242348789';                 
            acct.MSL_Account_Owner__c= integrationUser.Id;
            //acct.SCL_Account_Owner__c=CreateIntegrationUserData_Test.integrationUser.Id;
            acct.SEA_Account_Owner__c = SCLIntegrationUser.id;
            insert acct;
        }
        Contact cont=  TestBusinessHelper.createContact(acct, 'Customer_Contact', BrandUtilities.MAERSKLINE, true);
        /*cont.LastName  ='testsdf';
        cont.AccountId= acct.id;
        cont.Email='cvghfdg@gmail.play';
        //cont.Primary_Contact__c=true;
        //cont.Survey_Me__c=true; ver4.0
        cont.Liner_Brands__c = BrandUtilities.SEALAND;
        cont.Preferred_Language__c='English';
        System.runAs(CreateIntegrationUserData_Test.integrationUser)
        {
            insert cont;
        }*/
        
        Contact contsl = TestBusinessHelper.createContact(acct, 'Customer_Contact', BrandUtilities.SEALAND, true);
        /*contsl.LastName  ='testsdf';
        contsl.AccountId= acct.id;
        contsl.Email='cvghfdger@gmail.play';
        //contsl.Primary_Contact__c=true;
        //contsl.Survey_Me__c=true; ver4.0
        contsl.Liner_Brands__c = BrandUtilities.SEALAND;
        contsl.Preferred_Language__c='English';
        System.runAs(CreateIntegrationUserData_Test.integrationUser) {
            insert contsl;
        }*/
        
        //set up opportunity
       
        Opportunity oppt;
        //Opp Insertion by single branded MaerskLine user
        system.runAs(SCLIntegrationUser) {
            Validation_Rules_Bypass__c  setting = new Validation_Rules_Bypass__c ();
            setting.Active__c  = true; 
            insert setting;
           oppt=TestBusinessHelper.createOpportunity(acct, cont, SCLIntegrationUser, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
	
            /*oppt.name='testop';
            oppt.CloseDate=date.today()+1;
            oppt.AccountId=acct.id; 
            oppt.StageName= Label.LeadLabel;
            oppt.Cargo_Type__c='DRY';
            oppt.type='Transactional';
            oppt.Primary_contact__c=cont.id;
            oppt.Named_Account__c=acct.id;
            oppt.Liner_Brand__c = BrandUtilities.SEALAND;
            insert oppt;*/
        }
        
        //Opp Insertion by single branded MaerskLine user
        
        Task tsk = new Task();
        tsk.Subject='Opportunity Expiration Notification';
        tsk.Status='Not Started';
        tsk.Priority='Normal';
        tsk.WhatID=oppt.id;
        tsk.ActivityDate=date.today();
        tsk.ReminderDateTime=date.today()+1; 
        insert tsk;  
        
        Opportunity opp = [select id from opportunity where Id=:oppt.id];
        update opp;
        
        opp = [select id from opportunity where Id=:opp.id]; 
        
        
        Task tsk1 = new Task();
        tsk1.Subject='Opportunity Expiration Notification';
        tsk1.Status='Not Started';
        tsk1.Priority='Normal';
        tsk1.WhatID=opp.id;
        tsk1.ActivityDate=date.today()+1;
        tsk1.ReminderDateTime=date.today()+1; 
        insert tsk1;
        Test.StopTest();
    }
    
    /**
*TestDriven Approach: #PR-00031_2 - below test method is for testing the chatter feed for SEA account owner on Sealand opportunity insertion with Named Account
**/
    public static testMethod void sealndOppNamedAccChatterPost() {
        
        Test.StartTest();
        
        UserDataGeneratorHelper_Test.initializeIntegrationUser();
        
        //for inserting the account
        Account lstAcct=new Account();
        system.debug('MSLSystemAdminUser');
        lstAcct.Name='MainAccount';
        lstAcct.SEA_Account_Owner__c = UserDataGeneratorHelper_Test.SEAIntegrationUser.id;
        
        System.runAs(UserDataGeneratorHelper_Test.integrationUser) {
            insert lstAcct;
        }
        
        //for inserting the Named Account
        Account namedAcct=new Account();
        namedAcct.Name='named Acc';
        namedAcct.SEA_Account_Owner__c = UserDataGeneratorHelper_Test.SEAIntegrationUser.id;
        
        System.runAs(UserDataGeneratorHelper_Test.integrationUser) {
            insert namedAcct;
        }
        
        //for inserting the contact
        Contact seaCont=new Contact();
        seaCont.LastName  ='testsdf';
        seaCont.AccountId= lstAcct.id;
        seaCont.Email='cvghfdg@gmail.play';
        //seaCont.Primary_Contact__c=true;
        //seaCont.Survey_Me__c=true;ver4.0
        seaCont.Liner_Brands__c = BrandUtilities.SEALAND;
        seaCont.Preferred_Language__c='English';
        System.runAs(UserDataGeneratorHelper_Test.SEAIntegrationUser) {
            insert seaCont;
        }
        
        //for inserting the opportunity
        Opportunity namedOpp = new Opportunity();
        namedOpp.name = 'testop123';
        namedOpp.CloseDate = date.today();
        namedOpp.AccountId = lstAcct.id; 
        namedOpp.StageName =  Label.LeadLabel;
        namedOpp.Cargo_Type__c = 'DRY';
        namedOpp.type = 'Transactional';
        namedOpp.Primary_contact__c = seaCont.id;
        namedOpp.Named_Account__c = namedAcct.id;
        namedOpp.Liner_Brand__c = BrandUtilities.SEALAND;
        namedOpp.Expected_Handling_Rounds__c=2;
        System.runAs(UserDataGeneratorHelper_Test.SEAIntegrationUser) {
            insert namedOpp;
        }
        Test.StopTest();
    }
    
    
    /**
    *TestDriven Approach: #PR-0042 - below test method is for testing the chatter feed for MCC account owner on MCC opportunity insertion with Named Account
    **/
    public static testMethod void mccOppNamedAccChatterPost() {
        
        Test.StartTest();
        
        UserDataGeneratorHelper_Test.initializeIntegrationUser();
        
        //for inserting the account
        Account lstAcct=new Account();
        lstAcct.Name='MainAccount';
        lstAcct.MCC_Account_Owner__c = UserDataGeneratorHelper_Test.MCCIntegrationUser.id;
        
        System.runAs(UserDataGeneratorHelper_Test.integrationUser) {
            insert lstAcct;
        }
        
        //for inserting the Named Account
        Account namedAcct=new Account();
        namedAcct.Name='named Acc';
        namedAcct.MCC_Account_Owner__c = UserDataGeneratorHelper_Test.MCCIntegrationUser.id;
        
        System.runAs(UserDataGeneratorHelper_Test.integrationUser) {
            insert namedAcct;
        }
        
        //for inserting the contact
        Contact mccCont=new Contact();
        mccCont.LastName  ='testsdf';
        mccCont.AccountId= lstAcct.id;
        mccCont.Email='cvghfdg@gmail.play';
        //mccCont.Primary_Contact__c=true;
        //mccCont.Survey_Me__c=true;ver4.0
        mccCont.Liner_Brands__c = BrandUtilities.MCC;
        mccCont.Preferred_Language__c='English';
        System.runAs(UserDataGeneratorHelper_Test.MCCIntegrationUser) {
            insert mccCont;
        }
        
        //for inserting the opportunity
        Opportunity opp = new Opportunity();
        opp.name = 'testop123';
        opp.CloseDate = date.today();
        opp.AccountId = lstAcct.id; 
        opp.StageName =  Label.LeadLabel;
        opp.Cargo_Type__c = 'DRY';
        opp.type = 'Transactional';
        opp.Primary_contact__c = mccCont.id;
        opp.Liner_Brand__c = BrandUtilities.MCC;
        opp.Expected_Handling_Rounds__c=2;
        System.runAs(UserDataGeneratorHelper_Test.MCCIntegrationUser) {
            insert Opp;
            List<OpportunityFeed> oppFeedLst = [select id, ParentId From OpportunityFeed where parentId=:opp.id];
            system.assertEquals(oppFeedLst.size()>0,false);
        }
        
        //for inserting the opportunity for Named Account
        Opportunity namedOpp = new Opportunity();
        namedOpp.name = 'testop123';
        namedOpp.CloseDate = date.today();
        namedOpp.AccountId = lstAcct.id; 
        namedOpp.StageName =  Label.LeadLabel;
        namedOpp.Cargo_Type__c = 'DRY';
        namedOpp.type = 'Transactional';
        namedOpp.Primary_contact__c = mccCont.id;
        namedOpp.Named_Account__c = namedAcct.id;
        namedOpp.Liner_Brand__c = BrandUtilities.MCC;
        namedOpp.Expected_Handling_Rounds__c=2;
        
        System.runAs(UserDataGeneratorHelper_Test.MCCIntegrationUser) {
            insert namedOpp;
        }
        Test.StopTest();
    }
}