public with sharing class ArtemisFilterLogicHandler {

    public class ResultsSerialized {
        @InvocableVariable
        public String updateInsertEventFlag;
    }
    
    public class RequestsSerialized {
        @InvocableVariable
        public sObject inputSObjectNew; 
        @InvocableVariable
        public sObject inputSObjectOld;        
        @InvocableVariable
        public String inputSObjectName;
    }
    
    @InvocableMethod
    public static List <ResultsSerialized> identifyEventBasedOnFilterLogic (List<RequestsSerialized> requestList) {
        List<ResultsSerialized> responseWrapper= new List<ResultsSerialized>();
		String updateInsertEventFlag ='';
        Map<String, Object> rowOld;
        Map<String, Object> rowNew;
        ResultsSerialized response;
        List<Artemis_PE_Object_Config__mdt> evtPEList=[select Platform_Event__c,From_Field__c,To_Field__c,Is_Updatable__C from Artemis_PE_Object_Config__mdt where Platform_Event__c =: requestList[0].inputSObjectName and Is_Updatable__C = true];

        for (RequestsSerialized curRequest : requestList) {
            
            response = new ResultsSerialized();

            SObject inputSObjectNew = curRequest.inputSObjectNew;
            rowNew = (Map<String, Object>) JSON.deserializeUntyped(Json.serialize(inputSObjectNew));

            if(curRequest.inputSObjectOld != null){
            	SObject inputSObjectOld = curRequest.inputSObjectOld;
          	 	rowOld = (Map<String, Object>) JSON.deserializeUntyped(Json.serialize(inputSObjectOld));
           
            }else if(curRequest.inputSObjectOld == null){
            	response.updateInsertEventFlag = 'Insert';
                responseWrapper.add(response);
                continue;
            }
        
        Map<String, String> rowSObjectMapOld = new Map<String, String>(); 
        Map<String, String> rowSObjectMapNew = new Map<String, String>(); 

        for(String rowTemp : rowOld.keySet()){
                
            rowSObjectMapOld.put(rowTemp.toLowerCase(), rowOld.get(rowTemp) != null ? String.valueOf(rowOld.get(rowTemp)) : '');
        }
        for(String rowTemp : rowNew.keySet()){
                
            rowSObjectMapNew.put(rowTemp.toLowerCase(), rowNew.get(rowTemp) != null ? String.valueOf(rowNew.get(rowTemp)) : '');
        }
        for(Artemis_PE_Object_Config__mdt peMetaObj:evtPEList){
            
            System.debug('-->rowSObjectMapNew.get(peMetaObj.From_Field__c)'+rowSObjectMapNew.get(peMetaObj.From_Field__c.ToLowerCase()));
            System.debug('-->rowSObjectMapOld.get(peMetaObj.From_Field__c)'+rowSObjectMapOld.get(peMetaObj.From_Field__c.ToLowerCase()));

            if( rowSObjectMapOld.get(peMetaObj.From_Field__c.toLowercase()) != rowSObjectMapNew.get(peMetaObj.From_Field__c.toLowercase())){
                
                updateInsertEventFlag = 'Update';
                system.debug('-->Insider If'+updateInsertEventFlag);
                break;
                
            }
            else{
                
                continue;
            }
         }
       
        response.updateInsertEventFlag = updateInsertEventFlag;
        responseWrapper.add(response);
    	}
       return responseWrapper;
    }
}