/*   
* Purpose : Utility methods for Insurance API callouts
* Test Class : QuoteTrigger_Test, QuoteLineItemTrigger_Test   
* Revision 	Ref Number  	Date          Owner                          Description
* -------- 	----------  	-----------   -------------------            -----------
* 1.0      	RQ-012787   	27/12/2019    Amritesh         			     Class created
* 1.1      	RQ-012785   	27/12/2019    Sidhartha         			 GetInsurance API Added
* 2.0		RQ-013342       31/03/2020    Amritesh                       Added timeout 
* 3.0		#SFSE-8466		20/05/2022	  Rakesh Allam					 Added Consumer Key as part of APIGEE standards
*/ 

public with sharing class InsuranceAPIUtility {
    
     /**
     * @description : Getting callout details from AO_Services__mdt meta data
     * @return : AO_Services__mdt
     */
    public static AO_Services__mdt getAOServicesMetadataValue(String strObjectName) {        
        AO_Services__mdt aOServicesMetadataDetails = [SELECT End_point_URL__c, Authorization_Key__c,
                                                      Environment__c, Timeout__c, NamedCred__c FROM AO_Services__mdt 
                                                      WHERE Active__c = TRUE AND MasterLabel = :strObjectName WITH SECURITY_ENFORCED LIMIT 1 ];
        return aOServicesMetadataDetails;
    }
    
     /**
     * @description : Generic method to accept parameters and send Insurnace Rest callout
     * @return : HTTP Response
     */
    public static HTTPResponse sendRequest(String uri, String req_method, String strBody, Decimal Timeout, Map<String, String> mapHeaders) {
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        req.setEndpoint(uri);
        req.setMethod(req_method);        
        for(String headerKey: mapHeaders.keySet()) {
            req.setHeader(headerKey, mapHeaders.get(headerKey));
        }
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        if(!String.isBlank(strBody)) {
            req.setHeader('Content-Length', String.valueOf(strBody.length()));
            req.setBody(strBody);             
        }
        if(Timeout==null){
            Timeout = 20000;
        }
        req.setTimeout(Integer.valueOf(Timeout));
        HTTPResponse res = http.send(req);
        return res;
    }
    
     /**
     * @description : Callout to Insurance API
     * @return : HTTP Response
     */
    public static HTTPResponse callGetInsuranceAPI(String getAuthToken, String header, String strBody, String strendPointUrl) {
		Integer timeOut = getAOServicesMetadataValue('getInsurance').Timeout__c == NULL ? 20000 : Integer.valueof(getAOServicesMetadataValue('getInsurance').Timeout__c);
        HttpRequest reqGetInsurance = new HttpRequest();
        reqGetInsurance.setEndpoint(strendPointUrl);
        reqGetInsurance.setHeader('Authorization', 'Bearer ' +getAuthToken);
        //Added Consumer Key - #SFSE-8466
        reqGetInsurance.setHeader('Consumer-Key', getAOServicesMetadataValue('getInsurance').Authorization_Key__c); 
        reqGetInsurance.setHeader('requestDate', String.valueof(System.today()));
        reqGetInsurance.setHeader('userId', header);
        reqGetInsurance.setHeader('Content-Type', 'application/json');
        reqGetInsurance.setHeader('Accept', 'application/json');
        reqGetInsurance.setTimeout(timeOut);
        reqGetInsurance.setBody(strBody);
        reqGetInsurance.setMethod('POST');
        Http http = new Http();
        HTTPResponse res;
        try{
            res = http.send(reqGetInsurance);
        } catch (System.CalloutException ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Quote', 'InsuranceAPIUtility.callGetInsuranceAPI', new list<Exception>{ex}); 
        }
        return res;
    }
    
     /**
     * @description : Callout to Insurance API to check City
     * @return : HTTP Response
     */
    public static HTTPResponse callGetInsuranceAPICheckCity(String getAuthToken, String header,String strendPointUrl) {
		Integer timeOut = getAOServicesMetadataValue('cargoInsuranceStatus').Timeout__c == NULL ? 20000 : Integer.valueof(getAOServicesMetadataValue('cargoInsuranceStatus').Timeout__c);
        HttpRequest reqGetInsurance = new HttpRequest();
        reqGetInsurance.setEndpoint(strendPointUrl);
        reqGetInsurance.setHeader('Authorization', 'Bearer ' +getAuthToken);
        //Added Consumer Key - #SFSE-8466
        reqGetInsurance.setHeader('Consumer-Key', getAOServicesMetadataValue('cargoInsuranceStatus').Authorization_Key__c); 
        reqGetInsurance.setHeader('requestDate', String.valueof(System.today()));
        reqGetInsurance.setHeader('timestamp', String.valueof(system.now()));
        reqGetInsurance.setHeader('userId', header);
        reqGetInsurance.setHeader('Content-Type', 'application/json');
        reqGetInsurance.setHeader('Accept', 'application/json');
        reqGetInsurance.setTimeout(timeOut);
        reqGetInsurance.setMethod('GET');
        Http http = new Http();
        HTTPResponse res;
        try{
            res = http.send(reqGetInsurance);
        } catch (System.CalloutException ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Quote', 'InsuranceAPIUtility.callGetInsuranceAPICheckCity', new list<Exception>{ex}); 
        }
        return res;
    }
    
 
    /**
     * @description : to query Quote Line Itesm based on Quote Id
     * @return : List of QuoteLineItem
     */
    public static List<QuoteLineItem> getQuoteLineItems(Id quoteId) {
        string stringquote = string.valueOf(quoteId);                 
        List<String> lstField = new List<String>(QuoteLineItem.SObjectType.getDescribe().fields.getMap().keySet());
        lstField.addAll(new List<String>{ 'Quote.Carrier_Code__c', 'Quote.Account.SCV_Code__c', 'Quote.Account.Name' , 'Insurance_Commodity__r.Commodity_Code__c' });
        String strQuery = 'SELECT ' + String.join(lstField, ',') + ' FROM QuoteLineItem' ;
        if(stringquote.startsWith(Quote.sObjectType.getDescribe().getKeyPrefix())) {
            strQuery += ' WHERE ' + 'QuoteId=\''+quoteId+'\'';
        } 
        else if(stringquote.startsWith(QuoteLineItem.sObjectType.getDescribe().getKeyPrefix())) {
            strQuery += ' WHERE ' + 'Id=\''+quoteId+'\'';
        }        
        return Database.query(strQuery);
    }
    
   	/**
     * @description : to query Insurance Error Codes
     * @return : List of E2E_Insurance_Error_Messages__mdt
     */
    public static List<E2E_Insurance_Error_Messages__mdt> getErrorCodeMsg() {
        List<E2E_Insurance_Error_Messages__mdt> lsterrorCodeMessage = [select Id, Error_Code__c, Error_Message__c from E2E_Insurance_Error_Messages__mdt];
        return lsterrorCodeMessage;
    }
    
    /**
     * @description : to get Error Message based on Error Code
     * @return : String - Error Message
     */
    public static String getErrorCodeMsg(String errorCode) {
        E2E_Insurance_Error_Messages__mdt errorCodeMessage = [SELECT Id, Error_Code__c,MasterLabel, Error_Message__c FROM E2E_Insurance_Error_Messages__mdt WHERE MasterLabel=:errorCode LIMIT 1];
        if(errorCodeMessage!=null){
            return errorCodeMessage.Error_Message__c;
        }
        else{
            return '';
        }
    }
    
}