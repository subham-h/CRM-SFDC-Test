/*
Date            Story       Developer       Description
30-May-2022     SFSE-8443   Meghana         Code Created
14-July-2022    SFSE-8853   Vazid            Passing OLI Id instead of Null in getComponentsAndFeatures method call.
09-Sept-2022    SFSE-9146    Vazid            Added getTotalFeatureNumber and deleteRecord methods
12-Oct- 2022    SFSE-9330   Shilpa          Added Feedback Category field in feedback instance.
08-Dec-2022        SFSE-9819    Vazid            Added cloneAsClosedLostOptyproduct and getClosedLostPicklistValues methods                                            
10-Oct-2023    SFSE-11504   Bharti         Removed the reference of 'TempBatchToPopulateTotalRequiredFeature' batch from 'TestBatchToPulateTotalRequiredFeature' method.
10-NOV-2023     SFSE-12881  Shashi@Maersk   Added test method for checkOpptyProdCloneEligibility()
03-Mar-2023     SFSE-14236      03-Mar-2024     Sunil.bs@maersk.com   To cover set Default Gp and default revenue values for new price book entry
02-Apr-2024		SFSE-13634	Jothsana@Maersk	Added testmethod for default revenue and GP values country level for opportunity products added 
*/

 

@isTest
private class AddOpptyProductsCntrl_Test {

    @testSetup static void setup() {
        TriggerExecutionController.skipAllTriggers(true);
        
        Geography__c geoCountry = TestBusinessHelper.createGeography('United States', 'Country', null, true);
        Geography__c geoState = TestBusinessHelper.createGeography('Arizona', 'State', geoCountry.Id, true);
        //user user1 = TestBusinessHelper.createUser('Sales', 'Seago', true);
        
		BDA__c uSParentBDA = TestBusinessHelper.createBDA('North America Region', 'Trade Region', 'NAM', null, UserInfo.getUserId(), true);
        BDA__c uSChildBDA = TestBusinessHelper.createBDA('North America Area', 'Cluster', 'NOA', uSParentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c uSBdaGeo = TestBusinessHelper.createBDAGeography(uSChildBDA.Id, geoCountry.Id, null, true);
        
        Segmentation_Matrix__c USsgm = TestBusinessHelper.createSegmentationMatrix(uSParentBDA.Id, uSChildBDA.Id, geoCountry.Id, true);
        
        Account ClientAccount = TestBusinessHelper.createAccount(null, geoCountry, 'Client_Account', true);
        Contact cont = TestBusinessHelper.createContact(ClientAccount, 'Customer_Contact','MaerskLine', true);
        //Account clientAccount = TestBusinessHelper.createAccount('Client_Account', true);
        Opportunity tenderOpportunity = TestBusinessHelper.createOpportunity(ClientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        tenderOpportunity.Pricebook2Id = Test.getStandardPricebookId();
        update tenderOpportunity;
       // Opportunity mslOppty = TestBusinessHelper.createOpportunity(ClientAccount, cont, user1,'Supply_Chain_Services','MaerskLine', true);
        List<String> operators = new List<String>{'MCC','MSL','SAF'};//new List<String>{BrandUtilities.MCC}
        //List<Trade_Route__c> lstTDR = TestBusinessHelper.createTradeRoutes(operators, 2, true);
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;

        List<String> lstProdFamily = new List<String>{'Ocean','Air','LCL'};
        List<Product2> lstProd = new List<Product2>();
        lstProd = TestBusinessHelper.createProducts(lstProdFamily,3,true);
        lstProd[0].Definition_Type__c = 'Product';
        lstProd[0].Portfolio__c = 'Ocean';
        lstProd[1].Definition_Type__c = 'Product';
        lstProd[1].Portfolio__c = 'LnS';
        update lstProd;
        
		PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = lstProd[0].Id,
            UnitPrice = 10,
            Default_Revenue_per_Unit__c = 10,
            Default_GP_Margin__c = 50,
            IsActive = true
        );
        Insert pbe;
        
       Segment_Data__c sgdata = TestBusinessHelper.createSegmentaData(lstProd[0].id, USsgm.Id, true);
        
       List<Product_Component__c> comps =  new List<Product_Component__c>();
        for (integer i = 0; i < 4; i++){
            Product_Component__c pc = new Product_Component__c();
            pc.Name = 'Comp' + i;
            pc.Component_Code__c = 'PC' + i;
          	pc.Product__c = lstProd[0].Id;
            pc.Display_Order__c = i;
            comps.add(pc);
        }
        insert comps;
        
        List<Product_Feature__c> lstfeat = new List<Product_Feature__c>();
        
        for (integer i = 0; i < 4; i++){
            
            Product_Feature__c f = new Product_Feature__c();
            f.Name = 'Feature' + i;
            f.Feature_Code__c = 'F' + i;
            f.Product_Component__c = comps[i].Id;
            f.Categorisation__c = 'Service';
            if(i==0){
             	f.Default_Visibility__c = 'INCLUDED';
                f.Configurable_at_Contracting__c  = false;
            }else if(i == 1){
                f.Default_Visibility__c = 'INCLUDED';
                f.Configurable_at_Contracting__c  = true;
            }else if(i == 2){
                f.Default_Visibility__c = 'NOT_INCLUDED';
            	f.Configurable_at_Contracting__c  = false;
            }else{
                f.Default_Visibility__c = 'NOT_INCLUDED';
            	f.Configurable_at_Contracting__c  = true;
            }
            
            f.Display_Order__c = i;
            f.Description__c = 'Feature description ';           
            lstfeat.add(f);
        }

        insert lstfeat;

        List<Product_Specification_Parameter__c> lstparameter = new List<Product_Specification_Parameter__c>();

        for(integer i=0;i<4;i++){
            Product_Specification_Parameter__c para = new Product_Specification_Parameter__c();
            para.Name = 'paramter' + i;
            para.Specification_Parameter_Code__c = 'SP' + i;
            para.Product_Feature__c = lstfeat[i].Id;
            para.Display_Order__c = i;
            para.Sales_Configurable__c= true;
            para.Is_Mandatory__c = true;
            para.type__c='options';
            if(i==0){
             	para.Default_Visibility__c = 'INCLUDED';
                para.Configurable_at_Contracting__c  = false;
                para.Specification_Parameter_Code__c = 'SP' + i;
               	para.Allow_Multiselect__c = true;
            }else if(i == 1){
                para.Default_Visibility__c = 'INCLUDED';
                para.Configurable_at_Contracting__c  = true;
                para.Specification_Parameter_Code__c = 'SP' + i;
            }else if(i == 2){
                para.Default_Visibility__c = 'NOT_INCLUDED';
            	para.Configurable_at_Contracting__c  = false;
                para.Specification_Parameter_Code__c = 'SP' + i;
            }else if(i == 3){
                para.Default_Visibility__c = 'NOT_INCLUDED';
            	para.Configurable_at_Contracting__c  = true;
                para.Specification_Parameter_Code__c = 'SP' + i;
                para.Allow_Multiselect__c = true;
            }
            para.Description__c = 'Parameter description ';  
            lstparameter.add(para);
        }
        insert lstparameter;

        List<Product_Specification_Option__c> lstoption = new List<Product_Specification_Option__c>();

        for(integer i=0;i<4;i++){
            Product_Specification_Option__c opt = new Product_Specification_Option__c();
            opt.Name = 'option' + i;
            opt.Specification_Option_Name__c = 'option' + i;
            opt.Specification_Option_Code__c = 'SPC' + i;
            opt.Product_Specification_Parameter__c = lstparameter[i].Id;
            opt.Display_Order__c = i;
            opt.Description__c = 'option description ';  
            lstoption.add(opt);
        }
        insert lstoption;
		
        
        
     
        Test.startTest();
        //List<PriceBookEntry> pbEntry = [select Id from PriceBookEntry];
        
        Opportunity_Product__c Oli1 = TestBusinessHelper.createOpportunityLineItemCustom(tenderOpportunity, lstProd[0].id, null, geoCountry, geoState, true);
        Opportunity_Product__c Oli2 = TestBusinessHelper.createOpportunityLineItemCustom(tenderOpportunity, lstProd[1].id, null, geoCountry, geoState, true);
        
        Test.stopTest();
        
        List<Opportunity_Product_Configuration__c> lstconfig= new list<Opportunity_Product_Configuration__c>();
        for(integer i=0;i<4;i++){
            Opportunity_Product_Configuration__c config= new Opportunity_Product_Configuration__c();
            config.Opportunity_Product_Cus__c = Oli1.id;
            if(i==0 || i==2){
                 config.Product_Specification_Option__c = lstoption[i].id;
            }else{
                 
            }
            config.Is_Feature_Included__c = true;
            config.Is_Specification_Parameter_Included__c = true;
            config.Configured_Product_Feature__c = lstfeat[i].id;
            config.Configured_Product_Component__c = comps[i].id;
            config.Product_Specificaiton_Parameter__c = lstparameter[i].id;
            config.name='test'+i;
            lstconfig.add(config);
        }
      
       
        Opportunity_Product_Configuration__c config= new Opportunity_Product_Configuration__c();
        config.Is_Feature_Included__c = true;
        config.Opportunity_Product_Cus__c = Oli1.id;
        config.Configured_Product_Feature__c = lstfeat[0].id;
        config.Configured_Product_Component__c = comps[0].id;
        config.name='test'+5;
        lstconfig.add(config);
        Opportunity_Product_Configuration__c config1= new Opportunity_Product_Configuration__c();
        config1.Is_Feature_Included__c = true;
        config1.Opportunity_Product_Cus__c = Oli1.id;
        config1.Configured_Product_Feature__c = lstfeat[1].id;
        config1.Configured_Product_Component__c = comps[1].id;
        config1.name='test'+6;
        lstconfig.add(config1);
        Opportunity_Product_Configuration__c config2= new Opportunity_Product_Configuration__c();
        config2.Is_Feature_Included__c = true;
        config2.Opportunity_Product_Cus__c = Oli1.id;
        config2.Configured_Product_Feature__c = lstfeat[2].id;
        config2.Configured_Product_Component__c = comps[2].id;
        config2.name='test'+7;
        
        Opportunity_Product_Configuration__c config3= new Opportunity_Product_Configuration__c();
        config3.Is_Feature_Included__c = true;
        config3.Is_Specification_Parameter_Included__c = false;
        config3.Opportunity_Product_Cus__c = Oli1.id;
        config3.Configured_Product_Feature__c = lstfeat[1].id;
        config3.Configured_Product_Component__c = comps[1].id;
        config3.Product_Specificaiton_Parameter__c = lstparameter[1].id;
        config3.name='test'+7;
    
        lstconfig.add(config3);
        
        
  		insert lstconfig;
        TriggerExecutionController.skipAllTriggers(false);
        //insert (DataGeneratorHelper_OIPC.createOpptyFeatures(Oli1.Id, featureIds));

    }
   

    static testmethod void TestOpptyLineItem(){  
       // TriggerExecutionController.skipAllTriggers(true);
        
         TriggerExecutionController.skipAllTriggers(true);
        Geography__c geoCountry = TestBusinessHelper.createGeography('United States', 'Country', null, true);
        Geography__c geoState = TestBusinessHelper.createGeography('Arizona', 'State', geoCountry.Id, true);
        List<Opportunity> oppList = [SELECT Id FROM Opportunity LIMIT 1];
        oppList[0].Opportunity_contains_Dangerous_Goods__c = 'NO';
        update oppList;

      
        List<Opportunity_Product__c> oli = [SELECT Id ,Country__c,product2id__c FROM Opportunity_Product__c where OpportunityId__c in: oppList limit 1 ];
        List<Product2> prodlist = [Select id,name from Product2 limit 1];
        List<Id> prodids = new list<Id>();
        for(Product2 p : prodlist){
            prodids.add(p.id);
        }  
		//Test.startTest();
        System.debug('oppList' + oppList);
        Map<Id, Product2> prodMap = new Map<Id, Product2>([SELECT Id FROM Product2 WHERE isActive = true limit 1]);
       // List<Opportunity_Product__c> oli = [SELECT Id ,Country__c FROM Opportunity_Product__c where OpportunityId__c in: oppList ];
        List<Product_Specification_Option__c> option = [Select id,name from Product_Specification_Option__c limit 1];
        List<Product_Component__c> componenet = [SELECT Id, Name, Component_Code__c, Product__c from Product_Component__c where Product__c In :prodids limit 1];
        List<Product_Feature__c> feature = [SELECT Id, Name,Product_Component__c, Type__c, Value__c    , Default_Value__c, Options__c, Allow_Multiselect__c, Description__c,
                                                                                 Allow_None_Value__c, Value_Min__c, Value_Max__c, Value_Unit__c, Product_Component__r.Product__c, Choice_Required__c
         ,Default_Visibility__c,Configurable_at_Contracting__c from Product_Feature__c where Product_Component__c =:componenet[0].id limit 1];
      
        List<Product_Specification_Parameter__c> specification = [SELECT Id, Name, Specification_Parameter_Code__c, Product_Feature__c, Type__c,Configurable_at_Contracting__c, Allow_Multiselect__c, Is_Mandatory__c,Product_Feature__r.name from Product_Specification_Parameter__c limit 1];
       
        System.debug('oli' + oli);
        List<Opportunity_Product_Configuration__c> config = [Select id,name from Opportunity_Product_Configuration__c limit 1];
        Map<String, Opportunity_Product__c> mapOLI = new Map<String, Opportunity_Product__c> ();
        Map<String, Feedback__c> feedbackMap = new Map<String, Feedback__c>();
        for (Opportunity_Product__c rec : oli){
            mapOLI.put(rec.Id, rec);
            feedbackMap.put(rec.Id, new Feedback__c(Description__c = 'missing features',Feedback_Category__c = 'Other'));
        }
       	
      	//System.debug('test 112 '+ [Select id, name,(Select ID, Product2Id, UnitPrice FROM PricebookEntries where Pricebook2Id=:Test.getStandardPricebookId()) from Product2]);
         AddOpptyProductsCntrl.getRecords(oppList[0].Id);
         AddOpptyProductsCntrl.getComponentsAndFeatures(prodids,oli[0].id,'Productkey',false,false, false);
         AddOpptyProductsCntrl.getProducts(oppList[0].Id, false, oli[0].id, false);
         AddOpptyProductsCntrl.getProducts(oppList[0].Id, true, oli[0].Id, false);
         AddOpptyProductsCntrl.getProducts(oppList[0].Id, true, oli[0].Id, true);
         AddOpptyProductsCntrl.getComponentsAndFeatures(new list<Id>(prodMap.keySet()), oli[0].Id, null,false,false, false);
         AddOpptyProductsCntrl.getComponentsAndFeatures(new list<Id>(prodMap.keySet()), null, oli[0].product2id__c,false,false, false);
         AddOpptyProductsCntrl.responseWrapper r = AddOpptyProductsCntrl.getComponentsAndFeatures(new list<Id>(prodMap.keySet()), oli[0].id, oli[0].id,false,false, false);
         AddOpptyProductsCntrl.responseWrapper r1 = AddOpptyProductsCntrl.getComponentsAndFeatures(new list<Id>(), oli[0].id, oli[0].id,false,false, false);
        List<AddOpptyProductsCntrl.prodfeatureWrapper> fList = new List<AddOpptyProductsCntrl.prodfeatureWrapper>();
        for (List<AddOpptyProductsCntrl.prodfeatureWrapper> f : r.mapComponentToProductFeatures.values()){
            fList.addAll(f);
        }
        
        AddOpptyProductsCntrl.addEditProducts(mapOLI, fList, feedbackMap, true, false, false);
        AddOpptyProductsCntrl.addEditProducts(mapOLI, fList, feedbackMap, false, true, false);  
        AddOpptyProductsCntrl.addEditProducts(mapOLI, fList, feedbackMap, true, false, true); 
      	Test.startTest();
        Opportunity_Product__c newProductadded = TestBusinessHelper.createOpportunityLineItemCustom(oppList[0], prodlist[0].id, null, geoCountry, geoState, true);
      	system.debug('newProductadded'+ newProductadded.id);
        Opportunity_Product__c prodadded=[SELECT Id,product2id__c from Opportunity_Product__c where id =: newProductadded.id];
        AddOpptyProductsCntrl.responseWrapper r3 = AddOpptyProductsCntrl.getComponentsAndFeatures(new list<Id>(prodMap.keySet()), null, prodadded.product2id__c,false,false, false);
        List<AddOpptyProductsCntrl.prodfeatureWrapper> fList1 = new List<AddOpptyProductsCntrl.prodfeatureWrapper>();
        for (List<AddOpptyProductsCntrl.prodfeatureWrapper> f : r3.mapComponentToProductFeatures.values()){
            fList1.addAll(f);
        }
        
        AddOpptyProductsCntrl.addEditProducts(new Map<String, Opportunity_Product__c>{prodadded.Id => prodadded}, fList1, new Map<String, Feedback__c>{prodadded.Id => new Feedback__c(Description__c = 'missing features',Feedback_Category__c = 'Other')}, true, false,false);
        AddOpptyProductsCntrl.getRecordAccessLevel(oppList[0].Id);
        AddOpptyProductsCntrl.getTotalFeatureNumber(oppList[0].Id); 
        AddOpptyProductsCntrl.getCreateOppProdConfiguration('Feature',option[0].Id,specification[0].id,componenet[0].id,feature[0].id,true,true);
        AddOpptyProductsCntrl.getCreateOppProdConfigurationFeature('TestFeature',componenet[0].id,feature[0].id,true);
        DynamicDependentPicklist.getDependentPicklistValues('Opportunity.Reason_For_Close__c');
        
        Test.stopTest();
        TriggerExecutionController.skipAllTriggers(false);
    }
    static testmethod void TestOpptyLineItemClosedLostOpty(){ 
        Test.startTest();
        TriggerExecutionController.skipAllTriggers(true);
        List<Opportunity> oppList = [SELECT Id FROM Opportunity LIMIT 1];
        Map<Id, Product2> prodMap = new Map<Id, Product2>([SELECT Id FROM Product2 WHERE isActive = true Limit 1]);
        List<Opportunity_Product__c> oli = [SELECT Id  FROM Opportunity_Product__c limit 1];

        Map<String, Opportunity_Product__c> mapOLI = new Map<String, Opportunity_Product__c> ();
        Map<String, Feedback__c> feedbackMap = new Map<String, Feedback__c>();
        for (Opportunity_Product__c rec : oli){
            mapOLI.put(rec.Id, rec);
            feedbackMap.put(rec.Id, new Feedback__c(Description__c = 'missing features',Feedback_Category__c = 'Other'));
        }
        AddOpptyProductsCntrl.cloneAsClosedLostOptyproduct(oppList[0].Id, oli[0].Id,'Rejected - Asset/resource/tech investment limitation');
        AddOpptyProductsCntrl.getClosedLostProducts(oli[0].Id);
        TriggerExecutionController.skipAllTriggers(false);
        Test.stopTest();
    }
   
    
    static testmethod void TestBatchToPulateTotalRequiredFeature(){ 
        Product_Feature__c pdf = [select Id, Choice_Required__c, Enabled__c from Product_Feature__c limit 1];
        pdf.Choice_Required__c = true;
        pdf.Enabled__c = true;
        update pdf;
        system.debug('@@@@@ ' + pdf);
        
    }
    
    static testmethod void TestdeleteRecord(){
        Test.startTest();
        List<Opportunity> oppList = [SELECT Id FROM Opportunity LIMIT 1];
        AddOpptyProductsCntrl.getRecords(oppList[0].Id);
        List<Opportunity_Product__c> oli = [SELECT Id, Definition_Type__c,OpportunityId__r.Count_Opp_Product__c,OpportunityId__r.isClosed,Product2ID__r.IsActive,Product2ID__r.Product_Status__c  FROM Opportunity_Product__c WHERE OpportunityId__c =: oppList[0].Id];
        oli[1].Product2ID__r.IsActive = false; 
        oli[1].Product2ID__r.Product_Status__c = 'End of Sales';
        update oli;
        System.debug('oli1='+oli[1]);
        System.debug('oli1='+oli[1].OpportunityId__r.Count_Opp_Product__c);
        System.debug('oli1='+oli[1].OpportunityId__r.isClosed);
        System.debug('oli1='+oli[1].Product2ID__r.IsActive);
        System.debug('oli1='+oli[1].Product2ID__r.Product_Status__c);
        List<Product_Specification_Parameter__c> specification = [Select id,name from Product_Specification_Parameter__c];
        set<Id> ids = new set<Id>();
        for(Product_Specification_Parameter__c spec: specification ){
           ids.add(spec.id); 
        }
        List<Opportunity_Product_Configuration__c> configuration = [SELECT Id, Name, Opportunity_Product_Cus__c, Product_Specificaiton_Parameter__c,Product_Specification_Option__r.Name,Is_Feature_Included__c,
                                                                 Is_Specification_Parameter_Included__c,Product_Specification_Option__c, Specification_Parameter_Code__c, Specification_Option_Code__c, Specification_Option_Name__c, 
                                                                 Feature_Code__c, Product_Specificaiton_Parameter__r.Product_Feature__c,Component_Code__c, Product_Component__c, Product_Feature__c, Opportunity_Product_Cus__r.Product2ID__c,
                                                                 Configured_Product_Component__c,Configured_Product_Feature__c from Opportunity_Product_Configuration__c where 	Product_Specificaiton_Parameter__c In:ids];

 
        AddOpptyProductsCntrl.deleteOppProdConfiguration(ids);
        AddOpptyProductsCntrl.getProducts(oppList[0].Id, false, oli[0].Id, false);
        AddOpptyProductsCntrl.getProducts(oppList[0].Id, true, oli[0].Id, false);
        AddOpptyProductsCntrl.deleteRecord(oli[0].Id, null, null);


        AddOpptyProductsCntrl.deleteRecord(oli[1].Id, null, null); 
        
        Test.stopTest();      
    } 
    
    static testmethod void getFeatureConfig(){
        test.startTest();
        List<Opportunity> oppList = [SELECT Id FROM Opportunity LIMIT 1];
        List<Opportunity_Product__c> oli = [SELECT Id  FROM Opportunity_Product__c where OpportunityId__c =:oppList[0].id  limit 1];
        List<Product2> prodlist = [Select id,name from Product2 limit 1];
       
        List<Id> prodids = new list<Id>();
        for(Product2 p : prodlist){
            prodids.add(p.id);
        }
        List<Product_Component__c> componenet = [SELECT Id, Name, Component_Code__c, Product__c from Product_Component__c where Product__c In :prodids limit 1];
        List<SP_Visibility_matrix__mdt> visibility = SP_Visibility_matrix__mdt.getAll().values();
        List<Product_Feature__c> prodFeature = [Select id,name from Product_Feature__c];
        prodFeature[0].Configurable_at_Contracting__c = true;
        prodFeature[0].RecordTypeId = Schema.getGlobalDescribe().get('Product_Feature__c').getDescribe().getRecordTypeInfosByName().get(System.Label.FeatureRecordType).getRecordTypeId();
        //prodFeature[0].Default_Visibility__c = 'INCLUDED';
        prodFeature[0].Default_Visibility__c = 'NOT_INCLUDED';
        //prodFeature[0].Type__c = 'Information';
        prodFeature[0].Description__c = 'add comment';
        prodFeature[0].Allow_None_Value__c = true;
        update prodFeature;
        
        List<Product_Specification_Parameter__c> specification = [Select id,name,Default_Visibility__c from Product_Specification_Parameter__c where Product_Feature__c =:prodFeature[0].id limit 1];
        specification[0].Sales_Configurable__c = true;
      //  specification[0].Default_Visibility__c = 'INCLUDED';
        specification[0].Default_Visibility__c = 'NOT_INCLUDED';
        specification[0].Configurable_at_Contracting__c = true;
        specification[0].Type__c = 'options';
        update specification;
        List<Opportunity_Product_Configuration__c> config = [Select id,name,Product_Specificaiton_Parameter__c,Is_Specification_Parameter_Included__c,Product_Specification_Option__c from Opportunity_Product_Configuration__c where Opportunity_Product_Cus__c=:oli[0].id limit 1];
        //config[0].Is_Specification_Parameter_Included__c = true;
        //config[0].Product_Specificaiton_Parameter__c = specification[0].id;
       // update config;
        System.debug('Configuration' + config);
        List<Product_Specification_Option__c> option = [Select id,name from Product_Specification_Option__c where Product_Specification_Parameter__c =:specification[0].id limit 1];
        
        AddOpptyProductsCntrl.getComponentsAndFeatures(prodids,oli[0].id,'Productkey',false,false, false);
        
        test.stopTest();
    }
    
    static testmethod void checkForOption(){
        test.startTest();
        List<Product2> prodlist = [Select id,name,Latest_Product_Version__c from Product2 limit 1];
        prodlist[0].IsActive = false;
        update prodlist;
        List<Opportunity> oppList = [SELECT Id FROM Opportunity LIMIT 1];
        List<Product2> prodlist2 = [Select id,name from Product2 limit 1];
        List<Id> prodids = new list<Id>();
        for(Product2 p : prodlist){
            prodids.add(p.id);
        }
       List<Opportunity_Product__c> oli = [SELECT Id  FROM Opportunity_Product__c where OpportunityId__c =:oppList[0].id  limit 1];
        Map<String, Opportunity_Product__c> mapOLI = new Map<String, Opportunity_Product__c> ();
        Map<String, Feedback__c> feedbackMap = new Map<String, Feedback__c>();
        List<Product_Feature__c> prodFeature = [Select id,name from Product_Feature__c];
        prodFeature[0].Configurable_at_Contracting__c = true;
        prodFeature[0].RecordTypeId = Schema.getGlobalDescribe().get('Product_Feature__c').getDescribe().getRecordTypeInfosByName().get(System.Label.FeatureRecordType).getRecordTypeId();
       // prodFeature[0].Default_Visibility__c = 'NOT_INCLUDED';
        prodFeature[0].Default_Visibility__c = 'INCLUDED';
        prodFeature[0].Type__c = 'options';
        prodFeature[0].Description__c = 'add comment';
        prodFeature[0].Allow_None_Value__c = true;
        update prodFeature;
        List<Product_Specification_Parameter__c> specification = [Select id,name,Default_Visibility__c from Product_Specification_Parameter__c where Product_Feature__c =:prodFeature[0].id limit 1];
        specification[0].Sales_Configurable__c = true;
        specification[0].Default_Visibility__c = 'INCLUDED';
        specification[0].Type__c = 'options';
        specification[0].Allow_Multiselect__c = false;
        specification[0].Is_Mandatory__c = true;
        specification[0].Configurable_at_Contracting__c = true;
        update specification;
        AddOpptyProductsCntrl.getuserlocale();
        List<Opportunity_Product_Configuration__c> config = [Select id,name,Product_Specificaiton_Parameter__c,Is_Specification_Parameter_Included__c,Product_Specification_Option__c from Opportunity_Product_Configuration__c where Product_Specificaiton_Parameter__c != null and Is_Specification_Parameter_Included__c = false limit 1];
        AddOpptyProductsCntrl.getComponentsAndFeatures(prodids,oli[0].id,'Productkey',false,false, false);
        AddOpptyProductsCntrl.getProducts(oppList[0].Id, true, oli[0].id, false);
        test.stopTest(); 
    }
    
    static testmethod void checkforConfigurability(){
        test.startTest();
        List<Product2> prodlist = [Select id,name,Latest_Product_Version__c from Product2 limit 1];
        
        List<Opportunity> oppList = [SELECT Id FROM Opportunity LIMIT 1];
        List<Product2> prodlist2 = [Select id,name from Product2 limit 1];
        List<Id> prodids = new list<Id>();
        for(Product2 p : prodlist){
            prodids.add(p.id);
        }
        List<Opportunity_Product__c> oli = [SELECT Id  FROM Opportunity_Product__c where OpportunityId__c =:oppList[0].id  limit 1];
        List<Product_Feature__c> prodFeature = [Select id,name from Product_Feature__c];
        prodFeature[0].Allow_None_Value__c = true;
        update prodFeature;
        List<Product_Specification_Parameter__c> specification = [Select id,name,Default_Visibility__c from Product_Specification_Parameter__c where Product_Feature__c =:prodFeature[0].id limit 1];
        specification[0].Sales_Configurable__c = true;
        specification[0].Allow_Multiselect__c = true;
        specification[0].Type__c = 'option';
        update specification;
        List<Opportunity_Product_Configuration__c> config = [Select id,name,Product_Specificaiton_Parameter__c,Is_Specification_Parameter_Included__c,Product_Specification_Option__c from Opportunity_Product_Configuration__c where Product_Specificaiton_Parameter__c = null limit 1];
        AddOpptyProductsCntrl.getComponentsAndFeatures(prodids,oli[0].id,'Productkey',false,false, false);
        AddOpptyProductsCntrl.getProducts(oppList[0].Id, true, oli[0].id, false);
        test.stopTest();
        
    }
    
   static testmethod void checkforproductVersion(){
       user userlist = [Select id,name from user limit 1];
       TestBusinessHelper.createProduct('Ocean test3', true);
       List<Product2> prod4 = [Select id,name,OIPC_Code__c from Product2 where family = 'Ocean test3' limit 1];

       
       List<Opportunity> oppList = [SELECT Id FROM Opportunity LIMIT 1];
       Opportunity_Product__c oli2 = [SELECT Id  FROM Opportunity_Product__c where OpportunityId__c =:oppList[0].id  limit 1];
           List<Product2> prod1 = [Select id,name,OIPC_Code__c from Product2 where family = 'Ocean' limit 1];
           prod4[0].isActive = false;
           prod4[0].OIPC_Code__c = prod1[0].OIPC_Code__c;
           TriggerExecutionController.skipAllTriggers(true);
           update prod4;
           TriggerExecutionController.skipAllTriggers(false);
       
       TestBusinessHelper.createProduct('Ocean test', true);

       Segmentation_Matrix__c USsgm = [SELECT Id from Segmentation_Matrix__c LIMIT 1];
       List<Product2> prod2 = [Select id,name,OIPC_Code__c from product2 where family = 'Ocean test' limit 1];
       Segment_Data__c sgdata = TestBusinessHelper.createSegmentaData(prod2[0].id, USsgm.Id, true);
       /*prod2[0].isActive = false;
       prod2[0].Latest_Product_Version__c = prod1[0].id;
       prod2[0].OIPC_Code__c = prod1[0].OIPC_Code__c;
       update prod2;
       
       List<Product2> prod3 = [Select id,name,OIPC_Code__c from Product2];
       for(Product2 p:prod3){
       }
       
       list<PricebookEntry> pbe2 = [select id from pricebookentry where Default_Revenue_per_Unit__c!=null limit 1];
       delete pbe2;
       
         Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
       
       PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = prod1[0].Id,
            UnitPrice = 10,
            Default_Revenue_per_Unit__c = 10,
            Default_GP_Margin__c = 50,
            IsActive = true
        );
        Insert pbe;*/
       
       prod2[0].isActive = false;
       prod2[0].Latest_Product_Version__c = prod1[0].id;
       prod2[0].OIPC_Code__c = prod1[0].OIPC_Code__c;
       update prod2;
       
       List<Opportunity_Product__c> oli = [SELECT Id  FROM Opportunity_Product__c where OpportunityId__c =:oppList[0].id  limit 1];
       oli[0].Product2Id__c = prod2[0].id;
       oli[0].Product_Revenue_Per_Unit__c = 1;
       update oli;
       List<Feedback__c> feed = new list<Feedback__c>();
       Feedback__c feedbacklist = new Feedback__c();
       feedbacklist.Related_To_ID__c = oli[0].id;
       feedbacklist.Name = 'feedback';
       feedbacklist.Feedback_Category__c = 'Other';
       feed.add(feedbacklist);
       insert feed;
       AddOpptyProductsCntrl.getProducts(oppList[0].Id, false, oli[0].Id, true);
       //Product2Utilities.addPriceBookEntry();
    }
    
    
    static testmethod void tetProductUpgrade(){
        
        TriggerExecutionController.skipAllTriggers(true);
        TriggerExecutionController.skipOpportunityTrigger(true);
        TriggerExecutionController.skipOpportunityProductTrigger(true);
        Product2 prod= [Select id,version__c, Include_in_OMEB_Approvals__c,isactive,oipc_code__c,Latest_Product_Version__c from Product2 limit 1];
        prod.Is_Features_Mandatory__c =true;
        prod.oipc_code__c='P-P0-test';
        prod.version__c= 1;
        prod.isactive = false;
        //prod.Latest_Product_Version__c= lastestPorduct.id;
        update prod;
        
   
       
        
        Product2 lastestPorduct= TestBusinessHelper.createProduct('Ocean', true);
        Product2 prod1= [Select id,version__c, Include_in_OMEB_Approvals__c,isactive,oipc_code__c,Latest_Product_Version__c from Product2 where id=:lastestPorduct.id limit 1];
        prod1.oipc_code__c='P-P0-test';
        prod1.version__c=2;
        prod1.isactive = true;
        update prod1;
        
        Product2 prodtoupdate= [Select id,version__c, Include_in_OMEB_Approvals__c,isactive,oipc_code__c,Latest_Product_Version__c from Product2 where Is_Features_Mandatory__c=true];
        prodtoupdate.Latest_Product_Version__c = prod1.id;
		update prodtoupdate;
        Geography__c geoCountry = TestBusinessHelper.createGeography('United States', 'Country', null, true);
        Geography__c geoState = TestBusinessHelper.createGeography('Arizona', 'State', geoCountry.Id, true);
        Account ClientAccount = TestBusinessHelper.createAccount(null, geoCountry, 'Client_Account', true);
        Pricebook2 standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE isStandard = true]; 
        // PricebookEntry pbe=[select Id from PriceBookEntry where Product2Id =:prod.Id];
        List<Trade_Route__c> lstTDR = TestBusinessHelper.createTradeRoutes(new List<String> {'MSL'},  1, true);
        Opportunity mslOppty2 = TestBusinessHelper.createOpportunity(ClientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
       	Opportunity_Product__c Oli1 =TestBusinessHelper.createOpportunityLineItemCustom(mslOppty2, prod.id, lstTDR[0], true) ;
       
        List<Product_Component__c> comps =  new List<Product_Component__c>();
        for (integer i = 1; i <= 2; i++){
            Product_Component__c pc = new Product_Component__c();
            pc.Name = 'Comp' + i;
            pc.Component_Code__c = 'PC' + i;
          	pc.Product__c = prod1.Id;
            pc.Display_Order__c = i;
            comps.add(pc);
        }
        insert comps;
		
        List<Product_Feature__c> lstfeat = new List<Product_Feature__c>();
        
        for (integer i = 0; i < 2; i++){
            
            Product_Feature__c f = new Product_Feature__c();
            f.Name = 'Feature' + i;
            f.Feature_Code__c = 'F' + i;
            f.Product_Component__c = comps[i].Id;
            f.Display_Order__c = i;
            f.Categorisation__c ='Service';
            f.Default_Visibility__c= 'INCLUDED';
            f.Description__c = 'Feature description ';           
            lstfeat.add(f);
        }

        insert lstfeat;

        List<Product_Specification_Parameter__c> lstparameter = new List<Product_Specification_Parameter__c>();

        for(integer i=0;i<2;i++){
            Product_Specification_Parameter__c para = new Product_Specification_Parameter__c();
            para.Name = 'paramter' + i;
            para.Specification_Parameter_Code__c = 'SP' + i;
            para.Product_Feature__c = lstfeat[i].Id;
            para.Display_Order__c = i;
            para.type__c='options';
            para.Description__c = 'Parameter description ';  
            lstparameter.add(para);
        }
        insert lstparameter;

        List<Product_Specification_Option__c> lstoption = new List<Product_Specification_Option__c>();

        for(integer i=0;i<2;i++){
            Product_Specification_Option__c opt = new Product_Specification_Option__c();
            opt.Name = 'option' + i;
            opt.Specification_Option_Name__c = 'option' + i;
            opt.Specification_Option_Code__c = 'SPC' + i;
            opt.Product_Specification_Parameter__c = lstparameter[i].Id;
            opt.Display_Order__c = i;
            opt.Description__c = 'option description ';  
            lstoption.add(opt);
        }
        insert lstoption;
        TriggerExecutionController.skipAllTriggers(false);
        TriggerExecutionController.skipOpportunityTrigger(false);
        TriggerExecutionController.skipOpportunityProductTrigger(false);
       
        Test.startTest();

 		
       
        try{
            AddOpptyProductsCntrl.checkServieNoServieProduct(mslOppty2.Id, Oli1.id);
        }catch(Exception ex){
            
        }
        
        Test.stopTest();
    } 
      

    @isTest
    static void checkOpptyProdCloneEligibilityTest(){
        TriggerExecutionController.skipAllTriggers(true);
        Geography__c country = [SELECT Id from Geography__c WHERE Type_Of_Location__c='Country' LIMIT 1];
        Geography__c state = [SELECT Id from Geography__c WHERE Type_Of_Location__c='State' AND Parent_Geography__c =: country.Id LIMIT 1];        
        Opportunity opp = [SELECT Id from Opportunity WHERE Name='ShippingCargoServices' LIMIT 1];
        Product2 product = TestBusinessHelper.createProduct('Ocean', true);  
        product.Name = 'CRM Test Product';
        product.OIPC_Code__c='P-P0-test';
        product.Portfolio__c='Ocean';
        product.Version__c=1;
        product.IsActive=false;
        product.Latest_Product_Version__c=null;
        update product;
        Opportunity_Product__c opptyProd = TestBusinessHelper.createOpportunityLineItemCustom(opp, product.Id, null, country, state, true);
        Test.startTest();
        String result1 = AddOpptyProductsCntrl.checkOpptyProdCloneEligibility(opptyProd.id);
        Assert.areEqual('CRM Test Product',result1);
        product.IsActive=true; 
        update product;
        opptyProd.Product2ID__c=product.Id;
        String result2 = AddOpptyProductsCntrl.checkOpptyProdCloneEligibility(opptyProd.id);
        Assert.areEqual('success',result2);
        Test.stopTest();
        
    }

    @isTest
    static void testgetCustomerJourneyFieldValue(){
        TriggerExecutionController.skipAllTriggers(true);
        Opportunity opp = [SELECT Id,CloseDate from Opportunity WHERE Name='ShippingCargoServices' LIMIT 1];
        opp.Customer_Journey__c = 'Instant Quote (Non Negotiable)';
        Integer daysLeftInMonth = opp.CloseDate.daysBetween(opp.CloseDate.toStartOfMonth());
        Integer daysLeftForNextMonth = Date.daysInMonth(opp.CloseDate.year(), opp.CloseDate.month()) + daysLeftInMonth;
        opp.First_Shipment_Date__c = opp.CloseDate + daysLeftForNextMonth + 9;
        opp.Last_Shipment_Date__c =  opp.CloseDate + daysLeftForNextMonth + 10; 
        update opp;
        Test.startTest();
        String result1 = AddOpptyProductsCntrl.getCustomerJourneyFieldValue(opp.Id);
        Assert.areEqual('Instant Quote (Non Negotiable)',result1);
        AddOpptyProductsCntrl.ProductDefinition prodDef= AddOpptyProductsCntrl.getExistingOpptyProdDefinition(opp.Id);
        Assert.areEqual(proddef.isProduct,true); 
        Test.stopTest(); 
    }
    
    @isTest
    static void testSupplyChainMgmtDestinationUSAValidation(){
        TriggerExecutionController.skipAllTriggers(true);
        Geography__c country = [SELECT Id from Geography__c WHERE Type_Of_Location__c='Country' LIMIT 1];
        country.name = 'India';
        country.GEO_ID__c = Label.United_States_Country;
        Update country;
        TriggerExecutionController.skipAllTriggers(false);
        Test.startTest();
        Id result1 = AddOpptyProductsCntrl.getUnitedStatesRecordId();
        Assert.areEqual(country.id,result1);
        Test.stopTest();
    }
	/*
     @isTest
    //SFSE-14236 Test class to cover defaulting a global value for product revenue per unit field and GP
    static void testDefaultingGlobalValuesforRevenueAndGP(){
        Geography__c country = [SELECT Id from Geography__c WHERE Type_Of_Location__c='Country' LIMIT 1];
        Geography__c state = [SELECT Id from Geography__c WHERE Type_Of_Location__c='State' AND Parent_Geography__c =: country.Id LIMIT 1];    
        Opportunity opp = [SELECT Id from Opportunity WHERE Name='ShippingCargoServices' LIMIT 1];
        List<Product2> prodlist = [Select id,name from Product2 limit 1];
        List<Opportunity_Product__c> oli = [SELECT Id  FROM Opportunity_Product__c where OpportunityId__c =:opp.id  limit 1];
  	    List<AddOpptyProductsCntrl.productWrapper> result = new List<AddOpptyProductsCntrl.productWrapper>();
        result = AddOpptyProductsCntrl.getProducts(opp.Id, false, oli[0].id, false);
        Assert.areequal(result[0].ProductRevenuePerunit,10.00,'Error if value is not be 10');
        Assert.areequal(result[0].defaultGPMargin,50.00,'Error if value is not 50');
        Assert.areequal(result[0].UnitPrice,5.00,'Error if value is not 5');
    }*/
    
    @isTest
    static void testDefaultingGlobalRevenueandGPvalues(){
        TriggerExecutionController.skipAllTriggers(true);
		Segmentation_Matrix__c USsgm = [SELECT Id from Segmentation_Matrix__c LIMIT 1];
		Opportunity opp = [SELECT Id from Opportunity WHERE Name='ShippingCargoServices' LIMIT 1];
		List<Product2> prodlist = [Select id,name,OIPC_Code__c from Product2 limit 1];
        TestBusinessHelper.createProduct('Ocean test', true);
        List<Product2> prod2 = [Select id,name,OIPC_Code__c,Portfolio__c,Latest_Product_Version__c,isActive from product2 where family = 'Ocean test' limit 1];
        prod2[0].isActive = false;
        prod2[0].Latest_Product_Version__c = prodlist[0].id;
        prod2[0].OIPC_Code__c = prodlist[0].OIPC_Code__c;
        prod2[0].Portfolio__c = 'Ocean';
        update prod2;
        List<Segment_Data__c> sgd = [select id,Product__c from Segment_Data__c];
        List<Id> prodids = new list<Id>();
        prodids.add(prodlist[0].id);
        prodids.add(prod2[0].id);
        List<Opportunity_Product__c> oli = [SELECT Id  FROM Opportunity_Product__c where OpportunityId__c =:opp.id  limit 1];
        TriggerExecutionController.skipAllTriggers(false);
        Test.startTest();
        AddOpptyProductsCntrl.responseWrapper r = AddOpptyProductsCntrl.getComponentsAndFeatures(prodids, oli[0].id, null, false, false, false);
        Assert.areequal(r.MapofProdToSegmentData.containsKey(prodids[0]),true,'Error if segmentdata is not coming');
        Map<Id,Map<Id,List<Segment_Data__c>>> result = AddOpptyProductsCntrl.getSegmentData(prodids);
        Assert.areequal(result.containsKey(prodids[0]),true,'Error if segmentdata is not coming');
        
        Test.stopTest();
    }

    @isTest
    static void test_getOpptyStage(){
        Opportunity opp = [SELECT Id,StageName from Opportunity WHERE Name='ShippingCargoServices' LIMIT 1];
        String opptyStage = AddOpptyProductsCntrl.getOpptyStage(opp.Id);
        Assert.areEqual(opp.StageName,opptyStage);
    }
}