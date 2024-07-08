/*
* Author    : Richa
* Purpose   : To handle all logic related to Party data
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-9582     22-12-2023  Richa@Maersk            Party data related logic
*/
public class PartyTriggerHandler extends TriggerHandler {
    public map<Id, Party__c> newMap;
    public map<Id, Party__c> oldMap;
    public PartyTriggerHandler() {
        this.newMap = (map<Id, Party__c>)Trigger.newMap;
        this.oldMap = (map<Id, Party__c>)Trigger.oldMap; 
    }
    
    public PartyRecordSelector partyRecordSelector;
    
    public override void getRecordSelector() {
        partyRecordSelector = new PartyRecordSelector(Trigger.new, this.oldMap, this);
    }   
    
    public override void onAfterInsert() {
       if(!partyRecordSelector.mapBookingNumberOpls.isEmpty() && !partyRecordSelector.mapBookedByParty.isEmpty() && !partyRecordSelector.mapBookedByContact.isEmpty()){   
            PartyUtility.updatePartyOnOpl(partyRecordSelector.mapBookedByParty ,partyRecordSelector.mapBookingNumberOpls, partyRecordSelector.mapBookedByContact);
       } 
    }
    
    public override void onAfterUpdate() {
       if(!partyRecordSelector.mapBookingNumberOpls.isEmpty() && !partyRecordSelector.mapBookedByParty.isEmpty() && !partyRecordSelector.mapBookedByContact.isEmpty()){   
            PartyUtility.updatePartyOnOpl(partyRecordSelector.mapBookedByParty ,partyRecordSelector.mapBookingNumberOpls, partyRecordSelector.mapBookedByContact);
       } 
    }
   
}