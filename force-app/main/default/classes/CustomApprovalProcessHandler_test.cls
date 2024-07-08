/*              
* Revision 	Ref Number	Date			Owner					Description
* -------- 	----------	-----------		-----------------		-----------
* 1.0      	SFSE-10586	28/04/2023		Aleena@maersk			Code created for Approval History records and mail notification
* 2.0		SFSE-11157	06-Jul-2023		Kiran@Maersk			OMEB 3.1 Full Approval Process
* 3.0       SFSE-12427  11/09/2023      Aleena@Maersk           Last Mile Porducts test method
* 4.0		SFSE-14118	11/03/2024		Jothsana@Maersk			Removing Maersk Flow(MF1) from OMEB
*/

@isTest
public without sharing class CustomApprovalProcessHandler_test {
    
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
        Geography__c chinaCountry = TestBusinessHelper.createGeography('China','Country', null, true);
        Geography__c uSCountry = TestBusinessHelper.createGeography('United States',  'Country',  null, true);
        Geography__c ukState = TestBusinessHelper.createGeography('London', 'State', ukCountry.Id, true);
        Geography__c state = TestBusinessHelper.createGeography('Karnataka', 'State', country.Id, true);
        Geography__c uSstate = TestBusinessHelper.createGeography('New Jersey', 'State', uSCountry.Id, true);
        Geography__c chinastate = TestBusinessHelper.createGeography('San Carlos','State', chinaCountry.Id, true);
        
        BDA__c parentBDA = TestBusinessHelper.createBDA('India, Middle East, and Africa', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true);
        BDA__c childBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'IBS', parentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, country.Id, null, true);
        
        BDA__c ukParentBDA = TestBusinessHelper.createBDA('United Kingdom', 'Other', 'EMEA', null, UserInfo.getUserId(), true);
        BDA__c ukChildBDA = TestBusinessHelper.createBDA('United Kingdom and Ireland Area', 'Cluster', 'UKI', ukParentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c ukBdaGeo = TestBusinessHelper.createBDAGeography(ukChildBDA.Id, ukCountry.Id, null, true);
        
        BDA__c uSParentBDA = TestBusinessHelper.createBDA('North America Region', 'Trade Region', 'NAM', null, UserInfo.getUserId(), true);
        BDA__c uSChildBDA = TestBusinessHelper.createBDA('North America Area', 'Cluster', 'NOA', uSParentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c uSBdaGeo = TestBusinessHelper.createBDAGeography(uSChildBDA.Id, uSCountry.Id, null, true);
        
        BDA__c chinaParentBDA = TestBusinessHelper.createBDA('Asia Pacific Region', 'Trade Region', 'APA', null, UserInfo.getUserId(), true);
        BDA__c chinaChildBDA = TestBusinessHelper.createBDA('Greater China Area', 'Cluster', 'GCA', chinaParentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c chinaBdaGeo = TestBusinessHelper.createBDAGeography(chinaChildBDA.Id, chinaCountry.Id, null, true);
        
        
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
            insert clientAccount;
            opportunity = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'Supply_Chain_Services', BrandUtilities.MAERSKLINE, false);
            opportunity.Id = null;
            opportunity.Requires_IT_Integration__c = 'Yes, I am sure this is required basis my discussion with customer';
            opportunity.Requires_Custom_Integration__c = 'Yes, I am sure this is required basis my discussion with customer';
            opportunity.Last_Shipment_Date__c = System.today() + 180;
            opportunity.First_Shipment_Date__c = System.today() + 60;
            opportunity.Estimated_Agreement_Duration__c = 30;
            
            insert opportunity;
        }
        system.debug('opportunity.Type@@'+opportunity.Type);
        List<Product2> productsToInsert = new List<Product2>();
        
        List<Products_For_Approval__mdt> productsForApprovalList =Products_For_Approval__mdt.getAll().values();
        
        Product2 product;
        for(Products_For_Approval__mdt prodForApprovalMD : Products_For_Approval__mdt.getAll().values()){
            if(prodForApprovalMD.Family_Code__c != 'cold_chain_logistics' && prodForApprovalMD.OIPC_Code__c != null){
                product = TestBusinessHelper.createProduct(prodForApprovalMD.Product_Family__c, false);
                product.Id = null;
                product.Family_Code__c = prodForApprovalMD.Family_Code__c;
                product.OIPC_Code__c = prodForApprovalMD.OIPC_Code__c;
                product.Include_in_OMEB_Approvals__c = true;
                productsToInsert.add(product);
            }
        }
        
        Product2 productColdStorage = TestBusinessHelper.createProduct('Cold Chain Logistics', false);
        productColdStorage.Id = null;
        productColdStorage.Family_Code__c = 'cold_chain_logistics';
        productColdStorage.OIPC_Code__c = 'P-P0-144i';
        productColdStorage.Name = 'Cold Storage';
        productColdStorage.Include_in_OMEB_Approvals__c = true;
        productsToInsert.add(productColdStorage);
        
        Product2 productContractLogistics = TestBusinessHelper.createProduct('Contract Logistics', false);
        productContractLogistics.Id = null;
        productContractLogistics.Family_Code__c = 'contract_logistics';
        productContractLogistics.OIPC_Code__c = 'P-P0-dwb';
        productContractLogistics.Name = 'Deconsolidation';
        productContractLogistics.Include_in_OMEB_Approvals__c = true;
        productsToInsert.add(productContractLogistics);
        
        Product2 productCustomServices = TestBusinessHelper.createProduct('Customs Services & Insurance', false);
        productCustomServices.Id = null;
        productCustomServices.Family_Code__c = 'customs_services';
        productCustomServices.OIPC_Code__c = 'P-P0-env';
        productCustomServices.Name = 'AEO Guru';
        productCustomServices.Include_in_OMEB_Approvals__c = true;
        productsToInsert.add(productCustomServices);
        
        Product2 productAirLcl = TestBusinessHelper.createProduct('Air & LCL', false);
        productAirLcl.Id = null;
        productAirLcl.Family_Code__c = 'air_n_lcl';
        productAirLcl.OIPC_Code__c = 'P-P0-dw2';
        productAirLcl.Name = 'Air Charter';
        productAirLcl.Include_in_OMEB_Approvals__c = true;
        productsToInsert.add(productAirLcl);
        
        Product2 productLastMiles = TestBusinessHelper.createProduct('E-commerce Logistics', false);
        productLastMiles.Id = null;
        productLastMiles.Family_Code__c = 'ecommerce_logistics';
        productLastMiles.OIPC_Code__c = 'P-P0-2xpo';
        productLastMiles.Name = 'Domestic Parcel Delivery';
        productLastMiles.Include_in_OMEB_Approvals__c = true;
        productsToInsert.add(productLastMiles);
        
        Product2 productMM = TestBusinessHelper.createProduct('Middle Mile', false);
        productMM.id = null;
        productMM.Family_Code__c = 'middle_mile';
        productMM.OIPC_Code__c = 'P-P0-255t';
        productMM.Include_in_OMEB_Approvals__c = true;
        productMM.Portfolio__c = 'LnS';
        productsToInsert.add(productMM);
        
        System.runAs(adminUser){
            insert productsToInsert;
            // Approval Process
            List<Approval_Process__c> approvalProcessToInsert = new List<Approval_Process__c>();
            Approval_Process__c processProductsPreWin = TestBusinessHelper.createApprovalPorcess('Pre-Win Gate Products', prewin, 'Product', 1, null, true, false);
            processProductsPreWin.Id = null;
            approvalProcessToInsert.add(processProductsPreWin);
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
            Approval_Process__c processPlatformPreWin = TestBusinessHelper.createApprovalPorcess('Pre-Win Gate Platform', prewin, 'Platform', 1, null, true, false);
            processPlatformPreWin.Id = null;
            approvalProcessToInsert.add(processPlatformPreWin);
            insert approvalProcessToInsert;
            
            //Approval Matrix data
            List<Approval_Process_Escalation_Matrix__c> proceMatrixToInsert = new List<Approval_Process_Escalation_Matrix__c>();
            Approval_Process_Escalation_Matrix__c processProdcutsPreWin = TestBusinessHelper.createApprovalPorcessMatrix(processProductsPreWin, country, 'IBS' , 'India, Middle East, and Africa', '4PL,MC1,MC2,MC3,MC4,MC5,MC6,MC7,MC8,MC9,AL,CS,LM,MM', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processProdcutsPreWin.Id = null;
            proceMatrixToInsert.add(processProdcutsPreWin);
            Approval_Process_Escalation_Matrix__c processMatrixKCPursuit = TestBusinessHelper.createApprovalPorcessMatrix(processKCPursuit, null, null, null, '4PL,SCM,CCL,ECM,WD,CS,GH', null, null, null, null, true, false);
            processMatrixKCPursuit.Id = null;
            proceMatrixToInsert.add(processMatrixKCPursuit);
            Approval_Process_Escalation_Matrix__c processMatrixPlatformSolution = TestBusinessHelper.createApprovalPorcessMatrix(processPlatformSolution, country, 'IBS' , 'India, Middle East, and Africa', 'MC1,MC2,MC3,MC4,MC5,MC6,MC7,MC8,MC9,AL,CS,LM,MM', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processMatrixPlatformSolution.Id = null;
            proceMatrixToInsert.add(processMatrixPlatformSolution);
            Approval_Process_Escalation_Matrix__c processMatrixProductsSolution = TestBusinessHelper.createApprovalPorcessMatrix(processProductsSolution, country, 'IBS' , 'India, Middle East, and Africa', 'MC1,MC2,MC3,MC4,MC5,MC6,MC7,MC8,MC9,AL,CS,LM,SMD', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processMatrixProductsSolution.Id = null;
            proceMatrixToInsert.add(processMatrixProductsSolution);
            Approval_Process_Escalation_Matrix__c processMatrixProductPursuit = TestBusinessHelper.createApprovalPorcessMatrix(processProductsPursuit, country, 'IBS' , 'India, Middle East, and Africa', '4PL,SCM,CCL,ECM,WD,CS,GH', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processMatrixProductPursuit.Id = null;
            proceMatrixToInsert.add(processMatrixProductPursuit);
            Approval_Process_Escalation_Matrix__c processMatrixCLQualification = TestBusinessHelper.createApprovalPorcessMatrix(processCLQualification, null, null, null, 'CL,GL', null, null, null, null, true, false);
            processMatrixCLQualification.Id = null;
            Approval_Process_Escalation_Matrix__c processMatrixProductPursuitUK = TestBusinessHelper.createApprovalPorcessMatrix(processProductsPursuit, ukCountry, 'UKI' , 'United Kingdom', 'WD', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processMatrixProductPursuitUK.Id = null;
            proceMatrixToInsert.add(processMatrixCLQualification);
            Approval_Process_Escalation_Matrix__c processMatrixPlatformQualification = TestBusinessHelper.createApprovalPorcessMatrix(processQualificationPlatform, country, 'IBS' , 'India, Middle East, and Africa', '4PL,SCM,CCL', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processMatrixPlatformQualification.Id = null;
            proceMatrixToInsert.add(processMatrixPlatformQualification);
            Approval_Process_Escalation_Matrix__c processMatrixPlatformPreWin = TestBusinessHelper.createApprovalPorcessMatrix(processPlatformPreWin, country, 'IBS' , 'India, Middle East, and Africa', '4PL,SCM,CCL,MC1,MC2,MC3,MC4,MC5,MC6,MC7,MC8,MC9,AL,CS,MM,SMD', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processMatrixPlatformPreWin.Id = null;
            proceMatrixToInsert.add(processMatrixPlatformPreWin);
            Approval_Process_Escalation_Matrix__c processMatrixLMSolution = TestBusinessHelper.createApprovalPorcessMatrix(processProductsSolution,country,'IBS','India, Middle East, and Africa','LM',new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processMatrixLMSolution.Id = null;
            proceMatrixToInsert.add(processMatrixLMSolution);
            Approval_Process_Escalation_Matrix__c processMatrixProductsSolutionuK = TestBusinessHelper.createApprovalPorcessMatrix(processProductsSolution, ukCountry, 'UKI' , 'United Kingdom', 'LM', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processMatrixProductsSolutionuK.Id = null;
            proceMatrixToInsert.add(processMatrixProductsSolutionuK);
            Approval_Process_Escalation_Matrix__c processMatrixProdcutsPreWinUk = TestBusinessHelper.createApprovalPorcessMatrix(processProductsPreWin, ukCountry, 'UKI' , 'United Kingdom', 'LM', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processMatrixProdcutsPreWinUk.Id = null;
            proceMatrixToInsert.add(processMatrixProdcutsPreWinUk);
            insert proceMatrixToInsert;
        }
        TriggerExecutionController.skipAllTriggers(false);
        
        Test.stopTest();
    } 
    
    @isTest
    static void testMFCLProductSubmissionToPursuitAndQualification() {
        Opportunity supplyChainOppty = [SELECT ID, Name,Type, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, createdById
                                       FROM Opportunity LIMIT 1];
        Geography__c countryIndia = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' and name = 'India'];
        Geography__c stateKA = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'State' and name = 'Karnataka'];
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        salesUserId = supplyChainOppty.createdById;
        adminUserId = tradeRoute.createdById;
        Set<Id> productIds = new Set<Id>();
        for(Product2 prod : [SELECT Id, Name FROM Product2 WHERE OIPC_Code__c IN ('P-P0-dwb','P-P0-1cm1')]){
            productIds.add(prod.Id);
        }
        List<Opportunity_Product__c> optyList = TestBusinessHelper.createOpportunityLineItemCustoms(supplyChainOppty, productIds, tradeRoute, countryIndia, stateKA, true);
        Test.startTest();
        
        //System.runAs(new User(Id = salesUserId)){
            TestBusinessHelper.createOpportunityLineItemCustoms(supplyChainOppty, productIds, tradeRoute, countryIndia, stateKA, true);
            System.debug(supplyChainOppty.Approval_Required__c  +'--- '+supplyChainOppty.Products_for_Approval__c +' @@supplyChainOppty@@ '+supplyChainOppty);
            supplyChainOppty = [SELECT ID, Name,Type, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, createdById, Opportunity_Owner_Country__c
                                       FROM Opportunity LIMIT 1];
            System.debug(supplyChainOppty.Approval_Required__c  +'--- '+supplyChainOppty.Products_for_Approval__c +' @@supplyChainOppty@@ '+supplyChainOppty);
            
            //Create parameter
            Map<String, Object> Params = new Map<String, Object>();
            Params.put('Opportunity', supplyChainOppty);
            
            //create instance of Interview
            Flow.Interview.Opportunity_Pursuit_Gate_Approval_Process callPursuit = new Flow.Interview.Opportunity_Pursuit_Gate_Approval_Process(Params);
            //Invoke start method
            callPursuit.start();
           
        Test.stopTest();
        
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c FROM Opportunity LIMIT 1];
        
        List<Batch_Error_Logger__c> errorLogs = [SELECT Id, Name, Exception_Cause__c, Exception_Code__c, Exception_Detail__c, Exception_Summary__c FROM Batch_Error_Logger__c WHERE createddate = today];
        System.debug('errorLogs size '+errorLogs.size() +' errorLogs '+errorLogs);
    }
    
    @isTest
    static void testMCSandCSProductSubmissionToPreWin() {
        
        Opportunity supplyChainOppty = [SELECT ID, Name,Type, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, CreatedById
                                       FROM Opportunity LIMIT 1];
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Geography__c countryIndia = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' and name = 'India'];
        Geography__c stateKA = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'State' and name = 'Karnataka'];
        salesUserId = supplyChainOppty.CreatedById;
        adminUserId = tradeRoute.CreatedById;
        
        Test.startTest();
        Set<Id> productIds = new Set<Id>();
        for(Product2 prod : [SELECT Id, Name FROM Product2 WHERE OIPC_Code__c IN ('P-P0-env','P-P0-144i')]){
            productIds.add(prod.Id);
        }
        //System.runAs(new User(Id = salesUserId)){
            
            TestBusinessHelper.createOpportunityLineItemCustoms(supplyChainOppty, productIds, tradeRoute, countryIndia, stateKA, true);
        	
            System.debug(supplyChainOppty.Approval_Required__c  +'--- '+supplyChainOppty.Products_for_Approval__c +' @@supplyChainOppty@@ '+supplyChainOppty);
            supplyChainOppty = [SELECT ID, Name, StageName,Type, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, Opportunity_Owner_Country__c
                                FROM Opportunity LIMIT 1];
        	supplyChainOppty.Approval_Status__c = 'Approved - Solution Gate';
        	supplyChainOppty.StageName = 'Quoting';
        	Update supplyChainOppty;
            //Create parameter
            Map<String, Object> Params = new Map<String, Object>();
            Params.put('Opportunity', supplyChainOppty);
            
            //create instance of Interview
            Flow.Interview.Opportunity_Pre_Win_Gate_Approval_Process callPreWin = new Flow.Interview.Opportunity_Pre_Win_Gate_Approval_Process(Params);
            //Invoke start method
            callPreWin.start();
        //}
        Test.stopTest();
        
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c FROM Opportunity LIMIT 1];
        //System.assertEquals(supplyChainOppty.Approval_Status__c, 'Submitted - Pursuit Gate', 'Opportunity to be submitted for pursuit gate');
        
        List<Batch_Error_Logger__c> errorLogs = [SELECT Id, Name, Exception_Cause__c, Exception_Code__c, Exception_Detail__c, Exception_Summary__c FROM Batch_Error_Logger__c WHERE createddate = today];
        System.debug('errorLogs size '+errorLogs.size() +' errorLogs '+errorLogs);
    }
    @isTest
    static void testLMProductSubmissionToPreWinlessthan50K() {
        
        Opportunity supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, CreatedById
                                       FROM Opportunity LIMIT 1];
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Geography__c countryIndia = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' and name = 'India'];
        Geography__c stateKA = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'State' and name = 'Karnataka'];
        salesUserId = supplyChainOppty.CreatedById;
        adminUserId = tradeRoute.CreatedById;
        
        
        Set<Id> productIds = new Set<Id>();
        for(Product2 prod : [SELECT Id, Name FROM Product2 WHERE OIPC_Code__c IN ('P-P0-2xpo','P-P0-2z95')]){
            productIds.add(prod.Id);
        }
        //System.runAs(new User(Id = salesUserId)){
            
            List<Opportunity_Product__c> optyList=TestBusinessHelper.createOpportunityLineItemCustoms(supplyChainOppty, productIds, tradeRoute, countryIndia, stateKA, true);
            optyList[0].UnitPrice__c = 10;
            optyList[0].Quantity__c = 20;
            optyList[0].L_S_Product__c = true;
            TriggerExecutionController.skipAllTriggers(true);
            Update optyList;
            TriggerExecutionController.skipAllTriggers(false);
        for (Opportunity_Product__c opp:optyList){
            system.debug('AGP'+opp.Annualized_Gross_Profit__c);
        }
            System.debug(supplyChainOppty.Approval_Required__c  +'--- '+supplyChainOppty.Products_for_Approval__c +' @@supplyChainOppty@@ '+supplyChainOppty);
            supplyChainOppty = [SELECT ID, Name,Type, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, Opportunity_Owner_Country__c
                                FROM Opportunity LIMIT 1];
        	supplyChainOppty.Approval_Status__c = 'Approved - Solution Gate';
        	supplyChainOppty.StageName = 'Quoting';
        	Update supplyChainOppty;
            //Create parameter
            Test.startTest();
            Map<String, Object> Params = new Map<String, Object>();
            Params.put('Opportunity', supplyChainOppty);
            
            //create instance of Interview
            Flow.Interview.Opportunity_Pre_Win_Gate_Approval_Process callPreWin = new Flow.Interview.Opportunity_Pre_Win_Gate_Approval_Process(Params);
            //Invoke start method
            callPreWin.start();
        //}
        Test.stopTest();
        
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c FROM Opportunity LIMIT 1];
        //System.assertEquals(supplyChainOppty.Approval_Status__c, 'Submitted - Pursuit Gate', 'Opportunity to be submitted for pursuit gate');
        
        List<Batch_Error_Logger__c> errorLogs = [SELECT Id, Name, Exception_Cause__c, Exception_Code__c, Exception_Detail__c, Exception_Summary__c FROM Batch_Error_Logger__c WHERE createddate = today];
        System.debug('errorLogs size '+errorLogs.size() +' errorLogs '+errorLogs);
    }
    @isTest
    Static void testPursuitGateProduct(){
         Opportunity supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, CreatedById
                                       FROM Opportunity LIMIT 1];
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Geography__c countryUK = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' and name = 'United Kingdom'];
        Geography__c stateLN = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'State' and name = 'London'];
        salesUserId = supplyChainOppty.CreatedById;
        adminUserId = tradeRoute.CreatedById;
    
        Test.startTest();
        Set<Id> productIds = new Set<Id>();
        for(Product2 prod : [SELECT Id, Name FROM Product2 WHERE OIPC_Code__c IN ('P-P0-dwb')]){
            productIds.add(prod.Id);
        }
        //System.runAs(new User(Id = salesUserId)){
            
            List<Opportunity_Product__c> optyList = TestBusinessHelper.createOpportunityLineItemCustoms(supplyChainOppty, productIds, tradeRoute, countryUK, stateLN, true);
        	optyList[0].UnitPrice__c = 10000000;
        	optyList[0].Discount__c = 5;
        	optyList[0].Quantity__c = 200;
        	update optyList;
        for(Opportunity_Product__c opty : optyList){
            System.debug('Total Price >> '+optyList[0].Annualized_Gross_Profit__c);
        }
            
        
            supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c,Type, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, Opportunity_Owner_Country__c
                                FROM Opportunity LIMIT 1];
        	System.debug(supplyChainOppty.Approval_Required__c  +'--- '+supplyChainOppty.Products_for_Approval__c +' @@supplyChainOppty@@ '+supplyChainOppty);
            //Create parameter
            Map<String, Object> Params = new Map<String, Object>();
            Params.put('Opportunity', supplyChainOppty);
            
            //create instance of Interview
            Flow.Interview.Opportunity_Pursuit_Gate_Approval_Process callPursuit = new Flow.Interview.Opportunity_Pursuit_Gate_Approval_Process(Params);
            //Invoke start method
            callPursuit.start();
        //}
        Test.stopTest();
        
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c FROM Opportunity LIMIT 1];
        //System.assertEquals(supplyChainOppty.Approval_Status__c, 'Submitted - Pursuit Gate', 'Opportunity to be submitted for pursuit gate');
        
        List<Batch_Error_Logger__c> errorLogs = [SELECT Id, Name, Exception_Cause__c, Exception_Code__c, Exception_Detail__c, Exception_Summary__c FROM Batch_Error_Logger__c WHERE createddate = today];
        System.debug('errorLogs size '+errorLogs.size() +' errorLogs '+errorLogs);
    }
    
    @isTest
    Static void testSolutionGateProductMCS(){
         Opportunity supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c,Type, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, CreatedById
                                       FROM Opportunity LIMIT 1];
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Geography__c countryUK = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' and name = 'United Kingdom'];
        Geography__c stateLN = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'State' and name = 'London'];
        salesUserId = supplyChainOppty.CreatedById;
        adminUserId = tradeRoute.CreatedById;
    
        Test.startTest();
        Set<Id> productIds = new Set<Id>();
        for(Product2 prod : [SELECT Id, Name FROM Product2 WHERE OIPC_Code__c IN ('P-P0-env','P-P0-dw2','P-P0-2z95')]){
            productIds.add(prod.Id);
        }
        //System.runAs(new User(Id = salesUserId)){
            
            List<Opportunity_Product__c> optyList = TestBusinessHelper.createOpportunityLineItemCustoms(supplyChainOppty, productIds, tradeRoute, countryUK, stateLN, true);
        	optyList[0].UnitPrice__c = 10;
        	optyList[0].Discount__c = 5;
        	optyList[0].Quantity__c = 200;
        	optyList[0].Exclude_From_OMEB__c = false;
            optyList[0].Country__c = countryUK.id;
           TriggerExecutionController.skipAllTriggers(true);
        	update optyList;
           TriggerExecutionController.skipAllTriggers(false);
        for(Opportunity_Product__c opty : optyList){
            System.debug('Total Price >> '+optyList[0].Annualized_Gross_Profit__c);
        }
            
        
            supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c,Type, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, Opportunity_Owner_Country__c
                                FROM Opportunity LIMIT 1];
        	System.debug(supplyChainOppty.Approval_Required__c  +'--- '+supplyChainOppty.Products_for_Approval__c +' @@supplyChainOppty@@ '+supplyChainOppty);
            //Create parameter
            Map<String, Object> Params = new Map<String, Object>();
        	supplyChainOppty.Approval_Status__c = 'Approved - Qualification Gate';
        	supplyChainOppty.StageName = 'Designing Proposal';
        	Update supplyChainOppty;
            Params.put('Opportunity', supplyChainOppty);
            System.debug(supplyChainOppty.Approval_Required__c  +'--- '+supplyChainOppty.Products_for_Approval__c +' @@==supplyChainOppty@@ '+supplyChainOppty);

            //create instance of Interview
            Flow.Interview.Opportunity_Solution_Gate_Approval_Process callSolution = new Flow.Interview.Opportunity_Solution_Gate_Approval_Process(Params);
            //Invoke start method
            callSolution.start();
        //}
        Test.stopTest();
        
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c FROM Opportunity LIMIT 1];
        //System.assertEquals(supplyChainOppty.Approval_Status__c, 'Submitted - Pursuit Gate', 'Opportunity to be submitted for pursuit gate');
        
        List<Batch_Error_Logger__c> errorLogs = [SELECT Id, Name, Exception_Cause__c, Exception_Code__c, Exception_Detail__c, Exception_Summary__c FROM Batch_Error_Logger__c WHERE createddate = today];
        System.debug('errorLogs size '+errorLogs.size() +' errorLogs '+errorLogs);
    }
    @istest
    static void testLMProductSubmissionToPreWinmoreThan50k() {
        
        Opportunity supplyChainOppty = [SELECT ID, Name, StageName,Type, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, CreatedById
                                       FROM Opportunity limit 1];
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Geography__c countryUK = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' and name = 'United Kingdom'];
        Geography__c stateLN = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'State' and name = 'London'];
        salesUserId = supplyChainOppty.CreatedById;
        adminUserId = tradeRoute.CreatedById;
        
       /* List<Approval_Process__c> app = [select id,Active__c, Name from Approval_Process__c limit 1];
        app[0].Name = 'Pre-Win Gate Products';
        app[0].Active__c=true;
        List<Approval_Process_Escalation_Matrix__c> apm = [select id , Approval_Process_Name__c, Active__c, Vertical__c from Approval_Process_Escalation_Matrix__c limit 1];
        apm[0].Approval_Process_Name__c = app[0].id;
        apm[0].Active__c = true;
        apm[0].Auto_Approved__c=false;*/
        
        Test.startTest();
        Set<Id> productIds = new Set<Id>();
        for(Product2 prod : [SELECT Id, Name FROM Product2 WHERE OIPC_Code__c IN ('P-P0-2xpo')]){
            productIds.add(prod.Id);
        }

        
        //System.runAs(new User(Id = salesUserId)){
            
           List<Opportunity_Product__c> optyList=TestBusinessHelper.createOpportunityLineItemCustoms(supplyChainOppty, productIds, tradeRoute, countryUK, stateLN, true);
            optyList[0].UnitPrice__c = 1000;
            optyList[0].Quantity__c = 200000;
            optyList[0].Discount__c = 20;
            optyList[0].L_S_Product__c = true;
            optyList[0].Exclude_From_OMEB__c = false;
            optyList[0].Country__c = countryUK.id;
            TriggerExecutionController.skipAllTriggers(true);
            Update optyList;
            TriggerExecutionController.skipAllTriggers(false);
            System.debug(supplyChainOppty.Approval_Required__c  +'--- '+supplyChainOppty.Products_for_Approval__c +' @@supplyChainOppty@@ '+supplyChainOppty);
             supplyChainOppty = [SELECT ID, Name, StageName,Type, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, Opportunity_Owner_Country__c
                                FROM Opportunity  LIMIT 1];
            System.debug(supplyChainOppty.Approval_Required__c  +'--- '+supplyChainOppty.Products_for_Approval__c +' @@==supplyChainOppty@@ '+supplyChainOppty);

        	supplyChainOppty.Approval_Status__c = 'Approved - Solution Gate';
        	supplyChainOppty.StageName = 'Quoting';
            TriggerExecutionController.skipAllTriggers(true);
        	Update supplyChainOppty;
            TriggerExecutionController.skipAllTriggers(false);
            System.debug(supplyChainOppty.Approval_Required__c  +'--- '+supplyChainOppty.Products_for_Approval__c +' @@==>>supplyChainOppty@@ '+supplyChainOppty);

            //Create parameter
  
            Map<String, Object> Params = new Map<String, Object>();
            Params.put('Opportunity', supplyChainOppty);
            
            //create instance of Interview
            Flow.Interview.Opportunity_Pre_Win_Gate_Approval_Process callPreWin = new Flow.Interview.Opportunity_Pre_Win_Gate_Approval_Process(Params);
            //Invoke start method
            callPreWin.start();
        //}
        Test.stopTest();
        
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c FROM Opportunity LIMIT 1];
        //System.assertEquals(supplyChainOppty.Approval_Status__c, 'Submitted - Pursuit Gate', 'Opportunity to be submitted for pursuit gate');
        
        List<Batch_Error_Logger__c> errorLogs = [SELECT Id, Name, Exception_Cause__c, Exception_Code__c, Exception_Detail__c, Exception_Summary__c FROM Batch_Error_Logger__c WHERE createddate = today];
        System.debug('errorLogs size '+errorLogs.size() +' errorLogs '+errorLogs);
    }
    @isTest
    static void testMMproductSubmitForApprovalSolution(){
        Opportunity supplyChainOppty = [SELECT ID, Name, StageName,Type, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, CreatedById
                                       FROM Opportunity LIMIT 1];
        
        Assert.isNull(supplyChainOppty.Products_for_Approval__c);
        Assert.areEqual(false, supplyChainOppty.Must_Go_To_OMEB__c);
        
        Map<String, Geography__c> countyGeographyMap = new Map<String, Geography__c>();
        for(Geography__c country : [SELECT Id, Name FROM Geography__c Where Type_Of_Location__c = 'Country' AND Active__c = true]){
            countyGeographyMap.put(country.Name, country);
        }
        
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Product2 mmProduct = [SELECT Id FROM Product2 where OIPC_Code__c = 'P-P0-255t' AND IsActive = true LIMIT 1];
        List<Approval_History__c> historyList = new List<Approval_History__c>();
        Boolean isSuccess;
        Test.startTest();
        Opportunity_Product__c customOliMMProduct = TestBusinessHelper.createOpportunityLineItemCustom(supplyChainOppty, mmProduct.Id, tradeRoute, false);
        customOliMMProduct.Id = null;
        customOliMMProduct.Country__c = countyGeographyMap.get('India').Id;
        customOliMMProduct.Quantity__c = 1000000;
        customOliMMProduct.UnitPrice__c = 10000;
        customOliMMProduct.Product_Revenue_Per_Unit__c = 1;
        customOliMMProduct.L_S_Product__c = True;
        insert customOliMMProduct;
        system.debug( 'customOliMMProduct@@' + [Select id,Quantity__c,UnitPrice__c,L_S_Product__c,Annualized_Gross_Profit__c,Total_Price__c from Opportunity_Product__c where id=:customOliMMProduct.Id]);
       supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c,Opportunity_Owner_Country__c, Requires_IT_Integration__c, Owner_Area_Code__c, CreatedById,Type
                                       FROM Opportunity LIMIT 1];
        //Create parameter
        system.debug('agp@@@'+customOliMMProduct.Annualized_Gross_Profit__c);
        system.debug('supplyChainOppty@@'+supplyChainOppty);
        Map<String, Object> Params = new Map<String, Object>();
            supplyChainOppty.Approval_Status__c = 'Approved - Qualification Gate';
        	supplyChainOppty.StageName = 'Designing Proposal';
            update supplyChainOppty;
        Params.put('Opportunity', supplyChainOppty);
        
        
        System.runAs(new User(Id = supplyChainOppty.createdById)){
      
            Flow.Interview.Opportunity_Solution_Gate_Approval_Process callSolution = new Flow.Interview.Opportunity_Solution_Gate_Approval_Process(Params);
            //Invoke start method
            callSolution.start();
        }
        
        historyList = [SELECT Id from Approval_History__c where TargetObjectId__c =:supplyChainOppty.Id AND Status__c = 'Pending'];
        Assert.areEqual(1, historyList.size());
        
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c,Type, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, CreatedById
                                       FROM Opportunity LIMIT 1];
        Assert.isNotNull(supplyChainOppty.Products_for_Approval__c);
        Assert.areEqual('MM3', supplyChainOppty.Products_for_Approval__c);
        Assert.areEqual(true, supplyChainOppty.Must_Go_To_OMEB__c);
        Assert.areEqual('Submitted - Solution Gate', supplyChainOppty.Approval_Status__c);
        
        historyList = [SELECT Id, Assigned_To__c from Approval_History__c where TargetObjectId__c =:supplyChainOppty.Id AND Status__c = 'Pending'];
        Assert.areEqual(1, historyList.size());
        
        System.runAs(new User(Id = historyList[0].Assigned_To__c)){
            isSuccess = ApprovalHistoryController.approveRecord(historyList[0].Id, 'Approving from test class', '');
        }
        Assert.areEqual(isSuccess, true);
        
        
        Test.stopTest();
        
       
        historyList = [SELECT Id, Assigned_To__c from Approval_History__c where TargetObjectId__c =:supplyChainOppty.Id AND Status__c = 'Pending'];
        Assert.areEqual(0, historyList.size());
        
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                            Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, createdById, Opportunity_Owner_Country__c, Type
                            FROM Opportunity LIMIT 1];
        
        Assert.areEqual('Approved - Solution Gate', supplyChainOppty.Approval_Status__c);
        Assert.areEqual(Label.Quoting, supplyChainOppty.StageName);
        
    }
   @isTest
    static void testMMproductSubmitForApprovalPreWingate(){
         Opportunity supplyChainOppty = [SELECT ID, Name, StageName,Type, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, CreatedById
                                       FROM Opportunity LIMIT 1];
        Assert.isNull(supplyChainOppty.Products_for_Approval__c);
        Assert.areEqual(false, supplyChainOppty.Must_Go_To_OMEB__c);
        Map<String, Geography__c> countyGeographyMap = new Map<String, Geography__c>();
        for(Geography__c country : [SELECT Id, Name FROM Geography__c Where Type_Of_Location__c = 'Country' AND Active__c = true]){
            countyGeographyMap.put(country.Name, country);
        }
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Product2 mmProduct = [SELECT Id FROM Product2 where OIPC_Code__c = 'P-P0-255t' AND IsActive = true LIMIT 1];
        List<Approval_History__c> historyList = new List<Approval_History__c>();
        Boolean isSuccess;
        Test.startTest();
        Opportunity_Product__c customOliMMProduct = TestBusinessHelper.createOpportunityLineItemCustom(supplyChainOppty, mmProduct.Id, tradeRoute, false);
        customOliMMProduct.Id = null;
        customOliMMProduct.Country__c = countyGeographyMap.get('India').Id;
        customOliMMProduct.Quantity__c = 100000;
        customOliMMProduct.UnitPrice__c = 100;
        customOliMMProduct.Product_Revenue_Per_Unit__c = 1;
        customOliMMProduct.L_S_Product__c = True;
        insert customOliMMProduct;
 
        //Update Quantity and Unit price to make Annualized Gp >100k
     
        system.debug( 'customOliMMProduct@@' + [Select id,Quantity__c,UnitPrice__c,L_S_Product__c,Annualized_Gross_Profit__c,Total_Price__c from Opportunity_Product__c where id=:customOliMMProduct.Id]);
 
       supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c,Opportunity_Owner_Country__c, Requires_IT_Integration__c, Owner_Area_Code__c, CreatedById,Type
                                       FROM Opportunity LIMIT 1];
        //Create parameter
        system.debug('agp@@@'+customOliMMProduct.Annualized_Gross_Profit__c);
        system.debug('supplyChainOppty@@'+supplyChainOppty);
        Map<String, Object> Params = new Map<String, Object>();
            supplyChainOppty.Approval_Status__c = 'Approved - Pursuit Gate';
        	supplyChainOppty.StageName = 'Qualifying';
            TriggerExecutionController.skipAllTriggers(true);
            update supplyChainOppty;
            supplyChainOppty.Approval_Status__c = 'Approved - Qualification Gate';
            supplyChainOppty.StageName = 'Designing Proposal';
            update supplyChainOppty;
            supplyChainOppty.Approval_Status__c = 'Approved - Solution Gate';
        	supplyChainOppty.StageName = 'Quoting';
            update supplyChainOppty;
            TriggerExecutionController.skipAllTriggers(false);
        Params.put('Opportunity', supplyChainOppty);

        System.runAs(new User(Id = supplyChainOppty.createdById)){
            Flow.Interview.Opportunity_Pre_Win_Gate_Approval_Process callPreWin = new Flow.Interview.Opportunity_Pre_Win_Gate_Approval_Process(Params);
            //Invoke start method
            callPreWin.start();
        }
        historyList = [SELECT Id from Approval_History__c where TargetObjectId__c =:supplyChainOppty.Id AND Status__c = 'Pending'];
        Assert.areEqual(2, historyList.size());
        supplyChainOppty = [SELECT ID, Name,Type, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, CreatedById
                                       FROM Opportunity LIMIT 1];
        Assert.isNotNull(supplyChainOppty.Products_for_Approval__c);
        Assert.areEqual('MM3', supplyChainOppty.Products_for_Approval__c);
        Assert.areEqual(true, supplyChainOppty.Must_Go_To_OMEB__c);
        Assert.areEqual('Submitted - Pre-Win Gate', supplyChainOppty.Approval_Status__c);
        historyList = [SELECT Id, Assigned_To__c from Approval_History__c where TargetObjectId__c =:supplyChainOppty.Id AND Status__c = 'Pending'];
        Assert.areEqual(2, historyList.size());
        System.runAs(new User(Id = historyList[0].Assigned_To__c)){
            isSuccess = ApprovalHistoryController.approveRecord(historyList[0].Id, 'Approving from test class', '');
        }
        Assert.areEqual(isSuccess, true);
		System.runAs(new User(Id = historyList[1].Assigned_To__c)){
            isSuccess = ApprovalHistoryController.approveRecord(historyList[1].Id, 'Approving from test class', '');
        }
        Test.stopTest();

        historyList = [SELECT Id, Assigned_To__c from Approval_History__c where TargetObjectId__c =:supplyChainOppty.Id AND Status__c = 'Pending'];
        Assert.areEqual(0, historyList.size());
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                            Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, createdById, Opportunity_Owner_Country__c, Type
                            FROM Opportunity LIMIT 1];
        Assert.areEqual('Approved - Pre-Win Gate', supplyChainOppty.Approval_Status__c);
        Assert.areEqual(Label.Quoting, supplyChainOppty.StageName);

    }
}