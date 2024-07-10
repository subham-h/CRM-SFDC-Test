/**
Test Class:-ShowProductVersionDiffController_Test            
* Revision Date        Owner                	    Description
* -------- ----------  -----------				    -----------
* 1.0      13-06-23    Samar@maersk.com           

**/
public without sharing class ShowProductVersionDiffController {
   
    public static Map<String,Set<String>> mapofCompRemoved = new Map<String,Set<String>>();
    public static Map<String,Set<String>> mapofCompAdded = new Map<String,Set<String>>();
    public static Map<String,Set<String>> mapofFeatRemoved = new Map<String,Set<String>>();
    public static Map<String,Set<String>> mapofFeatAdded = new Map<String,Set<String>>();
    public static Map<String,Set<String>> mapofparaRemoved = new Map<String,Set<String>>();
    public static Map<String,Set<String>> mapofparaAdded = new Map<String,Set<String>>();
    public static Map<String,Set<String>> mapofOptRemoved = new Map<String,Set<String>>();
    public static Map<String,Set<String>> mapofOptAdded = new Map<String,Set<String>>();

    public static Map<String,set<String>> mapOfComponenttoProcess = new Map<String,Set<String>>();
    public static Map<String,List<Component>> mapOfOliAndComponent = new Map<String,List<Component>>();
    public static Map<String,List<Feature>> mapOfCompIdandFeature= new Map<String,List<Feature>>();

    @AuraEnabled(Cacheable= true)
    public static DifferenceWrapper getDifference(Id oliId,Id recId,Boolean isSolution, Id currentVersion, Id lastestVersion,Opportunity_Product__c oli){ //Id recId, Boolean isSolution, Id currentVersion, Id lastestVersion,Opportunity_Product__c oli
        //List<Id> product2Ids= new List<Id>();
        system.debug('oliId==>'+oliId);
        system.debug('recId==>'+recId);
        system.debug('isSolution==>'+isSolution);
        system.debug('currentVersion==>'+currentVersion);
        system.debug('lastestVersion==>'+lastestVersion);
        system.debug('oli==>'+oli);

        Map<String,Set<String>> mapofVersionComp = new  Map<String,Set<String>>();// To store OIPC product version and set of strings
        Map<String,Map<String,Set<String>>> mapofVersionFeat = new  Map<String,Map<String,Set<String>>>();  
        Map<String,Map<String,Set<String>>> mapofVersionPara = new  Map<String,Map<String,Set<String>>>();  
        Map<String,Map<String,Set<String>>> mapofVersionOpt = new  Map<String,Map<String,Set<String>>>();
        Map<Id,String> mapofProductName = new Map<Id,String>();

        Map<String,Component> mapOfCompCodeAndComp = new Map<String,Component>();
        Map<String,Feature> mapOfFeatureCodeAndFeat = new Map<String,Feature>();
        Map<String,Parameter> mapOfParaCodeAndPara = new Map<String,Parameter>();
        Map<String,Option> mapOfOptionCodeAndOpt = new Map<String,Option>();



        Map<String,List<Component>> mapOfOipcVersionandComp = new Map<String,list<Component>>();

        Map<Id,String> mapOfoliandOldVersion = new map<Id,String>();// To store oli id and the old OIPC product version  
        Map<Id,String> mapOfoliandNewVersion = new map<Id,String>();// To store oli id and the new OIPC product version  
        Map<String,Id> mapofOIPCVerionandProductId = new Map<String,Id>(); // to coment out
        Map<Id,Set<String>> mapOfOLliIdandversion = new map<Id,Set<String>>(); // to store oli id and List of String of OIPC product version      
        try {
            //Flip the map along with queries for Solutions and normal products
            /*if(!isSolution){
                for(Opportunity_Product__c oli:[SELECT id, Product2ID__c,Product2ID__r.OIPC_ProductCode_Version__c , Product2ID__r.Latest_Product_Version__c, Product2ID__r.Latest_Product_Version__r.OIPC_ProductCode_Version__c,Product2Id__r.Name
                                                FROM  Opportunity_Product__c WHERE Id =: oliId AND OpportunityID__c =:recId ]){
                                                // product2Ids.add(oli.Product2ID__c,oli.Product2ID__r.Latest_Product_Version__c);

                    if(!mapofProductName.containsKey(oli.id)){
                        mapofProductName.put(oli.id,oli.Product2Id__r.Name);
                    }
                    if(!mapOfOLliIdandversion.containsKey(oli.id)){
                        mapOfOLliIdandversion.put(oli.id,new Set<String>{oli.Product2ID__r.OIPC_ProductCode_Version__c,oli.Product2ID__r.Latest_Product_Version__r.OIPC_ProductCode_Version__c });
                    }                                

                    if(!mapofOIPCVerionandProductId.containsKey(oli.Product2ID__r.OIPC_ProductCode_Version__c)){
                        mapofOIPCVerionandProductId.put(oli.Product2ID__r.OIPC_ProductCode_Version__c,oli.Product2ID__c);
                    }

                    if(!mapofOIPCVerionandProductId.containsKey(oli.Product2ID__r.Latest_Product_Version__r.OIPC_ProductCode_Version__c )){
                        mapofOIPCVerionandProductId.put(oli.Product2ID__r.Latest_Product_Version__r.OIPC_ProductCode_Version__c ,oli.Product2ID__r.Latest_Product_Version__c);
                    }

                    if(!mapOfoliandOldVersion.containsKey(oli.Id)){
                        mapOfoliandOldVersion.put(oli.id,oli.Product2ID__r.OIPC_ProductCode_Version__c);
                    }
                    if(!mapOfoliandNewVersion.containsKey(oli.Id)){
                        mapOfoliandNewVersion.put(oli.id,oli.Product2ID__r.Latest_Product_Version__r.OIPC_ProductCode_Version__c);
                    }
                }
            }else{*/
                if(!mapofProductName.containsKey(oliId)){
                    mapofProductName.put(oliId,oli.Product2Id__r.Name);
                } 
                List<Id> lstProductid= new List<Id>();
                if(currentVersion != null && lastestVersion!= null ){
                    lstProductid.add(currentVersion);
                    lstProductid.add(lastestVersion);
                }
                Map<Id,product2> mapofProduct = new Map<Id,Product2>();
                for(Product2 prod:[SELECT Id,OIPC_ProductCode_Version__c,oipc_code__c,Name,version__c FROM Product2 WHERE ID IN:lstProductid ]){
                   if(!mapofProduct.containsKey(prod.Id)){
                        mapofProduct.put(prod.Id,prod);
                    } 
                }

                if(!mapOfOLliIdandversion.containsKey(oli.id)){
                    mapOfOLliIdandversion.put(oli.id,new Set<String>{mapofProduct.get(currentVersion).OIPC_ProductCode_Version__c,mapofProduct.get(lastestVersion).OIPC_ProductCode_Version__c });
                }

                if(!mapofOIPCVerionandProductId.containsKey(mapofProduct.get(currentVersion).OIPC_ProductCode_Version__c)){
                    mapofOIPCVerionandProductId.put(mapofProduct.get(currentVersion).OIPC_ProductCode_Version__c,mapofProduct.get(currentVersion).Id);
                }

                if(!mapofOIPCVerionandProductId.containsKey(mapofProduct.get(lastestVersion).OIPC_ProductCode_Version__c)){
                    mapofOIPCVerionandProductId.put(mapofProduct.get(lastestVersion).OIPC_ProductCode_Version__c,mapofProduct.get(lastestVersion).Id);
                }

                if(!mapOfoliandOldVersion.containsKey(oli.Id)){
                    mapOfoliandOldVersion.put(oli.id,mapofProduct.get(currentVersion).OIPC_ProductCode_Version__c);
                }

                if(!mapOfoliandNewVersion.containsKey(oli.Id)){
                    mapOfoliandNewVersion.put(oli.id,mapofProduct.get(lastestVersion).OIPC_ProductCode_Version__c);
                }

            //}

            if(!mapofOIPCVerionandProductId.values().isEmpty()){
                for(Product_specification_option__c opt:[SELECT id, Specification_Option_Name__c, Specification_Option_Code__c, Product_Specification_Parameter__r.name , Product_Specification_Parameter__r.ID,      
                                                        Product_Specification_Parameter__r.Specification_Parameter_Code__c,  Product_Specification_Parameter__r.Configurable_at_Contracting__c, Product_Specification_Parameter__r.Is_Mandatory__c,  Product_Specification_Parameter__r.Sales_Configurable__c,
                                                        Product_Specification_Parameter__r.Product_Feature__r.name, Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c, product_Specification_Parameter__r.Product_Feature__r.Id,product_Specification_Parameter__r.Product_Feature__r.Categorisation__c,
                                                        Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c, Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Name, Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.ID,
                                                        Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c, Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.Version__c  
                                                        FROM Product_Specification_Option__c 
                                                        WHERE Product_Specification_Parameter__r.Sales_Configurable__c = true AND Specification_Option_Code__c!= null AND Product_Specification_Parameter__r.Type__c ='options' 
                                                        AND Product_Specification_Parameter__r.Product_Feature__r.RecordType.name='Feature'
                                                        AND Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__c IN :mapofOIPCVerionandProductId.values() ]){
                    
                    if(mapofVersionComp.containsKey(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c)){
                        mapofVersionComp.get(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c).add(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c);
                    }else{
                        mapofVersionComp.put(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c , new Set<String>{opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c});
                    }

                    //feature map
                    if(mapofVersionFeat.containsKey(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c)){
                        if(mapofVersionFeat.get(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c).containsKey(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c)){
                            mapofVersionFeat.get(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c).get(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c).add(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c +'-'+  opt.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c);
                        }else{
                            mapofVersionFeat.get(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c).put(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c,new Set<String>{ opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c +'-'+ opt.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c});
                        }
                    }else{
                        mapofVersionFeat.put(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c,new Map<String,Set<String>>{ opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c => new Set<String>{opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c +'-'+ opt.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c}} );
                    }

                    //parameter map
                    if(mapofVersionPara.containsKey(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c)){
                        if(mapofVersionPara.get(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c).containsKey(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c +'-'+ opt.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c)){
                            mapofVersionPara.get(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c).get(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c +'-'+ opt.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c).add(opt.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c +'-'+ opt.Product_Specification_Parameter__r.Specification_Parameter_Code__c);
                        }else{
                            mapofVersionPara.get(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c).put(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c +'-'+ opt.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c,new Set<String>{ opt.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c +'-'+ opt.Product_Specification_Parameter__r.Specification_Parameter_Code__c});
                        }
                    }else{
                        mapofVersionPara.put(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c, new Map<String,Set<String>>{opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c +'-'+ opt.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c => new Set<String>{ opt.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c +'-'+ opt.Product_Specification_Parameter__r.Specification_Parameter_Code__c}});
                    }

                    //option code
                    if(mapofVersionOpt.containsKey(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c)){
                        if(mapofVersionOpt.get(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c).containsKey(opt.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c +'-'+ opt.Product_Specification_Parameter__r.Specification_Parameter_Code__c)){
                            mapofVersionOpt.get(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c).get(opt.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c +'-'+ opt.Product_Specification_Parameter__r.Specification_Parameter_Code__c).add(opt.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c +'-'+ opt.Product_Specification_Parameter__r.Specification_Parameter_Code__c +'-'+ opt.Specification_Option_Code__c);
                        }else{
                            mapofVersionOpt.get(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c).put(opt.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c +'-'+ opt.Product_Specification_Parameter__r.Specification_Parameter_Code__c, new Set<String>{ opt.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c +'-'+ opt.Product_Specification_Parameter__r.Specification_Parameter_Code__c +'-'+ opt.Specification_Option_Code__c});
                        }
                    }else{
                        mapofVersionOpt.put(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c, new Map<String,Set<String>>{opt.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c +'-'+ opt.Product_Specification_Parameter__r.Specification_Parameter_Code__c=> new Set<String>{ opt.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c +'-'+ opt.Product_Specification_Parameter__r.Specification_Parameter_Code__c +'-'+opt.Specification_Option_Code__c}});
                    }

                    // Version +'-'+ Component code
                    if(!mapOfCompCodeAndComp.containskey(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c+'-'+opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c)){
                        Component comp= new Component();
                        comp.componentCode = opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c;
                        comp.componentId = opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Id;
                        comp.componentName = opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Name;
                        mapOfCompCodeAndComp.put(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c+'-'+opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c,comp);
                    }
                    // Version +'-'+ Component code + Feature code
                    if(!mapOfFeatureCodeAndFeat.containsKey(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c+'-'+opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c+'-'+opt.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c)){
                        Feature feat= new Feature();
                        feat.componentId = opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Id;
                        feat.componentCode = opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c;
                        feat.featureCode = opt.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c ;
                        feat.featureId = opt.Product_Specification_Parameter__r.Product_Feature__r.Id;
                        feat.isService = opt.Product_Specification_Parameter__r.Product_Feature__r.Categorisation__c == null ? 'Service': opt.Product_Specification_Parameter__r.Product_Feature__r.Categorisation__c == 'Service' ? 'Service': 'Non_Service';
                        feat.featureName = opt.Product_Specification_Parameter__r.Product_Feature__r.name;
                        mapOfFeatureCodeAndFeat.put(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c+'-'+opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c+'-'+opt.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c, feat);
                    }
                    // Version +'-'+ Feature code + Parameter code
                    if(!mapOfParaCodeAndPara.containsKey(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c+'-'+opt.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c+'-'+opt.Product_Specification_Parameter__r.Specification_Parameter_Code__c)){
                        Parameter para=  new Parameter();
                        para.componentCode = opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c;
                        para.parameterCode = opt.Product_Specification_Parameter__r.Specification_Parameter_Code__c;
                        para.parameterId = opt.Product_Specification_Parameter__r.Id;
                        para.featureId = opt.Product_Specification_Parameter__r.Product_Feature__r.Id;
                        para.parameterName =  opt.Product_Specification_Parameter__r.name;
                        mapOfParaCodeAndPara.put(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c+'-'+opt.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c+'-'+opt.Product_Specification_Parameter__r.Specification_Parameter_Code__c,para);
                    }
                     // Version +'-'+ Feature code + Parameter code + Option code
                    if(!mapOfOptionCodeAndOpt.containsKey(opt.Specification_Option_Code__c)){
                        Option op= new Option();
                        op.componentCode = opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Component_Code__c;
                        op.optionCode = opt.Specification_Option_Code__c;
                        // op.optionId = opt.Id;
                        // op.parameterId = opt.Product_Specification_Parameter__r.Id;
                        // op.featureId = opt.Product_Specification_Parameter__r.Product_Feature__r.Id;
                        op.optionName = opt.Specification_Option_Name__c;
                        mapOfOptionCodeAndOpt.put(opt.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_ProductCode_Version__c+'-'+opt.Product_Specification_Parameter__r.Product_Feature__r.Feature_Code__c+'-'+opt.Product_Specification_Parameter__r.Specification_Parameter_Code__c +'-'+opt.Specification_Option_Code__c,op);
                    }


                }
            }

            findDifferenceinComponents(mapOfoliandOldVersion, mapOfoliandNewVersion, mapofVersionComp, mapOfOLliIdandversion, mapOfCompCodeAndComp); 
            findDifferenceinFeatures(mapOfoliandOldVersion, mapOfoliandNewVersion, mapofVersionFeat, mapOfOLliIdandversion, mapOfFeatureCodeAndFeat);
            findDifferenceParameters(mapOfoliandOldVersion, mapOfoliandNewVersion, mapofVersionPara, mapOfOLliIdandversion, mapOfParaCodeAndPara);
            findDifferenceOptions(mapOfoliandOldVersion, mapOfoliandNewVersion, mapofVersionOpt, mapOfOLliIdandversion, mapOfOptionCodeAndOpt);
            /*
            System.debug('mapOfComponenttoProcess '+ mapOfComponenttoProcess.keySet());
            System.debug('mapOfComponenttoProcess '+ mapOfComponenttoProcess);

            System.debug('mapOfoliandOldVersion==>'+mapOfoliandOldVersion);
            System.debug('mapOfoliandNewVersion==>'+mapOfoliandNewVersion);
            System.debug('mapofVersionComp==>'+mapofVersionComp);
            System.debug('mapOfOLliIdandversion==>'+mapOfOLliIdandversion);
            System.debug('mapOfCompCodeAndComp==>'+mapOfCompCodeAndComp);
            */
            createOLItoCompMap(mapOfoliandOldVersion, mapOfoliandNewVersion, mapofVersionComp, mapOfOLliIdandversion, mapOfCompCodeAndComp);
            //System.debug('mapOfComponenttoProcess '+ mapOfOliAndComponent);
            
           createCompToFeatureMap(mapOfOLliIdandversion,mapofVersionComp,mapofVersionFeat,mapofVersionPara,mapofVersionOpt,mapOfCompCodeAndComp,mapOfFeatureCodeAndFeat,mapOfParaCodeAndPara,mapOfOptionCodeAndOpt);
			//system.debug('mapOfCompIdandFeature '+ mapOfCompIdandFeature );
            /*
            if(!mapofOIPCVerionandProductId.keySet().isEmpty()){

                for(String oipcVersion : mapofOIPCVerionandProductId.keyset()){
                    List<Component> compList = new List<Component>();
                    if(mapofVersionComp.containsKey(oipcVersion)){
                        for(String compCode: mapofVersionComp.get(oipcVersion)){
                            Component comp = mapOfCompCodeAndComp.get(oipcVersion+'-'+compCode);
                            if(mapofVersionFeat.containsKey(oipcVersion) && mapofVersionFeat.get(oipcVersion).containsKey(compCode)){
                                for(String featcode: mapofVersionFeat.get(oipcVersion).get(compCode)){
                                    Feature feat = mapOfFeatureCodeAndFeat.get(oipcVersion+'-'+compCode+'-'+featcode);
                                    if(mapofVersionPara.containsKey(oipcVersion) && mapofVersionPara.get(oipcVersion).containsKey(featcode)){
                                        for(String paramCode:mapofVersionPara.get(oipcVersion).get(featcode)){
                                            Parameter para= mapOfParaCodeAndPara.get(oipcVersion+'-'+featcode+'-'+paramCode);
                                            if(mapofVersionOpt.containsKey(oipcVersion) && mapofVersionOpt.get(oipcVersion).containsKey(paramCode)){
                                                for(String optionCode: mapofVersionOpt.get(oipcVersion).get(paramCode)){
                                                    Option opt=mapOfOptionCodeAndOpt.get(optionCode);
                                                    para.items.add(opt);
                                                }
                                            }
                                            feat.items.add(para);
                                        }
                                    }
                                    comp.items.add(feat);
                                }
                            }
                            compList.add(comp);
                        }
                    } 
                    system.debug('compList ' + compList);
                    mapOfOipcVersionandComp.put(oipcVersion,compList);
                }
            }
            */

            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        System.debug(mapOfOipcVersionandComp);

        DifferenceWrapper diff= new DifferenceWrapper();
        //diff.mapOfOipcVersionandComp = mapOfOipcVersionandComp;
        diff.mapofOIPCVerionandProductId = mapofOIPCVerionandProductId;
        diff.mapOfOLliIdandversion = mapOfOLliIdandversion;
        diff.mapOfoliandOldVersion = mapOfoliandOldVersion;
        diff.mapOfoliandNewVersion = mapOfoliandNewVersion;
        diff.mapOfOliAndComponent = mapOfOliAndComponent;
        diff.mapOfCompIdandFeature = mapOfCompIdandFeature;
        diff.mapofProductName= mapofProductName;
        return diff;
    }

    public static void findDifferenceinComponents(Map<Id,String> mapOfoliandOldVersion, Map<Id,String> mapOfoliandNewVersion, Map<String,Set<String>> mapofVersionComp, Map<Id,Set<String>> mapOfOLliIdandversion, Map<String,Component> mapOfCompCodeAndComp  ){


        for(Id oli:mapOfOLliIdandversion.keySet()){
            system.debug('mapOfOLliIdandversion.get(oli)==>'+mapOfOLliIdandversion.get(oli));
            if(mapOfOLliIdandversion.get(oli).size()== 2){
                List<String> oipcVersion= new List<String>(mapOfOLliIdandversion.get(oli));
                if(mapofVersionComp.containsKey(oipcVersion[0]) &&  mapOfoliandOldVersion.containsKey(oli) && mapOfoliandOldVersion.get(oli) == oipcVersion[0] ){
                    for(String compCode: mapofVersionComp.get(oipcVersion[0])){
                        if( mapofVersionComp.get(oipcVersion[0]) == null || !mapofVersionComp.get(oipcVersion[1]).contains(compCode)){ // Component is removed from new Version of Product
                            mapOfCompCodeAndComp.get(oipcVersion[0]+'-'+compCode).isRemoved = true;
                            mapOfCompCodeAndComp.get(oipcVersion[0]+'-'+compCode).noChange = false;
                            if(!mapOfComponenttoProcess.containsKey(oipcVersion[0])){
                                mapOfComponenttoProcess.put(oipcVersion[0],new Set<String>{compCode});
                            }else{
                                mapOfComponenttoProcess.get(oipcVersion[0]).add(compCode);
                            }

                            if(!mapofCompRemoved.containsKey(oipcVersion[0])){
                                mapofCompRemoved.put(oipcVersion[0],new Set<String>{compCode});
                            }else{
                                mapofCompRemoved.get(oipcVersion[0]).add(compCode);
                            }
                        }
                    }
                }

                if(mapofVersionComp.containsKey(oipcVersion[1]) &&  mapOfoliandNewVersion.containsKey(oli) && mapOfoliandNewVersion.get(oli) == oipcVersion[1] ){
                    for(String compCode: mapofVersionComp.get(oipcVersion[1])){
                        system.debug('test debug'+ mapofVersionComp.get(oipcVersion[0]));
                        if( mapofVersionComp.get(oipcVersion[0]) == null || !mapofVersionComp.get(oipcVersion[0]).contains(compCode)){ // new Component is added Version of Product
                            mapOfCompCodeAndComp.get(oipcVersion[1]+'-'+compCode).isAdded = true;
                            mapOfCompCodeAndComp.get(oipcVersion[1]+'-'+compCode).noChange =false;
                            if(!mapofCompAdded.containsKey(oipcVersion[1])){
                                mapofCompAdded.put(oipcVersion[1],new Set<String>{compCode});
                            }else{
                                mapofCompAdded.get(oipcVersion[1]).add(compCode);
                            }
                              
                            if(!mapOfComponenttoProcess.containsKey(oipcVersion[1])){
                                mapOfComponenttoProcess.put(oipcVersion[1],new Set<String>{compCode});
                            }else{
                                mapOfComponenttoProcess.get(oipcVersion[1]).add(compCode);
                            }
                        }
                    }
                }
            }
        }
        System.debug('mapofCompRemoved ' + mapofCompRemoved);
        System.debug('mapofCompAdded ' + mapofCompAdded);
    }

    public static void findDifferenceinFeatures(Map<Id,String> mapOfoliandOldVersion, Map<Id,String> mapOfoliandNewVersion, Map<String,Map<String,Set<String>>> mapofVersionFeat,Map<Id,Set<String>> mapOfOLliIdandversion,  Map<String,Feature> mapOfFeatureCodeAndFeat ){
        system.debug('mapOfFeatureCodeAndFeat '+mapOfFeatureCodeAndFeat);
        for(Id oli:mapOfOLliIdandversion.keySet()){
            if(mapOfOLliIdandversion.get(oli).size()== 2){
                List<String> oipcVersion= new List<String>(mapOfOLliIdandversion.get(oli));
                if(mapofVersionFeat.containsKey(oipcVersion[0]) &&  mapOfoliandOldVersion.containsKey(oli) && mapOfoliandOldVersion.get(oli) == oipcVersion[0] ){

                    for(String comp:mapofVersionFeat.get(oipcVersion[0]).keySet()){
                        if( (mapofCompRemoved.containsKey(oipcVersion[0]) && mapofCompRemoved.get(oipcVersion[0]).contains(comp) ) ){ // if feature belongs to Removed Comp
                            continue;
                        }else{
                            for(String feat:mapofVersionFeat.get(oipcVersion[0]).get(comp) ){
                                system.debug('feat removed mapOfFeatureCodeAndFeat ');
                                if(mapofVersionFeat.get(oipcVersion[1]).containsKey(comp) && mapofVersionFeat.get(oipcVersion[1]).get(comp).contains(feat) && ( mapOfFeatureCodeAndFeat.get(oipcVersion[0]+'-'+feat).isService == mapOfFeatureCodeAndFeat.get(oipcVersion[1]+'-'+feat).isService || (mapOfFeatureCodeAndFeat.get(oipcVersion[0]+'-'+feat).isService != mapOfFeatureCodeAndFeat.get(oipcVersion[1]+'-'+feat).isService && mapOfFeatureCodeAndFeat.get(oipcVersion[0]+'-'+feat).isService !='Service'&& mapOfFeatureCodeAndFeat.get(oipcVersion[1]+'-'+feat).isService =='Service' )) ){
                                    continue;
                                }else{
                                   
                                    mapOfFeatureCodeAndFeat.get(oipcVersion[0]+'-'+feat).isRemoved = true;
                                    if(!mapofFeatRemoved.containsKey(oipcVersion[0])){
                                        mapofFeatRemoved.put(oipcVersion[0] ,new set<String>{feat});
                                    }else{
                                        mapofFeatRemoved.get(oipcVersion[0]).add(feat);
                                    }

                                    if(!mapOfComponenttoProcess.containsKey(oipcVersion[0])){
                                        mapOfComponenttoProcess.put(oipcVersion[0],new Set<String>{mapOfFeatureCodeAndFeat.get(oipcVersion[0]+'-'+feat).componentCode});
                                    }else{
                                        mapOfComponenttoProcess.get(oipcVersion[0]).add(mapOfFeatureCodeAndFeat.get(oipcVersion[0]+'-'+feat).componentCode);
                                    }
                                }
                            }
                        }
                    }
                }

                if(mapofVersionFeat.containsKey(oipcVersion[1]) &&  mapOfoliandNewVersion.containsKey(oli) && mapOfoliandNewVersion.get(oli) == oipcVersion[1] ){
                    for(String comp:mapofVersionFeat.get(oipcVersion[1]).keySet()){
                        if( (mapofCompAdded.containsKey(oipcVersion[1]) && mapofCompAdded.get(oipcVersion[1]).contains(comp) ) ){ // if feature belongs to Removed Comp
                            continue;
                        }else{
                            for(String feat:mapofVersionFeat.get(oipcVersion[1]).get(comp) ){
                                if(mapofVersionFeat.get(oipcVersion[0]).containsKey(comp) && mapofVersionFeat.get(oipcVersion[0]).get(comp).contains(feat) &&
                                 ( mapOfFeatureCodeAndFeat.get(oipcVersion[0]+'-'+feat).isService == mapOfFeatureCodeAndFeat.get(oipcVersion[1]+'-'+feat).isService || (mapOfFeatureCodeAndFeat.get(oipcVersion[0]+'-'+feat).isService != mapOfFeatureCodeAndFeat.get(oipcVersion[1]+'-'+feat).isService && mapOfFeatureCodeAndFeat.get(oipcVersion[0]+'-'+feat).isService =='Service'&& mapOfFeatureCodeAndFeat.get(oipcVersion[1]+'-'+feat).isService !='Service' )) ){
                                    continue;
                                }else{//mapOfFeatureCodeAndFeat.get(oipcVersion[0]+'-'+feat).isService =='Service'&& mapOfFeatureCodeAndFeat.get(oipcVersion[1]+'-'+feat).isService !='Service' ))
                                    mapOfFeatureCodeAndFeat.get(oipcVersion[1]+'-'+feat).isAdded = true;
                                    if(!mapofFeatAdded.containsKey(oipcVersion[1])){
                                        mapofFeatAdded.put(oipcVersion[1] ,new set<String>{feat});
                                    }else{
                                        mapofFeatAdded.get(oipcVersion[1]).add(feat);
                                    }
                                    
                                    if(!mapOfComponenttoProcess.containsKey(oipcVersion[1])){
                                        mapOfComponenttoProcess.put(oipcVersion[1],new Set<String>{mapOfFeatureCodeAndFeat.get(oipcVersion[1]+'-'+feat).componentCode});
                                    }else{
                                        mapOfComponenttoProcess.get(oipcVersion[1]).add(mapOfFeatureCodeAndFeat.get(oipcVersion[1]+'-'+feat).componentCode);
                                    }
                                }
                            }
                        }
                    }
                }

            }
        }
        
        System.debug('mapofFeatRemoved '+ mapofFeatRemoved);
        System.debug('mapofFeatAdded '+ mapofFeatAdded);
    }

    public static void findDifferenceParameters(Map<Id,String> mapOfoliandOldVersion, Map<Id,String> mapOfoliandNewVersion, Map<String,Map<String,Set<String>>> mapofVersionPara,Map<Id,Set<String>> mapOfOLliIdandversion, Map<String,Parameter> mapOfParaCodeAndPara ){

        for(Id oli:mapOfOLliIdandversion.keySet()){
            if(mapOfOLliIdandversion.get(oli).size()== 2){
                List<String> oipcVersion= new List<String>(mapOfOLliIdandversion.get(oli));
                if(mapofVersionPara.containsKey(oipcVersion[0]) &&  mapOfoliandOldVersion.containsKey(oli) && mapOfoliandOldVersion.get(oli) == oipcVersion[0] ){
                    for(String feat:mapofVersionPara.get(oipcVersion[0]).keySet()){
                        if( (mapofFeatRemoved.containsKey(oipcVersion[0]) && mapofFeatRemoved.get(oipcVersion[0]).contains(feat) ) ){ // if feature belongs to Removed Comp
                            continue;
                        }else{
                            for(String para:mapofVersionPara.get(oipcVersion[0]).get(feat) ){
                                if( mapofVersionPara.get(oipcVersion[0]) == null || (mapofVersionPara.get(oipcVersion[1]).containsKey(feat) && mapofVersionPara.get(oipcVersion[1]).get(feat).contains(para))){
                                    continue;
                                }else{
                                    mapOfParaCodeAndPara.get(oipcVersion[0]+'-'+para).isRemoved = true;
                                    if(!mapofparaRemoved.containsKey(oipcVersion[0])){
                                        mapofparaRemoved.put(oipcVersion[0] ,new set<String>{para});
                                    }else{
                                        mapofparaRemoved.get(oipcVersion[0]).add(para);
                                    }

                                    if(!mapOfComponenttoProcess.containsKey(oipcVersion[0])){
                                        mapOfComponenttoProcess.put(oipcVersion[0],new Set<String>{mapOfParaCodeAndPara.get(oipcVersion[0]+'-'+para).componentCode});
                                    }else{
                                        mapOfComponenttoProcess.get(oipcVersion[0]).add(mapOfParaCodeAndPara.get(oipcVersion[0]+'-'+para).componentCode);
                                    }
                                }
                            }
                        }
                    }
                }

                if(mapofVersionPara.containsKey(oipcVersion[1]) &&  mapOfoliandNewVersion.containsKey(oli) && mapOfoliandNewVersion.get(oli) == oipcVersion[1] ){
                    for(String feat:mapofVersionPara.get(oipcVersion[1]).keySet()){
                        if( (mapofFeatAdded.containsKey(oipcVersion[1]) && mapofFeatAdded.get(oipcVersion[1]).contains(feat) ) ){ // if feature belongs to Removed Comp
                            continue;
                        }else{
                            for(String para:mapofVersionPara.get(oipcVersion[1]).get(feat) ){
                                if( mapofVersionPara.get(oipcVersion[0]) == null || (mapofVersionPara.get(oipcVersion[0]).containsKey(feat) && mapofVersionPara.get(oipcVersion[0]).get(feat).contains(para))){ //added change 
                                    continue;
                                }else{
                                    mapOfParaCodeAndPara.get(oipcVersion[1]+'-'+para).isAdded = true;
                                    if(!mapofparaAdded.containsKey(oipcVersion[1])){
                                        mapofparaAdded.put(oipcVersion[1] ,new set<String>{para});
                                    }else{
                                        mapofparaAdded.get(oipcVersion[1]).add(para);
                                    }

                                    if(!mapOfComponenttoProcess.containsKey(oipcVersion[1])){
                                        mapOfComponenttoProcess.put(oipcVersion[1],new Set<String>{mapOfParaCodeAndPara.get(oipcVersion[1]+'-'+para).componentCode});
                                    }else{
                                        mapOfComponenttoProcess.get(oipcVersion[1]).add(mapOfParaCodeAndPara.get(oipcVersion[1]+'-'+para).componentCode);
                                    }
                                }
                            }
                        }
                    }
                }

            }
        }
        
        System.debug('mapofparaRemoved '+ mapofparaRemoved);
        System.debug('mapofparaAdded '+ mapofparaAdded);
    }

    public static void findDifferenceOptions(Map<Id,String> mapOfoliandOldVersion, Map<Id,String> mapOfoliandNewVersion, Map<String,Map<String,Set<String>>> mapofVersionOpt,Map<Id,Set<String>> mapOfOLliIdandversion,Map<String,Option> mapOfOptionCodeAndOpt ){

        for(Id oli:mapOfOLliIdandversion.keySet()){
            if(mapOfOLliIdandversion.get(oli).size()== 2){
                List<String> oipcVersion= new List<String>(mapOfOLliIdandversion.get(oli));
                if(mapofVersionOpt.containsKey(oipcVersion[0]) &&  mapOfoliandOldVersion.containsKey(oli) && mapOfoliandOldVersion.get(oli) == oipcVersion[0] ){
                    for(String para : mapofVersionOpt.get(oipcVersion[0]).keySet()){
                        if( (mapofparaRemoved.containsKey(oipcVersion[0]) && mapofparaRemoved.get(oipcVersion[0]).contains(para) ) ){ // if feature belongs to Removed Comp
                            continue;
                        }else{
                            for(String opt : mapofVersionOpt.get(oipcVersion[0]).get(para) ){
                                if(mapofVersionOpt.get(oipcVersion[1]) == null || (mapofVersionOpt.get(oipcVersion[1]).containsKey(para) && mapofVersionOpt.get(oipcVersion[1]).get(para).contains(opt))){
                                    continue;
                                }else{
                                    mapOfOptionCodeAndOpt.get(oipcVersion[0]+'-'+opt).isRemoved = true;
                                    if(!mapofOptRemoved.containsKey(oipcVersion[0])){
                                        mapofOptRemoved.put(oipcVersion[0] ,new set<String>{opt});
                                    }else{
                                        mapofOptRemoved.get(oipcVersion[0]).add(opt);
                                    }
                                    if(!mapOfComponenttoProcess.containsKey(oipcVersion[0])){
                                        mapOfComponenttoProcess.put(oipcVersion[0],new Set<String>{mapOfOptionCodeAndOpt.get(oipcVersion[0]+'-'+opt).componentCode});
                                    }else{
                                        mapOfComponenttoProcess.get(oipcVersion[0]).add(mapOfOptionCodeAndOpt.get(oipcVersion[0]+'-'+opt).componentCode);
                                    }
                                }
                            }
                        }
                    }
                }

                if(mapofVersionOpt.containsKey(oipcVersion[1]) &&  mapOfoliandNewVersion.containsKey(oli) && mapOfoliandNewVersion.get(oli) == oipcVersion[1] ){
                    for(String para : mapofVersionOpt.get(oipcVersion[1]).keySet()){
                        if( (mapofparaAdded.containsKey(oipcVersion[1]) && mapofparaAdded.get(oipcVersion[1]).contains(para) ) ){ // if feature belongs to Removed Comp
                            continue;
                        }else{
                            for(String opt : mapofVersionOpt.get(oipcVersion[1]).get(para) ){
                                if(mapofVersionOpt.get(oipcVersion[0]) == null || ( mapofVersionOpt.get(oipcVersion[0]).containsKey(para) && mapofVersionOpt.get(oipcVersion[0]).get(para).contains(opt))){ //added change 
                                    continue;
                                }else{
                                    mapOfOptionCodeAndOpt.get(oipcVersion[1]+'-'+opt).isAdded = true;
                                    if(!mapofOptAdded.containsKey(oipcVersion[1])){
                                        mapofOptAdded.put(oipcVersion[1] ,new set<String>{opt});
                                    }else{
                                        mapofOptAdded.get(oipcVersion[1]).add(opt);
                                    }
                                    if(!mapOfComponenttoProcess.containsKey(oipcVersion[1])){
                                        mapOfComponenttoProcess.put(oipcVersion[1],new Set<String>{mapOfOptionCodeAndOpt.get(oipcVersion[1]+'-'+opt).componentCode});
                                    }else{
                                        mapOfComponenttoProcess.get(oipcVersion[1]).add(mapOfOptionCodeAndOpt.get(oipcVersion[1]+'-'+opt).componentCode);
                                    }
                                }
                            }
                        }
                    }
                }

            }
        }
        
        System.debug('mapofOptAdded '+ mapofOptAdded);
        System.debug('mapofOptRemoved '+ mapofOptRemoved);
    }

    public static void createOLItoCompMap(Map<Id,String> mapOfoliandOldVersion, Map<Id,String> mapOfoliandNewVersion, Map<String,Set<String>> mapofVersionComp, Map<Id,Set<String>> mapOfOLliIdandversion, Map<String,Component> mapOfCompCodeAndComp ){
        for(Id oliId:mapOfOLliIdandversion.keySet()){
            Set<String> comCode=new Set<String>();
            for(String oipcVersion: mapOfOLliIdandversion.get(oliId)){
                if(mapOfComponenttoProcess.containsKey(oipcVersion)){
                    for(String compCode:mapOfComponenttoProcess.get(oipcVersion)){
                        Component comp= mapOfCompCodeAndComp.get(oipcVersion+'-'+compCode);
                        comp.noChange = !(comp.isRemoved || comp.isAdded );
                        // if( mapofCompRemoved.containsKey(oipcVersion) && mapofCompRemoved.get(oipcVersion).contains(compCode)){
                        //     comp.isRemoved = true;
                        // }
                        // if(mapofCompAdded.containsKey(oipcVersion) && mapofCompAdded.get(oipcVersion).contains(compCode)){
                        //     comp.isAdded = true;
                        // }
                        if(!mapOfOliAndComponent.containsKey(oliId)){
                            comCode.add(comp.componentCode);
                                mapOfOliAndComponent.put(oliId,new List<Component>{comp});
                            
                        }else{
                            if(!comCode.contains(comp.componentCode)){
                                comCode.add(comp.componentCode);
                                mapOfOliAndComponent.get(oliId).add(comp);
                            }
                        }
                    }
                }
            }
        }
    }

    public static void  createCompToFeatureMap( Map<Id,Set<String>> mapOfOLliIdandversion,Map<String,Set<String>> mapofVersionComp, Map<String,Map<String,Set<String>>> mapofVersionFeat,Map<String,Map<String,Set<String>>> mapofVersionPara, Map<String,Map<String,Set<String>>> mapofVersionOpt,Map<String,Component> mapOfCompCodeAndComp, Map<String,Feature> mapOfFeatureCodeAndFeat, Map<String,Parameter> mapOfParaCodeAndPara,Map<String,Option> mapOfOptionCodeAndOpt){

        for(Id oliId:mapOfOLliIdandversion.keySet()){
            Map<String,Map<String,Feature>> mapofFeatureChange = new Map<String,Map<String,Feature>>();
            Map<String,Map<String,Parameter>> mapOfParameterChange = new Map<String,Map<String,parameter>>();
            Map<String,Set<String>> mapofParaOptions= new map<String,set<String>>();
            for(String oipcVersion: mapOfOLliIdandversion.get(oliId)){
                if(mapOfComponenttoProcess.containsKey(oipcVersion)){
                    for(String compCode : mapOfComponenttoProcess.get(oipcVersion)){
                        Component comp = mapOfCompCodeAndComp.get(oipcVersion+'-'+compCode);
                        	//system.debug('comp '+ comp + ' comp.isRemoved '+ comp.isRemoved + ' comp.isAdded ' + comp.isAdded);
                        if(mapofVersionFeat.containsKey(oipcVersion) && mapofVersionFeat.get(oipcVersion).containsKey(compCode)){
                             boolean isfeatureModified = false;
                            for(String featcode: mapofVersionFeat.get(oipcVersion).get(compCode)){
                                Boolean toBeAdded= false;
								//system.debug('featcode '+ featcode+ ' isfeatureModified '+ isfeatureModified);
                                Feature feat = mapOfFeatureCodeAndFeat.get(oipcVersion+'-'+featcode);
                                feat.isRemoved = feat.isRemoved || comp.isRemoved ;
                                feat.isAdded = feat.isAdded || comp.isAdded;
                                // new change
                                isfeatureModified =   feat.isRemoved || comp.isRemoved || feat.isAdded || comp.isAdded; // new feature or removed feature -> new component or removed component
                                feat.noChange = !(feat.isRemoved || feat.isAdded );
                                if(mapofVersionPara.containsKey(oipcVersion) && mapofVersionPara.get(oipcVersion).containsKey(featcode)){
                                  
                                    for(String paramCode : mapofVersionPara.get(oipcVersion).get(featcode)){
                                        boolean isParameterModified= false;
                                        Parameter para= mapOfParaCodeAndPara.get(oipcVersion+'-'+paramCode);
                                        //system.debug('paramCode '+ paramCode+ ' isParameterModified '+ isParameterModified);
                                        //system.debug('paramCode '+ paramCode+ ' isfeatureModified '+ isfeatureModified);
                                        isParameterModified =  isParameterModified || isfeatureModified ? true : para.isRemoved || para.isAdded;
                                        para.isAdded = feat.isAdded || comp.isAdded || para.isAdded ;
                                        para.isRemoved = feat.isRemoved || comp.isRemoved ||  para.isRemoved;
                                        para.noChange = !(para.isRemoved || para.isAdded );
                                    	//system.debug('paramCode '+ paramCode+ ' isParameterModified '+ isParameterModified);
                                        if(mapofVersionOpt.containsKey(oipcVersion) && mapofVersionOpt.get(oipcVersion).containsKey(paramCode)){
                                                boolean isOptionModified= false;
                                            for(String optionCode: mapofVersionOpt.get(oipcVersion).get(paramCode)){
                                                Option opt=mapOfOptionCodeAndOpt.get(oipcVersion+'-'+optionCode);
                                                isOptionModified = isOptionModified || isfeatureModified || isParameterModified ? true: opt.isAdded ||  opt.isRemoved ;
                                                opt.isAdded = opt.isAdded || feat.isAdded || comp.isAdded || para.isAdded ;
                                                opt.isRemoved = opt.isRemoved || feat.isRemoved || comp.isRemoved ||  para.isRemoved;
                                                //toBeAdded = opt.isRemoved || opt.isAdded || toBeAdded;
                                                toBeAdded = isOptionModified;
                                                opt.noChange = !(opt.isRemoved || opt.isAdded );
												system.debug('optionCode '+ optionCode+ ' isOptionModified '+ isOptionModified);
                                                if(mapOfParameterChange.containsKey(feat.featureCode)){
                                                    if( mapOfParameterChange.get(feat.featureCode).containsKey(para.parameterCode) ){
                                                        mapOfParameterChange.get(feat.featureCode).get(para.parameterCode).options.add(opt);
                                                    }else{
                                                        para.options.add(opt);
                                                        mapOfParameterChange.get(feat.featureCode).put(para.parameterCode,para);
                                                    }
                                                }else{
                                                    para.options.add(opt);
                                                    mapOfParameterChange.put(feat.featureCode,new Map<String,Parameter>{para.parameterCode => para});
                                                }
                                            }
                                        }
                                        if(toBeAdded){
                                            if(mapofFeatureChange.containsKey(feat.componentCode)){
                                                if( mapofFeatureChange.get(feat.componentCode).containsKey(feat.featureCode)){
                                                        mapofFeatureChange.get(feat.componentCode).get(feat.featureCode).parameters.add(mapOfParameterChange.get(feat.featureCode).get(para.parameterCode));
                                                }else{
                                                    feat.parameters.add(mapOfParameterChange.get(feat.featureCode).get(para.parameterCode));
                                                        mapofFeatureChange.get(feat.componentCode).put(feat.featureCode,feat);
                                                }
                                            }else{
                                                feat.parameters.add(mapOfParameterChange.get(feat.featureCode).get(para.parameterCode));
                                                mapofFeatureChange.put(feat.componentCode, new Map<String,feature>{feat.featureCode => feat});
                                            }
                                           // feat.parameters.add(para);
                                        }
                                    }
                                }
                            //    if(tobeadded){
                            //         if(!mapOfCompIdandFeature.containsKey(feat.componentCode)){
                            //             mapOfCompIdandFeature.put(feat.componentCode,new List<Feature>{feat});
                            //         }else{
                            //             mapOfCompIdandFeature.get(feat.componentCode).add(feat);
                            //         }
                            //    }
                            }
                        }
                    }
                }
                for(String compcode:mapofFeatureChange.keyset()){
                   
                        mapOfCompIdandFeature.put(compcode,mapofFeatureChange.get(compcode).values());
                    }               
            }   
        }

            
    }


    public class DifferenceWrapper{
        //@AuraEnabled
       // public Map<String,List<Component>> mapOfOipcVersionandComp{get;set;}
        @AuraEnabled
        public Map<String,Id> mapofOIPCVerionandProductId {get;set;}
        @AuraEnabled
        public Map<Id,Set<String>> mapOfOLliIdandversion {get;set;}
        @AuraEnabled
        public  Map<Id,String> mapOfoliandOldVersion {get;set;}
        @AuraEnabled
        public  Map<Id,String> mapOfoliandNewVersion {get;set;}
        @AuraEnabled
        public  Map<String,List<Component>> mapOfOliAndComponent {get;set;}
        @AuraEnabled
        public  Map<String,List<Feature>> mapOfCompIdandFeature {get;set;}
        @AuraEnabled
        public  Map<Id,String> mapofProductName {get;set;}
    }

    public class Component{
        @AuraEnabled
        public String componentCode {get;set;} 
        @AuraEnabled
        public String componentName {get;set;} 
        @AuraEnabled
        public Id componentId {get;set;} 
        @AuraEnabled
        public Boolean isRemoved {get;set;} 
        @AuraEnabled
        public Boolean isAdded {get;set;} 
        @AuraEnabled
        public Boolean noChange {get;set;} 
        @AuraEnabled
        public List<Feature> features{get;set;} 
        public Component(){
            features= new List<Feature>();
            isAdded = false;
            isRemoved = false;
            noChange = true;
        }
    }

    public class Feature{
        @AuraEnabled
        public String componentCode {get;set;} 
        @AuraEnabled
        public Id componentId {get;set;} 
        @AuraEnabled
        public String featureCode {get;set;} 
        @AuraEnabled
        public String featureName {get;set;} 
        @AuraEnabled
        public Id featureId {get;set;} 
        @AuraEnabled
        public String isService {get;set;}     
        @AuraEnabled
        public Boolean isRemoved {get;set;} 
        @AuraEnabled
        public Boolean isAdded {get;set;} 
        @AuraEnabled
        public Boolean noChange {get;set;} 
        @AuraEnabled
        public Set<Parameter> parameters{get;set;} 
        public Feature(){
            parameters= new Set<Parameter>();
            isAdded = false;
            isRemoved = false;
            noChange = true;
        }
    }

    public class Parameter{
        @AuraEnabled
        public String componentCode {get;set;} 
        @AuraEnabled
        public String parameterCode {get;set;} 
        @AuraEnabled
        public String parameterName {get;set;} 
        @AuraEnabled
        public Id parameterId {get;set;} 
        @AuraEnabled
        public Id featureId {get;set;} 
        @AuraEnabled
        public Boolean isRemoved {get;set;} 
        @AuraEnabled
        public Boolean isAdded {get;set;}
        @AuraEnabled
        public Boolean noChange {get;set;}  
        @AuraEnabled
        public Set<Option> options{get;set;} 
        public Parameter(){
            options= new Set<Option>();
            isAdded = false;
            isRemoved = false;
            noChange= true;
        }
    }

    public class Option{
        @AuraEnabled
        public String componentCode {get;set;} 
        @AuraEnabled
        public String optionCode {get;set;} 
        @AuraEnabled
        public String optionName {get;set;} 
        @AuraEnabled
        public Boolean isRemoved {get;set;} 
        @AuraEnabled
        public Boolean isAdded {get;set;} 
        @AuraEnabled
        public Boolean noChange {get;set;} 
        public Option(){
            isAdded = false;
            isRemoved = false;
            noChange= true;
        }
    }


    @AuraEnabled(Cacheable= true)
    public static ProductDiff checkForDefinationType(Id oliId,Id recId,boolean hasSolution){ // (Id OLI, Id recId, Boolean isSolution, Id ProductlatestVersion ))
        ProductDiff prodDiff= new ProductDiff();

        if(hasSolution){
            Map<Id,Id> mapOfOpptyIdAndOldSolution = new Map<Id,Id>();
            Map<Id,Id> mapOfOpptyIdAndNewSolution = new Map<Id,Id>();
            Map<Id,Map<String,String>> mapOfSolutionIdandProductRef = new Map<Id,Map<String,String>>();
            Map<String,Opportunity_Product__c> mapOfOpptyProduct =  new Map<String,Opportunity_Product__c>();
            Map<String,Id> mapofProduct2=  new Map<String,Id>();
            for( Opportunity_Product__c prod: [SELECT  id,Product2ID__c,Product2ID__r.OIPC_ProductCode_Version__c,Product2ID__r.Name,Solution__c,Solution__r.name,Solution__r.oipc_code__c,Solution__r.isActive, Solution__r.Definition_Type__c,Solution__r.Version__c ,Solution__r.Latest_Product_Version__c ,Solution__r.Latest_Product_Version__r.isActive,OpportunityID__c
                                            FROM  Opportunity_Product__c WHERE OpportunityID__c =:recId ]){
                                                if(prod.Solution__c != null){
                                                    if(!mapOfOpptyIdAndOldSolution.containsKey(prod.OpportunityID__c) && prod.Solution__r.isActive == false && prod.Solution__r.Latest_Product_Version__c != null && prod.Solution__r.Latest_Product_Version__r.isActive == true){
                                                        mapOfOpptyIdAndOldSolution.put(prod.OpportunityID__c, prod.Solution__c);
                                                        mapOfOpptyIdAndNewSolution.put(prod.OpportunityID__c, prod.Solution__r.Latest_Product_Version__c);
                                                    }
                                                }
                                                if(!mapOfOpptyProduct.containsKey(prod.Product2ID__r.OIPC_ProductCode_Version__c)){
                                                    mapOfOpptyProduct.put(prod.Product2ID__r.OIPC_ProductCode_Version__c,prod);
                                                }
            }

            if(!mapOfOpptyIdAndOldSolution.keyset().isEmpty() && !mapOfOpptyIdAndNewSolution.keySet().isEmpty()){
                List<Id> lstSoluionId= new List<Id>();
                lstSoluionId.addAll(mapOfOpptyIdAndOldSolution.values());
                lstSoluionId.addAll(mapOfOpptyIdAndNewSolution.values());

                for(Product_Reference__c prodRef:[SELECT id,Product__c,Product__r.OIPC_Code__c,Product__r.OIPC_ProductCode_Version__c, Solution__r.Version__c,Solution__r.IsActive,solution__r.OIPC_ProductCode_Version__c,Solution__c FROM Product_Reference__c WHERE Solution__c IN:lstSoluionId] ){
                    if(!mapOfSolutionIdandProductRef.containsKey(prodRef.Solution__c)){
                        mapOfSolutionIdandProductRef.put(prodRef.Solution__c, new Map<String,String>{prodRef.Product__r.OIPC_Code__c => prodRef.Product__r.OIPC_ProductCode_Version__c});
                    }else{
                        if(!mapOfSolutionIdandProductRef.get(prodRef.Solution__c).containsKey(prodRef.Product__r.OIPC_Code__c)){
                            mapOfSolutionIdandProductRef.get(prodRef.Solution__c).put(prodRef.Product__r.OIPC_Code__c,prodRef.Product__r.OIPC_ProductCode_Version__c);
                        }
                    }

                    if(!mapofProduct2.containsKey(prodRef.Product__r.OIPC_ProductCode_Version__c)){
                        mapofProduct2.put(prodRef.Product__r.OIPC_ProductCode_Version__c,prodRef.Product__c);
                    }
                   
                }   
            }
            system.debug('test class check'+mapOfSolutionIdandProductRef);
            //01tS8000002bsoHIAQ={P-P0-test1 = P-P0-test1-1, P-P0-test2 = P-P0-test2-1}, 
            //01tS8000002jVajIAE={P-P0-test1=P-P0-test1-2, P-P0-test2=P-P0-test2-2}

          
            
            prodDiff.isSolution = true;
            List<ProductInfo> lstProductInfo= new List<ProductInfo>();
            //  mapOfOpptyIdAndOldSolution.get(recId)  - Old Solution Id
            //system.debug('test class check mapOfOpptyIdAndOldSolution '+mapOfOpptyIdAndOldSolution.get(recId));
            //system.debug('test class check mapOfOpptyIdAndOldSolution '+mapOfOpptyIdAndNewSolution.get(recId));
			//system.debug('mapOfOpptyProduct '+ mapOfOpptyProduct);
            if(mapOfSolutionIdandProductRef.containsKey(mapOfOpptyIdAndOldSolution.get(recId))){ // Product reference under Solution id
                Map<String,String> oldSolutionProductRef = mapOfSolutionIdandProductRef.get(mapOfOpptyIdAndOldSolution.get(recId)); // Map of product reference from old solution
                Map<String,String> newSolutionProductRef = mapOfSolutionIdandProductRef.get(mapOfOpptyIdAndNewSolution.get(recId)); // Map of product reference from new solution
                system.debug('test class check oldSolutionProductRef '+oldSolutionProductRef);
                system.debug('test class check newSolutionProductRef '+newSolutionProductRef);
                for(String oipcCode:oldSolutionProductRef.keyset()){ //OIPC_Code__c is key
                    //system.debug('oipcCode '+ oipcCode);
                    if(newSolutionProductRef.containsKey(oipcCode)){
                        //system.debug('oldSolutionProductRef.get(oipcCode) '+ oldSolutionProductRef.get(oipcCode));
                        //system.debug('oldSolutionProductRef.get(oipcCode) '+ mapOfOpptyProduct.get('P-P0-20jb'));
                        ProductInfo tempProduct = new ProductInfo();
                        Opportunity_Product__c opptyProduct= mapOfOpptyProduct.containskey(oldSolutionProductRef.get(oipcCode)) ? mapOfOpptyProduct.get(oldSolutionProductRef.get(oipcCode)):null; 
                        //system.debug('opptyProduct ' + opptyProduct);
                        tempProduct.currentVerionId = opptyProduct != null ? opptyProduct.Product2ID__c:'';
                        tempProduct.oliId = opptyProduct != null ? opptyProduct.Id:'';
                        tempProduct.latestVerionId = mapofProduct2.containsKey(newSolutionProductRef.get(oipcCode)) ? mapofProduct2.get(newSolutionProductRef.get(oipcCode)) : null;
                        tempProduct.opptyProduct = opptyProduct != null ? opptyProduct : null;
                        prodDiff.opptyProductName = opptyProduct != null ? opptyProduct.Solution__r.name :'';
                        tempProduct.key =opptyProduct != null ? opptyProduct.Id:'';
                        tempProduct.product2Name =opptyProduct != null ? opptyProduct.Product2ID__r.Name :'';
                        lstProductInfo.add(tempProduct);
                    }
                }
                prodDiff.productList=lstProductInfo;
            }
            
        }else{
           for( Opportunity_Product__c prod: [SELECT id, Product2ID__c,Product2ID__r.Name,Product2ID__r.OIPC_ProductCode_Version__c , Product2ID__r.Latest_Product_Version__c, Product2ID__r.Latest_Product_Version__r.OIPC_ProductCode_Version__c, Product2Id__r.Definition_Type__c
                                            FROM  Opportunity_Product__c WHERE Id =: oliId AND OpportunityID__c =:recId ]){
            
               
             
                prodDiff.isSolution = false;
                prodDiff.opptyProductName = prod.Product2Id__r.Name;

                ProductInfo tempProduct = new ProductInfo();
                tempProduct.oliId = prod.Id;
                tempProduct.latestVerionId = prod.Product2ID__r.Latest_Product_Version__c;
                tempProduct.currentVerionId = prod.Product2ID__c;
                tempProduct.opptyProduct =  prod;
                tempProduct.key = prod.id;
                tempProduct.product2Name = prod.Product2ID__r.Name;
                prodDiff.productList.add(tempProduct);
            }
        }

        return prodDiff;
    }

    public class ProductDiff{
       
        @AuraEnabled
        public Boolean isSolution {get;set;}
        @AuraEnabled
        public String opptyProductName {get;set;}
        @AuraEnabled
        public List<ProductInfo> productList {get;set;}  
        public ProductDiff (){
            productList = new List<ProductInfo>();
            opptyProductName = '';
            isSolution = false; 
        }  
    }

    public class ProductInfo{   
        @AuraEnabled
        public Id key{get;set;}
        @AuraEnabled
        public String product2Name{get;set;}
        @AuraEnabled
        public Id oliId{get;set;}
        @AuraEnabled
        public Id latestVerionId {get;set;}
        @AuraEnabled
        public Id currentVerionId {get;set;}
        @AuraEnabled
        public Opportunity_Product__c opptyProduct {get;set;}
    }
}