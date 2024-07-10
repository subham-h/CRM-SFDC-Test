/* 
 * Author   : Amrutha
 * Purpose  : Single trigger for ContactPointTypeConsent object as per CBO architecture
 * 
*        
* Revision Ref Number  Date            Owner                      Description
* -------- ----------  -----------     -------------------        -----------
* 1.0      SFMC-7285   03-Jan-2024     amrutha@maersk             Code created for Reduce SFMC Billable Contact Count: Change the 'Sync to SFMC' logic in Sales Cloud
* 1.1      SFMC-7285   09-Jan-2024     Ranjan@maersk              Code modified for CBO architecture
*/


public class ContactPointTypeConsentTriggerHandler extends TriggerHandler {
    
    // Maps to store new and old records during trigger execution
    public Map<Id, ContactPointTypeConsent> newMap;
    public Map<Id, ContactPointTypeConsent> oldMap;
    /**
     * Constructor to initialize newMap and oldMap with Trigger.newMap and Trigger.oldMap.
     */
    public ContactPointTypeConsentTriggerHandler() {
        this.newMap = (Map<Id, ContactPointTypeConsent>)Trigger.newMap;
        this.oldMap = (Map<Id, ContactPointTypeConsent>)Trigger.oldMap; 
    }
    public ContactPointtypeConsentSelector recordSelector;
    
    public override void getRecordSelector() {
        recordSelector = new ContactPointtypeConsentSelector( trigger.new, this.oldMap, this);
    }
    
    /**
     * Trigger handler method executed after ContactPointTypeConsent records are inserted.
     */
    public override void onAfterInsert(){
        // Set to store unique Individual Ids affected by the trigger
        Set<Id> individualIdSet = new Set<Id> ();
        // Iterate through new records to collect Individual Ids
        for (ContactPointTypeConsent consent : this.newMap.values()) {
            individualIdSet.add(consent.PartyId);
        }
        // Update SyncToSFMC for affected Individual Ids
        SyncToSFMCUpdator.updateSyncToSFMC(individualIdSet,this.oldMap,false);
        if(!recordSelector.marketingIndivIdSet.isEmpty()){
            LeadMELUpdator.updateLeadOnCPTC(recordSelector.marketingIndivIdSet);
        }
    }
    
    /**
     * Trigger handler method executed after ContactPointTypeConsent records are updated.
     */
    public override void onAfterUpdate(){
        // Set to store unique Individual Ids affected by the trigger
        Set<Id> individualIdSet = new Set<Id> ();
        for (ContactPointTypeConsent newConsent : this.newMap.values()) {
            ContactPointTypeConsent oldConsent = this.oldMap.get(newConsent.Id);
            // Check if 'Privacy Consent Status' field is changed
            if (oldConsent != null && newConsent.PrivacyConsentStatus != oldConsent.PrivacyConsentStatus) {
                individualIdSet.add(newConsent.PartyId);
            }
        }
        if (!individualIdSet.isEmpty()) {
            SyncToSFMCUpdator.updateSyncToSFMC(individualIdSet,this.oldMap,false);
        }
        if(!recordSelector.marketingIndivIdSet.isEmpty()){
            LeadMELUpdator.updateLeadOnCPTC(recordSelector.marketingIndivIdSet);
        }
    }
    public override void onAfterDelete(){
        Set<Id> individualIdSet = new Set<Id> ();
        for (ContactPointTypeConsent deletedConsent : this.oldMap.values()) {
            individualIdSet.add(deletedConsent.PartyId);
        }
        SyncToSFMCUpdator.updateSyncToSFMC(individualIdSet,this.oldMap,true);
        LeadMELUpdator.updateLeadOnCPTC(individualIdSet);
    }

    

    
}