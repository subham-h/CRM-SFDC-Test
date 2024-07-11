public inherited sharing class GeographyHelper {
    public static Map<String, BDA_Geography__c> mapBdaGeographyByCountryCode;
    public static Map<String, String> mapCountryCodeByGeographyId;
    
    public static Map<String, BDA_Geography__c> getBdaGeographyByCountryCode(Set<String> setCountryCode) {
        GeographyHelper.mapBdaGeographyByCountryCode = new Map<String, BDA_Geography__c>();
        GeographyHelper.mapCountryCodeByGeographyId = new Map<String, String>();
        for (BDA_Geography__c eachBdaGeo: [	SELECT Id
                                           , Geography__c
                                           , Geography__r.GEO_Code__c
                                           , BDA__c
                                           , BDA__r.Name
                                           , BDA__r.Parent_BDA__r.Name
                                           FROM BDA_Geography__c 
                                           WHERE BDA__r.Type__c ='Cluster' 
                                           AND Geography__r.Type_Of_Location__c ='Country' 
                                           AND Geography__r.Active__c = true 
                                           AND Geography__r.GEO_Code__c IN :setCountryCode ]){
                                               GeographyHelper.mapBdaGeographyByCountryCode.put(eachBdaGeo.Geography__r.GEO_Code__c, eachBdaGeo);
                                               GeographyHelper.mapCountryCodeByGeographyId.put(eachBdaGeo.Geography__c, eachBdaGeo.Geography__r.GEO_Code__c);
                                           }
        
        return GeographyHelper.mapBdaGeographyByCountryCode;
    }
    
    public static Map<String, BDA_Geography__c> getBdaGeographyByCountryCode() {
        GeographyHelper.mapBdaGeographyByCountryCode = new Map<String, BDA_Geography__c>();
        GeographyHelper.mapCountryCodeByGeographyId = new Map<String, String>();
        for (BDA_Geography__c eachBdaGeo: [	SELECT Id
                                           , Geography__c
                                           , Geography__r.GEO_Code__c
                                           , BDA__c
                                           , BDA__r.Name
                                           , BDA__r.Parent_BDA__r.Name
                                           FROM BDA_Geography__c 
                                           WHERE BDA__r.Type__c ='Cluster' 
                                           AND Geography__r.Active__c = true 
                                           AND Geography__r.Type_Of_Location__c ='Country' ]){
                                               GeographyHelper.mapBdaGeographyByCountryCode.put(eachBdaGeo.Geography__r.GEO_Code__c, eachBdaGeo);
                                               GeographyHelper.mapCountryCodeByGeographyId.put(eachBdaGeo.Geography__c, eachBdaGeo.Geography__r.GEO_Code__c);
                                           }
        
        return GeographyHelper.mapBdaGeographyByCountryCode;
    }
}