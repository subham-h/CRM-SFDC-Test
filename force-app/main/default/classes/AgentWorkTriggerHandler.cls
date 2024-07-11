/**
* Author   : Ragu@UST
* Purpose  : Gives abstract view of all the business logic / functionality implemented on AgenrWorkTrigger.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-8380   22-Aug-2023 Meghna@Maersk              Manual vs Auto Assignment flag

*/
public class AgentWorkTriggerHandler extends TriggerHandler {
    
    public map<Id, AgentWork> newMap;
    public map<Id, AgentWork> oldMap;
    public AgentWorkTriggerHandler() {
        this.newMap = (map<Id, AgentWork>)Trigger.newMap;
        this.oldMap = (map<Id, AgentWork>)Trigger.oldMap; 
    }
    
    public AgentWorkRecordSelector awRecordSelector;
    
    public override void getRecordSelector() {
        awRecordSelector = new AgentWorkRecordSelector (Trigger.new, this.oldMap, this);
    }
    
    public override void onAfterInsert() {

        AgentWorkFieldPopulator.updateCaseAssignmentIndicator(Trigger.new,awRecordSelector.mapRelatedCases);

    }
   
}