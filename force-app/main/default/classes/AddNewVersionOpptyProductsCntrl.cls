/**
* 1.0		16/06/2023		sriram@maersk			SFSE-11594		
* 2.0       08/09/2023      ramya                   SFSE-12054      -     Added new optionality structure for configurations
* 3.0       13/02/2024      ramadevi@maersk.com     SFSE-13892            Upgrade all the opportunity products with the product references available from the latest version of the solution 
**/
public class AddNewVersionOpptyProductsCntrl {
    public static Set<Opportunity_Product_Configuration__c> listofSptoUpsert = new Set<Opportunity_Product_Configuration__c>();
    public static List<Opportunity_Product_Configuration__c> opcListToDelete = new List<Opportunity_Product_Configuration__c>();
    
    //Get The Opportunity Products for which new version of the Product is available 
    @AuraEnabled
    public static ProductList getNewVersions(Id recId) {
        
        ProductList prodListwrapper = new ProductList();
        Boolean hasSolution = false;
        map<String,OpptyProduct> mapofProduct = new Map<String,OpptyProduct>();

        //to do commented this Product2Id__r.Latest_Product_sVersion__c
       for( Opportunity_Product__c optyLineItem : [SELECT Id,Product2Id__c,Product2ID__r.OIPC_Code__c,Product2ID__r.Name, Country__r.Name, Executing_City_State__r.Name, Trade_Route__r.Name,
                                                        Product2Id__r.isActive,Product2Id__r.Latest_Product_Version__c,Solution__r.isActive, Solution__r.Latest_Product_Version__c,Solution__c,Solution__r.OIPC_Code__c,Solution__r.Name
                                                        FROM Opportunity_Product__c WHERE OpportunityId__c =: recId AND ( (Product2Id__r.isActive = false AND Product2Id__r.Latest_Product_Version__c !=null) OR (Solution__r.isActive = false AND Solution__r.Latest_Product_Version__c !=null)) ]){
            if(optyLineItem.solution__c != null && optyLineItem.Solution__r.isActive == false && optyLineItem.Solution__r.Latest_Product_Version__c !=null){
                hasSolution = true; 
                OpptyProduct tempProduct= new OpptyProduct();
                tempProduct.country = '';
                tempProduct.key = optyLineItem.Solution__r.OIPC_Code__c;
                tempProduct.productName = optyLineItem.Solution__r.Name;
                tempProduct.tradeRoute = '';
                tempProduct.oliId = optyLineItem.Id;
                if(!mapofProduct.containsKey(optyLineItem.Solution__r.OIPC_Code__c)){
                    mapofProduct.put(optyLineItem.Solution__r.OIPC_Code__c,tempProduct ) ;
                }

            }else if (optyLineItem.solution__c == null && optyLineItem.Product2Id__r.isActive == false && optyLineItem.Product2Id__r.Latest_Product_Version__c !=null){
                hasSolution = hasSolution ? true:false;
                OpptyProduct tempProduct= new OpptyProduct();
                tempProduct.country = optyLineItem.Country__r.Name != null ? optyLineItem.Country__r.Name :'';
                tempProduct.key = optyLineItem.Product2Id__r.OIPC_Code__c;
                tempProduct.productName = optyLineItem.Product2Id__r.Name;
                tempProduct.tradeRoute = optyLineItem.Trade_Route__r.Name != null ?optyLineItem.Trade_Route__r.Name:'';
                tempProduct.oliId = optyLineItem.Id;
                if(!mapofProduct.containsKey(optyLineItem.Product2Id__r.OIPC_Code__c)){
                    mapofProduct.put(optyLineItem.Product2Id__r.OIPC_Code__c,tempProduct ) ;
                }
            }
        }
        prodListwrapper.isSolution = hasSolution;
       
        if(!mapofProduct.keySet().isEmpty()){
            prodListwrapper.oliRecList.addAll(mapofProduct.values());
        }
        system.debug('prodListwrapper=='+prodListwrapper);
        return prodListwrapper;
    }
    
    
    //Update Opprtunity Product with new Product Version and Update related OpporhandleRowSelectiontunity Configuration 
    @AuraEnabled
    public static String updateOpportunityProducts(list<string> oipcCode,Id recId) {
        Map<Id,String> mapOfOLIandProductName= new  Map<Id,String> ();
        Id solutionProduct ;
        String returnMessage = 'success';
        try{ 
            //SFSE-13892 - Changes to update the solution in Opportunity product
            Boolean isSolution = false;
            // create a map of Oipc code and Procut map with latest versions
            map<string,Product2> oipcProdcutMap = new map<string,Product2>();

            for(Product2 prod:[SELECT id, OIPC_Code__c,name,Definition_Type__c  FROM Product2 WHERE OIPC_Code__c In:oipcCode and isActive = true ]){
                //SFSE-13892 - To identify if solution/product to be updated in Opportunity Product
                if(prod.Definition_Type__c == 'Packaged Solution'){
                    isSolution = true;
                    solutionProduct = prod.id;
                }
                oipcProdcutMap.put(prod.OIPC_Code__c,prod);
            }
            
            //Query Products related the Opportunity and latest Product Version 
            String queryString = 'select id,Product2Id__c,Product2ID__r.OIPC_Code__c,Product2ID__r.Name,Solution__c,Definition_Type__c from  Opportunity_Product__c';
            if(isSolution==true){
                queryString = queryString + ' where ( (Solution__r.OIPC_Code__c =: oipcCode AND Definition_Type__c ='+  '\'' +'Packaged Solution'+ '\'' +  ') or (Product2ID__r.OIPC_Code__c In: oipcCode AND Definition_Type__c !='+  '\'' +'Packaged Solution'+ '\'' +  ') ) and OpportunityId__c =: recId';
            } else {
                queryString = queryString + ' where Product2ID__r.OIPC_Code__c In: oipcCode AND Definition_Type__c !='+  '\'' +'Packaged Solution'+ '\'' +  ' and OpportunityId__c =: recId';
            }
            System.debug('queryString==>'+queryString);
            list<Opportunity_Product__c> oldProdList = Database.query(queryString);
            System.debug('oldProdList'+ oldProdList.size());
            for(Opportunity_Product__c prod:oldProdList ){
                 System.debug('oldProdList'+ prod);
            }
            //SFSE-13892 - Get the Products for new solution
            
                Map<String,Id> newSolProductsMap = new Map<String,Id>();
            if(isSolution==true){
                for (Product_Reference__c prodRef:[SELECT Id,Product__c, Product__r.OIPC_Code__c FROM Product_Reference__c WHERE Solution__c =:solutionProduct]) {        
                    newSolProductsMap.put(prodRef.Product__r.OIPC_Code__c,prodRef.Product__c);                        
                }
                system.debug('newSolProductsMap==>'+newSolProductsMap);
            }

            
            list<Opportunity_Product__c> finalListToUpdate = new list<Opportunity_Product__c>();
            for(Opportunity_Product__c oppProd:oldProdList){
                if(!mapOfOLIandProductName.containsKey(oppProd.ID)){
                    mapOfOLIandProductName.put(oppProd.ID,oppProd.Product2ID__r.Name);
                }
                Opportunity_Product__c oppProdtoUpdate = new Opportunity_Product__c();
                oppProdtoUpdate = oppProd;
                //SFSE-13892 -Solution and product has to be updated in Opp Prod
               if(oppProdtoUpdate.Solution__c!= null){
                    oppProdtoUpdate.Product2Id__c = newSolProductsMap.containsKey(oppProd.Product2ID__r.OIPC_Code__c) ? newSolProductsMap.get(oppProd.Product2ID__r.OIPC_Code__c):oppProdtoUpdate.Product2Id__c;
                    oppProdtoUpdate.Solution__c = solutionProduct;
                } else{
                    oppProdtoUpdate.Product2Id__c = oipcProdcutMap.containsKey(oppProd.Product2ID__r.OIPC_Code__c) ?  oipcProdcutMap.get(oppProd.Product2ID__r.OIPC_Code__c).id:oppProdtoUpdate.Product2Id__c;
                }
                finalListToUpdate.add(oppProdtoUpdate);
                
            }
            system.debug('finalListToUpdate==>'+finalListToUpdate);
            
            Bypass_Product_Upgrade_Validation__c bt1= Bypass_Product_Upgrade_Validation__c.getInstance();
            system.debug('test11'+bt1);
            bt1.Skip_Validation__c = true;
            insert bt1;

            //Opportunity Products to Update 
            system.debug('test12'+finalListToUpdate);
            update finalListToUpdate;
            
            Map< Id,Opportunity_Product__c> oppProductwithStandalone = new Map<Id,Opportunity_Product__c>();
            Map< Id,Opportunity_Product__c> oppProductwithSolution = new Map<Id, Opportunity_Product__c>();
            for(Opportunity_Product__c opptyproduct:  [SELECT id,Product2Id__c,Product2ID__r.OIPC_Code__c,solution__c FROM  Opportunity_Product__c WHERE id In: finalListToUpdate]){
                if(opptyproduct.solution__c!= null){
                    oppProductwithSolution.put( opptyproduct.id,opptyproduct);
                }else{
                    oppProductwithStandalone.put( opptyproduct.id,opptyproduct);
                }
            }
            
            //Create or delete Product Configuration 
            if(!oppProductwithStandalone.keyset().isempty()){
                createConfigurations( oppProductwithStandalone.values(), new List<Id>(oppProductwithStandalone.keyset()));
            } 
            
            if(!oppProductwithSolution.keyset().isempty()){
                createConfigurations(  oppProductwithSolution.values(), new List<Id>(oppProductwithSolution.keyset()));
            } 
            
            //Delete Unused Product Configuration 
            if(opcListToDelete.size()>0){
                delete opcListToDelete;
            }
            
        
            
            //Upsert new Product Configurations 
            if(listofSptoUpsert.size()>0){
                Upsert new List<Opportunity_Product_Configuration__c>(listofSptoUpsert);
            }
            
            //test 

            Bypass_Product_Upgrade_Validation__c bt2= Bypass_Product_Upgrade_Validation__c.getInstance();
            delete bt2;
                
        }catch(DMLException e){ 
            returnMessage='';
           // System.debug('Exception '+e.getMessage());
           // returnMessage = e.getMessage();
            Bypass_Product_Upgrade_Validation__c bt2= Bypass_Product_Upgrade_Validation__c.getInstance();
            delete bt2;
            for(Integer i=0; i < e.getNumDml(); i++) {
                returnMessage = returnMessage + e.getDmlMessage(i).unescapeHtml4() + '; ';
            }
            ErrorLogger.writeErrors( 'SFDC', 'AddNewVersionOpptyProductsCntrl', 'AddNewVersionOpptyProductsCntrl.updateOpportunityProducts', new list<Exception>{e});
        }
        //Prepare map of Opportunity Product and new update Product 
        return returnMessage;
    }

    public class ProductList{      
        @AuraEnabled 
        public  Boolean isSolution {get; set;}
        @AuraEnabled 
        public  List<OpptyProduct> oliRecList{get; set;}
        public ProductList(){
            isSolution = false;
            oliRecList = new List<OpptyProduct>();
        }
    }
    public class OpptyProduct{
        @AuraEnabled 
        public  String productName {get; set;}
        @AuraEnabled 
        public  String country {get; set;}
        @AuraEnabled 
        public  String tradeRoute {get; set;}
        @AuraEnabled 
        public  String key {get; set;}
        @AuraEnabled 
        public  Id oliId {get; set;}        
    }


    public static void createConfigurations(List<Opportunity_Product__c> oppProdUpdated, List<Id> oldProductlist){
        String profeatRecordTypeID = Schema.getGlobalDescribe().get('Product_Feature__c').getDescribe().getRecordTypeInfosByName().get(System.Label.FeatureRecordType).getRecordTypeId();
            map<id,list<Opportunity_Product__c>> prodOppMap = new  map<id,list<Opportunity_Product__c>>();
            for(Opportunity_Product__c prod:oppProdUpdated){
                if(prodOppMap.containsKey(prod.Product2Id__c)){
                    prodOppMap.get(prod.Product2Id__c).add(prod);
                }else{
                    prodOppMap.put(prod.Product2Id__c,new list<Opportunity_Product__c>{prod}); // 
                }
            }
            
            
            list<Opportunity_Product_Configuration__c> oppConfig = [select id,Name,Opportunity_Product_Cus__c,Opportunity_Product_Cus__r.Product2Id__c,Product_Feature__c,Configured_Product_Feature__r.Feature_Code__c,
            Product_Specificaiton_Parameter__c,Specification_Parameter_Code__c,Specification_Option_Code__c,Is_Feature_Included__c,Is_Specification_Parameter_Included__c,
            Configured_Product_Component__c,Configured_Product_Feature__c,Feature_Default_Visibility__c,Specification_Param_Default_Visibility__c,Feature_Code__c
            from Opportunity_Product_Configuration__c where Opportunity_Product_Cus__c In:oldProductlist];
                
            
            // query Product components
            Map<Id, Product_Component__c> lstComponents = new Map<Id, Product_Component__c>([SELECT Id, Name, Component_Code__c, Product__c
                                                                                             FROM Product_Component__c 
                                                                                             WHERE Product__c IN:prodOppMap.keySet() ORDER BY Display_Order__c,Name]);
            
            
            
            // for above fetched components get Product Features
            Map<Id,Product_Feature__c> lstFeatures = new Map<Id,Product_Feature__c>([SELECT Id, Name,Product_Component__c, Type__c, Value__c    , Default_Value__c, Options__c, Allow_Multiselect__c, Description__c,
            Allow_None_Value__c, Value_Min__c, Value_Max__c, Value_Unit__c, Product_Component__r.Product__c, Choice_Required__c//8854
            ,Default_Visibility__c,Configurable_at_Contracting__c,Feature_Code__c FROM Product_Feature__c   WHERE Product_Component__c in :lstComponents.keySet() AND RecordTypeId=:profeatRecordTypeID 
                                                                                     AND (Categorisation__c =: 'Service' OR Categorisation__c=:'') ORDER BY Display_Order__c,Name]);
            
            
            
            map<Id,Product_Specification_Parameter__c> mapofProdSpecParams = new Map<Id,Product_Specification_Parameter__c>([SELECT Id, Name, Specification_Parameter_Code__c, Product_Feature__c, Type__c, 
                                                                                                                             Product_Feature__r.Product_Component__r.Product__c,Product_Feature__r.Description__c,Product_Feature__r.Default_Visibility__c,
                                                                                                                             Display_Order__c, Product_Feature__r.name,Feature_Code__c,Product_Feature__r.Product_Component__c,Description__c,Default_Visibility__c
                                                                                                                             FROM Product_Specification_Parameter__c 
                                                                                                                             WHERE Product_Feature__c in :lstFeatures.keySet() AND Type__c='options' ]);
            map<string,Product_Specification_Parameter__c> SpcodetoSp = new map<string,Product_Specification_Parameter__c>();
            
            for(Product_Specification_Parameter__c sp:mapofProdSpecParams.values()){
                SpcodetoSp.put(sp.Specification_Parameter_Code__c,sp);                
            }

            map<string,Product_Feature__c> codetoPF = new map<string,Product_Feature__c>();
            for(Product_Feature__c sp:lstFeatures.values()){
                codetoPF.put(sp.Feature_Code__c,sp);                
            }
            
            //specification perameter code vs option code 
            map<string,string> specParamCodeToSpecOptionCode = new map<string,string>();
            map<string,list<Opportunity_Product_Configuration__c>> specParamCodeToconfiguration = new map<string,list<Opportunity_Product_Configuration__c>>();
            map<string,list<Opportunity_Product_Configuration__c>> feartureCodeToconfiguration = new map<string,list<Opportunity_Product_Configuration__c>>();
            set<string> OptionstoQuery = new set<string>();
          
            
            for(Opportunity_Product_Configuration__c oppPc:oppConfig){
                
                if(SpcodetoSp.containsKey(oppPc.Specification_Parameter_Code__c)){ // check new defination have old parameter 
                    
                    specParamCodeToSpecOptionCode.put(oppPc.Opportunity_Product_Cus__c+'-'+oppPc.id,oppPc.Specification_Option_Code__c);
                   
                    if(!specParamCodeToconfiguration.containsKey(oppPc.Opportunity_Product_Cus__c+'-'+oppPc.Specification_Parameter_Code__c)){
                        specParamCodeToconfiguration.put(oppPc.Opportunity_Product_Cus__c+'-'+oppPc.Specification_Parameter_Code__c,new list<Opportunity_Product_Configuration__c> {oppPc});
                    }else{
                        specParamCodeToconfiguration.get(oppPc.Opportunity_Product_Cus__c+'-'+oppPc.Specification_Parameter_Code__c).add(oppPc);
                    }        
                    
                    if( oppPc.Specification_Option_Code__c != null){
                        OptionstoQuery.add(oppPc.Specification_Option_Code__c);
                    }
                }else if(codetoPF.containsKey(oppPc.Configured_Product_Feature__r.Feature_Code__c) && oppPc.Product_Specificaiton_Parameter__c == null && oppPc.Is_Feature_Included__c){ 
                    
                    if(!feartureCodeToconfiguration.containsKey(oppPc.Opportunity_Product_Cus__c+'-'+oppPc.Configured_Product_Feature__r.Feature_Code__c)){
                        feartureCodeToconfiguration.put(oppPc.Opportunity_Product_Cus__c+'-'+oppPc.Configured_Product_Feature__r.Feature_Code__c,new list<Opportunity_Product_Configuration__c> {oppPc});
                    }else{
                        feartureCodeToconfiguration.get(oppPc.Opportunity_Product_Cus__c+'-'+oppPc.Configured_Product_Feature__r.Feature_Code__c).add(oppPc);
                    }    
                    
                }else{
                    opcListToDelete.add(oppPc);
                }
            }
            
            
            map<string,Id> spocTospocId = new map<string,Id>();
            //Query Specification options by code and get the new list and prepare a map of SPOC vs SPO ID
          list<Product_Specification_Option__c> spOption = [SELECT id,Specification_Option_Code__c,Product_Specification_Parameter__c,Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.name from Product_Specification_Option__c 
															  WHERE Specification_Option_Code__c In:OptionstoQuery AND 
												              Product_Specification_Parameter__c IN :mapofProdSpecParams.keyset() AND
															  Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__c IN:prodOppMap.keySet()];
            
            for(Product_Specification_Option__c spo:spOption){
                spocTospocId.put( spo.Product_Specification_Parameter__c + spo.Specification_Option_Code__c,spo.id);
            }
            
            
            
            

            Set<String> featMatrix = new Set<String>();
        
            Map<String,String> matrixMap = new Map<String,String>();
            for(SP_Visibility_matrix__mdt rec :  SP_Visibility_matrix__mdt.getAll().values()){
                if(rec.Product_Upgrade__c==true){
                    matrixMap.put(rec.Default_Visibility_Features__c+'-'+rec.Default_Visibility_SP__c,rec.Default_Visibility_SP__c);
                    featMatrix.add(rec.Default_Visibility_Features__c);
                }
            }

            for(Product_Specification_Parameter__c ps:mapofProdSpecParams.values()){
                for(Opportunity_Product__c opc: prodOppMap.get(ps.Product_Feature__r.Product_Component__r.Product__c))
                {
                    list<Opportunity_Product_Configuration__c> configRec = new list<Opportunity_Product_Configuration__c>();                    
                     if(specParamCodeToconfiguration.containsKey(opc.id+'-'+ps.Specification_Parameter_Code__c)){ 
                        configRec = specParamCodeToconfiguration.get(opc.id+'-'+ps.Specification_Parameter_Code__c);
                    }
                    //Update the configuration with new version of the SP and Options 
                    if(configRec.size()>0){
                       
                        for(Opportunity_Product_Configuration__c config:configRec){ 
                           
                            string optionCode = specParamCodeToSpecOptionCode.get(opc.id+'-'+config.id);
                            Opportunity_Product_Configuration__c opcObj = new Opportunity_Product_Configuration__c();
                            opcObj = config;
                            opcObj.Product_Specificaiton_Parameter__c  =  ps.id;      
                            opcObj.Is_Specification_Parameter_Included__c  =  config.Is_Specification_Parameter_Included__c;                            
                            opcObj.Product_Specification_Option__c  =  spocTospocId.containsKey( ps.id + optionCode) ?spocTospocId.get( ps.id + optionCode): null ;
                            opcObj.Name = ps.Product_Feature__r.name;
                            opcObj.Is_Feature_Included__c = config.Is_Feature_Included__c;
                            opcObj.Configured_Product_Component__c = ps.Product_Feature__r.Product_Component__c;
                            opcObj.Configured_Product_Feature__c = ps.Product_Feature__c;
                            listofSptoUpsert.add(opcObj);
                        }                    
                    }else{
                        if(matrixMap.get(ps.Product_Feature__r.Default_Visibility__c+'-'+ps.Default_Visibility__c)=='INCLUDED'){ 
                         //Create the configuration with new  SP   //Map<Opportunity_Product__c,Feat ID>
                            Opportunity_Product_Configuration__c opcObj = new Opportunity_Product_Configuration__c();
                            opcObj.Opportunity_Product_Cus__c  = opc.id;
                            opcObj.Product_Specificaiton_Parameter__c  =  ps.id;
                            opcObj.Name = ps.Product_Feature__r.name;
                            opcObj.Is_Specification_Parameter_Included__c = true;
                            opcObj.Is_Feature_Included__c = true;
                            opcObj.Configured_Product_Component__c = ps.Product_Feature__r.Product_Component__c;
                            opcObj.Configured_Product_Feature__c = ps.Product_Feature__c;
							listofSptoUpsert.add(opcObj);
    
}                    }
                }
            }
        
        for(Product_Feature__c pf:lstFeatures.values()){
             list<Opportunity_Product_Configuration__c> configRec = new list<Opportunity_Product_Configuration__c>();  
            for(Opportunity_Product__c opc: prodOppMap.get(pf.Product_Component__r.Product__c)) {             
                                 
                 if(feartureCodeToconfiguration.containsKey(opc.id+'-'+pf.Feature_Code__c)){ 
                    configRec = feartureCodeToconfiguration.get(opc.id+'-'+pf.Feature_Code__c);
                }
                //Update the configuration with new version of the SP and Options 
                if(configRec.size()>0){
                    for(Opportunity_Product_Configuration__c config:configRec){ 
                        Opportunity_Product_Configuration__c opcObj = new Opportunity_Product_Configuration__c();
                        //opcObj.Opportunity_Product_Cus__c  = opc.id;
                        opcoBj= config;
                        opcObj.Configured_Product_Feature__c  =  pf.id;   
                        opcObj.Configured_Product_Component__c = pf.Product_Component__c;
                        opcObj.Name = pf.Name;
                        opcObj.Is_Feature_Included__c = config.Is_Feature_Included__c;
						listofSptoUpsert.add(opcObj);
                    
                    }                    
                }else{
                        if(featMatrix.contains(pf.Default_Visibility__c)){
                        Opportunity_Product_Configuration__c opcObj = new Opportunity_Product_Configuration__c();
                        //opcObj = config;
                        opcObj.Opportunity_Product_Cus__c  = opc.id;
                        opcObj.Configured_Product_Feature__c  =  pf.id;   
                        opcObj.Configured_Product_Component__c = pf.Product_Component__c;
                        opcObj.Name = pf.Name;
                        opcObj.Is_Feature_Included__c = true;
                        listofSptoUpsert.add(opcObj);
                    }
                }
            }
        }        
    }
}