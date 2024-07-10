@isTest(seeAllData= false)
public class OpptyLineItemSchedulingHelper_Test {
    
    @testSetup static void setup() {
        TriggerExecutionController.skipAllTriggers(true);
        Account clientAccount = AccountDataHelper_Test.createClientAccount();
        Opportunity mslOppty = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( clientAccount.id, null);  
        Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;
        TriggerExecutionController.skipAllTriggers(false);
        test.startTest();
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
       
        Opportunity_Product__c Oli2 = TestBusinessHelper.createOpportunityLineItemCustom(mslOppty, lstProd[0].Id,lstTradeRoute[0], true);
        
        
       
        List<Product_Component__c> comps = DataGeneratorHelper_OIPC.createOipcProductComponents(2, lstProd[0].Id);
        insert comps;
        List<Product_Feature__c> prodFeatList = DataGeneratorHelper_OIPC.createOipcProductFeatures(3, comps[0].Id);
        insert prodFeatList;
      
        Test.stopTest();
        //insert DataGeneratorHelperCusOli_OIPC.createOpptyFeatures(Oli2.Id,featList);
        
        
                      
    }
    
    static testmethod void testcreatestdOli(){
        TriggerExecutionController.skipAllTriggers(true);
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
         List<Opportunity_Product__c> oli =[SELECT Id, Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c, Quantity__c, OpportunityId__c,
                                           UnitPrice__c, Opt_Out_Auto_Quantity_Scheduling__c,Tender_Target__c, Nominated_Quantity__c,/* Commitment__c,*/ Country__c
                                           FROM Opportunity_Product__c limit 1];          
        Product2 prod= [Select id, oipc_code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
     Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE isStandard = true]; 
        PricebookEntry pbe=[select Id from PriceBookEntry where Product2Id =:prod.Id];
        list<OpportunityLineItem> Oli4 = new list<OpportunityLineItem>();
        Oli4.add (new OpportunityLineItem(OpportunityId = opp[0].Id,
            Quantity = 33,
            PriceBookEntryId = pbe.id,
            UnitPrice = 1,
            Opportunity_Product__c = oli[0].id,
            Opt_Out_Auto_Quantity_Scheduling__c = false
          ));
        insert Oli4;
        
        list<OpportunityLineItemSchedule> schlistToCreate = new list<OpportunityLineItemSchedule>();
        for(Opportunity_Product_Schedule__c schItem: [Select id,Schedule_Date__c ,Revenue__c , Quantity__c,Description__c,Type__c  from Opportunity_Product_Schedule__c where Opportunity_Product__c =:oli[0].id ]){
            OpportunityLineItemSchedule oppProdSch = new OpportunityLineItemSchedule();
                oppProdSch.Description = schItem.Description__c;
                oppProdSch.OpportunityLineItemId = Oli4[0].id;
                oppProdSch.Quantity = schItem.Quantity__c;
                oppProdSch.Revenue = schItem.Revenue__c;
                oppProdSch.ScheduleDate = schItem.Schedule_Date__c;
                oppProdSch.Type = schItem.Type__c;
                schlistToCreate.add(oppProdSch);
        }
     insert schlistToCreate; 
      TriggerExecutionController.skipAllTriggers(false); 
      Test.startTest();
        OpptyLineItemSchedulingHelper.scheduleOppLineItem(Oli4, null, new Map<Id,Opportunity>{opp[0].id => opp[0]} , new Map<Id,Boolean>{opp[0].id => false});
        OpptyLineItemSchedulingHelper.OppLineItemOnDelete(new Map<id,OpportunityLineItem>{Oli4[0].id => Oli4[0]},  new Map<Id,Opportunity>{opp[0].id => opp[0]} , new Map<Id,Boolean>{opp[0].id => false});
        try{
             OpptyLineItemSchedulingHelper.validateoliOnDelete(new Map<id,OpportunityLineItem>{Oli4[0].id => Oli4[0]},new Map<Id,Boolean>{opp[0].id => true}, false);
        }catch(Exception ex){
            
        }
        Test.stopTest();
    }
    
    static testmethod void teststdOlisch(){
        Test.startTest();
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
         List<Opportunity_Product__c> oli =[SELECT Id, Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c, Quantity__c, OpportunityId__c,
                                           UnitPrice__c, Opt_Out_Auto_Quantity_Scheduling__c,Tender_Target__c, Nominated_Quantity__c,/* Commitment__c,*/ Country__c
                                           FROM Opportunity_Product__c limit 1];          
        Product2 prod= [Select id, oipc_code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
     Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE isStandard = true]; 
        PricebookEntry pbe=[select Id from PriceBookEntry where Product2Id =:prod.Id];
        LIst<Opportunity_Product_Schedule__c> schItem=[Select id,Schedule_Date__c ,Revenue__c , Quantity__c,Description__c,Type__c  from Opportunity_Product_Schedule__c where Opportunity_Product__c =:oli[0].id ];
        list<OpportunityLineItem> Oli4 = new list<OpportunityLineItem>();
        Oli4.add (new OpportunityLineItem(OpportunityId = opp[0].Id,
            Quantity = 33,
            PriceBookEntryId = pbe.id,
            UnitPrice = 1,
            Amend_Expected_FFE__c =33,
            Opportunity_Product__c = oli[0].id,
            Opt_Out_Auto_Quantity_Scheduling__c = false
          ));
        insert Oli4;
        
        list<OpportunityLineItemSchedule> schlistToCreate = new list<OpportunityLineItemSchedule>();
        /*
        for(Opportunity_Product_Schedule__c schItem: [Select id,Schedule_Date__c ,Revenue__c , Quantity__c,Description__c,Type__c  from Opportunity_Product_Schedule__c where Opportunity_Product__c =:oli[0].id ]){
            OpportunityLineItemSchedule oppProdSch = new OpportunityLineItemSchedule();
                oppProdSch.Description = schItem.Description__c;
                oppProdSch.OpportunityLineItemId = Oli4[0].id;
                oppProdSch.Quantity = schItem.Quantity__c;
                oppProdSch.Revenue = schItem.Revenue__c;
                oppProdSch.ScheduleDate = schItem.Schedule_Date__c;
                oppProdSch.Type = schItem.Type__c;
                schlistToCreate.add(oppProdSch);
        }
     insert schlistToCreate;  
        */
        OpptyLineItemSchedulingHelper.deleteDefaultScheduleOppLineItem(Oli4,false);
        OpptyLineItemSchedulingHelper.deleteDefaultScheduleOppLineItem(Oli4,true);
         OpptyLineItemSchedulingHelper.reCreateScheduleOppLineItem(Oli4,true);
      OpptyLineItemSchedulingHelper.reCreateScheduleOppLineItem(Oli4,false);
        Test.stopTest();
        
    }
    
    static testmethod void teststdOlisch1(){
    TriggerExecutionController.skipAllTriggers(true);
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
         List<Opportunity_Product__c> oli =[SELECT Id, Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c, Quantity__c, OpportunityId__c,
                                           UnitPrice__c, Opt_Out_Auto_Quantity_Scheduling__c,Tender_Target__c, Nominated_Quantity__c,/* Commitment__c,*/ Country__c
                                           FROM Opportunity_Product__c limit 1];          
        Product2 prod= [Select id, oipc_code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
     Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE isStandard = true]; 
        PricebookEntry pbe=[select Id from PriceBookEntry where Product2Id =:prod.Id];
        list<OpportunityLineItem> Oli4 = new list<OpportunityLineItem>();
        Oli4.add (new OpportunityLineItem(OpportunityId = opp[0].Id,
            Quantity = 33,
            PriceBookEntryId = pbe.id,
            UnitPrice = 1,
            Amend_Expected_FFE__c =33,
            Opportunity_Product__c = oli[0].id,
            Schedule_Details__c ='123123:12313'+'/'+'133123',
            Opt_Out_Auto_Quantity_Scheduling__c = false
          ));
        insert Oli4;
        
        list<OpportunityLineItemSchedule> schlistToCreate = new list<OpportunityLineItemSchedule>();
        for(Opportunity_Product_Schedule__c schItem: [Select id,Schedule_Date__c ,Revenue__c , Quantity__c,Description__c,Type__c  from Opportunity_Product_Schedule__c where Opportunity_Product__c =:oli[0].id ]){
            OpportunityLineItemSchedule oppProdSch = new OpportunityLineItemSchedule();
                oppProdSch.Description = schItem.Description__c;
                oppProdSch.OpportunityLineItemId = Oli4[0].id;
                oppProdSch.Quantity = schItem.Quantity__c;
                oppProdSch.Revenue = schItem.Revenue__c;
                oppProdSch.ScheduleDate = schItem.Schedule_Date__c;
                oppProdSch.Type = schItem.Type__c;
                schlistToCreate.add(oppProdSch);
        }
     insert schlistToCreate; 
     TriggerExecutionController.skipAllTriggers(false);
         Test.startTest(); 
        OpptyLineItemSchedulingHelper.setScheduleDetailsOnOLIAfterInsert(Oli4);
        OpptyLineItemSchedulingHelper.prepareScheduleDetailsForOLI(Oli4);
        OpptyLineItemSchedulingHelper.updateOliGP(Oli4);
        OpptyLineItemSchedulingHelper.setScheduleDetailsOnOLI(Oli4,new map<Id, OpportunityLineItem>{Oli4[0].id => Oli4[0]});
        Test.stopTest();
    }
}