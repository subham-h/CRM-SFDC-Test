@isTest(seeAllData= false)
public class OpportunityToLineItemUtilities_test {

     @testSetup static void setup() {
        TriggerExecutionController.skipAllTriggers(true);
        Account clientAccount = AccountDataHelper_Test.createClientAccount();
        Opportunity mslOppty = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( clientAccount.id, null);  
        Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        Test.startTest(); 
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;
        TriggerExecutionController.skipAllTriggers(false);
       // List<Product2> lstProd = DataGeneratorHelper1_Test.createProduct2( 1,'A','DE','Ocean');
        ScheduleOppProducts.OpportunityfromClone = false;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Update standardPricebook;
        Map<String, string> geoMap = new Map<String, String>();
        GeoMap.put( 'Long Beach', 'Country' );
        List<Geography__c> geoList = DataGeneratorHelper1_Test.createGeography( geoMap );
        system.debug('geoList ' + geoList);
        Geography__c geo = geoList[0];
        geo.Is_Port__c = true;
        update geo;
       
        List<Trade_Route__c> lstTradeRoute = DataGeneratorHelper_OIPC.createTradeRoutes(1, 'MCC');
        insert lstTradeRoute;
        Id tradeRouteId = lstTradeRoute[0].Id;
        Product2 prod= TestBusinessHelper.createProduct('Ocean', true);
         List<Product2> lstProd = new List<Product2>{prod};
        List<Opportunity_Product__c> lstoli= new list<Opportunity_Product__c>();
         
        Opportunity_Product__c Oli1 = TestBusinessHelper.createOpportunityLineItemCustom(mslOppty, lstProd[0].Id,lstTradeRoute[0], true);
        //Opportunity_Product__c Oli1 = DataGeneratorHelperCusOli_Test.createOpportunityLineItem( mslOppty.Id);
       
        Opportunity_Product__c Oli2 = TestBusinessHelper.createOpportunityLineItemCustom(mslOppty, lstProd[0].Id,lstTradeRoute[0], true);
        //Oli2.Tender_Target__c = 100;
        //update Oli2;
        /*
        for(Opportunity_Product__c oli:[Select id, Product2ID__c from Opportunity_Product__c where opportunityid__c =: mslOppty.Id ]){
            oli.Product2ID__c=lstProd[0].id;
            lstoli.add(oli);
        }
        update lstoli;
        */
       
        List<Product_Component__c> comps = DataGeneratorHelper_OIPC.createOipcProductComponents(2, lstProd[0].Id);
        insert comps;
        List<Product_Feature__c> prodFeatList = DataGeneratorHelper_OIPC.createOipcProductFeatures(3, comps[0].Id);
        insert prodFeatList;
        List<Id> featList = new List<Id>();
        for( Product_Feature__c prodFeat : prodFeatList){
            featList.add(prodFeat.Id);
        }
        system.debug('featList :'+featList);
            Test.stopTest();            
    }
    
    /*static testmethod void TestOpptyLineItem(){ 
        Test.startTest();
         Opportunity mslOppty = [SELECT id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                Expected_Handling_Rounds__c, Pricebook2Id
                                FROM Opportunity where Liner_Brand__c = :BrandUtilities.MAERSKLINE];
        
          List<Opportunity_Product__c> oli =[SELECT Id, Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c, Quantity__c, OpportunityId__c,
                                           UnitPrice__c, Opt_Out_Auto_Quantity_Scheduling__c,Tender_Target__c, Country__c
                                           FROM Opportunity_Product__c limit 1];          
        Product2 prod= [Select id, oipc_code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
        Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE isStandard = true]; 
        PricebookEntry pbe=[select Id from PriceBookEntry where Product2Id =:prod.Id];
        list<OpportunityLineItem> Oli4 = new list<OpportunityLineItem>();
        Oli4.add (new OpportunityLineItem(OpportunityId = mslOppty.Id,
            Quantity = 33,
            PriceBookEntryId = pbe.id,
            UnitPrice = 1,                              
            Opportunity_Product__c = oli[0].id,
            Opt_Out_Auto_Quantity_Scheduling__c = false
            ));
        insert Oli4;
        
        list<OpportunityLineItemSchedule> schlistToCreate = new list<OpportunityLineItemSchedule>();
        for(Opportunity_Product_Schedule__c schItem: [Select id,Schedule_Date__c ,Revenue__c , Quantity__c,Description__c,Type__c  from Opportunity_Product_Schedule__c where Opportunity_Product__r.opportunityid__c =:mslOppty.Id ]){
            OpportunityLineItemSchedule oppProdSch = new OpportunityLineItemSchedule();
                oppProdSch.Description = schItem.Description__c;
                oppProdSch.OpportunityLineItemId = Oli4[0].id;
                oppProdSch.Quantity = schItem.Quantity__c;
                oppProdSch.Revenue = schItem.Revenue__c;
                oppProdSch.ScheduleDate = schItem.Schedule_Date__c;
                oppProdSch.Type = schItem.Type__c;
                schlistToCreate.add(oppProdSch);
        }
                OpportunityLineItemSchedule oppProdSch1 = new OpportunityLineItemSchedule();
                oppProdSch1.Description = 'test';
                oppProdSch1.OpportunityLineItemId = Oli4[0].id;
                oppProdSch1.Quantity = 1;
                oppProdSch1.Revenue = 33;
                oppProdSch1.ScheduleDate = Date.today();
                oppProdSch1.Type ='Both';
        schlistToCreate.add(oppProdSch1);
        insert schlistToCreate;  
        
        
        system.debug('First_Shipment_Date__c 1'+ msloppty.First_Shipment_Date__c );
        system.debug('First_Shipment_Date__c 1'+ msloppty.Last_Shipment_Date__c );
        msloppty.First_Shipment_Date__c = date.today()+300;
        msloppty.Last_Shipment_Date__c = date.today()+580;
        update msloppty;
        
         Opportunity newOppty = [SELECT id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                Expected_Handling_Rounds__c, Pricebook2Id
                                FROM Opportunity where Liner_Brand__c = :BrandUtilities.MAERSKLINE];
        system.debug('First_Shipment_Date__c 1'+ newOppty.First_Shipment_Date__c );
        system.debug('First_Shipment_Date__c 1'+ newOppty.Last_Shipment_Date__c );
       
            
        
        //OpportunityToLineItemUtilities.AdjustUnassignedProdFEE_ProdSchedule(new Map<Id, Opportunity>{newOppty.id => newOppty}, new Map<Id, Opportunity>{msloppty.id =>msloppty});
        Test.stopTest();
    }*/
    
    static testmethod void testRevenueSchedule(){
         Test.StartTest();
        Opportunity mslOppty = [SELECT id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                Expected_Handling_Rounds__c, Pricebook2Id
                                FROM Opportunity where Liner_Brand__c = :BrandUtilities.MAERSKLINE];
        Product2 prod= [Select id, oipc_code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
        List<Opportunity_Product__c> oli =[SELECT Id, Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c, Quantity__c, OpportunityId__c,
                                           UnitPrice__c, Opt_Out_Auto_Quantity_Scheduling__c,Tender_Target__c,Product_Revenue_Per_Unit__c, Country__c
                                           FROM Opportunity_Product__c limit 1];   
        oli[0].Product_Revenue_Per_Unit__c= 20;
        oli[0].Amend_Expected_FFE__c=100000;
        oli[0].Product2ID__c=prod.Id;
        oli[0].Opt_Out_Auto_Quantity_Scheduling__c= false;
        update oli;
        
        
        msloppty.First_Shipment_Date__c = date.today()+100;
        msloppty.Last_Shipment_Date__c = date.today()+580;
        update msloppty;
        
       List<Opportunity_Product_Schedule__c> OppProductSch = [Select Id,Opportunity_Product__r.Product2ID__r.Name,Schedule_Date__c,Revenue__c,Quantity__c,Description__c,Schedule_Revenue__c from Opportunity_Product_Schedule__c where  Opportunity_Product__c =:oli[0].id order by Schedule_Date__c ];
  		Assert.areEqual(oli[0].Product_Revenue_Per_Unit__c,(OppProductSch[0].Schedule_Revenue__c/OppProductSch[0].Quantity__c));
        Test.stopTest();
    }
    
}