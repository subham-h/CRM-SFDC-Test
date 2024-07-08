/*
* Trigger Handler Utility Class for OpptyProductConfigTriggerHandler Trigger
* 
* Revision Ref Number   Date            Owner                           Description
* -------- ----------   -----------     -------------------             --------------------------------------------------------
* 1.0      SFSE-12549   11-Sept-2023     Samar@Maersk                   Created a new Trigger on Opportunity Product Configuration Object
* 2.0      SFSE-13391   09-May-2024      Shashi@Maersk                  Added conditions to prevent Opportunity Product Configuration insert/update/delete on closed opportunities.

*/
public class OpptyProductConfigUtility {
   
    public static void updateOpptyProduct(Set<Id> setOfOpptyProduct, Set<Id> setOfDeleteConfig,Boolean isDelete){
        Map<Id,List<Id>> mapOfOpptyProductAndTotalMandatory= new Map<Id,List<Id>>();
        Map<Id,List<Id>> mapOfOpptyProductAndTotalMandatoryFilled= new Map<Id,List<Id>>();
        Map<Id,List<Id>> mapOfOpptyProductAndTotalConfig= new Map<Id,List<Id>>();
        Map<Id,List<Id>> mapOfOpptyProductAndTotalConfigFilled= new Map<Id,List<Id>>();
        Set<Opportunity_Product__c> setOfOpportunityProduct=  new  Set<Opportunity_Product__c>();
        Map<Id,Id> mapOfOpptyProductwithProduct = new  Map<Id,Id>();

        //try{
            if(!setOfOpptyProduct.isEmpty()){
                for(Opportunity_Product_Configuration__c config:[SELECT id,Opportunity_Product_Cus__c, Product_Specification_Option__c,Product_Specificaiton_Parameter__c,Product_Specificaiton_Parameter__r.Is_Mandatory__c,Is_Feature_Included__c,Is_Specification_Parameter_Included__c,
                Product_Specificaiton_Parameter__r.Configurable_at_Contracting__c,Product_Specificaiton_Parameter__r.Type__c,Product_Specificaiton_Parameter__r.Sales_Configurable__c  FROM Opportunity_Product_Configuration__c WHERE Opportunity_Product_Cus__c IN :setOfOpptyProduct] ){
                   
                    if(config.Product_Specificaiton_Parameter__c!= null &&  config.Product_Specificaiton_Parameter__r.Type__c =='options' && config.Product_Specificaiton_Parameter__r.Sales_Configurable__c && !setOfDeleteConfig.contains(config.id) && config.Is_Feature_Included__c && config.Is_Specification_Parameter_Included__c){
                       
                        if(config.Product_Specificaiton_Parameter__r.Is_Mandatory__c){
                            //Total mandatory Configurations Filled
                            if(config.Product_Specification_Option__c != null){
                                if(mapOfOpptyProductAndTotalMandatoryFilled.containsKey(config.Opportunity_Product_Cus__c)){
                                    if(!mapOfOpptyProductAndTotalMandatoryFilled.get(config.Opportunity_Product_Cus__c).contains(config.Product_Specificaiton_Parameter__c)){
                                        mapOfOpptyProductAndTotalMandatoryFilled.get(config.Opportunity_Product_Cus__c).add(config.Product_Specificaiton_Parameter__c);
                                    }
                                }else{
                                    mapOfOpptyProductAndTotalMandatoryFilled.put(config.Opportunity_Product_Cus__c, new List<Id>{config.Product_Specificaiton_Parameter__c});
                                }
                            }

                            // Total mandatory Configurations
                            if(mapOfOpptyProductAndTotalMandatory.containsKey(config.Opportunity_Product_Cus__c)){
                                if(!mapOfOpptyProductAndTotalMandatory.get(config.Opportunity_Product_Cus__c).contains(config.Product_Specificaiton_Parameter__c)){
                                    mapOfOpptyProductAndTotalMandatory.get(config.Opportunity_Product_Cus__c).add(config.Product_Specificaiton_Parameter__c);
                                }
                            }else{
                                mapOfOpptyProductAndTotalMandatory.put(config.Opportunity_Product_Cus__c, new List<Id>{config.Product_Specificaiton_Parameter__c});
                            }
                        }

                        //Total Configurations  
                        if(mapOfOpptyProductAndTotalConfig.containsKey(config.Opportunity_Product_Cus__c)){
                            if(!mapOfOpptyProductAndTotalConfig.get(config.Opportunity_Product_Cus__c).contains(config.Product_Specificaiton_Parameter__c)){
                                mapOfOpptyProductAndTotalConfig.get(config.Opportunity_Product_Cus__c).add(config.Product_Specificaiton_Parameter__c);
                            }
                        }else{
                            mapOfOpptyProductAndTotalConfig.put(config.Opportunity_Product_Cus__c, new List<Id>{config.Product_Specificaiton_Parameter__c});
                        }
                        
                        //Total Configurations Filled 
                        if(config.Product_Specification_Option__c != null){
                            if(mapOfOpptyProductAndTotalConfigFilled.containsKey(config.Opportunity_Product_Cus__c)){
                                if(!mapOfOpptyProductAndTotalConfigFilled.get(config.Opportunity_Product_Cus__c).contains(config.Product_Specificaiton_Parameter__c)){
                                    mapOfOpptyProductAndTotalConfigFilled.get(config.Opportunity_Product_Cus__c).add(config.Product_Specificaiton_Parameter__c);
                                }
                            }else{
                                mapOfOpptyProductAndTotalConfigFilled.put(config.Opportunity_Product_Cus__c, new List<Id>{config.Product_Specificaiton_Parameter__c});
                            }
                        }
                    }   
                }
                
                /*
                List<Opportunity_Product__c> lstOpptyProd = [SELECT id, Product2ID__c, Total_Configurations__c, Total_Configurations_Filled__c,Total_Mandatory_Configuration__c, Total_Mandatory_Configuration_Filled__c FROM Opportunity_Product__c WHERE ID IN :setOfOpptyProduct ];

                for(Opportunity_Product__c opptyProd : lstOpptyProd ){
                    if(!mapOfOpptyProductwithProduct.containsKey(opptyProd.id)){
                        mapOfOpptyProductwithProduct.put(opptyProd.id,opptyProd.Product2ID__c);
                    }
                }
             
                if(!mapOfOpptyProductwithProduct.values().isEmpty()){
                    for(Product_Specification_Parameter__c parameter:[SELECT id,Type__c, Is_Mandatory__c, Configurable_at_Contracting__c, Product_Feature__r.Product_Component__r.Product__c FROM Product_Specification_Parameter__c WHERE Product_Feature__r.Product_Component__r.Product__c IN :mapOfOpptyProductwithProduct.values()]){
                        if(parameter.Type__c =='options' && parameter.Configurable_at_Contracting__c){
                            // Total mandatory Configurations
                            if(parameter.Is_Mandatory__c){
                                if(mapOfOpptyProductAndTotalMandatory.containsKey(config.Opportunity_Product_Cus__c)){
                                    if(!mapOfOpptyProductAndTotalMandatory.get(config.Opportunity_Product_Cus__c).contains(config.Product_Specificaiton_Parameter__c)){
                                        mapOfOpptyProductAndTotalMandatory.get(config.Opportunity_Product_Cus__c).add(config.Product_Specificaiton_Parameter__c);
                                    }
                                }else{
                                    mapOfOpptyProductAndTotalMandatory.put(config.Opportunity_Product_Cus__c, new List<Id>{config.Product_Specificaiton_Parameter__c});
                                }
                            }

                            //Total Configurations  
                            if(mapOfOpptyProductAndTotalConfig.containsKey(config.Opportunity_Product_Cus__c)){
                                if(!mapOfOpptyProductAndTotalConfig.get(config.Opportunity_Product_Cus__c).contains(config.Product_Specificaiton_Parameter__c)){
                                    mapOfOpptyProductAndTotalConfig.get(config.Opportunity_Product_Cus__c).add(config.Product_Specificaiton_Parameter__c);
                                }
                            }else{
                                mapOfOpptyProductAndTotalConfig.put(config.Opportunity_Product_Cus__c, new List<Id>{config.Product_Specificaiton_Parameter__c});
                            }
                        }
                    }
                }
                */
    
                for(Opportunity_Product__c opptyProd : [SELECT id, Product2ID__c, Total_Configurations__c, Total_Configurations_Filled__c,Total_Mandatory_Configuration__c, Total_Mandatory_Configuration_Filled__c FROM Opportunity_Product__c WHERE ID IN :setOfOpptyProduct ] ){

                    opptyProd.Total_Configurations__c = mapOfOpptyProductAndTotalConfig.containsKey(opptyProd.id) ? mapOfOpptyProductAndTotalConfig.get(opptyProd.id).size() :  0;
                    
                    opptyProd.Total_Mandatory_Configuration__c = mapOfOpptyProductAndTotalMandatory.containsKey(opptyProd.id) ? mapOfOpptyProductAndTotalMandatory.get(opptyProd.id).size() : 0;

                   /* if(!isDelete){
                        opptyProd.Total_Configurations_Filled__c = mapOfOpptyProductAndTotalConfigFilled.containsKey(opptyProd.id) ? mapOfOpptyProductAndTotalConfigFilled.get(opptyProd.id).size() :opptyProd.Total_Configurations_Filled__c;

                        opptyProd.Total_Mandatory_Configuration_Filled__c = mapOfOpptyProductAndTotalMandatoryFilled.containsKey(opptyProd.id) ? mapOfOpptyProductAndTotalMandatoryFilled.get(opptyProd.id).size() :opptyProd.Total_Mandatory_Configuration_Filled__c;
                    }else{*/
                        opptyProd.Total_Configurations_Filled__c =  mapOfOpptyProductAndTotalConfigFilled.containsKey(opptyProd.id) ? mapOfOpptyProductAndTotalConfigFilled.get(opptyProd.id).size() : 0 ;

                        opptyProd.Total_Mandatory_Configuration_Filled__c = mapOfOpptyProductAndTotalMandatoryFilled.containsKey(opptyProd.id) ? mapOfOpptyProductAndTotalMandatoryFilled.get(opptyProd.id).size() : 0 ;
                   // }
                    

                    setOfOpportunityProduct.add(opptyProd);
                }
    
                if(!setOfOpportunityProduct.isEmpty()){
                    OpportunityProductRecordSelector.oppProductTrigger = false;
                    TriggerExecutionController.skipAllTriggers(true);
                   /* Bypass_Product_Upgrade_Validation__c bt= Bypass_Product_Upgrade_Validation__c.getInstance();
            	    bt.Skip_Validation__c = true;
            	    insert bt;*/
                    Database.SaveResult[] results  = Database.update(new List<Opportunity_Product__c>(setOfOpportunityProduct),false);
                  /* Bypass_Product_Upgrade_Validation__c btt= Bypass_Product_Upgrade_Validation__c.getInstance();
            	    delete btt;*/
                    TriggerExecutionController.skipAllTriggers(false);
                    ErrorLogger.writeErrors('SFDC', 'OpptyProductConfigUtility', 'OpptyProductConfigUtility.updateOpptyProduct()', results  , new List<Opportunity_Product__c>(setOfOpportunityProduct)); 
                }
          }
        /*}catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OpptyProductConfigUtility', 'OpptyProductConfigUtility', new list<Exception>{ex});
        }*/
    }

    /*
    public static void processOpptyProductEvent(List<Id> lstofproduct,Boolean isOpptyBoolean){
        System.enqueueJob(new OpptyProductEventQueueable(lstofproduct,isOpptyBoolean));
    }*/
    
    public static void preventConfigModification(List<Opportunity_Product_Configuration__c> lstOpptyProdConfig){
            if(!lstOpptyProdConfig.isEmpty()){
                System.debug('inpreventConfigModification');
                for(Opportunity_Product_Configuration__c opptyProdConfig : lstOpptyProdConfig){
                opptyProdConfig.addError('Configuration changes cannot be made to closed opportunities.');
              }
        }   
    }
}