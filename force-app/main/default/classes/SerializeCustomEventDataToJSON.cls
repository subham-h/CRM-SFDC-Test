/*              
* Revision   Ref Number       Date        Owner                       Description
* --------  ------------   ------------  ---------------------       ----------------------
* 1.0         SC-9978     07-May-2024    Richa@maersk.com           Wrapper class used in "Publish Custom Events To Kafka" flow to send serialized payload to kafka
*/

public with sharing class SerializeCustomEventDataToJSON {    
    
    public class Results {
        @InvocableVariable
        public String serializedSObjectString;
    }
    
    public class Requests {
        @InvocableVariable(required=true)
        public SObject inputSObject;    
        @InvocableVariable
        public String inputSObjectName;      
    }
    
    @InvocableMethod
    public static List <Results> serialize (List<Requests> lstRequest) {
        List<Results> responseWrapper= new List<Results>();
        
        for (Requests curRequest : lstRequest) {
            SObject inputSObject = curRequest.inputSObject;
            String inputSObjectName = curRequest.inputSObjectName;
            String serializedSObjectString = processCustomEventData(inputSObject,inputSObjectName);
            Results response = new Results();
            if(serializedSObjectString !=null && serializedSObjectString != '') {
                response.serializedSObjectString = serializedSObjectString;
            }
            responseWrapper.add(response);
        } 
        return responseWrapper;  
    }
    
    public static string processCustomEventData(sObject customEvt, String sObjectName) {        
        SObjectType thisSObject = ((SObject) Type.forName(String.valueOf(sObjectName)).newInstance()).getSObjectType();   
        sObject genericObject = thisSObject.newSObject();
        genericObject = customEvt;
        String serializedSObjectString = '';
        String serializedString = '';
        
        CaseEventResponseWrapper.message msg; 
        
        if(genericObject.get('JSON_1__c') != null && genericObject.get('JSON_1__c') != ''){
            serializedString = (String)genericObject.get('Json_1__c');
        }
        if(genericObject.get('JSON_2__c') != '' && genericObject.get('JSON_2__c') != null){
            serializedString = serializedString + genericObject.get('JSON_2__c');
        }
        if(genericObject.get('JSON_3__c') != '' && genericObject.get('JSON_3__c') != null){
            serializedString = serializedString + genericObject.get('JSON_3__c');
        }
        if(genericObject.get('JSON_4__c') != '' && genericObject.get('JSON_4__c') != null){
            serializedString = serializedString + genericObject.get('JSON_4__c');  
        }
        if(genericObject.get('JSON_5__c') != '' && genericObject.get('JSON_5__c') != null){
            serializedString = serializedString + genericObject.get('JSON_5__c');
        }
        if(genericObject.get('JSON_6__c') != '' && genericObject.get('JSON_6__c') != null){
            serializedString = serializedString + genericObject.get('JSON_6__c');       
        }
        
        
        if(genericObject.get('JSON_1__c') != null  && genericObject.get('JSON_1__c') != ''){
            msg = (CaseEventResponseWrapper.message) System.JSON.deserialize(serializedString, CaseEventResponseWrapper.message.class);
        }
        
        CaseEventResponseWrapper.serviceCase finalmsg = new CaseEventResponseWrapper.serviceCase(CaseEventResponseWrapper.getHeader((String)genericObject.get('Notification_Name__c'),(String)genericObject.get('Transaction_Type__c')), msg,(String)genericObject.get('Topic__c'),(String)genericObject.get('Key__c'));
        if(finalmsg.message !=null) {           
            serializedSObjectString = JSON.serialize(finalmsg).replace('systemz','system');            
        }
        
        return serializedSObjectString;
    }
    
}