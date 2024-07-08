/*
* Author   : Sandhya@UST
* Purpose  : Handles all Exchange Rate related functionalities.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-002683   23-Feb-2016 Sandhya@UST               Created.
* 2.0      RQ-004427   29-Nov-2016  Nisha@UST                Connection errors to the ESB are logged in the source system error fields.
* 3.0      RQ-005636   25-Sep-2017  Nisha@UST                Update references of GlobalErrorLogger
* 4.0      RQ-007793   07-Feb-2018  Meenakshi@UST RQ-007793  ESB service calls from salesforce through USI - New URL
* 5.0      SC-267      26-03-2020   Sreya@Maersk             Callout to heroku endpoint from Service view. 
* 6.0      SC-2183     27-04-2021   Richa@maersk             Future method callout to Azure Eventhub for OHP integration
* 7.0      SC-1601     20-07-2021   Richa@maersk             Retrieve GCSS Writeback Custom Metadata record
* 8.0      SC-3659     15-11-2021   Richa@maersk             Retrieve Language Mapping Custom Metadata record
* 9.0	   SC-9504	   11-01-2024	Nayana@maersk			 Leveraged method connectServiceUsageToHeroku() to handle CX package usage
* 10.0          	   11/01/2024   Vivek@maersk             Added new header akamaiRequestHeader to authorize at Akamai for getFRToken() Method

*/

public class WebserviceUtilities {
    
    public static ESB_Webservice__mdt esbServiceDetails = new ESB_Webservice__mdt(); // Custom Metadata Type to store webservice details
    public static map<Integer, Webservice_Field_List__mdt> fieldMap = new map<Integer, Webservice_Field_List__mdt>();
    public class ESBWebserviceNotConfiguredException extends Exception {}
    
    @future(callout=true)
    public static void sendHTTPRequest(String strBody, String strTimeout,String strEndpointURL, String strObjectName, set<Id> setRecordIds) {
        General_Key_Value_Configurations__mdt akamaiHeader = General_Key_Value_Configurations__mdt.getInstance('AkamaiRequestHeader');

        try {
           
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('content-type', 'text/xml;charset=UTF-8');
            req.setHeader('SOAPAction','PublishToJMS');
            if(akamaiHeader!= null && akamaiHeader.First_Field_Value__c != null )
            	req.setHeader('x-requestor',akamaiHeader.First_Field_Value__c);//added new header as part of Token api issue resolution from akamai

            req.setBody(strBody);
            req.setTimeout(Integer.valueof(strTimeout));
            //req.setClientCertificateName(strCertificate);  RQ-007793 
            req.setEndpoint(strEndpointURL);
            
            system.debug('req--->>'+req);
            system.debug('strBody--->>'+strBody);            
            
            HTTPResponse res = (new Http()).send(req);
            if(res.getStatusCode() != 200) {
                logErrorsToSourceObject(String.valueOf(res.getStatusCode()), res.getStatus(), strObjectName, setRecordIds);
            }
        }
        catch(Exception ex) {
            System.debug(Logginglevel.ERROR, 'Exception! ' + ex.getMessage());
            ErrorLogger.writeErrors( 'SFDC', strObjectName, 'WebserviceUtilities.sendHTTPRequest', new list<Exception>{ex}); // #RQ-005636
            logErrorsToSourceObject(ex.getTypeName(), ex.getMessage(), strObjectName, setRecordIds); // v2.0
        }
    }
    
    // v2.0 - Created to store the error messages back to source object records so that end users know what happened.
    // NOTE: Source object should have Source_System_Error_Code__c & Source_System_Error_Message__c fields inorder to store the error details. 
    @TestVisible private static void logErrorsToSourceObject(String strType, String strMessage, String strObjectName, set<Id> setRecordIds) {
        try {
            String strQuery = 'select Id, Source_System_Error_Code__c, Source_System_Error_Message__c from ' + strObjectName + ' where Id in :setRecordIds';
            list<sObject> lstSObjects = Database.query(strQuery);
            for(sObject sObj : lstSObjects) {
                sObj.put('Source_System_Error_Code__c', strType);
                sObj.put('Source_System_Error_Message__c', strMessage);
            }
            TriggerExecutionController.skipAllTriggers(true);
            update lstSObjects;
            TriggerExecutionController.skipAllTriggers(false);
        }
        catch(Exception e) {
            ErrorLogger.writeErrors( 'SFDC', strObjectName, 'WebserviceUtilities.logErrorsToSourceObject', new list<Exception>{e}); // #RQ-005636
        }
    }
    
    public static String getHeader(String moduleName, String strUsername, String strPassword) {
        String strXMLHeader = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v2="http://services.apmoller.net/ManagementFramework/CommonIdentifier/v2" xmlns:v1="http://services.apmoller.net/AMM/HTTPJMSAdapter/v1">'
            +'<soap:Header xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:quot="http://services.apmoller.net/AMM/v4/QuoteOrchestration" xmlns:v4="http://services.apmoller.net/AMM/v4">'
            +'<wsse:Security soap1:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:soap1="soapenv">'
            +'<wsse:UsernameToken wsu:Id="UsernameToken-3" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
            +'<wsse:Username>' + strUsername + '</wsse:Username>'
            +'<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + strPassword + '</wsse:Password>'
            +'</wsse:UsernameToken>'
            +'</wsse:Security>'
            +'<v2:CommonIdentifierRequest>'
            +'<v2:ApplicationRequester>'
            +'<v2:ApplicationID>SFDC</v2:ApplicationID>'
            +'<v2:ChannelID>ESB</v2:ChannelID>'
            +'<v2:OperatorID>ApexCode</v2:OperatorID>'
            +'<v2:TransactionID>1</v2:TransactionID>'
            +'<v2:ApplicationUserID>' + UserInfo.getUserId() + '</v2:ApplicationUserID>'
            +'</v2:ApplicationRequester>'
            +'<v2:UserRequester/>'
            +'</v2:CommonIdentifierRequest>'
            +'</soap:Header>'
            +'<soapenv:Body>'
            +'<v1:PublishToJMSRequest>' 
            +'<v1:ModuleName>' + moduleName + '</v1:ModuleName>'
            +'<v1:anyXMLRequest>';
        return strXMLHeader;
    }
    
    public static String getFooter() {
        String strXMLFooter = '</v1:anyXMLRequest>'+
            '</v1:PublishToJMSRequest>'+
            '</soapenv:Body>'+
            '</soapenv:Envelope>';
        return strXMLFooter;
    }
    
    // Get the webservice and field details from custom metadata type
    public static ESB_Webservice__mdt esbMetadataValue(String objName, String moduleName){
        String serviceName = moduleName;
        
        // Webservice call details
        esbServiceDetails  = [select MasterLabel,Module__c, End_point_URL__c, Timeout__c, Password__c, OSB_Username__c
                              from ESB_Webservice__mdt where Active__c = TRUE and MasterLabel = :objName and Module__c = :serviceName limit 1];
        
        if(esbServiceDetails == null) {
            throw (new ESBWebserviceNotConfiguredException('ESB_Webservice__mdt is not yet configured!'));
        }
        return esbServiceDetails;
    }
    
    // Get the webservice and field details from custom metadata type
    public static map<Integer, Webservice_Field_List__mdt> getWebServiceFieldMetadataValue(String objName, String moduleName){
        String serviceName = moduleName;
        
        // Field details
        for(Webservice_Field_List__mdt fieldRow : [select MasterLabel, ESB_Module_Name__c, Type__c, Value__c, DeveloperName, Order__c 
                                                   from Webservice_Field_List__mdt where MasterLabel = :objName and ESB_Module_Name__c = :serviceName order by DeveloperName asc]) {
                                                       
                                                       fieldMap.put(Integer.valueof(fieldRow.Order__c), fieldRow);
                                                       
                                                   }   
        return fieldMap;
    }
    public static ESB_Webservice__mdt getESBShipmentMetadataValue(String strObjectName,String strModuleName){
        
        ESB_Webservice__mdt esbServiceDetails  = [select MasterLabel,End_point_URL__c, Timeout__c, Password__c, OSB_Username__c
                                                  from ESB_Webservice__mdt where Active__c = TRUE and MasterLabel = :strObjectName and Module__c = :strModuleName limit 1];
        
        return esbServiceDetails;
    }
    
    public static AO_Services__mdt getAOServicesMetadataValue(String strObjectName,String strModuleName){
        
        AO_Services__mdt aOServicesMetadataDetails  = [select MasterLabel,Environment__c,End_point_URL__c, Timeout__c, Authorization_Key__c,Apex_Timeout__c,NamedCred__c,Akami_Key__c
                                                       from AO_Services__mdt where Active__c = TRUE and MasterLabel = :strObjectName and Module__c = :strModuleName limit 1];
        
        return aOServicesMetadataDetails;
    }
    public static OIPC_Connection_Details__mdt getOIPCMetadataValue(){
        
        OIPC_Connection_Details__mdt oipcMetadata  = [select MasterLabel,Consumer_Key__c, Grant_Type__c,Scope__c,Timeout__c,Auth_Url__c,Client_ID__c,Client_Secret__c,Endpoint_URL__c,Testtoken__c from OIPC_Connection_Details__mdt where Active__c = TRUE limit 1];
        
        return oipcMetadata;
    }
    //SC-1601: get GCSS Writeback custom metadata values
    public static GCSS_Write_Back_Services__mdt getGCSSWriteBackMetadataValue(String strObjectName,String strModuleName){
        
        GCSS_Write_Back_Services__mdt gcssWriteBackMetadataDetails  = [select MasterLabel,Environment__c,End_point_URL__c, Timeout__c, Authorization_Key__c,Apex_Timeout__c,NamedCred__c
                                                       from GCSS_Write_Back_Services__mdt where Active__c = TRUE and MasterLabel = :strObjectName and Module__c = :strModuleName limit 1];
        
        return gcssWriteBackMetadataDetails;
    } 
    
    //SC-3659: get Language mapping custom metadata values
    public static List<Sentiment_Language_Mapping__mdt> getLangMapping(String language){
        
        List<Sentiment_Language_Mapping__mdt> langMappingDetails  = [select DeveloperName,Sentiment_Language_Code__c from Sentiment_Language_Mapping__mdt where DeveloperName = :language limit 1];
        
        return langMappingDetails;
    } 
    
    
    public static String getShipmentServiceHeader(ESB_Webservice__mdt esbServiceDetail){
        String strHeader = +'<v2:CommonIdentifierRequest>'
            +'<v2:ApplicationRequester>'
            +'<v2:ApplicationID>SFDC</v2:ApplicationID>'
            +'<v2:ChannelID>ESB</v2:ChannelID>'
            +'<v2:OperatorID>ApexCode</v2:OperatorID>'
            +'<v2:ApplicationUserID>'+ UserInfo.getUserId() +'</v2:ApplicationUserID>'
            +'<v2:TransactionID>1</v2:TransactionID>'
            +'</v2:ApplicationRequester>'
            +'<v2:UserRequester/>'
            +'</v2:CommonIdentifierRequest>'
            +'</soapenv:Header>'
            +'<soapenv:Body>';
        return strHeader;        
    }
    
    public static String getShipmentServiceFooter(){
        String strFooter = '</soapenv:Body>'
            +'</soapenv:Envelope>';
        return strFooter;
    }
    // Callout to heroku endpoint from Service view LWC components
    @AuraEnabled
    public static void connectServiceUsageToHeroku(string sf_record_id,string app_name,string appcomponent_usage){
        try{
            system.debug(sf_record_id+app_name+appcomponent_usage);
            // recordId will be null for service view stand alone app and will be caseid for service view hosted in case page.
            string recId = (sf_record_id == null) ? '' : sf_record_id;
            // setting up input parameters
            herokuInput inputs = new herokuInput();
            inputs.sf_user_id = userInfo.getUserId();
            inputs.sf_record_id = recId;
            inputs.app_name= app_name;
            inputs.appcomponent_usage= appcomponent_usage;
            inputs.usagedate= string.valueOf(system.now());
            
            // Querying metadata for certificate and endpoint
            LWC_Heroku_Integration__mdt mdtObj = new LWC_Heroku_Integration__mdt();
            if(app_name!=null && app_name=='CX Package'){ //SC-9504
                mdtObj = getHerokuLWCMetadata('LWC CXPackage metrics Insert');
            }else{
                mdtObj = getHerokuLWCMetadata('LWC Metrics Insert');
        	}
            system.debug('metadata'+mdtObj);
            
            // calling getJWTBearer method for getting JWT token
            string jwtToken = getJWTBearer(mdtObj.Certificate_Name__c,mdtObj.Role__c,mdtObj.Audience__c);
            system.debug('jwt token'+jwtToken);
            
            // making the heroku post call
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json'); 
            req.setHeader('Authorization', 'Bearer '+jwtToken);           
            req.setBody(JSON.serialize( inputs));
            req.setEndpoint(mdtObj.End_point_URL__c);
           
            http httpobj = new http();
            HttpResponse res = httpobj.send(req);
            system.debug('heroku response'+res.getBody());
            system.debug('heroku status'+res.getStatusCode());
            if (res.getStatusCode()<200 || res.getStatusCode()>299){
                //Writing the exception details to global error logger record.
                ErrorLogger.writeError( 'SFDC', 'Case', 'WebserviceUtilities.connectServiceUsageToHeroku',string.ValueOf(res.getStatusCode()) , res.getStatus(),res.getBody());               
            }
        }
        catch(Exception ex){
            system.debug('Exception'+ex.getMessage());
            //Writing the exception details to global error logger record.
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'WebserviceUtilities.connectServiceUsageToHeroku', new list<Exception>{ex});
        }       
        
    }
    public static String getJWTBearer(string certName, String role, String Audience) {
        
        Map<String,String> claims = new Map<String,String>();
        claims.put('role',role);
        
        Auth.JWT jwt = new Auth.JWT();
        
        // Add standard claims       
        jwt.setAud(Audience);
        jwt.setValidityLength(120);
        
        // Add custom claims
        jwt.setAdditionalClaims(claims);
        
        // Initiate JWS class to generate jwt token
        Auth.JWS signedToken = new Auth.JWS(jwt, certName);
        String serializedToken = signedToken.getCompactSerialization();
        return serializedToken;
        
    }
    
    // utility method for fetching Heroku connectivity metadata
    public static LWC_Heroku_Integration__mdt getHerokuLWCMetadata(string apiName){
       return [select End_point_URL__c,Certificate_Name__c,Audience__c,Role__c from LWC_Heroku_Integration__mdt where Active__c = true and MasterLabel =: apiName limit 1];
    }
    public class herokuInput{
        public string sf_user_id;
        public string sf_record_id;
        public string app_name;
        public string appcomponent_usage;
        public string usagedate;
    }
    
    //SC-2183
   @future(callout=true)
    public static void sendOHPHTTPRequest(String strBody,Set<Id> setCaseIds) {
                System.debug('***strBody'+strBody);  
                String strIds = JSON.serialize(setCaseIds); 
                string strObjectName = 'OHPDisputeWorkflow';
                string strModuleName = 'getOHPDisputes';
                AO_Services__mdt aoServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName,strModuleName);               
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setMethod('POST'); 
                req.setHeader('content-type', 'application/atom+xml;type=entry;charset=utf-8'); 
                req.setTimeout(Integer.valueof(aoServiceDetail.Timeout__c));
                req.setEndpoint(aoServiceDetail.End_point_URL__c);
                req.setbody(strBody);                        
                string res;
                try{  
                    res = AO_APILoginUtility.sendAzureOHPRequest(req,aoServiceDetail);
                    if(res.contains(Label.Token_Validation_Failed) || res != Label.AzureOHPSuccess){ 
                        Cache.Org.put('OHPToken'+aoServiceDetail.Environment__c,'',300);
                        res = AO_APILoginUtility.sendAzureOHPRequest(req,aoServiceDetail);
                    }                    
                } catch(Exception e){
                    system.debug('error:'+e.getMessage());
                    ErrorLogger.writeError( 'SFDC', 'Case', 'WebserviceUtilities.sendOHPHTTPRequest','System.CalloutException',e.getMessage(),strIds);
                }
                System.debug('**ResponseStatus '+res);             
    }

}