/*
 * Author   : Ragu
 * Purpose  : Utility test class for creating Account related test data. 
 *
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-002633   06-May-2016 Ragu@UST                Created.
 * 
 */

@isTest
public class BDAGeographyData_Test {
    
    public static BDA__c regionNA, regionEU, regionFE, clusterNA, clusterUK, clusterEE, clusterGC, clusterDE, clusterCL;
    public static Geography__c countryUS, countryUK, countryRU, countryCH, countryIN, countryCanada, countryDE, citySterling, cityEdinburgh, cityFIPTerminal, cityBeijing, cityRugao, countryCL, citySantiago;
    
    public static list<BDA__c> lstBDAs;
    public static map<BDA__c, list<BDA__c>> mapBDAs;
    
    public static list<Geography__c> lstGeographies;
    public static map<Geography__c, list<Geography__c>> mapGeographies;
    
    public static list<BDA_Geography__c> lstBDAGeographies;
    
    static {
        // Create BDA - Trade Regions & Clusters
        regionNA = new BDA__c(Name = 'North America', GEO_ID__c = 'NA-Trade', Default_Account_Owner__c = UserInfo.getUserId(), Type__c = 'Trade Region');
        regionEU = new BDA__c(Name = 'Europe', GEO_ID__c = 'EU-Trade', Default_Account_Owner__c = UserInfo.getUserId(), Type__c = 'Trade Region');
        regionFE = new BDA__c(Name = 'Far East Asia', GEO_ID__c = 'FE-Trade', Default_Account_Owner__c = UserInfo.getUserId(), Type__c = 'Trade Region');
        
        clusterNA = new BDA__c(Name = 'North America Area', GEO_ID__c = '8EUQZ9N6BTEYY', Default_Account_Owner__c = UserInfo.getUserId(), Type__c = 'Cluster');
        clusterUK = new BDA__c(Name = 'United Kingdom and Ireland Area', GEO_ID__c = 'IRYKMQOSDQCBZ', Default_Account_Owner__c = UserInfo.getUserId(), Type__c = 'Cluster');
        clusterEE = new BDA__c(Name = 'Eastern Europe Area', GEO_ID__c = 'GG9TZSKXJCRZH', Default_Account_Owner__c = UserInfo.getUserId(), Type__c = 'Cluster');       
        clusterGC = new BDA__c(Name = 'Greater China Area', GEO_ID__c = 'G6LCTZURWSIZC', Default_Account_Owner__c = UserInfo.getUserId(), Type__c = 'Cluster');
        clusterDE = new BDA__c(Name = 'North Europe Continent Area', GEO_ID__c = 'FZHVV6WBH1RSL', Default_Account_Owner__c = UserInfo.getUserId(), Type__c = 'Cluster');
        clusterCL = new BDA__c(Name = 'West Coast South America Area', GEO_ID__c = '20090923000BO', Default_Account_Owner__c = UserInfo.getUserId(), Type__c = 'Cluster');

        
        lstBDAs = new list<BDA__c>{regionNA, regionEU, regionFE};
        insert lstBDAs;
        
        mapBDAs = new map<BDA__c, list<BDA__c>>();
        mapBDAs.put(regionNA, new list<BDA__c> {clusterNA, clusterCL});
        mapBDAs.put(regionEU, new list<BDA__c> {clusterUK, clusterEE, clusterDE});
        mapBDAs.put(regionFE, new list<BDA__c> {clusterGC});
        
        for(BDA__c bda : mapBDAs.keySet()) {
            for(BDA__c clusterBDA : mapBDAs.get(bda)) {
                clusterBDA.Parent_BDA__c = bda.Id;
                lstBDAs.add(clusterBDA);
                System.debug('clusterBDA: ' + clusterBDA);
            }
        }
        upsert lstBDAs;
        
        
        // Create Geography - Countries & Cities
        countryUS = new Geography__c(Name = 'United States', GEO_Code__c = 'US', GEO_ID__c = '3PUUQDPGC5PXA', Type_Of_Location__c = 'Country', Active__c = true);
        countryUK = new Geography__c(Name = 'United Kingdom', GEO_Code__c = 'UK', GEO_ID__c = '21X0YL36747LQ', Type_Of_Location__c = 'Country', Active__c = true);
        countryRU = new Geography__c(Name = 'Russia', GEO_Code__c = 'RU', GEO_ID__c = '2QA6J1CVO81OE', Type_Of_Location__c = 'Country', Active__c = true);
        countryCH = new Geography__c(Name = 'China', GEO_Code__c = 'CN', GEO_ID__c = '1HDVVRK6OM45A', Type_Of_Location__c = 'Country', Active__c = true);
        countryIN = new Geography__c(Name = 'India', GEO_Code__c = 'IN', GEO_ID__c = '10Z2W9Zkjh3q4a3', Type_Of_Location__c = 'Country', Active__c = true);
        countryCanada = new Geography__c(Name = 'Canada', GEO_Code__c = 'CA', GEO_ID__c = '3VBYA8HXO7KAM', Type_Of_Location__c = 'Country', Active__c = true);
        countryDE = new Geography__c(Name = 'Germany', GEO_Code__c = 'DE', GEO_ID__c = '1PLJ5T7MFKBJY', Type_Of_Location__c = 'Country', Active__c = true);
        countryCL = new Geography__c(Name = 'Chile', GEO_Code__c = 'CL', GEO_ID__c = '21NEJV0F2XSVY', Type_Of_Location__c = 'Country', Active__c = true);

        
        citySterling = new Geography__c(Name = 'Sterling', GEO_Code__c = 'USSEO', GEO_ID__c = '1DA7UHY4ENSLB', Type_Of_Location__c = 'City');
        cityEdinburgh = new Geography__c(Name = 'Edinburgh', GEO_Code__c = 'GBEDI', GEO_ID__c = '0KJFDUGMMEEF3', Type_Of_Location__c = 'City');
        cityFIPTerminal = new Geography__c(Name = 'Fish Port Terminal', GEO_Code__c = 'RUFIP', GEO_ID__c = '20OPJSXL3PRYB', Type_Of_Location__c = 'City');      
        cityBeijing = new Geography__c(Name = 'Beijing', GEO_Code__c = 'CNBEI', GEO_ID__c = '15COCIKDLLMKE', Type_Of_Location__c = 'City');
        citySantiago = new Geography__c(Name = 'Santiago', GEO_Code__c = 'CLSCL', GEO_ID__c = '3O808E7Q67GRD', Type_Of_Location__c = 'City');
        
        
        lstGeographies = new list<Geography__c>{countryUS, countryUK, countryRU, countryCH, countryCanada,countryDE,countryCL};
        database.insert(lstGeographies,false);
        
        mapGeographies = new map<Geography__c, list<Geography__c>>();
        mapGeographies.put(countryUS, new list<Geography__c> {citySterling});
        mapGeographies.put(countryUK, new list<Geography__c> {cityEdinburgh});
        mapGeographies.put(countryRU, new list<Geography__c> {cityFIPTerminal});
        mapGeographies.put(countryCH, new list<Geography__c> {cityBeijing});
        mapGeographies.put(countryCL, new list<Geography__c> {citySantiago});
        
        for(Geography__c geo : mapGeographies.keySet()) {
            for(Geography__c cityGeo : mapGeographies.get(geo)) {
                cityGeo.Parent_Geography__c = geo.Id;
                lstGeographies.add(cityGeo);
                System.debug('cityGeo: ' + cityGeo);
            }
        }
        database.upsert (lstGeographies,false);
        
        
        // Create BDA_Geography__c - association between Cluster and Country
        lstBDAGeographies = new list<BDA_Geography__c>();
        lstBDAGeographies.add(new BDA_Geography__c(BDA__c = clusterNA.Id, Geography__c = countryUS.Id));
        lstBDAGeographies.add(new BDA_Geography__c(BDA__c = clusterUK.Id, Geography__c = countryUK.Id));
        lstBDAGeographies.add(new BDA_Geography__c(BDA__c = clusterEE.Id, Geography__c = countryRU.Id));
        lstBDAGeographies.add(new BDA_Geography__c(BDA__c = clusterGC.Id, Geography__c = countryCH.Id));
        lstBDAGeographies.add(new BDA_Geography__c(BDA__c = clusterDE.Id, Geography__c = countryDE.Id));
        lstBDAGeographies.add(new BDA_Geography__c(BDA__c = clusterCL.Id, Geography__c = countryCL.Id));
        database.insert( lstBDAGeographies,false);
    }
    
}