@isTest(seeAllData= false)
public without sharing class OpportunityDataGenerator_Test {
	
     @isTest
    public static void testOpptyEventWrapper(){  
       TriggerExecutionController.skipAllTriggers(true);
        Test.startTest();
        Account ClientAccount = TestBusinessHelper.createAccount('Client_Account', true);
        User RunUser = TestBusinessHelper.createUser('Integration User', BrandUtilities.SEALAND, true);
        Contact MSLContact = TestBusinessHelper.createContact(clientAccount, 'Customer_Contact', BrandUtilities.MAERSKLINE, true);
        
        Business_Plan__c bp = new Business_Plan__c();
        bp.Lead_Account__c = ClientAccount.Id;
        bp.Name = 'Test';
        bp.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        insert bp;
         
        Opportunity MSLOppty = TestBusinessHelper.createOpportunity(clientAccount, MSLContact, RunUser, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);

        List<Opportunity> lstOppty = TestBusinessHelper.createOpportunities(clientAccount, MSLContact, RunUser,new List<String>{ 'ShippingCargoServices','Quarterly_Deal'}, BrandUtilities.MAERSKLINE, true);
	   Opportunity opp = TestBusinessHelper.createOpportunity(clientAccount, MSLContact, RunUser, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);

        Opportunity Oppty2 =TestBusinessHelper.createOpportunity(clientAccount, MSLContact, RunUser, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
  
        Opportunity opty =  TestBusinessHelper.createOpportunity(clientAccount, MSLContact, RunUser, 'Quarterly_Deal', BrandUtilities.MAERSKLINE, true);

        Opportunity Oppty1 = TestBusinessHelper.createOpportunity(clientAccount, MSLContact, RunUser, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
 
         
         
        Test.stopTest(); 
		TriggerExecutionController.skipAllTriggers(false);
    }
    
         @isTest
    public static void testOppty(){  
       TriggerExecutionController.skipAllTriggers(true);
        Test.startTest();
        Account ClientAccount = AccountDataHelper_Test.createClientAccount();
        User RunUser = UserDataGeneratorHelper_Test.MSLIntegrationUser;
        Contact MSLContact =ContactDataGeneratorHelper_Test.createCustomerContact( BrandUtilities.MAERSKLINE, ClientAccount.Id, 'Qwerty@gmail.com', RunUser );
        
        Business_Plan__c bp = new Business_Plan__c();
        bp.Lead_Account__c = ClientAccount.Id;
        bp.Name = 'Test';
        bp.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        insert bp;
        
  

        Opportunity oppSeg = OpportunityDataGeneratorHelper_Test.createSegDryOpportunity( ClientAccount.id, null);  
        Opportunity oppMSL = OpportunityDataGeneratorHelper_Test.createMSLDryClosedOpportunity( ClientAccount.id, null);  
        Opportunity oppMSLTender = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( ClientAccount.id, null);   
        Opportunity oppMSLQuater = OpportunityDataGeneratorHelper_Test.createMSLQuarterlyDealOpportunity( ClientAccount.id, null);   
        Opportunity oppSupply = OpportunityDataGeneratorHelper_Test.createSupplyChainServicesRecord( ClientAccount.id);   
         
         
        Test.stopTest(); 
		TriggerExecutionController.skipAllTriggers(false);
    }
}