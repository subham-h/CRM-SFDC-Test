public with sharing class ArtemisProducerHandler2 {

    public class ResultsSerialized {
        @InvocableVariable
        public String serializedSObjectString;
    }
    
    public class RequestsSerialized {
        @InvocableVariable(required=true)
        public SObject inputSObject;      
        @InvocableVariable
        public String inputSObjectName;
    }
    
    @InvocableMethod
    public static List <ResultsSerialized> serializePEProducerData (List<RequestsSerialized> requestList) {
        List<ResultsSerialized> responseWrapper= new List<ResultsSerialized>();
        
        for (RequestsSerialized curRequest : requestList) {
            SObject inputSObject = curRequest.inputSObject;
            
            String serializedSObjectString= ArtemisProducerHandler.getSerializedPeObject(inputSObject, curRequest.inputSObjectName);
            ResultsSerialized response = new ResultsSerialized();
            if(serializedSObjectString !=null && serializedSObjectString != '') {
                    response.serializedSObjectString =serializedSObjectString.contains('"{') ?(serializedSObjectString.substringBefore('"{')+'{'+serializedSObjectString.substringAfter('"{')):serializedSObjectString;   
                    response.serializedSObjectString=response.serializedSObjectString.contains('}"')?response.serializedSObjectString.substringBeforeLast('}"')+'}'+response.serializedSObjectString.substringAfterLast('}"'):response.serializedSObjectString;
            }
            responseWrapper.add(response);
        } 
        return responseWrapper;  
    }
}