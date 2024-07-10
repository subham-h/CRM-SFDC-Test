/**
* Author   : Ragu@UST
* Purpose  : Centralize the record selection process for Case object.
*          Defines the methods which iterate and segregate the Case records for further use.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-002633   18-Feb-2016 Ragu@UST                Created for implementing CBO (Centralized By Org) trigger architecture.
* 1.1      RQ-003147   23-Mar-2016 Ananth@UST              Added ISR record type.
* 1.2      RQ-002679   08-Apr-2016 Jiji@UST                Modified to handle GCSS integration for Claim RT.
* 1.3      RQ-002633   27-Apr-2016 Ragu@UST                Added variables for populating Care Relationship.
* 1.4      RQ-004058   07-Jun-2016 Sandhya@UST             Assign ISR Queues based on Case Liner Brand
* 1.5      RQ-002879   19-Jul-2016 Jiji@UST                To populate liner brand from single branded contact(MDM)
* 1.6      RQ-004502   23-Nov-2016 Sunu@UST                Add a criteria to include cases with Origin = SEAGLOBALDISP along with manually created cases.
* 1.7      RQ-004424   20-Dec-2016 Subha@UST               To populate Direction for portal only created cases based on Case Type Sub Type Direction Map.   
* 1.8      RQ-003805   13-Dec-2016 Nirmal@UST              To trigger Assignment rules and auto response rules for portal created cases
* 2.0      RQ-004298   02-Jan-2017 Ragu@UST                Internal contacts not linking to cases when sent cross brand.
* 3.0      RQ-001360   30-Jan-2017 IBM Support Team        Added Set variable to store Case IDs and the block of code for ISUPDATE TriggerEvent inside the ISAFTER TriggerType. Also, Updated the code to utilise the newly created Set variable for ISINSERT TriggerEvent inside the ISAFTER TriggerType.
* 3.1      RQ-004634   01-Feb-2017 Ragu@UST                Populate Liner Brand from Parent case to ISR case created through Publisher action
* 3.2      RQ-004653   16-Mar-2017 Ranjini@UST             Get the City record id corresponding to Account Billing City.
* 3.3      RQ-004909   05-Mar-2017 Nisha@UST               Updated to close the Milestones for the cases from FSCM
* 4.0      RQ-004667   20-Apr-2017 Nisha@UST               Populate the field related to FCR calculation from closed merged or duplicate  case to Parent Case
* 4.1      RQ-005373   22-Apr-2017 Ragu@UST                Issue: Auto response emails are not triggered when case is getting created during failover scenario. 
* 5.0      RQ-006949   21-Sep-2017 Ranjini@UST             Updates to the Case Resolution Process
* 6.0      RQ-007488   05-Dec-2017 Nisha@UST               CSAT - Pro Active Cases must not send an auto-closure
* 7.0      RQ-007464   18-Jan-2018 Ranjini@UST             Added vendor code and vendor type fields to Account query.
* 8.0      RQ-008020   21-Mar-2018 meenakshi@UST           RQ-008020 Notification on Closed ISR
* 9.0      RQ-007865   03-Apr-2018 Nisha@Ust               Update ISR case 'country' to case owner country on Owner Change
* 10       RQ-008547   14-Jun-2018 meenakshi.rajasekaran@ust  Case Assignment Notification
* 11       RQ-008773   02-July-2018 alokesin@in.ibm.com    Type of location added to the query
* 12       RQ-009034   1-Aug-2018  Ranjini@ust             Dispute changes. 
* 13.      RQ-008620   1-Sep-2018  Ranjini@ust             Non Englis template changes.
* 14       RQ-008863   24-Sep-2018 Partha@MAersk           Care relationship for ISR
* 15       RQ-008889   24-Sep-2018 Nisha@Ust               Prevent survey sent to internal contacts.
*`16       RQ-009429   22-Oct-2018 Nisha@Ust               Send Case Closure field should take the value at the time of case creation irrespective of the code  logic.
* 17       RQ-009451   22-Oct-2018 Nisha@Ust               MLL check for the closure email scenario is applicable only for the external record type.
* 18       RQ-007915   31-Oct-2018 Sreya@Maersk            Automatic closure of Parent case on closure of all the child cases and throw error on closure of Parent case if all the child cases are not closed.
* 19       RQ-009662   05-12-2018  Sreya@Maersk            Auto Closure of Parent Dispute Cases enabled only for Bulk Dispuite Parent Case
* 20       RQ-009245   03-01-2019  Naved@ maersk           Allow to close spam cases when case owner is queue
* 21       RQ-008925   21-01-2019  Naved@maersk            Liner brand ,Direction and Country fields for case to be updated automatically
* 22       RQ-008890   28-01-2019  Partha@maersk           set case closure to no for chat cases - commented it out
* 23.0     RQ-010042   12-02-2019  abhinav.ankit@maersk    Calling two ststic method from getRelatedRecords,Called  two method from staic class from getRelatedLBDCs , getMapCountryNameId method 
* 24.0     RQ-009910   18-02-2019  Sreya@Maersk            Fire Auto response rules for MyFinance Dispute cases.
* 25.0     RQ-010061   06/03/2019  Naved@maersk            Cluster and Region fields to change automatically with change in Country
* 26.0     RQ-011196   15-Jul-2019 Ranjini@ust             Consider ins.maersk.com as external email.
* 27.0     RQ-011720   19-Sep-2019 Ranjini@ust             CSAT Exclusion for EMR 3rd Party Invoice/Disputes RFC
* 28.0     RQ-012299   13-11-2019  Ranjini@UST             Updated the mapEmdts to accomodate vendor scenario.
* 29.0     RQ-011816   13-11-2019  Sreya@Maersk            CSAT Enabling for Cases with Dispute Record Type.
* 30.0     RQ-012315   15-Nov-2019 Ranjini@ust             Twill changes.
* 31.0     RQ-010351   19-12-2019  ramadevi@ust            Handle Send Email Errors
* 33       SC-147      12-03-2020  Ranjini@ust             Removal of Traige Milestone for non Email channels
* 34       SC-199      30-03-2020  Ranjini@ust             Twill identifier changes.
* 35       SC-290      04-05-2020  Avinash@ust             Visibility & Direction for Ocean - SFDC To Portal
* 36       SC-173      02-06-2020  Naved@maersk            Include case channel for No Case closer
* 37.0     SC-390      10-06-2020 Sreya@Maersk             Case Visibility update for Email to Case and Portal cases.
* 38.0     SC-394      15-06-2020  ramadevi@ust            Added Mailing Address to Contact query 
* 39.0     SC-594      25-06-2020  Sunil BS                Included BE code field while populating mapRelatedAccounts
* 40.0     SC-495      08-07-2020   Ramadevi@ust           Commented mapOwnerDetails as the condition for Twill Cases has been changed
* 41.0     IIP-149     24-08-2020   Avinash@ust             Import Manifest Case - Auto Update
* 42.0     SC-1005     07-09-2020   Avinash@ust             Identify Shipment Number from Case
* 43.0     SC-1146     07-10-2020   Akash N                 CSAT excluded  for SEAGLOBALSALES and MSLGLOBALSALES
* 44.0     SC-1207     02-11-2020   Naved@maersk            CSAT Included  for MLL Chat & email-to-case
* 45.0     SC-1256     18-11-2020   Sreya V                 CSAT Logic is moved to CaseFieldPopulator class
*46.0      SC-1126     24-11-2020   Sriram                  Shipment Number based Attributes for Routing - Product Delivery
*47.0      SC-1584     15-01-2020   Sreya V                 Shipment Number should not be filled if already exists in Shipment Number.
*48.0      SC-1625     03-02-2021   ramadevi@ust            Added SCM_on_behalf_of__c to getrelatedconact query
*49.0      SC-2183     27-04-2021   Richa@maersk            Added condition to identify the Dispute cases eligible for OHP API callout
*50.0      SC-2406     21-05-2021   Sreya V                 Auto-Response Rule should be excluded for Twill Portal Cases.
*51.0      SC-2350     31-05-2021   Chakshu@Maersk          To fire auto-response rules for user with custom permission Portal_Web_To_Case_Creation (added as part of Web To Case API Design Change).
*52.0      SC-2447     17-05-2021   Sunil.bs@maersk.com     Commented out the method as it was checking requestor department value as disputes to update case country but as part of sc-2447, only single carrier picklist is present for ocean cases on requestor department.
*53.0      SC-3659     15-11-2021   Richa@maersk            Added condition to identify the cases eligible for Sentiment Analysis callout
*54.0      SC-4201     20-01-2022   Richa@maersk            Added OHP Disputes channel wherever Myfinance channel was listed
*55.0      SC-4321     24-01-2022   Richa@maersk            Description null check in OR condition for populating shipment number
*56.0      SC-4212     02-02-2022   Sreya V                 Omni-Skill based routing for Email cases
*57.0      SC-4185     09-02-2022   Sreya V                 Custom Case Classification Auto-Update
*58.0      SC-4134     10-02-2022   Shashwat Jha            Update sentiment only for cases received from External domain
*59.0      SC-4499     17-02-2022   Thippeswamy A@UST       Stoped Activity related Reference validation for Ocean Claim.
*60.0      SC-4859     07-04-2022   Richa@Maersk            Added condition to identify 4PL Cases 
*61.0      SC-4770     21-04-2022   Thippeswamy@Maersk      Custom Model Pilot for ECC 
*62.0      SC-5376     17-06-2022   Thippeswamy@UST         4PL dashboard enhancement
*63.0      SC-5492     28-06-2022   Richa@Maersk            Added condition to identify portal cases for 4PL sharing
*64.0      SPI-100     17-06-2022   Ronnie@SF               Removed brand hardcoding
*65.0      SC-5543     19-09-2022   Richa@Maersk            Added condition for Dispute Owner change
*66.0      SC-5744     19-10-2022   Vivek@Maersk            Added filter to prevent integration call from Maersk LnS brand for Dispute cases                      
*67.0      SC-5414     9-01-2023    Saradha@UST             Metadata query changes as part of CTO
*68.0      SC-6639     7-02-2023    Harmeet@Maersk          Adding filter for calling Custom Classification Model for setCasesForCustomCC Set of Id
*69.0      SC-7243     27-02-2023   Saradha@UST             Synchoronous sharing for ISR cases
*70.0      SC-7253     07-03-2023   nayana@Maersk           Bypass GCSS integration for Hamburg Sud cases
*71.0      SC-7133     08-03-2023   Ayush@Maersk            Implement LNS Case Classification Model
*72.0      SC-7083     18-03-2023   ramadevi@maersk.com     Validation Rule for selecting the recommendation on Case Closure.
*73.0      SC-7347     27-03-2023   Vivek@maersk.com        Changes to CLaim/Claim Recovery records fields from Sub_Type->Type , RFC->Sub_Type to resolve RFC limits
*73.0      SC-7804     24-05-2023   Ramadevi@Maersk.com     Validation shown for all Users,while closing the case.
*75.0      SC-5371     11-05-2023   Richa@maersk            4PL bug fix
*76.0     SC-8274     15-06-2023  Nayana@maersk.com    Added condition to fetch data for CaseOmniSkillBasedRouting.defineCaseSkillMap and deletePSRForOmniEmail
*77.0     SC-8310     27-06-2023  Shahanawaz@maersk.com  Added filter for products to not perform auto classification
*78.0     SC-7849     12-07-2023  Nayana@maersk      Added handshakeExcludedCaseOrigins and csatExcludedCaseOrigins, removed ExcludedCaseOrigins to decouple CSAT and Handshake exclusion logic
*79.0     SC-8700     28-07-2023  Nayana@maersk        Move Omni origins from Custom label to Custom metadata
*80.0     SC-8358     31-07-2023  Sunil.bs@maersk        Enabled omni routing for web to case as well
*81.0     SC-8816     21-08-2023  Shahanawaz@maersk    Migrate Before Save Flow to Before Apex Trigger
*82.0      SC-8489     08-08-2023   Vivek@Maersk      Added record type check on checkNBAActionStatusOnCaseClose to prevent it to fire for Email Recommendations record
*83.0      SC-8791     01-09-2023   Vivek@Maersk            Migrate After Save Flow to After apex trigger
*84.0      SC-8818     15-09-2023   Meghna@Maersk           Excluding specific cases for 4PL sharing which belongs to SCM Restricted Visibility
*85.0      SC-9056     18-10-2023   Raksha@Maersk           Validation Rule for clicking View Details button on NBA Recommendation
*86.0      SC-9138     18-10-2023   Vivek@Maersk            Added new variable to fire for AI agent -1 resolution summary related KPIs update
*87.0      SC-9190     19-10-2023   Shahanawaz@Maersk.com   Added new wrapperlist to create external object record
*88.0      SC-9008     20-10-2023   Sunil.bs@maersk.com     Move Time spend in Main Queue logic to apex from batch
*89.0      SC-8989     22-02-2024   Shahanawaz@maersk.com   Add Entitlement for Email Cases which are not classified
*90.0      SC-9291     19-03-2024   Shahanawaz@maersk.com   Update Auto Handshake Email Address SCM KC BA
*91.0	   SC-9978	   06-May-2024	Richa@maersk		    Publish Cases through Custom Event framework
*92.0	   SC-10076	   27-May-2024	Shahanawaz@maersk		Update Case Omni skill type on reassignment
*93.0      SC-10137    11-06-2024   Shahanawaz@maersk   	Automate Response Received Flag
*94.0 SC-10036 01-07-2024 Vazid Added updateCaseOwnerhasCheckerQueue to update logged in user as case owner if owner is checker queue.
*95.0      SC-10204	   02-07-2024	Shahanawaz@maersk		Auto Populate From Address (Multiple CM BA)
*96.0      SC-10036	   04-07-2024	Vazid					Added logic to re-trigger Gen2 recommendations when Direction, RFC, Type or subtype updated
*/
/**
* @description CaseRecordSelector
*/
public class CaseRecordSelector implements RecordSelector {
    
    private TriggerHandler casTriggerHandler;
    // To store cases based on the record type
    public list<Case> lstExternalCases = new list<Case>();
    public list<Case> lstExternalandDispCases = new list<Case>();//#RQ-009034
    public list<Case> lstExternalInstantDOCases = new list<Case>();//RQ-SC-3762
    public list<Case> lst4PLCases = new list<Case>();//RQ-SC-4507
    public list<Case> lstClaimCases = new list<Case>();
    public list<Case> lstClaimsRecoveryCases = new list<Case>();
    public list<Case> lstExtAndClaimCases = new list<Case>();
    public list<Case> lstManualExternalCases = new list<Case>();
    public set<Id> setCaseIdsToSetDMLOptions = new set<Id>();
    public set<Id> setCaseIdsToSetDMLOptionsAW = new set<Id>();
    public set<Id> setCaseIdsToSetAutoResponseOptions = new set<Id>(); 
    public list<Case> lstCasesToCompleteMilestones = new list<Case>(); // RQ-004502
    public map<Id, Case> mapCasesToUpdateKPIsForAI     = new map<Id,Case>(); //SC-9138
    public set<Id> setAiResponseCreatorId  = new set<Id>();//SC-9138
    public map<Id, Case> mapCasesForAiAgentUpdate = new map<Id, Case>();//SC-9661
    public Map<Id,Case> twillCaseMap = new Map<Id,Case>();
    
    // RQ-008889 : Closure email notification for cases
    public list<Case> lstCasesNotToSentSurvey = new list<Case>(); 
    public list<Case> lstCasesToSentSurvey =  new list<Case>(); 
    
    
    //SC-1005 ->Identify Shipment Number from Case
    //List to store cases for E-mail channel
    public List<Case> lstE2CShipmentNumberPopulation = new List<Case>();
    
    public list<Case> lstExtClaimDispAndISRCases = new list<Case>(); // RQ-003147 //#RQ-009034. Renamed to add Dispute also.
    public list<Case> lstClaimsforGCSSIntgtn = new list<Case>(); // RQ-002679
    public list<Case> lstClaimsIdsForResetGCSSCheckbox = new list<Case>(); // RQ-002679
    public list<Case> lstISRCases = new list<Case>(); // RQ-004058
    public list<Case> lstCasesToPopulateDirection = new list<Case>(); // RQ-004502
    public list<id> lstSpamCaseId =  new list<id>();
    public list<Case> lstCaseOwmerChange =  new list<Case>();
    public list<Case> lstCasesToUpdateNBAOptOut = new list<Case>(); // SC-9008
    public list<Case> lstCaseCountryChange =  new list<Case>();
    public list<Case> lstCasesInScope =  new list<Case>();
    public  map<id,id> mapCasesforemailalerts =  new map<id,id>();
    public  map<id,id> mapCasesTaskforclaims =  new map<id,id>();
    public  map<id,string> mapUpdateBHtime =  new map<id,string>();
    public  map<id,string> mapCalculateBHtime =  new map<id,string>();
    public List<Case> caseEscalationSendEmailAlertsList = new List<Case>();
    public map<String,Case> mapQueueIdCase =  new map<String,Case>();
    public list<Case> lstAutocloseCase = new List<Case>();
    public map<String, Case_Type_Sub_Type_Direction_Mapping__mdt> mapTSD = new map<String, Case_Type_Sub_Type_Direction_Mapping__mdt>(); // RQ-004502
    
    // RQ-001360 - To populate the Case IDs
    public set<Id> setCaseIdsToUpdateMilestones = new set<Id>();  
    
    // To populate Service Relationship (Care Relationship)
    public list<Case> lstCasesToPopulateCR = new list<Case>();
    
    // RQ-007915 - To store the Map of dispute cases on closure
    public Map<Id,Case> mapDisputeClosureCases = new Map<Id,Case>();
    public set<String> setDisputeClosureCases = new set<String>();
    
    // To store related Account details
    public set<Id> setAccountIds = new set<Id>();
    public map<Id, Account> mapRelatedAccounts = new map<Id, Account>();
    
    // To store related Contact details
    public set<Id> setContactIds = new set<ID>();
    public set<Id> setCountryIds = new set<ID>();
    public set<String> setSuppliedEmails = new set<String>();
    public map<Id, Contact> mapRelatedContacts = new map<Id, Contact>();
    public map<Id, Geography__c> mapRelatedGeography = new map<Id, Geography__c>();

    
    //SC-4212
    public set<Id> setCareRelationshipIds = new set<Id>();
    public map<id, Care_Relationship__c> mapRelatedCareRelation = new map<id, Care_Relationship__c>();
    public set<Id> setKeyClientIds = new set<Id>();
    public map<id, Client_Case_Assignments__c> mapKeyClient = new map<id,Client_Case_Assignments__c>();
    
    // To store related LinerBrand_Direction_and_Country__mdt details
    public set<String> setOriginsForE2C = new set<String>(); 
    public static map<String, LinerBrand_Direction_and_Country__mdt> mapLBDCs = new map<String, LinerBrand_Direction_and_Country__mdt>();
    public map<String, LinerBrand_Direction_and_Country__mdt> mapOwnerNameLBDCs = new map<String, LinerBrand_Direction_and_Country__mdt>();
    //converted to static variable
    public static map<String, SCM_Key_Client_Country_Mapping__mdt> mapSCMKC = new map<String, SCM_Key_Client_Country_Mapping__mdt>();
    public static map<String, SCM_Key_Client_Country_Mapping__mdt> mapAllSCMKC = new map<String, SCM_Key_Client_Country_Mapping__mdt>();
    
    
    // RQ-004634 - Populate Liner Brand from Parent case to ISR case created through Publisher action
    public set<Id> setCaseIds = new set<Id>();
    public map<Id, Case> mapRelatedCases = new map<Id, Case>();
    
    // RQ-004667 -Populate the field related to FCR calculation from closed merged or duplicate  case to Parent Case
    public set<Id> setChildCaseId = new set<Id>(); 
    public set<Id> setParentCaseId = new set<Id>();
    
    //#RQ-006949
    public Map<Id,Case> mapCasesForClosureNotification = new Map<Id,Case>();
    public Map<Id,Case> mapISRClosurePost = new Map<Id,Case>();
    
    //#RQ-008020
    Public set<id> setclosedcaseIds = new set<id>();
    
    //#RQ-008547     
    public Map<Case,id> mapCaseownerUpdated = new Map<Case,id>();
    public Map<Id,Case> mapCaseownerEligible = new Map<Id,Case>();
    
    //#RQ-007865
    public map<String,Id> mapCountryNameId = new map<String,Id>();
    public map<Id,Id> mapCaseIdOwnerId = new map<Id,Id>();
    public map<Id, String> mapOwnerandCountry = new map<Id,String>();
    public map<Id, String> mapOwnerandRole1 = new map<Id,String>();
    
    public map<Id,String> mapCountryIdName = new map<Id,String>();
    public map<String,String> mapCountryNameCountryId = new map<String,String>();
    public map<String, Email_Template_Mapping__mdt> mapEmdts = new map<String, Email_Template_Mapping__mdt>();
    public static Boolean blnCountryChange = false;
    
    //#RQ-012315
    public List<Id> lstOwnerIds = new List<Id>();
    //public map<Id,User> mapOwnerDetails = new map<Id,User>();//Commented as part of Sc-495
    public list<Case> caseswithShipmentNumber = new list<Case>();
    public Map<Id,EventTypeWrapper> mapCasesToPublish = new Map<Id,EventTypeWrapper>(); //SC-2183 //SC-9978
    public list<Case> lstCasesForSentiment = new list<Case>();//SC-3659
    public List<Case> csListForCustomCC = new List<Case>();//SC-4185
    public list<Case> listCasesOwnerChangeForOmni = new list<Case>();//SC-8274
    public Set<Id> setDeleteRoutingForOmni = new Set<Id>();//SC-8274
    public List<Case> lstDeleteRoutingForOmni = new List<Case>();//SC-8380
    public List<Case> validShipmentnumberCases = new List<Case>();//SC-8380
    
    public Map<Id,Group> mapOmniQueues = new Map<Id,Group>();//SC-8274  
    public Map<String,Case_OmniSkill_Mappings__c> ownerSkillmap = new Map<String,Case_OmniSkill_Mappings__c>();//SC-8274
    public Set<Id> caseOwnerID = new Set<Id>();//SC-4374
    public Set<Id> caseOwnerIDSCMKC = new Set<Id>();    
    //SC-7849: Decouple Handshake and CSAT exclusion logic  
    public static List<String> handshakeExcludedCaseOrigins = New List<String>();
    public static List<String> csatExcludedCaseOrigins = New List<String>();
    public static List<String> scmRestrictedOrigins = New List<String>();
    
    
    // SC-4212 
    public list<Case> lstSkillRoutingCases = new List<Case>(); 
    public Set<Id> set4PLExtrnlCaseIds  = new Set<Id>();// SC-4859
    public Set<Id> set4PLChngeIdsExtrnl  = new Set<Id>(); //SC-5371
    public Set<Id> set4PLISRCaseIds  = new Set<Id>();// SC-7243
    public Set<Id> set4PLCaseIds = new Set<Id>();
    public list<Case> lst4PLISRCasesForShare = new list<Case>(); // SC-7243
    public Set<Id> set4PLCaseIdsPortal = new Set<Id>();// SC-5492
    public Set<Id> set4PLChngeIdsPortal = new Set<Id>(); //SC-5371
    public list<Case> lstExternalISRCases = new list<Case>(); 
    public set<Case> setCaseManagerUpdate = new set<Case>(); //SC-5322
    
    
    // SC-2350
    private static final String CUSTOM_PERMISSION_PORTAL_CASE_CREATION = 'Portal_Web_To_Case_Creation';
    //SC-4770
    public Set<Case> setCasesforClassificationChange = new Set<Case>(); // contains set of case ids which type or subtype is changed
    //SC-5414 removed from constructor and added logic in select records for checkActivityReference         
    public Map<Id,Case> newMapForClaimRT = new Map<Id,Case>();
    //public static Boolean containsClaimRT = false;
    public Boolean containsClaimRT = false;
    
    //SC-8358
    public list<Case> lstPortalCasesToOmniRoute = new List<case>();
    
    //NBA
    public List<Case> extNBACloseCases = new List<Case>();
    public List<Case> caseRecommendationList = new List<Case>(); 
    
    //Move Omni origins from Custom label to metadata
    public static List<String> omniOriginList = New List<String>();
    
    public static List<String> omniPortalOriginList = New List<String>();
    public static List<String> originArtemisGE = New List<String>();
    
    //SC-7661
    public List<Case> idaCaseslist = new List<Case>();
    
    //Update Ownership Change Time
    public List<Case> ownershipChangeCaseList = new List<Case>();
    //Update New Email Flag
    public List<Case> newEmailFlagCaseList = new List<Case>();
    //Update Last Meaningful Activity
    public Set<Id> lastMeaningfulActCaseIdSet = new Set<Id>();
    public List<String> closedStatuses = new List<String>();
    //SC-8816
    public List<Case> caseListToUpdateBlankBolNo = new List<Case>();
    public List<Case> caseListToUpdateClaimBolNo = new List<Case>();
    public List<Case> caseListToUpdateISRBolNo = new List<Case>();
    public Set<Id> countryIdSetToUpdateISRBolNo = new Set<Id>();
    public List<Case> caseListToUpdateSubject = new List<Case>();
    public List<Case> caseListToUpdatePortalOnBehalf = new List<Case>();
    public List<Case> caseListToUpdateProductClaimActivity = new List<Case>();
    public Set<Id> parentIdSet = new Set<Id>();
    //SC-8791
    public List<Case> isrClosedCaseList = new List<Case>();
    //SC-8791
    public Map<Case, Case> artemisCasesMap = new  Map<Case, Case> ();
    public Set<Id> artemisQueueIds = new Set<Id>();
    //SC-8791
    public Map<Case, Case> dispCasesOnEmailTrigCondition =  new Map<Case, Case>();
    
    //SC-9190
    public List<CaseHistoryWrapper> csHistoryWrapList = new List<CaseHistoryWrapper>();
    
    //SC-9293
    public List<Case> caseListForFeedItem = new List<Case>();
    
    //SC-9626
    public static Boolean skipOBHLogic = false;
    
    //SC-9291
    public List<Case> caseListForHandshake = new List<Case>();
    public Set<String> originsSet = new Set<String>();
    public static Set<String> templateNames = new Set<String>();
    public static Set<String> replyToEmailList = new Set<String>();
    public static Map<String, SCM_Key_Client_Country_Mapping__mdt> scmIndicatorToSCMKCMap = new Map<String, SCM_Key_Client_Country_Mapping__mdt>();
    //SC-10076
    public List<Case> caseOmniSkillUpdateList = new List<Case>();
    //SC-10137
    public Set<Id> isrParentCaseSet = new Set<Id>();
    public Map<Id,Case> mapOfCasesLatestRecomm = new Map<Id,Case>();
    public List<Case> checkerQueueOwnerCases = new List<Case>();
    public Set<Id> caseIdSetToUpdateOwner = new Set<Id>();
    //SC-10204
    public Set<Id> caseOwnerIdsForBAAddress = new Set<Id>();
    public List<Case> caseListForBAAddress = new List<Case>();
    /** 
    * @description | CaseRecordSelector constructor
    * @param lstCases accepts case list
    * @param mapOldCases accepts case old map
    * @param casTriggerHandler accepts case TriggerHandler context
    * SC-9161
    */
    public CaseRecordSelector(list<Case> lstCases, map<Id, Case> mapOldCases, TriggerHandler casTriggerHandler) {
        this.casTriggerHandler = casTriggerHandler;
        this.selectRecords(lstCases, mapOldCases);
        //SC-5414 calls only if the NEW cases are type ClaimRT to reduce soql and unnecessary calls
        if(containsClaimRT){
            this.checkActivityReference(newMapForClaimRT,mapOldCases);  
        }
        
        if(extNBACloseCases.size()>0){
            this.checkNBAActionStatusOnCaseClose(extNBACloseCases);
        }
        
        if(lstCases != null) {
            this.getRelatedRecords(lstCases);
        }
        else if(mapOldCases != null) {
            this.getRelatedRecords(mapOldCases.values());
        }
    }
    
    /** 
    * @description | filter case records
    * @param lstCases accepts case list
    * @param mapOldCases accepts case oldmap
    * SC-9161
    */
    public void selectRecords(list<Case> lstCases, map<Id, sObject> mapOldCases) {
        Id externalCaseRTId = Label.External_Case_RT_Id;
        Id claimRTId = Label.Claim_Case_RT_Id;
        Id claimsRecoveryRTId = Label.Claim_Recovery_Case_RT_Id;
        Id disputeRTId = Label.Dispute_Case_RT_Id;
        Id isrrtid = Label.ISR_Case_RT_Id;
        Set<String> setMergedStatuses = new Set<String>{'Closed - Merged', 'Closed - Duplicate'};
            //SC-8274
            list<id> ownerIdsInScope = new list<id>();
        for(Case newCase : (list<Case>)lstCases) {
            if(string.isNotBlank(newCase.ownerid)){
                ownerIdsInScope.add(newCase.ownerid);
            }
        }
        if(!ownerIdsInScope.isempty()){
            for(Case_OmniSkill_Mappings__c skl: [select Case_Field__c, Value__c, Origin__c, Skill_Id__c,Queue_Id__c from Case_OmniSkill_Mappings__c where Queue_Id__c in: ownerIdsInScope and Mandatory__c = true and Active__c = true]){  
                ownerSkillmap.put(skl.Queue_Id__c,skl);  
            }
        }
        // RQ-005373
        User currentUser = StaticFactory.getCurrentUserDetails();
        // SC-4770
        List<String> lstCaseOrigins = New List<String>();
        //SC-5415 Made call to static factory to reduce SOQL calls and query rows
        List<General_Key_Value_Configurations__mdt> lstGeneralkeyValueConfigmdt = StaticFactory.getGeneralkeyValueConfigmdt('CustomModelECC');
        for(General_Key_Value_Configurations__mdt mdt : lstGeneralkeyValueConfigmdt){
            lstCaseOrigins.add(mdt.First_Field_Value__c);
        }
        
        if(closedStatuses.isEmpty()){
            for(CaseStatus cs : [Select Id, MasterLabel From CaseStatus Where IsClosed = true]){
                closedStatuses.add(cs.MasterLabel);
            }
        }
        
        if(artemisQueueIds.isEmpty()){
            List<String> artemisQueueList = StaticFactory.getArtemisQueueList();
            for(Group gp : [Select Id From Group Where DeveloperName =: artemisQueueList]){
                artemisQueueIds.add(gp.Id);
            }
        }
        
        String productExclusion = General_Key_Value_Configurations__mdt.getInstance('Auto_Classification_Product_Exclusion').First_Field_Value__c;
        List<String> prodExcList = new List<String>();
        if(!String.isEmpty(productExclusion)){
            prodExcList = productExclusion.split(',');
        }
        getOriginArtemisGEList();
        String deliveryChannel = General_Key_Value_Configurations__mdt.getInstance('Delivery_Channel').first_field_value__c;
        
        for(SCM_Key_Client_Country_Mapping__mdt scmKC : SCM_Key_Client_Country_Mapping__mdt.getall().values()) {
            originsSet.add(scmKC.Relation_to_LBDC_metadata__r.DeveloperName);
        } 
        
        if(lstCases != null) {
            for(Case newCase : (list<Case>)lstCases) {
                Case oldCase;
                newMapForClaimRT.put(newCase.Id,newCase);
                if(mapOldCases != null && !mapOldCases.isEmpty()) {
                    oldCase = (Case)mapOldCases.get(newCase.Id);
                    
                    if(oldCase.AccountId != newCase.AccountId) {
                        setAccountIds.add(oldCase.AccountId);
                    }
                    if(oldCase.ContactId != newCase.ContactId){
                        setContactIds.add(oldCase.ContactId);
                    }
                    if(oldCase.Country__c != newCase.Country__c){
                        setCountryIds.add(oldCase.Country__c);
                    }
                }
                
                // SC-8791
                if(newcase.RecordTypeid == claimRTId && newcase.Status == 'Potential Claim'){
                    mapCasesTaskforclaims.put(newCase.id,newCase.id);
                }
                
                // Store AccountId
                if(newCase.AccountId != null) {
                    setAccountIds.add(newCase.AccountId);
                }
                if(newCase.On_Behalf_Account__c != null) {
                    setAccountIds.add(newCase.On_Behalf_Account__c);
                }
                
                
                // Store ContactId
                if(newCase.ContactId != null) {
                    setContactIds.add(newCase.ContactId);
                } 
                if(newCase.Country__c != null) {
                    setCountryIds.add(newCase.Country__c);
                } 
                
                // SC-4212 Store Care relationship Ids
                if(newCase.Care_Relationship__c != null) {
                    setCareRelationshipIds.add(newCase.Care_Relationship__c);
                }
                if (newCase.On_Behalf_Account__c != null || newCase.AccountId != null) {
                    setKeyClientIds.add(newCase.On_Behalf_Account__c != null ? newCase.On_Behalf_Account__c : newCase.AccountId);
                }
                
                // Segregate Cases based on the Record Type
                if(newCase.RecordTypeId == externalCaseRTId) {
                    lstExternalCases.add(newCase);
                    lstExternalandDispCases.add(newCase);//#RQ-009034
                    lstExtAndClaimCases.add(newCase);
                    lstExtClaimDispAndISRCases.add(newCase); // RQ-003147
                    lstCasesToPopulateCR.add(newCase); // RQ-002633
                    lstExternalISRCases.add(newCase);// SC-4861
                    
                    //SC-3762 --> store all instant DO cases.
                    if(newCase.Reason_For_Case__c == 'Letter of Authorization/Mandatory Document Approval'){
                        lstExternalInstantDOCases.add(newCase);
                    }
                    
                    //SC-4507 --> store all 4pl Spot cases.
                    if(BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MAERSKLS).contains(newCase.Liner_Brand__c) && newCase.Product__c == '4PL'){
                        lst4PLCases.add(newCase);
                    }
                    
                    //SC-1005 -> Identify Shipment Number from Case
                    //SC-1584 : Identify Shipment Number from Case only if Shipment Number is blank
                    if((newCase.Case_Channel__c == 'E-mail' || newCase.Case_Channel__c == 'Portal') && ((newCase.Subject != null && newCase.Subject != '') || (newCase.Description != null && newCase.Description != '')) && String.isBlank(newCase.Shipment_Number__c)){
                        lstE2CShipmentNumberPopulation.add(newCase);
                    }
                    
                }
                else if(newCase.RecordTypeId == claimRTId) {
                    lstClaimCases.add(newCase);
                    lstExtAndClaimCases.add(newCase);
                    lstExtClaimDispAndISRCases.add(newCase); // RQ-003147
                    lstCasesToPopulateCR.add(newCase); // RQ-002633    
                    if(!containsClaimRT){
                        containsClaimRT = true;
                    }
                }
                else if(newCase.RecordTypeId == claimsRecoveryRTId) {
                    lstClaimsRecoveryCases.add(newCase);
                    lstExtAndClaimCases.add(newCase);
                    lstExtClaimDispAndISRCases.add(newCase); // RQ-003147                    
                }
                // RQ-003147 - Start
                else if(newCase.RecordTypeId == isrrtid) {
                    lstExtClaimDispAndISRCases.add(newCase);
                    lstISRCases.add(newCase);
                    lstCasesToPopulateCR.add(newCase); //RQ-008863 
                    lstExternalISRCases.add(newCase);// SC-4861
                    
                    //SC-1005 -> Identify Shipment Number from Case
                    //SC-1584 : Identify Shipment Number from Case only if Shipment Number is blank
                    if(((newCase.Subject != null && newCase.Subject != '') || (newCase.Description != null && newCase.Description != '')) && String.isBlank(newCase.Shipment_Number__c)){
                        lstE2CShipmentNumberPopulation.add(newCase);
                    }
                }
                // RQ-003147 - End
                //#RQ-009034. Add dispute record types to the common case list lstExtClaimDispAndISRCases
                else if(newCase.RecordTypeId == disputeRTId) {
                    lstExtClaimDispAndISRCases.add(newCase);
                    lstExternalandDispCases.add(newCase);
                    lstCasesToPopulateCR.add(newCase);
                }
                
                
                // Store SuppliedEmail and Origin
                if(!String.isBlank(newCase.SuppliedEmail)) {
                    setSuppliedEmails.add(newCase.SuppliedEmail);
                    if(!String.isBlank(newCase.Origin)) {
                        setOriginsForE2C.add(newCase.Origin);
                    }
                }
                
                // RQ-002679 Start
                if(casTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) {
                    if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                        if(newCase.RecordTypeId == claimRTId && newCase.Refresh_GCSS_Data__c == true) {
                            lstClaimsIdsForResetGCSSCheckbox.add(newCase);
                        }
                        // RQ-004634 - Populate Liner Brand from Parent case to ISR case created through Publisher action
                        else if(newCase.RecordTypeId == isrrtid) {
                            setCaseIds.add(newCase.ParentId);
                        }
                        // RQ-004424: For Portal Cases, set direction according to the Type, Sub Type values
                        if(newCase.Case_Channel__c == Label.CaseChannelPortal) {
                            lstCasesToPopulateDirection.add(newCase);
                        }
                        
                        // SC-9008  
                        if(newcase.Require_NBA_opt_out__c == true){ 
                            lstCasesToUpdateNBAOptOut.add(newcase);  
                        }
                        
                        //#RQ-012315. To get the Owner Ids
                        if(!String.valueOf(newCase.ownerId).startsWith('00G')){
                            lstOwnerIds.add(newCase.ownerId);
                            caseOwnerIDSCMKC.add(newCase.ownerId);
                        }
                        //SC-5376   
                        if(newCase.ownerId!=Null)   
                        {                              
                            caseOwnerID.add(newCase.ownerId);   
                        }       
                        
                        //NBA - Cases to retrieve Recommendations -
                        /*if(newCase.recordtypeId== externalCaseRTId  && newCase.Case_Channel__c == 'E-mail' && newCase.Type <> null && newCase.Sub_Type__c <> null && newCase.Product__c <> null){
caseRecommendationList.add(newCase);
}*/  
                        //SC-8816 - update for Claim cases
                        if(newCase.RecordTypeId == claimRTId && !closedStatuses.contains(newCase.Status) && newCase.Status != 'Triaged' && newCase.MLL__c == false && !String.isEmpty(newCase.BoL_Number__c) && !String.isEmpty(newCase.Type) && !String.isEmpty(newCase.Sub_Type__c) && newCase.Sub_Type__c != 'Commercial Claim' && newCase.Sub_Type__c != 'Contractual Claim' && newCase.Sub_Type__c != 'Other Legal Claim'){
                            caseListToUpdateClaimBolNo.add(newCase);
                        }
                    }
                    else if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                        // SC-9008  
                        if(newCase.Require_NBA_opt_out__c == true && oldCase.Require_NBA_opt_out__c == false){  
                            lstCasesToUpdateNBAOptOut.add(newcase);  
                        }
                        
                        //SC-8274  
                        if(oldCase.ownerId != newCase.ownerid && (newCase.Case_Channel__c == 'E-mail'|| newCase.Case_Channel__c == 'Portal' || newCase.Case_Channel__c == 'Website')){                              
                            setDeleteRoutingForOmni.add(newCase.Id);  
                            lstDeleteRoutingForOmni.add(newCase);
                            
                        } //end of SC-8274  
                        
                        //NBA-Cases to retrieve Recommendations
                        if(newCase.recordtypeId == externalCaseRTId  && newCase.Case_Channel__c == 'E-mail' && (newCase.Type <> oldCase.Type || newCase.Sub_Type__c <> oldCase.Sub_Type__c || newCase.Reason_For_Case__c <> oldCase.Reason_For_Case__c || newCase.Product__c <> oldCase.Product__c )){     //SC-9056: added RFC condition to consider RFC for NBA recommendation
                            //|| newCase.Status <> oldCase.Status - removing, API callout to be made only on Classification changes
                            caseRecommendationList.add(newCase);                           
                        }
                        if(newCase.RecordTypeId == claimRTId) {
                            if(!String.isBlank(newCase.Liner_Brand__c) && !BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.HAMBURGSUD).contains(newCase.Liner_Brand__c)){ //bypass GCSS for Hamburg sud
                                if(newCase.BoL_Number__c != oldCase.BoL_Number__c || (newCase.Refresh_GCSS_Data__c == TRUE && newCase.Refresh_GCSS_Data__c != oldCase.Refresh_GCSS_Data__c)) {
                                    if(newCase.BoL_Number__c != null) {
                                        lstClaimsforGCSSIntgtn.add(newCase);   
                                    }
                                    if(newCase.Refresh_GCSS_Data__c == true) {
                                        lstClaimsIdsForResetGCSSCheckbox.add(newCase);
                                    }
                                }
                            }
                        }
                        // RQ-009245 - Allow to close spam cases when case owner is queue
                        if(casTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE){
                            if(oldCase.ownerId != null){
                                if(String.valueOf(oldCase.ownerId).startsWith('00G') && 
                                   newCase.type =='Non-Case' && newCase.Status == 'Closed - Not a case' && oldCase.type != newCase.type  && oldCase.Status != newCase.status ){
                                       lstSpamCaseId.add(newCase.id);
                                   }
                            }                            
                            if(newCase.ownerId != null){
                                if(String.valueOf(newCase.ownerId).startsWith('00G') && oldCase.ownerId != newCase.ownerid){
                                    
                                    //lstCaseOwmerChange.add(newCase);
                                    newCase.Cluster__c=null;
                                    newCase.Region__c = null;
                                    mapQueueIdCase.put(newCase.ownerid+'_'+newCase.id,newCase);                                                              
                                } 
                                
                                //#RQ-012315. To get the Owner Ids
                                if(!String.valueOf(newCase.ownerId).startsWith('00G') && oldCase.ownerId != newCase.ownerid)
                                {
                                    lstOwnerIds.add(newCase.ownerId);
                                }
                            }                         
                            
                            //RQ-010061 
                            if(newCase.country__c != oldCase.country__c ||newCase.City__c != oldCase.City__c) {
                                if(blnCountryChange == false){
                                    newCase.Cluster__c=null;
                                    newCase.Region__c = null;
                                    blnCountryChange = true;
                                }
                                
                                //   lstCaseCountryChange.add(newCase);
                                //CaseGeoData.validateGeoData(lstCaseCountryChange);
                            }
                            
                            //NBA - To check Actioned Recommendation on close                           
                            if(newCase.recordtypeId== externalCaseRTId  && newCase.Status != oldCase.Status && newCase.status == 'Closed - Resolved'){
                                extNBACloseCases.add(newCase);
                            }
                            
                            
                        }
                        
                        // RQ-004424: For Portal Cases, set direction according to the Type, Sub Type values
                        if(newCase.Case_Channel__c == Label.CaseChannelPortal && (newCase.Type != oldCase.Type || newCase.Sub_Type__c != oldCase.Sub_Type__c)) {
                            lstCasesToPopulateDirection.add(newCase);
                        }
                        
                        /* SC-2447 Commented out the method as it was checking requestor department value as disputes to check case country but as part of sc-2447, only single carrier picklist is present for ocean cases on requestor department.

// v9.0 :#RQ-007865 (Update the ISR Country to Case Owner Country on owner change.) 
if (doSetCountryFromUserCountry(newCase, oldCase, isrrtid)) {
blnCountryChange = true;
mapCaseIdOwnerId.put(newCase.Id, newCase.OwnerId);
}*/
                        
                        // RQ-007915 - To store the Map of dispute cases on closure
                        // RQ-009662 - Consider only for bulk dipute cases.
                        if(newCase.RecordTypeId == disputeRTId && newCase.Status != oldCase.Status && (newCase.status == 'Closed - Resolved' || newCase.status == 'Closed - Not a case' || newCase.status == 'Closed - Reassigned' || newCase.status == 'Closed - Merged' || newCase.Status == 'Closed - Duplicate')  && newCase.ParentId == null  && newCase.Bulk_Dispute__c == 'True') {                                                       
                            mapDisputeClosureCases.put(newCase.Id,newCase);  
                        }
                        
                        //SC-9661 new variable mapCasesForAiAgentUpdate to be updated if the user has Ocean, External Case and E-mail and Onboarded country for AI to be used for dashboard filters 
                        if(newCase.RecordTypeId == externalCaseRTId && newCase.Status == 'Closed - Resolved' &&  newCase.Resolution_Summary__c != null && newCase.Case_Channel__C == 'E-mail' && newCase.Product__c == 'Ocean' && Label.IDACountryFieldCriteriaEmailRecommendation.containsIgnoreCase(newCase.Case_Country__c) && newCase.ContactId != null && newCase.OwnerId !=null && String.valueOf(newCase.OwnerId).Substring(0,3) == '005') {                            
                            mapCasesForAiAgentUpdate.put(newCase.Id, newCase);      
                        }
                        
                        //SC-5322 - create case owner manager update set
                        if(newCase.OwnerId !=null && oldCase.OwnerId!= newCase.OwnerId )
                        {
                            setCaseManagerUpdate.add(newCase);
                        }
                        //Update Ownership Change Time
                        if(oldCase.OwnerId != newCase.OwnerId && !String.isEmpty(newCase.Status) && !newCase.Status.contains('Closed')){
                            ownershipChangeCaseList.add(newCase);
                        }
                        //Update New Email Flag
                        if(!closedStatuses.isEmpty() && closedStatuses.contains(newCase.Status) && newCase.Status != oldCase.Status && newCase.New_Mail__c == true && Userinfo.getUserType() == 'Standard'){
                            newEmailFlagCaseList.add(newCase);
                        }
                        
                        //SC-8816 - Update to Blank
                        if(newCase.RecordTypeId == isrrtid && !String.isEmpty(newCase.Compound_Index_for_BoL_Number__c) && newCase.Collaboration_Reason__c != oldCase.Collaboration_Reason__c && newCase.Collaboration_Reason__c != 'AFR Closure'){
                            caseListToUpdateBlankBolNo.add(newCase);
                        }
                        
                        //SC-8816 - Update for Claim cases
                        if(newCase.RecordTypeId == claimRTId && !closedStatuses.contains(newCase.Status) && newCase.Status != 'Triaged' && newCase.MLL__c == false && !String.isEmpty(newCase.BoL_Number__c) && newCase.Sub_Type__c != 'Commercial Claim' && newCase.Sub_Type__c != 'Contractual Claim' && newCase.Sub_Type__c != 'Other Legal Claim' && (newCase.BoL_Number__c != oldCase.BoL_Number__c || newCase.Sub_Type__c != oldCase.Sub_Type__c || newCase.Status != oldCase.Status || newCase.MLL__c != oldCase.MLL__c)){
                            caseListToUpdateClaimBolNo.add(newCase);
                        }
                    	
                        //To update case owner as logged in user if case is associated with checker queue.
                        if(!String.isEmpty(newCase.Status) && newCase.Status.contains('Closed')  && String.valueOf(oldCase.OwnerId).startsWith('00G') && newCase.AI_Recommendation_Status__c == 'Resolution Recommended'){
                            checkerQueueOwnerCases.add(newCase);
                            caseIdSetToUpdateOwner.add(oldCase.OwnerId);
                        }
                        
                        //Below logic is to re-trigger the gen2 recommendation when below fields are modified
                        if( ((newCase.Direction__c !=null && oldCase.Direction__c!= newCase.Direction__c) ||
                             (newCase.Delivery_Channel__c !=null && oldCase.Delivery_Channel__c!= newCase.Delivery_Channel__c) || 
                             (newCase.Reason_For_Case__c !=null && oldCase.Reason_For_Case__c!= newCase.Reason_For_Case__c) ||
                             (newCase.Sub_Type__c !=null && oldCase.Sub_Type__c!= newCase.Sub_Type__c)) && !newCase.Status.contains('Closed') && Label.Checker_Queue_Regions.contains(newCase.Case_Country__c) &&  newCase.recordtypeid == externalCaseRTId && newCase.Case_Channel__c == 'E-mail' &&
                           (newCase.AI_Recommendation_Status__c == 'Resolution Recommended' || (newCase.AI_Recommendation_Status__c != 'Resolution Recommended' && String.valueOf(oldCase.OwnerId).startsWith('00G')))){
                               mapOfCasesLatestRecomm.put(newCase.Id,newCase);
                           }

                        //SC-10138: lst cases for auto closure
                        if(newCase.CreatedById =='005D00000041R4YIAU' && newCase.Type == 'Non-Case' && newCase.Status!='Closed Not-a-case' &&  newCase.recordtypeid == externalCaseRTId && newCase.Product__c !='Ocean' && (newCase.Type != oldCase.Type ||  oldCase.recordtypeid != oldCase.recordtypeid || newCase.Product__c !=oldCase.Product__c || newCase.Status != oldCase.Status )){
                            system.debug('lst getting populated');
                            lstAutocloseCase.add(newCase);
                    	}
                        
                        //SC-10204
                        if(newCase.RecordTypeId == externalCaseRTId && newCase.OwnerId != oldCase.OwnerId && String.valueOf(newCase.OwnerId).startsWith('00G')){
                            caseOwnerIdsForBAAddress.add(newCase.OwnerId);
                            caseListForBAAddress.add(newCase);
                        }
                    }
                    
                    //SC-8816 - Update to Blank
                    if(newCase.RecordTypeId == claimRTId && !String.isEmpty(newCase.Compound_Index_for_BoL_Number__c) && (newCase.Status == 'Triaged' || newCase.Sub_Type__c != 'Damage/Loss of Cargo' || closedStatuses.contains(newCase.Status))){
                        caseListToUpdateBlankBolNo.add(newCase);
                    }
                    
                    //SC-8816 - Update for ISR cases
                    if((oldCase == null || newCase.RecordTypeId != oldCase.RecordTypeId || newCase.Collaboration_Reason__c != oldCase.Collaboration_Reason__c || newCase.BoL_Number__c != oldCase.BoL_Number__c || newCase.Direction__c != oldCase.Direction__c || newCase.Country__c != oldCase.Country__c)
                       && newCase.RecordTypeId == isrrtid && newCase.Collaboration_Reason__c == 'AFR Closure' && newCase.IsCloned__c == false && System.now() > General_Settings__c.getInstance().Bol_Date_for_ISR__c){
                           caseListToUpdateISRBolNo.add(newCase);
                           if(!String.isEmpty(newCase.Country__c)){
                               countryIdSetToUpdateISRBolNo.add(newCase.Country__c);
                           }
                       }
                    
                    //SC-8816 - Update Subject
                    if(String.isEmpty(newCase.Subject) && (!String.isEmpty(newCase.AccountId) || !String.isEmpty(newCase.ContactId)) && (String.isEmpty(newCase.SuppliedEmail) || newCase.Case_Channel__c == 'Portal' || newCase.Case_Channel__c == 'Chat' || newCase.Case_Channel__c == 'WhatsApp')){
                        caseListToUpdateSubject.add(newCase);
                    }
                    //SC-8816 - update Portal on behalf
                    if((newCase.RecordTypeId == externalCaseRTId || newCase.RecordTypeId == claimRTId) && (!String.isEmpty(newCase.AccountId) || !String.isEmpty(newCase.ContactId)) && (String.isEmpty(newCase.Portal_On_Behalf_Of__c) || (oldCase != null && (newCase.AccountId != oldCase.AccountId || newCase.ContactId != oldCase.ContactId)))){
                        caseListToUpdatePortalOnBehalf.add(newCase);
                    }
                    //SC-8816 - update Product, Product Category & Claim Activity
                    if(newCase.RecordTypeId == claimsRecoveryRTId && newCase.ParentId != null){
                        caseListToUpdateProductClaimActivity.add(newCase);
                        parentIdSet.add(newCase.ParentId);
                    }
                    
                    //SC-9008 - Move Time spend in Main Queue logic to apex from batch 
                    if(oldCase != null && oldCase.OwnerId != null && newCase.RecordTypeId == externalCaseRTId && oldCase.OwnerId != newCase.OwnerId && newCase.Case_Channel__c == 'E-mail' && (newCase.Time_spent_in_Main_Queue_BH__c == null || newCase.Time_spent_in_Main_Queue_BH__c == 0) && String.valueOf(oldCase.OwnerId).startsWith('00G')){
                        if(String.valueOf(newCase.OwnerId).startsWith('005')){
                            if(newCase.QueueOwnerChangetime__c == null){
                                mapUpdateBHtime.put(newCase.id,'QueueOwnerChangetimeIsNull');
                            }
                            else{
                                mapUpdateBHtime.put(newCase.id,'HasQueueOwnerChangeTime');
                            }
                        }
                        else if(String.valueOf(newCase.OwnerId).startsWith('00G')){
                            if(newCase.QueueOwnerChangetime__c == null){
                                mapCalculateBHtime.put(newCase.id,'QueueOwnerChangetimeIsNull');  
                            }
                            else{
                                mapCalculateBHtime.put(newCase.id,'HasQueueOwnerChangeTime'); 
                            }
                        }
                    }
                }
                
                else if(casTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER) {
                    if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                        //Twill case automation for translation
                        if(newCase.Case_Channel__c == 'Website' &&
                            deliveryChannel!=null && newCase.Delivery_Channel__c!=null &&
                            deliveryChannel.containsignorecase(newCase.Delivery_Channel__c) &&
                            (String.isBlank(newCase.Language)  ||(newCase.Language!=null && //either language is null or its not english
                                                !newCase.Language.contains('en_US'))
                            )&&
                            !String.isBlank(newCase.Description))
                        {
                            twillCaseMap.put(newCase.Id,newCase);
                        }
                        
                        //SC-1126  all cases with shipment number  
                        //SC-1584 : Update Delivery Channel based on Shipment Number only if Delivery Channel is blank                      
                        if(!string.isBlank(newCase.Shipment_Number__c)){
                            caseswithShipmentNumber.add(newCase);
                        }
                        //SC-8989
                        if(newCase.RecordTypeId == externalCaseRTId && newCase.Case_Channel__c == 'E-mail' && newCase.EntitlementId != null && newCase.Status != 'New') {
                            setCaseIdsToUpdateMilestones.add(newCase.Id);
                        }
                        if(newCase.RecordTypeId == claimRTId) {
                            if(!String.isBlank(newCase.Liner_Brand__c) && !BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.HAMBURGSUD).contains(newCase.Liner_Brand__c)){ //bypass GCSS for Hamburg sud
                                if(newCase.BoL_Number__c != null) {
                                    lstClaimsforGCSSIntgtn.add(newCase);   
                                }
                            }
                        }
                        
                        // RQ-005373 - Remember cases will be created by ESB Interface user during failover scenarios.
                        // IIP - 149 - Import Manifest Case - Auto Update
                        // v1.7: RQ-003805 - Fire auto response rules for cases created from portal.
                        // SC-2406 : For the Cases from Twill Portal Only Assignmentment Rule need to be fired. Autoresponse rule shouldn't be fired. 
                        // SC-2350 : Checks if current user has Portal_Web_To_Case_Creation custom permission & removes empty string check on Reason_For_Case__c field (added as part of Web To Case API Design Change).
                        // SC-6711 : Extend Twill Cases for Channel = Website as well
                        if((newCase.Case_Channel__c == 'Portal' || newCase.Case_Channel__c == 'Website') && (newCase.Reason_For_Case__c == Label.WorkFlow_Request_Portal_RFC || newCase.Delivery_Channel__c == 'MaerskGo') && (StaticFactory.isCommunityUser() || currentUser.Profile.Name == 'Integration User' || FeatureManagement.checkPermission(CUSTOM_PERMISSION_PORTAL_CASE_CREATION)) ) {
                            setCaseIdsToSetDMLOptionsAW.add(newCase.Id); 
                        }
                        else if(newCase.Case_Channel__c == 'Portal' && newCase.Reason_For_Case__c != Label.WorkFlow_Request_Portal_RFC && newCase.Delivery_Channel__c != 'MaerskGo' && (StaticFactory.isCommunityUser() || currentUser.Profile.Name == 'Integration User' || FeatureManagement.checkPermission(CUSTOM_PERMISSION_PORTAL_CASE_CREATION))){
                            setCaseIdsToSetDMLOptions.add(newCase.Id);
                        }
                        
                        //RQ-009910 - Fire Auto response rules for MyFinance Dispute cases and OHP Disputes cases.
                        if(newCase.Case_Channel__c == 'MyFinance' && newCase.Type == 'Charges, Invoice & Payment' && newCase.Sub_Type__c == 'Dispute' && newCase.ParentId == null && currentUser.Name =='ESB Interface') {
                            setCaseIdsToSetAutoResponseOptions.add(newCase.Id); 
                        }
                        
                        
                        // #RQ-006949. Collects all the cases which are resolved and have a resolutionm summary.
                        // #RQ-007488 - Pro Active Cases must not send an auto-closure
                        // #RQ-011720 . CSAT Exclution for EMR 3rd party Invoice Disputes
                        // #RQ-011816 - Enabled case closure email for dispute case record type. External cases with disupte sub type will be excluded as existing.
                        
                        if(newCase.RecordTypeId == externalCaseRTId && newCase.Status == 'Closed - Resolved' && !Label.Survey_Channels_Excluded.Contains(newCase.Case_Channel__c) && newCase.Resolution_Summary__c != null && newCase.Sub_Type__c != 'Dispute' && newCase.Reason_For_Case__c !='EMR 3rd Party Invoice Disputes' && newCase.ContactId != null && newCase.Send_Case_Closure__c == 'Yes' ) {                            
                            mapCasesForClosureNotification.put(newCase.Id, newCase);                             
                        }
                        
                        
                        //SC-2183 - To get newly inserted Cases for OHP Dispute Integration
                        //SC-5744 - added filter to prevent integration call from Maersk LnS brand 
                        if(newCase.RecordTypeId == disputeRTId &&  newCase.Liner_Brand__c != BrandUtilities.MAERSKLS && currentUser.Name != 'EMP Interface') {                           
                            mapCasesToPublish.put(newCase.Id,new EventTypeWrapper('Create', 'Case_Event'));  //SC-9978
                        }
                        
                        Boolean isInternalDomain = CaseRecordSelector.checkInternalContactDomain(newCase);
                        if(newCase.RecordTypeId == externalCaseRTId && (newCase.Case_Channel__c == 'E-mail' || newCase.Case_Channel__c == 'Portal') && (!isInternalDomain) && newCase.Case_Country__c != Null && newCase.Description != Null && newCase.Liner_Brand__c != BrandUtilities.MAERSKLS && newCase.Closure_Language_Code__c !=Null && String.isNotBlank(newCase.Origin)){
                            lstCasesForSentiment.add(newCase);  
                        }
                        
                        //SC-4185 - Get the list of cases for which the custom classification auto-update should happen 
                        //SC-6639 Added filter for Brand != MaerskL&S OR Brand = MaerskL&S AND Product = SCM 
                        //SC-7133 Implement LNS Case Classification Model
                        //SC-8310 Adding filter for products to not perform auto classification
                        //Added filter for Type to not perform auto classification as part of Artemis
                        if(newCase.RecordTypeId == externalCaseRTId && newCase.Case_Channel__c == 'E-mail' && String.isNotBlank(newCase.Origin) && String.isNotBlank(newCase.Subject) && String.isNotBlank(newCase.Description) && String.isNotBlank(newCase.Liner_Brand__c) && (prodExcList.isEmpty() || (!prodExcList.isEmpty() && newCase.SF_4PL_Account__c != 'Nvidia' && !prodExcList.contains(newCase.Product__c)))
                           && (!originArtemisGE.isEmpty() && !originArtemisGE.contains(newCase.Origin))){
                               csListForCustomCC.add(newCase);
                           }
                        
                        //SC-4859 - Get the list of 4PL cases for sharing. Moved ISR to next If as part of SC-7243
                        //SC-8818 - Added condition to exclude sharing MC Restricted External cases to 4PL groups
                        if((newCase.RecordTypeId == externalCaseRTId) && newCase.Case_Channel__c != Label.CaseChannelPortal && newCase.Multi_Carrier_Restricted_Account__c==NULL) {
                            set4PLExtrnlCaseIds.add(newCase.Id);
                        }
                        //SC-7243 - ONly ISR records
                        //SC-8818 Added Condition to exclude Cases with MC Restrcited Visibility to 4PL groups
                        if((newCase.RecordTypeId == isrrtid) && newCase.Case_Channel__c != Label.CaseChannelPortal && !(newcase.Resolver_Dept__c.contains('SCM (Restricted):') && newCase.Requestor_Dept__c.contains('Multi Carrier (Restricted)'))) {
                            set4PLISRCaseIds.add(newCase.Id); 
                            lst4PLISRCasesForShare.add(newCase);
                        }
                        
                        //SC-5492 - Get Portal cases for 4PL sharing
                        if((newCase.RecordTypeId == externalCaseRTId || newCase.RecordTypeId == isrrtid) && newCase.Case_Channel__c == Label.CaseChannelPortal) {
                            set4PLCaseIdsPortal.add(newCase.Id); 
                        } 
                        //#RQ-012315. To get the Owner Ids
                        if(!String.valueOf(newCase.ownerId).startsWith('00G')){
                            lstOwnerIds.add(newCase.ownerId);
                            caseOwnerIDSCMKC.add(newCase.ownerId);
                        }
                        
                        //SC-7661 SONumber and OBA Populate 
                        General_Key_Value_Configurations__mdt originValues = General_Key_Value_Configurations__mdt.getInstance('IDAOriginFieldCriteria');                     
                        if(newCase.RecordTypeId == externalCaseRTId && newCase.Product__c == 'SCM' && newCase.case_channel__c == 'E-mail' && !String.isEmpty(newCase.Origin) && ((newCase.Origin.startsWith('SCM') && newCase.Origin.endsWith('SVC') && originValues.First_Field_Value__c == 'True' ) ||( originValues.First_Field_Value__c == 'False' && originValues.Second_Field_Value__c.contains(newCase.Origin)))){ 
                            idaCaseslist.add(newCase); 
                        } 
                        lstCasesInscope = lstCases;
                        //SC-8358
                      //SC-8651 Enabled omni for portal twill
                        if(String.isnotblank(newCase.Case_Channel__c) && (newCase.Case_Channel__c == Label.CaseChannelPortal || newCase.Case_Channel__c == 'Website') && !(string.isnotblank(newcase.Delivery_Channel__c) && newcase.delivery_channel__c == 'MaerskGo' && newCase.Cluster_CSCE__c == True)) {
                            if(!omniPortalOriginList.isempty() && string.isnotblank(newCase.liner_brand__c) && string.isnotblank(newCase.Country__c) && string.isnotblank(newCase.Direction__c) && omniPortalOriginList.contains(newCase.liner_brand__c+newCase.Country__c+newCase.Direction__c)){
                                lstPortalCasesToOmniRoute.add(newCase);
                            }
                            else if(string.isnotblank(newCase.Delivery_Channel__c) && newCase.Delivery_Channel__c == 'MaerskGo'){
                                lstPortalCasesToOmniRoute.add(newCase);
                            }
                        }
                        //Update Last Meaningful Activity
                        if(newCase.RecordTypeId == isrrtid && newCase.ParentId != null){
                            lastMeaningfulActCaseIdSet.add(newCase.ParentId);
                        }
                        
                        //SC-8791
                        //formimg data for artemisCasesMap
                        //SC-8791
                        if(newCase.Artemis_Id__c != null || newCase.Resolver_Dept__c =='Ocean: Finance - Account Receivables' || (String.valueOf(newCase.ownerId).startsWith('00G') && !artemisQueueIds.isEmpty() && artemisQueueIds.contains(newCase.OwnerId))) {
                            artemisCasesMap.put(newCase, null);
                        }
                        
                        //SC-9293
                        if(newCase.ParentId != null){
                            caseListForFeedItem.add(newCase);
                        }
                        
                        //SC-9291
                        if(newCase.RecordTypeId == externalCaseRTId && newCase.Case_Channel__c == 'E-mail' && (UserInfo.getUserName().contains('system.owner@maersk.com') || Test.isRunningTest()) && originsSet.contains(newCase.Origin) && !newCase.Autohandshake_Opt_Out__c){
                            caseListForHandshake.add(newCase);
                        }
                        
                        //SC-10137
                        if(newCase.RecordTypeId == isrrtid && newCase.ParentId != null){
                            isrParentCaseSet.add(newCase.ParentId);
                        }
                        
                    }
                    // RQ-001360 - Added this block to store the Case IDs when there is an update on Case Status
                    else if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {                        
                        //SC-8651
                        String skipOmniReRoutingForQueue = General_Key_Value_Configurations__mdt.getInstance('skipOmniReRoutingForQueue').First_Field_Value__c;                        
                        //SC-8822
                        if((oldCase.shipment_number__c != newCase.shipment_number__c) && (newCase.case_channel__c == 'E-mail' || newCase.case_channel__c == 'Portal')){
                            //SC-9159
                            Case cs = CaseFieldPopulator.validateShipmentNumber(newCase);
                            if(cs != null){
                                validShipmentnumberCases.add(cs);
                            }
                        } //SC-8822  
                        //NBA-Cases to retrieve Recommendations - to call deleteCaseRecommendation method
                        if(newCase.recordtypeId == externalCaseRTId  &&  newCase.Case_Channel__c == 'E-mail' && (newCase.Type <> oldCase.Type || newCase.Sub_Type__c <> oldCase.Sub_Type__c || newCase.Reason_For_Case__c <> oldCase.Reason_For_Case__c || newCase.Product__c <> oldCase.Product__c )){  //SC-9056: added RFC condition to consider RFC for NBA recommendation  
                            //removing status as we need to make callout on Classification change || newCase.Status <> oldCase.Status                       
                            caseRecommendationList.add(newCase);                         
                        }
                        
                        // #RQ-006949. Collects all the cases which are resolved and have a resolutionm summary.
                        // #RQ-007488 - Pro Active Cases must not send an auto-closure.Internal maersk contacts should be excluded from 
                        // #RQ-011720 . CSAT Exclution for EMR 3rd party Invoice Disputes
                        // #RQ-011816 - Enabled case closure email for dispute case record type. External cases with disupte sub type will be excluded as existing.
                        if(newCase.RecordTypeId == externalCaseRTId && newCase.Status != oldCase.Status && newCase.Status == 'Closed - Resolved' && !Label.Survey_Channels_Excluded.Contains(newCase.Case_Channel__c) && newCase.Resolution_Summary__c != null && newCase.Sub_Type__c != 'Dispute' && newCase.Reason_For_Case__c !='EMR 3rd Party Invoice Disputes' && newCase.ContactId != null && newCase.Send_Case_Closure__c == 'Yes' ) {                            
                            mapCasesForClosureNotification.put(newCase.Id, newCase);
                        }
                        
                        //SC-9138 new variable to run for kpis calculation for AI gen 1 req when Case is Ocean and AI Related fields are not updated 
                        if(newCase.RecordTypeId == externalCaseRTId && newCase.Status == 'Closed - Resolved' &&  newCase.Resolution_Summary__c != null && newCase.Case_Channel__C == 'E-mail' && newCase.Product__c == 'Ocean' && Label.IDACountryFieldCriteriaEmailRecommendation.containsIgnoreCase(newCase.Case_Country__c) && newCase.ART_with_Email_Recommendations__c == null && newCase.ContactId != null) {                            
                            mapCasesToUpdateKPIsForAI.put(newCase.Id, newCase);      
                            setAiResponseCreatorId.add(newCase.lastModifiedById);                      
                        }
                        
                        //#SC-147.As now we have only Triage milestone, the milestone will be completed as soon as the status is changed from "New" to any other status.
                        //SC-8989
                        if(newCase.RecordTypeId == externalCaseRTId && newCase.Case_Channel__c == 'E-mail' && newCase.EntitlementId != null && oldCase.Status == 'New' && newCase.Status != oldCase.Status) {
                            setCaseIdsToUpdateMilestones.add(newCase.Id);
                        }
                        
                        // V4.0 : RQ-004667 ##RQ-009034. Added Dispute record type also.
                        if(newCase.ParentId != null && newCase.Case_Channel__c != 'Proactive' && (newCase.RecordTypeId == externalCaseRTId || newCase.RecordTypeId == disputeRTId)  && setMergedStatuses.contains(newCase.Status) && !setMergedStatuses.contains(oldCase.Status)) {
                            setParentCaseId.add(newCase.ParentId);
                            setChildCaseId.add(newCase.Id);
                        }
                        
                        // #RQ-008020 Notification on Closed ISR
                        if(newCase.RecordTypeId == isrrtid && newCase.Status != oldCase.Status && (newCase.Status == 'Closed - Resolved' || newCase.Status == 'Closed - Merged' || newCase.Status == 'Closed - Duplicate' ))
                        {
                            mapISRClosurePost.put(newCase.Id, newCase);
                        }
                        
                        //#RQ-008547 Case Assignment Notification
                        
                        if(!string.valueOf(newCase.OwnerId).startsWith('00G') && newCase.OwnerId != userinfo.getUserId() && newCase.OwnerId  != oldCase.OwnerId )
                        {
                            mapCaseownerUpdated.put(newCase, newCase.OwnerId);
                        }
                        
                        // RQ-007915 - To store the dispute cases IDs on closure
                        // RQ-009662 - Consider only for Closed-Resolved status
                        if(newCase.RecordTypeId == disputeRTId && newCase.Status != oldCase.Status && newCase.status == 'Closed - Resolved' && newCase.ParentId != null) {                            
                            setDisputeClosureCases.add(newCase.Id);    
                            
                        }
                        //#RQ-012315. To get the Owner Ids
                        if(newCase.Status != oldCase.Status && newCase.status == 'Closed - Resolved'){
                            lstOwnerIds.add(newCase.ownerId); 
                        }
                        //SC-2183 - To get Cases with recordtype changed to Dispute or Dispute cases with inbound email for OHP Dispute Integration 
                        //SC-5744 - added filter to prevent integration call from Maersk LnS brand                       
                        if(newCase.RecordTypeId == disputeRTId && newCase.Liner_Brand__c != BrandUtilities.MAERSKLS && (newCase.RecordTypeId != oldCase.RecordTypeId) && currentUser.Name != 'EMP Interface') {                           
                           mapCasesToPublish.put(newCase.Id,new EventTypeWrapper('Create', 'Case_Event'));  //SC-9978
                        }
                        
                        //SC-5543 - To get Dispute Cases with owner changed to Dispute Queue for OHP Dispute Integration                        
                        //SC-5744 - added filter to prevent integration call from Maersk LnS brand                       
                        if(newCase.RecordTypeId == disputeRTId && oldCase.OwnerId != newCase.OwnerId && newCase.Liner_Brand__c !='Maersk L&S' && newCase.OwnerId == Label.Global_Dispute_Queue && currentUser.Name != 'EMP Interface') {                           
                           mapCasesToPublish.put(newCase.Id,new EventTypeWrapper('Create', 'Case_Event'));  //SC-9978
                        }
                        //SC-4859 - Get the list of 4PL cases for 4pl sharing. Moved ISR to next If as part of SC-7243
                        //SC-8818
                        if(newCase.RecordTypeId == externalCaseRTId && (oldCase.SF_4PL_Account__c != newCase.SF_4PL_Account__c || newCase.Case_Visibility__c !=  oldCase.Case_Visibility__c || newCase.RecordTypeId != oldCase.RecordTypeId ) && newCase.Case_Channel__c != Label.CaseChannelPortal && newCase.Multi_Carrier_Restricted_Account__c==NULL){
                            set4PLExtrnlCaseIds.add(newCase.Id); 
                        }//SC-5371
                        else if(newCase.RecordTypeId == externalCaseRTId && (oldCase.OwnerId != newCase.OwnerId||oldCase.ContactId != newCase.ContactId||oldCase.AccountId !=newCase.AccountId) && newCase.Case_Channel__c != Label.CaseChannelPortal && newCase.Multi_Carrier_Restricted_Account__c==NULL ){
                            set4PLChngeIdsExtrnl.add(newCase.Id); 
                        }
                        //SC-7243
                        //SC-8818
                        if(newCase.RecordTypeId == isrrtid && (oldCase.SF_4PL_Account__c != newCase.SF_4PL_Account__c || oldCase.OwnerId != newCase.OwnerId  || newCase.Case_Visibility__c !=  oldCase.Case_Visibility__c || newCase.RecordTypeId != oldCase.RecordTypeId ) && newCase.Case_Channel__c != Label.CaseChannelPortal && !(newcase.Resolver_Dept__c.contains('SCM (Restricted):') && newCase.Requestor_Dept__c.contains('Multi Carrier (Restricted)'))){
                            set4PLISRCaseIds.add(newCase.Id); 
                            lst4PLISRCasesForShare.add(newCase);
                        }
                        
                        //SC-5492 - Get the list of portal cases for 4pl sharing
                        if((newCase.RecordTypeId == externalCaseRTId || newCase.RecordTypeId == isrrtid) && (oldCase.SF_4PL_Account__c != newCase.SF_4PL_Account__c || newCase.Case_Visibility__c !=  oldCase.Case_Visibility__c || newCase.RecordTypeId != oldCase.RecordTypeId) && newCase.Case_Channel__c == Label.CaseChannelPortal){
                            set4PLCaseIdsPortal.add(newCase.Id); 
                        }
                        
                        //SC-5371
                        if((newCase.RecordTypeId == externalCaseRTId || newCase.RecordTypeId == isrrtid) && (oldCase.OwnerId != newCase.OwnerId||oldCase.ContactId != newCase.ContactId||oldCase.AccountId !=newCase.AccountId) && newCase.Case_Channel__c == Label.CaseChannelPortal){
                            set4PLChngeIdsPortal.add(newCase.Id); 
                        }
                        
                        //SC-4374
                        if(newCase.ownerId!=Null){
                            caseOwnerID.add(newCase.ownerId); 
                        }                        
                        
                        //SC-8274 - if new owner is a Queue then retrigger Omni logic  
                        //SC-8651 Added condition to skip omni re-routing for twill HQ Cargo Flow Queue
                        //SC-8651 Added condition to skip omni re-routing for twill HQ Cargo Flow Queue
                        if(string.isnotblank(newCase.ownerId) && oldCase.ownerId != newCase.ownerid && string.isnotblank(newCase.Case_Channel__c) && (newCase.Case_Channel__c == 'E-mail' ||((newCase.Case_Channel__c == 'Portal' || newCase.Case_Channel__c == 'Website') && !omniPortalOriginList.isempty() && string.isnotblank(newCase.liner_brand__c) && string.isnotblank(newCase.Country__c) && string.isnotblank(newCase.Direction__c) && omniPortalOriginList.contains(newCase.liner_brand__c+newCase.Country__c+newCase.Direction__c))) && String.valueOf(newCase.ownerId).startsWith('00G')  
                           && !skipOmniReRoutingForQueue.contains(newCase.ownerid) && !(string.isnotblank(newcase.Delivery_Channel__c) && newcase.delivery_channel__c == 'MaerskGo' && newCase.Cluster_CSCE__c == True)){  
                               if(!ownerSkillmap.isEmpty() && ownerSkillmap.ContainsKey(newCase.ownerId)){
                                   listCasesOwnerChangeForOmni.add(newCase);      
                               }//SC-10076
                               else if(!String.isBlank(newCase.Omni_Skill_Type__c)){
                                   caseOmniSkillUpdateList.add(newCase);
                               }
                           }
                        //end of SC-8274
                        // SC-8791 Create List of Closed ISR Cases
                        if(newCase.RecordTypeId == isrrtid && newCase.Status != oldCase.Status && newCase.isClosed == true)
                        {
                            isrClosedCaseList.add(newCase);
                        }
                        //SC-8791
                        //formimg data for artemisCasesMap
                        if(newCase.Artemis_Id__c != null || newCase.Resolver_Dept__c =='Ocean: Finance - Account Receivables' || (String.valueOf(newCase.ownerId).startsWith('00G') && !artemisQueueIds.isEmpty() && artemisQueueIds.contains(newCase.OwnerId))) {
                            artemisCasesMap.put(newCase, oldCase);
                        }
                        //SC-8791
                        if(newCase.recordTypeId == disputeRTId || (newCase.IsCloned__c == true && newCase.ParentId != null && oldCase.ParentId != newCase.ParentId)) {
                            
                            dispCasesOnEmailTrigCondition.put(newCase, oldCase);
                        }
                        // SC-8791 
                        if(string.isNotBlank(newCase.Contactid)){
                            string contactEmail = staticfactory.getrelatedContactEmail(newCase.Contactid);   
                            if(string.isNotBlank(contactEmail)){
                                if(newCase.Number_Of_Public_Case_Comments__c!=oldCase.Number_Of_Public_Case_Comments__c &&  oldCase.Number_Of_Public_Case_Comments__c < newCase.Number_Of_Public_Case_Comments__c){
                                    mapCasesforemailalerts.put(newCase.id,newCase.id);
                                }
                            }
                        }  
                    }
                    
                    // SC-8791 for case escalation
                    if((newcase.RecordTypeId == externalCaseRTId || newcase.RecordTypeId==isrrtid|| newcase.RecordTypeId == disputeRTId) && newcase.IsEscalated == TRUE && !String.isEmpty(newcase.OwnerId) && String.valueOf(newcase.OwnerId).startsWith('005') && (oldCase == null || oldCase.IsEscalated == false)){                   
                        caseEscalationSendEmailAlertsList.add(newcase);
                    }
                }
                // RQ-002679 End
            }
        }
        
    }
    
    /** 
    * @description | get case related records
    * @param lstCases accepts case list
    * SC-9161
    */
    public void getRelatedRecords(list<Case> lstCases) {
        getRelatedAccounts();
        getRelatedContacts();
        getRelatedCases();
        getRelatedLBDCs();
        getRelatedGeoData();
        getRelatedUserCountry();// RQ-007865 
        getMapCountryNameId();// RQ-007865 
        getCaseOwnerEligibility();//RQ-008547
        getEmailTemplateMapping();//RQ-008620
        //getmapOwnerDetails();//RQ-012315 // Commented as part of SC-495
        getRelatedCareRelationship();//SC-4212 
        getRelatedUserRole();
        getRelatedSCMKC();
        getExcludedOrigin();
        getOmniOriginsList(); // SC-8700-Move Omni origins from Custom label to Custom metadata
        getomniPortalOriginList(); //8358
        getSCMRestrictedOrigins();
        
    }
    
    /** 
    * @description | Retrieve related Accounts
    * SC-9161
    */
    public void getRelatedAccounts() {
        if(!setAccountIds.isEmpty()) {
            mapRelatedAccounts = new map<Id, Account>([select Id, Name, SCV_Code__c, ParentId,Value_Proposition__c, Damco_BE_Code__c,  LS_CM_SCM_Supplier__c, BillingCity, Country__c, Country__r.Name, Cluster_Name__c, Cluster_Name__r.Name, Cluster_Name__r.Parent_BDA__r.Parent_BDA__c, Cluster_Name__r.Parent_BDA__r.Parent_BDA__r.Name, Vendor_Code__c, Vendor_Type__c, RecordTypeId from Account where Id in :setAccountIds]);
        }
    }
    
    /** 
    * @description | Retrieve related Contacts
    * SC-9161
    */
    public void getRelatedContacts() {
        if(!setContactIds.isEmpty() || !setSuppliedEmails.isEmpty()) {
            mapRelatedContacts = new map<Id, Contact>([select Id, Name, AccountId, Account.Name, Account.SCV_Code__c, Email, CSAT_Opt_Out__c, Auto_Notification_Opt_Out__c, Deduped_Contact__c, Liner_Brands__c, IsDuplicate__c, RecordTypeId, RecordType.Name, Preferred_Language__c,IsEmailBounced,MailingCity,Country__c,SCM_on_behalf_of__c from Contact where Id in :setContactIds or Email in :setSuppliedEmails ORDER By Email, RecordTypeId, Deduped_Contact__c Desc]);
        }
    }
    public void getRelatedGeoData() {
        if(!setCountryIds.isEmpty()) {
           mapRelatedGeography = new map<Id, Geography__c>([select Id,GEO_ID__c, Name  from Geography__c where Id in :setCountryIds]);
        }
    }
    
    /** 
    * @description | Get the related care relationship
    * SC-9161
    */
    public void getRelatedCareRelationship(){
        if(!setCareRelationshipIds.isEmpty()) {
            mapRelatedCareRelation = new map<id, Care_Relationship__c>([select Id, Care_Business_Partner__c,GSC_Agent__c,Frontline_backup__c, GSC_Backup_Agent__c from Care_Relationship__c where Id in: setCareRelationshipIds]);   
        }
    }
    
    public void getRelatedKeyClient(){
        if(!setKeyClientIds.isEmpty()) {
            mapKeyClient = new map<id,Client_Case_Assignments__c>([select id, Active__c,Account__c, Direction__c,Country__c,Dedicated_Agent__c,Back_up_Dedicated_Agent__c from Client_Case_Assignments__c where Id in: setKeyClientIds]);   
        }
    }
    
    /** 
    * @description | Retrieve related Cases
    * SC-9161
    */
    public void getRelatedCases() {
        if(!setCaseIds.isEmpty()) {
            mapRelatedCases = new map<Id, Case>([select Id, Liner_Brand__c,SF_4PL_Account__c,Multi_Carrier_Restricted_Account__c, New_Mail__c from Case where Id in :setCaseIds]);
        }
    }
    
    /** 
    * @description | Case_Type_Sub_Type_Direction_Mapping__mdt records
    * @return | return Case_Type_Sub_Type_Direction_Mapping__mdt records
    * SC-9161
    */    
    public map<String, Case_Type_Sub_Type_Direction_Mapping__mdt> getMapTSD() {
        if(mapTSD == null || mapTSD.isEmpty()) {
            //SC-5414 metadata SOQl query to Static method call
            mapTSD = new map<String, Case_Type_Sub_Type_Direction_Mapping__mdt>();
            List<Case_Type_Sub_Type_Direction_Mapping__mdt> tsdLst = Case_Type_Sub_Type_Direction_Mapping__mdt.getall().values();
            for(Case_Type_Sub_Type_Direction_Mapping__mdt tsd : tsdLst) {
                String mapKey = tsd.Product__c + ':' + tsd.Type__c + ':' + tsd.Sub_Type__c;
                mapTSD.put(mapKey, tsd);
            }
        }
        return mapTSD;
    }
    
    /** 
    * @description | Retrieve related LinerBrand_Direction_and_Country__mdt records
    * SC-9161
    */
    public void getRelatedLBDCs() {
        if(mapLBDCs.isEmpty()) {
            mapLBDCs = CaseTrigger_DataSetUtilities.getAllCustomMetadataList();
        }
    }
    
    /** 
    * @description | Retrieve related SCM_Key_Client_Country_Mapping__mdt records
    * SC-9161
    */
    public void getRelatedSCMKC(){
        //SC-5414 metadata SOQl query to Static method call
        if(mapSCMKC.isEmpty()){
            Map<String, SCM_Key_Client_Country_Mapping__mdt> scmKCMap = SCM_Key_Client_Country_Mapping__mdt.getall();
            for(SCM_Key_Client_Country_Mapping__mdt scmKC : scmKCMap.values()) {
                mapSCMKC.put(scmKC.QueueId__c, scmKC);
                scmIndicatorToSCMKCMap.put(scmKC.SCM_KC_Indicator__c, scmKC);
                templateNames.add(scmKC.Template_Unique_Name__c);
                replyToEmailList.add(scmKC.Reply_To_Email__c);
            }
            if(mapAllSCMKC.isEmpty()){
                mapAllSCMKC = scmKCMap;
            }
        }
    }
    
    /** 
    * @description | Retrieve excluded origins for handshake & CSAT
    * SC-9161
    */
    public void getExcludedOrigin(){   
        //SC-7849 - Decouple CSAT and Handshake exclusion
        if(handshakeExcludedCaseOrigins.isEmpty()){
            for(General_Key_Value_Configurations__mdt gen : [Select Key__c, First_Field_Value__c From General_Key_Value_Configurations__mdt Where Key__c = 'ONLYAutoHandshakeExclusion']){
                if(!String.isEmpty(gen.First_Field_Value__c)){
                    handshakeExcludedCaseOrigins.addAll(gen.First_Field_Value__c.trim().split(','));
                }
            }
        }
        if(csatExcludedCaseOrigins.isEmpty()){
            for(General_Key_Value_Configurations__mdt gen : [Select Key__c, First_Field_Value__c From General_Key_Value_Configurations__mdt Where Key__c = 'ONLYCSATExclusion']){
                if(!String.isEmpty(gen.First_Field_Value__c)){
                    csatExcludedCaseOrigins.addAll(gen.First_Field_Value__c.trim().split(','));
                }
            }
        }
    }
    
    /** 
    * @description | Retrieve Omni origins from metadata
    * SC-9161
    */
    public void getOmniOriginsList(){
        if(omniOriginList.isEmpty()){
            for(General_Key_Value_Configurations__mdt gen : [Select Key__c, First_Field_Value__c From General_Key_Value_Configurations__mdt Where Key__c = 'OmniChannelOrigins']){
                if(!String.isEmpty(gen.First_Field_Value__c)){
                    omniOriginList.addAll(gen.First_Field_Value__c.trim().split(','));
                }
            }
        }
    }
    
    /** 
    * @description | Retrieve Artemis origins from metadata
    * SC-9161
    */
    public void getOriginArtemisGEList(){
        if(originArtemisGE.isEmpty()){
            for(General_Key_Value_Configurations__mdt gen : [Select Key__c, First_Field_Value__c From General_Key_Value_Configurations__mdt Where Key__c = 'ArtemisOrigin']){
                if(!String.isEmpty(gen.First_Field_Value__c)){
                    originArtemisGE.addAll(gen.First_Field_Value__c.replace(' ','').split(';'));
                }
            }
        }
    }
    
    /** 
    * @description | Retrieve SCM restricted origins from metadata
    * SC-9161
    */
    public void getSCMRestrictedOrigins(){
        if(scmRestrictedOrigins.isEmpty()){
            for(General_Key_Value_Configurations__mdt gen : [Select Key__c, First_Field_Value__c From General_Key_Value_Configurations__mdt Where Key__c = 'SCMRESTRICTED']){
                if(!String.isEmpty(gen.First_Field_Value__c)){
                    scmRestrictedOrigins.addAll(gen.First_Field_Value__c.trim().split(','));
                }
            }
        }
    }
    
    /** 
    * @description | Retrieve omni portal origins from metadata
    * SC-9161
    */
    public void getomniPortalOriginList(){
        if(omniPortalOriginList.isEmpty()){
            for(General_Key_Value_Configurations__mdt gen : [Select Key__c, First_Field_Value__c From General_Key_Value_Configurations__mdt Where Key__c = 'OmniChannelPortalOrigins']){
                if(!String.isEmpty(gen.First_Field_Value__c)){
                    omniPortalOriginList.addAll(gen.First_Field_Value__c.trim().split(','));
                }
            }
        }
    }
    
    /** 
    * @description | Get the related user and country name map 
    * SC-9161
    */
    public void getRelatedUserCountry() {   
        if(!mapCaseIdOwnerId.isEmpty()){        
            for(User userIterator :  [SELECT Id, Country FROM User WHERE Id IN : mapCaseIdOwnerId.values() ]){ 
                if(String.isNotBlank(userIterator.Country)){                                             
                    mapOwnerandCountry.put(userIterator.Id, userIterator.Country.toLowerCase()); 
                }                                                   
            }           
        }     
    }
    
    /** 
    * @description | Get the related user role
    * SC-9161
    */
    public void getRelatedUserRole() {  
        if(!caseOwnerID.isEmpty()){
            for(User userIterator : StaticFactory.getCaseOwnerDetails(caseOwnerId).values()){ 
                if(String.isNotBlank(userIterator.UserRole.Name)){                                             
                    mapOwnerandRole1.put(userIterator.Id, userIterator.UserRole.Name); 
                }                                                             
            }
        }
    }
    
    /** 
    * @description | Get the Country Name and id map
    * SC-9161
    */
    public void getMapCountryNameId(){
        list<Geography__c>  lstCountrygeoList = StaticFactory.getGetGeoListValues();
        for(Geography__c geo :lstCountrygeoList ){
            if(mapOwnerandCountry != null && String.isNotBlank(geo.Id) && mapOwnerandCountry.values().Contains(geo.Name.toLowerCase())){
                mapCountryNameId.put(geo.Name.toLowerCase(), geo.Id);
            }  
            mapCountryIdName.put(geo.Id, geo.Name);//#RQ-008620
            mapCountryNameCountryId.put(geo.GEO_ID__c,geo.Id);
        } 
    }
    
    /** 
    * @description | Case Assignment Notification
    * SC-9161
    */
    public void getCaseOwnerEligibility(){
        if(!mapCaseownerUpdated.isEmpty()){
            Map<id, user> mapuseroptin = new Map<id, user>([Select Id,Receive_Case_Ownership_Change__c from User Where Id IN : mapCaseownerUpdated.values()]);
            for(Case c: mapCaseownerUpdated.keyset()){
                if(mapuseroptin.get(c.Ownerid).Receive_Case_Ownership_Change__c == true){
                    mapCaseownerEligible.put(c.Id, c);
                }
            }
        }
    }
    
    /** 
    * @description | Get Email_Template_Mapping__mdt records
    * SC-9161
    */
    public void getEmailTemplateMapping(){
        for(Email_Template_Mapping__mdt emdt : [SELECT Id, Liner_Brand__c, Filter_1__c,Filter_2__c,Filter_3__c,Email_Rule__c,Additional_Language__c FROM Email_Template_Mapping__mdt WHERE Email_Rule__c = 'm0557000000KyoL']){
            //mapEmdts.put(emdt.Liner_Brand__c+emdt.Filter_1__c, emdt);
            mapEmdts.put(emdt.Liner_Brand__c+emdt.Filter_1__c+emdt.Filter_2__c, emdt);
        }        
    }
    
    /** 
    * @description | LinerBrand_Direction_and_Country__mdt records
    * @return | return LinerBrand_Direction_and_Country__mdt records
    * @param mapQueuOwnerCase accepts case queue map
    * SC-9161
    */
    public Static Map<String,LinerBrand_Direction_and_Country__mdt> getDataBasisOnOwner(map<String,Case> mapQueuOwnerCase){
        Map<String, LinerBrand_Direction_and_Country__mdt> mapQueueIdLBDCs = new Map<String, LinerBrand_Direction_and_Country__mdt>();
        
        //SC-5414 metadata SOQl query to Static method call
        List<String> lstQueueName = new List<String>();
        
        for(String str : mapQueuOwnerCase.keyset()){
            String strName = str.substring(0,str.indexof('_'));
            lstQueueName.add(strName);
        }
        
        // SC-390 - Added Case_Visibility__c field in the query.
        for(LinerBrand_Direction_and_Country__mdt lbdc : [select MasterLabel, Queue_Name__c, QueueId__c ,Cluster__c, Country__c, Direction__c, Liner_Brand__c, Business_Hours__c,Case_Visibility__c from LinerBrand_Direction_and_Country__mdt where QueueId__c in :lstQueueName ]) {
            mapQueueIdLBDCs.put(LBDC.QueueId__c, lbdc);
        }
        
        ///SC-5414 metadata SOQl query to Static method call
        if(mapSCMKC == null || mapSCMKC.size() == 0){
            CaseRecordSelector crsObj;
            crsObj.getRelatedSCMKC();
        }
        
        for(String queueIdSKCM : mapSCMKC.keySet()){
            if(lstQueueName.contains(queueIdSKCM)){
                SCM_Key_Client_Country_Mapping__mdt sckmTmp = mapSCMKC.get(queueIdSKCM);
                LinerBrand_Direction_and_Country__mdt lbdcTmp = LinerBrand_Direction_and_Country__mdt.getInstance(sckmTmp.Relation_to_LBDC_metadata__c);
                //created this clone to avoid read only error
                LinerBrand_Direction_and_Country__mdt lbdc = lbdcTmp.clone(true);
                lbdc.Id = lbdcTmp.Id;
                //Get the country geo id form SKCC metadata itself as in LBDC global BA the value will be blank
                lbdc.Country__c = sckmTmp.Country__c;
                //SC-7708 - Get the Direction form SKCC metadata itself for Direction Specific BA's
                system.debug('sckmTmp.Direction__c ##'+sckmTmp.Direction__c);
                if(sckmTmp.Direction__c <> null || sckmTmp.Direction__c <> '') {
                    system.debug('Inside Id ###');
                    lbdc.Direction__c = sckmTmp.Direction__c;
                }
                mapQueueIdLBDCs.put(sckmTmp.QueueId__c, lbdc);
            }
        }
        
        return mapQueueIdLBDCs;      
    }
    
    /** 
    * @description | checkActivityReference
    * @param newMap accepts case map
    * @param mapOldCases accepts case old map
    * SC-9161
    */
    public void checkActivityReference(map<Id, Case> newMap, map<Id, Case> mapOldCases){
        Map<String, Schema.FieldSet> fsMap = Schema.SObjectType.Activity_Related_Reference__c.fieldSets.getMap();
        Id claimRTId = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get(Label.Claim).getRecordTypeId();
        List<String> statusList = Label.LNS_ARR_Status.split(',');
        String oceanProduct = Label.Ocean_Product;
        
        List<Activity_Related_Reference__c> activityRefList = new List<Activity_Related_Reference__c>();
        Map<Id,Activity_Related_Reference__c> caseIdARRMap = new  Map<Id,Activity_Related_Reference__c>();               
        
        if(mapOldCases != null){
            activityRefList = [SELECT Id,Case__c,RAIL_Other_References__c,AIR_Carrier__c,AIR_Other_References__c,Container_ID__c,Facility_Incident_Record_Number__c,FCR_number_Rail_document_reference__c,Haulage_Reference_Transport_Order__c,Haulier__c,HAWB_Number__c,INTERNAL_Other_References__c,Item_Number__c,Maersk_B_L_Number__c,MAWB_Number__c,OCE_Carrier__c,Other_Carrier_B_L_Number__c,Railcar_Container_ID__c,RAIL_Operator__c,ROAD_Other_References__c,Service_description__c,Service_reference__c,Trailer_Container_ID__c from Activity_Related_Reference__c where case__c in :newMap.keySet()];
            for(Activity_Related_Reference__c arr:activityRefList ){
                caseIdARRMap.put(arr.Case__c,arr);
            }
        }   
        
        for (Id caseId : newMap.keyset()){
            
            if(mapOldCases == NULL ){
                if(newMap.get(caseId).RecordTypeId == claimRTId && statusList.contains(newMap.get(caseId).Status) && newMap.get(caseId).Claim_Activity__c <> NULL && oceanProduct != newMap.get(caseId).Product__c){
                    Case newCase = newMap.get(caseId);
                    if(newCase != null){
                        newCase.addError('Please ensure that Claim Activity is updated.Activity Related Reference should be updated before updating the status.');
                    }
                    
                } else if(newMap.get(caseId).RecordTypeId == claimRTId &&  mapOldCases == NULL && statusList.contains(newMap.get(caseId).Status) && newMap.get(caseId).Claim_Activity__c == NULL && oceanProduct != newMap.get(caseId).Product__c){
                    
                    Case newCase = newMap.get(caseId);
                    if(newCase != null){
                        newCase.addError('Please ensure that Claim Activity is updated.Activity Related Reference should be added before updating the status.');
                    }
                }
            }else{ 
                if(newMap.get(caseId).RecordTypeId == claimRTId && newMap.get(caseId).Type == 'Claim - L&S' && newMap.get(caseId).Status != mapOldCases.get(caseId).Status && statusList.contains(newMap.get(caseId).Status) && newMap.get(caseId).Claim_Activity__c <> NULL){ //SC-7347
                    if(caseIdARRMap.containsKey(caseId)){
                        //for(Activity_Related_Reference__c ar : activityRefList){
                        Activity_Related_Reference__c ar = caseIdARRMap.get(caseId);
                        Integer numberOfFieldsNotNull = 0;
                        
                        for(Schema.FieldSetMember f : fsMap.get(newMap.get(caseId).Claim_Activity__c.left(4).trim()).getFields()){
                            String fName = f.getFieldPath();
                            if(ar.get(fName) <> NULL){
                                numberOfFieldsNotNull =numberOfFieldsNotNull +1;
                            }
                        }
                        if(numberOfFieldsNotNull == 0){
                            Case newCase = newMap.get(caseId);
                            if(newCase != null){
                                newCase.addError('Please capture Activity Related References and the Claim Activity fields before updating the status.');
                            }
                        }
                        //}
                    } else {
                        Case newCase = newMap.get(caseId);
                        if(newCase != null){
                            newCase.addError('Please capture Activity Related References and the Claim Activity fields before updating the status.');
                        }
                    }
                    
                } else if(newMap.get(caseId).RecordTypeId == claimRTId && newMap.get(caseId).Type == 'Claim - L&S' && newMap.get(caseId).Status != mapOldCases.get(caseId).Status && statusList.contains(newMap.get(caseId).Status) && newMap.get(caseId).Claim_Activity__c == NULL) { //SC-7347
                    Case newCase = newMap.get(caseId);
                    if(newCase != null){
                        newCase.addError('Please capture Activity Related References and the Claim Activity fields before updating the status.');
                    }
                }
            }
        }
    }
    
    /** 
    * @description | check case contact internal domain
    * @return | check case contact internal domain
    * @param tCase accepts case
    * SC-9161
    */
    public static boolean checkInternalContactDomain(Case tCase){
        Boolean isInternalDomain = false;
        try{
            if(tCase.Contact_Email__c!=null) {        
                String domain = tCase.Contact_Email__c.split('@').get(1);
                set<String> setEmailDomains = new set<String>();
                //SC-5414 metadata SOQl query to Static method call
                List<Email_Domains_Excluded_From_Survey__mdt> emailDomainLst = Email_Domains_Excluded_From_Survey__mdt.getAll().values();
                
                for(Email_Domains_Excluded_From_Survey__mdt emailDomain : emailDomainLst) {
                    setEmailDomains.add(emailDomain.MasterLabel);
                    //SC-5415 merged to one for loop
                    if(domain.contains(emailDomain.MasterLabel)){
                        isInternalDomain = true;
                        break;
                    }
                } 
                
            }
            return isInternalDomain;
        }catch(Exception e){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseRecordSelector.checkInternalContactDomain', new list<Exception>{e});
            return isInternalDomain;
        }
    }
    
    /** 
    * @description | checkNBAActionStatusOnCaseClose
    * @param cseList accepts case case list
    * SC-9161
    */
    public void checkNBAActionStatusOnCaseClose(List<Case> cseList){
        Map<Id,List<Case_Recommendation__c>> avlcaseRecMap = new Map<Id,List<Case_Recommendation__c>>(); // to get actioned recommendations
        Map<Id,List<Case_Recommendation__c>> allcaseRecMap = new Map<Id,List<Case_Recommendation__c>>(); // to get all available recommendation
        Map<Id,List<Case_Recommendation__c>> viewcaseRecMap = new Map<Id,List<Case_Recommendation__c>>(); // to get actioned recommendations
        List<Id> cseIdList = new List<Id>();
        Set<Id> cseOwnerIdList = new Set<Id>();
        Set<Id> ownerInPSASet = new Set<Id>();
        Id externalCaseRTId = Label.External_Case_RT_Id;
        try{
            for(Case cse:cseList){
                cseIdList.add(cse.Id);
                cseOwnerIdList.add(cse.OwnerId);
                cseOwnerIdList.add(UserInfo.getUserId());
            }
            //added recordtype check as part of SC-8489
            for(Case_Recommendation__c cseRec : [SELECT Id,Case__c,Description__c,Priority__c,Action_Status__c,View_Details_Status__c,Show_View_Details_button__c,Recommendation_Name__c,Recommendation_Id__c,Rejected_Reason__c,Is_Valid__c from Case_Recommendation__c where Case__c in :cseIdList AND Is_Valid__c = true  and recordtype.name = 'NBA Recommendation']){                    
                if(cseRec.Action_Status__c <> null) {
                    if(avlcaseRecMap.containsKey(cseRec.Case__c)){
                        avlcaseRecMap.get(cseRec.Case__c).add(cseRec);
                    } else {
                        avlcaseRecMap.put(cseRec.Case__c,new List<Case_Recommendation__c>{cseRec});
                    }     
                }   
                
                if(cseRec.View_Details_Status__c == null && cseRec.Show_View_Details_button__c==true){ // SC-9056: Logic for handling the validation rule that View Details has to be clicked
                    if(viewcaseRecMap.containsKey(cseRec.Case__c)){
                        viewcaseRecMap.get(cseRec.Case__c).add(cseRec);
                    } else {
                        viewcaseRecMap.put(cseRec.Case__c,new List<Case_Recommendation__c>{cseRec});
                    }  
                }
                
                if(allcaseRecMap.containsKey(cseRec.Case__c)){
                    allcaseRecMap.get(cseRec.Case__c).add(cseRec);
                } else {
                    allcaseRecMap.put(cseRec.Case__c,new List<Case_Recommendation__c>{cseRec});
                }
            }
            
            if(cseOwnerIdList<> null && cseOwnerIdList.size()>0) {
                for(PermissionSetAssignment psa:[SELECT AssigneeId,PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId=:cseOwnerIdList AND PermissionSet.Name = 'Receive_NBA_Recommendations']){
                    ownerInPSASet.add(psa.AssigneeId);
                }
            }
            
            List<String> excludedEmailDomains = Label.ExcludedEmailDomains_for_NBA.toLowercase().Split(',');
            
            for(Case cse:cseList){ 
                if(cse.RecordTypeId == externalCaseRTId && cse.Case_Channel__c == 'E-mail' && cse.Product__c== 'Ocean' && (ownerInPSASet.contains(UserInfo.getUserId())) && cse.Require_NBA_opt_out__c <> true && ((cse.ContactId <> NULL && !String.isBlank(cse.ContactEmail) && !excludedEmailDomains.contains(cse.ContactEmail.split('@')[1]))  || (cse.ContactId == NULL && cse.SuppliedEmail<> null && !excludedEmailDomains.contains(cse.SuppliedEmail.split('@')[1])))){
                    if(allcaseRecMap.containsKey(cse.Id) && (!avlcaseRecMap.containsKey(cse.Id) || avlcaseRecMap.isEmpty())){
                        cse.addError(Label.NBA_Trigger_Error_Message);
                    }
                    if(allcaseRecMap.containsKey(cse.Id) && (viewcaseRecMap.containsKey(cse.Id) || !viewcaseRecMap.isEmpty())){  // SC-9056: Validation rule error message
                        cse.addError(Label.NBA_Trigger_View_Details_Error_Message);
                    }
                }
            }
        } 
        catch(Exception e){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseRecordSelector.CloseNBA', new list<Exception>{e});
        }
    }
    
}