public class DataGeneratorHelperCusOli_OIPC {

    static {
         // check if users are already initialized due to some other test data generator class being used in test class       
        //List<User> lstUser = [SELECT Id FROM User WHERE Maersk_User_id__c = 'INT001' LIMIT 1];   
        if ( UserDataGeneratorHelper_Test.integrationUser == null){
            UserDataGeneratorHelper_Test.initializeIntegrationUser();  
        }
    } 
    
    public static List<Trade_Route__c> createTradeRoutes (Integer count, String Operator){
        List<Trade_Route__c> lstTDR = new List<Trade_Route__c>();
        for(Integer i = 0; i < count; i++) {
            
            Trade_Route__c tdr = new Trade_Route__c();
            tdr.Description__c = 'Trade Routes'+i;
            tdr.Direction__c = 'W';
            tdr.Name = 'Trade Routes'+math.random();
            tdr.Operator__c = Operator;
            tdr.Route_Code__c = 'FA'+math.random();
            tdr.Route_Direction_Code__c = 'FAW'+math.random();
            tdr.Active__c = true;
            lstTDR.add(tdr);  
        }
        return lstTDR;
    }
    
    /*public static List<Product2> createOipcProducts (Integer count){
        
        List<Product2> lstProducts = new List<Product2>();
        
        for (integer i = 1; i <= count; i++){
            Product2 prod = new Product2();
            prod.Name = 'OIPC Product' + i;
            prod.OIPC_Code__c = 'Oipc00' + i;
            prod.Portfolio__c = 'Ocean';
            prod.Route_Direction_Code__c = 'OC' + i;
            prod.Family = 'Ocean';
            prod.IsActive = true;
            prod.Product_Owner_Name__c = UserDataGeneratorHelper_Test.integrationUser.Id;
            prod.Description = 'test record';
            lstProducts.add(prod);
        }
        return lstProducts;
    }
    
    public static List<Product_Component__c> createOipcProductComponents (Integer count, Id prodId){
        
        List<Product_Component__c> lst = new List<Product_Component__c>();
        
        for (integer i = 1; i <= count; i++){
            Product_Component__c pc = new Product_Component__c();
            pc.Name = 'Comp' + i;
            pc.Component_Code__c = 'PC' + i;
          	pc.Product__c = prodId;
            pc.Display_Order__c = i;
            lst.add(pc);
        }
        return lst;
    }
    
    public static List<Product_Feature__c> createOipcProductFeatures (Integer count, Id componentId){
        
        List<Product_Feature__c> lst = new List<Product_Feature__c>();
        for (integer i = 1; i <= count; i++){
            
            Product_Feature__c f = new Product_Feature__c();
            f.Name = 'Feature' + i;
            f.Feature_Code__c = 'PC' + i;
          	f.Product_Component__c = componentId;
            f.Display_Order__c = i;
            f.Enabled__c = true;
            f.Description__c = 'Feature description ';
            
            switch on math.mod(i,4){
                when 1 { f.Allow_Multiselect__c = true; f.Type__c = 'options';f.Default_Value__c = true; f.Options__c = 'Option1;Option2;Option3'; f.Value__c = 'Option2';}
                when 2 { f.Type__c = 'options'; f.Default_Value__c = true; f.Options__c = 'Option1;Option2;Option3'; f.Value__c = 'Option2';f.Allow_None_Value__c=true;}
                when 3 { f.Type__c = 'included';}
                when 0 { f.Type__c = 'range'; f.Value__c = '20'; f.Value_Max__c = 50; f.Value_Min__c = 10; f.Value_Unit__c = 'Kgs';}

            }
            lst.add(f);
        }
        return lst;
    }
    
    public static List<Product_Specification_Parameter__c> createProdSpecfiParams (Integer Count, Id fetureid){
        
        List<Product_Specification_Parameter__c> lstparameter = new List<Product_Specification_Parameter__c>();
        List<Boolean> booleanlist = new List<boolean>{true,false,false,true};
        List<String> strlist = new List<String>{'options','information','included','information'};
        for(integer i=0;i<Count;i++){
            Product_Specification_Parameter__c para = new Product_Specification_Parameter__c();
           // para.Name = 'test1';
            para.Name = 'Feature' + i;
            para.Specification_Parameter_Code__c = 'SP' + i;
            para.Product_Feature__c = fetureid;
            para.Display_Order__c = i;
            para.Configurable_at_Contracting__c = true;
            para.Is_Mandatory__c = true;
            para.Description__c = 'Parameter description ';  
            para.Type__c = strlist[i];
            para.Allow_Multiselect__c=booleanlist[i];
            lstparameter.add(para);
        }
        return lstparameter;
        
    }
    
     public static List<Product_Specification_Option__c> createProdSpecfiOptions ( Integer count,Id specfparamId){
        
        List<Product_Specification_Option__c> lstoption = new List<Product_Specification_Option__c>();

        for(integer i=0;i<count;i++){
            Product_Specification_Option__c opt = new Product_Specification_Option__c();
            opt.Name = 'option' + i;
            opt.Specification_Option_Name__c = 'Test123';
            opt.Specification_Option_Code__c = 'SPC' + i;
            opt.Product_Specification_Parameter__c = specfparamId;
            opt.Display_Order__c = i;
            opt.Description__c = 'option description ';  
            lstoption.add(opt);
        }
        return lstoption;
    }
    
    
    public static List<Opportunity_Product_Feature__c> createOpptyFeatures ( Id oliId, List<Id> featureIds){
        
        List<Opportunity_Product_Feature__c> lst = new List<Opportunity_Product_Feature__c>();
        
        for (Id f : featureIds){
            
            Opportunity_Product_Feature__c feature = new Opportunity_Product_Feature__c();
            feature.Name = 'Test_' + f;
          	feature.Product_Feature__c = f;
          	//feature.Opportunity_Product_Cus__c = oliId;
            //feature.Opportunity_Product__c = '00k7Y00000JHMn2QAH';
            feature.Feature_Value__c = 'sample';
            lst.add(feature);
        }
        return lst;
    }
    
    public static List<Opportunity_Product_Configuration__c> createOpptyProdCOnfigs ( Id oliId, Id SpecParamId,List<Id> SpecficalOptId){
        
        List<Opportunity_Product_Configuration__c> lst = new List<Opportunity_Product_Configuration__c>();
        
        for (Id f : SpecficalOptId){
            
            Opportunity_Product_Configuration__c oppFeatures = new Opportunity_Product_Configuration__c();
            oppFeatures.Name = 'Test_'+f;
            oppFeatures.Product_Specification_Option__c = f;
            oppFeatures.Product_Specificaiton_Parameter__c = SpecParamId;
           // oppFeatures.Opportunity_Product__c= oliId;
            oppFeatures.Opportunity_Product_Cus__c= oliId;
                 lst.add(oppFeatures);
        }
        return lst;
    }*/
}