/**
 * Test class for AccountTrigger & AccountTriggerHandler
 * 
 * Version    Date          Modified By                         Description
 * 1.0       12/12/2015     meghana.gupta@ust-global.com        Code created as part of #RQ-002192
 * 2.0       03/02/2016     meghana.gupta@ust-global.com        RQ-002775 MOdify Opportunity test data generator method calls
 * 3.0       28/02/2017     Hitha.Vasudevan@ust-global.com      RQ-004653 - Removed references to Account.City_Name__C
 * 4.0       10/4/2017      Ranjini.Janardhanan@ust-global.com  RQ-004168 - Commented the unwanted methods.
 * 5.0       11/Jul/2019    Junaid.Khader@ust-global.com        RQ-010654: Removed invocation of method DataGeneratorHelper1_Test.createTarget which creates deprecated object Target__c
 * 6.0       12-Nov-2019    manjuanth@maersk                    RQ-012362: Removed references of deprecated Account fields
 * 7.0       15/10/2020     meghana.gupta@ust                   SFSE-4767: Safmarine brand deprecated
 * 7.1       24-Jun-2021    Nitin@Maersk                        SFSE-6116: testPopulateAccountAddressAreaOnUpdate, testPopulateAccountAddressAreaOnCreate unit test
 * 7.2       27-Jun-2022    Ronnie@SF                           SPI-100: Removed brand hardcoding
 */

@isTest
private class AccountTriggerHandler_Test {

    @TestSetup static void dataSetup(){

        Map<String, String> mapGeo = new Map<String, String> {'United Kingdom'=>'Country', 'India' =>'Country'};
        List<Geography__c> lstGeo = DataGeneratorHelper1_Test.createGeography(mapGeo);
        
        UserDataGeneratorHelper_Test.initializeSystemAdminUser();
        List<BDA__c> lstBDA = DataGeneratorHelper1_Test.createBDA('Cluster', null, UserDataGeneratorHelper_Test.systemAdminUser.Id, 2);
        lstBDA[0].BDA_Code__c = 'UKI';
        lstBDA[1].BDA_Code__c = 'WAF';
        update lstBDA;

        Map<Id, Id> mapBDAToGeo = new Map<Id, Id>{lstBDA[0].Id => lstGeo[0].Id, lstBDA[1].Id => lstGeo[1].Id};
        List<BDA_Geography__c> lstBDAGeo = DataGeneratorHelper1_Test.createBDAGeography(mapBDAToGeo);
        
        TriggerExecutionController.skipAccountTrigger(true);
        Account clientAcc1 = AccountDataHelper_Test.createClientAccount();
        TriggerExecutionController.skipAccountTrigger(false);
        Business_Plan__c bp = new Business_Plan__c();
        bp.Lead_Account__c = clientAcc1.Id;
        bp.Name = 'Test';
        bp.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        insert bp;
    }
    @isTest 
    static void testAttractivenessAndKCAccount(){
        Id clientAccountRecTypeId =  (Id) Schema.SObjectType.Account.getRecordTypeInfosByName().get( Label.ClientAccountRecordType).getRecordTypeId();
        Account testClientAccount1 = [SELECT Id FROM Account WHERE RecordTypeId = :clientAccountRecTypeId limit 1];   
        //testClientAccount1.Attractiveness__c ='Key Client-MSL';
        Test.startTest();
        update testClientAccount1;
        Test.stopTest();
    }
    
    @isTest 
    static void testPopulateAccountAddressAreaOnUpdate(){

        Geography__c testGeo = [SELECT Id FROM Geography__c WHERE Type_Of_Location__c = 'Country' AND Name = 'United Kingdom' limit 1];
        Id clientAccountRecTypeId =  (Id) Schema.SObjectType.Account.getRecordTypeInfosByName().get( Label.ClientAccountRecordType).getRecordTypeId();
        Account testClientAccount = [SELECT Id, Country__c, MSL_Account_Owner__c FROM Account WHERE RecordTypeId = :clientAccountRecTypeId limit 1];

        Test.startTest();
            testClientAccount.Country__c = testGeo.Id;
            testClientAccount.MSL_Account_Owner__c = null;
            testClientAccount.BillingState = 'SFO';
            update testClientAccount;
        Test.stopTest();

        Account testAccToCheck = [SELECT Id, Sales_Group__c FROM Account WHERE Id =: testClientAccount.Id];
        //System.assert(testAccToCheck.Sales_Group__c != null, 'Sales Group is not populated on Account Update.');
    }

    @isTest 
    static void testPopulateAccountAddressAreaOnCreate(){

        Geography__c testGeo = [SELECT Id FROM Geography__c WHERE Type_Of_Location__c = 'Country' AND Name = 'United Kingdom' limit 1];
        Id clientAccountRecTypeId =  (Id) Schema.SObjectType.Account.getRecordTypeInfosByName().get( Label.ClientAccountRecordType).getRecordTypeId();
        Account clientAccount = new Account ();        
        clientAccount.Name = 'Test Class Client Account Address Area';
        clientAccount.Type = 'BCO' ;
        clientAccount.SCV_Code__c = '11110045402';
        clientAccount.SCV_Status__c = 'Active';
        clientAccount.RecordTypeId = clientAccountRecTypeId;
        clientAccount.BillingCity = 'London';
        clientAccount.BillingStreet = 'test street 123';
        clientAccount.BillingState = 'SFO';
        clientAccount.MSL_Account_Owner__c  = null ;  
        clientAccount.Country__c = testGeo.Id;
        clientAccount.Represents_Concern__c= true;


        Test.startTest();
            insert clientAccount;
        Test.stopTest();

        Account testAccToCheck = [SELECT Id, Sales_Group__c FROM Account WHERE Id =: clientAccount.Id];
        //System.assert(testAccToCheck.Sales_Group__c != null, 'Sales Group is not populated on Account Create');
    }

    @IsTest
    static void testBeforeDelete(){
        Id clientAccountRecTypeId =  (Id) Schema.SObjectType.Account.getRecordTypeInfosByName().get( Label.ClientAccountRecordType).getRecordTypeId();
        Account testClientAccount = [SELECT Id, Country__c, MSL_Account_Owner__c FROM Account WHERE RecordTypeId = :clientAccountRecTypeId limit 1];

        try{
            delete testClientAccount;
        } catch(Exception e){
            System.debug('## e: ' + e.getMessage());
        }
    }

}