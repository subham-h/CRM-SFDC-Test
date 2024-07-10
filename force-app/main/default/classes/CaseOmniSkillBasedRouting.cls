/*
* @author : Sreya
* @date : 25/01/2022
* @description : Class to build custom logic for omni skill based routing for Email and Portal Cases.

* Revision Ref Number    Date          Owner                  Description
* -------- ----------    -----------   -------------------    -----------
* 1.0      SC-4212       25-01-2022    Sreya                  Build custom logic for omni skill based routing for Email Cases.
* 2.0      SC-4212       25-01-2022    Sunil BS               Build custom logic for omni skill based routing for Email Cases when price owner is updated after ECC updates Case (To resolve Race condition)
* 3.0      SC-5448       30-06-2022    Sreya                  Capturing Omni Skill Type field on case based on the type of skill associated with the case. 
* 4.0      SC-7827       05-05-2023    Sunil BS               Made the omni rule priority order dynamic
* 5.0      SC-7826       09/06/2023    Nayana N Sharma        Subtype-based Service Relationship Routing logic added
* 6.0      SC-8274       30-06-2023    Nayana N Sharma        Made Queue skill as mandatory instead of Country skill, Added logic to handle owner update in defineCaseSkillMap method
*                                                             Added methods deletePSRForOmniEmail to handle PSR deletion for Owner update
* 7.0      SC-8264       27-06-2023    Sunil BS               Altered logic for direct assignement in omni where we check if preferred user if OOO if he is then route to an back up agent selected by countries
* 8.0      SC-8380       22-08-2023    Meghna Singh           Manual vs Auto Assignment flag to identify omni case
* 9.0      SC-9321       05-11-2023    Sunil BS               Made General skill as dynamic/optional
* 10.0     SC-8651       20-11-2023    Sunil BS               Modified class to enable routing for twill
* 11.0     SC-10048      15-05-2024    Nayana N Sharma        RFC-based Service Relationship Routing logic added
*															  Moved OOO logic to a new method due to redundancy
* 12.0     SC-10045      16-05-2024    Shahanawaz        	  Auto Case Assignment - Ocean - Based on Vessel Service and Vessel Service Journey Leg with Subtype or Reason for Case
*/
public class CaseOmniSkillBasedRouting {
    /**
* @description | Update omni skill type
* @param listNewCases accepts case list
* @param mapRelatedCareRelation accepts Care_Relationship__c map
* @param isUpdate accepts isUpdate
* @param isPortalCaseFlag accepts isportal
* @param caseMap accepts case map
* @param caseMapToUpdate accepts case map to updatecaseIterator
* SC-7083
*/
    public static void defineCaseSkillMap(List<Case> listNewCases, Map<Id,Care_Relationship__c> mapRelatedCareRelation, Map<Id,Client_Case_Assignments__c> mapKeyClient, Boolean isUpdate, Boolean isPortalCaseFlag, Map<Id,Case> caseMap, Map<Id,Case> caseMapToUpdate){
        try {
            if(Generic_TriggerHandler.validateRunForMethod('CaseOmniSkillBasedRouting.defineCaseSkillMap()',1)){
                Map<String, Case_OmniSkill_Mappings__c> skillMap = new Map<String, Case_OmniSkill_Mappings__c>();
                Map<Id, List<String>> mapCaseSkills = new Map<Id, List<String>>();
                List<PendingServiceRouting> listDirectPSR = new List<PendingServiceRouting>();
                List<PendingServiceRouting> listPSR = new List<PendingServiceRouting>();
                Map<String, String> mapCasePSR = new Map<String, String>();
                list<SkillRequirement> listNewSkills = new List<SkillRequirement>();
                Map<string, Omni_Service_Relationship_Mappings__c> mapSRMapping = new Map<string, Omni_Service_Relationship_Mappings__c>();
                Map<string, Omni_Service_Relationship_Mappings__c> mapSRSubtypeMapping = new Map<string, Omni_Service_Relationship_Mappings__c>();
                Map<string, Omni_Service_Relationship_Mappings__c> mapSRRfcMapping = new Map<string, Omni_Service_Relationship_Mappings__c>();  //SC-10048
                Map<string, Client_Case_Assignments__c> mapKeyClientSubtypeMapping = new Map<string, Client_Case_Assignments__c>();
                Map<String, String> originToJourneyLegMap = new Map<String, String>(); //SC-10045
                
                String strSkillType = '';
                List<Case> listCaseSkillType = new List<Case>();
                Map<String, String> mapSkillType = new Map<String, String>();
                set<id> inputCaseIds = new Set<id>();
                set<string> inputCaseOrigins = new Set<string>();
                String omniPriorityOrder = '';
                List<String> omniPriorityOrderlist = new List<String>();
                List<String> omniPriorityOrderAdditionalValueslist = new List<String>();
                Map<Id, String> caseIdOriginMap = new Map<Id, String>();
                LinerBrand_Direction_and_Country__mdt lbdcInscope = new LinerBrand_Direction_and_Country__mdt();
                Map<String, LinerBrand_Direction_and_Country__mdt> brandDirectionCountryMap = new Map<String, LinerBrand_Direction_and_Country__mdt>();
                map<string, General_Key_Value_Configurations__mdt> omniCaseSkillTypeMap = new Map<string, General_Key_Value_Configurations__mdt>();
                object omniSkillTypeFieldValue;
                String twillHQCargoFlowQueueSkillId = General_Key_Value_Configurations__mdt.getinstance('TwillHQCargoFlow').Second_Field_value__c;
                Map<String, Case_OmniSkill_Mappings__c> mandatorySkillsMap = new Map<String, Case_OmniSkill_Mappings__c>();
                //SC-8651
                Set<id> ownerIds = new Set<id>();
                Map<id, id> ownerIdsMap = new Map<id, id>();
                Map<Id, Group> mapOwnerQueues = new Map<Id, Group>();
                //SC-8651
                General_Key_Value_Configurations__mdt cargoFlowInstance = General_Key_Value_Configurations__mdt.getInstance('OmniSkillType7');
                String cargoFlow = cargoFlowInstance.First_Field_Value__c;
                String cargoFlowOmniSkillType = 'Cargo_Flow__c';
                General_Key_Value_Configurations__mdt globalTwillOriginInstance = General_Key_Value_Configurations__mdt.getInstance('GlobalTwillOrigin');
                String globalTwillOrigin = globalTwillOriginInstance.First_Field_Value__c;
                Map<string, General_Key_Value_Configurations__mdt> keyValuePairMap = new Map<string, General_Key_Value_Configurations__mdt>();
                list<String> omniSkipIdentifyingFieldValueList = General_Key_Value_Configurations__mdt.getInstance('omniSkipIdentifyingFieldValueList').First_Field_Value__c.split(';');
                Map<string, string> omniGlobalOriginCountriesMap = new Map<string, string>();
                String deliveryChannel = General_Key_Value_Configurations__mdt.getInstance('Delivery_Channel').first_field_value__c;
                Set<Id> accountIdsForKeyClient = new Set<Id>();
                
                for (General_Key_Value_Configurations__mdt keyvaluepair : [SELECT id, First_Field_Value__c, key__c FROM General_Key_Value_Configurations__mdt WHERE label LIKE '%DirectionAndDirectionCodeMap%']) {
                    keyValuePairMap.put(keyvaluepair.First_Field_Value__c, keyvaluepair);
                }
                
                //Get Mandatory skill records with Queue name as key
                for (Case_OmniSkill_Mappings__c maprec : [SELECT Case_Field__c, Value__c, Origin__c, Skill_Id__c FROM Case_OmniSkill_Mappings__c WHERE Active__c = TRUE AND Mandatory__c = TRUE]) {
                    mandatorySkillsMap.put(maprec.Value__c, maprec);
                }
                
                //Form brandDirectionCountryMap in order to identify case origin for portal cases
                if (isPortalCaseFlag == true) {
                    for(LinerBrand_Direction_and_Country__mdt lbdc : caseRecordselector.mapLBDCs.values()){
                        brandDirectionCountryMap.put(lbdc.Liner_Brand__c+';'+lbdc.Country_Name__c+';'+lbdc.Direction__c, lbdc);
                    }
                }
                
                //Check if omni is triggered by case update and if so get origin basis ownerid of the new queue value
                if(isUpdate){
                    for(Case caseiterator : listNewCases){
                        ownerIds.add(caseiterator.OwnerId);
                        ownerIdsMap.put(caseiterator.OwnerId, caseiterator.Id);
                    }
                    
                    if(!ownerIds.isEmpty()){
                        for(Group q : [SELECT Id, Developername, Name FROM group WHERE id IN :ownerIds]){
                            if(mandatorySkillsMap.containskey(q.Developername)) {
                                mapOwnerQueues.put(q.Id, q);
                                inputCaseOrigins.add(mandatorySkillsMap.get(q.Developername).Origin__c);
                                caseIdOriginMap.put(ownerIdsMap.get(q.id), mandatorySkillsMap.get(q.Developername).Origin__c);
                            }
                        }
                    }
                }
                
                for(Case caseiterator : listNewCases){
                    String caseCountry = '';
                    //case map wont be null if called from case classification future method
                    caseCountry = (caseMap != null && !caseMap.isEmpty() && caseMap.containsKey(caseIterator.Id)) ? caseMap.get(caseIterator.Id).Case_country__c : caseIterator.Case_country__c;
                    inputCaseIds.add(caseiterator.Id);
                    
                    if(caseiterator.AccountId != null){
                        accountIdsForKeyClient.add(caseiterator.AccountId);
                    }
                    if(caseiterator.On_Behalf_Account__c != null){
                        accountIdsForKeyClient.add(caseiterator.On_Behalf_Account__c);
                    }
                    
                    if(isUpdate){
                        continue;
                    }
                    //SC-8651 to cover both HQ cargo flow and Global twill origin
                    else if(!string.isBlank(caseiterator.delivery_channel__c) && deliveryChannel.contains(caseiterator.delivery_channel__c)){
                        inputCaseOrigins.add(globalTwillOrigin);
                        caseIdOriginMap.put(caseiterator.id, globalTwillOrigin);
                    }
                    //Get case origin for email to case
                    else if(!string.isBlank(caseiterator.origin) && isPortalCaseFlag == false){
                        inputCaseOrigins.add(caseiterator.origin);
                        caseIdOriginMap.put(caseiterator.id, caseiterator.origin);
                    }
                    //To form case origin for portal to case
                    else if(isPortalCaseFlag == true && !brandDirectionCountryMap.isempty() && brandDirectionCountryMap.containsKey(caseIterator.Liner_Brand__c+';'+caseCountry+';'+caseIterator.Direction__c)) {
                        inputCaseOrigins.add(brandDirectionCountryMap.get(caseIterator.Liner_Brand__c+';'+caseCountry+';'+caseIterator.Direction__c).DeveloperName);
                        caseIdOriginMap.put(caseIterator.Id, brandDirectionCountryMap.get(caseIterator.Liner_Brand__c+';'+caseCountry+';'+caseIterator.Direction__c).DeveloperName);
                    }
                }
                
                for(General_Key_Value_Configurations__mdt mapvalue : [SELECT First_Field_Name__c, First_Field_Value__c FROM General_Key_Value_Configurations__mdt WHERE Key__c LIKE '%OmniSkilltype%']){
                    mapSkillType.put(mapvalue.First_Field_Name__c, mapvalue.First_Field_Value__c);
                    omniCaseSkillTypeMap.put(mapvalue.First_Field_Name__c, mapvalue);
                }
                if (!inputCaseOrigins.isempty()) {
                    // Query for case and omnichannel skill mapping metadata for origins in picture
                    for(Case_OmniSkill_Mappings__c maprec : [SELECT Case_Field__c,Value__c,Value_2__c,Value_3__c,Origin__c,Skill_Id__c,Mandatory__c, Vessel_Journey_Leg__c FROM Case_OmniSkill_Mappings__c WHERE (origin__c IN :inputCaseOrigins OR Case_Field__c = 'Unassigned') AND Active__c = TRUE]) {
                        //Add mandatory skills with Origin as key
                        if (maprec.Mandatory__c == true) {
                            skillMap.put(maprec.Origin__c, maprec);
                        } 
                        else if (string.isnotblank(maprec.Value__c) && string.isnotblank(maprec.Value_2__c) && string.isnotblank(maprec.Value_3__c)) {
                            skillMap.put(maprec.Value__c+';'+maprec.Value_2__c+';'+maprec.Value_3__c+';'+maprec.Origin__c, maprec);
                        } 
                        else if(string.isnotblank(maprec.Value__c) && string.isnotblank(maprec.Value_2__c)) {
                            skillMap.put(maprec.Value__c+';'+maprec.Value_2__c+';'+maprec.Origin__c, maprec);
                        } 
                        else if(string.isnotblank(maprec.Value__c)) {
                            skillMap.put(maprec.Value__c + ';' + maprec.Origin__c, maprec);
                        }
                        
                        if(!String.isBlank(maprec.Vessel_Journey_Leg__c) && (originToJourneyLegMap.isEmpty() || !originToJourneyLegMap.containsKey(maprec.Origin__c))){
                            originToJourneyLegMap.put(maprec.Origin__c, maprec.Vessel_Journey_Leg__c);
                    }
                }
                }
                // Query for getting Service Relationship Mapping Origins along with Subtype and RFC
                for(Omni_Service_Relationship_Mappings__c mapInstance : [SELECT id, Active__c, Origin__c, Preferred_Agent__c, Sub_Type__c,Reason_for_Case__c FROM Omni_Service_Relationship_Mappings__c WHERE Active__c = TRUE]) {
                    if(mapInstance.Sub_Type__c!=null){
                        mapSRSubtypeMapping.put(mapInstance.Origin__c + ';' + mapInstance.Sub_Type__c,mapInstance);
                    }//SC-10048
                    else if(mapInstance.Reason_for_Case__c!=null){
                    	mapSRRfcMapping.put(mapInstance.Origin__c + ';' + mapInstance.Reason_for_Case__c,mapInstance);
                    }
                    else{
                        mapSRMapping.put(mapInstance.Origin__c, mapInstance);
                    }                    
                }
                
                for(Client_Case_Assignments__c KeymapInstance : [SELECT id, Active__c, Account__c, Direction__c,Country__c,Dedicated_Agent__c,Back_up_Dedicated_Agent__c,Sub_Type__c FROM Client_Case_Assignments__c WHERE Account__c != null AND Account__c=: accountIdsForKeyClient AND Sub_Type__c != NULL AND Active__c = TRUE]){
                    mapKeyClientSubtypeMapping.put(KeymapInstance.Account__c + ';' + KeymapInstance.Sub_Type__c,KeymapInstance);
                }
                
                //Query the routing config for email
                QueueRoutingConfig routingConfig = [SELECT RoutingPriority, CapacityWeight, RoutingModel, PushTimeout FROM QueueRoutingConfig WHERE DeveloperName = 'Email' LIMIT 1];
                
                //Query the service channel for email
                String channel = General_Key_Value_Configurations__mdt.getinstance('OmniServiceChannelEmail').First_Field_Value__c;        
                
                list<PendingServiceRouting> psrInScope = new List<PendingServiceRouting>();
                if (!inputCaseIds.isEmpty()) {
                    psrInScope = [SELECT id, workitemid FROM PendingServiceRouting WHERE workitemid IN :inputCaseIds];
                }
                map<id, PendingServiceRouting> mapPSR = new Map<id, PendingServiceRouting>();
                
                for(PendingServiceRouting psrinstance : psrInScope){
                    mapPSR.put(psrinstance.workitemid, psrinstance);
                }
                
                List<String> twillPortalCountryList = new List<String>();
                for(General_Key_Value_Configurations__mdt gen : [SELECT Key__c, First_Field_Value__c, Second_Field_Value__c FROM General_Key_Value_Configurations__mdt WHERE Key__c = 'OmniGlobalOriginPortalOptedCountries']) {
                    if(!String.isEmpty(gen.First_Field_Value__c) && !String.isEmpty(gen.Second_Field_Value__c)){
                        list<string> countriesOpted = new List<string>();
                        countriesOpted.addall(gen.Second_Field_Value__c.split(';'));
                        for(string countryName : countriesOpted){
                            omniGlobalOriginCountriesMap.put(gen.First_Field_Value__c + ';' + countryName, gen.Second_Field_Value__c);
                        }
                    }
                }
                
                List<String> twillCargoFlowPortalCountryList = new List<String>();
                for(General_Key_Value_Configurations__mdt gen : [SELECT Key__c, First_Field_Value__c FROM General_Key_Value_Configurations__mdt WHERE Key__c = 'OmniTwillCargoFlowPortalOptedCountries']) {
                    if (!String.isEmpty(gen.First_Field_Value__c)) {
                        twillCargoFlowPortalCountryList.addAll(gen.First_Field_Value__c.trim().split(';'));
                    }
                }
                
                Map<Id, OutOfOffice> userOutofofficeMap = new Map<Id, Outofoffice>();
                for(OutOfOffice outOfOfficeInstance : [SELECT Id,StartDate,EndDate,Message,IsEnabled,User.TimeZoneSidKey,userid FROM OutOfOffice]){
                    userOutofofficeMap.put(outOfOfficeInstance.userid, outOfOfficeInstance);
                }
                
                for (Case caseIterator : listNewCases) {
                    //Clear the global variable so next case iterations skill type can be held
                    Id srPreferredUserId;
                    Id KeyClientDedicatedUserId;
                    strSkillType = '';
                    //SC-9321
                    Boolean countryHasGeneral = false;
                    omniSkillTypeFieldValue = '';
                    String mandatorySkill = '';
                    String caseOrigin = '';
                    lbdcInscope = new LinerBrand_Direction_and_Country__mdt();
                    omniPriorityOrderlist = new List<string>();
                    omniPriorityOrderAdditionalValueslist = new List<string>();
                    
                    //SC-8274 - Change mandatory skill as Case queue name skill instead of country skill.
                    //ownerName helps to know what is the queue of the case in scope so that during case update we can identify the new origin in scope as the origin which was stamped during case creation is now redundant
                    //SC-8561 - Stamp origin for twill cases as MSLGLOBALTWILL
                    caseOrigin = caseIdOriginMap.get(caseIterator.id);
                    if(string.isnotblank(caseOrigin) && skillMap.containsKey(caseOrigin) && !mapPSR.containskey(caseIterator.id)){
                        mandatorySkill = skillMap.get(caseOrigin).Skill_Id__c;                        
                        //Identify the Agent to be selected as case owner basis Service Relationship Exlusion Metadata
                        String businessPartner = '';
                        businessPartner = (caseMap != null && !caseMap.isEmpty() && caseMap.containsKey(caseIterator.Id)) ? caseMap.get(caseIterator.Id).Care_Relationship_Business_Partner__c : caseIterator.Care_Relationship_Business_Partner__c;
                        String gscAgent = '';
                        gscAgent = (caseMap != null && !caseMap.isEmpty() && caseMap.containsKey(caseIterator.Id)) ? caseMap.get(caseIterator.Id).Care_Relationship_GSC_Agent__c : caseIterator.Care_Relationship_GSC_Agent__c;
                        String backupAgent = '';
                        backupAgent = (caseMap != null && !caseMap.isEmpty() && caseMap.containsKey(caseIterator.Id)) ? caseMap.get(caseIterator.Id).Backup_Agent__c : caseIterator.Backup_Agent__c;
                        String caseCountry = '';
                        caseCountry = (caseMap != null && !caseMap.isEmpty() && caseMap.containsKey(caseIterator.Id)) ? caseMap.get(caseIterator.Id).Case_country__c : caseIterator.Case_country__c;
                        
                        //SC-8651 Skip Routing Twill cargo countries which have not opted for portal to case
                        if (caseIterator.Cargo_Flow__c == true && string.isnotblank(caseIterator.Delivery_channel__c) && deliveryChannel.contains(caseIterator.Delivery_channel__c) && string.isnotblank(caseIterator.Case_channel__c) &&
                            (caseIterator.Case_channel__c == 'Portal' || caseIterator.Case_channel__c == 'Website') && string.isnotblank(caseCountry) &&
                            !twillCargoFlowPortalCountryList.isEmpty() && !twillCargoFlowPortalCountryList.contains(caseCountry)){
                                continue;
                            }
                        
                        //SC-8651 Skip Routing Global Origin for countries which have not opted for portal to case
                        if(isPortalCaseFlag == true && string.isnotblank(caseCountry) && string.isnotblank(caseIterator.Case_channel__c) && (caseIterator.Case_channel__c == 'Portal' || caseIterator.Case_channel__c == 'Website') &&
                           !omniGlobalOriginCountriesMap.isempty() && !omniGlobalOriginCountriesMap.containskey(caseOrigin + ';' + caseCountry) && (caseOrigin.contains('Global'))) {
                               continue;
                           }
                        
                        if(
                            (mapRelatedCareRelation != null && !mapRelatedCareRelation.isEmpty()) && String.isNotBlank(caseIterator.Care_Relationship__c) &&
                            (mapRelatedCareRelation.ContainsKey(caseIterator.Care_Relationship__c) && mapRelatedCareRelation.get(caseIterator.Care_Relationship__c) != null) &&
                            (String.isNotBlank(businessPartner) || String.isNotBlank(gscAgent) || String.isNotBlank(backupAgent))) {
                                Id sRPreferredAgentId = null;                            
                                //SC-7826 - Subtype-based SR Routing
                                if (mapSRSubtypeMapping.containsKey(caseOrigin + ';' + caseIterator.Sub_Type__c) && mapSRSubtypeMapping.get(caseOrigin + ';' + caseIterator.Sub_Type__c) != null) {
                                    list<string> sRPreferredAgents = mapSRSubtypeMapping.get(caseOrigin + ';' + caseIterator.Sub_Type__c).Preferred_Agent__c.split(';');
                                    for(String sRPreferredAgentInstance : sRPreferredAgents) {
                                        if(mapRelatedCareRelation.get(caseIterator.Care_Relationship__c).get(sRPreferredAgentInstance) != null) {
                                            sRPreferredAgentId = (id) mapRelatedCareRelation.get(caseIterator.Care_Relationship__c).get(sRPreferredAgentInstance);
                                            Boolean isAgentOoo = false;
                                            if(sRPreferredAgentId!=null){
                                            	isAgentOoo = checkOOOforAgents(sRPreferredAgentId, userOutofofficeMap);
                                            }                                            
                                            if(isAgentOoo){
                                                continue;
                                            }
                                            srPreferredUserId = sRPreferredAgentId;
                                            break;
                                        } 
                                    }
                                }
                                //SC-10048 - RFC-based SR Routing
                                else if (mapSRRfcMapping.containsKey(caseOrigin + ';' + caseIterator.Reason_for_Case__c) && mapSRRfcMapping.get(caseOrigin + ';' + caseIterator.Reason_for_Case__c) != null) {
                                    list<string> sRPreferredAgents = mapSRRfcMapping.get(caseOrigin + ';' + caseIterator.Reason_for_Case__c).Preferred_Agent__c.split(';');
                                    for(String sRPreferredAgentInstance : sRPreferredAgents) {
                                        if(mapRelatedCareRelation.get(caseIterator.Care_Relationship__c).get(sRPreferredAgentInstance) != null) {
                                            sRPreferredAgentId = (id) mapRelatedCareRelation.get(caseIterator.Care_Relationship__c).get(sRPreferredAgentInstance);
                                            Boolean isAgentOoo = false;
                                            if(sRPreferredAgentId!=null){
                                            	isAgentOoo = checkOOOforAgents(sRPreferredAgentId, userOutofofficeMap);
                                            }                                            
                                            if(isAgentOoo){
                                                continue;
                                            }
                                            srPreferredUserId = sRPreferredAgentId;
                                            break;
                                        } 
                                    }
                                }
                                // If not SR+Subtype routing then only SR routing is to be done
                                else if(mapSRMapping.containsKey(caseOrigin) && (mapSRMapping.get(caseOrigin) != null)){
                                    list<string> sRPreferredAgents = mapSRMapping.get(caseOrigin).Preferred_Agent__c.split(';');
                                    for (String sRPreferredAgentInstance : sRPreferredAgents) {
                                        if (mapRelatedCareRelation.get(caseIterator.Care_Relationship__c).get(sRPreferredAgentInstance) != null){
                                            sRPreferredAgentId = (id) mapRelatedCareRelation.get(caseIterator.Care_Relationship__c).get(sRPreferredAgentInstance);
                                            Boolean isAgentOoo = false;
                                            if(sRPreferredAgentId!=null){
                                            	isAgentOoo = checkOOOforAgents(sRPreferredAgentId, userOutofofficeMap);
                                            }                                            
                                            if(isAgentOoo){
                                                continue;
                                            }
                                            srPreferredUserId = sRPreferredAgentId;
                                            break;
                                        }
                                    }
                                }
                            }
                        // key client
                        Id KeyClientAccount = String.isNotBlank(caseIterator.On_Behalf_Account__c) ? caseIterator.On_Behalf_Account__c : caseIterator.AccountId;
                        if (
                            (mapKeyClientSubtypeMapping != null &&!mapKeyClientSubtypeMapping.isEmpty()) &&
                            (mapKeyClientSubtypeMapping.ContainsKey(KeyClientAccount + ';' + caseIterator.Sub_Type__c) &&
                             mapKeyClientSubtypeMapping.get(KeyClientAccount + ';' + caseIterator.Sub_Type__c) !=  null)){
                                 Id keyClientPreferredAgentId = null;
                                 Client_Case_Assignments__c keyClientAssignment = mapKeyClientSubtypeMapping.get(KeyClientAccount + ';' + caseIterator.Sub_Type__c);
                                 
                                 if (keyClientAssignment.Country__c == caseIterator.Country__c && keyClientAssignment.Direction__c == caseIterator.Direction__c) {
                                     keyClientPreferredAgentId = keyClientAssignment.Dedicated_Agent__c;
                                     Boolean isAgentOoo = false;
                                     if(keyClientPreferredAgentId!=null){
                                         isAgentOoo = checkOOOforAgents(keyClientPreferredAgentId, userOutofofficeMap);
                                     }
                                     
                                     if(isAgentOoo){
                                         if (String.isNotBlank(keyClientAssignment.Back_up_Dedicated_Agent__c)) {
                                             keyClientPreferredAgentId = keyClientAssignment.Back_up_Dedicated_Agent__c;
                                         }
                                     }
                                 }
                                 
                                 if (keyClientPreferredAgentId != null) {
                                     KeyClientDedicatedUserId = keyClientPreferredAgentId;
                                 }
                             }
                        
                        
                        lbdcInscope = LinerBrand_Direction_and_Country__mdt.getinstance(caseOrigin);
                        if (lbdcInscope == null) {
                            continue;
                        }
                        
                        if(lbdcInscope != null && string.isNotBlank(lbdcInscope.Omni_Channel_Priority_Rule__c)) {
                            omniPriorityOrder = lbdcInscope.Omni_Channel_Priority_Rule__c;
                            omniPriorityOrderlist = omniPriorityOrder.split(';');
                            //SC-9321
                            if(lbdcInscope.Omni_Channel_Priority_Rule__c.contains('General')){
                                countryHasGeneral = true;
                            }
                        }
                        if (!omniPriorityOrderlist.isEmpty()) {
                            omniPriorityOrderAdditionalValueslist = omniPriorityOrderlist;
                            omniPriorityOrderAdditionalValueslist.addall(General_Key_Value_Configurations__mdt.getInstance('omniAdditionalValuesnotinprioritylist').First_Field_Value__c.split(';'));
                        }
                        // Loop through the priority order countries have choosen
                        for (String omniSkillType : omniPriorityOrderlist) {
                            if (String.isnotblank(strSkillType)) {
                                break;
                            }
                            //Route basis priority choosen by the areas from the LBDC metadata record
                            //SC-9321
                            //SC-8651 Excluded for twill
                            omniSkillTypeFieldValue = '';
                            if (omniSkillType == 'Cargo_Flow__c') {
                                if(caseIterator.Cargo_Flow__c){
                                    omniSkillTypeFieldValue = 'Cargo Flow';
                                }                           
                            }
                            else if (omniSkipIdentifyingFieldValueList.contains(omniSkillType)) {
                                omniSkillTypeFieldValue = omniSkillType;
                            } 
                            else if(omniCaseSkillTypeMap.get(omniSkillType) != null && caseIterator.get(omniSkillType) != null) {
                                omniSkillTypeFieldValue = caseIterator.get(omniSkillType);
                            }
                            
                            //SC-10045
                            if(omniSkillType == 'Vessel_Service_Numbers__c' && !originToJourneyLegMap.isEmpty()){
                                omniSkillTypeFieldValue = getVesselServiceValue(caseIterator, caseOrigin, omniSkillType, originToJourneyLegMap);
                            }
                            
                            //Direct case owner Assignment by checking Service Relationship
                            if (omniSkillType == 'Care_Relationship__c' && String.isNotBlank(srPreferredUserId)) {
                                // Initiate direct routing with the Primary Agent
                                PendingServiceRouting psr = new PendingServiceRouting();
                                psr.workItemId = caseIterator.Id;
                                psr.RoutingType = 'SkillsBased';
                                psr.RoutingPriority = routingConfig.RoutingPriority;
                                psr.CapacityWeight = routingConfig.CapacityWeight;
                                psr.RoutingModel = routingConfig.RoutingModel;
                                psr.ServiceChannelId = channel;
                                psr.IsPreferredUserRequired = true;
                                psr.PreferredUserId = srPreferredUserId;
                                psr.IsReadyForRouting = true;
                                listDirectPSR.add(psr);
                                strSkillType = mapSkillType.get('Care_Relationship__c');
                                if(String.isNotBlank(strSkillType)) {
                                    if ((caseMapToUpdate.isEmpty() || !caseMapToUpdate.containsKey(caseIterator.Id))) {
                                        caseMapToUpdate.put(caseIterator.Id,new Case(Id = caseIterator.Id,Omni_Skill_Type__c = strSkillType));
                                    } 
                                    else {
                                        caseMapToUpdate.get(caseIterator.Id).Omni_Skill_Type__c = strSkillType;
                                    }
                                }
                                break;
                            }
                            
                            if(omniSkillType == 'Client Dedicated' && String.isNotBlank(KeyClientDedicatedUserId)) {
                                // Initiate direct routing with the Primary Agent
                                PendingServiceRouting psr = new PendingServiceRouting();
                                psr.workItemId = caseIterator.Id;
                                psr.RoutingType = 'SkillsBased';
                                psr.RoutingPriority = routingConfig.RoutingPriority;
                                psr.CapacityWeight = routingConfig.CapacityWeight;
                                psr.RoutingModel = routingConfig.RoutingModel;
                                psr.ServiceChannelId = channel;
                                psr.IsPreferredUserRequired = true;
                                psr.PreferredUserId = KeyClientDedicatedUserId;
                                psr.IsReadyForRouting = true;
                                listDirectPSR.add(psr);
                                strSkillType = mapSkillType.get('Client Dedicated');
                                if(String.isNotBlank(strSkillType)) {                            
                                    if((caseMapToUpdate.isEmpty() || !caseMapToUpdate.containsKey(caseIterator.Id)) ) {
                                        caseMapToUpdate.put(caseIterator.Id, new Case(Id = caseIterator.Id,Omni_Skill_Type__c = strSkillType));
                                    } 
                                    else{
                                        caseMapToUpdate.get(caseIterator.Id).Omni_Skill_Type__c = strSkillType;
                                    }
                                }
                                break;
                            }
                            
                            for(String omniSkillType2 : omniPriorityOrderAdditionalValueslist){
                                if(String.isnotblank(strSkillType)){
                                    break;
                                }
                                
                                if(omniSkillType2 == 'Care_Relationship__c' || omniSkillType2 == 'Client Dedicated'){
                                    continue;
                                }
                                
                                object omniSkillTypeFieldValue2;
                                omniSkillTypeFieldValue2 = '';
                                if(omniSkillType2 == 'Case_Country__c') {
                                    omniSkillTypeFieldValue2 = casecountry;
                                }
                                else if(omniSkillType2 == 'Cargo_Flow__c') {
                                    if(caseIterator.Cargo_Flow__c){
                                        omniSkillTypeFieldValue2 = 'Cargo Flow';
                                    }
                                }
                                else if(omniSkipIdentifyingFieldValueList.contains(omniSkillType2)) {
                                    omniSkillTypeFieldValue2 = omniSkillType2;
                                } 
                                else if(omniCaseSkillTypeMap.get(omniSkillType2) != null && caseIterator.get(omniSkillType2) != null ){
                                    omniSkillTypeFieldValue2 = caseIterator.get(omniSkillType2);
                                } 
                                
                                //SC-10045
                                if(omniSkillType2 == 'Vessel_Service_Numbers__c' && !originToJourneyLegMap.isEmpty()){
                                    omniSkillTypeFieldValue2 = getVesselServiceValue(caseIterator, caseOrigin, omniSkillType2, originToJourneyLegMap);
                                }
                                
                                for(String omniSkillType3 : omniPriorityOrderAdditionalValueslist){
                                    if (string.isnotblank(strSkillType)) {
                                        break;
                                    }
                                    
                                    if (omniSkillType3 == 'Care_Relationship__c' || omniSkillType2 == 'Client Dedicated') {
                                        continue;
                                    }
                                    
                                    object omniSkillTypeFieldValue3;
                                    omniSkillTypeFieldValue3 = '';
                                    if (omniSkillType3 == 'Case_Country__c') {
                                        omniSkillTypeFieldValue3 = casecountry;
                                    } 
                                    else if (omniSkillType3 == 'Cargo_Flow__c') {
                                        if(caseIterator.Cargo_Flow__c){
                                            omniSkillTypeFieldValue3 = 'Cargo Flow';
                                        }
                                    } 
                                    else if(omniSkipIdentifyingFieldValueList.contains(omniSkillType3)){
                                        omniSkillTypeFieldValue3 = omniSkillType3;
                                    } 
                                    else if(omniCaseSkillTypeMap.get(omniSkillType3) != null && caseIterator.get(omniSkillType3) != null){
                                        omniSkillTypeFieldValue3 = caseIterator.get(omniSkillType3);
                                    }
                                    
                                    //SC-10045
                                    if(omniSkillType3 == 'Vessel_Service_Numbers__c' && !originToJourneyLegMap.isEmpty()){
                                        omniSkillTypeFieldValue3 = getVesselServiceValue(caseIterator, caseOrigin, omniSkillType3, originToJourneyLegMap);
                                    }
                                    //SC-8651 Logic to get skills for routing for cases with 3 values in scope
                                    if(!SkillMap.isEmpty() && SkillMap.containsKey(omniSkillTypeFieldValue+';'+omniSkillTypeFieldValue2+';'+omniSkillTypeFieldValue3+';'+caseOrigin)){
                                        String skillTypeIdList = SkillMap.get(omniSkillTypeFieldValue+';'+omniSkillTypeFieldValue2+';'+omniSkillTypeFieldValue3+';'+caseOrigin).Skill_Id__c;
                                        List<String> skillList = new List<String>();
                                        skillList = skillTypeIdList.split(';');
                                        skillList.add(mandatorySkill);
                                        mapCaseSkills.put(caseIterator.Id, skillList);
                                        strSkillType = mapSkillType.get(omniSkillType);
                                    }
                                    //SC-8651 Logic to get skills for routing for cases with 2 values in scope
                                    else if(!SkillMap.isEmpty() && SkillMap.containsKey(omniSkillTypeFieldValue + ';' + omniSkillTypeFieldValue2 + ';' + caseOrigin)){
                                        String skillTypeIdList = SkillMap.get(omniSkillTypeFieldValue+';'+omniSkillTypeFieldValue2+';'+caseOrigin).Skill_Id__c;
                                        List<String> skillList = new List<String>();
                                        skillList = skillTypeIdList.split(';');
                                        if(mapSkillType.get(omniSkillType) == 'Cargo Flow'){
                                            skillList.add(twillHQCargoFlowQueueSkillId);
                                        }
                                        else{
                                            skillList.add(mandatorySkill);
                                        }
                                        mapCaseSkills.put(caseIterator.Id, skillList);
                                        strSkillType = mapSkillType.get(omniSkillType);
                                    }
                                    //Apart from Service Relationship for rest of the skill types pick value from case omni skill map
                                    //SC-8651 Excluded for twill
                                    else if(omniSkillTypeFieldValue != null && skillMap.ContainsKey(omniSkillTypeFieldValue + ';' + caseOrigin) && (omniSkillType != 'Care_Relationship__c' && omniSkillType != 'Client Dedicated')) {
                                        String skillTypeIdList = SkillMap.get(omniSkillTypeFieldValue+';'+caseOrigin).Skill_Id__c;
                                        List<String> skillList = new List<String>();
                                        skillList = skillTypeIdList.split(';');
                                        skillList.add(mandatorySkill);
                                        mapCaseSkills.put(caseIterator.Id, skillList);
                                        strSkillType = mapSkillType.get(omniSkillType);
                                    }
                                    
                                    if (string.isnotblank(strSkillType)) {
                                        break;
                                    }
                                }
                            }
                        }
                        
                        // General skill need to be mapped if no valid skills are identified for the case.
                        //SC-9321
                        if(String.isBlank(strSkillType) && countryHasGeneral == true && !caseOrigin.containsIgnoreCase('Global')){
                            String defaultSkill = skillMap.get('General;Global').Skill_Id__c;
                            mapCaseSkills.put(caseIterator.Id, new List<String>{ defaultSkill, mandatorySkill });
                            strSkillType = mapSkillType.get('General');
                        }
                        
                        //SC-5448 : Updating Omni_Skill_Type__c field on case based on the category of the skill.
                        if(strSkillType != 'Service Relationship' && strSkillType != 'Client Dedicated') {
                            if(caseMapToUpdate == null){
                                caseMapToUpdate = new Map<Id, Case>();
                            }
                            if (caseMapToUpdate == null || caseMapToUpdate.isEmpty() || !caseMapToUpdate.containsKey(caseIterator.Id)) {
                                caseMapToUpdate.put(caseIterator.Id, new Case( Id = caseIterator.Id, Omni_Skill_Type__c = strSkillType, ownerid = caseIterator.ownerid));
                            } 
                            else {
                                caseMapToUpdate.get(caseIterator.Id).Omni_Skill_Type__c = strSkillType;
                            }
                        }
                    } 
                    else {
                        if(caseMapToUpdate == null){
                            caseMapToUpdate = new Map<Id, Case>();
                        }
                        if (caseMapToUpdate == null || caseMapToUpdate.isEmpty() || !caseMapToUpdate.containsKey(caseIterator.Id)) {
                            caseMapToUpdate.put(caseIterator.Id, new Case( Id = caseIterator.Id, Omni_Skill_Type__c = strSkillType, ownerid = caseIterator.ownerid));
                        } 
                        else {
                            caseMapToUpdate.get(caseIterator.Id).Omni_Skill_Type__c = strSkillType;
                        }
                    }
                }
                
                for(Case caseIterator : listNewCases){
                    if(!mapCaseSkills.isEmpty() && mapCaseSkills.containsKey(caseIterator.Id) && mapCaseSkills.get(caseIterator.Id) != null){
                        // New instance of PSR to be created for every case.
                        if (!mapCaseSkills.get(caseIterator.Id).isEmpty()) {
                            PendingServiceRouting psr = new PendingServiceRouting();
                            psr.workItemId = caseIterator.Id;
                            psr.RoutingType = 'SkillsBased';
                            psr.RoutingPriority = routingConfig.RoutingPriority;
                            psr.CapacityWeight = routingConfig.CapacityWeight;
                            psr.PushTimeout = routingConfig.PushTimeout;
                            psr.RoutingModel = routingConfig.RoutingModel;
                            psr.ServiceChannelId = channel;
                            psr.IsReadyForRouting = false;
                            listPSR.add(psr);
                        }
                    }
                }
                
                if(!listDirectPSR.isEmpty()){
                    database.insert(listDirectPSR, false);
                }
                
                if(!listPSR.isEmpty()){
                    database.insert(listPSR, false);
                }
                
                for(PendingServiceRouting psr : listPSR){
                    mapCasePSR.put(psr.workItemId, psr.Id);
                }
                
                // SkillRequirement to be created for all the identified skills for the case
                for(String caseId : mapCaseSkills.keySet()) {
                    if(mapCasePSR.containsKey(caseId)) {
                        for (String skillId : mapCaseSkills.get(caseId)) {
                            SkillRequirement newSkill = new SkillRequirement(RelatedRecordId = mapCasePSR.get(caseId), SkillId = skillId);
                            listNewSkills.add(newSkill);
                        }
                    }
                }
                
                if(!listNewSkills.isEmpty()){
                    Database.insert(listNewSkills, false);
                }
                
                for(PendingServiceRouting psr : listPSR){
                    psr.IsReadyForRouting = true;
                }
                
                if(!listPSR.isEmpty()){
                    database.update(listPSR, false);
                }
                
                //SC-5448 : Updating Omni_Skill_Type__c field on case based on the category of the skill
                // For after insert a new case instance is created and skill info is updated
                if (caseMap == null && !caseMapToUpdate.isempty()) {
                    TriggerExecutionController.skipCaseTrigger(true);
                    List<Database.SaveResult> lstSaveResults = Database.update(caseMapToUpdate.values(), false);
                    TriggerExecutionController.skipCaseTrigger(false);
                    ErrorLogger.writeErrors('SFDC', 'Case'+listNewCases[0].caseNumber, 'CaseOmniSkillBasedRouting.defineCaseSkillMap', lstSaveResults, listCaseSkillType);
                }
            }
        } catch (Exception ex) {
            ErrorLogger.writeErrors('SFDC', 'Case'+listNewCases[0].caseNumber, 'CaseOmniSkillBasedRouting.defineCaseSkillMap2', new List<Exception>{ex});
        }
    }
     /**
* @description | Check OOO
* @param sRPreferredAgentId accepts UserId
* @param isOoo returns true if OOO else false
*/
    public static Boolean checkOOOforAgents(Id sRPreferredAgentId, Map<id, OutOfOffice> userOutofofficeMap){      
        //Query Out of Office records which us help us know if user is working before doing direct ownership assignment
        OutofOffice objOOO = useroutofOfficeMap.get(sRPreferredAgentId);        
        Boolean isOoo = false;
        if (objOOO != null) {
            String strtdt = objOOO.StartDate.format('yyyy-MM-dd HH:mm:ss',objOOO.User.TimeZoneSidKey);
            Datetime strtdate = Datetime.valueOf(strtdt);
            Date startDate = Date.newInstance(strtdate.year(),strtdate.month(),strtdate.day());
            Date endDate = Date.newInstance(objOOO.EndDate.year(),objOOO.EndDate.month(),objOOO.EndDate.day());
            if (objOOO.IsEnabled = true && system.today() >= startdate && system.today() <= endDate) {
                isOoo=true;
            }
        }
        return isOoo;
    }
	/**
* @description | get vessel service value
* @param caseIterator accepts case
* @param caseOrigin accepts case origin
* @param omniSkillType accepts omni skill type
* @param originToJourneyLegMap accepts origin journey leg map
* SC-10045
*/
    public static String getVesselServiceValue(Case caseIterator, String caseOrigin, String omniSkillType, Map<String, String> originToJourneyLegMap){
        String omniSkillTypeFieldValue = '';
        String vesselServices = (String)caseIterator.get(omniSkillType);
        String jrnyLeg = originToJourneyLegMap.get(caseOrigin);
        if(!String.isBlank(vesselServices)){
            List<String> vesselServiceList = vesselServices.split(',');
            if(jrnyLeg == 'First Leg'){
                omniSkillTypeFieldValue = vesselServiceList[0];
            }
            else if(jrnyLeg == 'Last Leg'){
                omniSkillTypeFieldValue = vesselServiceList[vesselServiceList.size() - 1];
            }
        }
        return omniSkillTypeFieldValue;        
    }
    /**
* @description | Delete PSR
* @param caseIds accepts case Ids
* @param lstCase accepts case list
* SC-7083
*/
    public static void deletePSRForOmniEmail(Set<Id> caseIds, List<Case> lstCase){
        try {
            String psrDeletionExclusionUsers = General_Key_Value_Configurations__mdt.getInstance('PSRDeletionExclusionUser').First_Field_Value__c;
            List<PendingServiceRouting> psrInScope = new List<PendingServiceRouting>();
            if (!caseIds.isempty()) {
                psrInScope = [SELECT id, workitemid FROM PendingServiceRouting WHERE workitemid IN :caseIds];
            }
            
            if (!psrDeletionExclusionUsers.contains(UserInfo.getUserId()) && !psrDeletionExclusionUsers.contains(UserInfo.getProfileId())) {
                //SC-8380 Changing the status as manually assigned for ownership change
                // This is not done only for cases with psr because if once agent picks via omni and re-assigns it to another queue which is not in omni scope
                // manually then too it has to be captured as manually assigned
                for(Case cs : lstCase){
                    cs.Auto_Assignment_Indicator__c = 'Manually Assigned';
                }
                if(!psrInScope.isempty()){
                    Database.DeleteResult[] resultsList = Database.delete(psrInScope, false);
                    ErrorLogger.writeErrors('SFDC', 'Case', 'CaseOmniSkillBasedRouting.deletePSRForOmniEmail'+caseIds, resultsList, psrInScope);
                }
            }
        }
        catch(Exception e){
            ErrorLogger.writeErrors('SFDC', 'Case', 'CaseOmniSkillBasedRouting.deletePSRForOmniEmail' + caseIds,new List<Exception>{ e });
        }
    }
}