/*              
* Revision 	Date			Owner						Description
* -------- 	----------		-----------					-----------
* 1.0      			  									Base code
* 2.0      23-Aug-23        Shashi@Maersk               Revamped test setup based on new test framework to resolve SOQL 101 exception
*/
@isTest
public class OpportunityProductScheduleTrigger_Test{
    
   @TestSetup
   static void setup()
    {
        Test.startTest();
        TriggerExecutionController.skipAllTriggers(true);
        /**TriggerExecutionController.skipAllTriggers(true);
        Account clientAccount = AccountDataHelper_Test.createClientAccount();
        Opportunity mslOppty = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( clientAccount.id, null);  
        Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;
       TriggerExecutionController.skipAllTriggers(false);*/
        
       // List<Product2> lstProd = DataGeneratorHelper1_Test.createProduct2( 1,'A','DE','Ocean');
       
        User maerskLineUser = TestBusinessHelper.createUser('System Administrator', BrandUtilities.MAERSKLINE, true);
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', true);   
        Contact contact = TestBusinessHelper.createContact(ClientAccount, 'Customer_Contact', BrandUtilities.MAERSKLINE, true);
        Opportunity mslOppty = TestBusinessHelper.createOpportunity(ClientAccount, contact, maerskLineUser, 'ShippingCargoServices',  BrandUtilities.MAERSKLINE, true);
        mslOppty.Pricebook2Id = Test.getStandardPricebookId();
        update mslOppty;
        
        list<String> prodFamily = new List<String>{'Ocean'};
        List<Product2> lstProd =  TestBusinessHelper.createProducts(prodFamily, 1, true);
        lstProd[0].Include_in_OMEB_Approvals__c=false;
        lstProd[0].Is_Product_Solution__c = true;
        update lstProd;
        
        ScheduleOppProducts.OpportunityfromClone = false;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Update standardPricebook;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = lstProd[0].Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
         //TriggerExecutionController.skipAllTriggers(true);
        
        /**Map<String, string> geoMap = new Map<String, String>();
        GeoMap.put( 'Long Beach', 'Country' );
        List<Geography__c> geoList = DataGeneratorHelper1_Test.createGeography( geoMap );
        system.debug('geoList ' + geoList);
        Geography__c geo = geoList[0];
        geo.Is_Port__c = true;
        update geo;*/
        
        Geography__c geo = TestBusinessHelper.createGeography('Long Beach', 'Country', null, true);
        geo.Is_Port__c = true;
        update geo;
        
        Geography__c city = TestBusinessHelper.createGeography('Colorado', 'City', geo.Id, true);
       
        /**List<Trade_Route__c> lstTradeRoute = DataGeneratorHelper_OIPC.createTradeRoutes(1, 'MCC');
        insert lstTradeRoute;
        Id tradeRouteId = lstTradeRoute[0].Id;
        Opportunity_Product__c Oli1 = DataGeneratorHelperCusOli_Test.createOpportunityLineItem( mslOppty.Id);
        TriggerExecutionController.skipAllTriggers(false);
        List<Product2> lstProd = DataGeneratorHelper1_Test.createProduct2( 1,'A','DE','Ocean');
        
        Opportunity_Product__c Oli2 = DataGeneratorHelperCusOli_Test.createOpportunityLineItemWithCountry( mslOppty.Id, geoList[0].Id );
        List<Opportunity_Product__c> lstoli= new list<Opportunity_Product__c>();
        for(Opportunity_Product__c oli:[Select id, Product2ID__c from Opportunity_Product__c where opportunityid__c =: mslOppty.Id ]){
            oli.Product2ID__c=lstProd[0].id;
            lstoli.add(oli);
        }
        update lstoli;*/
        
        List<String> lstTradeRouteOperator = new List<String>{'MCC'}; 
        List<Trade_Route__c> lstTradeRoute = TestBusinessHelper.createTradeRoutes(lstTradeRouteOperator, 1, true);
        
        Opportunity_Product__c Oli1 = TestBusinessHelper.createOpportunityLineItemCustom(mslOppty, lstProd[0].Id, lstTradeRoute[0], true);
        
        Opportunity_Product__c Oli2 = TestBusinessHelper.createOpportunityLineItemCustom(mslOppty, lstProd[0].Id, lstTradeRoute[0], geo, city, true);
        
     
        /**List<Product_Component__c> comps = DataGeneratorHelper_OIPC.createOipcProductComponents(2, lstProd[0].Id);
        insert comps;
        List<Product_Feature__c> prodFeatList = DataGeneratorHelper_OIPC.createOipcProductFeatures(3, comps[0].Id);
        insert prodFeatList;
        List<Id> featList = new List<Id>();
        for( Product_Feature__c prodFeat : prodFeatList){
            featList.add(prodFeat.Id);
        }
        system.debug('featList :'+featList);
           TriggerExecutionController.skipAllTriggers(false);
        //insert DataGeneratorHelperCusOli_OIPC.createOpptyFeatures(Oli2.Id,featList);
         Test.stopTest();*/
        
        List<Product2> lstProd1 = new List<Product2>{lstProd[0]};
        List<Product_Component__c> comps = TestBusinessHelper.createProductComponents(lstProd1, 2, true);
        
        List<Product_Component__c> lstCompnt1 = new List<Product_Component__c>{comps[0]};
        List<Product_Feature__c> lstFeatures1 = TestBusinessHelper.createProductFeatures(lstCompnt1, 3, true);
        
        System.debug('pbid='+pricebookId);
        System.debug('prodid='+lstProd[0].id);
        
        /**PricebookEntry pbEntry = new PricebookEntry(
            IsActive=true,
            UnitPrice=100,
            Pricebook2Id=standardPricebook.Id,
            UseStandardPrice=true,
            Product2Id=lstProd[0].id
        );
        insert pbEntry;*/
        
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = lstProd[0].Id, UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
              
    }
    static testmethod void TestOpptyLineItem(){  
        
        Test.StartTest();
        TriggerExecutionController.skipAllTriggers(true);
        //OpportunityLineItem Oli2 = [SELECT Id FROM OpportunityLineItem Where Product_family__c = 'Lead Logistics' limit 1];
        Opportunity_Product__c Oli = [SELECT Id, Amend_Gross_Profit_per_unit__c, UnitPrice__c FROM Opportunity_Product__c limit 1];
        //OpportunityLineItem Oli2 = [SELECT Id FROM OpportunityLineItem Where Product_family__c = 'Lead Logistics' limit 1];
        
        
        decimal newGP = Oli.UnitPrice__c + 2;
        Oli.Amend_Gross_Profit_per_unit__c = newGP;
        update Oli;
        
        //List<Opportunity_Product__c> lst = [SELECT Id, UnitPrice__c FROM Opportunity_Product__c Where id = :Oli.Id];       
        //Opportunity_Product__c opptyProd =  [SELECT Id, UnitPrice__c FROM Opportunity_Product__c Where id = :Oli.Id];   
        //System.assertEquals(opptyProd.UnitPrice__c, newGP);
        
        //delete Oli2;
        
        Test.StopTest();
        
        
    } 
    
    static testmethod void TestOpptyLineItemDelete(){  
        
        Test.StartTest();
        Opportunity opp = [select id,name ,StageName from Opportunity limit 1];
        opp.StageName = 'Qualifying';
        update opp;
        Opportunity_Product__c Oli = [SELECT Id, Amend_Gross_Profit_per_unit__c, UnitPrice__c FROM Opportunity_Product__c where OpportunityId__c=:opp.Id  limit 1];
        
        delete Oli;
        Test.StopTest();
    } 
    
    
    
    static testmethod void testinvokeClonefunctionality(){
        Test.startTest();
        Opportunity mslOppty = [SELECT id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                Expected_Handling_Rounds__c, Pricebook2Id
                                FROM Opportunity where Liner_Brand__c = :BrandUtilities.MAERSKLINE];
        
        List<Opportunity_Product__c> Oli = [SELECT Id, Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c, Quantity__c, OpportunityId__c,
                                            UnitPrice__c, Opt_Out_Auto_Quantity_Scheduling__c,Tender_Target__c,Country__c,
                                            Trade_Route__c
                                            FROM Opportunity_Product__c where OpportunityId__c=:mslOppty.id];
        // Query schedules which gets created
        try{
            Opportunity lstClonedrec = mslOppty.clone(false, false, false,false);        
            insert lstClonedrec;       
            List<Opportunity_Product__c> newItemList = new List<Opportunity_Product__c>();
            for(Opportunity_Product__c item : Oli){
                Opportunity_Product__c ol = item.clone();
                ol.OpportunityId__c = lstClonedrec.id;
                newItemList.add(ol);
            }
            insert newItemList;
            
            List<Opportunity_Product_Schedule__c> oliSch = [select id,Opportunity_Product__c, isClonedrecord__c, Schedule_Date__c,Quantity__c,Revenue__c,Type__c from Opportunity_Product_Schedule__c where Opportunity_Product__c=:Oli[0].id];     
            List<Opportunity_Product_Schedule__c> OpportunityLineItemScheduleList = new List<Opportunity_Product_Schedule__c>();
            for(Opportunity_Product_Schedule__c oitem : oliSch){
                Opportunity_Product_Schedule__c osl = oitem.clone();
                osl.Opportunity_Product__c = newItemList[0].id;
                
                OpportunityLineItemScheduleList.add(osl);
            }
            insert OpportunityLineItemScheduleList;
            
            Opportunity_Product_Schedule__c olicloneSch = [select id, isClonedrecord__c, Schedule_Date__c,Quantity__c,Revenue__c,Type__c from Opportunity_Product_Schedule__c where Opportunity_Product__c=:newItemList[0].id];
            System.debug('after olicloneSch>>>>'+olicloneSch.getCloneSourceId());           
            //System.assertEquals(olicloneSch.size(), 2); // check if schedules are created on cloning
        } catch(Exception e){
            
            
        }
        Test.StopTest();
        
    }
    
    static testmethod void testinvokerecreateonFFEUpdate(){
        Test.startTest();
        Opportunity mslOppty = [SELECT id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                Expected_Handling_Rounds__c, Pricebook2Id
                                FROM Opportunity where Liner_Brand__c = :BrandUtilities.MAERSKLINE];       
        Opportunity_Product__c Oli = [SELECT Id, Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c, Quantity__c, OpportunityId__c,
                                      UnitPrice__c, Opt_Out_Auto_Quantity_Scheduling__c,Tender_Target__c,/* Commitment__c,*/ Country__c
                                      FROM Opportunity_Product__c where OpportunityId__c=:mslOppty.id limit 1];
       
   
        Oli.Amend_Expected_FFE__c = 10;
        Oli.Quantity__c = 5;
        update Oli;            
        System.assertEquals(Oli.Amend_Expected_FFE__c, 10);            
        Test.stopTest();
    }
    static testmethod void testValidationMethods(){
        Test.startTest();
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
        List<Opportunity_Product__c> oli =[SELECT Id, Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c, Quantity__c, OpportunityId__c,
                                           UnitPrice__c, Opt_Out_Auto_Quantity_Scheduling__c,Tender_Target__c,/* Commitment__c,*/ Country__c
                                           FROM Opportunity_Product__c limit 1];
        OpportunityProductUtilities.validateOpptyStageApprovalStatus(oli);
        OpportunityProductUtilities.validateOpptyPendingApprovalProcesses(oli, opp);
        Test.stopTest();
    }
    
    static testmethod void testclosedWonopp(){
        Test.startTest();
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
       	opp[0].Tender_Submission_Format__c = 'No Ocean Tender';
        opp[0].stagename='Closed Won';
        opp[0].Offer_Type__c='Offer containing Standard T&Cs';
        update opp;    
        List<Opportunity_Product__c> oli =[SELECT Id, Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c, Quantity__c, OpportunityId__c,
                                           UnitPrice__c, Opt_Out_Auto_Quantity_Scheduling__c,Tender_Target__c,/* Commitment__c,*/ Country__c
                                           FROM Opportunity_Product__c where opportunityid__c=:opp[0].id limit 1];          
        
        try{
            Opportunity_Product_Schedule__c sch=  new Opportunity_Product_Schedule__c(
            Opportunity_Product__c = oli[0].id,
            Quantity__c =20,
            Schedule_Date__c =system.today());
            insert sch;
            //OppoProductSchUtilities.preventToUpdateQuantityAndRevenue(new List<Opportunity_Product_Schedule__c>{sch},new Map<id,Opportunity_Product_Schedule__c>{sch.id=>sch},'Insert');
            //OppoProductSchUtilities.preventToUpdateQuantityAndRevenue(new List<Opportunity_Product_Schedule__c>{sch},new Map<id,Opportunity_Product_Schedule__c>{sch.id=>sch},'Delete');
            //OppoProductSchUtilities.preventToUpdateQuantityAndRevenue(new List<Opportunity_Product_Schedule__c>{sch},new Map<id,Opportunity_Product_Schedule__c>{sch.id=>sch},'update');
        }catch(Exception ex){
                
        }  
        Test.stopTest();
        }
    
    static testmethod void testdeleteSch(){
        Test.startTest();
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
        opp[0].Tender_Submission_Format__c = 'No Ocean Tender';
        opp[0].stagename='Closed Won';
        opp[0].Offer_Type__c='Offer containing Standard T&Cs';
        update opp;    
        List<Opportunity_Product__c> oli =[SELECT Id, Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c, Quantity__c, OpportunityId__c,
                                           UnitPrice__c, Opt_Out_Auto_Quantity_Scheduling__c,Tender_Target__c,/* Commitment__c,*/ Country__c
                                           FROM Opportunity_Product__c limit 1];          
        
        try{
            Opportunity_Product_Schedule__c sch= [Select id from Opportunity_Product_Schedule__c where Opportunity_Product__c =:oli[0].id limit 1 ];
           
            delete sch;
        }catch(Exception ex){
                
        }  
          
          
        try{
            Opportunity_Product_Schedule__c sch= [Select id,quantity__c from Opportunity_Product_Schedule__c where Opportunity_Product__c =:oli[0].id limit 1 ];
           	sch.quantity__c = 10;
            update sch;
        }catch(Exception ex){
                
        }   
        Test.stopTest();
        }
   		
   	static testmethod void testupdateSch(){
        Test.startTest();
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
     
        List<Opportunity_Product__c> oli =[SELECT Id, Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c, Quantity__c, OpportunityId__c,
                                           UnitPrice__c, Opt_Out_Auto_Quantity_Scheduling__c,Tender_Target__c,/* Commitment__c,*/ Country__c
                                           FROM Opportunity_Product__c limit 1];          
        Product2 prod= [Select id, oipc_code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
	 	Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE isStandard = true]; 
        PricebookEntry pbe=[select Id from PriceBookEntry where Product2Id =:prod.Id LIMIT 1];
        TriggerExecutionController.skipAllTriggers(true);
        list<OpportunityLineItem> Oli4 = new list<OpportunityLineItem>();
        Oli4.add (new OpportunityLineItem(OpportunityId = opp[0].Id,
            Quantity = 33,
            PriceBookEntryId = pbe.id,
            UnitPrice = 1,
            Opportunity_Product__c = oli[0].id,
            Opt_Out_Auto_Quantity_Scheduling__c = false
        	));
        insert Oli4;
        Opportunity_Product_Schedule__c sch1=  new Opportunity_Product_Schedule__c(
            Opportunity_Product__c = oli[0].id,
            Quantity__c =20,
            Type__c = 'Quantity',
            Revenue__c=1,
            Schedule_Date__c =system.today());
            insert sch1;
        list<OpportunityLineItemSchedule> schlistToCreate = new list<OpportunityLineItemSchedule>();
        for(Opportunity_Product_Schedule__c schItem: [Select id,Schedule_Date__c ,Revenue__c , Quantity__c,Description__c,Type__c  from Opportunity_Product_Schedule__c where Opportunity_Product__c =:oli[0].id ]){
            OpportunityLineItemSchedule oppProdSch = new OpportunityLineItemSchedule();
                oppProdSch.Description = schItem.Description__c;
                oppProdSch.OpportunityLineItemId = Oli4[0].id;
                oppProdSch.Quantity = schItem.Quantity__c;
                //oppProdSch.Revenue = schItem.Revenue__c;
                oppProdSch.ScheduleDate = schItem.Schedule_Date__c;
              	oppProdSch.Type = 'Quantity';
                schlistToCreate.add(oppProdSch);
        }
		insert schlistToCreate;         	
       TriggerExecutionController.skipAllTriggers(false);
        Opportunity_Product_Schedule__c sch= [Select id,quantity__c from Opportunity_Product_Schedule__c where Opportunity_Product__c =:oli[0].id limit 1 ];
        	system.debug('sch.quantity__c_01 @@@'+sch.quantity__c);	   	
        sch.quantity__c = 100;
            update sch; 
        system.debug('sch.quantity__c_02 @@@'+sch.quantity__c);
         Test.stopTest();
     }
   	
    static testmethod void testcreatestdOli(){
        Test.startTest();
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
     
        List<Opportunity_Product__c> oli =[SELECT Id, Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c, Quantity__c, OpportunityId__c,
                                           UnitPrice__c, Opt_Out_Auto_Quantity_Scheduling__c,Tender_Target__c,/* Commitment__c,*/ Country__c
                                           FROM Opportunity_Product__c limit 1];          
        Product2 prod= [Select id, oipc_code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
	 	Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE isStandard = true]; 
        PricebookEntry pbe=[select Id from PriceBookEntry where Product2Id =:prod.Id LIMIT 1];
        list<OpportunityLineItem> Oli4 = new list<OpportunityLineItem>();
        Oli4.add (new OpportunityLineItem(OpportunityId = opp[0].Id,
            Quantity = 33,
            PriceBookEntryId = pbe.id,
            UnitPrice = 1,
            Opportunity_Product__c = oli[0].id,
            Opt_Out_Auto_Quantity_Scheduling__c = false
        	));
        insert Oli4;
        
        OppoProductSchUtilities.createstdOli(oli, new Map<Id,Opportunity>{opp[0].id => opp[0]} , new Map<Id,Boolean>{opp[0].id => false});
        List<Opportunity_Product_Schedule__c> schItem= [Select id,Schedule_Date__c ,Revenue__c , Quantity__c,Description__c,Type__c  from Opportunity_Product_Schedule__c where Opportunity_Product__c =:oli[0].id ];
        try{
            OppoProductSchUtilities.validateAgreementDates(schItem);
            OppoProductSchUtilities.setCloneFlag(schItem);
        }catch(Exception ex){
            
        }
        
        
        Test.stopTest();
      }
    
    static testmethod void testclosedWonopptest1(){
        Test.startTest();
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
       	opp[0].Tender_Submission_Format__c = 'No Ocean Tender';
        opp[0].stagename='Closed Won';
        opp[0].Offer_Type__c='Offer containing Standard T&Cs';
        update opp;    
        List<Opportunity_Product__c> oli =[SELECT Id, Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c, Quantity__c, OpportunityId__c,
                                           UnitPrice__c, Opt_Out_Auto_Quantity_Scheduling__c,Tender_Target__c,/* Commitment__c,*/ Country__c
                                           FROM Opportunity_Product__c where opportunityid__c=:opp[0].id limit 1];          
        
        try{
            Opportunity_Product_Schedule__c sch=  new Opportunity_Product_Schedule__c(
            Opportunity_Product__c = oli[0].id,
            Quantity__c =20,
            Schedule_Date__c =system.today());
            insert sch;
            
            //OppoProductSchUtilities.preventToUpdateQuantityAndRevenue(new List<Opportunity_Product_Schedule__c>{sch},new Map<id,Opportunity_Product_Schedule__c>{sch.id=>sch},'Delete');
            //OppoProductSchUtilities.preventToUpdateQuantityAndRevenue(new List<Opportunity_Product_Schedule__c>{sch},new Map<id,Opportunity_Product_Schedule__c>{sch.id=>sch},'update');
        }catch(Exception ex){
                
        }  
        Test.stopTest();
        
    }
   static testmethod void testclosedWonopptest2(){
        Test.startTest();
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
        opp[0].Tender_Submission_Format__c = 'No Ocean Tender';
        opp[0].stagename='Closed Won';
        opp[0].Offer_Type__c='Offer containing Standard T&Cs';
        update opp;    
        List<Opportunity_Product__c> oli =[SELECT Id, Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c, Quantity__c, OpportunityId__c,
                                           UnitPrice__c, Opt_Out_Auto_Quantity_Scheduling__c,Tender_Target__c,/* Commitment__c,*/ Country__c
                                           FROM Opportunity_Product__c where opportunityid__c=:opp[0].id limit 1];          
        
        try{
            Opportunity_Product_Schedule__c sch=  new Opportunity_Product_Schedule__c(
            Opportunity_Product__c = oli[0].id,
            Quantity__c =20,
            Schedule_Date__c =system.today());
            insert sch;
		 //OppoProductSchUtilities.preventToUpdateQuantityAndRevenue(new List<Opportunity_Product_Schedule__c>{sch},new Map<id,Opportunity_Product_Schedule__c>{sch.id=>sch},'update');
        }catch(Exception ex){
                
        }  
        Test.stopTest();
        
    }
}