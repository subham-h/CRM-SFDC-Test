/*
* Author    : Richa
* Purpose   : Query records related to Party
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-9582     12-12-2023   Richa@Maersk           Query Party records
*/
public class PartyRecordSelector implements RecordSelector{
    private TriggerHandler partyTriggerHandler;  
    public Set<String> setContactExId = new Set<String>();  
    public Map<String,Contact > mapBookedByContact = new Map<String,Contact>();
    public Map<String,Ocean_Plus_Lead__c> mapBookingNumberOpls = new Map<String,Ocean_Plus_Lead__c>();
    public Map<String,Party__c> mapBookedByParty = new Map<String,Party__c>();
    
    public PartyRecordSelector(list<Party__c> lstParties, map<Id, Party__c> mapOldParties, PartyTriggerHandler partyTriggerHandler) {
        this.partyTriggerHandler= partyTriggerHandler;
        this.selectRecords(lstParties, mapOldParties);
        if(lstParties != null && lstParties.size() >0) {
            this.getRelatedRecords(lstParties);
        }
    }
    public void selectRecords(list<Party__c> lstParties, map<Id, sObject> mapOldParties) {
        if(lstParties != null && lstParties.size() >0) {
            for(Party__c newPrty : lstParties) {
                Party__c oldPrty;
                if(mapOldParties != null && !mapOldParties.isEmpty()) {
                    oldPrty = (Party__c)mapOldParties.get(newPrty.Id);
                }
                
                if(partyTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER) {
                    if(partyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                       if(newPrty.Party_Number__c == '1' && newPrty.Contact_Person__c != null){
                            setContactExId.add(newPrty.Contact_Person__c);
                            mapBookedByParty.put(newPrty.Shipment_Number__c,newPrty);
                        } 
                    }else if(partyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                        if(newPrty.Party_Number__c == '1' && oldPrty.Contact_Person__c != newPrty.Contact_Person__c && newPrty.Contact_Person__c != null){
                            setContactExId.add(newPrty.Contact_Person__c);
                            mapBookedByParty.put(newPrty.Shipment_Number__c,newPrty);
                        } 
                    }
                }                
            }
        }
    }
    
    public void getRelatedRecords(list<Party__c> lstParties) {
       getRelatedOPLs();
       getRelatedContacts();
    }
    // Retrieve related OPLs
    public void getRelatedOPLs() {
        if(!mapBookedByParty.isEmpty()) {
            for(Ocean_Plus_Lead__c opl: [Select Id,Booking_Number__c,Booked_By_Contact_Name__c,Booked_By_Contact_Email__c,Booked_By_Contact_Phone_Number__c from Ocean_Plus_Lead__c where Booking_Number__c IN :mapBookedByParty.keySet() and Status__c IN ('New','In Progress')]){             
                mapBookingNumberOpls.put(opl.Booking_Number__c,opl);
            } 
        } 
    }
    // Retrieve related Contacts
    public void getRelatedContacts(){
        if(!setContactExId.isEmpty()) {
            for(Contact con: [Select Id,Name,External_ID__c,Email, Phone,MobilePhone from Contact where External_ID__c != null and External_ID__c IN :setContactExId]){
                mapBookedByContact.put(con.External_ID__c,con);                
            }
        }
    }
    
}