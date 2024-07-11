/*
* Author   : Sriram@Maersk
* Purpose  : Class for checking the Equipment Availability
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-010517   10-July-2019  Sriram@Maersk          performs callout to check the availabilty of Equipment
* 2.0	   RQ-012391   18-11-2019    Sreya@Maersk		    Made the getEquipmentAvailability service input parameters to uppercase.
* 3.0      SC-71	   21-09-2019	 Naved@Maersk			Change Api from Soap to Rest ,Also include Group alloction field in response.	
*/

public  class EquipmentAvailabilityManagement {
   // Handling the web service callout to check the availabilty of Equipment
@AuraEnabled(continuation=true cacheable=true)
public static Object getEquipmentAvailability(string size,string type,string height,string operator,string Receipt,string owner,string count,string pickUpDate){
    General_Key_Value_Configurations__mdt akamaiHeader = General_Key_Value_Configurations__mdt.getInstance('AkamaiRequestHeader');
    string strObjectName = 'Case';
    string strModuleName = 'SFDC.GetEquipmentAvailability.REQUEST';
    if(owner.length()>=10 ){
         owner = owner.substring(0,10);
    }   
    // Getting the Endpoint and Security details from ESB Service metadata.
    ESB_Webservice__mdt esbServiceDetail = WebserviceUtilities.getESBShipmentMetadataValue(strObjectName,strModuleName);
    String strXMLRequest ='{ "getEquipmentAvailabilityManagementRequest" : { "priceOwner" : "'+owner+' ", "por" : "'+Receipt.toUpperCase()+'", "pickUpDate" : "'+pickUpDate+'", "operators" : { "operator" : "'+operator+'"},"equipments" : {"equipment" : {"equipmentSize" : "'+size+'","equipmentType" : "'+type.toUpperCase()+'","equipmentHeight" : "'+height+'","equipmentCount" : "'+count+'"}},	"receiptMode" : "CY"}}';
    HttpRequest req = new HttpRequest();
    req.setMethod('POST');
    Blob headerValue = Blob.valueOf(esbServiceDetail.OSB_Username__c + ':' + esbServiceDetail.Password__c);
    system.debug('EncodingUtil.base64Encode(headerValue)'+EncodingUtil.base64Encode(headerValue));
    String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);  
    req.setHeader('Authorization', authorizationHeader);  
    req.setHeader('content-type', 'application/json');
    req.setHeader('x-requestor',akamaiHeader.First_Field_Value__c);//added new header as part of Token api issue resolution from akamai
    req.setBody(strXMLRequest);  
    req.setTimeout(Integer.valueof(esbServiceDetail.Timeout__c));
    req.setEndpoint(esbServiceDetail.End_point_URL__c);
    // Creating continuation object for making the callout.
    Continuation con = new Continuation(120);
    con.state = con.addHttpRequest(req);
    con.continuationMethod='processEquipmentAvailabilityReq';
    system.debug('con---->'+con);
    return con;
}

@AuraEnabled(cacheable=true)
public static Object processEquipmentAvailabilityReq(Object state) {
    //getting the service response for getEquipmentAvailability service.
    HttpResponse response = Continuation.getResponse((String)state); 
    system.debug('response------>'+response.getBody());
    return response.getBody();
    
}

 @AuraEnabled(cacheable=true)
public static map<string,string> getLocationNames(list<string> locationCodes){
   system.debug('locationCodes-->'+locationCodes);
   map<string,string> geoCodeMap =  new  map<string,string>();
   list<Geography__c> GeoList = new  list<Geography__c>();
      if(!locationCodes.isEmpty()){   
        GeoList = [select id,GEO_Code__c,name from Geography__c where GEO_Code__c in:locationCodes]; 
        for(Geography__c geo:GeoList){
            geoCodeMap.put(geo.GEO_Code__c,geo.name);
        }            
    }
     system.debug('geoCodeMap-->'+geoCodeMap);
    return geoCodeMap;

}

}