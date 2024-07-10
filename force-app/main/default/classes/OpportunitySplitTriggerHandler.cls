/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      RQ-012405   13-Nov-2019 Neha-TCS                Trigger handler to validate split records created against Opportunity 
*/
public class OpportunitySplitTriggerHandler extends TriggerHandler {
    public map<Id, OpportunitySplit> newMap;
    public map<Id, OpportunitySplit> oldMap;
    
    public OpportunitySplitTriggerHandler() {
        this.newMap = (map<Id, OpportunitySplit>)trigger.newMap;
        this.oldMap = (map<Id, OpportunitySplit>)trigger.oldMap; 
    }
    
    public OpportunitySplitRecordSelector recordSelector;
    
    public override void getRecordSelector() {
        recordSelector = new OpportunitySplitRecordSelector( trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeUpdate() { 
        if(!recordSelector.oppid.isEmpty() && !recordSelector.splitOwneridSet.isEmpty()){
            OpportunitySplitUtilities.validateSplitrecordforOpportunities(trigger.new,recordSelector.oppid,recordSelector.splitOwneridSet);
        }
    }
    public override void onBeforeInsert() {         
         if(!recordSelector.oppid.isEmpty() && !recordSelector.splitOwneridSet.isEmpty()){
            OpportunitySplitUtilities.validateSplitrecordforOpportunities(trigger.new,recordSelector.oppid,recordSelector.splitOwneridSet);
         }

    }
    
}