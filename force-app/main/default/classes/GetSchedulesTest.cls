/*
* Version	Date			Owner					SFSE#					Description
***********************************************************************************************************************************************
* 1.0                                                                   Base Code
* 2.0		15/09/2023		Aleena@Maersk			SFSE-10599		-   Removing reference of Nominated Quantity field
* 3.0       18/09/2023      Aleena@Maersk           SFSE-10599      -   New test framework 
* 4.0      30-Jan-2024     Samar@maersk.com 		SFSE-13638          Opportunity product revenue schedule
*/

@isTest(seeAllData= false)
public class GetSchedulesTest {
    static Account clientAccount;
    @testSetup static void setup() {
        TriggerExecutionController.skipAllTriggers(true);
        //Account clientAccount = AccountDataHelper_Test.createClientAccount();
        clientAccount =TestBusinessHelper.createAccount('Client_Account', true);
        Account acc= [Select id,vertical__C from Account where id =: clientAccount.id limit 1];
        ScheduleOppProducts.OpportunityfromClone = false;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true );
        Update standardPricebook;
        // Opportunity mslOppty = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( clientAccount.id, null);
        Id supplychainrecordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.OppSupplyChainServicesRecType).getRecordTypeId();
        Opportunity mslOppty = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        Opportunity opp = [SELECT Id, StageName FROM Opportunity where id=:mslOppty.id limit 1];
        opp.RecordTypeId = supplychainrecordtypeId;
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;
        TriggerExecutionController.skipAllTriggers(false);
        // List<Product2> lstProd = DataGeneratorHelper1_Test.createProduct2( 1,'A','DE','Ocean');
        /* Map<String, string> geoMap = new Map<String, String>();
GeoMap.put( 'Long Beach', 'Country' );
List<Geography__c> geoList = DataGeneratorHelper1_Test.createGeography( geoMap );

system.debug('geoList ' + geoList);
Geography__c geo = geoList[0];
geo.Is_Port__c = true;
update geo;*/
        Geography__c country = TestBusinessHelper.createGeography('United States', 'Country', null, true); 
        country.Is_Port__c = true;
        update country; 
        /* List<Trade_Route__c> lstTradeRoute = DataGeneratorHelper_OIPC.createTradeRoutes(1, 'MCC');
insert lstTradeRoute;
Id tradeRouteId = lstTradeRoute[0].Id;*/
        List<Trade_Route__c> lstTradeRoute = TestBusinessHelper.createTradeRoutes(new List<String>{'MCC'}, 1,true);
        // List<Product2> lstProd = DataGeneratorHelper1_Test.createProduct2( 1,'A','DE','Ocean');
        Product2 Prod = TestBusinessHelper.createProduct('Ocean', true);
        Product2 lstProd = [Select id from Product2 where id=:Prod.id limit 1];
        // Opportunity_Product__c Oli1 = DataGeneratorHelperCusOli_Test.createOpportunityLineItem( mslOppty.Id);
        //Opportunity_Product__c Oli1 = TestBusinessHelper.createOpportunityLineItemCustom(mslOppty, lstProd.Id,lstTradeRoute[0], true);
        Opportunity_Product__c Oli2 = TestBusinessHelper.createOpportunityLineItemCustom(mslOppty, lstProd.Id,lstTradeRoute[0], true);
        Opportunity_Product__c oli = [Select id, Tender_Target__c from Opportunity_Product__c where id=:Oli2.id limit 1];
        oli.Tender_Target__c = 100;
        //update oli;

        //List<Product_Component__c> comps = DataGeneratorHelper_OIPC.createOipcProductComponents(2, lstProd.Id);
        List<Product_Component__c> comps = TestBusinessHelper.createProductComponents(new List<Product2>{lstProd}, 1,true);  
        //insert comps;
        //List<Product_Feature__c> prodFeatList = DataGeneratorHelper_OIPC.createOipcProductFeatures(3, comps[0].Id);
        List<Product_Feature__c> prodFeatList = TestBusinessHelper.createProductFeatures(comps, 1,true);  
        //insert prodFeatList;
        List<Id> featList = new List<Id>();
        for( Product_Feature__c prodFeat : prodFeatList){
            featList.add(prodFeat.Id);
        }
        system.debug('featList :'+featList);
        //insert DataGeneratorHelperCusOli_OIPC.createOpptyFeatures(Oli2.Id,featList);              
    }
    
    static testmethod void TestOpptyLineItem(){  
        
        Test.StartTest();
        
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,Must_Go_To_OMEB__c,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,Approval_Required__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,Approval_status__c,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,Requires_IT_Integration__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
        
        Geography__c recGeography = new Geography__c();
        recGeography.Name = 'India';
        recGeography.Active__c = true;
        recGeography.GEO_Code__c = 'IN12';
        recGeography.GEO_ID__c = '10Z2W9Zkjh3q4a12';
        recGeography.Is_Port__c = true;
        recGeography.Type_Of_Location__c = 'Country';
        insert recGeography;
        
        Product2 prod= [Select id, oipc_code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
        Trade_Route__c testRoute= [Select id from Trade_Route__c limit 1];
        Opportunity_Product__c Oli = New Opportunity_Product__c();
        Oli.OpportunityId__c = opp[0].id;
        Oli.Quantity__c = 1;
        oli.Product2ID__c= prod.id;
        Oli.UnitPrice__c = 1;
        Oli.Product_Revenue_Per_Unit__c = 1;
        oli.Opt_Out_Auto_Quantity_Scheduling__c = false;
        Oli.Tender_Target__c = 1;
        // oli.Nominated_Quantity__c = 1;
        oli.Trade_Route__c = testRoute.id;
        oli.Country__c = recGeography.id;
        insert oli;
        TriggerExecutionController.skipAllTriggers(true);
        Opportunity_Product__c Oli1 = New Opportunity_Product__c();
        Oli1.OpportunityId__c = opp[0].id;
        Oli1.Quantity__c = 1;
        oli1.Product2ID__c= prod.id;
        Oli1.UnitPrice__c = 1;
        Oli1.Product_Revenue_Per_Unit__c = 1;
        oli1.Opt_Out_Auto_Quantity_Scheduling__c = false;
        Oli1.Tender_Target__c = 1;
        Oli1.Trade_Route__c = testRoute.id;
        // oli1.Nominated_Quantity__c = 1;
        oli1.Country__c = recGeography.id;
        oli1.Total_Tender_FFE_per_Route_Direction__c = 1;
        Database.DmlOptions dmlOptions = new Database.DmlOptions();
        dmlOptions.DuplicateRuleHeader.allowSave = true;
        dmlOptions.EmailHeader.triggerUserEmail = false; 
        Database.SaveResult resultoli1 = Database.insert(oli1, dmlOptions);
        system.debug('resultoli1'+resultoli1);
        System.assert(resultoli1.isSuccess()); 
        TriggerExecutionController.skipAllTriggers(false);
        GetSchedules.scheduleWrapper wrapper1 = GetSchedules.getSchedules(oli1.Id);
       	GetSchedules.scheduleWrapper wrapper = GetSchedules.getSchedules(oli.Id);
        list<Opportunity_Product_Schedule__c> lstSch = wrapper.schedule;
        String jsonString = JSON.serialize(lstSch); 
        String result = GetSchedules.updateSchedules(jsonString,15,oli.Id);
        String result1 = GetSchedules.updateSchedules(jsonString,15,oli1.Id);
        
        Test.StopTest();
        
        
    } 
    
    
    static testmethod void TestReEstablishSchedule(){  
        TriggerExecutionController.skipAllTriggers(true);
        Test.StartTest();
        
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,Must_Go_To_OMEB__c,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,Approval_Required__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,Approval_status__c,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,Requires_IT_Integration__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
        Geography__c recGeography = new Geography__c();
        recGeography.Name = 'India';
        recGeography.Active__c = true;
        recGeography.GEO_Code__c = 'IN12';
        recGeography.GEO_ID__c = '10Z2W9Zkjh3q4a12';
        recGeography.Is_Port__c = true;
        recGeography.Type_Of_Location__c = 'Country';
        //System.runAs(new User(Id = UserInfo.getUserId())){ 
        insert recGeography;
        //}
        opp[0].First_Shipment_Date__c = date.today() + 300; 
        opp[0].Last_Shipment_Date__c = date.today() + 500; 
        opp[0].StageName = 'Closed Won';
        opp[0].Offer_Type__c = 'Offer containing Non-Standard T&Cs (contract or addendum)';
        //System.runAs(new User(Id = UserInfo.getUserId())){ 
        update opp;
        //}
		Trade_Route__c testRoute= [Select id from Trade_Route__c limit 1];        
        Product2 prod= [Select id, oipc_code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
        Opportunity_Product__c Oli = New Opportunity_Product__c();
        Oli.OpportunityId__c = opp[0].id;
        Oli.Quantity__c = 1;
        oli.Product2ID__c= prod.id;
        Oli.UnitPrice__c = 1;
        Oli.Product_Revenue_Per_Unit__c = 1;
        oli.Opt_Out_Auto_Quantity_Scheduling__c = false;
        Oli.Tender_Target__c = 1;
        oli.Trade_Route__c = testRoute.id;
        // oli.Nominated_Quantity__c = 1;
        oli.Country__c = recGeography.id;
        //System.runAs(new User(Id = UserInfo.getUserId())){ 
        insert oli;
        //}
        
        //Opportunity_Product_Schedule__c OppProduct= [Select id  from Opportunity_Product_Schedule__c where Opportunity_Product__c=oli.id limit 1];
        //List<Opportunity_Product_Schedule__c> lstSch = GetSchedules.getSchedules(oli.Id);
        
        // List<Id> scheduleIds = new List<Id>();
        
        //for (Opportunity_Product_Schedule__c schedule : lstSch) {
        //  scheduleIds.add(schedule.Id);
        //}
        
        String result = GetSchedules.ReEstablishSchedule( 400,oli.Id,'Repeat');
        opp[0].StageName = 'Closed Lost';
        opp[0].Reason_For_Close__c = 'Lost - Implementation failure';
        //opp[0].First_Shipment_Date__c = null; 
        opp[0].Last_Shipment_Date__c = null; 
        // System.runAs(new User(Id = UserInfo.getUserId())){ 
        update opp;
        //}
        String result1 = GetSchedules.ReEstablishSchedule( 400,oli.Id,'Divide');
        
        
        Test.StopTest();
        TriggerExecutionController.skipAllTriggers(false);
        
    }
    
    static testmethod void TestgetProductDetails(){  
        
        Test.StartTest();
        
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,Must_Go_To_OMEB__c,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,Approval_Required__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,Approval_status__c,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,Requires_IT_Integration__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
        
        Geography__c recGeography = new Geography__c();
        recGeography.Name = 'India';
        recGeography.Active__c = true;
        recGeography.GEO_Code__c = 'IN12';
        recGeography.GEO_ID__c = '10Z2W9Zkjh3q4a12';
        recGeography.Is_Port__c = true;
        recGeography.Type_Of_Location__c = 'Country';
        insert recGeography;
        
        Product2 prod= [Select id, oipc_code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
        Trade_Route__c testRoute= [Select id from Trade_Route__c limit 1];  
        Opportunity_Product__c Oli = New Opportunity_Product__c();
        Oli.OpportunityId__c = opp[0].id;
        Oli.Quantity__c = 1;
        oli.Product2ID__c= prod.id;
        Oli.UnitPrice__c = 1;
        Oli.Product_Revenue_Per_Unit__c = 1;
        oli.Opt_Out_Auto_Quantity_Scheduling__c = false;
        Oli.Tender_Target__c = 1;
        Oli.Trade_Route__c = testRoute.Id;
        //oli.Nominated_Quantity__c = 1;
        oli.Country__c = recGeography.id;
        insert oli;
        
        GetSchedules.getProductDetails(oli.Id);
        
        
        //String result = GetSchedules.ReEstablishSchedule(scheduleIds, 400);
        
        
        Test.StopTest();
        
        
    }
    
    
    static testmethod void testRevenueSchedule(){
        Test.StartTest();
        TriggerExecutionController.skipAllTriggers(true);
        Account clientAcc = [SELECT id from account LIMIT 1];
        Opportunity mslOppty2 = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        mslOppty2.Customer_Journey__c = 'As-Is Journey';
        update mslOppty2;
        Product2 latestProduct= TestBusinessHelper.createProduct('ocean', true);
        List<Product2> prodIns = [Select id,name,Product_Scope__c from Product2 where id =: latestProduct.id];
        prodIns[0].Product_Scope__c = 'Included In Email Agreement';
        update prodIns;
        List<Trade_Route__c> lstTDR = TestBusinessHelper.createTradeRoutes(new List<String> {'MSL'},  1, true);
        TriggerExecutionController.skipAllTriggers(false);
        Opportunity_Product__c oli1 = TestBusinessHelper.createOpportunityLineItemCustom(mslOppty2, prodIns[0].id,lstTDR[0], false) ;
        oli1.Id= null;
        oli1.Product_Revenue_Per_Unit__c=10;
       	oli1.Quantity__c = 15;
        insert oli1;     
        
       	GetSchedules.scheduleWrapper wrapper = GetSchedules.getSchedules(oli1.Id);
        list<Opportunity_Product_Schedule__c> lstSch = wrapper.schedule;
        String jsonString = JSON.serialize(lstSch); 
        String result = GetSchedules.updateSchedules(jsonString,15,oli1.Id);
        Assert.areEqual(oli1.Product_Revenue_Per_Unit__c,(lstSch[0].Schedule_Revenue__c/lstSch[0].Quantity__c));
         Test.stopTest();
    }
    
    
}