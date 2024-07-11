/*
Date            Story       Developer       Description
30-June-2023     SFSE-8443   ramya          Code Created 
14-Feb-2024      SFSE-13892  ramadevi       upgrade solution on the Opportunity Product                                      
*/

@isTest
private class AddNewVersionOpptyProductsCntrl_Test {
    
    @testSetup static void setupTestData(){
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
            product.Latest_Product_Version__c = null;
            update product;
            List<Trade_Route__c> lstTDR = TestBusinessHelper.createTradeRoutes(new List<String> {'MSL'},  1, true);
            Geography__c geoCountry = TestBusinessHelper.createGeography('United States', 'Country', null, true);
            Geography__c geoState = TestBusinessHelper.createGeography('Arizona', 'State', geoCountry.Id, true);
        	BDA__c uSParentBDA = TestBusinessHelper.createBDA('North America Region', 'Trade Region', 'NAM', null, UserInfo.getUserId(), true);
        	BDA__c uSChildBDA = TestBusinessHelper.createBDA('North America Area', 'Cluster', 'NOA', uSParentBDA, UserInfo.getUserId(), true);
        	Segmentation_Matrix__c USsgm = TestBusinessHelper.createSegmentationMatrix(uSParentBDA.Id, uSChildBDA.Id, geoCountry.Id, true);
        	Segment_Data__c sgdata = TestBusinessHelper.createSegmentaData(product.id, USsgm.Id, true);
            Opportunity_Product__c opp = TestBusinessHelper.createOpportunityLineItemCustom(op, product.Id, lstTDR[0], geoCountry, geoState, true);
            List<String> family = new List<String>{'Customs Services & Insurance', 'Ocean Spot'};
            List<Product2> newProdList = TestBusinessHelper.createProducts(family, 1, true);
            newProdList[0].OIPC_Code__c='12345';
            newProdList[0].Portfolio__c='LnS';
            newProdList[0].Version__c=1;
            newProdList[0].IsActive=true;
            newProdList[0].Product_Status__c='Ready-to-sell';
            update newProdList;
            list<Product_Component__c> pc = TestBusinessHelper.createProductComponents(newProdList, 1, true);
            list<Product_Feature__c> pf = TestBusinessHelper.createProductFeatures(pc, 1, true);
            pf[0].Default_Visibility__c = 'INCLUDED';
            update pf;
            list<Product_Specification_Parameter__c> psp = TestBusinessHelper.createProductSpecificationParameters(pf, 1, true);
            psp[0].is_Mandatory__c =true;
            psp[0].Configurable_at_Contracting__c = true;
            psp[0].Default_Visibility__c = 'INCLUDED';
            psp[0].Type__c='options';
            psp[0].Specification_Parameter_Code__c='SP-P0-228d';
            update psp;
            List<Product_Specification_Option__c> lstoption = TestBusinessHelper.createProductSpecificationOptions(psp, 1, true);
            list<Opportunity_Product_Configuration__c> oppConfig = TestBusinessHelper.createOpportunityProductConfigurations(opp, psp, lstoption, 1, true);
            
            Product2 solution1 = TestBusinessHelper.createProduct('Ocean', false);
            solution1.Id = null;
            solution1.OIPC_Code__c = 's-p0-123';
            solution1.Portfolio__c = 'Ocean';
            solution1.Version__c = 2;
            solution1.IsActive = true;
            solution1.Is_Product_Solution__c = true;
            
            solution1.Definition_Type__c = 'Packaged Solution';
            insert solution1;
        }
    
    static testmethod void testProductWithoutUpgrade(){         
		//list<Product2> prodMap1 = [select id, OIPC_Code__c,name  from Product2 where isActive = true];
        //list<Opportunity_Product__c> oppProdUpdated = [select id,Product2Id__c,Product2ID__r.OIPC_Code__c from  Opportunity_Product__c];
        //list<Product_Specification_Parameter__c> pspp = [select Product_Feature__r.Product_Component__r.Product__c  from Product_Specification_Parameter__c];
        List<Product2> newProdList = [SELECT id,OIPC_Code__c from Product2 where isActive=true];
        list<Opportunity_Product__c> oppProd = [select id,Product2Id__c,Product2ID__r.OIPC_Code__c,OpportunityId__c from  Opportunity_Product__c where Product2ID__r.OIPC_Code__c=:newProdList[0].OIPC_Code__c];
        Test.startTest();
        //String msg = AddNewVersionOpptyProductsCntrl.updateOpportunityProducts(new list<string>{newProdList[0].OIPC_Code__c} ,op.Id);
        String msg = AddNewVersionOpptyProductsCntrl.updateOpportunityProducts(new list<string>{newProdList[0].OIPC_Code__c} ,oppProd[0].OpportunityId__c);
        System.assertEquals(msg,'success');
        Test.stopTest();
       // opportunity product that record id 
         //need to create a product with same oipc code 
    }

    static testmethod void TestgetNewVersions(){ 
        
        Geography__c geoCountry = [SELECT id from Geography__c where Name='United States' limit 1];
        Geography__c geoState = [SELECT id from Geography__c where Name='Arizona'  limit 1];
        List<Trade_Route__c> lstTDR1 = [SELECT id from Trade_Route__c];
        Opportunity op = [SELECT id from Opportunity limit 1];

        Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true);  
		product.OIPC_Code__c='P-T1-35fd';
		product.Portfolio__c='Ocean';
		product.Version__c=6;
		product.IsActive=true;
		product.Product_Status__c='Ready-to-sell';
		update product;       
        Opportunity_Product__c opp = TestBusinessHelper.createOpportunityLineItemCustom(op, product.Id, lstTDR1[0], geoCountry, geoState, true);
        List<Opportunity_Product__c> optyLineItemList = [Select Id,Amend_Gross_Profit_per_unit__c, Name,Product2Id__c,Product2ID__r.OIPC_Code__c,Product2ID__r.Name,Quantity__c,UnitPrice__c
                                                         , Country__r.Name, Executing_City_State__r.Name, Trade_Route__r.Name, OpportunityId__r.IsClosed, Product2ID__r.Include_in_OMEB_Approvals__c,
                                                         OpportunityId__r.StageName, OpportunityId__c, OpportunityId__r.Must_Go_To_OMEB__c,Product2Id__r.isActive,Product2Id__r.Latest_Product_Version__c 
                                                         from Opportunity_Product__c where Product2Id__r.isActive = false and Product2Id__r.Latest_Product_Version__c !=null limit 2]; 
       

       Test.startTest();
       AddNewVersionOpptyProductsCntrl.getNewVersions(opp.Id);
       Test.stopTest();
    }
    
    
    static testmethod void testProductWithUpgrade(){         
        Product2 oldProduct = [SELECT id,OIPC_Code__c,IsActive,Latest_Product_Version__c from Product2 where Latest_Product_Version__c=null and IsActive=true and OIPC_Code__c='12345' limit 1];
        Opportunity op = [SELECT id from Opportunity limit 1];
        Test.startTest();

        Product2 newProduct = TestBusinessHelper.createProduct('Customs Services & Insurance', true);  
		newProduct.OIPC_Code__c='12345';
		newProduct.Portfolio__c='LnS';
		newProduct.Version__c=2;
		newProduct.IsActive=true;
		//product.Product_Status__c='Ready-to-sell';
		newProduct.Latest_Product_Version__c=null;
		update newProduct; 
        
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
        
        String msg = AddNewVersionOpptyProductsCntrl.updateOpportunityProducts(new list<string>{oldProduct.OIPC_Code__c} ,op.Id);
        System.assertEquals(msg,'success');

        Test.stopTest();
        
}    
    static testmethod void testProductWithUpgrade1(){
        Product2 oldProduct = [SELECT id,OIPC_Code__c from Product2 where Latest_Product_Version__c=null and IsActive=true and OIPC_Code__c='12345' limit 1];
        Opportunity op = [SELECT id from Opportunity limit 1];
        list<Opportunity_Product__c> opp = [select id,Product2Id__c,Product2ID__r.OIPC_Code__c,OpportunityId__c from  Opportunity_Product__c where Product2ID__r.OIPC_Code__c=:oldProduct.OIPC_Code__c];
        

        list<Product_Component__c> pcOld = [SELECT Id from Product_Component__c limit 1];
        list<Product_Feature__c> pfOld = [SELECt Id,Default_Visibility__c,Feature_Code__c from Product_Feature__c limit 2];
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
        List<Opportunity_Product_Configuration__c> oppConfig = TestBusinessHelper.createOpportunityProductConfigurations(opp[0], pspOld, lstoptionOld, 1, true);

        Opportunity_Product_Configuration__c featConfig = new Opportunity_Product_Configuration__c(
              Configured_Product_Component__c=pcOld[0].Id,
              Configured_Product_Feature__c=pfOld[0].Id,
              Is_Feature_Included__c=true,
              Is_Specification_Parameter_Included__c=false,
              Opportunity_Product_Cus__c=opp[0].Id
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
        
        String msg = AddNewVersionOpptyProductsCntrl.updateOpportunityProducts(new list<string>{oldProduct.OIPC_Code__c} ,op.Id);
        System.assertEquals(msg,'success');

        Test.stopTest();
        
 }
    
    static testmethod void testgetNewVersionsProducts(){
        Test.startTest();        
        Product2 lstProd = [SELECT id,OIPC_Code__c from Product2 limit 1];
        Opportunity mslOppty = [SELECT id from Opportunity limit 1];
        Product2 productTest2 = TestBusinessHelper.createProduct('Ocean', false);
        productTest2.id = null;
        productTest2.OIPC_Code__c = 'oipc-Code-1';
        productTest2.isActive = true;
        productTest2.Version__c = 2;
       	productTest2.Minor_Version__c = 0;
        productTest2.Increment_Version__c = 0;
        insert productTest2;
         List<Product2> lstProd1= [Select  Id,OIPC_Code__c,Version__c,Minor_Version__c,Increment_Version__c,isactive,Latest_Product_Version__c from Product2 where id=:lstProd.id limit 1];
        lstProd1[0].OIPC_Code__c = 'oipc-Code-1';
        lstProd1[0].isactive= false;
        lstProd1[0].Latest_Product_Version__c = productTest2.id;
        lstProd1[0].Version__c = 1;
        lstProd1[0].Minor_Version__c = 0;
        lstProd1[0].Increment_Version__c = 0;
        update lstProd1;
        
        TriggerExecutionController.skipAllTriggers(false);
        AddNewVersionOpptyProductsCntrl.getNewVersions(mslOppty.id);        
        
        Test.stopTest();
    }
    
    static testmethod void testgetNewVersionsSolutions(){
        Test.startTest();       
        
        Opportunity mslOppty = [SELECT Id,Pricebook2Id from Opportunity limit 1];
        mslOppty.Pricebook2Id = Test.getStandardPricebookId();
        update mslOppty;

        Product2 solution1 = [SELECT Id from Product2 where Definition_Type__c = 'Packaged Solution'];

        Product2 solution2 = TestBusinessHelper.createProduct('Ocean', false);
        solution2.Id = null;
        solution2.OIPC_Code__c = 's-p0-123';
        solution2.Portfolio__c = 'Ocean';
        solution2.Version__c = 2;
        solution2.IsActive = false;
        solution2.Is_Product_Solution__c = true;
        solution2.Latest_Product_Version__c=solution1.id;
        solution2.Definition_Type__c = 'Packaged Solution';
        insert solution2;
        Database.DMLOptions opts = new Database.DMLOptions();
        opts.DuplicateRuleHeader.AllowSave = true;
      
        Product2 latestproduct1 = TestBusinessHelper.createProduct('Ocean', false);
        latestproduct1.Id= null;
        latestproduct1.name = 'TestProduct';
        latestproduct1.OIPC_Code__c ='oipc-Code-2';
        latestproduct1.Portfolio__c = 'Ocean';
        latestproduct1.Version__c = 2;
        latestproduct1.IsActive = true;
        latestproduct1.Product_Status__c = 'Ready-to-sell';
        latestproduct1.Latest_Product_Version__c = null;
        latestproduct1.Is_Product_Solution__c = true;
        latestproduct1.Definition_Type__c = 'Product';
         Database.insert(latestproduct1, opts);

        Product2 latestproduct2 = TestBusinessHelper.createProduct('Ocean', FALSE);
        latestproduct2.Id = null;
        latestproduct2.OIPC_Code__c = 'oipc-Code-1';
        latestproduct2.Portfolio__c = 'Ocean';
        latestproduct2.Version__c = 2;
        latestproduct2.IsActive = true;
        latestproduct2.Product_Status__c='Ready-to-sell';
        latestproduct2.Latest_Product_Version__c=null;
        latestproduct2.Is_Product_Solution__c = true;
        latestproduct2.Definition_Type__c = 'Product';
       //nsert latestproduct2;
        Database.insert(latestproduct2, opts);
        
        TestBusinessHelper.createProductReference(solution2.Id,new List<String>{latestproduct1.Id},true);
        TestBusinessHelper.createProductReference(solution2.Id,new List<String>{latestproduct2.id},true);

        Geography__c geoCountry = [SELECT id from Geography__c where Name='United States' limit 1];
        Geography__c geoState = [SELECT id from Geography__c where Name='Arizona'  limit 1];
        List<Trade_Route__c> lstTDR1 = [SELECT id from Trade_Route__c];
        
        List<String> operators = new List<String>{'MCC','MSL','SAF'};
        List<Trade_Route__c> lstTDR = TestBusinessHelper.createTradeRoutes(operators, 2, true);
        Opportunity_Product__c Oli1 = TestBusinessHelper.createOpportunityLineItemCustom(mslOppty, latestproduct2.id, null, geoCountry, geoState, true);
        Oli1.Solution__c=solution2.id;
        update oli1;
        TriggerExecutionController.skipAllTriggers(false);
        AddNewVersionOpptyProductsCntrl.getNewVersions(mslOppty.id);
        //upgrade solution on the Opportunity Product
        String msg = AddNewVersionOpptyProductsCntrl.updateOpportunityProducts(new list<string>{solution2.OIPC_Code__c} ,mslOppty.id);
        System.assertEquals(msg,'success');
        test.stoptest();
        
    }
}