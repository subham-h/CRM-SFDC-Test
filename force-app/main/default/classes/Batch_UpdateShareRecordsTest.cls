@isTest
public class Batch_UpdateShareRecordsTest {
    
    @isTest
    static void testShareReadUpdate() {
        User user1 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
        List<String> cadence= new List<String>{'Monthly','Monthly','Monthly'};
        List<String> year = new List<String>{'2034','2035','2036'};
        List<String> curr = new List<String>{'USD','USD','USD'};
        List<Target__c> testTargets = TestBusinessHelper.createSalesTargets(user1, year,curr,cadence, 3, true);
        BDA_Geography__c bdaGeography = BDAGeographyData_Test.lstBDAGeographies[0];
        Geography__c geo = new Geography__c(Type_Of_Location__c ='Country',Id=bdaGeography.Geography__c);
        update geo;
        
        Geography__c testCountry = new Geography__c();
        testCountry.Name = 'United States';
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
        
        BDA__c testRegion = new BDA__C ();
        testRegion.Name = 'Central West Africa';
        testRegion.Type__c = 'Trade Region';
        testRegion.BDA_Code__c = 'CWAD';
        testRegion.GEO_ID__c= 'dsaewetweryyy';
        testRegion.Active__c  =  true;
        testRegion.Parent_BDA__c = testCluster.Id; 
        insert testRegion;
        
        Budget_Group__c bg = new Budget_Group__c();
        bg.Target__c = testTargets[0].Id;
        bg.Brand__c = 'Maersk Line';
        bg.Country_Code__c = 'US';
        bg.Executing_Country__c = testCountry.Id;
        bg.Product_Family__c = '4PL PF';
        bg.Executing_Country__c = geo.id;
        insert bg;
        
        BDA_Geography__c bdaGeo = new BDA_Geography__c(); 
        bdaGeo.BDA__c = testCluster.Id;
        bdaGeo.Geography__c = testCountry.Id;
        insert bdaGeo;
        List<Geography__c> cntry= new List<Geography__c>{testCountry,testCountry,testCountry};
        String countryCode= 'IN';
        List<String> productFamily = new List<String>{'4PL PF','AIR PF','Cold Chain PF'}; 
        List<String> uniqueIds = new List<String>{'INML','DKSM','INSM'};
        List<String> brands = new List<String>{'Maersk Line','Hamburg Sud','B2C'};
        Account acc = TestBusinessHelper.createAccount(user1,testCountry,'Client_Account',true);
        Account accConcern = TestBusinessHelper.createAccount(user1,testCountry,'Concern_Account',true);
        accConcern.Represents_Concern__c = true;
        Update accConcern;
        List<Target_item_group__c> testTargetGroup = TestBusinessHelper.createSalesTargetItemGroups(testTargets, brands,cntry,bdaGeo, productFamily, 3, true);
        List<Target_item__c> SalesTargetItems = TestBusinessHelper.createSalesTargetItems(testTargetGroup, acc, 3, true);
        List<Target_item__Share> lstItemShare = new List<Target_item__Share>();
        for(Target_item__c ti : SalesTargetItems){
            Target_item__Share ts = new Target_item__Share();
            ts.rowcause = 'Manual';
            ts.AccessLevel = 'Edit';
            ts.ParentId = ti.Id;
            ts.UserOrGroupId = user1.Id;
            lstItemShare.add(ts);
        }
        if(!lstItemShare.isEmpty()){
            insert lstItemShare;
        }
        String limitstr = 'Limit 50000000';
        Test.startTest();
        Batch_UpdateShareRecords bch = new Batch_UpdateShareRecords(testTargets[0].Id,limitstr);
            ID batchprocessid = Database.executeBatch(bch);
        Test.StopTest();
    }

}