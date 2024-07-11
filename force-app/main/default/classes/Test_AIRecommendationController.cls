@isTest
public class Test_AIRecommendationController{
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
        opportunity.StageName = 'Identifying';
        opportunity.Customer_Type__c = 'BCO';
        opportunity.Type = 'Acquisition';
        update opportunity;
        system.debug('opportunity==>'+opportunity);
        
        Opportunity QuaterlyDealOppty = TestBusinessHelper.createOpportunity(account, contact, null, 'Quarterly_Deal', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
        QuaterlyDealOppty.Cargo_Type__c = 'Dry';
        QuaterlyDealOppty.OwnerId = maerskLineUser.Id; //creating oppty owner
        QuaterlyDealOppty.Offer_Type__c = 'Offer containing Standard T&Cs';
        update QuaterlyDealOppty;

        Product2 product = TestBusinessHelper.createProduct('Ocean', true);  
        product.OIPC_Code__c='P-P0-dx1';
        product.Portfolio__c='Ocean';
        product.Version__c=1;
        product.IsActive=true;
        product.Product_Status__c='Ready-to-sell';
        product.Latest_Product_Version__c=null;
        update product;
        
        List<Product2> productlst = new List<Product2>{product};        
            
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
        OpportunityTeamMember opptyteammember = TestBusinessHelper.createOpportunityTeamMember(teammate, opportunity, 'Sales Contributor', true);
        
        
        //for opportunity 2
        Opportunity_Product__c opptyProd1 = TestBusinessHelper.createOpportunityLineItemCustom(QuaterlyDealOppty, product.Id, null, country, city, true);        
        List <Opportunity_Product_Configuration__c> opptyProdConfig_1 = TestBusinessHelper.createOpportunityProductConfigurations(opptyProd1, prodSpecParameters, prodSpecOptions, 1, true);
        OpportunityTeamMember opptyteammember1 = TestBusinessHelper.createOpportunityTeamMember(teammate, QuaterlyDealOppty, 'Sales Contributor', true);

        //create recommendation definition
        Recommendation_Definition__c recomDef = new Recommendation_Definition__c ();
        recomDef.Insight__c = 'To recommend IMCH product';
        recomDef.Recommended_Item_Reference__c = 'P-P0-dx1';
        recomDef.Is_User_Action_Mandatory__c = true;
        recomDef.Recommended_Item__c = 'Product';
        recomDef.IsActive__c = true;
        recomDef.Recommendation_Target__c = 'Opportunity';
        recomDef.Entry_Criteria__c = '1 AND 2 AND 3 AND 4 AND 5';
        insert recomDef;

        List<Recommendation_Condition__c> conditionList = new List<Recommendation_Condition__c>();
        Recommendation_Condition__c recomCondition = new Recommendation_Condition__c ();
        recomCondition.Condition__c = '=';
        recomCondition.Expected_Value__c = 'Identifying';
        recomCondition.Field_Name__c = 'StageName';
        recomCondition.Is_Related_To_Target_Object__c = false;
        recomCondition.IsActive__c = true;
        recomCondition.Object_Name__c = 'Opportunity';
        recomCondition.Recommendation_Definition__c = recomDef.Id;
        recomCondition.Rule_Number__c = 1;
        conditionList.add(recomCondition);

        Recommendation_Condition__c recomCondition1 = new Recommendation_Condition__c ();
        recomCondition1.Condition__c = '=';
        recomCondition1.Expected_Value__c = 'BCO';
        recomCondition1.Field_Name__c = 'Customer_Type__c';
        recomCondition1.Is_Related_To_Target_Object__c = false;
        recomCondition1.IsActive__c = true;
        recomCondition1.Object_Name__c = 'Opportunity';
        recomCondition1.Recommendation_Definition__c = recomDef.Id;
        recomCondition1.Rule_Number__c = 2;
        conditionList.add(recomCondition1);

        Recommendation_Condition__c recomCondition2 = new Recommendation_Condition__c ();
        recomCondition2.Condition__c = '=';
        recomCondition2.Expected_Value__c = 'Acquisition';
        recomCondition2.Field_Name__c = 'Type';
        recomCondition2.Is_Related_To_Target_Object__c = false;
        recomCondition2.IsActive__c = true;
        recomCondition2.Object_Name__c = 'Opportunity';
        recomCondition2.Recommendation_Definition__c = recomDef.Id;
        recomCondition2.Rule_Number__c = 3;
        conditionList.add(recomCondition2);

        Recommendation_Condition__c recomCondition3 = new Recommendation_Condition__c ();
        recomCondition3.Condition__c = 'in';
        recomCondition3.Expected_Value__c = 'P-P0-dx1,78912';
        recomCondition3.Field_Name__c = 'OIPC_Product_Code__c';
        recomCondition3.Is_Related_To_Target_Object__c = true;
        recomCondition3.IsActive__c = true;
        recomCondition3.Object_Name__c = 'Opportunity_Product__c';
        recomCondition3.Recommendation_Definition__c = recomDef.Id;
        recomCondition3.Number_of_Related_Records__c = 'Any';
        recomCondition3.Related_Field_Name__c ='OpportunityId__c';
        recomCondition3.Rule_Number__c = 4;
        conditionList.add(recomCondition3);

        Recommendation_Condition__c recomCondition4 = new Recommendation_Condition__c ();
        recomCondition4.Condition__c = '<>';
        recomCondition4.Expected_Value__c = 'P-P0-20jb';
        recomCondition4.Field_Name__c = 'OIPC_Product_Code__c';
        recomCondition4.Is_Related_To_Target_Object__c = true;
        recomCondition4.IsActive__c = true;
        recomCondition4.Object_Name__c = 'Opportunity_Product__c';
        recomCondition4.Recommendation_Definition__c = recomDef.Id;
        recomCondition4.Number_of_Related_Records__c = 'Any';
        recomCondition4.Related_Field_Name__c ='OpportunityId__c';
        recomCondition4.Rule_Number__c = 5;
        conditionList.add(recomCondition4);
        insert conditionList;

        List<Recommendation_Action__c> recomActionList = new List<Recommendation_Action__c>();
        Recommendation_Action__c recomAction = new Recommendation_Action__c();
        recomAction.Action__c = 'Accept';
        recomAction.Action_Component__c = 'selectProduct';
        recomAction.Action_Type__c = 'LWC';
        recomAction.Name = 'Accept Action';
        recomAction.Order__c = 1;
        recomAction.Recommendation_Definition__c = recomDef.Id;        
        recomActionList.add(recomAction);

        Recommendation_Action__c recomAction1 = new Recommendation_Action__c();
        recomAction1.Action__c = 'Reject';
        recomAction1.Action_Component__c = 'showRejectionReason';
        recomAction1.Action_Type__c = 'LWC';
        recomAction1.Name = 'Reject Action';
        recomAction1.Order__c = 1;
        recomAction1.Recommendation_Definition__c = recomDef.Id;
        recomAction1.Rejection_Reason__c = 'Has its own service,Has Vendor,Not this product decision-maker,Interested but the price is high';
        recomActionList.add(recomAction1);
        insert recomActionList;
        
        
        Opportunity opportunity1 = TestBusinessHelper.createOpportunity(account, contact, null, 'ShippingCargoServices', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
        opportunity1.Cargo_Type__c = 'Dry';
        opportunity1.OwnerId = maerskLineUser.Id; //creating oppty owner
        opportunity1.Offer_Type__c = 'Offer containing Standard T&Cs';
        opportunity1.StageName = 'Identifying';
        opportunity1.Customer_Type__c = 'BCO';
        opportunity1.Type = 'Additional Business';
        update opportunity1;
        
        Test.stopTest();
    }

    @isTest
    public static void testOppRecommendation(){
        Test.startTest();
        Opportunity oppTest = [Select id from Opportunity where Customer_Type__c = 'BCO' and Type = 'Acquisition' limit 1];
        AIRecommendationController.getRecommendations(oppTest.Id,'Opportunity');

        List<Opportunity_Product__c> oppProd = [SELECT id from Opportunity_Product__c where OpportunityId__c=:oppTest.Id];
        delete oppProd;
        
        Recommendation__c testRecom = [SELECT id,Is_valid__c from Recommendation__c where Recommended_To__c =: oppTest.Id limit 1];
        Assert.areEqual(testRecom.Is_valid__c, false);
        
        Test.stopTest();
    }

    @isTest
    public static void testOppRecommendation_Save(){
        Test.startTest();
        Opportunity oppTest = [Select id from Opportunity where Customer_Type__c = 'BCO' and Type = 'Acquisition' limit 1];
        List<AIRecommendationController.RecommendationWrapper> wrapperList =  AIRecommendationController.getRecommendations(oppTest.Id,'Opportunity');
        Recommendation__c recom = new Recommendation__c();
        for (AIRecommendationController.RecommendationWrapper wrap : wrapperList){
            wrap.recommendationRecord.Status__c = 'Accepted';
            recom = wrap.recommendationRecord;            
        }      
        
        AIRecommendationController.saveRecommendations(JSON.Serialize(recom));
        
        Recommendation__c testRecom = [SELECT id,Status__c from Recommendation__c where Recommended_To__c =: oppTest.Id limit 1];
        Assert.areEqual(testRecom.Status__c, 'Accepted');
        
        Test.stopTest();
    }

    @isTest
    public static void testOppRecommendation_AlreadyExist(){   
        
        Test.startTest(); 
        System.runAs ( new User(Id = UserInfo.getUserId()) ) { 
            PermissionSet ps = [SELECT Id 
                    FROM PermissionSet 
                    WHERE Name = 'Recommendation_Component_Access'];
            try{
                PermissionSetAssignment UserAssignment = [SELECT id from PermissionSetAssignment  where AssigneeId =: UserInfo.getUserId() and PermissionSetId =: ps.Id limit 1];
            }catch(Exception e){
                PermissionSetAssignment pSA = new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = ps.Id);
                insert pSA;    
            }
        }
        Opportunity oppTest = [Select id from Opportunity where Customer_Type__c = 'BCO' and Type = 'Acquisition'  limit 1];
        
        AIRecommendationController.getRecommendations(oppTest.Id,'Opportunity');
        AIRecommendationController.getRecommendations(oppTest.Id,'Opportunity');
        try{
            oppTest.stageName = 'Closed Won';
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
                update oppTest;
            }
        } catch( exception e){
            String message = e.getMessage();
            system.debug('message==>'+message);
            Assert.areEqual(message.contains(Label.Recommendation_Error_Message), true);
        }

        oppTest.stageName = 'Identifying';
        oppTest.Customer_Type__c = 'Freight Forwarder';
        oppTest.Type = 'Renewal';
        update oppTest;
        
        Test.stopTest();
    }
    
    @isTest
    public static void testOppRecommendationCondition(){
         
        //create recommendation definition
        Recommendation_Definition__c recomDef1 = new Recommendation_Definition__c ();
        recomDef1.Insight__c = 'To recommend IMCH product';
        recomDef1.Recommended_Item_Reference__c = 'P-P0-dx1';
        recomDef1.Is_User_Action_Mandatory__c = true;
        recomDef1.Recommended_Item__c = 'Product';
        recomDef1.IsActive__c = true;
        recomDef1.Recommendation_Target__c = 'Opportunity';
        recomDef1.Entry_Criteria__c = '6 and 7 and 8 and 9 and 10';
        insert recomDef1;

        List<Recommendation_Condition__c> conditionList1 = new List<Recommendation_Condition__c>();
        Recommendation_Condition__c recomCondition5 = new Recommendation_Condition__c ();
        recomCondition5.Condition__c = '=';
        recomCondition5.Expected_Value__c = '2028-03-31';
        recomCondition5.Field_Name__c = 'CloseDate';
        recomCondition5.Is_Related_To_Target_Object__c = false;
        recomCondition5.IsActive__c = true;
        recomCondition5.Object_Name__c = 'Opportunity';
        recomCondition5.Recommendation_Definition__c = recomDef1.Id;
        recomCondition5.Rule_Number__c = 6;
        conditionList1.add(recomCondition5);
        
        Recommendation_Condition__c recomCondition6 = new Recommendation_Condition__c ();
        recomCondition6.Condition__c = '=';
        recomCondition6.Expected_Value__c = '2025-02-27T00:44:07.000+0000';
        recomCondition6.Field_Name__c = 'Sales_Qualified_Date__c';
        recomCondition6.Is_Related_To_Target_Object__c = false;
        recomCondition6.IsActive__c = true;
        recomCondition6.Object_Name__c = 'Opportunity';
        recomCondition6.Recommendation_Definition__c = recomDef1.Id;
        recomCondition6.Rule_Number__c = 7;
        conditionList1.add(recomCondition6);
        
        Recommendation_Condition__c recomCondition7 = new Recommendation_Condition__c ();
        recomCondition7.Condition__c = '=';
        recomCondition7.Expected_Value__c = '123.00';
        recomCondition7.Field_Name__c = 'Actual__c';
        recomCondition7.Is_Related_To_Target_Object__c = false;
        recomCondition7.IsActive__c = true;
        recomCondition7.Object_Name__c = 'Opportunity';
        recomCondition7.Recommendation_Definition__c = recomDef1.Id;
        recomCondition7.Rule_Number__c = 8;
        conditionList1.add(recomCondition7);         
        
        Recommendation_Condition__c recomCondition8 = new Recommendation_Condition__c ();
        recomCondition8.Condition__c = '=';
        recomCondition8.Expected_Value__c = '39';
        recomCondition8.Field_Name__c = 'Probability';
        recomCondition8.Is_Related_To_Target_Object__c = false;
        recomCondition8.IsActive__c = true;
        recomCondition8.Object_Name__c = 'Opportunity';
        recomCondition8.Recommendation_Definition__c = recomDef1.Id;
        recomCondition8.Rule_Number__c = 9;
        conditionList1.add(recomCondition8);
        
        Recommendation_Condition__c recomCondition9 = new Recommendation_Condition__c ();
        recomCondition9.Condition__c = '=';
        recomCondition9.Expected_Value__c = '89';
        recomCondition9.Field_Name__c = 'IqScore';
        recomCondition9.Is_Related_To_Target_Object__c = false;
        recomCondition9.IsActive__c = true;
        recomCondition9.Object_Name__c = 'Opportunity';
        recomCondition9.Recommendation_Definition__c = recomDef1.Id;
        recomCondition9.Rule_Number__c = 10;
        conditionList1.add(recomCondition9); 
        
        insert conditionList1;
        
        Test.startTest();
        Opportunity oppTest = [Select id from Opportunity where Customer_Type__c = 'BCO' limit 1];
        AIRecommendationController.getRecommendations(oppTest.Id,'Opportunity');
        Recommendation__c testRecom = [SELECT id,Is_valid__c from Recommendation__c where Recommended_To__c =: oppTest.Id limit 1];
        Assert.areEqual(testRecom <> null?true:false, true);
        Test.stopTest();
        
    }
    
    @isTest
    public static void ClosedLostProductCondition(){
        
        Recommendation_Definition__c  recomDef = [Select id,Entry_Criteria__c from Recommendation_Definition__c limit 1];
    
        Recommendation_Condition__c recomCondition4 = new Recommendation_Condition__c ();
        recomCondition4.Condition__c = '=';
        recomCondition4.Expected_Value__c = 'P-P0-20jb';
        recomCondition4.Field_Name__c = 'Lost_Product_Parent_Opportunity__c';
        recomCondition4.Is_Related_To_Target_Object__c = true;
        recomCondition4.IsActive__c = true;
        recomCondition4.Object_Name__c = 'Opportunity';
        recomCondition4.Recommendation_Definition__c = recomDef.Id;
        recomCondition4.Number_of_Related_Records__c = 'Any';
        recomCondition4.Related_Field_Name__c ='Lost_Product_Parent_Opportunity__c';
        recomCondition4.Rule_Number__c = 6;        
        insert recomCondition4;
        
        recomDef.Entry_Criteria__c = '1 AND 2 AND 3 AND 4 AND 5 AND 6';
        update recomDef;
         
        Opportunity oppTest = [Select id,Lost_Product_Parent_Opportunity__c  from Opportunity where Customer_Type__c = 'BCO' and Type = 'Additional Business' limit 1];     
        Geography__c country = [Select id from Geography__c where Type_Of_Location__c = 'Country' limit 1]; 
        //TestBusinessHelper.createGeography('United States', 'Country', null, true);
        Geography__c city = [Select id from Geography__c where Type_Of_Location__c = 'City' limit 1]; 
        //TestBusinessHelper.createGeography('Colorado', 'City', country.Id, true); 
        Product_Component__c prodComponents =  [SELECT id from Product_Component__c limit 1];
        Product_Feature__c prodFeatures =  [SELECT id from Product_Feature__c limit 1];
        
        Product2 newProduct = TestBusinessHelper.createProduct('Ocean', true);
        newProduct.OIPC_Code__c='P-P0-20jb';
        newProduct.Portfolio__c='Ocean';
        newProduct.Version__c=1;
        newProduct.Product_Status__c='Ready-to-sell';
        newProduct.IsActive=true;
        newProduct.Latest_Product_Version__c=null;
        update newProduct;
        List<Product2> productlstnew = new List<Product2>{newProduct};
        //new prod 
        Opportunity_Product__c opptyProd = TestBusinessHelper.createOpportunityLineItemCustom(oppTest, newProduct.Id, null, country, city, true);
        
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
            Configured_Product_Component__c = prodComponents.Id,
            Configured_Product_Feature__c = prodFeatures.Id
        );
        
        Test.startTest();
        
        Opportunity oppTest1 = [Select id from Opportunity where Customer_Type__c = 'BCO' and Type = 'Acquisition' limit 1]; 
        oppTest.Lost_Product_Parent_Opportunity__c  = oppTest1.Id;
        Update oppTest;
        
        //Opportunity_Product__c oppProd = [SELECT id from Opportunity_Product__c where OIPC_Product_Code__c='P-P0-dx1' limit 1];
        //AddOpptyProductsCntrl.cloneAsClosedLostOptyproduct(oppTest.Id, oppProd.Id,'Rejected - Asset/resource/tech investment limitation');
        AIRecommendationController.getRecommendations(oppTest1.Id,'Opportunity');
        
        List<Recommendation__c> testRecom = [SELECT id,Is_valid__c from Recommendation__c where Recommended_To__c =: oppTest1.Id];
        Assert.areEqual(testRecom.size() , 0);        
        Test.stopTest();
    }
    
    
    @isTest
    public static void testOppRecommendation_Rejected_Save(){
        Test.startTest();
        Opportunity oppTest = [Select id,accountId from Opportunity where Customer_Type__c = 'BCO' and Type = 'Acquisition' limit 1];
        List<AIRecommendationController.RecommendationWrapper> wrapperList =  AIRecommendationController.getRecommendations(oppTest.Id,'Opportunity');
        Recommendation__c recom = new Recommendation__c();
        for (AIRecommendationController.RecommendationWrapper wrap : wrapperList){
            wrap.recommendationRecord.Status__c = 'Rejected';
            wrap.recommendationRecord.Rejection_Reason__c = 'Customer has its own service';
            recom = wrap.recommendationRecord;            
        }      
        
        AIRecommendationController.saveRecommendations(JSON.Serialize(recom));
        
        Recommendation__c testRecom = [SELECT id,Status__c,Rejection_Reason__c,lastmodifieddate from Recommendation__c where Recommended_To__c =: oppTest.Id limit 1];
        Assert.areEqual(testRecom.Status__c, 'Rejected');
        
        Recommendation_Definition__c[] recomDef_old = [SELECT id,Recommended_Item__c,Recommended_Item_Reference__c ,Prerequisite__c from Recommendation_Definition__c];
        system.debug('recomDef_old ==>'+recomDef_old);
        recomDef_old[0].Recommended_Item_Reference__c = 'P-P0-20jb';
        recomDef_old[0].Prerequisite__c = 'Check History of Recommendation based on Account';
        update recomDef_old;
        
        Opportunity opp2 = [select id,StageName,Customer_Type__c,Type from opportunity where id !=: oppTest.Id and accountid=:oppTest.accountId  limit 1];
        opp2.StageName = 'Identifying';
        opp2.Customer_Type__c = 'BCO';
        opp2.Type = 'Acquisition';
        update opp2;
        
        List<AIRecommendationController.RecommendationWrapper> wrapperList_1 =  AIRecommendationController.getRecommendations(opp2.Id,'Opportunity');
        
        Test.stopTest();
    }
    
    @isTest
    public static void testOppRecommendation_ClosedLost(){
        Test.startTest();
            Opportunity oppTest = [Select id,StageName from Opportunity where Customer_Type__c = 'BCO' and Type = 'Acquisition' limit 1];
            system.debug('oppTest ==>'+oppTest );
            List<AIRecommendationController.RecommendationWrapper> wrapperList =  AIRecommendationController.getRecommendations(oppTest.Id,'Opportunity');   
            oppTest.StageName = 'Closed Lost';  
            oppTest.Reason_For_Close__c='Lost - Uncompetitive price';
            Update oppTest; 
        Test.stopTest();
        Recommendation__c testRecom = [SELECT id,Status__c from Recommendation__c where Recommended_To__c =: oppTest.Id limit 1];
        Assert.areEqual(testRecom.Status__c, 'Obselete - Lost Opportunity');
    }
            
}