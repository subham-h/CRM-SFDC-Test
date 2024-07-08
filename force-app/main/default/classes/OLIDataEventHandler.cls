/*    
* Test Class:-OLIEventResponseWrapper_Test          
* Revision Date        Owner                	    Description
* -------- ----------  -----------				    -----------
* 1.0      28-03-23  Samarpreet.singh@maersk.com    Wrapper class used in "Send Opportunity Product Event to Kafka" flow to send payload to kafka
*/
public without sharing class OLIDataEventHandler {
    
    @InvocableMethod(label='Process OLIData  Event')
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
        Opportunity_Product_Data__e evt = (Opportunity_Product_Data__e)oppEvt;
        String serializedSObjectString = '';
        String jsonSTR ='';
        /*
        List<OLIEventResponseWrapper.SelectedProductConfiguration> oliProduct= new  List<OLIEventResponseWrapper.SelectedProductConfiguration>();
        List<OLIEventResponseWrapper.OpportunityLineItemSchedules_z> oliSchedule = new List<OLIEventResponseWrapper.OpportunityLineItemSchedules_z>();
        List<OLIEventResponseWrapper.OpportunityLineItemSchedules_z> oliSchedule1 = new List<OLIEventResponseWrapper.OpportunityLineItemSchedules_z>();
       	*/
        
        OLIEventResponseWrapper.LineItemMessage msg; 

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
            msg = (OLIEventResponseWrapper.LineItemMessage) System.JSON.deserialize(jsonSTR, OLIEventResponseWrapper.LineItemMessage.class);
        }
        /*
        if(evt.JSON_2__c != null){
            oliProduct = (List<OLIEventResponseWrapper.SelectedProductConfiguration>) System.JSON.deserialize(evt.JSON_2__c, List<OLIEventResponseWrapper.SelectedProductConfiguration>.class);
        }
        if(evt.JSON_3__c != null){
            oliSchedule = (List<OLIEventResponseWrapper.OpportunityLineItemSchedules_z>) System.JSON.deserialize(evt.JSON_3__c, List<OLIEventResponseWrapper.OpportunityLineItemSchedules_z>.class);
        }
        if(evt.JSON_4__c != null){
            oliSchedule1 = (List<OLIEventResponseWrapper.OpportunityLineItemSchedules_z>) System.JSON.deserialize(evt.JSON_4__c, List<OLIEventResponseWrapper.OpportunityLineItemSchedules_z>.class);
        }

        if(oliProduct!=null){
            msg.selectedProductConfigurations= oliProduct;
        }
        if(oliSchedule!=null){
            msg.opportunityLineItemSchedules.addAll(oliSchedule);
        }
        if(oliSchedule1!=null){
            msg.opportunityLineItemSchedules.addAll(oliSchedule1);
        }*/
        OLIEventResponseWrapper.OpportunityProductData finalmsg = new OLIEventResponseWrapper.OpportunityProductData(OLIEventResponseWrapper.getheader(evt.EventUuid), msg,evt.Topic_name__c,evt.key__c);
       
        if(finalmsg.message !=null) {
           serializedSObjectString = JSON.serialize(finalmsg);
        }  
        

        system.debug('serializedSObjectString '+ serializedSObjectString);
        
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