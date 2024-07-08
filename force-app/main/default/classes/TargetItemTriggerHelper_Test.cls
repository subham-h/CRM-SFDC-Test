// test class for Target Item Object trigger , handler , helper 
@IsTest
public class TargetItemTriggerHelper_Test {
    
    @testSetup
    static void testSetUp() {
        BDA_Geography__c bdaGeography = BDAGeographyData_Test.lstBDAGeographies[0];
        BDA__c bda = new BDA__c(Type__c = 'Cluster', Id = bdaGeography.BDA__c);
        update bda;
        Geography__c geo = new Geography__c(Type_Of_Location__c ='Country',Id=bdaGeography.Geography__c);
        update geo;
        Target__c target = new Target__c();
        target.Status__c = 'New';
        target.Applicable_Year__c = '2041';
        insert target;
        Target_Item_Group__c targetItemGp = new Target_Item_Group__c();
        targetItemGp.Country_Code__c = 'US'; 
        targetItemGp.BrandMnA__c = 'Maersk Line';
        targetItemGp.Product_Family__c  = '4PL PF';
        targetItemGp.Target__c = target.Id;
        insert targetItemGp;
        AccountData_Test.createConcernAccounts();
        List<Account> Pacct = [SELECT Id,Name,Represents_Concern__c,SCV_Status__c from Account where RecordType.DeveloperName = 'Concern_Account'];
        Pacct[0].Represents_Concern__c=false;
        Pacct[0].SCV_Status__c='Active';
        Pacct[1].Represents_Concern__c=false;
        Pacct[1].SCV_Status__c='Active';
        update Pacct;
        AccountData_Test.createClientAccounts();
        List<Account> acct= [SELECT Id,Name,Represents_Concern__c,SCV_Status__c from Account where RecordType.DeveloperName = 'Client_Account'];
        acct[0].Represents_Concern__c=true;
        acct[0].SCV_Status__c='Active';
        acct[1].Represents_Concern__c=false;
        acct[1].SCV_Status__c='Active';
        acct[2].Represents_Concern__c=false;
        acct[2].ParentId = Pacct[0].Id;
        acct[2].SCV_Status__c='Active';
        acct[3].Represents_Concern__c=true;
        acct[3].ParentId = Pacct[0].Id;
        acct[3].SCV_Status__c='Active';
        update acct; 
    }
    
    
    @IsTest
    public static void testAccountDetails() {
        Target_Item_Group__c targetItemGroup = [SELECT Id FROM Target_Item_Group__c LIMIT 1];
        List<Account> accountList = [SELECT Id FROM Account WHERE SCV_Status__c = 'Active' ORDER BY Createddate desc];
        List<Geography__c> geoList = [SELECT Id FROM Geography__c LIMIT 1];
        Test.startTest();
        Target_Item__c targetItem1 = new Target_Item__c(Account__c = accountList[2].Id, Sales_Target_Item_Group__c = targetItemGroup.Id);
        Target_Item__c targetItem2 = new Target_Item__c(Account__c = accountList[3].Id, Sales_Target_Item_Group__c = targetItemGroup.Id);
        Target_Item__c targetItem3 = new Target_Item__c(Account__c = null, Sales_Target_Item_Group__c = targetItemGroup.Id, Controlling_Country_Item__c = geoList[0].Id);
        insert new List<Target_Item__c>{ targetItem1, targetItem2, targetItem3 };
        targetItem3.Account__c = accountList[0].Id;
        update new List<Target_Item__c>{ targetItem1, targetItem2, targetItem3 };
        TargetItemTriggerHelper.accountDetails(new List<Target_Item__c>{ targetItem1, targetItem2, targetItem3 }, null);
        Test.stopTest();
    }
}