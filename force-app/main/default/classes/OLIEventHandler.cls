/*    
* Test Class:-OLIEventResponseWrapper_Test          
* Revision Date        Owner                	    Description
* -------- ----------  -----------				    -----------
* 1.0      28-03-23       Samarpreet.singh@maersk.com    Wrapper class used in "Send Opportunity Product Event to Kafka" flow to send payload to kafka
* 2.0      12-Mar-2024    Samar@maersk.com	             deactivate V3 and Adding V5 event logic SFSE-11535
*/
public without sharing class OLIEventHandler {
    
    @InvocableMethod(label='Process OLI Event')
    public static List <Results> serialize (List<Requests> requestList) {
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
        Opportunity_Product_Event__e evt = (Opportunity_Product_Event__e)oppEvt;
        String serializedSObjectString = '';
		String jsonSTR ='';
        OLIEventResponseWrapper.message msg; 
        
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
        
        if(evt.JSON_1__c != null){
            msg = (OLIEventResponseWrapper.message) System.JSON.deserialize(jsonSTR, OLIEventResponseWrapper.message.class);
        }
        
        OLIEventResponseWrapper.opportunityProduct finalmsg = new OLIEventResponseWrapper.opportunityProduct(OLIEventResponseWrapper.getheaderWrapper(evt.EventUuid), msg,evt.topic__c,evt.key__c);
       
        if(finalmsg.message !=null) {
           serializedSObjectString = JSON.serialize(finalmsg);
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