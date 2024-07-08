/**
 * Author   : Meghana.Gupta@UST
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on Opportunity trigger.
 * 
 * Revision Ref Number      Date        Owner                             Description
 * -------- ----------   -----------  -------------------                 -----------
 * 1.0      #RQ-002301  26-Feb-2016    Meghana.Gupta@UST                  Created for implementing CBO (Centralized By Org) trigger architecture.
 * 2.0      #RQ-004742  22-May-2017    Meghana.Gupta@UST-Global.com       Update Sales Metrics records on opportunity update/delete
 * 3.0      #RQ-005190  28-Jun-2017    Sandhya.Sambasivan@ust-global.com  Change 'Move To Tender' to a chatter feed button 
 * 4.0      #RQ-005471  06-Jul-2017    Meghana.Gupta@ust-global.com       Code Optimization                                                                       - Check 'Draft account related oppty is not Closed Won' - moved to validation rule
 * 4.1      #RQ-005318  31-Jul-2017    Sandhya.Sambasivan@ust-global.com  Populate Territory for Opportunity,Opp team functionality
 * 4.2      #RQ-005157  31-Jul-2017    Sandhya.Sambasivan@ust-global.com  Removed Chatter post for named accounts 
 * 5.0      #RQ-008175  18-Apr-2018    Jiji.Jayasingh@ust-global.com      To create Project templates, milestones and tasks when a qualified tender opportunity is created
 * 6.0      #RQ-008580  25-May-2018    meghana.gupta@ust-global.com       Populate custom field 'Territory__c' and oppty with territory group
 * 7.0      #RQ-008607  18-Jun-2018    Jiji.Jayasingh@ust-global.com      To deprecate the Move to Tender functionality.
 * 8.0      #RQ-008622  29-Aug-2018    Jiji.Jayasingh@ust-global.com      Tender owner changes tender criteria after creation
 * 9.0      #RQ-008100  10-Oct-2018    meghana.gupta@ust-global.com       When Quarterly Deal is cloned from UI using standard clone feature, then need to copy OpportunityLineItems from old opportunity
 * 10.0     #RQ-009058  18-Mar-2019    Junaid.Khader@ust-global.com       Removed Territory2 related codes
 * 11.0     #RQ-011435  14-Aug-2019    Junaid.Khader@ust-global.com       Removed invocation of methods SalesMetricFieldPopulator.removeCluAPLinkage & SalesMetricFieldPopulator.resetRemoveCluAPLinkage as part of decommisioning CluAP
 * 12.0     #RQ-012032  22-Oct-2019    Sidhartha@maersk.com               Removed auto cloning functionality.
 * 13.0     #RQ-012233  25-Nov-2019    manjunath@maersk                   Logic for adding new dangerous cargo team members - Mod-01 to Mod-02
 * 13.1     RQ-013016   03-04-2020     Sidhartha@maersk                   Removed populateOpportunityOwner method
 * 14.0     SFSE-111    26-May-2020    manjunath@maersk                   Removed references and logic related to "Expected_FFE_Lead__c" object 
 * 15.0     SFSE-5309    16-Mar-2021   Meghana.Gupta@Ust                  Recalculate Must got to Omeb if Agreement dates or estimated duration is changed
 * 16.0     SFSE-5787    12-Apr-2021   Kiran@Maersk                       Stop Territory and Cluster Code fields from being populated on Opportunity
 * 16.1     SFSE-6523   21-Dec-2021    Meghana.Gupta@UST                  Removed invocation of methods from class SalesMetricFieldPopulator
 * 16.2     SFSE-9341   16-Sep-2022    Nitin@Maersk                       Added check before insert/update to validate Features Mandatory
 * 16.3     SFSE-9813   02-Jan-2023    Aleena@Maersk                      Logic to call updateOmebKpi,createOmebKpi from Utilities class
 * 16.4     SFSE-9502   01-Jun-2023     Kiran@Maersk                      Adding logic to populate Clone Opportunity Source. Clone with related to Clone functionality
 * 16.5     SFSE-10656  25-07-2023      Vinay@Maersk                      Added logic to call populateCreatorRole in onBeforeInsert
 * 16.6     SFSE-10610  04-Aug-2023    Shashi@Maersk                      Added logic to pass list of non omeb opportunities moving beyond designing proposal to Utilities class
 * 16.7     SFSE-11844  11-Aug-2023     Vazid@UST                         Added logic to prompt at upon closure of the opportunity if GP is 100k or above 
 * 16.8     SFSE-11594   30-Jun-2023   Sriram@maersk                      Opportunity Auto Renewal 
 * 17.1     SFSE-11281  15-Aug-2023     Jothsana@Maersk                     OMEB new product Air/LCL & MCS product changes
 * 17.2     SFSE-11517  15-Aug-2023     Aleena@Maersk                       OMEB new product Air/LCL & MCS product changes
 * 17.3     SFSE-12203  25-Aug-2023     Kiran@Maersk                        OMEB new products Air/LCL & MCS Live issue fixes
 * 18.0     SFSE-12560  22-Sep-2023     shashi@Maersk                       Remove Validation for Contract Logistics Financial fields
 * 19.0     SFSE-12165  22-Sep-2023     Jothsana@Maersk                     Validate Product Upgrade for OMEB opportunities
 * 20.0     SFSE-12889  16-Oct-2023     Jothsana@maersk.com                 To make OLI event publish queable
 * 20.1     SFSE-12888  16-Oct-2023     Aleena@maersk.com                   To make Opportunity event publish queable
 * 21.0     SFSE-12722  20-Oct-2023     Kiran@Maersk                        SOQL101 Error fixes
 * 22.0     SFSE-13499  19-Dec-2023     Shashi@Maersk                       Added logic to autopopulate "Business Process" field for P2Q journey
 * 23.0     SFSE-13322  04-Jan-2024     Jothsana@Maersk                     SFSE-13322      Remove the logic added for OMEB_Process_KPI__c object
 * 24.0     SFSE-13409  18-Jan-2024     Shilpa@Maersk                       Added logic to remove the non P2Q products from opportunity when Customer Journey marked as Instant quote       
 * 25.0     SFSE-13704  25-Jan-2024     Jothsana@Maersk                     Remove the logic added for creator role on opportunity
 * 26.0     SFSE-13852  29-Jan-2024     Avinash@Maersk                      Backend Data updates when Customer Journey field is updated in Oppty Details
 * 27.0     SFSE-13802 02-Feb-2024      Shilpa@maersk                       Added logic to prevention to change customer journey field when file opportunity files is uploaded and Quote is created.
 * 28.0     SFSE-14250  16-02-2024      Vinay@Maersk                        Added Logic to Nullify Offer Status field when an Opportunity is Clonned.
 * 29.0     SFSE-13681  24-Feb-2024     Shashi@Maersk                       Added logic for End of sales/service conditions
 * 30.0		SFSE-14064	16-Mar-2024		Vinay								Added a static variable to avoid Opportunity Renewal Recurssion.
 * 31.0     SFSE-14196  18-Mar-2024     Bharti@Maersk                       Added logic to validate Opp. while update auto renew drop down.  
 * 32.0     SFSE-14324   21/03/2024     ramadevi@maersk                     Update the Recommendation is the Opportunity is updated   
 * 33.0     SFSE-13670   22-Mar-2024    Anjali@Maersk                       Added logic in Before Insert and Update to populate X_Auto_Renew__c field and keep Auto_Renew__c in sync
 * 34.0		SFSE-14511	 08-04-2024		Avinash@Maersk						Site ID status update
 * 35.0     SFSE-14619   15-04-2024     Bharti@Maersk                       Added logic in Before Insert and Update to move the workflows/Builder logic into apex .
 * 36.0		SFSE-14210	19-04-2024		Jothsana@Maersk						Added logic to call product stamping when agreement dates are changed on opportunity
 * 37.0     SFSE-13391  02-May-2024     Shashi@Maersk                       Added logic to unlock opportunity record when opportunity is opened by LiveHelp
 * 38.0     SFSE-15070  30-05-2024    ramadevi@Maersk                       Update the Recommendation status to Obsolete on Opportunity Closed Lost
 * 39.0     SFSE-14825  05-05-2024    	Avinash@Maersk                      Cargo Type on Opportunity level
*/
 
public class OpportunityTriggerHandler extends TriggerHandler{
  
    public Map<Id, Opportunity> newMap;
    public Map<Id, Opportunity> oldMap;
    public List<Opportunity> oppList;
    public static boolean firstrun = true; 
    public static Boolean  isAutoRenewalFirstRun= TRUE;// SFSE-14064
    public OpportunityTriggerHandler() {
        
        this.newMap = ( map<Id, Opportunity> ) Trigger.newMap;
        this.oldMap = ( map<Id, Opportunity> ) Trigger.oldMap;
        this.oppList = (List<Opportunity>) Trigger.new;
        
    }
    
    // Use an OpportunityRecordSelector instance to initiate and form lists of opportunities that need to be considered for different functionalities
    public OpportunityRecordSelector opptyRecordSelector;
    
    public override void getRecordSelector() {
    
        if (opptyRecordSelector == null)
            opptyRecordSelector = new OpportunityRecordSelector( Trigger.new, this.oldMap, this);
            system.debug('Opp Trigger=getRecordSelector==>Test==>1==>'+Limits.getHeapSize()+'====='+Limits.getLimitHeapSize());        
    }
    
    public override void onBeforeInsert() {
        
        // Populate Liner Brand
        if ( !opptyRecordSelector.updateLinerBrandList.IsEmpty()){
            OpportunityFieldPopulator.populateLinerBrand ( opptyRecordSelector.updateLinerBrandList, OpportunityRecordSelector.loggedInUser );
        }
        System.debug(' before insert-populateLinerBrand' +' '+ Limits.getQueries());
        // Set standard price book as default price book
        //OpportunityFieldPopulator.SetPriceBook( opptyRecordSelector.newOpptyList );
        System.debug('before insert SetPriceBook' +' '+ Limits.getQueries());
        
        if(opptyRecordSelector.lstFastTrackOpportunity.size() > 0) {
            OpportunityFieldPopulator.populateTenderType(opptyRecordSelector.lstFastTrackOpportunity);
            System.debug(' before insert-populateTenderType' +' '+ Limits.getQueries());
        }
        if(!opptyRecordSelector.checkToUpdateOtherClosedReason.isEmpty()){
            OpportunityUtilities.removeOtherReasonForClosevalue(opptyRecordSelector.checkToUpdateOtherClosedReason);             
        }

        //10859-hard stop products
        /*if( !opptyRecordSelector.isSalesStageChanged.IsEmpty()){
            OpportunityUtilities.validateOppContainsOldProduct(opptyRecordSelector.isSalesStageChanged);
        }*/
        // OpportunityFieldPopulator.populateErrorCodes(opptyRecordSelector.newOpptyList);
        
        //SFSE-12881
        /*if(opptyRecordSelector.lstCloneOppty.size() > 0){
            OpportunityUtilities.checkOpptyCloneEligibility(opptyRecordSelector.lstCloneOppty);
        }*/ 
        
        //SFSE-13852 : Backend Data updates when Customer Journey field is updated in Oppty Details
        if(!opptyRecordSelector.lstOppCustJrnyFieldstoUpdt.isEmpty()){
            OpportunityFieldPopulator.populateCustomerJourneyBackendFields(opptyRecordSelector.lstOppCustJrnyFieldstoUpdt);
        }
      
        //SFSE-13499
        if(!opptyRecordSelector.lstOpptyPopulateBusinessProcessField.IsEmpty()){
            OpportunityUtilities.populateBusinessProcessFieldP2Q(opptyRecordSelector.lstOpptyPopulateBusinessProcessField);            
        }
        
      //SFSE-14250 For Cloned Opportunities, Nullify Offer Status Field.
        if(!opptyRecordSelector.listOpportuntiyOnClone.isEmpty()){
           OpportunityUtilities.resetFieldsOnClone (opptyRecordSelector.listOpportuntiyOnClone); 
        }

        //SFSE-13670 Update Auto-Renew Yes/No Acc. to Agreement Duration
        if(!opptyRecordSelector.lstOpptyXAutoRenew.isEmpty()){
           OpportunityUtilities.updateXAutoRenewYesorNo(opptyRecordSelector.lstOpptyXAutoRenew,null);
        }
       //SFSE- 14619 Update close Date when opp is created from lead conversion
        if(!opptyRecordSelector.lstToUpdateOppOnLeadConversion.isEmpty()){
            OpportunityUtilities.updateCloseDateOnLeadConversion(opptyRecordSelector.lstToUpdateOppOnLeadConversion);
        }
       //SFSE- 14619 Set Opp Name when Opp name given as X
        if(!opptyRecordSelector.lstToUpdateOppName.isEmpty()){
            OpportunityUtilities.updateOppName(opptyRecordSelector.lstToUpdateOppName);
        }
       
      
    }

    public override void onBeforeUpdate() {
        
        //SFSE-14825
        if(!opptyRecordSelector.mapOppoIdsWithInstantQuote.isEmpty()){
            OpportunityFieldPopulator.validateOppoProdCargoTypeForCustJrnyOppo(opptyRecordSelector.mapOppoIdsWithInstantQuote);
        }
        
        OpportunityUtilities.updateAutoRenew(this.oppList,this.oldMap);
        //SFSE- 14619  when opp is updated to closed lost/won then update close date. 
        if(!opptyRecordSelector.lstToUpdateOpp.isEmpty()){
            OpportunityUtilities.updateCloseDate(opptyRecordSelector.lstToUpdateOpp);
        }
        
        if(!opptyRecordSelector.lstOppValidateFootprintRequirementSqm.isEmpty()){
            OpportunityUtilities.validateSqmField(opptyRecordSelector.lstOppValidateFootprintRequirementSqm);
        } 
        //SFSE- 14619 when First time Opp. is move to closed lost populate first time close date.
        if(!opptyRecordSelector.lstToUpdateFirstTimeCloseDate.isEmpty()){
         
            OpportunityUtilities.updateFirstTimeClosedate(opptyRecordSelector.lstToUpdateFirstTimeCloseDate);
            
        }
        //SFSE- 14619 when Opp move to any stage except closed Lost/Won update sales qualified date
        if(!opptyRecordSelector.lstToUpdateSalesQualifieddate.isEmpty()){
            OpportunityUtilities.updateSalesqualified(opptyRecordSelector.lstToUpdateSalesQualifieddate);
        }
        
        //SFSE-13670 & SFSe-14196 Update Auto-Renew Yes/No Acc. to Agreement Duration
         if(!opptyRecordSelector.lstOpptyXAutoRenew.isEmpty()){
           OpportunityUtilities.updateXAutoRenewYesorNo(opptyRecordSelector.lstOpptyXAutoRenew, this.oldMap);
          
        } 
        //SFSe-14196
        if(!opptyRecordSelector.lstForValidateOpp.isEmpty()){
            OpportunityUtilities.validationOnAutorenew(opptyRecordSelector.lstForValidateOpp);

        }        
        //Check Destination Country on closed won stage
        
        // Populate Liner Brand
        if ( !opptyRecordSelector.updateLinerBrandList.IsEmpty())
            OpportunityFieldPopulator.populateLinerBrand ( opptyRecordSelector.updateLinerBrandList, OpportunityRecordSelector.loggedInUser );
            System.debug(' before update-populateLinerBrand' +' '+ Limits.getQueries());
       
        /*V7.0: Code commented to deprecate the Move to Tender funtionality.
        // Set stagename and type for opportunity when moving to Tender Opportunity
        if ( !opptyRecordSelector.moveToTenderOpptyList.IsEmpty())
          OpportunityFieldPopulator.populateTenderOppFields( opptyRecordSelector.moveToTenderOpptyList );
        */
        
        if(opptyRecordSelector.lstFastTrackOpportunity.size() > 0) {
            OpportunityFieldPopulator.populateTenderType(opptyRecordSelector.lstFastTrackOpportunity);
            System.debug(' before update-populateTenderType' +' '+ Limits.getQueries());
        }
        if(!opptyRecordSelector.checkDestinationCountry.IsEmpty()){
            OpportunityUtilities.validateDestinationCountryForAirLCLproducts(opptyRecordSelector.checkDestinationCountry);
        }
         

        if(!opptyRecordSelector.mapOpptyInQualifyingStage.isEmpty()) {
            OpportunityUtilities.validateQualifyStage(opptyRecordSelector.mapOpptyInQualifyingStage);
            System.debug(' before update-populateTenderType' +' '+ Limits.getQueries());
        }
        if ( !opptyRecordSelector.lstParentOpportunity.IsEmpty()){
            OpportunityUtilities.CheckIfParent(opptyRecordSelector.lstParentOpportunity);
            System.debug(' before update-CheckIfParent' +' '+ Limits.getQueries());
        }
        
        if (opptyRecordSelector.lstOpptyValidateSP.size() >0){
            OpportunityUtilities.validateFeaturesMandatory(opptyRecordSelector.lstOpptyValidateSP);
        }
        
        if(opptyRecordSelector.lstPEPOpptyHasPendingApprovals.size() > 0){
            //OpptyLineItemUtilities.validateOpptyPendingApprovalProcesses(null,opptyRecordSelector.lstPEPOpptyHasPendingApprovals);
            OpportunityProductUtilities.validateOpptyPendingApprovalProcesses(null, opptyRecordSelector.lstPEPOpptyHasPendingApprovals);
            System.debug(opptyRecordSelector.lstPEPOpptyHasPendingApprovals.size());
        }
        
        /*if(opptyRecordSelector.lstNonOmebOppty.size()>0){
            OpportunityUtilities.validateRequiredFieldsOppty(opptyRecordSelector.lstNonOmebOppty);
        }
        if(opptyRecordSelector.lstOmebOppty.size()>0){
            OpportunityUtilities.validateRequiredFieldsOppty(opptyRecordSelector.lstOmebOppty);
        }*/
      
      //SFSE-11281
        if(!opptyRecordSelector.checkForAirLclProd.isEmpty()){
            OpportunityUtilities.validateOpptyForALproducts(opptyRecordSelector.checkForAirLclProd); 
        }
        
        //SFSE-11517
        if(!opptyRecordSelector.checkForMCSProd.isEmpty()){
            OpportunityUtilities.validateOpptyForMCSproducts(opptyRecordSelector.checkForMCSProd);  
        }
        if(!opptyRecordSelector.opplist.isEmpty()){
            System.debug('Entered in handler');
            OpportunityUtilities.populateProductType(opptyRecordSelector.opplist);
        }
        if(!opptyRecordSelector.checkToUpdateOtherClosedReason.isEmpty()){
            OpportunityUtilities.removeOtherReasonForClosevalue(opptyRecordSelector.checkToUpdateOtherClosedReason);
        }
        
        //SFSE-13852 : Backend Data updates when Customer Journey field is updated in Oppty Details
        if(!opptyRecordSelector.lstOppCustJrnyFieldstoUpdt.isEmpty()){
            OpportunityFieldPopulator.populateCustomerJourneyBackendFields(opptyRecordSelector.lstOppCustJrnyFieldstoUpdt);
        }
        
        //SFSE-13499
        if(!opptyRecordSelector.lstOpptyPopulateBusinessProcessField.IsEmpty()){
            OpportunityUtilities.populateBusinessProcessFieldP2Q(opptyRecordSelector.lstOpptyPopulateBusinessProcessField);
        }

        //SFSE-13790
        if(!opptyRecordSelector.mapValidateRevenueFieldForNonOmeb.IsEmpty()){
           OpportunityUtilities.validateRevenueFieldforNonOmeb(opptyRecordSelector.mapValidateRevenueFieldForNonOmeb);
        }
        
        if(!opptyRecordSelector.lstOpptyToCheckCustomerJourney.isEmpty()){
          
            OpportunityUtilities.validateCustomerJourney(opptyRecordSelector.lstOpptyToCheckCustomerJourney);
            
        }
        
        If(!opptyRecordSelector.mapToOppvalidateOpportunityFiles.isEmpty()){
            OpportunityUtilities.validateOpportunityFiles(opptyRecordSelector.mapToOppvalidateOpportunityFiles);
            
        }  
       
        //SFSE-13681  
        if(!opptyRecordSelector.lstOpptyValidateProductRetirement.isEmpty()){
            OpportunityUtilities.validateProductRetirement(opptyRecordSelector.lstOpptyValidateProductRetirement, this.oldMap);
        } 
        
        //SFSE-14324        
        if(opptyRecordSelector.oppIdListToCheckRecomStatus.size()>0){
            OpportunityFieldPopulator.checkRecommendationStatusOnClose(opptyRecordSelector.oppIdListToCheckRecomStatus,opptyRecordSelector.OppHasRecomm);
        }
        
        //SFSE:14511
        if(!opptyRecordSelector.lstOptyWithInvalidWarehouseSites.isEmpty()){
            OpportunityFieldPopulator.populateCountOfInvalidWarehouseSite(opptyRecordSelector.mapOptyIdToProdWithValidWarehouseSites,opptyRecordSelector.lstOptyWithInvalidWarehouseSites);
        }
        
        //SFSE-13391 
        if(!opptyRecordSelector.lstReopenedOppty.isEmpty()){
            OpportunityUtilities.unlockOpportunityOnStageChange(opptyRecordSelector.lstReopenedOppty);
        }
        
        //SFSE-13391
        if(!opptyRecordSelector.lstOpptyValidateClosedUnlockedOppty.isEmpty() && !opptyRecordSelector.MapValidateClosedUnlockedOppty.isEmpty()){
            OpportunityUtilities.validateClosedUnlockedOppty(opptyRecordSelector.lstOpptyValidateClosedUnlockedOppty,opptyRecordSelector.MapValidateClosedUnlockedOppty);        
        }
       
        //SFSE-13391
        if(!opptyRecordSelector.lstReOpenedUnlockedOpportunity.isEmpty()){
            OpportunityUtilities.validateUnlockedReOpenedOppty(opptyRecordSelector.lstReOpenedUnlockedOpportunity);        
        }
       
     } 

    public override void onAfterInsert() {
        
        // Update opportunity team 
        if ( !opptyRecordSelector.addTeamMemberOpptyList.IsEmpty())
            OpportunityTeamMemberUtilities.UpdateOpportunityTeam ( opptyRecordSelector.addTeamMemberOpptyList, opptyRecordSelector.updateTeamMemberOldMap, Trigger.isInsert);
            System.debug(' after insert- UpdateOpportunityTeamt' +' '+ Limits.getQueries());
         
        //#RQ-008175 - To create Project templates, milestones and tasks when a tender opportunity is created
         if (!opptyRecordSelector.lstComplexOpportunity.IsEmpty() && !TriggerRecursionCounter.isOpportunityClone)
            TenderWorkflowUtilities.CreateProjectTemplates( opptyRecordSelector.lstComplexOpportunity );
        
        //RQ-012233
        if(opptyRecordSelector.lstOpptywithDngrGoods.size() > 0) // RQ-012233 - Mod-01
            OpportunityUtilities.addDngrsGoodsTeamMembers(opptyRecordSelector.lstOpptywithDngrGoods);
        
        
        //SFSE-9502
        if(!opptyRecordSelector.mapClonedOpptyToSourceId.isEmpty()){
            OpportunityUtilities.cloneOpporutnityProductsWithLatest(opptyRecordSelector.mapClonedOpptyToSourceId);
        }
        //12888 
        if(!opptyRecordSelector.lstOfOpptyForOpptyEvent.isEmpty() && (!System.isFuture() && !System.isBatch() && !System.isQueueable() && !System.isScheduled())){
           OpportunityEventUtilities.toFireQueableforOpptyEvent(new List<Id>(opptyRecordSelector.lstOfOpptyForOpptyEvent),true,true,true); 
        }else if(!opptyRecordSelector.lstOfOpptyForOpptyEvent.isEmpty() && (System.isFuture() || System.isBatch() || System.isQueueable() || System.isScheduled())){
            OpportunityEventUtilities.toFireOpptyEvent(new List<Id>(opptyRecordSelector.lstOfOpptyForOpptyEvent),true,true,true);
        }
    }
    
    
    public override void onAfterUpdate() {
        
        if ( !opptyRecordSelector.addTeamMemberOpptyList.IsEmpty()){
            OpportunityTeamMemberUtilities.UpdateOpportunityTeam ( opptyRecordSelector.addTeamMemberOpptyList, opptyRecordSelector.updateTeamMemberOldMap, false);
        }
        
        // Adjust ExpectedFEE and Product schedule
        //OpportunityToLineItemUtilities newOppProdSch = new OpportunityToLineItemUtilities();
        OpportunityToLineItemUtilities.AdjustUnassignedProdFEE_ProdSchedule ( this.newMap, this.oldMap );
        System.debug('After Update - AdjustUnassignedProdFEE_ProdSchedule' +' '+ Limits.getQueries());

        //  Update AFLS Quote Owners to be same as Opportunity Owner
        if ( !opptyRecordSelector.oppOwnerUpdateOpptyList.IsEmpty())
            OpportunityUtilities.UpdateAFLSQuoteOwner ( opptyRecordSelector.oppOwnerUpdateOpptyList );
            System.debug('After Update-UpdateAFLSQuoteOwner' +' '+ Limits.getQueries());     
        
        /*if(!opptyRecordSelector.toCloneQuarterlyDealOpptyList.IsEmpty()){
            OpportunityUtilities.CloneQuarterlyDealOpportunitiesOnClose(opptyRecordSelector.toCloneQuarterlyDealOpptyList, OpportunityRecordSelector.RelatedAccountsMap);           
        }
        
        //Create the new tender Opportunity along with OpportunityLine Item when Oldoppty is gets closed
        if ( !opptyRecordSelector.toCloneOpptyList.IsEmpty())        
            OpportunityUtilities.CloneTenderOpportunitiesOnClose( opptyRecordSelector.toCloneOpptyList, OpportunityRecordSelector.RelatedAccountsMap );
        */
        
       If(opptyRecordSelector.oppOwnerUpdated) {
            OpportunityUtilities.shareContract(Trigger.new, this.oldMap); 
        } 
        
        //#RQ-008622: Start
        if (!opptyRecordSelector.lstComplexOpportunity.IsEmpty())
            TenderWorkflowUtilities.CreateProjectTemplates( opptyRecordSelector.lstComplexOpportunity );
          System.debug('After Update - CreateProjectTemplates ' +' '+ Limits.getQueries());
        
        if (!opptyRecordSelector.lstNonComplexOpportunity.IsEmpty())
            TenderWorkflowUtilities.removeProjectTemplateDetails( opptyRecordSelector.lstNonComplexOpportunity);
        System.debug('After Update - removeProjectTemplateDetails ' +' '+ Limits.getQueries());
        //RQ-008622: End
        
        //#RQ-008622: Start
        if (!opptyRecordSelector.lstUnlockRecordApprovalProcess.IsEmpty()){
            System.debug ('$$$$# OpportunityUtilities.UnlockApprovalProcessRecord: ' + opptyRecordSelector.lstUnlockRecordApprovalProcess);
            // OpportunityUtilities.UnlockApprovalProcessRecord( opptyRecordSelector.lstUnlockRecordApprovalProcess );
            UpdateOpportunityUnlock updateJob = new UpdateOpportunityUnlock(opptyRecordSelector.lstUnlockRecordApprovalProcess);
            ID jobID = System.enqueueJob(updateJob);
            OpportunityUtilities.UnlockApprovalProcessRecord( opptyRecordSelector.lstUnlockRecordApprovalProcess );
            System.debug(' After Update - UnlockApprovalProcessRecord' +' '+ Limits.getQueries());
        }
        
        //RQ-012233
        if(opptyRecordSelector.lstOpptywithDngrGoods.size() > 0) // RQ-012233 - Mod-02
            OpportunityUtilities.addDngrsGoodsTeamMembers(opptyRecordSelector.lstOpptywithDngrGoods); 
        System.debug('After Update-addDngrsGoodsTeamMembers ' +' ' + Limits.getQueries());
        
        /*if(opptyRecordSelector.lstPEPOpptyHasPendingApprovals.size() > 0){
            OpptyLineItemUtilities.validateOpptyPendingApprovalProcesses(null, opptyRecordSelector.lstPEPOpptyHasPendingApprovals);
            System.debug(opptyRecordSelector.lstPEPOpptyHasPendingApprovals.size());
        }
        
        if(opptyRecordSelector.lstOpptyReevaluateOMEB.size() > 0){
            OpptyLineItemUtilities.checkProductsForOmeb(null, opptyRecordSelector.lstOpptyReevaluateOMEB, 'Update'); 
            System.debug('After Update-checkProductsForOmeb' +' '+ Limits.getQueries());
        }
        
        if(opptyRecordSelector.lstPEPOpptyHasPendingApprovals.size() > 0){
            OpportunityProductUtilities.validateOpptyPendingApprovalProcesses(null, opptyRecordSelector.lstPEPOpptyHasPendingApprovals);
        }*/
        
        if(!opptyRecordSelector.lstOpptyReevaluateOMEB.isEmpty() && !opptyRecordSelector.lstOfOMEBoli.isEmpty()){
          OpportunityProductUtilities.ProductListUpdate(opptyRecordSelector.lstOfOMEBoli);
            OpportunityProductUtilities.checkProductsForOmeb(null, opptyRecordSelector.lstOpptyReevaluateOMEB, 'Update'); 
          //OpportunityProductUtilities.ProductListUpdate(opptyRecordSelector.lstOpptyReevaluateOMEB); 
            System.debug('After Update-checkProductsForOmeb' +' '+ Limits.getQueries());
        }
        
        //SFSE-10656
        if(opptyRecordSelector.oppIAcceptSet.size() > 0 && !opptyRecordSelector.oppIAcceptSet.isEmpty()) {
            //If(StopTriggerRecurssion.isFirstTime){
            //StopTriggerRecurssion.isFirstTime = false;
          //  OneClickValidationHelper.checkAllValidation(opptyRecordSelector.oppIAcceptSet,'trigger');
        }
        
        if(!opptyRecordSelector.lstForOLIEvent.isEmpty() && (!System.isFuture() && !System.isBatch() && !System.isQueueable() && !System.isScheduled())){
            OLIEventResponseHandler.fireQueableOliEventsAsync(opptyRecordSelector.lstForOLIEvent, true, true, true, false);
        }else if(!opptyRecordSelector.lstForOLIEvent.isEmpty() && (!System.isFuture() && !System.isBatch() && !System.isQueueable() && !System.isScheduled())){
            OLIEventResponseHandler.fireOliEventAsync(opptyRecordSelector.lstForOLIEvent, true, true, true, false);
        }

        //#RQ RAM
        //if(!opptyRecordSelector.lstOpptyclosedwonLost.IsEmpty()){
        //OpportunityUtilities.deleteOpptyProdConfigRecords(opptyRecordSelector.lstOpptyclosedwonLost);
        //}
        
        //Opportunity AutoRenewal SFSE-11594
        if(!opptyRecordSelector.autoRenewalOpportunities.isEmpty() && isAutoRenewalFirstRun){
           
            // Id batchJobId = Database.executeBatch(new BatchOpportunityAutoRenewal(opptyRecordSelector.autoRenewalOpportunities), 200);
            OpportunityAutoRenewal.OpportunityAutoRenewal(opptyRecordSelector.autoRenewalOpportunities);
            isAutoRenewalFirstRun=FALSE; //SFSE-14064
           
        }
    
       //SFSE-11844 : Prompt the feedback widget component upon closure of the opportunity if GP is 100k or above. 
        if(!opptyRecordSelector.lstOfOptyIdsForFBs.IsEmpty()){
            FeedbackController.createFBInviteRecordLevel(Label.Opportunity_Functionality, true, opptyRecordSelector.lstOfOptyIdsForFBs[0]);
        }
        /*system.debug('enddatelstOpptyClosedBy90Days_'+opptyRecordSelector.lstOpptyClosedBy90Days.size());
        if (opptyRecordSelector.lstOpptyClosedBy90Days.size() > 0){
            
            OpportunityUtilities.ShowChatterForEndDate90Days(opptyRecordSelector.lstOpptyClosedBy90Days);
        }*/
           //SFSE-11466 :- Promopt an error if new versio of product doesn't have the service and non-service Available for non-omeb
           //SFSE-12165 :- Promopt an error if new version of product doesn't have the service and non-service Available for omeb
        if(!opptyRecordSelector.lstForOpptyProductUpgrade.isEmpty()){
            OpportunityUtilities.validateOpportunityProductUpgrade(opptyRecordSelector.lstForOpptyProductUpgrade);
        }
        
        
        
        
        system.debug('batch--'+System.isBatch());
        //12888
        if(!opptyRecordSelector.lstOfOpptyForOpptyEvent.isEmpty() && (!System.isFuture() && !System.isBatch() && !System.isQueueable() && !System.isScheduled())){
           OpportunityEventUtilities.toFireQueableforOpptyEvent(new List<Id>(opptyRecordSelector.lstOfOpptyForOpptyEvent),true,true,true); 
        }else if(!opptyRecordSelector.lstOfOpptyForOpptyEvent.isEmpty() && (System.isFuture() || System.isBatch() || System.isQueueable() || System.isScheduled())){
            OpportunityEventUtilities.toFireOpptyEvent(new List<Id>(opptyRecordSelector.lstOfOpptyForOpptyEvent),true,true,true);
        }

        //SFSE-14324
        if(opptyRecordSelector.recomList.size()>0){
            OpportunityFieldPopulator.updateRecommendationAsInvalid(opptyRecordSelector.recomList,'Is_valid__c');
        }
        //SFSE-15070
        if(opptyRecordSelector.oppIdToUpdateStatus.size()>0){            
            OpportunityFieldPopulator.updateRecommendationAsInvalid(opptyRecordSelector.oppIdToUpdateStatus,'Status__c');
        }                 
        
  }
   
}