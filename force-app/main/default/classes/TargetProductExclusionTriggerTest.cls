@isTest
public class TargetProductExclusionTriggerTest {

    @testSetup
    static void testSetup() {
        User user1 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
        TestBusinessHelper.createSalesTarget(user1,'2078','USD','Monthly',true);
    }
    
    @isTest
    static void testProductExclusions() {
        Target__c target = [SELECT Id FROM Target__c LIMIT 1];
        System.debug(target);
        Test.startTest();
        //TestBusinessHelper.createSalesTargetProductExclusion(target,'',null,null,null,'4PL PF',false);
        Target_Product_Exclusion__c prodExclusions = new Target_Product_Exclusion__c();
        prodExclusions.Target__C = target.Id;
        prodExclusions.Product_Family__c = '4PL PF';
        insert prodExclusions;
        update prodExclusions;
        delete prodExclusions;
        Test.stopTest();
    }
}