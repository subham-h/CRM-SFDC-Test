/*  
* Version	Date			Owner					Description
* --------	-----------		-------------------		-----------
* 1.0		25-Sept-2023	Vazid					Test class for DynamicMultiFilterCntrl
*/
@isTest
public class DynamicMultiFilterCntrlTest {
    @testSetUp
    static void testData() {        
        User user1 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
    }
    
    @isTest static void testgetObjectFields() {
        DynamicMultiFilterCntrl.getObjectFields('Target_Item__c');
        DynamicMultiFilterCntrl.getOptionsForSelectedPicklistField('Target_Measure__c','Measure_Dimension__c');
    }
	@isTest static void testgetObjectFields2() {
        User user1 = [SELECT Id FROM User Limit 1];
        DynamicMultiFilterCntrl.getObjectFields('Target_Customer_Portfolio__c');
        DynamicMultiFilterCntrl.getTargetMeasureFromCustomerPortfolio('Assigned_Sales_Rep__c', user1.Id);
    }
}