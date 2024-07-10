/**
 * @description       : 
 * @author            : Samar@Maserk.com
**/
@isTest
public with sharing class ShowProductVersionDiffController_Test {
   
    @testSetup static void setup() {
        Test.startTest();
        TriggerExecutionController.skipAllTriggers(true);

        Geography__c geoCountry = TestBusinessHelper.createGeography('United States', 'Country', null, true);
        Geography__c geoState = TestBusinessHelper.createGeography('Arizona', 'State', geoCountry.Id, true);
        user user1 = TestBusinessHelper.createUser('Sales', 'Seago', true);
        
        Account ClientAccount = TestBusinessHelper.createAccount(user1, geoCountry, 'Client_Account', true);
        Contact cont = TestBusinessHelper.createContact(ClientAccount, 'Customer_Contact','MaerskLine', true);
        Opportunity mslOppty = TestBusinessHelper.createOpportunity(ClientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        mslOppty.Pricebook2Id = Test.getStandardPricebookId();
        update mslOppty;

        TriggerExecutionController.skipAllTriggers(false);


        Product2 lstProd = TestBusinessHelper.createProduct('Ocean', true);
        List<Product2> lstProd1= [Select  Id,OIPC_Code__c,Version__c,Minor_Version__c,Increment_Version__c from Product2 limit 1];
        lstProd1[0].OIPC_Code__c = 'oipc-Code-1';
        lstProd1[0].Version__c = 1;
        lstProd1[0].Minor_Version__c = 0;
        lstProd1[0].Increment_Version__c = 0;
        update lstProd1;
        ScheduleOppProducts.OpportunityfromClone = false;

        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Update standardPricebook;

     
        List<String> operators = new List<String>{'MCC','MSL','SAF'};
        List<Trade_Route__c> lstTDR = TestBusinessHelper.createTradeRoutes(operators, 2, true);
      

        Opportunity_Product__c Oli1 = TestBusinessHelper.createOpportunityLineItemCustom(mslOppty, lstProd.id, null, geoCountry, geoState, true);
    
       

        List<Product_Component__c> comps =  new List<Product_Component__c>();
        for (integer i = 0; i < 2; i++){
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

        for(integer i=0;i<2;i++){
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
        for(integer i=0 ;i<2; i++){
            Opportunity_Product_Configuration__c config= new Opportunity_Product_Configuration__c();
            config.Opportunity_Product_Cus__c = Oli1.id;
            if(i==0 ){
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
        
        
  		insert lstconfig;
        Test.stopTest();

    }
    @isTest
    public static void testAddingNewFeatures(){  
        TriggerExecutionController.skipAllTriggers(true);
        Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        Test.startTest(); 
        List<Product2> lstProd1= [Select  Id,OIPC_Code__c,Version__c,Minor_Version__c,Increment_Version__c,Latest_Product_Version__c from Product2 limit 1];
        Opportunity_Product__c oli= [SELECT Id,Quantity__c,UnitPrice__c,Amend_Gross_Profit_per_unit__c,Product2ID__c,Product2Id__r.Name FROM Opportunity_Product__c where OpportunityId__c=:opp.Id];
        oli.Amend_Gross_Profit_per_unit__c = 3;
        oli.Product2ID__c= lstProd1[0].id;
        update oli;
        
      
       
        Product2 testP = new Product2();
        testp.name = 'test1';
        testp.ProductCode = 'A1';
        testp.Direction__c = 'DE1';
        testp.family  = 'Ocean' ;
        testp.OIPC_Code__c = 'oipc-Code-1';
        testp.Version__c = 2;
        testp.Minor_Version__c = 0;
        testp.Increment_Version__c = 0;
        insert testP;

        lstProd1[0].Latest_Product_Version__c= testP.Id;
        update lstProd1;

    
        List<Product_Component__c> comps =  new List<Product_Component__c>();
        for (integer i = 0; i < 4; i++){
            Product_Component__c pc = new Product_Component__c();
            pc.Name = 'Comp' + i;
            pc.Component_Code__c = 'PC' + i;
          	pc.Product__c = testP.Id;
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
        ShowProductVersionDiffController.getDifference(oli.Id, opp.Id,false,lstProd1[0].Id ,testp.Id ,oli);
        Test.stopTest();
    }
    
	@isTest
    public static void testdeleteExistingFeatures(){  
        TriggerExecutionController.skipAllTriggers(true);
        Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        Test.startTest();
        List<Product2> lstProd1= [Select  Id,OIPC_Code__c,Version__c,Minor_Version__c,Increment_Version__c,Latest_Product_Version__c from Product2 limit 1];
        Opportunity_Product__c oli= [SELECT Id,Quantity__c,UnitPrice__c,Amend_Gross_Profit_per_unit__c,Product2ID__c,Product2Id__r.Name FROM Opportunity_Product__c where OpportunityId__c=:opp.Id];
        oli.Amend_Gross_Profit_per_unit__c = 3;
        oli.Product2ID__c= lstProd1[0].id;
        update oli;
       
        
       
        Product2 testP = new Product2();
        testp.name = 'test1';
        testp.ProductCode = 'A1';
        testp.Direction__c = 'DE1';
        testp.family  = 'Ocean' ;
        testp.OIPC_Code__c = 'oipc-Code-1';
        testp.Version__c = 2;
        testp.Minor_Version__c = 0;
        testp.Increment_Version__c = 0;
        insert testP;

        lstProd1[0].Latest_Product_Version__c= testP.Id;
        update lstProd1;

        List<Product_Component__c> comps =  new List<Product_Component__c>();
           
            for (integer i = 0; i < 4; i++){
                Product_Component__c pc = new Product_Component__c();
                pc.Name = 'Comp' + i;
                pc.Component_Code__c = 'PC' + i;
                pc.Product__c = testP.Id;
                pc.Display_Order__c = i;
                if(i==2){
                    pc.Component_Code__c = 'PC-2' + i;
                }else{
                    pc.Name = 'Comp' + i;
                }
            
            comps.add(pc);
        }
        insert comps;
        
        List<Product_Feature__c> lstfeat = new List<Product_Feature__c>();
        
        for (integer i = 0; i < 4; i++){
            
            Product_Feature__c f = new Product_Feature__c();
            f.Name = 'Feature' + i;
          
            f.Product_Component__c = comps[i].Id;
            f.Categorisation__c = 'Service';
            if(i==0){
                f.Feature_Code__c = 'F-0' + i;
             	f.Default_Visibility__c = 'INCLUDED';
                f.Configurable_at_Contracting__c  = false;
            }else if(i == 1){
                f.Feature_Code__c = 'F-0' + i;
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
        ShowProductVersionDiffController.getDifference(oli.Id, opp.Id,false,lstProd1[0].Id ,testp.Id ,oli);
       

        Test.stopTest();
    }
    
    @isTest
    public static void testdeleteExistingParameter(){  

        TriggerExecutionController.skipAllTriggers(true);
        Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        Test.startTest(); 
        List<Product2> lstProd1= [Select  Id,OIPC_Code__c,Version__c,Minor_Version__c,Increment_Version__c,Latest_Product_Version__c from Product2 limit 1];
        Opportunity_Product__c oli= [SELECT Id,Quantity__c,UnitPrice__c,Amend_Gross_Profit_per_unit__c,Product2ID__c,Product2Id__r.Name FROM Opportunity_Product__c where OpportunityId__c=:opp.Id];
        oli.Amend_Gross_Profit_per_unit__c = 3;
        oli.Product2ID__c= lstProd1[0].id;
        update oli;
       
      
       
        Product2 testP = new Product2();
        testp.name = 'test1';
        testp.ProductCode = 'A1';
        testp.Direction__c = 'DE1';
        testp.family  = 'Ocean' ;
        testp.OIPC_Code__c = 'oipc-Code-1';
        testp.Version__c = 2;
        testp.Minor_Version__c = 0;
        testp.Increment_Version__c = 0;
        insert testP;

        lstProd1[0].Latest_Product_Version__c= testP.Id;
        update lstProd1;

        List<Product_Component__c> comps =  new List<Product_Component__c>();
           
        for (integer i = 0; i < 4; i++){
            Product_Component__c pc = new Product_Component__c();
            pc.Name = 'Comp' + i;
            pc.Component_Code__c = 'PC' + i;
            pc.Product__c = testP.Id;
            pc.Display_Order__c = i;
            if(i==2){
                pc.Component_Code__c = 'PC-2' + i;
            }else{
                pc.Name = 'Comp' + i;
            }
    
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
           
            para.Product_Feature__c = lstfeat[i].Id;
            para.Display_Order__c = i;
            para.Sales_Configurable__c= true;
            para.Is_Mandatory__c = true;
            para.type__c='options';
            if(i==0){
             	para.Default_Visibility__c = 'INCLUDED';
                para.Configurable_at_Contracting__c  = false;
                para.Specification_Parameter_Code__c = 'SP-0' + i;
               	para.Allow_Multiselect__c = true;
            }else if(i == 1){
                para.Default_Visibility__c = 'INCLUDED';
                para.Configurable_at_Contracting__c  = true;
                para.Specification_Parameter_Code__c = 'SP-0' + i;
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
           
            opt.Specification_Option_Code__c = 'SPC' + i;
            opt.Product_Specification_Parameter__c = lstparameter[i].Id;
            opt.Display_Order__c = i;
            opt.Description__c = 'option description ';  
            if(i==2 || i== 3){
                opt.Specification_Option_Name__c = 'option-0' + i;
            }else{
                opt.Specification_Option_Name__c = 'option' + i;
            }
           
            lstoption.add(opt);
        }
        insert lstoption;
        TriggerExecutionController.skipAllTriggers(false);
        ShowProductVersionDiffController.getDifference(oli.Id, opp.Id,false,lstProd1[0].Id ,testp.Id ,oli);
     

        Test.stopTest();
    }


    @isTest
    public static void testCheckProductDefination(){  

        Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        Test.startTest(); 
        List<Product2> lstProd1= [Select  Id,OIPC_Code__c,Version__c,Minor_Version__c,Increment_Version__c,Latest_Product_Version__c from Product2 limit 1];
        Opportunity_Product__c oli= [SELECT Id,Quantity__c,UnitPrice__c,Amend_Gross_Profit_per_unit__c,Product2ID__c,Product2Id__r.Name FROM Opportunity_Product__c where OpportunityId__c=:opp.Id];
        oli.Amend_Gross_Profit_per_unit__c = 3;
        oli.Product2ID__c= lstProd1[0].id;
        update oli;

        ShowProductVersionDiffController.checkForDefinationType(oli.Id, opp.Id,false);
        Test.stopTest();
    }

    @isTest
    public static void testCheckSolutionDefination(){ 
        TriggerExecutionController.skipAllTriggers(true);
        TriggerExecutionController.skipProduct2Trigger(true);
        Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        List<Product2> lstProd1= [Select  Id,OIPC_Code__c,Version__c,Minor_Version__c,Increment_Version__c,Latest_Product_Version__c from Product2 limit 1];
        Product2 temProd = TestBusinessHelper.createProduct('Ocean', FALSE);
        temProd.Id=null;
        temProd.OIPC_Code__c='oipc-Code-2';
        temProd.Portfolio__c='Ocean';
        temProd.Version__c=1;
        temProd.IsActive=true;
        temProd.Product_Status__c='Ready-to-sell';
        temProd.Latest_Product_Version__c=null;
        temProd.Is_Product_Solution__c = true;
        temProd.Definition_Type__c = 'Product';
        insert temProd;

        Product2 solution1 = TestBusinessHelper.createProduct('Ocean', true);  
        solution1.OIPC_Code__c='s-p0-123';
        solution1.Portfolio__c='Ocean';
        solution1.Version__c=1;
        solution1.IsActive=true;
        solution1.Product_Status__c='Ready-to-sell';
        solution1.Latest_Product_Version__c=null;
        solution1.Is_Product_Solution__c = true;
        solution1.Definition_Type__c = 'Packaged Solution';
        update solution1;

        TestBusinessHelper.createProductReference(solution1.Id,new List<String>{lstProd1[0].Id},true);
		TestBusinessHelper.createProductReference(solution1.Id,new List<String>{temProd.id},true);
        
        Product2 solution2 = TestBusinessHelper.createProduct('Ocean', false);
        solution2.Id = null;
        solution2.OIPC_Code__c = 's-p0-123';
        solution2.Portfolio__c = 'Ocean';
        solution2.Version__c = 2;
        solution2.IsActive = true;
        solution2.Is_Product_Solution__c = true;
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
	
        Product2 prodSolution= [SELECT  Id,OIPC_Code__c,Version__c,Minor_Version__c,Increment_Version__c,Latest_Product_Version__c,isactive FROM Product2 WHERE Id=:solution1.Id limit 1];
        prodSolution.IsActive = false;
        prodSolution.Latest_Product_Version__c = solution2.Id;
        update prodSolution;
        
        Opportunity_Product__c oli= [SELECT Id,Quantity__c,UnitPrice__c,Amend_Gross_Profit_per_unit__c,Product2ID__c,Product2Id__r.Name,solution__c FROM Opportunity_Product__c where OpportunityId__c=:opp.Id];
        oli.solution__c = solution1.Id;
        update oli;
        Geography__c geoCountry = TestBusinessHelper.createGeography('United States', 'Country', null, true);
        Geography__c geoState = TestBusinessHelper.createGeography('Arizona', 'State', geoCountry.Id, true);
        
        Opportunity_Product__c opptyProduct = TestBusinessHelper.createOpportunityLineItemCustom(opp, temProd.id, null, geoCountry, geoState, true);
      //opptyProduct.Id = null;
        opptyProduct.solution__c = solution1.Id;
        update opptyProduct;
        
        TriggerExecutionController.skipProduct2Trigger(false);
        TriggerExecutionController.skipAllTriggers(false);
       

        ShowProductVersionDiffController.checkForDefinationType(null, opp.Id,true);
    }



}