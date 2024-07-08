/*              
* Revision Date        Owner                	Description
* -------- ----------  -----------				-----------
* 1.0     25-july-2023  Samar@maersk.com    	Wrapper class used in "Send OpportunityData Event to Kafka" flow to send payload to kafka
*/
public with sharing class OpportunityEventHandler {

    
    @InvocableMethod
    public static List <Results> serializeOpptyData (List<Requests> requestList) {
        List<Results> responseWrapper= new List<Results>();
        for (Requests curRequest : requestList) {
            SObject inputSObject = curRequest.inputSObject;
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
        OpportunityData_Event__e evt = (OpportunityData_Event__e)oppEvt;
        String serializedSObjectString = '';
        String jsonSTR ='';

        OpportunityEventResponseWrapper.OpportunityMessage msg = new OpportunityEventResponseWrapper.OpportunityMessage(); 
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
            msg = (OpportunityEventResponseWrapper.OpportunityMessage) System.JSON.deserialize(jsonSTR, OpportunityEventResponseWrapper.OpportunityMessage.class);
        }
        
        OpportunityEventResponseWrapper.salesOpportunityData finalmsg = new OpportunityEventResponseWrapper.salesOpportunityData(OpportunityEventResponseWrapper.getheader(evt.EventUuid, evt.Notification_Name__c), msg,evt.Topic_name__c,evt.key__c);
        if(finalmsg.message !=null) {
            if(finalmsg.message.opportunityLineItem !=null) {
                serializedSObjectString = JSON.serialize(finalmsg).replace('systemz','system');
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