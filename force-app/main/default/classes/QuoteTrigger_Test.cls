/**
* Purpose : Test class for QuoteTrigger, QuoteTriggerHandler, QuoteRecordSelector, InsuranceAgreementsAPI, InsuranceAPIUtility classes.
*    
* Revision  Ref Number      Date          Owner                          Description
* --------  ----------      -----------   -------------------            -----------
* 1.0       RQ-012787       27/12/2019    Amritesh                       Class created
* 2.0       RQ-013127       26-Mar-2020   manjunath@maersk               Test class fix - due to introduction of new validation rules
* 3.0       RQ-013342       31/03/2020    Amritesh                       Added timeout
* 4.0       SFSE-4548       15-Sep-2020   manjunath@maersk               Test class fix
* 5.0       SFSE-5691       12-Apr-2021   Neha@TCS                       replaced the product family from Insurance to Customs Services & Insurance
* 6.0       SPI-100         15-Jun-2022   Ronnie@SF                      Removed brand hardcoding
* 7.0		SFSE-11753		03-11-23	  Ritika@Maersk				     To change the hard coded product family references to custom label
*/ 

@isTest
public class QuoteTrigger_Test {
    
    @testSetup static void setup() {
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
        recOpportunity.Expected_Handling_Rounds__c=2;
        insert recOpportunity;   
     
        Id StdPricebook = Test.getStandardPricebookId();
        String family  = System.Label.Custom_Services_and_Insurance_Family_Name; //SFSE-11753
        List<Product2> pdt1 = DataGeneratorHelper1_Test.createProduct2( 1,'A','D',family); // create a product //SFSE-11753
        pdt1[0].OIPC_Code__c = Label.Product_Maersk_Cargo_Insurance_OIPC_Code;
        update pdt1;
        PriceBookEntry pbEntry = [select id,Pricebook2Id from PriceBookEntry where Product2Id =:pdt1[0].Id];   
        pbEntry.IsActive = true;
        update pbEntry;
        List<Quote> lstQuote = DataGeneratorHelper2_Test.createQuote(1, recOpportunity.Id); //create quote
        Quote objQuote = lstQuote[0];
        objQuote.Pricebook2Id = pbEntry.Pricebook2Id;
        objQuote.Status = 'Draft';
        objQuote.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('PAYG_Insurance').getRecordTypeId();
        update objQuote; //update quote to insurance type
        Reference_Data__c objRefData = new Reference_Data__c(Active__c=true, Commodity_Code__c='123456');
        insert objRefData; //insert reference data
        
        Map<String,String> mapGeo = new Map<String,String>{'India'=>'Country', 'United Kingdom'=>'Country'};
        List<Geography__c> lstGeo = DataGeneratorHelper1_Test.createGeography(mapGeo); //create geography
        QuoteLineItem QLI = new QuoteLineItem(
            QuoteId=objQuote.Id, 
            Quantity = 1,
            PriceBookEntryId = pbEntry.Id,
            UnitPrice = 1,
            Agreement_Status__c = 'Submit for Quotation',
            Insurance_Commodity__c = objRefData.Id,
            Origin__c = lstGeo[0].Id, 
            Destination__c = lstGeo[1].Id
        );
        insert QLI;  //create quote line item
        QLI.Agreement_Status__c = 'Quote Received';
        QLI.Agreement_Id__c = '123456';
        QLI.Agreement_Start_Date__c = Date.today();
        QLI.Agreement_End_Date__c = Date.today().addDays(30);
        update QLI;
        QLI.Agreement_Status__c = 'Accepted by Customer';
        update QLI;
    }
    
    @isTest
    static void test_QuoteTrigger() {   
        Quote objQuote = [SELECT Id, OpportunityId FROM Quote LIMIT 1];
        objQuote.Status = 'Closed';
        objQuote.Reason_for_Closure__c = 'Approved by Customer'; 
        update objQuote;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new InsuranceAPIMockCallout(InsuranceAPIMockCallout.request_mode.idtoken));         
        InsuranceAgreementsAPI.ApiCalloutQueueable apiCallQueue = new InsuranceAgreementsAPI.ApiCalloutQueueable(new List<Quote>{objQuote});
        apiCallQueue.execute(null);
        Test.stopTest();        
        System.assertEquals('Success', apiCallQueue.lstQuoteUpdate[0].Agreement_Status__c);
    }
    
    @isTest
    static void test_InsuranceAPI_Fail() {   
        Quote objQuote = [SELECT Id, OpportunityId FROM Quote LIMIT 1];
        objQuote.Status = 'Closed';
        objQuote.Reason_for_Closure__c = 'Approved by Customer';   
        update objQuote;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new InsuranceAPIMockCallout(InsuranceAPIMockCallout.request_mode.idtoken));
        InsuranceAgreementsAPI.ApiCalloutQueueable apiCallQueue = new InsuranceAgreementsAPI.ApiCalloutQueueable(new List<Quote>{objQuote});
        System.enqueueJob(apiCallQueue);
        Test.stopTest();            
        //System.assertEquals('API Failure', [SELECT Agreement_Status__c FROM Quote WHERE Id=:objQuote.Id].Agreement_Status__c);
    }
    
	@isTest        
    static void test_InsuranceAPIUtility() {   
        Quote objQuote = [SELECT Id, OpportunityId FROM Quote LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new InsuranceAPIMockCallout(InsuranceAPIMockCallout.request_mode.idtoken)); 
        String idToken = '12345'; //InsuranceAPIUtility.getE2EInsuranceToken();
        AO_Services__mdt aOUrlDetails = InsuranceAPIUtility.getAOServicesMetadataValue('postInsuranceAgreements');
        if(Test.isRunningTest()) Test.setMock(HttpCalloutMock.class, new InsuranceAPIMockCallout(InsuranceAPIMockCallout.request_mode.agreements)); 
        String strBody = InsuranceAgreementsAPI.createRequestBody(objQuote.Id);
        HTTPResponse httpres = InsuranceAPIUtility.sendRequest(aOUrlDetails.End_point_URL__c, 'POST', strBody , aOUrlDetails.Timeout__c,new Map<String,String>{'Authorization'=>idToken});     
        InsuranceAPIUtility.getQuoteLineItems(objQuote.Id);       
        InsuranceAPIUtility.getErrorCodeMsg();
        Test.stopTest();  
        System.assertEquals(201, httpres.getStatusCode());
    }  
    
    @isTest
    static void test_InsuranceAPIUtility2() {   
        //Quote objQuote = [SELECT Id, OpportunityId FROM Quote LIMIT 1];
        QuoteLineItem qli = [select id,QuoteId, Agreement_Status__c from QuoteLineItem];// where QuoteId =: objQuote.Id];
        qli.Agreement_Status__c = 'Cancelled';
        update qli;        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new InsuranceAPIMockCallout(InsuranceAPIMockCallout.request_mode.idtoken)); 
        String idToken = '12345'; //InsuranceAPIUtility.getE2EInsuranceToken();
        AO_Services__mdt aOUrlDetails = InsuranceAPIUtility.getAOServicesMetadataValue('postInsuranceAgreements');
        if(Test.isRunningTest()) Test.setMock(HttpCalloutMock.class, new InsuranceAPIMockCallout(InsuranceAPIMockCallout.request_mode.agreements)); 
        String strBody = InsuranceAgreementsAPI.createRequestBody(qli.QuoteId);
        HTTPResponse httpres = InsuranceAPIUtility.sendRequest(aOUrlDetails.End_point_URL__c, 'POST', strBody , aOUrlDetails.Timeout__c, new Map<String,String>{'Authorization'=>idToken});     
        InsuranceAPIUtility.getQuoteLineItems(qli.QuoteId);       
        InsuranceAPIUtility.getErrorCodeMsg();
        Test.stopTest();  
        System.assertEquals(201, httpres.getStatusCode());
    }
    
    @isTest
    static void test_InsuranceAPIUtility3() {   
        //Quote objQuote = [SELECT Id, OpportunityId FROM Quote LIMIT 1];
        QuoteLineItem qli = [select id,QuoteId, Agreement_Status__c from QuoteLineItem where Agreement_Status__c != 'Cancelled' LIMIT 1];
        qli.Agreement_Status__c = 'Cancelled';
        update qli;        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new InsuranceAPIMockCallout(InsuranceAPIMockCallout.request_mode.idtoken));
        InsuranceAgreementsAPI.ApiCalloutQueueable apiCallQueue = new InsuranceAgreementsAPI.ApiCalloutQueueable(new List<QuoteLineItem>{qli});
        System.enqueueJob(apiCallQueue);
        Test.stopTest();  
        QuoteLineItem qli2 = [select id,QuoteId, Agreement_Status__c from QuoteLineItem where id=:qli.Id LIMIT 1];
        System.assertEquals('Cancelled', qli2.Agreement_Status__c);
    }
}