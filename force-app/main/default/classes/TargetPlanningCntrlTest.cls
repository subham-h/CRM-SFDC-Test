/*  
* Version	Date			Owner					Description
* --------	-----------		-------------------		-----------
* 1.0		25-Sept-2023	Vazid					Test class for TargetPlanningCntrl
* 2.0		20-Oct-2023	    Vazid					Modified for SFSE-13044
*/
@isTest
public class TargetPlanningCntrlTest {
    
    @testSetUp
    static void testData() {
        
        User user1 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
        
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
        
        List<String>measureDim=new List<String>{TargetSettingConstants.CY_ACTUALS,TargetSettingConstants.TARGET,TargetSettingConstants.CY_ACTUALS};
        List<String>measureType=new List<String>{'Revenue','Gross Profit','Volume'};
        List<String>partyType=new List<String>{'Price Owner','Shipper','Consignee'};
        List<Boolean> credEligible=new List<Boolean>{true,false,true};
        List <Target_measure__c> testItemMeasures= TestBusinessHelper.createSalesTargetItemMeasures(SalesTargetItems, measureDim, measureType, partyType,credEligible, 3, true);
    }
    
    @isTest static void testgetTargetItemRecords() {
        List<Target__c> targetRec = [Select Id from Target__c limit1];
        string whereQuery = ' AND Account_Name__c like \'%test%\'';
        User user1 = [SELECT Id FROM User Limit 1];
        //String userId = user1.Id;
        TargetPlanningCntrl.getTargetItemRecords(targetRec[0].Id,'Assigned_Sales_Rep__c = \''+user1.Id+'\'', whereQuery,0,50,'Name','DESC','Yes');
    }

	@isTest static void testgetTargetItemRecords2() {
        List<Target__c> targetRec = [Select Id from Target__c limit1];
        string whereQuery = ' AND Account_Name__c like \'%test%\'';
        User user1 = [SELECT Id FROM User Limit 1];
        TargetPlanningCntrl.getTargetItemRecords(targetRec[0].Id,'Assigned_Sales_Rep__r.Manager.Id = \''+user1.Id+'\'', whereQuery,0,50,'Name','DESC','Yes');
    }
    
    @isTest static void testgetTargetItemRecords3() {
        List<Target__c> targetRec = [Select Id from Target__c limit1];
        string whereQuery = ' AND Account_Name__c like \'%test%\'';
        User user1 = [SELECT Id FROM User Limit 1];
        TargetPlanningCntrl.getTargetItemRecords(targetRec[0].Id,'Portfolio_Owner_Responsibility__c = \'Global Account Owner\'', whereQuery,0,50,'Name','DESC','Yes');
    }
    
    @isTest static void testgetItemMeasureRecords() {
        Map<String, String> datamap 
            = new Map<String, String>{'Jan__c'=>'11','Feb__c'=>'11','Mar__c'=>'11','Apr__c'=>'11','May__c'=>'11','Jun__c'=>'11','Jul__c'=>'11','Aug__c'=>'11','Sep__c'=>'11','Oct__c'=>'11','Nov__c'=>'11','Dec__c'=>'11'};
        Map<Id,Target_item__c> targetItemRec = new Map<Id, Target_item__c>([Select Id from Target_item__c limit 1]);
        List<Id> lstOfIds = new List<Id>(targetItemRec.keyset());
        TargetPlanningCntrl.getItemMeasureRecords(lstOfIds[0], datamap, null, 'Volume', TargetSettingConstants.TARGET,new List<String>{'Price Owner','Shipper'}, 'Yes', null);
        TargetPlanningCntrl.getItemMeasureRecordsForTargetPlanning(lstOfIds,'Volume',TargetSettingConstants.TARGET,'Price Owner', 'Yes');//SFSE-13044
    }
    
    @isTest static void updateMeasureRecords() {
        Target_Measure__c measureRec = [Select Id, Name, Measure_Type__c, Measure_Dimension__c, Jan__c,Feb__c, Mar__c, Apr__c, May__c,  Jun__c, Jul__c, Aug__c, Sep__c,Oct__c, Nov__c, Dec__c from Target_Measure__c limit 1];
        measureRec.Jan__c = 1000;
        TargetPlanningCntrl.updateMeasureRecords(measureRec);
    }
    
    @isTest static void testgetCountOfTargetItems() {
        List<Target__c> targetRec = [Select Id from Target__c limit1];
        string whereQuery = ' AND Account_Name__c like \'%test%\'';
        User user1 = [SELECT Id FROM User Limit 1];
        TargetPlanningCntrl.getCountOfTargetItems(targetRec[0].Id,whereQuery,'Yes', 'Assigned_Sales_Rep__c = \''+user1.Id+'\'');
    }
    @isTest static void testfireTargetMeasureBatch() {
        List<Target__c> targetRec = [Select Id from Target__c limit1];
          string whereQuery = ' AND Account_Name__c like \'%test%\'';
        Test.startTest();
        TargetPlanningCntrl.fireTargetMeasureBatch(whereQuery,targetRec[0].Id,'Yes','Revenue',null,new List<String>{'Price Owner','Shipper'}, null, 'Amount',null);
        TargetPlanningCntrl.getBatchIdStatus();
        Test.stopTest();
    }
}