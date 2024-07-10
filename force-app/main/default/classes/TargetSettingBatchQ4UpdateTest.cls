@IsTest(SeeAllData = false)
public with sharing class TargetSettingBatchQ4UpdateTest {
    @TestSetup static void setupTestData() { 
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
        
        User salesUserTest = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
        salesUserTest.CM_Visibility__c ='Single Carrier'; 
        salesUserTest.id = null;
        salesUserTest.country = 'India';
        salesUserTest.Email = 'abc76g@lflogistics.com'; 
    
        System.runAs(new User(Id = UserInfo.getUserId())){
            TriggerExecutionController.skipAllTriggers(true); 
            insert salesUserTest;
        }
    
        System.runAs(salesUserTest){
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
            
            Target_Item_Group__c tig = new Target_Item_Group__c();
            tig.BrandMnA__c = 'Maersk Line';
            tig.Product_Family__c = '4PL PF';
            tig.Target__c=targetList[0].id;
            tig.Country_Code__c =' IN';
            tig.Executing_Area__c = testCluster.id;
            tig.Executing_Country__c = testCountry.id;
            insert tig;
            
            Budget_Group__c budgetGrp = new Budget_Group__c ();
            budgetGrp.Target__c = targetList[0].id;
            budgetGrp.Brand__c = 'Maersk Line';
            budgetGrp.Product_Family__c = '4PL PF';
            budgetGrp.Country_Code__c = 'IN';
            budgetGrp.Executing_Country__c = testCountry.Id;
            insert budgetGrp;
            
            Target_Item__c item = new Target_Item__c();
            item.Sales_Target_Item_Group__c = tig.Id;
            insert item;
            
            Target_Measure__c targetMeasure = new Target_Measure__c();
            targetMeasure.Jan__c = 10;
            targetMeasure.Feb__c  = 20;
            targetMeasure.Mar__c  = 30;
            targetMeasure.Apr__c = 40;
            targetMeasure.May__c = 50;
            targetMeasure.Jun__c = 60;
            targetMeasure.Jul__c = 70;
            targetMeasure.Aug__c  = 80;
            targetMeasure.Sep__c  = 90;
            targetMeasure.Oct__c = 10;
            targetMeasure.Nov__c = 10;
            targetMeasure.Dec__c = 10;
            targetMeasure.Measure_Type__c = 'Revenue';
            targetMeasure.Measure_Dimension__c =  TargetSettingConstants.PY_ACTUALS;
            targetMeasure.Target_Item__c = item.Id;
            targetMeasure.Party_Type__c = 'Price Owner';
            insert targetMeasure;    
        }
    }

    @IsTest static void runBatchTest() {
        Target__c targetRec = [SELECT Id from Target__c LIMIT 1];
        
        Test.startTest();
        TargetSettingBatchQ4Update batchTest = new TargetSettingBatchQ4Update(targetRec.Id);
        Database.executeBatch(batchTest); 
        Test.stopTest();
    }
}