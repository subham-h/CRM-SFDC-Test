/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-20-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class TempOpportunityProductScheduleTest {
    @testSetup static void setup() {
        Test.startTest();
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
        Geography__c state = TestBusinessHelper.createGeography('Karnataka', 'State', country.Id, true);
        Geography__c chinaCountry = TestBusinessHelper.createGeography('China','Country', null, true);
        Geography__c chinastate = TestBusinessHelper.createGeography('San Carlos','State', chinaCountry.Id, true);
        
        BDA__c parentBDA = TestBusinessHelper.createBDA('India, Middle East, and Africa', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true);
        BDA__c childBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'IBC', parentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, country.Id, null, true);
        
        BDA__c chinaParentBDA = TestBusinessHelper.createBDA('Asia Pacific Region', 'Trade Region', 'APA', null, UserInfo.getUserId(), true);
        BDA__c chinaChildBDA = TestBusinessHelper.createBDA('Greater China Area', 'Cluster', 'GCC', chinaParentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c chinaBdaGeo = TestBusinessHelper.createBDAGeography(chinaChildBDA.Id, chinaCountry.Id, null, true);
        
        TriggerExecutionController.skipAllTriggers(true);
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', true);
        Opportunity mslOppty = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        mslOppty.Pricebook2Id = Test.getStandardPricebookId();
        update mslOppty;
        
        TriggerExecutionController.skipAllTriggers(false);
        ScheduleOppProducts.OpportunityfromClone = false;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );

        Update standardPricebook;
        Map<String, string> geoMap = new Map<String, String>();
        GeoMap.put( 'Long Beach', 'Country' );
        
        List<Trade_Route__c> lstTradeRoute = TestBusinessHelper.createTradeRoutes(new List<String>{BrandUtilities.MCC}, 1,true);
        //insert lstTradeRoute;
        Id tradeRouteId = lstTradeRoute[0].Id;
        List<Product2> Prodlist = new list<Product2>();
        Product2 lstProd = TestBusinessHelper.createProduct('Ocean', true);
        lstProd.Is_Product_Solution__c = true;
        
        update lstProd;
        
        Bypass_Product_Upgrade_Validation__c bt= Bypass_Product_Upgrade_Validation__c.getInstance();
                bt.Skip_Validation__c = true;
                insert bt;
        //TriggerExecutionController.skipAllTriggers(true);
        Opportunity_Product__c Oli1 = TestBusinessHelper.createOpportunityLineItemCustom(mslOppty, lstProd.Id,lstTradeRoute[0], false);
        oli1.id=null;
        oli1.Quantity__c =100;
        oli1.Product_Revenue_Per_Unit__c=null;
        insert oli1;
        Bypass_Product_Upgrade_Validation__c btt= Bypass_Product_Upgrade_Validation__c.getInstance();
        delete btt;
        Test.stopTest();
    }

    static testmethod void testOpptyLineItem(){  
        Test.startTest();
        Opportunity_Product__c oli = [SELECT Id, Amend_Gross_Profit_per_unit__c, UnitPrice__c,Product_Revenue_Per_Unit__c FROM Opportunity_Product__c limit 1];
        system.debug('test 1'+oli);
        TriggerExecutionController.skipAllTriggers(true);
        oli.Product_Revenue_Per_Unit__c = 5;
        update oli;
        TriggerExecutionController.skipAllTriggers(false);
 		
        Database.executeBatch(new TempOpportunityProductSchedule());
        Test.stopTest();
        Opportunity_Product_Schedule__c sch=[SELECT id,Revenue__c, Quantity__c, Schedule_Date__c,Opportunity_Product__c, Schedule_Revenue__c FROM Opportunity_Product_Schedule__c WHERE Opportunity_Product__c =: oli.id limit 1];
        system.debug(sch.Schedule_Revenue__c/sch.Quantity__c);
        Assert.areEqual(5, sch.Schedule_Revenue__c/sch.Quantity__c);
        
    }
    
}