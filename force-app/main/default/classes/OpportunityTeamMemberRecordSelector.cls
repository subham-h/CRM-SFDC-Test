/*
* Purpose  : Centralize the record selection process for User object.
*          Defines the methods which iterate and segregate the User records for further use.
* 
* Revision Ref Number   Date            Owner                           Description
* -------- ----------   -----------     -------------------             --------------------------------------------------------
* 1.0      #RQ-00       06-Jul-2017     Meghana.Gupta@ust-global.com   Created for implementing CBO (Centralized By Org) trigger architecture.
*/

public class OpportunityTeamMemberRecordSelector implements RecordSelector {
    
    private OpportunityTeamMemberTriggerHandler opptyTMTriggerHandler;
    public List<OpportunityTeamMember> oppTMemeberList = new List<OpportunityTeamMember>(); 
    public Map<Id, OpportunityTeamMember> teamMemberOldMap = new Map<Id, OpportunityTeamMember>();
    public List<OpportunityTeamMember> newOpptyTeamMemberList = new List<OpportunityTeamMember>();
    public Set<Id> setOPTMIds = new Set<Id>();
      
        
    // constructor 
    public OpportunityTeamMemberRecordSelector ( List<OpportunityTeamMember> lstOppty, map<Id, OpportunityTeamMember> mapOldOppty, OpportunityTeamMemberTriggerHandler opptyTMTriggerHandler) {
        
        this.opptyTMTriggerHandler = opptyTMTriggerHandler;
        selectRecords(lstOppty, mapOldOppty); // call method to set all required opportunity lists
               
    }
    
    // Method to check different conditions and form opportunity lists that will be used in UserTriggerHandler
    public void selectRecords(list<OpportunityTeamMember> triggerNewOpptyTeamMemberList, map<Id, sObject> mapOldOppty) {
        if(triggerNewOpptyTeamMemberList !=null) {
            for (OpportunityTeamMember otmRecord : triggerNewOpptyTeamMemberList ){       
                newOpptyTeamMemberList.add(otmRecord ); // list of all opportunities 
                if ( opptyTMTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE){
                  /*  OpportunityTeamMember oldOpptM = (OpportunityTeamMember) mapOldOppty.get(otmRecord.Id);
                    If(otmRecord.UserId != oldOpptM.UserId && otmRecord.UserId !=null){
                        oppTMemeberList.add(otmRecord);
                        teamMemberOldMap.put(otmRecord.Id, oldOpptM);
                    }*/
                }
            } 
        }else{
            for(OpportunityTeamMember recToDelete: (List<OpportunityTeamMember>) mapOldOppty.values()) {
                if(opptyTMTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE) {
                    setOPTMIds.add(recToDelete.UserId); 
                }
            }
        }    
    }
    
    public void getRelatedRecords( list<Opportunity> newOpptyTeamMemberList ) {
    
    }
}