/* Ver.      Ref Number          Date              Dev                   Description
* --------   ----------         -----------   -------------------         -----------
*                               22-Aug-23       Shashi@Maersk            Modified the test class as per new Test Framework 
* 
*/
@isTest
private class OpportunityWizardCtrlTest {
    @TestSetup 
    static void setup() {
        Test.startTest();
        TriggerExecutionController.skipAllTriggers(true);
        
        /**Account ClientAccount = AccountDataHelper_Test.createClientAccount();
        ContactData_Test.createCustomerContacts();  
        Opportunity mslOppty = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( ClientAccount.id, null);**/
        
        User maerskLineUser = TestBusinessHelper.createUser('System Administrator', BrandUtilities.MAERSKLINE, true);
        Account ClientAccount = TestBusinessHelper.createAccount('Client_Account', true);
        Contact contact = TestBusinessHelper.createContact(ClientAccount, 'Customer_Contact', BrandUtilities.MAERSKLINE, true);
        Opportunity mslOppty = TestBusinessHelper.createOpportunity(ClientAccount, contact, maerskLineUser, 'ShippingCargoServices',  BrandUtilities.MAERSKLINE, true);
        
        TriggerExecutionController.skipAllTriggers(false);
        
        
        //List<Trade_Route__c> lstTDR = DataGeneratorHelper_OIPC.createTradeRoutes(1, 'MSL');
        //insert lstTDR;
        List<String> lstTradeRouteOperator = new List<String>{'MSL'}; 
        List<Trade_Route__c> lstTDR = TestBusinessHelper.createTradeRoutes(lstTradeRouteOperator, 1, true);
        
        
        //List<Product2> lstProd = DataGeneratorHelper_OIPC.createOipcProducts(2);
        //insert lstProd;
        list<String> prodFamily = new List<String>{'Ocean'};
        List<Product2> lstProd = TestBusinessHelper.createProducts(prodFamily, 2, true);

        //List<Product_Component__c> lstComp = DataGeneratorHelper_OIPC.createOipcProductComponents(2, lstProd[0].id);
        //lstComp.addAll(DataGeneratorHelper_OIPC.createOipcProductComponents(1, lstProd[1].id));
        //insert lstComp ;
        List<Product2> lstProd1 = new List<Product2>{lstProd[0]};
        List<Product_Component__c> lstComp1 = TestBusinessHelper.createProductComponents(lstProd1, 2, true);
        List<Product2> lstProd2 = new List<Product2>{lstProd[1]};
        List<Product_Component__c> lstComp2 = TestBusinessHelper.createProductComponents(lstProd2, 1, true);
        List<Product_Component__c> lstComp = new List<Product_Component__c>();
        lstComp.addAll(lstComp1);
        lstComp.addAll(lstComp2);
            
        //List<Product_Feature__c> lstFeatures = DataGeneratorHelper_OIPC.createOipcProductFeatures(4, lstComp[0].id);
        //lstFeatures.addAll(DataGeneratorHelper_OIPC.createOipcProductFeatures(1, lstComp[1].id));
        //lstFeatures.addAll(DataGeneratorHelper_OIPC.createOipcProductFeatures(2, lstComp[2].id));
        //insert lstFeatures;
        List<Product_Component__c> lstCompnt1 = new List<Product_Component__c>{lstComp[0]};
        List<Product_Component__c> lstCompnt2 = new List<Product_Component__c>{lstComp[1]};   
        List<Product_Component__c> lstCompnt3 = new List<Product_Component__c>{lstComp[2]}; 
        List<Product_Feature__c> lstFeatures1 = TestBusinessHelper.createProductFeatures(lstCompnt1, 4, true);
        List<Product_Feature__c> lstFeatures2 = TestBusinessHelper.createProductFeatures(lstCompnt2, 1, true);
        List<Product_Feature__c> lstFeatures3 = TestBusinessHelper.createProductFeatures(lstCompnt3, 2, true);
        List<Product_Feature__c> lstFeatures = new List<Product_Feature__c>();
        lstFeatures.addAll(lstFeatures1);
        lstFeatures.addAll(lstFeatures2);
        lstFeatures.addAll(lstFeatures3);
        
        
        /**List<Product_Specification_Parameter__c> lstFeatParam = DataGeneratorHelper_OIPC.createProdSpecfiParams(4, lstFeatures[0].id);
        lstFeatParam.addAll(DataGeneratorHelper_OIPC.createProdSpecfiParams(1, lstFeatures[1].id));
        lstFeatParam.addAll(DataGeneratorHelper_OIPC.createProdSpecfiParams(2, lstFeatures[2].id));
        insert lstFeatParam;*/
        List<Product_Feature__c> lstFeature1 = new List<Product_Feature__c>{lstFeatures[0]};
        List<Product_Feature__c> lstFeature2 = new List<Product_Feature__c>{lstFeatures[4]};
        List<Product_Feature__c> lstFeature3 = new List<Product_Feature__c>{lstFeatures[5]};    
        List<Product_Specification_Parameter__c> lstFeatParam1 = TestBusinessHelper.createProductSpecificationParameters(lstFeature1, 4, true);
        List<Product_Specification_Parameter__c> lstFeatParam2 = TestBusinessHelper.createProductSpecificationParameters(lstFeature2, 1, true);
        List<Product_Specification_Parameter__c> lstFeatParam3 = TestBusinessHelper.createProductSpecificationParameters(lstFeature3, 2, true);
        List<Product_Specification_Parameter__c> lstspecParameters = new List<Product_Specification_Parameter__c>();
        lstspecParameters.addAll(lstFeatParam1);
        lstspecParameters.addAll(lstFeatParam2);
        lstspecParameters.addAll(lstFeatParam3);
        
        /**List<Product_Specification_Option__c> lstSpecOptions = DataGeneratorHelper_OIPC.createProdSpecfiOptions(4, lstFeatParam[0].id);
        lstSpecOptions.addAll(DataGeneratorHelper_OIPC.createProdSpecfiOptions(1, lstFeatParam[1].id));
        lstSpecOptions.addAll(DataGeneratorHelper_OIPC.createProdSpecfiOptions(2, lstFeatParam[2].id));
        insert lstSpecOptions;*/
        List<Product_Specification_Parameter__c> lstSpecParam1 = new List<Product_Specification_Parameter__c>{lstspecParameters[0]};
        List<Product_Specification_Parameter__c> lstSpecParam2 = new List<Product_Specification_Parameter__c>{lstspecParameters[4]};
        List<Product_Specification_Parameter__c> lstSpecParam3 = new List<Product_Specification_Parameter__c>{lstspecParameters[5]};
        List<Product_Specification_Option__c> lstSpecOption1 = TestBusinessHelper.createProductSpecificationOptions(lstSpecParam1, 4, true);
        List<Product_Specification_Option__c> lstSpecOption2 = TestBusinessHelper.createProductSpecificationOptions(lstSpecParam2, 1, true);
        List<Product_Specification_Option__c> lstSpecOption3 = TestBusinessHelper.createProductSpecificationOptions(lstSpecParam3, 2, true);
        List<Product_Specification_Option__c> lstSpecoptions = new List<Product_Specification_Option__c>();
        lstSpecoptions.addAll(lstSpecOption1);
        lstSpecoptions.addAll(lstSpecOption2);
        lstSpecoptions.addAll(lstSpecOption3);
        
        List<PriceBookEntry> pbEntry = [select Id from PriceBookEntry];
        /**OpportunityLineItem Oli1 = DataGeneratorHelper1_Test.createOpportunityLineItemWithTrade( mslOppty.Id, pbEntry[0].Id , null, lstTDR[0].Id);
        //insert Oli1;
        Opportunity_Product__c Oli = New Opportunity_Product__c();
            Oli.OpportunityId__c = mslOppty.Id;
            Oli.Quantity__c = 1;
            //oli.Product2ID__c= prod.id;
            Oli.UnitPrice__c = 1000000;
            oli.Opt_Out_Auto_Quantity_Scheduling__c = false;
            Oli.Tender_Target__c = 1;
            oli.Nominated_Quantity__c = 1;
            insert oli;*/
        
        Opportunity_Product__c Oli = TestBusinessHelper.createOpportunityLineItemCustom(mslOppty, lstProd[0].Id, lstTDR[0], true);
        
        
        /**List<Id> featureIds = new List<Id> ();
        for (Product_Feature__c f : lstFeatures){
            featureIds.add(f.Id);
        }
        /
        Opportunity_Product_Configuration__c config1= new Opportunity_Product_Configuration__c();
        config1.Opportunity_Product__c=  Oli1.Id;
        config1.Opportunity_Product_Cus__c = oli.id;
        config1.Product_Specification_Option__c= lstSpecOptions[0].Id;
        config1.Product_Specificaiton_Parameter__c=  lstFeatParam[0].Id;
        lstconfig.add(config1);*/
        
        //List<Opportunity_Product_Configuration__c> lstconfig = new List<Opportunity_Product_Configuration__c>();
        
        List<Opportunity_Product_Configuration__c> config = TestBusinessHelper.createOpportunityProductConfigurations(Oli, lstspecParameters, lstSpecoptions, 2, true);
        
        /**Opportunity_Product_Configuration__c config2= new Opportunity_Product_Configuration__c();
        config2.Opportunity_Product__c=  Oli1.Id;
        config2.Opportunity_Product_Cus__c = oli.id;
        config2.Product_Specification_Option__c= lstSpecOptions[1].Id;
        config2.Product_Specificaiton_Parameter__c=  lstFeatParam[1].Id;
        lstconfig.add(config2);
        insert lstconfig;*/
        Test.stopTest();
        //insert (DataGeneratorHelper_OIPC.createOpptyFeatures(Oli1.Id, featureIds));
        
    }
    static testmethod void TestOpptyRecordType(){ 
     Test.startTest();
        OpportunityWizardCtrl.getListOfRecordType();
        OpportunityWizardCtrl.getAvailableRecordTypeOpp();
        test.stopTest();
    }
    static testmethod void TestAccountOpty(){ 
        
        List<Account> accList = [Select Id from Account Limit 1];
        List<Id> lstOfIds = new List<Id>();
        for(Account acc: accList){
            lstOfIds.add(acc.Id);
        }
        OpportunityWizardCtrl.isPermitted();
        OpportunityWizardCtrl.isAccRecTypeConcern(lstOfIds);
        
        OpportunityWizardCtrl.fetchOpps(accList[0].Id);
        
    }
    static testmethod void TestContact(){
        List<Contact> lstOfContacts = [Select Id from Contact limit 1];
        OpportunityWizardCtrl.fetchContactDetails(lstOfContacts[0].Id);
    } 
    static testmethod void TestAccount(){
        List<Account> accList = [Select Id from Account Limit 1];
        
        OpportunityWizardCtrl.fetchAccountDetails(accList[0].Id);
    } 
    static testmethod void TestcreateContract(){
    
        List<Account> accList = [Select Id from Account Limit 1];
        List<Opportunity> optyList = [select Id from Opportunity limit 1];
         Test.startTest();
        Contract__c cont = new Contract__c();
        cont.Agreement_Type_Code__c = 'Credit_Agreement';
        cont.Brand_Name__c = 'Maersk';
        cont.Customer__c = accList[0].Id;
        cont.Effective_Date__c = system.today();
        cont.Expiration_Date__c = system.today() + 10;
        cont.Is_FMC_Contract__c = false;
        cont.Is_Master_Contract__c = false;
        cont.Status__c = 'Draft';
        insert cont;
        system.debug('cont ' + cont);
        Opportunity_Contract__c opc = new Opportunity_Contract__c();
        opc.Contract__c = cont.Id;
        opc.Opportunity__c = optyList[0].Id;
        // insert opc;
        List<Opportunity_Contract__c> oppContracts = new List<Opportunity_Contract__c>();
        oppContracts.add(opc);
        
        OpportunityWizardCtrl.createOppContracts(oppContracts,optyList[0].Id);
        OpportunityWizardCtrl.fetchContracts(accList[0].Id);
        test.stoptest();
    } 
    static testmethod void TestcreateOptys(){
        List<Account> accList = [Select Id from Account Limit 1];
        Opportunity recOpportunity = new Opportunity();
        recOpportunity.Name = 'Test OmebKpiProcess';
        recOpportunity.Submitted_For_approval__c=False;
        recOpportunity.Approval_Status__c=Null;
        recOpportunity.AccountId = accList[0].Id;
        recOpportunity.Liner_Brand__c='Maersk Line';
        recOpportunity.Type='Acquisition';
        recOpportunity.CloseDate=System.today() + 10;
        recOpportunity.StageName='Identifying';
        recOpportunity.Go_Live_Date__c=System.today() + 30;
        recOpportunity.First_Shipment_Date__c=System.today() + 20;
        recOpportunity.Last_Shipment_Date__c=System.today() + 40;    
        recOpportunity.Requires_IT_Integration__c=' Yes, I am sure this is required basis my discussion with customer';
        recOpportunity.Estimated_Agreement_Duration__c=9;
        recOpportunity.Offer_Type__c = 'Offer containing Standard T&Cs';
        recOpportunity.Expected_Handling_Rounds__c=2;
        List<Opportunity> optyList = new List<Opportunity>();
        optyList.add(recOpportunity);
        List<sObject> oppContracts = new List<sobject>();
        list<Opportunity> opportunities = OpportunityWizardCtrl.insertOpps(optyList, 'Supply Chain Services', oppContracts );
        System.assertNotEquals(opportunities, null);
    }
    /*
    static testmethod void TestcheckRecordTypeRules(){
        Date lastSnippingDate = System.today() + 40;
        Date firstSnippingDate = System.today() + 20;
        List<AddOpptyProductsCntrl.productWrapper> lstProductWrapper = new List<AddOpptyProductsCntrl.productWrapper>();
        List<Product2> productList = [SELECT Id, Name, (Select ID, Product2Id, UnitPrice FROM PricebookEntries) Route_Direction_Code__c, QuantityUnitOfMeasure, Family, Product_Status__c, OIPC_Code__c,Portfolio__c,Include_in_OMEB_Approvals__c from Product2 LIMIT 5];
        for (Product2 prod :productList){
            AddOpptyProductsCntrl.productWrapper prodRecord = new AddOpptyProductsCntrl.productWrapper();
            prodRecord.Name = prod.Name;
            prodRecord.totalCompletedFeatures = 0;
            prodRecord.productId = prod.Id;
            prodRecord.productURL = '/' + prod.PricebookEntries[0].Id; //prod.Id;
            prodRecord.QuantityUnitOfMeasure = prod.QuantityUnitOfMeasure;
            prodRecord.Family = prod.Family;
            prodRecord.featureCount = 0;
            prodRecord.includeInOMEB = prod.Include_in_OMEB_Approvals__c;
            prodRecord.qtyUnitOfMeasure = prod.QuantityUnitOfMeasure;
            prodRecord.productCategory	 = prod.Product_Category__c;
            lstProductWrapper.add(prodRecord);
        }
        OpportunityWizardCtrl.checkRecordTypeRules(lastSnippingDate,firstSnippingDate, lstProductWrapper,'Tender');
        
    }*/
}