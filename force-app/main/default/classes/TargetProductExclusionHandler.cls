public class TargetProductExclusionHandler extends TriggerHandler{
	public List<Target_Product_Exclusion__c> newList;
    public List<Target_Product_Exclusion__c> oldList;
    public Map<Id, Target_Product_Exclusion__c> oldMap;
    
    public TargetProductExclusionHandler() {
        this.newList = (List<Target_Product_Exclusion__c>) Trigger.new;
        this.oldList = (List<Target_Product_Exclusion__c>) Trigger.old;
        this.oldMap = (Map<Id, Target_Product_Exclusion__c>) Trigger.oldMap; 
    }
    
    public override void onBeforeInsert() {
        TargetProductExclusionHelper.checkStageValidation(this.newList);
    }
    
    public override void onAfterInsert() {
        TargetProductExclusionHelper.updateTargetStage(this.newList);
    }
    
    public override void onBeforeUpdate() {
        TargetProductExclusionHelper.checkStageValidation(this.newList);
    }
    
    public override void onBeforeDelete() {
        TargetProductExclusionHelper.checkStageValidation(this.oldList);
    }
    
}