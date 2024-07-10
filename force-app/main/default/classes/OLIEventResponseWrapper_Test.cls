/*              
* Revision Date        Owner                        Description
* -------- ----------  -----------                  -----------
* 1.0      28-03-23  Samarpreet.singh@maersk.com    Test Class for 'OLIEventResponseWrapper' & 'OLIEventHandler'.
* 2.0      26-05-23  Samarpreet.singh@maersk.com    Added logic to read from new Custom OBject for prodcut and Schedules
*/
@isTest(seeAllData= false)
public without sharing class OLIEventResponseWrapper_Test {
    @testSetup static void setup() {
        Test.startTest();
        TriggerExecutionController.skipAllTriggers(true);
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', true);
        Opportunity tenderOpportunity = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        opp.StageName = 'Qualifying';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;
      
        //List<Product2> lstProd = DataGeneratorHelper1_Test.createProduct2( 1,'A','DE','Ocean');
    	Product2 lstProd = TestBusinessHelper.createProduct('Ocean', true);
        ScheduleOppProducts.OpportunityfromClone = false;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Update standardPricebook;

      
        
        // PriceBookEntry pbEntry = [select Id from PriceBookEntry where Product2Id =:lstProd[0].Id];

        /*Map<String, string> geoMap = new Map<String, String>();
        GeoMap.put( 'Long Beach', 'Country' );
        List<Geography__c> geoList = DataGeneratorHelper1_Test.createGeography( geoMap );
        system.debug('geoList ' + geoList);
        Geography__c geo = geoList[0];
        geo.Is_Port__c = true;
        update geo;
       
    	*/
       
        
        
        

        List<Trade_Route__c> lstTradeRoute =  TestBusinessHelper.createTradeRoutes(new List<String>{BrandUtilities.MCC}, 1,true);
       
        Id tradeRouteId = lstTradeRoute[0].Id;
    
       // List<Product2> prods = DataGeneratorHelper_OIPC.createOipcProducts(1);
        Opportunity_Product__c oli = New Opportunity_Product__c();
        oli.OpportunityId__c = tenderOpportunity.Id;
        oli.Quantity__c = 1;
        oli.UnitPrice__c = 1;
        oli.Product_Revenue_Per_Unit__c = 1;
        oli.Opt_Out_Auto_Quantity_Scheduling__c = false;
        oli.Tender_Target__c = 1;
       // oli.Nominated_Quantity__c = 1;
        oli.Product2ID__c = lstProd.Id;
        oli.Trade_Route__c = tradeRouteId;
        insert oli;
		
        //OpportunityLineItem oli = DataGeneratorHelper1_Test.createOpportunityLineItem( mslOppty.Id, pbEntry.Id );

       //TestBusinessHelper.createProductComponents(new List<Product2>{lstProd}, 2, true);
      
        List<Product_Component__c> comps =  new List<Product_Component__c>();
        for (integer i = 1; i <= 2; i++){
            Product_Component__c pc = new Product_Component__c();
            pc.Name = 'Comp' + i;
            pc.Component_Code__c = 'PC' + i;
          	pc.Product__c = lstProd.Id;
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
        
        List<Opportunity_Product_Configuration__c> lstconfig= new list<Opportunity_Product_Configuration__c>();

        for(integer i=0;i<2;i++){
            Opportunity_Product_Configuration__c config= new Opportunity_Product_Configuration__c();
            config.Opportunity_Product_Cus__c = oli.id;
            config.Product_Specification_Option__c = lstoption[i].id;
            config.Is_Feature_Included__c = true;
            config.Is_Specification_Parameter_Included__c = true;
            config.Configured_Product_Feature__c = lstfeat[i].id;
            config.Configured_Product_Component__c = comps[i].id;
            config.Product_Specificaiton_Parameter__c = lstparameter[i].id;
            config.name='test'+i;
            lstconfig.add(config);
        }
        insert lstconfig;
        TriggerExecutionController.skipAllTriggers(false);
 		Test.stopTest();
    }
    @isTest
    public static void testOpptyEventWrapper(){  
        Test.startTest();
        Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        Opportunity_Product__c oli= [SELECT Id,Quantity__c,UnitPrice__c,Amend_Gross_Profit_per_unit__c FROM Opportunity_Product__c where OpportunityId__c=:opp.Id];
        oli.Amend_Gross_Profit_per_unit__c = 3;
        update oli;
        Opportunity_Product__c olitest= [SELECT Id,Quantity__c,UnitPrice__c FROM Opportunity_Product__c where OpportunityId__c=:opp.Id];
        Test.stopTest();

    }

    @isTest
    public static void  testOpptyEvent(){  
        Test.startTest();
        Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        Opportunity_Product__c oli= [SELECT Id,Quantity__c,UnitPrice__c FROM Opportunity_Product__c where OpportunityId__c=:opp.Id];
      
        OLIEventResponseWrapper.Requests req= new OLIEventResponseWrapper.Requests();
        req.isOliDeletd=false;
        req.oliReq= oli;
         
        List<OLIEventResponseWrapper.Results> res= OLIEventResponseWrapper.prepareOliEventData(new List<OLIEventResponseWrapper.Requests>{req});

        Opportunity_Product_Event__e event=new Opportunity_Product_Event__e();
        event.JSON_1__c= res[0].serializedJSON1;
        event.JSON_2__c= res[0].serializedJSON2;
        event.JSON_3__c= res[0].serializedJSON3;
        event.topic__c='test';
        EventBus.publish(event);

        OLIEventHandler.Requests request=new OLIEventHandler.Requests();
        request.inputSObject =(SObject)event;

        //OLIEventHandler.serialize(new List<OLIEventHandler.Requests>{request});
        
        Test.stopTest();
        Opportunity_Product__c olitest= [SELECT Id,Quantity__c,UnitPrice__c FROM Opportunity_Product__c where OpportunityId__c=:opp.Id];
        system.assertEquals(olitest.Quantity__c,oli.Quantity__c);
        
    }

    @isTest
    public static void  testOpptyStageChange(){  
        Test.startTest();
        Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        opp.StageName = 'Designing Proposal';
        update opp;
        
        Test.stopTest();
    }

    @isTest
    public static void  testDeleteProduct(){  
        Test.startTest();
        Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        Opportunity_Product__c oli= [SELECT Id,Quantity__c,UnitPrice__c FROM Opportunity_Product__c where OpportunityId__c=:opp.Id];
        delete oli;
        Test.stopTest();
    }
    @isTest
    public static void testConfigData(){
        Test.startTest();
        List<Opportunity_Product_Configuration__c> opc = [select Id, Name, Is_Feature_Included__c, Is_Specification_Parameter_Included__c, 
                                                          Configured_Product_Feature__c, Configured_Product_Component__c, Product_Specificaiton_Parameter__c 
                                                          from Opportunity_Product_Configuration__c limit 1];
        opc[0].Product_Specificaiton_Parameter__c = null;
        opc[0].Is_Specification_Parameter_Included__c = false;
        opc[0].Is_Feature_Included__c = false;
        update opc;
        Test.stopTest();
    }
    
    @isTest
    public static void testConfigData2(){
        Test.startTest();
        List<Opportunity_Product_Configuration__c> opc = [select Id, Name, Is_Feature_Included__c, Is_Specification_Parameter_Included__c, 
                                                          Configured_Product_Feature__c, Configured_Product_Component__c, Product_Specificaiton_Parameter__c  from Opportunity_Product_Configuration__c limit 1];
       opc[0].Product_Specificaiton_Parameter__c = null;
       opc[0].Is_Specification_Parameter_Included__c = false;                                                  
       opc[0].Is_Feature_Included__c = true;
       update opc;
      Test.stopTest();
    }
     @isTest
    public static void testConfigData3(){
        Test.startTest();
        List<Opportunity_Product_Configuration__c> opc = [select Id, Name, Is_Feature_Included__c, Is_Specification_Parameter_Included__c, 
                                                          Configured_Product_Feature__c, Configured_Product_Component__c, Product_Specificaiton_Parameter__c  from Opportunity_Product_Configuration__c where Specification_Parameter_Code__c!= null limit 1];
       opc[0].Product_Specificaiton_Parameter__c = null;
       opc[0].Is_Specification_Parameter_Included__c = false;                                                  
       opc[0].Is_Feature_Included__c = true;
       update opc;
      Test.stopTest();
    }
}