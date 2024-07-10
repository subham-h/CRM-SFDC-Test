/* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0                   05-09-23    Anjali@maersk           Created
* 
*/
public inherited sharing class BudgetMeasureTriggerHandler extends TriggerHandler{
   public List<Budget_Measure__c> newList;
   public Map<Id, Budget_Measure__c> oldMap;
    
    public BudgetMeasureTriggerHandler() {
        this.newList = (List<Budget_Measure__c>) Trigger.new;
        this.oldMap = (Map<Id, Budget_Measure__c>) Trigger.oldMap; 
    }
    public BudgetMeasureRecordSelector bdgtMeasureRecordSelector;
    public override void getRecordSelector() {
        bdgtMeasureRecordSelector = new BudgetMeasureRecordSelector(Trigger.new, this.oldMap, this);
    }  
    public override void onBeforeInsert() {
        if(bdgtMeasureRecordSelector.befInsertList.size() > 0) {
            System.debug('handler before insert');
            BudgetMeasureTriggerHelper.checkForDuplicateBudgetMeasure(bdgtMeasureRecordSelector.befInsertList);
        }
    }  
    public override void onBeforeUpdate() {
        if(bdgtMeasureRecordSelector.befUpdateList.size() > 0) {
             System.debug('handler before update');
             BudgetMeasureTriggerHelper.checkForDuplicateBudgetMeasure(bdgtMeasureRecordSelector.befUpdateList);
        }
    }
}