/*
* Author   : Vaishali Gayatri
* Purpose  : Centralize the record selection process for LiveChatTranscript object.
*          Defines the methods which iterate and segregate the Chat Transcript records for further use.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------

*/
public class LiveChatTranscriptRecordSelector implements RecordSelector{
    public set<Id> setChatTranscriptIds = new set<Id>();
    public set<Id> setCaseId = new set<Id>();
    public set<Id> setOwnerId = new set<Id>();
    public set<Id> setCaseOwnerId = new set<Id>();
    public map<Id, Case> mapRelatedCases = new map<Id, Case>();
    public map<id,User> mapRelatedOwner = new map<id,User>();
    
    //To Store Live Chat Transcript based on criteria
    public list<LiveChatTranscript> listChatTranscripttoUpdate = new List<LiveChatTranscript>();
    public list<LiveChatTranscript> listOwnerChangedChatTrascript = new List<LiveChatTranscript>();
    public list<LiveChatTranscript> listMissedChatlist = new List<LiveChatTranscript>();
    public list<LiveChatTranscript> caseBotOwnerChangeList = new List<LiveChatTranscript>();
    public list<LiveChatTranscript> caseOwnerChangeViaBotList = new List<LiveChatTranscript>();
    public list<LiveChatTranscript> listTwillChatOwnerChange = new List<LiveChatTranscript>();
    public list<LiveChatTranscript> listMissedTwillChats = new List<LiveChatTranscript>();
    public list<LiveChatTranscript> listSpamChats = new List<LiveChatTranscript>();
    public list<LiveChatTranscript> listTimeOutChats = new List<LiveChatTranscript>();
    private TriggerHandler ChatTranscriptTriggerHandler;
    public Id externalCaseRTId = StaticFactory.getRecordTypeIdByName('Case', Label.External_Case);
    public Id disputeRTId = StaticFactory.getRecordTypeIdByName('Case', Label.Dispute);
    
    public liveChatTranscriptRecordSelector(list<LiveChatTranscript> lstLiveChatTranscript, map<Id, LiveChatTranscript> mapOldLiveChatTranscript, TriggerHandler ChatTranscriptTriggerHandler) {
        this.ChatTranscriptTriggerHandler = ChatTranscriptTriggerHandler;
        this.selectRecords(lstLiveChatTranscript, mapOldLiveChatTranscript);
        
        //LNS
        Map<Id,LiveChatTranscript> newMap = new Map<Id,LiveChatTranscript>();
        for(LiveChatTranscript c :lstLiveChatTranscript){
            newMap.put(c.Id,c);
        }
        
        // End
        
        if(lstLiveChatTranscript != null) {
            this.getRelatedRecords(lstLiveChatTranscript);
        }
        else if(mapOldLiveChatTranscript != null) {
            this.getRelatedRecords(mapOldLiveChatTranscript.values());
        }
    }
    
    public void selectRecords(list<LiveChatTranscript> lstnewChatTranscripts, map<Id, sObject> mapOldChatTranscripts) {
        //Make public recordtype map 
        
        for(LiveChatTranscript lct : lstnewChatTranscripts){
            if(lct.CaseId!=null){
                setCaseId.add(lct.CaseId);
            }
            if(lct.OwnerId!=null){
                setownerId.add(lct.OwnerId);
            }
        }
        
        if(!setCaseId.isEmpty() || !setownerId.isEmpty()){
            this.getRelatedRecords(lstnewChatTranscripts);
        }
        
        if (!lstnewChatTranscripts.isEmpty()){
            for(LiveChatTranscript lct : lstnewChatTranscripts){
                
                LiveChatTranscript oldchatTranscript;
                Case associatedCase = mapRelatedCases.get(lct.CaseId);
                
                User chatTranscriptOwner = mapRelatedOwner.get(lct.OwnerId);
                if(mapOldChatTranscripts!= null && !mapOldChatTranscripts.isEmpty()){
                    oldchatTranscript = (LiveChatTranscript)mapOldChatTranscripts.get(lct.Id);
                }
                
                if(lct.CaseId != null && (oldchatTranscript == null || (oldchatTranscript != null && oldchatTranscript.CaseId != lct.CaseId)) && (mapRelatedCases.get(lct.CaseId).RecordTypeId == externalCaseRTId || mapRelatedCases.get(lct.CaseId).RecordTypeId == disputeRTId)){
                    listChatTranscripttoUpdate.add(lct);
                }
                
                if(chatTranscriptOwner!=null && oldchatTranscript!=null && lct.OwnerId != oldchatTranscript.OwnerId && String.ValueOf(lct.OwnerId).startsWith('005') && chatTranscriptOwner.FirstName != 'Automated' && chatTranscriptOwner.LastName != 'Process' ){
                    listOwnerChangedChatTrascript.add(lct) ; 
                }
                if(lct.Status == 'Missed'){
                    listMissedChatlist.add(lct) ; 
                }
                if(lct.Status == 'InProgress'){
                    caseBotOwnerChangeList.add(lct);
                } 
                
                if(oldchatTranscript!=null && associatedCase!=null && oldchatTranscript.Status != lct.Status && String.ValueOf(lct.OwnerId).startsWith('005') && chatTranscriptOwner.FirstName != 'Automated' && chatTranscriptOwner.LastName != 'Process' && lct.Status =='Completed'
                   && (associatedCase.OwnerId == Label.ChatBotUserId || (associatedCase.Owner.FirstName =='Automated' && associatedCase.Owner.LastName =='Process'))){
                       
                       listTwillChatOwnerChange.add(lct);
                   }
                
                if(oldchatTranscript!=null && oldchatTranscript.Status != lct.Status && lct.Status =='Completed'){
                    if(associatedCase.Delivery_Channel__c == 'MaerskGo' ){
                        listMissedTwillChats.add(lct);
                    }
                    //SC-5472 Excliding cases with bot last action containing transfer so that direct transfer in which subtype is not marked as closed when customer closes the chat in queue
                    else if(associatedCase.Bot_Last_Action__c==null || !associatedCase.Bot_Last_Action__c.contains('Transfer'))
                    {
                        listSpamChats.add(lct);
                    }
                }
                if(oldchatTranscript!=null && chatTranscriptOwner!=null && chatTranscriptOwner.Name == 'Automated Process' && oldchatTranscript.Status != lct.Status && lct.Status == 'Completed'){
                    listTimeOutChats.add(lct);
                }
                
            }
        }
    }
    public void getRelatedRecords(list<LiveChatTranscript> listChatTranscripts) {
        getRelatedOwner();
        getRelatedCases();        
    }
    public void getRelatedCases() {
        if(!setCaseId.isEmpty()) {
            mapRelatedCases = new map<Id, Case>([select Id,RecordTypeId,Owner.FirstName,Owner.LastName,RecordType.DeveloperName,Date_First_Resolved__c,FCR_Inbound_Chats__c,Is_Resolved__c,SF_4PL_Account__c,Delivery_Channel__c,isClosed, ownerId, owner.Name,Status,Reason_For_Case__c,Sub_Type__c,Type,Priority,Bot_Last_Action__c  from Case where Id in :setCaseId]);
        }
    }
    public void getRelatedOwner() {
        if(!setOwnerId.isEmpty()){
            mapRelatedOwner = new map<Id,User>([select id,FirstName,LastName,Name from User where Id in:setOwnerId]);
        }
    }
    
}