/*              
 * Revision Ref Number  Date          Owner                   Description
 * -------- ----------  -----------   -----------------       -----------
 * 1.0 		SFSE-11233	23-June-2023  Vinay					  test class for OneClickOfferConfirmationEmailCtrl class	
*/
@istest
public class OneClickOfferConfirmationEmailCtrlTest {

    @testSetup
    static void testSetupData(){
        TriggerExecutionController.skipAllTriggers(true);
        
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', true);
        
        Opportunity mslOppty = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
    
        mslOppty.Pricebook2Id = Test.getStandardPricebookId();
        update mslOppty;
        
        ScheduleOppProducts.OpportunityfromClone = false;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
            
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
        Geography__c state = TestBusinessHelper.createGeography('Karnataka', 'State', country.Id, true);
        
        List<Trade_Route__c> lstTradeRoute =  TestBusinessHelper.createTradeRoutes(new List<String>{'MCC'}, 1,true);

        
        Id tradeRouteId = lstTradeRoute[0].Id;
        
        List<Product2> lstProd = new List<Product2>{TestBusinessHelper.createProduct('Ocean', true)};
         //List<Product2> lstProdt = DataGeneratorHelper1_Test.createProduct2( 1,'A','DE','LnS'); 
        List<Opportunity_Product__c> lstoli= new list<Opportunity_Product__c>();
        Opportunity_Product__c Oli1 =  TestBusinessHelper.createOpportunityLineItemCustom(mslOppty, lstProd[0].Id,lstTradeRoute[0], true);
        Opportunity_Product__c Oli2 =TestBusinessHelper.createOpportunityLineItemCustom(mslOppty, lstProd[0].Id,lstTradeRoute[0], country, state,true);
        
        List<Product_Component__c> comps = DataGeneratorHelper_OIPC.createOipcProductComponents(2, lstProd[0].Id);
        insert comps;
        List<Product_Feature__c> prodFeatList = DataGeneratorHelper_OIPC.createOipcProductFeatures(3, comps[0].Id);
        insert prodFeatList;
        List<Id> featList = new List<Id>();
        for( Product_Feature__c prodFeat : prodFeatList){
            featList.add(prodFeat.Id);
        }
        system.debug('featList :'+featList);
        
    }
    
    @istest
    static void callConstructorTest(){
        
        opportunity opty =[SELECT Id FROM Opportunity LIMIT 1];
        Assert.isNotNull(opty);
        
        Test.startTest();
        PageReference testPage = Page.OneClickOfferConfirmationEmailTemplate;         
        testPage.getParameters().put('optyId', opty.Id);
        testPage.getParameters().put('name', 'test');
        testPage.getParameters().put('offercreatedby', 'test');
        Test.setCurrentPage(testPage);
	
		OneClickOfferConfirmationEmailCtrl offerctrl = new OneClickOfferConfirmationEmailCtrl();
		test.stopTest();        
    }

}