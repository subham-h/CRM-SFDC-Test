@isTest
public class BudgetGroupTriggerTest {
    
    @testSetup
    static void testSetUp() {
        User user1 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
        List<String> cadence= new List<String>{'Monthly','Monthly','Monthly'};
        List<String> year= new List<String>{'2034','2035','2036'};
        List<String> curr= new List<String>{'USD','USD','USD'};
        List<Target__c> testTargets = TestBusinessHelper.createSalesTargets(user1, year,curr,cadence, 3, true);
        BDA_Geography__c bdaGeography = BDAGeographyData_Test.lstBDAGeographies[0];
        BDA__c bda = new BDA__c(Type__c = 'Cluster', Id = bdaGeography.BDA__c);
        update bda;
        Geography__c geo = new Geography__c(Type_Of_Location__c ='Country',Id=bdaGeography.Geography__c);
        update geo;
    }
    
    @isTest
    static void testBudgetGroup() {
        Target__c target = [SELECT ID FROM Target__c limit 1];
        BDA__c bda = [SELECT Id FROM BDA__c limit 1];
        Geography__c geo = [SELECT Id FROM Geography__c LIMIT 1];
        Test.startTest();
        Budget_Group__c budgetGroup = new Budget_Group__c ();
        budgetGroup.Brand__c = 'Maersk Line';
        budgetGroup.Product_Family__c = '4PL PF';
        budgetGroup.Target__c = target.Id;
        budgetGroup.Executing_Country__c = geo.Id;
        budgetGroup.Country_Code__c = 'US';
        insert budgetGroup;
        Test.stopTest();
    }
    
    @isTest
    static void testBudgetGroup1() {
        Target__c target = [SELECT ID FROM Target__c limit 1];
        BDA__c bda = [SELECT Id FROM BDA__c limit 1];
        Geography__c geo = [SELECT Id FROM Geography__c LIMIT 1];
        Test.startTest();
        Budget_Group__c budgetGroup = new Budget_Group__c ();
        budgetGroup.Brand__c = 'Maersk Line';
        budgetGroup.Product_Family__c = '4PL PF';
        budgetGroup.Target__c = target.Id;
        budgetGroup.Executing_Country__c = geo.Id;
        insert budgetGroup;
        try {
            Budget_Group__c budgetGroup1 = new Budget_Group__c ();
            budgetGroup1.Brand__c = 'Maersk Line';
            budgetGroup1.Product_Family__c = '4PL PF';
            budgetGroup1.Target__c = target.Id;
            insert budgetGroup1; 
        } catch (Exception ex) {
    
}        Test.stopTest();
    }
}