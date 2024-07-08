/*
 * Author   : Shahanawaz@Maersk
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on Booking Information trigger.
 * 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0     SC-9293     22-12-2023  Shahanawaz@maersk       	Create feeditem on parent Case
*/
public class ExternalPartyHandler extends TriggerHandler{
    
    public map<Id, External_Party__c> newMap;
    public map<Id, External_Party__c> oldMap;
    public ExternalPartyHandler() {
        this.newMap = (map<Id, External_Party__c>)Trigger.newMap;
        this.oldMap = (map<Id, External_Party__c>)Trigger.oldMap; 
    }
    
    public ExternalPartyRecordSelector extPartyRecordSelector;
    
    public override void getRecordSelector() {
        extPartyRecordSelector = new ExternalPartyRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onAfterInsert() {
        if(!extPartyRecordSelector.extPartyList.isEmpty()){
            ExternalPartyHelper.createFeedItem(extPartyRecordSelector.extPartyList);
        }
    }

}