/*
* Interface class referred by two triggers : CaseTrigger and CareTrigger to validate Geo Data (Cluster and Country level)
* mentioned on the respective records during insert and update operations.
* 
*Version    Date            Owner                                               RQ#                 Description
*********************************************************************************************************************************  
* 1.0        6/19/2015       Vivek Menon                                        Code created
* 2.0        07/09/2015      Sherin.jose@accenture.com                         #RQ-001771-Changes made for US Flag BA Addresses                                                                                      (RQ-001535)
* 3.0        21/09/2015      prashanth.ds@accenture.com                        #RQ-001774-Utility method to Get Custtom Setting Value based on Case Origin
* 4.0        23/09/2015      Sherin.jose@accenture.com                         #RQ-001772-Changes made for Sealand BA Addresses
* 5.0        22/10/2015      Ranjini.Janardhanan@ust-global.com                #RQ-002062-Added validation bypass for all the validations.
* 6.0        23/03/2016      Ranjini.Janardhanan@ust-global.com                #RQ-001773 - Updated getLinerBrandLogic method to include Seago.
*/


public class GeoDataUtility
{

  public static void validateGeoData(List<Case> caseList, List<Care_Relationship__c> careList)
  {
    Set<String> countryIds = new Set<String>();   
    Set<String> clusterIds = new Set<String>();
    Set<String> geoIds     = new Set<String>();
    
    if(careList != null)
    {
      for(Care_Relationship__c care : careList)
       {
         if(care.Country__c != null)
          countryIds.add(care.Country__c);
         if(care.Cluster__c != null)
          clusterIds.add(care.Cluster__c);
       }
    }
      
    //Querying Country Records
    List<Geography__c> countryList = [SELECT Id, GEO_ID__c FROM Geography__c WHERE 
                                      Type_Of_Location__c = 'Country'];
    system.debug('COUNTRY FOUND IS ------------->' + countryList);
    Map<String, String> countryMapping = new Map<String, String>(); 
    Map<String, String> countryCodeMapping = new Map<String, String>();
    for(Geography__c country : countryList){
       countryMapping.put(country.GEO_ID__c, country.Id);
       countryCodeMapping.put(country.Id, country.GEO_ID__c);
       //countrySet.add(country.Id);
       geoIds.add(country.GEO_ID__c);
    }
    
    //Querying Cluster Records
    List<BDA__c> clusterList = [SELECT Id, Parent_BDA__c, GEO_ID__c, Type__c FROM BDA__c WHERE Id IN :clusterIds
                                AND Type__c = 'Cluster'
                                ];
    Map<String, String> clusterMapping = new Map<String, String>();
    Map<String, String> clusterRegionMapping = new Map<String, String>();
    for(BDA__c cluster : clusterList){
        clusterMapping.put(cluster.Id, cluster.GEO_ID__c);
        clusterRegionMapping.put(cluster.Id, cluster.Parent_BDA__c);
        geoIds.add(cluster.GEO_ID__c);
    }
        
            
    //scenario 1 : country != null but cluster = null
    List<BDA_Geography__c> countryGeoList = [SELECT Geography__c, BDA__c, BDA__r.Parent_BDA__c                
                                             FROM BDA_Geography__c WHERE Geography__c IN :countryIds
                                             AND BDA__r.Type__c = 'Cluster' AND Geography__r.Type_Of_Location__c = 'Country'];
    Map<Id, Set<BDA_Geography__c>> countryGeoMap = new Map<Id, Set<BDA_Geography__c>>();
    for(BDA_Geography__c coGeo : countryGeoList){
        countryGeoMap.put(coGeo.Geography__c, new Set<BDA_Geography__c>{coGeo});
    }
    for(BDA_Geography__c coGeo : countryGeoList){
        if(countryGeoMap.containsKey(coGeo.Geography__c))
           countryGeoMap.get(coGeo.Geography__c).add(coGeo);
    }
    
    //scenario 2 : country = null but cluster != null
    List<BDA_Geography__c> clusterGeoList = [SELECT Geography__c, BDA__c, BDA__r.Parent_BDA__c                
                                             FROM BDA_Geography__c WHERE BDA__c IN :clusterIds
                                             AND BDA__r.Type__c = 'Cluster' AND Geography__r.Type_Of_Location__c = 'Country'
                                             ];                                     
    Map<Id, Set<BDA_Geography__c>> clusterGeoMap = new Map<Id, Set<BDA_Geography__c>>();
    for(BDA_Geography__c clGeo : clusterGeoList){
        clusterGeoMap.put(clGeo.BDA__c, new Set<BDA_Geography__c>{clGeo});
    }
    for(BDA_Geography__c clGeo : clusterGeoList){
        if(clusterGeoMap.containsKey(clGeo.BDA__c))
           clusterGeoMap.get(clGeo.BDA__c).add(clGeo);
    }  
    
    //scenario 2(b) : Specifically for China Cluster - China Country mapping
    List<CM_Geo_Data__c> bhSettingsList = [SELECT External_Geo_Code__c, Clusters_Country_Code__c FROM CM_Geo_Data__c WHERE (External_Geo_Code__c IN :geoIds OR Clusters_Country_Code__c IN :geoIds) AND 
                                          Clusters_Country_Code__c != null];
    //system.debug('SETTINGS FOUND--------------------------->' +businessHoursSettingsList); 
    Map<String, String> geoIdMap = new Map<String, String>();
    Map<String, Set<String>> clusterCountryCodeMap = new Map<String, Set<String>>(); //Map to store cluster code values against a single country code value found in Clusters_Country_Code columnn
    for(CM_Geo_Data__c bhSetting : bhSettingsList){
        geoIdMap.put(bhSetting.External_Geo_Code__c, bhSetting.Clusters_Country_Code__c);
        clusterCountryCodeMap.put(bhSetting.Clusters_Country_Code__c, new Set<String>{bhSetting.External_Geo_Code__c});        
    }
    for(CM_Geo_Data__c bhSetting : bhSettingsList){
       if(clusterCountryCodeMap.containsKey(bhSetting.Clusters_Country_Code__c))
         clusterCountryCodeMap.get(bhSetting.Clusters_Country_Code__c).add(bhSetting.External_Geo_Code__c);
    }
    
  
    //scenario 3 : country and cluster != null  
    List<BDA_Geography__c> countryClusterGeoList = [SELECT Id, Geography__c, BDA__c, BDA__r.Parent_BDA__c                
                                             FROM BDA_Geography__c WHERE BDA__c IN :clusterIds AND Geography__c IN :countryIds
                                             AND BDA__r.Type__c = 'Cluster' AND Geography__r.Type_Of_Location__c = 'Country'
                                             ];                                                                                  
    Map<Id, Map<Id, Id>> ccGeoMap = new Map<Id, Map<Id, Id>>();
    for(BDA_Geography__c ccGeo : countryClusterGeoList){
       ccGeoMap.put(ccGeo.Geography__c, new Map<Id, Id>{ccGeo.BDA__c => ccGeo.Id});
    }
    
    if(careList != null)
    {
      for(Care_Relationship__c care : careList)
      {
        Id Country, Cluster, Region, bdaGeo;  
        String clusterCode, countryCode;
        Set<BDA_Geography__c> bdaGeoSet;
        Set<String> clusterCountrySet;
        
          //SCENARIO 1 --> Country != null BUT Cluster == null)
          if(care.Country__c != null && care.Cluster__c == null){
              bdaGeoSet = countryGeoMap.get(care.Country__c);
              if(bdaGeoSet == null){
                    system.debug('HEY BDAGEOSET IS NULL');
                    countryCode = countryCodeMapping.get(care.Country__c);
                    system.debug('COUNTRY CODE IN SCENARIO 1 IS ------>' + countryCode);
                    if(countryCode != null){
                         clusterCountrySet = clusterCountryCodeMap.get(countryCode);
                         system.debug('CLUSTER COUNTRY SET IS ------->' + clusterCountrySet);
                         
                         //#RQ-002062. Added validation bypass condition.
                         if(clusterCountrySet != null && !Validation_Rules_Bypass__c.getinstance(Userinfo.getuserId()).Active__c){
                              if(clusterCountrySet.size() > 0 && clusterCountrySet.size() != 1)
                                    care.addError(Label.GeoErrorMessage1);
                         }
                         //#RQ-002062. Added validation bypass condition. 
                         else if(!Validation_Rules_Bypass__c.getinstance(Userinfo.getuserId()).Active__c)
                                care.addError(Label.GeoErrorMessage2);
                    }
              }   
              
              //#RQ-002062. Added validation bypass condition.
              else if(bdaGeoSet.size() > 1 && !Validation_Rules_Bypass__c.getinstance(Userinfo.getuserId()).Active__c)
                    care.addError(Label.GeoErrorMessage1);
              else if(bdaGeoSet.size() == 1){
                    for(BDA_Geography__c  geo : bdaGeoSet){     
                      care.Cluster__c = geo.BDA__c;
                      care.Region__c = geo.BDA__r.Parent_BDA__c;
                    }
              }
        }
        
        
        //      SCENARIO 2 --> Cluster != null AND Country != null)
        else if(care.Country__c != null && care.Cluster__c != null){
            
               if(ccGeoMap.get(care.Country__c) != null)
                    bdaGeo = ccGeoMap.get(care.Country__c).get(care.Cluster__c);
            
               if(bdaGeo == null){
                    clusterCode = clusterMapping.get(care.Cluster__c);     
                    system.debug('CLUSTER CODE FOUND IS ----------------->' + clusterCode);
                    if(clusterCode != null)
                        countryCode = geoIdMap.get(clusterCode);
                    system.debug('COUNTRY CODE FOUND IS ----------------->' + countryCode);
                    if(countryCode != null)  
                        country = countryMapping.get(countryCode);
                    system.debug('COUNTRY FOUND IS ----------------->' + country);
                   
                    //#RQ-002062. Added validation bypass condition.
                    if(country != care.Country__c && !Validation_Rules_Bypass__c.getinstance(Userinfo.getuserId()).Active__c)
                        care.addError(Label.GeoErrorMessage5);
                    else{
                       system.debug('HELLOO!!!!!!');
                       Region = clusterRegionMapping.get(care.Cluster__c);
                       if(Region != null)
                       care.Region__c =  Region;              
                      }  
               }
               else{
                   Region = clusterRegionMapping.get(care.Cluster__c);
                   if(Region != null)
                   care.Region__c =  Region; 
               }
        }
        
             
      }
    }
    
  
  }
}