/*
Description  : Perform callout to get GCSS transport plan  

* version       Date                Owner                                       Description
*******************************************************************************************************************
* V1.0          06/09/2021         meghna@maersk.com                    Perform callout to get GCSS transport plan
*-------------------------------------------------------------------------------------------------------------------
*/
public with sharing class TransportPlanController {
    @AuraEnabled(cacheable=true)
    public static object getTransportPlan( string shipmentNo, string operator){
    
        
        operator = operator.toUpperCase();
        string strObjectName = 'TransportPlan';
        string modulename = 'getTransportPlan';
        
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename);  
        
        string urlParameterString = '';       
        if(shipmentNo != '' &&  shipmentNo != null){
            urlParameterString = 'shipments/'+shipmentNo+'/transportPlan?carrier=';
        }
        urlParameterString = AOServiceDetail.End_point_URL__c+urlParameterString+operator+'&'+Label.GCSSParamStringShipmentSummary;           
        System.debug('urlParameterString '+urlParameterString);
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        //setting Authorization header with the access token
        // req.setHeader('Authorization','Bearer '+accessToken);
        req.setHeader('Consumer-Key',AOServiceDetail.Authorization_Key__c);
        req.setHeader('RequestId', string.valueOf(UserInfo.getUserId()+''+system.now()));
        req.setTimeout(Integer.valueof(AOServiceDetail.Timeout__c));
        req.setEndpoint(urlParameterString); 
        system.debug('setEndpoint '+req);
        string res;
        try{  
            res = AO_APILoginUtility.sendRequest(req,AOServiceDetail);
            if(res.contains(Label.Token_Validation_Failed)){    
                Cache.Org.put('FRToken'+AOServiceDetail.Environment__c+AOServiceDetail.Authorization_Key__c,'',300);
                res = AO_APILoginUtility.sendRequest(req,AOServiceDetail);
            }else{
                return res;
            }
            
        } catch(Exception e){
            system.debug('error:'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('res.getBody() '+res);
        return res;
    } 
    
}