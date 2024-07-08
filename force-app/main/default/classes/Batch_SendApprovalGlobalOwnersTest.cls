@isTest
public class Batch_SendApprovalGlobalOwnersTest {
    
    @testSetup
    static void testSetUp() {
        User user1 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
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
        RecordType recType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Client_Account' LIMIT 1];
        Account acc = new Account(Name='Test Account',Represents_Concern__c = true, RecordTypeId = recType.Id,SCV_Status__c = 'Active');
        acc.MSL_Account_Owner__c = user1.Id;
        insert acc;
        Target__c target = TestBusinessHelper.createSalesTarget(user1,'2078','USD','Monthly',true);
        Target_Item_Group__c targetItemGroup = TestBusinessHelper.createSalesTargetItemGroup(target, BrandUtilities.MAERSKLINE, testCountry, bdaGeo, '4PL PF', true);        
        Target_Item__c item = TestBusinessHelper.createSalesTargetItem(target, targetItemGroup, null, acc, null, null, null, true);
    }
    
    @isTest
    static void testBatchItems() {
        Target__c target = [SELECT Id FROM Target__c LIMIT 1];
        Test.startTest();
        Batch_SendApprovalEmailToGlobalOwners bch = new Batch_SendApprovalEmailToGlobalOwners(target.Id,false);
        DataBase.executeBatch(bch);
        Test.stopTest();
    }
    @isTest
    static void testBatchItemsForReadAccess() {
        Target__c target = [SELECT Id FROM Target__c LIMIT 1];
        Test.startTest();
        Batch_SendApprovalEmailToGlobalOwners bch = new Batch_SendApprovalEmailToGlobalOwners(target.Id,true);
        DataBase.executeBatch(bch);
        Test.stopTest();
    }
}