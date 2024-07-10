/**
* Revision Ref Number  Date          Owner                   Description
* -------- ----------  -----------   -----------------       -----------
* 1.0	   SFSE-14161  16-may-2024	 Samar					 Sending Quote file for p2q Oppty.	 	
**/
@isTest
public  class AthenaFetchFileCtrlTest {

    @testSetup static void setup() {
        Test.startTest();
         TriggerExecutionController.skipAllTriggers(true);
        User salesUser = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, true);
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', true);
        Contact con = TestBusinessHelper.createContact(clientAccount, 'Customer_Contact','MaerskLine', true);
        Contact con2 = TestBusinessHelper.createContact(clientAccount, 'Customer_Contact', 'Alianca', true);
        Opportunity mslOppty = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        mslOppty.CloseDate = Date.today().addDays(1);
        mslOppty.Offer_Status__c ='Sent';
    
        mslOppty.Customer_Journey__c = 'Instant Quote (Non Negotiable)';
        Integer daysLeftInMonth = mslOppty.CloseDate.daysBetween(mslOppty.CloseDate.toStartOfMonth());
        Integer daysLeftForNextMonth = Date.daysInMonth(mslOppty.CloseDate.year(), mslOppty.CloseDate.month()) - daysLeftInMonth;
        mslOppty.First_Shipment_Date__c = mslOppty.CloseDate + daysLeftForNextMonth + 9;
        mslOppty.Last_Shipment_Date__c =  mslOppty.CloseDate + daysLeftForNextMonth + 10;
        update mslOppty;

        Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true);  
        product.OIPC_Code__c='12345';
        product.Portfolio__c='LnS';
        product.Version__c=1;
        product.IsActive=true;
        product.Product_Scope__c ='Included In P2Q';
        product.Product_Status__c='Ready-to-sell';
        product.Latest_Product_Version__c = null;
        update product;
        List<Trade_Route__c> lstTDR = TestBusinessHelper.createTradeRoutes(new List<String> {'MSL'},  1, true);
        Geography__c geoCountry = TestBusinessHelper.createGeography('United States', 'Country', null, true);
        Geography__c geoState = TestBusinessHelper.createGeography('Arizona', 'State', geoCountry.Id, true);
        BDA__c uSParentBDA = TestBusinessHelper.createBDA('North America Region', 'Trade Region', 'NAM', null, UserInfo.getUserId(), true);
        BDA__c uSChildBDA = TestBusinessHelper.createBDA('North America Area', 'Cluster', 'NOA', uSParentBDA, UserInfo.getUserId(), true);
        Segmentation_Matrix__c USsgm = TestBusinessHelper.createSegmentationMatrix(uSParentBDA.Id, uSChildBDA.Id, geoCountry.Id, true);
        Segment_Data__c sgdata = TestBusinessHelper.createSegmentaData(product.id, USsgm.Id, true);
        Opportunity_Product__c opp = TestBusinessHelper.createOpportunityLineItemCustom(mslOppty, product.Id, lstTDR[0], geoCountry, geoState, true);
        Quotes__c quote= new Quotes__c();
        quote.Status__c='Negotiation Initiated';
        quote.Negotiation_Round__c =1;
        quote.Negotiation_Source__c='CRM';
        quote.Opportunity__c = mslOppty.Id;
        Quote.Quote_Copo_Link__c ='https://ath-container-interface.cdt.maersk-digital.net/athena/v1/assemblerfiles/CP-0008136/1?fileType=MaerskQuote';
        insert quote;
        Test.stopTest();
        TriggerExecutionController.skipAllTriggers(false);
        //Offer_Information__c offInfo = TestBusinessHelper.createOfferInformation('Sent',salesUser,mslOppty,con,con2,true);
    }

    @isTest static void testAccessToken() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Athena_HttpCallOutMock());
        string accessToken = AthenaFetchFileCtrl.getAccessToken();
        Assert.areEqual('9999999', accessToken);
        Test.stopTest();
    }
    @isTest static void testfile() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Athena_HttpCallOutMock());
        Opportunity oppty=[SELECT id FROM Opportunity WHERE Customer_Journey__c = 'Instant Quote (Non Negotiable)'];
        AthenaFetchFileCtrl.responsewrap  resp= AthenaFetchFileCtrl.fetchQuoteFile(oppty.id);
        
        Assert.areEqual('MaerskQuote_CP-0008136_1.xlsx', resp.filename);
        Test.stopTest();
    }
    
     @isTest static void testfileError() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Athena_HttpCallOutMock());
        Opportunity oppty=[SELECT id FROM Opportunity WHERE Customer_Journey__c = 'Instant Quote (Non Negotiable)'];
        TriggerExecutionController.skipAllTriggers(true);
        Quotes__c quote =[SELECT id,Quote_Copo_Link__c FROM Quotes__c LIMIT 1];
        quote.Quote_Copo_Link__c =  quote.Quote_Copo_Link__c+'Test';
        update quote;
        TriggerExecutionController.skipAllTriggers(false);
        AthenaFetchFileCtrl.responsewrap  resp= AthenaFetchFileCtrl.fetchQuoteFile(oppty.id);
        Assert.areEqual('Error', resp.status);
        Test.stopTest();
    }
	@isTest static void testfileEmptyURL() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Athena_HttpCallOutMock());
        TriggerExecutionController.skipAllTriggers(true);
        Opportunity oppty=[SELECT id FROM Opportunity WHERE Customer_Journey__c = 'Instant Quote (Non Negotiable)'];
        Quotes__c quote =[SELECT id,Quote_Copo_Link__c FROM Quotes__c LIMIT 1];
        quote.Quote_Copo_Link__c = null;
        update quote;
         TriggerExecutionController.skipAllTriggers(false);
        AthenaFetchFileCtrl.responsewrap  resp= AthenaFetchFileCtrl.fetchQuoteFile(oppty.id);
        Assert.areEqual('Error', resp.status);
        Test.stopTest();
    }

}