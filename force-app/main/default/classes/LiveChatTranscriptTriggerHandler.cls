/*
* Author   : Vaishali Gayatri
* Purpose  : To migrate and handle all logic associated with the Chat Transcript from Chat Channel Case Updates PB to Trigger.
*   
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 
*/
public class LiveChatTranscriptTriggerHandler extends TriggerHandler{
    public map<Id, LiveChatTranscript> newMap;
    public map<Id, LiveChatTranscript> oldMap;
    public LiveChatTranscriptTriggerHandler() {
        this.newMap = (map<Id, LiveChatTranscript>)Trigger.newMap;
        this.oldMap = (map<Id, LiveChatTranscript>)Trigger.oldMap;
    }
    public LiveChatTranscriptRecordSelector liveChatRecordSelector;
    
    public override void getRecordSelector() {
        liveChatRecordSelector = new LiveChatTranscriptRecordSelector(Trigger.new, this.oldMap, this);
    }
    public override void onAfterInsert() {
        //Case Updation When Chat Request Created or Relinked
        if(!liveChatRecordSelector.listChatTranscripttoUpdate.isEmpty()){
            LiveChatTranscriptFieldPopulator.updateFieldsonChatRequestCreationOrRelink(Trigger.new,null,liveChatRecordSelector.listChatTranscripttoUpdate,liveChatRecordSelector.mapRelatedCases);
        }
        
        //Update Case when Chat Owner Changed
        if(!liveChatRecordSelector.listOwnerChangedChatTrascript.isEmpty()){
            LiveChatTranscriptFieldPopulator.updateWhenchatOwnerChanged(Trigger.new, null,liveChatRecordSelector.caseBotOwnerChangeList,liveChatRecordSelector.mapRelatedCases);
        }
        else if(!liveChatRecordSelector.caseBotOwnerChangeList.isEmpty()){
            LiveChatTranscriptFieldPopulator.updateWhenchatOwnerChanged(Trigger.new, null,liveChatRecordSelector.caseBotOwnerChangeList,liveChatRecordSelector.mapRelatedCases);
            
        }
        
        // Update case for Missed Chat
        if(!liveChatRecordSelector.listMissedChatlist.isEmpty()){
            LiveChatTranscriptFieldPopulator.missedChat(Trigger.new, null,liveChatRecordSelector.listMissedChatlist,liveChatRecordSelector.mapRelatedCases);
        }
        
        //Update Case When Twill Chat is Missed
        if(!liveChatRecordSelector.listMissedTwillChats.isEmpty() || !liveChatRecordSelector.listSpamChats.isEmpty()){
            LiveChatTranscriptFieldPopulator.twillChatMissedChat(Trigger.new, null,liveChatRecordSelector.listMissedTwillChats,liveChatRecordSelector.listSpamChats,liveChatRecordSelector.mapRelatedCases);
        }
        //Update Case for Time Out Chats
        if(!liveChatRecordSelector.listTimeOutChats.isEmpty()){
            LiveChatTranscriptFieldPopulator.closeTimeOutCase(Trigger.new, null,liveChatRecordSelector.listTimeOutChats,liveChatRecordSelector.mapRelatedCases);
        }
    } 
    public override void onAfterUpdate() {
        //listcheck
        //Case Updation for Chat Request Created or Relinked
        if(!liveChatRecordSelector.listChatTranscripttoUpdate.isEmpty()){
            LiveChatTranscriptFieldPopulator.updateFieldsonChatRequestCreationOrRelink(Trigger.new,this.oldMap,liveChatRecordSelector.listChatTranscripttoUpdate,liveChatRecordSelector.mapRelatedCases);
        }
        
        //Update Case when Chat Owner Changed
        if(!liveChatRecordSelector.listOwnerChangedChatTrascript.isEmpty()){
            LiveChatTranscriptFieldPopulator.updateWhenchatOwnerChanged(Trigger.new, this.oldMap,liveChatRecordSelector.listOwnerChangedChatTrascript,liveChatRecordSelector.mapRelatedCases);
        }
        else if(!liveChatRecordSelector.caseBotOwnerChangeList.isEmpty()){
            LiveChatTranscriptFieldPopulator.updateWhenchatOwnerChanged(Trigger.new, null,liveChatRecordSelector.caseBotOwnerChangeList,liveChatRecordSelector.mapRelatedCases);
            
        }
        // Update case for Missed Chat
        if(!liveChatRecordSelector.listMissedChatlist.isEmpty()){
            LiveChatTranscriptFieldPopulator.missedChat(Trigger.new, this.oldMap,liveChatRecordSelector.listMissedChatlist,liveChatRecordSelector.mapRelatedCases);
        }
        
        //Update Case when Twill Chat Owner Change
        if(!liveChatRecordSelector.listTwillChatOwnerChange.isEmpty()){
            LiveChatTranscriptFieldPopulator.twillChatOwnerChange(Trigger.new, this.oldMap,liveChatRecordSelector.listTwillChatOwnerChange,liveChatRecordSelector.mapRelatedCases);
        }
        
        //Update Case When Twill Chat is Missed
        if(!liveChatRecordSelector.listMissedTwillChats.isEmpty() || !liveChatRecordSelector.listSpamChats.isEmpty()){
            LiveChatTranscriptFieldPopulator.twillChatMissedChat(Trigger.new, this.oldMap,liveChatRecordSelector.listMissedTwillChats,liveChatRecordSelector.listSpamChats,liveChatRecordSelector.mapRelatedCases);
        }
        //Update Case for Time Out Chats
        if(!liveChatRecordSelector.listTimeOutChats.isEmpty()){
            LiveChatTranscriptFieldPopulator.closeTimeOutCase(Trigger.new, this.oldMap,liveChatRecordSelector.listTimeOutChats,liveChatRecordSelector.mapRelatedCases);        
        }
    }    
    
}