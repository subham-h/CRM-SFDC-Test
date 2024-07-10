/*
 * Author   : Meghana.Gupta@UST
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on Opportunity trigger.
 * 
 * Revision Ref Number      Date        Owner                Description
 * -------- ----------   -----------  -------------------   -----------
 * 1.0      #RQ-002301  26-Feb-2016    Meghana.Gupta@UST                 Created for implementing CBO (Centralized By Org) trigger architecture.
 * 2.0      #RQ-004742  22-May-2017    Meghana.Gupta@UST-Global.com      Update Sales Metrics records on opportunity update/delete
 * 3.0      #RQ-00      06-Jul-2017    Meghana.Gupta@ust-global.com   Code Optimization
                                                                        
 */
 
public class OpportunityTeamMemberTriggerHandler extends TriggerHandler {
  
    public Map<Id, OpportunityTeamMember> newMap;
    public Map<Id, OpportunityTeamMember> oldMap;
      
    public OpportunityTeamMemberTriggerHandler() {
        
        this.newMap = ( map<Id, OpportunityTeamMember> ) Trigger.newMap;
        this.oldMap = ( map<Id, OpportunityTeamMember> ) Trigger.oldMap; 
        
    }
    
    // Use an OpportunityRecordSelector instance to initiate and form lists of opportunities that need to be considered for different functionalities
    public OpportunityTeamMemberRecordSelector otmRecordSelector;
    
    public override void getRecordSelector() {
    
        if (otmRecordSelector == null)
            otmRecordSelector = new OpportunityTeamMemberRecordSelector( Trigger.new, this.oldMap, this);
    
    }
    
    public override void onBeforeInsert() {
        
        OpportunityTeamMemberUtilities.validateTeamMemberList ( otmRecordSelector.newOpptyTeamMemberList );
        OpportunityTeamMemberUtilities.shareContract ( otmRecordSelector.newOpptyTeamMemberList, null, null); 
            
    }

    public override void onBeforeUpdate() {
        
       OpportunityTeamMemberUtilities.validateTeamMemberList ( otmRecordSelector.newOpptyTeamMemberList );
        
    }
    
    public override void onBeforeDelete() {
        if(otmRecordSelector.setOPTMIds.size() > 0) {
            OpportunityTeamMemberUtilities.shareContract ( null, otmRecordSelector.teamMemberOldMap, otmRecordSelector.setOPTMIds );  
        }    
    }
}