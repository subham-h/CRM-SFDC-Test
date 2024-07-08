public inherited sharing class TargetItemGroupTriggerHandler extends TriggerHandler {
    public List<Target_Item_Group__c> newList;
    public Map<Id, Target_Item_Group__c> oldMap;
    
    public TargetItemGroupTriggerHandler() {
        this.newList = (List<Target_Item_Group__c>) Trigger.new;
        this.oldMap = (Map<Id, Target_Item_Group__c>) Trigger.oldMap; 
    }
    
    public override void onBeforeInsert() {
        TargetItemGroupTriggerHelper.mapCountryBdaDetails(this.newList);
        TargetItemGroupTriggerHelper.updateUniqueExternalId(this.newList);
    }
}