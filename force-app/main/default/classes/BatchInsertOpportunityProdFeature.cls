/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-23-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class BatchInsertOpportunityProdFeature implements Database.Batchable<SObject>{
    
   /* global Set<String> opptyProdFeatureId;
    
    global BatchInsertOpportunityProdFeature(Set<String> opptyProdFeatureId){
        opptyProdFeatureId = new set<String>();
        this.opptyProdFeatureId = opptyProdFeatureId;
    }*/
    
    global Database.QueryLocator start(Database.BatchableContext bc){        
        String query;      
        String productoipcCode='P-P0-dx2';
        query = 'select id,Name,Product_Feature__c,Product_Feature__r.Name ,Opportunity_Product__c,Product_Feature__r.Options__c,Feature_Value__c,Product_Feature__r.Feature_Code__c,Product_Feature__r.OIPC_Component_Code__c,Product_Feature__r.Product_Component__r.Product__r.OIPC_Code__c,Product_Feature__r.Product_Component__r.Product__c from Opportunity_Product_Feature__c where Opportunity_Product__r.Product2.OIPC_Code__c =\'P-P0-dx2\'';
        
       /* if(opptyProdFeatureId.size() > 0 && opptyProdFeatureId != null){
            query += ' WHERE Id IN : opptyProdFeatureId';
        }*/
        System.debug('query' + query);        
        return Database.getQueryLocator(query);
    }   
    global void execute(Database.BatchableContext BC,List<Opportunity_Product_Feature__c> OppProdFeature){
        
        System.debug('OppProdFeature'+ OppProdFeature.Size());
        
        Set<String> productfeaturenames = new Set<String>();
        Set<String> optionNames = new Set<String>();
        List <String> featureOption = new List<String>();
        
        for(Opportunity_Product_Feature__c f : OppProdFeature){
            if(f.Feature_Value__c != null && f.Product_Feature__c != null) {
                featureOption = f.Feature_Value__c.split(';');
                System.debug('featureOption '+featureOption);
                optionNames.addAll(featureOption);
                productfeaturenames.add(f.Product_Feature__r.Name);
            }
        }
        System.debug('optionNames '+optionNames);
        System.debug('optionNames '+optionNames.size());
        System.debug('productfeaturenames '+productfeaturenames);
        List<Product_Specification_Option__c> prodSpecOptionList = [select id, Name, Specification_Option_Name__c, Product_Specification_Parameter__c, Product_Specification_Parameter__r.Name,  Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__c,Product_Specification_Parameter__r.Specification_Parameter_Code__c 
                                                                    from Product_Specification_Option__c 
                                                                    where (Product_Specification_Parameter__r.name IN : productfeaturenames AND
                                                                    Specification_Option_Name__c IN : optionNames ) AND  Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.OIPC_Code__c =: 'P-P0-dx2'];
        
        Map<String, Product_Specification_Option__c> mapKeyToSpecOption = new Map<String, Product_Specification_Option__c>();
        System.debug(prodSpecOptionList);
        String uniqueKey;
        for(Product_Specification_Option__c specoption : prodSpecOptionList){
            uniqueKey = specoption.Specification_Option_Name__c.trim() + '-' + specoption.Product_Specification_Parameter__r.Specification_Parameter_Code__c.trim() + '-' + specoption.Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__c;
            System.debug('uniqueKey '+uniqueKey);
            mapKeyToSpecOption.put(uniqueKey.trim(), specoption);
        }
        System.debug(mapKeyToSpecOption.keyset().size());
        List<Opportunity_Product_Configuration__c> prodConfigsToInsert = new List<Opportunity_Product_Configuration__c>();
        Opportunity_Product_Configuration__c prodConfigRec;
        
        try{
            for(Opportunity_Product_Feature__c f : OppProdFeature){
                if(f.Feature_Value__c != null && f.Product_Feature__c != null) {
                    featureOption = f.Feature_Value__c.split(';');
                    System.debug('featureOption' + featureOption);
                    if( featureOption.size() > 0){
                        for(integer i = 0;i < featureOption.size();i++){
                            uniqueKey = featureOption[i].trim() + '-' + f.Product_Feature__r.Feature_Code__c.trim() + '-'+ f.Product_Feature__r.Product_Component__r.Product__c;
                            System.debug('uniqueKey' + uniqueKey);
                            if(mapKeyToSpecOption.containsKey(uniqueKey.trim())){
                                prodConfigRec = new Opportunity_Product_Configuration__c();
                                prodConfigRec.Opportunity_Product__c = f.Opportunity_Product__c;
                                System.debug('mapKeyToSpecOption '+mapKeyToSpecOption.get(uniqueKey));
                                prodConfigRec.Product_Specificaiton_Parameter__c = mapKeyToSpecOption.get(uniqueKey).Product_Specification_Parameter__c;
                                prodConfigRec.Product_Specification_Option__c = mapKeyToSpecOption.get(uniqueKey).Id;
                                System.debug('prodConfigRec.Product_Specification_Option__c' +  prodConfigRec.Product_Specification_Option__c);
                                prodConfigRec.Name = f.Name;
                                prodConfigsToInsert.add(prodConfigRec);
                            }
                        }
                    }           
                }
            } 
            
            System.debug('prodConfigsToInsert '+prodConfigsToInsert);
            Database.SaveResult[] results = Database.insert(prodConfigsToInsert, true);
            ErrorLogger.writeErrors('SFDC', 'Insert Product configurations', 'BatchInsertOpportunityProdFeature.Execute ', results, prodConfigsToInsert);
        }catch(Exception ex){
            System.debug('Exception '+ex.getMessage());
            ErrorLogger.writeErrors( 'SFDC', 'Insert Product configurations', 'BatchInsertOpportunityProdFeature.Execute ', new list<Exception>{ex});
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
}