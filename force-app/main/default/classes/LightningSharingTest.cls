/**
 * Purpose : Test class for class LightningSharing
 *        
 * Revision Ref Number  Date           Owner                                Description
 * -------- ----------  -----------    -----------------                    -----------
 * 1.0      #RQ-010312  20/05/2019     meghana.gupta@ust-global.com      	Code created
 * 2.0     	            15/10/2020     meghana@UST							null argument error fix
 * 3.0      SPI-100     08/06/2022     Ronnie@SF                            Removed brand hardcoding
 */
@isTest
private class LightningSharingTest {

    @testSetup static void setup() {
        
        Map<String, String> GeoCountryList = new Map<String, String> ();
        GeoCountryList.put('Denmark', 'Country');
        GeoCountryList.put('China', 'Country');       
        List<Geography__c> geoList = DataGeneratorHelper1_Test.createGeography ( GeoCountryList );   
        
        Account clientAcc = AccountDataHelper_Test.createClientAccount(null, 'Active','testAcc123');    
        System.debug('address '+ clientAcc.BillingAddress);
        Request__c rec = RateSheetData_Test.createVIPDeal(clientAcc.Id, BrandUtilities.MAERSKLINE, 'Standard VIP Deal', geoList[0].id, 'New');  
        insert rec;
    }
    
     static testMethod void testSharingAccess() {
         
         Request__c recRequest = [SELECT Id, Account__c FROM Request__c LIMIT 1];
         User usrRec = [SELECT Id, firstName FROM USER WHERE isActive = true and Id <> :userInfo.getUserId() and ProfileId = :Label.TestClean_ProfileIdsSales AND firstName <> ''  limit 1];
         system.debug(usrRec);
         
         LightningSharing.doSOSL(usrRec.firstName,'User');
         LightningSharing.upsertPerm(usrRec.Id, recRequest.Id, 'Read');
         LightningSharing.upsertPerm(usrRec.Id, recRequest.Id, 'Edit');
         LightningSharing.getSharings( recRequest.Id);
         LightningSharing.getSharings( recRequest.Account__c);
         
         LightningSharing.deletePerm(usrRec.Id, recRequest.Id);
     }
}