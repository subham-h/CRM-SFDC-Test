/**
* Test Class:-ProductEventHandlerTest                
* Revision Date        Owner                	    Description
* -------- ----------  -----------				    -----------
* 1.0      28-04-23    Arpitha@maersk.com           Class will be used in Product Event Platform Event     
* 2.0      11-05-23    Samarpreet@maersk.com        Added checks for Soft coded values & bulkify the Event
* 3.0      04-09-23    Vazid      				    Added mapping for Product Category (revered)
* 4.0      20-10-23    Ramya      				    consuming integrated solution
* 5.0      12-03-24    Samar@maersk.com             Added coded to consume default values SFSE-13836
**/
public without sharing class ProductEventHandler{
    public List<Product2> lstProductUpsert = new List<Product2>();
    //added by samar
    Map<String,Product2> mapOfProduct = new Map<String,Product2>();
    Set<String> setOfProduct = new Set<String>();
    Map<String,List<Product2>> mapofAllVersion = new Map<String,List<Product2>>();
    public Map<String,Product_Component__c> mapofProductComp =new Map<String,Product_Component__c>();
    public Map<String,Product_Feature__c> mapofProductFeat =new Map<String,Product_Feature__c>();
    public Map<String,Product_Specification_Parameter__c> mapofProductspec =new Map<String,Product_Specification_Parameter__c>();
    public Map<String,Product_Specification_Option__c> mapOfOptionsUpsert = new Map<String,Product_Specification_Option__c>();
    public Map<String,Product_Specification_Option__c> mapOfOptionsValueInsert = new Map<String,Product_Specification_Option__c>();
    public Map<String,String> mapOfSoftCodeValue=  new Map<String,String>();
    public Map<String,String> mapOfproductGroupName=  new Map<String,String>();//11496
    public Map<String,String> mapOfproductGroupCode=  new Map<String,String>();//11496
    public String jsonSTR;
    public map<String,Id> existingProdComponentMap = new map<String,Id>();
    public map<String,Id> existingProdFeatureMap = new map<String,Id>();
    public map<String,Id> existingProdspecificationMap = new map<String,Id>();
    public map<String,Id> existingProdspecificationOption = new map<String,Id>();
    public map<String,Id> existingProdspecificationOptionValue = new map<String,Id>();
    public map<String,Set<productElementComponents>> productElementsComponent = new map<String,Set<productElementComponents>>();
    public map<String,List<productElementsFeature>> productElementsFeature = new map<String,List<productElementsFeature>>();
    public map<String,List<productElementsParameter>> productElementsSpecification = new map<String,List<productElementsParameter>>();
    public map<String,List<Options>> productConfigurationOptions = new map<String,List<Options>>();
    public map<String,String> productConfigurationOptionsValue = new map<String,String>();
    public map<String,Integer> mapOfProductinPackageSolution = new Map<String,Integer>();
    public map<String,Product2> mapOfProductCodeAndProduct = new Map<String,Product2>();
    Set<Product_Reference__c> setOfProductRef = new Set<Product_Reference__c>();
    
    public void onAfterInsert(List<Product_Event_Message__e>prodEveMessList){
      
        for(Product_Event_Message__e prod:prodEveMessList){
            if(prod.JSON_1__c!=null){
                jsonSTR = prod.JSON_1__c;
            }
            if(prod.JSON_2__c!=null && jsonSTR!= null){
                jsonSTR = jsonSTR + prod.JSON_2__c;  
            }
            if(prod.JSON_3__c!=null && jsonSTR!= null){
                jsonSTR =jsonSTR +  prod.JSON_3__c;
            }
            if(prod.JSON_4__c!=null &&  jsonSTR!= null){
                jsonSTR =jsonSTR +  prod.JSON_4__c;
            }
            if(prod.JSON_5__c!=null &&  jsonSTR!= null){
                jsonSTR =jsonSTR +  prod.JSON_5__c;   
            }

            if(prod.JSON_6__c!=null && jsonSTR!= null){
                jsonSTR = jsonSTR + prod.JSON_6__c;  
            }
            if(prod.JSON_7__c!=null && jsonSTR!= null){
                jsonSTR =jsonSTR +  prod.JSON_7__c;
            }
            if(prod.JSON_8__c!=null &&  jsonSTR!= null){
                jsonSTR =jsonSTR +  prod.JSON_8__c;
            }
            if(prod.JSON_9__c!=null &&  jsonSTR!= null){
                jsonSTR =jsonSTR +  prod.JSON_9__c;   
            }if(prod.JSON_10__c!=null &&  jsonSTR!= null){
                jsonSTR =jsonSTR +  prod.JSON_10__c;   
            }
            if(jsonSTR!= null){
                system.debug('jsonSTR '+ jsonSTR);
                EMPProductWrapper deserializedData = parse(jsonSTR);
                 system.debug('deserializedData '+ deserializedData);
                upsertProducts(deserializedData);
            }
           
           
        }   
    }
    
    
    public static EMPProductWrapper parse(String jsonSTR){
        return (EMPProductWrapper)JSON.deserialize(jsonStr, EMPProductWrapper.class);     
    }
   
    public void upsertProducts(EMPProductWrapper wrp){
           
        try{
            Product2 prodToUpsert = new Product2(OIPC_Code__c = wrp.productCode);

            String productVersion='';

            prodToUpsert.Version__c = wrp.productVersion.contains('.') ? Integer.valueOf(wrp.productVersion.split('[.]')[0] ) : Integer.valueOf(wrp.productVersion);
            productVersion = wrp.productCode +'-'+ prodToUpsert.Version__c;
            prodToUpsert.Minor_Version__c = wrp.productVersion.contains('.') ? wrp.productVersion.split('[.]').size() >= 2 ? Integer.valueOf(wrp.productVersion.split('[.]')[1]) :0  : 0;
            prodToUpsert.Increment_Version__c = wrp.productVersion.contains('.') ? wrp.productVersion.split('[.]').size() >=3 ? Integer.valueOf(wrp.productVersion.split('[.]')[2]) :0  : 0;
            prodToUpsert.Name=wrp.productName;
            Set<String> serviceModelValues = new Set<String>();

            if(wrp.productGroups!=null){
                for(productGroups val:wrp.productGroups){
                    if (val.productGroupCode != null && val.productGroupLevelLabel != null && val.productGroupName != null) {
                        if(val.productGroupLevelLabel == 'ProductFamily'){
                            prodToUpsert.Family_Code__c = val.productGroupCode;
                            prodToUpsert.Family=val.productGroupName;
                        } 
                        if(val.productGroupLevelLabel == 'ProductPortfolio'){
                            if(val.productGroupCode == 'LOGISTICS_AND_SERVICES'){
                                prodToUpsert.Portfolio__c='LnS';
                            }else if(val.productGroupCode == 'OCEAN'){
                                prodToUpsert.Portfolio__c='Ocean';
                            }else{
                                prodToUpsert.Portfolio__c=val.productGroupCode;
                            }
                        }
                        if(val.productGroupLevelLabel == 'ServiceModel'){
                            serviceModelValues.add(val.productGroupName);
                            //prodToUpsert.Service_Model__c=val.productGroupName;
                        }
                    }
                }
                String serviceModelString = String.join(new List<String>(serviceModelValues), ',');
                prodToUpsert.Service_Model__c = serviceModelString;
            }
             

            prodToUpsert.Description = 'This product is mastered by OIPC, please visit OIPC Description field for this information';
            prodToUpsert.Description__c = wrp.productDescriptionRichText;
            prodToUpsert.Status__c = wrp.productStatus == 'ACTIVE' ? 'Active' : wrp.productStatus == 'RETIRED' ? 'Retired': wrp.productStatus;
            if(wrp.productStatus !=null && wrp.productStatus=='ACTIVE'){
                prodToUpsert.IsActive = true;
                prodToUpsert.Product_Status__c = 'Ready-to-sell';
            }else if(wrp.productStatus !=null && wrp.productStatus=='RETIRED'){
                prodToUpsert.IsActive = false;
                prodToUpsert.Product_Status__c ='End of Sales';
            }
            prodToUpsert.Contracting__c = wrp.productContracting;
            prodToUpsert.Maturity__c = wrp.productMaturity;
            prodToUpsert.Is_Product_Solution__c = wrp.isProductSolution !=null && wrp.isProductSolution ? true: false ; //11496
            prodToUpsert.Is_Product_Add_On__c = wrp.isAddOn != null &&  wrp.isAddOn ? true: false; //11496 uncomment after getting this field in sample jason
            // quantity check 

            if(wrp.softCodedValues!=null){
               for(softCodedValues val:wrp.softCodedValues){
                    if(val.entityName != null && val.attributeName!=null ){
                        if(!mapOfSoftCodeValue.containsKey(productVersion+val.attributeName)){
                            mapOfSoftCodeValue.put(productVersion+val.attributeName,val.value);
                        }
                        if(val.attributeName == 'Product Definition Type'){
                            prodToUpsert.Definition_Type__c = val.value == 'addon'? 'Add-On Product': val.value ;
                        }
                    }
                }
            }

            prodToUpsert.Limitation__c =  mapOfSoftCodeValue.containsKey(productVersion+'Limitation') ? mapOfSoftCodeValue.get(productVersion+'Limitation').left(1999) :'';
            prodToUpsert.keyContacts__c =  mapOfSoftCodeValue.containsKey(productVersion+'Key Contacts') ? mapOfSoftCodeValue.get(productVersion+'Key Contacts').left(999) :'';
            prodToUpsert.Restriction__c =  mapOfSoftCodeValue.containsKey(productVersion+'Restriction') ? mapOfSoftCodeValue.get(productVersion+'Restriction').left(1999) :'';
            prodToUpsert.Customer_Commitments__c =  mapOfSoftCodeValue.containsKey(productVersion+'Customer Commitments') ? mapOfSoftCodeValue.get(productVersion+'Customer Commitments').left(1999) :'';
            prodToUpsert.Dependency__c =  mapOfSoftCodeValue.containsKey(productVersion+'Dependency') ? mapOfSoftCodeValue.get(productVersion+'Dependency').left(1999) :'';
            prodToUpsert.Product_Tagline__c =  mapOfSoftCodeValue.containsKey(productVersion+'Product Tagline') ? mapOfSoftCodeValue.get(productVersion+'Product Tagline').left(1999) :'';
            prodToUpsert.Twoway_Commitment_Tagline__c =  mapOfSoftCodeValue.containsKey(productVersion+'Twoway Commitment Tagline') ? mapOfSoftCodeValue.get(productVersion+'Twoway Commitment Tagline').left(999) :'';
            prodToUpsert.Customer_Need__c =  mapOfSoftCodeValue.containsKey(productVersion+'Customer Need') ? mapOfSoftCodeValue.get(productVersion+'Customer Need').left(7999) :'';
            prodToUpsert.Target_Customer_Segment__c =  mapOfSoftCodeValue.containsKey(productVersion+'Target Customer Segments') ? mapOfSoftCodeValue.get(productVersion+'Target Customer Segments').left(3999) :'';
            prodToUpsert.Target_Customer_Verticals__c =  mapOfSoftCodeValue.containsKey(productVersion+'Target Customer Verticals') ? mapOfSoftCodeValue.get(productVersion+'Target Customer Verticals').left(3999) :'';
            prodToUpsert.Sales_Channel__c =  mapOfSoftCodeValue.containsKey(productVersion+'Sales Channels') ? mapOfSoftCodeValue.get(productVersion+'Sales Channels').left(3999) :'';
            prodToUpsert.Booking_Channel__c =  mapOfSoftCodeValue.containsKey(productVersion+'Booking Channels') ? mapOfSoftCodeValue.get(productVersion+'Booking Channels').left(3999) :'';
 	
            List<String> lstOfStatus = Label.OIPCProduct_Status.split(',');	
            //if “Is Solution” is true and “products” array is not null then ignore message as its Package Solution which is out of scope
            //(wrp.isProductSolution ==true && wrp.products != null  && wrp.products.size() > 0)
             if( !lstOfStatus.contains(wrp.productStatus.toUpperCase())){             
                return;
            }
            
            setOfProduct.add(wrp.productCode);
            
            //added by samar
            mapOfProduct.put(productVersion ,prodToUpsert);
            
            if(wrp.productElements!=null){
                for(productElementComponents comp:wrp.productElements){
                    if(comp.productElementType == 'COMPONENT'){
                        if(!productElementsComponent.containskey(productVersion)){
                            comp.displayOrder=1;
                            productElementsComponent.put(productVersion,new set<productElementComponents>{comp}); 
                        } 
                        else{
                            comp.displayOrder=productElementsComponent.get(productVersion).size()+1;
                            productElementsComponent.get(productVersion).add(comp);
                        }
                        
                    }
                    if(comp.productElements!= null && comp.productElements.size()>0){
                        for(productElementsFeature features:comp.productElements){
                            if(!productElementsFeature.containskey(productVersion + comp.productElementCode)){
                                features.displayOrder=1;
                                productElementsFeature.put(productVersion + comp.productElementCode,new list<productElementsFeature>{features});   
                            }
                            else{
                                features.displayOrder=productElementsFeature.get(productVersion + comp.productElementCode).size()+1;
                                productElementsFeature.get(productVersion + comp.productElementCode).add(features);
                            }

                            if(features.productElements!= null && features.productElements.size()>0){
                                for(productElementsParameter specification:features.productElements){
                                    if(!productElementsSpecification.containskey(productVersion + comp.productElementCode + features.productElementCode)){
                                        specification.displayOrder = 1;
                                        productElementsSpecification.put(productVersion + comp.productElementCode + features.productElementCode,new list<productElementsParameter>{specification});
                                    }
                                    else{
                                        specification.displayOrder=productElementsSpecification.get(productVersion + comp.productElementCode + features.productElementCode).size()+1;
                                        productElementsSpecification.get(productVersion + comp.productElementCode + features.productElementCode).add(specification);
                                    }
                                    
                                    if(!specification.productConfigurations.isEmpty() && specification.productConfigurations!= null){
                                       for(ProductConfigurations config:specification.productConfigurations){
                                            if(config.productConfigurationType =='information' && config.predefinedAttribute !=null){
                                                productConfigurationOptionsValue.put(productVersion + comp.productElementCode + features.productElementCode + specification.productElementCode,config.predefinedAttribute.defaultValue);
                                            }
                                            if(config.productConfigurationType == 'options' && config.productConfigurationOptions != null && !config.productConfigurationOptions.isEmpty()){
                                                String defaultOption;
                                                if(config.predefinedAttribute!= null && config.predefinedAttribute.defaultValue != null){
                                                    defaultOption = config.predefinedAttribute.defaultValue;
                                                }

                                                for(Options op: config.productConfigurationOptions){
                                                    if(defaultOption!= null  && defaultOption == op.productConfigurationOptionCode){
                                                        op.isDefaultValue = true;
                                                    }
                                                    if(!productConfigurationOptions.containskey(productVersion + comp.productElementCode + features.productElementCode + specification.productElementCode)){
                                                        op.displayOrder = 1;
                                                        productConfigurationOptions.put(productVersion + comp.productElementCode + features.productElementCode + specification.productElementCode,new list<Options>{op});    
                                                    }
                                                    else{
                                                        op.displayOrder=productConfigurationOptions.get(productVersion + comp.productElementCode + features.productElementCode + specification.productElementCode).size()+1;
                                                        productConfigurationOptions.get(productVersion + comp.productElementCode + features.productElementCode + specification.productElementCode).add(op);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }   
                    }
                }   
            } 
                
            //Add all Products in solution with their version in the map for the respective Solution
            if(wrp.isProductSolution!= null &&  wrp.isProductSolution  && wrp.products!=null && wrp.products.size()>0){
                for(products prod : wrp.products){
                    if(!mapOfProductinPackageSolution.containsKey(prod.productCode)){
                        mapOfProductinPackageSolution.put(prod.productCode,Integer.valueOf(prod.productVersion)) ;
                    }
                }
            }
                
            
            List<User> user = [SELECT Id, IsActive FROM User WHERE Name ='Martyna Cybulka' AND IsActive = TRUE];

            // Check for the Product Version before inserting the Product.
            for(Product2 product:[SELECT id,OIPC_Code__c,Product_Status__c,Status__c,Version__c, IsActive, OIPC_ProductCode_Version__c,QuantityUnitOfMeasure,Product_Owner_Name__c,
                                Include_in_OMEB_Approvals__c,Include_in_SIP__c,Product_Scope__c	,Is_Features_Mandatory__c,Definition_Type__c FROM Product2 WHERE OIPC_ProductCode_Version__c IN: mapOfProduct.keySet() ]){
                if(mapOfProduct.containskey(product.OIPC_ProductCode_Version__c)){
                    mapOfProduct.get(product.OIPC_ProductCode_Version__c).Id = product.Id;
                    mapOfProduct.get(product.OIPC_ProductCode_Version__c).Product_Status__c =  mapOfProduct.get(product.OIPC_ProductCode_Version__c).Status__c == 'Active' ? 'Ready-to-sell' : mapOfProduct.get(product.OIPC_ProductCode_Version__c).Status__c == 'Retired' ? 'End of Sales': '' ; 
                    mapOfProduct.get(product.OIPC_ProductCode_Version__c).QuantityUnitOfMeasure = product.QuantityUnitOfMeasure!= null  ? product.QuantityUnitOfMeasure : 'FFE';
                    mapOfProduct.get(product.OIPC_ProductCode_Version__c).Product_Owner_Name__c = product.Product_Owner_Name__c != null? product.Product_Owner_Name__c :  !user.isEmpty() ? user[0].id:null;
                    mapOfProduct.get(product.OIPC_ProductCode_Version__c).Include_in_OMEB_Approvals__c = product.Include_in_OMEB_Approvals__c ;
                    mapOfProduct.get(product.OIPC_ProductCode_Version__c).Is_Features_Mandatory__c = product.Is_Features_Mandatory__c;
                    mapOfProduct.get(product.OIPC_ProductCode_Version__c).Include_in_SIP__c = product.Include_in_SIP__c;
                    mapOfProduct.get(product.OIPC_ProductCode_Version__c).Product_Scope__c = product.Product_Scope__c;
                }
            }

            if(!mapOfProduct.keySet().isEmpty()){
                Database.UpsertResult[] results=  Database.upsert(mapOfProduct.values(), false);
                ErrorLogger.writeErrors('SFDC', 'Product OIPC Message', 'ProductEventHandler on Product Udpate', results, mapOfProduct.values());
            }

            // Fetch all products present in packed solution 
            if(wrp.isProductSolution != null && wrp.isProductSolution && !mapOfProductinPackageSolution.keySet().isEmpty()){
                String prodQuery='';
                for(String prodOipcCode : mapOfProductinPackageSolution.keyset()){
                    prodQuery = prodQuery =='' ? ' ( OIPC_Code__c =' +'\''+ prodOipcCode +'\''+ ' AND Version__c = ' + mapOfProductinPackageSolution.get(prodOipcCode)+ ')' : prodQuery + ' OR ( OIPC_Code__c =' +'\''+ prodOipcCode +'\''+ ' AND Version__c = ' + mapOfProductinPackageSolution.get(prodOipcCode)+ ')';
                }

                String query='SELECT ID,OIPC_Code__c,Version__c  from Product2 where ' + prodQuery;
                //  Create map of oipc code and product Id
                For(Product2 prod: (List<Product2>)database.query(query)){
                    mapOfProductCodeAndProduct.put(prod.OIPC_Code__c, prod);
                }

                for(Product2 product:[SELECT id,OIPC_Code__c,Version__c,Name,Definition_Type__c,OIPC_ProductCode_Version__c,(SELECT id,  Product__c, Product_Version__c FROM Solutions__r) 
                                        FROM Product2 WHERE OIPC_ProductCode_Version__c IN: mapOfProduct.keySet() and Definition_Type__c='Packaged Solution' ]){
                    if(product.Solutions__r.size() == 0 && mapOfProductCodeAndProduct.keySet().size()>0){  // new Packaged Solution
                        for(Product2 productsInSolution :mapOfProductCodeAndProduct.values()){
                            Product_Reference__c ref=  new Product_Reference__c();
                            ref.Product__c = productsInSolution.Id;
                            ref.Solution__c = product.Id;
                            ref.name = product.name+'-'+ product.Version__c;
                            setOfProductRef.add(ref);
                        }
                    }
                }
                 
                if(!setOfProductRef.isEmpty()){
                    Database.UpsertResult[] refresults=  Database.upsert(new List<Product_Reference__c>(setOfProductRef), false);
                    ErrorLogger.writeErrors('SFDC', 'Product OIPC Message', 'ProductEventHandler on Product Udpate', refresults, new List<Product_Reference__c>(setOfProductRef));
                }
            }
            

            // comparing the latest version against the last version and upate all version except latest version to inactive status 
            for(Product2 prod:[SELECT id,OIPC_Code__c,Product_Status__c,Status__c,Version__c, IsActive, OIPC_ProductCode_Version__c,QuantityUnitOfMeasure,Product_Owner_Name__c,Product_Scope__c,
            End_of_Sales__c,End_of_Service__c,Include_in_OMEB_Approvals__c,Terms_Conditions__c,Include_in_SIP__c,Is_Features_Mandatory__c,Latest_Product_Version__c,Product_Owner_Name__r.IsActive,Product_Type__c,Type_of_Location_Needed__c FROM Product2 WHERE OIPC_Code__c IN: setOfProduct  order by Version__c desc]){//SFSE-11392 : Added Product_Category__c in SOQL Query
                if(mapofAllVersion.containsKey(prod.OIPC_Code__c) ){
                    mapofAllVersion.get(prod.OIPC_Code__c).add(prod);
                }else{
                    mapofAllVersion.put(prod.OIPC_Code__c,new List<Product2>{prod});
                }    
            }

            // Maaping values from the Old version to New version of same Product

            List<Product2> listToUpdate = new List<Product2>();
            for(String prodOipcCode:mapofAllVersion.keyset()){
                if( mapofAllVersion.get(prodOipcCode)!= null &&  mapofAllVersion.get(prodOipcCode).size()>1){
                    
                    // copying values to latest version of product Product_Type__c
                    //mapofAllVersion.get(prodOipcCode)[0].IsActive=true;
                    //mapofAllVersion.get(prodOipcCode)[0].Product_Status__c = mapofAllVersion.get(prodOipcCode)[0].Product_Status__c !=null ? mapofAllVersion.get(prodOipcCode)[0].Product_Status__c : mapofAllVersion.get(prodOipcCode)[1].Product_Status__c != null ? mapofAllVersion.get(prodOipcCode)[1].Product_Status__c:'Ready-to-sell';                    
                    mapofAllVersion.get(prodOipcCode)[0].Product_Type__c = mapofAllVersion.get(prodOipcCode)[0].Product_Type__c !=null ? mapofAllVersion.get(prodOipcCode)[0].Product_Type__c : mapofAllVersion.get(prodOipcCode)[1].Product_Type__c != null ? mapofAllVersion.get(prodOipcCode)[1].Product_Type__c:'';
                    mapofAllVersion.get(prodOipcCode)[0].QuantityUnitOfMeasure =mapofAllVersion.get(prodOipcCode)[0].QuantityUnitOfMeasure!=null ?mapofAllVersion.get(prodOipcCode)[0].QuantityUnitOfMeasure : mapofAllVersion.get(prodOipcCode)[1].QuantityUnitOfMeasure!= null  ? mapofAllVersion.get(prodOipcCode)[1].QuantityUnitOfMeasure : 'FFE';
                    mapofAllVersion.get(prodOipcCode)[0].Product_Owner_Name__c = mapofAllVersion.get(prodOipcCode)[0].Product_Owner_Name__c != null  ? mapofAllVersion.get(prodOipcCode)[0].Product_Owner_Name__c   : (mapofAllVersion.get(prodOipcCode)[1].Product_Owner_Name__c != null && mapofAllVersion.get(prodOipcCode)[1].Product_Owner_Name__r.IsActive )? mapofAllVersion.get(prodOipcCode)[1].Product_Owner_Name__c : !user.isEmpty() ? user[0].id:null;                    
                    mapofAllVersion.get(prodOipcCode)[0].Is_Features_Mandatory__c = mapofAllVersion.get(prodOipcCode)[0].Is_Features_Mandatory__c || mapofAllVersion.get(prodOipcCode)[1].Is_Features_Mandatory__c ;
                    mapofAllVersion.get(prodOipcCode)[0].Include_in_SIP__c = mapofAllVersion.get(prodOipcCode)[0].Include_in_SIP__c || mapofAllVersion.get(prodOipcCode)[1].Include_in_SIP__c ;
                    mapofAllVersion.get(prodOipcCode)[0].Include_in_OMEB_Approvals__c = mapofAllVersion.get(prodOipcCode)[0].Include_in_OMEB_Approvals__c || mapofAllVersion.get(prodOipcCode)[1].Include_in_OMEB_Approvals__c ;
                    mapOfAllVersion.get(prodOipcCode)[0].Type_of_Location_Needed__c = mapofAllVersion.get(prodOipcCode)[0].Type_of_Location_Needed__c !=null ? mapofAllVersion.get(prodOipcCode)[0].Type_of_Location_Needed__c : mapofAllVersion.get(prodOipcCode)[1].Type_of_Location_Needed__c != null ? mapofAllVersion.get(prodOipcCode)[1].Type_of_Location_Needed__c:'Origin Only';
                    mapofAllVersion.get(prodOipcCode)[0].Product_Scope__c = mapofAllVersion.get(prodOipcCode)[0].Product_Scope__c !=null ? mapofAllVersion.get(prodOipcCode)[0].Product_Scope__c : mapofAllVersion.get(prodOipcCode)[1].Product_Scope__c != null ? mapofAllVersion.get(prodOipcCode)[1].Product_Scope__c:'';
                    mapofAllVersion.get(prodOipcCode)[0].End_of_Sales__c = mapofAllVersion.get(prodOipcCode)[0].End_of_Sales__c != null ? mapofAllVersion.get(prodOipcCode)[0].End_of_Sales__c : mapofAllVersion.get(prodOipcCode)[1].End_of_Sales__c != null ? mapofAllVersion.get(prodOipcCode)[1].End_of_Sales__c:null;
                    mapofAllVersion.get(prodOipcCode)[0].End_of_Service__c = mapofAllVersion.get(prodOipcCode)[0].End_of_Service__c != null ? mapofAllVersion.get(prodOipcCode)[0].End_of_Service__c : mapofAllVersion.get(prodOipcCode)[1].End_of_Service__c != null ? mapofAllVersion.get(prodOipcCode)[1].End_of_Service__c:null;
                    mapofAllVersion.get(prodOipcCode)[0].Terms_Conditions__c=mapofAllVersion.get(prodOipcCode)[0].Terms_Conditions__c != null ? mapofAllVersion.get(prodOipcCode)[0].Terms_Conditions__c : mapofAllVersion.get(prodOipcCode)[1].Terms_Conditions__c != null ? mapofAllVersion.get(prodOipcCode)[1].Terms_Conditions__c : '';

                    for(Integer i =1; i < mapofAllVersion.get(prodOipcCode).size(); i++){

                        mapofAllVersion.get(prodOipcCode)[i].IsActive = false;
                        mapofAllVersion.get(prodOipcCode)[i].Status__c = 'Retired';
                        mapofAllVersion.get(prodOipcCode)[i].Latest_Product_Version__c = mapofAllVersion.get(prodOipcCode)[0].Id;
                        mapofAllVersion.get(prodOipcCode)[i].End_of_Service__c = mapofAllVersion.get(prodOipcCode)[0].End_of_Service__c != null ? mapofAllVersion.get(prodOipcCode)[0].End_of_Service__c : mapofAllVersion.get(prodOipcCode)[1].End_of_Service__c != null ? mapofAllVersion.get(prodOipcCode)[1].End_of_Service__c:null;
                        mapofAllVersion.get(prodOipcCode)[i].End_of_Sales__c = mapofAllVersion.get(prodOipcCode)[0].End_of_Sales__c != null ? mapofAllVersion.get(prodOipcCode)[0].End_of_Sales__c : mapofAllVersion.get(prodOipcCode)[1].End_of_Sales__c != null ? mapofAllVersion.get(prodOipcCode)[1].End_of_Sales__c:null;
                    
                        if( mapofAllVersion.get(prodOipcCode)[0].IsActive){
                            mapofAllVersion.get(prodOipcCode)[i].Product_Status__c = 'Ready-to-sell';
                        }else{
                            mapofAllVersion.get(prodOipcCode)[i].Product_Status__c = 'End of Sales';
                        }
                    }
                }else{
                    Product2 prod =mapofAllVersion.get(prodOipcCode)[0];
                   // prod.Product_Status__c = prod.Status__c == 'Active' ? 'Ready-to-sell':'';
                    prod.QuantityUnitOfMeasure = prod.QuantityUnitOfMeasure!= null  ? prod.QuantityUnitOfMeasure : 'FFE';
                    prod.Product_Owner_Name__c = prod.Product_Owner_Name__c != null && prod.Product_Owner_Name__r.IsActive ? prod.Product_Owner_Name__c : !user.isEmpty() ? user[0].id:null;
                }
                listToUpdate.addAll(mapofAllVersion.get(prodOipcCode));
            }

            if(!listToUpdate.isEmpty()){
                Database.SaveResult[] results=  Database.update(listToUpdate, false);
                ErrorLogger.writeErrors('SFDC', 'Product OIPC Message', 'ProductEventHandler on Product Udpate', results, listToUpdate);
            }

           // Querying existing Product Components
        
            List<Product_Component__c> existingProductComponents = [SELECT id,Component_Code__c,Product__r.OIPC_Code__c,Description__c,Display_Order__c,Product__c,Product__r.OIPC_ProductCode_Version__c 
                        FROM Product_Component__c WHERE Product__r.OIPC_ProductCode_Version__c IN : mapOfProduct.keySet()];
            for(Product_Component__c pc:existingProductComponents){
                existingProdComponentMap.put(pc.Product__r.OIPC_ProductCode_Version__c + pc.Component_Code__c ,pc.id);
            }
           
            for(Product2 prod:[Select id,OIPC_Code__c,Product_Status__c,Status__c,OIPC_ProductCode_Version__c  from Product2 where OIPC_ProductCode_Version__c IN:mapOfProduct.keySet()]){
               
                if(productElementsComponent.containskey(prod.OIPC_ProductCode_Version__c) && productElementsComponent.get(prod.OIPC_ProductCode_Version__c)!=null){
                    for(productElementComponents prodComp:productElementsComponent.get(prod.OIPC_ProductCode_Version__c)){
                        Product_Component__c pc = new Product_Component__c();
                        if(existingProdComponentMap.containskey(prod.OIPC_ProductCode_Version__c + prodComp.productElementCode) && existingProdComponentMap.get(prod.OIPC_ProductCode_Version__c + prodComp.productElementCode)!=null){
                            pc.id =  existingProdComponentMap.get(prod.OIPC_ProductCode_Version__c + prodComp.productElementCode);       
                        }
                        pc.Name=prodComp.productElementName;
                        pc.Component_Code__c=prodComp.productElementCode;
                        pc.Description__c = prodComp.productElementDescription;
                        pc.Product__c=prod.id;
                        pc.Display_Order__c= prodComp.displayOrder;
                        if(!mapofProductComp.containsKey(prod.OIPC_ProductCode_Version__c + prodComp.productElementCode)){
                            mapofProductComp.put(prod.OIPC_ProductCode_Version__c + prodComp.productElementCode, pc);
                        }
                        //lstProductComponent.add(pc);
                    }    
                }
            }

           // Update the product Component 
          
            if(mapofProductComp.values().size()>0){
                Database.UpsertResult[] results1=  Database.upsert(mapofProductComp.values(),false);   
                ErrorLogger.writeErrors('SFDC', 'Product OIPC Message', 'ProductEventHandler on ProductComponent Udpate', results1, mapofProductComp.values()); 
            }
            
            // Querying existing Product Featue
            
            Id featureRecordType = Schema.SObjectType.Product_Feature__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
            for(Product_Feature__c feature:[SELECT id,Feature_Code__c,Description__c,name,Product_Component__c,Product_Component__r.Component_Code__c, Product_Component__r.Product__r.OIPC_Code__c,Product_Component__r.Product__r.OIPC_ProductCode_Version__c FROM Product_Feature__c WHERE Product_Component__c IN:mapofProductComp.values() AND recordtypeId =: featureRecordType ]){
                existingProdFeatureMap.put(feature.Product_Component__r.Product__r.OIPC_ProductCode_Version__c + feature.Product_Component__r.Component_Code__c + feature.Feature_Code__c,feature.id);
            }



            for(Product_Component__c prodComp:[Select id,Product__r.OIPC_ProductCode_Version__c,Component_Code__c from Product_Component__c where Id IN:mapofProductComp.values()]){
                if(productElementsFeature.containskey(prodComp.Product__r.OIPC_ProductCode_Version__c +  prodComp.Component_Code__c) && productElementsFeature.get(prodComp.Product__r.OIPC_ProductCode_Version__c +  prodComp.Component_Code__c)!=null){
                    for(productElementsFeature feature:productElementsFeature.get(prodComp.Product__r.OIPC_ProductCode_Version__c + prodComp.Component_Code__c)){
                        Product_Feature__c features = new Product_Feature__c();
                        if(existingProdFeatureMap.containskey(prodComp.Product__r.OIPC_ProductCode_Version__c + prodComp.Component_Code__c + feature.productElementCode) && existingProdFeatureMap.get(prodComp.Product__r.OIPC_ProductCode_Version__c + prodComp.Component_Code__c + feature.productElementCode)!=null){
                            features.id = existingProdFeatureMap.get(prodComp.Product__r.OIPC_ProductCode_Version__c + prodComp.Component_Code__c + feature.productElementCode);
                        }
                        features.recordtypeId = featureRecordType;
                        features.Name = feature.productElementName;
                        features.Feature_Code__c = feature.productElementCode;
                        features.Description__c = feature.productElementDescription;
                        features.Product_Component__c = prodComp.id;
                        features.Display_Order__c = feature.displayOrder;

                        if(feature.productConfigurations!=null  && !feature.productConfigurations.isEmpty()){
                            if(feature.productConfigurations[0].productConfigurationType == 'options'){
                                features.Categorisation__c = feature.productConfigurations[0].isService ? 'Service' : 'No Service';
                                features.Configurable_at_Contracting__c = feature.productConfigurations[0].isContractConfigurable;
                                features.Default_Visibility__c = feature.productConfigurations[0].predefinedAttribute.defaultValue == 'INCLUDED' || feature.productConfigurations[0].predefinedAttribute.defaultValue =='NOT_INCLUDED' ? feature.productConfigurations[0].predefinedAttribute.defaultValue : '';
                                //features.Optionality__c = feature.productConfigurations[0].predefinedAttribute.defaultValue =='INCLUDED' && !feature.productConfigurations[0].isContractConfigurable ? 'Core' : feature.productConfigurations[0].predefinedAttribute.defaultValue =='NOT_INCLUDED' && feature.productConfigurations[0].isContractConfigurable ? 'Optional':'';
                            }
                        }else{
                            features.Categorisation__c = 'No Service';
                        }


                        if(!mapofProductFeat.containskey(prodComp.Product__r.OIPC_ProductCode_Version__c + prodComp.Component_Code__c + feature.productElementCode)){
                            mapofProductFeat.put(prodComp.Product__r.OIPC_ProductCode_Version__c + prodComp.Component_Code__c + feature.productElementCode,features);
                        }
                    }
                }    
            }

            if(mapofProductFeat.values().size()>0){
                Database.UpsertResult[] results2=  Database.upsert(mapofProductFeat.values(),false);     
                ErrorLogger.writeErrors('SFDC', 'Product OIPC Message', 'ProductEventHandler on ProductFeature Udpate', results2, mapofProductFeat.values());
            }

           

            // Querying existing Product Specification
            List<Product_Specification_Parameter__c>existingProductSpecification = [Select id,Specification_Parameter_Code__c,Product_Feature__c,Product_Feature__r.Feature_Code__c,Product_Feature__r.Product_Component__r.Component_Code__c, Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c from Product_Specification_Parameter__c where Product_Feature__c IN:mapofProductFeat.values()];
            for(Product_Specification_Parameter__c spec:existingProductSpecification){
                existingProdspecificationMap.put(spec.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c + spec.Product_Feature__r.Product_Component__r.Component_Code__c + spec.Product_Feature__r.Feature_Code__c + spec.Specification_Parameter_Code__c, spec.id );
            }


            for(Product_Feature__c prodFeature:[SELECT id,Product_Component__r.Product__r.OIPC_ProductCode_Version__c,Product_Component__r.Component_Code__c,Feature_Code__c FROM Product_feature__c WHERE ID IN: mapofProductFeat.values()]){
                if(productElementsSpecification.containskey(prodfeature.Product_Component__r.Product__r.OIPC_ProductCode_Version__c + prodfeature.Product_Component__r.Component_Code__c+  prodFeature.Feature_Code__c) && productElementsSpecification.get(prodfeature.Product_Component__r.Product__r.OIPC_ProductCode_Version__c + prodfeature.Product_Component__r.Component_Code__c + prodFeature.Feature_Code__c)!=null){
                    for(productElementsParameter specification:productElementsSpecification.get(prodfeature.Product_Component__r.Product__r.OIPC_ProductCode_Version__c + prodfeature.Product_Component__r.Component_Code__c + prodFeature.Feature_Code__c)){
                        Product_Specification_Parameter__c spec = new Product_Specification_Parameter__c();    
                        if(existingProdspecificationMap.containskey(prodfeature.Product_Component__r.Product__r.OIPC_ProductCode_Version__c + prodfeature.Product_Component__r.Component_Code__c +    prodFeature.Feature_Code__c + specification.productElementCode) && 
                                                                    existingProdspecificationMap.get(prodfeature.Product_Component__r.Product__r.OIPC_ProductCode_Version__c + prodfeature.Product_Component__r.Component_Code__c + prodFeature.Feature_Code__c + specification.productElementCode)!=null){
                            spec.id = existingProdspecificationMap.get( prodfeature.Product_Component__r.Product__r.OIPC_ProductCode_Version__c + prodfeature.Product_Component__r.Component_Code__c+  prodFeature.Feature_Code__c + specification.productElementCode);        
                        }
                        spec.Product_Feature__c = prodFeature.id;
                        spec.Name = specification.productElementName;
                        spec.Specification_Parameter_Code__c = specification.productElementCode;
                        spec.Description__c  = specification.productElementDescription;
                        // spec.Configurable_at_Contracting__c = specification.isContractConfigurable;
                        spec.Display_Order__c= specification.displayOrder;
                        spec.type__c = productConfigurationOptionsValue.containskey(prodfeature.Product_Component__r.Product__r.OIPC_ProductCode_Version__c + prodfeature.Product_Component__r.Component_Code__c+  prodFeature.Feature_Code__c + specification.productElementCode) ? 'information': 'options';
                        
                        if(specification.productConfigurations!=null  && !specification.productConfigurations.isEmpty()){
                            for(ProductConfigurations config:specification.productConfigurations){
                                
                                if((config.productConfigurationType == 'options') && config.productConfigurationOptions == null){
                                    //spec.Optionality__c = config.predefinedAttribute.defaultValue == 'INCLUDED' && !config.isContractConfigurable ? 'Core' : config.predefinedAttribute.defaultValue =='NOT_INCLUDED' && config.isContractConfigurable ? 'Optional':'';
                                    spec.Sales_Configurable__c = config.isRelevantForSalesUser;//11496
                                    spec.Configurable_at_Contracting__c = config.isContractConfigurable;
                                    spec.Default_Visibility__c = config.predefinedAttribute.defaultValue == 'INCLUDED' ||  config.predefinedAttribute.defaultValue =='NOT_INCLUDED' ?  config.predefinedAttribute.defaultValue : '';
                        	    spec.type__c = (config.predefinedAttribute.defaultValue == 'NOT_INCLUDED' &&  !config.isContractConfigurable) ? 'information' : spec.type__c!= null ?spec.type__c:'';
                                    
                                }else if(config.productConfigurationType == 'options' && config.productConfigurationOptions != null){
                                    spec.type__c = (config.productConfigurationType == 'options' && config.productConfigurationOptions != null && !config.isContractConfigurable) ? 'information' : 'options';

                                    if(config.isContractConfigurableMultiSelectable!= null){
                                        spec.Allow_Multiselect__c = config.isContractConfigurableMultiSelectable;
                                    }
                                    if(config.isContractConfigurableRequired!= null){
                                        spec.Is_Mandatory__c = config.isContractConfigurableRequired;
                                    }
                                }else if(config.productConfigurationType == 'information' && config.productConfigurationOptions != null){
                                    if(config.isContractConfigurableMultiSelectable!= null){
                                        spec.Allow_Multiselect__c = config.isContractConfigurableMultiSelectable;
                                    }
                                    if(config.isContractConfigurableRequired!= null){
                                        spec.Is_Mandatory__c = config.isContractConfigurableRequired;
                                    }
                                }
                            }
                        }

                        if(!mapofProductspec.containsKey(prodfeature.Product_Component__r.Product__r.OIPC_ProductCode_Version__c + prodfeature.Product_Component__r.Component_Code__c +prodFeature.Feature_Code__c + specification.productElementCode)){
                            mapofProductspec.put(prodfeature.Product_Component__r.Product__r.OIPC_ProductCode_Version__c + prodfeature.Product_Component__r.Component_Code__c +prodFeature.Feature_Code__c + specification.productElementCode,spec);

                        }
                        // lstSpecificationUpsert.add(spec); 
                    }
                }
            }

            if(mapofProductspec.values().size()>0){
                Database.UpsertResult[] results3=   Database.upsert(mapofProductspec.values(),false);   
                ErrorLogger.writeErrors('SFDC', 'Product OIPC Message', 'ProductEventHandler on ProductSpecification Udpate', results3, mapofProductspec.values());  
            }


            // Querying existing/new Product Specification
            List<Product_Specification_Parameter__c> existingProductSpecificationAf = [Select id,Specification_Parameter_Code__c,Product_Feature__c,Product_Feature__r.Feature_Code__c,Product_Feature__r.Product_Component__r.Component_Code__c, Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c from Product_Specification_Parameter__c 
            where Id IN:mapofProductspec.values()];

            // Querying existing Product Specification
            List<Product_Specification_Option__c> existingProdSpecOption = [Select id,Description__c,Product_Specification_Parameter__c,Specification_Option_Code__c,Specification_Option_Name__c,Product_Specification_Parameter__r.Specification_Parameter_Code__c,Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c,Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c, 
                                                                            Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c,Product_Specification_Parameter__r.Type__c from Product_Specification_Option__c where Product_Specification_Parameter__c IN:mapofProductspec.values() ];
            for(Product_Specification_Option__c op:existingProdSpecOption){
                // 2 map - options and informations
                if(op.Specification_Option_Code__c != null){
                existingProdspecificationOption.put(op.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c + op.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c+ op.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c +  op.Product_Specification_Parameter__r.Specification_Parameter_Code__c+op.Specification_Option_Code__c,op.id);            
                }else{
                    existingProdspecificationOptionValue.put(op.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c + op.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c+ op.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c +  op.Product_Specification_Parameter__r.Specification_Parameter_Code__c,op.id);            
                }
            }

            for(Product_Specification_Parameter__c spec:existingProductSpecificationAf){
            if(productConfigurationOptions.containskey(spec.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c +spec.Product_Feature__r.Product_Component__r.Component_Code__c+spec.Product_Feature__r.Feature_Code__c+spec.Specification_Parameter_Code__c) 
                                && productConfigurationOptions.get(spec.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c +spec.Product_Feature__r.Product_Component__r.Component_Code__c+spec.Product_Feature__r.Feature_Code__c+spec.Specification_Parameter_Code__c)!=null){
                for(Options ops:productConfigurationOptions.get(spec.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c +spec.Product_Feature__r.Product_Component__r.Component_Code__c+spec.Product_Feature__r.Feature_Code__c+spec.Specification_Parameter_Code__c)){
                        Product_Specification_Option__c op = new Product_Specification_Option__c();
                        if(!existingProdspecificationOption.containskey(ops.productConfigurationOptionCode)){//11496
                            op.Product_Specification_Parameter__c = spec.id;
                        }
                        if(existingProdspecificationOption.containskey(spec.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c +spec.Product_Feature__r.Product_Component__r.Component_Code__c+spec.Product_Feature__r.Feature_Code__c+spec.Specification_Parameter_Code__c+ops.productConfigurationOptionCode) 
                        && existingProdspecificationOption.get(spec.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c +spec.Product_Feature__r.Product_Component__r.Component_Code__c+spec.Product_Feature__r.Feature_Code__c+spec.Specification_Parameter_Code__c+ops.productConfigurationOptionCode)!=null){
                            op.id = existingProdspecificationOption.get(spec.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c +spec.Product_Feature__r.Product_Component__r.Component_Code__c+spec.Product_Feature__r.Feature_Code__c+spec.Specification_Parameter_Code__c+ops.productConfigurationOptionCode);
                        }
                        //11496
                        op.Name = ops.productConfigurationOptionName.length() > 79 ?  ops.productConfigurationOptionName.substring(0,79):  ops.productConfigurationOptionName;
                        op.Specification_Option_Name__c = ops.productConfigurationOptionName.length() > 254 ?  ops.productConfigurationOptionName.substring(0,254):  ops.productConfigurationOptionName;
                    	op.Description__c = ops.productConfigurationOptionDescription;//11496
                        op.Specification_Option_Code__c = ops.productConfigurationOptionCode;//11496
                        op.Display_Order__c = ops.displayOrder;
                        op.isDefaultValue__c =  ops.isDefaultValue != null && ops.isDefaultValue ? true: false;
                        if(!mapOfOptionsUpsert.containskey(spec.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c +spec.Product_Feature__r.Product_Component__r.Component_Code__c+spec.Product_Feature__r.Feature_Code__c+spec.Specification_Parameter_Code__c+ops.productConfigurationOptionCode)){
                            mapOfOptionsUpsert.put(spec.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c +spec.Product_Feature__r.Product_Component__r.Component_Code__c+spec.Product_Feature__r.Feature_Code__c+spec.Specification_Parameter_Code__c+ops.productConfigurationOptionCode,op);
                        }
                    }
                }
            }

            
            if(mapOfOptionsUpsert.values().size()>0){
                Database.UpsertResult[] results4=   Database.upsert(mapOfOptionsUpsert.values(),false);
                ErrorLogger.writeErrors('SFDC', 'Product OIPC Message', 'ProductEventHandler on option Udpate', results4, mapOfOptionsUpsert.values());
            }
            
            for(Product_Specification_Parameter__c spec:existingProductSpecificationAf){
                if(productConfigurationOptionsValue.containskey(spec.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c +spec.Product_Feature__r.Product_Component__r.Component_Code__c+spec.Product_Feature__r.Feature_Code__c+spec.Specification_Parameter_Code__c)
                && productConfigurationOptionsValue.get(spec.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c +spec.Product_Feature__r.Product_Component__r.Component_Code__c+spec.Product_Feature__r.Feature_Code__c+spec.Specification_Parameter_Code__c)!=null){
                    String valueText = productConfigurationOptionsValue.get(spec.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c +spec.Product_Feature__r.Product_Component__r.Component_Code__c+spec.Product_Feature__r.Feature_Code__c+spec.Specification_Parameter_Code__c);
                    Product_Specification_Option__c opVal = new Product_Specification_Option__c();


                    if(!existingProdspecificationOptionValue.containskey(spec.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c +spec.Product_Feature__r.Product_Component__r.Component_Code__c+spec.Product_Feature__r.Feature_Code__c+spec.Specification_Parameter_Code__c)){
                        opVal.Product_Specification_Parameter__c = spec.id;    
                    }
                    if(existingProdspecificationOptionValue.containskey(spec.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c +spec.Product_Feature__r.Product_Component__r.Component_Code__c+spec.Product_Feature__r.Feature_Code__c+spec.Specification_Parameter_Code__c) 
                    && existingProdspecificationOptionValue.get(spec.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c +spec.Product_Feature__r.Product_Component__r.Component_Code__c+spec.Product_Feature__r.Feature_Code__c+spec.Specification_Parameter_Code__c)!=null){
                        opVal.id = existingProdspecificationOptionValue.get(spec.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c +spec.Product_Feature__r.Product_Component__r.Component_Code__c+spec.Product_Feature__r.Feature_Code__c+spec.Specification_Parameter_Code__c);
                    }
                    opVal.name = valueText.left(79);
                    opVal.Specification_Option_Name__c = valueText.left(254);
                    opVal.Description__c = valueText;
                    opVal.Display_Order__c= 1;
                    if(!mapOfOptionsValueInsert.containskey(spec.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c +spec.Product_Feature__r.Product_Component__r.Component_Code__c+spec.Product_Feature__r.Feature_Code__c+spec.Specification_Parameter_Code__c)){
                        mapOfOptionsValueInsert.put(spec.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c +spec.Product_Feature__r.Product_Component__r.Component_Code__c+spec.Product_Feature__r.Feature_Code__c+spec.Specification_Parameter_Code__c,opVal);
                        
                    }
                }
            }

            if(mapOfOptionsValueInsert.values().size()>0){
                Database.UpsertResult[] results5=    Database.upsert(mapOfOptionsValueInsert.values(),false);
                ErrorLogger.writeErrors('SFDC', 'Product OIPC Message', 'ProductEventHandler on option Udpate', results5, mapOfOptionsValueInsert.values());
            }
        }catch(Exception ex){
            ErrorLogger.writeErrors('SFDC', 'Product OIPC Message', 'ProductEventHandler.upsertProducts', new list<Exception>{ex});
        }    
    }

    
    public class EMPProductWrapper{
    
        public String productCode{get;set;}
        public String productVersion{get;set;}
        public String productName{get;set;}
        public String productDescriptionRichText{get;set;}
        public String productDescription{get;set;}
        public String productStatus{get;set;}
        public boolean isProductSolution{get;set;}//11496
        public boolean isAddOn{get;set;}//11496
        public String addOnRelationDefault{get;set;}
        public String productContracting{get;set;}
        public List<productGroups> productGroups{get;set;}//11496
        public String productMaturity{get;set;}
        public List<SoftCodedValues> softCodedValues{get;set;}
        public List<products> products{get;set;}//11496
        public List<productElementComponents> productElements{get;set;}
        public EMPProductWrapper(){
            isAddOn = false;
            isProductSolution = false;
            softCodedValues = new List<SoftCodedValues>();
            productGroups = new List<productGroups>();//11496
            products = new List<products>();//11496
            productElements = new List<productElementComponents>();
        }
    }
    public class productGroups{//11496
        public String productGroupCode{get;set;}
        public String productGroupDescription{get;set;}
        public String productGroupName{get;set;}
        public String productGroupLevelLabel{get;set;}
    }

    public class products{//11496
        public String productCode{get;set;}
        public String productVersion{get;set;}
        public String productName{get;set;}
        public String productGroupDescription {get;set;}
    }

    public class SoftCodedValues{
        public String entityName{get; set;}
        public String attributeName{get; set;}
        public String dataType{get;set;}
        public String value{get;set;}
        public String sequence{get; set;}
    }
    
    public class ProductElementComponents{
        public String productElementType{get; set;}
        public String productElementCode{get; set;}
        //public String productElementVersion{get;set;}
        public String productElementName{get;set;}
        public String productElementDescription{get; set;}
        public list<productElementsFeature> productElements{get;set;}
        public List<ProductConfigurations> productConfigurations{get;set;}
        public Integer displayOrder{get;set;}
        public productElementComponents(){
            productElements= new List<productElementsFeature>();
            displayOrder = 0;
            productConfigurations = new List<ProductConfigurations>();
        }
    }
    
    public class ProductElementsFeature{
        public String productElementType {get; set;}
        public String productElementCode {get; set;}
        //public String productElementVersion {get;set;}
        public String productElementName {get;set;}
        public String productElementDescription {get; set;}
        public Integer displayOrder {get;set;}
      
        public List<ProductConfigurations> productConfigurations{get;set;}
        public list<productElementsParameter> productElements{get;set;}
        public productElementsFeature(){
            productElements= new List<productElementsParameter>();
            productConfigurations = new List<ProductConfigurations>();
            displayOrder = 0;
        }
    }
    
    public class ProductElementsParameter{
        //public String productElementType{get; set;}
        public String productElementCode{get; set;}
       // public String productElementVersion{get;set;}
        public String productElementName{get;set;}
        public String productElementDescription{get; set;}
        public List<ProductConfigurations> productConfigurations{get;set;}
        // public Boolean isContractConfigurable{get;set;}
        // public Boolean isContractConfigurableRequired{get;set;}
        // public Boolean isContractConfigurableMultiSelectable{get;set;}
        // public Boolean isServiceConfigurable{get;set;}
        public Integer displayOrder{get;set;}
        public productElementsParameter(){
            productConfigurations = new List<ProductConfigurations>();
            displayOrder = 0;
        }
    }

    public class ProductConfigurations{
        public String productConfigurationType{get;set;}
        public Boolean isService{get;set;}
        public String valueAddedServiceCode{get;set;}
        public PredefinedAttribute predefinedAttribute {get;set;}
        public list<Options> productConfigurationOptions{get;set;}  
        public Boolean isRelevantForSalesUser{get;set;}//11496
        public Boolean isContractConfigurable{get;set;}
        public Boolean isContractConfigurableRequired{get;set;}
        public Boolean isContractConfigurableMultiSelectable{get;set;} 
        public Boolean isServiceConfigurable{get;set;}
        public Boolean isServiceConfigurableMultiSelectable{get;set;}
        public Boolean isServiceConfigurableRequired{get;set;}
        public ProductConfigurations(){
            productConfigurationOptions = new List<Options>();
        }
    }
    
    public class PredefinedAttribute{
        public String attributeName{get;set;}
        public String dataType{get;set;}
        public List<String> enumeratedValues {get;set;}
        public String defaultValue{get;set;}
        public PredefinedAttribute(){
            enumeratedValues = new List<String>();
        }
    }

    

    public class Options{
        public String productConfigurationOptionCode{get;set;}//11496
        public String productConfigurationOptionName{get;set;}//11496
        public String productConfigurationOptionDescription{get;set;}//11496
        public Integer displayOrder{get;set;}
        public boolean isDefaultValue {get;set;}
        public Options(){
            displayOrder = 0;
            isDefaultValue = false;
        }
    }
       
       
}