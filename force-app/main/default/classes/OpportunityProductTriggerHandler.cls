/*      
* Revision      Ref Number      Date            Owner                       Description
* --------      ----------      -----------     -------------------         -------------------------
* 1.0           SFSE-10984      16-May-2023     mahanthi.devi@maersk.com    To replicate standard OLI Trigger Logic on cutom object Opportunity Product .
* 1.1           SFSE-10984      23-May-2023     Kiran@Maersk                Cont
* 1.2           SFSE-10900      29-May-2023     Samarpreet@maersk.com       Add Logic for Opportunity Product Platform Event  .
* 1.3           SFSE-9052       02-Jun-2023     Kiran@Maersk                Removing the logic implemented as part of SFSE-8521
* 2.1           SFSE-11281      15-Aug-2023     Jothsana@Maersk             OMEB new product Air/LCL & MCS product changes
* 2.2           SFSE-11517      15-Aug-2023     Aleena@Maersk               OMEB new product Air/LCL & MCS product changes
* 2.3           SFSE-12203      25-Aug-2023     Kiran@Maersk                OMEB new products Air/LCL & MCS Live issue fixes
* 3.0           SFSE-12889      16-Oct-2023     Jothsana@maersk.com         To make OLI event publish queable
* 3.1           SFSE-12888      16-Oct-2023     Aleena@maersk.com           To make opportunity event publish queable
 * 4.0          SFSE-12722      20-Oct-2023     Kiran@Maersk                SOQL101 Error fixes
* 5.0           SFSE-13638      30-Jan-2024     Samar@maersk.com            Opportunity product revenue schedule
* 6.0           SFSE-14128      30-feb-2024     ramya@maersk.com            Remove the sync between standard and custom objects
* 7.0           SFSE-14324      21/03/2024      ramadevi@maersk             Update the Recommendation is the Opportunity Product is deleted  
* 8.0          SFSE-14428      23-Apr-2024     Avinash@Maersk            Refine the code to overcome the governor limits.
* 9.0          SFSE-14825      28-May-2024     Avinash@Maersk              "Cargo type" on Opportunity level
*/

public class OpportunityProductTriggerHandler extends TriggerHandler{
    public map<Id, Opportunity_Product__c> newMap;
    public map<Id, Opportunity_Product__c> oldMap;
    
    //SFSE-14428 - start - Commented below lines
    //public map<Id, Opportunity> opptyMap;
    //public set<Id> opptyId = new set<Id>();
    //public set<Id> prodId = new set<Id>();
    //public map<Id,Product2> prodMap;
    //SFSE-14428 - end
    
    public OpportunityProductTriggerHandler() {
        this.newMap = (map<Id, Opportunity_Product__c>)Trigger.newMap;
        this.oldMap = (map<Id, Opportunity_Product__c>)Trigger.oldMap; 
        
        //SFSE-14428 - start - Commented below lines
        // Get opportunity id whose line item is updated
        /*if( trigger.isUpdate ) {
            
            for(Opportunity_Product__c newOpptyProduct : this.newMap.values()) {
                prodId.add(newOpptyProduct.Product2ID__c);
                opptyId.add(newOpptyProduct.opportunityId__c);
            }
        }
        
        if( trigger.isInsert ) {
            
            for(Opportunity_Product__c newOpptyProduct : (List<Opportunity_Product__c>)trigger.new) {
                 prodId.add(newOpptyProduct.Product2ID__c);
                opptyId.add(newOpptyProduct.opportunityId__c);
            }
        }
        
        if( trigger.isDelete ) {
            
            for(Opportunity_Product__c newOpptyProduct : this.oldMap.values()) {
                prodId.add(newOpptyProduct.Product2ID__c);
                opptyId.add(newOpptyProduct.opportunityId__c);
            }
        }
        
        // v6.0 Added RecordTypeId in SOQL
        if(opptyId.size() > 0 && (opptyMap == NULL || opptyMap.isEmpty())) {
            opptyMap = new map<Id, Opportunity>([SELECT id, Name, IsClosed, StageName, Approval_Status__c, Requires_Custom_Integration__c, Requires_IT_Integration__c, Must_Go_To_OMEB__c, 
                                                 RecordTypeId, RecordType.DeveloperName, TotalOpportunityQuantity, First_Shipment_Date__c, Last_Shipment_Date__c
                                                 FROM Opportunity WHERE Id IN: opptyId]);
        }
        
        if(!prodId.isEmpty()){
            prodMap = new map<Id,Product2>([Select id, Name, Include_in_OMEB_Approvals__c,Portfolio__c,Is_Product_Solution__c from Product2 where id=:prodId]);
        }
        //SFSE-14428 - End 
        */
    }
    
    // Get valid records based on criteria
    public OpportunityProductRecordSelector OpptyProdRecordSelector;
    public override void getRecordSelector() {
        if (OpptyProdRecordSelector == null)
        OpptyProdRecordSelector = new OpportunityProductRecordSelector(Trigger.new, this.oldMap, this/*, this.opptyMap,prodMap*/);
    }
    
    public override void onBeforeInsert() {
        
        OpportunityProductFieldPopulator.updateOpptyProdName(trigger.new,this.OldMap, OpptyProdRecordSelector.VRBypassIsActive, OpportunityProductRecordSelector.opptyMap, OpportunityProductRecordSelector.prodMap);//SFSE-14428 -Getting opptyMap and prodMap from OpportunityProductRecordSelector
        OpportunityProductFieldPopulator.updateOpptyProdFields(trigger.new,this.OldMap, OpptyProdRecordSelector.VRBypassIsActive, OpptyProdRecordSelector.closedOppMap);
        if(OpptyProdRecordSelector.approvedSGOptyQuoteStage.size() > 0){
            OpportunityProductUtilities.validateOpptyStageApprovalStatus(OpptyProdRecordSelector.approvedSGOptyQuoteStage);
        }
        
        //SFSE-9417 Stop creating/updating/deleting OLI if OMEB Opportunity has pending approvals
        if(OpptyProdRecordSelector.OppProdOpptyWithPendingApprovals.size() > 0){
            OpportunityProductUtilities.validateOpptyPendingApprovalProcesses(OpptyProdRecordSelector.OppProdOpptyWithPendingApprovals, null);
        }
    }
    
    public override void onBeforeUpdate() {
               
        OpportunityProductFieldPopulator.updateOpptyProdName(trigger.new,this.OldMap, OpptyProdRecordSelector.VRBypassIsActive, OpportunityProductRecordSelector.opptyMap, OpportunityProductRecordSelector.prodMap);//SFSE-14428 -Getting opptyMap and prodMap from OpportunityProductRecordSelector
        OpportunityProductFieldPopulator.updateOpptyProdFields(trigger.new,this.OldMap, OpptyProdRecordSelector.VRBypassIsActive, OpptyProdRecordSelector.closedOppMap);  
    
        // v6.0 call method to update amend quantity based on product owner target or nominated qty
        OpportunityProductFieldPopulator.updateAmendQty(OpptyProdRecordSelector.lstSetQuantityToProductOwnerTarget);
        //Stop creating/updating/deleting OLI if OMEB Opportunity has pending approvals
        if(OpptyProdRecordSelector.OppProdOpptyWithPendingApprovals.size() > 0){
            OpportunityProductUtilities.validateOpptyPendingApprovalProcesses(OpptyProdRecordSelector.OppProdOpptyWithPendingApprovals, null);
        }
    }
    
    public override void onAfterInsert() {

        //SFSE-14825
        if(!OpportunityProductRecordSelector.setOptyToUpdtCargoType.isEmpty()){
            OpportunityProductFieldPopulator.updateOptyCargoType(OpportunityProductRecordSelector.setOptyToUpdtCargoType);
        }
        
       	OpportunityProductUtilities.ProductListUpdate(trigger.new); 
        OpportunityProductSchedulingHelper.setScheduleDetailsOnOLIAfterInsert(trigger.new); 
        //System.enqueueJob(new OpportunityProdSchQueueable(trigger.new, null, null, null, null, 'setScheduleDetailsOnOLIAfterInsert'));
        
        
        // Within method check is done to check Oppty record type using OpportnityMap
        OpportunityProductUtilities.createCorridorGuidance(trigger.new, OpptyProdRecordSelector.opportunityMap);
        
        if (OpptyProdRecordSelector.lstOmebCheck.size() > 0){
            OpportunityProductUtilities.checkProductsForOmeb(OpptyProdRecordSelector.lstOmebCheck, null, 'Insert');
        }
        
        if (!OpptyProdRecordSelector.isClone) {
            OpportunityProductSchedulingHelper.scheduleOppLineItem(trigger.new,trigger.old,OpptyProdRecordSelector.opportunityMap, OpptyProdRecordSelector.closedOppMap );
            //System.enqueueJob(new OpportunityProdSchQueueable(trigger.new, this.OldMap, OpptyProdRecordSelector.opportunityMap, OpptyProdRecordSelector.closedOppMap, OpptyProdRecordSelector.isClone, 'scheduleOppLineItemInsert'));
        }
        else{
            OpportunityProductSchedulingHelper.reCreateScheduleOppLineItem(trigger.new,OpptyProdRecordSelector.isClone);
            //System.enqueueJob(new OpportunityProdSchQueueable(trigger.new, null, null, null, OpptyProdRecordSelector.isClone, 'reCreateScheduleOppLineItemInsert'));
        }
        
        // Future Method to process OpportunityLineItem Platform Event
        if(OpptyProdRecordSelector.lstOpptyProductIdtoProcess.size()>0 && (!System.isFuture() && !System.isBatch() && !System.isQueueable() && !System.isScheduled())){
            OLIEventResponseHandler.fireQueableOliEventsAsync(OpptyProdRecordSelector.lstOpptyProductIdtoProcess, false, true, true,true);
        }else if(OpptyProdRecordSelector.lstOpptyProductIdtoProcess.size()>0 && (System.isFuture() || System.isBatch() || System.isQueueable() || System.isScheduled())){
            OLIEventResponseHandler.fireOliEventAsync(OpptyProdRecordSelector.lstOpptyProductIdtoProcess, false, true, true,true);
        }
        
        //OppoProductSchUtilities.createstdOli(Trigger.New,OpptyProdRecordSelector.opportunityMap, OpptyProdRecordSelector.closedOppMap);
        //commented below line for 14128 removal of sync between std and custom obj of opp prod and sch
        //InsertStdOppProductQueueable queueable = new InsertStdOppProductQueueable(trigger.new, null, OpptyProdRecordSelector.opportunityMap, OpptyProdRecordSelector.closedOppMap);
        //InsertStdOppProductQueueable queueable = new InsertStdOppProductQueueable(trigger.new);
        //null, OpptyProdRecordSelector.opportunityMap, OpptyProdRecordSelector.closedOppMap);
        //commented below line for 14128 removal of sync between std and custom obj of opp prod and sch
        //System.enqueueJob(queueable);
        //10656
         if(OpptyProdRecordSelector.oppIAcceptSet.size() > 0) {
            OneClickValidationHelper.checkAllValidation(OpptyProdRecordSelector.oppIAcceptSet,'trigger');
        }
        
         //12888
        if(OpptyProdRecordSelector.lstOfOpportunityProductForEvent.size()>0 && (!System.isFuture() && !System.isBatch() && !System.isQueueable() && !System.isScheduled())){
             OpportunityEventUtilities.toFireQueableforOpptyEvent(new List<Id>(OpptyProdRecordSelector.lstOfOpportunityProductForEvent),true,true,true); 
        }else if(OpptyProdRecordSelector.lstOfOpportunityProductForEvent.size()>0 && (System.isFuture() || System.isBatch() || System.isQueueable() || System.isScheduled())){
            OpportunityEventUtilities.toFireOpptyEvent(new List<Id>(OpptyProdRecordSelector.lstOfOpportunityProductForEvent),true,true,true);
        } 
    }
    
    public override void onAfterUpdate() {
      
        //SFSE-14825
        if(!OpportunityProductRecordSelector.setOptyToUpdtCargoType.isEmpty()){
            OpportunityProductFieldPopulator.updateOptyCargoType(OpportunityProductRecordSelector.setOptyToUpdtCargoType);
        }
        
        // This would delete the schedule of parent Opp when being cloned        
        if (OpptyProdRecordSelector.isClone) {
            OpportunityProductSchedulingHelper.deleteDefaultScheduleOppLineItem(trigger.new, true);
        }

        if (! OpptyProdRecordSelector.lstOptOutSelected.isEmpty()) {
            OpportunityProductSchedulingHelper.deleteDefaultScheduleOppLineItem(OpptyProdRecordSelector.lstOptOutSelected, false);
        }

        if (CheckTriggerRecursive.runOnce()){
            if(OpptyProdRecordSelector.lstAmendedFFEProducts.Size() > 0){
                OpportunityProductSchedulingHelper.reCreateScheduleOppLineItem(OpptyProdRecordSelector.lstAmendedFFEProducts,OpptyProdRecordSelector.isClone);
                //System.enqueueJob(new OpportunityProdSchQueueable(OpptyProdRecordSelector.lstAmendedFFEProducts, null, null, null, OpptyProdRecordSelector.isClone, 'reCreateScheduleOppLineItem'));
            }else{
                OpportunityProductSchedulingHelper.setScheduleDetailsOnOLI(trigger.new, this.OldMap);
                //System.enqueueJob(new OpportunityProdSchQueueable(trigger.new, this.OldMap, null, null, null, 'setScheduleDetailsOnOLI'));
            }
        }
        
        OpportunityProductSchedulingHelper.scheduleOppLineItem(trigger.new,trigger.old,OpptyProdRecordSelector.opportunityMap, OpptyProdRecordSelector.closedOppMap);
        //System.enqueueJob(new OpportunityProdSchQueueable(trigger.new, this.OldMap, OpptyProdRecordSelector.opportunityMap, OpptyProdRecordSelector.closedOppMap, null, 'scheduleOppLineItem'));
        
        if (OpptyProdRecordSelector.lstAmendGP.size() > 0){
            OpportunityProductSchedulingHelper.updateOliGP(OpptyProdRecordSelector.lstAmendGP);
        }
        
        if (OpptyProdRecordSelector.lstAmendedRevenueProducts.size() > 0){
            OpportunityProductSchedulingHelper.updateOliRevenue(OpptyProdRecordSelector.lstAmendedRevenueProducts);// SFSE-13638
        }
        
        if (OpptyProdRecordSelector.lstOmebCheck.size() > 0){
            OpportunityProductUtilities.ProductListUpdate(OpptyProdRecordSelector.lstOmebCheck);
            OpportunityProductUtilities.checkProductsForOmeb(OpptyProdRecordSelector.lstOmebCheck, null, 'Update');
        }
        
        if(OpptyProdRecordSelector.lstChangedCountryProduct.Size() > 0){
            OpportunityProductUtilities.ProductListUpdate(OpptyProdRecordSelector.lstChangedCountryProduct); 
        }

        if(OpptyProdRecordSelector.lstChangedAnnualizedGrossProfitCLProduct.Size() > 0){
            OpportunityProductUtilities.ProductListUpdate(OpptyProdRecordSelector.lstChangedAnnualizedGrossProfitCLProduct); 
        }
        
        if(OppProductScheduleRecordSelector.oppProductScheduleTrigger && OpportunityProductRecordSelector.oppProductTrigger){
            //commented below two line for 14128 removal of sync between std and custom obj of opp prod and sch
           // UpdateStdOppProductQueueable queueableUpdate = new UpdateStdOppProductQueueable(trigger.new, null, OpptyProdRecordSelector.opportunityMap, OpptyProdRecordSelector.closedOppMap);
           // System.enqueueJob(queueableUpdate);
        }
        
         // Future Method to process OpportunityLineItem Platform Event
        if(OpptyProdRecordSelector.lstOpptyProductIdtoProcess.size()>0 && (!System.isFuture() && !System.isBatch() && !System.isQueueable() && !System.isScheduled())){
            OLIEventResponseHandler.fireQueableOliEventsAsync(OpptyProdRecordSelector.lstOpptyProductIdtoProcess, false, true, true,false);
        }else if(OpptyProdRecordSelector.lstOpptyProductIdtoProcess.size()>0 && (System.isFuture() || System.isBatch() || System.isQueueable() || System.isScheduled())){
            OLIEventResponseHandler.fireOliEventAsync(OpptyProdRecordSelector.lstOpptyProductIdtoProcess, false, true, true,false);
        }
        
        //10656
        if(OpptyProdRecordSelector.oppIAcceptSet.size() > 0 && OpptyProdRecordSelector.oppIAcceptSet !=null) {
            OneClickValidationHelper.checkAllValidation(OpptyProdRecordSelector.oppIAcceptSet,'trigger');
        }


        //12888
        if(OpptyProdRecordSelector.lstOfOpportunityProductForEvent.size()>0 && (!System.isFuture() && !System.isBatch() && !System.isQueueable() && !System.isScheduled())){
            OpportunityEventUtilities.toFireQueableforOpptyEvent(new List<Id>(OpptyProdRecordSelector.lstOfOpportunityProductForEvent),true,true,true); 
        }else if(OpptyProdRecordSelector.lstOfOpportunityProductForEvent.size()>0 && (System.isFuture() || System.isBatch() || System.isQueueable() || System.isScheduled())){
            OpportunityEventUtilities.toFireOpptyEvent(new List<Id>(OpptyProdRecordSelector.lstOfOpportunityProductForEvent),true,true,true);
        }
    }

    public override void onAfterDelete() {
        
        //SFSE-14825
        if(!OpportunityProductRecordSelector.setOptyToUpdtCargoType.isEmpty()){
            OpportunityProductFieldPopulator.updateOptyCargoType(OpportunityProductRecordSelector.setOptyToUpdtCargoType);
        }
        
        OpportunityProductSchedulingHelper.OppLineItemOnDelete(this.OldMap,OpptyProdRecordSelector.opportunityMap, OpptyProdRecordSelector.closedOppMap);
        OpportunityProductSchedulingHelper.validateoliOnDelete(this.OldMap,OpptyProdRecordSelector.closedOppMap, OpptyProdRecordSelector.VRBypassIsActive);
        //DeleteStdOppProductQueueable queueableDelete = new DeleteStdOppProductQueueable(trigger.new, null, OpptyProdRecordSelector.opportunityMap, OpptyProdRecordSelector.closedOppMap);
        //System.enqueueJob(queueableDelete);
        //OpportunityProductUtilities.ProductListUpdate(trigger.old); 
        
        OpportunityProductUtilities.ProductListUpdate(trigger.old); 
         if (OpptyProdRecordSelector.lstOmebCheck.size() > 0){
            OpportunityProductUtilities.checkProductsForOmeb(OpptyProdRecordSelector.lstOmebCheck, null, 'Delete');
        }

         //SFSE-14324 
        if (OpptyProdRecordSelector.oppToUpdateRecomm.size() > 0){
            OpportunityProductFieldPopulator.updateRecommendationAsInvalid(OpptyProdRecordSelector.oppToUpdateRecomm,OpptyProdRecordSelector.oppRecomUpdateType);
        }        
       
     }
    
    public override void onBeforeDelete() {
        
        //Stop creating/deleting OLI if OMEB Opportunity in Quoting/Negotiating stage
        if(OpptyProdRecordSelector.approvedSGOptyQuoteStage.size() > 0){
            OpportunityProductUtilities.validateOpptyStageApprovalStatus(OpptyProdRecordSelector.approvedSGOptyQuoteStage);
        }
        
        //Stop creating/updating/deleting OLI if OMEB Opportunity has pending approvals
        if(OpptyProdRecordSelector.OppProdOpptyWithPendingApprovals.size() > 0){
            OpportunityProductUtilities.validateOpptyPendingApprovalProcesses(OpptyProdRecordSelector.OppProdOpptyWithPendingApprovals, null);
        }
        //  Method to process OpportunityLineItem Platform Event
        if(OpptyProdRecordSelector.lstOpptyProductIdonDelete.size()>0){
            OLIEventResponseHandler.fireOliEventSync(OpptyProdRecordSelector.lstOpptyProductIdonDelete, true, true);
        }
        
        //Stop creating/updating/deleting OLI if OMEB Opportunity has pending approvals
        if(OpptyProdRecordSelector.lstOpptyProductIdonDelete.size()>0){
            OpportunityProductUtilities.stampingOLIidsonhistoryRecords(OpptyProdRecordSelector.lstOpptyProductIdonDelete);
        }
        
        //12888
        if(OpptyProdRecordSelector.lstOfOpportunityProductForEventDel.size()>0){
             OpportunityEventUtilities.toFireOpptyDeleteEvent(new List<Id>(OpptyProdRecordSelector.lstOfOpportunityProductForEventDel),false,true,true); 
        }
     }
}