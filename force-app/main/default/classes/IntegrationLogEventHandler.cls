/*
* Author   : Ayush.k@Maersk
* Purpose  : Triggers calls the handler class to handle the insert/update of integrartion logs in salesforce 
  
* Revision Ref Number  Date           Owner                   Description
* -------- ----------  -----------    -------------------     -----------
* 1.0       SS-5430    16-Nov-2022     Ayush.k@Maersk        Handler class to create Integration Log
* 2.0       SC-9362	   21-Nov-2023	   Nayana@maersk		 Added Related_Record_Number__c field to add Case number to Integration log,
*															 Optimized the code to bulkify the Case and Integration log queries
   
*/
/**
* 
* @author Ayush.k@Maersk
* @description Utility class to create Integration Log records
*/
public class IntegrationLogEventHandler {
/**
* 
* @author Ayush.k@Maersk
* @description Inner class to store response data from platform event
*/    
    public class JsonResponseFormat {
        public String CustomerName;
        public String customerNameExtracted;
        public String status;
        public String SoNumber;
        public String caseId;
        public String request_id;
        public String message;
    }
        
    public static General_Key_Value_Configurations__mdt response = General_Key_Value_Configurations__mdt.getInstance('IntegrationLogResult');
    public static General_Key_Value_Configurations__mdt fieldValues = General_Key_Value_Configurations__mdt.getInstance('IntegrationLogFieldValues');
    public static General_Key_Value_Configurations__mdt fieldValues2 = General_Key_Value_Configurations__mdt.getInstance('IntegrationLogFieldValues2');
    public static General_Key_Value_Configurations__mdt logValues = General_Key_Value_Configurations__mdt.getInstance('IntegrationLogValues');
    public static General_Key_Value_Configurations__mdt logStatus = General_Key_Value_Configurations__mdt.getInstance('IntegrationLogStatus');
    public static General_Key_Value_Configurations__mdt errorResponse = General_Key_Value_Configurations__mdt.getInstance('IntegrationLogErrorResponse');
    
    public static Map<Id,Case> mapCases = new Map<Id,Case>();
    public static Map<String,Integration_Log__c> mapIntegrationLogs = new Map<String,Integration_Log__c>();
    
/** 
* @description | Create Integration Log using platform event data |
* @param newList accepts list of Integration_Log_Event__e
*/
	public static void createIntegrationLog(List<Integration_Log_Event__e > newList) {

         // Map to store the Json field values of response in string , string format
    	jsonResponseFormat integrationLogsJson;       
        
        try{
            //This is to extract Case and Integration log records using the response
            extractDataFromEvent(newList);
            //
            for (Integration_Log_Event__e thisEvent : newList){
                String jsonResponse =  thisEvent.JSON_Response__c;
                if(!String.isEmpty(jsonResponse)){
                    jsonResponse = jsonResponse.trim();
                }
                Integration_Log__c tempLog = new Integration_Log__c();                
                integrationLogsJson = (jsonResponseFormat) JSON.deserialize(jsonResponse ,jsonResponseFormat.class);  
                // Insert the first response
                if(integrationLogsJson.request_id != null && integrationLogsJson.status == 'true'){
                    tempLog = IntegrationLogEventHandler.createInitialLogUpdate(integrationLogsJson);
                }//Insert the second response
                else if(integrationLogsJson.SoNumber != null && integrationLogsJson.CustomerName != null && integrationLogsJson.caseId != null){
                    tempLog = IntegrationLogEventHandler.createUpdatedLog(integrationLogsJson);    
                }//Insert Error Response
                else{
                    tempLog = IntegrationLogEventHandler.createErrorLog(integrationLogsJson);
                }
                upsert tempLog;
            }
        }
        Catch(Exception ex){
            String thisEventList = newList.toString();
            ErrorLogger.writeError( 'Integration Log', 'Case', 'IntegrationLogEventHandler.createIntegrationLog','Unknown exception',thisEventList,ex.getMessage() );
            
        }
       
    }
    
/** 
* @description | Update Integration log record |
* @param integrationLogsJson accepts jsonResponseFormat wrapper data
* @return Integration_Log__c
*/    
    public static Integration_Log__c createInitialLogUpdate(jsonResponseFormat integrationLogsJson) {
        Integration_Log__c tempLog = new Integration_Log__c();
        if(integrationLogsJson.request_id != null){
            String caseId = integrationLogsJson.request_id.split('-')[1];  
            tempLog = IntegrationLogEventHandler.extractLog(caseId);
            tempLog.Additional_Notes__c = integrationLogsJson.request_id;
        }     
        tempLog.Sub_Status__c = integrationLogsJson.status;
        tempLog.Status__c = logStatus.First_Field_Value__c;   
        return tempLog;
    }

/** 
* @description | Update Integration log record with more data like SO number, Customer Name etc |
* @param integrationLogsJson accepts jsonResponseFormat wrapper data
* @return Integration_Log__c
*/ 
    public static Integration_Log__c createUpdatedLog(jsonResponseFormat integrationLogsJson) {
        Integration_Log__c tempLog = IntegrationLogEventHandler.extractLog(integrationLogsJson.caseId);
        
        if(integrationLogsJson.SoNumber !=null){
            tempLog.Value_1__c = integrationLogsJson.SoNumber;
        }
       	if(integrationLogsJson.CustomerName !=null){
        	tempLog.Value_2__c = integrationLogsJson.CustomerName;
        }
        if(integrationLogsJson.customerNameExtracted !=null){
        	tempLog.Value_3__c = integrationLogsJson.customerNameExtracted;
        }
        tempLog.Status__c = logStatus.Second_Field_Value__c;
		tempLog.Sub_Status__c = 'Completed';
        tempLog.Field_1__c = fieldValues.First_Field_Value__c;
        tempLog.Field_2__c = fieldValues.Second_Field_Value__c;
        tempLog.Field_3__c = fieldValues2.First_Field_Value__c;
        tempLog.Additional_Notes__c += ' IDA_Response:' + integrationLogsJson.request_id;
        
        return tempLog;
    }

/** 
* @description | Create Error data in Integration log record |
* @param integrationLogsJson accepts jsonResponseFormat wrapper data
* @return Integration_Log__c
*/     
    public static Integration_Log__c createErrorLog(jsonResponseFormat integrationLogsJson){
        Integration_Log__c tempLog;
        String caseId = '';
        if(integrationLogsJson.request_id != null){
            caseId = integrationLogsJson.request_id.split('-')[1];  
            tempLog = IntegrationLogEventHandler.extractLog(caseId);
            tempLog.Error_Response__c = errorResponse.First_Field_Value__c;
        }
        else if(integrationLogsJson.caseId != null){
            tempLog = IntegrationLogEventHandler.extractLog(integrationLogsJson.caseId);
            tempLog.Error_Response__c = errorResponse.First_Field_Value__c;
        }//Case Id is Null or wrong format.
        else{
            tempLog = IntegrationLogEventHandler.extractLog(null);
            tempLog.Error_Response__c = errorResponse.Second_Field_Value__c;
        }
        
        return tempLog;
    }

/** 
* @description | Forms the Integration_Log__c data for above methods |
* @param caseId accepts case Id
* @return Integration_Log__c
*/ 
    public static Integration_Log__c extractLog(String caseId){
		
        String obj = logValues.First_Field_Value__c;
        String opType = logValues.Second_Field_Value__c;
        String externalId = opType + '_' +  caseId; 
        Integration_Log__c tempLog = new Integration_Log__c();
        
        if(caseId == null){ 
            tempLog.External_ID__c = opType + '_' +  System.now(); 
            tempLog.Object__c = obj;
            tempLog.External_Application__c = 'IDA';
            tempLog.Operation_Type__c = opType;
        }else{             
            //If no Integration log present for the external id then create new
            if(mapIntegrationLogs.isEmpty() || (!mapIntegrationLogs.isEmpty() && !mapIntegrationLogs.containskey(externalId)) ){ 
                tempLog.External_ID__c = opType + '_' +  caseId; 
                tempLog.Related_Record_Id__c = caseId;                
                tempLog.Related_Record_Number__c = (!mapCases.isEmpty() && mapCases.containskey(caseId)) ? mapCases.get(caseId).CaseNumber : ''; //SC-9362
                tempLog.Object__c = obj;
                tempLog.External_Application__c = 'IDA';
                tempLog.Operation_Type__c = opType;
            }else{ // If Integration log is already present for the external id then update existing
                tempLog = mapIntegrationLogs.get(externalId);
            }
        }

        return tempLog;
    }

/** 
* @description | Gets the case and Integration log records from the event |
* @param newList accepts list of Integration_Log_Event__e
*/     
    public static void extractDataFromEvent(List<Integration_Log_Event__e> newList){
        jsonResponseFormat integrationLogsJsonTemp;
        Set<Id> caseIds = new Set<Id>();
        Set<String> externalIds = new Set<String>();
        for (Integration_Log_Event__e thisEvent : newList){
            String jsonResponse =  thisEvent.JSON_Response__c;
            system.debug('jsonResponse++'+jsonResponse);
            String caseId = null;
            if(!String.isEmpty(jsonResponse)){
                jsonResponse = jsonResponse.trim();
                integrationLogsJsonTemp = (jsonResponseFormat) JSON.deserialize(jsonResponse ,jsonResponseFormat.class);  
            }                
            String opType = logValues.Second_Field_Value__c;
            String requestid = integrationLogsJsonTemp.request_id;
            if(requestid != null && requestid.contains('-')){
                caseId = integrationLogsJsonTemp.request_id.split('-')[1]; 
            }
            if(integrationLogsJsonTemp.caseId != null){
                caseId = integrationLogsJsonTemp.caseId;
            }
            if(caseId != null && caseId !=''){
                String externalId = opType + '_' +  caseId; 
                caseIds.add(caseId);
                externalIds.add(externalId);
            }
            
        }
        if(!caseIds.isEmpty()){ 
            mapCases = getCases(caseIds);
        }
        if(!externalIds.isEmpty()){ 
            mapIntegrationLogs = getIntegrationLogs(externalIds);
        }
    }

/** 
* @description | Gets the case records |
* @param caseIds accepts set of case Ids
* @return map of Cases
*/     
    public static Map<Id,Case> getCases(Set<Id> caseIds){     
        Map<Id,Case> mapCases = new Map<Id,Case>();
        if(!caseIds.isEmpty()){        
            for(Case cs:[Select Id, CaseNumber from Case where Id =:caseIds]){
                mapCases.put(cs.Id,cs);
            }
        }
        return mapCases;
    }

/** 
* @description | Gets the Integration log records |
* @param externalIds accepts set of String
* @return map of Integration_Log__c
*/     
    public static Map<String,Integration_Log__c> getIntegrationLogs(Set<String> externalIds){
        Map<String,Integration_Log__c> mapIntegrationLogs = new Map<String,Integration_Log__c>();
        if(!externalIds.isEmpty()){  
            for(Integration_Log__c intLog:[SELECT Id,Additional_Notes__c,External_ID__c FROM Integration_Log__c WHERE External_ID__c = :externalIds]){
                mapIntegrationLogs.put(intLog.External_ID__c,intLog);
            }    
        }
        return mapIntegrationLogs;
    }
    
}