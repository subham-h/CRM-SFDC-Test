/**
* Author   : Ragu
* Purpose  : Utility class to hold simple and reusable functionalities related to Case Business Hours. 
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-002633   22-Feb-2016 Ragu@UST                Created for implementing CBO (Centralized By Org) trigger architecture.
* 2.0      RQ-005636   25-Sep-2017 Nisha@UST               Update references of GlobalErrorLogger
* 3.0      RQ-009493   20-nov-2018 Partha@maersk           adding logic for Current_Time_Spent_Open_BH__c
* 4.0      RQ-009493   20-nov-2018 Sreya@maersk            updated logic for business hours changes 
* 5.0      RQ-009493   07-dec-2018 Sreya@maersk            updated logic for Current_Time_Spent_Open_BH__c
* 6.0      RQ-009701   11-feb-2018 Naved@maersk            updated logic for Total Time Awaiting Vendor Input (BH)   
* 7.0      SC-245      27-Mar-2020 Avinash@Ust             Chat BOT Dashboard Enhancements 2
* 8.0      SC-2489     05-May-2021 Saradha@Ust             Chat BOT Off-Business Hour Fix
* 9.0       SC-2491     07-Jun-2021 Meghna@maersk           Bug Fix to populate Maersk Business Hour
* 10.0     SPI-100     17-Jun-2022 Ronnie@SF               Removed brand hardcoding
*/

public class CaseBusinessHours {
    
    // RQ-000962: Initializes the Business Hours calculation related fields
    // RQ-002633: Code optimized and separated from calculateBusinessHoursAges()
    public static void initializeBusinessHoursFields(list<Case> lstCases) {
        // Get the stop statuses...
        list<Stop_Status__c> lstStopStatuses = CaseTrigger_DataSetUtilities.getstopStatusList();
        
        
        for(Case newCase : lstCases) {
            // Reset the Last Status Change and the total Case Age in Hours...
            newCase.Last_Status_Change__c = System.now();
            newCase.Age_In_Business_Hours__c = 0;
            newCase.Time_First_Open__c = 0;
            newCase.Time_Re_Opened__c = 0;
            newCase.Case_Reopened__c = false;
            newCase.Case_Reopen_Count__c = 0;
            newCase.Case_Reopened_Date_Time__c = null;
            if(newCase.Total_Time_Awaiting_Vendor_Input_BH__c == null){
                newCase.Total_Time_Awaiting_Vendor_Input_BH__c =0;
            }
            
            // Now go through each Stop Status record, find the Case field being used to store the bucket of time and set it to 0...
            for(Stop_Status__c stopStatus : lstStopStatuses) {
                if(stopStatus.Field_Name__c != null) {
                    newCase.put(stopStatus.Field_Name__c, 0);
                }
            }
        }
    }
    
    // RQ-001547: Set business hours based on City (for Russia) / Cluster (for China) / Country (for other countries) 
    public static void setBusinessHours(list<Case> lstNewCases, map<Id, Case> mapOldCases, Boolean isInsert, Boolean isUpdate) {
        try {
            // RQ-002250: Improve Case Trigger Recursion Control
            if(Generic_TriggerHandler.validateRunForMethod('CaseBusinessHours.setBusinessHours()', 1)) {
                list<Case> lstCasesToProcess = new list<Case>();
                if(isInsert) {
                    lstCasesToProcess = lstNewCases;
                }
                else if(isUpdate) {
                    for(Case newCase : lstNewCases) {
                        Case oldCase = mapOldCases.get(newCase.Id);
                        
                        if(newCase.City__c != oldCase.City__c || newCase.Country__c != oldCase.Country__c || newCase.Cluster__c != oldCase.Cluster__c || newCase.Liner_Brand__c != oldCase.Liner_Brand__c || newCase.MLL__c != oldCase.MLL__c) {
                            lstCasesToProcess.add(newCase);
                        }
                    }
                }
                
                if(!lstCasesToProcess.isEmpty()) {
                    set<Id> setCityIds = new set<Id>();
                    set<Id> setCountryIds = new set<Id>();
                    set<Id> setClusterIds = new set<Id>();
                    set<String> setCaseLinerBrands = new set<String>();
                    
                    for(Case newCase : lstCasesToProcess) {
                        if(newCase.City__c != null) {
                            setCityIds.add(newCase.City__c);
                        }
                        if(newCase.Country__c != null) {
                            setCountryIds.add(newCase.Country__c);
                        }
                        if(newCase.Cluster__c != null) {
                            setClusterIds.add(newCase.Cluster__c);
                        }
                        
                        if(BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.USFLAG).contains(CaseUtilities.getLinerBrandLogic(newCase))) {
                            setCaseLinerBrands.add(BrandUtilities.USFLAG);
                        } else {
                            setCaseLinerBrands.add(newCase.Liner_Brand__c);
                        }
                    }
                    
                    set<String> setGeoCodes = new set<String>();
                    map<Id, String> mapCityGeoIdCode = new map<Id, String>();
                    map<Id, String> mapCountryGeoIdCode = new map<Id, String>();
                    for(Geography__c geography : CaseTrigger_DataSetUtilities.getBHCountryCitylist(setCityIds, setCountryIds)) {
                        if(setCityIds.contains(geography.Id)) {
                            setGeoCodes.add(geography.GEO_ID__c);
                            mapCityGeoIdCode.put(geography.Id, geography.GEO_ID__c);
                            
                        }
                        
                        if(setCountryIds.contains(geography.Id)) {
                            setGeoCodes.add(geography.GEO_ID__c); 
                            mapCountryGeoIdCode.put(geography.Id, geography.GEO_ID__c);
                        }
                    }
                    
                    map<Id, String> mapBDAIdCode = new map<Id, String>();
                    for(BDA__c clusterBDA : CaseTrigger_DataSetUtilities.getBDAList()) {
                        if(setClusterIds.contains(clusterBDA.Id)) {
                            setGeoCodes.add(clusterBDA.GEO_ID__c); 
                            mapBDAIdCode.put(clusterBDA.Id, clusterBDA.GEO_ID__c);
                        }
                    }
                    // Step 2: Querying for Custom metadata records and acquiring/storing the Liner Brand / Business Hour Name in a Map [Key: GEO Id, Value: Map{Liner Brand, Business Hour Name}];
                    set<String> setBHNames = new set<String>{'Default'};
                        map<String, map<String, String>> mapGeoIdLBBH = new map<String, map<String, String>>();
                    Map<string, LinerBrand_Direction_and_Country__mdt> lbdcs = caseRecordselector.mapLBDCs;
                    for(LinerBrand_Direction_and_Country__mdt LBDC : lbdcs.values()) {
                        if(LBDC!=null){
                            if(setGeoCodes.contains(LBDC.Country__c) && LBDC.Business_Hours__c != null) {
                                setBHNames.add(LBDC.Business_Hours__c);
                                
                                if(mapGeoIdLBBH.containskey(LBDC.Country__c)) {
                                    mapGeoIdLBBH.get(LBDC.Country__c).put(LBDC.Liner_Brand__c, LBDC.Business_Hours__c);
                                } else {
                                    mapGeoIdLBBH.put(LBDC.Country__c, new map<String, String> {LBDC.Liner_Brand__c => LBDC.Business_Hours__c});
                                }
                            }
                            
                            if(setGeoCodes.contains(LBDC.Cluster__c) && LBDC.Business_Hours__c != null) {
                                setBHNames.add(LBDC.Business_Hours__c);
                                if(!mapGeoIdLBBH.containskey(LBDC.Cluster__c)) {
                                    mapGeoIdLBBH.put(LBDC.Cluster__c, new map<String, String> {LBDC.Liner_Brand__c => LBDC.Business_Hours__c});
                                } else {
                                    mapGeoIdLBBH.get(LBDC.Cluster__c).put(LBDC.Liner_Brand__c, LBDC.Business_Hours__c);
                                }
                            }
                        }
                    }
                    Map<string, SCM_Key_Client_Country_Mapping__mdt> SCMKCs = caserecordselector.mapAllSCMKC;
                    Map<String, String> brandMap = new Map<String, String>();

                    for (SCM_Key_Client_Country_Mapping__mdt SCMKC : [SELECT Country__c, Relation_to_LBDC_metadata__r.Liner_Brand__c FROM SCM_Key_Client_Country_Mapping__mdt WHERE Country__c!=null AND Country__c IN :setGeoCodes AND Business_Hour__c != null]) {
                        brandMap.put(SCMKC.Country__c, SCMKC.Relation_to_LBDC_metadata__r.Liner_Brand__c);
                    }

                    for(SCM_Key_Client_Country_Mapping__mdt SCMKC : SCMKCs.values()) {
                            if(setGeoCodes.contains(SCMKC.Country__c) && SCMKC.Business_Hour__c != null) {
                                setBHNames.add(SCMKC.Business_Hour__c);
                                
                                if(mapGeoIdLBBH.containskey(SCMKC.Country__c)) {
                                    mapGeoIdLBBH.get(SCMKC.Country__c).put(brandMap.get(SCMKC.Country__c), SCMKC.Business_Hour__c);
                                }
                                else {
                                    mapGeoIdLBBH.put(SCMKC.Country__c, new map<String, String> {brandMap.get(SCMKC.Country__c) => SCMKC.Business_Hour__c});
                                }
                            }
                    }
                    // Step 3: Querying for the Business Hours record from a match in name found from Custom Settings and storing into a Map{Key: Name, Value: BH Record}
                    map<String, BusinessHours> mapBHNameBH = new map<String, BusinessHours>();
                    for(BusinessHours bHour : CaseTrigger_DataSetUtilities.getBHList(setBHNames)) {
                        mapBHNameBH.put(bHour.Name, bHour);
                    }
                    
                    for(Case newCase : lstCasesToProcess) {
                        Boolean bhUpdated = false;
                        
                        // Assigning the Business Hours based on Case's City (for Russia Country)
                        if((newCase.City__c != null)) {
                            bhUpdated = assignBusinessHour(newCase, mapGeoIdLBBH, mapBHNameBH, mapCityGeoIdCode.get(newCase.City__c));
                        }
                        
                        // Assigning the Business Hours based on Case's Country (Except for China)
                        if(newCase.Country__c != null && bhUpdated == false) {
                            bhUpdated = assignBusinessHour(newCase, mapGeoIdLBBH, mapBHNameBH, mapCountryGeoIdCode.get(newCase.Country__c));
                        }
                        
                        /***CAN BE DELETED LATER AS CHINA FOLLOWS COUNTRY - CLUSTER LOGIC SAME AS OTHER COUNTRIES***/
                        // Assigning the Business Hours based on Case's Cluster (for China Country)
                        if(newCase.Cluster__c != null && bhUpdated == false) {
                            bhUpdated = assignBusinessHour(newCase, mapGeoIdLBBH, mapBHNameBH, mapBDAIdCode.get(newCase.Cluster__c));
                        }
                        
                        if(bhUpdated == false) {
                            BusinessHours bHour = mapBHNameBH.get('Default');
                            if(bHour != null) {
                                newCase.BusinessHoursId = bHour.Id;
                                newCase.Business_Hours_Case__c = 'Yes';
                            }
                        }
                    }
                }
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseBusinessHours.setBusinessHours', new list<Exception>{ex}); // #RQ-005636 
        }
    }
    
    private static Boolean assignBusinessHour(Case newCase, map<String, map<String, String>> mapGeoIdLBBH, map<String, BusinessHours> mapBHNameBH, String geoId) {
        Boolean bUpdated = false;
        if(mapGeoIdLBBH.get(geoId) != null) {
            String bhName;
            // For USFlag cases linerbrand is stored in Custom metadata as "USFlag"
            if(BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.USFLAG).contains(CaseUtilities.getLinerBrandLogic(newCase))) {
                bhName = mapGeoIdLBBH.get(geoId).get(BrandUtilities.USFLAG);
            } 
            else {
                bhName = mapGeoIdLBBH.get(geoId).get(newCase.Liner_Brand__c);
                //SC-2491 Temporary Bug Fix to populate Maersk Business hour instead of default
                if(bhName == null && BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.SEALAND).contains(newCase.Liner_Brand__c)) {
                    bhName = mapGeoIdLBBH.get(geoId).get(BrandUtilities.MAERSKLINE);
                }
            }
            
            if(bhName != null) {
                BusinessHours bHour = mapBHNameBH.get(bhName);
                if(bHour != null) {
                    newCase.BusinessHoursId = bHour.Id;
                    
                    //SC-2489 code change whether the date time is during business hour(checks holiday and weekend) start
                    DateTime date1 = DateTime.now();
                    
                    if(BusinessHours.isWithin(bHour.Id, date1)){
                        newCase.Business_Hours_Case__c = 'Yes';
                    }else{
                        newCase.Business_Hours_Case__c = 'No';
                    }
                    //SC-2489 end
                    bUpdated = true;
                }
            }
        }
        return bUpdated;
    }
    
    // RQ-000962: This method is to calculate the business hours spent on a particular status of Case and Case Age
    // RQ-002633: Code optimized
    public static void calculateBusinessHoursAges(list<Case> lstNewCases, map<Id, Case> mapOldCases) {
        try {
            // RQ-002250: Improve Case Trigger Recursion Control
            // [Ragu on 26th Apr]: Updated recursion control variable to 2 in order to consider the Status changes via workflow field updates (e.g. New to Triaged)
            if(Generic_TriggerHandler.validateRunForMethod('CaseBusinessHours.calculateBusinessHoursAges()', 2)) {
                // Get the stop statuses...
                list<Stop_Status__c> lstStopStatuses = CaseTrigger_DataSetUtilities.getStopStatusList();
                map<String, Stop_Status__c> mapStopStatuses = new map<String, Stop_Status__c>();
                if(lstStopStatuses != null) {
                    for(Stop_Status__c stopStatus : lstStopStatuses) {
                        mapStopStatuses.put(stopStatus.Case_Status_Value__c, stopStatus);
                    }
                }
                
                // Get the closed statuses (because at the point of this trigger Case.IsClosed won't be set yet)...
                set<String> setCaseClosedStatuses = new set<String>();
                for(CaseStatus status : CaseTrigger_DataSetUtilities.getCaseStatusList()) {
                    setCaseClosedStatuses.add(status.MasterLabel);
                }
                
                // For any case where the status is changed, recalc the business hours in the buckets...
                for(Case newCase : lstNewCases) {                    
                    Case oldCase = mapOldCases.get(newCase.Id);
                    // First of all check if we need to stop the SLA...
                    newCase.IsStopped = false;
                    if(newCase.EntitlementId != null && mapStopStatuses.containsKey(newCase.Status)) {
                        if(mapStopStatuses.get(newCase.Status).Pause_Milestone__c == true && newCase.IsStopped != true) {
                            newCase.IsStopped = true;
                        } 
                    }
                    
                    // Set the Case re-opened details the first time...
                    // Ragu on 3rd May: Added condition to avoid increasing Case Reopen Count when workflow field update executes the trigger again.
                    if(setCaseClosedStatuses.contains(oldCase.Status) && !setCaseClosedStatuses.contains(newCase.Status) && !Generic_TriggerHandler.isBypassed('CaseBusinessHours.caseReopenCountCalculation')) {
                        Generic_TriggerHandler.bypass('CaseBusinessHours.caseReopenCountCalculation');
                        newCase.Case_Reopen_Count__c++;
                        newCase.Case_Reopened_Date_Time__c = System.now();
                        newCase.Ownership_Changed_Time__c = System.now();
                        // newcase.Current_Time_Spent_Open_BH__c=0;
                        
                        if(!newCase.Case_Reopened__c) {
                            newCase.Case_Reopened__c = true;
                        }
                    }
                    
                    if((newCase.Status != oldCase.Status || newCase.businessHoursId != oldCase.businessHoursId ) && newCase.Last_Status_Change__c != null) {
                        // OK, the status has changed, we only update the buckets for open cases...
                        if(!setCaseClosedStatuses.contains(oldCase.Status)) {
                            double dTimeSinceLastStatus;
                            if(newCase.Status != oldCase.Status){
                                // The diff method comes back in milliseconds, so we divide by 3600000 to get hours or 6000 to get minutes....
                                dTimeSinceLastStatus = BusinessHours.diff(newCase.BusinessHoursId, newCase.Last_Status_Change__c, System.now()) / 3600000.0;
                                //Change as part of RQ-009701
                                Stop_Status__c stopStatus = mapStopStatuses.get(oldCase.Status);
                                if(stopStatus != null && stopStatus.Field_Name__c != null) {
                                    if(newCase.get(stopStatus.Field_Name__c) != null){
                                        Double dTimeElapsed = Double.valueOf(newCase.get(stopStatus.Field_Name__c));
                                        newCase.put(stopStatus.Field_Name__c, dTimeElapsed + dTimeSinceLastStatus);
                                    }
                                }
                            }
                            if(newCase.businessHoursId != oldCase.businessHoursId){
                                dTimeSinceLastStatus = BusinessHours.diff(oldCase.BusinessHoursId, newCase.Last_Status_Change__c, System.now()) / 3600000.0;
                                //Change as part of RQ-009701
                                Stop_Status__c stopStatus = mapStopStatuses.get(newCase.Status);
                                if(stopStatus != null && stopStatus.Field_Name__c != null) {
                                    if(newCase.get(stopStatus.Field_Name__c)!=null){
                                        Double dTimeElapsed = Double.valueOf(newCase.get(stopStatus.Field_Name__c));
                                        newCase.put(stopStatus.Field_Name__c, dTimeElapsed + dTimeSinceLastStatus);
                                    }
                                }    
                            }
                            // We decide which bucket to add it to based on whether it was in a stop status before...
                            
                            if( newCase.Age_In_Business_Hours__c !=null){
                                newCase.Age_In_Business_Hours__c = newCase.Age_In_Business_Hours__c + dTimeSinceLastStatus;
                            }
                            
                            // Update the time spent first open or subsequently open...
                            if(!newCase.Case_Reopened__c) {
                                if(newCase.Time_First_Open__c != null){
                                    newCase.Time_First_Open__c = newCase.Time_First_Open__c + dTimeSinceLastStatus;
                                }
                            } else {
                                if(newCase.Time_Re_Opened__c != null){
                                    newCase.Time_Re_Opened__c = newCase.Time_Re_Opened__c + dTimeSinceLastStatus;
                                }
                            }
                        }
                        newCase.Last_Status_Change__c = System.now();
                    }
                    // RQ-009493 adding logic for Current_Time_Spent_Open_BH__c
                }
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseBusinessHours.calculateBusinessHoursAges', new list<Exception>{ex}); // #RQ-005636 
        }
    }
}