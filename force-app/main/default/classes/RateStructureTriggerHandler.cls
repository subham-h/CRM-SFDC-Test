/*
 * Author   : Meghana.Gupta@UST-Global.com
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on Opportunity trigger.
 * 
 * Revision Ref Number    Date            Owner                          Description
 * -------- ----------   -----------  -------------------              --------------------------------------------------------
 * 1.0      RQ-003428   19-Jul-2016     Meghana.Gupta@ust-global.com	Code created
 * 2.0      RQ-009022   13/08/2018      Junaid.Khader@ust-global.com	Salesforce completes related task when rate structure is approved
 * 3.0		SFSE-6393	14-Jun-2021		Kiran@Maersk					ProjectTaskStatus update logic removed as Project_Task__c deprecation
 */
 
public class RateStructureTriggerHandler extends TriggerHandler {
  
    public Map<Id, Rate_Structure__c> newMap;
    public Map<Id, Rate_Structure__c> oldMap;
    public RateStructureRecordSelector rateStructRecordSelector;
    
    public RateStructureTriggerHandler() {
        
        this.newMap = ( map<Id, Rate_Structure__c> ) Trigger.newMap;
        this.oldMap = ( map<Id, Rate_Structure__c> ) Trigger.oldMap; 
        
    }
    
    public override void getRecordSelector() {
        if (rateStructRecordSelector == null){
            rateStructRecordSelector = new RateStructureRecordSelector( Trigger.new, this.oldMap, this);
        }
    }
    
    public override void onBeforeInsert() {
        
       
    }

    public override void onBeforeUpdate() {
        
       
    }

    public override void onAfterInsert() {
      
        RateStructure_Utilities.addRateStructureItems( newMap.values() );
    }
    
    public override void onAfterUpdate() {
        
        
    }
}