/*
Description  : Perform callout to Azure to get Sentiment

* version       Ref Number    Date                Owner                                       Description
*******************************************************************************************************************
* V1.0          SC-3659       15/11/2021          Richa@maersk.com                       Perform callout to get Sentiment score
*-------------------------------------------------------------------------------------------------------------------
*/
public with sharing class SentimentAnalysis {
    
    public static String getSentimentScore(String body){
        String res;
        String strObjectName = 'AzureTextAnalytics';
        String modulename = 'getAzureSentiment';
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename);
        try{        	
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http = new Http();
			request.setMethod('POST');            
            request.setHeader('Content-Type', 'application/json');            
            request.setEndpoint('callout:'+AOServiceDetail.NamedCred__c);  
            request.setHeader('Ocp-Apim-Subscription-Key', '{!$Credential.Password}');
			request.setHeader('X-Requestor',AOServiceDetail.Akami_Key__c);            
            request.setTimeout(Integer.valueof(AOServiceDetail.Timeout__c));
            request.setBody(body);
            response = http.send(request);
            System.debug('***endpoint'+AOServiceDetail.NamedCred__c);
            System.debug('***response'+response);
            if (response.getStatusCode() == 200) {
                res = response.getBody();              
                return res;
            }         
        } catch(Exception e){
            system.debug('error:'+e.getMessage());
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'SentimentAnalysis', new list<Exception>{e});
        }
        System.debug('***res.getBody() '+res);
        return res;
    }
    
}