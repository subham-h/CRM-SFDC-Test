/*
* Author   : Ramadevi
* Purpose  : This class and method is called from bot, This method deletes the PSR created before transfering the chat to button skill
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-5478   23-01-2022    Ramadevi@maersk.com     This class and method is called from bot, DeleteExistingPSR method deletes the PSR created before transfering the chat to button skill
*/
public class deletePSRForSkillRouting{

    public class botInput
    {
        @InvocableVariable(required=true)
        public Id chatTranscriptId;
        @InvocableVariable(required=false)
        public String liveChatButtonId;
    }
    
    @InvocableMethod(label='DeletExistingPSRforReroute')    
    public static void DeleteExistingPSR(List<botInput> lstBotInput){
        try{
            if(lstBotInput[0].liveChatButtonId <> null){
                LiveChatTranscript lct = [SELECT Id,CaseId from LiveChatTranscript where id=:lstBotInput[0].chatTranscriptId];
                Case cse = new Case();
                cse.Id = lct.CaseId ;               
                cse.Omni_Skill_Type__c = 'Chat - General';            
                List<PendingServiceRouting > psrDelList= new List<PendingServiceRouting >();                                       
                psrDelList = ListPSRtoDelete(lstBotInput[0].chatTranscriptId);
                if(psrDelList.size()>0){
                    Delete psrDelList;
                }
                //Update the Case Omni Skill Type to General
                List<Case> cseList = new List<Case>{cse};
                TriggerExecutionController.skipCaseTrigger(true);
                system.debug('cseList ##'+cseList);
                list<Database.SaveResult> lstSaveResults = Database.update(cseList, false);
                TriggerExecutionController.skipCaseTrigger(false);
                ErrorLogger.writeErrors('SFDC', 'Case', 'CaseOmniSkillBasedRouting.defineCaseSkillMap', lstSaveResults, cseList);
            }
        } catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseOmniSkillBasedRouting.defineCaseSkillMap', new list<Exception>{ex});
        }
    }
    
    public static List<PendingServiceRouting> ListPSRtoDelete(Id chatTranscriptId){
        List<String> workStatuses = new List<String>{'DeclinedOnPushTimeout','Declined','Unavailable'}; 
        List<PendingServiceRouting > psrDelList= new List<PendingServiceRouting >(); 
        for(Agentwork work:[SELECT Name,PendingServiceRoutingId,PreferredUserId,RoutingModel,RoutingPriority,RoutingType,Status,UserId,WorkItemId FROM AgentWork WHERE WorkItemId =: chatTranscriptId]){                    
            if(workStatuses.contains(work.Status) && work.PendingServiceRoutingId <> NULL){
                PendingServiceRouting psr = new PendingServiceRouting();
                psr.id = work.PendingServiceRoutingId;
                psrDelList.add(psr);
            }
        }
        return psrDelList;
    }
}