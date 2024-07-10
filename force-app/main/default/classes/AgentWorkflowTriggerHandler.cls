/*
 * Author   : Mudit@UST
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on AgentWorkflow trigger.
 * 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 2.0      RQ-002633   13-08-2020  Mudit@UST               Created for implementing CBO (Centralized By Org) trigger architecture.
 * 1.0      IIP-149     24-08-2020  Avinash@ust             Import Manifest Case - Auto Update
 * 3.0      SC-1141     07-10-2020  Sriram@maersk           Update recordtype to spot FMC,owner assignement, Region and GSC 
 * 4.0      SC-9293     22-12-2023  Shahanawaz@maersk       Create feeditem on parent Case 
*/
public class AgentWorkflowTriggerHandler extends TriggerHandler {
    
    public map<Id, Agent_Workflow__c> newMap;
    public map<Id, Agent_Workflow__c> oldMap;
    public AgentWorkflowTriggerHandler() {
        this.newMap = (map<Id, Agent_Workflow__c>)Trigger.newMap;
        this.oldMap = (map<Id, Agent_Workflow__c>)Trigger.oldMap; 
    }
    
    public AgentWorkflowRecordSelector awRecordSelector;
    
    public override void getRecordSelector() {
        awRecordSelector = new AgentWorkflowRecordSelector (Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert() {
        //THIS METHOD SHOULD EXECUTE AT START ONLY
        //Method to assign record type basis agent workflow type
        if(!awRecordSelector.listToPopulateRecordTypes.isEmpty()){
            AgentWorkflowFieldPopulator.updateWorkflowRecordType(awRecordSelector.listToPopulateRecordTypes);
        }
        
        // SC-1141 update record type and other fields to Spot FMC
        if(!awRecordSelector.listSpotFMCRecords.isEmpty()){
            AgentWorkflowFieldPopulator.updateSpotFMCFields(awRecordSelector.listSpotFMCRecords,awRecordSelector.agentAndCountryMap);
        }
        
        // IIP-926 update longTextArea field with line breaks for all formukas
        if(!awRecordSelector.listToPopulateRecordTypes.isEmpty()){
            AgentWorkflowFieldPopulator.updateLongTextAreaFields(awRecordSelector.listToPopulateRecordTypes);
        }
        
        //Method to update agent workflow status field basis Approvals needed field as per workflow queue management rules
        /*if(!awRecordSelector.listApprovalNeededAW.isEmpty()){
            AgentWorkflowFieldPopulator.updateStatusbasisApprovalNeeded(awRecordSelector.listApprovalNeededAW);
        }*/
    }
    
    public override void onBeforeUpdate() {
        if(!awRecordSelector.listClosedAW.isEmpty()) {
            AgentWorkflowFieldPopulator.updateAgentWorkflowOwner( awRecordSelector.listClosedAW,awRecordSelector.mapRelatedCases );
        }
    }
    
    public override void onAfterUpdate() {
        //Update child workflow status on basis parent workflows
        if(!awRecordSelector.listChildToUpdate.isEmpty()){
            AgentWorkflowFieldPopulator.updateChildWorkflowStatus(awRecordSelector.listChildToUpdate,awRecordSelector.mapRelatedAW);
        }
        
        //Update Case Owner as AW Owner,Status and Resolution Summary when Agent Workflow Approved / Rejected
        if(!awRecordSelector.listClosedAW.isEmpty()){
            AgentWorkflowFieldPopulator.updateCaseClosureOwnerOnAWClosure(awRecordSelector.listClosedAW,awRecordSelector.mapRelatedCases);
        }
    }
    
    public override void onAfterInsert(){
        //Method to Update Case owner,Status and Resolution Summary as agent workflow owner when workflow is auto-approved.
        //This logic will execute only on insert
        if(!awRecordSelector.listAutoApprovedAW.isEmpty()) {
            AgentWorkflowFieldPopulator.updateCaseOwnerOnAWAutoApproved(awRecordSelector.listAutoApprovedAW,awRecordSelector.setAutoApprovedAWCases,awRecordSelector.mapRelatedCases);
        }
        
        if(!awRecordSelector.agentWorkflowListForFeed.isEmpty()){
            AgentWorkflowFieldPopulator.createFeedItem(awRecordSelector.agentWorkflowListForFeed);
        }
    }
}