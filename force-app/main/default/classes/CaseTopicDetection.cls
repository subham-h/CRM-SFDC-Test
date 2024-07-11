@RestResource(urlmapping = '/casetopicdetection')
global class CaseTopicDetection {
    @HttpPost
    global static void doPost(){
        system.debug('Body-->'+RestContext.request.requestBody.toString());  //Response received from other system
        string jsonRequestStr = RestContext.request.requestBody.toString();
        ResponseWrapper wrapper = (ResponseWrapper) JSON.deserialize(jsonRequestStr,ResponseWrapper.class); 
        system.debug('wrapper-->'+wrapper);
    } 
    
    public class ResponseWrapper {
        public List<Results> Results;
    }
    
    public class Results {
        public String Intent;
        public String caseNumber;
        public List<entities> entities;
    }
    
    public class entities {
        public String containerNumber;
        public String shipmentNumber;
    }
    
    
}