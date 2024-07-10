/*
* Purpose : Test class for BatchUpdateAccountAddressArea
*        
* Revision Ref Number  Date            Owner                                  Description
* -------- ----------  -----------     -------------------                    -----------
* 1.0      SFSE-6116   24-Jun-2021     nitin@maersk                           Code created 
*/
@isTest
public class BatchUpdateAccountAddressArea_Test {
    
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
        clientAcc1.Country__c = lstGeo[0].Id;
        update clientAcc1;
                                
        TriggerExecutionController.skipAccountTrigger(false);
    }

    @isTest
    static void testBatchUpdateAddressGroup(){
        Test.startTest();
            BatchUpdateAccountAddressArea batchUpdAAA = new BatchUpdateAccountAddressArea(false);
            Database.executeBatch( batchUpdAAA, 10);
        Test.stopTest();

        Id clientAccountRecTypeId =  (Id) Schema.SObjectType.Account.getRecordTypeInfosByName().get( Label.ClientAccountRecordType).getRecordTypeId();
        List<Account> lstAccountToCheck = [SELECT Id, Account_Address_Area__c FROM Account WHERE RecordTypeId = :clientAccountRecTypeId AND Country__c != null ];

        System.assert(lstAccountToCheck[0].Account_Address_Area__c != null, 'Account Address Area is not populated');
    }
        
}