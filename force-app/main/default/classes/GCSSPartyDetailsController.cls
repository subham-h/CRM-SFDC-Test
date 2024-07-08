/*
Description  : Perform callout to get GCSS party  

* version    Ref Number     Date               Owner                              Description
*******************************************************************************************************************
* 1.0        SC-2784        28/07/2021         Richa@maersk.com                    Perform callout to get GCSS Party Details at Shipment level
* 2.0        SC-4737        23/08/2022         Thippeswamy@UST.com                 Perform callout to get GCSS party Details based on TpDocNumber
*-------------------------------------------------------------------------------------------------------------------
*/
public with sharing class GCSSPartyDetailsController {
    @AuraEnabled(cacheable=true)
    public static object getGCSSPartyDetails(String shipmentNumber,String scvCode, String operator){
        String strObjectName = 'PartyDetails';
        String modulename = 'getPartyDetails';
        AO_Services__mdt aoServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename);        
        operator = operator.toUpperCase();
        
        String Endpoint =aoServiceDetail.End_point_URL__c+'shipments/'+shipmentNumber+'/verifyCustomerRole/'+scvCode+'?carrier='+operator;
        System.debug('***Endpoint---> '+Endpoint);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');        
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Consumer-Key', aoServiceDetail.Authorization_Key__c);       
        req.setTimeout(Integer.valueof(aoServiceDetail.Timeout__c));
        req.setEndpoint(Endpoint);               
        String res;
        try{  
            res = AO_APILoginUtility.sendRequest(req,aoServiceDetail);
            System.debug('***res'+res); 
            if(res.contains(Label.Token_Validation_Failed)){    
                Cache.Org.put('FRToken'+aoServiceDetail.Environment__c+aoServiceDetail.Authorization_Key__c,'',300);
                res = AO_APILoginUtility.sendRequest(req,aoServiceDetail);
            }
            
        } catch(Exception ex){
            System.debug('***exception error'+ex.getMessage()+'**'+ex.getLineNumber());           
        }
        System.debug('res.getBody() '+res);
        return res;
    } 
    /*
    Get the customer details based on TpDoc number
    SC-4737
    */
    public static object getGCSSPartyDetailsFortpDoc(String tpDocNumber,String scvCode, String operator){
        String strObjectName = 'PartyRole';
        String modulename = 'getPartyRole';
        AO_Services__mdt aoServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename);        
        operator = operator.toUpperCase();
        
        String Endpoint =aoServiceDetail.End_point_URL__c+'tpDocs/'+tpDocNumber+'/verifyCustomerRole/'+scvCode+'?carrier='+operator;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');        
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Consumer-Key', aoServiceDetail.Authorization_Key__c);       
        req.setTimeout(Integer.valueof(aoServiceDetail.Timeout__c));
        req.setEndpoint(Endpoint);               
        String res;
        try{  
            res = AO_APILoginUtility.sendRequest(req,aoServiceDetail);
            if(res.contains(Label.Token_Validation_Failed)){    
                Cache.Org.put('FRToken'+aoServiceDetail.Environment__c+aoServiceDetail.Authorization_Key__c,'',300);
                res = AO_APILoginUtility.sendRequest(req,aoServiceDetail);
            }
            
        } catch(Exception ex){
            System.debug('***exception error'+ex.getMessage()+'**'+ex.getLineNumber());           
        }
        return res;
    }
    
}