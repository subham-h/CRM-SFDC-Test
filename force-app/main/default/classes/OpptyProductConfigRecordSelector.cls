/**
* Purpose  : Centralize the record selection process for User object.
*          Defines the methods which iterate and segregate the User records for further use.
* 
* Revision Ref Number   Date            Owner                           Description
* -------- ----------   -----------     -------------------             --------------------------------------------------------
* 1.0      SFSE-12549   11-Sept-2023     Samar@Maersk                   Created a new Trigger on Opportunity Product Configuration Object
* 2.0      SFSE-13391   09-May-2024      Shashi@Maersk                  Added conditions to prevent Opportunity Product Configuration insert/update/delete on closed opportunities.
**/
public class OpptyProductConfigRecordSelector{
    private OpptyProductConfigTriggerHandler opptyProductConfigTriggerHandler ;

    public Set<Id> setOfOpptyProduct = new Set<Id>();
    public Set<Id> setOpptyProductIdtoProcess = new Set<Id>();
    public Set<Id> lstOpptyProductIdonDelete = new Set<Id>();
    public Set<Id> setOfProducts = new Set<Id>();
    public set<Id> setOfDeleteConfig =  new Set<Id>();
    public List<Opportunity_Product_Configuration__c> lstConfigOfClosedOppty = new List<Opportunity_Product_Configuration__c>();
    public Map<Id, Opportunity_Product_Configuration__c> configMap;
    Set<Id> setConfigId = new Set<Id>();
    
    public OpptyProductConfigRecordSelector( List<Opportunity_Product_Configuration__c> lstconfig, map<Id, Opportunity_Product_Configuration__c> mapOldConfig, OpptyProductConfigTriggerHandler opptyProductConfigTriggerHandler) {
    
        this.opptyProductConfigTriggerHandler = opptyProductConfigTriggerHandler;
        selectRecords(lstconfig, mapOldConfig); 
    } 
   
    
    public void selectRecords(List<Opportunity_Product_Configuration__c> lstconfig, Map<Id, Opportunity_Product_Configuration__c> mapOldConfig) {
        
        if(lstconfig != null){
            for(Opportunity_Product_Configuration__c configRecord : lstconfig){
            setConfigId.add(configRecord.Id);
        }
        }
        
        
        configMap = new Map<Id, Opportunity_Product_Configuration__c>([SELECT Id, Opportunity_Product_Cus__r.OpportunityId__c, Opportunity_Product_Cus__r.OpportunityId__r.isClosed
                                                                                    FROM Opportunity_Product_Configuration__c 
                                                                                    WHERE Id IN :setConfigId]);
        
        if (lstconfig != null){
            for(Opportunity_Product_Configuration__c configRecord: lstconfig ){
                Opportunity_Product_Configuration__c oldconfig;
                if(mapOldConfig != null){
                    oldconfig = mapOldConfig.get(configRecord.id);
                }
                
                if(opptyProductConfigTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && opptyProductConfigTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE ){
                    if(configMap.get(configRecord.Id).Opportunity_Product_Cus__r.OpportunityId__r.isClosed == true ){
                    /*setOfProducts.add(oldConfig.Opportunity_Product_Cus__c);
                    setOfDeleteConfig.add(oldConfig.Id);
                    lstOpptyProductIdonDelete.add(oldConfig.Opportunity_Product_Cus__c);*/
                    lstConfigOfClosedOppty.add(configRecord);
                }
                }
                
                if(opptyProductConfigTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER && (opptyProductConfigTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE  || opptyProductConfigTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT)
                    && configRecord.Opportunity_Product_Cus__c != null ){
                    setOfOpptyProduct.add(configRecord.Opportunity_Product_Cus__c );
                }
                if(opptyProductConfigTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER  && (opptyProductConfigTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT ||  ( opptyProductConfigTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE 
                && (configRecord.Product_Specification_Option__c != oldconfig.Product_Specification_Option__c || configRecord.Product_Specificaiton_Parameter__c != oldconfig.Product_Specificaiton_Parameter__c 
                || configRecord.Configured_Product_Feature__c != oldconfig.Configured_Product_Feature__c || configRecord.Is_Feature_Included__c != oldconfig.Is_Feature_Included__c || configRecord.Is_Specification_Parameter_Included__c != oldconfig.Is_Specification_Parameter_Included__c  ) ) )){
                    setOpptyProductIdtoProcess.add(configRecord.Opportunity_Product_Cus__c );
                }                      
            } 
        }else{
            for(Opportunity_Product_Configuration__c oldConfig:mapOldConfig.values()){                           
                if(oldConfig.Opportunity_Product_Cus__r.OpportunityId__r.IsClosed == false && opptyProductConfigTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE &&  opptyProductConfigTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE && oldConfig.Opportunity_Product_Cus__c != null){
                    setOfProducts.add(oldConfig.Opportunity_Product_Cus__c);
                    setOfDeleteConfig.add(oldConfig.Id);
                    lstOpptyProductIdonDelete.add(oldConfig.Opportunity_Product_Cus__c);
                }
                if(oldConfig.Opportunity_Product_Cus__r.OpportunityId__r.IsClosed == true && opptyProductConfigTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE &&  (opptyProductConfigTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT || opptyProductConfigTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE)){
                    /*setOfProducts.add(oldConfig.Opportunity_Product_Cus__c);
                    setOfDeleteConfig.add(oldConfig.Id);
                    lstOpptyProductIdonDelete.add(oldConfig.Opportunity_Product_Cus__c);*/
                    lstConfigOfClosedOppty.add(oldConfig);
                }
                
            } 
        }
    }
    
}