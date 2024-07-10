/**
 *
 * Test class for : OpportunityTrigger, OpportunityTriggerHandler, OpportunityTriggerHandler_Utilities
 *
 * Version  Date            Modified By                         Ref Number      Description
 * 1.0      25/02/2016      meghana.gupta@ust-global.com        #RQ-002301      OpportunityTrigger Refactoring
 *                          Madhava.kotte@ust-global.com        
 * 2.0      6-Nov-2017      Sandhya.Sambasivan@ust-global.com   #RQ-005318      Territory for Opprtunity
 * 3.0      14/05/2018      Junaid.Khader@ust-global.com                        Test class fixes
 * 4.0      18-Mar-2019     Junaid.Khader@ust-global.com        #RQ-010252      Removed methods (Test_ManualTerritoryChange, Test_MultiTerForSingleLBWithSalesOwnr, Test_MultiTerritoryForSingleLB, Test_SingleTerritoryForSingleLB) referencing out of box territory2 model
 * 5.0      06-Jun-2019     manjunath.c.holekade@maersk.com     #RQ-010819      Removal of references of deprecated fields
 * 6.0      26-May-2020     manjunath@maersk                    SFSE-111        Removed references and logic related to "Expected_FFE_Lead__c" object
 * 7.0      16-Oct-2020     meghana@UST                         SFSE-4767       Remove Safmarine related test method
 * 8.0      20-Nov-2020     Neha@TCS                            SFSE-4383       Updated teh First round submission date
 * 9.0      08-Jun-2022     Ronnie@SF                           SPI-100         Removed brand hardcoding
 * 10.0     19-Sep-2022     Kiran@Maersk                        SFSE-9341       Code coverage for validate Features Mandatory feature
 * 11.0     28-Aug-2023     Kiran@Maersk                        SFSE-12235      Test data new framework
 * 12.0     27-Sep-2023     Shashi@Maersk                       SFSE-12320      Addded method for renewal trigger testAutoRenewalTrigger()
 * 13.0     29-Jan-2024     Avinash@Maersk                      SFSE-13852      Backend Data updates when Customer Journey field is updated in Oppty Details
 * 14.0     12-Apr-2024     Avinash@Maersk                      SFSE-14511      Site ID status update
 * 15.0     05-Jun-2024     Avinash@Maersk                      SFSE-14825      Cargo Type on Opportunity Level
*/

@isTest(SeeAllData=false)
private class OpportunityTrigger_Test {  
    
    //public static Account ClientAccount = AccountDataHelper_Test.createClientAccount();
    //public static Account UnAssignedAccount = AccountDataHelper_Test.createUnassignedAccount();
    //public static Account draftAcc = AccountDataHelper_Test.createDraftAccount();
    private static Id salesUserId;
    private static Id adminUserId;
    private static User salesUser;
    
    @testSetup static void setup() {
        TriggerExecutionController.skipAllTriggers(true);
        
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
        Geography__c state = TestBusinessHelper.createGeography('Karnataka', 'State', country.Id, true);
        
        BDA__c parentBDA = TestBusinessHelper.createBDA('India, Middle East, and Africa', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true);
        BDA__c childBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'IBS', parentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, country.Id, null, true);
        
        List<user> usersToInsert = new List<user>();
        User salesUser = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
        salesUser.Id = null;
        salesUser.country = 'India';
        usersToInsert.add(salesUser);
        
        User adminUser = TestBusinessHelper.createUser('System Administrator', BrandUtilities.MAERSKLINE, false);
        adminUser.Id = null;
        adminUser.country = 'India';
        usersToInsert.add(adminUser);
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert usersToInsert;
        }
        
        Opportunity tenderOpportunity;
        System.runAs(salesUser){
            Account clientAccount = TestBusinessHelper.createAccount('Client_Account', true);
            tenderOpportunity = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        }
        
        Trade_Route__c tradeRoute;
        System.runAs(adminUser){
            tradeRoute = TestBusinessHelper.createTradeRoutes(new List<String>{BrandUtilities.MCC}, 1, true)[0];
        }
        system.debug('tradeRoute@@'+tradeRoute);
        List<Product2> lstProd = new List<Product2>();
        lstProd.add(TestBusinessHelper.createProduct('Ocean', true));
        lstProd.add(TestBusinessHelper.createProduct('Ocean test', true));
        system.debug('lstProd@@'+lstProd[0].name);
        Test.startTest();
        System.runAs(salesUser){
           Opportunity_Product__c Oli1 = TestBusinessHelper.createOpportunityLineItemCustom(tenderOpportunity, lstProd[0].id, tradeRoute, country, state, true);
        }
        Test.stopTest();
        
        BDA__c region = TestBusinessHelper.createBDA('North America Area', 'Trade Region', 'NAM', null, null, true); 
        List<BDA__c> regionList = new List<BDA__c>();
        regionList.add(region);

        BDA__c cluster = TestBusinessHelper.createBDA('North America Region', 'Cluster', 'NAR', region, null, true);
        List<BDA__c> clusterList = new List<BDA__c>();
        clusterList.add(cluster);
        
        Geography__c country1 = TestBusinessHelper.createGeography('United States', 'Country', null, true);
        
        BDA_Geography__c BDAGeo1 = TestBusinessHelper.createBDAGeography(cluster.Id, country1.Id, '1234', true);
        BDA_Geography__c BDAGeo2 = TestBusinessHelper.createBDAGeography(region.Id, country1.Id, '1111', true);
        
        List<String> linkIds = new List<String>{'test1','test2'};  //unique IDs for linking tradeRegion and clusters in Parent BDA

            User maerskLineUser = TestBusinessHelper.createUser(ProfileUtilities.Sales, BrandUtilities.MaerskLine, false);
        TriggerExecutionController.skipAllTriggers(true);
        System.runAs(adminUser){
            maerskLineUser.Id = null;
            maerskLineUser.FederationIdentifier='testmsluser111@maersk.com';
            maerskLineUser.Cluster__c='North America Area';
            maerskLineUser.Country='United States';
            maerskLineUser.Region__c='North America Region';
            maerskLineUser.IsActive=true;
            maerskLineUser.Maersk_User_Id__c='SSS123'; 
            insert maerskLineUser;
        }
        TriggerExecutionController.skipAllTriggers(false);
        
        List<Parent_BDA__c> parentBDA1 = TestBusinessHelper.createParentBDAs(clusterList, regionList, maerskLineUser,linkIds, 1, true);
    }
    
    @isTest(SeeAllData=false)
    static void testchangeOppOwner(){
        
        Opportunity opportunity = [SELECT Id, OwnerId, CreatedById FROM Opportunity WHERE Name = 'ShippingCargoServices'];
        salesUser = new User(Id = opportunity.CreatedById);
        System.assertNotEquals(opportunity.OwnerId, UserInfo.getUserId(), 'Incorrect owner id on opportunity');
        Test.startTest();
        opportunity.OwnerId = UserInfo.getUserId();
        System.runAs(salesUser){
            update opportunity;
        }
        Test.stopTest();
        opportunity = [SELECT OwnerId FROM Opportunity WHERE Name = 'ShippingCargoServices'];
        System.assertEquals(opportunity.OwnerId, UserInfo.getUserId(), 'Incorrect owner id on opportunity');
    }
    
    @isTest(SeeAllData=false)
    static void testMSLOpportunityTrigger1(){  
        Opportunity opportunity = [SELECT Id, Liner_Brand__c, OwnerId, CreatedById FROM Opportunity WHERE Name = 'ShippingCargoServices'];
        salesUser = new User(Id = opportunity.CreatedById);
        Test.startTest();
        System.runAs(salesUser){
            opportunity.Liner_Brand__c = '';
            update opportunity;
        }
        Test.stopTest();
        opportunity = [SELECT Id, Liner_Brand__c FROM Opportunity WHERE Name = 'ShippingCargoServices'];
        System.assertNotEquals('', opportunity.Liner_Brand__c, 'Liner Brand should have been set');
        System.assertEquals(BrandUtilities.MAERSKLINE, opportunity.Liner_Brand__c, 'Liner Brand should have been set');
    }
    
    //SFSE-14825
    @isTest
    static void testValidateOppoProdCargoTypeForCustJrnyOppo(){
        Trade_Route__c tradeRoutes = TestBusinessHelper.createTradeRoutes(new List<String>{BrandUtilities.MCC}, 1, true)[0];
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', false);
        clientAccount.Id = null;
        clientAccount.Vertical__c = 'Lifestyle';
        insert clientAccount;
        Contact con = TestBusinessHelper.createContact(clientAccount, 'Customer_Contact','MaerskLine', true);
        opportunity opp = TestBusinessHelper.createOpportunity(clientAccount, con, salesUser, 'Supply_Chain_Services', BrandUtilities.MAERSKLINE, false);
        opp.Id = null;
        opp.Customer_Journey__c = Label.As_is_Journey;
        insert opp;
        Test.setCreatedDate(opp.Id, system.today().toStartOfMonth());
        
        Product2 oceanProduct = TestBusinessHelper.createProduct('Ocean Contract', false);
        oceanProduct.Id = null;
        oceanProduct.Family_Code__c = 'ocean_contract';
        oceanProduct.OIPC_Code__c = 'P-P0-dwf';
        oceanProduct.Portfolio__c = 'Ocean';
        oceanProduct.Product_Scope__c = 'Included In P2Q';
        insert oceanProduct;
        
        Opportunity_Product__c opptyProd = TestBusinessHelper.createOpportunityLineItemCustom(opp, oceanProduct.Id,tradeRoutes, false);
        opptyProd.Id = null;
        opptyProd.Country__c = country.Id;
        opptyProd.Quantity__c = 10;
        opptyProd.UnitPrice__c = 10;
        opptyProd.Product_Revenue_Per_Unit__c = 1;
        opptyProd.Cargo_Type__c = 'Reefer';
        insert opptyprod;
        
        Test.startTest();
        try{
            opp.Customer_Journey__c = Label.Instant_Quote;
            opp.CloseDate = Date.today().addDays(Date.today().toStartOfMonth().Day() + 1);
            opp.First_Shipment_Date__c = Date.today().addDays(Date.today().toStartOfMonth().Day() + 2);
            opp.Last_Shipment_Date__c =  Date.today().addDays(Date.today().toStartOfMonth().Day() + 3);
            update opp;
        }
        Catch(Exception ex){
            Assert.areEqual(true, ex.getMessage().contains(Label.Cargo_Type_Dry_InstantQuote_Opty)); 
        }
        Test.stopTest();
    }
    
    //SFSE-14511 : Site ID status update
    @isTest
    static void testInvalidWarehouseSiteCount(){
        Trade_Route__c tradeRoutes = TestBusinessHelper.createTradeRoutes(new List<String>{BrandUtilities.MCC}, 1, true)[0];
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', false);
        clientAccount.Id = null;
        clientAccount.Vertical__c = 'Lifestyle';
        insert clientAccount;
        Contact con = TestBusinessHelper.createContact(clientAccount, 'Customer_Contact','MaerskLine', true);
        opportunity opp = TestBusinessHelper.createOpportunity(clientAccount, con, salesUser, 'Supply_Chain_Services', BrandUtilities.MAERSKLINE, false);
        opp.Id = null;
        insert opp;
        
        Product2 productCL = TestBusinessHelper.createProduct('Warehousing & Fulfilment', false);
        productCL.Id = null;
        productCL.Family_Code__c = 'warehousing_fulfilment';
        productCL.OIPC_Code__c = 'P-P0-dw9';
        productCL.Portfolio__c = 'LnS';
        insert productCL;
        
        /*Warehouse_Site__c wh = new Warehouse_Site__c();
        wh.Site_Id__c = '12345';
        wh.Name = 'Test Warehouse Site';
        wh.Country__c = country.Id;
        wh.Status__c = 'Active';
        insert wh;*/
        
        Opportunity_Product__c opptyProd = TestBusinessHelper.createOpportunityLineItemCustom(opp, productCL.Id,tradeRoutes, false);
        opptyProd.Id = null;
        opptyProd.Country__c = country.Id;
        opptyProd.Quantity__c = 10;
        opptyProd.UnitPrice__c = 10;
        opptyProd.Product_Revenue_Per_Unit__c = 1;
        opptyProd.Warehouse_Site__c = null;
        opptyProd.Estimated_Footprint_Requirement_in_Sqm__c = 100;
        insert opptyprod;
        
        Test.startTest();
        try{
            opp.StageName = 'Closed Won';
            opp.Offer_Type__c = 'Offer containing Standard T&Cs';
            update opp;
        }
        Catch(Exception ex){ 
            Assert.areEqual(true, ex.getMessage().contains('Please provide “Warehouse site” before closing the opportunity and ensure that an active, site setup-lease/acquisition start or IP approved site has been selected')); 
        }
        
        Warehouse_Site__c wh = new Warehouse_Site__c();
        wh.Site_Id__c = '12345';
        wh.Name = 'Test Warehouse Site';
        wh.Country__c = country.Id;
        wh.Status__c = 'Active';
        insert wh;
        
        opptyProd.Warehouse_Site__c = wh.id;
       
        update opptyProd;
        
        opp.StageName = 'Closed Won';
        opp.Offer_Type__c = 'Offer containing Standard T&Cs';
        update opp;
        
        OpportunityFieldPopulator.checkRecommendationStatusOnClose(new List<String>{opp.Id},new List<Opportunity>{opp});
        
        Opportunity opty = [Select id ,Count_of_Invalid_Warehouse_Sites__c from Opportunity where id=:opp.id];
        Assert.areEqual(0, opty.Count_of_Invalid_Warehouse_Sites__c);  
        Test.stopTest();
        
    }
    
    //SFSE-13852 : Backend Data updates when Customer Journey field is updated in Oppty Details
    @isTest(SeeAllData=false)
    static void testCustomerJourneybackendFieldPopulation(){
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', true);
        Opportunity optyToInsert = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, false);
        optyToInsert.Id = null;
        optyToInsert.Customer_Journey__c = 'As-Is Journey';
        insert optyToInsert;
        
        
        Opportunity optyTemp = [SELECT Id,Customer_Journey__c,First_Shipment_Date__c,Last_Shipment_Date__c,CloseDate FROM Opportunity WHERE Id =: optyToInsert.Id];
        optyTemp.Customer_Journey__c = 'Instant Quote (Non Negotiable)';
        Test.setCreatedDate(optyTemp.Id, system.today().toStartOfMonth());
        optyTemp.CloseDate = Date.today().addDays(Date.today().toStartOfMonth().Day() + 1);
        optyTemp.First_Shipment_Date__c = Date.today().addDays(Date.today().toStartOfMonth().Day() + 2);
        optyTemp.Last_Shipment_Date__c =  Date.today().addDays(Date.today().toStartOfMonth().Day() + 3);
        Test.startTest();
        update optyTemp;
        Test.stopTest();
        Opportunity optyTempRec = [SELECT Id,Customer_Journey__c,Tender_Submission_Format__c,Customer_Requested_Rate_Structure__c,Offer_Type__c,Cargo_Type__c FROM Opportunity WHERE Id =: optyToInsert.Id];
        System.assertEquals(optyTempRec.Tender_Submission_Format__c, 'Maersk Line standard format');
        System.assertEquals(optyTempRec.Customer_Requested_Rate_Structure__c, 'No');
        System.assertEquals(optyTempRec.Offer_Type__c, 'Offer containing Standard T&Cs');
        System.assertEquals(optyTempRec.Cargo_Type__c, 'Dry');
    }  
    
    // Test Ownership logic for MSL Opportunity 
    
    /*static testmethod void testMSLOpportunityTrigger() {
        
        
        TriggerExecutionController.skipAllTriggers(true);
        // create an opportunity
        Contact MSLconObj = new Contact(FirstName= 'MSL',LastName='MSL1',Liner_Brands__c=BrandUtilities.MAERSKLINE, AccountId=clientAccount.Id,Email='MSL@test.com',Preferred_Language__c='English');
        System.runAs(UserDataGeneratorHelper_Test.MSLIntegrationUser){
            insert MSLconObj;
        }
        
        Opportunity mslOppty = OpportunityDataGeneratorHelper_Test.createMSLDryOpportunity( clientAccount.id, MSLconObj.id );
        system.assertEquals(mslOppty.Opp_Owners_Manager__c==UserDataGeneratorHelper_Test.MSLSystemAdminUser.id,true,false);
        TriggerExecutionController.skipAllTriggers(false);
        Map<Id, Opportunity> oldOpptyMap = new Map<id,Opportunity>();
        oldOpptyMap.put(mslOppty.id,mslOppty);
        Test.startTest();
        mslOppty.OwnerId = UserDataGeneratorHelper_Test.MSLsalesUser.id ;
        mslOppty.Opp_Owners_Manager__c = UserDataGeneratorHelper_Test.systemAdminUser.id;
        system.runAs(UserDataGeneratorHelper_Test.MSLIntegrationUser){
            Database.update(mslOppty,false);
        }
        
        Map<Id, Opportunity> newOpptyMap = new Map<id,Opportunity>();
        newOpptyMap.put(mslOppty.id,mslOppty);
        
        for (Integer i=0;i<200;i++) {
            system.assertEquals(mslOppty.OwnerId==UserDataGeneratorHelper_Test.MSLsalesUser.id,true,false);
        }
        DataGeneratorHelper2_Test.createOppTeamMembr(1,UserDataGeneratorHelper_Test.MSLIntegrationUser,mslOppty.Id,Label.Team_Role_Label_Owner);
        
        OpportunityTeamMemberUtilities.UpdateOpportunityTeam(newOpptyMap.values(),oldOpptyMap, false );
        
        Test.stopTest();
    }
    
    
    // Test Ownership logic for SEA Opportunity 
    static testMethod void testSEAOpportunityTrigger() {
        
        Test.startTest();
        Contact SEAconObj =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.SEALAND,ClientAccount.Id,'QwertySEA31@gmail.com',UserDataGeneratorHelper_Test.SEAIntegrationUser);//Create SEA Contact
        
        // create an opportunity
        Opportunity seaOppty = OpportunityDataGeneratorHelper_Test.createSEADryOpportunity( clientAccount.id, SEAconObj.id );
        
        seaOppty.OwnerId = UserDataGeneratorHelper_Test.SEASystemAdminUser.id ; 
        system.runAs(UserDataGeneratorHelper_Test.SEAIntegrationUser){
            Database.update(seaOppty,false);
        }
        for (Integer i=0;i<200;i++) {
            system.assertEquals(seaOppty.OwnerId==UserDataGeneratorHelper_Test.SEASystemAdminUser.id,true,false);
        }
        Test.stopTest();
    }
    
    // Test Ownership logic for MCC Opportunity 
    static testMethod void testMCCOpportunityTrigger() {
        
        Test.startTest();
        Contact MCCconObj =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MCC,ClientAccount.Id,'QwertyMCC31@gmail.com',UserDataGeneratorHelper_Test.MCCIntegrationUser);//Create MCC Contact 
        
        // create an opportunity
        Opportunity mccOppty = OpportunityDataGeneratorHelper_Test.createMCCDryOpportunity( clientAccount.id, MCCconObj.id );
        
        mccOppty.OwnerId = UserDataGeneratorHelper_Test.MCCSystemAdminUser.id ; 
        system.runAs(UserDataGeneratorHelper_Test.MCCIntegrationUser){
            Database.update(mccOppty,false);
        }
        
        for (Integer i=0;i<200;i++) {
            system.assertEquals(mccOppty.OwnerId==UserDataGeneratorHelper_Test.MCCSystemAdminUser.id,true,false);
        }
        Test.stopTest();
    }
    
    // Test Ownership logic for SEG Opportunity 
    static testMethod void testSEGOpportunityTrigger() {
        TriggerExecutionController.skipAllTriggers(true);
        
        Contact seagoConObj =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.SEAGO,ClientAccount.Id,'QwertySEG31@gmail.com',UserDataGeneratorHelper_Test.SeagoIntegrationUser );//Create MSL Contact 
        TriggerExecutionController.skipAllTriggers(false);
        Test.startTest();
        // create an opportunity
        Opportunity SegOppty = OpportunityDataGeneratorHelper_Test.createSegDryOpportunity( clientAccount.id, seagoConObj.id );
        SegOppty.OwnerId = UserDataGeneratorHelper_Test.SeagoSystemAdminUser.id ; 
        system.runAs(UserDataGeneratorHelper_Test.SeagoIntegrationUser ){
            Database.update(SegOppty,false);
        }
        for (Integer i=0;i<200;i++) {
            system.assertEquals(SegOppty.OwnerId==UserDataGeneratorHelper_Test.SeagoSystemAdminUser.id,true,false);
        } 
        Test.stopTest();
    }
    
    static testmethod void testTenderOpportunityTrigger() {
        Test.startTest();  
        // create an opportunity        
        Opportunity mslOppty = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( clientAccount.id, null );
        mslOppty.Tender_Submission_Format__c = 'No Ocean Tender';
        mslOppty.Customer_Requested_Rate_Structure__c = 'No';
        mslOppty.First_Round_Submission_Date__c = null;
        mslOppty.Creator_Role__c = 'MLL';
        update mslOppty;
        List<Opportunity>opplist = new list<Opportunity>();
        opplist.add(mslOppty);
        
        OpportunityFieldPopulator.SetPriceBook(opplist);
        Test.stopTest();
    }*/
    
    static testmethod void testvalidateFeaturesMandatory() {
        Opportunity oppty = [SELECT Id, Liner_Brand__c, OwnerId, CreatedById FROM Opportunity WHERE Name = 'ShippingCargoServices'];
        oppty.Tender_Submission_Format__c = 'No Ocean Tender';
        oppty.Tender_Type__c='';
        oppty.Offer_Type__c = 'Offer containing Standard T&Cs';
        oppty.First_Shipment_Date__c = system.today()+12;
        oppty.Last_Shipment_Date__c = system.Today()+25;
        update oppty; 
        
        Product2 product = TestBusinessHelper.createProduct('Contract Logistics', true);  
        product.OIPC_Code__c='P-P0-dwd';
        product.Include_in_OMEB_Approvals__c=false;
        product.Portfolio__c='LnS';
        product.Version__c=1;
        product.IsActive=true;
        product.Product_Status__c='Ready-to-sell';
        update product;
        
        /*List<Product_Component__c> comps1 =  new List<Product_Component__c>();
        for (integer i = 1; i <= 2; i++){
            Product_Component__c pc = new Product_Component__c();
            pc.Name = 'Comp' + i;
            pc.Component_Code__c = 'PC' + i;
            pc.Product__c = prod.Id;
            pc.Display_Order__c = i;
            comps1.add(pc);
        }
        insert comps1;
        
        List<Product_Feature__c> lstfeat1 = new List<Product_Feature__c>();
        
        for (integer i = 0; i < 2; i++){
            
            Product_Feature__c f = new Product_Feature__c();
            f.Name = 'Feature' + i;
            f.Feature_Code__c = 'F' + i;
            f.Product_Component__c = comps1[i].Id;
            f.Display_Order__c = i;
            f.Categorisation__c ='';
            f.Default_Visibility__c= '';
            f.Description__c = 'Feature description ';           
            lstfeat1.add(f);
        }

        insert lstfeat1;

        List<Product_Specification_Parameter__c> lstparameter1 = new List<Product_Specification_Parameter__c>();

        for(integer i=0;i<2;i++){
            Product_Specification_Parameter__c para = new Product_Specification_Parameter__c();
            para.Name = 'paramter' + i;
            para.Specification_Parameter_Code__c = 'SP' + i;
            para.Product_Feature__c = lstfeat1[i].Id;
            para.Display_Order__c = i;
            para.type__c='options';
            para.Description__c = 'Parameter description ';  
            lstparameter1.add(para);
        }
        insert lstparameter1;

        List<Product_Specification_Option__c> lstoption1 = new List<Product_Specification_Option__c>();

        for(integer i=0;i<2;i++){
            Product_Specification_Option__c opt = new Product_Specification_Option__c();
            opt.Name = 'option' + i;
            opt.Specification_Option_Name__c = 'option' + i;
            opt.Specification_Option_Code__c = 'SPC' + i;
            opt.Product_Specification_Parameter__c = lstparameter1[i].Id;
            opt.Display_Order__c = i;
            opt.Description__c = 'option description ';  
            lstoption1.add(opt);
        }
        insert lstoption1;*/
        Geography__c country = TestBusinessHelper.createGeography('United States', 'Country', null, true);
        List<Trade_Route__c> lstTDR = TestBusinessHelper.createTradeRoutes(new List<String> {'MSL'},  1, true);
        Opportunity_Product__c opptyProd = TestBusinessHelper.createOpportunityLineItemCustom(oppty, product.Id, lstTDR[0], false);
        opptyprod.Id=null;
        opptyProd.Total_Mandatory_Configuration__c = 20;
        opptyProd.Total_Mandatory_Configuration_Filled__c = 10;
        opptyprod.Country__c=country.Id;
        opptyprod.Destination_Country__c=country.Id;
        insert opptyprod;

        Test.startTest();
        try{
            oppty.StageName = 'Quoting';
            update oppty;
        }catch(Exception e){
            System.debug('Exception '+e);
            Boolean expectedExceptionThrown =  e.getMessage().contains('Please check if all mandatory specification parameters are complete before moving to Quote stage!') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();  
    }
    
    /*static testmethod void testTenderOpportunityTrigger1() {
        Test.startTest();  
        // create an opportunity        
        Opportunity mslOppty = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( clientAccount.id, null );
        mslOppty.Tender_Submission_Format__c = 'Customer specific format';
        mslOppty.Customer_Requested_Rate_Structure__c = 'No';
        mslOppty.Submitted_For_approval__c = true;
        mslOppty.Expected_Tender_Receipt_Date__c = system.today();
        mslOppty.First_Round_Submission_Date__c = system.today() + 3 ;
        mslOppty.Customer_Type__c = 'BCO';
        mslOppty.Tender_Type__c  = 'Simple';
        mslOppty.StageName = 'Qualiyfying';
        update mslOppty;
        Test.stopTest();
    }
    
    static testmethod void testTenderOpportunityTrigger2() {
        Test.startTest(); 
        // create an opportunity        
        Opportunity mslOppty = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( clientAccount.id, null );
        mslOppty.Tender_Submission_Format__c = 'Customer specific format';
        mslOppty.Customer_Requested_Rate_Structure__c = 'No';
        mslOppty.Expected_Tender_Receipt_Date__c = system.today();
        mslOppty.First_Round_Submission_Date__c = system.today() + 3 ;
        mslOppty.Customer_Type__c = 'BCO';
        mslOppty.Tender_Type__c  = 'Simple';
        mslOppty.StageName = 'Qualiyfying';
        mslOppty.First_Shipment_Date__c = system.today()+ 100;
        mslOppty.Last_Shipment_Date__c = system.today() + 120;
        mslOppty.Estimated_Agreement_Duration__c = 2;
        mslOppty.Liner_Brand__c = '';
        update mslOppty;
        Test.stopTest();
    }
    
    static testmethod void testTenderOpportunityTrigger3() {
        Test.startTest(); 
        // create an opportunity        
        Opportunity mslOppty = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( clientAccount.id, null );
        mslOppty.Tender_Submission_Format__c = 'Customer specific format';
        mslOppty.Customer_Requested_Rate_Structure__c = 'No';
        mslOppty.Expected_Tender_Receipt_Date__c = system.today();
        mslOppty.First_Round_Submission_Date__c = system.today() + 3 ;
        mslOppty.Customer_Type__c = 'BCO';
        mslOppty.Tender_Type__c  = 'Simple';
        // mslOppty.StageName = 'Closed Won';
        mslOppty.First_Shipment_Date__c = system.today()+ 100;
        mslOppty.Last_Shipment_Date__c = system.today() + 120;
        mslOppty.Estimated_Agreement_Duration__c = 2;
        mslOppty.Liner_Brand__c = 'Maersk';
        update mslOppty;
        List<Product2> lstProd = DataGeneratorHelper1_Test.createProduct2( 1,'A','DE','Ocean');
        lstProd[0].Is_Features_Mandatory__c = true;
        update lstProd;
        List<PriceBookEntry> pbEntry = [select Id from PriceBookEntry where Product2Id =:lstProd[0].Id];   
        OpportunityLineItem Oli = DataGeneratorHelper1_Test.createOpportunityLineItem( mslOppty.Id, pbEntry[0].Id );
        oli.Total_Mandatory_Features__c = 2;
        oli.Total_Mandatory_Features_filled__c = 1;
        update Oli;
        Test.stopTest();
    }*/
    
    static testmethod void testCustomOliOpportunityTrigger4(){
        Test.startTest();
        Trade_Route__c tradeRoutes;
        Opportunity opportunity;
        TriggerExecutionController.skipAllTriggers(true);
        //User user1 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
        Geography__c ukCountry = TestBusinessHelper.createGeography('United Kingdom', 'Country', null, true);
        Geography__c ukState = TestBusinessHelper.createGeography('London', 'State', ukCountry.Id, true);
        Geography__c state = TestBusinessHelper.createGeography('Karnataka', 'State', country.Id, true);
        tradeRoutes = TestBusinessHelper.createTradeRoutes(new List<String>{BrandUtilities.MCC}, 1, true)[0]; 
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', false);
        clientAccount.Id = null;
        clientAccount.Vertical__c = 'Lifestyle';
        insert clientAccount;
        Contact con = TestBusinessHelper.createContact(clientAccount, 'Customer_Contact','MaerskLine', true);
        opportunity  opp = TestBusinessHelper.createOpportunity(clientAccount, con, salesUser, 'Supply_Chain_Services', BrandUtilities.MAERSKLINE, false);
        opp.Id = null;
        //opp.Requires_IT_Integration__c = 'Yes, I am sure this is required basis my discussion with customer';
        //opp.Requires_Custom_Integration__c = 'Yes, I am sure this is required basis my discussion with customer';
        insert opp;
        List<Product2> productsToInsert = new List<Product2>();
        Product2 productCustomServices = TestBusinessHelper.createProduct('Customs Services & Insurance', false);
        productCustomServices.Id = null;
        productCustomServices.Family_Code__c = 'customs_services';
        productCustomServices.OIPC_Code__c = 'P-P0-env';
        productCustomServices.Include_in_OMEB_Approvals__c = true;
        productsToInsert.add(productCustomServices);
        
        Product2 productAirLcl = TestBusinessHelper.createProduct('Air & LCL', false);
        productAirLcl.Id = null;
        productAirLcl.Family_Code__c = 'air_n_lcl';
        productAirLcl.OIPC_Code__c = 'P-P0-dw1';
        productAirLcl.Include_in_OMEB_Approvals__c = true;
        productsToInsert.add(productAirLcl);
        insert productsToInsert;
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Geography__c countryIndia = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' and name = 'India' limit 1];
        Geography__c stateKA = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'State' and name = 'Karnataka' limit 1];
        Set<Id> productIds = new Set<Id>();
        for(Product2 prod : [SELECT Id, Name FROM Product2 WHERE OIPC_Code__c IN ('P-P0-dw1','P-P0-env')]){
            productIds.add(prod.Id);
        }
        TriggerExecutionController.skipAllTriggers(false);
        TestBusinessHelper.createOpportunityLineItemCustoms(opp, productIds, tradeRoute, countryIndia, stateKA, true);
        Test.stopTest();
        
    }
    
     
     static testmethod void testAutoRenewalTrigger(){  
        ID profID = [SELECT Id FROM Profile WHERE Name = :ProfileUtilities.Sales LIMIT 1].Id;
        User maerskLineUser = [SELECT id, Region__c from User WHERE ProfileId = :profID and Maersk_User_Id__c =: 'SSS123' LIMIT 1];
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', false);
        clientAccount.Id = null;
        clientAccount.MSL_Account_Owner__c=maerskLineUser.Id;
        insert clientAccount;
        //Opportunity opportunity = [SELECT Id,Auto_Renew__c,Offer_Type__c,First_Shipment_Date__c,Last_Shipment_Date__c,CloseDate,AccountId,Liner_Brand__c, OwnerId,type,Cargo_Type__c,CreatedById FROM Opportunity WHERE Name = 'ShippingCargoServices'];
        Id supplychainrecordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.OppSupplyChainServicesRecType).getRecordTypeId();
        Opportunity opportunity = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        List<Product2> productsToInsert = new List<Product2>();
        Product2 productCustomServices = TestBusinessHelper.createProduct('Customs Services & Insurance', false);
        productCustomServices.Id = null;
        productCustomServices.Name = 'Customs Services';
        productCustomServices.Family_Code__c = 'customs_services';
        productCustomServices.OIPC_Code__c = 'P-P0-env';
        productCustomServices.Include_in_OMEB_Approvals__c = true;
        productsToInsert.add(productCustomServices);
        
        Product2 productAirLcl = TestBusinessHelper.createProduct('Air & LCL', false);
        productAirLcl.Id = null;
        productAirlcl.NAme  = 'Air Freight';
        productAirLcl.Family_Code__c = 'air_n_lcl';
        productAirLcl.OIPC_Code__c = 'P-P0-dw2';
        productAirLcl.Include_in_OMEB_Approvals__c = true;
        productsToInsert.add(productAirLcl);
        insert productsToInsert;
         
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Geography__c countryIndia = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' and name = 'India' limit 1];
        Geography__c stateKA = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'State' and name = 'Karnataka' limit 1];
        List<Product2> productList = new List<Product2>();
        for(Product2 prod : [SELECT Id, Name FROM Product2 WHERE OIPC_Code__c IN ('P-P0-dw2','P-P0-env')]){
            productList.add(prod);
        }
        TriggerExecutionController.skipAllTriggers(false);
        List<Trade_Route__c> lstTDR = TestBusinessHelper.createTradeRoutes(new List<String> {'MSL'},  1, true);
        //TestBusinessHelper.createOpportunityLineItemCustoms(opportunity, productIds, tdr1, countryIndia, stateKA, true);
        Opportunity_Product__c Oli1 = TestBusinessHelper.createOpportunityLineItemCustom(opportunity, productList[0].Id, lstTDR[0], false) ;
        Oli1.Id = null;
        Oli1.Country__c  = countryIndia.Id;
        insert Oli1;
        OpportunityTeamMember optyMember = TestBusinessHelper.createOpportunityTeamMember(maerskLineUser,opportunity,'Sales Contributor',true);
        opportunity.AccountId=clientAccount.Id;
        opportunity.Type='Renewal';
        opportunity.Cargo_Type__c = 'Dry'; 
        opportunity.OwnerId = maerskLineUser.Id; 
        opportunity.Offer_Type__c = 'Offer containing Standard T&Cs';
        opportunity.CloseDate = Date.today();
        opportunity.First_Shipment_Date__c = Date.today()+10;
        opportunity.Last_Shipment_Date__c = Date.today()+300;
        opportunity.Auto_Renew__c=true;
        opportunity.Liner_Brand__c='Maersk Line';
        opportunity.Tender_Submission_Format__c = 'No Ocean Tender';
        opportunity.Tender_Submission_Format__c = 'No Ocean Tender';
        opportunity.Requires_Custom_Integration__c = 'No, this is not required. Customer system will not connect with Maersk in any way';
        opportunity.Requires_IT_Integration__c = 'No, this is not required. Customer system will not connect with Maersk in any way';
        opportunity.Offer_Type__c = 'Offer containing Standard T&Cs';
        update opportunity;
         
        Test.startTest();
        opportunity.StageName='Closed Won';
        update opportunity;
         
        Set<Id> opptySet = new Set<Id>();
        opptySet.add(opportunity.Id);
        
        OpportunityAutoRenewal.OpportunityAutoRenewal(opptySet);
       
        List<Opportunity> oppty2 = [SELECT Id,Parent_Opportunity__c FROM Opportunity WHERE Parent_Opportunity__c = :opportunity.Id];
        if (!oppty2.isEmpty()) {
        ID renewedOpptyID = oppty2[0].Parent_Opportunity__c;
       
        System.assertEquals(renewedOpptyID, opportunity.Id);
        Test.stopTest();   
        
      } 
    
     }
    // SFSE-13409
    static testmethod void validateOpportunityP2QProduct(){
        Account clientAcc =TestBusinessHelper.createAccount('Client_Account', true);
        Opportunity mslOppty2 = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        mslOppty2.Customer_Journey__c = 'Instant Quote (Non Negotiable)';
        Test.setCreatedDate(mslOppty2.Id, system.today().toStartOfMonth());
        mslOppty2.CloseDate = Date.today().addDays(Date.today().toStartOfMonth().Day() + 1);
        mslOppty2.First_Shipment_Date__c = Date.today().addDays(Date.today().toStartOfMonth().Day() + 2);
        mslOppty2.Last_Shipment_Date__c =  Date.today().addDays(Date.today().toStartOfMonth().Day() + 3);
        Test.startTest();
        update mslOppty2;
        Product2 latestProduct= TestBusinessHelper.createProduct('ocean', true);
        List<Product2> prodIns = [Select id,name,Product_Scope__c from Product2 where id =: latestProduct.id];
        prodIns[0].Product_Scope__c = 'Included In P2Q';
        update prodIns;
        List<Trade_Route__c> lstTDR = TestBusinessHelper.createTradeRoutes(new List<String> {'MSL'},  1, true);
        Opportunity_Product__c Oli1 = TestBusinessHelper.createOpportunityLineItemCustom(mslOppty2, prodIns[0].id,lstTDR[0], true) ;
       
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,Must_Go_To_OMEB__c,
                                  Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,Approval_Required__c,Requires_Custom_Integration__c,
                                  First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,Approval_status__c,
                                  Expected_Tender_Receipt_Date__c,Customer_Journey__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,Requires_IT_Integration__c,Opportunity_Ref__c,Opportunity_Owner_Country__c,
                                  Expected_Handling_Rounds__c, Pricebook2Id
                                  FROM Opportunity  limit 1 ];
       List<Opportunity_Product__c> oli = [Select id,name,Product_Scope__c from Opportunity_Product__c where id=:Oli1.id];
       System.debug('olilist2' + oli);
       delete oli;
       opp[0].Customer_Journey__c = 'As-Is Journey';
       try{
       update opp;
       System.AssertEquals(1, opp.size(), 'Expected 1 record to be updated');
       }catch(Exception e){
          System.debug('Exception caught: ' + e.getMessage());  
       }
       Test.stopTest();
        
        
    }
     //SFSE - SFSE-13409
    static testmethod void validateOpportunityNonP2QProduct(){
        Test.startTest();
        Account clientAcc =TestBusinessHelper.createAccount('Client_Account', true);
        Opportunity mslOppty2 = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        mslOppty2.Customer_Journey__c = 'As-Is Journey';
        update mslOppty2;
        Product2 latestProduct= TestBusinessHelper.createProduct('ocean', true);
        List<Product2> prodIns = [Select id,name,Product_Scope__c from Product2 where id =: latestProduct.id];
        prodIns[0].Product_Scope__c = 'Included In Email Agreement';
        update prodIns;
        List<Trade_Route__c> lstTDR = TestBusinessHelper.createTradeRoutes(new List<String> {'MSL'},  1, true);
        Opportunity_Product__c Oli1 = TestBusinessHelper.createOpportunityLineItemCustom(mslOppty2, prodIns[0].id,lstTDR[0], true) ;
        
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,Must_Go_To_OMEB__c,
                                  Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,Approval_Required__c,Requires_Custom_Integration__c,
                                  First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,Approval_status__c,
                                  Expected_Tender_Receipt_Date__c,Customer_Journey__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,Requires_IT_Integration__c,Opportunity_Ref__c,Opportunity_Owner_Country__c,
                                  Expected_Handling_Rounds__c, Pricebook2Id
                                  FROM Opportunity  limit 1 ];
       List<Opportunity_Product__c> oli = [Select id,name,Product_Scope__c from Opportunity_Product__c where id=:Oli1.id];
       System.debug('olilist1' + oli);
       delete oli;
       opp[0].Customer_Journey__c = label.Instant_Quote;
       opp[0].First_Shipment_Date__c = system.today()+11;
       opp[0].Last_Shipment_Date__c = system.today()+20; 
       try{
       update opp;
       System.AssertEquals(1, opp.size(), 'Expected 1 record to be updated');
       }catch(Exception e){
          System.debug('Exception caught: ' + e.getMessage());  
       }
       Test.stopTest();
        
        
    }
      static testmethod void testRenewalCL(){
        Test.startTest();
        Trade_Route__c tradeRoutes;
        Opportunity opportunity;
     
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
        
        Geography__c state = TestBusinessHelper.createGeography('Karnataka', 'State', country.Id, true);
        tradeRoutes = TestBusinessHelper.createTradeRoutes(new List<String>{BrandUtilities.MCC}, 1, true)[0]; 
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', false);
        clientAccount.Id = null;
        clientAccount.Vertical__c = 'Lifestyle';
        insert clientAccount;
        Contact con = TestBusinessHelper.createContact(clientAccount, 'Customer_Contact','MaerskLine', true);
        opportunity  opp = TestBusinessHelper.createOpportunity(clientAccount, con, salesUser, 'Supply_Chain_Services', BrandUtilities.MAERSKLINE, false);
        opp.Id = null;
          opp.Last_Shipment_Date__c = System.today() + 180;
          opp.First_Shipment_Date__c = System.today() + 60;
          opp.Estimated_Agreement_Duration__c = 30;
          opp.Type = 'Renewal';
          opp.Requires_IT_Integration__c = 'No, this is not required. Customer system will not connect with Maersk in any way';
        insert opp;
        Assert.isNull(opp.Products_for_Approval__c);
        Assert.areEqual(false, opp.Must_Go_To_OMEB__c);  
        List<Product2> productsToInsert = new List<Product2>();
        Product2 productCL = TestBusinessHelper.createProduct('Warehousing & Fulfilment', false);
        productCL.Id = null;
        productCL.Family_Code__c = 'warehousing_fulfilment';
        productCL.OIPC_Code__c = 'P-P0-dw9';
        productCL.Portfolio__c = 'LnS';
        productCL.Include_in_OMEB_Approvals__c = true;
        productsToInsert.add(productCL);
 
        insert productsToInsert;
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Geography__c countryIndia = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' and name = 'India' limit 1];
        Geography__c stateKA = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'State' and name = 'Karnataka' limit 1];
        Set<Id> productIds = new Set<Id>();
        for(Product2 prod : [SELECT Id, Name FROM Product2 WHERE OIPC_Code__c IN ('P-P0-dw9')]){
            productIds.add(prod.Id);
        }
       
        Warehouse_Site__c wh = new Warehouse_Site__c();
        wh.Site_Id__c = '12345';
        wh.Name = 'Test Warehouse Site';
        wh.Country__c = country.Id;
        wh.Status__c = 'Active';
        insert wh;
          
        Opportunity_Product__c opptyProd = TestBusinessHelper.createOpportunityLineItemCustom(opp, productCL.Id, tradeRoutes, false);
        opptyProd.Id = null;
        opptyProd.Country__c = country.Id;
        opptyProd.Quantity__c = 10;
        opptyProd.UnitPrice__c = 10;
        opptyProd.Product_Revenue_Per_Unit__c = 1;
        opptyProd.L_S_Product__c = True;
        opptyProd.Warehouse_Site__c = wh.Id;
        opptyProd.Estimated_Footprint_Requirement_in_Sqm__c = 100;
        insert opptyprod;
       
        opportunity = [Select id ,Must_Go_To_OMEB__c,Products_for_Approval__c from Opportunity where id=:opp.id];
        system.debug('opptyProd@@' + [Select id, Exclude_from_OMEB__c ,Annualized_Gross_Profit__c ,UnitPrice__c from Opportunity_Product__c Where id =: opptyProd.Id]);
        // Type= Renewal and Requires IT = No , Product = CL --> Must go to OMEB = false  
        //Assert.areEqual(false, opportunity.Must_Go_To_OMEB__c);  
          
        opportunity.Type = 'Acquisition';
        Update opportunity; 
  
         
        // Type= Acquisition and Requires IT = No , Product = CL --> Must go to OMEB = true  
        opportunity = [Select id ,Must_Go_To_OMEB__c,Products_for_Approval__c from Opportunity where id=:opp.id];
        Assert.areEqual(true, opportunity.Must_Go_To_OMEB__c);  
        

    }
    static testmethod void testAliancaOMEB(){
      Test.startTest();
        Trade_Route__c tradeRoutes;
        Opportunity opportunity;
     
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
        
        Geography__c state = TestBusinessHelper.createGeography('Karnataka', 'State', country.Id, true);
        tradeRoutes = TestBusinessHelper.createTradeRoutes(new List<String>{BrandUtilities.MCC}, 1, true)[0]; 
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', false);
        clientAccount.Id = null;
        clientAccount.Vertical__c = 'Lifestyle';
        insert clientAccount;
        Contact con = TestBusinessHelper.createContact(clientAccount, 'Customer_Contact','MaerskLine', true);
        opportunity  opp = TestBusinessHelper.createOpportunity(clientAccount, con, salesUser, 'Supply_Chain_Services', BrandUtilities.MAERSKLINE, false);
        opp.Id = null;
          opp.Last_Shipment_Date__c = System.today() + 180;
          opp.First_Shipment_Date__c = System.today() + 60;
          opp.Estimated_Agreement_Duration__c = 30;
          opp.Liner_Brand__c = 'Alianca';
        insert opp;
        Assert.isNull(opp.Products_for_Approval__c);
        Assert.areEqual(false, opp.Must_Go_To_OMEB__c);  
        List<Product2> productsToInsert = new List<Product2>();
        Product2 productCL = TestBusinessHelper.createProduct('Warehousing & Fulfilment', false);
        productCL.Id = null;
        productCL.Family_Code__c = 'warehousing_fulfilment';
        productCL.OIPC_Code__c = 'P-P0-dw9';
        productCL.Portfolio__c = 'LnS';
        productCL.Include_in_OMEB_Approvals__c = true;
        productsToInsert.add(productCL);
 
        insert productsToInsert;
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Geography__c countryIndia = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' and name = 'India' limit 1];
        Geography__c stateKA = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'State' and name = 'Karnataka' limit 1];
        Set<Id> productIds = new Set<Id>();
        for(Product2 prod : [SELECT Id, Name FROM Product2 WHERE OIPC_Code__c IN ('P-P0-dw9')]){
            productIds.add(prod.Id);
        }
        
        Warehouse_Site__c wh = new Warehouse_Site__c();
        wh.Site_Id__c = '12345';
        wh.Name = 'Test Warehouse Site';
        wh.Country__c = country.Id;
        wh.Status__c = 'Active';
        insert wh;
       
        Opportunity_Product__c opptyProd = TestBusinessHelper.createOpportunityLineItemCustom(opp, productCL.Id, tradeRoutes, false);
        opptyProd.Id = null;
        opptyProd.Country__c = country.Id;
        opptyProd.Quantity__c = 10;
        opptyProd.UnitPrice__c = 10;
        opptyProd.Product_Revenue_Per_Unit__c = 1;
        opptyProd.L_S_Product__c = True;
        opptyProd.Warehouse_Site__c = wh.Id;
        opptyProd.Estimated_Footprint_Requirement_in_Sqm__c = 100;
        insert opptyprod;
       
        opportunity = [Select id ,Must_Go_To_OMEB__c,Products_for_Approval__c from Opportunity where id=:opp.id];
        system.debug('opptyProd@@' + [Select id, Exclude_from_OMEB__c ,Annualized_Gross_Profit__c ,UnitPrice__c from Opportunity_Product__c Where id =: opptyProd.Id]);
        Assert.areEqual(true, opportunity.Must_Go_To_OMEB__c);  
          
    }
    
    static testMethod void ValidateEstimatedSqmField(){
        
        Trade_Route__c tradeRoutes;
        Opportunity opportunity;
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
        tradeRoutes = TestBusinessHelper.createTradeRoutes(new List<String>{BrandUtilities.MCC}, 1, true)[0]; 
        List<Opportunity> opp = [Select Id,name from Opportunity];
        List<Product2> productsToInsert = new List<Product2>();
        Product2 productCL = TestBusinessHelper.createProduct('Warehousing & Fulfilment', false);
        productCL.Id = null;
        productCL.Family_Code__c = 'warehousing_fulfilment';
        productCL.OIPC_Code__c = 'P-P0-dw9';
        productCL.Family = 'warehousing_fulfilment';
        productCL.Portfolio__c = 'LnS';
        productCL.Include_in_OMEB_Approvals__c = false;
        productsToInsert.add(productCL);
        insert productsToInsert;
         Warehouse_Site__c wh = new Warehouse_Site__c();
        wh.Site_Id__c = '12345';
        wh.Name = 'Test Warehouse Site';
        wh.Country__c = country.Id;
        wh.Status__c = 'Active';
        insert wh;
        Opportunity_Product__c opptyProd = TestBusinessHelper.createOpportunityLineItemCustom(opp[0], productCL.Id, tradeRoutes, false);
        opptyProd.Id = null;
        opptyProd.Country__c = country.Id;
        opptyProd.Quantity__c = 10;
        opptyProd.UnitPrice__c = 10;
        opptyProd.Product_Revenue_Per_Unit__c = 1;
        opptyProd.L_S_Product__c = True;
        opptyProd.Warehouse_Site__c = wh.id;
        opptyProd.Estimated_Footprint_Requirement_in_Sqm__c = 100;
        insert opptyprod;
        Test.startTest();
        opp[0].StageName = 'Qualifying';
        Update opp;
        Test.stopTest();       
    }
 }