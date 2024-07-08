/*              
* Revision Date        Owner                    Description
* -------- ----------  -----------              ------------
* 1.0     27-Oct-2022  Sidhartha@maersk.com     Test Class for OpportunityEventResponseWrapper.cls, SerializeSObjectToJSON.cls
* 2.0     01-Feb-2023  Aditi@Maersk             Added Offer_Type__c field value
* 3.0     08-Jan-2023  Ramadevi@maersk.com      Added Business_Process__c field value 
*/
@isTest
public class OpportunityEventResponseWrapper_Test {
    @testSetup static void setup() {
        TriggerExecutionController.skipAllTriggers(true);
        Account ClientAccount = TestBusinessHelper.createAccount('Client_Account', true);
        Opportunity mslOppty = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);  
        Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        opp.Business_Process__c = 'Instant Quote;Tender';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        opp.Expected_Handling_Rounds__c = 5;
        
        update opp;
       
        String mslConObj1Email = 'QwertyMSL1@gmail.com';
        User runUser = TestBusinessHelper.createUser('Integration User', BrandUtilities.MAERSKLINE + ';' + BrandUtilities.MAERSKLS, true);
        Contact MSLconObj1 = TestBusinessHelper.createContact(clientAccount, 'Customer_Contact', BrandUtilities.MAERSKLINE, true);
        TriggerExecutionController.skipAllTriggers(false);
        List<Product2> lstProd = new List<Product2>{TestBusinessHelper.createProduct('Ocean', true)};
        Test.startTest();
        ScheduleOppProducts.OpportunityfromClone = false;
        /*Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
     
        Update standardPricebook;*/
       
        //PriceBookEntry pbEntry = [select Id from PriceBookEntry where Product2Id =:lstProd[0].Id];

        /*Map<String, string> GeoMap = new Map<String, String>();
        GeoMap.put( 'Long Beach', 'Country' );
        List<Geography__c> geoList = DataGeneratorHelper1_Test.createGeography( GeoMap );
        system.debug('geoList ' + geoList);
        Geography__c geo = geoList[0];
        geo.Is_Port__c = true;
        update geo;*/

        List<Trade_Route__c> lstTradeRoute = TestBusinessHelper.createTradeRoutes(new List<String>{BrandUtilities.MCC}, 1,true);
      
        Id tradeRouteId = lstTradeRoute[0].Id;
    
        
        Opportunity_Product__c oli = New Opportunity_Product__c();
        oli.OpportunityId__c = mslOppty.Id;
        oli.Quantity__c = 1;
        oli.UnitPrice__c = 1;
        oli.Product_Revenue_Per_Unit__c = 1;
        oli.Opt_Out_Auto_Quantity_Scheduling__c = false;
        oli.Tender_Target__c = 1;
        oli.Product2ID__c = lstProd[0].Id;
        oli.Trade_Route__c = tradeRouteId;
        insert oli;
        
        Offer_Information__c offer= new Offer_Information__c();
        offer.Offer_Status__c='Sent';
        offer.Date_Sent__c =system.today();
        offer.Opportunity__c= mslOppty.Id;
        offer.To_Recipient__c= MSLconObj1.id;
        offer.CC_Recipients__c =mslConObj1Email;
        insert offer;
        
        Quotes__c quote= new Quotes__c();
        quote.Status__c='Negotiation Initiated';
        quote.Negotiation_Round__c =1;
        quote.Negotiation_Source__c='CRM';
        quote.Opportunity__c = mslOppty.Id;
        insert quote;
        
        Opportunity_File__c file = new Opportunity_File__c();
        file.File_Category__c='RFQ/Nomination File';
        file.Quote__c=quote.id;
        file.Opportunity__c= mslOppty.Id;
        file.Name='test\\.test';
        insert file;
       // OpportunityLineItem Oli = DataGeneratorHelper1_Test.createOpportunityLineItem( mslOppty.Id, pbEntry.Id );
        Test.stopTest();
    }    
    
    static testmethod void testOpptyEventWrapper(){  
        Test.startTest();
        /*
        Account acc = [select Customer_Group__c from Account LIMIT 1];
        TriggerExecutionController.skipAllTriggers(true);
        String mslConObj1Email = 'QwertyMSL1@gmail.com';
        User runUser = UserDataGeneratorHelper_Test.MSLIntegrationUser;
        Contact MSLconObj1 =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MAERSKLINE,acc.Id,mslConObj1Email,runUser);
        TriggerExecutionController.skipAllTriggers(false);
        */
        Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        opp.StageName = 'Qualifying';
        //opp.Offer_Type__c = 'Offer containing Standard T&Cs';
        update opp;
        Test.stopTest();
        
    }
}