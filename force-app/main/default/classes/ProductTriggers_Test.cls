/******************************************************************************************************************************************************************************
*Version           Owner                             Date                Description
* 2.0       Sunu.Paul@ust-global.com            09.02.2015          #RQ-0002978-Introduced Data Generator classes and changed the class name to TestClean_ProductTriggers
* 3.0       Abby.Abraham@ust-global.com         25.04.2017          #RQ-005191 -  Added SeeAllData true to get the Standard PriceBook Entry
* 4.0       Junaid.Khader@ust-global.com        24.01.2019          RQ-009931 - Modified test class to incorporate new changes as part of introducing CBO architecture
*******************************************************************************************************************************************************************************/ 
@isTest(SeeAllData=false)
private class ProductTriggers_Test {
    @testSetup static void setupTestData(){
        // Creating Ocean product
        DataGeneratorHelper1_Test.createProduct2(1, 'AB', 'NB', 'Ocean');
        // Creating Non-Ocean product
        DataGeneratorHelper1_Test.createProduct2(1, 'ABC', '', 'Lead Logistics');
    }
    
    testMethod static void testProductUpdate() {
    	Product2 nonOceanProduct = [SELECT Id, isActive FROM Product2 WHERE OIPC_Code__c = 'P-P0-wet' LIMIT 1];
        Test.startTest();
        nonOceanProduct.isActive = true;
        update nonOceanProduct;
        Test.stopTest();
    }
}