/*********************************************************************
Description : Handler Class for Target Item 
**********************************************************************/
public inherited sharing class TargetItemTriggerHandler extends TriggerHandler {
    public List<Target_Item__c> newList;
    public Map<Id, Target_Item__c> oldMap;
    
    public TargetItemTriggerHandler() {
        this.newList = (List<Target_Item__c>) Trigger.new;
        this.oldMap = (Map<Id, Target_Item__c>) Trigger.oldMap;
    }
    
    public override void onBeforeInsert() {
        TargetItemTriggerHelper.generateUniqueIdentifier(this.newList);
        TargetItemTriggerHelper.accountDetails(this.newList, this.oldMap);
        TargetItemTriggerHelper.populateSalesTarget(this.newList);
    }

    public override void onBeforeUpdate() {
        TargetItemTriggerHelper.uniqueIdentifierOnAccountChange(this.newList, this.oldMap);
        TargetItemTriggerHelper.targetCannotBeRemoved(this.newList, this.oldMap);
        TargetItemTriggerHelper.accountDetails(this.newList, this.oldMap);
    }
}