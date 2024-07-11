@IsTest
public class SharingHelperTest {
    @TestSetup static void testDataSetup() {
        User user1 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
        System.debug(user1.isActive);
        //User user2 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
        List<String> cadence= new List<String>{'Monthly','Monthly','Monthly'};
            List<String> year = new List<String>{'2034','2035','2036'};
                List<String> curr = new List<String>{'USD','USD','USD'};
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
        List<String> productFamily = new List<String>{'4PL PF','AIR PF','Cold Chain PF'}; 
            List<String> uniqueIds = new List<String>{'INML','DKSM','INSM'};
                List<String> brands = new List<String>{'Maersk Line','Hamburg Sud','B2C'};
                    Account acc = TestBusinessHelper.createAccount('Client_Account',true);
        List<Target_item_group__c> testTargetGroup = TestBusinessHelper.createSalesTargetItemGroups(testTargets, brands,cntry,bdaGeo, productFamily, 3, true);
        List<Target_item__c> SalesTargetItems = TestBusinessHelper.createSalesTargetItems(testTargetGroup, acc, 3, true);	    
        
    }
    
    @isTest static void  testshareRecords(){
        Map<Id, String> mapAccessLevelByRecordId = new Map<Id, String>();
        Map<Id, List<Id>> mapUserOrGrpByRecordId = new Map<Id, List<Id>>();
        
        List<Target_item__c> targetItemList = [select Id from Target_item__c];
        List<Target_Item__Share> itemShareList = [Select AccessLevel, ParentId, RowCause, UserOrGroupId from Target_Item__Share];
        
        for(Target_Item__Share reviewer : itemShareList){
            for(Target_Item__c item : targetItemList){
                mapAccessLevelByRecordId.put(item.Id, 'Edit');
                if(!mapUserOrGrpByRecordId.containsKey(reviewer.ParentId)){
                    mapUserOrGrpByRecordId.put(reviewer.ParentId,new List<Id>{reviewer.Id}); 
                }else{
                    mapUserOrGrpByRecordId.get(reviewer.ParentId).add(reviewer.Id);
                }
            }
        }
        
        SharingHelper.shareRecords(mapAccessLevelByRecordId, mapUserOrGrpByRecordId);
    }
    
}