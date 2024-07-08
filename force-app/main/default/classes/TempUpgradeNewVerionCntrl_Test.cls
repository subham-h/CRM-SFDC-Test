/**
 * @description       : 
 * @author            : Samar@Maersk
 * @group             : 
 * @last modified on  : 11-07-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class TempUpgradeNewVerionCntrl_Test {

    static testmethod void testProductWithoutUpgrade(){ 
        TriggerExecutionController.skipAllTriggers(true);
        Account acc = TestBusinessHelper.createAccount('Client_Account', true);
        Contact con = TestBusinessHelper.createContact(acc, 'Customer_Contact','MaerskLine', true);
        User us = TestBusinessHelper.createUser('Sales', 'Maersk Line', true);
        Opportunity op = TestBusinessHelper.createOpportunity(acc, con, us,'Supply_Chain_Services','MaerskLine', true);
        Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true);  
		product.OIPC_Code__c='12345';
		product.Portfolio__c='LnS';
		product.Version__c=1;
		product.IsActive=true;
		product.Product_Status__c='Ready-to-sell';
		update product;
        List<Trade_Route__c> lstTDR = TestBusinessHelper.createTradeRoutes(new List<String> {'MSL'},  1, true);
        Geography__c geoCountry = TestBusinessHelper.createGeography('United States', 'Country', null, true);
        Geography__c geoState = TestBusinessHelper.createGeography('Arizona', 'State', geoCountry.Id, true);
        Opportunity_Product__c opp = TestBusinessHelper.createOpportunityLineItemCustom(op, product.Id, lstTDR[0], geoCountry, geoState, true);
        List<String> family = new List<String>{'Customs Services & Insurance', 'Ocean Spot'};
        List<Product2> newProdList = TestBusinessHelper.createProducts(family, 1, true);
        newProdList[0].OIPC_Code__c='12345';
		newProdList[0].Portfolio__c='LnS';
		newProdList[0].Version__c=1;
		newProdList[0].IsActive=true;
		newProdList[0].Product_Status__c='Ready-to-sell';
		update newProdList;

        product.IsActive=false;
        product.Latest_Product_Version__c = newProdList[0].Id;
        update product;

        list<Product_Component__c> pc = TestBusinessHelper.createProductComponents(newProdList, 1, true);
        list<Product_Feature__c> pf = TestBusinessHelper.createProductFeatures(pc, 1, true);
        pf[0].Default_Visibility__c = 'INCLUDED';
        update pf;
        list<Product_Specification_Parameter__c> psp = TestBusinessHelper.createProductSpecificationParameters(pf, 1, true);
        psp[0].is_Mandatory__c =true;
        psp[0].Configurable_at_Contracting__c = true;
        psp[0].Default_Visibility__c = 'INCLUDED';
        psp[0].Type__c='options';
        update psp;
        List<Product_Specification_Option__c> lstoption = TestBusinessHelper.createProductSpecificationOptions(psp, 1, true);
        list<Opportunity_Product_Configuration__c> oppConfig = TestBusinessHelper.createOpportunityProductConfigurations(opp, psp, lstoption, 1, true);
		//list<Product2> prodMap1 = [select id, OIPC_Code__c,name  from Product2 where isActive = true];
        //list<Opportunity_Product__c> oppProdUpdated = [select id,Product2Id__c,Product2ID__r.OIPC_Code__c from  Opportunity_Product__c];
        //list<Product_Specification_Parameter__c> pspp = [select Product_Feature__r.Product_Component__r.Product__c  from Product_Specification_Parameter__c];
        Test.startTest();
        String msg = TempUpgradeNewVerionCntrl.updateOpportunityProducts(new List<Id>{opp.Id}, new list<string>{newProdList[0].OIPC_Code__c} ,op.Id);
        //System.assertEquals(msg,'success');
        Test.stopTest();
       // opportunity product that record id 
         //need to create a product with same oipc code 
    }

  
   
    
    static testmethod void testProductWithUpgrade(){ 
        TriggerExecutionController.skipAllTriggers(true);
        Account acc = TestBusinessHelper.createAccount('Client_Account', true);
        Contact con = TestBusinessHelper.createContact(acc, 'Customer_Contact','MaerskLine', true);
        User us = TestBusinessHelper.createUser('Sales', 'Maersk Line', true);
        Opportunity op = TestBusinessHelper.createOpportunity(acc, con, us,'Supply_Chain_Services','MaerskLine', true);
        Product2 oldProduct = TestBusinessHelper.createProduct('Customs Services & Insurance', true);  
		oldProduct.OIPC_Code__c='12345';
		oldProduct.Portfolio__c='LnS';
		oldProduct.Version__c=1;
		oldProduct.IsActive=true;
		//product.Product_Status__c='Ready-to-sell';
		oldProduct.Latest_Product_Version__c=null;
		update oldProduct;
        
        List<Trade_Route__c> lstTDR = TestBusinessHelper.createTradeRoutes(new List<String> {'MSL'},  1, true);
        Geography__c geoCountry = TestBusinessHelper.createGeography('United States', 'Country', null, true);
        Geography__c geoState = TestBusinessHelper.createGeography('Arizona', 'State', geoCountry.Id, true);
        Opportunity_Product__c opp = TestBusinessHelper.createOpportunityLineItemCustom(op, oldProduct.Id, lstTDR[0], geoCountry, geoState, true);
        List<String> family = new List<String>{'Customs Services & Insurance', 'Ocean Spot'};
        
        
        list<Product_Component__c> pcOld = TestBusinessHelper.createProductComponents(new List<Product2> {oldProduct}, 1, true);
        list<Product_Feature__c> pfOld = TestBusinessHelper.createProductFeatures(pcOld, 1, true);
        pfOld[0].Default_Visibility__c = 'INCLUDED';
        update pfOld;
        list<Product_Specification_Parameter__c> pspOld = TestBusinessHelper.createProductSpecificationParameters(pfOld, 1, true);
        pspOld[0].is_Mandatory__c =true;
        pspOld[0].Configurable_at_Contracting__c = true;
        pspOld[0].Default_Visibility__c = 'INCLUDED';
        pspOld[0].Type__c='options';
        pspOld[0].Specification_Parameter_Code__c='SP-P0-228d';
        update pspOld;
        List<Product_Specification_Option__c> lstoptionOld = TestBusinessHelper.createProductSpecificationOptions(pspOld, 1, true);
        list<Opportunity_Product_Configuration__c> oppConfig = TestBusinessHelper.createOpportunityProductConfigurations(opp, pspOld, lstoptionOld, 1, true);
        
        Test.startTest();

        Product2 newProduct = TestBusinessHelper.createProduct('Customs Services & Insurance', true);  
		newProduct.OIPC_Code__c='12345';
		newProduct.Portfolio__c='LnS';
		newProduct.Version__c=2;
		newProduct.IsActive=true;
		//product.Product_Status__c='Ready-to-sell';
		newProduct.Latest_Product_Version__c=null;
		update newProduct; 


        oldProduct.IsActive=false;
        oldProduct.Latest_Product_Version__c = newProduct.Id;
        update oldProduct;
        
        list<Product_Component__c> pcNew = TestBusinessHelper.createProductComponents(new List<Product2> {newProduct}, 1, true);
        list<Product_Feature__c> pfNew = TestBusinessHelper.createProductFeatures(pcNew, 1, true);
        pfNew[0].Default_Visibility__c = 'INCLUDED';
        update pfNew;
        list<Product_Specification_Parameter__c> pspNew = TestBusinessHelper.createProductSpecificationParameters(pfNew, 1, true);
        pspNew[0].is_Mandatory__c =true;
        pspNew[0].Configurable_at_Contracting__c = true;
        pspNew[0].Default_Visibility__c = 'INCLUDED';
        pspNew[0].Type__c='options';
        pspNew[0].Specification_Parameter_Code__c='SP-P0-228f';
        update pspNew;
        List<Product_Specification_Option__c> lstoptionNew = TestBusinessHelper.createProductSpecificationOptions(pspNew, 1, true);
        
        oldProduct.IsActive=false;
		//product.Product_Status__c='Ready-to-sell';
		oldProduct.Latest_Product_Version__c=newProduct.Id;
		update oldProduct;
        
        String msg = TempUpgradeNewVerionCntrl.updateOpportunityProducts(new List<Id>{opp.Id}, new list<string>{oldProduct.OIPC_Code__c} ,op.Id);
        //System.assertEquals(msg,'success');

        Test.stopTest();
        
 }
    static testmethod void testProductWithUpgrade1(){ 
        TriggerExecutionController.skipAllTriggers(true);
        Account acc = TestBusinessHelper.createAccount('Client_Account', true);
        Contact con = TestBusinessHelper.createContact(acc, 'Customer_Contact','MaerskLine', true);
        User us = TestBusinessHelper.createUser('Sales', 'Maersk Line', true);
        Opportunity op = TestBusinessHelper.createOpportunity(acc, con, us,'Supply_Chain_Services','MaerskLine', true);
        Product2 oldProduct = TestBusinessHelper.createProduct('Customs Services & Insurance', true);  
		oldProduct.OIPC_Code__c='12345';
		oldProduct.Portfolio__c='LnS';
		oldProduct.Version__c=1;
		oldProduct.IsActive=true;
		//product.Product_Status__c='Ready-to-sell';
		oldProduct.Latest_Product_Version__c=null;
		update oldProduct;
        
        List<Trade_Route__c> lstTDR = TestBusinessHelper.createTradeRoutes(new List<String> {'MSL'},  1, true);
        Geography__c geoCountry = TestBusinessHelper.createGeography('United States', 'Country', null, true);
        Geography__c geoState = TestBusinessHelper.createGeography('Arizona', 'State', geoCountry.Id, true);
        Opportunity_Product__c opp = TestBusinessHelper.createOpportunityLineItemCustom(op, oldProduct.Id, lstTDR[0], geoCountry, geoState, true);
        List<String> family = new List<String>{'Customs Services & Insurance', 'Ocean Spot'};
        
        
        list<Product_Component__c> pcOld = TestBusinessHelper.createProductComponents(new List<Product2> {oldProduct}, 1, true);
        list<Product_Feature__c> pfOld = TestBusinessHelper.createProductFeatures(pcOld, 1, true);
        pfOld[0].Default_Visibility__c = 'INCLUDED';
        pfOld[0].Feature_Code__c ='F-P0-kd1';
        update pfOld;
        list<Product_Specification_Parameter__c> pspOld = TestBusinessHelper.createProductSpecificationParameters(pfOld, 1, true);
        pspOld[0].is_Mandatory__c =true;
        pspOld[0].Configurable_at_Contracting__c = true;
        pspOld[0].Default_Visibility__c = 'INCLUDED';
        pspOld[0].Type__c='options';
        pspOld[0].Specification_Parameter_Code__c='SP-P0-228d';
        update pspOld;
        List<Product_Specification_Option__c> lstoptionOld = TestBusinessHelper.createProductSpecificationOptions(pspOld, 1, true);
        List<Opportunity_Product_Configuration__c> oppConfig = TestBusinessHelper.createOpportunityProductConfigurations(opp, pspOld, lstoptionOld, 1, true);
        Opportunity_Product_Configuration__c featConfig = new Opportunity_Product_Configuration__c(
              Configured_Product_Component__c=pcOld[0].Id,
              Configured_Product_Feature__c=pfOld[0].Id,
              Is_Feature_Included__c=true,
              Is_Specification_Parameter_Included__c=false,
              Opportunity_Product_Cus__c=opp.Id
            );
        insert featConfig;
        
        Test.startTest();

        Product2 newProduct = TestBusinessHelper.createProduct('Customs Services & Insurance', true);  
		newProduct.OIPC_Code__c='12345';
		newProduct.Portfolio__c='LnS';
		newProduct.Version__c=2;
		newProduct.IsActive=true;
		//product.Product_Status__c='Ready-to-sell';
		newProduct.Latest_Product_Version__c=null;
		update newProduct; 
        
        oldProduct.IsActive=false;
        oldProduct.Latest_Product_Version__c = newProduct.Id;
        update oldProduct;

        list<Product_Component__c> pcNew = TestBusinessHelper.createProductComponents(new List<Product2> {newProduct}, 1, true);
        list<Product_Feature__c> pfNew = TestBusinessHelper.createProductFeatures(pcNew, 1, true);
        pfNew[0].Default_Visibility__c = 'INCLUDED';
        pfNew[0].Feature_Code__c ='F-P0-kd1';
        update pfNew;
        list<Product_Specification_Parameter__c> pspNew = TestBusinessHelper.createProductSpecificationParameters(pfNew, 1, true);
        pspNew[0].is_Mandatory__c =true;
        pspNew[0].Configurable_at_Contracting__c = true;
        pspNew[0].Default_Visibility__c = 'INCLUDED';
        pspNew[0].Type__c='options';
        pspNew[0].Specification_Parameter_Code__c='SP-P0-228f';
        update pspNew;
        List<Product_Specification_Option__c> lstoptionNew = TestBusinessHelper.createProductSpecificationOptions(pspNew, 1, true);
        
        oldProduct.IsActive=false;
		//product.Product_Status__c='Ready-to-sell';
		oldProduct.Latest_Product_Version__c=newProduct.Id;
		update oldProduct;
        
        String msg = TempUpgradeNewVerionCntrl.updateOpportunityProducts(new List<Id>{opp.Id},new list<string>{oldProduct.OIPC_Code__c} ,op.Id);
        //System.assertEquals(msg,'success');

        Test.stopTest();
        
 }

}