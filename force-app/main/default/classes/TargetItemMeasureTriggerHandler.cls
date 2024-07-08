/*
*  User Story       Date        Developer       Functionality
*  SFSE-11420       30/08/2023  Anjali          Created
*  SFSE-10711       05/09/2023  Aditi           Create Sales Target Item Measure records with Measure_dimension__c = 'Target' on after insert of 
Sales Target Item Measure records with Measure_dimension__c = 'Previous Year Actuals'

SFSE-13010       18/10/2023  Arpitha J       Applying percent to target dimension records                                                
* SFSE- 10712   07/11/2023   Bharti     Calling 'TargetsAssignToSalesRep' class to assign rep to targets on after insert 
*/
public inherited sharing class TargetItemMeasureTriggerHandler extends TriggerHandler {
    
    public List<Target_Measure__c> newList;
    public Map<Id, Target_Measure__c> oldMap; 
    
    public TargetItemMeasureTriggerHandler() {
        this.newList = (List<Target_Measure__c>) Trigger.new;
        this.oldMap = (Map<Id, Target_Measure__c>)Trigger.oldMap; 
    }
    public TargetItemMeasureRecordSelector ItemMeasureRecordSelector;
    public override void getRecordSelector() {
        ItemMeasureRecordSelector = new TargetItemMeasureRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert() {
        if(ItemMeasureRecordSelector.befInsertList.size() > 0) {
            TargetItemMeasureTriggerHelper.generateUniqueKey(ItemMeasureRecordSelector.befInsertList);
        }
    }  
    
    //SFSE-11420
    public override void onBeforeUpdate() {
        if(ItemMeasureRecordSelector.befUpdateList.size() > 0) {
            TargetItemMeasureTriggerHelper.generateUniqueKey(ItemMeasureRecordSelector.befUpdateList);
        }
    } 
    //10712
    public override void onAfterInsert() {
        if(ItemMeasureRecordSelector.afterInsertMeasureList != null && ItemMeasureRecordSelector.afterInsertMeasureList.size() > 0 )
            System.debug('called your class');
            TargetsAssignToSalesRep.getSalesTargetItemMeasure(ItemMeasureRecordSelector.afterInsertMeasureList);
    }
    
    public override void onAfterUpdate() {
        System.debug('after update ');
        if(TriggerExecutionController.isMeasureTriggerSkip){
            if(TriggerExecutionController.isRun){
                TriggerExecutionController.isRun = false;
                TargetItemMeasureTriggerHelper.updateTargetMeasurePercentage(ItemMeasureRecordSelector.afterUpdateList, ItemMeasureRecordSelector.oldTargetMeasureMap);
            }
        }
        
    }
    
}