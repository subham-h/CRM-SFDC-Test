/*              
* Revision Ref Number  Date          Owner                  Description
* -------- ----------  -----------   -------------------    -----------
* 1.0      RQ-004168   17-Mar-2017   Ranjini@ust            Test Class for AccountTrigger functionalities- Account Cluster , BillingState, Last Activity Date population.
* 2.0      RQ-005677   25-Sep-2017   Uvais.Komath@ust       All reference to Cluster Name field from account is removed as part of deprecation
* 3.0      SFSE-6116   24-June-2021  Neha@TCS               Corrected few method and created new method testpopulateAddressandSalesGroupforOTS()
* 4.0      SPI-100     07-06-2022    Ronnie@SF              Removing brand hard codings
*/

@isTest
public class AccountTrigger_Test {
    
    public static BDA__c testCluster = new BDA__C ();
    public static Geography__c testCountry = new Geography__c();
    public static BDA_Geography__c bdaGeo = new BDA_Geography__c();
    public static User salesUser = new User();
    public static Geography__c testcity1 = new Geography__c();
    public static Geography__c testcity2 = new Geography__c();
    public static Geography__c testcity3 = new Geography__c();
    public static Geography__c testState1 = new Geography__c();
    public static Geography__c testState2 = new Geography__c();
    public static Geography__c testState3 = new Geography__c();   
    
    public static testMethod void createBaseDetails(){
        
        Profile salesProfile = [Select Id,Name from Profile where Id = :Label.TestClean_ProfileIdsSales]; 
        User salesUser = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE + ';' + BrandUtilities.MAERSKLS, false);
        salesUser.Id= null;
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert new List<User>{salesUser};
                }
        
        
        List<Geography__c> cityList = new List<Geography__c> ();
        List<Geography__c> stateList = new List<Geography__c> ();
        
        testCluster.Name = 'West Africa Area';
        testCluster.Type__c = 'Cluster';
        testCluster.BDA_Code__c = 'WAF';
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
        
        
        //insert cityList;
        
        testState1.Name = 'Tamil Nadu';
        testState1.Active__c =true;
        testState1.GEO_Code__c = 'tn';
        testState1.GEO_ID__c = '10Z679Zk123234f6';
        testState1.Is_Port__c = false;
        testState1.Type_Of_Location__c = 'State';
        testState1.Parent_Geography__c = testCountry.Id;
        stateList.add(testState1);
        
        testState2.Name = 'Kerala';
        testState2.Active__c =true;
        testState2.GEO_Code__c = 'tn';
        testState2.GEO_ID__c = '10Z45W9Zk123234f6';
        testState2.Is_Port__c = false;
        testState2.Type_Of_Location__c = 'State';
        testState2.Parent_Geography__c = testCountry.Id;
        stateList.add(testState2);
        
        testState3.Name = 'Karnataka';
        testState3.Active__c =true;
        testState3.GEO_Code__c = 'tn';
        testState3.GEO_ID__c = '10Z2W923123234f6';
        testState3.Is_Port__c = false;
        testState3.Type_Of_Location__c = 'State';
        testState3.Parent_Geography__c = testCountry.Id;
        stateList.add(testState3);
        
        insert stateList;
        
        testcity1.Name = 'Chennai';
        testcity1.Active__c =true;
        testcity1.GEO_Code__c = 'tn';
        testcity1.GEO_ID__c = '10543Zkjh234f6';
        testcity1.Is_Port__c = false;
        testcity1.Type_Of_Location__c = 'City';
        testcity1.Parent_Geography__c = testState1.Id;
        cityList.add(testcity1);
        
        testcity2.Name = 'Kochi';
        testcity2.Active__c =true;
        testcity2.GEO_Code__c = 'tn';
        testcity2.GEO_ID__c = '109879Zkjh23';
        testcity2.Is_Port__c = false;
        testcity2.Type_Of_Location__c = 'City';
        testcity2.Parent_Geography__c = stateList[1].Id;
        cityList.add(testcity2);
        
        testcity3.Name = 'Kochi';
        testcity3.Active__c =true;
        testcity3.GEO_Code__c = 'tn';
        testcity3.GEO_ID__c = '109832fZkjh23';
        testcity3.Is_Port__c = false;
        testcity3.Type_Of_Location__c = 'City';
        testcity3.Parent_Geography__c = stateList[2].Id;
        cityList.add(testcity3);
        
        insert cityList;
        
        bdaGeo.BDA__c = testCluster.Id;
        bdaGeo.Geography__c = testCountry.Id;
        insert bdaGeo;
        
        
        /*TriggerExecutionController.skipAccountTrigger(true);
    testclAcc = AccountDataHelper_Test.createClientAccount(null,'Active',null );
    testcnAcc = AccountDataHelper_Test.createConcernAccount();
    TriggerExecutionController.skipAccountTrigger(false);*/
    }
    
    //RQ-005400 - Account State population based on the city value
    public static testMethod void testAccountStatePopulation(){
        
        createBaseDetails();
        TriggerExecutionController.skipAccountTrigger(true);
        Account clientAcc = AccountDataHelper_Test.createClientAccount();
        TriggerExecutionController.skipAccountTrigger(false);
        
        clientAcc.Country__c = testCountry.Id;
        clientAcc.BillingCity = 'Chennai';
        clientAcc.BillingState = 'WER';
        Test.startTest();               
        update clientAcc;               
        Test.stopTest();
        
        Account updatedAcc = [Select Id, BillingState,BillingCity, Country__c from Account where Id =: clientAcc.Id];        
        System.assertEquals(updatedAcc.BillingState, 'Tamil Nadu');        
        
    }
    
    //RQ-005400 - Account State population based on the city value when there are more than one city record with same name
    public static testMethod void testAccountStatePopulationWithmultipleCities(){
        
        createBaseDetails();
        TriggerExecutionController.skipAccountTrigger(true);
        Account clientAcc = AccountDataHelper_Test.createClientAccount();
        TriggerExecutionController.skipAccountTrigger(false);
        clientAcc.Country__c = testCountry.Id;
        clientAcc.BillingCity = 'Kochi';
        clientAcc.BillingState = 'WER';
        Test.startTest();
        update clientAcc;           
        Account updatedAcc = [Select Id, BillingState from Account where Id =: clientAcc.Id];
        System.assertEquals(updatedAcc.BillingState, 'WER'); 
        Test.stopTest();
        
    }    
    
    /*
    * Methods copied from AccountUtility_Test
    */ 
    public static testMethod void test_populateLastActivityDateTask () {
        list<Account> lstAccounts = new list<Account>();
        list<Task> lstTasks = new list<Task>();
        ActivityData_Test.bCreate = false;
        
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createDraftAccounts();
        Account accInstance =AccountData_Test.lstAccounts[0];
        
        ActivityData_Test.createTasks();
        lstTasks = ActivityData_Test.lstTasks;
        
        for(Task taskIterator : lstTasks) {
            taskIterator.WhatId = accInstance.Id;
        }
        
        Test.startTest();
        insert lstTasks;
        Test.stopTest();  
        
        Account acc = [SELECT Id,Last_Activity_Date__c FROM Account WHERE Id =: accInstance.Id];
        system.assertEquals(system.today(), acc.Last_Activity_Date__c);
    }
    
    public static testMethod void test_populateLastActivityDateTaskOnUpdation () {
        
        list<Account> lstAccounts = new list<Account>();
        list<Task> lstTasks = new list<Task>();
        ActivityData_Test.bCreate = false;
        
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createDraftAccounts();
        Account accInstance =AccountData_Test.lstAccounts[0];
        
        ActivityData_Test.createTasks();
        lstTasks = ActivityData_Test.lstTasks;
        
        for(Task taskIterator : lstTasks) {
            taskIterator.WhatId = accInstance.Id;
        }
        insert lstTasks;
        for(Task taskIterator : lstTasks){
            taskIterator.Subject = 'Task Updated';
        }
        TriggerExecutionController.skipTaskTrigger(False);
        
        Test.startTest();
        update lstTasks;
        Test.stopTest(); 
        
        Account acc = [SELECT Id,Last_Activity_Date__c FROM Account WHERE Id =: accInstance.Id];        
        system.assertEquals(system.today(), acc.Last_Activity_Date__c);
        
    }
    
    public static testMethod void test_populateLastActivityDateEvent () {
        list<Account> lstAccounts = new list<Account>();
        list<Event> lstEvents = new list<Event>();
        ActivityData_Test.bCreate = false;
        
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createDraftAccounts();
        Account accInstance =AccountData_Test.lstAccounts[0]; 
        
        ActivityData_Test.createEvents();
        lstEvents = ActivityData_Test.lstEvents;
        
        for(Event eventIterator : lstEvents) {
            eventIterator.WhatId = accInstance.Id;
        }
        
        Test.startTest();
        insert lstEvents;
        Test.stopTest();  
        
        Account acc = [SELECT Id,Last_Activity_Date__c FROM Account WHERE Id =: accInstance.Id];
        //system.debug('##### Last Activity date' + acc.Last_Activity_Date__c);
        
        system.assertEquals(system.today(), acc.Last_Activity_Date__c);
    }
    
    public static testMethod void test_populateLastActivityDateEventOnUpdation () {
        list<Account> lstAccounts = new list<Account>();
        list<Event> lstEvents = new list<Event>();
        ActivityData_Test.bCreate = false;
        
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createDraftAccounts();
        Account accInstance =AccountData_Test.lstAccounts[0];
        
        ActivityData_Test.createEvents();
        lstEvents = ActivityData_Test.lstEvents;
        
        for(Event eventIterator : lstEvents) {
            eventIterator.WhatId = accInstance.Id;
        }
        insert lstEvents;
        for(Event eventIterator : lstEvents){
            eventIterator.Subject = 'Task Updated';
        }
        TriggerExecutionController.skipEventTrigger(False);
        
        Test.startTest();
        update lstEvents;
        Test.stopTest(); 
        
        Account acc = [SELECT Id,Last_Activity_Date__c FROM Account WHERE Id =: accInstance.Id];        
        system.assertEquals(system.today(), acc.Last_Activity_Date__c);
    } 
    
    public static testMethod void testpopulateAddressandSalesGroupforOTS(){
        
        createBaseDetails();
        TriggerExecutionController.skipAccountTrigger(true);
        Account clientAcc = AccountDataHelper_Test.createClientAccount();
        TriggerExecutionController.skipAccountTrigger(false);
        
        clientAcc.Country__c = testCountry.Id; 
        clientAcc.MSL_Account_Owner__c  =null; // setting the MSL owner as null to set the Sales group for OTS accounts
        Test.startTest();               
        update clientAcc;
        Account updatedAcc = [Select Id, Sales_Group__c,Account_Address_Area__c, Country__c from Account where Id =: clientAcc.Id];
        //System.assertEquals(updatedAcc.Sales_Group__c, 'OTS - WAF');         
        System.assertEquals(updatedAcc.Account_Address_Area__c, testCluster.id); 
        Test.stopTest();
        
        
    }
    
}