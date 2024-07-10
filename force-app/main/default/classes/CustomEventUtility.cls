/*              
* Revision   Ref Number       Date        Owner                       Description
* --------  ------------   ------------  ---------------------       ----------------------
* 1.0         SC-9978      16-May-2024    Richa@maersk.com           Utility class used to send custom event data to kafka
*/
public without sharing class CustomEventUtility {
    
    /** 
* @description | SC-9978 - Utility method to create Custom Event records
* @param result accepts CustomEventResponseParentWrapper respone
* @param mapOfTopic accepts key value pair of Event type and Topic name
* @param eventNotification accepts event notification name
*/
    
    public static Custom_Event__c createCustomEvent(CustomEventResponseParentWrapper result,Map<String,String> mapOfTopic, String eventNotification) {       
        Custom_Event__c csEvt= new Custom_Event__c();
        csEvt.Topic__c = mapOfTopic.get(result.getEventType());
        csEvt.Notification_Name__c = eventNotification;
        csEvt.Transaction_Type__c = result.getTransactionType();
        csEvt.Event_Type__c = result.getEventType();
        csEvt.Direction__c = 'Outgoing';
        csEvt.Key__c = result.getKafkakey(); 
        csEvt.Publishing_Record_Id__c = result.getPublishingRecordId();
        csEvt.Publisher_LastModifiedDate__c = result.getPublisherLastModifiedDate();
        csEvt.JSON_1__c = result.getSerializedJSON1() != null ? result.getSerializedJSON1(): '';
        csEvt.JSON_2__c = result.getSerializedJSON2() != null ? result.getSerializedJSON2(): '';
        csEvt.JSON_3__c = result.getSerializedJSON3() != null ? result.getSerializedJSON3(): '';
        csEvt.JSON_4__c = result.getSerializedJSON4() != null ? result.getSerializedJSON4(): '';
        csEvt.JSON_5__c = result.getSerializedJSON5() != null ? result.getSerializedJSON5(): '';
        csEvt.JSON_6__c = result.getSerializedJSON6() != null ? result.getSerializedJSON6(): '';
        return csEvt;
    }
    
    
    /** 
* @description | SC-9978 - Retry to publish failed records, invoked from the flow which makes the callout to Heroku
* @param retryEventId accepts Custom Event Id for which callout failed
* @param retryRecordKey accepts Kafka key (key identifier of the publishing record, ex- CaseNumber) of the failed Custom event record
*/    
    public class retryRequests {
        @InvocableVariable(required=true)
        public String retryEventId;     //Custom event record Id
        @InvocableVariable(required=true)
        public String retryRecordKey;      // Key of Custom Event record Id
    }
    
    @InvocableMethod
    public static void retryPublish (List<retryRequests> lstRequests) { 
        Set<String> setKeys = new Set<String>();
        Set<Id> setCustomEventId = new Set<Id>();
        List<Custom_Event__c> lstCustomEventUpdate = new List<Custom_Event__c>();
        Map<String,Custom_Event__c> mapOfCurrentEvents = new Map<String,Custom_Event__c>();        
        Map<String,Integer> mapOfKeyCount = new Map<String,Integer>(); // Map contains the Key and count of other failed records today with same key
        Map<Id,EventTypeWrapper> mapCasesToBePublishedAgain = new Map<Id,EventTypeWrapper>();        
        Boolean attemptRetry = false;        
        List<String> lstCustomEventPublishedAgain = new List<String> ();
        try{
            for(retryRequests cs : lstRequests){
                setKeys.add(cs.retryRecordKey);
                setCustomEventId.add(cs.retryEventId);
            }
            //Query all Failed custom event records with same Key and created today
            for(Custom_Event__c csEv:[Select Id,Status__c,Publishing_Record_Id__c,Transaction_Type__c,Key__c,Event_Type__c,Publisher_LastModifiedDate__c from Custom_Event__c where Key__c IN: setKeys and Status__c = 'Failed' and createddate = today order by createddate desc]){
                if(setCustomEventId.contains(csEv.Id)){
                    mapOfCurrentEvents.put(csEv.Key__c,csEv); 
                } 
                // Prepare map of count of existing failed events with same key
                if (mapOfKeyCount.containsKey(csEv.Key__c+csEv.Publisher_LastModifiedDate__c)) {
                    mapOfKeyCount.put(csEv.Key__c+csEv.Publisher_LastModifiedDate__c, mapOfKeyCount.get(csEv.Key__c+csEv.Publisher_LastModifiedDate__c) + 1);
                } else {
                    mapOfKeyCount.put(csEv.Key__c+csEv.Publisher_LastModifiedDate__c, 0);
                }                
            }
            
            for(Custom_Event__c csEvt:mapOfCurrentEvents.values()){  
                if(mapOfKeyCount.isEmpty() || (mapOfKeyCount.get(csEvt.Key__c+csEvt.Publisher_LastModifiedDate__c) < Integer.ValueOf(Label.Custom_Event_Retry_Count) && csEvt.Status__c == 'Failed')){
                    //add more if conditions to prepare map of other type of objects
                    if(csEvt.Event_Type__c == 'Case_Event'){
                        lstCustomEventPublishedAgain.add(csEvt.Id);                   
                        mapCasesToBePublishedAgain.put(csEvt.Publishing_Record_Id__c,new EventTypeWrapper(csEvt.Transaction_Type__c, csEvt.Event_Type__c));
                    } 
                }
            }
            
            //Call the object specific publish method or have a dispatcher class
            if(!mapCasesToBePublishedAgain.isEmpty()){
                CaseIntegrations.publishCases(mapCasesToBePublishedAgain,'live'); 
                attemptRetry = true;            
            }
            
            if(attemptRetry == true){
                for(String csEvt: lstCustomEventPublishedAgain){
                    Custom_Event__c evt = new Custom_Event__c(Id = csEvt);
                    evt.Retry_Attempted__c = attemptRetry; 
                    lstCustomEventUpdate.add(evt);
                }
            }
            if(lstCustomEventUpdate != null  && lstCustomEventUpdate.size() >0){
                update lstCustomEventUpdate;
            }
            
        }catch(Exception ex){   
            ErrorLogger.writeError( 'SFDC', 'Case', 'CustomEventUtility.retryPublish',ex.getTypeName(),ex.getMessage(),JSON.serialize(lstCustomEventPublishedAgain));
        }  
    }    
}