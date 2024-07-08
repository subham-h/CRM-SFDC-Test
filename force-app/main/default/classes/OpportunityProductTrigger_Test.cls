/*              
* Revision 	Date			Owner						Description
* -------- 	----------		-----------					-----------
* 1.0      			  									Base code
* 2.0      19-Aug-23		Kiran@maersk.com			New test data framework to resolve SOQL 101 exception
* 3.0	   30-oct-2023		mahanthi.devi@maersk.com	To change the product family references to oipc code
* 4.0      30-Jan-2024     Samar@maersk.com             Opportunity product revenue schedule SFSE-13638
*/

@isTest(seeAllData= false)
public class OpportunityProductTrigger_Test {
      // public static List<String> oipc_code = Label.Ocean_Product_OipcCode.split(';');
    
    @testSetup static void setup() {
        Test.startTest();
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
        Geography__c state = TestBusinessHelper.createGeography('Karnataka', 'State', country.Id, true);
        Geography__c chinaCountry = TestBusinessHelper.createGeography('China','Country', null, true);
        Geography__c chinastate = TestBusinessHelper.createGeography('San Carlos','State', chinaCountry.Id, true);
        
        BDA__c parentBDA = TestBusinessHelper.createBDA('India, Middle East, and Africa', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true);
        BDA__c childBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'IBS', parentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, country.Id, null, true);
        
        BDA__c chinaParentBDA = TestBusinessHelper.createBDA('Asia Pacific Region', 'Trade Region', 'APA', null, UserInfo.getUserId(), true);
        BDA__c chinaChildBDA = TestBusinessHelper.createBDA('Greater China Area', 'Cluster', 'GCA', chinaParentBDA, UserInfo.getUserId(), true);
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
        
        /*List<Geography__c> geoList = DataGeneratorHelper1_Test.createGeography( geoMap );
system.debug('geoList ' + geoList);
Geography__c geo = geoList[0];
geo.Is_Port__c = true;
update geo;*/
        
        
        List<Trade_Route__c> lstTradeRoute = TestBusinessHelper.createTradeRoutes(new List<String>{BrandUtilities.MCC}, 1,true);
        //insert lstTradeRoute;
        Id tradeRouteId = lstTradeRoute[0].Id;
        List<Product2> Prodlist = new list<Product2>();
        Product2 lstProd = TestBusinessHelper.createProduct('Ocean', true);
        lstProd.Is_Product_Solution__c = true;
        update lstProd;
        
        TriggerExecutionController.skipAllTriggers(true);
        List<Opportunity_Product__c> lstoli= new list<Opportunity_Product__c>();

        Opportunity_Product__c Oli1 = TestBusinessHelper.createOpportunityLineItemCustom(mslOppty, lstProd.Id,lstTradeRoute[0], true);
        List<OpportunityLineItem> stdOli = new list<OpportunityLineItem>();
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = mslOppty.id;
        oli2.Product2Id = lstProd.Id;
        oli2.Opportunity_Product__c = Oli1.Id;   
        stdOli.add(oli2);
        insert stdoli;
        
        //Opportunity_Product__c Oli1 = DataGeneratorHelperCusOli_Test.createOpportunityLineItem( mslOppty.Id);
        
        //Opportunity_Product__c Oli2 = TestBusinessHelper.createOpportunityLineItemCustom(mslOppty, lstProd.Id,lstTradeRoute[0], true);
        
        for(Opportunity_Product__c oli:[Select id, Product2ID__c from Opportunity_Product__c where opportunityid__c =: mslOppty.Id ]){
            oli.Product2ID__c=lstProd.id;
            oli.Tender_Target__c = 100;
            lstoli.add(oli);
        }
        update lstoli;
        TriggerExecutionController.skipAllTriggers(false);
        
        List<Product_Component__c> comps =  new List<Product_Component__c>();
        for (integer i = 1; i <= 3; i++){
            Product_Component__c pc = new Product_Component__c();
            pc.Name = 'Comp' + i;
            pc.Component_Code__c = 'PC' + i;
            pc.Product__c = lstProd.Id;
            pc.Display_Order__c = i;
            comps.add(pc);
        }
        insert comps;
        
        List<Product_Feature__c> prodFeatList = new List<Product_Feature__c>();
        
        for (integer i = 0; i < 3; i++){
            
            Product_Feature__c f = new Product_Feature__c();
            f.Name = 'Feature' + i;
            f.Feature_Code__c = 'F' + i;
            f.Product_Component__c = comps[i].Id;
            f.Display_Order__c = i;
            f.Description__c = 'Feature description ';           
            prodFeatList.add(f);
        }
        insert prodFeatList;
        
        List<Id> featList = new List<Id>();
        for( Product_Feature__c prodFeat : prodFeatList){
            featList.add(prodFeat.Id);
        }
        system.debug('featList :'+featList);
        Test.stopTest();
    }
    
    static testmethod void TestOpptyLineItem(){  
        
        Test.StartTest();
        
        Opportunity_Product__c Oli = [SELECT Id, Amend_Gross_Profit_per_unit__c, UnitPrice__c FROM Opportunity_Product__c limit 1];
        
        
        decimal newGP = Oli.UnitPrice__c + 2;
        Oli.Amend_Gross_Profit_per_unit__c = newGP;
        update Oli;
        
        List<Opportunity_Product__c> lst = [SELECT Id, UnitPrice__c FROM Opportunity_Product__c Where id = :Oli.Id];        
        System.assertEquals(lst[0].UnitPrice__c, newGP);
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
    
    
    
    /*static testmethod void testinvokeClonefunctionality(){
Test.startTest();
Opportunity mslOppty = [SELECT id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
Expected_Handling_Rounds__c, Pricebook2Id
FROM Opportunity where Liner_Brand__c = :BrandUtilities.MAERSKLINE LIMIT 1];

List<Opportunity_Product__c> Oli = [SELECT Id, Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c, Quantity__c, OpportunityId__c,
UnitPrice__c, Opt_Out_Auto_Quantity_Scheduling__c,Tender_Target__c, Country__c,
Trade_Route__c
FROM Opportunity_Product__c where OpportunityId__c=:mslOppty.id];

// Query schedules which gets created
try{
Opportunity lstClonedrec = mslOppty.clone(false, false, false,false);        
insert lstClonedrec;       
List<Opportunity_Product__c> newItemList = new List<Opportunity_Product__c>();
List<Opportunity_Product__c> updateList = New List<Opportunity_Product__c>();
for(Opportunity_Product__c item : Oli){
item.Quantity__c = 20;
Opportunity_Product__c ol = item.clone();
ol.OpportunityId__c = lstClonedrec.id;
ol.Quantity__c = 20;
newItemList.add(ol);
updateList.add(item);
}
insert newItemList;
update updateList;

List<Opportunity_Product_Schedule__c> oliSch = [select id,Opportunity_Product__c, isClonedrecord__c, Schedule_Date__c,Quantity__c,Revenue__c,Type__c from Opportunity_Product_Schedule__c where Opportunity_Product__c=:Oli[0].id];     
List<Opportunity_Product_Schedule__c> OpportunityLineItemScheduleList = new List<Opportunity_Product_Schedule__c>();
for(Opportunity_Product_Schedule__c oitem : oliSch){
Opportunity_Product_Schedule__c osl = oitem.clone();
osl.Opportunity_Product__c = newItemList[0].id;
osl.Quantity__c = 20;
OpportunityLineItemScheduleList.add(osl);
}
insert OpportunityLineItemScheduleList;

List<Opportunity_Product_Schedule__c> olicloneSch = [select id, isClonedrecord__c, Schedule_Date__c,Quantity__c,Revenue__c,Type__c from Opportunity_Product_Schedule__c where Opportunity_Product__c=:newItemList[0].id];
System.debug('after olicloneSch>>>>'+olicloneSch);           
//System.assertEquals(olicloneSch.size(), 2); // check if schedules are created on cloning
} catch(Exception e){

System.debug('Error Message >> '+e.getMessage());
}
Test.StopTest();

}*/
    
    static testmethod void testinvokerecreateonFFEUpdate(){
        Test.startTest();
        Opportunity mslOppty = [SELECT id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                Expected_Handling_Rounds__c, Pricebook2Id
                                FROM Opportunity where Liner_Brand__c = :BrandUtilities.MAERSKLINE LIMIT 1]; 
        
        
        Opportunity_Product__c Oli = [SELECT Id, Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c, Quantity__c, OpportunityId__c,
                                      UnitPrice__c, Opt_Out_Auto_Quantity_Scheduling__c,Tender_Target__c,/* Commitment__c,*/ Country__c
                                      FROM Opportunity_Product__c where OpportunityId__c=:mslOppty.id limit 1];
        
        
        Oli.Amend_Expected_FFE__c = 10;
        Oli.Quantity__c = 5;
        Oli.Opt_Out_Auto_Quantity_Scheduling__c = false;
        update Oli; 
        OpportunityLineItem  oli2  = [SELECT Id, Opportunity_Product__c,Total_Mandatory_Configuration__c,Total_Mandatory_Configuration_Filled__c, Total_Config_Completed_Percentage__c, 
                                    Amend_Expected_FFE__c, Amend_Gross_Profit_per_unit__c, Product2Id, HasSchedule,Country__c, opportunityId,UnitPrice,
                                    Executing_City_State__c, Executing_City_State__r.Name, Trade_Route__r.Name, Quantity, Warehouse_Site__c, Warehouse_Site__r.Name FROM OpportunityLineItem];
        
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
                                           UnitPrice__c, Opt_Out_Auto_Quantity_Scheduling__c,Tender_Target__c, /* Commitment__c,*/ Country__c
                                           FROM Opportunity_Product__c limit 1];
        OpportunityProductUtilities.validateOpptyStageApprovalStatus(oli);
        OpportunityProductUtilities.validateOpptyPendingApprovalProcesses(oli, opp);
       
        Test.stopTest();
    }
    
    static testmethod void testapprovedSGOptyQuoteStage(){
        Test.startTest();
        Id oppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Supply Chain Services').getRecordTypeId();
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,Must_Go_To_OMEB__c,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,Approval_Required__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,Approval_status__c,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,Requires_IT_Integration__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
        opp[0].Requires_IT_Integration__c ='Yes, I am sure this is required basis my discussion with customer';
        opp[0].recordtypeid =oppRecordType;
        opp[0].Approval_status__c='Approved - Pre-Win Gate';
        opp[0].stagename ='Negotiating';
        opp[0].Must_Go_To_OMEB__c = true;
        opp[0].Tender_Submission_Format__c = 'No Ocean Tender';
        update opp;
        
        Product2 prod= [Select id, oipc_code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
        prod.Include_in_OMEB_Approvals__c= true;
        update prod; 
        Opportunity_Product__c oli1= [Select id,quantity__c from Opportunity_Product__c where opportunityid__c =:opp[0].id limit 1];
        oli1.quantity__c = 20;
        update oli1;
        try{
            Opportunity_Product__c Oli = New Opportunity_Product__c();
            Oli.OpportunityId__c = opp[0].id;
            Oli.Quantity__c = 1;
            oli.Product2ID__c= prod.id;
            Oli.UnitPrice__c = 1;
			Oli.Product_Revenue_Per_Unit__c = 1;
            oli.Opt_Out_Auto_Quantity_Scheduling__c = false;
            Oli.Tender_Target__c = 1;
            //oli.Country__c = countryId;
            //oli.Trade_Route__c = tradeRouteId;
            insert oli;
        }catch(Exception ex){
            
        }
        Opportunity_Product__c oli2= [Select id,quantity__c from Opportunity_Product__c where opportunityid__c =:opp[0].id limit 1];
        update oli2;
        
        Test.stopTest();
    }
    
    static testmethod void testcheckProductsForOmeb(){
        
        TriggerExecutionController.skipAllTriggers(true);
        /*List<Opportunity_Product__c> prodList  = [SELECT Id, Name, Quantity__c FROM Opportunity_Product__c];
System.debug('Prod Count  >> '+prodList.size());
System.debug('Prod List >> '+prodList); */
        Id oppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Supply Chain Services').getRecordTypeId();
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,Must_Go_To_OMEB__c,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,Approval_Required__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,Approval_status__c,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,Requires_IT_Integration__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
        /*List<Opportunity_Product__c> prodList  = [SELECT Id, Name, Quantity__c FROM Opportunity_Product__c WHERE OpportunityId__c =: opp[0].Id];
System.debug('Prod Count  >> '+prodList.size());
System.debug('Prod List >> '+prodList);*/
        opp[0].recordtypeid =oppRecordType;
        // opp[0].Requires_IT_Integration__c ='Yes, I am sure this is required basis my discussion with customer';
        opp[0].Approval_status__c='';
        //opp[0].stagename ='Qualifying ';
        opp[0].Must_Go_To_OMEB__c = true;
        //opp[0].Products_for_Approval__c = 'SCM2';
        update opp;
        
        Product2 prod= [Select id, oipc_code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
        prod.Include_in_OMEB_Approvals__c= true;
        prod.family=System.Label.Warehousing_and_Fulfillment_family; //SFSE-11753
        prod.Family_Code__c='Warehousing_and_Fulfillment'; //10522
        prod.OIPC_Code__c = 'P-P0-dwh';
        update prod; 
        
        TriggerExecutionController.skipAllTriggers(false);
        Geography__c recGeography = new Geography__c();
        recGeography.Name = 'India';
        recGeography.Active__c = true;
        recGeography.GEO_Code__c = 'IN12';
        recGeography.GEO_ID__c = '10Z2W9Zkjh3q4a12';
        recGeography.Is_Port__c = true;
        recGeography.Type_Of_Location__c = 'Country';
        insert recGeography;
        
        Geography__c recGeography1 = new Geography__c();
        recGeography1.Name = 'US';
        recGeography1.Active__c = true;
        recGeography1.GEO_Code__c = 'IN12';
        recGeography1.GEO_ID__c = '10Z2W9Zkjh12';
        recGeography1.Is_Port__c = true;
        recGeography1.Type_Of_Location__c = 'Country';
        insert recGeography1;
        
        Opportunity_Product__c oli1= [Select id,quantity__c,Product2ID__c,Country__c from Opportunity_Product__c where opportunityid__c =:opp[0].id limit 1];
        oli1.Product2ID__c= prod.id;
        //oli1.quantity__c = 20;
        oli1.Amend_Gross_Profit_per_unit__c =10;
        oli1.Country__c = recGeography.id;
        oli1.Opt_Out_Auto_Quantity_Scheduling__c =true;
        oli1.Exclude_from_OMEB__c = false;
        TriggerExecutionController.skipAllTriggers(true); 
        update oli1;
        TriggerExecutionController.skipAllTriggers(false); 
        
        Opportunity_Product__c Oli = New Opportunity_Product__c();
        Oli.OpportunityId__c = opp[0].id;
        Oli.Quantity__c = 2;
        oli.Product2ID__c= prod.id;
        Oli.UnitPrice__c = 1;
        Oli.Product_Revenue_Per_Unit__c = 1;
        oli.Opt_Out_Auto_Quantity_Scheduling__c = false;
        Oli.Tender_Target__c = 1;
        oli.Country__c = recGeography1.id;
        oli.Exclude_from_OMEB__c = false;
        oli.Product_Revenue_Per_Unit__c=1;
        //oli.Trade_Route__c = tradeRouteId;
        TriggerExecutionController.skipAllTriggers(true); 
        insert oli;
        TriggerExecutionController.skipAllTriggers(false); 
        
        Test.startTest();
        
        List<Opportunity_Product__c> oli2= [Select id,quantity__c,Product2ID__c, OpportunityId__c from Opportunity_Product__c where opportunityid__c =:opp[0].id and Opt_Out_Auto_Quantity_Scheduling__c = true];
        delete oli2;
        
        Test.stopTest();
    }
    
    static testmethod void testlstChangedAnnualizedGrossProfit(){
        Test.startTest(); 
        Id oppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Supply Chain Services').getRecordTypeId();
        TriggerExecutionController.skipAllTriggers(true); 
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,Must_Go_To_OMEB__c,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,Approval_Required__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,Approval_status__c,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,Requires_IT_Integration__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
        
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Geography__c countryChina = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' and name = 'China'];
        Geography__c stateChina = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'State' and name = 'San Carlos'];
        
        Product2 prod= [Select id, oipc_code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
        prod.Include_in_OMEB_Approvals__c= true;
        prod.family=System.Label.Warehousing_and_Fulfillment_family; //SFSE-11753
        update prod; 
        
        Geography__c recGeography = new Geography__c();
        recGeography.Name = 'India';
        recGeography.Active__c = true;
        recGeography.GEO_Code__c = 'IN12';
        recGeography.GEO_ID__c = '10Z2W9Zkjh3q4a12';
        recGeography.Is_Port__c = true;
        recGeography.Type_Of_Location__c = 'Country';
        insert recGeography;
        
        Geography__c recGeography1 = new Geography__c();
        recGeography1.Name = 'US';
        recGeography1.Active__c = true;
        recGeography1.GEO_Code__c = 'IN12';
        recGeography1.GEO_ID__c = '10Z2W9Zkjh12';
        recGeography1.Is_Port__c = true;
        recGeography1.Type_Of_Location__c = 'Country';
        insert recGeography1;
        
        
        Opportunity_Product__c oli1= [Select id,quantity__c,Product2ID__c,Country__c,Amend_Gross_Profit_per_unit__c from Opportunity_Product__c where opportunityid__c =:opp[0].id  limit 1];
        oli1.Product2ID__c= prod.id;
        oli1.quantity__c = 20;
        oli1.Amend_Gross_Profit_per_unit__c =20;
        oli1.Country__c = recGeography.id;
        oli1.Opt_Out_Auto_Quantity_Scheduling__c =true;
        update oli1;
        
        
        Opportunity_Product__c oli3= [Select id,quantity__c,Product2ID__c,Country__c,Amend_Gross_Profit_per_unit__c from Opportunity_Product__c where opportunityid__c =:opp[0].id and Country__c =:recGeography.id limit 1];
        oli3.Amend_Gross_Profit_per_unit__c=5;
        update oli3;                           
        
        Opportunity_Product__c Oli = New Opportunity_Product__c();
        Oli.OpportunityId__c = opp[0].id;
        Oli.Quantity__c = 1;
        oli.Product2ID__c= prod.id;
        Oli.UnitPrice__c = 1;
        Oli.Product_Revenue_Per_Unit__c = 1;
        oli.Opt_Out_Auto_Quantity_Scheduling__c = false;
        Oli.Tender_Target__c = 1;
        oli.Country__c = countryChina.id;
        oli.Product_Revenue_Per_Unit__c=1;
        oli.Estimated_Footprint_Requirement_in_Sqm__c = 100;
        
        //oli.Trade_Route__c = tradeRouteId;
        insert oli;
        
        
        list<Opportunity_Product__c> oli2= [Select id,quantity__c,Product2ID__c from Opportunity_Product__c where opportunityid__c =:opp[0].id ];
        delete oli2;
        Test.stopTest();
    }
    
    
    /*static testmethod void testoceanPorducts(){
Test.startTest();
Id oppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Supply Chain Services').getRecordTypeId();
List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,Must_Go_To_OMEB__c,
Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,Approval_Required__c,
First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,Approval_status__c,
Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,Requires_IT_Integration__c,
Expected_Handling_Rounds__c, Pricebook2Id
FROM Opportunity  limit 1 ];


Product2 prod= [Select id, oipc_code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
prod.Include_in_OMEB_Approvals__c= true;
prod.family='Ocean';
update prod; 

Geography__c recGeography = new Geography__c();
recGeography.Name = 'India';
recGeography.Active__c = true;
recGeography.GEO_Code__c = 'IN12';
recGeography.GEO_ID__c = '10Z2W9Zkjh3q4a12';
recGeography.Is_Port__c = true;
recGeography.Type_Of_Location__c = 'Country';
insert recGeography;


Opportunity_Product__c Oli = New Opportunity_Product__c();
Oli.OpportunityId__c = opp[0].id;
Oli.Quantity__c = 1;
oli.Product2ID__c= prod.id;
Oli.UnitPrice__c = 1;
oli.Opt_Out_Auto_Quantity_Scheduling__c = false;
Oli.Tender_Target__c = 1;
oli.Country__c = recGeography.id;
//oli.Trade_Route__c = tradeRouteId;
insert oli;


Opportunity_Product__c oli1= [Select id,quantity__c,Product2ID__c,Country__c,Amend_Gross_Profit_per_unit__c,Tender_Target__c,opportunityid__r.Must_Go_To_OMEB__c,opportunityid__c,UnitPrice__c 
from Opportunity_Product__c where opportunityid__c =:opp[0].id and Country__c =: recGeography.id limit 1];
oli1.quantity__c = 20;
//oli1.Amend_Gross_Profit_per_unit__c =20;
oli1.Tender_Target__c=23;
update oli1;

try{
Opportunity_Product__c oliclone = oli1.clone();
insert oliclone;
}catch(Exception ex){
System.debug('Ocean Error Message >> '+ex.getMessage()); 
}   


Test.stopTest();
}*/
    
    static testmethod void testoceanoppProd(){
        Test.startTest();
        Id oppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Quarterly NAC & BCO Deals').getRecordTypeId();
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,Must_Go_To_OMEB__c,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,Approval_Required__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,Approval_status__c,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,Requires_IT_Integration__c, 
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
        opp[0].recordtypeId= System.Label.QuarterlyDealsRecordTypeId;
        update opp;
        
        
        Product2 prod= [Select id, OIPC_Code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
        prod.Include_in_OMEB_Approvals__c= true;
        prod.Family= Label.Ocean_Product;
       // prod.OIPC_Code__c = oipc_code[0];
        update prod; 
        System.debug('TESTING '+prod.OIPC_Code__c);
      //  System.debug('TESTING '+oipc_code[0]);
        
        List<Trade_Route__c> lstTradeRoute = TestBusinessHelper.createTradeRoutes(new List<String>{BrandUtilities.MCC}, 1,true);
        //insert lstTradeRoute;
        Id tradeRouteId = lstTradeRoute[0].Id;
        Opportunity_Product__c Oli = New Opportunity_Product__c();
        Oli.OpportunityId__c = opp[0].id;
        Oli.Quantity__c = 1;
        oli.Product2ID__c= prod.id;
        Oli.UnitPrice__c = 1;
        Oli.Product_Revenue_Per_Unit__c = 1;
        oli.Opt_Out_Auto_Quantity_Scheduling__c = false;
        Oli.Tender_Target__c = 1;
        OlI.Trade_Route__c = 
        //oli.Country__c = recGeography.id;
        oli.Trade_Route__c = tradeRouteId;
        insert oli;
        System.debug('TESTING '+oli.OIPC_Product_Code__c);
        
        OpportunityProductUtilities.createCorridorGuidance(new list<Opportunity_Product__c>{oli},new Map<Id,Opportunity>{opp[0].id=>opp[0]});
        
        
        Test.stopTest();
    }
    
    static testmethod void testcheckProductsForOmeb2(){
        TriggerExecutionController.skipAllTriggers(true);
        /*List<Opportunity_Product__c> prodList  = [SELECT Id, Name, Quantity__c FROM Opportunity_Product__c];
System.debug('Prod Count  >> '+prodList.size());
System.debug('Prod List >> '+prodList); */
        Id oppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Supply Chain Services').getRecordTypeId();
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,Must_Go_To_OMEB__c,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,Approval_Required__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,Approval_status__c,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,Requires_IT_Integration__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
        List<Opportunity_Product__c> prodList  = [SELECT Id, Name, Quantity__c FROM Opportunity_Product__c WHERE OpportunityId__c =: opp[0].Id];
        System.debug('Prod Count  >> '+prodList.size());
        System.debug('Prod List >> '+prodList);
        opp[0].recordtypeid =oppRecordType;
        // opp[0].Requires_IT_Integration__c ='Yes, I am sure this is required basis my discussion with customer';
        opp[0].Approval_status__c='';
        //opp[0].stagename ='Qualifying ';
        opp[0].Must_Go_To_OMEB__c = false;
        //opp[0].Products_for_Approval__c = 'SCM2';
        
        update opp;
        
        
        Product2 prod= [Select id, Name, family, oipc_code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
        prod.Include_in_OMEB_Approvals__c = true;
        prod.family='Lead Logistics';
        prod.Name = 'Supply Chain Orchestrator';
        update prod; 
        
        TriggerExecutionController.skipAllTriggers(false);
        Geography__c recGeography = new Geography__c();
        recGeography.Name = 'India';
        recGeography.Active__c = true;
        recGeography.GEO_Code__c = 'IN12';
        recGeography.GEO_ID__c = '10Z2W9Zkjh3q4a12';
        recGeography.Is_Port__c = true;
        recGeography.Type_Of_Location__c = 'Country';
        insert recGeography;
        
        Geography__c recGeography1 = new Geography__c();
        recGeography1.Name = 'US';
        recGeography1.Active__c = true;
        recGeography1.GEO_Code__c = 'IN12';
        recGeography1.GEO_ID__c = '10Z2W9Zkjh12';
        recGeography1.Is_Port__c = true;
        recGeography1.Type_Of_Location__c = 'Country';
        insert recGeography1;
        
        Opportunity_Product__c oli1= [Select id,quantity__c,Exclude_from_OMEB__c,Product2ID__c,Country__c from Opportunity_Product__c where opportunityid__c =:opp[0].id limit 1];
        oli1.Product2ID__c= prod.id;
        oli1.quantity__c = 20;
        oli1.Amend_Gross_Profit_per_unit__c =10;
        oli1.Country__c = recGeography.id;
        oli1.Opt_Out_Auto_Quantity_Scheduling__c =true;
        oli1.Exclude_from_OMEB__c = false;
        TriggerExecutionController.skipAllTriggers(true); 
        update oli1;
        TriggerExecutionController.skipAllTriggers(false); 
        
        Test.startTest();
        Opportunity_Product__c Oli = New Opportunity_Product__c();
        Oli.OpportunityId__c = opp[0].id;
        Oli.Quantity__c = 2;
        oli.Product2ID__c= prod.id;
        Oli.UnitPrice__c = 1;
        oli.Opt_Out_Auto_Quantity_Scheduling__c = false;
        Oli.Tender_Target__c = 1;
        oli.Product_Revenue_Per_Unit__c=1;
        //oli.Nominated_Quantity__c = 1;
        oli.Country__c = recGeography1.id;
        oli.Exclude_from_OMEB__c = false;
        //oli.Trade_Route__c = tradeRouteId;
        // TriggerExecutionController.skipAllTriggers(true); 
        insert oli;
        //TriggerExecutionController.skipAllTriggers(false); 
        
        List<Opportunity_Product__c> oli2= [Select id,quantity__c,Product2ID__c, OpportunityId__c from Opportunity_Product__c where opportunityid__c =:opp[0].id and Opt_Out_Auto_Quantity_Scheduling__c = true];
        delete oli2;
        Test.stopTest();
    }
    static testmethod void testcorridor(){
        TriggerExecutionController.skipAllTriggers(true);
        
        Id oppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Quarterly NAC & BCO Deals').getRecordTypeId(); 
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,Must_Go_To_OMEB__c,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,Approval_Required__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,Approval_status__c,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,Requires_IT_Integration__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ]  ;  
        opp[0].recordtypeid = oppRecordType;
        Update opp;
        Product2 prod= [Select id, oipc_code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
        prod.Include_in_OMEB_Approvals__c= true;
        prod.family=Label.Ocean_Product;
       // prod.OIPC_Code__c = oipc_code[0];
        
        update prod; 
        
        Geography__c recGeography = new Geography__c();
        recGeography.Name = 'India';
        recGeography.Active__c = true;
        recGeography.GEO_Code__c = 'IN12';
        recGeography.GEO_ID__c = '10Z2W9Zkjh3q4a12';
        recGeography.Is_Port__c = true;
        recGeography.Type_Of_Location__c = 'Country';
        insert recGeography;
        
        List<Opportunity_Product__c> oli1= [Select id,quantity__c,Product2ID__c,Country__c,Opportunity_Product__c.OpportunityId__c,Opportunity_Product__c.Product2ID__r.Family from Opportunity_Product__c where opportunityid__c =:opp[0].id limit 1];
        oli1[0].Product2ID__c= prod.id;
        oli1[0].quantity__c = 20;
        oli1[0].Amend_Gross_Profit_per_unit__c =100000;
        oli1[0].Opt_Out_Auto_Quantity_Scheduling__c = false;
        update oli1;
        
        /*Opportunity_Product__c Oli = New Opportunity_Product__c();
        Oli.OpportunityId__c = opp[0].id;
        Oli.Quantity__c = 2;
        Oli.Product2ID__c= prod.id;
        Oli.UnitPrice__c = 1;
        Oli.Opt_Out_Auto_Quantity_Scheduling__c = false;
        Oli.Tender_Target__c = 1;
        //oli.Nominated_Quantity__c = 1;
        Oli.Country__c = recGeography.id; 
        insert Oli;
        List<Opportunity_Product__c> oli1= [Select id,quantity__c,Product2ID__c,Country__c,OIPC_Product_Code__c,Opportunity_Product__c.OpportunityId__c,Opportunity_Product__c.Product2ID__r.Family from Opportunity_Product__c where opportunityid__c =:opp[0].id limit 1];
        */
        TriggerExecutionController.skipAllTriggers(false);
        OpportunityProductUtilities.createCorridorGuidance(oli1,new Map<id,Opportunity>{opp[0].id => opp[0]});
        
    }
    static testmethod void testcheckProductsForOmeb3(){
        Id currentApproverId = [SELECT Id FROM user WHERE IsActive = true AND Profile.Name = 'Sales' LIMIT 1][0].Id;
        Id EscalationApproverId = [SELECT Id FROM user WHERE IsActive = true AND Profile.Name = 'Sales' LIMIT 1 OFFSET 1][0].Id;
        String clientRecordTypeID = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Client Account').getRecordTypeId();
        System.debug('Account Record Type >> '+clientRecordTypeID);
        
        Account acc = New Account();
        acc.Name = 'Test Acc';
        acc.RecordTypeId = clientRecordTypeID;
        acc.Vertical__c = 'Lifestyle';
        //acc.Active__c = true;
        acc.Non_Profit_Customer__c = 'No';
        insert acc;
        
        Geography__c country = New Geography__c();
        country.Name = 'United Kingdom';
        country.Active__c = true;
        country.Type_Of_Location__c = 'Country';
        insert country; 
        
        String scRecordTypeID = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Supply Chain Services').getRecordTypeId();
        Opportunity opp = New Opportunity();
        Opp.Name = 'Test Opty';
        opp.RecordTypeId = scRecordTypeID;
        opp.AccountId = acc.Id;
        opp.Type = 'Acquistion';
        opp.CloseDate = System.today()+30;
        opp.StageName = 'Identifying';
        opp.Must_Go_To_OMEB__c = true;
        opp.Approval_Status__c = '';
        
        opp.Estimated_Agreement_Duration__c = 36;
        opp.Requires_IT_Integration__c = 'Yes, I am sure this is required basis my discussion with customer';
        opp.Liner_Brand__c = 'Maersk Line';
        insert opp;
        
        System.debug('opty Id >> '+opp.Id);
        System.debug('Approval >> '+opp.Products_for_Approval__c);
        
        Product2 prod = New Product2();
        prod.Name = 'Supply Chain Management';
        prod.Family = 'Lead Logistics';
        prod.Family_Code__c = 'lead_logistics';
        prod.OIPC_Code__c = 'P-P0-1ggy';
        insert prod;
        
        Test.startTest();
        Opportunity_Product__c optyProduct = New Opportunity_Product__c();
        optyProduct.Name = opp.Name + '-' + prod.Name;
        optyProduct.OpportunityId__c = opp.Id;
        optyProduct.Product2ID__c = prod.Id;
        optyProduct.Country__c = country.Id;
        optyProduct.Quantity__c = 500;
        optyProduct.Product_Revenue_Per_Unit__c=1;
        optyProduct.UnitPrice__c = 1;
        insert optyProduct;
        System.debug('Approval >> '+opp.Products_for_Approval__c);
        Approval_Process__c ap = New Approval_Process__c();
        ap.Name = 'Pursuit Gate Products';
        ap.Sub_Gate__c = 'Product';
        ap.Active__c = true;
        ap.Gate__c = 'Pursuit';
        ap.Order__c = 4;
        ap.SLA__c = 4;
        insert ap;
        
        opp.Products_for_Approval__c = 'SCM2';
        opp.Approval_status__c = 'Approved - Pursuit Gate';
        opp.StageName = 'Qualifying';
        update opp;
        
        Approval_Process_Escalation_Matrix__c ape = New Approval_Process_Escalation_Matrix__c();
        ape.Approval_Process_Name__c = ap.Id;
        ape.Step_Name__c = 'Pursuit Products-LL-(United Kingdom, Lifestyle)';
        ape.Area_code__c = 'UKI';
        ape.Country__c = country.Id;
        ape.Current_owner__c = currentApproverId;
        ape.Escalation_owner__c = EscalationApproverId;
        ape.Product_for_approval__c = '4PL,SCM';
        ape.Gate_Name__c = 'Pursuit';
        ape.Region__c = 'Europe Region';
        ape.Vertical__c = 'LifeStyle';
        insert ape;
        
        Opportunity_Product__c oli2 = [Select id,quantity__c,Product2ID__c,OpportunityId__c from Opportunity_Product__c where opportunityid__c =:opp.id AND Id=: optyProduct.Id LIMIT 1];
        System.debug('Opty Product >> '+oli2);
        List<Approval_History__c> aphList = New List<Approval_History__c>();
        Approval_History__c ahOne = New Approval_History__c();
        ahOne.Step_Name__c  = 'Pursuit Products-LL-(United Kingdom, Lifestyle)';
        ahOne.Approval_Step__c  = ape.Id;
        ahOne.Status__c = 'Pending';
        ahOne.TargetObjectId__c = opp.Id;
        ahOne.Opportunity_Product__c = oli2.Id;
        ahOne.Approved_By__c = currentApproverId;
        ahOne.Assigned_To__c = currentApproverId;
        aphList.add(ahOne);
        
        Approval_History__c ahTwo = New Approval_History__c();
        ahTwo.Step_Name__c  = 'Pursuit Products-LL-(United Kingdom, Lifestyle)';
        ahTwo.Approval_Step__c  = ape.Id;
        ahTwo.Status__c = 'Pending';
        ahTwo.TargetObjectId__c = opp.Id;
        ahTwo.Opportunity_Product__c = oli2.Id+'_D';
        ahTwo.Approved_By__c = currentApproverId;
        ahTwo.Assigned_To__c = currentApproverId;
        aphList.add(ahTwo);
        insert aphList;
        
        delete oli2;
        Test.stopTest();
    }
    
    static testmethod void testCheckhassolution(){
        Test.startTest();
        
        Product2  P = new Product2();
        p.Name = 'Test';
        p.Family = 'Ocean';
        p.Is_Product_Solution__c = false;
        insert p;
        //List<Product2> prodlist = [Select id,name from Product2 where Is_Product_Solution__c = false];
        List<Opportunity> opp = [Select id,name from Opportunity];
        List<Opportunity_product__c> oli = [Select id,name from Opportunity_product__c where OpportunityId__c =:opp[0].id and Product2ID__c = :P.Id];
        Test.StopTest();
    }
    static testmethod void testcheckProductsForOmeb4(){
         TriggerExecutionController.skipAllTriggers(true);
        Opportunity supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c,Last_Shipment_Date__c,First_Shipment_Date__c,Estimated_Agreement_Duration__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, CreatedById
                                       FROM Opportunity limit 1];
        	supplyChainOppty.Last_Shipment_Date__c = System.today() + 180;
            supplyChainOppty.First_Shipment_Date__c = System.today() + 60;
            supplyChainOppty.Estimated_Agreement_Duration__c = 30;
        Update supplyChainOppty;
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Geography__c countryChina = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' and name = 'China'];
        Geography__c stateSC = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'State' and name = 'San Carlos'];
        
        Product2 productContractLogistics = TestBusinessHelper.createProduct('Contract Logistics', false);
        productContractLogistics.Id = null;
        productContractLogistics.Family_Code__c = 'contract_logistics';
        productContractLogistics.OIPC_Code__c = 'P-P0-dwh';
        productContractLogistics.Include_in_OMEB_Approvals__c = true;
        insert productContractLogistics;
         TriggerExecutionController.skipAllTriggers(false);
        
        Test.startTest();
        Set<Id> productIds = new Set<Id>();
        for(Product2 prod : [SELECT Id, Name FROM Product2 WHERE OIPC_Code__c IN ('P-P0-dwh')]){
            productIds.add(prod.Id);
        }

        //System.runAs(new User(Id = salesUserId)){
            
           List<Opportunity_Product__c> optyList=TestBusinessHelper.createOpportunityLineItemCustoms(supplyChainOppty, productIds, tradeRoute, countryChina, stateSC, true);
            optyList[0].UnitPrice__c = 1000;
            optyList[0].Quantity__c = 200000;
            optyList[0].Discount__c = 20;
            optyList[0].L_S_Product__c = true;
            optyList[0].Exclude_From_OMEB__c = false;
            optyList[0].Country__c = countryChina.id;
            TriggerExecutionController.skipAllTriggers(true);
            Update optyList;
            TriggerExecutionController.skipAllTriggers(false);
            
    }
    
    static testmethod void testRevenueSchedule(){
        Test.startTest();
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
        
       
       List<Opportunity_Product_Schedule__c> OppProductSch = [Select Id,Opportunity_Product__r.Product2ID__r.Name,Schedule_Date__c,Revenue__c,Quantity__c,Description__c,Schedule_Revenue__c from Opportunity_Product_Schedule__c where  Opportunity_Product__c =:oli[0].id order by Schedule_Date__c ];
  		Assert.areEqual(oli[0].Product_Revenue_Per_Unit__c,(OppProductSch[0].Schedule_Revenue__c/OppProductSch[0].Quantity__c));
       Test.stopTest();  
    }
}