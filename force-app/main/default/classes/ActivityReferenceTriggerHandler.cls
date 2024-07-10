public class ActivityReferenceTriggerHandler extends TriggerHandler {
    
    public map<Id, Activity_Related_Reference__c> newMap;
    public map<Id, Activity_Related_Reference__c> oldMap;
    public List<Activity_Related_Reference__c> newList;
    public ActivityReferenceTriggerHandler() {
        this.newMap = (map<Id, Activity_Related_Reference__c>)Trigger.newMap;
        this.oldMap = (map<Id, Activity_Related_Reference__c>)Trigger.oldMap; 
        this.newList = (List<Activity_Related_Reference__c>)Trigger.new;
    }
    
    public ActivityReferenceRecordSelector arrRecordSelector;
    
   
    public override void getRecordSelector() {
        arrRecordSelector= new ActivityReferenceRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert() {
        for( Activity_Related_Reference__c ar : newList){
            if(arrRecordSelector.caseCountMap <> NULL && arrRecordSelector.caseCountMap.containsKey(ar.Case__c)){
                system.debug('Activity already exists');
                ar.addError('Cannot create Activity Related Reference. Case can have only one Activity Related Reference');
            }
        }
    }
    
    public override void onAfterInsert(){
        if(!arrRecordSelector.arfList.isEmpty()){
            ActivityReferenceTriggerHelper.createFeedItem(arrRecordSelector.arfList);
        }
    }

}