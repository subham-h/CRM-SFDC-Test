/*
* Author   : Vaishali Gayatri
* Purpose  : Utility class to hold simple and reusable functionalities for auto populating Chat fields. 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-5352   12-July-2022  Vaishali@Maersk       Move LiveChatTranscript Process Builder to Trigger
* 2.0      SC-5472   28-July-2022  Meghna@Maersk      	 Queueing Option for Chat Customers
*/
public class LiveChatTranscriptFieldPopulator {
    public static void updateFieldsonChatRequestCreationOrRelink(List<LiveChatTranscript> listnewlct,map<Id, LiveChatTranscript> mapOldLiveChatTranscript,List<LiveChatTranscript> LiveChatTranscriptlist, map<Id, Case> mapRelatedCases){
        TriggerExecutionController.skipCaseTrigger(true);
        try{
            List<Case> caseToUpdate = new List<Case>();
            if(!LiveChatTranscriptlist.isEmpty()){
                for(LiveChatTranscript lct:listnewlct){
                    
                    Case associatedCase = mapRelatedCases.get(lct.CaseId);
                    if(associatedCase != null){
                        if(associatedCase.Date_First_Resolved__c == null && associatedCase.Is_Resolved__c == false){
                            associatedCase.FCR_Inbound_Chats__c  = associatedCase.FCR_Inbound_Chats__c +1;
                        }
                        if(associatedCase.Date_First_Resolved__c < lct.StartTime && associatedCase.FCR_Post_Closure_Activity_Date__c == null && associatedCase.Is_Resolved__c == true ) {
                            associatedCase.FCR_Post_Closure_Activity_Date__c = lct.StartTime;
                        }
                        caseToUpdate.add(associatedCase);
                    }
                }
                if(!caseToUpdate.isEmpty()){
                    Update caseToUpdate;
                }
                TriggerExecutionController.skipCaseTrigger(false);
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'LiveChatTranscript', 'LiveChatTranscriptFieldPopulator.updateFieldsonChatRequestCreationOrRelink', new list<Exception>{ex});  
        }
    }
    public static void updateWhenchatOwnerChanged(List<LiveChatTranscript> listnewlct,map<Id, LiveChatTranscript> mapOldLiveChatTranscript, List<LiveChatTranscript> LiveChatTranscriptlist, map<Id, Case> mapRelatedCases) {
        TriggerExecutionController.skipCaseTrigger(true);
        try{
             
            List<Case> caseToUpdate = new List<Case>();
            if(!LiveChatTranscriptlist.isEmpty()){    
                for(LiveChatTranscript lct:listnewlct){
                    Case associatedCase = mapRelatedCases.get(lct.CaseId);
                    if(associatedCase != null){
                        if(associatedCase.isClosed  == false && associatedCase.OwnerId != lct.OwnerId){
                            associatedCase.OwnerId = lct.OwnerId;
                        }
                        else if((associatedCase.isClosed  == false && associatedCase.OwnerId != lct.OwnerId) && (associatedCase.Owner.Name == 'Automated Process'|| associatedCase.Owner.Name == '01 Chat Bot')){
                            associatedCase.OwnerId = lct.OwnerId;
                        }
                        caseToUpdate.add(associatedCase);
                    }
                }
            }
             
            if(!caseToUpdate.isEmpty()){
                Update caseToUpdate;
            }
            TriggerExecutionController.skipCaseTrigger(false);
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'LiveChatTranscript', 'LiveChatTranscriptFieldPopulator.updateWhenchatOwnerChanged', new list<Exception>{ex});  
        }
    }
    public static void missedChat(List<LiveChatTranscript> listnewlct,map<Id, LiveChatTranscript> mapOldLiveChatTranscript, List<LiveChatTranscript> LiveChatTranscriptlist, map<Id, Case> mapRelatedCases){
        TriggerExecutionController.skipCaseTrigger(true);
        try{
            List<Case> caseToUpdate = new List<Case>();
            if(!LiveChatTranscriptlist.isEmpty()){
                for(LiveChatTranscript lct:listnewlct){
                    Case associatedCase = mapRelatedCases.get(lct.CaseId);
                    if(associatedCase != null && associatedCase.Status != 'Closed - Not a case'){
                        associatedCase.Reason_For_Case__c = 'Missed Chat';  
                        associatedCase.Status = 'Closed - Not a case';
                        associatedCase.Sub_Type__c = 'Spam/Case Created in Error';
                        associatedCase.Type = 'Non-Case';
                        caseToUpdate.add(associatedCase);
                    }
                    
                }
                if(!caseToUpdate.isEmpty()){
                    update caseToUpdate;
                }
                TriggerExecutionController.skipCaseTrigger(false);
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'LiveChatTranscript', 'LiveChatTranscriptFieldPopulator.missedChat', new list<Exception>{ex});  
        }
    }
    
    public static void twillChatOwnerChange(List<LiveChatTranscript> listnewlct,map<Id, LiveChatTranscript> mapOldLiveChatTranscript, List<LiveChatTranscript> LiveChatTranscriptlist, map<Id, Case> mapRelatedCases) {
        TriggerExecutionController.skipCaseTrigger(true);
        try{
            List<Case> caseToUpdate = new List<Case>(); 
            if(!LiveChatTranscriptlist.isEmpty()){
                for(LiveChatTranscript lct:listnewlct){   
                    Case associatedCase = mapRelatedCases.get(lct.CaseId);
                    if(associatedCase != null && associatedCase.OwnerId != lct.OwnerId && associatedCase.isClosed == false){
                        associatedCase.OwnerId = lct.OwnerId; 
                        caseToUpdate.add(associatedCase);
                    }
                }
                if(!caseToUpdate.isEmpty()){
                    Update caseToUpdate;
                }
                TriggerExecutionController.skipCaseTrigger(false);
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'LiveChatTranscript', 'LiveChatTranscriptFieldPopulator.twillChatOwnerChange', new list<Exception>{ex});  
        }
    }
    
    public static void  twillChatMissedChat(List<LiveChatTranscript> listnewlct,map<Id, LiveChatTranscript> mapOldLiveChatTranscript, List<LiveChatTranscript> listMissedTwillChats, List<LiveChatTranscript> listSpamChats,map<Id, Case> mapRelatedCases) {
        TriggerExecutionController.skipCaseTrigger(true);
        try{
            List<Case> caseToUpdate = new List<Case>();
            for(LiveChatTranscript lct:listnewlct){
                Case associatedCase = mapRelatedCases.get(lct.CaseId);
                
                if(associatedCase != null && associatedCase.OwnerId != lct.OwnerId &&  associatedCase.Owner.Name == '01 Chat Bot' && associatedCase.Priority !='High' && associatedCase.Sub_Type__c == null){
                    if(!listMissedTwillChats.isEmpty()){
                        associatedCase.Reason_For_Case__c = 'Missed Chat';  
                        associatedCase.Status = 'Closed - Not a case';
                        associatedCase.Sub_Type__c = 'Spam/Case Created in Error';
                        associatedCase.Type = 'Non-Case';
                    }
                    if(!listSpamChats.isEmpty()){
                        associatedCase.Bot_Last_Action__c  = 'Closed - Not a case';  
                        associatedCase.Case_Closure_Opt_Out_Reason__c = 'System Exclusion';
                        associatedCase.Description = 'Spam case';
                        associatedCase.Reason_For_Case__c = 'Spam';
                        associatedCase.Send_Case_Closure__c = 'No';
                        associatedCase.Status = 'Closed - Not a case';
                        associatedCase.Sub_Type__c = 'Spam/Case Created in Error';
                        associatedCase.Type = 'Non-Case';
                    }
                    caseToUpdate.add(associatedCase);
                }
                
                TriggerExecutionController.skipCaseTrigger(false);
                
            }
            
            if(!caseToUpdate.isEmpty()){
                Update caseToUpdate;
            }
            TriggerExecutionController.skipCaseTrigger(false);
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'LiveChatTranscript', 'LiveChatTranscriptFieldPopulator.twillChatMissedChat', new list<Exception>{ex});  
        }
        
    }
    
    public static void closeTimeOutCase(List<LiveChatTranscript> listnewlct,map<Id, LiveChatTranscript> mapOldLiveChatTranscript, List<LiveChatTranscript> LiveChatTranscriptlist, map<Id, Case> mapRelatedCases) {
        TriggerExecutionController.skipCaseTrigger(true);
        try{
            List<Case> caseToUpdate = new List<Case>();
            TriggerExecutionController.skipCaseTrigger(true);
            if(!LiveChatTranscriptlist.isEmpty()){
                for(LiveChatTranscript lct:listnewlct){      
                    Case associatedCase = mapRelatedCases.get(lct.CaseId);
                    //SC-5472 Excluding the case for which bot last action is transfer to create high priority case if customer closes the bot window when in queue
                    if(associatedCase != null && associatedCase.Priority != 'High' && associatedCase.Status != 'Closed - Resolved' && associatedCase.Sub_Type__c != 'Spam/Case Created in Error' && associatedCase.Sub_Type__c != null &&(associatedCase.Bot_Last_Action__c==null|| !associatedCase.Bot_Last_Action__c.contains('Transfer'))  ){
                        associatedCase.Bot_Last_Action__c  = 'Closed - Resolved';  
                        associatedCase.Case_Closure_Opt_Out_Reason__c = 'System Exclusion';
                        associatedCase.Resolution_Summary__c = 'Chat ended by visitor - Timeout';
                        associatedCase.Send_Case_Closure__c = 'No';
                        associatedCase.Status = 'Closed - Resolved';  
                        caseToUpdate.add(associatedCase);
                    }
                    else if(associatedCase != null && !String.isBlank(associatedCase.Bot_Last_Action__c) && associatedCase.Bot_Last_Action__c.contains('Transfer') && associatedCase.OwnerId == Label.ChatBotUserId  && associatedCase.Priority != 'High' && associatedCase.Status != 'Closed - Resolved' && associatedCase.Sub_Type__c != 'Spam/Case Created in Error' ){        
                        associatedCase.Priority = 'High';
                        caseToUpdate.add(associatedCase);                        
                    }
                }
                if(!caseToUpdate.isEmpty()){
                    update caseToUpdate;
                }
                TriggerExecutionController.skipCaseTrigger(false);
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'LiveChatTranscript', 'LiveChatTranscriptFieldPopulator.closeTimeOutCase', new list<Exception>{ex});  
        }
    }
}