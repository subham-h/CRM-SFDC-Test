/*
 * Revision Ref Number    Date          Owner                Description
 * -------- ----------   -----------  -------------------   --------------------------------------------------------
 * 1.0      SFSE-11402   04-04-2024     Vinay                Capture This year actuals
 */
public inherited sharing class TargetLoadDataTriggerHandler extends TriggerHandler{
  
    public List<Target_Data_Load__c> newList;
    public Map<Id, Target_Data_Load__c> oldMap;
    
    public TargetLoadDataTriggerHandler() {
        this.newList = (List<Target_Data_Load__c>) Trigger.new;
        this.oldMap = (Map<Id, Target_Data_Load__c>) Trigger.oldMap;
    }
    public override void onAfterUpdate() {
        TargetLoadDataTriggerHelper.invokeBatchForActuals(this.newList, this.oldMap);
    }
}