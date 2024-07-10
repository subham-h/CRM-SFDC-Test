public with sharing class SyncContactToCMDUtility {
    public static void publishContactsEvents(List<Contact> conts) {
        system.debug('conts ' + conts);
        List<Sync_Contact_CMD_Event__e > events = new List<Sync_Contact_CMD_Event__e >();
        for(Contact c: conts) {
            Sync_Contact_CMD_Event__e contDetails = new Sync_Contact_CMD_Event__e();  
            contDetails.JSON_Payload__c = JSON.serialize(c);
            events.add(contDetails);
        }
        List<Database.SaveResult> results = EventBus.publish(events);
        
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event: '+ sr);
            } else {
                System.debug('Error when publishing event: ' + sr);
            }
        } 
    }
}