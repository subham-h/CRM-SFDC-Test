/*
* Version  Date           Owner                    RQ#           Description
****************************************************************************************************************************************
* 1.0      27-Jul-2019    sidhartha mohapatra      #RQ-011128    Test class for MultiSelectLookupController.cls
*/
@isTest()
public class MultiSelectLookupController_Test {

    static testMethod void search_should_return_Geography() {
        
        Id [] geoNames = new Id[1];
        String isfired = 'isOriginDestination';
        Map<String, String> GeoCountryList = new Map<String, String> ();
        GeoCountryList.put('Durban', 'Country');       
        List<Geography__c> recGeography = DataGeneratorHelper1_Test.createGeographyPortTrue(GeoCountryList);
        geoNames.add(recGeography[0].Id);
        Test.setFixedSearchResults(geoNames);        
        List<String> selectedIds = new List<String>();
        Schema.SObjectType sObjType = Schema.Geography__c.getSObjectType();
        Test.startTest();
        List<LookupSearchResult> results = MultiSelectLookupController.search('Durban', selectedIds,isfired);
        system.debug('results' + results);
		
        Test.stopTest();
        System.assertEquals(1, results.size());
        System.assertEquals(recGeography[0].Id, results.get(0).getId());
        System.assertEquals(recGeography[0].Name, results.get(0).getTitle());
        System.assertEquals(String.valueof(sObjType), results.get(0).getSObjectType());
        System.assertEquals(recGeography[0].GEO_Code__c, results.get(0).getSubtitle());
        System.assertEquals('custom:custom9', results.get(0).getIcon());

    }
    
}