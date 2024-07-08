@isTest
public class ProductExclusionCntrlTest {
    
    @testSetup
    static void setUpData() {
        List<Target__c> targetList = new List<Target__c>();
        Target__c target = new Target__c();
        target.Status__c = 'New';
        target.Cadence__c = 'Monthly';
        target.Applicable_Year__c = '2050';
        Target__c target1 = new Target__c();
        target1.Status__c = 'New';
        target1.Cadence__c = 'Monthly';
        target1.Applicable_Year__c = '2060';
        targetList.add(target);
        targetList.add(target1);
        insert targetList;
        Target_Product_Exclusion__c productExclusion = new Target_Product_Exclusion__c();
        productExclusion.Target__c = targetList[0].Id;
        productExclusion.Brand__c = 'Maersk Line';
        productExclusion.Product_Family__c = '4PL PF';
        insert productExclusion;
    }
    
    @isTest
    static void testCreateProductExclusion() {
        Test.startTest();
        List<Target__c> targetList = [SELECT Id FROM Target__c ORDER BY Cadence__c];
        ProductExclusionCntrl.createProductExclusion(targetList[0].Id,targetList[1].Id);
        Test.stopTest();
        targetList = [SELECT Id,(SELECT Id FROM Target_Product_Exclusions__r) FROM Target__c WHERE Applicable_Year__c = '2060'];
        System.assertEquals(1, targetList[0].Target_Product_Exclusions__r.size()); 
    }
}