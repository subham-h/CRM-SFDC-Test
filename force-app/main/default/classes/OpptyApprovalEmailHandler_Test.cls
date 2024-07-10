@isTest
public class OpptyApprovalEmailHandler_Test {
    
    private static final String pursuit = System.Label.Pursuit_Gate;
    private static final String qualification = System.Label.Feasibility_Gate;
    private static final String solution = System.Label.Solution_Gate;
    private static final String prewin = System.Label.Pre_Win_Gate;
    private static Id salesUserId;
    private static Id adminUserId;
    
    @testSetup
    static void setup() {
        Trade_Route__c tradeRoute;
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null,'IN', true);
        Geography__c ukCountry = TestBusinessHelper.createGeography('United Kingdom', 'Country', null,'UK', true);
        Geography__c ukState = TestBusinessHelper.createGeography('London', 'State', ukCountry.Id, true);
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
        DelegatedUser.Email = 'Delegatedapprovermaerskline@maersk.com';
        usersToInsert.add(DelegatedUser);
        User salesUser = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
        salesUser.Id = null;
        salesUser.IsActive=true;
        salesUser.country = 'India';
        salesUser.CM_Visibility__c = 'Single Carrier';
        salesUser.DelegatedApproverId = DelegatedUser.Id;
        usersToInsert.add(salesUser);
        
        User adminUser = TestBusinessHelper.createUser('System Administrator', BrandUtilities.MAERSKLINE, false);
        adminUser.Id = null;
        adminUser.IsActive=true;
        adminUser.country = 'India';
        usersToInsert.add(adminUser);
        System.runAs(new User(Id = UserInfo.getUserId())){
             TriggerExecutionController.skipAllTriggers(true);
            insert usersToInsert;
             TriggerExecutionController.skipAllTriggers(false);
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
            opportunity.Approval_Status__c = 'Submitted - Qualification Gate';
            opportunity.StageName = 'Identifying';
            insert opportunity;
        }
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
        productColdStorage.Include_in_OMEB_Approvals__c = true;
        productsToInsert.add(productColdStorage);
        
        Product2 productContractLogistics = TestBusinessHelper.createProduct('Contract Logistics', false);
        productContractLogistics.Id = null;
        productContractLogistics.Family_Code__c = 'contract_logistics';
        productContractLogistics.OIPC_Code__c = 'P-P0-dwb';
        productContractLogistics.Include_in_OMEB_Approvals__c = true;
        productsToInsert.add(productContractLogistics);
        System.runAs(adminUser){
            insert productsToInsert;
            
            List<Approval_Process__c> approvalProcessToInsert = new List<Approval_Process__c>();
            Approval_Process__c processPlatformQualification = TestBusinessHelper.createApprovalPorcess('Qualification Gate Platform', qualification, 'Platform', 4, null, true, false);
            processPlatformQualification.Id = null;
            approvalProcessToInsert.add(processPlatformQualification);
            Approval_Process__c processProductsQualification = TestBusinessHelper.createApprovalPorcess('Qualification Gate Products', qualification, 'Product', 7, null, true, false);
            processProductsQualification.Id = null;
            approvalProcessToInsert.add(processProductsQualification);
            Approval_Process__c processCLQualification = TestBusinessHelper.createApprovalPorcess('Qualification Gate Auto Approval', qualification, 'Product', 12, null, true, false);
            processCLQualification.Id = null;
            approvalProcessToInsert.add(processCLQualification);
            
            insert approvalProcessToInsert;
            
            List<Approval_Process_Escalation_Matrix__c> proceMatrixToInsert = new List<Approval_Process_Escalation_Matrix__c>();
            Approval_Process_Escalation_Matrix__c processMatrixProductsQualification = TestBusinessHelper.createApprovalPorcessMatrix(processProductsQualification, country, 'IBS' , 'India, Middle East, and Africa', '4PL,SCM,CCL,ECM,WD,CS,GH', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processMatrixProductsQualification.Id = null;
            proceMatrixToInsert.add(processMatrixProductsQualification);
            Approval_Process_Escalation_Matrix__c processMatrixProductQualification = TestBusinessHelper.createApprovalPorcessMatrix(processProductsQualification, country, 'IBS' , 'India, Middle East, and Africa', '4PL,SCM,CCL,ECM,WD,CS,GH', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processMatrixProductQualification.Id = null;
            proceMatrixToInsert.add(processMatrixProductQualification);
            Approval_Process_Escalation_Matrix__c processMatrixCLQualification = TestBusinessHelper.createApprovalPorcessMatrix(processCLQualification, null, null, null, 'CL,GL', null, null, null, null, true, false);
            processMatrixCLQualification.Id = null;
            Approval_Process_Escalation_Matrix__c processMatrixProductQualificationUK = TestBusinessHelper.createApprovalPorcessMatrix(processProductsQualification, ukCountry, 'UKI' , 'United Kingdom', '4PL,SCM,CCL,ECM,WD,CS,GH', new User(Id = UserInfo.getUserId()), new User(Id = UserInfo.getUserId()), null, 'Lifestyle', false, false);
            processMatrixProductQualificationUK.Id = null;
            proceMatrixToInsert.add(processMatrixCLQualification);
            insert proceMatrixToInsert;
        }
        Approval_Process_Escalation_Matrix__c ape = [select id,Step_Name__c,key__c from Approval_Process_Escalation_Matrix__c limit 1];
        Opportunity mslOppty = [Select id from opportunity limit 1];
        List<Approval_History__c> aphList = New List<Approval_History__c>();
        Approval_History__c ahOne = New Approval_History__c();
        ahOne.Step_Name__c  = ape.Step_Name__c;
        ahOne.Approval_Step__c  = ape.Id;
        ahOne.Status__c = 'Pending';
        ahOne.TargetObjectId__c =mslOppty.id;
        ahOne.Approved_By__c = salesUserId;
        ahOne.Assigned_To__c = salesUserId;
        //ahOne.Delegated_approver__c = '';
        //ahOne.key__c = ape1;
        aphList.add(ahOne);
        system.debug(ahOne);
        
        Approval_History__c ahTwo = New Approval_History__c();
        ahTwo.Step_Name__c  = ape.Step_Name__c;
        ahTwo.Approval_Step__c  = ape.Id;
        ahTwo.Status__c = 'Pending';
        ahTwo.TargetObjectId__c =mslOppty.id;
        ahTwo.Approved_By__c = salesUserId;
        ahTwo.Assigned_To__c = salesUserId;
        ahTwo.Delegated_approver__c = DelegatedUser.Id;
        aphList.add(ahTwo);
        system.debug(ahTwo);
     
        insert aphList;
        TriggerExecutionController.skipAllTriggers(false);
        
        Test.stopTest();
    } 
   
    public static testmethod void TestInBoundEmailApprove() {
        
        Opportunity opp = [SELECT Id FROM Opportunity where Liner_Brand__c ='Maersk Line' LIMIT 1];
        Approval_History__c ah = [SELECT id, Assigned_To__r.Email FROM Approval_History__c where TargetObjectId__c =:opp.Id limit 1];
        String historylink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+ah.Id;
        String Opptylink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+ opp.id;
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        List<string> emails = new List<string>{'opptyapproval@maersk.com'};
        email.subject = 'Opportunity Approval';
        email.fromAddress = ah.Assigned_To__r.Email;
        email.toAddresses = emails;
        email.plainTextBody = 'Approved\n OK\n Opportunity Id: '+Opptylink+'\nOR access Approval History link below\n'+historylink;
        
        Test.startTest();
        OpportunityApprovalEmailHandler  testInbound = new OpportunityApprovalEmailHandler();
        testInbound.handleInboundEmail(email, env);
        Test.stopTest();
        
    }
    public static testmethod void TestInBoundEmailReject() {
        
        Opportunity opp = [SELECT Id FROM Opportunity where Liner_Brand__c ='Maersk Line' LIMIT 1];
        Approval_History__c ah = [SELECT id, Assigned_To__r.Email,Key__c FROM Approval_History__c where TargetObjectId__c =:opp.Id limit 1];
        
        List<Approval_History__c> ah1 = New List<Approval_History__c>();
        ah.key__c = 'Qualification Products-LL-(United Kingdom, Lifestyle)-ECM';
        ah1.add(ah);
        update ah1;
        
        String historylink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+ah.Id;
        String Opptylink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+ opp.id;
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        List<string> emails = new List<string>{'opptyapproval@maersk.com'};
        email.subject = 'Opportunity Approval';
        email.fromAddress = ah.Assigned_To__r.Email;
        email.toAddresses = emails;
        email.plainTextBody = 'Rejected\n Not OK\n Opportunity Id: '+Opptylink+'\nOR access Approval History link below\n'+historylink;
        
        Test.startTest();
        OpportunityApprovalEmailHandler  testInbound = new OpportunityApprovalEmailHandler();
        testInbound.handleInboundEmail(email, env);
        Test.stopTest();
        
    }
    
    public static testmethod void TestInBoundEmailDelegated() {
        
        Opportunity opp = [SELECT Id FROM Opportunity where Liner_Brand__c ='Maersk Line' LIMIT 1];
        Approval_History__c ah = [SELECT id, Delegated_Approver__r.Email,Key__c FROM Approval_History__c where TargetObjectId__c =:opp.Id and Delegated_Approver__c != null limit 1];
        
        String historylink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+ah.Id;
        String Opptylink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+ opp.id;
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        List<string> emails = new List<string>{'opptyapproval@maersk.com'};
        email.subject = 'Opportunity Approval';
        email.fromAddress = ah.Delegated_Approver__r.Email;
        email.toAddresses = emails;
        email.plainTextBody = 'Rejected\n Not OK\n Opportunity Id: '+Opptylink+'\nOR access Approval History link below\n'+historylink;
        
        Test.startTest();
        OpportunityApprovalEmailHandler  testInbound = new OpportunityApprovalEmailHandler();
        testInbound.handleInboundEmail(email, env);
        Test.stopTest();
        
    }
    
}