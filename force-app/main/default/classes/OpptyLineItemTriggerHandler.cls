/* 
 * Author   : Madhava
 * Purpose  : Single trigger for OpportunityLineItem object as per CBO architecture
 * 
 * Revision     Ref Number      Date            Owner                         Description
 * --------     ----------      -----------     -------------------           -----------
 * 6.0          #RQ-013090       17/03/2020     Meghana@ust					Amend Quantity for complex deals, ocean products
 * 7.0          #RQ-013336       28/04/2020     Neha-TCS					Query Recordttype. developer name for opptyMap 
 * 8.0          SFSE-5309        02/Mar/2021    Meghana@UST					Call method to check Meets OMEB conditions
 * 9.0          SFSE-6737        02/Aug/2021    Neha@TCS					Update the method for recreating schedule to pass boolean to check if it cloned. Also
                                                							invoke deleteDefaultScheduleOppLineItem() in afterupdate
 * 9.1     		SFSE-6523    	21-Dec-2021	    Meghana.Gupta@Ust			Removing references to class Sales Metric object
 *10.0          SFSE-8606       27-Jun-2022     Meghana@UST					Method execution to create corridor guidance added. Code removed from Scheudle method
 * 11			SFSE-8521		04-Jul-2022		Rakesh@Maersk				Handle Cloning Opportunity Product Features on Opp clone
 * 14.0			SFSE-9417		18-Oct-2022		Kiran@Maersk				Adding VR to stop creatining OLI if Opportunity approval status is Approved Solution Gate and StageName is Quoting
 * 15.0         SFSE-9824       16-Nov-2022     Arpitha@Maersk              VR added as part of SFSE-9417 is modified to consider only OMEP Products.
 * 16.0			SFSE-10967		28-Apr-2023		Kiran@Maersk				Fix for CL product Annualized gross profit update
// Feature_PKA1 chagnes
 */
public class OpptyLineItemTriggerHandler extends TriggerHandler{
    public map<Id, OpportunityLineItem> newMap;
    public map<Id, OpportunityLineItem> oldMap;
    public map<Id, Opportunity> opptyMap;
    public set<Id> opptyId = new set<Id>();
    public set<Id> prodId = new set<Id>();
    public map<Id,Product2> prodMap;
    
    public opptyLineItemTriggerHandler() {
        this.newMap = (map<Id, OpportunityLineItem>)Trigger.newMap;
        this.oldMap = (map<Id, OpportunityLineItem>)Trigger.oldMap; 
        
        // Get opportunity id whose line item is updated
        
        //if(trigger.isAfter && trigger.isUpdate) {
        if( trigger.isUpdate ) {
            for(OpportunityLineItem newOpptyLineItem : this.newMap.values()) {
                prodId.add(newOpptyLineItem.Product2id);
                opptyId.add(newOpptyLineItem.opportunityId);
            }
        }
        
        if( trigger.isInsert ) {
            for(OpportunityLineItem newOpptyLineItem : (List<OpportunityLineItem>)trigger.new) {
                 prodId.add(newOpptyLineItem.Product2id);
                opptyId.add(newOpptyLineItem.opportunityId);
            }
        }
        
        if( trigger.isDelete ) {
            for(OpportunityLineItem newOpptyLineItem : this.oldMap.values()) {
                prodId.add(newOpptyLineItem.Product2id);
                opptyId.add(newOpptyLineItem.opportunityId);
            }
        }
        
        if( trigger.isInsert ) {
            for(OpportunityLineItem newOpptyLineItem : (List<OpportunityLineItem>)trigger.new) {
                opptyId.add(newOpptyLineItem.opportunityId);
            }
        }
        
        if( trigger.isDelete ) {
            for(OpportunityLineItem newOpptyLineItem : this.oldMap.values()) {
                opptyId.add(newOpptyLineItem.opportunityId);
            }
        }
        
        // v6.0 Added RecordTypeId in SOQL
        if(opptyId.size() > 0) {
            opptyMap = new map<Id, Opportunity>([SELECT id, IsClosed, StageName, Approval_Status__c, Must_Go_To_OMEB__c, RecordTypeId, RecordType.DeveloperName 
                                                 FROM Opportunity WHERE Id IN: opptyId]);
        }
        
        if(!prodId.isEmpty()){
            prodMap = new map<Id,Product2>([Select id,Include_in_OMEB_Approvals__c from Product2 where id=:prodId]);
        }
        system.debug('$$$ opptyMap '+ opptyMap);
    }
    
    // Get valid records based on criteria
    public OppLineItemRecordSelector oppLineItmRecordSelector;
    public override void getRecordSelector() {
        system.debug('$$$ opptyMap '+ opptyMap);
        oppLineItmRecordSelector = new OppLineItemRecordSelector(Trigger.new, this.oldMap, this, this.opptyMap,prodMap);
    }
    
    public override void onBeforeInsert() {
        OpptyLineItemFieldPopulator.updateOpptyLineFields(trigger.new,this.OldMap, oppLineItmRecordSelector.VRBypassIsActive, oppLineItmRecordSelector.closedOppMap);
        if(oppLineItmRecordSelector.approvedSGOptyQuoteStage.size() > 0){
            OpptyLineItemUtilities.validateOpptyStageApprovalStatus(oppLineItmRecordSelector.approvedSGOptyQuoteStage);
        }
        
        //SFSE-9417 Stop creating/updating/deleting OLI if OMEB Opportunity has pending approvals
        if(oppLineItmRecordSelector.oliOpptyWithPendingApprovals.size() > 0){
            OpptyLineItemUtilities.validateOpptyPendingApprovalProcesses(oppLineItmRecordSelector.oliOpptyWithPendingApprovals, null);
        }
    }
    
    public override void onBeforeUpdate() {
        system.debug('entered before update');
        OpptyLineItemFieldPopulator.updateOpptyLineFields(trigger.new,this.OldMap, oppLineItmRecordSelector.VRBypassIsActive, oppLineItmRecordSelector.closedOppMap);  
    
        // v6.0 call method to update amend quantity based on product owner target or nominated qty
        OpptyLineItemFieldPopulator.updateAmendQty(oppLineItmRecordSelector.lstSetQuantityToProductOwnerTarget , oppLineItmRecordSelector.lstSetQuantityToNominatedQuantity);
        
        //SFSE-9417 Stop creating/updating/deleting OLI if OMEB Opportunity has pending approvals
        if(oppLineItmRecordSelector.oliOpptyWithPendingApprovals.size() > 0){
            OpptyLineItemUtilities.validateOpptyPendingApprovalProcesses(oppLineItmRecordSelector.oliOpptyWithPendingApprovals, null);
        }
    }
    
    public override void onAfterInsert() {
        system.debug('on after insert');
        system.debug('oppLineItmRecordSelector.isClone>>>'+oppLineItmRecordSelector.isClone);

         //Hanlde Cloned Opportunity Products - SFSE-8521
        if(!oppLineItmRecordSelector.sourceIdClonedIdMap.isEmpty()){
            OpptyLineItemUtilities.cloneProductFeatures(oppLineItmRecordSelector.sourceIdClonedIdMap);
        }

        OpptyLineItemUtilities.ProductListUpdate(trigger.new); 
        OpptyLineItemSchedulingHelper.setScheduleDetailsOnOLIAfterInsert(trigger.new); 
        
        
        // Within method check is done to check Oppty record type using OpportnityMap
        OpptyLineItemUtilities.createCorridorGuidance(trigger.new, oppLineItmRecordSelector.opportunityMap);
        
         if (oppLineItmRecordSelector.lstOmebCheck.size() > 0){
            OpptyLineItemUtilities.checkProductsForOmeb(oppLineItmRecordSelector.lstOmebCheck, null, 'Insert');
        }
        
        if (!oppLineItmRecordSelector.isClone) {
            system.debug('entered clone');
            OpptyLineItemSchedulingHelper.scheduleOppLineItem(trigger.new,trigger.old,oppLineItmRecordSelector.opportunityMap, oppLineItmRecordSelector.closedOppMap );
        }
        else{
            OpptyLineItemSchedulingHelper.reCreateScheduleOppLineItem(trigger.new,oppLineItmRecordSelector.isClone);
        }
    }
    
    public override void onAfterUpdate() {

        system.debug('@@@ oppLineItmRecordSelector.isClone '+oppLineItmRecordSelector.isClone);
        // This would delete the schedule of parent Opp when being cloned        
        if (oppLineItmRecordSelector.isClone) {
            OpptyLineItemSchedulingHelper.deleteDefaultScheduleOppLineItem(trigger.new, true);
        }

        if (! oppLineItmRecordSelector.lstOptOutSelected.isEmpty()) {
            OpptyLineItemSchedulingHelper.deleteDefaultScheduleOppLineItem(oppLineItmRecordSelector.lstOptOutSelected, false);
        }

        if (CheckTriggerRecursive.runOnce()){
            if(oppLineItmRecordSelector.lstAmendedFFEProducts.Size() > 0){
                system.debug('@@@entered after first date');
                OpptyLineItemSchedulingHelper.reCreateScheduleOppLineItem(oppLineItmRecordSelector.lstAmendedFFEProducts,oppLineItmRecordSelector.isClone);
            }else{
                OpptyLineItemSchedulingHelper.setScheduleDetailsOnOLI(trigger.new, this.OldMap);
            }
        }
        
        system.debug('@@@entered after first date'); 
        OpptyLineItemSchedulingHelper.scheduleOppLineItem(trigger.new,trigger.old,oppLineItmRecordSelector.opportunityMap, oppLineItmRecordSelector.closedOppMap);
        if(oppLineItmRecordSelector.lstChangedCountryProduct.Size() > 0){
            system.debug('@@@entered oppLineItmRecordSelector.lstChangedCountryProduct'+oppLineItmRecordSelector.lstChangedCountryProduct);
            OpptyLineItemUtilities.ProductListUpdate(oppLineItmRecordSelector.lstChangedCountryProduct); 
        }
        
        if (oppLineItmRecordSelector.lstAmendGP.size() > 0){
            OpptyLineItemSchedulingHelper.updateOliGP(oppLineItmRecordSelector.lstAmendGP);
        }
        
        if (oppLineItmRecordSelector.lstOmebCheck.size() > 0){
            OpptyLineItemUtilities.checkProductsForOmeb(oppLineItmRecordSelector.lstOmebCheck, null, 'Update');
        }
        
        if(oppLineItmRecordSelector.lstChangedAnnualizedGrossProfitCLProduct.Size() > 0){
            system.debug('@@@entered oppLineItmRecordSelector.lstChangedAnnualizedGrossProfitCLProduct'+oppLineItmRecordSelector.lstChangedAnnualizedGrossProfitCLProduct);
            OpptyLineItemUtilities.ProductListUpdate(oppLineItmRecordSelector.lstChangedAnnualizedGrossProfitCLProduct); 
        }
    }

    public override void onAfterDelete() {
        OpptyLineItemSchedulingHelper.OppLineItemOnDelete(this.OldMap,oppLineItmRecordSelector.opportunityMap, oppLineItmRecordSelector.closedOppMap);
        OpptyLineItemSchedulingHelper.validateoliOnDelete(this.OldMap,oppLineItmRecordSelector.closedOppMap, oppLineItmRecordSelector.VRBypassIsActive);
        OpptyLineItemUtilities.ProductListUpdate(trigger.old); 
        
         if (oppLineItmRecordSelector.lstOmebCheck.size() > 0){
            OpptyLineItemUtilities.checkProductsForOmeb(oppLineItmRecordSelector.lstOmebCheck, null, 'Delete');
        }
     }
    
    public override void onBeforeDelete() {
        //SFSE-9417 Stop creatining/deleting OLI if OMEB Opportunity in Quoting/Negotiating stage
        if(oppLineItmRecordSelector.approvedSGOptyQuoteStage.size() > 0){
            OpptyLineItemUtilities.validateOpptyStageApprovalStatus(oppLineItmRecordSelector.approvedSGOptyQuoteStage);
        }
        
        //SFSE-9417 Stop creating/updating/deleting OLI if OMEB Opportunity has pending approvals
        if(oppLineItmRecordSelector.oliOpptyWithPendingApprovals.size() > 0){
            OpptyLineItemUtilities.validateOpptyPendingApprovalProcesses(oppLineItmRecordSelector.oliOpptyWithPendingApprovals, null);
        }
    }
    // Feature_PKA1 chagnes
    // Feature_PKA1 chagnes
    // Feature_PKA1 chagnes
   
}