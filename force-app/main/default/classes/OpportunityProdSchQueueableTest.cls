/*
* Version	Date			Owner					SFSE#					Description
***********************************************************************************************************************************************
* 1.0                                                                   Base Code
* 2.0		15/09/2023		Aleena@Maersk			SFSE-10599		-   Removing reference of Nominated Quantity field
* 3.0       18/09/2023      Aleena@Maersk           SFSE-10599      -   New test framework 
*/

@isTest(seeAllData= false)
public class OpportunityProdSchQueueableTest {
    static Account clientAccount;
	@testSetup static void setup() {
        TriggerExecutionController.skipAllTriggers(true);
        //Account clientAccount = AccountDataHelper_Test.createClientAccount();
        clientAccount =TestBusinessHelper.createAccount('Client_Account', true);
        Account acc= [Select id,vertical__C from Account where id =: clientAccount.id limit 1];
        Opportunity mslOppty = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        //Opportunity mslOppty = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( clientAccount.id, null);  
        TriggerExecutionController.skipAllTriggers(false);
       // Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        Opportunity opp = [SELECT Id, StageName FROM Opportunity where id=:mslOppty.id limit 1];
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;
       
       // List<Product2> lstProd = DataGeneratorHelper1_Test.createProduct2( 1,'A','DE','Ocean');
        ScheduleOppProducts.OpportunityfromClone = false;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Update standardPricebook;
      
        /*Map<String, string> geoMap = new Map<String, String>();
        GeoMap.put( 'Long Beach', 'Country' );
        List<Geography__c> geoList = DataGeneratorHelper1_Test.createGeography( geoMap );
        system.debug('geoList ' + geoList);
        Geography__c geo = geoList[0];
        geo.Is_Port__c = true;
        update geo;*/
    	Geography__c country = TestBusinessHelper.createGeography('United States', 'Country', null, true); 
        country.Is_Port__c = true;
        update country; 
     	Geography__c state = TestBusinessHelper.createGeography('Karnataka', 'State', country.Id, true);
       /* List<Trade_Route__c> lstTradeRoute = DataGeneratorHelper_OIPC.createTradeRoutes(1, 'MCC');
        insert lstTradeRoute;
        Id tradeRouteId = lstTradeRoute[0].Id;*/
        List<Trade_Route__c> lstTradeRoute = TestBusinessHelper.createTradeRoutes(new List<String>{'MCC'}, 1,true);

          Test.StartTest();
       // List<Product2> lstProd = DataGeneratorHelper1_Test.createProduct2( 1,'A','DE','Ocean');
        Product2 Prod = TestBusinessHelper.createProduct('Ocean', true);
        Product2 lstProd = [Select id,oipc_code__c from Product2 where id=:Prod.id limit 1];
        List<Opportunity_Product__c> lstoli= new list<Opportunity_Product__c>();
       /* Opportunity_Product__c Oli1 = DataGeneratorHelperCusOli_Test.createOpportunityLineItem( mslOppty.Id);
       
        Opportunity_Product__c Oli2 = DataGeneratorHelperCusOli_Test.createOpportunityLineItemWithCountry( mslOppty.Id, geoList[0].Id );
        Oli2.Tender_Target__c = 100;
        update Oli2;*/
        Opportunity_Product__c Oli2 = TestBusinessHelper.createOpportunityLineItemCustom(mslOppty, lstProd.Id,lstTradeRoute[0],country,state, true);
        Opportunity_Product__c oli1 = [Select id, Tender_Target__c,OIPC_Product_Code__c ,Country__c from Opportunity_Product__c where id=:Oli2.id limit 1];
    	system.debug('oli'+oli1);
        oli1.Tender_Target__c = 100;
        update oli1;
        for(Opportunity_Product__c oli:[Select id, Product2ID__c from Opportunity_Product__c where opportunityid__c =: mslOppty.Id ]){
            oli.Product2ID__c=lstProd.id;
            lstoli.add(oli);
        }
        update lstoli;
        
        List<Product_Component__c> comps = TestBusinessHelper.createProductComponents(new List<Product2>{lstProd}, 1,true);  
        //List<Product_Component__c> comps = DataGeneratorHelper_OIPC.createOipcProductComponents(2, lstProd[0].Id);
        //insert comps;
        //List<Product_Feature__c> prodFeatList = DataGeneratorHelper_OIPC.createOipcProductFeatures(3, comps[0].Id);
        //insert prodFeatList;
        List<Product_Feature__c> prodFeatList = TestBusinessHelper.createProductFeatures(comps, 1,true);  
        List<Id> featList = new List<Id>();
        for( Product_Feature__c prodFeat : prodFeatList){
            featList.add(prodFeat.Id);
        }
        system.debug('featList :'+featList);
        //insert DataGeneratorHelperCusOli_OIPC.createOpptyFeatures(Oli2.Id,featList);
        
        Test.stopTest();
                      
    }
    
     static testmethod void TestOpptyLineItem(){  
        Test.StartTest();
       
         List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
        Product2 prod= [Select id, oipc_code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
        prod.Include_in_OMEB_Approvals__c= true;
        update prod; 
        Geography__c countryIndia = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' limit 1];
        Geography__c stateKA = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'State'  limit 1];
        Trade_Route__c testroude = [SELECT Id FROM Trade_Route__c limit 1];
         
        Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE isStandard = true];
        //It should return true
        System.assertEquals(true, standardPricebook.IsStandard);
        TriggerExecutionController.skipAllTriggers(true);
         //PricebookEntry pbe=[select Id from PriceBookEntry where Product2Id =:prod.Id];
          Opportunity_Product__c Oli = New Opportunity_Product__c();
            Oli.OpportunityId__c = opp[0].id;
            Oli.Quantity__c = 1;
            oli.Product2ID__c= prod.id;
            Oli.UnitPrice__c = 1;
         	Oli.Product_Revenue_Per_Unit__c = 1;
            oli.Opt_Out_Auto_Quantity_Scheduling__c = false;
            Oli.Tender_Target__c = 1;
         	oli.Country__c = countryIndia.Id;
            oli.Executing_City_State__c = stateKA.Id;
         	oli.Trade_Route__c= testroude.Id;
            //oli.Nominated_Quantity__c = 1;
        
        insert Oli;
         /*list<OpportunityLineItem> Oli4 = new list<OpportunityLineItem>();
        Oli4.add (new OpportunityLineItem(OpportunityId = opp[0].Id,
        Quantity = 33,
        PriceBookEntryId = pbe.id,
        UnitPrice = 1,
        Opt_Out_Auto_Quantity_Scheduling__c = false
        ));
 
       
        insert Oli4;*/
      
         
         Opportunity_Product__c oli1 = [SELECT Id, Amend_Expected_FFE__c, Quantity__c FROM Opportunity_Product__c WHERE OpportunityId__c = :opp[0].Id AND Product2ID__c = :prod.Id LIMIT 1];
         System.debug('oli1 before update: ' + oli1);
         
         oli1.Amend_Expected_FFE__c = 20;
         oli1.Quantity__c = 20;
         update oli1;
         
         System.debug('oli1 after update: ' + oli1);
        
        
          ScheduleOppProducts.OtherProductFlag = false;
          ScheduleOppProducts.DeletedfromOppProductTrigger = true;
         
         //OpptyLineItemSchedulingHelper.scheduleOppLineItem(Oli4, null, new Map<Id,Opportunity>{opp[0].id => opp[0]} , new Map<Id,Boolean>{opp[0].id => false});
             
        opp[0].First_Shipment_Date__c = date.today() + 300; 
        opp[0].Last_Shipment_Date__c = date.today() + 500; 
        update opp;
        TriggerExecutionController.skipAllTriggers(false);

        ScheduleOpportunityProducts.getSchedulingLogic( new Set<Id>{opp[0].id}, 'Opportunity');
        ScheduleOppProducts.getSchedulingLogic( new Set<Id>{opp[0].id}, 'Opportunity');    
       
        Test.StopTest();
         
         
        
    } 
    
    static testmethod void TestOpptylineScheduleCreate(){  
        
       
         List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
        Product2 prod= [Select id, oipc_code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
        prod.Include_in_OMEB_Approvals__c= true;
        update prod; 
        Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE isStandard = true];
        //It should return true
        System.assertEquals(true, standardPricebook.IsStandard);
         
         PricebookEntry pbe=[select Id from PriceBookEntry where Product2Id =:prod.Id];
          Test.StartTest();
          
         list<OpportunityLineItem> Oli4 = new list<OpportunityLineItem>();
        Oli4.add (new OpportunityLineItem(OpportunityId = opp[0].Id,
        Quantity = 33,
        PriceBookEntryId = pbe.id,
        UnitPrice = 1,
        Opt_Out_Auto_Quantity_Scheduling__c = false
        ));
 
       
        insert Oli4;
        OpportunityLineItemSchedule oppProdSch1 = new OpportunityLineItemSchedule();
        oppProdSch1.Description = 'test';
        oppProdSch1.OpportunityLineItemId = Oli4[0].id;
        oppProdSch1.Quantity = 1;
        oppProdSch1.Revenue = 33;
        oppProdSch1.ScheduleDate = Date.today();
        oppProdSch1.Type ='Both';
       
        OpportunityProdSchQueueable insertBatch= new OpportunityProdSchQueueable(null,new list<OpportunityLineItemSchedule>{oppProdSch1},'InsertScheduleDetailsOnOLI');
        System.enqueueJob(insertBatch);
        Test.StopTest();
         
         
        
    } 
    
    static testmethod void TestOpptylineScheduleDelete(){  
        
       
         List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
        Product2 prod= [Select id, oipc_code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
        prod.Include_in_OMEB_Approvals__c= true;
        update prod; 
        Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE isStandard = true];
        //It should return true
        System.assertEquals(true, standardPricebook.IsStandard);
         
         //PricebookEntry pbe=[select Id from PriceBookEntry where Product2Id =:prod.Id];
          Test.StartTest();
          
         list<OpportunityLineItem> Oli4 = new list<OpportunityLineItem>();
        Oli4.add (new OpportunityLineItem(OpportunityId = opp[0].Id,
        Quantity = 33,
        //PriceBookEntryId = pbe.id,
        Product2Id = prod.id,
        UnitPrice = 1,
        Opt_Out_Auto_Quantity_Scheduling__c = false
        ));
 
       
        insert Oli4;
        OpportunityLineItemSchedule oppProdSch1 = new OpportunityLineItemSchedule();
        oppProdSch1.Description = 'test';
        oppProdSch1.OpportunityLineItemId = Oli4[0].id;
        oppProdSch1.Quantity = 1;
        oppProdSch1.Revenue = 33;
        oppProdSch1.ScheduleDate = Date.today();
        oppProdSch1.Type ='Both';
       	insert oppProdSch1;
        OpportunityProdSchQueueable insertBatch= new OpportunityProdSchQueueable(null,new list<OpportunityLineItemSchedule>{oppProdSch1},'DeleteScheduleDetailsOnOLI');
        System.enqueueJob(insertBatch);
        Test.StopTest();
         
         
        
    }
    
   	static testmethod void TestCustomOpptylineScheduleCreate(){  
        
       	Test.startTest();
         List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
        Product2 prod= [Select id, oipc_code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
        prod.Include_in_OMEB_Approvals__c= true;
        update prod; 
        List<Opportunity_Product__c> oli =[SELECT Id, Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c, Quantity__c, OpportunityId__c,
                                           UnitPrice__c, Opt_Out_Auto_Quantity_Scheduling__c,Tender_Target__c, Country__c
                                           FROM Opportunity_Product__c limit 1];
         List<Opportunity_Product_Schedule__c> oppLstsch= new List<Opportunity_Product_Schedule__c>();
 		for(Opportunity_Product_Schedule__c sch:[Select id,Schedule_Date__c ,Revenue__c , Quantity__c,Description__c,Type__c  from Opportunity_Product_Schedule__c where Opportunity_Product__r.opportunityid__c =:opp[0].Id ]){
            Opportunity_Product_Schedule__c oppProdSch = new Opportunity_Product_Schedule__c();
                oppProdSch.Description__c = sch.Description__c;
                oppProdSch.Opportunity_Product__c = Oli[0].id;
                oppProdSch.Quantity__c = sch.Quantity__c;
                oppProdSch.Revenue__c = sch.Revenue__c;
                oppProdSch.Schedule_Date__c = sch.Schedule_Date__c;
                oppProdSch.Type__c = sch.Type__c;
            oppLstsch.add(oppProdSch);
        }
       
       
       
         OpportunityProdSchQueueable insertBatch= new OpportunityProdSchQueueable(oppLstsch,null,'InsertScheduleDetailsOnCustomOLI');
        System.enqueueJob(insertBatch);
        
        Test.StopTest();
         
         
        
    } 
    
    	static testmethod void TestCustomOpptylineScheduleDelete(){  
        
       Test.startTest();
         List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
        Product2 prod= [Select id, oipc_code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
        prod.Include_in_OMEB_Approvals__c= true;
        update prod; 
        List<Opportunity_Product__c> oli =[SELECT Id, Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c, Quantity__c, OpportunityId__c,
                                           UnitPrice__c, Opt_Out_Auto_Quantity_Scheduling__c,Tender_Target__c,Country__c
                                           FROM Opportunity_Product__c limit 1];
         List<Opportunity_Product_Schedule__c> oppLstsch= new List<Opportunity_Product_Schedule__c>();
 		for(Opportunity_Product_Schedule__c sch:[Select id,Schedule_Date__c ,Revenue__c , Quantity__c,Description__c,Type__c  from Opportunity_Product_Schedule__c where Opportunity_Product__r.opportunityid__c =:opp[0].Id ]){
            Opportunity_Product_Schedule__c oppProdSch = new Opportunity_Product_Schedule__c();
                oppProdSch.Description__c = sch.Description__c;
                oppProdSch.Opportunity_Product__c = Oli[0].id;
                oppProdSch.Quantity__c = sch.Quantity__c;
                oppProdSch.Revenue__c = sch.Revenue__c;
                oppProdSch.Schedule_Date__c = sch.Schedule_Date__c;
                oppProdSch.Type__c = sch.Type__c;
            oppLstsch.add(oppProdSch);
        }
       	 insert oppLstsch;
       
       
         OpportunityProdSchQueueable insertBatch= new OpportunityProdSchQueueable(oppLstsch,null,'DeleteScheduleDetailsOnCustomOLI');
        System.enqueueJob(insertBatch);
        Test.StopTest();
         
         
        
    }
    
}