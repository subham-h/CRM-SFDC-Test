/**
 * Description  : Perform callout to get ShipmentParties
 * 
 * Version       Ref Number    Date                Owner                                  Description
 *******************************************************************************************************************
 * v1.0          SC-1300       24/08/2021          shahanawaz@maersk.com                  Perform callout to get ShipmentParties
 * v2.0          SC-1300       06/10/2021          Richa@maersk.com                       Modified the party endpoint as Composite API cannot be used
 * v3.0          SC-5243       07/16/2022          sunil.bs@maersk.com                    Made call to omni Method to route case even on callout error
 * v4.0          SPI-100       09/06/2022          Ronnie@SF                              Removed brand hardcoding
 *-------------------------------------------------------------------------------------------------------------------
 */
public with sharing class ShipmentParty {
    
    public static String getShipmentParty(string shipmentNo, string brand){
        String operator = BrandUtilities.getBrandOperatorCode(brand);
        operator = operator.toUpperCase();
        string strObjectName = 'ShipmentParty';
        string modulename = 'getShipmentParty';
        
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename); 
        string urlParameterString = AOServiceDetail.End_point_URL__c;       
        if(shipmentNo != '' &&  shipmentNo != null){
            urlParameterString += 'shipments/'+shipmentNo+'/parties?carrier='+operator;
        }
        system.debug('****urlParameterString-->'+urlParameterString);
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');        
        req.setHeader('content-type', 'application/json');
        req.setHeader('Consumer-Key', AOServiceDetail.Authorization_Key__c);
        req.setHeader('RequestId', string.valueOf(UserInfo.getUserId()+''+system.now()));
        req.setTimeout(Integer.valueof(AOServiceDetail.Timeout__c));
        req.setEndpoint(urlParameterString);
        string res;
        try{  
            res = AO_APILoginUtility.sendRequest(req,AOServiceDetail);
            if(res.contains(Label.Token_Validation_Failed)){    
                Cache.Org.put('FRToken'+AOServiceDetail.Environment__c+AOServiceDetail.Authorization_Key__c,'',300);
                res = AO_APILoginUtility.sendRequest(req,AOServiceDetail);
            }else{
                System.debug('****res- '+res);
               return res;
            }
            
        } catch(Exception e){
            system.debug('error:'+e.getMessage());
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.updateOnBehalfofAccountOnCase', new list<Exception>{e});
        }
        System.debug('res.getBody() '+res);
        return res;
    }    
}