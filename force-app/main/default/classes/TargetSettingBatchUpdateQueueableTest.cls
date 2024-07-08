@isTest
private class TargetSettingBatchUpdateQueueableTest {
	
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
        List<Geography__c> cntry= new List<Geography__c>{testCountry,testCountry,testCountry};
        String countryCode= 'IN';
        List<String> productFamily= new List<String>{'4PL PF','AIR PF','Cold Chain PF'}; 
        List<String> uniqueIds= new List<String>{'INML','DKSM','INSM'};
        List<String> brands= new List<String>{'Maersk Line','Hamburg Sud','B2C'};
        Account acc= TestBusinessHelper.createAccount('Client_Account',true);
        List<Target_item_group__c> testTargetGroup= TestBusinessHelper.createSalesTargetItemGroups(testTargets, brands,cntry,bdaGeo, productFamily, 3, true);
        List<Target_item__c> SalesTargetItems= TestBusinessHelper.createSalesTargetItems(testTargetGroup, acc, 3, true);
        List<String>measureDim=new List<String>{TargetSettingConstants.CY_ACTUALS,TargetSettingConstants.TARGET,TargetSettingConstants.CY_ACTUALS};
        List<String>measureType=new List<String>{'Revenue','Gross Profit','Volume'};
        List<String>partyType=new List<String>{'Price Owner','Shipper','Consignee'};
        List<Boolean> credEligible=new List<Boolean>{true,false,true};
        List <Target_measure__c> testItemMeasures= TestBusinessHelper.createSalesTargetItemMeasures(SalesTargetItems, measureDim, measureType, partyType,credEligible, 3, true);

        BDA__c bdaArea = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Area', 'IBA', null, user1.Id, true);
        Target__c target = TestBusinessHelper.createSalesTarget(user1, '2050', 'USD', 'Monthly', true);      
        Budget_Group__c budgetGroup = TestBusinessHelper.createSalesBudgetGroup(target, 'Hamburg Sud', bdaArea, testCountry, '4PL PF', 'StagingReference', true );
        Budget_Measure__c budgetMeasure = TestBusinessHelper.createBudgetMeasure(budgetGroup, 'Budget', 'Volume Growth Percent', true);
        Budget_Measure__c budgetMeasure2 = TestBusinessHelper.createBudgetMeasure(budgetGroup, 'Budget', 'Revenue Growth Percent', true);
        Target_Item_Group__c targetItemGroup = TestBusinessHelper.createSalesTargetItemGroup(target, 'Hamburg Sud', testCountry, bdaGeo, 'WND PF', true);
        Target_item__c targetItem = TestBusinessHelper.createSalesTargetItem(target, targetItemGroup, null, acc, null, null, null, true);
        Target_Measure__c targetMeasure = TestBusinessHelper.createSalesTargetItemMeasure(targetItem, 'Previous Year Actuals', 'Volume', 'Shipper', false, true);        
        Target_Measure__c targetMeasure2 = TestBusinessHelper.createSalesTargetItemMeasure(targetItem, 'Previous Year Actuals', 'Revenue', 'Shipper', false, true);
        Target_Measure__c targetMeasure3 = TestBusinessHelper.createSalesTargetItemMeasure(targetItem, 'Pipeline', 'Revenue', '', false, true);
        Target_Measure__c targetMeasure4 = TestBusinessHelper.createSalesTargetItemMeasure(targetItem, 'Target', 'Revenue', 'Shipper', false, true);
        
        Target_Setting_Staging__c stag = new Target_Setting_Staging__c();
        stag.Status__c = 'New'; 
        stag.Brand__c= 'Maersk Line';
        stag.Measure_Dimension__c = 'Rolling Forecast';
        stag.RoFo_Version__c = 'ROFOQ22023';
        stag.Country_Code__c = 'IN';
        stag.Product_Family__c = '4PL PF';
        stag.Measure_Type__c='Gross Profit';
        stag.Jan__c=10.00;
        stag.Feb__c=10.00;
        stag.Mar__c=10.00;
        stag.Apr__c=10.00;
        stag.May__c=10.00;
        stag.Jun__c=10.00;
        stag.Jul__c=10.00;
        stag.Aug__c=10.00;
        stag.Sep__c=10.00;
        stag.Oct__c=10.00;
        stag.Nov__c=10.00;
        stag.Dec__c=10.00;
        stag.Area__c = testCluster.id;
        stag.Country__c = testCountry.id;
        stag.Area__c = testCluster.id;
        stag.Country__c = testCountry.id;
        insert stag;
    }
    
    @isTest
    static void testQueuable() {
        List<Target_Measure__c> targetMeasureList = [SELECT Id FROM Target_Measure__c];
        List<Target_Setting_Staging__c> targetStagingList = [SELECT Id FROM Target_Setting_Staging__c];
        Test.startTest();
        	System.enqueueJob(new TargetSettingBatchUpdateQueueable(targetMeasureList, NULL));
        	System.enqueueJob(new TargetSettingBatchUpdateQueueable(NULL,targetStagingList));
        Test.stopTest();
    }
    
    @isTest
    static void testQueuable1() {
        List<Target_Measure__c> targetMeasureList = [SELECT Id FROM Target_Measure__c];
        List<Target_Setting_Staging__c> targetStagingList = [SELECT Id FROM Target_Setting_Staging__c];
        Test.startTest();
        	System.enqueueJob(new TargetSettingBatchUpdateQueueable(targetMeasureList, targetStagingList));
        Test.stopTest();
    }
    
}