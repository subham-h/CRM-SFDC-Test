public without sharing class EngagementTrackerTriggerHandler extends TriggerHandler {
     // Maps to store new and old records during trigger execution
     public Map<Id, Engagement_Tracker__c> newMap;
     public Map<Id, Engagement_Tracker__c> oldMap;
     /**
      * Constructor to initialize newMap and oldMap with Trigger.newMap and Trigger.oldMap.
      */
     public EngagementTrackerTriggerHandler() {
         this.newMap = (Map<Id, Engagement_Tracker__c>)Trigger.newMap;
         this.oldMap = (Map<Id, Engagement_Tracker__c>)Trigger.oldMap; 
     }
     public EngagementTrackerSelector recordSelector;
     
     public override void getRecordSelector() {
         recordSelector = new EngagementTrackerSelector( trigger.new, this.oldMap, this);
     }
     /**
     * Trigger handler method executed before Engagement Tracker records are inserted.
     */
    public override void onBeforeInsert(){
        if (!recordSelector.engtckrWithoutLdCon.isEmpty()) {
            SoftRegistrationUtility.searchLeadAndContact(recordSelector.engtckrWithoutLdCon);
        }
        
    }
    public override void onBeforeUpdate(){
        if (!recordSelector.engtckrWithoutLdCon.isEmpty()) {
            SoftRegistrationUtility.searchLeadAndContact(recordSelector.engtckrWithoutLdCon);
        }
        
    }
    public override void onAfterInsert(){
        if(!recordSelector.leadToMakeEmVerTrueIds.isEmpty() || !recordSelector.conToMakeEmVerTrueIds.isEmpty()){
            SoftRegistrationUtility.stampLeadContact(recordSelector.leadToMakeEmVerTrueIds, recordSelector.conToMakeEmVerTrueIds);
        }
        if(!recordSelector.conIdETMap.isEmpty()){
            SoftRegistrationUtility.changeContactConsent(recordSelector.conIdETMap);
        }
        if(!recordSelector.leadIdETMap.isEmpty()){
            SoftRegistrationUtility.changeLeadConsent(recordSelector.leadIdETMap);
        }
        if(!SoftRegistrationUtility.conToUpdate.isEmpty()){
            SoftRegistrationUtility.saveContact();
        }
        if(!SoftRegistrationUtility.leadToUpdate.isEmpty()){
            SoftRegistrationUtility.saveLead();
        }
        
    }
    public override void onAfterUpdate(){
        if(!recordSelector.leadToMakeEmVerTrueIds.isEmpty() || !recordSelector.conToMakeEmVerTrueIds.isEmpty()){
            SoftRegistrationUtility.stampLeadContact(recordSelector.leadToMakeEmVerTrueIds, recordSelector.conToMakeEmVerTrueIds);
        }
        if(!recordSelector.conIdETMap.isEmpty()){
            SoftRegistrationUtility.changeContactConsent(recordSelector.conIdETMap);
        }
        if(!recordSelector.leadIdETMap.isEmpty()){
            SoftRegistrationUtility.changeLeadConsent(recordSelector.leadIdETMap);
        }
        if(!SoftRegistrationUtility.conToUpdate.isEmpty()){
            SoftRegistrationUtility.saveContact();
        }
        if(!SoftRegistrationUtility.leadToUpdate.isEmpty()){
            SoftRegistrationUtility.saveLead();
        }
        
    }
}