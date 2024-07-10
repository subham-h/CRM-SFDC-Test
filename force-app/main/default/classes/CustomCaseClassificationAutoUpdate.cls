/*
Description  : Perform callout to get utilize the custom Case classification Modal created by DA team to classify cases. 

* version       Date                Owner                         Description
*******************************************************************************************************************
* V1.0          09/02/2022          Sreya@maersk                  Perform callout to utilize the custom Case classification Modal created by DA team to classify cases
* V2.0          11/07/2022          Sunil.bs@maersk               Added Retry mechanism for calling DA method on failure and also added check to triggger omni in case if any exceptions
*-------------------------------------------------------------------------------------------------------------------
*/
public class CustomCaseClassificationAutoUpdate {
    
    public static String getCaseClassification(String requestBody,String firstCaseNumber,set<id> caseIds){
        
        String responseBody;
        String strObjectName = 'CustomECC';
        String modulename = 'getCustomECC';
        Decimal Counter;
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename);
        try{ 
            General_Settings__c gs = General_Settings__c.getInstance();
            Counter = gs.Custom_Model_CC_Callout_Count__c;
            String accessToken;
            if(Counter!=null){
                for(;Counter>=0;Counter--){
                    accessToken = AO_APILoginUtility.getFRToken(AOServiceDetail);
                    if (accessToken != null){
                        break;              
                    } 
                }
            }

            System.debug('ABC  accessToken '+ accessToken);
            //API callout to utlize the case classification model built by DA team 
                HttpRequest request = new HttpRequest();
                HttpResponse response = new HttpResponse();
                Http http = new Http();
                request.setMethod('POST');            
                request.setHeader('Content-Type', 'application/json'); 
                request.setHeader('Consumer-Key',AOServiceDetail.Authorization_Key__c); 
                request.setHeader('X-Requestor',AOServiceDetail.Akami_Key__c);
                if(accessToken != null){
                 request.setHeader('Authorization', 'Bearer ' +accessToken);
                }
                request.setEndpoint(AOServiceDetail.End_point_URL__c);                    
                request.setTimeout(Integer.valueof(AOServiceDetail.Timeout__c));
                request.setBody(requestBody);
                 System.debug('ABC Request' + requestBody);
            System.debug('ABC Request' + request);
            System.debug('ABC Request' + AOServiceDetail.End_point_URL__c);
            System.debug('ABC Request' + Integer.valueof(AOServiceDetail.Timeout__c));
            System.debug('ABC Request' + AOServiceDetail.Akami_Key__c);
            System.debug('ABC Request' + AOServiceDetail.Authorization_Key__c);
                System.debug('@@@@response'+response.getBody());
                Counter = gs.Custom_Model_CC_Callout_Count__c;
                if(Counter!=null){
                    for(;Counter>=0;Counter--){
                        response = http.send(request);
                        if (response.getStatusCode() == 200){
                            responseBody = response.getBody();
                            break;              
                        } 
                    }
                }
                
                
                if (response.getStatusCode() != 200){
                    ErrorLogger.writeError( 'SFDC', 'Case', 'CustomCaseClassificationAutoUpdate.getCaseClassification1', string.ValueOf(response.getStatusCode())+'-'+response.getStatus() ,firstCaseNumber+';'+AOServiceDetail.Authorization_Key__c+';'+AOServiceDetail.End_point_URL__c ,response.getBody() );
                }
            
            
        } catch(Exception e){
            system.debug('PVA Exception is' +e.getMessage());
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CustomCaseClassificationAutoUpdate.getCaseClassification2', new list<Exception>{e});
        }  
        System.debug('ABC Res '+responseBody );
        return responseBody;
        
    }     
}