@isTest(seeAllData=false)
public class ProductAreaMetricTriggerTest {
    
	@testSetUp
    static void testSetUp() {
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
        AccountData_Test.createClientAccounts();
        List<Account> accountList = [SELECT Id,Name,Represents_Concern__c,SCV_Status__c from Account where RecordType.DeveloperName = 'Client_Account'];
        Business_Plan__c AccountPlanRec = TestBusinessHelper.createBusinessPlan(accountList[0],Brand__mdt.getInstance('MaerskLine').MasterLabel,true);
        List<String> family1 = new List<String>{'Landside Transportation','Contract Logistics'};
        List<Product2> prod = TestBusinessHelper.createProducts(family1, 1, true);
        Customer_Metrics__c metric = new Customer_Metrics__c();
        metric.Business_Plan__c = AccountPlanRec.Id;
        metric.Year__c = '2023';
        BDA__c bda1 = TestBusinessHelper.createBDA('test bda 1', 'Cluster', '1123', null, null, true);
        BDA__c bda2 = TestBusinessHelper.createBDA('test bda 2', 'Cluster', '1234', null, null, true);
        metric.Account__c = accountList[0].Id;
        insert metric;
    }
    
    @isTest
    static void testValidateMetricsForAreaNegative() {
        
        
        Customer_Metrics__c metric = [SELECT Id FROM Customer_Metrics__c LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        Customer_Product_Planning__c customer = new Customer_Product_Planning__c();
        customer.Product_Name__c = prod.Id;
        customer.Customer_Metrics__c = metric.Id;
        customer.Product_Family_Customer_Metric1__c='4PL PF';
        insert customer;
        
        BDA__c bda1 = [SELECT Id FROM BDA__c WHERE Active__c = true AND Type__c = 'Cluster' and Name =: 'test bda 1'];
        BDA__c bda2 = [SELECT Id FROM BDA__c WHERE Active__c = true AND Type__c = 'Cluster'  and Name =: 'test bda 2'];
        Product_Area_Metric__c prodMetric1 = new Product_Area_Metric__c (
				Area__c = bda1.id,
                Maersk_Revenue__c = 2000, 
            Customer_Product_Metric__c = customer.id
        ) ;
        Product_Area_Metric__c prodMetric2 = new Product_Area_Metric__c (
				Area__c = bda1.id,
                Maersk_Revenue__c = 2000, 
            	Customer_Product_Metric__c = customer.id
        ) ;
        Test.startTest();
        insert prodMetric1;
        try {
            insert prodMetric2;
			prodMetric2.Area__c = bda2.id;
        } catch (Exception ex) {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Area for the selected Customer Product Metric already exist.') ? true : false;
			System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
     @isTest
    static void testValidateMetricsForAreaNegativeUpdate() {
        
        
        Customer_Metrics__c metric = [SELECT Id FROM Customer_Metrics__c LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        Customer_Product_Planning__c customer = new Customer_Product_Planning__c();
        customer.Product_Name__c = prod.Id;
        customer.Customer_Metrics__c = metric.Id;
        customer.Product_Family_Customer_Metric1__c='4PL PF';
        insert customer;
        
        BDA__c bda1 = [SELECT Id FROM BDA__c WHERE Active__c = true AND Type__c = 'Cluster' and Name =: 'test bda 1'];
        BDA__c bda2 = [SELECT Id FROM BDA__c WHERE Active__c = true AND Type__c = 'Cluster'  and Name =: 'test bda 2'];
        Product_Area_Metric__c prodMetric1 = new Product_Area_Metric__c (
				Area__c = bda1.id,
                 Maersk_Revenue__c = 2000,
            Customer_Product_Metric__c = customer.id
        ) ;
        Product_Area_Metric__c prodMetric2 = new Product_Area_Metric__c (
				Area__c = bda1.id,
                 Maersk_Revenue__c = 2000, 
            	Customer_Product_Metric__c = customer.id
        ) ;
        Test.startTest();
        insert prodMetric1;
        try {
            Product_Area_Metric__c prod1 = [SELECT ID, Area__c FROM Product_Area_Metric__c LIMIT 1];
            prod1.Area__c = bda2.id;
            update prod1;
        } catch (Exception ex) {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Area for the selected Customer Product Metric already exist.') ? true : false;
			System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
}