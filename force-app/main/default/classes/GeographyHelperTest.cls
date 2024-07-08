@isTest
public class GeographyHelperTest {
    
    @testSetup
    static void testData() {
        BDA_Geography__c bdaGeography = BDAGeographyData_Test.lstBDAGeographies[0];
        BDA__c bda = new BDA__c(Type__c = 'Cluster', Id = bdaGeography.BDA__c);
        update bda;
        Geography__c geo = new Geography__c(Type_Of_Location__c ='Country',Id=bdaGeography.Geography__c);
        update geo;
    }
    
    @IsTest
    static void testGeographyHelper() {
        Set<String> countryCodes = new Set<String>{'US'};
            Test.startTest();
        Map<String, BDA_Geography__c> bdaGeographyMap = GeographyHelper.getBdaGeographyByCountryCode(countryCodes);
        Map<String, BDA_Geography__c> bdaGeographyMap1 = GeographyHelper.getBdaGeographyByCountryCode();
        Test.stopTest();  
    }
    
}