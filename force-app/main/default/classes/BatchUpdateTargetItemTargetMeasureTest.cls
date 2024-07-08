@isTest
public class BatchUpdateTargetItemTargetMeasureTest {
    @testSetup
    static void setupTestData() {        User user1 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
        
        List<String> cadence= new List<String>{'Monthly','Monthly','Monthly'};
        List<String> year= new List<String>{'2034','2035','2036'};
        List<String> curr= new List<String>{'USD','USD','USD'};
            
        List<Target__c> testTargets = TestBusinessHelper.createSalesTargets(user1, year,curr,cadence, 3, true);
        Geography__c testCountry = TestBusinessHelper.createGeography('India', 'Country', null, true);
        BDA__c testCluster = TestBusinessHelper.createBDA('West Africa Area', 'Cluster', 'WAF', null, null, true);
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(testCluster.Id,testCountry.Id,null, true);
        List<Geography__c> cntry= new List<Geography__c>{testCountry,testCountry,testCountry};
            
        List<String> productFamily= new List<String>{'4PL PF','INLAND PF','Depot & EMR PF'}; 
        List<String> brands= new List<String>{'Maersk Line','Hamburg Sud'};
        Account acc= TestBusinessHelper.createAccount('Client_Account',true);
        
        List<Target_item_group__c> testTargetGroup= TestBusinessHelper.createSalesTargetItemGroups(testTargets, brands,cntry,bdaGeo, productFamily, 3, true);
        List<Target_item__c> SalesTargetItems= TestBusinessHelper.createSalesTargetItems(testTargetGroup, acc, 3, true);
		system.debug('SalesTargetItems ' + SalesTargetItems);        
        List<String>measureDim=new List<String>{TargetSettingConstants.CY_ACTUALS,TargetSettingConstants.TARGET,TargetSettingConstants.CY_ACTUALS};
        List<String>measureType=new List<String>{'Revenue','Gross Profit','Volume'};
        List<String>partyType=new List<String>{'Price Owner','Shipper','Consignee'};
        List<Boolean> credEligible=new List<Boolean>{true,false,true};
        List <Target_measure__c> testItemMeasures= TestBusinessHelper.createSalesTargetItemMeasures(SalesTargetItems, measureDim, measureType, partyType,credEligible, 3, true);
        
    }
    
    @isTest
    static void testExecuteMeasureBatch() {
        Map<String, String> mapOfMonthTovalue = new Map<String, String>();
        Map<String, String> previousval = new Map<String, String>();
        mapOfMonthTovalue.put('Jan__c', '100');
        mapOfMonthTovalue.put('Feb__c', '100');
        mapOfMonthTovalue.put('Mar__c', '100');
        mapOfMonthTovalue.put('Apr__c', '100');
        mapOfMonthTovalue.put('May__c', '100');
        mapOfMonthTovalue.put('Jun__c', '100');
        mapOfMonthTovalue.put('Jul__c', '100');
        mapOfMonthTovalue.put('Aug__c', '100');
        mapOfMonthTovalue.put('Sep__c', '100');
        mapOfMonthTovalue.put('Oct__c', '100');
        mapOfMonthTovalue.put('Nov__c', '100');
        mapOfMonthTovalue.put('Dec__c', '100');
        for(Target_Measure__c tms : [Select Id,Target_Item__c, Name, Measure_Type__c, Measure_Dimension__c, Jan__c,Feb__c, Mar__c, Apr__c, May__c,  Jun__c, Jul__c, Aug__c, Sep__c,Oct__c, 
                                     Nov__c, Dec__c, Credit_Eligible__c, Party_Type__c,Q1_Total__c, Q2_Total__c, Q3_Total__c, Q4_Total__c, Total__c from Target_Measure__c]){
                                         previousval.put(tms.Target_Item__c, JSON.serialize(tms));                 
                                     }
        Map<String, String> datamap 
            = new Map<String, String>{'Jan__c'=>'11','Feb__c'=>'11','Mar__c'=>'11','Apr__c'=>'11','May__c'=>'11','Jun__c'=>'11','Jul__c'=>'11','Aug__c'=>'11','Sep__c'=>'11','Oct__c'=>'11','Nov__c'=>'11','Dec__c'=>'11'};
                List<Target__c> targetList = [SELECT Id FROM Target__c];
        
        Test.startTest();
        BatchUpdateTargetItemTargetMeasure bch = new BatchUpdateTargetItemTargetMeasure('', targetList[0].Id,'Yes','Revenue', datamap,new List<String>{'Price Owner','Shipper'}, previousval,'Percentage', null);
        DataBase.executeBatch(bch);  
        Test.stopTest();
    }
    
    @isTest
    static void testExecuteMeasureBatch1() {
        Map<String, String> mapOfMonthTovalue = new Map<String, String>();
        Map<String, String> previousval = new Map<String, String>();
        mapOfMonthTovalue.put('Jan__c', '100');
        mapOfMonthTovalue.put('Feb__c', '100');
        mapOfMonthTovalue.put('Mar__c', '100');
        mapOfMonthTovalue.put('Apr__c', '100');
        mapOfMonthTovalue.put('May__c', '100');
        mapOfMonthTovalue.put('Jun__c', '100');
        mapOfMonthTovalue.put('Jul__c', '100');
        mapOfMonthTovalue.put('Aug__c', '100');
        mapOfMonthTovalue.put('Sep__c', '100');
        mapOfMonthTovalue.put('Oct__c', '100');
        mapOfMonthTovalue.put('Nov__c', '100');
        mapOfMonthTovalue.put('Dec__c', '100');
        List<Target__c> targetList = [SELECT Id FROM Target__c];
        Test.startTest();
        BatchUpdateTargetItemTargetMeasure bch = new BatchUpdateTargetItemTargetMeasure('', targetList[0].Id,'Yes','Revenue', mapOfMonthTovalue,new List<String>{'Price Owner','Shipper'},  null,'Amount', null);
        DataBase.executeBatch(bch);  
        Test.stopTest();
    }
    // method to cover 'TargetSettingPortfolioAssignmentBatch'
    @isTest
    static void testPortfolioAssignementbatch(){
        List<Target__c> targetList = [SELECT Id FROM Target__c];
        Test.startTest();
        TargetSettingPortfolioAssignmentBatch bt = new TargetSettingPortfolioAssignmentBatch(targetList[0].Id);
        DataBase.executeBatch(bt);  
        Test.stopTest();
    }
}