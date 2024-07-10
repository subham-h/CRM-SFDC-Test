/**
 * Test Class for Request Trigger
 * 
 * Version  Date           Owner                                     RQ#           Description
 ****************************************************************************************************************************************
 * 1.0      03-Dec-2018    Jagadeesan.Sakthivel@ust-global.com       RQ-09384      Code created 
 * 2.0      21-Dec-2018    Junaid.Khader@ust-global.com              RQ-009707     Added lines for updating requester
 * 3.0	    29-Sep-2021    Kiran@Maersk								 SFSE-6066	   Removing Territory record type references and Territory User association object deprecation
 * 4.0      08-Jun-2022    Ronnie@SF                                 SPI-100       Removed brand hardcoding
 */

@isTest
private class RequestTrigger_Test {
    
    static testMethod void checkFollowerCreation_Test() {
        TerritoryDataGeneration_Test.createTerritoryData();   
        Account clientAcc = [SELECT Id FROM Account LIMIT 1];
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Test.startTest();
        List<Product2> prodList = DataGeneratorHelper1_Test.createProduct2WithEquipsAndCommodities( 1,'B','DE','MSL');
        
        List<Pricing_Management__c> pmList = new List<Pricing_Management__c>();
        pmList.add(RateSheetData_Test.preparePricingMgmtRec(prodList[0].Id, 'FAK', '20DRY;20REEF', '1 Month','1', true, '20DRY;20REEF', '1 Month', '1',true));
        pmList.add(RateSheetData_Test.preparePricingMgmtRec(prodList[0].Id, 'Scrap Metal', '20DRY;20REEF;40HREF', '1 Month','1', true, '20DRY;20REEF;', '1 Month','1',true));
        Database.Insert(pmList,false);

        Request__c req2 = RateSheetData_Test.createRequest(clientAcc.id, BrandUtilities.MAERSKLINE, 'No', 'Merged LQB & CL', 'FWD', 'No', 'Customised', 'Both', 'New', pmList[1].Id, 'FAK', '40DRY');
        req2.Requested_By__c = Userinfo.GetUserId();
        update req2;
        
        List<EntitySubscription> esList = [SELECT Id, ParentId FROM EntitySubscription WHERE parentId = :req2.Id];
        //System.assertEquals(esList.Size(), 1);
        Test.stopTest();
    }    
}