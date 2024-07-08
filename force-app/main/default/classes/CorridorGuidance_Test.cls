/**
* Test class for :  CorridorActualTriggerHandler, CorridorActual_Utilities,     CorridorGuidanceCntrl, CorridorGuidanceCreationController, CorridorGuidanceGetRouteSum,
                    CorridorGuidanceTriggerHandler, CorridorGuidanceUtilities, CorridorActualTrigger, CorridorGuidanceTrigger,CorridorGuidanceQuartDealLightningCtrl

* Date         Owner                                                    Description
*************************************************************************************************************************************
* 20/05/2016   Kishore.Dupam@ust-global.com               RQ-003428 : Code Created
* 20/04/2017   Govindaraj.Sundaram@ust-global.com         RQ-005191 : Test class improvements
* 22-Jun-2018  manjunath.c.holekade@maersk.com            RQ-008666 : Cover 'updateCG' method of 'CorridorGuidanceQuartDealLightningCtrl' class
* 03/01/2019   Junaid.Khader@ust-global.com               RQ-007160 : Code coverage improvement
* 11/04/2019   Junaid.Khader@ust-global.com               RQ-010542 : Class rewritten in order to fix test class run failure
* 14/08/2019   Junaid.Khader@ust-global.com               #RQ-011435: Removed invocation of method getRouteSum which referenced CluAp
* 11-Sep-2019  manjunath.c.holekade@maersk.com            RQ-011878 : Code coverage improvement
* 27-Apr-2020  rakesh.allam@maersk                        RQ-013390 : Deprecate Corridor related classes
*/

@isTest
private class CorridorGuidance_Test{
    
    @testSetup static void setupTestData(){
        // Insert Geography__c records
        Map<String, String> GeoCountryList = new Map<String, String> ();
        GeoCountryList.put('EAST ST PAUL', 'City');
        GeoCountryList.put('Durban', 'City');       
        List<Geography__c> recGeography = DataGeneratorHelper1_Test.createGeography(GeoCountryList);
        
        Map<Id, String> OriginList = new Map<Id, String>();
        OriginList.put(recGeography.get(0).id, recGeography.get(0).GEO_Code__c);
        OriginList.put(recGeography.get(1).id, recGeography.get(1).GEO_Code__c);
        
        Map<Id, String> DestinationList = new Map<Id, String>();
        DestinationList.put(recGeography.get(1).id, recGeography.get(1).GEO_Code__c);
        DestinationList.put(recGeography.get(0).id, recGeography.get(0).GEO_Code__c);
        
        List<Id> geographyList = new List<Id>();
        geographyList.addAll(OriginList.keySet());
        TriggerExecutionController.skipAllTriggers(true);
        // Insert client account
        Account clientAcc = AccountDataHelper_Test.createClientAccount();
        
        // Insert Tender & quarterly deal opportunity
        //TriggerExecutionController.skipOpportunityTrigger(true);
        Opportunity oppTender = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity(clientAcc.id, null);
        Opportunity oppQuarterlyDeal = OpportunityDataGeneratorHelper_Test.createMSLQuarterlyDealOpportunity(clientAcc.id, null);
        //TriggerExecutionController.skipOpportunityTrigger(false);
        TriggerExecutionController.skipAllTriggers(false);
        // Insert ocean products
        List<Product2> listOceanProducts = DataGeneratorHelper1_Test.createProduct2( 1,'A','DE','Ocean');
        List<Product2> listNonOceanProducts = DataGeneratorHelper1_Test.createProduct2( 1,'B','FE','Non Ocean');
       // PriceBookEntry pbEntry = [SELECT Id from PriceBookEntry WHERE Product2Id = :listOceanProducts[0].Id];
        
        // Insert OpportunityLineItem for tender opportunity
        TriggerExecutionController.skipopptyLineItemTrigger(true);
        //DataGeneratorHelper1_Test.createOpportunityLineItem(oppTender.Id, pbEntry.Id);
        TriggerExecutionController.skipopptyLineItemTrigger(false);
        
        // Insert Corridor_Guidance__c
        Corridor_Guidance__c rowCorridorGuidance = DataGeneratorHelper2_Test.createCorriodorGuidance(oppTender.Id, listOceanProducts[0].Id );
        
        Corridor_Guidance__c rowCorridorGuidance2 = new Corridor_Guidance__c();
        rowCorridorGuidance2.Comments__c = 'test commentsS';
        rowCorridorGuidance2.Opportunity__c = oppQuarterlyDeal.Id;
        rowCorridorGuidance2.Product__c = listNonOceanProducts[0].Id;
        rowCorridorGuidance2.Cluster_TNM_Approval__c = 'Approved';
        insert rowCorridorGuidance2;
        
        DataGeneratorHelper2_Test.createCorriodorGuidanceDetail (rowCorridorGuidance.id, geographyList[0], geographyList[1]);
        DataGeneratorHelper2_Test.createCorriodorGuidanceDetail (rowCorridorGuidance.id, geographyList[1], geographyList[0]);
        
        
        // Insert Pricing Management
        //DataGeneratorHelper2_Test.createQuarterlyDealPricingManagement(rowCorridorGuidance.id, 'GCA', 'Australia');
        // Insert Environment_Variables__c
        insert new Environment_Variables__c(Name = 'Heroku_HttpTimeoutTime', Value__c = 30000);
    }
    
    static testMethod void testCorridorGuidance6() {
        Opportunity oppTender = [SELECT Id, Last_Shipment_Date__c FROM Opportunity WHERE RecordTypeId = :System.Label.OppTenderRecordTypeId];
        Product2 rowProduct = [SELECT Id FROM Product2 WHERE Family = 'Ocean' LIMIT 1];
        
        Test.startTest();
        
        Corridor_Guidance__c rowCorridorGuidance = [SELECT Id FROM Corridor_Guidance__c WHERE Opportunity__c = :oppTender.Id AND Product__c = :rowProduct.Id LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(rowCorridorGuidance);      
        CorridorGuidanceQuartDealLightningCtrl corrCntrl2 = new CorridorGuidanceQuartDealLightningCtrl(sc);
        corrCntrl2.redirectToLightning();
        Test.stopTest();
    }
    
    static testMethod void testCorridorGuidance7() {
        Opportunity oppTender = [SELECT Id, Last_Shipment_Date__c FROM Opportunity WHERE RecordTypeId = :System.Label.OppTenderRecordTypeId];
        Product2 rowProduct = [SELECT Id FROM Product2 WHERE Family = 'Ocean' LIMIT 1];
        
        Test.startTest();
        
        Corridor_Guidance__c rowCorridorGuidance = [SELECT Id, comments__c FROM Corridor_Guidance__c WHERE Opportunity__c = :oppTender.Id AND Product__c = :rowProduct.Id LIMIT 1];
        rowCorridorGuidance.comments__c = 'updated comment';
        update rowCorridorGuidance;
        delete rowCorridorGuidance;
        List<Corridor_Guidance__c> listCorrGuidance = [SELECT Id FROM Corridor_Guidance__c WHERE Id = :rowCorridorGuidance.Id];
        Test.stopTest();
        system.assertEquals(0, listCorrGuidance.size());
    }
    
    static testMethod void testCorridorGuidance8() {
        Opportunity oppQuarterlyDeal = [SELECT Id, First_Shipment_Date__c, Last_Shipment_Date__c FROM Opportunity WHERE RecordTypeId = :System.Label.QuarterlyDealsRecordTypeId];
        Product2 rowProduct = [SELECT Id FROM Product2 WHERE Family = 'Non Ocean' LIMIT 1];
        
        PageReference pageRef = Page.CorridorGuidanceQuartDealsLightning; 
        pageRef.getParameters().put('prodId', rowProduct.id );
        pageRef.getParameters().put('optyId', oppQuarterlyDeal.id );
        pageRef.getParameters().put('id', '' );
        
        Test.startTest();
        Test.setCurrentPage( pageRef );
        Corridor_Guidance__c rowCorridorGuidance = [SELECT Id, comments__c FROM Corridor_Guidance__c WHERE Opportunity__c = :oppQuarterlyDeal.Id AND Product__c = :rowProduct.Id LIMIT 1];
        CorridorGuidanceQuartDealLightningCtrl.getCorridorResponse ( rowCorridorGuidance.id, oppQuarterlyDeal.id, rowProduct.id );
        Product2 rowProduct2 = CorridorGuidanceQuartDealLightningCtrl.getProductFamily(rowProduct.id);
        Test.stopTest();
        system.assertEquals('Non Ocean', rowProduct2.Family);
    }
    
    static testMethod void testCorridorGuidance10() {
        Opportunity oppQuarterlyDeal = [SELECT Id, First_Shipment_Date__c, Last_Shipment_Date__c FROM Opportunity WHERE RecordTypeId = :System.Label.QuarterlyDealsRecordTypeId];
        Product2 rowProduct = [SELECT Id FROM Product2 WHERE Family = 'Non Ocean' LIMIT 1];
        
        PageReference pageRef = Page.CorridorGuidanceQuartDealsLightning; 
        pageRef.getParameters().put('prodId', rowProduct.id );
        pageRef.getParameters().put('optyId', oppQuarterlyDeal.id );
        pageRef.getParameters().put('id', '' );
        
        Test.startTest();
        Test.setCurrentPage( pageRef );
        Corridor_Guidance__c rowCorridorGuidance = [SELECT Id, comments__c FROM Corridor_Guidance__c WHERE Opportunity__c = :oppQuarterlyDeal.Id AND Product__c = :rowProduct.Id LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(rowCorridorGuidance);      
        CorridorGuidanceQuartDealLightningCtrl corrCntrl = new CorridorGuidanceQuartDealLightningCtrl(sc);
       
        PageReference pageRef1 = Page.CorridorGuidanceQuartDealsLightning; 
        pageRef1.getParameters().put('id', rowCorridorGuidance.id );
        Test.setCurrentPage( pageRef1 );
       
        corrCntrl = new CorridorGuidanceQuartDealLightningCtrl(sc);
        corrCntrl.redirectToLightning();
        
        Test.stopTest();
    }
    
    static testMethod void testCorridorGuidance11() {
        Opportunity oppQuarterlyDeal = [SELECT Id, Last_Shipment_Date__c FROM Opportunity WHERE RecordTypeId = :System.Label.OppTenderRecordTypeId];
        Product2 rowProduct = [SELECT Id FROM Product2 WHERE Family = 'Ocean' LIMIT 1];
        
        Test.startTest();
        Corridor_Guidance__c rowCorridorGuidance = [SELECT Id, Cluster_TNM_Approval__c  FROM Corridor_Guidance__c WHERE Opportunity__c = :oppQuarterlyDeal.Id AND Product__c = :rowProduct.Id LIMIT 1];
        List<Corridor_Guidance_Detail__c> corrDetail = [SELECT Id FROM Corridor_Guidance_Detail__c WHERE Corridor_Guidance__c = :rowCorridorGuidance.Id];
        CorridorGuidanceQuartDealLightningCtrl.getCorridorResponse ( rowCorridorGuidance.id, oppQuarterlyDeal.id, rowProduct.id );
        CorridorGuidanceQuartDealLightningCtrl.updateCGDetails(corrDetail);
        corrDetail[0].Id = null;
        CorridorGuidanceQuartDealLightningCtrl.updateCGDetails(corrDetail);
        
        rowCorridorGuidance.Cluster_TNM_Approval__c = 'Approved';
        update rowCorridorGuidance;   
        CorridorGuidanceQuartDealLightningCtrl.updateCG('Sales Rep',rowCorridorGuidance.id);
        CorridorGuidanceQuartDealLightningCtrl.updateCG('Pricing Mgr',rowCorridorGuidance.id);
        List<Id> corrDetailIds = new List<Id>();
        corrDetailIds.add( corrDetail[0].id );
        CorridorGuidanceQuartDealLightningCtrl.deleteCorridor(corrDetailIds);
        CorridorGuidanceQuartDealLightningCtrl.deleteCorridor(null);
        List<Corridor_Guidance_Detail__c> recordList= [SELECT Id FROM Corridor_Guidance_Detail__c WHERE id in :corrDetailIds];
        Test.stopTest();
        system.assertEquals(0, recordList.size());
    }
    
    static testMethod void testCorridorGuidance12() {
        Opportunity oppTender = [SELECT Id, Last_Shipment_Date__c FROM Opportunity WHERE RecordTypeId = :System.Label.OppTenderRecordTypeId];
        Product2 rowProduct = [SELECT Id FROM Product2 WHERE Family = 'Ocean' LIMIT 1];
        
        Test.startTest();
        Corridor_Guidance__c rowCorridorGuidance = [SELECT Id, Cluster_TNM_Approval__c  FROM Corridor_Guidance__c WHERE Opportunity__c = :oppTender.Id AND Product__c = :rowProduct.Id LIMIT 1];
        
        CorridorGuidanceQuartDealLightningCtrl.saveCorridor ( rowCorridorGuidance.id,'test','GCA', 'Australia', rowProduct.id );
        CorridorGuidanceQuartDealLightningCtrl.saveCorridor ( null,'test','GCA', 'Australia', rowProduct.id );
        CorridorGuidanceQuartDealLightningCtrl.getPricingMgmtRates ( rowProduct.id, 'GCA', 'Australia' );
        CorridorGuidanceQuartDealLightningCtrl.getOriginAndDestinationList ( rowProduct.id);
        Boolean isCheckPermission = CorridorGuidanceQuartDealLightningCtrl.checkIsUserInGscPermSet();
        Test.stopTest();
        system.assertEquals(false, isCheckPermission);
    }
    
    static testMethod void testCorridorGuidance13() {
        Opportunity oppQuarterlyDeal = [SELECT Id, First_Shipment_Date__c, Last_Shipment_Date__c FROM Opportunity WHERE RecordTypeId = :System.Label.QuarterlyDealsRecordTypeId];
        Product2 rowProduct = [SELECT Id FROM Product2 WHERE Family = 'Non Ocean' LIMIT 1];
        PageReference pageRef = Page.CorridorGuidanceQuartDealsLightning; 
        pageRef.getParameters().put('prodId', rowProduct.id );
        pageRef.getParameters().put('optyId', oppQuarterlyDeal.id );
        pageRef.getParameters().put('id', '' );
        
        Test.startTest();
        Test.setCurrentPage( pageRef );
        CorridorGuidanceQuartDealLightningCtrl.getCorridorResponse ( '', oppQuarterlyDeal.id, rowProduct.id );
        Boolean isCentreUser = CorridorGuidanceQuartDealLightningCtrl.checkCentrUser();
        Test.stopTest();
        system.assertEquals(false, isCentreUser);
    }
    static testMethod void testCorridorGuidance14() {
        Opportunity oppQuarterlyDeal = [SELECT Id, First_Shipment_Date__c, Last_Shipment_Date__c FROM Opportunity WHERE RecordTypeId = :System.Label.QuarterlyDealsRecordTypeId];
        Product2 rowProduct = [SELECT Id FROM Product2 WHERE Family = 'Non Ocean' LIMIT 1];
        
        
        Test.startTest();
        Corridor_Guidance__c rowCorridorGuidance = [SELECT Id, Cluster_TNM_Approval__c  FROM Corridor_Guidance__c WHERE Opportunity__c = :oppQuarterlyDeal.Id AND Product__c = :rowProduct.Id LIMIT 1];
        //DataGeneratorHelper2_Test.createQuarterlyDealCorriodorGuidanceDetail1(rowCorridorGuidance.id, 'GCA', 'Australia');
        
        Corridor_Guidance_Detail__c recCGDetail = new Corridor_Guidance_Detail__c();
        recCGDetail.Origin_Micromarket__c= 'GCA';
        recCGDetail.Destination_Micromarket__c= 'Australia';
       
        recCGDetail.Corridor_Guidance__c = rowCorridorGuidance.id;
        recCGDetail.RecordTypeId= system.label.CG_Detail_Quarterly_Deal_Record_Type_Id;
        insert recCGDetail;
        
        CorridorGuidanceQuartDealLightningCtrl.getCorridorResponse ( rowCorridorGuidance.id, oppQuarterlyDeal.id, rowProduct.id );
        Boolean isTradeManager = CorridorGuidanceQuartDealLightningCtrl.checkTradeManagerPermSet();
        Test.stopTest();
        system.assertEquals(false, isTradeManager);
    }
}