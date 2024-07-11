/**
* Test class for :  BatchUpdatePortfolioSalesJobFunction 

* Date         Owner                                                    Description
*************************************************************************************************************************************
* 24-06-2021   Neha@TCS                                                 Test class for BatchUpdatePortfolioSalesJobFunction 

* */

@isTest
public class BatchPortfolioSalesJobFunction_Test{
    
    @testSetup static void setup() {
        TerritoryDataGeneration_Test.createTerritoryData(); // this will insert the territory and the associated account association
    }
    
    testmethod static void testBatchMigration() {
        Test.startTest();
        BatchUpdatePortfolioSalesJobFunction batchTest = new BatchUpdatePortfolioSalesJobFunction();
        Database.executeBatch( batchTest);
         Id portfolioRecTypeId =  (Id) Schema.SObjectType.Territory__c.getRecordTypeInfosByName().get('Portfolio').getRecordTypeId();
        List<Territory_Account_Association__c> lstTAAToCheck = [SELECT Id, Territory__r.Portfolio_Owner_Sales_Job_Function__c,Portfolio_Owner_Sales_Job_Function__c  FROM Territory_Account_Association__c WHERE Territory__r.RecordTypeId = :portfolioRecTypeId  ];

        System.assertEquals(lstTAAToCheck[0].Territory__r.Portfolio_Owner_Sales_Job_Function__c, lstTAAToCheck[0].Portfolio_Owner_Sales_Job_Function__c);
        Test.stopTest();
    }
}