public class SyncContactToCMDHandler extends TriggerHandler {
    public List<Sync_Contact_CMD_Event__e> newContactMsg;
    
    public SyncContactToCMDHandler() {
        this.newContactMsg = (List<Sync_Contact_CMD_Event__e>) Trigger.new;
    }
    public override void onAfterInsert() {
        Set<Id> accId = new Set<Id>();
        Set<String> geoCode = new Set<String>();
        List<Map<String, String>> phonenumbers = new List<Map<String, String>>();
        Map<Id, String> mapOfAcctoCustCode = new Map<Id, String>();
        Map<Id, String> mapOfCountrytoGeoCode = new Map<Id, String>();
        
        Map<Id,Contact> mapofIdtoContact = new Map<Id,Contact>();
        List<Contact> lstcontact = new List<Contact>();
        for(Sync_Contact_CMD_Event__e ss: newContactMsg) {
            String jsonStr = ss.JSON_Payload__c;
            Contact jsondata = (Contact)JSON.deserialize(jsonStr,Contact.class);
            Map<String,String> m1 = new Map<String, String> {
                'TEL' => jsondata.Phone,'MOB' => jsondata.MobilePhone
                    };
                        phonenumbers.add(m1);
            system.debug('@@@@@@ ' + jsondata);
            mapofIdtoContact.put(jsondata.Id, jsondata);
            accId.add(jsondata.AccountId);
            geoCode.add(jsondata.Country__c);
            lstcontact.add(jsondata);
            If( Limits.getQueueableJobs() < Limits.getLimitQueueableJobs() && !Test.isRunningTest()) {
                System.enqueueJob(new ApiCalloutCMDQueueable (mapofIdtoContact));
            }
        }
    }
}