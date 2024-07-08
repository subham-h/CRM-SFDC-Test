/**
* Test class for : OpportunityUtilities

* Date         Owner                                           Description
******************************************************************************************************************************
* 10/10/2016   meghana.gupta@ust-global.com               Test Class Optimization
* 03/07/2017   sandhya.sambasivan@ust-global.co           #RQ-5190:     Added Lead Route
* 27/04/2018   jiji.jayasingh@ust-global.com                            To include Tender workflow test scenarios
* 09/04/2018   Junaid.Khader@ust-global.com                             Modified method test_OpportunityUtilities2 to do the update only between Test.startTest and Test.stopTest
* 06-Jun-2019  manjunath.c.holekade@maersk.com            #RQ-010819    Removal of references of deprecated fields
* 19-Jun-2019  Neha TCS                                   #RQ-011061    SOQL 101 issue
* 29-Nov-2019  manjunath@maersk                           #RQ-012233    Created test data for BDA-Geography
* 16-Oct-2020  meghana@UST                                SFSE-4767     Remove Safmarine related test code
* 03-Mar-2021  Meghana@UST                                              Remove use of OLI field Meets OMEB
* 14-Jun-2021  Kiran@Maersk                               SFSE-6393     Remove Project_Task__c references   
* 7-Oct-2022   Meghana@UST                                SFSE-9418     Replace “Requires IT Solution” field with “Require IT Integration?”
* 2-Jan-2023   Aleena@Maersk                              SFSE-9813     Created test data for createOMEBKpi and updateOMEBKpi
* 8-Aug-2023   Shashi@Maersk                              SFSE-10610    created test_opptyProdFinancialFields 
* 22-Sep-2023  Shashi@Maersk                              SFSE-12560    removing test_opptyProdFinancialFields
* 04-Jan-2024  Jothsana@Maersk							  SFSE-13322	Remove the logic added for OMEB_Process_KPI__c object
* 02-Feb-2024  Shilpa@Maersk                              SFSE-13802    Added Method to validate Customer journey field is not change if file uploaded
* 05-Feb-2024  Avinash@Maersk							  SFSE-12654	Clone and auto-renew an opportunity with the latest solution version 
* 16-Feb-2024  Vinay@Maersk								  SFSE-14250	Added method to cover Clonning of Opportunity
* 06-May-2024  Shashi@Maersk                              SFSE-13391    Added methods to cover Opportunity Locking/Unlocking scenarios
*/


@isTest
private class OpportunityUtilities_Test{
    
    static Account clientAcc;
    static PriceBookEntry pbEntry;
    static List<Product2> pdt1;
    static BDA__c recParentBDA;
    static BDA__c recBDA ;
    
    static  {
        TriggerExecutionController.skipAllTriggers(true);
        clientAcc =TestBusinessHelper.createAccount('Client_Account', true);
        Account acc= [Select id,vertical__C from Account where id =: clientAcc.id];
        acc.vertical__c='Lifestyle';
        update acc;
        Opportunity mslOppty2 =  TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        Product2 latestProduct= TestBusinessHelper.createProduct('ocean', true);
        List<Trade_Route__c> lstTDR = TestBusinessHelper.createTradeRoutes(new List<String> {'MSL'},  1, true);
        Opportunity_Product__c Oli1 = TestBusinessHelper.createOpportunityLineItemCustom(mslOppty2, latestProduct.id,lstTDR[0], true) ;
        
        ////SFSE-12654 - Creating Solution
        Product2 solution1 = TestBusinessHelper.createProduct('Ocean', true);  
        solution1.OIPC_Code__c='s-p0-123';
        solution1.Portfolio__c='Ocean';
        solution1.Version__c=1;
        solution1.IsActive=true;
        solution1.Product_Status__c='Ready-to-sell';
        solution1.Latest_Product_Version__c=null;
        solution1.Is_Product_Solution__c = true;
        solution1.Definition_Type__c = 'Packaged Solution';
        update solution1;
        
        TestBusinessHelper.createProductReference(solution1.Id,new List<String>{latestProduct.Id},true);
        
        Product2 solution2 = TestBusinessHelper.createProduct('Ocean', true);
        solution2.OIPC_Code__c='s-p0-123';
        solution2.Portfolio__c='Ocean';
        solution2.Version__c=2;
        solution2.IsActive=false;
        solution2.Is_Product_Solution__c = true;
        solution2.Definition_Type__c = 'Packaged Solution';
        update solution2;
        
        TestBusinessHelper.createProductReference(solution2.Id,new List<String>{latestProduct.Id},true);
		//SFSE-12654
		        
        Quotes__c quote= new Quotes__c();
        quote.Status__c='Negotiation Initiated';
        quote.Negotiation_Round__c =1;
        quote.Negotiation_Source__c='CRM';
        quote.Opportunity__c = mslOppty2.Id;
        insert quote; 
        Opportunity_File__c file = new Opportunity_File__c();
        file.File_Category__c='RFQ/Nomination File';
        file.Quote__c=quote.id;
        file.Opportunity__c= mslOppty2.Id;
        file.Name='test\\.test';
        insert file; 
        Id StdPricebook = Test.getStandardPricebookId();
        pdt1 = new List<Product2>{TestBusinessHelper.createProduct('Ocean', true)};
        // pbEntry = [select Id from PriceBookEntry where Product2Id =:pdt1[0].Id];
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Update standardPricebook;
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
        Geography__c state = TestBusinessHelper.createGeography('Karnataka', 'State', country.Id, true);
        BDA__c recParentBDA = TestBusinessHelper.createBDA('India, Middle East, and Africa', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true);
        BDA__c recBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'IBS', recParentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(recBDA.Id, country.Id, null, true);         
        TriggerExecutionController.skipAllTriggers(false);

    }    

    //SFSE-12654
    @isTest
    static void test_CloneWithLatestWithPSUpgrade(){
        TriggerExecutionController.skipAllTriggers(true);
		Test.startTest();
        
        Product2 solution1 = [SELECT Id FROM Product2 WHERE Is_Product_Solution__c=true AND Version__c=1];
        Product2 solution2 = [SELECT Id FROM Product2 WHERE Is_Product_Solution__c=true AND Version__c=2];
            
        solution1.IsActive=true;
        solution1.Latest_Product_Version__c=null;
        update solution1;
        
        Product2 prod = [Select Id from Product2 where Is_Product_Solution__c = false LIMIT 1];
        
	    Opportunity optyRecCloned = [Select Id,name from Opportunity];
        
        Opportunity_Product__c opptyProd1 = TestBusinessHelper.createOpportunityLineItemCustom(optyRecCloned, prod.id,null, true);
        opptyProd1.Solution__c = solution1.Id;
        update opptyProd1;
        
        Opportunity optyRecToBeCloned =TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        
        solution1.IsActive=false;
        solution1.Latest_Product_Version__c=solution2.Id;
        update solution1;
        
        solution2.IsActive=true;
        solution2.Latest_Product_Version__c=null;
        update solution2;
        
        OpportunityUtilities.cloneOpporutnityProductsWithLatest(new Map<id, Id>{optyRecToBeCloned.id=>optyRecCloned.id});
        
        Test.stopTest();
        List<Opportunity_Product__c> lstCustomOLI = [Select Id from Opportunity_Product__c where OpportunityId__c =: optyRecToBeCloned.Id];
        System.assertEquals(true, lstCustomOLI.size() > 0);
    }   
    
    //SFSE-12654
    @isTest
    static void test_CloneWithLatestWithActivePS(){
        TriggerExecutionController.skipAllTriggers(true);
		Test.startTest();
        
        Product2 solution1 = [SELECT Id FROM Product2 WHERE Is_Product_Solution__c=true AND Version__c=1];
            
        solution1.IsActive=true;
        solution1.Latest_Product_Version__c=null;
        update solution1;
        
        Product2 prod = [Select Id from Product2 where Is_Product_Solution__c = false LIMIT 1];
        
	    Opportunity optyRecCloned = [Select Id,name from Opportunity];
        
        Opportunity_Product__c opptyProd1 = TestBusinessHelper.createOpportunityLineItemCustom(optyRecCloned, prod.id,null, true);
        opptyProd1.Solution__c = solution1.Id;
        update opptyProd1;
        
        Opportunity optyRecToBeCloned =TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        
        OpportunityUtilities.cloneOpporutnityProductsWithLatest(new Map<id, Id>{optyRecToBeCloned.id=>optyRecCloned.id});
        
        Test.stopTest();
        List<Opportunity_Product__c> lstCustomOLI = [Select Id from Opportunity_Product__c where OpportunityId__c =: optyRecToBeCloned.Id];
        System.assertEquals(true, lstCustomOLI.size() > 0);
    }
    
    static testMethod void test_UnlockApprovalProcessRecord() {
        test.startTest();  
       // Opportunity mslOppty2 =  TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        List<Opportunity> mslOppty2 = [Select Id,name,Custom_L_S_Solution_Required__c,Approval_Status__c,Products_for_Approval__c,Requires_IT_Integration__c,Submitted_For_approval__c,Must_Go_To_OMEB__c from Opportunity];
        mslOppty2[0].Custom_L_S_Solution_Required__c = 'Yes';
        mslOppty2[0].Approval_Status__c = 'Approved - Pursuit Gate';
        mslOppty2[0].Products_for_Approval__c = 'SCM';
        //mslOppty2.Requires_IT_Solution__c = true;
         mslOppty2[0].Requires_IT_Integration__c = 'Yes, I am sure this is required basis my discussion with customer';
         mslOppty2[0].Submitted_For_approval__c = true;
         mslOppty2[0].Must_Go_To_OMEB__c = true;
        update mslOppty2;
        test.stopTest();
    }
    static testMethod void test_cloneOpporutnityProductsWithLatest(){
        TriggerExecutionController.skipOpportunityTrigger(true);
       // Opportunity mslOppty1 = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        Opportunity mslOppty2 = [Select Id,name,Custom_L_S_Solution_Required__c,Approval_Status__c,Products_for_Approval__c,Requires_IT_Integration__c,Submitted_For_approval__c,Must_Go_To_OMEB__c from Opportunity];
        mslOppty2.Custom_L_S_Solution_Required__c = 'Yes';
        mslOppty2.Approval_Status__c = 'Approved - Pursuit Gate';
        mslOppty2.Products_for_Approval__c = 'SCM';
        //mslOppty2.Requires_IT_Solution__c = true;
        mslOppty2.Requires_IT_Integration__c = 'Yes, I am sure this is required basis my discussion with customer';
        mslOppty2.Submitted_For_approval__c = true;
        mslOppty2.Must_Go_To_OMEB__c = true;
        update mslOppty2;
        TriggerExecutionController.skipOpportunityTrigger(false);
        test.startTest();
        //List<Opportunity> mslOppty3 = [Select Id,name,Custom_L_S_Solution_Required__c,Clone_Opportunity_Source__c,Approval_Status__c,Products_for_Approval__c,Requires_IT_Integration__c,Submitted_For_approval__c,Must_Go_To_OMEB__c from Opportunity];
        Opportunity mslOppty3 =TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        mslOppty3.Clone_Opportunity_Source__c = mslOppty2.Id;
        Update mslOppty3; 
        test.stopTest();              
    }
    
    /**@isTest 
    static void test_opptyProdFinancialFields(){
        TriggerExecutionController.skipAllTriggers(true);
        User maerskLineUser = TestBusinessHelper.createUser('Sales', Brand__mdt.getInstance('MaerskLine').MasterLabel, false);
        System.runAs(new User(Id = UserInfo.getUserId())){
            maerskLineUser.Id = null;
            //maerskLineUser.FederationIdentifier='testmsluser@maersk.com';
            maerskLineUser.CM_Visibility__c='Single Carrier';
            insert maerskLineUser;
        }
        
        Geography__c country = TestBusinessHelper.createGeography('United States', 'Country', null, true);
        Geography__c city = TestBusinessHelper.createGeography('Colorado', 'City', country.Id, true);
        
        Account account = TestBusinessHelper.createAccount(maerskLineUser, country, 'Client_Account', false);
        account.Id = null;
        account.OwnerId = maerskLineUser.Id;     
        insert account;
        
        Contact contact = TestBusinessHelper.createContact(account, 'Customer_Contact', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
        
        Opportunity opportunity = TestBusinessHelper.createOpportunity(account, contact, null, 'ShippingCargoServices', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
        opportunity.Cargo_Type__c = 'Dry';
        opportunity.OwnerId = maerskLineUser.Id; //creating oppty owner
        opportunity.Offer_Type__c = 'Offer containing Standard T&Cs';
        //opportunity.StageName='Designing Proposal';
        update opportunity;
        Product2 product = TestBusinessHelper.createProduct('Contract Logistics', true);  
        product.OIPC_Code__c='P-P0-dwd';
        product.Include_in_OMEB_Approvals__c=false;
        product.Portfolio__c='LnS';
        product.Version__c=1;
        product.IsActive=true;
        product.Product_Status__c='Ready-to-sell';
        update product;
        
        TriggerExecutionController.skipAllTriggers(false);
        
        Test.startTest();
        try{
            Opportunity_Product__c opptyProd = TestBusinessHelper.createOpportunityLineItemCustom(opportunity, product.Id, null, country, city, true);
            opportunity.StageName='Quoting';
            update opportunity;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.Revenue_EBIT_Indirect_SG_A_Capex_NPV_and_IRR_fields_must_be_updated_before) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        Test.stopTest();
    }*/
    
    //To test tender workflow
    static testMethod void test_tenderWorkflow() {
        Test.startTest();  
        List<Project_Milestone_Mapping__mdt> projMilestoneList = new List<Project_Milestone_Mapping__mdt> ();
        for(Project_Milestone_Mapping__mdt projMilestoneMapping : [select MasterLabel,DeveloperName, 
                                                                   Milestone_Name__c, Order__c, 
                                                                   Milestones_Grouping__c,
                                                                   Reference_Date__c
                                                                   from Project_Milestone_Mapping__mdt 
                                                                   where Milestones_Grouping__c ='Preparation' 
                                                                   Order By Order__c]){
                                                                       
                                                                       projMilestoneList.add(projMilestoneMapping);                                                  
                                                                   }
        Map<String,Boolean> projTempMap = new Map<String,Boolean>();
        for(Project_Template_Mapping__mdt projTemplateMapping : [select MasterLabel,DeveloperName, isQualified__c
                                                                 from Project_Template_Mapping__mdt 
                                                                 where isQualified__c = TRUE]){
                                                                     
                                                                     projTempMap.put(projTemplateMapping.DeveloperName, projTemplateMapping.isQualified__c);                                                  
                                                                 }
        Opportunity mslOppty2 = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        mslOppty2.Customer_Type__c = 'Freight Forwarder';
        mslOppty2.Named_Account__c = mslOppty2.AccountId;
        //mslOppty2.First_Round_Submission_Date__c = NULL;
        update mslOppty2;
        
        mslOppty2.Customer_Type__c = 'BCO';
        mslOppty2.Named_Account__c = NULL;
        mslOppty2.First_Round_Submission_Date__c = system.today()+400;
        update mslOppty2;
        
        Test.stopTest();
        
    }
    
    static testMethod void test_ChatterPost2() {
        Test.startTest();       
        //Opportunity Oppty2 = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'Opportunity_Record_Type', BrandUtilities.MAERSKLINE, false);
        Opportunity mslOppty3 = [Select Id,name,Custom_L_S_Solution_Required__c,Clone_Opportunity_Source__c,Approval_Status__c,Products_for_Approval__c,Requires_IT_Integration__c,Submitted_For_approval__c,Must_Go_To_OMEB__c from Opportunity];
       
        Test.stopTest();        
    }
    
    static testMethod void test_ChatterPost3() {
        Test.startTest();       
        Opportunity Oppty2 = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'Opportunity_Record_Type', BrandUtilities.MAERSKLINE, false);
        Test.stopTest();        
    }
    
    static testMethod void test_ChatterPost4() {
        Test.startTest();       
        Opportunity Oppty2 = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'Opportunity_Record_Type', BrandUtilities.MAERSKLINE, false);
        Test.stopTest();        
    }
    
    static testMethod void test_ChatterPost5() {
        Test.startTest();       
        Opportunity Oppty2 = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'Opportunity_Record_Type', BrandUtilities.MAERSKLINE, false);
        Test.stopTest();        
    }
    static testMethod void test_TenderProcess() {
        Test.startTest();
        Opportunity mslOppty2 = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        if(pdt1.size() > 0){
            pdt1[0].Trade__c = 'AFR';
            update pdt1;
            List<Project_Template__c> listTemplates = new List<Project_Template__c>();
            for(Project_Template__c projTemplateRow : [SELECT Id, Lead_Route__c FROM Project_Template__c WHERE Lead_Route__c = null LIMIT 1]){
                projTemplateRow.Lead_Route__c = pdt1[0].Id;
                listTemplates.add(projTemplateRow);
            }
            if(listTemplates.size() > 0)
                update listTemplates;
        }
        Test.stopTest();
    }
    
    static testmethod void testreamingmethods(){
        
        TriggerExecutionController.skipAllTriggers(true);
        TriggerExecutionController.skipOpportunityTrigger(true);
        TriggerExecutionController.skipOpportunityProductTrigger(true);
        Contract__c cont = new Contract__c();
        cont.Agreement_Type_Code__c = 'Credit_Agreement';
        cont.Brand_Name__c = 'Maersk Line';
        cont.Customer__c = clientAcc.Id;
        cont.Effective_Date__c = system.today();
        cont.Expiration_Date__c = system.today() + 10;
        cont.Is_FMC_Contract__c = false;
        cont.Is_Master_Contract__c = false;
        cont.Status__c = 'Draft';
        insert cont;
        Opportunity mslOppty2 = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        
        Opportunity recOpportunity = new Opportunity();
        recOpportunity.Name =  BrandUtilities.MAERSKLINE + ' Test QuarterDeal';
        recOpportunity.AccountId = clientAcc.id;
        recOpportunity.Liner_Brand__c= BrandUtilities.MAERSKLINE;
        recOpportunity.Type = 'Quarterly Deal Acquisition';
        recOpportunity.CloseDate = date.today() + 90;
        recOpportunity.StageName = 'Identifying';
        recOpportunity.CloseDate = date.today() + 30;
        recOpportunity.First_Shipment_Date__c = date.today() + 100;
        recOpportunity.Last_Shipment_Date__c = date.today() + 130;
        recOpportunity.Commodity__c = 'Pharmaceuticals';
        recOpportunity.Freetime_Terms__c='No';
        recOpportunity.recordtypeid=System.label.QuarterlyDealsRecordTypeId;
        recOpportunity.Opportunity_contains_Dangerous_Goods__c = 'No';
        recOpportunity.Offer_Type__c = 'Offer containing Standard T&Cs';
        recOpportunity.Parent_Opportunity__c = mslOppty2.id;
        insert recOpportunity;
        Opportunity_Contract__c opc = new Opportunity_Contract__c();
        opc.Contract__c = cont.Id;
        opc.Opportunity__c = mslOppty2.Id;
        insert opc;
        
        Product2 prod= [Select id, oipc_code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
        prod.Is_Features_Mandatory__c =true;
        update prod;
        Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE isStandard = true]; 
        List<Trade_Route__c> lstTradeRoute = TestBusinessHelper.createTradeRoutes(new List<String>{'MCC'}, 1,true);

        
        //PricebookEntry pbe=[select Id from PriceBookEntry where Product2Id =:prod.Id];
        Opportunity_Product__c Oli = New Opportunity_Product__c();
        Oli.OpportunityId__c = mslOppty2.Id;
        Oli.Quantity__c = 1;
        oli.Product2ID__c= prod.id;
        Oli.UnitPrice__c = 1;
        Oli.Product_Revenue_Per_Unit__c = 1;
        oli.Opt_Out_Auto_Quantity_Scheduling__c = false;
        Oli.Tender_Target__c = 1;
        oli.Total_Configurations__c=10;
        oli.Total_Configurations_Filled__c =9;
        oli.Total_Mandatory_Configuration__c=8;
        oli.Total_Mandatory_Configuration_Filled__c=7;
        oli.trade_route__c= lstTradeRoute[0].Id;
        insert oli;
        TriggerExecutionController.skipAllTriggers(false);
        TriggerExecutionController.skipOpportunityTrigger(false);
        TriggerExecutionController.skipOpportunityProductTrigger(false);
        try{ Test.startTest();
            OpportunityUtilities.shareContract(new List<Opportunity>{mslOppty2},new map<Id, Opportunity>{mslOppty2.id => mslOppty2});
            OpportunityUtilities.UpdateAFLSQuoteOwner(new List<Opportunity>{mslOppty2});
            
            OpportunityUtilities.CheckIfParent(new List<Opportunity>{mslOppty2,recOpportunity});
            OpportunityUtilities.validateFeaturesMandatory(new List<Opportunity>{mslOppty2,recOpportunity});
            test.stopTest();
           }catch(Exception ex){
               System.debug('Exception '+ex);
           }
        
    }
    
    
    static testmethod void testcloningMethod(){
        
        TriggerExecutionController.skipAllTriggers(true);
        TriggerExecutionController.skipOpportunityTrigger(true);
        TriggerExecutionController.skipOpportunityProductTrigger(true);
        Product2 prod= [Select id, oipc_code__c , Include_in_OMEB_Approvals__c from Product2 limit 1];
        prod.Is_Features_Mandatory__c =true;
        update prod;
        
        Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE isStandard = true]; 
        // PricebookEntry pbe=[select Id from PriceBookEntry where Product2Id =:prod.Id];
        List<Trade_Route__c> lstTradeRoute = TestBusinessHelper.createTradeRoutes(new List<String>{'MCC'}, 1,true);

        Opportunity mslOppty2 = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        Opportunity_Product__c Oli = New Opportunity_Product__c();
        Oli.OpportunityId__c = mslOppty2.Id;
        Oli.Quantity__c = 1;
        oli.Product2ID__c= prod.id;
        Oli.UnitPrice__c = 1;
        Oli.Product_Revenue_Per_Unit__c = 1;
        oli.Opt_Out_Auto_Quantity_Scheduling__c = false;
        Oli.Tender_Target__c = 1;
        oli.Total_Configurations__c=10;
        oli.Total_Configurations_Filled__c =9;
        oli.Total_Mandatory_Configuration__c=8;
        oli.Total_Mandatory_Configuration_Filled__c=7;
        Oli.Trade_Route__c = lstTradeRoute[0].Id;
        insert oli;
       
        List<Product_Component__c> comps =  new List<Product_Component__c>();
        for (integer i = 1; i <= 2; i++){
            Product_Component__c pc = new Product_Component__c();
            pc.Name = 'Comp' + i;
            pc.Component_Code__c = 'PC' + i;
          	pc.Product__c = prod.Id;
            pc.Display_Order__c = i;
            comps.add(pc);
        }
        insert comps;
		
        List<Product_Feature__c> lstfeat = new List<Product_Feature__c>();
        
        for (integer i = 0; i < 2; i++){
            
            Product_Feature__c f = new Product_Feature__c();
            f.Name = 'Feature' + i;
            f.Feature_Code__c = 'F' + i;
            f.Product_Component__c = comps[i].Id;
            f.Display_Order__c = i;
            f.Description__c = 'Feature description ';           
            lstfeat.add(f);
        }

        insert lstfeat;

        List<Product_Specification_Parameter__c> lstparameter = new List<Product_Specification_Parameter__c>();

        for(integer i=0;i<2;i++){
            Product_Specification_Parameter__c para = new Product_Specification_Parameter__c();
            para.Name = 'paramter' + i;
            para.Specification_Parameter_Code__c = 'SP' + i;
            para.Product_Feature__c = lstfeat[i].Id;
            para.Display_Order__c = i;
            para.type__c='options';
            para.Description__c = 'Parameter description ';  
            lstparameter.add(para);
        }
        insert lstparameter;

        List<Product_Specification_Option__c> lstoption = new List<Product_Specification_Option__c>();

        for(integer i=0;i<2;i++){
            Product_Specification_Option__c opt = new Product_Specification_Option__c();
            opt.Name = 'option' + i;
            opt.Specification_Option_Name__c = 'option' + i;
            opt.Specification_Option_Code__c = 'SPC' + i;
            opt.Product_Specification_Parameter__c = lstparameter[i].Id;
            opt.Display_Order__c = i;
            opt.Description__c = 'option description ';  
            lstoption.add(opt);
        }
        insert lstoption;
        
        List<Opportunity_Product_Configuration__c> lstconfig= new list<Opportunity_Product_Configuration__c>();

        for(integer i=0;i<2;i++){
            Opportunity_Product_Configuration__c config= new Opportunity_Product_Configuration__c();
            config.Opportunity_Product_Cus__c = oli.id;
            config.Product_Specification_Option__c = lstoption[i].id;
            config.Product_Specificaiton_Parameter__c = lstparameter[i].id;
            config.name='test'+i;
            lstconfig.add(config);
        }
        insert lstconfig;
        Test.startTest();
        Opportunity recOpportunity = new Opportunity();
        recOpportunity.Name =  BrandUtilities.MAERSKLINE + ' Test QuarterDeal';
        recOpportunity.AccountId = clientAcc.id;
        recOpportunity.Liner_Brand__c= BrandUtilities.MAERSKLINE;
        recOpportunity.Type = 'Quarterly Deal Acquisition';
        recOpportunity.CloseDate = date.today() + 90;
        recOpportunity.StageName = 'Identifying';
        recOpportunity.CloseDate = date.today() + 30;
        
        recOpportunity.Commodity__c = 'Pharmaceuticals';
        recOpportunity.Freetime_Terms__c='No';
        recOpportunity.recordtypeid=System.label.QuarterlyDealsRecordTypeId;
        recOpportunity.Opportunity_contains_Dangerous_Goods__c = 'No';
        recOpportunity.Offer_Type__c = 'Offer containing Standard T&Cs';
        insert recOpportunity;
        
        
        OpportunityUtilities.cloneOpporutnityProductsWithLatest(new Map<id, Id>{recOpportunity.id=>mslOppty2.id});
        //OpportunityUtilities.addDngrsGoodsTeamMembers(opp);        
        TriggerExecutionController.skipAllTriggers(false);
        TriggerExecutionController.skipOpportunityTrigger(false);
        TriggerExecutionController.skipOpportunityProductTrigger(false);
        Test.stopTest();
    }
   	static testmethod void tetProductUpgrade(){
        
        TriggerExecutionController.skipAllTriggers(true);
        TriggerExecutionController.skipOpportunityTrigger(true);
        TriggerExecutionController.skipOpportunityProductTrigger(true);
        Product2 prod= [Select id,version__c, Include_in_OMEB_Approvals__c,isactive,oipc_code__c,Latest_Product_Version__c from Product2 limit 1];
        prod.Is_Features_Mandatory__c =true;
        prod.version__c= 1;
        prod.isactive = false;
        //prod.Latest_Product_Version__c= lastestPorduct.id;
        update prod;
        
        List<Product_Component__c> comps1 =  new List<Product_Component__c>();
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
        insert lstoption1;
        
        Product2 lastestPorduct= TestBusinessHelper.createProduct('Ocean', true);
        Product2 prod1= [Select id,version__c, Include_in_OMEB_Approvals__c,isactive,oipc_code__c,Latest_Product_Version__c from Product2 where id=:lastestPorduct.id limit 1];
        prod1.oipc_code__c='P-P0-test';
        prod1.version__c=2;
        prod1.isactive = true;
        update prod1;
        
        Product2 prodtoupdate= [Select id,version__c, Include_in_OMEB_Approvals__c,isactive,oipc_code__c,Latest_Product_Version__c from Product2 where Is_Features_Mandatory__c=true];
        prodtoupdate.Latest_Product_Version__c = prod1.id;
		update prodtoupdate;
        
        Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE isStandard = true]; 
        // PricebookEntry pbe=[select Id from PriceBookEntry where Product2Id =:prod.Id];
        List<Trade_Route__c> lstTDR = TestBusinessHelper.createTradeRoutes(new List<String> {'MSL'},  1, true);
        Opportunity mslOppty2 = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
       	Opportunity_Product__c Oli1 =TestBusinessHelper.createOpportunityLineItemCustom(mslOppty2, prod.id, lstTDR[0], true) ;
       
        List<Product_Component__c> comps =  new List<Product_Component__c>();
        for (integer i = 1; i <= 2; i++){
            Product_Component__c pc = new Product_Component__c();
            pc.Name = 'Comp' + i;
            pc.Component_Code__c = 'PC' + i;
          	pc.Product__c = prod1.Id;
            pc.Display_Order__c = i;
            comps.add(pc);
        }
        insert comps;
		
        List<Product_Feature__c> lstfeat = new List<Product_Feature__c>();
        
        for (integer i = 0; i < 2; i++){
            
            Product_Feature__c f = new Product_Feature__c();
            f.Name = 'Feature' + i;
            f.Feature_Code__c = 'F' + i;
            f.Product_Component__c = comps[i].Id;
            f.Display_Order__c = i;
            f.Categorisation__c ='Service';
            f.Default_Visibility__c= 'INCLUDED';
            f.Description__c = 'Feature description ';           
            lstfeat.add(f);
        }

        insert lstfeat;

        List<Product_Specification_Parameter__c> lstparameter = new List<Product_Specification_Parameter__c>();

        for(integer i=0;i<2;i++){
            Product_Specification_Parameter__c para = new Product_Specification_Parameter__c();
            para.Name = 'paramter' + i;
            para.Specification_Parameter_Code__c = 'SP' + i;
            para.Product_Feature__c = lstfeat[i].Id;
            para.Display_Order__c = i;
            para.type__c='options';
            para.Description__c = 'Parameter description ';  
            lstparameter.add(para);
        }
        insert lstparameter;

        List<Product_Specification_Option__c> lstoption = new List<Product_Specification_Option__c>();

        for(integer i=0;i<2;i++){
            Product_Specification_Option__c opt = new Product_Specification_Option__c();
            opt.Name = 'option' + i;
            opt.Specification_Option_Name__c = 'option' + i;
            opt.Specification_Option_Code__c = 'SPC' + i;
            opt.Product_Specification_Parameter__c = lstparameter[i].Id;
            opt.Display_Order__c = i;
            opt.Description__c = 'option description ';  
            lstoption.add(opt);
        }
        insert lstoption;
        TriggerExecutionController.skipAllTriggers(false);
        TriggerExecutionController.skipOpportunityTrigger(false);
        TriggerExecutionController.skipOpportunityProductTrigger(false);
       
        Test.startTest();

 		List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,Must_Go_To_OMEB__c,
                                  Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,Approval_Required__c,
                                  First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,Approval_status__c,
                                  Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,Requires_IT_Integration__c,Opportunity_Ref__c,
                                  Expected_Handling_Rounds__c, Pricebook2Id
                                  FROM Opportunity  limit 1 ];        
        opp[0].stagename='Qualifying';
        OpportunityUtilities.ApprovalWrapper wraprec = new OpportunityUtilities.ApprovalWrapper();
        wraprec.recordid = (string.valueOf(opp[0].id));
        try{
            OpportunityUtilities.submitForApprovalInstanceInvocable(new List<OpportunityUtilities.ApprovalWrapper>{wraprec});
          	update opp;
        }catch(Exception ex){
            
        }
        
        Test.stopTest();
    }
    
    static testmethod void totestALandMCS(){
        TriggerExecutionController.skipAllTriggers(true);
        Id supplychainrecordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.OppSupplyChainServicesRecType).getRecordTypeId();
        Opportunity mslOppty2 = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        Product2 lastestPorduct= TestBusinessHelper.createProduct('Ocean', true);
        Product2 prod1= [Select id,version__c, Include_in_OMEB_Approvals__c,isactive,oipc_code__c,Latest_Product_Version__c from Product2 where id=:lastestPorduct.id limit 1];
        prod1.oipc_code__c='P-P0-env';
        prod1.version__c = 1;
        prod1.isactive = true;
        update prod1;
        List<Trade_Route__c> lstTDR = TestBusinessHelper.createTradeRoutes(new List<String> {'MSL'},  1, true);
        Opportunity_Product__c Oli1 = TestBusinessHelper.createOpportunityLineItemCustom(mslOppty2, prod1.id, lstTDR[0], true) ;
        TriggerExecutionController.skipAllTriggers(false);
        
        Test.startTest();
       
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,Must_Go_To_OMEB__c,
                                  Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,Approval_Required__c,Requires_Custom_Integration__c,
                                  First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,Approval_status__c,
                                  Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,Requires_IT_Integration__c,Opportunity_Ref__c,Opportunity_Owner_Country__c,
                                  Expected_Handling_Rounds__c, Pricebook2Id
                                  FROM Opportunity  limit 1 ];        
        opp[0].stagename = 'Qualifying';
        opp[0].recordtypeId = supplychainrecordtypeId;
        opp[0].Requires_Custom_Integration__c='';
        opp[0].Requires_IT_Integration__c='';
        
        try{
            update opp;
        }catch(Exception ex){
            
        }
        TriggerExecutionController.skipAllTriggers(true);
        Product2 prod2= [Select id,version__c, Include_in_OMEB_Approvals__c,isactive,oipc_code__c,Latest_Product_Version__c from Product2 where id=:lastestPorduct.id limit 1];
        prod2.oipc_code__c='P-P0-dw1';
        prod2.version__c = 1;
        prod2.isactive = true;
        update prod2;
        OpportunityUtilities.addDngrsGoodsTeamMembers(opp);        
        TriggerExecutionController.skipAllTriggers(false);
        
        try{
            update opp;
        }catch(Exception ex){
            
        }
         Test.stopTest();
    } 
    
    @isTest
    static void test_populateBusinessProcessFieldP2Q(){
        TriggerExecutionController.skipAllTriggers(true);
        List<Opportunity> lstopptoUpdate = new List<Opportunity>();
        List<String> recordTypes = new List<String>{'ShippingCargoServices','ShippingCargoServices','ShippingCargoServices','Quarterly_Deal'};
        Account clientAcc =TestBusinessHelper.createAccount('Client_Account', true);
        Contact contact = TestBusinessHelper.createContact(clientAcc, 'Customer_Contact', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
        User maerskLineUser = TestBusinessHelper.createUser('Sales', Brand__mdt.getInstance('MaerskLine').MasterLabel, false);
        System.runAs(new User(Id = UserInfo.getUserId())){
            maerskLineUser.Id = null;
            //maerskLineUser.FederationIdentifier='testmsluser@maersk.com';
            maerskLineUser.CM_Visibility__c='Single Carrier';
            insert maerskLineUser;
        }
        List<Opportunity> lstopp = TestBusinessHelper.createOpportunities(clientAcc,contact,maerskLineUser,recordTypes,BrandUtilities.MAERSKLINE,true);
        lstopp[0].Customer_Journey__c = 'Instant Quote (Non Negotiable)';
        lstopp[0].Tender_Submission_Format__c = 'Maersk Line standard format';
        Integer daysLeftInMonth = lstopp[0].CloseDate.daysBetween(lstopp[0].CloseDate.toStartOfMonth());
        Integer daysLeftForNextMonth = Date.daysInMonth(lstopp[0].CloseDate.year(), lstopp[0].CloseDate.month()) - daysLeftInMonth;
        lstopp[0].First_Shipment_Date__c = lstopp[0].CloseDate + daysLeftForNextMonth + 9;
        lstopp[0].Last_Shipment_Date__c =  lstopp[0].CloseDate + daysLeftForNextMonth + 10; 
        //lstopp[0].First_Shipment_Date__c = lstopp[0].CloseDate + 1;
        //lstopp[0].Last_Shipment_Date__c = lstopp[0].CloseDate + 2;
        lstopp[1].Customer_Journey__c = 'As-Is Journey';
        lstopp[1].Tender_Submission_Format__c = 'Maersk Line standard format';
        lstopp[2].Customer_Journey__c = 'As-Is Journey';
        lstopp[2].Tender_Submission_Format__c = 'No Ocean Tender';
        lstopp[3].Customer_Journey__c = 'As-Is Journey';
        
        TriggerExecutionController.skipAllTriggers(false);
        update lstopp; 
        Test.startTest(); 
        List<Opportunity> updatedOpps = [SELECT Id, Business_Process__c FROM Opportunity WHERE Id IN :lstopp];
        List<String> expectedBPValues = new List<String>{'Instant Quote', 'Tender'};
        for(Integer i = 0; i <=1 ; i++) {
            Assert.areEqual(updatedOpps[i].Business_Process__c,expectedBPValues[i]);
        }
        for(Integer i = 2; i < updatedOpps.size(); i++) {
            Assert.areEqual(updatedOpps[i].Business_Process__c,null);
        }
         Test.stopTest(); 
    }

    static testmethod void toTestValidateRevenueFieldforNonOmeb(){
        //Data creation start
        TriggerExecutionController.skipAllTriggers(true);        
        //Id supplychainrecordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.OppSupplyChainServicesRecType).getRecordTypeId();
        Opportunity mslOppty2 = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        mslOppty2.Cargo_Type__c = 'Dry';
        Product2 lastestPorduct= TestBusinessHelper.createProduct('Ocean', true);
        Product2 prod1= [Select id,version__c, Include_in_OMEB_Approvals__c,isactive,oipc_code__c,Latest_Product_Version__c,Portfolio__c,Is_Product_Add_On__c from Product2 where id=:lastestPorduct.id limit 1];
        prod1.oipc_code__c='P-P0-env';
        prod1.version__c = 1;
        prod1.isactive = true;
        update prod1;
        
        List<Trade_Route__c> lstTDR = TestBusinessHelper.createTradeRoutes(new List<String> {'MSL'},  1, true);
        Opportunity_Product__c Oli1 = TestBusinessHelper.createOpportunityLineItemCustom(mslOppty2, prod1.id, lstTDR[0], true) ;
        Bypass_Product_Upgrade_Validation__c bt= Bypass_Product_Upgrade_Validation__c.getInstance();
        bt.Skip_Validation__c = true;
        insert bt;
        Oli1.Product_Revenue_Per_Unit__c = null;
        Oli1.cargo_type__c = 'Dry';
        update Oli1;
        Bypass_Product_Upgrade_Validation__c btt= Bypass_Product_Upgrade_Validation__c.getInstance();
        delete btt;
        prod1.Portfolio__c =  'Ocean';
        prod1.Is_Product_Add_On__c = false;
        update prod1;
        TriggerExecutionController.skipAllTriggers(false);
        //Data creation end
        
        //Below covers positive scenerio for non-omeb where Lns product is applicable so status change on non-Omeb opportunity should not work
        prod1.Portfolio__c = 'LnS';
        update prod1;        
        Test.startTest();        
        try{
            mslOppty2.Name =  BrandUtilities.MAERSKLINE + ' Test QuarterDeal';
            mslOppty2.StageName = 'Qualifying';
            mslOppty2.Must_Go_To_OMEB__c = false;
            update mslOppty2;
        }catch(Exception ex){
            opportunity oppIntance = [select id,Approval_Required__c,StageName from opportunity where id =:mslOppty2.id];
            Assert.areEqual(oppIntance.StageName,'Identifying', 'Stage name has not changed due to Validation error');
        }       
        
        //To cover negative scenerio for non-omeb where Lns product is not applicable so status change on non-Omeb opportunity should work
        prod1.Portfolio__c = 'Ocean';
        update prod1;      
        TriggerExecutionController.skipAllTriggers(true); 
        mslOppty2.Cargo_Type__c = 'Dry';
        update mslOppty2;
        TriggerExecutionController.skipAllTriggers(false);        
        mslOppty2.StageName = 'Identifying';
        mslOppty2.Must_Go_To_OMEB__c = false;
        mslOppty2.Cargo_Type__c = 'Dry';
        mslOppty2.Requires_Custom_Integration__c = 'No, this is not required. Customer system will not connect with Maersk in any way';
        //update mslOppty2;
        
        //To cover Negative scenerio for non-omeb scenario where since status is changing to a closed lost so validation is not applicable
        prod1.Portfolio__c = 'LnS';
        update prod1; 
        mslOppty2.StageName = 'Closed Lost';
        mslOppty2.Reason_For_Close__c = 'Lost - Customer Relationship Issue';
        update mslOppty2;
        Test.stopTest();
    }
    //SFSE - SFSE-13409
    static testmethod void validateOpportunityNonP2QProduct(){
        Test.startTest();
        List<Product2> prodIns = [Select id,name,Product_Scope__c from Product2];
        prodIns[0].Product_Scope__c = 'Included In Email Agreement';
        update prodIns;
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,Must_Go_To_OMEB__c,
                                  Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,Approval_Required__c,Requires_Custom_Integration__c,
                                  First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,Approval_status__c,
                                  Expected_Tender_Receipt_Date__c,Customer_Journey__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,Requires_IT_Integration__c,Opportunity_Ref__c,Opportunity_Owner_Country__c,
                                  Expected_Handling_Rounds__c, Pricebook2Id
                                  FROM Opportunity  limit 1 ];
       List<Opportunity_Product__c> oli = [Select id,name,Product_Scope__c from Opportunity_Product__c];
       opp[0].Customer_Journey__c =  Label.As_is_Journey;
       opp[0].First_Shipment_Date__c = system.today()+1;
       opp[0].Last_Shipment_Date__c = system.today()+20; 
       try{
       update opp;
       opp[0].Customer_Journey__c = label.Instant_Quote;
       update opp;
       System.AssertEquals(1, opp.size());
       }catch(Exception e){
          System.debug('Exception caught: ' + e.getMessage());  
       }
       Test.stopTest();
        
        
    }
   // SFSE-13409
    static testmethod void validateOpportunityP2QProduct(){
        Test.startTest();
        List<Product2> prodIns = [Select id,name,Product_Scope__c from Product2];
        prodIns[0].Product_Scope__c = 'Included In P2Q';
        update prodIns;
        List<Opportunity> mslOppty2 = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,Must_Go_To_OMEB__c,
                                  Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,Approval_Required__c,Requires_Custom_Integration__c,
                                  First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,Approval_status__c,
                                  Expected_Tender_Receipt_Date__c,Customer_Journey__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,Requires_IT_Integration__c,Opportunity_Ref__c,Opportunity_Owner_Country__c,
                                  Expected_Handling_Rounds__c, Pricebook2Id
                                  FROM Opportunity  limit 1 ];
        mslOppty2[0].Customer_Journey__c = label.Instant_Quote;
        mslOppty2[0].First_Shipment_Date__c = System.today()+20;
        mslOppty2[0].Last_Shipment_Date__c = System.today()+23; 
        List<Opportunity_Product__c> oli = [Select id,name,Product_Scope__c from Opportunity_Product__c];
       mslOppty2[0].Customer_Journey__c = Label.As_is_Journey;
       try{
       update mslOppty2;
       System.AssertEquals(1, mslOppty2.size());
       }catch(Exception e){
          System.debug('Exception caught: ' + e.getMessage());  
       }
       Test.stopTest();
        
        
    }
    static testmethod void ValidateCustomerJourney(){
       Test.StartTest();
       List<Opportunity> opp = [Select Id,name,Customer_journey__c from Opportunity];
       List<Opportunity_Product__c> oli = [Select id,name from Opportunity_Product__c];
       List<Quotes__c> Quote = [Select Id,Name from Quotes__c];
       List<Opportunity_File__c> oppFiles = [Select Id,name from Opportunity_File__c];
       opp[0].Customer_Journey__c = label.Instant_Quote;
        Try{
            Update opp;
            System.AssertEquals(1, opp.size());
        }catch(Exception e){
            System.debug(e.getMessage());    
        }
        Test.StopTest();  
    } 
    
    static testmethod void nullifyFieldsOnOptyClone(){
       
        Account acc= [Select id,vertical__C from Account LIMIT 1];
        Opportunity opp =  TestBusinessHelper.createOpportunity(acc, null, null, 'Quarterly_Deal', BrandUtilities.MAERSKLINE, TRUE);		
        opp.Offer_Status__c ='Accepted/Completed';
        update opp;
                        
       Test.startTest(); 
       Opportunity opty =  opp.clone(false,false,false,false);       
       insert opty; 
       Test.stopTest(); 
    }
     @isTest
    static void testUpdateOppName(){
        Account clientAcc =TestBusinessHelper.createAccount('Client_Account', true);
        Contact contact = TestBusinessHelper.createContact(clientAcc, 'Customer_Contact', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
        contact.FirstName = 'Test';
        contact.LastName = 'Record';
        Update contact;
        Opportunity opp = TestBusinessHelper.createOpportunity(clientAcc,contact,null,'Quarterly_Deal',BrandUtilities.MAERSKLINE,false);
        opp.id = null;
        opp.Name = 'X';
        insert opp;
        

        
    
}
    @isTest
    static void testEndOfService(){
        Opportunity oppty = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        Product2 prod = TestBusinessHelper.createProduct('ocean', true);
        List<Trade_Route__c> lstTDR = TestBusinessHelper.createTradeRoutes(new List<String> {'MSL'},  1, true);
        Opportunity_Product__c opptyProd = TestBusinessHelper.createOpportunityLineItemCustom(oppty, prod.id,lstTDR[0], true) ;
        String productName = '"' + prod.Name + '"';
        Test.startTest();
        prod.IsActive = false;
        prod.Product_Status__c = 'End of Sales';
        prod.End_of_Service__c = oppty.Last_Shipment_Date__c - 10;
        update prod;
        try{
            oppty.StageName = System.Label.Designing_Proposal;
            update oppty;
        }catch(Exception e){ 
            System.debug('Exception1'+e.getmessage());
            Boolean res = e.getmessage().contains(productName+' is/are no longer available. Please update to different product(s) if you wish to continue with this Opportunity.') ? true : false;
            Assert.areEqual(res, true);
        }
        TriggerExecutionController.skipAllTriggers(true);
        oppty.Offer_Type__c = 'Offer containing Standard T&Cs';
        oppty.StageName = System.Label.Quoting; 
        update oppty;
        TriggerExecutionController.skipAllTriggers(false);
        try{
            oppty.StageName = System.Label.close_won;
            update oppty;
        }catch(Exception e){
            Boolean res = e.getmessage().contains(productName+' is/are no longer available. You can proceed with the same product(s) provided that the Agreement End Date is not greater than the End of Service Date.') ? true : false;
            Assert.areEqual(res, true);
        }
        Test.stopTest();

    }
    
    //SFSE-13391
    @isTest
    static void test_unlockOpportunity(){
        User liveHelpUser = TestBusinessHelper.createUser(ProfileUtilities.LiveHelp, Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
        Opportunity oppty = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        Product2 prod = TestBusinessHelper.createProduct('ocean', true);
        List<Trade_Route__c> lstTDR = TestBusinessHelper.createTradeRoutes(new List<String> {'MSL'},  1, true);
        Opportunity_Product__c opptyProd = TestBusinessHelper.createOpportunityLineItemCustom(oppty, prod.id,lstTDR[0], true) ;
        oppty.Offer_Type__c = 'Offer containing Standard T&Cs';
        oppty.StageName = System.Label.Closed_lost; 
        oppty.Reason_For_Close__c = 'Lost - Customer Relationship Issue';
        oppty.X_Auto_Renew__c = 'No';
        oppty.Tender_Submission_Format__c = 'No Ocean Tender';
        update oppty;
        Test.StartTest();
        System.runAs(new User(Id = liveHelpUser.Id)){
            Validation_Rules_Bypass__c bypass = Validation_Rules_Bypass__c.getInstance();
            bypass.Active__c = true;
            insert bypass;
            oppty.StageName = System.Label.Negotiating;
        	update oppty;
            delete bypass;
        }
        List<Opportunity> lstOpp = [Select Id,Record_Locked__c, Reason_for_Unlocking__c, Opportunity_Unlocked_Date__c FROM Opportunity WHERE Id =:oppty.Id LIMIT 1];
        Assert.areEqual(lstOpp[0].Record_Locked__c,false);
        Assert.areEqual(lstOpp[0].Reason_for_Unlocking__c,'Administrative Reasons');
        Test.StopTest();
    }
    
    //SFSE-13391
    @isTest
    static void test_validateClosedUnlockedOppty(){
        User salesUser = TestBusinessHelper.createUser(ProfileUtilities.Sales, Brand__mdt.getInstance('MaerskLine').MasterLabel, true);        
        Opportunity oppty = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        Product2 prod = TestBusinessHelper.createProduct('ocean', true);
        List<Trade_Route__c> lstTDR = TestBusinessHelper.createTradeRoutes(new List<String> {'MSL'},  1, true);
    Opportunity_Product__c opptyProd = TestBusinessHelper.createOpportunityLineItemCustom(oppty, prod.Id, lstTDR[0], true);
        oppty.OwnerId = salesUser.Id;
        oppty.Offer_Type__c = 'Offer containing Standard T&Cs';
        oppty.StageName = System.Label.Closed_lost; 
        oppty.Reason_For_Close__c = 'Lost - Customer Relationship Issue';
        oppty.X_Auto_Renew__c = 'No';
        oppty.Tender_Submission_Format__c = 'No Ocean Tender';
        update oppty;
    
        Test.startTest();
        oppty.Record_Locked__c = false;
        oppty.Reason_for_Unlocking__c = 'Regulatory changes';
        oppty.Opportunity_Unlocked_Date__c = System.now();
        update oppty;

    System.runAs(new User(Id = salesUser.Id)) {
        try {
            oppty.First_Round_Submission_Date__c = oppty.First_Shipment_Date__c - 1;
            update oppty;
        } catch(Exception e) {
            Boolean res = e.getMessage().contains(System.Label.Closed_Unlocked_Oppty_error) ? true : false;
            Assert.areEqual(res, true);
        }

        try {
            oppty.Reason_for_Unlocking__c = 'Clerical Error / Contract Alignment';
            oppty.First_Round_Submission_Date__c = oppty.First_Shipment_Date__c - 1;
            update oppty;
        } catch(Exception e) {
            Boolean res = e.getMessage().contains(System.Label.Closed_Unlocked_Oppty_error_ClericalErrorReason) ? true : false;
            Assert.areEqual(res, true);
        }

        try {
            oppty.StageName = System.Label.Negotiating;
            update oppty;
        } catch(Exception e) {
            Boolean res = e.getMessage().contains(System.Label.Closed_Unlocked_Oppty_error) ? true : false;
            Assert.areEqual(res, true);
        }
    }
	Test.stopTest();
  }

}