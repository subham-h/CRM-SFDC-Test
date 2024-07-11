/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-11-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
*
* Revision Ref Number   Date            Owner                           Description
* -------- ----------   -----------     -------------------             --------------------------------------------------------
* 1.0      SFSE-13391   09-May-2024     Shashi@Maersk                   Added test method test_preventConfigModification()
*/
 
@isTest(seeAllData= false)
public class OpptyProductConfigTrigger_Test {
    @testSetup static void setup() {
        Test.startTest();
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
        Geography__c state = TestBusinessHelper.createGeography('Karnataka', 'State', country.Id, true);
        
        BDA__c parentBDA = TestBusinessHelper.createBDA('India, Middle East, and Africa', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true);
        BDA__c childBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'IBS', parentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, country.Id, null, true);
        
        TriggerExecutionController.skipAllTriggers(true);
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', true);
        Opportunity mslOppty = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        mslOppty.Pricebook2Id = Test.getStandardPricebookId();
        update mslOppty;

        TriggerExecutionController.skipAllTriggers(false);
        ScheduleOppProducts.OpportunityfromClone = false;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Update standardPricebook;
        Map<String, string> geoMap = new Map<String, String>();
        GeoMap.put( 'Long Beach', 'Country' );
        
        List<Trade_Route__c> lstTradeRoute = TestBusinessHelper.createTradeRoutes(new List<String>{'MCC'}, 1,true);
        //insert lstTradeRoute;
        Id tradeRouteId = lstTradeRoute[0].Id;
        Product2 lstProd = TestBusinessHelper.createProduct('Ocean', true);
        TriggerExecutionController.skipAllTriggers(true);
        
        Opportunity_Product__c Oli1 = TestBusinessHelper.createOpportunityLineItemCustom(mslOppty, lstProd.Id,lstTradeRoute[0], true);
        
        
       List<Product_Component__c> comps =  new List<Product_Component__c>();
        for (integer i = 0; i < 4; i++){
            Product_Component__c pc = new Product_Component__c();
            pc.Name = 'Comp' + i;
            pc.Component_Code__c = 'PC' + i;
            pc.Product__c = lstProd.Id;
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
        
       
        TriggerExecutionController.skipAllTriggers(false);
        Test.stopTest();
    }


    static testmethod void TestOpptyConfigUpdate(){  
        Test.startTest();
        Opportunity mslOppty = [SELECT id, Name, AccountId FROM Opportunity LIMIT 1]; 
        Opportunity_Product__c oli = [SELECT Id   FROM Opportunity_Product__c WHERE OpportunityId__c=:mslOppty.id limit 1];
        List<Product_Component__c> comps =  [SELECT Id FROM Product_Component__c];
        List<Product_Feature__c> lstfeat = [SELECT Id FROM Product_Feature__c];
        List<Product_Specification_Parameter__c> lstparameter = [SELECT Id FROM Product_Specification_Parameter__c];
        List<Product_Specification_Option__c> lstoption = [SELECT Id FROM Product_Specification_Option__c];

        List<Opportunity_Product_Configuration__c> lstconfig= new list<Opportunity_Product_Configuration__c>();

        for(integer i=0;i<4;i++){
            Opportunity_Product_Configuration__c config= new Opportunity_Product_Configuration__c();
            config.Opportunity_Product_Cus__c = oli.id;
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
        config.Opportunity_Product_Cus__c = oli.id;
        config.Configured_Product_Feature__c = lstfeat[0].id;
        config.Configured_Product_Component__c = comps[0].id;
        config.name='test'+5;
        lstconfig.add(config);
        Opportunity_Product_Configuration__c config1= new Opportunity_Product_Configuration__c();
        config1.Is_Feature_Included__c = true;
        config1.Opportunity_Product_Cus__c = oli.id;
        config1.Configured_Product_Feature__c = lstfeat[1].id;
        config1.Configured_Product_Component__c = comps[1].id;
        config1.name='test'+6;
        lstconfig.add(config1);
        Opportunity_Product_Configuration__c config2= new Opportunity_Product_Configuration__c();
        config2.Is_Feature_Included__c = true;
        config2.Opportunity_Product_Cus__c = oli.id;
        config2.Configured_Product_Feature__c = lstfeat[2].id;
        config2.Configured_Product_Component__c = comps[2].id;
        config2.name='test'+7;
        
        Opportunity_Product_Configuration__c config3= new Opportunity_Product_Configuration__c();
        config3.Is_Feature_Included__c = true;
        config3.Is_Specification_Parameter_Included__c = false;
        config3.Opportunity_Product_Cus__c = oli.id;
        config3.Configured_Product_Feature__c = lstfeat[1].id;
        config3.Configured_Product_Component__c = comps[1].id;
        config3.Product_Specificaiton_Parameter__c = lstparameter[1].id;
        config3.name='test'+7;
    
        lstconfig.add(config3);
        insert lstconfig;

        Opportunity_Product_Configuration__c config4 = [SELECT id,Opportunity_Product_Cus__c,Product_Specification_Option__c,Product_Specificaiton_Parameter__c FROM Opportunity_Product_Configuration__c LIMIT 1];
        config4.Product_Specificaiton_Parameter__c =lstparameter[3].id;
        config4.Product_Specification_Option__c =  lstoption[1].id;
        update config4;

        Test.stopTest();
    }

    static testmethod void TestOpptyConfigDelete(){  
    Test.startTest();
        Opportunity mslOppty = [SELECT id, Name, AccountId FROM Opportunity LIMIT 1]; 
        Opportunity_Product__c oli = [SELECT Id   FROM Opportunity_Product__c WHERE OpportunityId__c=:mslOppty.id limit 1];
        List<Product_Component__c> comps =  [SELECT Id FROM Product_Component__c];
        List<Product_Feature__c> lstfeat = [SELECT Id FROM Product_Feature__c];
        List<Product_Specification_Parameter__c> lstparameter = [SELECT Id FROM Product_Specification_Parameter__c];
        List<Product_Specification_Option__c> lstoption = [SELECT Id FROM Product_Specification_Option__c];

        List<Opportunity_Product_Configuration__c> lstconfig= new list<Opportunity_Product_Configuration__c>();

        for(integer i=0;i<4;i++){
            Opportunity_Product_Configuration__c config= new Opportunity_Product_Configuration__c();
            config.Opportunity_Product_Cus__c = oli.id;
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
        config.Opportunity_Product_Cus__c = oli.id;
        config.Configured_Product_Feature__c = lstfeat[0].id;
        config.Configured_Product_Component__c = comps[0].id;
        config.name='test'+5;
        lstconfig.add(config);
        Opportunity_Product_Configuration__c config1= new Opportunity_Product_Configuration__c();
        config1.Is_Feature_Included__c = true;
        config1.Opportunity_Product_Cus__c = oli.id;
        config1.Configured_Product_Feature__c = lstfeat[1].id;
        config1.Configured_Product_Component__c = comps[1].id;
        config1.name='test'+6;
        lstconfig.add(config1);
        Opportunity_Product_Configuration__c config2= new Opportunity_Product_Configuration__c();
        config2.Is_Feature_Included__c = true;
        config2.Opportunity_Product_Cus__c = oli.id;
        config2.Configured_Product_Feature__c = lstfeat[2].id;
        config2.Configured_Product_Component__c = comps[2].id;
        config2.name='test'+7;
        
        Opportunity_Product_Configuration__c config3= new Opportunity_Product_Configuration__c();
        config3.Is_Feature_Included__c = true;
        config3.Is_Specification_Parameter_Included__c = false;
        config3.Opportunity_Product_Cus__c = oli.id;
        config3.Configured_Product_Feature__c = lstfeat[1].id;
        config3.Configured_Product_Component__c = comps[1].id;
        config3.Product_Specificaiton_Parameter__c = lstparameter[1].id;
        config3.name='test'+7;
    
        lstconfig.add(config3);
        insert lstconfig;
        
        Opportunity_Product_Configuration__c config4 = [SELECT id,Product_Specificaiton_Parameter__c FROM Opportunity_Product_Configuration__c where Opportunity_Product_Cus__c!=null LIMIT 1];
        delete config4;
        Test.stopTest();
    
    }
    
    @isTest
    static void test_preventConfigModification(){
        Opportunity oppty = [SELECT Id, Record_Locked__c FROM Opportunity WHERE isClosed = false LIMIT 1]; 
        Opportunity_Product__c oli = [SELECT Id FROM Opportunity_Product__c WHERE OpportunityId__c=:oppty.Id LIMIT 1];
        List<Product_Component__c> comps =  [SELECT Id FROM Product_Component__c];
        List<Product_Feature__c> lstfeat = [SELECT Id FROM Product_Feature__c];
        List<Product_Specification_Parameter__c> lstparameter = [SELECT Id FROM Product_Specification_Parameter__c];
        List<Product_Specification_Option__c> lstoption = [SELECT Id FROM Product_Specification_Option__c];
        List<Opportunity_Product_Configuration__c> lstconfig= new list<Opportunity_Product_Configuration__c>();
        
        Opportunity_Product_Configuration__c config= new Opportunity_Product_Configuration__c();
        config.Is_Feature_Included__c = true;
        config.Opportunity_Product_Cus__c = oli.id;
        config.Configured_Product_Feature__c = lstfeat[0].id;
        config.Configured_Product_Component__c = comps[0].id;
        config.name='TEST'+config.name+'1';
        lstconfig.add(config);
        
        Opportunity_Product_Configuration__c config1= new Opportunity_Product_Configuration__c();
        config1.Is_Feature_Included__c = true;
        config1.Opportunity_Product_Cus__c = oli.id;
        config1.Configured_Product_Feature__c = lstfeat[1].id;
        config1.Configured_Product_Component__c = comps[1].id;
        config1.name='TEST'+config1.name+'2';
        lstconfig.add(config1);
        
        insert lstconfig;
        
        Opportunity_Product_Configuration__c config3 = new Opportunity_Product_Configuration__c();
        config3.Is_Feature_Included__c = true;
        config3.Is_Specification_Parameter_Included__c = false;
        config3.Opportunity_Product_Cus__c = oli.id;
        config3.Configured_Product_Feature__c = lstfeat[2].id;
        config3.Configured_Product_Component__c = comps[2].id;
        config3.Product_Specificaiton_Parameter__c = lstparameter[2].id;
        config3.name='TEST'+config3.name+'3';
        
        Test.startTest();
        oppty.StageName = System.Label.Closed_lost;
        oppty.Reason_For_Close__c = 'Lost - Customer Relationship Issue';
        update oppty;
        Opportunity_Product_Configuration__c configToUpdate = [SELECT id,Opportunity_Product_Cus__c,Product_Specification_Option__c,Product_Specificaiton_Parameter__c FROM Opportunity_Product_Configuration__c WHERE Opportunity_Product_Cus__c =:oli.Id LIMIT 1];
        configToUpdate.Product_Specificaiton_Parameter__c =lstparameter[3].id;
        configToUpdate.Product_Specification_Option__c =  lstoption[1].id;
        try{
            update configToUpdate;
        }
        catch(Exception e){
            Boolean res = e.getmessage().contains('Configuration changes cannot be made to closed opportunities.') ? true : false;
            Assert.areEqual(res, true);
        }
        try{
            insert config3;
        }
        catch(Exception e){
            Boolean res = e.getmessage().contains('Configuration changes cannot be made to closed opportunities.') ? true : false;
            Assert.areEqual(res, true);
        }
         try{
            delete configToUpdate;
        }
        catch(Exception e){
            Boolean res = e.getmessage().contains('Configuration changes cannot be made to closed opportunities.') ? true : false;
            Assert.areEqual(res, true);
        }
        
        Test.stopTest();
    }


}