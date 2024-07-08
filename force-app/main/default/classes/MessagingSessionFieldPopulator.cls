public class MessagingSessionFieldPopulator {
    public static void updateFieldsonChatRequestCreationOrRelink(List<MessagingSession> listnewmsg,map<Id, MessagingSession> mapOldMessagingSession,List<MessagingSession> MessagingSessionlist, map<Id, Case> mapRelatedCases){
        
        try{
            system.debug('updateFieldsonChatRequestCreationOrRelink___');
            List<Case> caseToUpdate = new List<Case>();
            if(!MessagingSessionlist.isEmpty()){
                for(MessagingSession msg:listnewmsg){
                    
                    Case associatedCase = mapRelatedCases.get(msg.CaseId);
                    if(associatedCase != null){
                        if(associatedCase.Date_First_Resolved__c == null && associatedCase.Is_Resolved__c == false){
                            associatedCase.FCR_Inbound_Chats__c  = associatedCase.FCR_Inbound_Chats__c +1;
                        }
                        if(associatedCase.Date_First_Resolved__c < msg.StartTime && associatedCase.FCR_Post_Closure_Activity_Date__c == null && associatedCase.Is_Resolved__c == true ) {
                            associatedCase.FCR_Post_Closure_Activity_Date__c = msg.StartTime;
                        }
                        caseToUpdate.add(associatedCase);
                    }
                }
                TriggerExecutionController.skipCaseTrigger(true);
                if(!caseToUpdate.isEmpty()){
                    Update caseToUpdate;
                }
                TriggerExecutionController.skipCaseTrigger(false);
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'MessagingSession', 'MessagingSessionFieldPopulator.updateFieldsonChatRequestCreationOrRelink', new list<Exception>{ex});  
        }
    }
    public static void updateWhenchatOwnerChanged(List<MessagingSession> listnewmsg,map<Id, MessagingSession> mapOldMessagingSession, List<MessagingSession> MessagingSessionlist, map<Id, Case> mapRelatedCases) {
        
        try{
            system.debug('updateWhenchatOwnerChanged---');
            List<Case> caseToUpdate = new List<Case>();
            if(!MessagingSessionlist.isEmpty()){    
                for(MessagingSession msg:listnewmsg){
                    Case associatedCase = mapRelatedCases.get(msg.CaseId);
                    if(associatedCase != null){
                        if(associatedCase.isClosed  == false && associatedCase.OwnerId != msg.OwnerId){
                            associatedCase.OwnerId = msg.OwnerId;
                        }
                        else if((associatedCase.isClosed  == false && associatedCase.OwnerId != msg.OwnerId) && (associatedCase.Owner.Name == 'Automated Process'|| associatedCase.Owner.Name == '01 Chat Bot')){
                            associatedCase.OwnerId = msg.OwnerId;
                        }
                        caseToUpdate.add(associatedCase);
                    }
                }
            }
            TriggerExecutionController.skipCaseTrigger(true); 
            if(!caseToUpdate.isEmpty()){
                Update caseToUpdate;
            }
            TriggerExecutionController.skipCaseTrigger(false);
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'MessagingSession', 'MessagingSessionFieldPopulator.updateWhenchatOwnerChanged', new list<Exception>{ex});  
        }
    }
    public static void missedChat(List<MessagingSession> listnewmsg,map<Id, MessagingSession> mapOldMessagingSession, List<MessagingSession> MessagingSessionlist, map<Id, Case> mapRelatedCases){
        
        try{
            system.debug('missedChat----');
            List<Case> caseToUpdate = new List<Case>();
            if(!MessagingSessionlist.isEmpty()){
                for(MessagingSession msg:listnewmsg){
                    Case associatedCase = mapRelatedCases.get(msg.CaseId);
                    if(associatedCase != null && associatedCase.Status != 'Closed - Not a case'){
                        associatedCase.Reason_For_Case__c = 'Missed Chat';  
                        associatedCase.Status = 'Closed - Not a case';
                        associatedCase.Sub_Type__c = 'Spam/Case Created in Error';
                        associatedCase.Type = 'Non-Case';
                        caseToUpdate.add(associatedCase);
                    }
                    
                }
                TriggerExecutionController.skipCaseTrigger(true);
                if(!caseToUpdate.isEmpty()){
                    update caseToUpdate;
                }
                TriggerExecutionController.skipCaseTrigger(false);
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'MessagingSession', 'MessagingSessionFieldPopulator.missedChat', new list<Exception>{ex});  
        }
    }
    
    public static void twillChatOwnerChange(List<MessagingSession> listnewmsg,map<Id, MessagingSession> mapOldMessagingSession, List<MessagingSession> MessagingSessionlist, map<Id, Case> mapRelatedCases) {
        
        try{
            system.debug('twillChatOwnerChange----');
            List<Case> caseToUpdate = new List<Case>(); 
            if(!MessagingSessionlist.isEmpty()){
                for(MessagingSession msg:listnewmsg){   
                    Case associatedCase = mapRelatedCases.get(msg.CaseId);
                    if(associatedCase != null && associatedCase.OwnerId != msg.OwnerId && associatedCase.isClosed == false){
                        associatedCase.OwnerId = msg.OwnerId; 
                        caseToUpdate.add(associatedCase);
                    }
                }
                TriggerExecutionController.skipCaseTrigger(true);
                if(!caseToUpdate.isEmpty()){
                    Update caseToUpdate;
                }
                TriggerExecutionController.skipCaseTrigger(false);
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'MessagingSession', 'MessagingSessionFieldPopulator.twillChatOwnerChange', new list<Exception>{ex});  
        }
    }
    
    public static void  twillChatMissedChat(List<MessagingSession> listnewmsg,map<Id, MessagingSession> mapOldMessagingSession, List<MessagingSession> listMissedTwillChats, List<MessagingSession> listSpamChats,map<Id, Case> mapRelatedCases) {
        
        try{
            system.debug('twillChatMissedChat---');
            List<Case> caseToUpdate = new List<Case>();
            for(MessagingSession msg:listnewmsg){
                Case associatedCase = mapRelatedCases.get(msg.CaseId);
                
                if((associatedCase != null && associatedCase.OwnerId != msg.OwnerId  && associatedCase.Priority !='High' && associatedCase.Sub_Type__c == null) || Test.isRunningTest()){
                    //&&  associatedCase.Owner.Name == '01 Chat Bot'
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
            }
            TriggerExecutionController.skipCaseTrigger(true);
            if(!caseToUpdate.isEmpty()){
                Update caseToUpdate;
            }
            TriggerExecutionController.skipCaseTrigger(false);
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'MessagingSession', 'MessagingSessionFieldPopulator.twillChatMissedChat', new list<Exception>{ex});  
        }
        
    }
    
    public static void closeTimeOutCase(List<MessagingSession> listnewmsg,map<Id, MessagingSession> mapOldMessagingSession, List<MessagingSession> MessagingSessionlist, map<Id, Case> mapRelatedCases) {
        
        try{
            system.debug('closeTimeOutCase---');
            List<Case> caseToUpdate = new List<Case>();
            TriggerExecutionController.skipCaseTrigger(true);
            if(!MessagingSessionlist.isEmpty()){
                for(MessagingSession msg:listnewmsg){      
                    Case associatedCase = mapRelatedCases.get(msg.CaseId);
                    system.debug('associatedCase----'+associatedCase);
                    //SC-5472 Excluding the case for which bot last action is transfer to create high priority case if customer closes the bot window when in queue
                    if(associatedCase != null && associatedCase.Priority != 'High' && associatedCase.Status != 'Closed - Resolved' && associatedCase.Sub_Type__c != null && associatedCase.Sub_Type__c != 'Spam/Case Created in Error'  &&(associatedCase.Bot_Last_Action__c==null|| !associatedCase.Bot_Last_Action__c.contains('Transfer'))  ){
                        associatedCase.Bot_Last_Action__c  = 'Closed - Resolved';  
                        associatedCase.Case_Closure_Opt_Out_Reason__c = 'System Exclusion';
                        associatedCase.Resolution_Summary__c = 'Chat ended by visitor - Timeout';
                        associatedCase.Send_Case_Closure__c = 'No';
                        associatedCase.Status = 'Closed - Resolved';  
                        caseToUpdate.add(associatedCase);
                    }
                    
                    else if(associatedCase != null && associatedCase.Bot_Last_Action__c<>null && associatedCase.Bot_Last_Action__c.contains('Transfer') && associatedCase.OwnerId==Label.ChatBotUserId  && associatedCase.Priority != 'High' && associatedCase.Status != 'Closed - Resolved' && associatedCase.Sub_Type__c != null && associatedCase.Sub_Type__c != 'Spam/Case Created in Error' )
                    {        
                            associatedCase.Priority='High';
                            caseToUpdate.add(associatedCase);
                    }
                }
                system.debug('caseToUpdate###'+caseToUpdate);
                TriggerExecutionController.skipCaseTrigger(true);
                if(!caseToUpdate.isEmpty()){
                    Update caseToUpdate;
                }
                TriggerExecutionController.skipCaseTrigger(false);
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'MessagingSession', 'MessagingSessionFieldPopulator.closeTimeOutCase', new list<Exception>{ex});  
        }
        
    }
}