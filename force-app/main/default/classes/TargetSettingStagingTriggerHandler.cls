Public inherited sharing class TargetSettingStagingTriggerHandler extends TriggerHandler{
    public List<Target_Setting_Staging__c> newList;
    
    public TargetSettingStagingTriggerHandler() {
        this.newList = (List<Target_Setting_Staging__c>) Trigger.new;
    }
    
    public override void onBeforeInsert() {
        TargetSettingStagingTriggerHelper.initAndValidateData(this.newList);
    }
    
    public override void onAfterInsert() {
		TargetSettingStagingTriggerHelper.evaluateCreditEligibility(this.newList);
    }
}