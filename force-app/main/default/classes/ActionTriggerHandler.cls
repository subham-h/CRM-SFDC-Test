/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      SFSE-7819   16-11-2022  Bharti.Rana@maersk     Logic to validate that only internal stakeholder can be the owner of the action       	 
*/

public class ActionTriggerHandler extends TriggerHandler {
    
    public map<Id, Action__c> newMap;
    public map<Id, Action__c> oldMap;
    public ActionTriggerHandler() {
        this.newMap = (map<Id, Action__c>)Trigger.newMap;
        this.oldMap = (map<Id, Action__c>)Trigger.oldMap; 
    }
    
    public ActionRecordSelector actRecordSelector;
    public override void getRecordSelector() {
        actRecordSelector = new ActionRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert() {
        
    }
    
    public override void onBeforeUpdate() {
        if(!this.actRecordSelector.actionList.isEmpty()){
            ActionUtility.Validation2ActionOwner(this.actRecordSelector.actionList);
        }
        
        
    }
    
     
}