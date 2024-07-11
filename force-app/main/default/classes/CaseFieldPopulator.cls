/** 
* @description 
* Author   : Ragu
* Purpose  : Utility class to hold simple and reusable functionalities for auto populating Case fields. 
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-002633   18-Feb-2016 Ragu@UST                Created and optimized for implementing CBO (Centralized By Org) trigger architecture.
* 1.1      RQ-002679   08-Apr-2016 Jiji@UST                To Reset Refresh GCSS Data Check box to False.
* 1.2      RQ-003719   03-May-2016 Ragu@UST                Changes done by IBM to resolve production issue is incorporated in the new trigger.
* 1.3      RQ-003041   03-May-2016 Sandhya@UST             Populate Case Country for Internal Contacts
* 1.4      RQ-004058   07-Jun-2016 Sandhya@UST             Assign ISR Queues based on Case Liner Brand
* 1.5      RQ-002879   19/07/2016  Jiji@UST                To populate liner brand from single branded contact(MDM)
* 1.6      RQ-004350   06/12/2016  Nirmal@ust              To Populate account and contact Id  from logged in user
* 1.7      RQ-004424   20-Dec-2016 Subha@UST               To populate Direction for portal only created cases based on Case Type Sub Type Direction Map.
* 2.0      RQ-004298   02-Jan-2017 Ragu@UST                Internal contacts not linking to cases when sent cross brand.
* 2.1      RQ-004634   01-Feb-2017 Ragu@UST                Populate Liner Brand from Parent case to ISR case created through Publisher action
* 2.2      RQ-004569   12-Apr-2017 Ragu@UST                Populate MLL__c for cases created via chat for MLL customers (liveagent.addCustomDetail is not working properly for boolean variables).
* 2.3      RQ-004895   23-Mar-2017 Nisha@UST               Verification of Case liner brand against the matched contact only fires for non-deduplicated non-shipping party contacts.
* 3.0      RQ-005636   25-Sep-2017 Nisha@UST               Update references of GlobalErrorLogger
* 4.0      RQ-007579   18-Jan-2018 Nisha@Ust               To remove the linerbrand check in populating the contact and account for the cases that belongs to the nsp contact, since nsp contact are deduped.         
* 5.0      RQ-009034   7-Aug-2018  Ranjini@ust             To add Dispute cases to duplicate management (Thread topic id)
* 6.0      RQ-008889   24-Sep-2018 Nisha@Ust               Prevent survey sent to internal contacts.
* 7.0      RQ-009414   10-0ct-2018 Nisha@Ust               Added check to ensure '@'is available in the supplied email to avoid exception.
* 8.0      RQ-008925   21-01-2019  Naved@maersk            Liner brand ,Direction and Country fields for case to be updated automatically
* 9.0      RQ-011027   11-06-2019  Sriram@maersk           AccountId to change automatically with change in contactId
* 10.0     RQ-011433   22-08-2019  Sreya@Maersk            Modified the Logic for Updating Thread Topic Field.
* 11.0     RQ-012299   13-11-2019  Ranjini@UST             Updated the code for closure language code.
* 17.0     RQ-012315   15-Nov-2019 Ranjini@ust             Twill changes.
* 18.0     RQ-012781   9-Dec-2019  Ranjini@ust              CSAT Issue fix
* 19.0     SC-199      23-03-2020  Ranjini@ust              Twill Value Proposition changes.
* 20.0     SC-160     02-04-2020  Ramadevi@ust             Implemented Trigger recurrsion for few methods.
* 21.0     SC-290      04-05-2020  Avinash@ust             Visibility & Direction for Ocean - SFDC To Portal
* 22.0     SC-481      13-05-2020  Ramadevi@ust            Removing recurrsion for caseDetailsBasedonQueue as Region and Cluster are getting null
* 23.0     SC-399      09-06-2020 Avinash@ust               Case Visibility - Manually created External Case
* 24.0     SC-390      10-06-2020 Sreya@Maersk              Case Visibility update for Email to Case and Portal cases.
* 25.0     SC-400      11-06-2020  sriram@maersk            Case Visibility - ISR
* 26.0     SC-394      16-06-2020  ramadevi@ust             Populate On behalf of account on case
* 27.0     SC-594      25-06-2020  Sunil BS                 Populate "BE Code" field of case for all record types with his Accounts "Damco BE Code"
* 28.0     SC-493      07-07-20202 Avinash@ust              Value Proposition Identification for Twill Cases
* 29.0     SC-675      13-07-2020  Sreya@Maersk             Update Competitor Claims checkbox based on Case Visibility.
* 30.0     SC-825      24-08-2020  Nivedita@ust          User 'Manager' Fields as a filter on CM
* 31.0     SC-1005     07-09-2020  Avinash@ust              Identify Shipment Number from Case
* 32.0     SC-1056     08-09-2020  Sriram                   temporary fix  for SCM Owner assignment issue
* 33.0     SC-1154     15-10-20202 Akash N                  added default value for MLL case to US Military (USM)
* 34.0     SC-1160     21-10-2020  Sreya@Maersk             Modified the Logic to update Case Owner Manager field update.
* 35.0     SC-1124     28-10-2020  Sreya@Maersk             Update closure language as English for Account Based SCM BAs
* 36.0     SC-391      04-11-2020  Sunil BS                 Populate "Supplier" field of case for all record types with his Accounts "Supplier"
* 38.0     SC-1249     10-11-2020  Sreya@Maersk             Introducing Maersk L&S as new Brand.
* 39.0     SC-1256     18-11-2020  Sreya V                  CSAT Closure opt-out option for customers and moved the entire logic for updating Send Case Closure to this class.
* 40.0     SC-1404     19-11-2020  Sreya V                  Prevent the update of case brand from contact brand for external cases. Part of L&S Brand introduction.
* 41.0     SC-1168     20-11-2020  ramadevi@ust             ISR Case Ownership,Case visibility
* 42.0     SC-1126     24-11-2020  sriram@maersk            Shipment Number based Attributes for Routing - Product Delivery
* 43.0     SC-1234     25-11-2020  Sunil BS                 Defaulted language as English for SCM Account based BA
* 44.0     SC-1316     25-11-2020  ramadevi@ust             Adding WhatsApp Case_Channel__c    
* 45.0     SC-1755     19-01-2021  ramadevi@ust             Condition added to check if Country based One Team Sales 
* 46.0     SC-1715     25-01-2021  ramadevi@ust             bug fix for Shipment number not identified.
* 47.0     SC-1625     03-02-2021  ramadevi@ust             Update On Behalf of Account from Contact
* 48.0     SC-2289     22-04-2021  ramadevi@ust             Added condition to bypass updating the CargoClassification for LNS 
* 49.0     SC-2977     08-09-2021  ramadevi@ust             All multicarrier cases need not be a Competitor claim. Hence Commented the existing condition.
* 50.0     SC-1300     25-08-2021  shahanawaz@maersk        perform callout to update On Behalf of Account on Case
* 51.0     SC-2954     25-09-2021  Sandhya@maersk           Populate On behalf of account for Proactive case channel
* 52.0     DOR-4331    20-09-2021  Sandeep@ust              Update workflow owners as case owner for instantDO cases.
* 53.0     SC-1300     06-10-2021  Richa@maersk             Edited updateOnBehalfofAccountOnCase method to parse result from GCSS shipment party endpoint.
* 54.0     SC-3659     15-11-2021  Richa@maersk             Perform Callout to populate Sentiment on Case
* 55.0     SC-4044     7-12-2021   Urvish@ust               Validation for financial details for Closed - Paid claim cases
* 56.0     SC-4246     13-01-2022  somya.mahapatra@maersk.com    Added Conditional Statement for MC: Legal Resolver Dept. for updating the Case Owner upon Assignment 
* 57.0     SC-4321     24-01-2022  Richa@maersk             Added condition to identify shipment number from description if not found in Subject
* 58.0     SC-4212     24-01-2022  Sunil BS                 Invoke omni channel Method to Route work when price owner is updated
* 59.0     SC-4185     09-02-2022  Sreya@Maersk             API call to utilize the case classification model built by DA team and to update the case classification 
* 60.0     Sc-4134     10-02-2022  Ayush@Maersk             To Exclude Signature from the description.
* 61.0     SC-2036     25-02-2022  sriram@maersk            Identify BKS cases
* 62.0     SC-3706     08-03-2022  Richa@Maersk             Changed condition in updateSendCaseClosure method to include Dispute cases for Case closure notification
* 63.0     SC-4857     05-04-2022  Richa@Maersk             Auto Populate CM Visibility & 4pl Account field for ISRs
* 64.0     SC-4861     05-04-2022  Meghna@Maersk            Custom Validation for External and ISR case for Case Visibility and 4PL account field
* 61.0     SC-4770     21-04-2022  Thippeswamy@Maersk       Custom Model Pilot for ECC
* 62.0     SC-4480     04-05-2022  Thippeswamy@Maersk       Fixing the Thread_Topic__c field for Space issue   
* 67.0     SC-4522     04-05-2022  Meghna@Maersk            Assign Owner for 4PL ISR
* 68.0     SC-4507     26-05-2022  Sandeep@Maersk           4PL dashboard related changes.  
* 69.0     SC-5376     14-06-2022  Thippeswamy@Maersk      4PL dashboard changes.
* 70.0     SPI-100     27-06-2022  Ronnie@SF               Removed brand hardcoding
* 71.0     SC-5744     19-10-2022  Vivek@Maersk            Added Dispute record type to update Case-Visibility for multi-carrierbased on Liner brand metadata   
* 72.0     SC-5845     03-11-2022  Sunil BS                Bypassed shipment population for HSUD
* 73.0     SC-5414     9-01-2023   Saradha@UST             Metadata query changes as part of CTO
* 74.0     SC-6639     7-02-2023   Harmeet@Maersk          Sending case Product in the Request and updating the product from the Response Received in UpdateCaseClassification Method
* 75.0     SC-7136     20-02-2023  Ayush@Maersk            Replace GCSS APIs with Shipment Events Data...
* 76.0     SC-7133     05-03-2023  Ayush@Maersk            Implement LNS Case Classification Model
* 77.0     SC-7083    18-03-2023  ramadevi@maersk.com      NBA - updating the IsRecommendationAvailable__c and Deleting the case recommendations on type,sub type change.
* 79.0     SC-6165    03-04-2023  Saradha@maersk.com       Assign owner to Twill queue when delivery channel is Twill and stop omni channel routing for Twill cases
* 80.0     SC-7914    11-05-2023  Harmeet@maersk           Added Validation for Product, Type, Subtype and Reason For Case.Wrong comination will be prevented
* 81.0     SC-8107     31-05-2023   Vivek@maersk           To set Case CLosure Language code to English based on Case Owners Role for cashbox onboarding
* 82.0     SC-8258     14-06-2023   Shahanawaz@maersk      Stamp shipment number by searching in description & remove search for existing shipment for stamping
* 83.0     SC-8404     11-07-2023   Meghna@maersk          Auto Case Assignment for Ocean Based based on Reason for Case
* 84.0     SC-7849     12-07-2023   Nayana@maersk          Added handshakeExcludedCaseOrigins and csatExcludedCaseOrigins to decouple CSAT and handshake exclusion logic in populateFieldsOnBeforeInsertUpdate() and updateSendCaseClosure() 
*                                                          Added logic to determine Closure language code for ECL cases in populateClosurelangauge() method
* 85.0     SC-7850     17-07-2023   Nayana@maersk          Added logic to handle ECL ISR cases and optimized assignISRCaseToQueue() method
* 86.0     SC-8700     28-07-2023   Nayana@maersk          Moved Omni origin from custom label to custom metadata and updated code whereever omniOriginList was referring label
* 87.0     SC-8358     20-07-2023   sunil.bs@maersk        Enabled OBA,SR,VP Autopopulation via shiment parites for web2case
* 88.0     SC-8804     18-07-2023   raksha.n@maersk        Added additional parameters account.name and scv code to the case classification request
* 89.0     SC-8506     05-08-2023   sunil.bs@maersk        Moved BKS updation on delivery channel to be based on shipment data instead of API callout
Added logic to update a shipment as a short transit shipment
* 90.0     SC-8816     21-08-2023   Shahanawaz@maersk       Migrate Before Save Flow to Before Apex Trigger
* 91.0     SC-8489     08-08-2023   Vivek@Maersk            Added record type check on deleteCaseRecommendation to prevent it to fire for Email Recommendations record
* 95.0     SC-8395     07-09-2023   meghna@Maersk           Custom validation for Multi Carrier Restricted Account and Visibility
* 96.0     SC-8808     06-09-2023   Sandhya@Maersk          Automation to populate case visibility,MC Restricted Account and owner for MC Restricted Visibility
* 97.0     SC-9190     19-10-2023   Shahanawaz@Maersk.com   Create custom case history on external object
* 98.0     SC-8580     20-10-2023   Harmeet@Maersk.com      Update Cluster CS/CE field for Twill Cases 
* 99.0     SC-9357     15-11-2023   Shahanawaz@Maersk.com   Change shipment lookup to additionaly look at tpdoc 
* 100.0    SC-8651     23-11-2023   Sunil.bs@Maersk.com     Added Logic to auto-populate Cargo flow and assign to its queue
* 101.0    SC-9519     08-12-2023   Raksha.n@Maersk.com     AI Assist-Update Topic based on the nba values
* 102.0    SC-8989     22-02-2024   Shahanawaz@maersk.com   Add Entitlement for Email Cases which are not classified
* 92.0     SC-10137    11-06-2024   Shahanawaz@maersk   	Automate Response Received Flag
* 92.0     SC-10138    11-06-2024   Meghna@maersk   		Auto Close Spam Cases
* 93.0     SC-10036	   01-07-2024	Vazid					Added updateCaseOwnerhasCheckerQueue to update logged in user as case owner if owner is checker queue.
* 94.0     SC-10204    02-07-2024   Shahanawaz@maersk.com   Auto Populate From Address (Multiple CM BA)
*/
public without sharing class CaseFieldPopulator {
    
    /** 
* @description | Update the isRecommendationAvaialble__c upon update of certain fields.
* @param lstCases accepts case list
* SC-7083
*/
    public static void updateRecommendationStatus(List<Case> lstCases){
        for(Case cse:lstCases){
            cse.isRecommendationAvaialble__c = false;
        }
    }
    
    /** 
* @description | Delete Case Recommendations which is not needed, upon update of certain fields.
* @param lstCases accepts case list
* SC-7083
*/
    public static void deleteCaseRecommendation(List<Case> lstCases){
        List<Case_Recommendation__c> casRecList = new List<Case_Recommendation__c>();        
        if(lstCases <> null){
            list<Id> caseIdList = new List<Id>();
            for(Case cse : lstCases){
                caseIdList.add(cse.Id);
            }
            casRecList = [SELECT Id from Case_Recommendation__c where Case__c in :caseIdList and Action_Status__c = null  and recordtype.name = 'NBA Recommendation'];                
            if(casRecList <> NULL && casRecList.size()>0){            
                Database.DeleteResult[] resultsList = Database.delete(casRecList, false);
                ErrorLogger.writeErrors('SFDC', 'Case', 'CaseFieldPopulator.deleteCaseRecommendation', resultsList, casRecList);
            }
        }
    }
    
    /** 
* @description | populate on behalf of account
* @param lstCases accepts case list
*/
    public static void  populateOnBehalfOfAccount(List<Case> lstCases){
        try {
            Map<String, LinerBrand_Direction_and_Country__mdt> brandDirectionCountryMap = new Map<String, LinerBrand_Direction_and_Country__mdt>();
            Map<Id, String> geoIdCountryIdMap = new Map<Id, String>();
            Map<Id, String> geoIdCountryNameMap = new Map<Id, String>();
            Map<Id, String> geoIdCountryCodeMap = new Map<Id, String>();
            Set<Id> countriesInScope = new Set<Id>();
            List<String> countryList = System.label.OnBehalfOfCountries.toLowerCase().split(',');
            List<String> omniOriginList = CaseRecordSelector.omniOriginList;
            List<String> omniPortalOriginList = CaseRecordSelector.omniPortalOriginList;
            Set<String> shipmentNumberSet = new Set<String>();
            Map<String, List<Party__c>> shipmentNumberToPartyListMap = new Map<String, List<Party__c>>();
            Set<String> scvCodesSet = new Set<String>();
            Map<String, Account> scvCodeToAccountMap = new Map<String, Account>();
            Map<String, General_Key_Value_Configurations__mdt> keyValuePairMap = new Map<String, General_Key_Value_Configurations__mdt>();
            Set<Id> accIdSet = new Set<Id>();
            Map<Id, List<Care_Relationship__c>> mapCareRelationships = new Map<Id, List<Care_Relationship__c>>();
            Map<Id, Account> mapRelatedAccounts = new Map<Id, Account>();
            
            for(Case newCase : lstCases){
                if(newCase.Country__c != null){
                    countriesInScope.add(newCase.Country__c);
                }
                if(!String.isBlank(newCase.Shipment_Number__c)){
                    shipmentNumberSet.add(newCase.Shipment_Number__c);
                }
                if(newCase.AccountId != null){
                    accIdSet.add(newCase.AccountId);
                }
            }
            
            if(!shipmentNumberSet.isEmpty()){
                for(Party__c party : [Select Id, Shipment_Number__c, Scv_Customer_Code__c, Party_Role_Type_Name__c From Party__c Where Shipment_Number__c != null AND Shipment_Number__c =: shipmentNumberSet]){
                    if(shipmentNumberToPartyListMap.isEmpty() || !shipmentNumberToPartyListMap.containsKey(party.Shipment_Number__c)){
                        shipmentNumberToPartyListMap.put(party.Shipment_Number__c, new List<Party__c>{party});
                    }
                    else{
                        shipmentNumberToPartyListMap.get(party.Shipment_Number__c).add(party);
                    }
                    if(!String.isBlank(party.Scv_Customer_Code__c)){
                        scvCodesSet.add(party.Scv_Customer_Code__c);
                    }
                }
            }
            
            if(!scvCodesSet.isEmpty()){
                for(Account acc : [Select Id, SCV_Code__c, Value_Proposition__c, ParentId From Account Where SCV_Code__c != null AND SCV_Code__c =: scvCodesSet]){
                    scvCodeToAccountMap.put(acc.SCV_Code__c, acc);
                    accIdSet.add(acc.Id);
                    if(acc.ParentId != null){
                        accIdSet.add(acc.ParentId);
                    }
                }
            }
            
            if(!accIdSet.isEmpty()){
                for(Care_Relationship__c careRelationship : [Select Id, Account__c, Country__c, Cluster__c, Direction__c, Location__c, Liner_Brand__c, Care_Business_Partner__r.Name from Care_Relationship__c where Account__c != null AND Account__c  IN: accIdSet and Country__c != null AND Country__c IN: countriesInScope and Status__c =: Label.ActiveStatus]){
                    if(mapCareRelationships.isEmpty() || !mapCareRelationships.containsKey(careRelationship.Account__c)){
                        mapCareRelationships.put(careRelationship.Account__c, new List<Care_Relationship__c>{careRelationship});
                    }
                    else{
                        mapCareRelationships.get(careRelationship.Account__c).add(careRelationship);
                    }
                }
                for(Account acc : [Select Id, ParentId From Account Where Id =: accIdSet]){
                    mapRelatedAccounts.put(acc.Id, acc);
                }
            }
            
            if(!countriesInScope.isEmpty()){
                for(Geography__c geoInstance : [Select Id,geo_id__c, Name, geo_code__c from geography__c where id in:countriesInScope and Active__c = true]){         
                    geoIdCountryIdMap.put(geoInstance.Id, geoInstance.geo_id__c);                  
                    geoIdCountryNameMap.put(geoInstance.Id, geoInstance.Name);
                    geoIdCountryCodeMap.put(geoInstance.Id, geoInstance.geo_code__c);
                }
            }
            
            for(LinerBrand_Direction_and_Country__mdt lbdcInstance : caseRecordselector.mapLBDCs.values()){
                if(String.isnotblank(lbdcInstance.Liner_Brand__c) && String.isnotblank(lbdcInstance.Country__c) && String.isnotblank(lbdcInstance.Direction__c)){
                    brandDirectionCountryMap.put(lbdcInstance.Liner_Brand__c+';'+lbdcInstance.Country__c+';'+lbdcInstance.Direction__c, lbdcInstance);                  
                }
            }
            
            for(General_Key_Value_Configurations__mdt keyvaluepair:[select id,First_Field_Value__c,key__c from General_Key_Value_Configurations__mdt where label like 'DirectionAndDirectionCodeMap%']){
                keyValuePairMap.put(keyvaluepair.First_Field_Value__c, keyvaluepair);
            }
            
            for(Case newCase : lstCases){
                Map<Id,LinerBrand_Direction_and_Country__mdt> lbdcMap = new  map<Id,LinerBrand_Direction_and_Country__mdt> ();
                String country = (!geoIdCountryNameMap.isEmpty() && geoIdCountryNameMap != null && geoIdCountryNameMap.containsKey(newCase.Country__c)) ? geoIdCountryNameMap.get(newCase.Country__c) : '';
                List<Party__c> lstParty = new List<Party__c>();
                if(!String.isBlank(newCase.Shipment_Number__c) && shipmentNumberToPartyListMap.containsKey(newCase.Shipment_Number__c)){
                    lstParty = shipmentNumberToPartyListMap.get(newCase.Shipment_Number__c);
                }
                if(!lstParty.isempty()){
                    if(!omniOriginList.isEmpty() || (!countryList.isEmpty() && !String.isEmpty(country)) || !omniPortalOriginList.isEmpty()) {
                        if (omniOriginList.contains(newCase.Origin) || countryList.contains(country.toLowerCase()) || omniPortalOriginList.contains(newCase.Liner_Brand__c+newCase.Country__c+newCase.Direction__c)) {
                            String partyChoiceVP = '';
                            String partyChoiceSR = '';
                            String partyChoiceOBA = '';
                            String directionCode = '';
                            if(newCase.Case_Channel__c != Label.CaseChannelPortal) {
                                if(String.isNotBlank(newCase.origin)){
                                    LinerBrand_Direction_and_Country__mdt lbdcInscope = LinerBrand_Direction_and_Country__mdt.getinstance(newCase.origin);
                                    lbdcMap.put(newcase.id, lbdcInscope);
                                }
                            }
                            
                            if (lbdcMap.isEmpty() && newCase.Case_Channel__c != Label.CaseChannelPortal) {            
                                if(keyValuePairMap!=null){
                                    directionCode = keyValuePairMap.get(newCase.Direction__c)?.key__c;
                                }
                                //If origin is null, then get metadata through combination of brand,direction and country
                                LinerBrand_Direction_and_Country__mdt lbdcInscope = LinerBrand_Direction_and_Country__mdt.getinstance(BrandUtilities.getBrandShortForm(newCase.Liner_Brand__c)+geoIdCountryCodeMap.get(newCase.Country__c)+directionCode);                                                                  
                                if(lbdcInscope != null){
                                    lbdcMap.put(newcase.Id, lbdcInscope);
                                }
                            }
                            
                            if (lbdcMap.isEmpty() && newCase.Case_Channel__c == Label.CaseChannelPortal){
                                String geoIdInScope = geoIdCountryIdMap.get(newCase.Country__c);
                                if(brandDirectionCountryMap.containsKey(newCase.Liner_Brand__c+';'+geoIdInScope+';'+newCase.Direction__c)){
                                    LinerBrand_Direction_and_Country__mdt lbdcInscope = brandDirectionCountryMap.get(newCase.Liner_Brand__c+';'+geoIdInScope+';'+newCase.Direction__c);
                                    lbdcMap.put(newcase.Id, lbdcInscope);
                                }                                       
                            }
                            String lbdcInScopeChar = '';
                            if(!lbdcMap.isEmpty() && lbdcMap.get(newCase.Id) != null){
                                lbdcInScopeChar = lbdcMap.get(newCase.id).Label;
                            }
                            if (!lbdcMap.isEmpty() && lbdcInScopeChar.length()>= 6) {
                                partyChoiceSR = lbdcMap.get(newCase.id).Service_Relationship_Party__c;
                                if(String.isNotBlank(partyChoiceSR)){
                                    partyChoiceSR = partyChoiceSR.deleteWhitespace().toLowerCase();
                                }
                                
                                partyChoiceVP = lbdcMap.get(newCase.id).Value_Proposition_Party__c;
                                if(String.isNotBlank(partyChoiceVP)){
                                    partyChoiceVP = partyChoiceVP.deleteWhitespace().toLowerCase();
                                }
                                
                                partyChoiceOBA = lbdcMap.get(newCase.id).On_behalf_of_account_name__c;
                                if(String.isNotBlank(partyChoiceOBA)){
                                    partyChoiceOBA = partyChoiceOBA.deleteWhitespace().toLowerCase();
                                }
                                
                                String custCodeSR;
                                String custCodeVP;
                                String custCodeOBA;
                                
                                if(!lstParty.isEmpty()) {
                                    for(Party__c party: lstParty){       
                                        if(!String.isBlank(party.party_role_type_name__c)){
                                            party.Party_Role_Type_Name__c = party.Party_Role_Type_Name__c.deleteWhitespace().toLowerCase();
                                        }
                                        if(partyChoiceSR != Null && partyChoiceSR == party.Party_Role_Type_Name__c) {
                                            custCodeSR = (String) party.Scv_Customer_Code__c;
                                        }
                                        if(partyChoiceVP != Null && partyChoiceVP == party.Party_Role_Type_Name__c) {
                                            custCodeVP = (String) party.Scv_Customer_Code__c;
                                        }
                                        if(partyChoiceOBA != Null && partyChoiceOBA == party.Party_Role_Type_Name__c) {
                                            custCodeOBA = (String) party.Scv_Customer_Code__c;
                                        }
                                    }
                                }
                                
                                if(!scvCodeToAccountMap.isEmpty()){
                                    if(!String.isEmpty(custCodeOBA) && scvCodeToAccountMap.containsKey(custCodeOBA)){
                                        newCase.On_Behalf_Account__c = scvCodeToAccountMap.get(custCodeOBA).Id;
                                    }
                                    
                                    if(!String.isEmpty(custCodeVP) && scvCodeToAccountMap.containsKey(custCodeVP)){
                                        newCase.Value_Proposition__c = scvCodeToAccountMap.get(custCodeVP).Value_Proposition__c;
                                    }
                                    
                                    if(!String.isEmpty(custCodeSR) && scvCodeToAccountMap.containsKey(custCodeSR)) {
                                        newCase.Care_Relationship__c = findOBHCareRelationship(newCase, null, mapRelatedAccounts, scvCodeToAccountMap.get(custCodeSR).Id, mapCareRelationships);
                                        CaseRecordSelector.skipOBHLogic = true;
                                    }
                                }
                            }
                        } 
                    }
                }
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors('SFDC', 'Case', 'CaseFieldPopulator.populateOnBehalfOfAccount', new list <Exception> {ex});
        }
    }
    
    /** 
* @description | validate on behalf of account cases
* @param caseList accepts case list
* @return list of cases
*/  
    public static List<Case> validateOnBehalfOfAccountCases(List<Case> caseList){    
        List<Case> validatedCasesList = new List<Case>();
        try{
            List<String> countryList =  System.label.OnBehalfOfCountries.toLowerCase().split(',');        
            List<String> omniOriginList = CaseRecordSelector.omniOriginList;
            List<String> omniPortalOriginList = CaseRecordSelector.omniPortalOriginList;
            for(Case cs : caseList){
                String portalOrigin = cs.Liner_Brand__c + cs.Country__c + cs.Direction__c;
                Boolean checkInternalContactDomain = CaseRecordSelector.checkInternalContactDomain(cs);
                if(checkInternalContactDomain && !String.isBlank(cs.Direction__c) && !String.isBlank(cs.Case_Country__c) && !countryList.isEmpty() && countryList.contains(cs.Case_Country__c.toLowerCase()) && BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MAERSKLINE).contains(cs.Liner_Brand__c)){
                    validatedCasesList.add(cs);
                }
                else if(!String.isEmpty(cs.Origin) && ((!omniOriginList.isEmpty() && omniOriginList.contains(cs.Origin)) || (!omniPortalOriginList.isEmpty() && omniPortalOriginList.contains(portalOrigin))) && (cs.Case_Channel__c == 'E-mail' || cs.Case_Channel__c == 'Portal')){
                    validatedCasesList.add(cs);
                }
            }
        }
        catch(Exception e){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseRecordSelector.validateOnBehalfOfAccountCases', new list<Exception>{e});
        }
        return validatedCasesList;
    }
    
    /** 
* @description | SC-1300: Method to associate appropriate Care Relationship to case records based on Liner Brand, Direction, Location Fields (starting from smallest level of Geography)after On behalf of account callout  |
* @param cs accepts a case
* @param mapOldCases accepts a key value pair of Id and Case object
* @param mapRelatedAccounts acceps a key value pair of Id and Account object
* @param onBehalfAccount Accepts a String 
* @param mapCareRelationships accepts as a Map
* @return care Id as a String
*/  
    public static String findOBHCareRelationship(Case cs, Map<Id, Case> mapOldCases, Map<Id, Account> mapRelatedAccounts, String onBehalfAccount, Map<Id, List<Care_Relationship__c>> mapCareRelationships) {
        String careId; 
        try{
            String strCaseLBLogic = CaseUtilities.getLinerBrandLogic(cs);
            Id accountId;
            if(mapOldCases == null){
                if(!String.isBlank(strCaseLBLogic) && !BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.USFLAG).contains(strCaseLBLogic)) { // No Care Relationship for US flag case.
                    if(onBehalfAccount != null) {
                        accountId = onBehalfAccount;
                    }
                    else if(cs.AccountId != null) {
                        accountId = cs.AccountId;
                    }
                }
            }
            // Assign Care Relationship based on the On Behalf Account or Account
            if(!mapCareRelationships.isEmpty() && mapCareRelationships.containsKey(accountId)){
                careId = CareRelationLogicHandler.setCareRelationship(cs, mapCareRelationships.get(accountId));
            }
            // If still Care Relationship not found then assign Care Relationship based on the concern account
            if(careId == null){
                Account relatedAccount = mapRelatedAccounts.get(accountId);
                if(relatedAccount != null && relatedAccount.ParentId != null && !mapCareRelationships.isEmpty() && mapCareRelationships.containsKey(relatedAccount.ParentId) && mapCareRelationships.get(relatedAccount.ParentId) != null) {
                    careId = CareRelationLogicHandler.setCareRelationship(cs, mapCareRelationships.get(relatedAccount.ParentId));
                }
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.findOBHCareRelationship', new list<Exception>{ex}); 
        }
        return careId;
    }
    
    /** 
* @description | Utility method which is called from findOBHCareRelationship() to return the Care Relationship based on the mentioned criterias  |
* @param newCase accepts a Case Record
* @param lstCareRelationship Accepts a list of Care Relationship Object
* @return careId in String format
*/  
    /*private static String setOBHCareRelationship(Case newCase, list<Care_Relationship__c> lstCareRelationship) {
        String careId;
        for(Care_Relationship__c care : lstCareRelationship) {           
            if(((care.Direction__c == newCase.Direction__c || care.Direction__c == Label.DirectionBoth) && (newCase.City__c != null) && (newCase.City__c == care.Location__c) && (newCase.Country__c == care.Country__c) && (newCase.Liner_Brand__c == care.Liner_Brand__c))) {
                careId = care.Id;
            }
        }
        
        if(careId == null) {
            for(Care_Relationship__c care : lstCareRelationship) {
                if(((care.Direction__c == newCase.Direction__c || care.Direction__c == Label.DirectionBoth) && (newCase.Cluster__c != null) && (newCase.Cluster__c == care.Cluster__c) && (newCase.Country__c == care.Country__c) && (newCase.Liner_Brand__c == care.Liner_Brand__c))) {
                    careId = care.Id;
                }
            }
        }       
        return careId;
    }*/
    
    /** 
* @description | SC-8506 API call to know whether the case is for a short transit delivery channel|
* @param caseId accepts Id for a case record
*/   
    /**    
* @description | SC-9008 - Move reporting field logic to case|  
* @param lstCases accepts case list 
*/  
    public static void populateNBAOptOutUser(List<Case> lstCases){  
        try { 
            if(Generic_TriggerHandler.validateRunForMethod('CaseFieldPopulator.populateNBAOptOutUser()', 1)) {    
                if(lstCases <> null){   
                    id userid = userinfo.getuserid();   
                    for(Case cse : lstCases){   
                        cse.Case_NBA_Bypassed_User__c = userid; 
                    }                   
                }   
            }   
        }   
        catch(Exception ex){    
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.populateNBAOptOutUser', new list<Exception>{ex});      
        }   
    }  
    
    /** 
* @description | SC-400 Case Visibility - ISR  |
* @param lstISRCases accepts the list of ISR Case Records
*/ 
    public static void populateISRCaseVisibilityValue(list<Case> lstISRCases){
        try{
            if (Generic_TriggerHandler.validateRunForMethod('CaseFieldPopulator.populateISRCaseVisibilityValue()', 1)) {
                // Get ISR Case_Visibility_Matrices__c 
                Map<String, Case_Visibility_Matrices__c> visibilityMapping = StaticFactory.getCaseVisibilityMatrixValue('ISR');
                for (Case newCase : lstISRCases) {
                    // SC-400 Case visibility for ISR cases 
                    if ((newCase.Case_Visibility__c == null && newCase.Resolver_Dept__c != null && StaticFactory.getCurrentUserDetails().CM_Visibility__c != null)) {
                        String resolvPrefix;
                        
                        if (newCase.Resolver_Dept__c != null && newCase.Resolver_Dept__c.contains('):')) {
                            resolvPrefix = newCase.Resolver_Dept__c.split(':')[0].trim();
                        } else {
                            resolvPrefix = newCase.Resolver_Dept__c.split(':')[0].split(' ')[0].trim();
                        }
                        String visibilityMappingStr = StaticFactory.getCurrentUserDetails().CM_Visibility__c + ' - ' + resolvPrefix;
                        if (visibilityMapping.containsKey(visibilityMappingStr)) {
                            newCase.Case_Visibility__c = visibilityMapping.get(visibilityMappingStr).Case_Visibility__c;
                        }                               
                    }
                }
            }
        } catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.populateISRCaseVisibilityValue', new list<Exception>{ex});  
        }
    }
    
    /** 
* @description | SC-399 && SC-389 Method to populate Case Visibility Value. This method will execute only on before insert.  |
* @param lstCases accepts the list of Case Records
*/ 
    public static void populateCaseVisibilityValue(list<Case> lstCases){
        try{
            if(Generic_TriggerHandler.validateRunForMethod('CaseFieldPopulator.populateCaseVisibilityValue()', 1)) { 
                for(Case newCase : lstCases){ 
                    //Below logic is catch scenario. It should always execute at the end after all the computations.
                    if(newCase.Case_Visibility__c == null || newCase.Case_Visibility__c == ''){
                        newCase.Case_Visibility__c = 'All Users';
                    }
                }            
            }
        }catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.populateCaseVisibilityValue', new list<Exception>{ex});  
        }
    }
    
    /** 
* @description | SC - 675 - Update Competitor Claims to TRUE when Case Visibility = Multi-Carrier. Also update Case Visibility to Multi-Carrier when Competitor Claims = TRUE on insert and update. |
* @param lstCases accepts the list of Case Records
* @param mapOldCases Accepts key value pair for Id and Case
* @param casTriggerHandler accepts record for type CaseTriggerHandler
*/ 
    public static void updateCompetitorClaimVisibility(list<Case> lstCases, map<Id, Case> mapOldCases, CaseTriggerHandler casTriggerHandler){
        try{
            if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                for(Case newCase : lstCases){
                    if(newCase.Competitor_Claim__c == true && newCase.Case_Visibility__c != 'Multi-Carrier'){
                        newCase.Case_Visibility__c = 'Multi-Carrier';
                    }
                    //SC-2977 - All multicarrier cases need not be a Competitor claim. Hence Commenting
                    /*
if(newCase.Case_Visibility__c == 'Multi-Carrier' && newCase.Competitor_Claim__c != true){
newCase.Competitor_Claim__c = true;
}*/
                    
                }
            }
            else if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                for(Case newCase : lstCases){
                    Case  oldCase;
                    if(mapOldCases != null && !mapOldCases.isEmpty()) {
                        oldCase = mapOldCases.get(newCase.Id);
                    }
                    if(newCase.Competitor_Claim__c != oldCase.Competitor_Claim__c && newCase.Competitor_Claim__c == true && newCase.Case_Visibility__c != 'Multi-Carrier'){
                        newCase.Case_Visibility__c = 'Multi-Carrier';
                    }
                    //SC-2977 - All multicarrier cases need not be a Competitor claim. Hence Commenting
                    /*                    
else if(newCase.Competitor_Claim__c != oldCase.Competitor_Claim__c && newCase.Competitor_Claim__c == false && newCase.Case_Visibility__c != 'All Users'){
newCase.Case_Visibility__c = 'All Users';
}
if(newCase.Case_Visibility__c != oldCase.Case_Visibility__c && newCase.Case_Visibility__c == 'Multi-Carrier' && newCase.Competitor_Claim__c != true){
newCase.Competitor_Claim__c = true;
} else*/
                    if(newCase.Case_Visibility__c != oldCase.Case_Visibility__c && newCase.Case_Visibility__c == 'All Users' && newCase.Competitor_Claim__c != false){
                        newCase.Competitor_Claim__c = false;
                    }
                }             
            }
        }
        catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.updateCompetitorClaimVisibility', new list<Exception>{ex}); 
        }
    }
    
    /** 
* @description | SC-290 Method to populate visibility in portal |
* @param lstCases accepts the list of Case Records
* @param mapOldCases Accepts key value pair for Id and Case
* @param casTriggerHandler accepts record for type CaseTriggerHandler
* @param casRecordSelector accepts a record of type CaseRecordSelector
*/ 
    public static void populateVisibilityInPortal(list<Case> lstCases, map<Id, Case> mapOldCases, CaseTriggerHandler casTriggerHandler, CaseRecordSelector casRecordSelector){
        try{
            map<String, Case_Type_Sub_Type_Direction_Mapping__mdt> mapTSDs = casRecordSelector.getMapTSD();
            String claimRecoveryRecTypeId = Label.Claim_Recovery_Case_RT_Id;
            String isrRecTypeId = Label.ISR_Case_RT_Id;
            
            for(Case newCase : lstCases) {
                Case oldCase;
                if(mapOldCases != null && !mapOldCases.isEmpty()) {
                    oldCase = mapOldCases.get(newCase.Id);
                }
                
                String mapKey = newCase.Product__c + ':' + newCase.Type + ':' + newCase.Sub_Type__c;
                Case_Type_Sub_Type_Direction_Mapping__mdt tsd = mapTSDs.get(mapKey);
                
                if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                    newCase.Visible_In_Portal__c = tsd != null && tsd.Visible_In_Portal__c == 'Yes' && newCase.Status != Label.CaseNew && newCase.Case_Channel__c != 'Proactive' && newCase.RecordTypeId != claimRecoveryRecTypeId && newCase.RecordTypeId != isrRecTypeId ? true : false;
                }
                else if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                    if(newCase.Product__c != oldCase.Product__c || newCase.Type != oldCase.Type || newCase.Sub_Type__c != oldCase.Sub_Type__c ||
                       newCase.Status != oldCase.Status || newCase.Case_Channel__c != oldCase.Case_Channel__c || newCase.RecordType != oldCase.RecordType){
                           newCase.Visible_In_Portal__c = tsd != null && tsd.Visible_In_Portal__c == 'Yes' && newCase.Status != Label.CaseNew && newCase.Case_Channel__c != 'Proactive' && newCase.RecordTypeId != claimRecoveryRecTypeId && newCase.RecordTypeId != isrRecTypeId ? true : false;
                       }
                }
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.populateVisibilityInPortal', new list<Exception>{ex}); // #RQ-005636 
        }
    }
    
    /** 
* @description |  Generic Case field population during OnBeforeInsert and OnBeforeUpdate |
* @param lstCases accepts the list of Case Records
* @param mapOldCases Accepts key value pair for Id and Case
* @param casTriggerHandler accepts record for type CaseTriggerHandler
* @param casRecordSelector accepts a record of type CaseRecordSelector
*/ 
    public static void populateFieldsOnBeforeInsertUpdate(list<Case> lstCases, map<Id, Case> mapOldCases, CaseTriggerHandler casTriggerHandler, CaseRecordSelector casRecordSelector) {
        try{
            if(Test.isRunningTest() || Generic_TriggerHandler.validateRunForMethod('CaseFieldPopulator.populateFieldsOnBeforeInsertUpdate()', 1)) {
                Boolean bRefreshRecordSelector = false;
                user currentUser = StaticFactory.getCurrentUserDetails();
                Id externalCaseRTId = Case.sObjectType.getDescribe(SObjectDescribeOptions.DEFAULT).getRecordTypeInfosByName().get(Label.External_Case).getRecordTypeId();
                Id claimRTId = Case.sObjectType.getDescribe(SObjectDescribeOptions.DEFAULT).getRecordTypeInfosByName().get(Label.Claim).getRecordTypeId();
                //Id claimsRecoveryRTId = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get(Label.Claims_Recovery).getRecordTypeId();
                Id isrrtid = Case.sObjectType.getDescribe(SObjectDescribeOptions.DEFAULT).getRecordTypeInfosByName().get(Label.ISR).getRecordTypeId();
                Id disputeRTId = Case.sObjectType.getDescribe(SObjectDescribeOptions.DEFAULT).getRecordTypeInfosByName().get(Label.Dispute).getRecordTypeId();            
                String subjectReplaceRegex = Label.Case_Subject_Replace_Values;
                Set<String> disputeChannelNames = new Set<String>{'MyFinance', 'E-mail', 'MOBILE', 'OHP Disputes', 'BATCHTWS', 'Other'};
                    
                    set<String> setEmailDomains;
                if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                    setEmailDomains = Email_Domains__c.getAll().keySet();
                }
                List<String> originArtemisGE = CaseRecordSelector.originArtemisGE;
                for(Case newCase : lstCases) {
                    Case oldCase;
                    if(mapOldCases != null && !mapOldCases.isEmpty()) {
                        oldCase = mapOldCases.get(newCase.Id);
                    }
                    
                    //#RQ-006949
                    if(newCase.Security_Code__c == null || newCase.Security_Code__c == ''){
                        newCase.Security_Code__c = CaseUtilities.generateRandomUniqueCode();
                    }
                    
                    
                    if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                        
                        // RQ-004350: Populate Account and Contact for portal created cases
                        if(currentUser.ContactId != null) { // If case is being created by community user
                            newCase.ContactId = currentUser.ContactId;
                            newCase.AccountId = currentUser.AccountId;
                            casRecordSelector.setAccountIds.add(newCase.AccountId);
                            bRefreshRecordSelector = true;
                            
                            // To resolve defect 9891 - Cases created via portal are not showing up in Duplicate Case Manager.
                            if(newCase.Subject == null) {
                                newCase.Subject = currentUser.Contact.Account.Name + ' - ' + newCase.Type;
                            }
                        }
                        
                        // RQ-002633: Do not populate Direction__c for Claim / Claims Recovery. Added "newCase.RecordTypeId == externalCaseRTId"
                        // RQ-009034. Added Dispute to populate Direction and Thread Topic.
                        // SC-390 : Added the logic for updating Case Visibility field based on Liner Brand Direction metadata value for email to case.
                        if(newCase.RecordTypeId == externalCaseRTId || newCase.RecordTypeId == claimRTId || newCase.RecordTypeId == disputeRTId) {
                            // RQ-002764: Populate the Direction__c field based on the Origin of the Case and configuration defined in the LinerBrand_Direction_and_Country__mdt
                            //SC-5744  :  Added dispute record type as well 
                            if((newCase.RecordTypeId == externalCaseRTId||newCase.RecordTypeId == claimRTId || newCase.RecordTypeId == disputeRTId) && casRecordSelector.setOriginsForE2C.contains(newCase.Origin) && caseRecordSelector.mapLBDCs != null && !caseRecordSelector.mapLBDCs.isEmpty() && caseRecordSelector.mapLBDCs.containsKey(newCase.Origin)) {
                                LinerBrand_Direction_and_Country__mdt lbdc = caseRecordSelector.mapLBDCs.get(newCase.Origin);                                
                                if(lbdc != null && lbdc.Direction__c != null) {
                                    newCase.Direction__c = lbdc.Direction__c;
                                }
                                if(lbdc != null && lbdc.Case_Visibility__c != null) {
                                    newCase.Case_Visibility__c = lbdc.Case_Visibility__c;
                                }
                                if(lbdc != null ) {
                                    newCase.Product__c = !String.isEmpty(lbdc.Product__c) ? lbdc.Product__c : '';                                
                                }
                                if(lbdc != null && lbdc.SF_4PL_Account__c != null) {
                                    newCase.SF_4PL_Account__c = lbdc.SF_4PL_Account__c;
                                }
                                if(lbdc != null && lbdc.Multi_Carrier_Restricted_Account__c != null) {  
                                    newCase.Multi_Carrier_Restricted_Account__c = lbdc.Multi_Carrier_Restricted_Account__c; 
                                }
                                if (!originArtemisGE.isEmpty() && originArtemisGE.contains(newCase.Origin) && lbdc!=null && lbdc.type__c!=null) {
                                    newCase.type=lbdc.type__c;
                                }
                            } 
                            
                            // RQ-001140: Populate the Thread Topic field of Case with Subject after removal of 'RE:/FWD:/FW:' occurances in the subject field of Case
                            if(newCase.Subject != null) {
                                //newCase.Thread_Topic__c = newCase.Subject.replaceAll('(?:\\[?(?:[Ff][Ww][Dd]?|[Rr][Ee])(?:\\s*[:;-]+\\s*\\]?))+', '');
                                //RQ-011433 - Moved the Regex string into custom label as new values has been added.
                                String threadTopic = newCase.Subject.replaceAll(subjectReplaceRegex,''); // SC-4480
                                newCase.Thread_Topic__c = threadTopic.replaceAll( '\\s+', ' ');  // SC-4480
                                
                            }
                        }
                        else if(newCase.RecordTypeId == isrrtid) {
                            // RQ-004634 - Populate Liner Brand from Parent case for ISR cases created through Publisher action
                            if(newCase.Liner_Brand__c == null && newCase.ParentId != null && !casRecordSelector.mapRelatedCases.isEmpty() && casRecordSelector.mapRelatedCases.containsKey(newCase.ParentId)) {
                                newCase.Liner_Brand__c = casRecordSelector.mapRelatedCases.get(newCase.ParentId).Liner_Brand__c;                            
                            }                         
                            //SC-4857: Auto Populate 4pl Account field for ISRs from parent Case
                            if(newCase.SF_4PL_Account__c == null && newCase.ParentId != null && !casRecordSelector.mapRelatedCases.isEmpty() && casRecordSelector.mapRelatedCases.containsKey(newCase.ParentId) && casRecordSelector.mapRelatedCases.get(newCase.ParentId).SF_4PL_Account__c != null) {
                                newCase.SF_4PL_Account__c = casRecordSelector.mapRelatedCases.get(newCase.ParentId).SF_4PL_Account__c;   
                            }
                            if(newCase.Multi_Carrier_Restricted_Account__c == null && newCase.ParentId != null && !casRecordSelector.mapRelatedCases.isEmpty() && casRecordSelector.mapRelatedCases.containsKey(newCase.ParentId) && casRecordSelector.mapRelatedCases.get(newCase.ParentId).Multi_Carrier_Restricted_Account__c != null) {
                                newCase.Multi_Carrier_Restricted_Account__c = casRecordSelector.mapRelatedCases.get(newCase.ParentId).Multi_Carrier_Restricted_Account__c;   
                            }
                            
                        }
                        
                        // Set Autohandshake_Opt_Out__c field to true if the case creation request is originated from the domain which is configured for Auto Handshake Opt-Out in Email Domains custom setting.
                        // RQ-009414 : Condition added to check whether '@' exists in the supplied email.
                        if((newCase.SuppliedEmail != null &&  newCase.SuppliedEmail.Contains('@'))) {    
                            String strEmailDomain = newCase.SuppliedEmail.subString(newCase.SuppliedEmail.indexOf('@'));
                            if(setEmailDomains.contains(strEmailDomain)) {
                                newCase.Autohandshake_Opt_Out__c = true;
                            }
                        }
                        //SC-5415 Made ExcludedCaseOrigins to static variable
                        if(CaseRecordSelector.handshakeExcludedCaseOrigins.contains(newCase.Origin))
                        {
                            newCase.Autohandshake_Opt_Out__c = true;
                        }
                        
                        //SC-8816 - Update Product Landside Transportation
                        if(newCase.OwnerId == Label.GLO_Inland && newCase.Product__c != 'Landside Transportation'){
                            newCase.Product__c = 'Landside Transportation';
                        }
                        //SC-8816 - Update Case Channel
                        if(UserInfo.getUserName().contains('system.owner@maersk.com') && newCase.SuppliedEmail != 'ml-noreply@maersk.com' && newCase.Case_Channel__c != 'Portal' && newCase.Case_Channel__c != 'Chat'){
                            newCase.Case_Channel__c = 'E-mail';
                        }
                        //SC-8816 - Update Case Channel & Visibility
                        if(newCase.SuppliedEmail == 'ml-noreply@maersk.com'){
                            newCase.Case_Channel__c = 'Website';
                            newCase.Case_Visibility__c = 'All Users';
                        }
                    }
                    else if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                        if(newCase.Country__c != oldCase.Country__c && newCase.City__c == oldCase.City__c) {
                            newCase.City__c = null;
                        }
                        
                        // v 9.0 RQ-011027  AccountId to change automatically with change in contactId
                        if(newCase.ContactId != oldCase.ContactId && newCase.ContactId != null) {
                            Contact conInstance = casRecordSelector.mapRelatedContacts.get(newCase.ContactId);
                            if(conInstance != null) {
                                newCase.AccountId = conInstance.AccountId;
                                
                                casRecordSelector.setAccountIds.add(newCase.AccountId);
                                bRefreshRecordSelector = true;
                            }
                        }
                        
                        //SC-8816 - Update Disputed Invoice number to blank
                        if(newCase.RecordTypeId != oldCase.RecordTypeId && oldCase.RecordTypeId == disputeRTId && !String.isEmpty(newCase.Disputed_Invoice_Number__c) && !UserInfo.getUserName().contains('empinterface@maersk.com')){
                            newCase.Disputed_Invoice_Number__c = '';
                        }
                        //SC-8816 - Update Type Subtype RFC owner of dispute recordtype
                        if(newCase.RecordTypeId != oldCase.RecordTypeId && newCase.RecordTypeId == disputeRTId){
                            newCase.Type = 'Charges, Invoice & Payment';
                            newCase.Sub_Type__c = 'Dispute';
                            newCase.Reason_For_Case__c = 'Case Reason Updated in OHP';
                            newCase.OwnerId = Label.Global_Dispute_Queue;
                        }
                        //SC-8816 - Update Type Subtype RFC recordtype to blank if a record type is changed from Dispute to External case by any user other than Maersk API Management users.
                        if(newCase.RecordTypeId != oldCase.RecordTypeId && newCase.RecordTypeId == externalCaseRTId && !UserInfo.getUserName().contains('maerskapimanagement@maersk.com')){
                            newCase.Type = '';
                            newCase.Sub_Type__c = '';
                            newCase.Reason_For_Case__c = '';
                        }
                        //SC-8816 - Update Type Subtype RFC recordtype of global dispute queue cases
                        if(newCase.OwnerId != oldCase.OwnerId && newCase.OwnerId == Label.Global_Dispute_Queue){
                            newCase.Type = 'Charges, Invoice & Payment';
                            newCase.Sub_Type__c = 'Dispute';
                            newCase.Reason_For_Case__c = 'Case Reason Updated in OHP';
                            newCase.RecordTypeId = disputeRTId;
                        }
                        if(newCase.RecordTypeId == disputeRTId && newCase.Resolved_Reason__c != oldCase.Resolved_Reason__c && UserInfo.getUserName().contains('empinterface@maersk.com')){
                            if(!String.isEmpty(newCase.Resolved_Reason__c) && !casRecordSelector.closedStatuses.contains(oldCase.Status)){
                                newCase.Status = 'Closed - Resolved';
                            }
                            else if(String.isEmpty(newCase.Resolved_Reason__c) && casRecordSelector.closedStatuses.contains(oldCase.Status)){
                                newCase.Status = 'In Progress';
                            }
                        }
                        //SC-10137
                        if(newCase.recordtypeId == externalCaseRTId && newCase.New_Mail__c && newCase.Status != oldCase.Status){
                            newCase.New_Mail__c = false;
                        }
                    }
                    // v1.2: Start (Populate AccountId on creation / during inline edit)
                    if(newCase.AccountId == null && newCase.ContactId != null) {
                        Contact conInstance = casRecordSelector.mapRelatedContacts.get(newCase.ContactId);
                        if(conInstance != null) {
                            newCase.AccountId = conInstance.AccountId;
                            
                            casRecordSelector.setAccountIds.add(newCase.AccountId);
                            bRefreshRecordSelector = true;
                        }
                    }                
                    // v1.2: End 
                    
                    //SC-8816 - Update Artemis OwnerId
                    if(!String.isEmpty(newCase.Artemis_Id__c) && !String.isEmpty(newCase.Status) && newCase.Status.contains('Closed') && String.valueOf(newCase.OwnerId).startsWith('00G')){
                        newCase.OwnerId = Label.Artemis_System_Owner_Id;
                    }
                    //SC-8816 - Update status to Triaged
                    if((newCase.RecordTypeId == externalCaseRTId || newCase.RecordTypeId == claimRTId || newCase.RecordTypeId == disputeRTId) && newCase.Status == 'New' && !String.isEmpty(newCase.Type) && !String.isEmpty(newCase.Sub_Type__c) && (!newCase.MLL__c || (newCase.MLL__c && !String.isEmpty(newCase.Cargo_Classification__c)))){
                        newCase.Status = 'Triaged';
                    }
                    //SC-8816 - Update type Subtype RFC
                    if((newCase.RecordTypeId == externalCaseRTId || newCase.RecordTypeId == claimRTId || newCase.RecordTypeId == disputeRTId) && String.isEmpty(newCase.Type) && String.isEmpty(newCase.Sub_Type__c)){
                        if(newCase.Status == 'Closed - Duplicate'){
                            newCase.Type = 'Non-Case';
                            newCase.Sub_Type__c = 'Spam/Case Created in Error';
                        }
                        else if((newCase.RecordTypeId == externalCaseRTId || newCase.RecordTypeId == disputeRTId) && newCase.Status == 'Closed - Not a case'){
                            newCase.Type = 'Non-Case';
                            newCase.Sub_Type__c = 'Spam/Case Created in Error';
                            newCase.Reason_For_Case__c = 'Spam';
                        }
                    }
                    //SC-8816 - Update Dispute recordtype & direction
                    if(newCase.RecordTypeId == externalCaseRTId && newCase.Type == 'Charges, Invoice & Payment' && newCase.Sub_Type__c == 'Dispute' && UserInfo.getUserName().contains('empinterface@maersk.com') && disputeChannelNames.contains(newCase.Case_Channel__c)){
                        newCase.RecordTypeId = disputeRTId;
                        newCase.Direction__c = 'Not Known';
                    }
                }
                
                // Since AccountId is explicitly updated, refresh the Record Selector to make it available to further business logic.
                if(bRefreshRecordSelector) {
                    casRecordSelector.getRelatedAccounts();
                }
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.populateFieldsOnBeforeInsertUpdate', new list<Exception>{ex}); // #RQ-005636 
        }
    }
    
    /** 
* @description |  v1.7: RQ-004424 Populates Direction field based on Type and Sub Type values. Mapping of Type, Sub Type and Direction is stored in Case_Type_Sub_Type_Direction_Mapping__mdt metadata type. 
SC-290 Added Product field to generate mapkey for mapTSDs map |
* @param lstCases accepts the list of Case Records
* @param mapTSDs Accepts key value pair for a String and Case_Type_Sub_Type_Direction_Mapping__mdt metadata
* @param casTriggerHandler accepts record for type CaseTriggerHandler
*/ 
    public static void populateDirectionForPortalCases(list<Case> lstCases, map<String, Case_Type_Sub_Type_Direction_Mapping__mdt> mapTSDs,CaseTriggerHandler casTriggerHandler, CaseRecordSelector casRecordSelector) {
        //SC-160 : Trigger Recurrsion controller
        //SC-390 - update Case_Visibility__c field on case based on Portal CM Visibility metadata value. This is for Portal cases.
        try{
            if(Generic_TriggerHandler.validateRunForMethod('CaseFieldPopulator.populateDirectionForPortalCases()', 1)){
                if(lstCases != null && mapTSDs != null) {
                    for(Case newCase : lstCases) {
                        Map<Id, Geography__c> mapRelatedGeo = casRecordSelector.mapRelatedGeography;
                        String mapKey = newCase.Product__c + ':' + newCase.Type + ':' + newCase.Sub_Type__c;
                        Case_Type_Sub_Type_Direction_Mapping__mdt tsd = mapTSDs.get(mapKey);
                        if(tsd != null) {
                            if(tsd.Direction__c!= null && (casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE || (casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && String.isBlank(newCase.Direction__c)))){
                                newCase.Direction__c = tsd.Direction__c;
                            }
                            if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                                newCase.Case_Visibility__c = tsd.Case_Visibility__c;
                            }                       
                        }
                        if (newCase.Liner_Brand__c == Constants.mcc_brand && mapRelatedGeo.get(newCase.Country__c).Name == Constants.philippines_country && newCase.Direction__c != Constants.domestic_direction) {
                        	newCase.Direction__c = Constants.domestic_direction;
                        }
                    }
                }
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.populateDirectionForPortalCases', new list<Exception>{ex}); // #RQ-005636 
        }
    }
    
    /** 
* @description | Generic Case field population during OnBeforeInsert and OnBeforeUpdate
// SC-1154 added default value for MLL case to US Military (USM) |
* @param lstCases accepts the list of Case Records
* @param mapOldCases Accepts key value pair for Id and Case
* @param casTriggerHandler accepts record for type CaseTriggerHandler
* @param casRecordSelector accepts record for type casRecordSelector
*/ 
    public static void populateLinerBrand(list<Case> lstCases, map<Id, Case> mapOldCases, CaseTriggerHandler casTriggerHandler, CaseRecordSelector casRecordSelector) {
        Id externalCaseRTId = Case.sObjectType.getDescribe(SObjectDescribeOptions.DEFAULT).getRecordTypeInfosByName().get(Label.External_Case).getRecordTypeId();
        String linerBrandLogicUSF = BrandUtilities.MAERSKLINE + ';' + BrandUtilities.MLL;
        try {
            if(Generic_TriggerHandler.validateRunForMethod('CaseFieldPopulator.populateLinerBrand()', 1)) {                
                User currentUser = StaticFactory.getCurrentUserDetails();
                //SC-1249 : Introduce new Line Brand for Maersk L&S
                Set<String> setAllLinerBrands = new Set<String>();
                setAllLinerBrands.addAll(BrandUtilities.getAllBrandsList());
                setAllLinerBrands.add(linerBrandLogicUSF);
                Map<Id, Contact> mapRelatedCon;
                for(Case newCase : lstCases) {
                    Case oldCase;
                    if(mapOldCases != null && !mapOldCases.isEmpty()) {
                        oldCase = mapOldCases.get(newCase.Id);
                    }
                    
                    // When a USFlag User tries to create a Case manually
                    if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                        // RQ-004569: Populate MLL__c for cases created via chat for MLL customers.
                        // SC-1154 added default value for MLL case to US Military (USM)
                        if((newCase.Case_Channel__c == 'Chat' || newCase.Case_Channel__c == 'WhatsApp') && newCase.Origin != null && 
                           newCase.Origin.startsWith(BrandUtilities.getBrandShortForm(BrandUtilities.MLL)) || newCase.Case_Channel__c == 'Portal' && 
                           newCase.Origin != null && newCase.Origin == 'MLLUSFLG') {
                               newCase.MLL__c = true;
                               if(newCase.Type != 'Online Help'){
                                   newCase.Cargo_Classification__c = 'US Military (USM)';
                               }
                           }
                        
                        if(String.isBlank(newCase.SuppliedEmail) && currentUser.MLL__c == true && currentUser.Liner_Brand_Logic__c == linerBrandLogicUSF) {
                            newCase.Liner_Brand__c = BrandUtilities.MAERSKLINE;
                            newCase.MLL__c = currentUser.MLL__c;
                        }
                    }
                    //SC-2954 : Update On Behalf of Account from Contact for Proactive case channel 
                    if(newCase.Case_Channel__c == 'Proactive')
                    {
                        mapRelatedCon = casRecordSelector.mapRelatedContacts;
                        if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && newCase.On_Behalf_Account__c == NULL && newCase.contactId <> NULL && mapRelatedCon <> NULL && !mapRelatedCon.isEmpty() && mapRelatedCon.containsKey(newCase.contactId) && mapRelatedCon.get(newCase.contactId) != null && mapRelatedCon.get(newCase.contactId).SCM_on_behalf_of__c <> NULL && newCase.Product__c == Label.SCM) {
                            newCase.On_Behalf_Account__c  = mapRelatedCon.get(newCase.contactId).SCM_on_behalf_of__c;
                        }
                    }
                    
                    
                    // Code Block Start: #RQ-001774
                    if(String.isBlank(newCase.Liner_Brand__c)) {
                        if(!String.isBlank(newCase.Origin)) {
                            // Populate Liner Brand based on the Origin of the Case and LinerBrand_Direction_and_Country__mdt
                            if(caseRecordSelector.mapLBDCs != null) {
                                LinerBrand_Direction_and_Country__mdt lbdc = caseRecordSelector.mapLBDCs.get(newCase.Origin);
                                //SC-5414 changed to static method call CaseRecordSelector.mapSCMKC
                                SCM_Key_Client_Country_Mapping__mdt scmKC =  CaseRecordSelector.mapSCMKC.get(newCase.OwnerId);
                                if(lbdc != null) {
                                    mapRelatedCon = casRecordSelector.mapRelatedContacts;
                                    newCase.Liner_Brand__c = lbdc.Liner_Brand__c;
                                    // Populate MLL__c as well for USFlag
                                    // SC-1154 added default value for MLL case to US Military (USM)
                                    // To Avoid this condition being executed for LNS - SC-2289
                                    if((scmKC != null && newCase.Origin.startsWith('SCMGLOBAL')) || (scmKC != null && CaseRecordSelector.scmRestrictedOrigins.contains(newCase.Origin))){
                                        if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT){
                                            if(scmKC.On_Behalf_of_Account_ID__c != NULL && newCase.On_Behalf_Account__c == NULL){
                                                newCase.On_Behalf_Account__c  = scmKC.On_Behalf_of_Account_ID__c;
                                            }
                                            if(scmKC.SCM_KC_Indicator__c != NULL && newCase.SCM_KC_Indicator__c == NULL){
                                                newCase.SCM_KC_Indicator__c = scmKC.SCM_KC_Indicator__c;
                                            }
                                            //SC-7708 - Populate Direction from SCM metadata
                                            if(scmKC.Direction__c!= NULL && newCase.Direction__c != ''){
                                                newCase.Direction__c = scmKC.Direction__c;
                                            }
                                        } 
                                    }
                                    if(newCase.Origin.contains(BrandUtilities.getBrandShortForm(BrandUtilities.MLL)) && !(newCase.Origin.startsWith('LNS'))) { 
                                        newCase.MLL__c = true;
                                        newCase.Cargo_Classification__c = 'US Military (USM)';
                                    }
                                    
                                    //Sc-394 - Populate On behalf of account on case
                                    if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && lbdc.On_Behalf_of_Account_ID__c != NULL && newCase.On_Behalf_Account__c == NULL){
                                        newCase.On_Behalf_Account__c = lbdc.On_Behalf_of_Account_ID__c;
                                    } 
                                    //SC-1625 : Update On Behalf of Account from Contact
                                    else if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && newCase.On_Behalf_Account__c == NULL && newCase.contactId <> NULL && mapRelatedCon <> NULL && !mapRelatedCon.isEmpty()  && mapRelatedCon.containsKey(newCase.contactId) && mapRelatedCon.get(newCase.contactId) != null && mapRelatedCon.get(newCase.contactId).SCM_on_behalf_of__c <> NULL && newCase.Product__c == Label.SCM) {
                                        newCase.On_Behalf_Account__c = mapRelatedCon.get(newCase.contactId).SCM_on_behalf_of__c;
                                    }
                                }
                            }
                        }
                        else if(setAllLinerBrands.contains(currentUser.Liner_Brand_Logic__c)) {
                            // Populate Liner Brand based on the Liner Brand defined for the current user
                            newCase.Liner_Brand__c = currentUser.Liner_Brand__c;
                            // Populate MLL__c as well for USFlag
                            // SC-1154 added default value for MLL case to US Military (USM)
                            if(currentUser.Liner_Brand_Logic__c == linerBrandLogicUSF) { 
                                newCase.MLL__c = true;
                                newCase.Cargo_Classification__c = 'US Military (USM)';
                            }
                        }
                        else if(casRecordSelector.mapRelatedContacts != null && !casRecordSelector.mapRelatedContacts.isEmpty()) {
                            // If Case Creator has none or multiple Liner Brands then get the Liner Brand from respective Conatct.
                            Contact contactInstance = casRecordSelector.mapRelatedContacts.get(newCase.ContactId);
                            if(contactInstance != null) {
                                // v1.5 - Start: Populate Liner_Brand__c only when Contact is single branded.
                                String strContactLB = contactInstance.Liner_Brands__c;
                                
                                // SC-1404 : For External Manual cases, Liner Brand shouldn't be populated from Contact if user is multi-branded.
                                if(String.isEmpty(newCase.Liner_Brand__c)) {
                                    if(strContactLB != null && !strContactLB.Contains(';') && newCase.RecordTypeId != externalCaseRTId) {
                                        newCase.Liner_Brand__c = strContactLB;
                                    }
                                    else {
                                        newCase.addError(Label.LinerBrand_Population_Error);
                                    }
                                }
                                // v1.5 - End
                            }
                        }
                    }
                    // Code Block End: #RQ-001774
                }
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.populateLinerBrand', new list<Exception>{ex}); // #RQ-005636 
        }
    }
    
    /** 
* @description | Method to populate correct Contact based on the Liner Brand and Web Email of the Case. |
* @param lstCases accepts the list of Case Records
* @param casRecordSelector accepts the Class caseRecordSelector
*/ 
    public static void findUniqueLinerBrandContact(list<Case> lstCases, CaseRecordSelector casRecordSelector) {
        try {
            Id internalRTId = Contact.sObjectType.getDescribe(SObjectDescribeOptions.DEFAULT).getRecordTypeInfosByName().get('Internal Contact').getRecordTypeId();
            Id customerRTId = Contact.sObjectType.getDescribe(SObjectDescribeOptions.DEFAULT).getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId(); // v2.3: RQ-004895
            Id nonShippingPartyRTId = Contact.sObjectType.getDescribe(SObjectDescribeOptions.DEFAULT).getRecordTypeInfosByName().get('Non-shipping Party Contact').getRecordTypeId(); // v2.3: RQ-004895
            
            map<String, list<Contact>> mapEmailContacts = new map<String, list<Contact>>();
            for(Contact conIterator : casRecordSelector.mapRelatedContacts.values()) {
                // RQ-003041 - Removed internal contact check
                if(conIterator.AccountId != null && conIterator.IsDuplicate__c == false) { 
                    if(!mapEmailContacts.containsKey(conIterator.Email)) {
                        mapEmailContacts.put(conIterator.Email, new list<Contact>{conIterator});
                    } 
                    else {
                        mapEmailContacts.get(conIterator.Email).add(conIterator);
                    }
                }
            }
            
            Boolean bRefreshRecordSelector = false;
            for(Case newCase : lstCases) {
                // D-311 fix. Removing Internal Contacts added to the Cases.
                if(newCase.ContactId != null) {
                    Contact contactInstance = casRecordSelector.mapRelatedContacts.get(newCase.ContactId);
                    if(contactInstance != null && contactInstance.AccountId == null) {
                        newCase.ContactId = null;
                    }
                }
                
                if(newCase.SuppliedEmail != null && mapEmailContacts.containsKey(newCase.SuppliedEmail)) {
                    Id caseContactId = newCase.ContactId;
                    
                    newCase.ContactId = null;
                    newCase.AccountId = null;
                    
                    for(Contact conIterator : mapEmailContacts.get(newCase.SuppliedEmail)) {
                        // v1.5 - Start: Updated if condition to check for Deduped_Contact__c
                        // v2.0: RQ-004298 (Added condition "conIterator.RecordTypeId == internalRTId" to populate contact & account regardless of the liner brand for internal contacts. Remember that internal contacts are unique across all liner brands)
                        // v4.0: RQ-004895 (Updated condition to check liner brand for non deduped Non-shipping Party Contacts, others can ignore the liner brands check since they are already deduped)
                        if((newCase.ContactId == null || caseContactId != null)
                           // v4.0: RQ-007579 (NSP contacts are deduped, linerbrand specific check for cases in  populating contact and account can be removed.)
                           && (conIterator.RecordTypeId == internalRTId || conIterator.RecordTypeId == customerRTId || conIterator.RecordTypeId == nonShippingPartyRTId)
                           //|| (conIterator.RecordTypeId == nonShippingPartyRTId && conIterator.Deduped_Contact__c == false && conIterator.Liner_Brands__c != null && newCase.Liner_Brand__c != null && conIterator.Liner_Brands__c.Contains(newCase.Liner_Brand__c)))
                          ){
                              newCase.ContactId = conIterator.Id;
                              newCase.AccountId = conIterator.AccountId;
                              
                              casRecordSelector.setContactIds.add(newCase.ContactId);
                              casRecordSelector.setAccountIds.add(newCase.AccountId);
                              bRefreshRecordSelector = true;
                              
                              break;
                          }
                        // v1.5 - End
                    }
                }
            }
            
            // Since AccountId and ContactId are explicitly updated, refresh the Record Selector to make them available in all other places.
            if(bRefreshRecordSelector) {
                casRecordSelector.getRelatedAccounts();
                casRecordSelector.getRelatedContacts();
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.findUniqueLinerBrandContact', new list<Exception>{ex}); // #RQ-005636 
        }
    }
    
    /** 
* @description | SC-3762 - This is to update workflow status as soon as case gets closed. |
* @param lstCases accepts the list of Case Records
* @param mapOldCases Accepts key value pair for Id and Case
* @param casTriggerHandler accepts record for type CaseTriggerHandler
*/ 
    public static void updateWorkflowOnCaseClosure(list<Case> lstCases, map<Id, Case> mapOldCases, CaseTriggerHandler casTriggerHandler) {
        try{
            
            set<Id> closedInstantDOCaseIds = new set<Id>();
            list<Agent_Workflow__c> lstWorkflowToBeUpdated = new list<Agent_Workflow__c>();
            
            if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                for(Case newCase : lstCases){
                    
                    
                    Case  oldCase;
                    if(mapOldCases != null && !mapOldCases.isEmpty()) {
                        oldCase = mapOldCases.get(newCase.Id);
                    }
                    if(newCase.Status != oldCase.Status && (newCase.status == 'Closed - Resolved' || newCase.status == 'Closed - Not a case' || newCase.status == 'Closed - Reassigned' || newCase.status == 'Closed - Merged' || newCase.Status == 'Closed - Duplicate')) {                                                       
                        closedInstantDOCaseIds.add(newCase.Id);
                    }
                    
                }
                
                for(Agent_Workflow__c objAW : [Select Case_ID__c, Id from Agent_Workflow__c where Run_Instant_DO__c = true AND Case_ID__c IN:closedInstantDOCaseIds AND Status__c != 'Approved' AND Status__c != 'Rejected'])
                {
                    objAW.status__c = 'Manually handled';
                    lstWorkflowToBeUpdated.add(objAW);
                }
                if(Schema.sObjectType.Agent_Workflow__c.isUpdateable())
                {
                    update lstWorkflowToBeUpdated;
                }
                
                
            }
            
            
        }
        catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.updateWorkflowOnCaseClosure', new list<Exception>{ex}); // #RQ- 
        }
    }
    
    /** 
* @description | DOR-4331 - This is to update workflow owners as soon as case owner gets updated. |
* @param lstCases accepts the list of Case Records
* @param mapOldCases Accepts key value pair for Id and Case
* @param casTriggerHandler accepts record for type CaseTriggerHandler
*/
    public static void updateWorkflowOwner(list<Case> lstCases, map<Id, Case> mapOldCases, CaseTriggerHandler casTriggerHandler) {
        try{
            map<Id, Id> mapCaseIdToAId = new map<Id, Id>();
            list<Agent_Workflow__c> lstAWToUpdate = new list<Agent_Workflow__c>();
            
            //Get all workflows where instantDO is true for case
            for(Agent_Workflow__c objAW : [Select Case_ID__c, Id, OwnerId from Agent_Workflow__c where Run_Instant_DO__c = true AND Case_ID__c IN:lstCases]){
                mapCaseIdToAId.put(objAW.Case_ID__c, objAW.Id);
            }
            
            if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                for(Case newCase : lstCases){
                    if(mapCaseIdToAId.containsKey(newCase.Id)){
                        Case  oldCase;
                        if(mapOldCases != null && !mapOldCases.isEmpty()) {
                            oldCase = mapOldCases.get(newCase.Id);
                        }
                        if(newCase.OwnerId !=null && oldCase.OwnerId!= newCase.OwnerId && String.valueOf(newCase.OwnerId).startswith('005')){
                            Agent_Workflow__c objNew = new Agent_Workflow__c(); 
                            objNew.OwnerId = newCase.OwnerId;
                            objNew.Id = mapCaseIdToAId.get(newCase.Id);
                            lstAWToUpdate.add(objNew);
                        }
                    }
                }
            }
            if(!lstAWToUpdate.isEmpty()){
                update lstAWToUpdate;
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.updateWorkflowOwner', new list<Exception>{ex}); // 
        }
    }
    
    /** 
* @description | Method to associate appropriate Care Relationship to case records based on Liner Brand, Direction, Location Fields (starting from smallest level of Geography) |
* @param lstNewCases accepts the list of Case Records
* @param mapOldCases Accepts key value pair for Id and Case
* @param mapRelatedAccounts accepts record for type CaseTriggerHandler
*/
    public static void findCareRelationship(List<Case> lstNewCases, Map<Id, Case> mapOldCases, Map<Id, Account> mapRelatedAccounts) {
        try {
            // RQ-002250: Improve Case Trigger Recursion Control
            if(Generic_TriggerHandler.validateRunForMethod('CaseFieldPopulator.findCareRelationship()', 1)) {
                Set<Id> setAccountIds = new Set<Id>();
                Set<Id> setCountries = new Set<Id>();
                List<Case> lstCasesToAssociateSR = new List<Case>();
                Map<Id, List<Care_Relationship__c>> mapCareRelationships = new Map<Id, List<Care_Relationship__c>>();
                
                for(Case newCase : lstNewCases){
                    Id accountId;
                    String strCaseLBLogic = CaseUtilities.getLinerBrandLogic(newCase);
                    if(mapOldCases == null){
                        if(!String.isBlank(strCaseLBLogic) && !BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.USFLAG).contains(strCaseLBLogic)) { // No Care Relationship for US flag case.
                            if(newCase.On_Behalf_Account__c != null) {
                                accountId = newCase.On_Behalf_Account__c;
                            }
                            else if(newCase.AccountId != null) {
                                accountId = newCase.AccountId;
                            }
                        }
                    }
                    else{
                        Case oldCase = mapOldCases.get(newCase.Id);
                        if(!String.isBlank(strCaseLBLogic) && !BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.USFLAG).contains(strCaseLBLogic)) { // No Care Relationship for US flag case.
                            if(newCase.On_Behalf_Account__c != null && (oldCase.On_Behalf_Account__c != newCase.On_Behalf_Account__c 
                                                                        || oldCase.City__c != newCase.City__c || oldCase.Country__c != newCase.Country__c || oldCase.Direction__c != newCase.Direction__c 
                                                                        || oldCase.Cluster__c != newCase.Cluster__c || oldCase.Liner_Brand__c != newCase.Liner_Brand__c || oldCase.RecordTypeId != newCase.RecordTypeId)) {
                                                                            accountId = newCase.On_Behalf_Account__c;
                                                                        }
                            else if(newCase.AccountId != null && newCase.On_Behalf_Account__c == null && (oldCase.On_Behalf_Account__c != newCase.On_Behalf_Account__c || oldCase.AccountId != newCase.AccountId
                                                                                                          || oldCase.City__c != newCase.City__c || oldCase.Country__c != newCase.Country__c || oldCase.Direction__c != newCase.Direction__c 
                                                                                                          || oldCase.Cluster__c != newCase.Cluster__c || oldCase.Liner_Brand__c != newCase.Liner_Brand__c || oldCase.RecordTypeId != newCase.RecordTypeId)) {
                                                                                                              accountId = newCase.AccountId;
                                                                                                          }
                        }
                    }
                    if(accountId != null){
                        setAccountIds.add(accountId);
                        setCountries.add(newCase.Country__c);
                        lstCasesToAssociateSR.add(newCase);
                        Account accIterator = mapRelatedAccounts.get(accountId);
                        if(accIterator != null && accIterator.ParentId != null) {
                            setAccountIds.add(accIterator.ParentId);                        
                        }
                    }
                }
                
                if(!setAccountIds.isEmpty()){
                    for(Care_Relationship__c careRelationship : [select Id, Account__c, Country__c, Cluster__c, Direction__c, Location__c, Liner_Brand__c, Care_Business_Partner__r.Name from Care_Relationship__c where Account__c in :setAccountIds and Country__c in :setCountries and Status__c = :Label.ActiveStatus]){
                        if(mapCareRelationships.isEmpty() || !mapCareRelationships.containsKey(careRelationship.Account__c)) {
                            mapCareRelationships.put(careRelationship.Account__c, new List<Care_Relationship__c>{careRelationship});
                        }
                        else {
                            mapCareRelationships.get(careRelationship.Account__c).add(careRelationship);
                        }
                    }
                }
                
                if(!mapCareRelationships.isEmpty()){
                    for(Case newCase : lstCasesToAssociateSR){
                        Id accountId;
                        if(newCase.On_Behalf_Account__c != null){
                            accountId = newCase.On_Behalf_Account__c;
                        }
                        else if(newCase.AccountId != null){
                            accountId = newCase.AccountId;
                        }
                        newCase.Care_Relationship__c = null;
                        
                        // Assign Care Relationship based on the On Behalf Account or Account
                        if(mapCareRelationships.containsKey(accountId) && mapCareRelationships.get(accountId) != null) {
                            String careIdStr=CareRelationLogicHandler.setCareRelationship(newCase, mapCareRelationships.get(accountId));
                            newCase.Care_Relationship__c = careIdStr;
                        }
                        
                        // If still Care Relationship not found then assign Care Relationship based on the concern account
                        if(newCase.Care_Relationship__c == null) {
                            Account relatedAccount = mapRelatedAccounts.get(accountId);
                            if(relatedAccount != null && relatedAccount.ParentId != null && mapCareRelationships.containsKey(relatedAccount.ParentId) && mapCareRelationships.get(relatedAccount.ParentId) != null) {
                                String careIdStr=CareRelationLogicHandler.setCareRelationship(newCase, mapCareRelationships.get(relatedAccount.ParentId));
                                newCase.Care_Relationship__c = careIdStr;
                            }
                        }
                    }
                }
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.findCareRelationship', new List<Exception>{ex}); // #RQ-005636 
        }
    }
    
    /** 
* @description | Utility method which is called from findCareRelationship() to assign the Care Relationship based on the mentioned criterias |
* @param newCase accepts the list of Case Records
* @param lstCareRelationship Accepts list of Care Relationship Objects
*/
    /*private static void setCareRelationship(Case newCase, list<Care_Relationship__c> lstCareRelationship) {
        for(Care_Relationship__c care : lstCareRelationship) {
            if(((care.Direction__c == newCase.Direction__c || care.Direction__c == Label.DirectionBoth) && (newCase.City__c != null) && (newCase.City__c == care.Location__c) && (newCase.Country__c == care.Country__c) && (newCase.Liner_Brand__c == care.Liner_Brand__c))) {
                newCase.Care_Relationship__c = care.Id;
            }
        }
        
        if(newCase.Care_Relationship__c == null) {
            for(Care_Relationship__c care : lstCareRelationship) {
                if(((care.Direction__c == newCase.Direction__c || care.Direction__c == Label.DirectionBoth) && (newCase.Cluster__c != null) && (newCase.Cluster__c == care.Cluster__c) && (newCase.Country__c == care.Country__c) && (newCase.Liner_Brand__c == care.Liner_Brand__c))) {
                    newCase.Care_Relationship__c = care.Id;
                }
            }
        }
    }*/
    
    
    /** 
* @description |  v1.1: To Reset Refresh GCSS Data Check box to False: Start |
* @param lstCases accepts the list of Case Records
*/
    public static void resetRefreshGCSSDataForClaims(list<Case> lstCases) {
        for(Case caseRecord : lstCases) {
            caseRecord.Refresh_GCSS_Data__c = false;
        }
    }
    
    /** 
* @description |  v1.4: Assign ISR cases to queue based on liner brand |
* @param lstISRCases accepts the list of Case Records
* @param mapOldCases accepts key value pair for Id and Case Record
*/ 
    
    public static void assignISRCaseToQueue(list<Case> lstISRCases, map<Id, Case> mapOldCases) {
        //SC-160 : Trigger Recurrsion controller
        try{
            if(Generic_TriggerHandler.validateRunForMethod('CaseFieldPopulator.assignISRCaseToQueue()', 1)){
                set<String> setISRQueueNames = new set<String>();  
                set<String> set4PLISRQueueNames = new set<String>();
                list<Case> lstISRCasesforOwnerUpdate = new list<Case>();
                list<Case> lstISRCasesAssignedToSCMISRQueue = new list<Case>();
                list<Case> lstISRCasesAssignedto4PLISRQueue = new List<Case>();
                set<String> setSCMRESISRQueueNames = new set<String>();
                list<Case> lstISRCasesAssignedtoSCMRESISRQueue = new List<Case>();
                
                for(Case caseIterator : lstISRCases) {
                    //SC-1056 a temporary fix for ISR owner assignment 
                    //check for isr case with resolver deartment starts with SCM and assign SCM ISR queue otherwise update owner based on Liner brand 
                    // SC-1168 - L&S and SCM ISR queue assignment
                    // SC-4246 - ISR for Sealand L&S Claims
                    // SC-4522 - Owner for 4PL ISR
                    if(mapOldCases == null || (caseIterator.Liner_Brand__c != mapOldCases.get(caseIterator.Id).Liner_Brand__c || 
                                               caseIterator.Resolver_Dept__c != mapOldCases.get(caseIterator.Id).Resolver_Dept__c || 
                                               caseIterator.RecordTypeId != mapOldCases.get(caseIterator.Id).RecordTypeId || 
                                               caseIterator.SF_4PL_Account__c!=mapOldCases.get(caseIterator.Id).SF_4PL_Account__c||
                                               caseIterator.Multi_Carrier_Restricted_Account__c!=mapOldCases.get(caseIterator.Id).Multi_Carrier_Restricted_Account__c)){
                                                   //4PL Resolver dept logic                                 
                                                   if(caseIterator.Resolver_Dept__c.contains('4PL') && caseIterator.SF_4PL_Account__c!=null) {
                                                       lstISRCasesAssignedto4PLISRQueue.add(caseIterator);                                                
                                                       set4PLISRQueueNames.add('4PL'+ ' '+caseIterator.SF_4PL_Account__c +' '+caseIterator.Resolver_Dept__c.replace('4PL ','')+' '+ Label.ISR);
                                                   }
                                                   //Multi Carrier Restricted Resolver dept logic
                                                   else if(caseIterator.Resolver_Dept__c.contains('SCM (Restricted)') && caseIterator.Multi_Carrier_Restricted_Account__c!=null) {
                                                       lstISRCasesAssignedtoSCMRESISRQueue.add(caseIterator);                                                
                                                       setSCMRESISRQueueNames.add(caseIterator.Multi_Carrier_Restricted_Account__c +' '+ Label.ISR);
                                                   }
                                                   
                                                   //MC or SCM Resolver dept logic except for MC Legal
                                                   else if(!(caseIterator.Resolver_Dept__c==Label.MC_Legal && (BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.SEAGO).contains(caseIterator.Liner_Brand__c) || 
                                                                                                               BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.SEALAND).contains(caseIterator.Liner_Brand__c) || 
                                                                                                               BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MCC).contains(caseIterator.Liner_Brand__c))) && 
                                                           (caseIterator.Resolver_Dept__c.startsWithIgnoreCase('MC') || caseIterator.Resolver_Dept__c.startsWithIgnoreCase('SCM'))&& 
                                                           (BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MAERSKLS).contains(caseIterator.Liner_Brand__c)) ) {
                                                               lstISRCasesAssignedToSCMISRQueue.add(caseIterator);
                                                           } 
                                                   
                                                   //MC Legal Resolver dept logic                              
                                                   else if(((caseIterator.Resolver_Dept__c==Label.MC_Legal && (BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.SEAGO).contains(caseIterator.Liner_Brand__c) || 
                                                                                                               BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.SEALAND).contains(caseIterator.Liner_Brand__c) || 
                                                                                                               BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MCC).contains(caseIterator.Liner_Brand__c)))   ||  
                                                            !(caseIterator.Resolver_Dept__c.startsWithIgnoreCase('MC') || caseIterator.Resolver_Dept__c.startsWithIgnoreCase('SCM'))) && caseIterator.Liner_Brand__c != null) {
                                                                setISRQueueNames.add(caseIterator.Liner_Brand__c + ' ' + Label.ISR); // Appending with ISR to query ISR queues based on queue
                                                                lstISRCasesforOwnerUpdate.add(caseIterator);
                                                            }
                                                   //SC-7850 - ISR ownership for ECL ISR 
                                                   else if(caseIterator.Resolver_Dept__c.startsWithIgnoreCase('ECL') && BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MAERSKLINE).contains(caseIterator.Liner_Brand__c)){
                                                       lstISRCasesforOwnerUpdate.add(caseIterator);                                                     
                                                       setISRQueueNames.add(caseIterator.Liner_Brand__c + ' ' + Label.ISR);
                                                   }   
                                               }
                    
                }
                
                //update case owner to SCM, L&S ISR Queue 
                if(!lstISRCasesAssignedToSCMISRQueue.isEmpty()) {
                    for(Case cObj : lstISRCasesAssignedToSCMISRQueue) {
                        cObj.OwnerId = Label.SCM_ISR_Queue_ID;
                    }
                }
                
                if(!lstISRCasesAssignedto4PLISRQueue.isEmpty()) {
                    map<String, Id> map4PLQueueNameToID = StaticFactory.getQueueNameIdMapByNames('Case', set4PLISRQueueNames);
                    if(map4PLQueueNameToID != null && !map4PLQueueNameToID.isEmpty()) {
                        for(Case cObj : lstISRCasesAssignedto4PLISRQueue) {
                            if(map4PLQueueNameToID.containsKey('4PL'+' '+cObj.SF_4PL_Account__c +' '+cObj.Resolver_Dept__c.replace('4PL ','')+' '+ Label.ISR)) {
                                cObj.OwnerId = map4PLQueueNameToID.get('4PL'+ ' '+cObj.SF_4PL_Account__c +' '+cObj.Resolver_Dept__c.replace('4PL ','')+' '+ Label.ISR);
                            }
                        }
                    }
                }
                if(!lstISRCasesAssignedtoSCMRESISRQueue.isEmpty()) {
                    map<String, Id> mapSCMRESQueueNameToID = StaticFactory.getQueueNameIdMapByNames('Case', setSCMRESISRQueueNames);
                    if(mapSCMRESQueueNameToID != null && !mapSCMRESQueueNameToID.isEmpty()) {
                        for(Case cObj : lstISRCasesAssignedtoSCMRESISRQueue) {
                            if(mapSCMRESQueueNameToID.containsKey(cObj.Multi_Carrier_Restricted_Account__c +' '+ Label.ISR)) {
                                cObj.OwnerId = mapSCMRESQueueNameToID.get(cObj.Multi_Carrier_Restricted_Account__c +' '+ Label.ISR);
                            }
                        }
                    }
                }
                
                if(!setISRQueueNames.isEmpty()) {
                    map<String, Id> mapQueueNameToId = StaticFactory.getQueueNameIdMapByNames('Case', setISRQueueNames);
                    if(mapQueueNameToId != null && !mapQueueNameToId.isEmpty()) {
                        for(Case cObj : lstISRCasesforOwnerUpdate) {
                            if(mapQueueNameToId.containsKey(cObj.Liner_Brand__c + ' ' + Label.ISR)) {
                                cObj.OwnerId = mapQueueNameToId.get(cObj.Liner_Brand__c + ' ' + Label.ISR);
                            }
                        }
                    }
                }
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.assignISRCaseToQueue', new list<Exception>{ex}); // #RQ-005636 
        }
    }
    /** 
* @description |   RQ-008620
RQ-012299. Updated to add the language code for vendor cases as well.
This logic can be simplified once all the Vendor countries agree to use the regional language closure templates. |
* @param lstCases accepts the list of Case Records
* @param mapOldCases accepts key value pair for Id and Case
* @param casRecordSelector accepts record of type CaseRecordSelector
*/
    public static void populateClosurelangauge(list<Case> lstCases, map<Id, Case> mapOldCases, CaseRecordSelector casRecordSelector) {
        //SC-160 : Trigger Recurrsion controller
        try{
            if(Generic_TriggerHandler.validateRunForMethod('CaseFieldPopulator.populateClosurelangauge()', 1)){
                for(Case caseIterator : lstCases){
                    if((mapOldCases == null || 
                        caseIterator.Liner_Brand__c != mapOldCases.get(caseIterator.Id).Liner_Brand__c || 
                        caseIterator.Country__c != mapOldCases.get(caseIterator.Id).Country__c || 
                        caseIterator.ContactId != mapOldCases.get(caseIterator.Id).ContactId || 
                        caseIterator.Closure_Language_Code__c == null||caseIterator.Additional_Closure_Language_Code__c==null) && caseIterator.Liner_Brand__c != null && caseIterator.Country__c != null){
                            
                            String lang;
                            
                            
                            if(caseIterator.Country__c != null && caseIterator.accountId != null){
                                
                                if((!casRecordSelector.mapCountryIdName.isEmpty() && casRecordSelector.mapCountryIdName.containsKey(caseIterator.Country__c) && casRecordSelector.mapCountryIdName.get(caseIterator.Country__c) != null && Label.IMD_Vendor_Countries.contains(casRecordSelector.mapCountryIdName.get(caseIterator.Country__c)) && !casRecordSelector.mapRelatedAccounts.isEmpty() && casRecordSelector.mapRelatedAccounts.containsKey(caseIterator.accountId) && casRecordSelector.mapRelatedAccounts.get(caseIterator.accountId).Vendor_Type__c!=null )  ||(caseIterator.Origin != null && caseIterator.Origin.right(3) == 'IMD')){
                                    
                                    if(casRecordSelector.mapEmdts.get(caseIterator.Liner_Brand__c+casRecordSelector.mapCountryIdName.get(caseIterator.Country__c)+true) != null  ) {
                                        lang = casRecordSelector.mapEmdts.get(caseIterator.Liner_Brand__c+casRecordSelector.mapCountryIdName.get(caseIterator.Country__c)+true).Filter_3__c;
                                    }
                                    
                                    
                                }
                                //SC-1124 Update closure language as English for Account Based SCM BAs
                                //SC-1249 : Modified the liner brand condition for SCM cases to Maersk L&S
                                //SC-1234 Modified condition to default language as English for SCM Account based BA's
                                
                                // else if(caseIterator.Liner_Brand__c == 'Maersk L&S' && caseIterator.Product__c == 'SCM' && ((String.isNotBlank(caseIterator.Origin) && caseIterator.Origin.left(3) == 'SCM' && caseIterator.Origin.right(3) != 'SVC')||(String.isBlank(caseIterator.Origin) && String.isNotBlank(caseIterator.On_Behalf_Account__c)))){                              
                                //  lang = 'en_US';
                                //}
                                
                                
                                //RQ-012781.Moved this else section inside the if condition (caseIterator.Country__c != null && caseIterator.accountId != null)
                                else
                                {   
                                    if(casRecordSelector.mapEmdts.get(caseIterator.Liner_Brand__c+casRecordSelector.mapCountryIdName.get(caseIterator.Country__c)+false) != null  ){
                                        lang = casRecordSelector.mapEmdts.get(caseIterator.Liner_Brand__c+casRecordSelector.mapCountryIdName.get(caseIterator.Country__c)+false).Filter_3__c;
                                        
                                        
                                    }
                                    
                                }
                                
                            }
                            
                            if((String.isNotBlank(caseIterator.Origin) && (caseIterator.Origin.startsWith('SCM')|| caseIterator.Origin.startsWith('MAERSKFLOW')||caseIterator.Origin.startsWith('LNS'))) ||
                               (String.isBlank(caseIterator.Origin) && caseIterator.Liner_Brand__c == 'Maersk L&S' && caseIterator.Product__c == 'SCM' )){
                                   
                                   if(casRecordSelector.mapEmdts.get(caseIterator.Liner_Brand__c+casRecordSelector.mapCountryIdName.get(caseIterator.Country__c)+false) != null){
                                       
                                       lang = casRecordSelector.mapEmdts.get(caseIterator.Liner_Brand__c+casRecordSelector.mapCountryIdName.get(caseIterator.Country__c)+false).Filter_3__c;
                                       if(casRecordSelector.mapEmdts.containsKey(caseIterator.Liner_Brand__c+casRecordSelector.mapCountryIdName.get(caseIterator.Country__c)+false)){
                                           caseIterator.Additional_Closure_Language_Code__c=casRecordSelector.mapEmdts.get(caseIterator.Liner_Brand__c+casRecordSelector.mapCountryIdName.get(caseIterator.Country__c)+false).Additional_Language__c;
                                       }
                                   }
                               }
                            
                            //SC-7849 Update Case Closure Language ECL cases
                            if((String.isNotBlank(caseIterator.Origin) && (caseIterator.Origin.startsWith('ED') || caseIterator.Origin.startsWith('EF'))) ||                           
                               (String.isBlank(caseIterator.Origin) && String.isNotBlank(caseIterator.Product__c) && (caseIterator.Product__c.startsWithIgnoreCase('E-') || Label.EFR_Products.containsIgnoreCase(caseIterator.Product__c)) && String.isNotBlank(caseIterator.Liner_Brand__c) && BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MAERSKLINE).contains(caseIterator.Liner_Brand__c) ) ){
                                   
                                   if(casRecordSelector.mapEmdts.get('ECL'+casRecordSelector.mapCountryIdName.get(caseIterator.Country__c)+false) != null){
                                       lang = casRecordSelector.mapEmdts.get('ECL'+casRecordSelector.mapCountryIdName.get(caseIterator.Country__c)+false).Filter_3__c;
                                       if(casRecordSelector.mapEmdts.containsKey('ECL'+casRecordSelector.mapCountryIdName.get(caseIterator.Country__c)+false)){
                                           caseIterator.Additional_Closure_Language_Code__c=casRecordSelector.mapEmdts.get('ECL'+casRecordSelector.mapCountryIdName.get(caseIterator.Country__c)+false).Additional_Language__c;    
                                       }
                                   }
                               }
                            
                            //SC-8107 Update Case Closure Language to en_US Based on Owners Role for CashBox manual onboarding and based on Origin for Email-to-Case
                            if((String.isNotBlank(caseIterator.Origin) && caseIterator.Origin.equals('SCMRATEMNGGSC')) || (!casRecordSelector.mapOwnerandRole1.isEmpty() && casRecordSelector.mapOwnerandRole1.containsKey(caseIterator.OwnerId) && Label.SCM_CASHBOX_ROLENAME.CONTAINSIGNORECASE(casRecordSelector.mapOwnerandRole1.get(caseIterator.OwnerId)))){
                                
                                lang = 'en_US';
                            }
                            
                            if(lang != null){
                                caseIterator.Closure_Language_Code__c = lang;
                                
                            }
                            else{
                                caseIterator.Closure_Language_Code__c = 'en_US';
                            }
                        }
                }
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.populateClosurelangauge', new list<Exception>{ex}); // #RQ-005636 
        }
    }
    
    
    /** 
* @description |   RQ-008925 |
* @param mapQueueIdCase accepts key value pair with String and Case Record
* @param mapCountryNameCountryId accepts key value pair with String and String
*/
    public static void caseDetailsBasedonQueue(map<String,Case> mapQueueIdCase, map<String,String> mapCountryNameCountryId){
        //SC-481 : Trigger Recurrsion controller cannot be applied for this method
        //if(Generic_TriggerHandler.validateRunForMethod('CaseFieldPopulator.caseDetailsBasedonQueue()', 1)){     
        try{
            Map<String,LinerBrand_Direction_and_Country__mdt> mapQueueIdLBDCs = new Map<String,LinerBrand_Direction_and_Country__mdt>();
            mapQueueIdLBDCs = caseRecordSelector.getDataBasisOnOwner(mapQueueIdCase);
            for(String str :mapQueueIdCase.keyset()){
                String strName = str.substring(0,str.indexof('_'));
                if(mapQueueIdLBDCs.containskey(strName)){  
                    mapQueueIdCase.get(str).Cluster__c=null;
                    mapQueueIdCase.get(str).Region__c = null;
                    mapQueueIdCase.get(str).Liner_Brand__c =mapQueueIdLBDCs.get(strName).Liner_Brand__c;
                    mapQueueIdCase.get(str).Direction__c =mapQueueIdLBDCs.get(strName).Direction__c;
                    mapQueueIdCase.get(str).Country__c =mapCountryNameCountryId.get(mapQueueIdLBDCs.get(strName).Country__c);
                }
                
            }
            CaseGeoData.validateGeoData(mapQueueIdCase.values());  
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.caseDetailsBasedonQueue', new list<Exception>{ex}); // #RQ-005636 
        }
    }
    
    
    /** 
* @description | RQ-012315. Populate Value Proposition.
This method will be executed only during case creation and if the case owner is updated.
SC-199.Twill checkbox is no more a condition for updating the value proposition in case.
SC-493.Value Proposition Identification for Twill Cases |
* @param lstCases accepts the list of Case Records
* @param mapOldCases accepts key value pair with Id and Case record
* @param casRecordSelector accepts the class CaseRecordHandler
* @param casTriggerHandler accepts the Class CaseTriggerHandler
*/  
    public static void populateVPDeliveryChannel(list<Case> lstCases, map<Id, Case> mapOldCases, CaseRecordSelector casRecordSelector,CaseTriggerHandler casTriggerHandler) {
        try{
            if(Generic_TriggerHandler.validateRunForMethod('CaseFieldPopulator.populateVPDeliveryChannel()', 1)) {
                General_Key_Value_Configurations__mdt twillrec = General_Key_Value_Configurations__mdt.getinstance('Global_Twill_Queue');
                Id twillQId = twillrec.First_Field_Value__c;
                List<Case> validatedCasesList = validateOnBehalfOfAccountCases(lstCases);
                //SC-8651
                List<Case> setAsCargoFlowcases = new List<Case>();
                for(Case newCase : lstCases){
                    Case oldCase;
                    if(mapOldCases != null && !mapOldCases.isEmpty()) {
                        oldCase = mapOldCases.get(newCase.Id);
                    }
                    if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && (newCase.Origin == 'MSLGLOBALMAERSKGO' || newCase.OwnerId == twillQId)){
                        newCase.Delivery_Channel__c = 'MaerskGo';
                        //SC-8651
                        setAsCargoFlowcases.add(newCase);
                    }
                    
                    if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                        if(newCase.OwnerId != oldCase.OwnerId || newCase.recordtypeId != oldCase.recordtypeId){
                            if((casRecordSelector.lstExternalCases.contains(newCase) || casRecordSelector.lstISRCases.contains(newCase)) &&  newCase.OwnerId == twillQId){
                                newCase.Delivery_Channel__c = 'MaerskGo';  
                            }
                        }
                    }
                    Boolean validateOnBehalf = !validatedCasesList.isEmpty() && validatedCasesList.contains(newCase);
                    if(validateOnBehalf && casRecordSelector.mapRelatedAccounts!= null && !casRecordSelector.mapRelatedAccounts.isEmpty() && newCase.On_Behalf_Account__c!= null && casRecordSelector.mapRelatedAccounts.containsKey(newCase.On_Behalf_Account__c) && casRecordSelector.mapRelatedAccounts.get(newCase.On_Behalf_Account__c) != null && casRecordSelector.mapRelatedAccounts.get(newCase.On_Behalf_Account__c).Value_Proposition__c != null){
                        newCase.Value_Proposition__c = casRecordSelector.mapRelatedAccounts.get(newCase.On_Behalf_Account__c).Value_Proposition__c;
                    }
                    else if(casRecordSelector.mapRelatedAccounts!= null && !casRecordSelector.mapRelatedAccounts.isEmpty() && newCase.AccountId!= null && casRecordSelector.mapRelatedAccounts.containsKey(newCase.AccountId) && casRecordSelector.mapRelatedAccounts.get(newCase.AccountId) != null && casRecordSelector.mapRelatedAccounts.get(newCase.AccountId).Value_Proposition__c != null){
                        newCase.Value_Proposition__c = casRecordSelector.mapRelatedAccounts.get(newCase.AccountId).Value_Proposition__c;
                    }
                    else{ 
                        newCase.Value_Proposition__c = '';
                    }
                }     
                //SC-8651 Set cargo flow to true & change ownership to HQ Twill Queue if the given pattern matches
                if(!setAsCargoFlowcases.isempty()){
                    populateCargoFlowForTwill(setAsCargoFlowcases);
                }
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.populateVPDeliveryChannel', new list<Exception>{ex});  
        }
    }
    
    /**    
* @description | SC-8651 - Populate cargo flow for twill cases|  
* @param lstCases accepts case list 
*/  
    public static void populateCargoFlowForTwill(List<Case> lstCases){  
        try { 
            if(Generic_TriggerHandler.validateRunForMethod('CaseFieldPopulator.populateCargoFlowForTwill()', 1)) {
                General_Key_Value_Configurations__mdt twillHQCargoFlowInstance = General_Key_Value_Configurations__mdt.getinstance('TwillHQCargoFlow');
                Id twillHQCargoFlowQueueId = twillHQCargoFlowInstance.First_Field_Value__c;   
                for(Case newCase: lstCases){
                    if(String.isnotblank(newCase.Subject) && String.isnotblank(newCase.Case_Channel__c) && (newCase.Case_Channel__c == 'E-mail'|| newCase.Case_Channel__c == 'Portal' || newCase.Case_Channel__c == 'Website')){
                        String caseSubject = newCase.subject.deleteWhitespace();
                        if(caseSubject.containsIgnoreCase('MaerskGoActionRequired')||caseSubject.containsIgnoreCase('TwillActionRequired')){
                            newCase.Cargo_Flow__c = True;
                            newCase.OwnerId = twillHQCargoFlowQueueId;
                        }  
                    }
                }                           
            }   
        }   
        catch(Exception ex){    
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.populateCargoFlowForTwill '+lstCases[0].casenumber, new list<Exception>{ex});      
        }   
    }
    
    /** 
* @description | SC-391. Code to populate "Supplier" field of case. These is done by fetching Accounts "Supplier" on insert or whenever Account related to the case changes |
* @param lstCases accepts the list of Case Records
* @param mapOldCases accepts key value pair with Id and Case record
* @param casRecordSelector accepts the class CaseRecordHandler
*/
    public static void populateSupplier(list<Case> lstCases, map<Id, Case> mapOldCases, CaseRecordSelector casRecordSelector) {
        try{
            if(Generic_TriggerHandler.validateRunForMethod('CaseFieldPopulator.populateSupplier()', 1)) {
                if(mapOldCases == null){
                    for(Case newCase : lstCases){
                        if(casRecordSelector.mapRelatedAccounts!= null && newCase.AccountId!= null && casRecordSelector.mapRelatedAccounts.get(newCase.AccountId).LS_CM_SCM_Supplier__c != false){
                            newCase.LS_CM_SCM_Supplier__c = casRecordSelector.mapRelatedAccounts.get(newCase.AccountId).LS_CM_SCM_Supplier__c;
                        }
                    }
                }
                else{            
                    for(Case newCase : lstCases){             
                        if(casRecordSelector.mapRelatedAccounts!= null && newCase.AccountId!= null && newCase.AccountId != mapOldCases.get(newCase.Id).AccountId){
                            newCase.LS_CM_SCM_Supplier__c = casRecordSelector.mapRelatedAccounts.get(newCase.AccountId).LS_CM_SCM_Supplier__c;
                        }
                        if(newCase.AccountId == null){  
                            newCase.LS_CM_SCM_Supplier__c = false;
                        }
                    }
                }
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.populateShipper', new list<Exception>{ex});  
        }
    }
    
    
    /** 
* @description | SC-594. Code to populate "BE Code" field of case. These is done by fetching Accounts "Damco BE code" on insert or whenever Account related to the case changes |
* @param lstCases accepts the list of Case Records
* @param mapOldCases accepts key value pair with Id and Case record
* @param casRecordSelector accepts the class CaseRecordHandler
*/
    public static void populateBECode(list<Case> lstCases, map<Id, Case> mapOldCases, CaseRecordSelector casRecordSelector) {
        try{
            if(Generic_TriggerHandler.validateRunForMethod('CaseFieldPopulator.populateBECode()', 1)) {
                if(mapOldCases == null){
                    for(Case caseIterator : lstCases){
                        if(casRecordSelector.mapRelatedAccounts!= null && caseIterator.AccountId!= null && casRecordSelector.mapRelatedAccounts.get(caseIterator.AccountId).Damco_BE_Code__c != null){
                            caseIterator.BE_Code__c = casRecordSelector.mapRelatedAccounts.get(caseIterator.AccountId).Damco_BE_Code__c;
                        }
                    }
                }
                else{            
                    for(Case caseIterator : lstCases){             
                        if(casRecordSelector.mapRelatedAccounts!= null && caseIterator.AccountId!= null && caseIterator.AccountId != mapOldCases.get(caseIterator.Id).AccountId){
                            caseIterator.BE_Code__c = casRecordSelector.mapRelatedAccounts.get(caseIterator.AccountId).Damco_BE_Code__c;
                        } 
                        if(caseIterator.AccountId == null){  
                            caseIterator.BE_Code__c = '';
                        }
                    }
                }
            }
        }catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.populateBECode', new list<Exception>{ex});  
        }
    }
    
    
    /** 
* @description | Case cannot be closed until all the workflows under it is closed (approved/Rejected).  |
* @param newMap accepts key value pair with Id and Case Record
* @param oldMap accepts key value pair with Id and Case Record
*/
    public static void handleCaseClosure( Map<Id,Case> newMap,Map<Id,Case> oldMap ){
        try{
            if(Generic_TriggerHandler.validateRunForMethod('CaseFieldPopulator.handleCaseClosure()', 1)) {
                set<Id> closedCaseIds = new set<Id>();
                for( Id newCaseId : newMap.keySet() ){
                    if( newMap.get( newCaseId ).Status.contains( 'Closed' ) && newMap.get( newCaseId ).Reason_For_Case__c == Label.WorkFlow_Request_Portal_RFC && newMap.get( newCaseId ).Status != oldMap.get( newCaseId ).Status ){
                        closedCaseIds.add( newCaseId );
                    }    
                }
                
                if( !closedCaseIds.isEmpty() ){
                    for( Agent_Workflow__c aw : [ SELECT ID,Case_ID__c FROM Agent_Workflow__c WHERE Case_ID__c IN : closedCaseIds AND Status__c NOT IN ('Approved','Rejected') ] ){
                        newMap.get( aw.Case_ID__c ).addError( Label.CaseClosureForWorkflows );
                    }
                }
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.handleCaseClosure', new list<Exception>{ex});  
        }
    }
    
    /** 
* @description | SC-825 User 'Manager' Fields as a filter on CM
SC-1160 : Optimized the update 'IF' condition to prevent unwanted blank update on Case Owner Manager update |
* @param lstCases accepts the list of Case Records
* @param mapOldCases accepts key value pair with Id and Case record
* @param casTriggerHandler accepts the class CaseTriggerHandler
*/
    public static void updateCaseOwnerManger(list<Case> lstCases, map<Id, Case> mapOldCases, CaseTriggerHandler casTriggerHandler){
        try{
            Map<Id,User> usrMgrMap =new Map<Id,User>();
            set<Id> caseOwnerId= new Set<Id> ();
            
            for(Case newCase : lstCases){
                if(newCase.OwnerId !=null && String.valueOf(newCase.OwnerId).Substring(0,3) == '005'){ 
                    caseOwnerId.add(newCase.OwnerId);
                }
            }
            if(!caseOwnerId.isEmpty()){               
                usrMgrMap =StaticFactory.getCaseOwnerDetails(caseOwnerId);
            }
            /*
for(User usr : [select id,manager.Name from user where Id in :caseOwnerId]){
usrMgrMap.put(usr.Id,usr.Manager.Name);             
}
*/
            if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT ) {
                for(Case newCase : lstCases){
                    if(newCase.OwnerId !=null && String.valueOf(newCase.OwnerId).Substring(0,3) == '005' && usrMgrMap.get(newCase.OwnerId) != null && usrMgrMap.get(newCase.OwnerId).manager.Name != null){ 
                        newCase.Case_Owner_Manager__c=  usrMgrMap.get(newCase.OwnerId).manager.Name;
                    }else{
                        newCase.Case_Owner_Manager__c= '';
                    }
                }
            } 
            else if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                for(Case newCase : lstCases){
                    Case  oldCase;
                    if(mapOldCases != null && !mapOldCases.isEmpty()) {
                        oldCase = mapOldCases.get(newCase.Id);
                    }
                    if(newCase.OwnerId !=null && oldCase.OwnerId!= newCase.OwnerId ){
                        if(String.valueOf(newCase.OwnerId).Substring(0,3) == '005' && usrMgrMap.get(newCase.OwnerId) != null && usrMgrMap.get(newCase.OwnerId).manager.Name != null){
                            newCase.Case_Owner_Manager__c= usrMgrMap.get(newCase.OwnerId).manager.Name;
                        }
                        else{
                            newCase.Case_Owner_Manager__c= '';
                        }                       
                    }
                }
            }
        }
        catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.updateCaseOwnerManger', new list<Exception>{ex}); 
        }
    }
    
    /** 
* @description | populate Shipment number & Shipment lookup from subject or description
* @param lstCases accepts the list of Case Records
*/
    public static void populateShipmentNumberFromSubject(list<Case> lstCases){
        try{
            List<Case> csListToProcess = new List<Case>();
            Set<String> shipmentNumberSet = new Set<String>();
            List<Case> csListToUpdateDeliveryChannel = new List<Case>();
            for(Case cs : lstCases){
                if((cs.Case_Channel__c == 'E-mail' || cs.Case_Channel__c == 'Portal') && (!String.isEmpty(cs.Subject) || !String.isEmpty(cs.Description)) && (String.isEmpty(cs.Shipment_Number__c))){
                    List<String> lstPatternMatchedStr = new List<String>();
                    Boolean isHumbBrand = false;
                    if(!String.isEmpty(cs.Liner_Brand__c)){                      
                        if(BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.HAMBURGSUD).contains(cs.Liner_Brand__c)){
                            isHumbBrand = true;
                        }
                    }
                    
                    if(!String.isEmpty(cs.Subject) && cs.Origin != Null && (!isHumbBrand || !cs.Origin.startsWith(BrandUtilities.getBrandShortForm(BrandUtilities.HAMBURGSUD)))){
                        for(String str : cs.Subject.replaceAll(Label.Replace_Special_Char_Case_Subject,' ').split(' ')){     
                            if(str.length() >= 9){                 
                                Matcher alphanumericMatcher = Pattern.compile(Label.Shipment_Alphanumeric_Regex).matcher(str);
                                if(alphanumericMatcher.find()){
                                    lstPatternMatchedStr.add(str);
                                }
                            }
                        }
                    }
                    
                    cs.Shipment_Number__c = !lstPatternMatchedStr.isEmpty() ? lstPatternMatchedStr[0] : '';
                    if(String.isEmpty(cs.Shipment_Number__c)){
                        if(String.isBlank(cs.Shipment_Number__c) && cs.Description != Null && cs.Origin != null && (!isHumbBrand || !cs.Origin.startsWith(BrandUtilities.getBrandShortForm(BrandUtilities.HAMBURGSUD)))){ 
                            Integer wordCount= 0;
                            for(String str : cs.Description.normalizeSpace().replaceAll(Label.Replace_Special_Char_Case_Subject,' ').replaceAll('  ',' ').split(' ')){     
                                wordCount++;
                                if(wordCount<= Integer.valueOf(Label.ShipmentDescripWordLimit)){
                                    if(str.length() >= 9){
                                        Matcher alphanumericMatcher = Pattern.compile(Label.Shipment_Alphanumeric_Regex).matcher(str);
                                        if(alphanumericMatcher.find()){
                                            lstPatternMatchedStr.add(str);
                                            break;
                                        }
                                    }
                                }else{
                                    break;
                                }
                            }
                            cs.Shipment_Number__c = !lstPatternMatchedStr.isEmpty() ? lstPatternMatchedStr[0] : '';
                        }
                    }
                    
                    if(!String.isEmpty(cs.Shipment_Number__c)){
                        shipmentNumberSet.add(cs.Shipment_Number__c);
                        csListToProcess.add(cs);
                    }
                    
                    
                }
            }
            if(!shipmentNumberSet.isEmpty()){
                Map<String, Shipment__c> shipmentMap = new Map<String, Shipment__c>();
                Map<String, TP_Doc__c> tpDocMap = new Map<String, TP_Doc__c>();
                for(Shipment__c ship : [Select Id, Shipment_Number__c, Product_Delivery_Agreement_Type__c, Property_Type_Name__c From Shipment__c Where Shipment_Number__c != null AND Shipment_Number__c =: shipmentNumberSet]){
                    shipmentMap.put(ship.Shipment_Number__c, ship);
                }
                for(TP_Doc__c tp : [Select Id, TP_Doc_Number__c, Shipment_Number__c, Shipment_Number__r.Shipment_Number__c, Shipment_Number__r.Product_Delivery_Agreement_Type__c, Shipment_Number__r.Property_Type_Name__c From TP_Doc__c Where TP_Doc_Number__c != null AND TP_Doc_Number__c =: shipmentNumberSet]){
                    if(tp.Shipment_Number__c != null && !String.isBlank(tp.Shipment_Number__r.Shipment_Number__c)){
                        tpDocMap.put(tp.TP_Doc_Number__c, tp);
                    }
                }
                if(!csListToProcess.isEmpty()){
                    for(Case cs : csListToProcess){
                        if(!shipmentMap.isEmpty() && shipmentMap.containsKey(cs.Shipment_Number__c)){
                            cs.Shipment__c = shipmentMap.get(cs.Shipment_Number__c).Id;
                        }//SC-9357
                        else if(!tpDocMap.isEmpty() && tpDocMap.containsKey(cs.Shipment_Number__c)){
                            TP_Doc__c tp = tpDocMap.get(cs.Shipment_Number__c);
                            cs.Shipment__c = tp.Shipment_Number__c;
                            cs.Shipment_Number__c = tp.Shipment_Number__r.Shipment_Number__c;
                            shipmentMap.put(tp.Shipment_Number__r.Shipment_Number__c, new Shipment__c(Product_Delivery_Agreement_Type__c = tp.Shipment_Number__r.Product_Delivery_Agreement_Type__c, Property_Type_Name__c = tp.Shipment_Number__r.Property_Type_Name__c));
                        }
                        if(String.isEmpty(cs.Delivery_Channel__c)){
                            csListToUpdateDeliveryChannel.add(cs);
                        }
                    }
                    if(!csListToUpdateDeliveryChannel.isEmpty()){
                        populateDeliveryChannel(csListToUpdateDeliveryChannel, shipmentMap);
                    }
                }
            }
        }
        catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.populateShipmentNumberFromSubject', new list<Exception>{ex}); 
        }
    }
    
    /** 
* @description | populate Delivery channel on case
* @param csList accepts the list of Case Records
* @param shipmentMap accepts map of shipment
*/
    public static void populateDeliveryChannel(List<Case> csList, Map<String, Shipment__c> shipmentMap) {
        try{
            General_Key_Value_Configurations__mdt twillrec = General_Key_Value_Configurations__mdt.getinstance('Global_Twill_Queue');
            List<String> originArtemisGE = CaseRecordSelector.originArtemisGE;
            //SC-8651
            List<Case> setAsCargoFlowcases = new List<Case>();
            
            Id twillQId = twillrec.First_Field_Value__c;
            for(Case cs : csList){
                if(shipmentMap.containsKey(cs.Shipment_Number__c)){
                    String productDeliveryAgreementType = shipmentMap.get(cs.Shipment_Number__c).Product_Delivery_Agreement_Type__c;
                    String bksValue = shipmentMap.get(cs.Shipment_Number__c).Property_Type_Name__c;
                    if(!String.isEmpty(productDeliveryAgreementType) && productDeliveryAgreementType.containsIgnoreCase('Spot')){
                        cs.Delivery_Channel__c = 'Spot';      
                    }
                    else if(!String.isEmpty(productDeliveryAgreementType) && productDeliveryAgreementType.containsIgnoreCase('Twill')){
                        cs.Delivery_Channel__c = 'MaerskGo';
                        //SC-8651
                        setAsCargoFlowcases.add(cs);
                        if(string.isNotBlank(cs.Liner_brand__c) && !BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MAERSKLS).contains(cs.Liner_Brand__c) 
                           && !(!originArtemisGE.isEmpty() && originArtemisGE.contains(cs.Origin))){
                               if(cs.OwnerId != twillQId){
                                   cs.OwnerId = twillQId;
                               }                        
                           }
                    }
                    
                    if(!String.isEmpty(bksValue)){
                        if(bksValue.containsIgnoreCase('LnS - Booking Services')) {
                            cs.Delivery_Channel__c = 'Booking Services (BKS)';
                        }
                    }
                }
            } 
            //SC-8651 Set cargo flow to true & change ownership to HQ Twill Queue if the given pattern matches
            if(!setAsCargoFlowcases.isempty()){
                populateCargoFlowForTwill(setAsCargoFlowcases);
            }
        }catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.populateDeliveryChannel', new list<Exception>{ex});  
        }
    }
    
    /** 
* @description | SC-8822 -> Validate Shipment Number from Case |
* @param newCase accepts a case
* @return Case
*/
    public static Case validateShipmentNumber(Case newCase){
        //SC-9159
        if(Generic_TriggerHandler.validateRunForMethod('CaseFieldPopulator.validateShipmentNumber()', 1)) {            
            try{
                List<String> lstPatternMatchedStr = new List<String>();                        
                Boolean isHumbBrand = false;
                if(String.isnotBlank(newCase.Liner_Brand__c)){                      
                    if(BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.HAMBURGSUD).contains(newCase.Liner_Brand__c)){
                        isHumbBrand = true;
                    }
                }
                
                // Bug fix for SC-1715
                if((!isHumbBrand || !newCase.Origin.startsWith(BrandUtilities.getBrandShortForm(BrandUtilities.HAMBURGSUD)))){
                    if(!String.isBlank(newCase.Shipment_Number__c) && newCase.Shipment_Number__c.length() >= 9)  {                 
                        Matcher alphanumericMatcher = Pattern.compile(Label.Shipment_Alphanumeric_Regex).matcher(newCase.Shipment_Number__c);
                        if(alphanumericMatcher.find()){
                            lstPatternMatchedStr.add(newCase.Shipment_Number__c);
                        }
                    }
                }
                
                //SC-8258
                String shipmentNumber = !lstPatternMatchedStr.isEmpty() ? lstPatternMatchedStr[0] : '';
                if (String.isnotBlank(shipmentNumber)){
                    return newCase;
                }
            }catch(Exception ex){
                ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.validateShipmentNumber1'+newCase.casenumber, new list<Exception>{ex}); 
                return null;
            } 
        } 
        return null;
    }
    
    /** 
* @description | SC-1256 : moved the logic for updating Send Case Case closure field to this class from case record selector |
* @param lstCases accepts the list of Case Records
* @param mapOldCases accepts key value pair with Id and Case record
* @param casTriggerHandler accepts the class CaseTriggerHandler
* @param casRecordSelector accepts the class CaseTriggerHandler
*/
    public static void updateSendCaseClosure(list<Case> lstCases,map<Id, Case> mapOldCases,CaseTriggerHandler casTriggerHandler,CaseRecordSelector casRecordSelector){
        Id externalCaseRTId = Label.External_Case_RT_Id;
        Map<Id, Contact> mapRelatedContacts;
        mapRelatedContacts = casRecordSelector.mapRelatedContacts;
        //SC-5415 Made ExcludedCaseOrigins to static variable
        List<String> excludedOrigins = CaseRecordSelector.csatExcludedCaseOrigins;
        Set<Id> setContactIds = new set<Id>();
        // RQ-008889: Prevent survey sent to internal contacts.                      
        // RQ-009429 : The Sent Case Closure is set to 'No' expect for external RT 
        // RQ-008890 : set case closure to no for chat cases 
        // SC - 141 : Added Telephone channel to exclude CSAT.       
        // SC-1146 -CSAT excluded  for SEAGLOBALSALES and MSLGLOBALSALES   
        //SC -1207 :Condition Removed for Mll CSAt -|| (newCase.MLL__c == True && newCase.RecordTypeId == externalCaseRTId)  
        // SC -1256  CSAT Closure opt-out option for customers
        // SC-1755 : Condition added to check if Country based One Team Sales on insert
        try{
            if(mapRelatedContacts.isEmpty() || mapRelatedContacts == null ){
                for(Case newCase : lstCases){
                    if(newCase.ContactId != null){
                        setContactIds.add(newCase.ContactId);
                    }
                    Case oldCase;
                    if(mapOldCases != null && !mapOldCases.isEmpty()) {
                        oldCase = (Case)mapOldCases.get(newCase.Id);
                    }
                    if(oldCase != null && oldCase.ContactId != newCase.ContactId){
                        setContactIds.add(oldCase.ContactId);
                    }
                }
                if(!setContactIds.isEmpty()){
                    mapRelatedContacts = new map<Id, Contact>([select Id, CSAT_Opt_Out__c from Contact where Id in :setContactIds]);  
                }   
            }                    
            for(Case newCase : lstCases){
                if(mapOldCases == null){
                    if(newCase.RecordTypeId != externalCaseRTId ||
                       //SC-5414 removed method checkInternalContactDomain from this class and reusing from CaseRecordselector & Made ExcludedCaseOrigins to static variable to reduce SOQL
                       ((CaseRecordSelector.checkInternalContactDomain(newCase) || newCase.Sub_Type__c == 'Dispute' ||newCase.Case_Channel__c == 'Chat' || newCase.Case_Channel__c == 'WhatsApp' ||newCase.Case_Channel__c == 'Telephone'||Label.Survey_Channels_Excluded.Contains(newCase.Case_Channel__c))||((newCase.Origin!=null) && (newCase.Origin.contains('GLOBALSALES') || (newCase.Origin.left(3).contains('MSL') && newCase.Origin.right(3).contains('SAL'))||CaseRecordSelector.csatExcludedCaseOrigins.contains(newCase.Origin))) && newCase.Send_Case_Closure__c == 'Yes')){                
                           newCase.Send_Case_Closure__c = 'No';                
                           newCase.Case_Closure_Opt_Out_Reason__c = 'System Exclusion'; 
                       }
                    else if(mapRelatedContacts.get(newCase.ContactId) != null && mapRelatedContacts.get(newCase.ContactId).CSAT_Opt_Out__c == true){
                        newCase.Send_Case_Closure__c = 'No'; 
                        newCase.Case_Closure_Opt_Out_Reason__c = 'Customer Requested Exclusion'; 
                    }
                }
                else{
                    Case oldCase = (Case)mapOldCases.get(newCase.Id);
                    //SC-5414 removed method checkInternalContactDomain from this class and reusing from CaseRecordselector
                    Boolean isIntrnlCntctDomnNewCase = CaseRecordSelector.checkInternalContactDomain(newCase);
                    if(newCase.RecordTypeId != externalCaseRTId){
                        newCase.Send_Case_Closure__c = 'No';                
                        newCase.Case_Closure_Opt_Out_Reason__c = 'System Exclusion'; 
                    }
                    else if(((newCase.ContactId != oldCase.ContactId ||  newCase.ContactId != null) && isIntrnlCntctDomnNewCase) ||
                            doNotSentClosureEmail(newCase, oldCase, externalCaseRTId, excludedOrigins)) {
                                newCase.Send_Case_Closure__c = 'No';                
                                newCase.Case_Closure_Opt_Out_Reason__c = 'System Exclusion'; 
                            }
                    
                    else if(mapRelatedContacts.get(newCase.ContactId) != null && mapRelatedContacts.get(newCase.ContactId).CSAT_Opt_Out__c == true &&((newCase.Case_Channel__c != 'Telephone' && newCase.Case_Channel__c != 'Chat' && newCase.Case_Channel__c != 'WhatsApp')|| ((newCase.Case_Channel__c == 'Telephone' || newCase.Case_Channel__c == 'Chat' || newCase.Case_Channel__c == 'WhatsApp')  && newCase.Send_Case_Closure__c == 'Yes') )){
                        newCase.Send_Case_Closure__c = 'No'; 
                        newCase.Case_Closure_Opt_Out_Reason__c = 'Customer Requested Exclusion'; 
                    }
                    
                    else if(oldCase.ContactId != newCase.ContactId && mapRelatedContacts.get(newCase.ContactId) != null && mapRelatedContacts.get(oldCase.ContactId) != null && 
                            mapRelatedContacts.get(newCase.ContactId).CSAT_Opt_Out__c == false && mapRelatedContacts.get(oldCase.ContactId).CSAT_Opt_Out__c == true && ((newCase.Case_Channel__c == 'Telephone' || newCase.Case_Channel__c == 'Chat'|| newCase.Case_Channel__c == 'WhatsApp') && newCase.Send_Case_Closure__c != 'Yes')
                           ){
                               newCase.Send_Case_Closure__c = 'No';                
                               newCase.Case_Closure_Opt_Out_Reason__c = 'System Exclusion';
                           }
                    //SC-5414 removed method checkInternalContactDomain from this class and reusing from CaseRecordselector
                    else  if(((CaseRecordSelector.checkInternalContactDomain(oldCase) && !isIntrnlCntctDomnNewCase)  || sentClosureEmail(newCase, oldCase, externalCaseRTId,mapRelatedContacts)) && newCase.Case_Channel__c != 'Telephone' &&  newCase.Case_Channel__c != 'Chat' && newCase.Case_Channel__c != 'WhatsApp'){  
                        newCase.Send_Case_Closure__c = 'Yes';
                        newCase.Case_Closure_Opt_Out_Reason__c = '';  
                    }
                }
            }
        }
        catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.updateSendCaseClosure', new list<Exception>{ex}); 
        }
    }
    
    // condition to check for not sending the survey
    // SC-1755 : Condition added to check if Country based One Team Sales
    private static Boolean doNotSentClosureEmail(Case newCase, Case oldCase, Id externalCaseRTId ,list<string> excludedOrigins) {  
        return ((
            ((newCase.Sub_Type__c != oldCase.Sub_Type__c  && newCase.Sub_Type__c == 'Dispute') || newCase.Sub_Type__c == 'Dispute') || ((newCase.Reason_For_Case__c != oldCase.Reason_For_Case__c  && newCase.Reason_For_Case__c == 'EMR 3rd Party Invoice Disputes') || newCase.Reason_For_Case__c == 'EMR 3rd Party Invoice Disputes') || 
            ((newCase.RecordTypeId != oldCase.RecordTypeId  && newCase.RecordTypeId != externalCaseRTId) || newCase.RecordTypeId != externalCaseRTId) || 
            ((newCase.Case_Channel__c !=  oldCase.Case_Channel__c && Label.Survey_Channels_Excluded.Contains(newCase.Case_Channel__c)) || Label.Survey_Channels_Excluded.Contains(newCase.Case_Channel__c)) || 
            (((newCase.Origin!=null) && (newCase.Origin.contains('GLOBALSALES') || (newCase.Origin.left(3).contains('MSL') && newCase.Origin.right(3).contains('SAL')) || excludedOrigins.contains(newCase.Origin))) && newCase.RecordTypeId == externalCaseRTId)
            
            
        ));
    }
    // condition to check for sending the survey
    private static Boolean sentClosureEmail(Case newCase, Case oldCase, Id externalCaseRTId,map<Id, Contact> mapRelatedContacts ) {
        return((
            (oldCase.Sub_Type__c == 'Dispute'  && newCase.Sub_Type__c != 'Dispute')             ||
            (oldCase.Reason_For_Case__c == 'EMR 3rd Party Invoice Disputes'  && newCase.Reason_For_Case__c != 'EMR 3rd Party Invoice Disputes')             ||
            (oldCase.RecordTypeId !=externalCaseRTId  && newCase.RecordTypeId == externalCaseRTId) ||
            (Label.Survey_Channels_Excluded.Contains(oldCase.Case_Channel__c) && !Label.Survey_Channels_Excluded.Contains(newCase.Case_Channel__c)) ||
            (oldCase.ContactId != newCase.ContactId && mapRelatedContacts.get(newCase.ContactId) != null && mapRelatedContacts.get(newCase.ContactId).CSAT_Opt_Out__c == false)
        ));
    }
    
    /** 
* @description | Validation for financial details for Closed - Paid claim cases |
* @param newCaseMap accepts the key value pair with Id and Case record
* @param oldCaseMap accepts key value pair with Id and Case record
*/
    public static void validateClaimCase (Map<Id,Case> newCaseMap, Map<Id,Case> oldCaseMap){
        List<Financial_Details__c> lstFinDet = new List<Financial_Details__c>();
        Map<Id,List<Financial_Details__c>> mapCaseIdtoFinDet = new Map<Id,List<Financial_Details__c>>();
        Id claimRTId = Label.Claim_Case_RT_Id;
        
        lstFinDet = [Select Id,Type__c,Claim__c from Financial_Details__c 
                     Where Claim__c in : newCaseMap.keySet() AND Type__c in ('Cargo Claim Paid','Other Legal Claim Paid','Commercial Claim Paid','Service Contract Claim Paid')];
        
        if(lstFinDet.size() > 0){
            for(Financial_Details__c objFinDet : lstFinDet){
                if(mapCaseIdtoFinDet.containsKey(objFinDet.Claim__c)){
                    mapCaseIdtoFinDet.get(objFinDet.Claim__c).add(objFinDet);
                }
                else{
                    mapCaseIdtoFinDet.put(objFinDet.Claim__c, new List<Financial_Details__c>{objFinDet});
                }
            }
        }
        
        for(Case newCase : newCaseMap.values()){
            if(newCase != oldCaseMap.get(newCase.Id) && newCase.RecordTypeId == claimRTId && newCase.Status != oldCaseMap.get(newCase.Id).Status && newCase.Status == 'Closed - Paid' && ((mapCaseIdtoFinDet.size() == 0) || (mapCaseIdtoFinDet.containsKey(newCase.Id) && mapCaseIdtoFinDet.get(newCase.Id).size() == 0))){
                newCase.addError('Please update Paid Financial Details before closing the case as Closed-Paid.');
            }
        }
    }
    
    /** 
* @description | SC-4861 Custom Validation for External and ISR case for Case Visibility and 4PL account field |
* @param lstCases accepts the list of Case Records
*/
    public static void validateCaseVisibility(list<Case> lstCases) {
        Id isrrtid = Label.ISR_Case_RT_Id;
        Id externalRTId = Label.External_Case_RT_Id;
        String userAccounts = '';
        String userMCResAccounts = '';
        List<String> userAccountList = new List<String>();
        List<String> userMCResAccountList = new List<String>();
        User currentUser=StaticFactory.getCurrentUserDetails();
        String userCMVisibility=CurrentUser.CM_Visibility__c;
        userAccounts=currentUser.SF_4PL_Account__c;
        userMCResAccounts = currentUser.Multi_Carrier_Restricted_Account__c;
        if(userAccounts!=NULL){
            userAccountList=userAccounts.split(';');
        }
        if(userMCResAccounts!= NULL){
            userMCResAccountList = userMCResAccounts.split(';');
        }
        
        if(userCMVisibility!=null){
            for(case newcase : lstCases){
                if(newcase.RecordTypeId==externalRTId ){
                    if(
                        (userCMVisibility=='Single Carrier' && (newcase.Case_Visibility__c=='4PL' ||newcase.Case_Visibility__c=='Multi-Carrier'|| newcase.SF_4PL_Account__c!=null))||
                        (userCMVisibility=='Multi-Carrier' && (newcase.Case_Visibility__c=='4PL' || newcase.SF_4PL_Account__c!=null)) ||
                        (userCMVisibility=='4PL' && !userAccountList.contains(newcase.SF_4PL_Account__c) && newcase.SF_4PL_Account__c!=null)){
                            newcase.addError(Label.External_Case_4PL_Validation);}
                    //SC-8818
                    else if((userCMVisibility=='Single Carrier' || userCMVisibility=='Multi-Carrier' || userCMVisibility=='4PL')  && (newcase.Case_Visibility__c=='Multi Carrier (Restricted)' || newcase.Multi_Carrier_Restricted_Account__c!=null )){
                        newcase.addError(Label.External_Case_MCRes_Validation_For_SC_MC_User);}
                    else if(userCMVisibility=='Multi Carrier (Restricted)' && (newcase.Case_Visibility__c=='4PL' || newcase.SF_4PL_Account__c!=NULL || (newcase.Multi_Carrier_Restricted_Account__c!=Null && !userMCResAccountList.contains(newcase.Multi_Carrier_Restricted_Account__c)))){
                        newcase.addError(Label.External_Case_MCRes_Validation_For_MCRes_User);}
                    
                }
                //Added condtion !newcase.Resolver_Dept__c.contains('4PL') as part of SC-6337
                if(newcase.RecordTypeId==isrrtid){
                    if(((userCMVisibility=='Single Carrier'||userCMVisibility=='Multi-Carrier') && ((!String.isBlank(newcase.Resolver_Dept__c) && !newcase.Resolver_Dept__c.contains('4PL') && !String.isBlank(newcase.Requestor_Dept__c) && !newcase.Requestor_Dept__c.contains('4PL') && newcase.SF_4PL_Account__c!=null)||(newcase.Case_Visibility__c=='4PL') )  )||
                       (userCMVisibility=='4PL' && ((!userAccountList.contains(newcase.SF_4PL_Account__c) && newcase.SF_4PL_Account__c !=null)||(newcase.Case_Visibility__c=='4PL' && !String.isBlank(newcase.Resolver_Dept__c) && !newcase.Resolver_Dept__c.contains('4PL'))))) {
                           newcase.addError(Label.ISR_Case_4PL_Validation);
                       }                          
                    //SC-8818
                    else if(((userCMVisibility=='Single Carrier'||userCMVisibility=='Multi-Carrier') && ((!String.isBlank(newcase.Resolver_Dept__c) && !newcase.Resolver_Dept__c.contains('SCM (Restricted)') && !String.isBlank(newcase.Requestor_Dept__c) && !newcase.Requestor_Dept__c.contains('Multi Carrier (Restricted)') && newcase.Multi_Carrier_Restricted_Account__c!=null)||(newcase.Case_Visibility__c=='Multi Carrier (Restricted)') )  )||
                            (userCMVisibility=='Multi Carrier (Restricted)' && ((!userMCResAccountList.contains(newcase.Multi_Carrier_Restricted_Account__c) && newcase.Multi_Carrier_Restricted_Account__c !=null))) )
                    {
                        newcase.addError(Label.ISR_Case_MCRes_Validation);
                    }
                }
            }
        }
    }
    
    /** 
* @description | SC -4770 The method construct the Subtype and Type and Map from metadata   |
* @return a Mapping of String to String key Value pair
*/
    public static Map<String, String> createSubTypeTypeMap(){
        Map<String,String> mapSupTypetoType = new Map<String,String>(); // map to store Subtype as key and type as value
        if(mapSupTypetoType.isEmpty() && !(mapSupTypetoType.size() > 0)){
            List<Case_Classification_Matrix__mdt> lstCaseClasfiMdt = [SELECT Type__c, Sub_Type__c 
                                                                      FROM 
                                                                      Case_Classification_Matrix__mdt];
            if(!lstCaseClasfiMdt.isEmpty() && lstCaseClasfiMdt.size() > 0)
            {
                for(Case_Classification_Matrix__mdt mdt : lstCaseClasfiMdt)
                {
                    mapSupTypetoType.put(mdt.Sub_Type__c, mdt.Type__c);  
                }                   
            }
        }
        
        return mapSupTypetoType;   
    }
    
    /** 
* @description | SC-4507, SC-5376 Populate the 4pl type if its SPOT Emergency or SPOT Reuest  |
* @param lstCases accepts a list of case record
* @param casRecordSelector accepts the class CaseTriggerHandler
*/
    public static void populate4PLType(List<Case> lstCases, CaseRecordSelector casRecordSelector){        
        if(!lstCases.isEmpty()){
            for(Case newCase : lstCases){
                String userRole = casRecordSelector.mapOwnerandRole1.containsKey(newCase.OwnerId) ? casRecordSelector.mapOwnerandRole1.get(newCase.OwnerId) : '';
                if(!String.isEmpty(newCase.Subject) && BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MAERSKLS).contains(newCase.Liner_Brand__c) && newCase.Product__c == '4PL' && ((newCase.Origin != null && newCase.Origin.contains('FPL')) || (userRole!= null && userRole.contains('4PL')))){               
                    String subj = newCase.Subject.replaceAll(Label.Replace_Special_Char_Case_Subject,' ');
                    if(subj != null && (subj.containsIgnoreCase(General_Key_Value_Configurations__mdt.getInstance('FourPLType_spot_emergency_order').First_Field_Value__c) ||
                                        subj.containsIgnoreCase(General_Key_Value_Configurations__mdt.getInstance('FourPLType_spot_urgent_order').First_Field_Value__c) || 
                                        subj.containsIgnoreCase(General_Key_Value_Configurations__mdt.getInstance('FourPLType_spot_urgent_request').First_Field_Value__c)))
                    {                        
                        newCase.X4PL_Type__c = 'Emergency Order Request';                        
                    }
                    else if(subj != null && subj.containsIgnoreCase(General_Key_Value_Configurations__mdt.getInstance('FourPLTypeAirSpot').First_Field_Value__c))
                    {
                        newCase.X4PL_Type__c = 'Air Spot';
                        
                    }
                    else if(subj != null && subj.containsIgnoreCase(General_Key_Value_Configurations__mdt.getInstance('FourPLTypeOceanSpot').First_Field_Value__c))
                    {
                        newCase.X4PL_Type__c = 'Ocean Spot';
                    }                    
                }
            }
        } 
    }
    
    /** 
* @description | SC-7914
* @param externalCaseList accepts a list of case record
*/
    public static void validateExternalCaseTypeSubtype(list<Case> externalCaseList){
        String errorMessage = General_Key_Value_Configurations__mdt.getInstance('CaseClassificationError').First_Field_Value__c; 
        Map<String, Set<String>> productTypeMap = new Map<String, Set<String>>();  
        Map<String, Set<String>> typeSubtypeMap = new Map<String, Set<String>>();
        Map<String, Set<String>> subTypeReasonForCaseMap = new Map<String, Set<String>>();
        
        list<Case_Classification_Matrix__mdt> caseClassificationmatrixList = CaseClassificationMatrixController.readClassificationMatrix();
        
        for(Case_Classification_Matrix__mdt casclass : caseClassificationmatrixList){
            if(productTypeMap.containsKey(casclass.Product__c)){
                productTypeMap.get(casclass.Product__c).add(casclass.Type__c);
            }
            else{
                productTypeMap.put(casclass.Product__c, new Set<String>{casclass.Type__c});
            }
            
            if(typeSubtypeMap.containsKey(casclass.product__c + ';' +casclass.type__c)){
                typeSubtypeMap.get(casclass.product__c + ';' +casclass.type__c).add(casclass.Sub_Type__c);
            }
            else{
                typeSubtypeMap.put(casclass.product__c + ';' +casclass.type__c, new Set<String>{casclass.Sub_Type__c});
            }
            
            if(subTypeReasonForCaseMap.containsKey(casclass.product__c + ';' +casclass.type__c + ';' +casclass.Sub_Type__c)){
                subTypeReasonForCaseMap.get(casclass.product__c + ';' +casclass.type__c + ';' +casclass.Sub_Type__c).add(casclass.Reason_for_Case__c);
            }
            else{
                subTypeReasonForCaseMap.put(casclass.product__c + ';' +casclass.type__c + ';' +casclass.Sub_Type__c, new Set<String>{casclass.Reason_for_Case__c});
            }
        }
        
        for(Case cs : externalCaseList){
            if(String.isNotBlank(cs.product__c) && String.isNotBlank(cs.type)){
                if(productTypeMap.containsKey(cs.product__c)){
                    if(!String.isEmpty(cs.type) && !productTypeMap.get(cs.product__c).contains(cs.type)){
                        cs.Type.addError(errorMessage);
                    }
                }
            }
            
            if(productTypeMap.containsKey(cs.product__c) && typeSubtypeMap.containsKey(cs.product__c + ';' +cs.type) ){
                if(!String.isEmpty(cs.Sub_Type__c) && !typeSubtypeMap.get(cs.product__c + ';' +cs.type).contains(cs.Sub_Type__c)){ 
                    cs.Sub_Type__c.addError(errorMessage);
                }
            }
            
            if(productTypeMap.containsKey(cs.product__c) && typeSubtypeMap.containsKey(cs.product__c + ';' +cs.type) && subTypeReasonForCaseMap.containsKey(cs.product__c + ';' +cs.type + ';' +cs.Sub_Type__c)){
                if(!String.isEmpty(cs.Reason_for_Case__c) && !subTypeReasonForCaseMap.get(cs.product__c + ';' +cs.type + ';' +cs.Sub_Type__c).contains(cs.Reason_for_Case__c)){
                    cs.Reason_for_Case__c.addError(errorMessage);
                }
            }
        }
    }
    
    /** 
* @description | Update Ownership Change Time
* @param csList accepts a list of case record
*/
    public static void updateOwnershipChangedTime(List<Case> csList){
        for(Case cs : csList){
            cs.Ownership_Changed_Time__c = System.now();
        }
    }
    
    /** 
* @description | Update New Email Flag
* @param csList accepts a list of case record
*/
    public static void updateNewEmailFlag(List<Case> csList){
        for(Case cs : csList){
            cs.New_Mail__c = false;
        }
    }
    
    /** 
* @description | Update Bol Number to Blank
* @param csList accepts a list of case record
*/
    public static void populateBolNumbertoBlank(List<Case> csList){
        for(Case cs : csList){
            cs.Compound_Index_for_BoL_Number__c = '';
        }
    }
    
    /** 
* @description | Update Claim Case Bol Number
* @param csList accepts a list of case record
*/
    public static void populateClaimCaseBolNumber(List<Case> csList){
        for(Case cs : csList){
            cs.Compound_Index_for_BoL_Number__c = 'Claim-'+cs.BoL_Number__c;
        }
    }
    
    /** 
* @description | Update ISR Case Bol Number
* @param csList accepts a list of case record
* @param countryIdSet accepts country ids
*/
    public static void populateISRCaseBolNumber(List<Case> csList, Set<Id> countryIdSet){
        try{
            Map<Id, Geography__c> countryMap = new Map<Id, Geography__c>();
            if(!countryIdSet.isEmpty()){
                countryMap = new Map<Id, Geography__c>([Select Id, Name From Geography__c Where Id =: countryIdSet]);
            }
            for(Case cs : csList){
                cs.Compound_Index_for_BoL_Number__c = 'AFR-closure-'+((!countryMap.isEmpty() && countryMap.containsKey(cs.Country__c)) ? countryMap.get(cs.Country__c).Name : '')+'-'+cs.Direction__c+'-'+cs.BoL_Number__c;
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.populateISRCaseBolNumber', new list<Exception>{ex}); // #RQ-005636 
        }
    }
    
    /** 
* @description | update Counter & Time fields
* @param csList accepts a list of case record
* @param oldMap accepts old case map
* @param closedStatusList accepts closed statuses list
*/
    public static void calculateCounterAndTimeFields(List<Case> csList, Map<Id, Case> oldMap, List<String> closedStatusList){
        try{
            Id externalCaseRTId = Label.External_Case_RT_Id;
            Id claimRTId = Label.Claim_Case_RT_Id;
            Id disputeRTId = Label.Dispute_Case_RT_Id;
            String bypassedReassignmentUsersAndProfiles = General_Key_Value_Configurations__mdt.getInstance('Reassignment_Exclusions_Profiles_Users').First_Field_Value__c;
            for(Case cs : csList){
                Case oldCase;
                if(oldMap != null && !oldMap.isEmpty()){
                    oldCase = oldMap.get(cs.Id);
                    if(cs.Status != oldCase.Status){
                        cs.Count_Status_Changes__c += 1;
                    }
                    if(!closedStatusList.contains(oldCase.Status) && closedStatusList.contains(cs.Status)){
                        if(cs.Case_Reopen_Count__c == 0){
                            cs.Overall_Time_Open_Until_Last_Closure_RH__c = getDateTimeDifferenceInHours(cs.CreatedDate, System.now());
                        }
                        else if(cs.Case_Reopen_Count__c > 0){
                            if(cs.Overall_Time_Open_Until_Last_Closure_RH__c == null){
                                cs.Overall_Time_Open_Until_Last_Closure_RH__c = 0; 
                            }
                            cs.Overall_Time_Open_Until_Last_Closure_RH__c += getDateTimeDifferenceInHours(cs.Case_Reopened_Date_Time__c, System.now());
                        }
                    }
                    if(cs.OwnerId != oldCase.OwnerId && cs.Time_with_First_Owner_RH__c == null){
                        cs.Time_with_First_Owner_RH__c = getDateTimeDifferenceInHours(cs.CreatedDate, System.now());
                    }
                    if(cs.OwnerId != oldCase.OwnerId && String.valueOf(oldCase.OwnerId).startsWith('005') && ((bypassedReassignmentUsersAndProfiles == null || String.isBlank(bypassedReassignmentUsersAndProfiles)) || (!String.isBlank(bypassedReassignmentUsersAndProfiles) && !bypassedReassignmentUsersAndProfiles.contains(UserInfo.getUserId()) && !bypassedReassignmentUsersAndProfiles.contains(UserInfo.getProfileId())))){
                        cs.Times_Case_Reassigned__c += 1;
                    }
                    if(cs.RecordTypeId != oldCase.RecordTypeId && cs.RecordTypeId == externalCaseRTId && UserInfo.getLastName() != 'Maersk API Management'){
                        cs.Type = '';
                        cs.Sub_Type__c = '';
                        cs.Reason_For_Case__c = '';
                    }
                    if(cs.Liner_Brand__c != oldCase.Liner_Brand__c || cs.Type != oldCase.Type || cs.Sub_Type__c != oldCase.Sub_Type__c || cs.Reason_For_Case__c != oldCase.Reason_For_Case__c || cs.Status != oldCase.Status || cs.Count_Case_Outbound_Email__c != oldCase.Count_Case_Outbound_Email__c || cs.MLL__c != oldCase.MLL__c || cs.Country__c != oldCase.Country__c){
                        cs.Last_Meaningful_Activity__c = System.now();
                    }
                }
                if(oldCase != null && cs.Case_Reopen_Count__c < 1 && closedStatusList.contains(cs.Status)){
                    cs.Duration_Of_Case_Closed_first_time__c = getDateTimeDifferenceInHours(cs.CreatedDate, System.now());
                }
                else if(oldCase == null && cs.Case_Reopen_Count__c < 1 && closedStatusList.contains(cs.Status)){
                    cs.Duration_Of_Case_Closed_first_time__c = 0;
                }
                if(cs.Date_First_Resolved__c == null && (cs.Status == 'Closed - Resolved' || cs.Status == 'Closed - Paid' || cs.Status == 'Recovery Obtained' || cs.Status == 'Closed - Reassigned')){
                    cs.Date_First_Resolved__c = System.now();
                }
                if((cs.RecordTypeId == externalCaseRTId || cs.RecordTypeId == claimRTId || cs.RecordTypeId == disputeRTId) && cs.Status == 'Awaiting Customer Input'){
                    cs.DateStatus_Pending_inputs_from_Customer__c = System.now();
                }
                if(String.isBlank(cs.First_Queue_Owner_Id__c) && String.valueOf(cs.OwnerId).startsWith('00G')){
                    cs.First_Queue_Owner_Id__c = cs.OwnerId;
                }
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.calculateCounterAndTimeFields', new list<Exception>{ex}); // #RQ-005636 
        }
    }
    
    /** 
* @description | update Subject
* @param csList accepts a list of case record
* @param accMap accepts account map
* @param conMap accepts contact map
*/
    public static void updateSubject(List<Case> csList, Map<Id, Account> accMap, Map<Id, Contact> conMap){
        for(Case cs : csList){
            if(!accMap.isEmpty() && !String.isEmpty(cs.AccountId) && accMap.containsKey(cs.AccountId)){
                cs.Subject = accMap.get(cs.AccountId).Name+'-'+cs.Type;
            }
            else if(!conMap.isEmpty() && !String.isEmpty(cs.ContactId) && conMap.containsKey(cs.ContactId)){
                cs.Subject = conMap.get(cs.ContactId).Account.Name+'-'+cs.Type;
            }
        }
    }
    
    /** 
* @description | update Portal on Behalf
* @param csList accepts a list of case record
* @param accMap accepts account map
* @param conMap accepts contact map
*/
    public static void updatePortalOnBehalf(List<Case> csList, Map<Id, Account> accMap, Map<Id, Contact> conMap){
        for(Case cs : csList){
            if(!accMap.isEmpty() && !String.isEmpty(cs.AccountId) && accMap.containsKey(cs.AccountId)){
                cs.Portal_On_Behalf_Of__c = accMap.get(cs.AccountId).SCV_Code__c;
            }
            else if(!conMap.isEmpty() && !String.isEmpty(cs.ContactId) && conMap.containsKey(cs.ContactId)){
                cs.Portal_On_Behalf_Of__c = conMap.get(cs.ContactId).Account.SCV_Code__c;
            }
        }
    }
    
    /** 
* @description | update Product, Product Category & Claim Activity
* @param csList accepts a list of case record
* @param parentIdSet accepts parent case Ids
*/
    public static void updateProductAndClaimActivity(List<Case> csList, Set<Id> parentIdSet){
        Map<Id, Case> parentCaseMap = new Map<Id, Case>([Select Id, Product__c, Product_Category__c, Claim_Activity__c From Case Where Id =: parentIdSet]);
        for(Case cs : csList){
            cs.Product__c = parentCaseMap.get(cs.ParentId).Product__c;
            cs.Product_Category__c = parentCaseMap.get(cs.ParentId).Product_Category__c;
            cs.Claim_Activity__c = parentCaseMap.get(cs.ParentId).Claim_Activity__c;
        }
    }
    
    /** 
* @description | get datetime difference
* @param starttime accepts start date time
* @param endtime accepts end date time
* @return Decimal value
*/
    public static Decimal getDateTimeDifferenceInHours(Datetime starttime, Datetime endtime){
        Long startDatetime = starttime.getTime();
        Long endDatetime = endtime.getTime();
        Decimal diffMilliSecs = Decimal.valueOf(endDatetime - startDatetime);
        Decimal dHours = diffMilliSecs/1000/60/60;
        return dHours.setScale(3);
    }
    
    /** 
* @description | Calculate Time spent in Main Queue in BH
* @param lstCases accepts Case record list
* @param mapOldCases accepts old case map
* @param casRecordSelector accepts casRecordSelector
* SC-9190
*/
    public static void calculateBHOnOwnerChange(List<Case> lstCases, Map<Id, Case> mapOldCases, CaseRecordSelector casRecordSelector) {
        try{
            String oldBusinessHourId = '';
            String defaultBH = System.label.Default_Business_Hours;
            
            for(Case caseInstance:lstCases){
                Long timeDiff = 0L;
                if(caseInstance.QueueOwnerChangeTimediffBH__c!=null){
                    timeDiff = (Long)caseInstance.QueueOwnerChangeTimediffBH__c;
                }
                
                if(!mapOldCases.isEmpty()){
                    if(mapOldCases.containskey(caseInstance.id) && mapOldCases.get(caseInstance.id).BusinessHoursId!=Null){
                        oldBusinessHourId = mapOldCases.get(caseInstance.id).BusinessHoursId; 
                    }
                    else{
                        oldBusinessHourId = defaultBH;
                    }   
                }
                
                if(casRecordSelector.mapUpdateBHtime.containskey(caseInstance.id) && oldBusinessHourId!=null){
                    if(casRecordSelector.mapUpdateBHtime.get(caseInstance.id) == 'QueueOwnerChangetimeIsNull'){
                        timeDiff += BusinessHours.diff(oldBusinessHourId, caseInstance.CreatedDate, system.now());
                    }
                    
                    if(casRecordSelector.mapUpdateBHtime.get(caseInstance.id) == 'HasQueueOwnerChangeTime'){
                        timeDiff += BusinessHours.diff(oldBusinessHourId, caseInstance.QueueOwnerChangetime__c, system.now());
                    }
                    if(timeDiff!=null){
                        Decimal d = timeDiff;
                        Decimal finalTime = d.divide(3600000, 3);
                        caseInstance.Time_spent_in_Main_Queue_BH__c = finalTime != null ? finalTime : null;
                    }
                }
                else if(casRecordSelector.mapCalculateBHtime.containskey(caseInstance.id)){
                    if(casRecordSelector.mapCalculateBHtime.get(caseInstance.id) == 'QueueOwnerChangetimeIsNull'){
                        timeDiff += BusinessHours.diff(oldBusinessHourId, caseInstance.CreatedDate, system.now());
                    }
                    
                    if(casRecordSelector.mapCalculateBHtime.get(caseInstance.id) == 'HasQueueOwnerChangeTime'){
                        timeDiff += BusinessHours.diff(oldBusinessHourId, caseInstance.QueueOwnerChangetime__c, system.now());
                    }
                    caseInstance.QueueOwnerChangetime__c= system.now();
                    if(timeDiff !=Null){
                        caseInstance.QueueOwnerChangeTimediffBH__c = timeDiff;
                    }
                }
            }
        } catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.calculateBHOnOwnerChange', new list<Exception>{ex});  
        }
    }
    
    /** 
* @description | Validate to check for creation of external case history
* @param csList accepts Case record list
* @param oldMap accepts key value pair with Id and Case record
* @param mapRelatedContacts accepts key value pair with Id and Contact record
* @param csHistoryWrapList accepts CaseHistoryWrapper List
* SC-9190
*/
    public static void validateCustomCaseHistory(List<Case> csList, Map<Id, Case> oldMap, Map<Id, Contact> mapRelatedContacts, List<CaseHistoryWrapper> csHistoryWrapList){
        try{
            Set<Id> bhIdSet = new Set<Id>();
            Set<Id> ctrlEntityIdSet = new Set<Id>();
            Map<Id, BusinessHours> businessHoursMap = new Map<Id, BusinessHours>();
            Map<Id, Controlling_Entity__c> ctrlEntityMap = new Map<Id, Controlling_Entity__c>();
            
            for(Case cs : csList){
                if(cs.BusinessHoursId != null){
                    bhIdSet.add(cs.BusinessHoursId);
                }
                if(oldMap != null && !oldMap.isEmpty() && oldMap.get(cs.Id).BusinessHoursId != null){
                    bhIdSet.add(oldMap.get(cs.Id).BusinessHoursId);
                }
                if(cs.Controlling_Entity__c != null){
                    ctrlEntityIdSet.add(cs.Controlling_Entity__c);
                }
                if(oldMap != null && !oldMap.isEmpty() && oldMap.get(cs.Id).Controlling_Entity__c != null){
                    ctrlEntityIdSet.add(oldMap.get(cs.Id).Controlling_Entity__c);
                }
            }
            
            if(!bhIdSet.isEmpty()){
                if(!bhIdSet.isEmpty()){
                    for(BusinessHours bh : [Select Id, Name From BusinessHours Where Id =: bhIdSet]){ 
                        businessHoursMap.put(bh.Id, bh);                                                           
                    }
                }
            }
            
            if(!ctrlEntityIdSet.isEmpty()){
                for(Controlling_Entity__c ctrl : [Select Id, Name From Controlling_Entity__c Where Id =: ctrlEntityIdSet]){ 
                    ctrlEntityMap.put(ctrl.Id, ctrl);                                                           
                }
            }
            
            String currentUserId = UserInfo.getUserId();
            for(Case cs : csList){
                if(oldMap == null && !UserInfo.getUserName().contains('system.owner@maersk.com')){
                    if(cs.BusinessHoursId != null){
                        String bhName = (!businessHoursMap.isEmpty() && businessHoursMap.containsKey(cs.BusinessHoursId) && businessHoursMap.get(cs.BusinessHoursId) != null) ? businessHoursMap.get(cs.BusinessHoursId).Name : cs.BusinessHoursId;
                        csHistoryWrapList.add(new CaseHistoryWrapper(cs.Id, JSON.serialize(System.now()).remove('"').left(19), 'Business Hours', bhName, '', currentUserId));
                    }
                    if(cs.Cargo_Type__c != null){
                        csHistoryWrapList.add(new CaseHistoryWrapper(cs.Id, JSON.serialize(System.now()).remove('"').left(19), 'Cargo Type', cs.Cargo_Type__c, '', currentUserId));
                    }
                    if(cs.Controlling_Entity__c != null){
                        String ctrlName = (!ctrlEntityMap.isEmpty() && ctrlEntityMap.containsKey(cs.Controlling_Entity__c) && ctrlEntityMap.get(cs.Controlling_Entity__c) != null) ? ctrlEntityMap.get(cs.Controlling_Entity__c).Name : cs.Controlling_Entity__c;
                        csHistoryWrapList.add(new CaseHistoryWrapper(cs.Id, JSON.serialize(System.now()).remove('"').left(19), 'Controlling Entity', ctrlName, '', currentUserId));
                    }
                    if(cs.Case_Channel__c != null){
                        csHistoryWrapList.add(new CaseHistoryWrapper(cs.Id, JSON.serialize(System.now()).remove('"').left(19), 'Case Channel', cs.Case_Channel__c, '', currentUserId));
                    }
                    if(cs.Case_Visibility__c != null){
                        csHistoryWrapList.add(new CaseHistoryWrapper(cs.Id, JSON.serialize(System.now()).remove('"').left(19), 'Case Visibility', cs.Case_Visibility__c, '', currentUserId));
                    }
                    if(cs.Cluster_CSCE__c != null){
                        csHistoryWrapList.add(new CaseHistoryWrapper(cs.Id, JSON.serialize(System.now()).remove('"').left(19), 'Cluster CS/CE', String.valueOf(cs.Cluster_CSCE__c), '', currentUserId));
                    }
                    if(cs.ContactId != null){
                        String conName = (!mapRelatedContacts.isEmpty() && mapRelatedContacts.containsKey(cs.ContactId) && mapRelatedContacts.get(cs.ContactId) != null) ? mapRelatedContacts.get(cs.ContactId).Name : cs.ContactId;
                        csHistoryWrapList.add(new CaseHistoryWrapper(cs.Id, JSON.serialize(System.now()).remove('"').left(19), 'Contact Name', conName, '', currentUserId));
                    }
                    if(cs.Priority != null){
                        csHistoryWrapList.add(new CaseHistoryWrapper(cs.Id, JSON.serialize(System.now()).remove('"').left(19), 'Priority', cs.Priority, '', currentUserId));
                    }
                    //SC-9793
                    if(cs.Auto_Assignment_Indicator__c != null){
                        csHistoryWrapList.add(new CaseHistoryWrapper(cs.Id, JSON.serialize(System.now()).remove('"').left(19), 'Auto Assignment Indicator', cs.Auto_Assignment_Indicator__c, '', currentUserId));
                    }
                }
                else if(oldMap != null){
                    if(cs.BusinessHoursId != oldMap.get(cs.Id).BusinessHoursId){
                        String bhName = (!businessHoursMap.isEmpty() && businessHoursMap.containsKey(cs.BusinessHoursId) && businessHoursMap.get(cs.BusinessHoursId) != null) ? businessHoursMap.get(cs.BusinessHoursId).Name : cs.BusinessHoursId;
                        String oldBhName = (!businessHoursMap.isEmpty() && businessHoursMap.containsKey(oldMap.get(cs.Id).BusinessHoursId) && businessHoursMap.get(oldMap.get(cs.Id).BusinessHoursId) != null) ? businessHoursMap.get(oldMap.get(cs.Id).BusinessHoursId).Name : oldMap.get(cs.Id).BusinessHoursId;
                        csHistoryWrapList.add(new CaseHistoryWrapper(cs.Id, JSON.serialize(System.now()).remove('"').left(19), 'Business Hours', bhName, oldBhName, currentUserId));
                    }
                    if(cs.Cargo_Type__c != oldMap.get(cs.Id).Cargo_Type__c){
                        csHistoryWrapList.add(new CaseHistoryWrapper(cs.Id, JSON.serialize(System.now()).remove('"').left(19), 'Cargo Type', cs.Cargo_Type__c, oldMap.get(cs.Id).Cargo_Type__c, currentUserId));
                    }
                    if(cs.Controlling_Entity__c != oldMap.get(cs.Id).Controlling_Entity__c){
                        String ctrlName = (!ctrlEntityMap.isEmpty() && ctrlEntityMap.containsKey(cs.Controlling_Entity__c) && ctrlEntityMap.get(cs.Controlling_Entity__c) != null) ? ctrlEntityMap.get(cs.Controlling_Entity__c).Name : cs.Controlling_Entity__c;
                        String oldCtrlName = (!ctrlEntityMap.isEmpty() && ctrlEntityMap.containsKey(oldMap.get(cs.Id).Controlling_Entity__c) && ctrlEntityMap.get(oldMap.get(cs.Id).Controlling_Entity__c) != null) ? ctrlEntityMap.get(oldMap.get(cs.Id).Controlling_Entity__c).Name : oldMap.get(cs.Id).Controlling_Entity__c;
                        csHistoryWrapList.add(new CaseHistoryWrapper(cs.Id, JSON.serialize(System.now()).remove('"').left(19), 'Controlling Entity', ctrlName, oldCtrlName, currentUserId));
                    }
                    if(cs.Case_Channel__c != oldMap.get(cs.Id).Case_Channel__c){
                        csHistoryWrapList.add(new CaseHistoryWrapper(cs.Id, JSON.serialize(System.now()).remove('"').left(19), 'Case Channel', cs.Case_Channel__c, oldMap.get(cs.Id).Case_Channel__c, currentUserId));
                    }
                    if(cs.Case_Visibility__c != oldMap.get(cs.Id).Case_Visibility__c){
                        csHistoryWrapList.add(new CaseHistoryWrapper(cs.Id, JSON.serialize(System.now()).remove('"').left(19), 'Case Visibility', cs.Case_Visibility__c, oldMap.get(cs.Id).Case_Visibility__c, currentUserId));
                    }
                    if(cs.Cluster_CSCE__c != oldMap.get(cs.Id).Cluster_CSCE__c){
                        csHistoryWrapList.add(new CaseHistoryWrapper(cs.Id, JSON.serialize(System.now()).remove('"').left(19), 'Cluster CS/CE', String.valueOf(cs.Cluster_CSCE__c), String.valueOf(oldMap.get(cs.Id).Cluster_CSCE__c), currentUserId));
                    }
                    if(cs.ContactId != oldMap.get(cs.Id).ContactId){
                        String conName = (!mapRelatedContacts.isEmpty() && mapRelatedContacts.containsKey(cs.ContactId) && mapRelatedContacts.get(cs.ContactId) != null) ? mapRelatedContacts.get(cs.ContactId).Name : cs.ContactId;
                        String oldConName = (!mapRelatedContacts.isEmpty() && mapRelatedContacts.containsKey(oldMap.get(cs.Id).ContactId) && mapRelatedContacts.get(oldMap.get(cs.Id).ContactId) != null) ? mapRelatedContacts.get(oldMap.get(cs.Id).ContactId).Name : oldMap.get(cs.Id).ContactId;
                        csHistoryWrapList.add(new CaseHistoryWrapper(cs.Id, JSON.serialize(System.now()).remove('"').left(19), 'Contact Name', conName, oldConName, currentUserId));
                    }
                    if(cs.Priority != oldMap.get(cs.Id).Priority){
                        csHistoryWrapList.add(new CaseHistoryWrapper(cs.Id, JSON.serialize(System.now()).remove('"').left(19), 'Priority', cs.Priority, oldMap.get(cs.Id).Priority, currentUserId));
                    }
                    //SC-9793
                    if(cs.Auto_Assignment_Indicator__c != oldMap.get(cs.Id).Auto_Assignment_Indicator__c){
                        csHistoryWrapList.add(new CaseHistoryWrapper(cs.Id, JSON.serialize(System.now()).remove('"').left(19), 'Auto Assignment Indicator', cs.Auto_Assignment_Indicator__c, oldMap.get(cs.Id).Auto_Assignment_Indicator__c, currentUserId));
                    }
                }
            }
        }catch(Exception e){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.validateCustomCaseHistory', new list<Exception>{e});
        }
    }
    
    /** 
* @description | Create external case history
* @param jsonBody accepts serialized CaseHistoryWrapper List
* SC-9190
*/
    @future(callout = true)
    public static void createCustomCaseHistory(String jsonBody){
        try{
            HttpResponse response = ExtDataSourceUtility.getResponse('POST', jsonBody, 'Case History Archival');
            if(response.getStatusCode()<200 || response.getStatusCode()>299){
                ErrorLogger.writeError('SFDC', 'Case', 'CaseFieldPopulator.createCustomCaseHistory', 'Error', 'Status Code:'+response.getStatusCode(), String.valueOf(response));
            }
        }catch(Exception e){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.createCustomCaseHistory', new list<Exception>{e});
        }
    }
    
    /** 
* @description | Validate cluster cases
* @param caselist accepts list of cases
* SC-8580
*/
    public static void validateClusterCases(list<Case> caselist){
        String deliveryChannel = General_Key_Value_Configurations__mdt.getInstance('Delivery_Channel').first_field_value__c;
        try{
            Set<String> countryIdList = new Set<String>();
            Map<Id, String> countryNameMap = new Map<Id, String>();
            Map<String, list<String>> subtypeCountryMap = new Map<String, list<String>>();
            for(Case cs : caselist){
                if(!String.isBlank(cs.Delivery_Channel__c) && deliveryChannel.contains(cs.Delivery_Channel__c) && !String.isBlank(cs.Sub_Type__c) && cs.Country__c!= null && (cs.Case_channel__c == 'Website' || cs.Case_Channel__c == 'Portal') ){
                    countryIdList.add(cs.Country__c);
                }
            }
            
            if(countryIdList.size()> 0){
                for(Geography__c geo : [Select id,name from Geography__c WHERE Id IN :countryIdList]){
                    countryNameMap.put(geo.Id, geo.Name);
                }
            }
            if(!countryNameMap.isEmpty()){
                for(General_Key_Value_Configurations__mdt gen : [Select Key__c, First_Field_Value__c From General_Key_Value_Configurations__mdt where key__c != null AND key__c IN :countryNameMap.values()] ){
                    if(!String.isEmpty(gen.First_Field_Value__c)  && !subtypeCountryMap.isEmpty() && subtypeCountryMap.containsKey(gen.key__c)){
                        subtypeCountryMap.get(gen.key__c).addAll(gen.First_Field_Value__c.trim().split(','));
                    }else if(!String.isEmpty(gen.First_Field_Value__c)){
                        subtypeCountryMap.put(gen.key__c, gen.First_Field_Value__c.trim().split(','));
                    }
                }
            }
            
            for(Case cs : caselist){
                if(!String.isBlank(cs.Delivery_Channel__c) && deliveryChannel.contains(cs.Delivery_Channel__c) && !String.isBlank(cs.Sub_Type__c) && cs.Country__c != null && !countryNameMap.isEmpty() && countryNameMap.containsKey(cs.country__c) && !subtypeCountryMap.isEmpty() && subtypeCountryMap.containsKey(countryNameMap.get(cs.Country__c)) && !subtypeCountryMap.get(countryNameMap.get(cs.Country__c)).contains(cs.Sub_type__c)){              
                    cs.Cluster_CSCE__c = true;
                }
            }
            
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.validateClusterCases', new list<Exception>{ex});
        }
    }
    
    /** 
    * @description | create feed item
    * @param csList accepts list of Case
    */
    public static void createFeedItem(List<Case> csList){
        List<FeedItemUtility.FeedItemWrapper> feedItemWrapList = new List<FeedItemUtility.FeedItemWrapper>();
        for(Case cs : csList){
            FeedItemUtility.FeedItemWrapper feedWrap = new FeedItemUtility.FeedItemWrapper(cs.Id, cs.ParentId, 'Case');
            feedItemWrapList.add(feedWrap);
        }
        
        if(!feedItemWrapList.isEmpty()){
            FeedItemUtility.createFeedItem(feedItemWrapList);
            system.debug('test');
        }
    }
    
    /** 
    * @description | assign Entitlement
    * @param caseIds accepts Case Ids
    */
    public static void assignEntitlement(List<Case> caseIdSetForEntitlement){
        List<Case> csListToUpdate = new List<Case>();
        Id externalCaseRTId = Label.External_Case_RT_Id;
        String productExclusion = General_Key_Value_Configurations__mdt.getInstance('Auto_Classification_Product_Exclusion').First_Field_Value__c;
        List<String> prodExcList = new List<String>();
        if(!String.isEmpty(productExclusion)){
            prodExcList = productExclusion.split(',');
        }
        for(Case newCase : caseIdSetForEntitlement){
            if(!(newCase.RecordTypeId == externalCaseRTId && newCase.Case_Channel__c == 'E-mail' && String.isNotBlank(newCase.Origin) && String.isNotBlank(newCase.Subject) && String.isNotBlank(newCase.Description) && String.isNotBlank(newCase.Liner_Brand__c) && (prodExcList.isEmpty() || (!prodExcList.isEmpty() && newCase.SF_4PL_Account__c != 'Nvidia' && !prodExcList.contains(newCase.Product__c)))
                 && (!CaseRecordSelector.originArtemisGE.isEmpty() && !CaseRecordSelector.originArtemisGE.contains(newCase.Origin))) && newCase.Type == null && newCase.Sub_Type__c == null){
                     newCase.EntitlementId = Label.Default_Entitlement_Id;
                 }
        }
    }
    
    /** 
* @description | update omni skill type
* @param caseOmniSkillUpdateList accepts Case list
*/
    public static void updateOmniSkillTypeToBlank(List<Case> caseOmniSkillUpdateList){
        try{
            List<Case> csListToUpdate = new List<Case>();
            for(Case cs : caseOmniSkillUpdateList){
                Case csToUpdate = new Case();
                csToUpdate.Id = cs.Id;
                csToUpdate.Omni_Skill_Type__c = '';
                csListToUpdate.add(csToUpdate);
            }
            if(!csListToUpdate.isEmpty()){
                TriggerExecutionController.skipCaseTrigger(true);
                update csListToUpdate;
                TriggerExecutionController.skipCaseTrigger(false);
            }
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.updateOmniSkillTypeToBlank', new list<Exception>{ex});
        }
    }
    
    /** 
* @description | update response received flag
* @param caseIds accepts Case Ids
* @param caseMap accepts case map
*/
    public static void updateISRParentCase(Set<Id> caseIds){
        try{
            List<Case> csListToUpdate = new List<Case>();
            for(Case cs : [Select Id, New_Mail__c From Case Where Id =: caseIds]){
                if(cs.New_Mail__c){
                    cs.New_Mail__c = false;
                    csListToUpdate.add(cs);
                }
            }
            if(!csListToUpdate.isEmpty()){
                TriggerExecutionController.skipCaseTrigger(true);
                update csListToUpdate;
                TriggerExecutionController.skipCaseTrigger(false);
            }
        }catch(Exception e){
            ErrorLogger.writeErrors('SFDC', 'Case', 'CaseFieldPopulator.updateISRParentCase', new list<Exception>{e});
        }
    }
      /** 
* @description | SC-10138:Auto Close Spam Cases
* @param csList accepts Case List
* 
*/
        public static void updateAutoClosureTime(List<Case> csList){
        try{
            system.debug('auto closure started');
            Integer defaultTime=8;
            List<Case> lstcasetoUpdate = new List<Case>();
            Map<String,Maersk_Admin_Configuration__c> Mapautoclosure=new Map<String,Maersk_Admin_Configuration__c>();
            for(Maersk_Admin_Configuration__c autoclousre:[Select id,Area__c,Type__c,Sub_Type__c,Reason_For_Case__c,Business_Hour__c,Case_Accepted_by_user__c,Excluded_4PL_Identifier__c,Excluded_Country__c from Maersk_Admin_Configuration__c where recordtypeid='0120D000000BLdvQAG']){
                Mapautoclosure.put(autoclousre.Area__c, autoclousre);
                system.debug('1st for'+Mapautoclosure);
            }
            
            for(Case cs : csList){
                system.debug('checking'+cs.Cluster__c);
                system.debug('2nd for'+ Mapautoclosure.get(cs.Cluster__c));
                system.debug(cs.Cluster__c);

                
                if(cs.Cluster__c!=null && Mapautoclosure.containskey(cs.Cluster__c))
                {	
                    system.debug('3rd if');
                    Maersk_Admin_Configuration__c mac = Mapautoclosure.get(cs.Cluster__c);
                    system.debug('mac rfc'+mac.Reason_For_Case__c);
                     if((mac.Sub_Type__c == null || (cs.Sub_Type__c!= null && mac.Sub_Type__c.split(';').contains(cs.Sub_Type__c))) &&
                        (mac.Reason_For_Case__c == null || (cs.Reason_For_Case__c!= null && mac.Reason_For_Case__c.split(';').contains(cs.Reason_For_Case__c))) &&
                        (mac.Case_Accepted_by_user__c || String.valueof(cs.OwnerId).startswith('OOG')) &&
                        ((mac.Excluded_4PL_Identifier__c == null) || (mac.Excluded_Country__c!=null && !mac.Excluded_4PL_Identifier__c.contains(cs.SF_4PL_Account__c) && !mac.Excluded_Country__c.contains(cs.Case_Country__c))))
                     	{	
                        	system.debug('inside final if');
							cs.Auto_Closure_Time__c = System.now().addHours(Integer.valueof(Mapautoclosure.get(cs.Cluster__c).Business_Hour__c));
                     	 }
                  	 }
                
                  	if(cs.Cluster__c!=null && !Mapautoclosure.containskey(cs.Cluster__c)){
                         cs.Auto_Closure_Time__c = System.now().addHours(defaultTime);
                     }
                }
              
        }
        catch(Exception ex){
              ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.updateAutoClosureTime', new list<Exception>{ex});

        }
    }
    /** 
* @description | Update Ownership Change
* @param csList accepts a list of case record
*/
    public static void updateCaseOwnerhasCheckerQueue(Set<Id> caseOwnerIds, List<Case> csList){
        
        Map<Id, Group> userMap = new Map<Id,Group>([select Id, Name from Group where Id IN :caseOwnerIds and Type = 'Queue']);
        Map<Id, set<Id>> mapOfGrpWithMemberlst = new Map<Id, set<Id>>();
        List<GroupMember> groupMemberList = [select UserOrGroupId, Id, Group.Name from GroupMember where GroupId In : userMap.keyset()];
        for(GroupMember grpRec: groupMemberList){
            if (!mapOfGrpWithMemberlst.containsKey(grpRec.GroupId)) {
                mapOfGrpWithMemberlst.put(grpRec.GroupId, new set<Id>{grpRec.UserOrGroupId});
            } else {
                mapOfGrpWithMemberlst.get(grpRec.GroupId).add(grpRec.UserOrGroupId);
            }
        }
        
        for(Case cs : csList){
            if(!userMap.isEmpty() && userMap.containskey(cs.OwnerId) && userMap.get(cs.OwnerId).Name.contains('Resolution')
               && mapOfGrpWithMemberlst.containskey(cs.OwnerId) && !mapOfGrpWithMemberlst.get(cs.OwnerId).isEmpty() && mapOfGrpWithMemberlst.get(cs.OwnerId).contains(UserInfo.getUserId())){
                cs.OwnerId = UserInfo.getUserId();
            }
        }
    }
    
    /** 
* @description | update BA From Addesss
* @param caseOwnerIds accepts Case owner Ids
* @param caseList accepts case list
*/
    public static void updateBAFromAddress(Set<Id> caseOwnerIds, List<Case> caseList){
        try{
            Map<String, String> queueToBAMap = new Map<String, String>();
            List<Custom_Email_Service__c> cesList = new List<Custom_Email_Service__c>([Select Id, Queue_Id__c, BA_Address__c From Custom_Email_Service__c Where Queue_Id__c =: caseOwnerIds]);
            if(!cesList.isEmpty()){
                for(Custom_Email_Service__c ces : cesList){
                    if(!String.isBlank(ces.BA_Address__c)){
                        queueToBAMap.put(ces.Queue_Id__c, ces.BA_Address__c);
                    }
                }
                if(!queueToBAMap.isEmpty()){
                    for(Case cs : caseList){
                        if(queueToBAMap.containsKey(cs.OwnerId)){
                            cs.BA_From_Address__c = queueToBAMap.get(cs.OwnerId);
                        }
                    }
                }
            }
        }
        catch(Exception e){
            ErrorLogger.writeErrors('SFDC', 'Case', 'CaseFieldPopulator.updateBAFromAddress', new list<Exception>{e});
        }
    }
}