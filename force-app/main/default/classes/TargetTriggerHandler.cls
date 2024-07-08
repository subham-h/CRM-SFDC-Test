public inherited sharing class TargetTriggerHandler extends TriggerHandler {
	
    public List<Target__c> newList;
    public Map<Id, Target__c> oldMap;
    
    public TargetTriggerHandler() {
        this.newList = (List<Target__c>) Trigger.new;
        this.oldMap = (Map<Id, Target__c>) Trigger.oldMap;
    }
    
    public override void onBeforeInsert() {
        TargetTriggerHelper.checkForActiveTarget(this.newList,null);   
    }
    
    public override void onBeforeUpdate() {
        TargetTriggerHelper.checkValidations(this.newList, this.oldMap);
    }
    
    public override void onAfterUpdate() {
        TargetTriggerHelper.updateStage(this.newList, this.oldMap);
    }
    
    
}