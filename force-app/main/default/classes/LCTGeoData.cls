public class LCTGeoData {
    
        public static void populateGeoData(list<LiveChatTranscript> lstNewlct, map<Id, LiveChatTranscript> mapOldlct, LiveChatTranscriptTriggerHandler lctTriggerHandler) {
        /*if(Generic_TriggerHandler.validateRunForMethod('LCTGeoData.populateGeoData()', 1)) {
            Boolean bInsert = lctTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT;
            bInsert = true;
            
            system.debug('Inside geo data');
           // populateGeoDataFromBDAGeography(lstNewlct, mapOldlct, bInsert, lctTriggerHandler.liveChatRecordSelector.mapLBDCs,LiveChatTranscriptRecordSelector.mapSCMKC, lctTriggerHandler);
            
            populateGeoDataFromAccount(lstNewlct, mapOldlct, bInsert, lctTriggerHandler.liveChatRecordSelector.mapRelatedAccounts, lctTriggerHandler.liveChatRecordSelector.mapRelatedContacts, lctTriggerHandler);
        }*/
            Boolean bInsert ;
            bInsert = true;
            
            system.debug('Inside geo data');
           // populateGeoDataFromBDAGeography(lstNewlct, mapOldlct, bInsert, lctTriggerHandler.liveChatRecordSelector.mapLBDCs,LiveChatTranscriptRecordSelector.mapSCMKC, lctTriggerHandler);
             
            //populateGeoDataFromAccount(lstNewlct, mapOldlct, bInsert, lctTriggerHandler.liveChatRecordSelector.mapRelatedAccounts, lctTriggerHandler.liveChatRecordSelector.mapRelatedContacts, lctTriggerHandler);
    }
    
       
    // #RQ-004653. Get the Account - City Id map based on the Account Billing City.
    private static map<Id, Id> getBillingCityMap(map<Id, Account> mapRelatedAccounts) {
        system.debug('inside billing city'+mapRelatedAccounts);
        set<Id> setCountryIds = new set<Id>();
        set<String> setBillingCities = new set<String>();
        map<String, list<Account>> mapBCAccounts = new map<String, list<Account>>();
        
        for(Account acc : mapRelatedAccounts.values()) {
            system.debug('Inside first for');
            if(acc.BillingCity != null) {
                setCountryIds.add(acc.Country__c);
                setBillingCities.add(acc.BillingCity);
                system.debug('setBillingCities setCountryIds'+setBillingCities+ setCountryIds);
                
                if(mapBCAccounts.containsKey(acc.BillingCity.toUpperCase())) {
                    mapBCAccounts.get(acc.BillingCity.toUpperCase()).add(acc);
                }
                else {
                    mapBCAccounts.put(acc.BillingCity.toUpperCase(), new list<Account> {acc});
                }
            }
            system.debug('mapBCAccounts setBillingCities'+mapBCAccounts+ setBillingCities);
        }
        
        map<Id, Id> mapAccIdCityId = new map<Id, Id>();
        if(!setBillingCities.isEmpty() && mapBCAccounts != null && !mapBCAccounts.isEmpty()) {
            system.debug('inside second if');
            for(Geography__c geoCity : [Select Id, Name, Parent_Geography__c, Parent_Geography__r.Parent_Geography__c from Geography__c 
                                        Where Name IN :setBillingCities and Type_Of_Location__c = 'City' and (Parent_Geography__c IN :setCountryIds or Parent_Geography__r.Parent_Geography__c IN :setCountryIds) order by Parent_Geography__c desc]) {
                                            system.debug('geo for');
                                            for(Account acc : mapBCAccounts.get(geoCity.Name.toUpperCase())) {
                                                system.debug('acc for');
                                                if(acc.Country__c == geoCity.Parent_Geography__c || acc.Country__c == geoCity.Parent_Geography__r.Parent_Geography__c) {
                                                    system.debug('inside third if');
                                                    mapAccIdCityId.put(acc.Id, geoCity.Id);
                                                }
                                            }
                                        }
        }
        return mapAccIdCityId;
    }
    
        // Method to set the Geo Data on LiveChatTranscript from Account (RQ-001552)
    private static void populateGeoDataFromAccount(list<LiveChatTranscript> lstNewlct, map<Id, LiveChatTranscript> mapOldlct, Boolean bInsert, map<Id, Account> mapRelatedAccounts,map<Id, Contact> mapRelatedContacts, LiveChatTranscriptTriggerHandler lctTriggerHandler) {
        try {
            system.debug('inside populate geo data');
            
            system.debug('mapRelatedContacts mapRelatedAccounts'+mapRelatedContacts +' '+mapRelatedAccounts);
            list<LiveChatTranscript> lstlctToValidate = new list<LiveChatTranscript>();
            map<Id, Id> mapAccIdCityId = getBillingCityMap(mapRelatedAccounts);
            system.debug('getbillingcitymap'+mapAccIdCityId);
            
            for(LiveChatTranscript newlct : lstNewlct) { 
                
                system.debug('test test'+newlct.test1__c);
                LiveChatTranscript oldlct;
                if(mapOldlct != null && !mapOldlct.isEmpty()) {
                    oldlct = mapOldlct.get(newlct.Id);
                }
                // RQ-007865 - Added condition to exclude the ISR cases on the Owner change
                
                 //system.debug('Populated from unexpected'+lctTriggerHandler.liveChatRecordSelectors.mapCaseIdOwnerId);
                    // String strLinerBrand = CaseUtilities.getLinerBrandLogic(newlct);
                    
                     // Condition to identify SCM Cases - SC-394
                     // SC-6042 for 4PL separate logic is written
                    if(newlct.Origin__c != null && newlct.Product__c != Label.SF_4PL && newlct.Product__c == Label.SCM && newlct.ContactId != null && newlct.Country__c == null) { 
                        Contact conInstance = mapRelatedContacts.get(newlct.ContactId);                        
                        if(conInstance != null && conInstance.Country__c != null) {                                                  
                            newlct.Country__c = conInstance.Country__c;                            
                            lstlctToValidate.add(newlct);
                        }
                    }
                    
                    // SC-394 - added Product__c to the condition for SCM Cases
                    // Regression issue for SCM BA - SCM Manual case country population is handled.
                    // SC-6042 for 4PL separate logic is written
                    if(newlct.AccountId != null && newlct.Product__c != Label.SF_4PL && newlct.Country__c == null && (newlct.Product__c != Label.SCM ||(newlct.Origin__c == null && newlct.Product__c == Label.SCM))) { // RQ-001510
                        system.debug('Inside final if');
                        Account accInstance = mapRelatedAccounts.get(newlct.AccountId);
                        if(accInstance != null && accInstance.Country__c != null) {
                            if(newlct.City__c == null || (!bInsert && oldlct.City__c == newlct.City__c)) { // RQ-005373
                                // RQ-004653 - Case City is populated from Account Billing City
                                newlct.City__c = mapAccIdCityId.get(accInstance.Id);
                            }
                            // RQ-005373
                            system.debug('country is populated here'+accInstance.Country__c);
                            newlct.Country__c = accInstance.Country__c;
                            
                            lstlctToValidate.add(newlct);
                        }
                    }
                
              // SC-6042 for 4PL cases, populate case's country from contact same like account BAs
                if(newlct.Product__c == Label.SF_4PL  && newlct.ContactId != null && newlct.Country__c == null) {
                    system.debug('Not goining inside this');
                    Contact conInstance = mapRelatedContacts.get(newlct.ContactId);                        
                    if(conInstance != null && conInstance.Country__c != null) {                                                  
                        newlct.Country__c = conInstance.Country__c;                            
                        lstlctToValidate.add(newlct);
                    }
                }  
            }
            
            
            
            // RQ-001535 : Validate populated Geo Data
            if(!lstlctToValidate.isEmpty()) {
                system.debug('validating');
                //commmented by meghna-check before update logic required or not?
                //caseRecordSelector.blnCountryChange=true;
                validateGeoData(lstlctToValidate);
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'LiveChatTranscript', 'LCTGeoData.populateGeoDataFromAccount', new list<Exception>{ex}); // #RQ-005636 
        }
    }
    
    public static void validateGeoData(list<LiveChatTranscript> lstlct) {
        set<Id> setCountryIds = new set<Id>();
        set<Id> setClusterIds = new set<Id>();
        for(LiveChatTranscript newlct : lstlct) {
            if(newlct.Country__c != null) {
                setCountryIds.add(newlct.Country__c);
            }
            if(newlct.Cluster__c != null) {
                setClusterIds.add(newlct.Cluster__c);
            }
        }
        
        // Querying Country Records
        set<String> setGeoCodes = new set<String>();
        map<String, String> mapGeoCodeId = new map<String, String>();
        map<String, String> mapGeoIdCode = new map<String, String>();
        for(Geography__c countryGeo : CaseTrigger_DataSetUtilities.getAllCountrylist()) {
            mapGeoCodeId.put(countryGeo.GEO_ID__c, countryGeo.Id);
            mapGeoIdCode.put(countryGeo.Id, countryGeo.GEO_ID__c);
            setGeoCodes.add(countryGeo.GEO_ID__c);
        }
        
        // Querying Cluster Records
        map<String, String> mapClusterIdCode = new map<String, String>();
        map<String, String> mapClusterIdParentBDA = new map<String, String>();
        for(BDA__c clusterBDA : CaseTrigger_DataSetUtilities.getBDAList()) {
            if(clusterBDA.Type__c == 'Cluster') {
                mapClusterIdCode.put(clusterBDA.Id, clusterBDA.GEO_ID__c);            //#RQ-004639 - Updated BDA_Code__c with GEO_ID__c
                mapClusterIdParentBDA.put(clusterBDA.Id, clusterBDA.Parent_BDA__c);
                setGeoCodes.add(clusterBDA.GEO_ID__c);    //#RQ-004639 - Updated BDA_Code__c with GEO_ID__c
            }
        }
        // system.debug('setClusterIds#'+setClusterIds);
        // system.debug('setCountryIds#'+setCountryIds);
        list<BDA_Geography__c> lstBDAGeographies = CaseTrigger_DataSetUtilities.getCountryClusterGeoList(setClusterIds, setCountryIds);
        
        // Scenario 1: Country != null but Cluster = null
        // System.debug('lstBDAGeographies ' + lstBDAGeographies);
        map<Id, set<BDA_Geography__c>> mapGeoIdBDAGeos = new map<Id, set<BDA_Geography__c>>();
        for(BDA_Geography__c bdaGeo :lstBDAGeographies ) {
            // RQ-002309 - Added check for Active Clusters.
            if(setCountryIds.contains(bdaGeo.Geography__c) && bdaGeo.Geography__r.Type_Of_Location__c == 'Country' && bdaGeo.BDA__r.Type__c == 'Cluster' && bdaGeo.BDA__r.Active__c == true) {
                if(mapGeoIdBDAGeos.containsKey(bdaGeo.Geography__c)) {
                    mapGeoIdBDAGeos.get(bdaGeo.Geography__c).add(bdaGeo);
                } 
                else {
                    mapGeoIdBDAGeos.put(bdaGeo.Geography__c, new set<BDA_Geography__c> {bdaGeo});
                }
            }
        }
        
        // Scenario 2: Country = null but Cluster != null
        map<Id, set<BDA_Geography__c >> mapBDAIdBDAGeos = new map<Id, set<BDA_Geography__c >>();
        for(BDA_Geography__c bdaGeo : lstBDAGeographies) {
            if(setClusterIds.contains(bdaGeo.BDA__c) && bdaGeo.BDA__r.Type__c == 'Cluster' && bdaGeo.Geography__r.Type_Of_Location__c == 'Country') {
                if(mapBDAIdBDAGeos.containsKey(bdaGeo.BDA__c)) {
                    mapBDAIdBDAGeos.get(bdaGeo.BDA__c).add(bdaGeo);
                }
                else {
                    mapBDAIdBDAGeos.put(bdaGeo.BDA__c, new set<BDA_Geography__c>{bdaGeo});
                }
            }
        }
        
        // Sherin
        // Scenario 2(b): Specifically for China Cluster - China Country mapping 
        /****THIS CAN BE REMOVED IN FUTURE AS CHINA NOW FOLLOWS CLOUNTRY - CLUSTER STRUCTURE SAME AS OTHER COUNTRIES****/
        Map<string,LinerBrand_Direction_and_Country__mdt> metadataList = CaseTrigger_DataSetUtilities.getAllCustomMetadataList();
        map<String, String> geoIdMap = new map<String, String>();
        map<String, set<String>> mapCountryCodeClusters = new map<String, set<String>>(); // Map to store cluster code values against a single country code value found in Clusters_Country_Code columnn
        for(LinerBrand_Direction_and_Country__mdt bhSetting : metadataList.values()) {
            if((setGeoCodes.contains(bhSetting.Cluster__c) || setGeoCodes.contains(bhSetting.Country__c)) && bhSetting.Cluster__c != null) {
                if(mapCountryCodeClusters.containsKey(bhSetting.Country__c)) {
                    geoIdMap.put(bhSetting.Cluster__c, bhSetting.Country__c);
                    mapCountryCodeClusters.get(bhSetting.Country__c).add(bhSetting.Cluster__c);
                } 
                else {
                    geoIdMap.put(bhSetting.Cluster__c, bhSetting.Country__c);
                    mapCountryCodeClusters.put(bhSetting.Country__c, new set<String> {bhSetting.Cluster__c});
                }
            }
        }
        
        // Scenario 3: Country and Cluster != null  
        map<Id, map<Id, Id>> ccGeoMap = new map<Id, map<Id, Id>>();
        for(BDA_Geography__c ccGeo: lstBDAGeographies) {
            if(setClusterIds.contains(ccGeo.BDA__c) && setCountryIds.contains(ccGeo.Geography__c)) {
                ccGeoMap.put(ccGeo.Geography__c, new map<Id, Id> {ccGeo.BDA__c => ccGeo.Id});
            }
        }
        
        for(LiveChatTranscript newlct: lstlct) {
            Id country;
            // Id cluster; 
            Id region;
            Id bdaGeo;
            String countryCode;
            String clusterCode;
            set<BDA_Geography__c> bdaGeoSet;
            // system.debug('newlct.Country__c '+newlct.Country__c );
            // system.debug('newlct.Country__c '+newlct.Cluster__c );
            // SCENARIO 1 --> Country != null BUT Cluster == null
            if(newlct.Country__c != null && newlct.Cluster__c == null) {
                // System.debug('mapGeoIdBDAGeos' + mapGeoIdBDAGeos);
                system.debug('inside scenario 1');
                bdaGeoSet = mapGeoIdBDAGeos.get(newlct.Country__c);
                if(bdaGeoSet == null) {
                    countryCode = mapGeoIdCode.get(newlct.Country__c);
                    
                    if(countryCode != null) {
                        // System.debug('mapCountryCodeClusters###' + mapCountryCodeClusters);
                        // System.debug('mapCountryCodeClusters###' + mapCountryCodeClusters.get(countryCode));
                        set<String> clusterCountrySet = mapCountryCodeClusters.get(countryCode);
                        
                        if(clusterCountrySet != null && !Validation_Rules_Bypass__c.getinstance(Userinfo.getuserId()).Active__c) {
                            if(clusterCountrySet.size()> 0 && clusterCountrySet.size() != 1) {
                                newlct.addError(Label.GeoErrorMessage1);
                            }
                        }
                        else if(!Validation_Rules_Bypass__c.getinstance(Userinfo.getuserId()).Active__c) {
                            newlct.addError(Label.GeoErrorMessage2);
                        }
                    }
                }
                else if(bdaGeoSet.size() > 1 && !Validation_Rules_Bypass__c.getinstance(Userinfo.getuserId()).Active__c) {
                    newlct.addError(Label.GeoErrorMessage1);
                }
                else if(bdaGeoSet.size() == 1) {
                    for(BDA_Geography__c geo : bdaGeoSet) {
                        newlct.Cluster__c = geo.BDA__c;
                        newlct.Region__c = geo.BDA__r.Parent_BDA__c;
                    }
                    // system.debug('newlct#'+newlct);
                }
            }
            // SCENARIO 2 --> Cluster != null BUT Country == null
            else if(newlct.Country__c == null && newlct.Cluster__c != null) {
                system.debug('inside scenario 2');
                clusterCode = mapClusterIdCode.get(newlct.Cluster__c);
                if(clusterCode != null) {
                    countryCode = geoIdMap.get(clusterCode);
                }
                if(countryCode != null) {
                    country = mapGeoCodeId.get(countryCode);
                    if(country != null) {
                        newlct.Country__c = country;
                    }
                    region = mapClusterIdParentBDA.get(newlct.Cluster__c);
                    if(region != null) {
                        newlct.Region__c = region;
                    }
                } 
                else {
                    bdaGeoSet = mapBDAIdBDAGeos.get(newlct.Cluster__c);
                    // system.debug('bdaGeoSet #'+bdaGeoSet );
                    if(bdaGeoSet != null) {
                        if(bdaGeoSet.size() > 1 && !Validation_Rules_Bypass__c.getinstance(Userinfo.getuserId()).Active__c) {
                            newlct.addError(Label.GeoErrorMessage3);
                        }
                        if(bdaGeoSet.size() == 1) {
                            for(BDA_Geography__c geo: bdaGeoSet) {
                                newlct.Country__c = geo.Geography__c;
                                newlct.Region__c = geo.BDA__r.Parent_BDA__c;
                            }
                        }
                    } 
                    else if(!Validation_Rules_Bypass__c.getinstance(Userinfo.getuserId()).Active__c) {
                        newlct.addError(Label.GeoErrorMessage4);
                    }
                }
            }
            // SCENARIO 3 --> Cluster != null AND Country != null
            else if(newlct.Country__c != null && newlct.Cluster__c != null) {
                system.debug('inside scenario 3');
                if(ccGeoMap.get(newlct.Country__c) != null) {
                    bdaGeo = ccGeoMap.get(newlct.Country__c).get(newlct.Cluster__c);
                }
                if(bdaGeo == null) {
                    clusterCode = mapClusterIdCode.get(newlct.Cluster__c);
                    if(clusterCode != null) {
                        countryCode = geoIdMap.get(clusterCode);
                    }
                    if(countryCode != null) {
                        country = mapGeoCodeId.get(countryCode);
                    }
                    // if(country != newlct.Country__c && !Validation_Rules_Bypass__c.getinstance(Userinfo.getuserId()).Active__c) {
                        //newlct.addError(Label.GeoErrorMessage5);
                    // }
                    else {
                        region = mapClusterIdParentBDA.get(newlct.Cluster__c);
                        if(region != null) {
                            newlct.Region__c = region;
                        }
                    }
                } 
                else {
                    region = mapClusterIdParentBDA.get(newlct.Cluster__c);
                    if(region != null) {
                        newlct.Region__c = region;
                    }
                }
            }
        }
    }
}