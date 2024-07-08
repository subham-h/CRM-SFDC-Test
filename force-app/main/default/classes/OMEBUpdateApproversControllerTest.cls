@isTest
public class OMEBUpdateApproversControllerTest {

    private static final String pursuit = System.Label.Pursuit_Gate;
    private static final String qualification = System.Label.Feasibility_Gate;
    private static final String solution = System.Label.Solution_Gate;
    private static final String prewin = System.Label.Pre_Win_Gate;

    @testSetup
    static void loadData(){
        
        User adminUser = TestBusinessHelper.createUser('System Administrator', BrandUtilities.MAERSKLINE, true);
        
        List<Geography__c> geoInsertList = new List<Geography__c>();
        Geography__c indCountry = TestBusinessHelper.createGeography('India', 'Country', null, false);
        indCountry.Id = null;
        indCountry.GEO_Code__c = 'IN';
        Geography__c ukCountry = TestBusinessHelper.createGeography('United Kingdom', 'Country', null, false);
        ukCountry.Id = null;
        ukCountry.GEO_Code__c = 'UK';
        Geography__c chinaCountry = TestBusinessHelper.createGeography('China','Country', null, false);
        chinaCountry.Id = null;
        chinaCountry.GEO_Code__c = 'CN';
        Geography__c uSCountry = TestBusinessHelper.createGeography('United States',  'Country',  null, false);
        uSCountry.Id = null;
        uSCountry.GEO_Code__c = 'US';
        Geography__c russiaCountry = TestBusinessHelper.createGeography('Russia','Country', null, false);
        russiaCountry.Id = null;
        
        geoInsertList.add(indCountry);
        geoInsertList.add(ukCountry);
        geoInsertList.add(chinaCountry);
        geoInsertList.add(uSCountry);
        geoInsertList.add(russiaCountry);
        
        System.runAs(adminUser){
            insert geoInsertList;
        }
        
        geoInsertList = new List<Geography__c>();
        Geography__c ukState = TestBusinessHelper.createGeography('London', 'State', ukCountry.Id, false);
        ukState.Id = null;
        Geography__c stateKA = TestBusinessHelper.createGeography('Karnataka', 'State', indCountry.Id, false);
        stateKA.Id = null;
        Geography__c uSstate = TestBusinessHelper.createGeography('New Jersey', 'State', uSCountry.Id, false);
        uSstate.Id = null;
        Geography__c chinastate = TestBusinessHelper.createGeography('San Carlos','State', chinaCountry.Id, false);
        chinastate.Id = null;
        geoInsertList.add(ukState);
        geoInsertList.add(stateKA);
        geoInsertList.add(uSstate);
        geoInsertList.add(chinastate);
        
        System.runAs(adminUser){
            insert geoInsertList;
        }
        
        BDA__c indParentBDA = TestBusinessHelper.createBDA('India, Middle East, and Africa', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true);
        BDA__c indChildBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'IBS', indParentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c indbdaGeo = TestBusinessHelper.createBDAGeography(indChildBDA.Id, indCountry.Id, null, true);
        
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
        
        User salesUser = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
        salesUser.Id = null;
        salesUser.Country = 'India';
        salesUser.FederationIdentifier = 'ABCSALES1234';
        
        User salesUserFromIndia4PLApprover = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
        salesUserFromIndia4PLApprover.Id = null;
        salesUserFromIndia4PLApprover.Country = 'India';
        salesUserFromIndia4PLApprover.FederationIdentifier = 'ABC1234';
        
        User salesUserFromIndia4PLEscApprover = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
        salesUserFromIndia4PLEscApprover.Id = null;
        salesUserFromIndia4PLEscApprover.Country = 'India';
        salesUserFromIndia4PLEscApprover.FederationIdentifier = 'ABCESC1234';

        User salesUserFromUS = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
        salesUserFromUS.Id = null;
        salesUserFromUS.country = 'United States';
        salesUserFromUS.FederationIdentifier = 'ABC1235';

        User salesUserFromUK = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
        salesUserFromUK.Id = null;
        salesUserFromUK.country = 'United Kingdom';
        salesUserFromUK.FederationIdentifier = 'ABC1236';

        User salesUserFromChina = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
        salesUserFromChina.Id = null;
        salesUserFromChina.country = 'China';
        salesUserFromChina.FederationIdentifier = 'ABC1237';
        
        usersToInsert.add(salesUser);
        usersToInsert.add(salesUserFromIndia4PLApprover);
        usersToInsert.add(salesUserFromIndia4PLEscApprover);
        usersToInsert.add(salesUserFromUS);
        usersToInsert.add(salesUserFromUK);
        usersToInsert.add(salesUserFromChina);
        
        System.runAs(new User(Id = UserInfo.getUserId())){
            //insert usersToInsert;
            insert salesUser;
            insert salesUserFromIndia4PLApprover;
            insert salesUserFromIndia4PLEscApprover;
            insert salesUserFromUS;
            insert salesUserFromUK;
            insert salesUserFromChina;
        }
        Trade_Route__c tradeRoute;
        System.runAs(adminUser){
            tradeRoute = TestBusinessHelper.createTradeRoutes(new List<String>{BrandUtilities.MCC}, 1, true)[0];
        }
        
        Account clientAccount;
        Opportunity opportunity;
        System.runAs(salesUser){
            clientAccount = TestBusinessHelper.createAccount('Client_Account', false);
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
        
        List<Product2> productsToInsert = new List<Product2>();
        
        List<Products_For_Approval__mdt> productsForApprovalList =Products_For_Approval__mdt.getAll().values();
        
        Product2 product;
        for(Products_For_Approval__mdt prodForApprovalMD : Products_For_Approval__mdt.getAll().values()){
            if(prodForApprovalMD.Family_Code__c != 'cold_chain_logistics' && prodForApprovalMD.Family_Code__c != 'contract_logistics ' && prodForApprovalMD.OIPC_Code__c != null){
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
        productContractLogistics.IsActive = true;
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
        
        Test.startTest();
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
            Approval_Process__c processProductQualification = TestBusinessHelper.createApprovalPorcess('Qualification Gate Products', qualification, 'Product', 3, 0, true, false);
            processProductQualification.Id = null;
            approvalProcessToInsert.add(processProductQualification);
            Approval_Process__c processPlatformQualification = TestBusinessHelper.createApprovalPorcess('Qualification Gate Platform', qualification, 'Platform', 4, 0, true, false);
            processPlatformQualification.Id = null;
            approvalProcessToInsert.add(processPlatformQualification);
            Approval_Process__c processIntegrationQualification = TestBusinessHelper.createApprovalPorcess('Qualification Gate EDI/API', qualification, 'EDIAPI', 5, 0, true, false);
            processIntegrationQualification.Id = null;
            approvalProcessToInsert.add(processIntegrationQualification);
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
            insert approvalProcessToInsert;
            
            //Approval Matrix data
            List<Approval_Process_Escalation_Matrix__c> proceMatrixToInsert = new List<Approval_Process_Escalation_Matrix__c>();
            Approval_Process_Escalation_Matrix__c processProdcutsPreWin = TestBusinessHelper.createApprovalPorcessMatrix(processProductsPreWin, indCountry, 'IBS' , 'India, Middle East, and Africa', '4PL,MC1,MC2,MC3,MC4,MC5,MC6,MC7,MC8,MC9,AL,CS,LM', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processProdcutsPreWin.Id = null;
            proceMatrixToInsert.add(processProdcutsPreWin);
            Approval_Process_Escalation_Matrix__c processMatrixKCPursuit = TestBusinessHelper.createApprovalPorcessMatrix(processKCPursuit, null, null, null, '4PL,SCM,CCL,ECM,WD,CS,GH', null, null, null, null, true, false);
            processMatrixKCPursuit.Id = null;
            proceMatrixToInsert.add(processMatrixKCPursuit);
            Approval_Process_Escalation_Matrix__c processMatrixPlatformSolution = TestBusinessHelper.createApprovalPorcessMatrix(processPlatformSolution, indCountry, 'IBS' , 'India, Middle East, and Africa', 'MC1,MC2,MC3,MC4,MC5,MC6,MC7,MC8,MC9,AL,CS,LM', salesUserFromIndia4PLApprover, salesUserFromIndia4PLEscApprover, null, 'Lifestyle', false, false);
            processMatrixPlatformSolution.Id = null;
            proceMatrixToInsert.add(processMatrixPlatformSolution);
            Approval_Process_Escalation_Matrix__c processMatrixProductsSolution = TestBusinessHelper.createApprovalPorcessMatrix(processProductsSolution, indCountry, 'IBS' , 'India, Middle East, and Africa', 'MC1,MC2,MC3,MC4,MC5,MC6,MC7,MC8,MC9,AL,CS,LM', salesUserFromIndia4PLApprover, salesUserFromIndia4PLEscApprover, null, 'Lifestyle', false, false);
            processMatrixProductsSolution.Id = null;
            proceMatrixToInsert.add(processMatrixProductsSolution);
            Approval_Process_Escalation_Matrix__c processMatrixProductPursuit = TestBusinessHelper.createApprovalPorcessMatrix(processProductsPursuit, indCountry, 'IBS' , 'India, Middle East, and Africa', '4PL,SCM,CCL,ECM,WD,CS,GH', salesUserFromIndia4PLApprover, salesUserFromIndia4PLEscApprover, null, 'Lifestyle', false, false);
            processMatrixProductPursuit.Id = null;
            proceMatrixToInsert.add(processMatrixProductPursuit);
            Approval_Process_Escalation_Matrix__c processMatrixCLQualification = TestBusinessHelper.createApprovalPorcessMatrix(processCLQualification, null, null, null, 'CL,GL', null, null, null, null, true, false);
            processMatrixCLQualification.Id = null;
            Approval_Process_Escalation_Matrix__c processMatrixProductPursuitUK = TestBusinessHelper.createApprovalPorcessMatrix(processProductsPursuit, ukCountry, 'UKI' , 'United Kingdom', 'WD', salesUserFromUK, salesUserFromUK, null, 'Lifestyle', false, false);
            processMatrixProductPursuitUK.Id = null;
            proceMatrixToInsert.add(processMatrixCLQualification);
            Approval_Process_Escalation_Matrix__c processMatrixLMSolution = TestBusinessHelper.createApprovalPorcessMatrix(processProductsSolution, indCountry, 'IBS', 'India, Middle East, and Africa', 'LM', salesUserFromIndia4PLApprover, salesUserFromIndia4PLEscApprover, null, 'Lifestyle', false, false);
            processMatrixLMSolution.Id = null;
            proceMatrixToInsert.add(processMatrixLMSolution);
            Approval_Process_Escalation_Matrix__c processMatrixProductsSolutionuK = TestBusinessHelper.createApprovalPorcessMatrix(processProductsSolution, ukCountry, 'UKI' , 'United Kingdom', 'LM', salesUserFromUK, salesUserFromUK, null, 'Lifestyle', false, false);
            processMatrixProductsSolutionuK.Id = null;
            proceMatrixToInsert.add(processMatrixProductsSolutionuK);
            Approval_Process_Escalation_Matrix__c processMatrixProdcutsPreWinUk = TestBusinessHelper.createApprovalPorcessMatrix(processProductsPreWin, ukCountry, 'UKI' , 'United Kingdom', 'LM', salesUserFromUK, salesUserFromUK, null, 'Lifestyle', false, false);
            processMatrixProdcutsPreWinUk.Id = null;
            proceMatrixToInsert.add(processMatrixProdcutsPreWinUk);
            
            Approval_Process_Escalation_Matrix__c processMatrixProdcutsQualificationInd = TestBusinessHelper.createApprovalPorcessMatrix(processProductQualification, indCountry, 'IBS' , 'India', '4PL', salesUserFromIndia4PLApprover, salesUserFromIndia4PLEscApprover, null, 'Lifestyle', false, false);
            processMatrixProdcutsQualificationInd.Id = null;
            processMatrixProdcutsQualificationInd.Step_Name__c = processProductQualification+'-4PL-(India,Lifestyle)';
            proceMatrixToInsert.add(processMatrixProdcutsQualificationInd);
            Approval_Process_Escalation_Matrix__c processMatrixPlatformQualificationInd = TestBusinessHelper.createApprovalPorcessMatrix(processPlatformQualification, indCountry, 'IBS' , 'India', '4PL', salesUserFromIndia4PLApprover, salesUserFromIndia4PLEscApprover, null, 'Lifestyle', false, false);
            processMatrixPlatformQualificationInd.Id = null;
            processMatrixPlatformQualificationInd.Step_Name__c = processPlatformQualification+'-4PL-(India,Lifestyle)';
            proceMatrixToInsert.add(processMatrixPlatformQualificationInd);
            Approval_Process_Escalation_Matrix__c processMatrixIntegrationQualificationInd = TestBusinessHelper.createApprovalPorcessMatrix(processIntegrationQualification, indCountry, 'IBS' , 'India', '4PL', salesUserFromIndia4PLApprover, salesUserFromIndia4PLEscApprover, null, 'Lifestyle', false, false);
            processMatrixIntegrationQualificationInd.Id = null;
            processMatrixIntegrationQualificationInd.Step_Name__c = processIntegrationQualification+'-4PL-(India,Lifestyle)';
            proceMatrixToInsert.add(processMatrixIntegrationQualificationInd);
            insert proceMatrixToInsert;
        }        
        Test.stopTest();
    }
    
    @isTest
    static void updateHistoryTest(){
        
        Opportunity supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                        Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, CreatedById
                                        FROM Opportunity LIMIT 1];
        Assert.isNull(supplyChainOppty.Products_for_Approval__c);
        Assert.areEqual(false, supplyChainOppty.Must_Go_To_OMEB__c);
        User salesUser4PLApprover = [SELECT Id FROM User WHERE FederationIdentifier = 'ABC1234' LIMIT 1];
        List<Approval_Process_Escalation_Matrix__c> matrixRecordsCurrentApprover4PL = OMEBUpdateApproversController.getApprovalMatrix(salesUser4PLApprover.Id, null, qualification, null, null, null, null, 'Current_owner__c', new List<String>{'4PL4'}, null);
        
        List<Approval_Process_Escalation_Matrix__c> matrixToUpdate = new List<Approval_Process_Escalation_Matrix__c>();
        for(Approval_Process_Escalation_Matrix__c matrix : matrixRecordsCurrentApprover4PL){
            matrixToUpdate.add(new Approval_Process_Escalation_Matrix__c(Id = matrix.Id, Escalation_owner__c = supplyChainOppty.CreatedById));
        }
        
        List<Approval_Process_Escalation_Matrix__c> updateRecords = OMEBUpdateApproversController.updateApprovalMatrix(matrixToUpdate, 'Current_owner__c', matrixRecordsCurrentApprover4PL);
        System.assertEquals(3, updateRecords.size());
        Integer count = OMEBUpdateApproversController.getOptyCount(matrixToUpdate, 'Current_owner__c', matrixRecordsCurrentApprover4PL);
    }
    
    @isTest
    static void updateHistoryTest2(){
        Opportunity supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                        Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, CreatedById
                                        FROM Opportunity LIMIT 1];
        Assert.isNull(supplyChainOppty.Products_for_Approval__c);
        Assert.areEqual(false, supplyChainOppty.Must_Go_To_OMEB__c);
        User salesUser4PLEscApprover = [SELECT Id FROM User WHERE FederationIdentifier = 'ABCESC1234' LIMIT 1];
        List<Approval_Process_Escalation_Matrix__c> matrixRecordsCurrentApprover4PL = OMEBUpdateApproversController.getApprovalMatrix(salesUser4PLEscApprover.Id, null, qualification, null, null, null, null, 'Escalation_owner__c', new List<String>{'4PL4'}, null);
        
        List<Approval_Process_Escalation_Matrix__c> matrixToUpdate = new List<Approval_Process_Escalation_Matrix__c>();
        for(Approval_Process_Escalation_Matrix__c matrix : matrixRecordsCurrentApprover4PL){
            matrixToUpdate.add(new Approval_Process_Escalation_Matrix__c(Id = matrix.Id, Escalation_owner__c = supplyChainOppty.CreatedById));
        }
        
        List<Approval_Process_Escalation_Matrix__c> updateRecords = OMEBUpdateApproversController.updateApprovalMatrix(matrixToUpdate, 'Escalation_owner__c', matrixRecordsCurrentApprover4PL);
        System.assertEquals(3, updateRecords.size());
        Integer count = OMEBUpdateApproversController.getOptyCount(matrixToUpdate, 'Escalation_owner__c', matrixRecordsCurrentApprover4PL);
    }
    
    @isTest
    static void testGetApprovalMatrix(){
        Opportunity supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, CreatedById
                                       FROM Opportunity LIMIT 1];
        Assert.isNull(supplyChainOppty.Products_for_Approval__c);
        Assert.areEqual(false, supplyChainOppty.Must_Go_To_OMEB__c);
        
        User salesUser4PLApprover = [SELECT Id FROM User WHERE FederationIdentifier = 'ABC1234' LIMIT 1];
        User salesUser4PLEscApprover = [SELECT Id FROM User WHERE FederationIdentifier = 'ABCESC1234' LIMIT 1];
        
        Map<String, Geography__c> countyGeographyMap = new Map<String, Geography__c>();
        for(Geography__c country : [SELECT Id, Name FROM Geography__c Where Type_Of_Location__c = 'Country' AND Active__c = true]){
            countyGeographyMap.put(country.Name, country);
        }
        
        Test.startTest();
        List<Approval_Process_Escalation_Matrix__c> matrixRecordsCurrentApprover = OMEBUpdateApproversController.getApprovalMatrix(salesUser4PLApprover.Id, countyGeographyMap.get('India').Id, qualification, 'Product', 'Lifestyle', 'IBS', '', 'Current_owner__c', null, null);
        List<Approval_Process_Escalation_Matrix__c> matrixRecordsCurrentApproverNV = OMEBUpdateApproversController.getApprovalMatrix(salesUser4PLApprover.Id, countyGeographyMap.get('India').Id, qualification, 'Product', 'NV', 'IBS', '', 'Current_owner__c', null, null);
        List<Approval_Process_Escalation_Matrix__c> matrixRecordsCurrentApprover4PL = OMEBUpdateApproversController.getApprovalMatrix(salesUser4PLApprover.Id, null, qualification, null, null, null, null, 'Current_owner__c', new List<String>{'4PL4'}, null);
        List<Approval_Process_Escalation_Matrix__c> matrixRecordsEscalationApprover = OMEBUpdateApproversController.getApprovalMatrix(salesUser4PLEscApprover.Id, countyGeographyMap.get('India').Id, qualification, 'Platform', 'Lifestyle', 'IBS', '', 'Escalation_owner__c', null, null);
        
        List<Approval_Process_Escalation_Matrix__c> matrixToUpdate = new List<Approval_Process_Escalation_Matrix__c>();
        for(Approval_Process_Escalation_Matrix__c matrix : matrixRecordsCurrentApprover4PL){
            matrixToUpdate.add(new Approval_Process_Escalation_Matrix__c(Id = matrix.Id, Current_owner__c = supplyChainOppty.CreatedById));
        }
        OMEBUpdateApproversController.saveRecords(JSON.serialize(matrixToUpdate), 'Current_owner__c');
        Test.stopTest();
        Assert.areEqual(1, matrixRecordsCurrentApprover.size());
        Assert.areEqual(1, matrixRecordsEscalationApprover.size());
        Assert.areEqual(0, matrixRecordsCurrentApproverNV.size());
        Assert.areEqual(3, matrixRecordsCurrentApprover4PL.size());
    }
    
    @isTest
    static void test4PLproductSubmitForApproval(){
        Opportunity supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, CreatedById
                                       FROM Opportunity LIMIT 1];
        Assert.isNull(supplyChainOppty.Products_for_Approval__c);
        Assert.areEqual(false, supplyChainOppty.Must_Go_To_OMEB__c);
        
        Map<String, Geography__c> countyGeographyMap = new Map<String, Geography__c>();
        for(Geography__c country : [SELECT Id, Name FROM Geography__c Where Type_Of_Location__c = 'Country' AND Active__c = true]){
            countyGeographyMap.put(country.Name, country);
        }
        
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Product2 ocfProduct = [SELECT Id FROM Product2 where OIPC_Code__c = 'P-P0-1ste' AND IsActive = true LIMIT 1];
        List<Approval_History__c> historyList = new List<Approval_History__c>();
        Boolean isSuccess;
        Test.startTest();
        Opportunity_Product__c customOliOCFProduct = TestBusinessHelper.createOpportunityLineItemCustom(supplyChainOppty, ocfProduct.Id, tradeRoute, false);
        customOliOCFProduct.Id = null;
        customOliOCFProduct.Country__c = countyGeographyMap.get('India').Id;
        customOliOCFProduct.Destination_Country__c = countyGeographyMap.get('United States').Id;
        customOliOCFProduct.Quantity__c = 100;
        insert customOliOCFProduct;
        
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                            Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, createdById, Opportunity_Owner_Country__c, Type
                            FROM Opportunity LIMIT 1];
        
        //Create parameter
        Map<String, Object> Params = new Map<String, Object>();
        Params.put('Opportunity', supplyChainOppty);
        
        System.runAs(new User(Id = supplyChainOppty.createdById)){
            //create instance of Interview
            Flow.Interview.Opportunity_Pursuit_Gate_Approval_Process callPursuit = new Flow.Interview.Opportunity_Pursuit_Gate_Approval_Process(Params);
            //Invoke start method
            callPursuit.start();
        }
        
        historyList = [SELECT Id from Approval_History__c where TargetObjectId__c =:supplyChainOppty.Id AND Status__c = 'Pending'];
        Assert.areEqual(1, historyList.size());
        
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, CreatedById
                                       FROM Opportunity LIMIT 1];
        Assert.isNotNull(supplyChainOppty.Products_for_Approval__c);
        Assert.areEqual('4PL4', supplyChainOppty.Products_for_Approval__c);
        Assert.areEqual(true, supplyChainOppty.Must_Go_To_OMEB__c);
        Assert.areEqual('Submitted - Qualification Gate', supplyChainOppty.Approval_Status__c);
        
        historyList = [SELECT Id, Assigned_To__c from Approval_History__c where TargetObjectId__c =:supplyChainOppty.Id AND Status__c = 'Pending'];
        Assert.areEqual(1, historyList.size());
        
        System.runAs(new User(Id = historyList[0].Assigned_To__c)){
            isSuccess = ApprovalHistoryController.approveRecord(historyList[0].Id, 'Approving from test class', '');
        }
        Assert.areEqual(isSuccess, true);
        
        historyList = [SELECT Id, Assigned_To__c from Approval_History__c where TargetObjectId__c =:supplyChainOppty.Id AND Status__c = 'Pending'];
        Assert.areEqual(0, historyList.size());
        
        Test.stopTest();
        
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                            Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, createdById, Opportunity_Owner_Country__c, Type
                            FROM Opportunity LIMIT 1];
        
        Assert.areEqual('Approved - Qualification Gate', supplyChainOppty.Approval_Status__c);
        Assert.areEqual(Label.Designing_Proposal, supplyChainOppty.StageName);
        
    }
    
    @isTest
    static void test4PLproductSubmitForApprovalRejection(){
        Opportunity supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, CreatedById
                                       FROM Opportunity LIMIT 1];
        Assert.isNull(supplyChainOppty.Products_for_Approval__c);
        Assert.areEqual(false, supplyChainOppty.Must_Go_To_OMEB__c);
        
        Map<String, Geography__c> countyGeographyMap = new Map<String, Geography__c>();
        for(Geography__c country : [SELECT Id, Name FROM Geography__c Where Type_Of_Location__c = 'Country' AND Active__c = true]){
            countyGeographyMap.put(country.Name, country);
        }
        
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Product2 ocfProduct = [SELECT Id FROM Product2 where OIPC_Code__c = 'P-P0-1ste' AND IsActive = true LIMIT 1];
        List<Approval_History__c> historyList = new List<Approval_History__c>();
        Boolean isSuccess;
        
        Test.startTest();
        Opportunity_Product__c customOliOCFProduct = TestBusinessHelper.createOpportunityLineItemCustom(supplyChainOppty, ocfProduct.Id, tradeRoute, false);
        customOliOCFProduct.Id = null;
        customOliOCFProduct.Country__c = countyGeographyMap.get('India').Id;
        customOliOCFProduct.Destination_Country__c = countyGeographyMap.get('United States').Id;
        customOliOCFProduct.Quantity__c = 100;
        insert customOliOCFProduct;
        
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                            Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, createdById, Opportunity_Owner_Country__c, Type
                            FROM Opportunity LIMIT 1];
        
        //Create parameter
        Map<String, Object> Params = new Map<String, Object>();
        Params.put('Opportunity', supplyChainOppty);
        
        System.runAs(new User(Id = supplyChainOppty.createdById)){
            //create instance of Interview
            Flow.Interview.Opportunity_Pursuit_Gate_Approval_Process callPursuit = new Flow.Interview.Opportunity_Pursuit_Gate_Approval_Process(Params);
            //Invoke start method
            callPursuit.start();
        }
        
        historyList = [SELECT Id from Approval_History__c where TargetObjectId__c =:supplyChainOppty.Id AND Status__c = 'Pending'];
        Assert.areEqual(1, historyList.size());
        
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, CreatedById
                                       FROM Opportunity LIMIT 1];
        Assert.isNotNull(supplyChainOppty.Products_for_Approval__c);
        Assert.areEqual('4PL4', supplyChainOppty.Products_for_Approval__c);
        Assert.areEqual(true, supplyChainOppty.Must_Go_To_OMEB__c);
        Assert.areEqual('Submitted - Qualification Gate', supplyChainOppty.Approval_Status__c);
        
        historyList = [SELECT Id, Assigned_To__c from Approval_History__c where TargetObjectId__c =:supplyChainOppty.Id AND Status__c = 'Pending'];
        Assert.areEqual(1, historyList.size());
        
        System.runAs(new User(Id = historyList[0].Assigned_To__c)){
            isSuccess = ApprovalHistoryController.rejectRecord(historyList[0].Id, 'Approving from test class', '', 'Business Rejection-Not aligned Area Business Plan');
        }
        
        Test.stopTest();
        
        Assert.areEqual(isSuccess, true);
        
        historyList = [SELECT Id, Assigned_To__c from Approval_History__c where TargetObjectId__c =:supplyChainOppty.Id AND Status__c = 'Pending'];
        Assert.areEqual(0, historyList.size());
        
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                            Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, createdById, Opportunity_Owner_Country__c, Type
                            FROM Opportunity LIMIT 1];
        
        Assert.areEqual('Rejected - Qualification Gate - Do Not Pursue', supplyChainOppty.Approval_Status__c);
        Assert.areEqual(Label.Identifying, supplyChainOppty.StageName);
        
    }
    
    @isTest
    static void test4PLproductSubmitForApprovalMassApproverUpdate(){
        Opportunity supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, CreatedById
                                       FROM Opportunity LIMIT 1];
        Assert.isNull(supplyChainOppty.Products_for_Approval__c);
        Assert.areEqual(false, supplyChainOppty.Must_Go_To_OMEB__c);
        
        Map<String, Geography__c> countyGeographyMap = new Map<String, Geography__c>();
        for(Geography__c country : [SELECT Id, Name FROM Geography__c Where Type_Of_Location__c = 'Country' AND Active__c = true]){
            countyGeographyMap.put(country.Name, country);
        }
        User salesUser4PLApprover = [SELECT Id FROM User WHERE FederationIdentifier = 'ABC1234' LIMIT 1];
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Product2 ocfProduct = [SELECT Id FROM Product2 where OIPC_Code__c = 'P-P0-1ste' AND IsActive = true LIMIT 1];
        List<Approval_History__c> historyList = new List<Approval_History__c>();
        String saveRecordsResult;
        Test.startTest();
        Opportunity_Product__c customOliOCFProduct = TestBusinessHelper.createOpportunityLineItemCustom(supplyChainOppty, ocfProduct.Id, tradeRoute, false);
        customOliOCFProduct.Id = null;
        customOliOCFProduct.Country__c = countyGeographyMap.get('India').Id;
        customOliOCFProduct.Destination_Country__c = countyGeographyMap.get('United States').Id;
        customOliOCFProduct.Quantity__c = 100;
        insert customOliOCFProduct;
        
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                            Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, createdById, Opportunity_Owner_Country__c, Type
                            FROM Opportunity LIMIT 1];
        
        //Create parameter
        Map<String, Object> Params = new Map<String, Object>();
        Params.put('Opportunity', supplyChainOppty);
        System.runAs(new User(Id = supplyChainOppty.createdById)){
            //create instance of Interview
            Flow.Interview.Opportunity_Pursuit_Gate_Approval_Process callPursuit = new Flow.Interview.Opportunity_Pursuit_Gate_Approval_Process(Params);
            //Invoke start method
            callPursuit.start();
        }
        historyList = [SELECT Id from Approval_History__c where TargetObjectId__c =:supplyChainOppty.Id AND Status__c = 'Pending'];
        Assert.areEqual(1, historyList.size());
        
        List<Approval_Process_Escalation_Matrix__c> matrixRecordsCurrentApprover4PL = OMEBUpdateApproversController.getApprovalMatrix(salesUser4PLApprover.Id, null, qualification, null, null, null, null, 'Current_owner__c', new List<String>{'4PL4'}, null);
        
        List<Approval_Process_Escalation_Matrix__c> matrixToUpdate = new List<Approval_Process_Escalation_Matrix__c>();
        for(Approval_Process_Escalation_Matrix__c matrix : matrixRecordsCurrentApprover4PL){
            matrixToUpdate.add(new Approval_Process_Escalation_Matrix__c(Id = matrix.Id, Current_owner__c = supplyChainOppty.CreatedById));
        }
        saveRecordsResult = OMEBUpdateApproversController.saveRecords(JSON.serialize(matrixToUpdate), 'Current_owner__c');
        
        Test.stopTest();
        
        Assert.areEqual('success',saveRecordsResult);
        
    }
    
    @isTest
    static void test4PLproductSubmitForApprovalMassEscalationApproverUpdate(){
        Opportunity supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, CreatedById
                                       FROM Opportunity LIMIT 1];
        Assert.isNull(supplyChainOppty.Products_for_Approval__c);
        Assert.areEqual(false, supplyChainOppty.Must_Go_To_OMEB__c);
        
        Map<String, Geography__c> countyGeographyMap = new Map<String, Geography__c>();
        for(Geography__c country : [SELECT Id, Name FROM Geography__c Where Type_Of_Location__c = 'Country' AND Active__c = true]){
            countyGeographyMap.put(country.Name, country);
        }
        User salesUser4PLApprover = [SELECT Id FROM User WHERE FederationIdentifier = 'ABC1234' LIMIT 1];
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Product2 ocfProduct = [SELECT Id FROM Product2 where OIPC_Code__c = 'P-P0-1ste' AND IsActive = true LIMIT 1];
        List<Approval_History__c> historyList = new List<Approval_History__c>();
        String saveRecordsResult;
        Test.startTest();
        Opportunity_Product__c customOliOCFProduct = TestBusinessHelper.createOpportunityLineItemCustom(supplyChainOppty, ocfProduct.Id, tradeRoute, false);
        customOliOCFProduct.Id = null;
        customOliOCFProduct.Country__c = countyGeographyMap.get('India').Id;
        customOliOCFProduct.Destination_Country__c = countyGeographyMap.get('United States').Id;
        customOliOCFProduct.Quantity__c = 100;
        insert customOliOCFProduct;
        
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                            Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, createdById, Opportunity_Owner_Country__c, Type
                            FROM Opportunity LIMIT 1];
        
        //Create parameter
        Map<String, Object> Params = new Map<String, Object>();
        Params.put('Opportunity', supplyChainOppty);
        System.runAs(new User(Id = supplyChainOppty.createdById)){
            //create instance of Interview
            Flow.Interview.Opportunity_Pursuit_Gate_Approval_Process callPursuit = new Flow.Interview.Opportunity_Pursuit_Gate_Approval_Process(Params);
            //Invoke start method
            callPursuit.start();
        }
        
        historyList = [SELECT Id, Approval_Step__r.Approval_Process_Name__r.SLA__c from Approval_History__c where TargetObjectId__c =:supplyChainOppty.Id AND Status__c = 'Pending'];
        Assert.areEqual(1, historyList.size());
        
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                            Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, createdById, Opportunity_Owner_Country__c, Type
                            FROM Opportunity LIMIT 1];
        
        new ApprovalProcessEscalationHandler().escalate(new List<Opportunity>{supplyChainOppty});
        
        historyList = [SELECT Id from Approval_History__c where TargetObjectId__c =:supplyChainOppty.Id AND Status__c = 'Pending'];
        Assert.areEqual(2, historyList.size());
        
        List<Approval_Process_Escalation_Matrix__c> matrixRecordsCurrentApprover4PL = OMEBUpdateApproversController.getApprovalMatrix(salesUser4PLApprover.Id, null, qualification, null, null, null, null, 'Current_owner__c', new List<String>{'4PL4'}, null);
        
        List<Approval_Process_Escalation_Matrix__c> matrixToUpdate = new List<Approval_Process_Escalation_Matrix__c>();
        for(Approval_Process_Escalation_Matrix__c matrix : matrixRecordsCurrentApprover4PL){
            matrixToUpdate.add(new Approval_Process_Escalation_Matrix__c(Id = matrix.Id, Escalation_owner__c = supplyChainOppty.CreatedById));
        }
        saveRecordsResult = OMEBUpdateApproversController.saveRecords(JSON.serialize(matrixToUpdate), 'Escalation_owner__c');
        
        Test.stopTest();
        
        Assert.areEqual('success',saveRecordsResult);
        
    }
    
    @isTest
    static void testOMEBMassApproverApp(){
        
        Opportunity supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, CreatedById
                                       FROM Opportunity LIMIT 1];
        Assert.isNull(supplyChainOppty.Products_for_Approval__c);
        Assert.areEqual(false, supplyChainOppty.Must_Go_To_OMEB__c);
        
        Map<String, Geography__c> countyGeographyMap = new Map<String, Geography__c>();
        for(Geography__c country : [SELECT Id, Name FROM Geography__c Where Type_Of_Location__c = 'Country' AND Active__c = true]){
            countyGeographyMap.put(country.Name, country);
        }
        User salesUser4PLApprover = [SELECT Id FROM User WHERE FederationIdentifier = 'ABC1234' LIMIT 1];
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        Product2 ocfProduct = [SELECT Id FROM Product2 where OIPC_Code__c = 'P-P0-1ste' AND IsActive = true LIMIT 1];
        List<Approval_History__c> historyList = new List<Approval_History__c>();
        OMEBUpdateApproversController.PendingRecordsCountWrapper pendingApprovalHistoriesCount;
        OMEBUpdateApproversController.PendingRecordsCountWrapper pendingEscalationApprovalHistoriesCount;
        Test.startTest();
        
        Opportunity_Product__c customOliOCFProduct = TestBusinessHelper.createOpportunityLineItemCustom(supplyChainOppty, ocfProduct.Id, tradeRoute, false);
        customOliOCFProduct.Id = null;
        customOliOCFProduct.Country__c = countyGeographyMap.get('India').Id;
        customOliOCFProduct.Destination_Country__c = countyGeographyMap.get('United States').Id;
        customOliOCFProduct.Quantity__c = 100;
        insert customOliOCFProduct;
        
        supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                            Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, createdById, Opportunity_Owner_Country__c, Type
                            FROM Opportunity LIMIT 1];
        
        Assert.isNotNull(supplyChainOppty.Products_for_Approval__c);
        Assert.areEqual('4PL4', supplyChainOppty.Products_for_Approval__c);
        Assert.areEqual(true, supplyChainOppty.Must_Go_To_OMEB__c);
        
        System.runAs(new User(Id = supplyChainOppty.createdById)){
            
            //Create parameter
            Map<String, Object> Params = new Map<String, Object>();
            Params.put('Opportunity', supplyChainOppty);
            //create instance of Interview
            Flow.Interview.Opportunity_Pursuit_Gate_Approval_Process callPursuit = new Flow.Interview.Opportunity_Pursuit_Gate_Approval_Process(Params);
            //Invoke start method
            callPursuit.start();
            
            supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                            Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, createdById, Opportunity_Owner_Country__c, Type
                            FROM Opportunity LIMIT 1];
            
            historyList = [SELECT Id, Approval_Step__c from Approval_History__c where TargetObjectId__c =:supplyChainOppty.Id AND Status__c = 'Pending'];
            Assert.areEqual(1, historyList.size());
            
            
            List<Approval_Process_Escalation_Matrix__c> matrixToUpdate = new List<Approval_Process_Escalation_Matrix__c>();
            for(Approval_History__c history : historyList){
                matrixToUpdate.add(new Approval_Process_Escalation_Matrix__c(Id = history.Approval_Step__c, Current_owner__c = supplyChainOppty.CreatedById));
            }
            
            OMEBUpdateApproversController.getGeographyCountries();
            OMEBUpdateApproversController.getTradeRegions();
            pendingApprovalHistoriesCount = OMEBUpdateApproversController.getReassignedHistoryCount(JSON.serialize(matrixToUpdate), 'Current_owner__c');
            //pendingEscalationApprovalHistoriesCount = OMEBUpdateApproversController.getReassignedHistoryCount(supplyChainOppty.Id, 'Escalation_owner__c');
            OMEBUpdateApproversController.getProductNames();
            OMEBUpdateApproversController.getTradeRegions();
        }
        Test.stopTest();
        
        Assert.areEqual(1, pendingApprovalHistoriesCount.opportunitiesCount);
        
    }

}