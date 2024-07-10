/**

* Test class for :OpptyLineItemUtilities

* Version    Date                  Modified By                       Description
* 1.0       08/12/2016          Kishore.dupam@ust-global.com               LTCF
* 2.0		28-Sep-2018			manjunath.c.holekade@maersk.com 	Code coverage for OpportunityToLineItemUtilities class
* 3.0 	    06-Jun-2019         manjunath.c.holekade@maersk.com		#RQ-010819 Removal of references of deprecated fields
* 4.0       26-May-2020         manjunath@maersk					SFSE-111 Removed references and logic related to "Expected_FFE_Lead__c" object
H*/
@isTest
private class OpptyLineItemUtilities_Test{
    
    @testSetup static void setup() {
        TriggerExecutionController.skipAllTriggers(true);
        Account ClientAccount = AccountDataHelper_Test.createClientAccount();
        Opportunity mslOppty = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( ClientAccount.id, null);
        Opportunity oppty =  OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( ClientAccount.id, null);
        TriggerExecutionController.skipAllTriggers(false);
        List<Product2> lstProd = DataGeneratorHelper1_Test.createProduct2( 1,'A','DE','Ocean');
        //List<Product2> lstProd1 = DataGeneratorHelper1_Test.createProduct2( 1,'AB','DE','Lead Logistics');
        //lstProd1[0].IsActive = true;
        
         //update lstProd1;
         system.debug('Opportunity' +oppty);
       
        ScheduleOppProducts.OpportunityfromClone = false;
        
        PriceBookEntry pbEntry = [select Id from PriceBookEntry where Product2Id =:lstProd[0].Id];
        //List<PriceBookEntry> pbEntry2 = [select Id from PriceBookEntry where Product2Id =:lstProd1[0].Id  ];

		Map<String, string> GeoMap = new Map<String, String>();
        GeoMap.put( 'Long Beach', 'Country' );
        List<Geography__c> geoList = DataGeneratorHelper1_Test.createGeography( GeoMap );
        system.debug('geoList ' + geoList);
        Geography__c geo = geoList[0];
        geo.Is_Port__c = true;
        update geo;
        OpportunityLineItem Oli = DataGeneratorHelper1_Test.createOpportunityLineItem( mslOppty.Id, pbEntry.Id );
      
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        oliList.add(Oli);
        
        OpptyLineItemUtilities.validateOpptyStageApprovalStatus(oliList);
        List<Opportunity> oppList = new List<Opportunity>();
         oppList.add(mslOppty);
         OpptyLineItemUtilities.validateOpptyPendingApprovalProcesses(oliList, oppList);
        
        //OpportunityLineItem Oli2 = DataGeneratorHelper1_Test.createOpportunityLineItemWithCountry( mslOppty.Id, pbEntry2[0].Id, geoList[0].Id );
        // OpportunityLineItem Oli2 = DataGeneratorHelper1_Test.createOpportunityLineItem( oppty.Id, pbEntry.Id );
    }
    
    static testmethod void TestOpptyLineItem(){  
       
        Test.StartTest();
        OpportunityLineItem Oli = [select Id,Tender_Target__c from OpportunityLineItem limit 1];
        TriggerExecutionController.skipopptyLineItemTrigger(false);
        Oli.Tender_Target__c = 200;
        update Oli;
        
        Oli.Tender_Target__c = null;
        update Oli;
        
        Oli.Tender_Target__c = 500;
        update Oli;
        
        Test.StopTest();
        
    }   
    
    static testmethod void TestOpptyLineItemClone(){  
        
        OpportunityLineItem Oli = [select  FIELDS(STANDARD), Executing_City_State__c, Trade_Route__c  from OpportunityLineItem limit 1];

        Test.StartTest();
		OpportunityLineItem cloneOli = Oli.clone();  
        cloneOli.TotalPrice = null;
        insert cloneOli;
        
        Test.StopTest();
        
    }  
  
}