/*   
* Test Class:-OLIEventResponseWrapper_Test                
* Revision Date        Owner                	    Description
* -------- ----------  -----------				    -----------
* 1.0      26-05-23     Samar@maersk.com    		This class is used to fire OpportunityLineItem Platform event
* 2.0	   16-10-2023	Jothsana@maersk.com			To make OLI event publish queable
* 3.0      12-03-2024   Samar@maersk.com			deactivate V3 and Adding V5 event logic
*/
public without sharing class OLIEventResponseHandler {
    public static void fireQueableOliEventsAsync(List<Id> lstofproduct,Boolean isOpptyBoolean, Boolean eventV3, Boolean eventV2,Boolean isInsert){
       System.enqueueJob(new OpptyProductEventQueueable(lstofproduct,isOpptyBoolean,eventV3,eventV2,isInsert));
    }
    
    public static void fireOliEventAsync(List<Id> listOfIdtoProcess, Boolean isOppty, Boolean eventV3, Boolean eventV2,Boolean isInsert){
        Set<Opportunity_Product__c> listOfOpptyLineItem = new Set<Opportunity_Product__c>();
        List<OLIEventResponseWrapper.Requests> listOfRequest= new List <OLIEventResponseWrapper.Requests>();
    
        if(isOppty){
            For(Opportunity opp:[SELECT Id,StageName, (SELECT id FROM Opportunity_Products__r) FROM Opportunity WHERE Id IN : listOfIdtoProcess ]){
                for(Opportunity_Product__c opptyProduct:opp.Opportunity_Products__r ){
                    listOfOpptyLineItem.add(opptyProduct);
                }
            }
        }else{
            For(Opportunity_Product__c opptyLineItem : [SELECT Id,OpportunityId__c,(Select id from Opportunity_Product_Configurations__r ) FROM Opportunity_Product__c WHERE Id IN : listOfIdtoProcess ]){
                if(isInsert){
                    if(opptyLineItem.Opportunity_Product_Configurations__r.size() == 0){
                listOfOpptyLineItem.add(opptyLineItem);
            }
                }else{
                    listOfOpptyLineItem.add(opptyLineItem);
                }
            }
        }

        if(!listOfOpptyLineItem.isEmpty()){
            // GetTopic name from Producer Platform Event Config for V1 and V2
            Map<String,String> mapOfTopic = new Map<String,String>();
            for(Producer_Platform_Event_Config__mdt event: Producer_Platform_Event_Config__mdt.getAll().values()){
                if(event.DeveloperName=='Opportunity_Product_Event' || event.DeveloperName=='Opportunity_Product_Data'){
                    mapOfTopic.put(event.DeveloperName, event.Topic_Name__c);
                }
            } 
            
            For(Opportunity_Product__c lineItem: listOfOpptyLineItem){
                OLIEventResponseWrapper.Requests req= new OLIEventResponseWrapper.Requests();
                req.isOliDeletd = false;
                req.oliReq = lineItem;
                listOfRequest.add(req);
            }
            processOLIEvent(listOfRequest,mapOfTopic,eventV3,eventV2);

        }
    }

    // To Process the Opportuninty Product which are being deleted.
    public static void fireOliEventSync(List<Id> listOfIdtoProcess, Boolean eventV3, Boolean eventV2){
        Set<Opportunity_Product__c> listOfOpptyLineItem = new Set<Opportunity_Product__c>();
        List<OLIEventResponseWrapper.Requests> listOfRequest= new List <OLIEventResponseWrapper.Requests>();

        For(Opportunity_Product__c opptyLineItem : [SELECT Id FROM Opportunity_Product__c WHERE Id IN : listOfIdtoProcess ]){
            listOfOpptyLineItem.add(opptyLineItem);
        }

        if(!listOfOpptyLineItem.isEmpty()){
            // GetTopic name from Producer Platform Event Config
            Map<String,String> mapOfTopic = new Map<String,String>();
            for(Producer_Platform_Event_Config__mdt event: Producer_Platform_Event_Config__mdt.getAll().values()){
                if(event.DeveloperName=='Opportunity_Product_Event' || event.DeveloperName=='Opportunity_Product_Data'){
                    mapOfTopic.put(event.DeveloperName, event.Topic_Name__c);
                }
            } 
        

            For(Opportunity_Product__c lineItem: listOfOpptyLineItem){
                OLIEventResponseWrapper.Requests req= new OLIEventResponseWrapper.Requests();
                req.isOliDeletd = true;
                req.oliReq = lineItem;
                listOfRequest.add(req);
            }
            processOLIEvent(listOfRequest,mapOfTopic,eventV3,eventV2);

        }
    }

    public static void processOLIEvent(List<OLIEventResponseWrapper.Requests>  listOfRequest,Map<String,String> mapOfTopic, Boolean eventV3, Boolean eventV2) {
        List<OLIEventResponseWrapper.Results> listOfResponse = new List<OLIEventResponseWrapper.Results> ();
        List<Opportunity_Product_Event__e> listOfProductEvent= new List<Opportunity_Product_Event__e>();
        List<Opportunity_Product_Data__e> listOfProductDataEvent= new List<Opportunity_Product_Data__e>();

        if(!listOfRequest.isEmpty()){
            listOfResponse= OLIEventResponseWrapper.prepareOliEventData(listOfRequest);
        }

        if(!listOfResponse.isEmpty()){
            for(OLIEventResponseWrapper.Results result: listOfResponse){
                if(result.serializedJSON1!= null){
                    if(eventV3){
                    Opportunity_Product_Event__e event= new Opportunity_Product_Event__e();
                    event.JSON_1__c = result.serializedJSON5 != null ? result.serializedJSON5: '';
                    event.JSON_2__c = result.serializedJSON6 != null ? result.serializedJSON6: '';
                    event.JSON_3__c = result.serializedJSON7 != null ? result.serializedJSON7: '';
                    event.JSON_4__c = result.serializedJSON8 != null ? result.serializedJSON8: '';
                    event.topic__c = mapOfTopic.get('Opportunity_Product_Event');
                    event.key__c = result.kafkakey;
                    listOfProductEvent.add(event);
                    }
                    if(eventV2){
                    Opportunity_Product_Data__e eventData= new Opportunity_Product_Data__e();
                    eventData.Topic_name__c = mapOfTopic.get('Opportunity_Product_Data');
                    eventData.JSON_1__c = result.serializedJSON1 != null ? result.serializedJSON1: '';
                    eventData.JSON_2__c = result.serializedJSON2 != null ? result.serializedJSON2: '';
                    eventData.JSON_3__c = result.serializedJSON3 != null ? result.serializedJSON3: '';
                    eventData.JSON_4__c = result.serializedJSON4 != null ? result.serializedJSON4: '';
                    eventData.key__c = result.kafkakey;
                    listOfProductDataEvent.add(eventData);
                }
            }
        }
        }
        if(!listOfProductEvent.isEmpty()){
            Database.SaveResult[] results=  EventBus.publish(listOfProductEvent);
        }

        if(!listOfProductDataEvent.isEmpty()){
            Database.SaveResult[] results=  EventBus.publish(listOfProductDataEvent);
        }
    }
}