/*
Description  : Perform callout to get ShipmentReferences from gcss

* version       Date                Owner                                       Description
*******************************************************************************************************************
* V1.0          13/07/2021          shahanawaz.akhtar@maersk.com                  Perform callout to get References from gcss
*-------------------------------------------------------------------------------------------------------------------
*/
public with sharing class GetReferences {
    
    @AuraEnabled(cacheable=true)
    public static Object getShipmentReferences(string shipmentNo, string operator){
        operator = operator.toUpperCase();
        string strObjectName = 'GetReferences';
        string modulename = 'getReferenceFromGCSS';
        
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename);
        String urlParameterString = '';
        HttpRequest req = new HttpRequest();
        if(!String.isEmpty(shipmentNo)){
            urlParameterString = 'shipments/'+shipmentNo+'/references?';
            urlParameterString = AOServiceDetail.End_point_URL__c+urlParameterString+Label.GCSSParamString+operator;
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Consumer-Key',AOServiceDetail.Authorization_Key__c);
            req.setHeader('RequestId', string.valueOf(UserInfo.getUserId()+''+system.now()));
            req.setTimeout(Integer.valueof(AOServiceDetail.Timeout__c));
            req.setEndpoint(urlParameterString); 
            system.debug('****endpoint-->'+req);
        }
        system.debug('****urlParameterString '+urlParameterString);
        String res;
        try{  
            res = AO_APILoginUtility.sendRequest(req, AOServiceDetail);
            if(res.contains(Label.Token_Validation_Failed)){    
                Cache.Org.put('FRToken'+AOServiceDetail.Environment__c+AOServiceDetail.Authorization_Key__c,'',300);
                res = AO_APILoginUtility.sendRequest(req, AOServiceDetail);
            }else{
                system.debug('****res.getBody()-->'+res);
                return res;
            }
        } catch(Exception e){
            system.debug('****error:'+e.getMessage());
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'GetReferences.getShipmentReferences', new list<Exception>{e});
        }
        system.debug('****res.getBody()-->'+res);
        return res;
    }
    
    @AuraEnabled(cacheable=true)
    public static Object getContainerReferences(string shipmentNo, string equipmentId, string operator){
        operator = operator.toUpperCase();
        string strObjectName = 'GetReferences';
        string modulename = 'getReferenceFromGCSS';
        
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename);
        String urlParameterString = '';
        HttpRequest req = new HttpRequest();
        if(!String.isEmpty(shipmentNo)){
            urlParameterString = 'shipments/'+shipmentNo+'/equipment/'+equipmentId+'/references?';
            urlParameterString = AOServiceDetail.End_point_URL__c+urlParameterString+Label.GCSSParamString+operator;
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Consumer-Key',AOServiceDetail.Authorization_Key__c);
            req.setHeader('RequestId', string.valueOf(UserInfo.getUserId()+''+system.now()));
            req.setTimeout(Integer.valueof(AOServiceDetail.Timeout__c));
            req.setEndpoint(urlParameterString);
        }
        system.debug('****urlParameterString '+urlParameterString);
        String res;
        try{  
            res = AO_APILoginUtility.sendRequest(req, AOServiceDetail);
            if(res.contains(Label.Token_Validation_Failed)){    
                Cache.Org.put('FRToken'+AOServiceDetail.Environment__c+AOServiceDetail.Authorization_Key__c,'',300);
                res = AO_APILoginUtility.sendRequest(req, AOServiceDetail);
            }else{
                system.debug('****res.getBody()-->'+res);
                return res;
            }
        } catch(Exception e){
            system.debug('****error:'+e.getMessage());
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'GetReferences.getContainerReferences', new list<Exception>{e});
        }
        system.debug('****res.getBody()-->'+res);
        return res;
    }
    
}