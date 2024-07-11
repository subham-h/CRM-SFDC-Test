public class LCTBusinessHours {
        // RQ-001547: Set business hours based on City (for Russia) / Cluster (for China) / Country (for other countries) 
    public static void setBusinessHours(list<LiveChatTranscript> lstNewlct, map<Id, LiveChatTranscript> mapOldlct, Boolean isInsert, Boolean isUpdate) {
        try {
            // RQ-002250: Improve LiveChatTranscript Trigger Recursion Control
            //if(Generic_TriggerHandler.validateRunForMethod('LCTBusinessHours.setBusinessHours()', 1)) {
                list<LiveChatTranscript> lstlctToProcess = new list<LiveChatTranscript>();
                if(isInsert) {
                    lstlctToProcess = lstNewlct;
                }
                else if(isUpdate) {
                    for(LiveChatTranscript newlct : lstNewlct) {
                        LiveChatTranscript oldlct = mapOldlct.get(newlct.Id);
                        
                        if(newlct.City__c != oldlct.City__c || newlct.Country__c != oldlct.Country__c || newlct.Cluster__c != oldlct.Cluster__c || newlct.Liner_Brand__c != oldlct.Liner_Brand__c || newlct.MLL__c != oldlct.MLL__c) {
                            lstlctToProcess.add(newlct);
                        }
                    }
                }
                
                if(!lstlctToProcess.isEmpty()) {
                    set<Id> setCityIds = new set<Id>();
                    set<Id> setCountryIds = new set<Id>();
                    set<Id> setClusterIds = new set<Id>();
                    set<String> setLctLinerBrands = new set<String>();
                    
                    for(LiveChatTranscript newlct : lstlctToProcess) {
                        if(newlct.City__c != null) {
                            setCityIds.add(newlct.City__c);
                        }
                        if(newlct.Country__c != null) {
                            setCountryIds.add(newlct.Country__c);
                        }
                        if(newlct.Cluster__c != null) {
                            setClusterIds.add(newlct.Cluster__c);
                        }
                        
                        if(BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.USFLAG).contains(LCTUtilities.getLinerBrandLogic(newlct))) {
                            setLctLinerBrands.add(BrandUtilities.USFLAG);
                        } else {
                            setLctLinerBrands.add(newlct.Liner_Brand__c);
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
                    for(LinerBrand_Direction_and_Country__mdt LBDC : [select MasterLabel, Cluster__c, Country__c, Direction__c, Liner_Brand__c, Business_Hours__c from LinerBrand_Direction_and_Country__mdt]) {
                        if(setGeoCodes.contains(LBDC.Country__c)) {
                            setBHNames.add(LBDC.Business_Hours__c);
                            
                            if(mapGeoIdLBBH.containskey(LBDC.Country__c)) {
                                mapGeoIdLBBH.get(LBDC.Country__c).put(LBDC.Liner_Brand__c, LBDC.Business_Hours__c);
                            } else {
                                mapGeoIdLBBH.put(LBDC.Country__c, new map<String, String> {LBDC.Liner_Brand__c => LBDC.Business_Hours__c});
                            }
                        }
                        
                        if(setGeoCodes.contains(LBDC.Cluster__c)) {
                            setBHNames.add(LBDC.Business_Hours__c);
                            if(!mapGeoIdLBBH.containskey(LBDC.Cluster__c)) {
                                mapGeoIdLBBH.put(LBDC.Cluster__c, new map<String, String> {LBDC.Liner_Brand__c => LBDC.Business_Hours__c});
                            } else {
                                mapGeoIdLBBH.get(LBDC.Cluster__c).put(LBDC.Liner_Brand__c, LBDC.Business_Hours__c);
                            }
                        }
                    }
                    for(SCM_Key_Client_Country_Mapping__mdt SCMKC : [select MasterLabel,QueueId__c,On_Behalf_of_Account_ID__c,Country__c,Business_Hour__c,Relation_to_LBDC_metadata__r.Liner_Brand__c from SCM_Key_Client_Country_Mapping__mdt]) {
                        if(setGeoCodes.contains(SCMKC.Country__c)) {
                            setBHNames.add(SCMKC.Business_Hour__c);
                            
                            if(mapGeoIdLBBH.containskey(SCMKC.Country__c)) {
                                mapGeoIdLBBH.get(SCMKC.Country__c).put(SCMKC.Relation_to_LBDC_metadata__r.Liner_Brand__c , SCMKC.Business_Hour__c);
                            }
                            else {
                                mapGeoIdLBBH.put(SCMKC.Country__c, new map<String, String> {SCMKC.Relation_to_LBDC_metadata__r.Liner_Brand__c  => SCMKC.Business_Hour__c});
                            }
                        }
                    }
                    // Step 3: Querying for the Business Hours record from a match in name found from Custom Settings and storing into a Map{Key: Name, Value: BH Record}
                    map<String, BusinessHours> mapBHNameBH = new map<String, BusinessHours>();
                    for(BusinessHours bHour : CaseTrigger_DataSetUtilities.getBHList(setBHNames)) {
                        mapBHNameBH.put(bHour.Name, bHour);
                    }
                    
                    for(LiveChatTranscript newlct : lstlctToProcess) {
                        Boolean bhUpdated = false;
                        
                        // Assigning the Business Hours based on LiveChatTranscript's City (for Russia Country)
                        if((newlct.City__c != null)) {
                            bhUpdated = assignBusinessHour(newlct, mapGeoIdLBBH, mapBHNameBH, mapCityGeoIdCode.get(newlct.City__c));
                        }
                        
                        // Assigning the Business Hours based on Case's Country (Except for China)
                        if(newlct.Country__c != null && bhUpdated == false) {
                            bhUpdated = assignBusinessHour(newlct, mapGeoIdLBBH, mapBHNameBH, mapCountryGeoIdCode.get(newlct.Country__c));
                        }
                        
                        /***CAN BE DELETED LATER AS CHINA FOLLOWS COUNTRY - CLUSTER LOGIC SAME AS OTHER COUNTRIES***/
                        // Assigning the Business Hours based on Case's Cluster (for China Country)
                        if(newlct.Cluster__c != null && bhUpdated == false) {
                            bhUpdated = assignBusinessHour(newlct, mapGeoIdLBBH, mapBHNameBH, mapBDAIdCode.get(newlct.Cluster__c));
                        }
                        
                        if(bhUpdated == false) {
                            BusinessHours bHour = mapBHNameBH.get('Default');
                            if(bHour != null) {
                                newlct.BusinessHoursId__c = bHour.Id;
                                newlct.Business_Hours_Case__c = 'Yes';
                            }
                        }
                    }
                }
            
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'LiveChatTranscript', 'LCTBusinessHours.setBusinessHours', new list<Exception>{ex}); // #RQ-005636 
        }
    }
    
        private static Boolean assignBusinessHour(LiveChatTranscript newlct, map<String, map<String, String>> mapGeoIdLBBH, map<String, BusinessHours> mapBHNameBH, String geoId) {
        Boolean bUpdated = false;
        if(mapGeoIdLBBH.get(geoId) != null) {
            String bhName;
            // For USFlag cases linerbrand is stored in Custom metadata as "USFlag"
            if(BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.USFLAG).contains(LCTUtilities.getLinerBrandLogic(newlct))) {
                bhName = mapGeoIdLBBH.get(geoId).get(BrandUtilities.USFLAG);
            } 
            else {
                bhName = mapGeoIdLBBH.get(geoId).get(newlct.Liner_Brand__c);
                //SC-2491 Temporary Bug Fix to populate Maersk Business hour instead of default
                if(bhName == null && BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.SEALAND).contains(newlct.Liner_Brand__c)) {
                	bhName = mapGeoIdLBBH.get(geoId).get(BrandUtilities.MAERSKLINE);
                }
            }
            
            if(bhName != null) {
                BusinessHours bHour = mapBHNameBH.get(bhName);
                if(bHour != null) {
                    newlct.BusinessHoursId__c = bHour.Id;
                    /*String convertedTimeStr = DateTime.now().format('HH:mm:ss', bHour.TimeZoneSidKey);
                    Time convertedCrtdTime = Time.newInstance(Integer.valueOf(convertedTimeStr.split(':')[0]),Integer.valueOf(convertedTimeStr.split(':')[1]),Integer.valueOf(convertedTimeStr.split(':')[2]),0);
					
                    if((convertedCrtdTime >= bHour.MondayStartTime && convertedCrtdTime <= bHour.MondayEndTime) || (convertedCrtdTime >= bHour.TuesdayStartTime && convertedCrtdTime <= bHour.TuesdayEndTime) ||
                       (convertedCrtdTime >= bHour.WednesdayStartTime && convertedCrtdTime <= bHour.WednesdayEndTime) || (convertedCrtdTime >= bHour.ThursdayStartTime && convertedCrtdTime <= bHour.ThursdayEndTime) ||
                       (convertedCrtdTime >= bHour.FridayStartTime && convertedCrtdTime <= bHour.FridayEndTime) || (convertedCrtdTime >= bHour.SaturdayStartTime && convertedCrtdTime <= bHour.SaturdayEndTime) ||
                       (convertedCrtdTime >= bHour.SundayStartTime && convertedCrtdTime <= bHour.SundayEndTime)){
                        newlct.Business_Hours_Case__c = 'Yes';
                    }else{
                        newlct.Business_Hours_Case__c = 'No';
                    }
					*/

                    //SC-2489 code change whether the date time is during business hour(checks holiday and weekend) start
                    DateTime date1 = DateTime.now();

                    if(BusinessHours.isWithin(bHour.Id, date1)){
                        newlct.Business_Hours_Case__c = 'Yes';
                    }else{
                        newlct.Business_Hours_Case__c = 'No';
                    }
                    //SC-2489 end
                    bUpdated = true;
                }
            }
        }
        return bUpdated;
    }

}