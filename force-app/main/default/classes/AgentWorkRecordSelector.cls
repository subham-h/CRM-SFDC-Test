/*
* Author   : Meghna Singh
* Purpose  : Centralize the record selection process for AgentWork object.
*          Defines the methods which iterate and segregate the AgentWork records for further use.
* 
* Revision Ref Number  Date        Owner                   Description
* 1.0      SC-8380   22-Aug-2023 Meghna@Maersk              Manual vs Auto Assignment flag
* -------- ----------  ----------- -------------------     -----------

*/
public class AgentWorkRecordSelector implements RecordSelector {
    
    	public set<Id> setCaseId = new set<Id>();
        public map<Id, Case> mapRelatedCases = new map<Id, Case>();

		private TriggerHandler AgentWorkTriggerHandler;
    
    private TriggerHandler awTriggerHandler;
        public AgentWorkRecordSelector(list<AgentWork> lstAgentWork, map<Id, AgentWork> mapOldAgentWork, TriggerHandler AgentWorkTriggerHandler) {
         this.AgentWorkTriggerHandler = AgentWorkTriggerHandler;
        this.selectRecords(lstAgentWork, mapOldAgentWork);
            

        }

    public void selectRecords(list<AgentWork> lstnewAgentWork, map<Id, sObject> mapOldAgentWork) {

           for(AgentWork aw : lstnewAgentWork){
                if(aw.WorkItemID!=null){
                    setCaseId.add(aw.WorkItemID);
                }
           }
        
            if(!setCaseId.isEmpty() ){
                this.getRelatedRecords(lstnewAgentWork);
                }
        
    }
    
        public void getRelatedRecords(list<AgentWork> listAgentWork) {
        getRelatedCases();        
    }
    public void getRelatedCases() {

        if(!setCaseId.isEmpty()) {
            mapRelatedCases = new map<Id, Case>([select Id,Auto_Assignment_Indicator__c  from Case where Id in :setCaseId and (Case_Channel__c='E-Mail' OR Case_Channel__c='Portal' OR Case_Channel__c='Website')]);
        }
    }

}