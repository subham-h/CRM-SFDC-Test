/*
Description  : Perform callout to get ShipmentSummary from gcss

* version       Date                Owner                                       Description
*******************************************************************************************************************
* V1.0          19/11/2020          sriram@maersk.com                  	Perform callout to get ShipmentSummary from gcss
* V2.0			26-Apr-2024			Kiran@Maersk						Auto Case Assignment - Ocean - based on Cargo types - Reefer, OOG, Break Bulk
*-------------------------------------------------------------------------------------------------------------------
*/
public with sharing class ShipmentSummary {
    @AuraEnabled
    public static String getShipmentSummary(String shipmentNo){
        String strObjectName = 'SpotTwillBookingIdentifier';
        String modulename = 'getSpotTwillIdentifi';        
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename); 
        String urlParameterString = '';       
        if(shipmentNo != '' &&  shipmentNo != null){
            urlParameterString = 'shipments/'+shipmentNo+'/shipmentSummary?';
        }
        urlParameterString = AOServiceDetail.End_point_URL__c+urlParameterString+Label.GCSSParamStringShipmentSummary;           
        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Consumer-Key',AOServiceDetail.Authorization_Key__c);
        req.setHeader('RequestId', string.valueOf(UserInfo.getUserId()+''+system.now()));
        req.setHeader('X-Requestor',AOServiceDetail.Akami_Key__c);
        req.setTimeout(Integer.valueof(AOServiceDetail.Timeout__c));
        req.setEndpoint(urlParameterString); 
        HttpResponse res;
        String errTokenMsg = '';
        try{  
            res = sendRequest(req, AOServiceDetail, errTokenMsg);
            if(!String.isBlank(errTokenMsg) && errTokenMsg.contains(Label.Token_Validation_Failed)){    
                Cache.Org.put('FRToken'+AOServiceDetail.Environment__c+AOServiceDetail.Authorization_Key__c,'',300);
                res = sendRequest(req, AOServiceDetail, errTokenMsg);
            }else{
                if(res.getStatusCode() >= 400){
                    ErrorLogger.writeError('SFDC', 'Case', 'ShipmentSummary.getShipmentSummery', String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody());
                }
                return res.getBody();
            }
        } catch(Exception e){
            ErrorLogger.writeErrors('SFDC', 'Case', 'ShipmentSummary.getShipmentSummery', new list<Exception>{e});
            return e.getMessage();
        }
        return !String.isBlank(res.getBody()) ? res.getBody() : '';
    }
    
    @AuraEnabled
    public static String getBreakBulkResponse(String shipmentNo, string operator){
        String strObjectName = 'SpotTwillBookingIdentifier';
        String modulename = 'getSpotTwillIdentifi';        
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename); 
        String urlParameterString = '';       
        if(shipmentNo != '' &&  shipmentNo != null){
            urlParameterString = 'shipments/'+shipmentNo+'/breakBulkDetails?';
        }
        urlParameterString = AOServiceDetail.End_point_URL__c+urlParameterString+'carrier='+operator;           
        System.debug('urlParameterString '+urlParameterString);
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Consumer-Key',AOServiceDetail.Authorization_Key__c);
        req.setHeader('RequestId', string.valueOf(UserInfo.getUserId()+''+system.now()));
        req.setHeader('X-Requestor',AOServiceDetail.Akami_Key__c);
        req.setTimeout(Integer.valueof(AOServiceDetail.Timeout__c));
        req.setEndpoint(urlParameterString); 
        HttpResponse res;
        String errTokenMsg = '';
        try{  
            res = sendRequest(req, AOServiceDetail, errTokenMsg);
            if(!String.isBlank(errTokenMsg) && errTokenMsg.contains(Label.Token_Validation_Failed)){    
                Cache.Org.put('FRToken'+AOServiceDetail.Environment__c+AOServiceDetail.Authorization_Key__c,'',300);
                res = sendRequest(req, AOServiceDetail, errTokenMsg);
            }else{
                if(res.getStatusCode() >= 400){
                    ErrorLogger.writeError('SFDC', 'Case', 'ShipmentSummary.getBreakBulkResponse', String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody());
                }
                return res.getBody();
            }
        } catch(Exception e){
            ErrorLogger.writeErrors('SFDC', 'Case', 'ShipmentSummary.getBreakBulkResponse', new list<Exception>{e});
            return e.getMessage();
        }
        return !String.isBlank(res.getBody()) ? res.getBody() : '';
    }
    
    public static HttpResponse sendRequest(HttpRequest req, AO_Services__mdt AOServiceDetail, String errTokenMsg) {
        AO_APILoginUtility.message msg = new AO_APILoginUtility.message();
        http httpobj = new http();
        HttpResponse res;
        String accessToken = AO_APILoginUtility.getFRToken(AOServiceDetail);
        if(accessToken != null || Test.isRunningTest()){
            req.setHeader('Authorization','Bearer '+accessToken);
            res = httpobj.send(req);
            return res;
        }else{
            errTokenMsg = Label.AccessTokenFailed;
            return null;
        }
    }    
    
}