/*
 * Created By   : Aleena@Maersk
 * Purpose      : To handle all logic associated with the Opportunity Event.
 *              
 * Revision Jira Number    Date            Owner                   Description
 * -------- ----------   -----------  -------------------   --------------------------------------------------------
 * 1.0      SFSE-12888   10-Oct-2023     Aleena@Maersk      to improve the way salesOpportunity event (v3.1 and v4) is published from flow to Apex trigger
 * 2.0      SFSE-11535   12-Mar-2024     Samar@maersk.com	deactivate V3 and Adding V5 event logic
 */

 public without sharing class OpportunityEventUtilities {
    
    // to publish Opportunity event asynchronous
    public static void toFireQueableforOpptyEvent(List<Id> listOfIdtoProcess,Boolean isOppty,Boolean eventV5, Boolean eventV4){
    	System.enqueueJob(new QueableOpptyEventAsync(listOfIdtoProcess,isOppty,eventV5,eventV4));
    }
    
    public static void toFireOpptyEvent(List<Id> listOfIdtoProcess,Boolean isOppty,Boolean eventV5, Boolean eventV4){
        Set<Opportunity> listOfOppty = new Set<Opportunity>();
        List<OpportunityEventResponseWrapper.Requests> listOfRequest= new List <OpportunityEventResponseWrapper.Requests>();
        
        if(!isOppty){
            For(Opportunity_Product__c opptyLineItem : [SELECT Id FROM Opportunity_Product__c WHERE Id IN : listOfIdtoProcess]){
                listOfOppty.add(opptyLineItem.OpportunityId__r);
            }
        }else {
            For(Opportunity opp : [SELECT Id FROM Opportunity WHERE Id IN : listOfIdtoProcess ]){
            listOfOppty.add(opp);}
             }

        if(!listOfOppty.isEmpty()){
            // to get Topic name from Producer Platform Event Config mdt
            Map<String,String> mapOfTopic = new Map<String,String>();
            for(Producer_Platform_Event_Config__mdt event: Producer_Platform_Event_Config__mdt.getAll().values()){
                if(event.DeveloperName=='Opportunity_Event' || event.DeveloperName=='OpportunityData_Event'){
                    mapOfTopic.put(event.DeveloperName, event.Topic_Name__c);
                }
            } 
          
            For(Opportunity opp: listOfOppty){
                OpportunityEventResponseWrapper.Requests req= new OpportunityEventResponseWrapper.Requests();
                req.oppReq = opp;
                listOfRequest.add(req);
            }
            opportunityEvent (listOfRequest,mapOfTopic,eventV5,eventV4,'live');

        }
    }
    
    public static void toFireOpptyDeleteEvent(List<Id> listOfIdtoProcess,Boolean isOppty,Boolean eventV5, Boolean eventV4){
        Set<Opportunity_Product__c> listOfOpptyProd = new Set<Opportunity_Product__c>();
        List<OpportunityEventResponseWrapper.Requests> listOfRequest= new List <OpportunityEventResponseWrapper.Requests>();
        
        if(!isOppty){
            For(Opportunity_Product__c opptyLineItem : [SELECT Id,OpportunityId__c FROM Opportunity_Product__c WHERE Id IN : listOfIdtoProcess]){
               listOfOpptyProd.add(opptyLineItem);
            }
        }
        

        if(!listOfOpptyProd.isEmpty()){
            // to get Topic name from Producer Platform Event Config mdt
            Map<String,String> mapOfTopic = new Map<String,String>();
            for(Producer_Platform_Event_Config__mdt event: Producer_Platform_Event_Config__mdt.getAll().values()){
                if(event.DeveloperName=='Opportunity_Event' || event.DeveloperName=='OpportunityData_Event'){
                    mapOfTopic.put(event.DeveloperName, event.Topic_Name__c);
                }
            } 
          
            For(Opportunity_Product__c oppProd: listOfOpptyProd){
                OpportunityEventResponseWrapper.Requests req= new OpportunityEventResponseWrapper.Requests();
                req.oliReq = oppProd;
                req.isOliDeletd = true;
                listOfRequest.add(req);
            }
            opportunityEvent (listOfRequest,mapOfTopic,eventV5,eventV4,'live');

        }
    }
   
    
    // publish opportunity event
    public static void opportunityEvent(List<OpportunityEventResponseWrapper.Requests>  listOfRequest,Map<String,String> mapOfTopic,boolean eventV5,boolean eventV4,String eventNotification) {
        List<OpportunityEventResponseWrapper.Results> listOfResponse = new List<OpportunityEventResponseWrapper.Results> ();
        List<Opportunity_Event__e> listOfOpportunityEvent= new List<Opportunity_Event__e>();
        List<OpportunityData_Event__e> listOfOpportunityDataEvent= new List<OpportunityData_Event__e>();

        if(!listOfRequest.isEmpty()){
            listOfResponse= OpportunityEventResponseWrapper.prepareOppEventData(listOfRequest);
        }

        if(!listOfResponse.isEmpty()){
            for(OpportunityEventResponseWrapper.Results result: listOfResponse){
                if(result.serializedJSON1!= null){
                    if(eventV5){
                        Opportunity_Event__e event= new Opportunity_Event__e();
                        event.topic__c = mapOfTopic.get('Opportunity_Event');
                        event.Notification_Name__c = eventNotification;
                        event.key__c = result.kafkakey;
                        event.JSON_1__c = result.serializedJSON7 != null ? result.serializedJSON7: '';
                    	event.JSON_2__c = result.serializedJSON8 != null ? result.serializedJSON8: '';
                    	event.JSON_3__c = result.serializedJSON9 != null ? result.serializedJSON9: '';
                    	event.JSON_4__c = result.serializedJSON10 != null ? result.serializedJSON10: '';
                    	event.JSON_5__c = result.serializedJSON11 != null ? result.serializedJSON11: '';
						event.JSON_6__c = result.serializedJSON12 != null ? result.serializedJSON12 : '';
                        
                        listOfOpportunityEvent.add(event);
                    }
                    if(eventV4){
                    OpportunityData_Event__e eventData= new OpportunityData_Event__e();
                    eventData.Topic_name__c = mapOfTopic.get('OpportunityData_Event');
                    eventData.key__c = result.kafkakey;
                    eventData.JSON_1__c = result.serializedJSON1 != null ? result.serializedJSON1: '';
                    eventData.JSON_2__c = result.serializedJSON2 != null ? result.serializedJSON2: '';
                    eventData.JSON_3__c = result.serializedJSON3 != null ? result.serializedJSON3: '';
                    eventData.JSON_4__c = result.serializedJSON4 != null ? result.serializedJSON4: '';
                    eventData.JSON_5__c = result.serializedJSON5 != null ? result.serializedJSON5: '';
                    eventData.JSON_6__c = result.serializedJSON6 != null ? result.serializedJSON6: '';
                    eventData.Notification_Name__c = eventNotification;
                    listOfOpportunityDataEvent.add(eventData);
                    }
                }
            }
        }
        
        if(!listOfOpportunityEvent.isEmpty()){
            Database.SaveResult[] results=  EventBus.publish(listOfOpportunityEvent);
        }

        if(!listOfOpportunityDataEvent.isEmpty()){
            Database.SaveResult[] results=  EventBus.publish(listOfOpportunityDataEvent);
        }
    }

}