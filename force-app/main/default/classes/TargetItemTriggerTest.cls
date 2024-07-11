//Test Class for Target Item Group Object Trigger, Handler, Helper
@IsTest
public class TargetItemTriggerTest {
    
    @testSetup
    static void testData() {
        BDA_Geography__c bdaGeography = BDAGeographyData_Test.lstBDAGeographies[0];
        BDA__c bda = new BDA__c(Type__c = 'Cluster', Id = bdaGeography.BDA__c);
        update bda;
        Geography__c geo = new Geography__c(Type_Of_Location__c ='Country',Id=bdaGeography.Geography__c);
        update geo;
        Target__c target = new Target__c();
        target.Status__c = 'New';
        target.Applicable_Year__c = '2030';
        insert target;
    }
    
    @IsTest
    static void testTargetItemGroupTrigger() {
        Target__c tg = [SELECT ID FROM Target__c limit 1];
        Target_Item_Group__c targetItemGp = new Target_Item_Group__c();
        targetItemGp.Country_Code__c = 'US'; 
        targetItemGp.BrandMnA__c = 'Maersk Line';
        targetItemGp.Product_Family__c  = '4PL PF';
        targetItemGp.Target__c = tg.Id;
        Test.startTest();
        insert targetItemGp;
        targetItemGp.Country_Code__c = 'US'; 
        update targetItemGp;
        Test.stopTest();
    }
    
    @IsTest
    static void testGeographyHelper() {
        Set<String> countryCodes = new Set<String>{'US'};
            Test.startTest();
        Map<String, BDA_Geography__c> bdaGeographyMap = GeographyHelper.getBdaGeographyByCountryCode(countryCodes);
        Test.stopTest();  
    }
    
    @isTest
    static void testCountryMandatory() {
        Target__c tg = [SELECT ID FROM Target__c LIMIT 1];
        Geography__c executingCountry = [SELECT Id FROM Geography__c WHERE Type_Of_Location__c = 'Country' LIMIT 1]; // Query a valid Geography__c record
        
        Target_Item_Group__c targetItemGp = new Target_Item_Group__c();
        targetItemGp.BrandMnA__c = 'Maersk Line';
        targetItemGp.Executing_Country__c = executingCountry.Id; // Assign the valid Geography__c record's Id
        targetItemGp.Product_Family__c = '4PL PF';
        targetItemGp.Target__c = tg.Id;
        Test.startTest();
        insert targetItemGp;
        Test.stopTest();   
    } 
    
    @IsTest
    static void testTargetItemTriggerHandler() {
        Target__c tg = [SELECT ID FROM Target__c limit 1];
        Target_Item_Group__c targetItemGp = new Target_Item_Group__c();
        targetItemGp.Country_Code__c = 'US';
        targetItemGp.BrandMnA__c = 'Maersk Line';
        targetItemGp.Product_Family__c  = '4PL PF';
        targetItemGp.Target__c  = tg.Id;
        Test.startTest();
        insert targetItemGp;
        Test.stopTest();    
    }      
}