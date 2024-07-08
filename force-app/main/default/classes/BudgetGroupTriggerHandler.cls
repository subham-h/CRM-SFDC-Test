public inherited sharing class BudgetGroupTriggerHandler extends TriggerHandler {
    public List<Budget_Group__c> newList;
    public Map<Id, Budget_Group__c> oldMap;
    
    public BudgetGroupTriggerHandler() {
        this.newList = (List<Budget_Group__c>) Trigger.new;
        this.oldMap = (Map<Id, Budget_Group__c>) Trigger.oldMap; 
    }
    
    public override void onBeforeInsert() {
        BudgetGroupTriggerHelper.mapCountryBdaDetails(this.newList);
        BudgetGroupTriggerHelper.updateUniqueExternalId(this.newList);
    }

    public override void onAfterInsert() {
        BudgetGroupTriggerHelper.createCorrespondingTargetItemGroup(this.newList);
    }
}