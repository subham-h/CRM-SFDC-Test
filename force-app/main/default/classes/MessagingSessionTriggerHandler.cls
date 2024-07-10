/*
*   
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 
*/
public class MessagingSessionTriggerHandler extends TriggerHandler{
    public map<Id, MessagingSession> newMap;
    public map<Id, MessagingSession> oldMap;
    public MessagingSessionTriggerHandler() {
        this.newMap = (map<Id, MessagingSession>)Trigger.newMap;
        this.oldMap = (map<Id, MessagingSession>)Trigger.oldMap;
    }
    public MessagingSessionRecordSelector msgSessionRecordSelector;
    
    public override void getRecordSelector() {
        msgSessionRecordSelector = new MessagingSessionRecordSelector(Trigger.new, this.oldMap, this);
    }
    public override void onAfterInsert() {
        //Case Updation When Chat Request Created or Relinked
        if(!msgSessionRecordSelector.listMessagingSessionToUpdate.isEmpty()){
            MessagingSessionFieldPopulator.updateFieldsonChatRequestCreationOrRelink(Trigger.new,null,msgSessionRecordSelector.listMessagingSessionToUpdate,msgSessionRecordSelector.mapRelatedCases);
        }
        
        //Update Case when Chat Owner Changed
        if(!msgSessionRecordSelector.listOwnerChangedChatTrascript.isEmpty()){
            MessagingSessionFieldPopulator.updateWhenchatOwnerChanged(Trigger.new, null,msgSessionRecordSelector.caseBotOwnerChangeList,msgSessionRecordSelector.mapRelatedCases);
        }
        else if(!msgSessionRecordSelector.caseBotOwnerChangeList.isEmpty()){
            MessagingSessionFieldPopulator.updateWhenchatOwnerChanged(Trigger.new, null,msgSessionRecordSelector.caseBotOwnerChangeList,msgSessionRecordSelector.mapRelatedCases);
            
        }
        
        // Update case for Missed Chat
        if(!msgSessionRecordSelector.listMissedChatlist.isEmpty()){
            MessagingSessionFieldPopulator.missedChat(Trigger.new, null,msgSessionRecordSelector.listMissedChatlist,msgSessionRecordSelector.mapRelatedCases);
        }
        
        //Update Case When Twill Chat is Missed
        if(!msgSessionRecordSelector.listMissedTwillChats.isEmpty() || !msgSessionRecordSelector.listSpamChats.isEmpty()){
            MessagingSessionFieldPopulator.twillChatMissedChat(Trigger.new, null,msgSessionRecordSelector.listMissedTwillChats,msgSessionRecordSelector.listSpamChats,msgSessionRecordSelector.mapRelatedCases);
        }
        //Update Case for Time Out Chats
        if(!msgSessionRecordSelector.listTimeOutChats.isEmpty()){
            MessagingSessionFieldPopulator.closeTimeOutCase(Trigger.new, null,msgSessionRecordSelector.listTimeOutChats,msgSessionRecordSelector.mapRelatedCases);
        }
    } 
    public override void onAfterUpdate() {
        //listcheck
        //Case Updation for Chat Request Created or Relinked
        if(!msgSessionRecordSelector.listMessagingSessionToUpdate.isEmpty()){
            MessagingSessionFieldPopulator.updateFieldsonChatRequestCreationOrRelink(Trigger.new,this.oldMap,msgSessionRecordSelector.listMessagingSessionToUpdate,msgSessionRecordSelector.mapRelatedCases);
        }
        
        //Update Case when Chat Owner Changed
        if(!msgSessionRecordSelector.listOwnerChangedChatTrascript.isEmpty()){
            MessagingSessionFieldPopulator.updateWhenchatOwnerChanged(Trigger.new, this.oldMap,msgSessionRecordSelector.listOwnerChangedChatTrascript,msgSessionRecordSelector.mapRelatedCases);
        }
        else if(!msgSessionRecordSelector.caseBotOwnerChangeList.isEmpty()){
            MessagingSessionFieldPopulator.updateWhenchatOwnerChanged(Trigger.new, null,msgSessionRecordSelector.caseBotOwnerChangeList,msgSessionRecordSelector.mapRelatedCases);
            
        }
        // Update case for Missed Chat
        if(!msgSessionRecordSelector.listMissedChatlist.isEmpty()){
            MessagingSessionFieldPopulator.missedChat(Trigger.new, this.oldMap,msgSessionRecordSelector.listMissedChatlist,msgSessionRecordSelector.mapRelatedCases);
        }
        
        //Update Case when Twill Chat Owner Change
        if(!msgSessionRecordSelector.listTwillChatOwnerChange.isEmpty()){
            MessagingSessionFieldPopulator.twillChatOwnerChange(Trigger.new, this.oldMap,msgSessionRecordSelector.listTwillChatOwnerChange,msgSessionRecordSelector.mapRelatedCases);
        }
        
        //Update Case When Twill Chat is Missed
        if(!msgSessionRecordSelector.listMissedTwillChats.isEmpty() || !msgSessionRecordSelector.listSpamChats.isEmpty()){
            MessagingSessionFieldPopulator.twillChatMissedChat(Trigger.new, this.oldMap,msgSessionRecordSelector.listMissedTwillChats,msgSessionRecordSelector.listSpamChats,msgSessionRecordSelector.mapRelatedCases);
        }
        //Update Case for Time Out Chats
        if(!msgSessionRecordSelector.listTimeOutChats.isEmpty()){
            MessagingSessionFieldPopulator.closeTimeOutCase(Trigger.new, this.oldMap,msgSessionRecordSelector.listTimeOutChats,msgSessionRecordSelector.mapRelatedCases);        
        }
    }    
    
}