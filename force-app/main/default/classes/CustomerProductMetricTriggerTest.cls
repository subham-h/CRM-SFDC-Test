/*              
* Revision   Ref Number   Date          Owner                 Description
* --------   ----------   -----------   -----------------     -----------
* 1.0        SFSE-11986   10-10-2023    Seba                  Test Class for CustomerProductMetricTrigger
* 2.0        SFSE-13430   09-02-2024    Anjali                Modified test class to check for duplicate product family
*/
@isTest(seeAllData=false) 
public class CustomerProductMetricTriggerTest {    
	@testSetUp
    static void testSetUp() {
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
        AccountData_Test.createClientAccounts();
        List<Account> accountList = [SELECT Id,Name,Represents_Concern__c,SCV_Status__c from Account where RecordType.DeveloperName = 'Client_Account'];
        Business_Plan__c AccountPlanRec = TestBusinessHelper.createBusinessPlan(accountList[0],Brand__mdt.getInstance('MaerskLine').MasterLabel,true);
        List<String> family1 = new List<String>{'Landside Transportation','Contract Logistics'};
        List<Product2> prod = TestBusinessHelper.createProducts(family1, 2, true);
        Customer_Metrics__c metric = new Customer_Metrics__c();
        metric.Business_Plan__c = AccountPlanRec.Id;
        metric.Year__c = '2023'; 
        metric.Account__c = accountList[0].Id;
        insert metric;
    }
    
    @isTest
    static void testValidateDuplicateProductInsert() { 
        
        Customer_Metrics__c metric = [SELECT Id FROM Customer_Metrics__c LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        Customer_Product_Planning__c customerProductMetricRec1 = new Customer_Product_Planning__c();
        customerProductMetricRec1.Product_Name__c = prod.Id;
        customerProductMetricRec1.Product_Family_Customer_Metric1__c='4PL PF';
        customerProductMetricRec1.Customer_Metrics__c = metric.Id;
        insert customerProductMetricRec1; 
        
        Test.startTest();
        Customer_Product_Planning__c customerProductMetricRec2 = new Customer_Product_Planning__c();
        customerProductMetricRec2.Product_Name__c = prod.Id;
        customerProductMetricRec2.Customer_Metrics__c = metric.Id;
        customerProductMetricRec2.Product_Family_Customer_Metric1__c='4PL PF';
         
        try { 
            insert customerProductMetricRec2;
        } catch (Exception ex) {
            Boolean expectedExceptionThrown =  ex.getMessage().contains(LABEL.Duplicate_Product_Family_on_Customer_Metric) ? true : false;
			System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
    @isTest
    static void testValidateDuplicateProductUpdate() {
        List<Customer_Product_Planning__c> lstCustomerProductPlanning = new List<Customer_Product_Planning__c>();
        
        Customer_Metrics__c metric = [SELECT Id FROM Customer_Metrics__c LIMIT 1];
        List<Product2> lstProd = [SELECT Id FROM Product2];
        Customer_Product_Planning__c customer1 = new Customer_Product_Planning__c();
        customer1.Product_Name__c = lstProd[0].Id;
        customer1.Product_Family_Customer_Metric1__c='4PL PF';
        customer1.Customer_Metrics__c = metric.Id;
        lstCustomerProductPlanning.add(customer1);
        
        Customer_Product_Planning__c customer2 = new Customer_Product_Planning__c();
        customer2.Product_Name__c = lstProd[1].Id;
        customer2.Product_Family_Customer_Metric1__c='Customs PF';
        customer2.Customer_Metrics__c = metric.Id;
        lstCustomerProductPlanning.add(customer2);
        
        insert lstCustomerProductPlanning;
        
        Test.startTest(); 
        try {
 			customer2.Product_Name__c = lstProd[0].Id;
            update customer2;
        } catch (Exception ex) {
            Boolean expectedExceptionThrown =  ex.getMessage().contains(LABEL.Duplicate_Product_Family_on_Customer_Metric) ? true : false;
			System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
}