@IsTest
public class BudgetMeasureTriggerTest {
    @testSetup
    static void setupTestData() {
        User user1 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
        List<String> cadence= new List<String>{'Monthly','Monthly','Monthly'};
        List<String> year= new List<String>{'2034','2035','2036'};
        List<String> curr= new List<String>{'USD','USD','USD'};
        List<Target__c> testTargets = TestBusinessHelper.createSalesTargets(user1, year,curr,cadence, 3, true);
        Geography__c testCountry = new Geography__c();
         testCountry.Name = 'India';
         testCountry.Active__c =true;
         testCountry.GEO_Code__c = 'IN';
         testCountry.GEO_ID__c = '10Z2W9Zkjh3q4cf6';
         testCountry.Is_Port__c = false;
         testCountry.Type_Of_Location__c = 'Country';
         insert testCountry;
         BDA__c testCluster = new BDA__C ();
         testCluster.Name = 'West Africa Area';
         testCluster.Type__c = 'Cluster';
         testCluster.BDA_Code__c = 'WAF';
         testCluster.GEO_ID__c= 'dsaewetwer';
         testCluster.Active__c  =  true;
         insert testCluster;
         BDA_Geography__c bdaGeo = new BDA_Geography__c(); 
         bdaGeo.BDA__c = testCluster.Id;
         bdaGeo.Geography__c = testCountry.Id;
         insert bdaGeo;
        Budget_Group__c budgetGp=TestBusinessHelper.createSalesBudgetGroup(testTargets[0],'Alianca',testCluster,testCountry,'RAIL PF','ALIARAIL',true);
        List<Budget_Group__c> listbdGp=new List<Budget_Group__c>{budgetGp,budgetGp,budgetGp};
        List<String> measureDm=new List<String>{'Rolling Forecast','Budget','Pipeline'};
        List<String> measureType=new List<String>{'Revenue','Gross Profit','Volume Growth Percent'};
        List<Budget_Measure__c> lstbdgtMeasure=TestBusinessHelper.createBudgetMeasures(listbdGp,measureDm,measureType,3,true);
    }
    
     @IsTest
     static void testBudgetMeasuresValidations() {
       List<Budget_Measure__c> budgetMeasureList=[SELECT Id,Name,Budget_Group__c,Measure_Dimension__c,Measure_Type__c from 
                                                  Budget_Measure__c];
       Test.startTest();
       BudgetMeasureTriggerHelper.checkForDuplicateBudgetMeasure(budgetMeasureList);
       budgetMeasureList[0].Measure_Dimension__c='Pipeline';
       update budgetMeasureList[0];
       Test.stopTest();
}
}