/**
* Author   : Ragu@UST
* Purpose  : Gives abstract view of all the business logic / functionality implemented on Case trigger.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-002633   18-Feb-2016 Ragu@UST                Created for implementing CBO (Centralized By Org) trigger architecture.
* 1.1      RQ-003147   23-Mar-2016 Ananth@UST              Updated if condition onBeforeInsert and onBeforeUpdate to include ISR record type.
* 1.2      RQ-002679   08-Apr-2016 Jiji@UST                Modified to handle GCSS integration for Claim RT on AfterInsert and AfterUpdate.
* 1.3      RQ-004058   07-Jun-2016 Sandhya@UST             Assign ISR Queues based on Case Liner Brand
* 1.4      RQ-004502   23-Nov-2016 Sunu@UST                Include cases with origin SEAGLOBALDISP along with manual cases to set the Triaged milestone to completed.
* 1.5      RQ-003805   13-Dec-2016 Nirmal@UST              To trigger Assignment rules and auto response rules for portal created cases
* 1.6      RQ-004424   02-Jan-2017 Subha@UST               To populate Direction for portal only created cases based on Case Type Sub Type Direction Map. 
* 2.0      RQ-001360   30-Jan-2017 IBM Support Team        Added onAfterUpdate() method to complete the Case Milestones after an update in Case Status. 
* 3.0      RQ-004667   20-Apr-2017 Nisha@UST               To populate FCR related fields in parent case based on merged or duplicated child case (onAfterUpdate).Updated the line of code in  onAfterInsert() method. Also, removed the line of code in onBeforeUpdate() which completes the Case Milestones.
* 4.0      RQ-006949   21-Sep-2017 Ranjini@UST             Send closue email to the case contact.
* 5.0      RQ-007464   18-Jan-2018 Ranjini@UST        Added related accounts also to CaseEmailUtility.sendCaseClosureEmail.
* 6.0      RQ-008020   21-Mar-2018 meenakshi@UST              Added onAfterUpdate() method to create a chatter post on a 'closed-resolved' ISR case
* 7.0      RQ-008547   14-Jun-2018 meenakshi.rajasekaran@ust  Case Assignment Notification
* 8.0      RQ-009034   30-Jul-2018 Ranjini@ust             Updated the Caserecord selector new variable names.
* 9.0      RQ-008620   1-Sep-2018  Ranjini@ust             Non Englis template changes.
* 10.0     RQ-009192   11-Sep-2018 Nisha@ust               Milestone for ISR Cases
* 11.0     RQ-008889   24-Sep-2018 Nisha@Ust               Prevent survey sent to internal contacts.
*`12.0     RQ-009429   22-Oct-2018 Nisha@Ust               Send Case Closure field should take the value at the time of case creation irrespective of the code  logic.
* 13.0     RQ-007915   31-Oct-2018 Sreya@Maersk            Automatic closure of Parent case on closure of all the child cases and throw error on closure of Parent case if all the child cases are not closed.
* 14.0     RQ-009245   03-01-2019  Naved@ maersk           Allow to close spam cases when case owner is queue 
* 15.0     RQ-011816   13-11-2019  Sreya@Maersk            CSAT Enabling for Cases with Dispute Record Type.
* 16.0     RQ-008925   21-01-2019  Naved@maersk            Liner brand ,Direction and Country fields for case to be updated automatically
* 17.0     RQ-012315   15-Nov-2019 Ranjini@ust             Twill changes. 
* 18.0     RQ-011549   02-03-2020    rama@ust               Resolve Milestone removed.
* 19.0     SC-147      12-03-2020  Ranjini@ust              Removal of Traige Milestone for non Email channels
* 20.0     SC-290      04-05-2020  Avinash@ust          Visibility & Direction for Ocean - SFDC To Portal
* 21.0     SC-399      09-06-2020 Avinash@ust        Case Visibility - Manually created External Case
* 22.0     SC-400      11-06-2020  sriram@maersk           Case Visibility - ISR
* 23.0     SC-594    25-06-2020  Sunil BS        Made a call "populateBECode()" OnbeforeInsert and OnbeforeUpdate
* 24.0     SC-675      13-07-2020  Sreya@Maersk             Update Competitor Claims checkbox based on Case Visibility.
* 25.0     IIP-149    24-08-2020   Avinash@ust             Import Manifest Case - Auto Update
* 26.0     SC-SC-825  24-08-2020   Nivedita@UST            User 'Manager' Fields as a filter on CM
* 27.0     SC-1005    07-09-2020   Avinash@ust             Identify Shipment Number from Case
* 28.0     SC-1256    18-11-202    Sreya V                 CSAT Closure opt-out option for customers
* 29.0     SC-1126    24-11-2020  sriram@maersk            Shipment Number based Attributes for Routing - Product Delivery
* 30.0     SC-2183    27-04-2021  Richa@maersk             Modified to handle OHP integration for Dispute RT on AfterInsert and AfterUpdate.
* 31.0     DOR-4331   20-09-2021  Sandeep@ust              Modified to update instantDO workflow owner's as case owner
* 32.0     SC-1300    06-10-2021  Richa@Maersk             Shipment party Callout
* 33.0     SC-3659    15-11-2021  Richa@Maersk             Azure Sentiment Analysis Callout
* 34.0     SC-4044     7-12-2021   Urvish@ust               Validation for financial details for Closed - Paid claim cases
* 35.0     SC-4212    02-02-2022  Sreya@Maersk             Initiate Omni-Skill based routing for Email Cases.
* 36.0     SC-4185    09-02-2022  Sreya@Maersk             Utilize the custom Case classification Modal created by DA team. Making API call.
* 37.0     SC-4859    07-04-2022   Richa@Maersk            Added condition for 4PL Cases apex sharing
* 38.0     SC-4770    04-05-2022  Thippeswamy@UST          CustomPilotModel for ECC  
* 39.0     SC-5376    17-06-2022  Thippeswamy@UST          4PL dashboard enhancement
* 40.0     SC-5492    28-06-2022   Richa@Maersk            Added condition for portal cases for 4PL sharing
* 41.0     SPI-100    27-06-2022  Ronnie@SF                Removed commented brand hardcoding
* 51.0     SC-5845    03-11-2022  Sunil BS                 Bypassed shipment number population and GCSS callout for HSUD
* 52.0     SC-6639    08-02-2023  Harmeet@Maersk           Enabling the method for calling CaseFieldPopulator.updateCaseClassification
* 53.0     SC-7243    27-02-2023  Saradha@UST              4PL ISR Sharing to synchronous
* 54.0     SC-7136    27-02-2023  Harmeet@UST              Moved calling of populateOnBehalfOfAccount and populateDeliveryChannel to Before Insert from After Insert
* 55.0     SC-7083    18-03-2023  ramadevi@maersk.com      NBA - updating the IsRecommendationAvailable__c and Deleting the case recommendations on type,sub type change.
* 56.0     SC-7914    11-05-2023  Harmeet@maersk           Added Validation for Product, Type, Subtype and Reason For Case.
* 57.0     SC-5371     11-05-2023   Richa@maersk            4PL bug fix
* 58.0     SC-8274     30-06-2023  Nayana@maersk.com       Added call for CaseOmniSkillBasedRouting.defineCaseSkillMap and handleCaseOwnerChangeForOmni for Owner update
* 81.0     SC-8816     21-08-2023   Shahanawaz@maersk       Migrate Before Save Flow to Before Apex Trigger
* 82.0     SC-8791     01-09-2023   Vivek@Maersk           Migrate After Save Flow to After apex trigger
* 83.0     SC-8363     05-10-2023   Harmeet@Maersk          Calling populate Shipment Number method before populateGeoData to get the ShipmentNumber
* 84.0     SC-9138     18-10-2023   Vivek@Maersk.com        adding method call IDAIntegrationForEmailRecommendation.UpdateEmailRecommendationKPIs for updating kpis based on variable lstCasesToUpdateKPIsForAI
* 85.0     SC-9190     19-10-2023   Shahanawaz@Maersk.com   Create custom case history on external object
* 86.0     SC-8580     20-10-2023   Harmeet@Maersk.com      Calling the method to update Cluster CS/CE field for Twill Cases
* 87.0     SC-8989     22-02-2024   Shahanawaz@maersk.com   Add Entitlement for Email Cases which are not classified
* 89.0     SC-9291     19-03-2024   Shahanawaz@maersk.com   Update Auto Handshake Email Address SCM KC BA
* 90.0	   SC-8631	   24-Apr-2024	Kiran@maersk		    Auto Case Assignment - Ocean - based on Cargo types - Reefer, OOG, Break Bulk
* 91.0	   SC-10076	   27-May-2024	Shahanawaz@maersk		Update Case Omni skill type on reassignment
* 92.0     SC-10137    11-06-2024   Shahanawaz@maersk   	Automate Response Received Flag
* 93.0     SC-10036	   01-07-2024	Vazid					Added updateCaseOwnerhasCheckerQueue to update logged in user as case owner if owner is checker queue.
* 94.0     SC-10204    02-07-2024   Shahanawaz@maersk.com   Auto Populate From Address (Multiple CM BA)
* 95.0     SC-10138    03-07-2024	Meghna@maersk	        Auto Close Spam Cases

*/

public class CaseTriggerHandler extends TriggerHandler {
    
    public map<Id, Case> newMap;
    public map<Id, Case> oldMap;
    public CaseTriggerHandler() {
        this.newMap = (map<Id, Case>)Trigger.newMap;
        this.oldMap = (map<Id, Case>)Trigger.oldMap;
    }
    
    public CaseRecordSelector casRecordSelector;
    public static Map<Id, Set<String>> caseOperations = new Map<Id, Set<String>>();
    
    public override void getRecordSelector() {
        casRecordSelector = new CaseRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert() {
        
        //Update Ownership Change Time
        CaseFieldPopulator.updateOwnershipChangedTime(Trigger.new);
        
        // Generic Case field population logic on before insert and before update
        CaseFieldPopulator.populateFieldsOnBeforeInsertUpdate(Trigger.new, null, this, casRecordSelector);
        
        //SC-290 Method to update visibility on portal
        CaseFieldPopulator.populateVisibilityInPortal(Trigger.new, null, this, casRecordSelector);
        
        // v1.6: RQ-004424 To populate Direction for cases created from portal.
        if(!casRecordSelector.lstCasesToPopulateDirection.isEmpty()) {
            CaseFieldPopulator.populateDirectionForPortalCases(casRecordSelector.lstCasesToPopulateDirection, casRecordSelector.getMapTSD(),this, casRecordSelector);
        }
        
        // v1.1 - Updated below if condition and inner block to use casRecordSelector.lstExtClaimAndISRCases instead of casRecordSelector.lstExtAndClaimCases
        //#RQ-009034. List name updated to lstExtClaimDispAndISRCases
        if(!casRecordSelector.lstExtClaimDispAndISRCases.isEmpty()) {
            // Populate Liner Brand based on the current user and settings defined in the LinerBrand_Direction_and_Country__mdt.
            CaseFieldPopulator.populateLinerBrand(casRecordSelector.lstExtClaimDispAndISRCases, null, this, casRecordSelector);
            
            // Populate correct Contact and Account based on the Web Email of the Case.
            CaseFieldPopulator.findUniqueLinerBrandContact(casRecordSelector.lstExtClaimDispAndISRCases, casRecordSelector);
            //SC-8363 Calling before populateGeoData to get Shipment Number
            CaseFieldPopulator.populateShipmentNumberFromSubject(Trigger.new);
            // Populate Geo related fields (Country, City, Region and Cluster).
            CaseGeoData.populateGeoData(casRecordSelector.lstExtClaimDispAndISRCases, null, this); 
            
            
            //SC-8580
            CaseFieldPopulator.validateClusterCases(Trigger.new);
            
            // Calculate the business hours spent on a particular status of a Case and calculate Case Age.
            CaseBusinessHours.initializeBusinessHoursFields(casRecordSelector.lstExtClaimDispAndISRCases);
            
            // Set BusinessHoursId based on City or Country or Cluster values.
            CaseBusinessHours.setBusinessHours(casRecordSelector.lstExtClaimDispAndISRCases, null, true, false);
            
            // #RQ-012315.Set Value Proposition and delivery channel for twill cases. 
            CaseFieldPopulator.populateVPDeliveryChannel(casRecordSelector.lstExtClaimDispAndISRCases, null, casRecordSelector,this);
            
            // #RQ-SC-594.Set BE CODE. 
            CaseFieldPopulator.populateBECode(casRecordSelector.lstExtClaimDispAndISRCases,  null, casRecordSelector); 
            //SC-391. Set Supplier on Case
            CaseFieldPopulator.populateSupplier(casRecordSelector.lstExtClaimDispAndISRCases,  null, casRecordSelector);
            
            // v1.3
            if(!casRecordSelector.lstISRCases.isEmpty()) {
                //SC-400  Update ISR cases Case Visibility field based on Case Visibiliti Metrix 
                CaseFieldPopulator.populateISRCaseVisibilityValue(casRecordSelector.lstISRCases);
                // Assign ISR cases to ISR Queues based on the Liner_Brand__c
                CaseFieldPopulator.assignISRCaseToQueue(casRecordSelector.lstISRCases, null);
            }
        }
        
        // SC-1256 : for updating Send Case Closure field
        CaseFieldPopulator.updateSendCaseClosure(Trigger.new,null, this, casRecordSelector);   
        
        if(!casRecordSelector.lstExternalCases.isEmpty()) {
            //RQ-008620. Get the closure language to be updated in Case record.
            //RQ-011816 - Closure language to be updated in Case record for Dispute cases as well.
            CaseFieldPopulator.populateClosurelangauge(casRecordSelector.lstExternalCases, null, casRecordSelector);
        }
        
        // v1.2: GCSS Integration
        if(!casRecordSelector.lstClaimsIdsForResetGCSSCheckbox.isEmpty()) {
            // Reset Refresh GCSS Data Check box to False
            CaseFieldPopulator.resetRefreshGCSSDataForClaims(casRecordSelector.lstClaimsIdsForResetGCSSCheckbox);
        }
        
        //SC-399 && SC-389 Method to populate Case Visibility Value. This method will execute only on before insert.
        //This method is covering catch scenario for External, Claim, Claim Recovery, Dispute Cases. This also covering
        //computation for ISR Cases. This method should always execute at the end of onBeforeInsert context.
        //This method should not be execute in any other trigger context apart from Before Insert
        CaseFieldPopulator.populateCaseVisibilityValue(Trigger.new);
        
        // SC - 675  Update Competitor Claims checkbox based on Case Visibility on insert.      
        CaseFieldPopulator.updateCompetitorClaimVisibility(Trigger.new,null,this);
        //SC-825 User 'Manager' Fields as a filter on CM
        CaseFieldPopulator.updateCaseOwnerManger(Trigger.new,null,this);
        
        //Validation for Case Visibility
        if(!casRecordSelector.lstExternalISRCases.isEmpty() && !Validation_Rules_Bypass__c.getInstance(userInfo.getUserId()).active__c && !Validation_Rules_Bypass__c.getInstance(userInfo.getProfileId()).active__c){
            CaseFieldPopulator.validateCaseVisibility(casRecordSelector.lstExternalISRCases);
        }
        
        // 4PL Type value addition based in Case Subject, SC-5376 
        CaseFieldPopulator.populate4PLType(Trigger.new,casRecordSelector); 
        
        //SC-7083 - Update the isRecommendationAvaialble__c upon update of certain fields.
        if(casRecordSelector.CaseRecommendationList <> null){
            CaseFieldPopulator.updateRecommendationStatus(casRecordSelector.CaseRecommendationList);
        }
        
        //SC-7704 populateOnBehalfOfAccount for omni cases
        List<Case> validatedCases = CaseFieldPopulator.validateOnBehalfOfAccountCases(Trigger.new);
        if(!validatedCases.isEmpty()){
            CaseFieldPopulator.populateOnBehalfOfAccount(validatedCases);
        }

		if(!casRecordSelector.lstCasesToPopulateCR.isEmpty() && !CaseRecordSelector.skipOBHLogic) {
            // Associate appropriate Care Relationship to Case based on the Liner Brand, Direction, Location Fields.
            CaseFieldPopulator.findCareRelationship(casRecordSelector.lstCasesToPopulateCR, null, casRecordSelector.mapRelatedAccounts);
        }		
        
        //SC-7914
        if(!casRecordSelector.lstExternalCases.isEmpty() && !Validation_Rules_Bypass__c.getInstance(userInfo.getUserId()).active__c && !Validation_Rules_Bypass__c.getInstance(userInfo.getProfileId()).active__c) {
            CaseFieldPopulator.validateExternalCaseTypeSubtype(casRecordSelector.lstExternalCases);
        } 
        
        //SC-8816
        if(!casRecordSelector.caseListToUpdateBlankBolNo.isEmpty()){
            CaseFieldPopulator.populateBolNumbertoBlank(casRecordSelector.caseListToUpdateBlankBolNo);
        }
        
        //SC-8816
        if(!casRecordSelector.caseListToUpdateClaimBolNo.isEmpty()){
            CaseFieldPopulator.populateClaimCaseBolNumber(casRecordSelector.caseListToUpdateClaimBolNo);
        }
        
        //SC-8816
        if(!casRecordSelector.caseListToUpdateISRBolNo.isEmpty()){
            CaseFieldPopulator.populateISRCaseBolNumber(casRecordSelector.caseListToUpdateISRBolNo, casRecordSelector.countryIdSetToUpdateISRBolNo);
        }
        
        //SC-8816 - update Counter & Time fields
        CaseFieldPopulator.calculateCounterAndTimeFields(Trigger.new, null, casRecordSelector.closedStatuses);
        
        //SC-8816 - update Subject
        if(!casRecordSelector.caseListToUpdateSubject.isEmpty()){
            CaseFieldPopulator.updateSubject(casRecordSelector.caseListToUpdateSubject, casRecordSelector.mapRelatedAccounts, casRecordSelector.mapRelatedContacts);
        }
        
        //SC-8816 - update Portal on behalf
        if(!casRecordSelector.caseListToUpdatePortalOnBehalf.isEmpty()){
            CaseFieldPopulator.updatePortalOnBehalf(casRecordSelector.caseListToUpdatePortalOnBehalf, casRecordSelector.mapRelatedAccounts, casRecordSelector.mapRelatedContacts);
        }
        
        //SC-8816 - update Product, Product Category & Claim Activity
        if(!casRecordSelector.caseListToUpdateProductClaimActivity.isEmpty()){
            CaseFieldPopulator.updateProductAndClaimActivity(casRecordSelector.caseListToUpdateProductClaimActivity, casRecordSelector.parentIdSet);
        }
        
        //SC-9008 - Update the user who updated the NBA bypass field    
        if(!casRecordSelector.lstCasesToUpdateNBAOptOut.isEmpty()){    
            CaseFieldPopulator.populateNBAOptOutUser(casRecordSelector.lstCasesToUpdateNBAOptOut);  
        }
        
        //SC-8989
        CaseFieldPopulator.assignEntitlement(Trigger.new);
        
        
    }
    
    public override void onBeforeUpdate() {        
        //Update Ownership Change Time
        if(!casRecordSelector.ownershipChangeCaseList.isEmpty()){
            CaseFieldPopulator.updateOwnershipChangedTime(casRecordSelector.ownershipChangeCaseList);
        }
        
        List<Case> validatedCases = CaseFieldPopulator.validateOnBehalfOfAccountCases(Trigger.new);
        if(!validatedCases.isEmpty()){
            CaseFieldPopulator.populateOnBehalfOfAccount(validatedCases);
        }
        
        //Update New Email Flag
        if(!casRecordSelector.newEmailFlagCaseList.isEmpty()){
            CaseFieldPopulator.updateNewEmailFlag(casRecordSelector.newEmailFlagCaseList);
        }
        
        //SC-8274: if Case owner is manually changed then delete the PSR to stop re-routing
        if(!casRecordSelector.setDeleteRoutingForOmni.isEmpty()  && Generic_TriggerHandler.validateRunForMethod('CaseOmniSkillBasedRouting.deletePSRForOmniEmail()', 1)){
            CaseOmniSkillBasedRouting.deletePSRForOmniEmail(casRecordSelector.setDeleteRoutingForOmni,casRecordSelector.lstDeleteRoutingForOmni);
        }
        
        //This is just to update all instantDO workflow owner as case owner as soon as case owner gets updated.
        CaseFieldPopulator.updateWorkflowOwner(casRecordSelector.lstExternalInstantDOCases,this.oldMap,this);
        
        //This is to update workflow status once case is closed
        CaseFieldPopulator.updateWorkflowOnCaseClosure(casRecordSelector.lstExternalInstantDOCases,this.oldMap,this);
        
        // Generic Case field population logic on before insert and before update
        CaseFieldPopulator.populateFieldsOnBeforeInsertUpdate(Trigger.new, this.oldMap, this, casRecordSelector);
        
        //SC-290 Method to update visibility on portal
        CaseFieldPopulator.populateVisibilityInPortal(Trigger.new, this.oldMap, this, casRecordSelector);
        
        // v1.6: RQ-004424 To populate Direction for portal cases when Type and Sub Types are updated.
        if(!casRecordSelector.lstCasesToPopulateDirection.isEmpty()) {
            CaseFieldPopulator.populateDirectionForPortalCases(casRecordSelector.lstCasesToPopulateDirection, casRecordSelector.getMapTSD(),this,casRecordSelector);
        }
        //Allow to close spam cases when case owner is queue
        if(!casRecordSelector.lstSpamCaseId.isEmpty()){
            updateOwnership(casRecordSelector.lstSpamCaseId);
        }
        
        if(!casRecordSelector.mapQueueIdCase.isEmpty()){           
            CaseFieldPopulator.caseDetailsBasedonQueue(casRecordSelector.mapQueueIdCase, casRecordSelector.mapCountryNameCountryId);
        }
        // v1.1 - Updated below if condition and inner block to use casRecordSelector.lstExtClaimAndISRCases instead of casRecordSelector.lstExtAndClaimCases
        //#RQ-009034. List name updated to lstExtClaimDispAndISRCases
        if(!casRecordSelector.lstExtClaimDispAndISRCases.isEmpty()) {
            // Populate Liner Brand based on the current user and settings defined in the LinerBrand_Direction_and_Country__mdt.
            CaseFieldPopulator.populateLinerBrand(casRecordSelector.lstExtClaimDispAndISRCases, this.oldMap, this, casRecordSelector);
            
            // Populate Geo related fields (Country, City, Region and Cluster).
            CaseGeoData.populateGeoData(casRecordSelector.lstExtClaimDispAndISRCases, this.oldMap, this);
            
            // Set BusinessHoursId based on City or Country or Cluster values.
            CaseBusinessHours.setBusinessHours(casRecordSelector.lstExtClaimDispAndISRCases, this.oldMap, false, true);
            
            // Calculate the business hours spent on a particular status of a Case and calculate Case Age.
            CaseBusinessHours.calculateBusinessHoursAges(casRecordSelector.lstExtClaimDispAndISRCases, this.oldMap);
            
            // #RQ-012315.Set Value Proposition and delivery channel for twill cases. 
            CaseFieldPopulator.populateVPDeliveryChannel(casRecordSelector.lstExtClaimDispAndISRCases,  this.oldMap, casRecordSelector,this); 
            
            // #RQ-SC-594.Set BE CODE. 
            CaseFieldPopulator.populateBECode(casRecordSelector.lstExtClaimDispAndISRCases,  this.oldMap, casRecordSelector); 
            
            //SC-391. Set Supplier On Case
            CaseFieldPopulator.populateSupplier(casRecordSelector.lstExtClaimDispAndISRCases,  this.oldMap, casRecordSelector); 
            
            // v1.3
            if(!casRecordSelector.lstISRCases.isEmpty()) {
                // Assign ISR cases to ISR Queues based on the Liner_Brand__c
                CaseFieldPopulator.assignISRCaseToQueue(casRecordSelector.lstISRCases, this.oldMap);
            }
        }
        
        if(!casRecordSelector.lstCasesToPopulateCR.isEmpty()) {
            // Associate appropriate Care Relationship to Case based on the Liner Brand, Direction, Location Fields.
            CaseFieldPopulator.findCareRelationship(casRecordSelector.lstCasesToPopulateCR, this.oldMap, casRecordSelector.mapRelatedAccounts);
        }
        
        // v1.2: GCSS Integration
        if(!casRecordSelector.lstClaimsforGCSSIntgtn.isEmpty()) {
            // Call middleware to get data from GCSS
            CaseIntegrations.GCSSIntegraionForClaims(casRecordSelector.lstClaimsForGCSSIntgtn, System.Label.Case_Label, System.Label.GCSS_Module_Name);
        }
        
        // SC-1256 : for updating Send Case Closure field
        CaseFieldPopulator.updateSendCaseClosure(Trigger.new, this.oldMap, this, casRecordSelector);
        
        if(!casRecordSelector.lstExternalandDispCases.isEmpty()) {
            //RQ-008620. Get the closure language to be updated in Case record. 
            //RQ-011816 - Closure language to be updated in Case record for dispute as well.
            CaseFieldPopulator.populateClosurelangauge(casRecordSelector.lstExternalandDispCases, this.oldMap, casRecordSelector);
        }
        
        // v1.2: GCSS Integration
        if(!casRecordSelector.lstClaimsIdsForResetGCSSCheckbox.isEmpty()) {
            // Reset Refresh GCSS Data Check box to False
            CaseFieldPopulator.resetRefreshGCSSDataForClaims(casRecordSelector.lstClaimsIdsForResetGCSSCheckbox);
        }  
        
        // RQ-007915 : Handle closure validations for Parent Dispute Cases
        if(!casRecordSelector.mapDisputeClosureCases.isEmpty()) {
            DisputeCaseClosureHelper.validateParentDISPCaseClosure(casRecordSelector.mapDisputeClosureCases);           
        } 
        
         // SC-9661 : update AI_Agent_Email_Recommendation_User__c flag based on owners access to AI Agent feature
        if(!casRecordSelector.mapCasesForAiAgentUpdate.isEmpty()) {
            IDAIntegrationForEmailRecommendation.updateAIAgentUserFlagOnCase(Trigger.new, this.oldMap, casRecordSelector.mapCasesForAiAgentUpdate);           
        } 
        
        //Case cannot be closed until all the workflows under it is closed (approved/Rejected).
        CaseFieldPopulator.handleCaseClosure( this.newMap,this.oldMap );
        
        //SC - 675 Update Competitor Claims checkbox based on Case Visibility on update.  
        CaseFieldPopulator.updateCompetitorClaimVisibility(Trigger.new,this.oldMap,this);
        
        //SC-825 User 'Manager' Fields as a filter on CM
        if(!casRecordSelector.setCaseManagerUpdate.isEmpty()){
            CaseFieldPopulator.updateCaseOwnerManger(Trigger.new,this.oldMap,this);
        }
        
        //Validation for financial details for Closed - Paid claim cases
        if(!casRecordSelector.lstClaimCases.isEmpty() && !Validation_Rules_Bypass__c.getInstance(userInfo.getUserId()).active__c && !Validation_Rules_Bypass__c.getInstance(userInfo.getProfileId()).active__c){
            CaseFieldPopulator.validateClaimCase(this.newMap,this.oldMap);
        }
        
        //Validation for Case Visibility 
        
        if(!casRecordSelector.lstExternalISRCases.isEmpty() && !Validation_Rules_Bypass__c.getInstance(userInfo.getUserId()).active__c && !Validation_Rules_Bypass__c.getInstance(userInfo.getProfileId()).active__c){
            CaseFieldPopulator.validateCaseVisibility(casRecordSelector.lstExternalISRCases);
        }
        
        //SC-7083 - Update the isRecommendationAvaialble__c upon update of certain fields.
        if(casRecordSelector.CaseRecommendationList <> null){
            CaseFieldPopulator.updateRecommendationStatus(casRecordSelector.CaseRecommendationList);
        }
        //SC-7914
        if(!casRecordSelector.lstExternalCases.isEmpty() && !Validation_Rules_Bypass__c.getInstance(userInfo.getUserId()).active__c && !Validation_Rules_Bypass__c.getInstance(userInfo.getProfileId()).active__c) {
            CaseFieldPopulator.validateExternalCaseTypeSubtype(casRecordSelector.lstExternalCases);
        }   
        
        //SC-8816
        if(!casRecordSelector.caseListToUpdateBlankBolNo.isEmpty()){
            CaseFieldPopulator.populateBolNumbertoBlank(casRecordSelector.caseListToUpdateBlankBolNo);
        }
        
        //SC-8816
        if(!casRecordSelector.caseListToUpdateClaimBolNo.isEmpty()){
            CaseFieldPopulator.populateClaimCaseBolNumber(casRecordSelector.caseListToUpdateClaimBolNo);
        }
        
        //SC-8816
        if(!casRecordSelector.caseListToUpdateISRBolNo.isEmpty()){
            CaseFieldPopulator.populateISRCaseBolNumber(casRecordSelector.caseListToUpdateISRBolNo, casRecordSelector.countryIdSetToUpdateISRBolNo);
        }
        
        //SC-8816 - update Counter & Time fields
        CaseFieldPopulator.calculateCounterAndTimeFields(Trigger.new, this.oldMap, casRecordSelector.closedStatuses);
        
        //SC-8816 - update Subject
        if(!casRecordSelector.caseListToUpdateSubject.isEmpty()){
            CaseFieldPopulator.updateSubject(casRecordSelector.caseListToUpdateSubject, casRecordSelector.mapRelatedAccounts, casRecordSelector.mapRelatedContacts);
        }
        
        //SC-8816 - update Portal on behalf
        if(!casRecordSelector.caseListToUpdatePortalOnBehalf.isEmpty()){
            CaseFieldPopulator.updatePortalOnBehalf(casRecordSelector.caseListToUpdatePortalOnBehalf, casRecordSelector.mapRelatedAccounts, casRecordSelector.mapRelatedContacts);
        }
        
        //SC-8816 - update Product, Product Category & Claim Activity
        if(!casRecordSelector.caseListToUpdateProductClaimActivity.isEmpty()){
            CaseFieldPopulator.updateProductAndClaimActivity(casRecordSelector.caseListToUpdateProductClaimActivity, casRecordSelector.parentIdSet);
        }
        
        //SC-9008 - Update the user who updated the NBA bypass field    
        if(casRecordSelector.lstCasesToUpdateNBAOptOut <> null){    
            CaseFieldPopulator.populateNBAOptOutUser(casRecordSelector.lstCasesToUpdateNBAOptOut);  
        }
        
        //SC-9008 - Move Time spend in Main Queue logic to apex from batch     
        if(!casRecordSelector.mapUpdateBHtime.isEmpty() || !casRecordSelector.mapCalculateBHtime.isEmpty()){
            CaseFieldPopulator.calculateBHOnOwnerChange(Trigger.new, this.oldMap, casRecordSelector);
        }
        
        
	//To update case owner as logged in user if case is associated with checker queue.
        if(!casRecordSelector.checkerQueueOwnerCases.isEmpty() && !casRecordSelector.caseIdSetToUpdateOwner.isEmpty()){
            CaseFieldPopulator.updateCaseOwnerhasCheckerQueue(casRecordSelector.caseIdSetToUpdateOwner, casRecordSelector.checkerQueueOwnerCases);
        }
        
        //SC-10138:Update Auto Closure Time
        if(!casRecordSelector.lstAutocloseCase.isEmpty()){
            CaseFieldPopulator.updateAutoClosureTime(casRecordSelector.lstAutocloseCase);
        }
        
        //SC-10204
        if(!casRecordSelector.caseOwnerIdsForBAAddress.isEmpty() && !casRecordSelector.caseListForBAAddress.isEmpty()){
            CaseFieldPopulator.updateBAFromAddress(casRecordSelector.caseOwnerIdsForBAAddress, casRecordSelector.caseListForBAAddress);
        }
        
         //Below logic is to send the case details to IDA to re-trigger the gen2 recommendation 
        if(!casRecordSelector.mapOfCasesLatestRecomm.isEmpty()){
            if(General_Settings__c.getInstance() != null && !General_Settings__c.getInstance().Disable_IDA_Email_Recommendation_Int__c){
                IDAIntegrationForEmailRecommendation.getEmailAndCaseDetailsOnUpdate(casRecordSelector.mapOfCasesLatestRecomm);
            }
        }
    }
    
    public override void onAfterInsert() {
        General_Settings__c gs = General_Settings__c.getInstance();
        if(!casRecordSelector.caseswithShipmentNumber.isEmpty()){                
            if(gs.Case_shipment_API_status__c && casRecordSelector.caseswithShipmentNumber.size() <= gs.Case_shipment_API_Count__c){
                for(Case newCase : casRecordSelector.caseswithShipmentNumber){
                    Boolean isHumbBrand = false;                     
                    if(String.isnotBlank(newCase.Liner_Brand__c) && BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.HAMBURGSUD).contains(newCase.Liner_Brand__c)){
                        isHumbBrand = true;
                    }
                    if(!isHumbBrand){
                        if(caseOperations.isEmpty() || !caseOperations.containsKey(newCase.Id)){
                            caseOperations.put(newCase.Id, new Set<String>{'Shipment Summary'});
                        }else{
                            caseOperations.get(newCase.Id).add('Shipment Summary');
                        }
                        
                        if(caseOperations.isEmpty() || !caseOperations.containsKey(newCase.Id)){
                            caseOperations.put(newCase.Id, new Set<String>{'Short transit'});
                        }else{
                            caseOperations.get(newCase.Id).add('Short transit');
                        }
                        
                        //SC-8631 Break bulk for Cargo type
                        if(caseOperations.isEmpty() || !caseOperations.containsKey(newCase.Id)){
                            caseOperations.put(newCase.Id, new Set<String>{'Break bulk'});
                        }else{
                            caseOperations.get(newCase.Id).add('Break bulk');
                        }
                    }   
                }
            }
        }
        
        //SC-3659 - To get cases for Sentiment Analysis population
        if(!casRecordSelector.lstCasesForSentiment.isEmpty()){
            //check if the api count as per configured settings
            if(gs.Case_sentiment_API_status__c && casRecordSelector.lstCasesForSentiment.size() <= gs.Case_sentiment_API_Count__c){
                for(Case newCase : casRecordSelector.lstCasesForSentiment){
                    if(caseOperations.isEmpty() || !caseOperations.containsKey(newCase.Id)){
                        caseOperations.put(newCase.Id, new Set<String>{'Sentiment Analysis'});
                    }
                    else{
                        caseOperations.get(newCase.Id).add('Sentiment Analysis');
                    }
                }                
            }
        }
        
        //SC-4185 - API callout to get custom Case Classification
        if(!casRecordSelector.csListForCustomCC.isEmpty()){ 
            if(gs.Case_Classification_API_status__c){
                for(Case newCase : casRecordSelector.csListForCustomCC){
                    if(caseOperations.isEmpty() || !caseOperations.containsKey(newCase.Id)){
                        caseOperations.put(newCase.Id, new Set<String>{'IDA Classification'});
                    }
                    else{
                        caseOperations.get(newCase.Id).add('IDA Classification');
                    }
                }
            }            
        }
        
        if(!casRecordSelector.setCaseIdsToSetDMLOptions.isEmpty()) {//V 1.5:  RQ-003805
            // Trigger Auto Response and case Assignment rules for Portal Cases
            CaseUtilities.fireAssignmentAndAutoResponse(casRecordSelector.setCaseIdsToSetDMLOptions);
        }
        
        if(!casRecordSelector.setCaseIdsToSetDMLOptionsAW.isEmpty()){//IIP-149
            // Trigger Auto Response and case Assignment rules for Portal Cases with Agent Workflow
            CaseUtilities.fireAssignmentRules(casRecordSelector.setCaseIdsToSetDMLOptionsAW);
        }
        
        //SC-4859 - apex based sharing for case after insert
        if(!casRecordSelector.set4PLExtrnlCaseIds.isEmpty()){   
            ApexSharingUtility.updateSharing(casRecordSelector.set4PLExtrnlCaseIds,'Case','Case_Visibility__c','Edit','Manual',false);  
        }
        //SC-7243 - synchoronous sharing for ISR cases
        if(casRecordSelector.lst4PLISRCasesForShare != null && casRecordSelector.lst4PLISRCasesForShare.size() >0 ){  
            ApexSharingUtility.createShareRecordForISR(casRecordSelector.set4PLISRCaseIds,'Case','Case_Visibility__c','Edit','Manual',false,casRecordSelector.lst4PLISRCasesForShare);  
        }
        
        //SC-5492 - apex based sharing for portal case after insert
        if(!casRecordSelector.set4PLCaseIdsPortal.isEmpty()){
            if(gs.Apex_Sharing_Retry_status__c){ 
                ApexSharingUtility.updateSharingPortal(casRecordSelector.set4PLCaseIdsPortal,false);  
            }
        }
        
        // v1.2: GCSS Integration
        if(!casRecordSelector.lstClaimsforGCSSIntgtn.isEmpty()) {
            // // Call middleware to get data from GCSS
            CaseIntegrations.GCSSIntegraionForClaims(casRecordSelector.lstClaimsForGCSSIntgtn, System.Label.Case_Label, System.Label.GCSS_Module_Name);
        }
        
        if(!casRecordSelector.setCaseIdsToUpdateMilestones.isEmpty()) { 
            // Mark the milestone as completed based on the Status of a case.
            CaseEntitlements.completeMilestones(casRecordSelector.setCaseIdsToUpdateMilestones); // v2.0 RQ-001360 -  Calling the completeMilestones() method.
        }
        
        //RQ-006949.Send closure emails.
        if(!casRecordSelector.mapCasesForClosureNotification.isEmpty()) {
            CaseEmailUtility.sendCaseClosureEmail(casRecordSelector.mapCasesForClosureNotification, casRecordSelector);
        }
        //SC-2183: OHP Integration
        if(!casRecordSelector.mapCasesToPublish.isEmpty()) {
            CaseIntegrations.publishCases(casRecordSelector.mapCasesToPublish,'live'); //Modified for SC-9978
        }
        
        //SC-8358
        if(!casRecordSelector.lstPortalCasesToOmniRoute.isEmpty()) {
            CaseOmniSkillBasedRouting.defineCaseSkillMap(casRecordSelector.lstPortalCasesToOmniRoute,casRecordSelector.mapRelatedCareRelation,casRecordSelector.mapKeyClient,false,true, null, new Map<Id, Case>());
        }
        
        //SC-7661
        if(!casRecordSelector.IDACaseslist.isEmpty()){
            PopulateNonKeyClientCase.populateSOandOBA(casRecordSelector.IDACaseslist);
        }
        
        //Update Last Meaningful Activity
        if(!casRecordSelector.lastMeaningfulActCaseIdSet.isEmpty()){
            TriggerExecutionController.skipCaseTrigger(true);
            CaseLastActivityUtility.updateCasefield(casRecordSelector.lastMeaningfulActCaseIdSet);
            TriggerExecutionController.skipCaseTrigger(false);
        }
        
        //SC-8791 Create plaform event for cases for artemis
        if(!casRecordSelector.artemisCasesMap.isEmpty()){            
            CaseAfterInsertUpdateManager.preparePublishCaseToPlatformEvent(casRecordSelector.artemisCasesMap, casRecordSelector.artemisQueueIds);
        }
        
        //SC-8791
        if(!casRecordSelector.mapCasesTaskforclaims.isempty()){
            CaseAfterInsertUpdateManager.taskcreationAndSendEmailAlerts(Trigger.new, this.oldMap, this, casRecordSelector);
        }
        
        //SC-8791
        if(!casRecordSelector.caseEscalationSendEmailAlertsList.isempty()){  
            CaseAfterInsertUpdateManager.sendCaseEscalationSendEmailAlert(casRecordSelector.caseEscalationSendEmailAlertsList);  
        }
        
        //SC-8789
        if(caseOperations != null && !caseOperations.isEmpty() && caseOperations.keySet().size() == 1){
            IntegrationRecordCreator.createIntegrationRecord(caseOperations, 'Case Insert');
        }

        //SC-9190
        if(!gs.Disable_Case_History_Tracking__c){
            CaseFieldPopulator.validateCustomCaseHistory(Trigger.new, this.oldMap, casRecordSelector.mapRelatedContacts, casRecordSelector.csHistoryWrapList);
            if(!casRecordSelector.csHistoryWrapList.isEmpty()){
                CaseFieldPopulator.createCustomCaseHistory(JSON.serialize(casRecordSelector.csHistoryWrapList));
            }
        }
        
        //SC-9293
        if(!casRecordSelector.caseListForFeedItem.isEmpty()){
            CaseFieldPopulator.createFeedItem(casRecordSelector.caseListForFeedItem);
        }
        
        //SC-9291
        if(!casRecordSelector.caseListForHandshake.isEmpty()){
            //CaseAfterInsertUpdateManager.sendHandshakeEmail(casRecordSelector.caseListForHandshake, CaseRecordSelector.scmIndicatorToSCMKCMap, CaseRecordSelector.templateNames, CaseRecordSelector.replyToEmailList, casRecordSelector.mapRelatedContacts);
        }
        
	if(!casRecordSelector.twillCaseMap.isEmpty()){
            System.enqueueJob(new CaseTranslatorQueuable(casRecordSelector.twillCaseMap));
        }
        
        //SC-10137
        if(!casRecordSelector.isrParentCaseSet.isEmpty()){
            CaseFieldPopulator.updateISRParentCase(casRecordSelector.isrParentCaseSet);
        }
    }
    
    
    // v2.0: RQ-001360 - Method to complete the Case Milestones after an update in Case Status. 
    public override void onAfterUpdate() {
        //SC-8822
        General_Settings__c gs = General_Settings__c.getInstance();
        if(!casRecordSelector.validShipmentnumberCases.isEmpty()){
            if(Generic_TriggerHandler.validateRunForMethod('CaseFieldPopulator.populateShortTransit()', 1)) {                
                if(gs.Case_shipment_API_status__c && casRecordSelector.validShipmentnumberCases.size() <= gs.Case_shipment_API_Count__c){
                    for(Case newCase:casRecordSelector.validShipmentnumberCases){
                        Boolean isHumbBrand = false;
                        if(String.isnotBlank(newCase.Liner_Brand__c) && BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.HAMBURGSUD).contains(newCase.Liner_Brand__c)){
                            isHumbBrand = true;
                        }
                        if (!isHumbBrand){
                            if(caseOperations.isEmpty() || !caseOperations.containsKey(newCase.Id)){
                                caseOperations.put(newCase.Id, new Set<String>{'Short transit'});
                            }else{
                                caseOperations.get(newCase.Id).add('Short transit');
                            }
                            
                            if(caseOperations.isEmpty() || !caseOperations.containsKey(newCase.Id)){
                                caseOperations.put(newCase.Id, new Set<String>{'Shipment Summary'});
                            }else{
                                caseOperations.get(newCase.Id).add('Shipment Summary');
                            }
                            
                            //SC-8631 Break bulk for Cargo type
                            if(caseOperations.isEmpty() || !caseOperations.containsKey(newCase.Id)){
                                caseOperations.put(newCase.Id, new Set<String>{'Break bulk'});
                            }else{
                                caseOperations.get(newCase.Id).add('Break bulk');
                            }
                        }   
                    }
                }//end of caseswithshipmentnumber check                
            } 
        }
        
        
        //SC-8274: if Case owner is manually changed to queue then retrigger Omni for the queue
        if(!casRecordSelector.listCasesOwnerChangeForOmni.isEmpty()){
            CaseOmniSkillBasedRouting.defineCaseSkillMap(casRecordSelector.listCasesOwnerChangeForOmni,casRecordSelector.mapRelatedCareRelation,casRecordSelector.mapKeyClient,true,false, null, new Map<Id, Case>());
        }
        
        //SC-7083 - Delete Case Recommendations which is not needed, upon update of certain fields.
        if(casRecordSelector.CaseRecommendationList <> null && !casRecordSelector.CaseRecommendationList.isEmpty()){
            CaseFieldPopulator.deleteCaseRecommendation(casRecordSelector.CaseRecommendationList);
        }
        
        //SC-4859 - apex based sharing for case after update
        if(!casRecordSelector.set4PLExtrnlCaseIds.isEmpty()){
            ApexSharingUtility.updateSharing(casRecordSelector.set4PLExtrnlCaseIds,'Case','Case_Visibility__c','Edit','Manual',true); 
        }
        //SC-5371
        if(!casRecordSelector.set4PLChngeIdsExtrnl.isEmpty()){
            if(Generic_TriggerHandler.validateRunForMethod('ApexSharingUtility.updateSharing()', 1)) {         
                ApexSharingUtility.updateSharing(casRecordSelector.set4PLChngeIdsExtrnl,'Case','Case_Visibility__c','Edit','Manual',false); 
            }
        }
        
        if(!casRecordSelector.set4PLISRCaseIds.isEmpty()){   
            ApexSharingUtility.createShareRecordForISR(casRecordSelector.set4PLISRCaseIds,'Case','Case_Visibility__c','Edit','Manual',false,casRecordSelector.lst4PLISRCasesForShare);  
        }
        
        
        //SC-5492 - apex based sharing for portal case after update
        if(!casRecordSelector.set4PLCaseIdsPortal.isEmpty()){           
            if(gs.Apex_Sharing_Retry_status__c){ 
                ApexSharingUtility.updateSharingPortal(casRecordSelector.set4PLCaseIdsPortal,true);
            }
        }
        
        //SC-5371
        if(!casRecordSelector.set4PLChngeIdsPortal.isEmpty()){  
            if(Generic_TriggerHandler.validateRunForMethod('ApexSharingUtility.updateSharingPortal()', 1)) {                   
                if(gs.Apex_Sharing_Retry_status__c){ 
                    ApexSharingUtility.updateSharingPortal(casRecordSelector.set4PLChngeIdsPortal,false);
                }
            }
        }
        
        if(!casRecordSelector.setCaseIdsToUpdateMilestones.isEmpty()) {            
            // Update milestone status based on the changes in Case.
            CaseEntitlements.completeMilestones(casRecordSelector.setCaseIdsToUpdateMilestones);
        }
        
        // v3.0: RQ-004667 - FCR Calculation
        if(!casRecordSelector.setParentCaseId.isEmpty()) { 
            // Populate the FCR related fields in parent Case from the merged or duplicated child case
            CaseFCRCalculation.populateFCRFieldInParent(casRecordSelector.setParentCaseId, casRecordSelector.setChildCaseId, newMap);     
        }
        
        //RQ-006949.Send closure emails.
        //#RQ-007464
        if(!casRecordSelector.mapCasesForClosureNotification.isEmpty()) {
            CaseEmailUtility.sendCaseClosureEmail(casRecordSelector.mapCasesForClosureNotification, casRecordSelector);
            
        }
        //SC-9138 calling method 
        if(!casRecordSelector.mapCasesToUpdateKPIsForAI.isEmpty()) {
            IDAIntegrationForEmailRecommendation.updateEmailRecommendationKPIs(null, casRecordSelector.mapCasesToUpdateKPIsForAI, casRecordSelector.setAiResponseCreatorId);
        }
        
        //RQ-008020 Notification on Closed ISR
        if(!casRecordSelector.mapISRClosurePost.isEmpty()){            
            CaseChatterPoster ccp = new CaseChatterPoster();
            ccp.strPostPrefix = System.Label.casepostprefix;
            ccp.strPostSuffix = System.Label.casepostsuffix;
            ccp.strPostMentionText = System.Label.CaseChattermentiontext;
            ccp.postToRequestorForRT(casRecordSelector.mapISRClosurePost);
        }
        
        //RQ-008547 Case Assignment Notification
        if(!casRecordSelector.mapCaseownerEligible.isEmpty()){            
            CaseChatterPoster ccp = new CaseChatterPoster();
            ccp.PostToNotifyCaseowner(casRecordSelector.mapCaseownerEligible);
        }
        
        // RQ-007915 : Handle updation of Parent Dispute Case closure on all the child dispute case closure
        if(!casRecordSelector.setDisputeClosureCases.isEmpty()) {
            DisputeCaseClosureHelper.updateParentDISPCaseStatus(casRecordSelector.setDisputeClosureCases);            
        } 
        //SC-2183: OHP Integration
        if(Generic_TriggerHandler.validateRunForMethod('CaseIntegrations.publishCases', 1)) {
            if(!casRecordSelector.mapCasesToPublish.isEmpty()) {
              CaseIntegrations.publishCases(casRecordSelector.mapCasesToPublish,'live'); //Modified for SC-9978
            }
        }
        
        //SC-8791 Create Notification on Closed ISR Case
        if(!casRecordSelector.isrClosedCaseList.isEmpty()){            
            CaseAfterInsertUpdateManager.sendNotificationOnClosedISR(casRecordSelector.isrClosedCaseList);
        }
        //SC-8791 publish Case platform event for artemis
        if(!casRecordSelector.artemisCasesMap.isEmpty()){            
            CaseAfterInsertUpdateManager.preparePublishCaseToPlatformEvent(casRecordSelector.artemisCasesMap,casRecordSelector.artemisQueueIds);
        }
        
        //SC-8791 call send email and chatter post for dispute case notification
        if(!casRecordSelector.dispCasesOnEmailTrigCondition.isEmpty()){            
            CaseAfterInsertUpdateManager.disputeNotificationsOnEmailTrgCond(casRecordSelector.dispCasesOnEmailTrigCondition);
        }
        // SC-8791 
        if(!casRecordSelector.mapCasesforemailalerts.isempty() || !casRecordSelector.mapCasesTaskforclaims.isempty()){
            CaseAfterInsertUpdateManager.taskcreationAndSendEmailAlerts(Trigger.new, this.oldMap, this, casRecordSelector);
        }
        
        //SC-8791   
        if(!casRecordSelector.caseEscalationSendEmailAlertsList.isempty()){  
            CaseAfterInsertUpdateManager.sendCaseEscalationSendEmailAlert(casRecordSelector.caseEscalationSendEmailAlertsList);  
        }
        
        //SC-9190
        if(!gs.Disable_Case_History_Tracking__c){
            CaseFieldPopulator.validateCustomCaseHistory(Trigger.new, this.oldMap, casRecordSelector.mapRelatedContacts, casRecordSelector.csHistoryWrapList);
            if(!casRecordSelector.csHistoryWrapList.isEmpty()){
                CaseFieldPopulator.createCustomCaseHistory(JSON.serialize(casRecordSelector.csHistoryWrapList));
            }
        }
        
        if(caseOperations != null && !caseOperations.isEmpty() && caseOperations.keySet().size() == 1){
            IntegrationRecordCreator.createIntegrationRecord(caseOperations, 'Case Update');
        }
        
        //SC-10076
        if(!casRecordSelector.caseOmniSkillUpdateList.isEmpty()){
            CaseFieldPopulator.updateOmniSkillTypeToBlank(casRecordSelector.caseOmniSkillUpdateList);
        }
    }
    // v2.0 End
    @future 
    public static void updateOwnership(List<Id> caseIDs) {
        TriggerExecutionController.skipCaseTrigger(true);
        Database.DMLOptions dmo = new Database.DMLOptions(); 
        dmo.EmailHeader.triggerUserEmail = false; 
        
        List<Case> casesToUpdate = new List<Case>(); 
        for( Id caseId : caseIDs ){
            Case caseToUpdate = new Case(
                Id = caseId,
                OwnerId = UserInfo.getUserId()
            );
            casesToUpdate.add( caseToUpdate ); 
        }
        
        if(Schema.sObjectType.Case.isUpdateable()){
            Database.update(casesToUpdate, dmo); // Actual DML operation is performed instead of implicit update
        }
        TriggerExecutionController.skipCaseTrigger(false);
    }
    
}