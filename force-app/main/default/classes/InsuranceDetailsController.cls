/*
Description  : Perform callout to get Insurance  Details

* version       Date                Owner                                       Description
*******************************************************************************************************************
* V1.0          05/02/2020          sriram.kalluri@maersk.com                    Perform callout to get Insurance Details
*-------------------------------------------------------------------------------------------------------------------
*/
public with sharing class InsuranceDetailsController {
   @AuraEnabled(cacheable=true)
    public static object getInsuranceDetails( string shipmentno,string policyno, string operator){
        
             General_Key_Value_Configurations__mdt akamaiHeader = General_Key_Value_Configurations__mdt.getInstance('AkamaiRequestHeader');

            system.debug('shipmentno-->'+shipmentno);
            system.debug('policyno-->'+policyno);
            
             string strObjectName = 'InsuranceDetails';
             string modulename = 'getInsurance';
               
             AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename);  
             //Get the access token 
               string  accessToken = AO_APILoginUtility.getLoginIdToken(operator,AOServiceDetail);           

             if(accessToken != null || Test.isRunningTest()){               
                
                string paramstring = '';
                if(policyno != '' &&  policyno != null){
                  paramstring = 'policyId='+policyno.trim()+'&';
                }
                if(shipmentno != '' &&  shipmentno != null){
                   paramstring = paramstring+'shipmentNumber='+shipmentno.trim();
                }else{
                     paramstring = paramstring.removeEnd('&');
                }
                
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setHeader('Content-Type', 'application/json');
                //setting Authorization header with the access token
                req.setHeader('Authorization','Bearer '+accessToken);
                req.setHeader('Consumer-Key',AOServiceDetail.Authorization_Key__c);
                req.setHeader('x-requestor',akamaiHeader.First_Field_Value__c);//added new header as part of Token api issue resolution from akamai
                req.setTimeout(Integer.valueof(AOServiceDetail.Timeout__c));
                req.setEndpoint(AOServiceDetail.End_point_URL__c+'?carrierCode='+operator.toUpperCase()+'&'+paramstring); 
                system.debug('setEndpoint'+req.getEndpoint());
                http httpobj = new http();
                httpresponse res;
                try{
                    res = httpobj.send(req);
                    system.debug('response'+res.getBody());
                } catch(Exception e){
                    //throwing the exception message in case of any service exception
                    system.debug('error:'+e.getMessage());
                    throw new AuraHandledException(e.getMessage());
                }
                return res.getBody();

            }
            else{
                //Setting custom message if access token is not retrieved correctly.
                message msg = new message();
                msg.message = Label.AccessTokenFailed;
                return JSON.serialize( msg);
            }
            
        
    }
    public class message{
        @AuraEnabled public string message{get;set;}
    }
 
@AuraEnabled(cacheable=true)
  public static string getCommodityDetails( string commodityCode){
      list<Reference_Data__c> comData;
      if(commodityCode != null){
             comData =  [select Name,Commodity_Description__c  from Reference_Data__c where Name =:commodityCode]; 
            if(comData.size()>=1){
               return comData[0].Commodity_Description__c;
            }
      }    
     return null;

  }

   @AuraEnabled(cacheable=true)
    public static map<string,string> getLocationNames(list<string> locationCodes){
       system.debug('locationCodes-->'+locationCodes);
       map<string,string> geoCodeMap =  new  map<string,string>();
       list<Geography__c> GeoList = new  list<Geography__c>();
          if(!locationCodes.isEmpty()){   
            GeoList = [select id,GEO_Code__c,name from Geography__c where GEO_Code__c in:locationCodes and Active__c =true and Type_Of_Location__c='Country']; 
            for(Geography__c geo:GeoList){
                geoCodeMap.put(geo.GEO_Code__c,geo.name);
            }            
        }
         system.debug('geoCodeMap-->'+geoCodeMap);
        return geoCodeMap;

    }

}