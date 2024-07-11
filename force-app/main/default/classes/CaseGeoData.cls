/** 
@description
* Author   : Ragu
* Purpose  : Utility class to hold simple and reusable functionalities related to Case Geo Data. 
*        
* Revision Ref Number  Date         Owner                                   Description
* -------- ----------  -----------  -------------------                     -----------
* 1.0      RQ-002633   22-Feb-2016  Ragu@UST                                Created for implementing CBO (Centralized By Org) trigger architecture.
* 2.0      RQ-002811   14-July-2016 Ranjini@UST                             Updated the method 'populateGeoDataFromAccount' for populating country for FSCM dispute cases while creation.
* 3.0      RQ-004653   16-Mar-2017  Ranjini@UST                             Updated the city population logic from Account. Now Case City will be populated from Account.BillingCity.
* 4.0      RQ-004639   05-Apr-2017  Govindaraj.sundaram@ust-global.com      Updated BDA_Code__c with GEO_ID__c
* 5.0      RQ-005373   22-May-2017  Ragu@UST                                Populate the City and Country when user change the Contact and blank out the Country. 
* 6.0      RQ-005636   25-Sep-2017  Nisha@UST                               Update references of GlobalErrorLogger
* 7.0      RQ-007865   03-Apr-2018  Nisha@Ust                               Update ISR case 'country' to case owner country on Owner Change
* 8.0      RQ-008162   02-July-2018 Nisha@Ust                               Prevent the country getting populated from Account on leaving the country blank for the caribbean BAs.
* 9.0      RQ-008922   23-Aug-2018  Nisha@USt                               Revert the change of RQ-008162, Since default country for CAR Island Cluster is set to 'Antigua and Barbuda'.
* 10.0     RQ-010061   06/03/2019   Naved@maersk                            Cluster and Region fields to change automatically with change in Country
* 11.0     SC-394      24/06/2020   ramadevi@ust                            SCM Case Creation- External Case
* 12.0	   SC-5414	   09-01-2023   Saradha@UST             				Metadata query changes as part of CTO
* 13.0	   SC-6042	   08-02-2023   Saradha@UST             				4PL cases to populate case's country from contact.
* 14.0	   SC-8336	   05-10-2023   Harmeet@Maersk                          Twill Automation populate country from Shipment's Country for Twill delivery channel
*/

public class CaseGeoData {
    
    /** 
      * @description | RQ-001535 - Created [Ragu on 22nd May: This method is not yet optimized]
        RQ-002062 - Added "!Validation_Rules_Bypass__c.getinstance(Userinfo.getuserId()).Active__c" validation bypass condition throughout the method.  |
      * @param lstNewCases accepts a list of case record
      * @param mapOldCases accepts a key value pair of Id and Case Record
      * @param casTriggerHandler accepts the Class CaseTriggerHandler
      */
    public static void populateGeoData(list<Case> lstNewCases, map<Id, Case> mapOldCases, CaseTriggerHandler casTriggerHandler) {
        // RQ-002250 - Improve Case Trigger Recursion Control
        if(Generic_TriggerHandler.validateRunForMethod('CaseGeoData.populateGeoData()', 1)) {
            Boolean bInsert = casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT;
            
            // Populate Geo related fields (Country, Region and Cluster) based on the Geograpny, BDA and BDA Geography objects.
            // RQ-007865 - Added the parameter casTriggerHandler
            //cto populateGeoDataFromBDAGeography(lstNewCases, mapOldCases, bInsert, casTriggerHandler.casRecordSelector.mapLBDCs,casTriggerHandler.casRecordSelector.mapSCMKC, casTriggerHandler);
            //SC-5414 changed to static method call CaseRecordSelector.mapSCMKC
            populateGeoDataFromBDAGeography(lstNewCases, mapOldCases, bInsert, caseRecordSelector.mapLBDCs,CaseRecordSelector.mapSCMKC, casTriggerHandler);
            
            // Populate Geo related fields (City, Country, Region and Cluster) based on the Account associated with the Case.
            // RQ-007865 - Added the parameter casTriggerHandler
            populateGeoDataFromAccount(lstNewCases, mapOldCases, bInsert, casTriggerHandler.casRecordSelector.mapRelatedAccounts, casTriggerHandler.casRecordSelector.mapRelatedContacts, casTriggerHandler);
        }
    }
    
    private static void populateGeoDataFromBDAGeography(list<Case> lstNewCases, map<Id, Case> mapOldCases, Boolean bInsert, map<String, LinerBrand_Direction_and_Country__mdt> mapLBDCs,map<String, SCM_Key_Client_Country_Mapping__mdt> mapSCMKC , CaseTriggerHandler casTriggerHandler) {
        try {
            set<Id> setUpdatedCityIds = new set<Id>();
            set<String> setCountryCodes = new set<String>();
            map<String, String> mapOriginCountryCode = new map<String, String>();
            map<String, String> mapQueueCountryCode = new map<String, String>();
            
            for(Case newCase : lstNewCases) {
                Case oldCase;
                if(mapOldCases != null && !mapOldCases.isEmpty()) {
                    oldCase = mapOldCases.get(newCase.Id);
                    
                    // On a existing a Case if City is changed, Case GeoData (Country, Cluster and Region) has to be updated with respect to City.
                    if(newCase.City__c != oldCase.City__c) {
                        setUpdatedCityIds.add(newCase.City__c);
                    }
                }
                
                // For cases created via email to case
                if(newCase.SuppliedEmail != null && newCase.Origin != null) {
                    LinerBrand_Direction_and_Country__mdt lbdc = mapLBDCs.get(newCase.Origin);
                    SCM_Key_Client_Country_Mapping__mdt SCMKC =  mapSCMKC.get(newCase.OwnerId);
                    if(SCMKC != null && newCase.Origin.startsWith('SCMGLOBAL'))
                    {
                        if(SCMKC.Country__c != null){
                          setCountryCodes.add(SCMKC.Country__c);
                          mapQueueCountryCode.put(SCMKC.QueueId__c, SCMKC.Country__c);
                        }
                    }
                    
                    else if(lbdc != null) {
                        if(lbdc.Country__c != null) {
                            setCountryCodes.add(lbdc.Country__c);
                            mapOriginCountryCode.put(lbdc.MasterLabel, lbdc.Country__c);
                        }
                    }
                }
            }
            
            map<String, String> mapCountryCodeGeoId = new map<String, String>();
            set<Id> setParentGeoIds = new set<Id>();
            map<Id, Id> mapGeoIdParentGeoId = new map<Id, Id>();
            map<Id, Id> mapCountryGeoIdBDAId = new map<Id, Id>();
            map<Id, Id> mapBDAIdParentBDAId = new map<Id, Id>();
            if(!setCountryCodes.isEmpty() || !setUpdatedCityIds.isEmpty()) {
                // Query country details from Geography object
                for(Geography__c geography : [select Id, GEO_ID__c, Type_Of_Location__c, Parent_Geography__c, Parent_Geography__r.Type_Of_Location__c, Parent_Geography__r.Parent_Geography__c from Geography__c where GEO_ID__c in :setCountryCodes or Id in :setUpdatedCityIds ]) {
                    if(geography.Type_Of_Location__c == Label.TypeCountry) {
                        mapCountryCodeGeoId.put(geography.GEO_ID__c, geography.Id);
                    }
                    
                    // Get Country for updated City
                    if(setUpdatedCityIds.contains(geography.Id)) {
                        if(geography.Parent_Geography__r.Type_Of_Location__c == Label.TypeCountry) {
                            setParentGeoIds.add(geography.Parent_Geography__c);
                            mapGeoIdParentGeoId.put(geography.Id, geography.Parent_Geography__c);
                        } 
                        else {
                            setParentGeoIds.add(geography.Parent_Geography__r.Parent_Geography__c);
                            mapGeoIdParentGeoId.put(geography.Id, geography.Parent_Geography__r.Parent_Geography__c);
                        }
                    }
                }
                
                if(!setUpdatedCityIds.isEmpty()) {
                    // Querying parent Cluster details for the new Country values
                    for(BDA_Geography__c bdaGeography : [select Id, Geography__c, BDA__c, BDA__r.Parent_BDA__c from BDA_Geography__c where Geography__c in :setParentGeoIds and BDA__r.Type__c = 'Cluster' ]) {
                        mapCountryGeoIdBDAId.put(bdaGeography.Geography__c, bdaGeography.BDA__c);
                        mapBDAIdParentBDAId.put(bdaGeography.BDA__c, bdaGeography.BDA__r.Parent_BDA__c);
                    }
                }
            }
            
            list<Case> lstCasesToValidate = new list<Case>();
            for(Case newCase : lstNewCases) {
                Case oldCase;
                if(mapOldCases != null && !mapOldCases.isEmpty()) {
                    oldCase = mapOldCases.get(newCase.Id);
                }
                
                // When a new Case is created from Email to Case, get Country code from Origin and use it to populate geo data
                if(bInsert && newCase.SuppliedEmail != null) {
                    String strCountryCode = mapOriginCountryCode.get(newCase.Origin);
                    String strCountryCodeSCMKC = mapQueueCountryCode.get(newCase.OwnerId);
                    if(strCountryCodeSCMKC != null) {
                        String strCountryId = mapCountryCodeGeoId.get(strCountryCodeSCMKC);
                        if(strCountryId != null) {
                            newCase.Country__c = strCountryId;
                        }
                    }
                    else if(strCountryCode != null) {
                        String strCountryId = mapCountryCodeGeoId.get(strCountryCode);
                        if(strCountryId != null) {
                            newCase.Country__c = strCountryId;
                        }
                    }
                }
                
                // On an existing Case if City is changed, geo data has to be updated with respect to City
                if(!bInsert) {                    
                    Id countryGeoId ; 
                    
                    // RQ-007865 - Updated to populate the ISR Case country based on the case owner country on owner change 
                    if(casTriggerHandler.casRecordSelector.mapCaseIdOwnerId.containSkey(newCase.Id)){                        
                        countryGeoId = casTriggerHandler.casRecordSelector.mapCountryNameId.get(casTriggerHandler.casRecordSelector.mapOwnerandCountry.get(casTriggerHandler.casRecordSelector.mapCaseIdOwnerId.get(newCase.Id)));
                        
                        if(countryGeoId == null ){
                            newCase.Country__c = null;
                            newCase.Cluster__c = null;
                            newCase.Region__c  = null;
                        }                        
                    }
                    
                    // On an existing Case if City is changed, geo data has to be updated with respect to City
                    else{
                        countryGeoId = mapGeoIdParentGeoId.get(newCase.City__c);
                    }    
                    // system.debug('countryGeoId ###'+countryGeoId );         
                    if(countryGeoId != null) {                        
                        newCase.Country__c = countryGeoId;                      
                        Id clusterBDAId = mapCountryGeoIdBDAId.get(countryGeoId);
                        Id regionBDAId ;                        
                        if(clusterBDAId != null) {                            
                            newCase.Cluster__c = clusterBDAId;                          
                            regionBDAId = mapBDAIdParentBDAId.get(clusterBDAId);
                            if(regionBDAId != null) {
                                newCase.Region__c = regionBDAId;
                            }
                        }
                        else{
                            newCase.Cluster__c = null;
                            newCase.Region__c  = null;
                        }
                    }                   
                }
                
                // Collecting list of cases to be validated for Geo Data details
                if(bInsert || (!bInsert && (oldCase.Country__c != newCase.Country__c || oldCase.Cluster__c != newCase.Cluster__c || oldCase.City__c != newCase.City__c || (oldCase.Status == Label.CaseNew && oldCase.SuppliedEmail != null)))) {
                    lstCasesToValidate.add(newCase);
                }
            }
            // system.debug('lstCasesToValidate#####'+lstCasesToValidate);
            // RQ-001535 : Validate populated Geo Data
            if(!lstCasesToValidate.isEmpty()) {
                validateGeoData(lstCasesToValidate);
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseGeoData.populateGeoDataFromBDAGeography', new list<Exception>{ex}); // #RQ-005636 
        }
    }   
    
    // #RQ-004653. Get the Account - City Id map based on the Account Billing City.
    private static map<Id, Id> getBillingCityMap(map<Id, Account> mapRelatedAccounts) {
        set<Id> setCountryIds = new set<Id>();
        set<String> setBillingCities = new set<String>();
        map<String, list<Account>> mapBCAccounts = new map<String, list<Account>>();
        
        for(Account acc : mapRelatedAccounts.values()) {
            if(acc.BillingCity != null) {
                setCountryIds.add(acc.Country__c);
                setBillingCities.add(acc.BillingCity);
                
                if(mapBCAccounts.containsKey(acc.BillingCity.toUpperCase())) {
                    mapBCAccounts.get(acc.BillingCity.toUpperCase()).add(acc);
                }
                else {
                    mapBCAccounts.put(acc.BillingCity.toUpperCase(), new list<Account> {acc});
                }
            }
        }
        
        map<Id, Id> mapAccIdCityId = new map<Id, Id>();
        if(!setBillingCities.isEmpty() && mapBCAccounts != null && !mapBCAccounts.isEmpty()) {
            for(Geography__c geoCity : [Select Id, Name, Parent_Geography__c, Parent_Geography__r.Parent_Geography__c from Geography__c 
                                        Where Name IN :setBillingCities and Type_Of_Location__c = 'City' and (Parent_Geography__c IN :setCountryIds or Parent_Geography__r.Parent_Geography__c IN :setCountryIds) order by Parent_Geography__c desc]) {
                                            for(Account acc : mapBCAccounts.get(geoCity.Name.toUpperCase())) {
                                                if(acc.Country__c == geoCity.Parent_Geography__c || acc.Country__c == geoCity.Parent_Geography__r.Parent_Geography__c) {
                                                    mapAccIdCityId.put(acc.Id, geoCity.Id);
                                                }
                                            }
                                        }
        }
        return mapAccIdCityId;
    }
    
    // Method to set the Geo Data on Case from Account (RQ-001552)
    private static void populateGeoDataFromAccount(list<Case> lstNewCases, map<Id, Case> mapOldCases, Boolean bInsert, map<Id, Account> mapRelatedAccounts,map<Id, Contact> mapRelatedContacts, CaseTriggerHandler casTriggerHandler) {
        try {
            //SC-8336
            General_Key_Value_Configurations__mdt genKey = General_Key_Value_Configurations__mdt.getInstance('Delivery_Channel');
            Set<Id> shipmentIdSet = new Set<Id>();
            Map<Id,Id> shipmentMap = new Map<Id,Id>();

            list<Case> lstCasesToValidate = new list<Case>();
            map<Id, Id> mapAccIdCityId = getBillingCityMap(mapRelatedAccounts);
            //SC-6042
            General_Key_Value_Configurations__mdt mdt = General_Key_Value_Configurations__mdt.getInstance('SF_4PL');
			String str4PL = mdt.key__c;

            for(Case cs : lstNewCases) {
               if(cs.Shipment__c != null && String.isNotBlank(cs.Delivery_Channel__c) && genKey.first_field_value__c.contains(cs.Delivery_Channel__c)){
                 shipmentIdSet.add(cs.Shipment__c);
               }
             }

            if(!shipmentIdSet.isEmpty()){
              for(Shipment__c shp : [Select id,Place_of_Receipt_Id__c,Place_of_Receipt_Id__r.Parent_Geography__c,Place_of_Receipt_Id__r.Parent_Geography__r.Parent_Geography__c,Place_of_Receipt_Id__r.Parent_Geography__r.Parent_Geography__r.Type_Of_Location__c,Place_of_Receipt_Id__r.Parent_Geography__r.Type_Of_Location__c from Shipment__c WHERE Id IN :shipmentIdSet AND Place_of_Receipt_Id__c != null AND (Place_of_Receipt_Id__r.Parent_Geography__r.Type_Of_Location__c = 'Country' OR Place_of_Receipt_Id__r.Parent_Geography__r.Parent_Geography__r.Type_Of_Location__c = 'Country')]){
                  if(shp.Place_of_Receipt_Id__c != null && shp.Place_of_Receipt_Id__r.Parent_Geography__c != null && !String.isBlank(shp.Place_of_Receipt_Id__r.Parent_Geography__r.Type_Of_Location__c) && shp.Place_of_Receipt_Id__r.Parent_Geography__r.Type_Of_Location__c == 'Country' ){
                    shipmentMap.put(shp.Id, shp.Place_of_Receipt_Id__r.Parent_Geography__c);
                  }else if(shp.Place_of_Receipt_Id__c != null && shp.Place_of_Receipt_Id__r.Parent_Geography__c != null && shp.Place_of_Receipt_Id__r.Parent_Geography__r.Parent_Geography__c != null && !String.isBlank(shp.Place_of_Receipt_Id__r.Parent_Geography__r.Parent_Geography__r.Type_Of_Location__c) && shp.Place_of_Receipt_Id__r.Parent_Geography__r.Parent_Geography__r.Type_Of_Location__c == 'Country'){
				     shipmentMap.put(shp.Id, shp.Place_of_Receipt_Id__r.Parent_Geography__r.Parent_Geography__c);
				  }
               }
            }
            
            for(Case newCase : lstNewCases) {   
                Case oldCase;
                if(mapOldCases != null && !mapOldCases.isEmpty()) {
                    oldCase = mapOldCases.get(newCase.Id);
                }
                // RQ-007865 - Added condition to exclude the ISR cases on the Owner change
                if(!casTriggerHandler.casRecordSelector.mapCaseIdOwnerId.containsKey(newCase.Id)){
                
                    // String strLinerBrand = CaseUtilities.getLinerBrandLogic(newCase);
                    
                     // Condition to identify SCM Cases - SC-394
                     // SC-6042 for 4PL separate logic is written
                    if(newCase.Origin != null && newCase.Product__c != str4PL && newCase.Product__c == Label.SCM && newCase.ContactId != null && newCase.Country__c == null) { 
                        Contact conInstance = mapRelatedContacts.get(newCase.ContactId);                        
                        if(conInstance != null && conInstance.Country__c != null) {                                                 
                            newCase.Country__c = conInstance.Country__c;                            
                            lstCasesToValidate.add(newCase);
                        }
                    }
                    
                    // SC-394 - added Product__c to the condition for SCM Cases
                    // Regression issue for SCM BA - SCM Manual case country population is handled.
                    // SC-6042 for 4PL separate logic is written
                    if(newCase.AccountId != null && newCase.Product__c != str4PL && newCase.Country__c == null && (newCase.Product__c != Label.SCM ||(newCase.Origin == null && newCase.Product__c == Label.SCM))) { // RQ-001510
                        Account accInstance = mapRelatedAccounts.get(newCase.AccountId);
                        if(accInstance != null && accInstance.Country__c != null) {
                            if(newCase.City__c == null || (!bInsert && oldCase.City__c == newCase.City__c)) { // RQ-005373
                                // RQ-004653 - Case City is populated from Account Billing City
                                newCase.City__c = mapAccIdCityId.get(accInstance.Id);
                            }
                            // RQ-005373
                            newCase.Country__c = accInstance.Country__c;                       
                            lstCasesToValidate.add(newCase);
                        }
                    }
                }
              // SC-6042 for 4PL cases, populate case's country from contact same like account BAs
                if(newCase.Product__c == str4PL  && newCase.ContactId != null && newCase.Country__c == null) { 
                    Contact conInstance = mapRelatedContacts.get(newCase.ContactId);                        
                    if(conInstance != null && conInstance.Country__c != null) {                                                  
                      newCase.Country__c = conInstance.Country__c;
                      lstCasesToValidate.add(newCase);
                    }
                } 
              
                //SC-8336 Twill Country Automation
				if(newCase.Country__c == null && newCase.Shipment__c!= null && !shipmentMap.isEmpty() && shipmentMap.containsKey(newCase.Shipment__c)  && String.isNotBlank(newCase.Case_Channel__c)  && (newCase.Case_Channel__c == 'Portal' || newCase.Case_Channel__c == 'E-mail' || newCase.Case_Channel__c == 'Website')){		
					 newCase.Country__c = shipmentMap.get(newCase.Shipment__c);
 		          	 lstCasesToValidate.add(newCase);						   
                } 
 
            }
                  
            // RQ-001535 : Validate populated Geo Data
            if(!lstCasesToValidate.isEmpty()) {
                caseRecordSelector.blnCountryChange=true;
                validateGeoData(lstCasesToValidate);
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseGeoData.populateGeoDataFromAccount', new list<Exception>{ex}); // #RQ-005636 
        }
    }    
    
    
    /** 
      * @description | RQ-001535 - Created [Ragu on 22nd May: This method is not yet optimized]
        RQ-002062 - Added "!Validation_Rules_Bypass__c.getinstance(Userinfo.getuserId()).Active__c" validation bypass condition throughout the method.  |
      * @param lstCases accepts a list of case record
      */
    public static void validateGeoData(list<Case> lstCases) {
        set<Id> setCountryIds = new set<Id>();
        set<Id> setClusterIds = new set<Id>();
        for(Case newCase : lstCases) {
            if(newCase.Country__c != null) {
                setCountryIds.add(newCase.Country__c);
            }
            if(newCase.Cluster__c != null) {
                setClusterIds.add(newCase.Cluster__c);
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
        map<string,LinerBrand_Direction_and_Country__mdt> metadataList = CaseTrigger_DataSetUtilities.getAllCustomMetadataList();
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
        
        for(Case newCase: lstCases) {
            Id country;
            // Id cluster; 
            Id region;
            Id bdaGeo;
            String countryCode;
            String clusterCode;
            set<BDA_Geography__c> bdaGeoSet;
            // system.debug('newCase.Country__c '+newCase.Country__c );
            // system.debug('newCase.Country__c '+newCase.Cluster__c );
            // SCENARIO 1 --> Country != null BUT Cluster == null
            if(newCase.Country__c != null && newCase.Cluster__c == null) {
                // System.debug('mapGeoIdBDAGeos' + mapGeoIdBDAGeos);
                
                bdaGeoSet = mapGeoIdBDAGeos.get(newCase.Country__c);
                if(bdaGeoSet == null) {
                    countryCode = mapGeoIdCode.get(newCase.Country__c);
                    
                    if(countryCode != null) {
                        // System.debug('mapCountryCodeClusters###' + mapCountryCodeClusters);
                        // System.debug('mapCountryCodeClusters###' + mapCountryCodeClusters.get(countryCode));
                        set<String> clusterCountrySet = mapCountryCodeClusters.get(countryCode);
                        
                        if(clusterCountrySet != null && !Validation_Rules_Bypass__c.getinstance(Userinfo.getuserId()).Active__c) {
                            if(clusterCountrySet.size()> 0 && clusterCountrySet.size() != 1) {
                                newCase.addError(Label.GeoErrorMessage1);
                            }
                        }
                        else if(!Validation_Rules_Bypass__c.getinstance(Userinfo.getuserId()).Active__c) {
                            newCase.addError(Label.GeoErrorMessage2);
                        }
                    }
                }
                else if(bdaGeoSet.size() > 1 && !Validation_Rules_Bypass__c.getinstance(Userinfo.getuserId()).Active__c) {
                    newCase.addError(Label.GeoErrorMessage1);
                }
                else if(bdaGeoSet.size() == 1) {
                    for(BDA_Geography__c geo : bdaGeoSet) {
                        newCase.Cluster__c = geo.BDA__c;
                        newCase.Region__c = geo.BDA__r.Parent_BDA__c;
                    }
                    // system.debug('newCase#'+newCase);
                }
            }
            // SCENARIO 2 --> Cluster != null BUT Country == null
            else if(newCase.Country__c == null && newCase.Cluster__c != null) {
                clusterCode = mapClusterIdCode.get(newCase.Cluster__c);
                if(clusterCode != null) {
                    countryCode = geoIdMap.get(clusterCode);
                }
                if(countryCode != null) {
                    country = mapGeoCodeId.get(countryCode);
                    if(country != null) {
                        newCase.Country__c = country;
                    }
                    region = mapClusterIdParentBDA.get(newCase.Cluster__c);
                    if(region != null) {
                        newCase.Region__c = region;
                    }
                } 
                else {
                    bdaGeoSet = mapBDAIdBDAGeos.get(newCase.Cluster__c);
                    // system.debug('bdaGeoSet #'+bdaGeoSet );
                    if(bdaGeoSet != null) {
                        if(bdaGeoSet.size() > 1 && !Validation_Rules_Bypass__c.getinstance(Userinfo.getuserId()).Active__c) {
                            newCase.addError(Label.GeoErrorMessage3);
                        }
                        if(bdaGeoSet.size() == 1) {
                            for(BDA_Geography__c geo: bdaGeoSet) {
                                newCase.Country__c = geo.Geography__c;
                                newCase.Region__c = geo.BDA__r.Parent_BDA__c;
                            }
                        }
                    } 
                    else if(!Validation_Rules_Bypass__c.getinstance(Userinfo.getuserId()).Active__c) {
                        newCase.addError(Label.GeoErrorMessage4);
                    }
                }
            }
            // SCENARIO 3 --> Cluster != null AND Country != null
            else if(newCase.Country__c != null && newCase.Cluster__c != null) {
                if(ccGeoMap.get(newCase.Country__c) != null) {
                    bdaGeo = ccGeoMap.get(newCase.Country__c).get(newCase.Cluster__c);
                }
                if(bdaGeo == null) {
                    clusterCode = mapClusterIdCode.get(newCase.Cluster__c);
                    if(clusterCode != null) {
                        countryCode = geoIdMap.get(clusterCode);
                    }
                    if(countryCode != null) {
                        country = mapGeoCodeId.get(countryCode);
                    }
                    // if(country != newCase.Country__c && !Validation_Rules_Bypass__c.getinstance(Userinfo.getuserId()).Active__c) {
                        //newCase.addError(Label.GeoErrorMessage5);
                    // }
                    else {
                        region = mapClusterIdParentBDA.get(newCase.Cluster__c);
                        if(region != null) {
                            newCase.Region__c = region;
                        }
                    }
                } 
                else {
                    region = mapClusterIdParentBDA.get(newCase.Cluster__c);
                    if(region != null) {
                        newCase.Region__c = region;
                    }
                }
            }
        }
    }
    
}