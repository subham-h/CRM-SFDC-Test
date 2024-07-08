/*
Description  : Perform callout to get Pricing Details  

* version       Date                Owner                                       Description
*******************************************************************************************************************
* V1.0          01/10/2020          avinash@ust.com                    Perform callout to get Pricing Details 
*-------------------------------------------------------------------------------------------------------------------
*/
public with sharing class PricingDetailsController {
    @AuraEnabled(cacheable=true)
    public static Object getPricingDetails(string shipmentNo, string operator){
        system.debug('shipmentNo :'+shipmentNo);
        system.debug('operator :'+operator);
        operator = operator.toUpperCase();
        string strObjectName = 'PricingDetails';
        string modulename = 'getPricingDetails';
        
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename);  
        string urlParameterString = '';
        
        if(shipmentNo != '' &&  shipmentNo != null){
            //urlParameterString = shipmentNo+'/freightLines/invoiceDetails?';
            urlParameterString = shipmentNo+'/freightLines?';
        }
        urlParameterString = AOServiceDetail.End_point_URL__c+urlParameterString+Label.GCSSParamString+operator;           
        System.debug('urlParameterString '+urlParameterString);
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        //setting Authorization header with the access token
        req.setHeader('Consumer-Key',AOServiceDetail.Authorization_Key__c);
        req.setHeader('RequestId', string.valueOf(UserInfo.getUserId()+''+system.now()));
        req.setTimeout(Integer.valueof(AOServiceDetail.Timeout__c));
        req.setEndpoint(urlParameterString); 
        system.debug('setEndpoint '+req);
        http httpobj = new http();
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