/*              
* Revision 	Ref Number	Date			Owner					Description
* -------- 	----------	-----------		-----------------		-----------
* 1.0      				28/04/2023		Rama@maersk				Code created for show next approver
* 2.0		SFSE-11583	06-Jul-2023		Kiran@Maersk			OMEB 3.1 Full Approval Process
* 3.0	    SFSE-11753	03-11-23	   	Ritika@Maersk			To change the hard coded product family references to custom label
* 4.0		SFSE-14118	11/03/2024		Jothsana@Maersk			Removing Maersk Flow(MF1) from OMEB
*/
@isTest
public class showNextApprovalProcess_test {
    
    private static final String pursuit = System.Label.Pursuit_Gate;
    private static final String qualification = System.Label.Feasibility_Gate;
    private static final String solution = System.Label.Solution_Gate;
    private static final String prewin = System.Label.Pre_Win_Gate;
    private static Id salesUserId;
    private static Id adminUserId;
    
    @testSetup
    static void setup() {
        Trade_Route__c tradeRoute;
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
        Geography__c ukCountry = TestBusinessHelper.createGeography('United Kingdom', 'Country', null, true);
        Geography__c usCountry = TestBusinessHelper.createGeography('United States', 'Country', null, true);
        Geography__c ukState = TestBusinessHelper.createGeography('London', 'State', ukCountry.Id, true);
        Geography__c usState = TestBusinessHelper.createGeography('New Jersey', 'State', usCountry.Id, true);
        Geography__c state = TestBusinessHelper.createGeography('Karnataka', 'State', country.Id, true);
        
        BDA__c parentBDA = TestBusinessHelper.createBDA('India, Middle East, and Africa', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true);
        BDA__c childBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'IBS', parentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, country.Id, null, true);
        
        BDA__c ukParentBDA = TestBusinessHelper.createBDA('United Kingdom', 'Other', 'EMEA', null, UserInfo.getUserId(), true);
        BDA__c ukChildBDA = TestBusinessHelper.createBDA('United Kingdom and Ireland Area', 'Cluster', 'UKI', ukParentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c ukBdaGeo = TestBusinessHelper.createBDAGeography(ukChildBDA.Id, ukCountry.Id, null, true);
        
        List<user> usersToInsert = new List<user>();
        User DelegatedUser = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
        DelegatedUser.Id = null;
        DelegatedUser.IsActive=true;
        DelegatedUser.country = 'India';
        DelegatedUser.CM_Visibility__c = 'Single Carrier';
        DelegatedUser.UserPreferencesReceiveNotificationsAsDelegatedApprover = true;
        usersToInsert.add(DelegatedUser);
        User salesUser = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
        salesUser.Id = null;
        salesUser.IsActive=true;
        salesUser.country = 'India';
        salesUser.CM_Visibility__c = 'Single Carrier';
        salesUser.UserPreferencesReceiveNoNotificationsAsApprover = false;
        salesUser.DelegatedApproverId = DelegatedUser.Id;
        usersToInsert.add(salesUser);
        
        User adminUser = TestBusinessHelper.createUser('System Administrator', BrandUtilities.MAERSKLINE, false);
        adminUser.Id = null;
        adminUser.IsActive=true;
        adminUser.country = 'India';
        salesUser.UserPreferencesReceiveNoNotificationsAsApprover = false;
        salesUser.DelegatedApproverId = DelegatedUser.Id;
        usersToInsert.add(adminUser);
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert usersToInsert;
        }
        salesUserId = salesUser.Id;
        adminUserId = adminUser.Id;
        
        System.runAs(adminUser){
            tradeRoute = TestBusinessHelper.createTradeRoutes(new List<String>{BrandUtilities.MCC}, 1, true)[0];
        }
        
        Test.startTest();
        
        Opportunity opportunity;
        TriggerExecutionController.skipAllTriggers(true);
        System.runAs(salesUser){
            Account clientAccount = TestBusinessHelper.createAccount('Client_Account', false);
            clientAccount.Id = null;
            clientAccount.Vertical__c = 'Lifestyle';
            clientAccount.Attractiveness__c='Key Client';
            insert clientAccount;
            opportunity = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'Supply_Chain_Services', BrandUtilities.MAERSKLINE, false);
            opportunity.Id = null;
            opportunity.Requires_IT_Integration__c = 'Yes, I am sure this is required basis my discussion with customer';
            opportunity.Requires_Custom_Integration__c = 'Yes, I am sure this is required basis my discussion with customer';
            insert opportunity;
        }
        List<Product2> productsToInsert = new List<Product2>();
        
        List<Products_For_Approval__mdt> productsForApprovalList =Products_For_Approval__mdt.getAll().values();
        
        Product2 product;
        for(Products_For_Approval__mdt prodForApprovalMD : Products_For_Approval__mdt.getAll().values()){
            if(prodForApprovalMD.Active__c && prodForApprovalMD.OIPC_Code__c != null){
                product = TestBusinessHelper.createProduct(prodForApprovalMD.Product_Family__c, false);
                product.Id = null;
                product.Family_Code__c = prodForApprovalMD.Family_Code__c;
                product.OIPC_Code__c = prodForApprovalMD.OIPC_Code__c;
                product.Include_in_OMEB_Approvals__c = true;
                productsToInsert.add(product);
            }
        }
        /*
        Product2 productColdStorage = TestBusinessHelper.createProduct('Cold Storage', false); //SFSE-11753
        productColdStorage.Id = null;
        productColdStorage.Family_Code__c = 'cold_storage'; //SFSE-11753
        productColdStorage.OIPC_Code__c = 'P-P0-144i';
        productColdStorage.Include_in_OMEB_Approvals__c = true;
        productsToInsert.add(productColdStorage);
        String contract = System.Label.Warehousing_and_Fulfillment_family; //SFSE-11753
        Product2 productContractLogistics = TestBusinessHelper.createProduct(contract, false); //SFSE-11753
        productContractLogistics.Id = null;
        productContractLogistics.Family_Code__c = 'Warehousing_and_Fulfillment';
        productContractLogistics.OIPC_Code__c = 'P-P0-dwb';
        productContractLogistics.Include_in_OMEB_Approvals__c = true;
        productsToInsert.add(productContractLogistics);
        
        String customsServices = System.Label.Custom_Services_and_Insurance_Family_Name; //SFSE-11753
        Product2 productCustomServices = TestBusinessHelper.createProduct(customsServices, false); //SFSE-11753
        productCustomServices.Id = null;
        productCustomServices.Family_Code__c = 'customs_services';
        productCustomServices.OIPC_Code__c = 'P-P0-env';
        productCustomServices.Include_in_OMEB_Approvals__c = true;
        productsToInsert.add(productCustomServices);
        
        String airnLcl = System.Label.Air_and_LCL_Family_Name; //SFSE-11753
        Product2 productAirLcl = TestBusinessHelper.createProduct(airnLcl, false); //SFSE-11753
        productAirLcl.Id = null;
        productAirLcl.Family_Code__c = 'air_n_lcl';
        productAirLcl.OIPC_Code__c = 'P-P0-dw2';
        productAirLcl.Include_in_OMEB_Approvals__c = true;
        productsToInsert.add(productAirLcl);
        
        Product2 productMM = TestBusinessHelper.createProduct('Middle Mile', false);
        productMM.id = null;
        productMM.Family_Code__c = 'middle_mile';
        productMM.OIPC_Code__c = 'P-P0-255t';
        productMM.Include_in_OMEB_Approvals__c = true;
        productsToInsert.add(productMM);
        */
        
        System.runAs(adminUser){
            insert productsToInsert;
            
            List<Approval_Process__c> approvalProcessToInsert = new List<Approval_Process__c>();
            Approval_Process__c processProductsPreWin = TestBusinessHelper.createApprovalPorcess('Pre-Win Gate Products', prewin, 'Product', 1, null, true, false);
            processProductsPreWin.Id = null;
            approvalProcessToInsert.add(processProductsPreWin);
            Approval_Process__c processPlatformPreWin = TestBusinessHelper.createApprovalPorcess('Pre-Win Gate Platform', prewin, 'Platform', 1, null, true, false);
            processPlatformPreWin.Id = null;
            approvalProcessToInsert.add(processPlatformPreWin);
            Approval_Process__c processKCPursuit = TestBusinessHelper.createApprovalPorcess('Pursuit gate-auto pass KC/Booster/RC', pursuit, 'Sales', 2, null, true, false);
            processKCPursuit.Id = null;
            approvalProcessToInsert.add(processKCPursuit);
            Approval_Process__c processPlatformSolution = TestBusinessHelper.createApprovalPorcess('Solution Gate Platform', solution, 'Platform', 3, null, true, false);
            processPlatformSolution.Id = null;
            approvalProcessToInsert.add(processPlatformSolution);
            Approval_Process__c processProductsSolution = TestBusinessHelper.createApprovalPorcess('Solution Gate Products', solution, 'Product', 4, null, true, false);
            processProductsSolution.Id = null;
            approvalProcessToInsert.add(processProductsSolution);
            Approval_Process__c processProductsPursuit = TestBusinessHelper.createApprovalPorcess('Pursuit Gate Products', pursuit, 'Product', 7, null, true, false);
            processProductsPursuit.Id = null;
            approvalProcessToInsert.add(processProductsPursuit);
            Approval_Process__c processCLQualification = TestBusinessHelper.createApprovalPorcess('Qualification Gate Auto Approval', qualification, 'Product', 12, null, true, false);
            processCLQualification.Id = null;
            approvalProcessToInsert.add(processCLQualification);
            Approval_Process__c processQualificationPlatform = TestBusinessHelper.createApprovalPorcess('Qualification Gate Platform', qualification, 'Platform', 12, null, true, false);
            processQualificationPlatform.Id = null;
            approvalProcessToInsert.add(processQualificationPlatform);

            insert approvalProcessToInsert;
            
            List<Approval_Process_Escalation_Matrix__c> proceMatrixToInsert = new List<Approval_Process_Escalation_Matrix__c>();
            Approval_Process_Escalation_Matrix__c processProdcutsPreWin = TestBusinessHelper.createApprovalPorcessMatrix(processProductsPreWin, country, 'IBS' , 'India, Middle East, and Africa', '4PL,MC1,MC2,MC3,MC4,MC5,MC6,MC7,MC8,MC9,AL,CS,MM,SMD', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processProdcutsPreWin.Id = null;
            proceMatrixToInsert.add(processProdcutsPreWin);
            Approval_Process_Escalation_Matrix__c processMatrixPlatformQualification = TestBusinessHelper.createApprovalPorcessMatrix(processQualificationPlatform, country, 'IBS' , 'India, Middle East, and Africa', '4PL,SCM,CCL', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processMatrixPlatformQualification.Id = null;
            proceMatrixToInsert.add(processMatrixPlatformQualification);
            Approval_Process_Escalation_Matrix__c processMatrixPlatformPreWin = TestBusinessHelper.createApprovalPorcessMatrix(processPlatformPreWin, country, 'IBS' , 'India, Middle East, and Africa', '4PL,SCM,CCL,MC1,MC2,MC3,MC4,MC5,MC6,MC7,MC8,MC9,AL,CS,MM,SMD', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processMatrixPlatformPreWin.Id = null;
            proceMatrixToInsert.add(processMatrixPlatformPreWin);
            Approval_Process_Escalation_Matrix__c processMatrixKCPursuit = TestBusinessHelper.createApprovalPorcessMatrix(processKCPursuit, null, null, null, '4PL,SCM,CCL,ECM,WD,CS,GH', null, null, null, null, true, false);
            processMatrixKCPursuit.Id = null;
            proceMatrixToInsert.add(processMatrixKCPursuit);
            Approval_Process_Escalation_Matrix__c processMatrixPlatformSolution = TestBusinessHelper.createApprovalPorcessMatrix(processPlatformSolution, country, 'IBS' , 'India, Middle East, and Africa', 'MC1,MC2,MC3,MC4,MC5,MC6,MC7,MC8,MC9,AL,CS,MM', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processMatrixPlatformSolution.Id = null;
            proceMatrixToInsert.add(processMatrixPlatformSolution);
            Approval_Process_Escalation_Matrix__c processMatrixProductsSolution = TestBusinessHelper.createApprovalPorcessMatrix(processProductsSolution, country, 'IBS' , 'India, Middle East, and Africa', 'MC1,MC2,MC3,MC4,MC5,MC6,MC7,MC8,MC9,AL,CS,SMD', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processMatrixProductsSolution.Id = null;
            proceMatrixToInsert.add(processMatrixProductsSolution);
            Approval_Process_Escalation_Matrix__c processMatrixProductPursuit = TestBusinessHelper.createApprovalPorcessMatrix(processProductsPursuit, country, 'IBS' , 'India, Middle East, and Africa', '4PL,SCM,CCL,ECM,WD,CS,GH', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processMatrixProductPursuit.Id = null;
            proceMatrixToInsert.add(processMatrixProductPursuit);
            Approval_Process_Escalation_Matrix__c processMatrixCLQualification = TestBusinessHelper.createApprovalPorcessMatrix(processCLQualification, null, null, null, 'CL,GL', null, null, null, null, true, false);
            processMatrixCLQualification.Id = null;
            proceMatrixToInsert.add(processMatrixCLQualification);
            Approval_Process_Escalation_Matrix__c processMatrixProductPursuitUK = TestBusinessHelper.createApprovalPorcessMatrix(processProductsPursuit, ukCountry, 'UKI' , 'United Kingdom', '4PL,SCM,CCL,ECM,WD,CS,GH', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processMatrixProductPursuitUK.Id = null;
            proceMatrixToInsert.add(processMatrixProductPursuitUK);
            insert proceMatrixToInsert;
        
        }
        
        TriggerExecutionController.skipAllTriggers(false);
        
        Set<Id> productIds = new Set<Id>();
        for(Product2 prod : [SELECT Id, Name FROM Product2 WHERE OIPC_Code__c IN ('P-P0-1cm1','P-P0-dwb','P-P0-144i','P-P0-dw2','P-P0-env','P-P0-255t','P-P0-dwr')]){
            productIds.add(prod.Id);
        }
        List<Opportunity_Product__c> optyList=TestBusinessHelper.createOpportunityLineItemCustoms(opportunity, productIds, tradeRoute, country, state, true);
        List<Opportunity_Product__c> optyList1 = new List<Opportunity_Product__c>();
        for(Opportunity_Product__c oppprod : optyList){
            oppprod.UnitPrice__c = 10;
            oppprod.Quantity__c =100;
            optyList1.add(oppprod);
        }
        update optyList1;
		Test.stopTest();
    }
   
    @isTest
    static void testCLGLProductNextApprovers() {
        Opportunity supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c
                                       FROM Opportunity LIMIT 1];
        
        Test.startTest();
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Geography__c country = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' and name = 'India'];
        Geography__c state = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'State' and name = 'Karnataka'];
        
        Set<Id> productIds = new Set<Id>();
        for(Product2 prod : [SELECT Id, Name FROM Product2 WHERE OIPC_Code__c IN ('P-P0-dwb','P-P0-2bc4')]){
            productIds.add(prod.Id);
        }
        TestBusinessHelper.createOpportunityLineItemCustoms(supplyChainOppty, productIds, tradeRoute, country, state, true);
        showNextApprovalProcess.getNextApprover(supplyChainOppty.Id);
        Test.stopTest();
   		List<Opportunity_Product__c> lstop = [Select id,Product2Id__r.OIPC_Code__c,Product2Id__r.Name from Opportunity_Product__c where OpportunityId__c =: supplyChainOppty.Id];
        
    }
    
    @isTest
    static void testLLGHCSProductSubmittedNextAprovers() {
        Test.startTest();
		/*
        List<Opportunity_Product__c> oliCustomList = [SELECT Id, Tender_Target__c, Total_Price__c, OpportunityId__r.Name, OpportunityId__r.Products_for_Approval__c,
                                             OpportunityId__r.Approval_Required__c, OpportunityId__r.Must_Go_To_OMEB__c
                                              FROM Opportunity_Product__c];
        
        Opportunity supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c,Opportunity_Owner_Country__c
                                       FROM Opportunity LIMIT 1];
        TriggerExecutionController.skipAllTriggers(true);
        //delete oliCustomList;
        TriggerExecutionController.skipAllTriggers(false);*/
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Geography__c countryIndia = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' and name = 'India'];
        Geography__c stateKA = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'State' and name = 'Karnataka'];
        
        Opportunity supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, Opportunity_Owner_Country__c
                                       FROM Opportunity LIMIT 1];
        
        supplyChainOppty.Last_Shipment_Date__c = System.today() + 180;
        supplyChainOppty.First_Shipment_Date__c = System.today() + 60;
        supplyChainOppty.Estimated_Agreement_Duration__c = 30;
        update supplyChainOppty;
        Set<Id> productIds = new Set<Id>();
        for(Product2 prod : [SELECT Id, Name FROM Product2 WHERE OIPC_Code__c IN ('P-P0-144i','P-P0-dwr')]){
            productIds.add(prod.Id);
        }
        
        List<Opportunity_Product__c> optyList=TestBusinessHelper.createOpportunityLineItemCustoms(supplyChainOppty, productIds, tradeRoute, countryIndia, stateKA, true);
        optyList[0].UnitPrice__c = 1000000;
        optyList[0].Quantity__c = 20;
        optyList[0].L_S_Product__c = true;
        optyList[1].UnitPrice__c = 1000000;
        optyList[1].Quantity__c = 20;
        optyList[1].L_S_Product__c = true;
        //TriggerExecutionController.skipAllTriggers(true);
        update optyList;
        //TriggerExecutionController.skipAllTriggers(false);
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, Opportunity_Owner_Country__c
                                       FROM Opportunity LIMIT 1];
        //Test.startTest();
        //Create parameter
        Map<String, Object> Params = new Map<String, Object>();
        Params.put('Opportunity', supplyChainOppty);
        for (Opportunity_Product__c opp:optyList){
            system.debug('AGP'+opp.Annualized_Gross_Profit__c);
        }
        

        //create instance of Interview
        Flow.Interview.Opportunity_Pursuit_Gate_Approval_Process callPursuit = new Flow.Interview.Opportunity_Pursuit_Gate_Approval_Process(Params);
        //Invoke start method
        callPursuit.start();
        
        List<Approval_Process_Escalation_Matrix__c> matrix = [SELECT ID From Approval_Process_Escalation_Matrix__c WHERE Approval_Process_Name__r.Gate__c =:System.Label.Pursuit_Gate LIMIT 2];
        List<Approval_History__c> aphList = New List<Approval_History__c>();
        Approval_History__c ahOne = New Approval_History__c();
        ahOne.Step_Name__c  = 'Pursuit Products-LL-(United Kingdom, Lifestyle)';
        ahOne.Approval_Step__c  = matrix[0].Id;
        ahOne.Status__c = 'Pending';
        ahOne.TargetObjectId__c = supplyChainOppty.Id;
        ahOne.Approved_By__c = UserInfo.getUserId();
        ahOne.Assigned_To__c = UserInfo.getUserId();
        aphList.add(ahOne);
        Approval_History__c ahSecond = New Approval_History__c();
        ahSecond.Step_Name__c  = 'Pursuit Products-LL-(United Kingdom, Lifestyle)';
        ahSecond.Approval_Step__c  = matrix[1].Id;
        ahSecond.Status__c = 'Pending';
        ahSecond.TargetObjectId__c = supplyChainOppty.Id;
        ahSecond.Approved_By__c = UserInfo.getUserId();
        ahSecond.Assigned_To__c = UserInfo.getUserId();
     	aphList.add(ahSecond);
        insert aphList;
       
        showNextApprovalProcess.getNextApprover(supplyChainOppty.Id);
        
        Test.stopTest();
        
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c FROM Opportunity LIMIT 1];
        //System.assertEquals(supplyChainOppty.Approval_Status__c, 'Submitted - Pursuit Gate', 'Opportunity to be submitted for qualifciation gate');
    }
     @isTest
    static void testLLGHCSProductSubmittedNextAproversQualification() {
        Test.startTest();

        List<Opportunity_Product__c> oliCustomList = [SELECT Id, Tender_Target__c, Total_Price__c, OpportunityId__r.Name, OpportunityId__r.Products_for_Approval__c,
                                             OpportunityId__r.Approval_Required__c, OpportunityId__r.Must_Go_To_OMEB__c
                                              FROM Opportunity_Product__c];
        
        Opportunity supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c
                                       FROM Opportunity LIMIT 1];
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Geography__c countryIndia = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' and name = 'India'];
        Geography__c stateKA = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'State' and name = 'Karnataka'];
        TriggerExecutionController.skipAllTriggers(true);
        delete oliCustomList;
        TriggerExecutionController.skipAllTriggers(false);
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c
                                       FROM Opportunity LIMIT 1];
        
        supplyChainOppty.Last_Shipment_Date__c = System.today() + 180;
        supplyChainOppty.First_Shipment_Date__c = System.today() + 60;
        supplyChainOppty.Estimated_Agreement_Duration__c = 30;
        supplyChainOppty.Type = 'Renewal';
        update supplyChainOppty;
        Set<Id> productIds = new Set<Id>();
        for(Product2 prod : [SELECT Id, Name FROM Product2 WHERE OIPC_Code__c IN ('P-P0-144i','P-P0-dwb','P-P0-dwb')]){
            productIds.add(prod.Id);
        }
        
        List<Opportunity_Product__c> optyList=TestBusinessHelper.createOpportunityLineItemCustoms(supplyChainOppty, productIds, tradeRoute, countryIndia, stateKA, true);
        optyList[0].UnitPrice__c = 10;
        optyList[0].Quantity__c = 20;
        optyList[0].L_S_Product__c = true;
        TriggerExecutionController.skipAllTriggers(true);
        update optyList;
        TriggerExecutionController.skipAllTriggers(false);
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, Opportunity_Owner_Country__c
                                       FROM Opportunity LIMIT 1];
        //Test.startTest();
        //Create parameter
        Map<String, Object> Params = new Map<String, Object>();
        Params.put('Opportunity', supplyChainOppty);
        system.debug(supplyChainOppty.Products_for_Approval__c+'product code');
        for (Opportunity_Product__c opp:optyList){
            system.debug('AGP'+opp.Annualized_Gross_Profit__c);
        }
        

        //create instance of Interview
        Flow.Interview.Opportunity_Feasibility_Gate_Approval_Process callQualification = new Flow.Interview.Opportunity_Feasibility_Gate_Approval_Process(Params);
        //Invoke start method
        callQualification.start();
        
        List<Approval_Process_Escalation_Matrix__c> matrix = [SELECT ID From Approval_Process_Escalation_Matrix__c WHERE Approval_Process_Name__r.Gate__c =:System.Label.Pursuit_Gate LIMIT 2];
        List<Approval_History__c> aphList = New List<Approval_History__c>();
        Approval_History__c ahOne = New Approval_History__c();
        ahOne.Step_Name__c  = 'Qualification Gate Auto Approval';
        ahOne.Approval_Step__c  = matrix[0].Id;
        ahOne.Status__c = 'Approved';
        ahOne.TargetObjectId__c = supplyChainOppty.Id;
        ahOne.Approved_By__c = UserInfo.getUserId();
        ahOne.Assigned_To__c = UserInfo.getUserId();
        aphList.add(ahOne);
       
        insert aphList;
       
        showNextApprovalProcess.getNextApprover(supplyChainOppty.Id);
        
        Test.stopTest();
        
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c FROM Opportunity LIMIT 1];
        //System.assertEquals(supplyChainOppty.Approval_Status__c, 'Submitted - Pursuit Gate', 'Opportunity to be submitted for qualifciation gate');
    }
    
    @isTest
    static void testSMDProductSubmittedNextAprovers(){
        Opportunity supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c
                                       FROM Opportunity LIMIT 1];
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Geography__c countryUS = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' and name = 'United States'];
        countryUS.GEO_ID__c = Label.United_states_country;
        Update countryUS;
        Geography__c stateUS = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'State' and name = 'New Jersey'];
        Set<Id> productIds = new Set<Id>();
        for(Product2 prod : [SELECT Id, Name FROM Product2 WHERE OIPC_Code__c IN ('P-P0-2akk')]){
            productIds.add(prod.Id);
        }
        List<Opportunity_Product__c> optyList=TestBusinessHelper.createOpportunityLineItemCustoms(supplyChainOppty, productIds, tradeRoute, countryUS, stateUS, true);
        Test.startTest();
        showNextApprovalProcess.getNextApprover(supplyChainOppty.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testSkipPlatformApprovalsforRenewal(){
        Opportunity supplyChainOppty = [SELECT ID, Name,Type, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c
                                       FROM Opportunity LIMIT 1];
        supplyChainOppty.Type = 'Renewal';
        Update supplyChainOppty;
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Geography__c countryIndia = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' and name = 'India'];
        Geography__c stateKA = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'State' and name = 'Karnataka'];
        Set<Id> productIds = new Set<Id>();
        for(Product2 prod : [SELECT Id, Name FROM Product2 WHERE OIPC_Code__c IN ('P-P0-1ste','P-P0-1udc','P-P0-1ggy')]){
            productIds.add(prod.Id);
        }
        List<Opportunity_Product__c> optyList=TestBusinessHelper.createOpportunityLineItemCustoms(supplyChainOppty, productIds, tradeRoute, countryIndia, stateKA, true);
        Test.startTest();
        showNextApprovalProcess.getNextApprover(supplyChainOppty.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testSkipPlatformApprovalsforAddBusiness(){
        Opportunity supplyChainOppty = [SELECT ID, Name,Type, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c
                                       FROM Opportunity LIMIT 1];
        supplyChainOppty.Type = 'Additional Business';
        Update supplyChainOppty;
        system.debug('supplyChainOppty.Products_For_Approval__c@@'+supplyChainOppty.Products_For_Approval__c);
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Geography__c countryIndia = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' and name = 'India'];
        Geography__c stateKA = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'State' and name = 'Karnataka'];
        Set<Id> productIds = new Set<Id>();
        for(Product2 prod : [SELECT Id, Name FROM Product2 WHERE OIPC_Code__c IN ('P-P0-1ue5','P-P0-wet','P-P0-1ggy')]){
            productIds.add(prod.Id);
        }
        List<Opportunity_Product__c> optyList=TestBusinessHelper.createOpportunityLineItemCustoms(supplyChainOppty, productIds, tradeRoute, countryIndia, stateKA, true);
        for(Opportunity_Product__c oppprod : optyList){
            system.debug('oppty prod total gp@@'+oppprod.Total_Price__c);
            system.debug('oppty prod@@'+oppprod);
        }
        system.debug('supplyChainOppty.Products_For_Approval__c2@@'+supplyChainOppty.Products_For_Approval__c);
        Test.startTest();
        showNextApprovalProcess.getNextApprover(supplyChainOppty.Id);
        Test.stopTest();
    }
}