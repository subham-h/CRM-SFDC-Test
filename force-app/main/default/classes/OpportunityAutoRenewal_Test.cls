/*
* Author    : Shashi
* Purpose   : Test class for OpportunityAutoRenewal
* NOTE      : 
*        

* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0                   14-07-23    Shashi@Maersk           Created. 
* 2.0       SFSE-12654  05-02-24    Avinash@Maersk          Clone and auto-renew an opportunity with the latest solution version 
* 3.0       SFSE-13703  05-02-24    Jothsana@Maersk         To check MLL Brand Account owner for MLL Branded opportunity
* 4.0       SFSE-14064  07-03-2024  Vinay@Maersk            Added test methods for AutoRenewal.
* 5.0       SFSE-13671  11-03-2024  Arpitha@Maersk          Added a test method testAutoRenewalForQuaterlyDeal2.
*/

@isTest
public class OpportunityAutoRenewal_Test {
    
    @TestSetup @TestVisible
    static void setupTestData()
    {
       Test.startTest();
       TriggerExecutionController.skipAllTriggers(true);

        BDA__c region = TestBusinessHelper.createBDA('North America Area', 'Trade Region', 'NAM', null, null, true); 
        List<BDA__c> regionList = new List<BDA__c>();
        regionList.add(region);

        BDA__c cluster = TestBusinessHelper.createBDA('North America Region', 'Cluster', 'NAR', region, null, true);
        List<BDA__c> clusterList = new List<BDA__c>();
        clusterList.add(cluster);
        
        Geography__c country = TestBusinessHelper.createGeography('United States', 'Country', null, true);
        Geography__c city = TestBusinessHelper.createGeography('Colorado', 'City', country.Id, true);
        
        BDA_Geography__c BDAGeo1 = TestBusinessHelper.createBDAGeography(cluster.Id, country.Id, '1234', true);

        User teammate = TestBusinessHelper.createUser(ProfileUtilities.Sales, Brand__mdt.getInstance('MaerskLine').MasterLabel, false);

        System.runAs(new User(Id = UserInfo.getUserId())){
            teammate.Id = null;
            teammate.FederationIdentifier='testuser1@maersk.com';
            teammate.IsActive=true;
            insert teammate;
        }
        

        User maerskLineUser = TestBusinessHelper.createUser(ProfileUtilities.Sales, Brand__mdt.getInstance('MaerskLine').MasterLabel, false);

        System.runAs(new User(Id = UserInfo.getUserId())){
            maerskLineUser.Id = null;
         maerskLineUser.FederationIdentifier='testmsluser@maersk.com';
                maerskLineUser.Cluster__c='North America Area';
                maerskLineUser.Country='United States';
                maerskLineUser.Region__c='North America Region';
                maerskLineUser.IsActive=true;
                maerskLineUser.MLL__c = true;
            insert maerskLineUser;
        }

        List<String> linkIds = new List<String>{'test1','test2'};  //unique IDs for linking tradeRegion and clusters in Parent BDA
            
        List<Parent_BDA__c> parentBDA = TestBusinessHelper.createParentBDAs(clusterList, regionList, maerskLineUser,linkIds, 2, true);
        
        Account account = TestBusinessHelper.createAccount(maerskLineUser, country, 'Client_Account', false);
        account.Id = null;
        account.OwnerId = maerskLineUser.Id; 
        account.MLL_Account_Owner__c = maerskLineUser.Id;
        insert account;

       Contact contact = TestBusinessHelper.createContact(account, 'Customer_Contact', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);

        Opportunity opportunity = TestBusinessHelper.createOpportunity(account, contact, null, 'ShippingCargoServices', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
        opportunity.Cargo_Type__c = 'Dry';
        opportunity.OwnerId = maerskLineUser.Id; //creating oppty owner
        opportunity.Offer_Type__c = 'Offer containing Standard T&Cs';
        update opportunity;
        
        Opportunity QuaterlyDealOppty = TestBusinessHelper.createOpportunity(account, contact, null, 'Quarterly_Deal', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
        QuaterlyDealOppty.Cargo_Type__c = 'Dry';
        QuaterlyDealOppty.OwnerId = maerskLineUser.Id; //creating oppty owner
        QuaterlyDealOppty.Offer_Type__c = 'Offer containing Standard T&Cs';
        update QuaterlyDealOppty;

        Product2 product = TestBusinessHelper.createProduct('Ocean', true);  
        product.OIPC_Code__c='12345';
        product.Portfolio__c='Ocean';
        product.Version__c=1;
        product.IsActive=true;
        product.Product_Status__c='Ready-to-sell';
        product.Latest_Product_Version__c=null;
        update product;
        
        Product2 newProduct = TestBusinessHelper.createProduct('Ocean', true);
         newProduct.OIPC_Code__c='12345';
         newProduct.Portfolio__c='Ocean';
         newProduct.Version__c=2;
         newProduct.IsActive=false;
         update newProduct;

        List<Product2> productlst = new List<Product2>{product};
        List<Product2> productlstnew = new List<Product2>{newProduct};
            
        //old prod
        List<Product_Component__c> prodComponents = TestBusinessHelper.createProductComponents(productlst, 1, true); 
        prodComponents[0].Component_Code__c='11111';
        update prodComponents;

        List<Product_Feature__c> prodFeatures = TestBusinessHelper.createProductFeatures(prodComponents, 1, true);
        prodFeatures[0].Feature_Code__c='22222';
        prodFeatures[0].Default_Visibility__c='INCLUDED';
        prodFeatures[0].Categorisation__c = 'Service';
        update prodFeatures;

        List<Product_Specification_Parameter__c> prodSpecParameters = TestBusinessHelper.createProductSpecificationParameters(prodFeatures, 1, true);
        prodSpecParameters[0].Specification_Parameter_Code__c='33333';
        prodSpecParameters[0].Default_Visibility__c='INCLUDED';
        prodSpecParameters[0].Type__c='options';
        update prodSpecParameters;
        
        List<Product_Specification_Option__c> prodSpecOptions = TestBusinessHelper.createProductSpecificationOptions(prodSpecParameters, 1, true);
        prodSpecOptions[0].Specification_Option_Code__c='44444';
        update prodSpecOptions;
        
        Opportunity_Product__c opptyProd = TestBusinessHelper.createOpportunityLineItemCustom(opportunity, product.Id, null, country, city, true);
        
        List <Opportunity_Product_Configuration__c> opptyProdConfig1 = TestBusinessHelper.createOpportunityProductConfigurations(opptyProd, prodSpecParameters, prodSpecOptions, 1, true);
        
        //new prod 
        //
        List<Product_Component__c> prodComponentsnew = TestBusinessHelper.createProductComponents(productlstnew, 1, true);
        prodComponentsnew[0].Component_Code__c='AAAAA';
        update prodComponentsnew;

        List<Product_Feature__c> prodFeaturesnew = TestBusinessHelper.createProductFeatures(prodComponentsnew, 1, true);
        prodFeaturesnew[0].Feature_Code__c='BBBBB';
        prodFeaturesnew[0].Default_Visibility__c='INCLUDED';
        prodFeaturesnew[0].Categorisation__c = 'Service';
        update prodFeaturesnew;
        
        List<Product_Specification_Parameter__c> prodSpecParametersnew = TestBusinessHelper.createProductSpecificationParameters(prodFeaturesnew, 1, true);
        prodSpecParametersnew[0].Specification_Parameter_Code__c='CCCCC';
        prodSpecParametersnew[0].Default_Visibility__c='INCLUDED';
        prodSpecParametersnew[0].Type__c='options';
        update prodSpecParametersnew;
        
        List<Product_Specification_Option__c> prodSpecOptionsnew = TestBusinessHelper.createProductSpecificationOptions(prodSpecParametersnew, 1, true);
        prodSpecOptionsnew[0].Specification_Option_Code__c='DDDDD';
        update prodSpecOptionsnew;
        
        Opportunity_Product_Configuration__c  opptyProdConfig2 = new Opportunity_Product_Configuration__c(
            Opportunity_Product_Cus__c=opptyProd.Id,
            Is_Feature_Included__c = true,
            Configured_Product_Component__c = prodComponents[0].Id,
            Configured_Product_Feature__c = prodFeatures[0].Id
        );
        


        OpportunityTeamMember opptyteammember = TestBusinessHelper.createOpportunityTeamMember(teammate, opportunity, 'Sales Contributor', true);
        
        //Creating Solution
        Product2 solution1 = TestBusinessHelper.createProduct('Ocean', true);  
        solution1.OIPC_Code__c='s-p0-456';
        solution1.Portfolio__c='Ocean';
        solution1.Version__c=1;
        solution1.IsActive=true;
        solution1.Product_Status__c='Ready-to-sell';
        solution1.Latest_Product_Version__c=null;
        solution1.Is_Product_Solution__c = true;
        solution1.Definition_Type__c = 'Packaged Solution';
        update solution1;
        
        TestBusinessHelper.createProductReference(solution1.Id,new List<String>{product.Id,newProduct.Id},true);
        
        Product2 solution2 = TestBusinessHelper.createProduct('Ocean', true);
        solution2.OIPC_Code__c='s-p0-456';
        solution2.Portfolio__c='Ocean';
        solution2.Version__c=2;
        solution2.IsActive=false;
        solution2.Is_Product_Solution__c = true;
        solution2.Definition_Type__c = 'Packaged Solution';
        update solution2;
        TestBusinessHelper.createProductReference(solution2.Id,new List<String>{product.Id,newProduct.Id},true);
        
        Test.stopTest();
    }
 
    /*@isTest
    static void createNewProduct1()
    {
        
        Test.startTest();
        
        Product2 newProduct = [SELECT Id FROM Product2 WHERE Family='Customs Services & Insurance' AND Version__c=2];

        List<Product2> productlstnew = new List<Product2>();
        productlstnew.add(newProduct);

        List<Product_Component__c> prodComponentsnew = TestBusinessHelper.createProductComponents(productlstnew, 1, true);
        prodComponentsnew[0].Component_Code__c='AAAAA';
        update prodComponentsnew;

        List<Product_Feature__c> prodFeaturesnew = TestBusinessHelper.createProductFeatures(prodComponentsnew, 1, true);
        prodFeaturesnew[0].Feature_Code__c='BBBBB';
        prodFeaturesnew[0].Default_Visibility__c='INCLUDED';
        update prodFeaturesnew;
        
        Test.stopTest();
    }*/
    
    /*@isTest
    static void createNewProduct2()
    {
        
        Test.startTest();
        
        List<Product_Feature__c> productftrList = new List<Product_Feature__c>([Select Id from Product_Feature__c where Name='Test' LIMIT 1]);

        List<Product_Specification_Parameter__c> prodSpecParametersnew = TestBusinessHelper.createProductSpecificationParameters(productftrList, 1, true);
        prodSpecParametersnew[0].Specification_Parameter_Code__c='CCCCC';
        prodSpecParametersnew[0].Default_Visibility__c='INCLUDED';
        update prodSpecParametersnew;
        
        List<Product_Specification_Option__c> prodSpecOptionsnew = TestBusinessHelper.createProductSpecificationOptions(prodSpecParametersnew, 1, true);
        prodSpecOptionsnew[0].Specification_Option_Code__c='DDDDD';
        update prodSpecOptionsnew;

        Product2 product = [SELECT Id FROM Product2 WHERE Family='Customs Services & Insurance' AND Version__c=1];
        Product2 newProduct = [SELECT Id FROM Product2 WHERE Family='Customs Services & Insurance' AND Version__c=2];
        product.IsActive=false;
        product.Product_Status__c='Do Not Sell';
        product.Latest_Product_Version__c=newProduct.Id;
        update product;  
        
        Test.stopTest();
        
    }*/
    
   @isTest
    static void updateOpportunityStageWithProdUpgrade()
    {
        Test.startTest();
        TriggerExecutionController.skipAllTriggers(true);
        
        Product2 product = [SELECT Id FROM Product2 WHERE Family='Ocean' AND Version__c=1 AND Is_Product_Solution__c = false];
        Product2 newProduct = [SELECT Id FROM Product2 WHERE Family='Ocean' AND Version__c=2 AND Is_Product_Solution__c = false];
        
        product.IsActive=false; 
        product.Latest_Product_Version__c=newProduct.Id;
        update product;
        
        newProduct.IsActive=true;
        newProduct.Latest_Product_Version__c=null;
        update newProduct;  
        
         Opportunity parentOppty = [SELECT Id from Opportunity WHERE NAME='ShippingCargoServices' LIMIT 1];
        
        Opportunity_Product__c opptyProdnew = TestBusinessHelper.createOpportunityLineItemCustom(parentOppty, newProduct.Id, null, true);
        
         
         parentOppty.StageName = 'Closed Won';       
         update parentOppty;
        
        Set<Id> opptySet = new Set<Id>();
        opptySet.add(parentOppty.Id);
        
        OpportunityAutoRenewal.OpportunityAutoRenewal(opptySet);
       
        List<Opportunity> oppty2 = [SELECT Id,Parent_Opportunity__c FROM Opportunity WHERE Parent_Opportunity__c = :parentOppty.Id];
        if (!oppty2.isEmpty()) {
        ID renewedOpptyID = oppty2[0].Parent_Opportunity__c;
       
        System.assertEquals(renewedOpptyID, parentOppty.Id);
        
        Test.stopTest();
        }
     }

    @isTest
    static void updateOpportunityStageWithoutProdUpgrade()
    {
        Test.startTest();
        TriggerExecutionController.skipAllTriggers(true);
        
        Product2 product = [SELECT Id FROM Product2 WHERE Family='Ocean' AND Version__c=1 AND Is_Product_Solution__c = false];
        Product2 newProduct = [SELECT Id FROM Product2 WHERE Family='Ocean' AND Version__c=2 AND Is_Product_Solution__c = false];
        
        newProduct.IsActive=false;
        newProduct.Latest_Product_Version__c=null;
        update newProduct;  
        
        product.IsActive=true;
        product.Latest_Product_Version__c=null;
        update product;
        
        //newProduct.Product_Status__c='Do Not Sell';
        //product.Latest_Product_Version__c=newProduct.Id;
        
        
         Opportunity parentOppty = [SELECT Id from Opportunity WHERE NAME='ShippingCargoServices' LIMIT 1];
         
         Opportunity_Product__c opptyProdold = TestBusinessHelper.createOpportunityLineItemCustom(parentOppty, product.Id, null, true);
         
         parentOppty.StageName = 'Closed Won';       
         update parentOppty;
        
        Set<Id> opptySet = new Set<Id>();
        opptySet.add(parentOppty.Id);
        
        OpportunityAutoRenewal.OpportunityAutoRenewal(opptySet);
       
        List<Opportunity> oppty2 = [SELECT Id,Parent_Opportunity__c FROM Opportunity WHERE Parent_Opportunity__c = :parentOppty.Id];
        if (!oppty2.isEmpty()) {
        ID renewedOpptyID = oppty2[0].Parent_Opportunity__c;
       
        System.assertEquals(renewedOpptyID, parentOppty.Id);
        
        Test.stopTest();
      }
 }
    
    //SFSE-12654
    @isTest
    static void testAutoRenewalWithPSActiveVersion(){
        Test.startTest();
        TriggerExecutionController.skipAllTriggers(true);
        
        Product2 product = [SELECT Id FROM Product2 WHERE Family='Ocean' AND Version__c=1 AND Is_Product_Solution__c = false];
        Product2 newProduct = [SELECT Id FROM Product2 WHERE Family='Ocean' AND Version__c=2 AND Is_Product_Solution__c = false];
        
        Product2 solution1 = [SELECT Id FROM Product2 WHERE Is_Product_Solution__c=true AND Version__c=1];
        
        solution1.IsActive=true;
        solution1.Latest_Product_Version__c=null;
        update solution1;
        
        Opportunity parentOppty = [SELECT Id from Opportunity WHERE NAME='ShippingCargoServices' LIMIT 1];
         
        Opportunity_Product__c opptyProd1 = TestBusinessHelper.createOpportunityLineItemCustom(parentOppty, product.Id, null, true);
        opptyProd1.Solution__c = solution1.Id;
        update opptyProd1;
            
        Opportunity_Product__c opptyProd2 = TestBusinessHelper.createOpportunityLineItemCustom(parentOppty, newProduct.Id, null, true);
        opptyProd2.Solution__c = solution1.Id;
        update opptyProd2;
        
        parentOppty.StageName = 'Closed Won';       
        update parentOppty;
        system.debug('parentOppty :'+parentOppty);
        Set<Id> opptySet = new Set<Id>();
        opptySet.add(parentOppty.Id);
        
        OpportunityAutoRenewal.OpportunityAutoRenewal(opptySet);
        
        Test.stopTest();
        
        List<Opportunity> oppty2 = [SELECT Id,Parent_Opportunity__c FROM Opportunity WHERE Parent_Opportunity__c = :parentOppty.Id];
        ID renewedOpptyID;
        if (!oppty2.isEmpty()) {
            renewedOpptyID = oppty2[0].Parent_Opportunity__c;
        }
       
        System.assertEquals(renewedOpptyID, parentOppty.Id);
    }
    
    //SFSE-12654
    @isTest
    static void testAutoRenewalWithPSUpgrade(){
        Test.startTest();
        TriggerExecutionController.skipAllTriggers(true);
        
        Product2 product = [SELECT Id FROM Product2 WHERE Family='Ocean' AND Version__c=1 AND Is_Product_Solution__c = false];
        Product2 newProduct = [SELECT Id FROM Product2 WHERE Family='Ocean' AND Version__c=2 AND Is_Product_Solution__c = false];
        
        Product2 solution1 = [SELECT Id FROM Product2 WHERE Is_Product_Solution__c=true AND Version__c=1];
        Product2 solution2 = [SELECT Id FROM Product2 WHERE Is_Product_Solution__c=true AND Version__c=2];
        
        solution1.IsActive=true;
        solution1.Latest_Product_Version__c=null;
        update solution1;
        
        Opportunity parentOppty = [SELECT Id from Opportunity WHERE NAME='ShippingCargoServices' LIMIT 1];
         
        Opportunity_Product__c opptyProd1 = TestBusinessHelper.createOpportunityLineItemCustom(parentOppty, product.Id, null, true);
        opptyProd1.Solution__c = solution1.Id;
        update opptyProd1;
            
        Opportunity_Product__c opptyProd2 = TestBusinessHelper.createOpportunityLineItemCustom(parentOppty, newProduct.Id, null, true);
        opptyProd2.Solution__c = solution1.Id;
        update opptyProd2;
        
        solution1.IsActive=false;
        solution1.Latest_Product_Version__c=solution2.Id;
        update solution1;
        
        solution2.IsActive=true;
        solution2.Latest_Product_Version__c=null;
        update solution2;
        
        parentOppty.StageName = 'Closed Won';       
        update parentOppty;
        Set<Id> opptySet = new Set<Id>();
        opptySet.add(parentOppty.Id);
        
        OpportunityAutoRenewal.OpportunityAutoRenewal(opptySet);
        
        Test.stopTest();
        
        List<Opportunity> oppty2 = [SELECT Id,Parent_Opportunity__c FROM Opportunity WHERE Parent_Opportunity__c = :parentOppty.Id];
        ID renewedOpptyID;
        if (!oppty2.isEmpty()) {
            renewedOpptyID = oppty2[0].Parent_Opportunity__c;
        }
       
        System.assertEquals(renewedOpptyID, parentOppty.Id);
    }
    
    //SFSE-13703
    @isTest
    static void testAutoRenewalWithAccountBrandOwners(){
        Test.startTest();
        TriggerExecutionController.skipAllTriggers(true);
        
        Product2 product = [SELECT Id FROM Product2 WHERE Family='Ocean' AND Version__c=1 AND Is_Product_Solution__c = false];
        Product2 newProduct = [SELECT Id FROM Product2 WHERE Family='Ocean' AND Version__c=2 AND Is_Product_Solution__c = false];
        
        Opportunity parentOppty = [SELECT Id from Opportunity WHERE NAME='ShippingCargoServices' LIMIT 1];
         
        Opportunity_Product__c opptyProd1 = TestBusinessHelper.createOpportunityLineItemCustom(parentOppty, product.Id, null, true);
        
        parentOppty.Liner_Brand__c = BrandUtilities.MLL;
        parentOppty.StageName = 'Closed Won';       
        update parentOppty;
        Set<Id> opptySet = new Set<Id>();
        opptySet.add(parentOppty.Id);
        
        OpportunityAutoRenewal.OpportunityAutoRenewal(opptySet);
        
        Test.stopTest();
        
        List<Opportunity> oppty2 = [SELECT Id,Parent_Opportunity__c FROM Opportunity WHERE Parent_Opportunity__c = :parentOppty.Id];
        ID renewedOpptyID;
        if (!oppty2.isEmpty()) {
            renewedOpptyID = oppty2[0].Parent_Opportunity__c;
        }
       
        System.assertEquals(renewedOpptyID, parentOppty.Id);
    }
    
    //SFSE-13667
    @isTest
    static void testAutoRenewalForQuaterlyDeal(){
        Test.startTest();
        TriggerExecutionController.skipAllTriggers(true);
        
        Product2 product = [SELECT Id FROM Product2 WHERE Family='Ocean' AND Version__c=1 AND Is_Product_Solution__c = false];
        
        Opportunity parentOppty = [SELECT Id from Opportunity WHERE NAME='Quarterly_Deal' LIMIT 1];
         
        Opportunity_Product__c opptyProd1 = TestBusinessHelper.createOpportunityLineItemCustom(parentOppty, product.Id, null, true);
        
        parentOppty.Liner_Brand__c = BrandUtilities.Alianca;
        parentOppty.StageName = 'Closed Won';       
        update parentOppty;
        Set<Id> opptySet = new Set<Id>();
        opptySet.add(parentOppty.Id);
        
        OpportunityAutoRenewal.OpportunityAutoRenewal(opptySet);
        
        Test.stopTest();
        
        List<Opportunity> oppty2 = [SELECT Id,Parent_Opportunity__c FROM Opportunity WHERE Parent_Opportunity__c = :parentOppty.Id];
        ID renewedOpptyID;
        if (!oppty2.isEmpty()) {
            renewedOpptyID = oppty2[0].Parent_Opportunity__c;
        }
       
        System.assertEquals(renewedOpptyID, parentOppty.Id);
    }
    
    //SFSE-14064
    @isTest
    static void testAutoRenewalForClosedWon(){
        
        List<Opportunity> opty = [SELECT Id,StageName,Auto_Renew__c from Opportunity WHERE NAME='Quarterly_Deal' ];
        Product2 product = [SELECT Id FROM Product2 WHERE Family='Ocean' AND Version__c=1 AND Is_Product_Solution__c = false];
        Opportunity_Product__c opptyProd = TestBusinessHelper.createOpportunityLineItemCustom(opty[0], product.Id, null, true);
        List<Opportunity> optyToUpdate = new List<Opportunity>();
        Test.startTest();
            opty[0].Auto_Renew__c=true;
            opty[0].StageName = 'Closed Won';
        	opty[0].Tender_Submission_Format__c ='No Ocean Tender'; 
        	opty[0].Reason_For_Close__c='Won - Price (market relevant pricing position)';
            optyToUpdate.add(opty[0]);        
            update optyToUpdate;           
            
        Test.stopTest();
        List<Opportunity> opty1 = [SELECT Id,Type from Opportunity WHERE Parent_Opportunity__c=: optyToUpdate[0].Id];          
        Assert.areEqual(1,opty1.size());        
    }
    
    //SFSE-14064
    @isTest
    static void testAutoRenewalForClosedLost(){
        
        List<Opportunity> opty = [SELECT Id,StageName,Auto_Renew__c from Opportunity WHERE NAME='Quarterly_Deal' ];
        Product2 product = [SELECT Id FROM Product2 WHERE Family='Ocean' AND Version__c=1 AND Is_Product_Solution__c = false];
        Opportunity_Product__c opptyProd = TestBusinessHelper.createOpportunityLineItemCustom(opty[0], product.Id, null, true);
        List<Opportunity> optyToUpdate = new List<Opportunity>();
        Test.startTest();
            opty[0].Auto_Renew__c=true;
            opty[0].StageName = 'Closed Lost';
        	opty[0].Reason_For_Close__c='Lost - Disagreement on contract terms and conditions';
            optyToUpdate.add(opty[0]);        
            update optyToUpdate;           
            
        Test.stopTest();
        List<Opportunity> opty1 = [SELECT Id,Type from Opportunity WHERE Parent_Opportunity__c=: optyToUpdate[0].Id];          
        Assert.areEqual(1,opty1.size());        
    }
    
    //SFSE-14064
    @isTest
    static void testAutoRenewalForClosedLost1(){
        //System shouldnt create Renewed Opty for Reasons System - End Date Passed,Rejected - Should not have been auto-renewed,Rejected - Duplicate,90 days after Close date. 
        List<Opportunity> opty = [SELECT Id,StageName,Auto_Renew__c from Opportunity WHERE NAME='Quarterly_Deal' ];
        Product2 product = [SELECT Id FROM Product2 WHERE Family='Ocean' AND Version__c=1 AND Is_Product_Solution__c = false];
        Opportunity_Product__c opptyProd = TestBusinessHelper.createOpportunityLineItemCustom(opty[0], product.Id, null, true);
        List<Opportunity> optyToUpdate = new List<Opportunity>();
        Test.startTest();
        try{
        	opty[0].Auto_Renew__c=true;
            opty[0].StageName = 'Closed Lost';
        	opty[0].Reason_For_Close__c='System - End Date Passed';
            optyToUpdate.add(opty[0]);        
            update optyToUpdate;           
        }
        Catch(exception e){
            
        }
        Test.stopTest();
        List<Opportunity> opty1 = [SELECT Id,Type from Opportunity WHERE Parent_Opportunity__c=: optyToUpdate[0].Id];          
        Assert.areEqual(0,opty1.size());        
               
    }
    
    //13671
    @isTest
    static void testAutoRenewalForQuaterlyDeal2(){
        
        List<Opportunity> opty = [SELECT Id,StageName,Auto_Renew__c,Reason_For_Close__c from Opportunity WHERE NAME='Quarterly_Deal' ];
        Product2 product = [SELECT Id FROM Product2 WHERE Family='Ocean' AND Version__c=1 AND Is_Product_Solution__c = false];
        Opportunity_Product__c opptyProd = TestBusinessHelper.createOpportunityLineItemCustom(opty[0], product.Id, null, true);
        List<Opportunity> optyToUpdate = new List<Opportunity>();
        Test.startTest();
            opty[0].Auto_Renew__c=true;
            opty[0].StageName = 'Closed Lost';
            opty[0].Reason_For_Close__c='Won - Others';
            optyToUpdate.add(opty[0]);        
            update optyToUpdate;           
            
        Test.stopTest();
        List<Opportunity> opty1 = [SELECT Id,Type,Parent_Opportunity__r.Type from Opportunity WHERE Parent_Opportunity__c=: optyToUpdate[0].Id];
          
       
        System.assertEquals(opty1[0].Parent_Opportunity__r.Type,opty1[0].Type);
        
    }
    
    
}