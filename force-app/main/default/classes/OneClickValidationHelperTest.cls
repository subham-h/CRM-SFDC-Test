/**
* Rev    Story           Name                   Date                Comments
* 1.   SFSE-13329      Shashi@Maersk         15-Apr-2024          Added test method testP2Q_I_Agree_Validations
*
**/

@IsTest
public class OneClickValidationHelperTest {

    
       @testSetup 
       static void setup() {
        
       TriggerExecutionController.skipAllTriggers(true);
        
        Account clientAccount = AccountDataHelper_Test.createClientAccount(); 
        Opportunity mslOppty = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( clientAccount.id, null); 
        Opportunity opp = [SELECT Id, StageName, CloseDate FROM Opportunity LIMIT 1];        
           
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;
        TriggerExecutionController.skipAllTriggers(false);
       // List<Product2> lstProd = DataGeneratorHelper1_Test.createProduct2( 1,'A','DE','Ocean');
        ScheduleOppProducts.OpportunityfromClone = false;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Update standardPricebook;
        Map<String, string> geoMap = new Map<String, String>();
        GeoMap.put( 'Long Beach', 'Country' );
        List<Geography__c> geoList = DataGeneratorHelper1_Test.createGeography( geoMap );
        Geography__c geo = geoList[0];
        geo.Is_Port__c = true;
        update geo;
        //List<Trade_Route__c> lstTradeRoute = DataGeneratorHelper_OIPC.createTradeRoutes(1, 'MCC');
        //insert lstTradeRoute;
        //Id tradeRouteId = lstTradeRoute[0].Id;
         //List<Product2> lstProd = DataGeneratorHelper1_Test.createProduct2( 1,'A','DE','Ocean');
         Product2 product = TestBusinessHelper.createProduct('ocean', true);
         List<Trade_Route__c> lstTradeRoute = TestBusinessHelper.createTradeRoutes(new List<String> {'MSL'},  1, true);
         //List<Product2> lstProdt = DataGeneratorHelper1_Test.createProduct2( 1,'A','DE','LnS'); 
        List<Opportunity_Product__c> lstoli= new list<Opportunity_Product__c>();
        Test.startTest();
        //Opportunity_Product__c Oli1 = DataGeneratorHelperCusOli_Test.createOpportunityLineItem( mslOppty.Id);
        Opportunity_Product__c Oli1 = TestBusinessHelper.createOpportunityLineItemCustom(mslOppty, product.Id,lstTradeRoute[0], true);
       // Opportunity_Product__c Oli2 = DataGeneratorHelperCusOli_Test.createOpportunityLineItemWithCountry( mslOppty.Id, geoList[0].Id );
        Opportunity_Product__c Oli2 = TestBusinessHelper.createOpportunityLineItemCustom( mslOppty, product.Id, lstTradeRoute[0], true ); 
        for(Opportunity_Product__c oli:[Select id, Product2ID__c from Opportunity_Product__c where opportunityid__c =: mslOppty.Id ]){
            oli.Product2ID__c = product.id;
            lstoli.add(oli);
        }
        update lstoli;
        List<Product_Component__c> comps = DataGeneratorHelper_OIPC.createOipcProductComponents(2, product.Id);
        insert comps;
        List<Product_Feature__c> prodFeatList = DataGeneratorHelper_OIPC.createOipcProductFeatures(3, comps[0].Id);
        insert prodFeatList;
        List<Id> featList = new List<Id>();
        for( Product_Feature__c prodFeat : prodFeatList){
            featList.add(prodFeat.Id);
        }
           
            /*Account clientAcc =TestBusinessHelper.createAccount('Client_Account', true);
            Contact contact = TestBusinessHelper.createContact(clientAcc, 'Customer_Contact', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
            User maerskLineUser = TestBusinessHelper.createUser('Sales', Brand__mdt.getInstance('MaerskLine').MasterLabel, false);
            System.runAs(new User(Id = UserInfo.getUserId())){
            maerskLineUser.Id = null;
            //maerskLineUser.FederationIdentifier='testmsluser@maersk.com';
            maerskLineUser.CM_Visibility__c='Single Carrier';
            insert maerskLineUser;
        }
           Opportunity opp1 = TestBusinessHelper.createOpportunity(clientAcc,contact,maerskLineUser,'ShippingCargoServices',BrandUtilities.MAERSKLINE,true);*/
           
      Test.stopTest();
        //insert DataGeneratorHelperCusOli_OIPC.createOpptyFeatures(Oli2.Id,featList);                 
    }
    
    @IsTest
    static void testOfferTypeValidation() {
        // Create test data
        Test.startTest();
        String lwcStr = 'lwc'; Set<Id> oppIdSet = new Set<Id>();
        
        
        List<Opportunity> oppty= [SELECT Id, Offer_Type__c,First_Shipment_Date__c,Last_Shipment_Date__c FROM Opportunity LIMIT 1];
        oppty[0].Offer_Type__c='Offer containing Standard T&Cs';
        oppty[0].Must_Go_To_OMEB__c=false;
        oppty[0].Last_Shipment_Date__c = null;
        //oppty[0].Estimated_L_S_Product_Gross_Profit1__c=10000;
        update oppty;
        oppIdSet.add(Oppty[0].Id);
        String errOrNoError='OfferTypeError';
        List<Opportunity_Product__c> oli=[Select id, Product2ID__c,OpportunityId__r.First_Shipment_Date__c, OpportunityId__r.Last_Shipment_Date__c, OpportunityId__r.Offer_Type__c,Total_Price__c,UnitPrice__c,Discount__c,Quantity__c,Product2ID__r.Portfolio__c from Opportunity_Product__c where opportunityid__c =: oppty[0].Id ];
        OneClickValidationHelper.checkAllValidation(oppIdSet , lwcStr);
        OneClickValidationHelper.agreementValidation(oli[0]);
        String ErrCode = OneClickValidationHelper.offerTypeValidation(oppty[0]);
        // Verify the results
        //System.assertEquals(1, oppIdToErrCode.size());
        System.assertEquals('', ErrCode);
        List<Opportunity> oppty1= [SELECT Id, First_Shipment_Date__c, Last_Shipment_Date__c, Offer_Type__c FROM Opportunity LIMIT 1];
        oppty1[0].Offer_Type__c='Offer containing Standard T&Cs';
        oppty1[0].Must_Go_To_OMEB__c=false;
        oppty1[0].Last_Shipment_Date__c = null;
        update oppty1;
        String ErrCode1 = OneClickValidationHelper.offerTypeValidation(oppty1[0]);
        OneClickValidationHelper.omebValidation(oppty1[0]);
        // Verify the results
        //System.assertEquals(1, oppIdToErrCode1.size());
        System.assertEquals('', ErrCode1);
        String ErrCode3 = OneClickValidationHelper.startEndDateAgreementCheck(oppty1[0]);
        Test.stopTest();
    }
    
    @IsTest
    static void testOfferTypeValidationError() {
        // Create test data
        Test.startTest();
        List<Opportunity> oppty= [SELECT Id, Offer_Type__c,Tender_Submission_Format__c,RecordType.DeveloperName,First_Shipment_Date__c,Last_Shipment_Date__c FROM Opportunity LIMIT 1];
        oppty[0].Offer_Type__c='Offer linked to existing signed MSA/Framework';
        oppty[0].Must_Go_To_OMEB__c=true;
        oppty[0].Cargo_Type__c='Dry';
        oppty[0].First_Shipment_Date__c=System.today() + 20;
        oppty[0].Last_Shipment_Date__c=System.today() + 90;
        update oppty;
        String lwcStr = 'lwc'; Set<Id> oppIdSet = new Set<Id>();
        oppIdSet.add(Oppty[0].Id);
        List<Opportunity_Product__c> oli=[Select id, OpportunityId__r.First_Shipment_Date__c, OpportunityId__r.Last_Shipment_Date__c, Product2ID__c,Product2ID__r.Name,OpportunityId__r.Offer_Type__c,Product2ID__r.Portfolio__c,Total_Price__c from Opportunity_Product__c where opportunityid__c =: oppty[0].Id ];
        oli[0].Product2ID__r.Name = 'E-Delivery';
        update oli;
        OneClickValidationHelper.checkAllValidation(oppIdSet , lwcStr);
        String ErrCode = OneClickValidationHelper.offerTypeValidation(oppty[0]);
        OneClickValidationHelper.startEndDateAgreementCheck(oppty[0]);
        OneClickValidationHelper.agreementValidation(oli[0]);
        // Verify the results
        //System.assertEquals(1, oppIdToErrCode.size());
        System.assertEquals('OfferTypeError', ErrCode);
        List<Opportunity> oppty1= [SELECT Id, Offer_Type__c FROM Opportunity LIMIT 1];
        oppty1[0].Offer_Type__c='Offer linked to existing signed MSA/Framework';
        oppty1[0].Must_Go_To_OMEB__c=true;
        oppty1[0].Cargo_Type__c='Dry';
        update oppty1;
        String ErrCode1 = OneClickValidationHelper.offerTypeValidation(oppty1[0]);
        OneClickValidationHelper.omebValidation(oppty1[0]);
        // Verify the results
        //System.assertEquals(1, oppIdToErrCode1.size());
        System.assertEquals('OfferTypeError', ErrCode1);
         
        String ErrCode3 = OneClickValidationHelper.agreementValidation(oli[0]);
        Test.stopTest();
    }
    
    @IsTest
    static void testHasAccessValidation() {
         String lwcStr = 'lwc'; Set<Id> oppIdSet = new Set<Id>();
        // Create a test Account
        Account acc=[SELECT Id,OwnerId,MSL_Account_Owner__r.Id,Alianca_Account_Owner__r.Id
                                      ,HSUD_Account_Owner__r.Id,MCC_Account_Owner__r.Id,MLL_Account_Owner__r.Id
                                      ,Seago_Account_Owner__r.Id,SEA_Account_Owner__r.Id from Account LIMIT 1];
        Opportunity testOppty= [SELECT Id,AccountId,Liner_Brand__c,Opportunity.OwnerId,Business_Process__c FROM Opportunity LIMIT 1];  
        oppIdSet.add(testOppty.Id);
        Test.startTest();
        OneClickValidationHelper.checkAllValidation(oppIdSet , lwcStr);
        OneClickValidationHelper.hasAccessValidation(testOppty);
        Test.stopTest();
    }
        @IsTest
    static void dryReeferTest() {
        
        TriggerExecutionController.skipAllTriggers(true);
        String lwcStr = 'lwc'; Set<Id> oppIdSet = new Set<Id>();
        List<Opportunity> Oppty= [SELECT Id,Cargo_Type__c,RecordType.DeveloperName from Opportunity where RecordType.DeveloperName != 'Supply_Chain_Services' LIMIT 1];
        Oppty[0].Cargo_Type__c= null;
        update Oppty; 
        oppIdSet.add(Oppty[0].Id);
        
        List<Product2> prodct = [Select id,Portfolio__c from Product2 limit 1];
        prodct[0].Portfolio__c = 'Ocean'; update prodct[0]; 
        List<Opportunity_Product__c> oli = [SELECT Id, OpportunityId__r.Qualify_OneClick_Journey__c, Product2ID__r.Name,
                Special_Cargo__c,
                OpportunityId__r.Estimated_L_S_Product_Gross_Profit1__c, OpportunityId__r.Special_Cargo__c,
                OpportunityId__r.Cargo_Type__c, OpportunityId__r.First_Shipment_Date__c,OpportunityId__r.Last_Shipment_Date__c,
                Product2ID__r.Portfolio__c, OpportunityId__c, OpportunityId__r.Must_Go_To_OMEB__c, OpportunityId__r.Offer_Type__c,
                OpportunityId__r.Estimated_Ocean_FFE__c,OpportunityId__r.Tender_Submission_Format__c,OpportunityId__r.RecordType.Name,
                OpportunityId__r.RecordType.DeveloperName,Total_Mandatory_Configuration_Filled__c,Total_Mandatory_Configuration__c 
                FROM Opportunity_Product__c where OpportunityId__c =: oppty[0].Id LIMIT 1 ];
        oli[0].Special_Cargo__c = null; 
        oli[0].Product2ID__c  = prodct[0].Id; 
        oli[0].Total_Mandatory_Configuration__c = 5;
        oli[0].Total_Mandatory_Configuration_Filled__c = 3;
        update oli[0]; 
        Test.startTest();
        OneClickValidationHelper.checkAllValidation(oppIdSet , lwcStr);
        OneClickValidationHelper.dryCargoQuantityValidation(oli[0]);
        OneClickValidationHelper.reeferSpecialQuantityValidation(oli[0]);
        OneClickValidationHelper.mandatoryFeatureValidation(oli[0]);
        TriggerExecutionController.skipAllTriggers(false);
        Oppty[0].Cargo_Type__c= 'Dry'; update Oppty;
        OneClickValidationHelper.dryCargoQuantityValidation(oli[0]);
        OneClickValidationHelper.reeferSpecialQuantityValidation(oli[0]);
        Test.stopTest();
    }
    
        @IsTest
    static void GrossProfitHighValidationTest() {
        TriggerExecutionController.skipAllTriggers(true);
        List<Opportunity> Oppty= [SELECT Id,Cargo_Type__c,RecordType.DeveloperName from Opportunity where RecordType.DeveloperName != 'Supply_Chain_Services' LIMIT 1];
        //Oppty[0].Estimated_L_S_Product_Gross_Profit1__c= 2000000;
        //update Oppty; 
        List<Product2> prodct = [Select id,Portfolio__c from Product2 limit 1];
        prodct[0].Portfolio__c = 'LnS'; update prodct[0]; 
        List<Opportunity_Product__c> oli = [Select id,Product2ID__c,Quantity__c,Product2ID__r.Portfolio__c,OpportunityId__r.RecordType.DeveloperName,OpportunityId__r.Cargo_Type__c,OpportunityId__r.Estimated_Ocean_FFE__c, OpportunityId__r.Estimated_L_S_Product_Gross_Profit1__c from Opportunity_Product__c where opportunityid__c =: oppty[0].Id LIMIT 1 ];
        oli[0].Special_Cargo__c = null; 
        oli[0].Product2ID__c  = prodct[0].Id;  
        update oli[0]; 
        String lwcStr = 'lwc'; Set<Id> oppIdSet = new Set<Id>();
        oppIdSet.add(Oppty[0].Id);
        
        Test.startTest();
        OneClickValidationHelper.grossProfitHighValidation(oli[0]);
        OneClickValidationHelper.checkAllValidation(oppIdSet , lwcStr);
        Test.stopTest();
    }
    
        @isTest
        static void testP2Q_I_Agree_Validations() {
            Account clientAcc = TestBusinessHelper.createAccount('Client_Account', true);
            Contact contact = TestBusinessHelper.createContact(clientAcc, 'Customer_Contact', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
            User maerskLineUser = TestBusinessHelper.createUser('Sales', Brand__mdt.getInstance('MaerskLine').MasterLabel, false);
            System.runAs(new User(Id = UserInfo.getUserId())){
                maerskLineUser.Id = null;
                maerskLineUser.CM_Visibility__c='Single Carrier';
                insert maerskLineUser;
            }
        	Opportunity opp1 = TestBusinessHelper.createOpportunity(clientAcc,contact,maerskLineUser,'ShippingCargoServices',BrandUtilities.MAERSKLINE,true);
            opp1.Customer_Journey__c = 'Instant Quote (Non Negotiable)';
            opp1.Tender_Submission_Format__c = 'Maersk Line standard format';
            Integer daysLeftInMonth = opp1.CloseDate.daysBetween(opp1.CloseDate.toStartOfMonth());
            Integer daysLeftForNextMonth = Date.daysInMonth(opp1.CloseDate.year(), opp1.CloseDate.month()) - daysLeftInMonth;
            opp1.First_Shipment_Date__c = opp1.CloseDate + daysLeftForNextMonth + 9;
            opp1.Last_Shipment_Date__c =  opp1.CloseDate + daysLeftForNextMonth + 10; 
            opp1.StageName = System.Label.Identifying;
        	TriggerExecutionController.skipAllTriggers(false);
            update opp1;
            String lwcStr = 'lwc'; Set<Id> oppIdSet = new Set<Id>();
            Test.startTest();
            Opportunity updatedOpp = [SELECT Id, Business_Process__c,StageName FROM Opportunity WHERE Id =:opp1.Id];
            oppIdSet.add(updatedOpp.Id);
            Map<Id, String> mapOppErr = new Map<Id, String>();
            Quotes__c quote  = new Quotes__c(
                 Opportunity__c = updatedOpp.Id,
                 Status__c = 'Negotiation Initiated',
                 Submission_Date__c = Date.Today()
             );
            insert quote;    
            mapOppErr = OneClickValidationHelper.checkAllValidation(oppIdSet , lwcStr);
            Boolean containsErrorCode2 = mapOppErr.get(updatedOpp.Id).contains('P2QQuote') ? true : false;
            Assert.areEqual(containsErrorCode2,true);
            Test.stopTest();
    	}
    
}