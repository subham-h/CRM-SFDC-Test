@isTest
private class TargetItemMeasureTriggerTest {
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
        
    }
   
    @isTest
    static void testItemMeasuresValidations() {
        List<Target_measure__c> newTargetMeasures= [SELECT Id,name,measure_dimension__c,measure_type__c,party_type__c,credit_eligible__c,target_item__r.name from Target_measure__c];
        Test.startTest();        
        newTargetMeasures[0].Measure_Dimension__c='Target';
        newTargetMeasures[0].Jan__c=40;
        newTargetMeasures[0].Feb__c=40;
        newTargetMeasures[0].Mar__c=40;
        newTargetMeasures[0].Apr__c=40;
        newTargetMeasures[0].May__c=40;
        newTargetMeasures[0].Jun__c=40;
        newTargetMeasures[0].Jul__c=40;
        newTargetMeasures[0].Aug__c=40;
        newTargetMeasures[0].Sep__c=40;
        newTargetMeasures[0].Oct__c=40;
        newTargetMeasures[0].Nov__c=40;
        newTargetMeasures[0].Dec__c=40;
        update newTargetMeasures[0];
        Test.stopTest(); 
    }
    
    @isTest
    static void testCheckForDuplicateItemMeasure() { 
        Target_Item__c targetItem = [SELECT Id FROM Target_Item__c LIMIT 1];
        Test.startTest();
        try {
            Target_Measure__c targetMeasure2 = TestBusinessHelper.createSalesTargetItemMeasure(targetItem, 'Previous Year Actuals', 'Revenue', 'Shipper', false, true);
            Target_Measure__c targetMeasure7 = TestBusinessHelper.createSalesTargetItemMeasure(targetItem, 'Previous Year Actuals', 'Revenue', 'Shipper', false, true);
        } catch (Exception ex) {
            //System.assert(ex.getMessage().contains('Duplicate Current or Previous Year Actuals record for the same Measure Type,Party Type & SIP Eligible combination exists under the Target Item'), 
                          //'message=' + ex.getMessage());
        }
        try {
            Target_Measure__c targetMeasure3 = TestBusinessHelper.createSalesTargetItemMeasure(targetItem, 'Pipeline', 'Revenue', '', false, true);
            Target_Measure__c targetMeasure4 = TestBusinessHelper.createSalesTargetItemMeasure(targetItem, 'Pipeline', 'Revenue', '', false, true);
        } catch(Exception ex) {
            //System.assert(ex.getMessage().contains('Duplicate Pipeline record for the same Measure Type exists under the Target Item'), 
                          //'message=' + ex.getMessage());
        }
        try {
            Target_Measure__c targetMeasure5 = TestBusinessHelper.createSalesTargetItemMeasure(targetItem, 'Target', 'Revenue', 'Shipper', false, true);
            Target_Measure__c targetMeasure4 = TestBusinessHelper.createSalesTargetItemMeasure(targetItem, 'Target', 'Revenue', 'Shipper', false, true);
        } catch (Exception ex) {
            //System.assert(ex.getMessage().contains('Duplicate Target record for the same Measure Type, Party Type & SIP Eligible combination exists under the Target Item'), 
                          //'message=' + ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCheckForDuplicateItemMeasure1() { 
        Target_Item__c targetItem = [SELECT Id FROM Target_Item__c LIMIT 1];
        List<Target_Item__c> lsttargetItem=new List<Target_Item__c>();
        lsttargetItem.add(targetItem);
        List<String> lstmd=new List<String>{'Target','Target'};
        List<String> lstmtype= new List<String>{'Volume','Volume'};
        List<String> lstpartytype= new List<String>{'Shipper','Shipper'};
        List<Boolean> lstcredit=new List<Boolean>{true,true};
        Test.startTest();
        try{
            List<Target_Measure__c> targetMeasure6=TestBusinessHelper.createSalesTargetItemMeasures(lsttargetItem,lstmd,lstmtype,lstpartytype,lstcredit,2,true);
        }
        catch(Exception ex){}
        
        Test.stopTest();
    } 
}