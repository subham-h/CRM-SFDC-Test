/*
Description  : Returns Geographie results 
* version     RQ        Date                Owner                                       Description
*******************************************************************************************************************
* V1.0      RQ-012390   26/10/2019          sriram.kalluri@maersk.com                  Returns Geographie results
*-------------------------------------------------------------------------------------------------------------------
*/
public with sharing class ServiceViewGetGeographies {
     @AuraEnabled(cacheable=true)
    public static object getGeographies(String searchString){
         list<Geography__c> GeoList = new  list<Geography__c>();
         String key = searchString+'%';
         GeoList = [select id,GEO_Code__c,Port_City__c,name,Type_Of_Location__c from Geography__c where ( Name LIKE:key) and Active__c = true and Type_Of_Location__c = 'City']; 
         return GeoList;
    }

     @AuraEnabled(cacheable=true)
public static map<string,string> getGeoCodes(list<string> geoids){
   system.debug('locationCodes-->'+geoids);
   map<string,string> geoCodeMap =  new  map<string,string>();
   list<Geography__c> GeoList = new  list<Geography__c>();
      if(!geoids.isEmpty()){   
        GeoList = [select id,GEO_ID__c,GEO_Code__c,name from Geography__c where GEO_ID__c in:geoids]; 
        for(Geography__c geo:GeoList){
            geoCodeMap.put(geo.GEO_ID__c,geo.GEO_Code__c);
        }            
    }
     system.debug('geoCodeMap-->'+geoCodeMap);
    return geoCodeMap;

}    
}