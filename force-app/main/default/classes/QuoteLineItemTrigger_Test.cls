/**
* Revision  Ref Number      Date          Owner                          Description
* --------  ----------      -----------   -------------------            -----------
* 1.0       RQ-012785       30/12/2019    sidhartha                      Code created
* 2.0       RQ-013342       31/03/2020    Amritesh                       Added timeout
 * 3.0       SFSE-4548       15/09/2020    manjunath@maersk               Test class fix
 * 4.0       SFSE- 5691      12/04/2021    Neha@TCS                       replaced the product family from Insurance to Customs Services & Insurance
 * 5.0       SPI-100         15/06/2022    Ronnie@SF                      Removed brand hardcoding
 * 6.0		SFSE-11753		 03-11-23	   Ritika@Maersk				  To change the hard coded product family references to custom label
*/
@isTest()
public class QuoteLineItemTrigger_Test {
    @testSetup static void setup() {
        
        Geography__c geo = new Geography__c();
        geo.Name = 'India';
        geo.Type_Of_Location__c='Country';
        geo.GEO_ID__c = '123456789';
        geo.GEO_Code__c = 'ITCDN';
        insert geo;
        
        Geography__c geo1 = new Geography__c();
        geo1.Name = 'United Kingdom';
        geo1.Type_Of_Location__c='Country';
        geo1.GEO_ID__c = '9999999999999';
        geo1.GEO_Code__c = 'FRSSY';
        insert geo1;
        
        Account clientAccount = new Account ();        
        clientAccount.Name = 'Test Class Client Account';
        clientAccount.Type = 'BCO' ;
        clientAccount.SCV_Code__c = '10000045402';
        clientAccount.SCV_Status__c = 'Active';
        clientAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client_Account').getRecordTypeId();
        clientAccount.BillingCity = 'London';
        clientAccount.BillingStreet = 'test street 123';
        clientAccount.Represents_Concern__c= true;
        insert clientAccount;  
        
        Opportunity recOpportunity = new Opportunity();        
        recOpportunity.Name =  'Test opportunity';
        recOpportunity.AccountId = clientAccount.Id;
        recOpportunity.CloseDate = date.today() + 10;
        recOpportunity.StageName = 'Identifying';
        recOpportunity.Cargo_Type__c = 'DRY';
        recOpportunity.Primary_Contact__c = NULL;
        recOpportunity.Type = 'Transactional';
        recOpportunity.Liner_Brand__c = BrandUtilities.MAERSKLINE;    
        recOpportunity.First_Shipment_Date__c = date.today() + 20;
        recOpportunity.Last_Shipment_Date__c = date.today() + 30;
        recOpportunity.Opportunity_contains_Dangerous_Goods__c = 'No';
         recOpportunity.Expected_Handling_Rounds__c = 2;
        insert recOpportunity;
        
       product2 testP = new product2();
        testP.OIPC_Code__c = Label.Product_Maersk_Cargo_Insurance_OIPC_Code;
        testP.Name = 'Test';
        testp.family  = System.Label.Custom_Services_and_Insurance_Family_Name; //SFSE-11753
        testp.IsActive = true;
        insert testp;
               
        PriceBookEntry pbEntry = [select id,Pricebook2Id from PriceBookEntry where Product2Id =:testP.Id];   
        pbEntry.IsActive = true;
        update pbEntry;
     

        List<Quote> lstQuote = DataGeneratorHelper2_Test.createQuote(1, recOpportunity.Id); //
        Quote objQuote = lstQuote[0];
        objQuote.Pricebook2Id = pbEntry.Pricebook2Id;
        objQuote.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('PAYG_Insurance').getRecordTypeId();
        update objQuote;
        
        Reference_Data__c objRefData = new Reference_Data__c(Name = '004601', Active__c=true, Commodity_Code__c='004601');
        insert objRefData;
        QuoteLineItem QLI = new QuoteLineItem(
            QuoteId=objQuote.Id, 
            Quantity = 1,
            PriceBookEntryId = pbEntry.Id,
            UnitPrice = 1,
            Origin__c = geo.Id,
            Destination__c = geo1.Id,
            Agreement_Status__c = 'Draft Quote',
            Insurance_Commodity__c = objRefData.Id,
            Agreement_Id__c = '123456',
            Agreement_Start_Date__c=Date.today(),
            Agreement_End_Date__c=Date.today().addDays(30)
        );
        insert QLI;
        system.debug('@@@@@@@ ' + limits.getQueries());
    }
    
    static testMethod void Test_QuoteLineItemTrigger_SubmitForQuotation() {
        Reference_Data__c refData = [select Id, Name from Reference_Data__c limit 1];
        Map<Id,QuoteLineItem> mapQuoteLineItemCommodity = new Map<Id,QuoteLineItem>([SELECT Id,Agreement_Id__c, CreatedBy.Maersk_User_Id__c, Destination_Geo_Code__c, Origin_Geo_Code__c, Quote.Price_Owner_Code__c, Quote.Carrier_Code__c, Insurance_Commodity__r.Name FROM QuoteLineItem Limit 1]);
        List<Id> mapKeys = new List<Id>(mapQuoteLineItemCommodity.keySet());
        mapQuoteLineItemCommodity.get(mapKeys[0]).Agreement_Status__c = 'Submit for Quotation';
        update mapQuoteLineItemCommodity.values();
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new CargoInsuranceStatusQueueableMock(CargoInsuranceStatusQueueableMock.request_mode.authToken)); 
        CargoInsuranceStatusQueueable apiCallQueue = new CargoInsuranceStatusQueueable(mapQuoteLineItemCommodity);
        apiCallQueue.execute(null);
        Test.stopTest();        
    }
    
    static testMethod void Test_QuoteLineItemTrigger_SubmitForQuotation_positivetive() {
        Reference_Data__c refData = [select Id, Name from Reference_Data__c limit 1];
        Map<Id,QuoteLineItem> mapQuoteLineItemCommodity = new Map<Id,QuoteLineItem>([SELECT Id,Agreement_Id__c, CreatedBy.Maersk_User_Id__c, Destination_Geo_Code__c, Origin_Geo_Code__c, Quote.Price_Owner_Code__c, Quote.Carrier_Code__c, Insurance_Commodity__r.Name FROM QuoteLineItem Limit 1]);
        List<Id> mapKeys = new List<Id>(mapQuoteLineItemCommodity.keySet());
        mapQuoteLineItemCommodity.get(mapKeys[0]).Agreement_Status__c = 'Submit for Quotation';
        update mapQuoteLineItemCommodity.values();
        Test.setMock(HttpCalloutMock.class, new CargoInsuranceStatusQueueableMock(CargoInsuranceStatusQueueableMock.request_mode.authToken)); 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CargoInsuranceStatusQueueableMock(CargoInsuranceStatusQueueableMock.request_mode.priceOwnerchk)); 
        CargoInsuranceStatusQueueable apiCallQueue = new CargoInsuranceStatusQueueable(mapQuoteLineItemCommodity);
        apiCallQueue.execute(null);
        QuoteLineItem objQuoteLI = [SELECT Id, Agreement_Status__c FROM QuoteLineItem LIMIT 1];
        system.debug('Agreement_Status__c' + objQuoteLI.Agreement_Status__c); 
        Test.stopTest();       
    }
    
    static testMethod void Test_QuoteLineItemTrigger_SubmitForQuotation_negative() {
        Reference_Data__c refData = [select Id, Name from Reference_Data__c limit 1];
        Map<Id,QuoteLineItem> mapQuoteLineItemCommodity = new Map<Id,QuoteLineItem>([SELECT Id,Agreement_Id__c, CreatedBy.Maersk_User_Id__c, Destination_Geo_Code__c, Origin_Geo_Code__c, Quote.Price_Owner_Code__c, Quote.Carrier_Code__c, Insurance_Commodity__r.Name FROM QuoteLineItem Limit 1]);
        List<Id> mapKeys = new List<Id>(mapQuoteLineItemCommodity.keySet());
        mapQuoteLineItemCommodity.get(mapKeys[0]).Agreement_Status__c = 'Submit for Quotation';
        update mapQuoteLineItemCommodity.values();
        Test.setMock(HttpCalloutMock.class, new CargoInsuranceStatusQueueableMock(CargoInsuranceStatusQueueableMock.request_mode.authToken)); 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CargoInsuranceStatusQueueableMock(CargoInsuranceStatusQueueableMock.request_mode.priceOwnerchkng)); 
        CargoInsuranceStatusQueueable apiCallQueue = new CargoInsuranceStatusQueueable(mapQuoteLineItemCommodity);
        apiCallQueue.execute(null);
        Test.stopTest();        
    }
    
    static testMethod void Test_QuoteLineItemTrigger_GetInsurance() {
        Map<Id,QuoteLineItem> mapQuoteLineItemCommodity = new Map<Id,QuoteLineItem>([SELECT Id,Agreement_Id__c, CreatedBy.Maersk_User_Id__c, Destination_Geo_Code__c, Origin_Geo_Code__c, Quote.Price_Owner_Code__c, Quote.Carrier_Code__c, Insurance_Commodity__r.Name FROM QuoteLineItem Limit 1]);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GetInsuranceAPIMockCallout(GetInsuranceAPIMockCallout.request_mode.authToken)); 
        GetInsuranceAPIQueueable apiCallQueue = new GetInsuranceAPIQueueable(mapQuoteLineItemCommodity);
        apiCallQueue.execute(null);
        Test.stopTest();        
    }
    
    static testMethod void Test_QuoteLineItemTrigger_GetInsuranceQuoteId() {
        Map<Id,QuoteLineItem> mapQuoteLineItemCommodity = new Map<Id,QuoteLineItem>([SELECT Id,Agreement_Id__c, CreatedBy.Maersk_User_Id__c, Destination_Geo_Code__c, Origin_Geo_Code__c, Quote.Price_Owner_Code__c, Quote.Carrier_Code__c, Insurance_Commodity__r.Name FROM QuoteLineItem Limit 1]);
        Test.setMock(HttpCalloutMock.class, new GetInsuranceAPIMockCallout(GetInsuranceAPIMockCallout.request_mode.authToken)); 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GetInsuranceAPIMockCallout(GetInsuranceAPIMockCallout.request_mode.getInsurance)); 
        GetInsuranceAPIQueueable apiCallQueue = new GetInsuranceAPIQueueable(mapQuoteLineItemCommodity);
        apiCallQueue.execute(null);
        Test.stopTest();        
    }
    
    static testMethod void Test_InsuranceAPIUtility() {   
        Quote objQuote = [SELECT Id, OpportunityId FROM Quote LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new InsuranceAPIMockCallout(InsuranceAPIMockCallout.request_mode.idtoken)); 
        String idToken = '12345'; //InsuranceAPIUtility.getE2EInsuranceToken();
        AO_Services__mdt aOUrlDetails = InsuranceAPIUtility.getAOServicesMetadataValue('postInsuranceAgreements');
        if(Test.isRunningTest()) Test.setMock(HttpCalloutMock.class, new InsuranceAPIMockCallout(InsuranceAPIMockCallout.request_mode.agreements)); 
        String strBody = InsuranceAgreementsAPI.createRequestBody(objQuote.Id);
        HTTPResponse httpres = InsuranceAPIUtility.sendRequest(aOUrlDetails.End_point_URL__c, 'POST', strBody , aOUrlDetails.Timeout__c, new Map<String,String>{'Authorization'=>idToken});     
        InsuranceAPIUtility.getQuoteLineItems(objQuote.Id);       
        InsuranceAPIUtility.getErrorCodeMsg();        
        Test.stopTest();  
        System.assertEquals(201, httpres.getStatusCode());
    }
}