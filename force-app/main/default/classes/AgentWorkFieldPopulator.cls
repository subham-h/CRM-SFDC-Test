/*
* Author   : Meghna
* Purpose  : Utility class to hold simple and reusable functionalities for auto populating AgentWork fields. 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-8380   09-August-2023  Meghna@Maersk      	Manual vs Auto Assignment flag
* 2.0      SC-9793	 21-Feb-2024     Divya@Maersk      	    Allow Users to view Case Assignment History and Omni Skill Type

*/
public class AgentWorkFieldPopulator {
    
    public static void updateCaseAssignmentIndicator(List<AgentWork> lstaw,map<Id, Case> mapRelatedCases){
        TriggerExecutionController.skipCaseTrigger(true);   
        try{
            List<CaseHistoryWrapper> csHistoryWrapList = new List<CaseHistoryWrapper>(); 
            List<Case> caseToUpdate = new List<Case>();
            List<Case> caseToUpdate2 = new List<Case>();
            List<ID> lstCaseID= new List<ID>();
            List<Case> lstCase = new List<Case>();
            String currentUserId = UserInfo.getUserId();
            
            if(!lstaw.isEmpty()){
                //For capturing the field change value on case history first the value is emptied and then added with auto-assigned
                for(AgentWork aw:lstaw)
                {
                    Case associatedCase = mapRelatedCases.get(aw.WorkItemId);
                    if(aw.status=='Assigned' && associatedCase!=null && associatedCase.Auto_Assignment_Indicator__c=='Auto Assigned'){                        
                        associatedCase.Auto_Assignment_Indicator__c='';
                        caseToUpdate.add(associatedCase);
                        //SC-9793
                        csHistoryWrapList.add(new CaseHistoryWrapper(associatedCase.Id, JSON.serialize(System.now()).remove('"').left(19), 'Auto Assignment Indicator', '', 'Auto Assigned', currentUserId));
                    }
                }
            }
            if(!caseToUpdate.isEmpty()){
                database.Update(caseToUpdate,false);
            }
            if(!lstaw.isEmpty()){
                for(AgentWork aw:lstaw){
                    Case associatedCase = mapRelatedCases.get(aw.WorkItemId);
                    if( associatedCase!=null && aw.status=='Assigned'){
                        associatedCase.Auto_Assignment_Indicator__c='Auto Assigned';
                        caseToUpdate2.add(associatedCase);
                        //SC-9793
                        csHistoryWrapList.add(new CaseHistoryWrapper(associatedCase.Id, JSON.serialize(System.now()).remove('"').left(19), 'Auto Assignment Indicator', 'Auto Assigned', 'Assigned', currentUserId));                        
                    }
                }
            }
            if(!caseToUpdate2.isEmpty()){
                database.Update(caseToUpdate2,false);
            }
            //SC-9793
            if(!csHistoryWrapList.isEmpty()){
                CaseFieldPopulator.createCustomCaseHistory(JSON.serialize(csHistoryWrapList));
            }
            TriggerExecutionController.skipCaseTrigger(false);
        }
        catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'AgentWork', 'AgentWorkFieldPopulator.updateCaseAssignmentIndicator', new list<Exception>{ex});  
        } 
    }  
}