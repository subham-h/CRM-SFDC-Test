/**
 * Author   : Samarpreet Singh
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on Opportunity Product Configuration trigger.
 * 
 * Revision Ref Number      Date        Owner                             Description
 * -------- ----------   -----------  -------------------                 -----------
 * 1.0      SFSE-12549   11-Sept-2023 Samar@Maersk                       Created a new Trigger on Opportunity Product Configuration Object
 * 2.0		SFSE-12889	 16-Oct-2023  Jothsana@maersk.com				 To make OLI event publish queable
 * 3.0      SFSE-13391   09-May-2024  Shashi@Maersk                      Added conditions to prevent Opportunity Product Configuration insert/update/delete on closed opportunities.
**/
public class OpptyProductConfigTriggerHandler extends TriggerHandler{
    public Map<Id, Opportunity_Product_Configuration__c> newMap;
    public Map<Id, Opportunity_Product_Configuration__c> oldMap;
    
    
    public OpptyProductConfigTriggerHandler() {
  
        this.newMap = ( map<Id, Opportunity_Product_Configuration__c> ) Trigger.newMap;
        this.oldMap = ( map<Id, Opportunity_Product_Configuration__c> ) Trigger.oldMap; 
    }
    
    public OpptyProductConfigRecordSelector opptyProductConfigRecordSelector;
    
    public override void getRecordSelector() {    
        if (opptyProductConfigRecordSelector == null){
            opptyProductConfigRecordSelector = new OpptyProductConfigRecordSelector( Trigger.new, this.oldMap, this);
        }
    }
    
    public override void onBeforeInsert(){
        if(!OpptyProductConfigRecordSelector.lstConfigOfClosedOppty.IsEmpty()){
            OpptyProductConfigUtility.preventConfigModification(OpptyProductConfigRecordSelector.lstConfigOfClosedOppty);
        }
    }
    
    public override void onAfterInsert() {
        if(!OpptyProductConfigRecordSelector.setOfOpptyProduct.isEmpty()){
            OpptyProductConfigUtility.updateOpptyProduct(OpptyProductConfigRecordSelector.setOfOpptyProduct,new Set<Id>{},false);
        }
        
         // future method to call the OLI Events
        if(OpptyProductConfigRecordSelector.setOpptyProductIdtoProcess.size()>0 && (!System.isFuture() && !System.isBatch() && !System.isQueueable() && !System.isScheduled())){
            OLIEventResponseHandler.fireQueableOliEventsAsync(new List<Id>(OpptyProductConfigRecordSelector.setOpptyProductIdtoProcess), false, true, true,false);
        }else if(OpptyProductConfigRecordSelector.setOpptyProductIdtoProcess.size()>0 && (System.isFuture() || System.isBatch() || System.isQueueable() || System.isScheduled())){
             OLIEventResponseHandler.fireOliEventAsync(new List<Id>(OpptyProductConfigRecordSelector.setOpptyProductIdtoProcess), false, true, true,false);
        }
    }
 
    public override void onBeforeUpdate(){
        if(!OpptyProductConfigRecordSelector.lstConfigOfClosedOppty.IsEmpty()){
            OpptyProductConfigUtility.preventConfigModification(OpptyProductConfigRecordSelector.lstConfigOfClosedOppty);
        }
    }
       
    public override void onAfterUpdate(){
        if(!OpptyProductConfigRecordSelector.setOfOpptyProduct.isEmpty()){
            OpptyProductConfigUtility.updateOpptyProduct(OpptyProductConfigRecordSelector.setOfOpptyProduct,new Set<Id>{},false);
        }
        
         // future method to call the OLI Events
        if(OpptyProductConfigRecordSelector.setOpptyProductIdtoProcess.size()>0 && (!System.isFuture() && !System.isBatch() && !System.isQueueable() && !System.isScheduled())){
            OLIEventResponseHandler.fireQueableOliEventsAsync(new List<Id>(OpptyProductConfigRecordSelector.setOpptyProductIdtoProcess), false, true, true,false);
        }else if(OpptyProductConfigRecordSelector.setOpptyProductIdtoProcess.size()>0 && (System.isFuture() || System.isBatch() || System.isQueueable() || System.isScheduled())){
             OLIEventResponseHandler.fireOliEventAsync(new List<Id>(OpptyProductConfigRecordSelector.setOpptyProductIdtoProcess), false, true, true, false);
        }
    }

    public override void onBeforeDelete(){
        if(!OpptyProductConfigRecordSelector.setOfProducts.isEmpty() ){
            OpptyProductConfigUtility.updateOpptyProduct(OpptyProductConfigRecordSelector.setOfProducts,OpptyProductConfigRecordSelector.setOfDeleteConfig,true);
        }
        
        
        // future method to call the OLI Events
        if(OpptyProductConfigRecordSelector.lstOpptyProductIdonDelete.size()>0 && (!System.isFuture() && !System.isBatch() && !System.isQueueable() && !System.isScheduled())){
            OLIEventResponseHandler.fireQueableOliEventsAsync(new List<Id>(OpptyProductConfigRecordSelector.lstOpptyProductIdonDelete), false, true, true,false);
            //OpptyProductConfigUtility.fireQueableOliEventsAsync(new List<Id>(OpptyProductConfigRecordSelector.lstOpptyProductIdonDelete), false);
        }else if(OpptyProductConfigRecordSelector.lstOpptyProductIdonDelete.size()>0 && (System.isFuture() || System.isBatch() || System.isQueueable() || System.isScheduled())){
             OLIEventResponseHandler.fireOliEventAsync(new List<Id>(OpptyProductConfigRecordSelector.lstOpptyProductIdonDelete), false, true, true, false);
        }
        
        if(!OpptyProductConfigRecordSelector.lstConfigOfClosedOppty.IsEmpty()){
            OpptyProductConfigUtility.preventConfigModification(OpptyProductConfigRecordSelector.lstConfigOfClosedOppty);
        }
    }
}