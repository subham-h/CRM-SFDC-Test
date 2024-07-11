/*              
* Revision Date        Owner                	Description
* -------- ----------  -----------				-----------
* 1.0     27-Oct-2022  Sidhartha@maersk.com    	Wrapper class used in "Send Opportunity Event To Kafka" flow to send payload to kafka
* 2.0     12-Mar-2024  Samar@maersk.com		    deactivate V3 and Adding V5 event logic  SFSE-11535
*/
public with sharing class SerializeSObjectToJSON {

    
    @InvocableMethod
    public static List <Results> serialize (List<Requests> requestList) {
        List<Results> responseWrapper= new List<Results>();
       
        for (Requests curRequest : requestList) {
            SObject inputSObject = curRequest.inputSObject;
           // Opportunity_Event__e evt = (Opportunity_Event__e)inputSObject;
            String serializedSObjectString = processOpportunityEventData(inputSObject);
            Results response = new Results();
            if(serializedSObjectString !=null && serializedSObjectString != '') {
                response.serializedSObjectString = serializedSObjectString;
            }
            responseWrapper.add(response);
        } 
        return responseWrapper;  
    }
    
    public static string processOpportunityEventData(SObject oppEvt) {
        Opportunity_Event__e evt = (Opportunity_Event__e)oppEvt;
        String serializedSObjectString = '';
        String jsonSTR ='';
        system.debug('Check '+evt.JSON_1__c);
       
        OpportunityEventResponseWrapper.message msg; 
        if(evt.JSON_1__c!=null){
            jsonSTR = evt.JSON_1__c;
        }
        if(evt.JSON_2__c!=null && jsonSTR!= null){
            jsonSTR = jsonSTR + evt.JSON_2__c;  
        }
        if(evt.JSON_3__c!=null && jsonSTR!= null){
            jsonSTR =jsonSTR +  evt.JSON_3__c;
        }
        if(evt.JSON_4__c!=null &&  jsonSTR!= null){
            jsonSTR =jsonSTR +  evt.JSON_4__c;
        }
        if(evt.JSON_5__c!=null &&  jsonSTR!= null){
            jsonSTR =jsonSTR +  evt.JSON_5__c;
        }
        if(evt.JSON_6__c!=null &&  jsonSTR!= null){
            jsonSTR =jsonSTR +  evt.JSON_6__c;
        }

        if(evt.JSON_1__c != null){
            msg = (OpportunityEventResponseWrapper.message) System.JSON.deserialize(jsonSTR, OpportunityEventResponseWrapper.message.class);
        }

        OpportunityEventResponseWrapper.salesOpportunity finalmsg = new OpportunityEventResponseWrapper.salesOpportunity(OpportunityEventResponseWrapper.getheaderWrapper(evt.EventUuid,evt.Notification_Name__c), msg,evt.topic__c,evt.key__c);
        if(finalmsg.message !=null) {
            if(finalmsg.message.opportunityLineItem !=null) {
                serializedSObjectString = JSON.serialize(finalmsg).replace('opportunityLineItemSchedules','opportunityLineItemSchedule').replace('opportunityLineItem','opportunityLineItem').replace('systemz','system');
            }
        }
        return serializedSObjectString;
    }
    
    public class Results {
        @InvocableVariable
        public String serializedSObjectString;
    }
    
    public class Requests {
        @InvocableVariable(required=true)
        public SObject inputSObject;       
    }
}