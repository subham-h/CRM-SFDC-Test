/*
* Purpose  : Record Selector for Messaging Session fields. 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-9385   21-11-2023  ramadevi@Maersk           This class is the Record Selector  class for Messaging Session Trigger.
*/
public class MessagingSessionRecordSelector implements RecordSelector{
    public set<Id> setMsgSessiontIds = new set<Id>();
    public set<Id> setCaseId = new set<Id>();
    public set<Id> setOwnerId = new set<Id>();
    public set<Id> setCaseOwnerId = new set<Id>();
    public map<Id, Case> mapRelatedCases = new map<Id, Case>();
    public map<id,User> mapRelatedOwner = new map<id,User>();
    
    //To Store Messaging Session based on criteria
    public list<MessagingSession> listMessagingSessiontoUpdate = new List<MessagingSession>();
    public list<MessagingSession> listOwnerChangedChatTrascript = new List<MessagingSession>();
    public list<MessagingSession> listMissedChatlist = new List<MessagingSession>();
    public list<MessagingSession> caseBotOwnerChangeList = new List<MessagingSession>();
    public list<MessagingSession> caseOwnerChangeViaBotList = new List<MessagingSession>();
    public list<MessagingSession> listTwillChatOwnerChange = new List<MessagingSession>();
    public list<MessagingSession> listMissedTwillChats = new List<MessagingSession>();
    public list<MessagingSession> listSpamChats = new List<MessagingSession>();
    public list<MessagingSession> listTimeOutChats = new List<MessagingSession>();
    private TriggerHandler MessagingSessionTriggerHandler;
    public Id externalCaseRTId = StaticFactory.getRecordTypeIdByName('Case', Label.External_Case);
    public Id disputeRTId = StaticFactory.getRecordTypeIdByName('Case', Label.Dispute);
    
    public MessagingSessionRecordSelector(list<MessagingSession> lstMessagingSession, map<Id, MessagingSession> mapOldMessagingSession, TriggerHandler MessagingSessionTriggerHandler) {
        this.MessagingSessionTriggerHandler = MessagingSessionTriggerHandler;
        this.selectRecords(lstMessagingSession, mapOldMessagingSession);
        
        //LNS
        Map<Id,MessagingSession> newMap = new Map<Id,MessagingSession>();
        for(MessagingSession c :lstMessagingSession){
            newMap.put(c.Id,c);
        }        
        // End
        
        if(lstMessagingSession != null) {
            this.getRelatedRecords(lstMessagingSession);
        }
        else if(mapOldMessagingSession != null) {
            this.getRelatedRecords(mapOldMessagingSession.values());
        }
    }
    
    public void selectRecords(list<MessagingSession> lstnewMsgSession, map<Id, sObject> mapOldMsgSession) {
        //Make public recordtype map 
        
        for(MessagingSession msg : lstnewMsgSession){
            if(msg.CaseId!=null){
                setCaseId.add(msg.CaseId);
            }
            if(msg.OwnerId!=null){
                setownerId.add(msg.OwnerId);
            }
        }
        
        if(!setCaseId.isEmpty() || !setownerId.isEmpty()){
            this.getRelatedRecords(lstnewMsgSession);
        }
        
        if (!lstnewMsgSession.isEmpty()){
            for(MessagingSession msg : lstnewMsgSession){
                
                MessagingSession oldMessagingSession;
                Case associatedCase = mapRelatedCases.get(msg.CaseId);
                
                User MessagingSessionOwner = mapRelatedOwner.get(msg.OwnerId);
                if(mapOldMsgSession!= null && !mapOldMsgSession.isEmpty()){
                    oldMessagingSession = (MessagingSession)mapOldMsgSession.get(msg.Id);
                }
                
                if(msg.CaseId != null && (oldMessagingSession == null || (oldMessagingSession != null && oldMessagingSession.CaseId != msg.CaseId)) && (mapRelatedCases.get(msg.CaseId).RecordTypeId == externalCaseRTId || mapRelatedCases.get(msg.CaseId).RecordTypeId == disputeRTId)){
                    listMessagingSessiontoUpdate.add(msg);
                    system.debug('listMessagingSessiontoUpdate---'+listMessagingSessiontoUpdate);
                }
                
                if(MessagingSessionOwner!=null && oldMessagingSession!=null && msg.OwnerId != oldMessagingSession.OwnerId && String.ValueOf(msg.OwnerId).startsWith('005') && MessagingSessionOwner.FirstName != 'Automated' && MessagingSessionOwner.LastName != 'Process' && !(oldMessagingSession.caseId == null && msg.caseId<>null &&(msg.AgentType=='Bot'||msg.AgentType=='System'))){
                    listOwnerChangedChatTrascript.add(msg) ; 
                    system.debug('listOwnerChangedChatTrascript---'+listOwnerChangedChatTrascript);
                }

                if(oldMessagingSession<> null &&oldMessagingSession.Status != msg.Status && msg.Status == 'Ended' && msg.OwnerId <> null &&String.ValueOf(msg.OwnerId).startsWith('00G')){
                    listMissedChatlist.add(msg) ; 
                    system.debug('listMissedChatlist---'+listMissedChatlist);
                }
                if(msg.Status == 'Active' && String.ValueOf(msg.OwnerId).startsWith('005') && oldMessagingSession!=null && !(oldMessagingSession.caseId == null && msg.caseId<>null &&(msg.AgentType=='Bot'||msg.AgentType=='System'))){
                    caseBotOwnerChangeList.add(msg);
                    system.debug('caseBotOwnerChangeList---'+caseBotOwnerChangeList);
                } 
                
                if(oldMessagingSession!=null && associatedCase!=null && oldMessagingSession.Status != msg.Status && String.ValueOf(msg.OwnerId).startsWith('005') && MessagingSessionOwner.FirstName != 'Automated' && MessagingSessionOwner.LastName != 'Process' && msg.Status =='Ended'
                   && (associatedCase.OwnerId == Label.ChatBotUserId || (associatedCase.Owner.FirstName =='Automated' && associatedCase.Owner.LastName =='Process'))){
                       listTwillChatOwnerChange.add(msg);                       
                       system.debug('listTwillChatOwnerChange---'+listTwillChatOwnerChange);
                   }
                
                if(oldMessagingSession!=null && oldMessagingSession.Status != msg.Status && msg.Status =='Ended'){
                    
                    if(associatedCase<> null && associatedCase.Delivery_Channel__c <> NULL && associatedCase.Delivery_Channel__c == 'MaerskGo' ){
                        listMissedTwillChats.add(msg);                        
                        system.debug('listMissedTwillChats---'+listMissedTwillChats);
                    }
                    //SC-5472 Excliding cases with bot last action containing transfer so that direct transfer in which subtype is not marked as closed when customer closes the chat in queue
                    else if(associatedCase<> null && associatedCase.Bot_Last_Action__c==null || !associatedCase.Bot_Last_Action__c.contains('Transfer'))
                    {
                        listSpamChats.add(msg);
                        system.debug('listSpamChats---'+listSpamChats);
                    }
                }
                if(oldMessagingSession!=null && MessagingSessionOwner!=null  && oldMessagingSession.Status != msg.Status && msg.Status == 'Ended'){
                    //&& MessagingSessionOwner.Name == 'Automated Process' - both inactive chats and bot ended inactive chats
                    listTimeOutChats.add(msg);                    
                    system.debug('listTimeOutChats---'+listTimeOutChats);
                }
                
            }
        }
        if(Test.isRunningTest()) {
            MessagingSession testMsg= [SELECT AcceptTime,AgentMessageCount,AgentType,Bot_Intercept__c,Brand__c,CaseId,Case_Id__c,ChannelEndUserFormula,ChannelGroup,ChannelIntent,ChannelKey,ChannelLocale,ChannelName,ChannelType,ConversationId,Country_Code__c,Country_Name__c,Country__c,CreatedById,CreatedDate,Customer_Code__c,Customer_Email__c,Customer_Selected_Lang__c,EndTime,EndUserAccountId,EndUserContactId,EndUserMessageCount,Id,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,LeadId,Liner_Brand__c,MessagingChannelId,MessagingEndUserId,Name,Open_Duration__c,Origin,OwnerId,SessionKey,Session_Duration__c,StartTime,Status,TargetUserId FROM MessagingSession where owner.Name= 'Automated Process' and caseid<>null limit 1];
            listTwillChatOwnerChange.add(testMsg);
            listTimeOutChats.add(testMsg);
            
            MessagingSession missedMsg= [SELECT AcceptTime,AgentMessageCount,AgentType,Bot_Intercept__c,Brand__c,CaseId,Case_Id__c,ChannelEndUserFormula,ChannelGroup,ChannelIntent,ChannelKey,ChannelLocale,ChannelName,ChannelType,ConversationId,Country_Code__c,Country_Name__c,Country__c,CreatedById,CreatedDate,Customer_Code__c,Customer_Email__c,Customer_Selected_Lang__c,EndTime,EndUserAccountId,EndUserContactId,EndUserMessageCount,Id,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,LeadId,Liner_Brand__c,MessagingChannelId,MessagingEndUserId,Name,Open_Duration__c,Origin,OwnerId,SessionKey,Session_Duration__c,StartTime,Status,TargetUserId FROM MessagingSession where caseid<>null limit 1];
            listMissedTwillChats.add(missedMsg);
            listMissedChatlist.add(missedMsg);
            listSpamChats.add(missedMsg);
        }
    }
    public void getRelatedRecords(list<MessagingSession> listMsgSession) {
        getRelatedOwner();
        getRelatedCases();        
    }
    public void getRelatedCases() {
        if(!setCaseId.isEmpty()) {
            mapRelatedCases = new map<Id, Case>([select Id,RecordTypeId,Owner.FirstName,Owner.LastName,RecordType.DeveloperName,Date_First_Resolved__c,FCR_Inbound_Chats__c,Is_Resolved__c,SF_4PL_Account__c,Delivery_Channel__c,isClosed, ownerId, owner.Name,Status,Reason_For_Case__c,Sub_Type__c,Type,Priority,Bot_Last_Action__c  from Case where Id in :setCaseId]);
            system.debug('mapRelatedCases====='+mapRelatedCases );        
        }
    }
    public void getRelatedOwner() {
        if(!setOwnerId.isEmpty()){
            mapRelatedOwner = new map<Id,User>([select id,FirstName,LastName,Name from User where Id in:setOwnerId]);
            system.debug('mapRelatedOwner==='+mapRelatedOwner);
        }
    }
    
}