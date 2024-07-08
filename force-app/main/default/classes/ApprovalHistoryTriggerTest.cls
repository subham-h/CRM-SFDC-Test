@isTest
public class ApprovalHistoryTriggerTest {
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
        Geography__c ukState = TestBusinessHelper.createGeography('London', 'State', ukCountry.Id, true);
        Geography__c state = TestBusinessHelper.createGeography('Karnataka', 'State', country.Id, true);
        
        BDA__c parentBDA = TestBusinessHelper.createBDA('India, Middle East, and Africa', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true);
        BDA__c childBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'IBS', parentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, country.Id, null, true);
        
        BDA__c ukParentBDA = TestBusinessHelper.createBDA('United Kingdom', 'Other', 'EMEA', null, UserInfo.getUserId(), true);
        BDA__c ukChildBDA = TestBusinessHelper.createBDA('United Kingdom and Ireland Area', 'Cluster', 'UKI', ukParentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c ukBdaGeo = TestBusinessHelper.createBDAGeography(ukChildBDA.Id, ukCountry.Id, null, true);
        
        List<user> usersToInsert = new List<user>();
        User salesUser = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
        salesUser.Id = null;
        salesUser.IsActive=true;
        salesUser.country = 'India';
        salesUser.CM_Visibility__c = 'Single Carrier';
        usersToInsert.add(salesUser);
        
        User adminUser = TestBusinessHelper.createUser('System Administrator', BrandUtilities.MAERSKLINE, false);
        adminUser.Id = null;
        adminUser.IsActive=true;
        adminUser.country = 'India';
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
            opportunity.StageName = 'Identifying';
        	opportunity.Must_Go_To_OMEB__c = true;
        	opportunity.Approval_Status__c = '';
            insert opportunity;
        }
        List<Product2> productsToInsert = new List<Product2>();
        
        List<Products_For_Approval__mdt> productsForApprovalList = Products_For_Approval__mdt.getAll().values();
        
        Product2 product;
        for(Products_For_Approval__mdt prodForApprovalMD : Products_For_Approval__mdt.getAll().values()){
            if(prodForApprovalMD.Active__c){
            if(prodForApprovalMD.Family_Code__c != 'cold_chain_logistics' && prodForApprovalMD.OIPC_Code__c != null){
                product = TestBusinessHelper.createProduct(prodForApprovalMD.Product_Family__c, false);
                product.Id = null;
                product.Name = prodForApprovalMD.Product_Name__c;
                product.Family_Code__c = prodForApprovalMD.Family_Code__c;
                product.OIPC_Code__c = prodForApprovalMD.OIPC_Code__c;
                product.Include_in_OMEB_Approvals__c = true;
                productsToInsert.add(product);
            }
            }
        }
        
        Product2 productColdStorage = TestBusinessHelper.createProduct('Cold Chain Logistics', false);
        productColdStorage.Id = null;
        productColdStorage.Family_Code__c = 'cold_chain_logistics';
        productColdStorage.OIPC_Code__c = 'P-P0-144i';
        productColdStorage.Include_in_OMEB_Approvals__c = true;
        productsToInsert.add(productColdStorage);
        
        System.runAs(adminUser){
            insert productsToInsert;
            
            List<Approval_Process__c> approvalProcessToInsert = new List<Approval_Process__c>();
            Approval_Process__c processPlatformQualification = TestBusinessHelper.createApprovalPorcess('Qualification Gate Platform', qualification, 'Platform', 7, null, true, false);
            processPlatformQualification.Id = null;
            approvalProcessToInsert.add(processPlatformQualification);
            Approval_Process__c processProductsQualification = TestBusinessHelper.createApprovalPorcess('Qualification Gate Products', qualification, 'Product', 12, null, true, false);
            processProductsQualification.Id = null;
            approvalProcessToInsert.add(processProductsQualification);
            
            insert approvalProcessToInsert;
            
            List<Approval_Process_Escalation_Matrix__c> processMatrixToInsert = new List<Approval_Process_Escalation_Matrix__c>();
            Approval_Process_Escalation_Matrix__c processMatrixProductsLLQualification = TestBusinessHelper.createApprovalPorcessMatrix(processProductsQualification, country, 'IBS' , 'India, Middle East, and Africa', '4PL,SCM,CCL', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processMatrixProductsLLQualification.Id = null;
            processMatrixProductsLLQualification.Step_Name__c = 'Qualification Products-LL-(India,Lifestyle)';
            processMatrixToInsert.add(processMatrixProductsLLQualification);
            Approval_Process_Escalation_Matrix__c processMatrixProductsWDQualification = TestBusinessHelper.createApprovalPorcessMatrix(processProductsQualification, country, 'IBS' , 'India, Middle East, and Africa', 'WD,GH', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processMatrixProductsWDQualification.Id = null;
            processMatrixProductsWDQualification.Step_Name__c = 'Qualification Products-CL-(India,Lifestyle)';
            processMatrixToInsert.add(processMatrixProductsWDQualification);
            Approval_Process_Escalation_Matrix__c processMatrixPlatformLLQualification = TestBusinessHelper.createApprovalPorcessMatrix(processPlatformQualification, country, 'IBS' , 'India, Middle East, and Africa', '4PL,SCM,CCL', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processMatrixPlatformLLQualification.Id = null;
            processMatrixPlatformLLQualification.Step_Name__c = 'Qualification Platform-LL-(India,Lifestyle)';
            processMatrixToInsert.add(processMatrixPlatformLLQualification);
            Approval_Process_Escalation_Matrix__c processMatrixPlatformWDQualification = TestBusinessHelper.createApprovalPorcessMatrix(processPlatformQualification, country, 'IBS' , 'India, Middle East, and Africa', 'WD,GH', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processMatrixPlatformWDQualification.Id = null;
            processMatrixPlatformWDQualification.Step_Name__c = 'Qualification Platform-CL-(India,Lifestyle)';
            processMatrixToInsert.add(processMatrixPlatformWDQualification);
            insert processMatrixToInsert;
        }
        TriggerExecutionController.skipAllTriggers(false);
        
        Test.stopTest();
    }
	@isTest
    public static void beforeInsertTest(){
        Opportunity supplyChainOppty = [SELECT ID, Name, StageName, Products_for_Approval__c, Approval_Required__c, Must_Go_To_OMEB__c, Approval_Status__c, RecordType.DeveloperName,
                                       Account.Attractiveness__c, Liner_Brand__c, Requires_IT_Integration__c, Owner_Area_Code__c, CreatedById
                                       FROM Opportunity LIMIT 1];
        supplyChainOppty.StageName = 'Qualifying';
        supplyChainOppty.Approval_Status__c = 'Approved - Pursuit Gate';
        Update supplyChainOppty;
        Approval_Process_Escalation_Matrix__c ape = [Select id,Step_Name__c from Approval_Process_Escalation_Matrix__c where Step_Name__c = 'Qualification Products-LL-(India,Lifestyle)' limit 1];
        Approval_Process_Escalation_Matrix__c ape1 = [Select id,Step_Name__c from Approval_Process_Escalation_Matrix__c where Step_Name__c = 'Qualification Platform-LL-(India,Lifestyle)' limit 1];
        Approval_Process_Escalation_Matrix__c ape2 = [Select id,Step_Name__c from Approval_Process_Escalation_Matrix__c where Step_Name__c = 'Qualification Products-CL-(India,Lifestyle)' limit 1];
        Approval_Process_Escalation_Matrix__c ape3 = [Select id,Step_Name__c from Approval_Process_Escalation_Matrix__c where Step_Name__c = 'Qualification Platform-CL-(India,Lifestyle)' limit 1];
        Geography__c countryIndia = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' and name = 'India'];
        Geography__c stateKA = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'State' and name = 'Karnataka'];
        Trade_Route__c tradeRoute = [SELECT Id,createdById  FROM Trade_Route__c LIMIT 1];
        salesUserId = supplyChainOppty.createdById;
        adminUserId = tradeRoute.createdById;
        Set<Id> productIds = new Set<Id>();
        for(Product2 prod : [SELECT Id, Name FROM Product2 WHERE (OIPC_Code__c IN ('P-P0-wet','P-P0-dw9','P-P0-2bc4') or Name = 'Supply Chain Orchestrator')]){
            productIds.add(prod.Id);
        }
        List<Opportunity_Product__c> optyList = TestBusinessHelper.createOpportunityLineItemCustoms(supplyChainOppty, productIds, tradeRoute, countryIndia, stateKA, true);
        Opportunity_Product__c optyProduct = [Select id from Opportunity_Product__c limit 1];
        system.debug('oppty product for approval @@@'+supplyChainOppty.Products_for_Approval__c);
         system.debug('oppty product@@@'+optyProduct);
        Test.StartTest();
        List<Approval_History__c> aphList = New List<Approval_History__c>();
        Approval_History__c ahOne = New Approval_History__c();
        ahOne.Step_Name__c  = 'Qualification Products-LL-(India,Lifestyle)';
        ahOne.Approval_Step__c  = ape.Id;
        ahOne.Status__c = 'Pending';
        ahOne.Submission_Order__c = 1;
        ahOne.TargetObjectId__c = supplyChainOppty.Id;
        ahOne.Approved_By__c = salesUserId;
        ahOne.Assigned_To__c = salesUserId;
        aphList.add(ahOne);
        
        Approval_History__c ahTwo = New Approval_History__c();
        ahTwo.Step_Name__c  = 'Qualification Products-CL-(India,Lifestyle)';
        ahTwo.Approval_Step__c  = ape2.Id;
        ahTwo.Status__c = 'Pending';
        ahTwo.Submission_Order__c = 1;
        ahTwo.TargetObjectId__c = supplyChainOppty.Id;
        ahTwo.Approved_By__c = salesUserId;
        ahTwo.Assigned_To__c = salesUserId;
        aphList.add(ahTwo);
        
        Approval_History__c ah1 = New Approval_History__c();
        ah1.Step_Name__c  = 'Qualification Products-CL-(India,Lifestyle)';
        ah1.Approval_Step__c  = ape2.Id;
        ah1.Status__c = 'Pending';
        ah1.Submission_Order__c = 1;
        ah1.TargetObjectId__c = supplyChainOppty.Id;
        ah1.Approved_By__c = adminUserId;
        ah1.Assigned_To__c = adminUserId;
        aphList.add(ah1);
        
        insert aphList;
        Approval_History__c aph = [select id,Status__c from Approval_History__c where TargetObjectId__c =: supplyChainOppty.Id limit 1];
        aph.Status__c = 'Reassigned';
        update aph;
        
        List<Approval_History__c> aphList2 = New List<Approval_History__c>();
        Approval_History__c ahThree = New Approval_History__c();
        ahThree.Step_Name__c  = 'Qualification Platform-LL-(United Kingdom, Lifestyle)';
        ahThree.Approval_Step__c  = ape1.Id;
        ahThree.Status__c = 'Pending';
        ahThree.Opportunity_Product__c = (String)optyProduct.Id;
        ahThree.TargetObjectId__c = supplyChainOppty.Id;
        ahThree.Approved_By__c = salesUserId;
        ahThree.Assigned_To__c = salesUserId;
        aphList2.add(ahThree);
        
        Approval_History__c ahEscalated = New Approval_History__c();
        ahEscalated.Step_Name__c  = 'Qualification Products-LL-(India,Lifestyle)';
        ahEscalated.Approval_Step__c  = ape1.Id;
        ahEscalated.Status__c = 'Pending';
        ahEscalated.Opportunity_Product__c = (String)optyProduct.Id;
        ahEscalated.TargetObjectId__c = supplyChainOppty.Id;
        ahEscalated.Approved_By__c = salesUserId;
        ahEscalated.Assigned_To__c = salesUserId;
        ahEscalated.Type__c = 'Escalation';
        aphList2.add(ahEscalated);
        insert aphList2;
        Test.StopTest();
    }
}