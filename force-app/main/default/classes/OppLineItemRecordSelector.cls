/*
 * Author  : Madhava
 * Purpose  : Utility class to hold simple and reusable functionalities
 *        
 * Revision Ref Number  	Date			Owner							Description
 * -------- ----------  	-----------		-------------------				-----------
 * 8.0		#RQ-013324		30/04/2020		Sidhartha Mohapatra				added isClone() feature for clone with related button
 * 8.1		#RQ-013439		11/05/2020		Meghana.Gupta@Ust-global.com	replace Solution record type label to SupplyChainServices record type
 * 9.0		SFSE-94			28-May-2020		manjunath@maersk				Replaced 'OppTenderRecordTypeId' label with 'OppShippingCargoRecordType' and its related criteria
 * 10.0		SFSE-4388		14-Sep-2020		meghana.gupta@UST				If Amend GP field is modified then modify OLi schedule records
 * 11.0		SFSE-5309		02-Mar-2021		Meghana@UST						Check if an opportunity Meets OMEB conditions
 * 12.0		SFSE-8606		27-Jun-2022		Meghana@UST						Remove code related to deprecated feature (Unassigned Products)
 * 13.0		SFSE-8521		04-Jul-2022		Rakesh@Maersk					Handle Cloning Opportunity Product Features on Opp clone
 * 14.0		SFSE-9417		18-Oct-2022		Kiran@Maersk					Adding VR to stop creatining OLI if Opportunity approval status is Approved Solution Gate and StageName is Quoting
 * 15.0     SFSE-9824       16-Nov-2022     Arpitha@Maersk                  VR added as part of SFSE-9417 is modified to consider only OMEP Products.
 * 16.0		SFSE-10967		28-Apr-2023		Kiran@Maersk					Added new variable to identify if any CL product Annualized gross profit changed
*/
public class OppLineItemRecordSelector {
    
    public Map<Id,Opportunity> opportunityMap = New Map<Id,Opportunity>();
    public List<OpportunityLineItem> lstAmendedFFEProducts = new List<OpportunityLineItem>();
    public List<OpportunityLineItem> lstChangedCountryProduct = new List<OpportunityLineItem>();
    //public List<OpportunityLineItem> lstchangedManually = new List<OpportunityLineItem>();
    public List<OpportunityLineItem> lstsetSalesPrice = new List<OpportunityLineItem>();
    public Map<id,Boolean> closedOppMap = new map<id,Boolean>();
    public Boolean VRBypassIsActive;
    public Boolean isClone = false;
    public List<OpportunityLineItem> lstSetQuantityToProductOwnerTarget = new List<OpportunityLineItem>();
    public List<OpportunityLineItem> lstSetQuantityToNominatedQuantity = new List<OpportunityLineItem>();
    public List<OpportunityLineItem> lstAmendGP = new List<OpportunityLineItem>();
    public List<OpportunityLineItem> lstOmebCheck = new List<OpportunityLineItem>();
    public List<OpportunityLineItem> lstOptOutSelected = new List<OpportunityLineItem>();
    public Map<Id,Id> sourceIdClonedIdMap = new Map<Id,Id>(); //holds Source Opp Id for cloned Opportunities
    public List<OpportunityLineItem> approvedSGOptyQuoteStage = new List<OpportunityLineItem>();		//SFSE-9417 Opportunity with Approval solution gate and quoting stage
    public List<String> solutionGateOpportunityStages = new List<String>();
    public List<OpportunityLineItem> oliOpptyWithPendingApprovals = new List<OpportunityLineItem>();		//SFSE-9417 Opportunity with Approval solution gate and quoting stage
    public List<OpportunityLineItem> lstChangedAnnualizedGrossProfitCLProduct = new List<OpportunityLineItem>();  // SFSE-10967


    public OppLineItemRecordSelector(list<OpportunityLineItem> lstNewoppLnItems, map<Id, OpportunityLineItem> OldoppLnItems, TriggerHandler opptyLnItemTriggerHandler, map<Id, Opportunity> opptyMap,map<Id,Product2>prodMap) {
        
        //SFSE-9417 Sales stages to not to allow deleting Products
        solutionGateOpportunityStages = Label.Solution_Gate_Opportunity_Stages.split(',');
        Set<Id> opptyHasPendingApprovalProcesses = getPendingApprovalProcesses(opptyMap);
       
        Set<Id> lChangedOppSet = new Set<Id>();    // Store Ids of Opportunity whose Products are being operated
        OpportunityLineItem oldOli;
        //Get the logged User in value from the custom setting Validation_Rules_Bypass__c
        Validation_Rules_Bypass__c VRBypass = Validation_Rules_Bypass__c.getInstance(UserInfo.getUserId());
        VRBypassIsActive = VRBypass.Active__c;
        system.debug('$$$ opptyMap in record selector'+ opptyMap);
        //Get Opp Id on creation, updated and deletion of opportunity line item
        
        // Get list of product family to check for OMEB conditions
        Set<String> setOmebProdFamily = new Set<String>();
        for (productFamilyForOMEB__mdt pf : productFamilyForOMEB__mdt.getAll().values()){
            if(pf.isActive__c){
                setOmebProdFamily.add(pf.MasterLabel);
            }
        }

        if(trigger.isInsert || trigger.isUpdate){
            for(OpportunityLineItem lOppLineItem : lstNewoppLnItems){  

                if(OldoppLnItems != null){
                    oldOli = OldoppLnItems.get(lOppLineItem.id);
                }
                
                if(lOppLineItem.isClone()) {
                    isClone = true;
                } else {
                    isClone = false;
                }
                if( Trigger.isInsert || (Trigger.isUpdate && lOppLineItem.Quantity != OldoppLnItems.get(lOppLineItem.id).Quantity )){
                    lChangedOppSet.add(lOppLineItem.OpportunityId);
                }
                
                if( Trigger.isUpdate && ( lOppLineItem.Amend_Expected_FFE__c != null && lOppLineItem.Amend_Expected_FFE__c != lOppLineItem.Quantity )){
                    system.debug('@@@@lstAmendedFFEProducts');
                      lstAmendedFFEProducts.add(lOppLineItem);
                }
                
                if( Trigger.isUpdate && lOppLineItem.Country__c != OldoppLnItems.get(lOppLineItem.id).Country__c){
                    system.debug('@@@@lstChangedCountryProduct');
                      lstChangedCountryProduct.add(lOppLineItem);
                }
                
                if( opptyLnItemTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && opptyLnItemTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER && 
                   (lOppLineItem.Annualized_Gross_Profit__c != OldoppLnItems.get(lOppLineItem.id).Annualized_Gross_Profit__c ||
                    (lOppLineItem.Amend_Expected_FFE__c != null && lOppLineItem.Amend_Expected_FFE__c != lOppLineItem.Quantity) || 
                    (lOppLineItem.Amend_Gross_Profit_per_unit__c  != null && lOppLineItem.Amend_Gross_Profit_per_unit__c  != lOppLineItem.UnitPrice)) && 
                   Label.ContractLogisticFamily_OipcCode.contains(lOppLineItem.OIPC_Product_Code__c) && lOppLineItem.Country__c == OldoppLnItems.get(lOppLineItem.id).Country__c){
                       system.debug('@@@@lstChangedAnnualizedGrossProfitCLProduct');
                       lstChangedAnnualizedGrossProfitCLProduct.add(lOppLineItem);
                   }
                
                Id oppShippingCargoRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.OppShippingCargoRecordType ).getRecordTypeId();
                //v6.0 - If Oppty record type = complex and Product family = Ocean and Product Owner Target is changed
                
                if (opptyMap != null && opptyLnItemTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && opptyLnItemTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE ){
                        
                        if ((opptyMap.get(lOppLineItem.OpportunityId).RecordTypeId ==  oppShippingCargoRecordTypeId || opptyMap.get(lOppLineItem.OpportunityId).RecordType.DeveloperName ==  Label.OppSupplyChainServicesRecType)
                            && lOppLineItem.Tender_Target__c != OldoppLnItems.get(lOppLineItem.id).Tender_Target__c
                            && lOppLineItem.Product_Family__c == 'Ocean' && lOppLineItem.Opt_Out_Auto_Quantity_Scheduling__c == false
                            && opptyMap.get(lOppLineItem.OpportunityId).IsClosed == false
                            && lOppLineItem.Quantity != lOppLineItem.Tender_Target__c){
                            
                            lstSetQuantityToProductOwnerTarget.add(lOppLineItem);
                        } 
                
                        // If Oppty record type = complex and Product family = Ocean and Nominated Quantity is changed
                        if ((opptyMap.get(lOppLineItem.OpportunityId).RecordTypeId == oppShippingCargoRecordTypeId || opptyMap.get(lOppLineItem.OpportunityId).RecordType.DeveloperName ==  Label.OppSupplyChainServicesRecType)
                                && lOppLineItem.Nominated_Quantity__c != OldoppLnItems.get(lOppLineItem.id).Nominated_Quantity__c
                                && lOppLineItem.Product_Family__c == 'Ocean' && lOppLineItem.Opt_Out_Auto_Quantity_Scheduling__c == false
                                && opptyMap.get(lOppLineItem.OpportunityId).IsClosed == false
                                && lOppLineItem.Quantity != lOppLineItem.Nominated_Quantity__c){
                                    
                                lstSetQuantityToNominatedQuantity.add(lOppLineItem);
                        } 
                }

                // Capture Cloned Opportunity Products and Source Id - SFSE-8521
                if( opptyLnItemTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT &&
                        opptyLnItemTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER){
                                if(lOppLineItem.isClone()){
                                    sourceIdClonedIdMap.put(lOppLineItem.getCloneSourceId(), lOppLineItem.Id);
                                }

                }
               
                //SFSE-4388
                if( Trigger.isUpdate && lOppLineItem.Amend_Gross_Profit_per_unit__c  != null && lOppLineItem.Amend_Gross_Profit_per_unit__c  != lOppLineItem.UnitPrice ){
                      lstAmendGP.add(lOppLineItem);
                }

                // SFSE-5309              
           
                if ( ( Trigger.isInsert && setOmebProdFamily.contains(lOppLineItem.Product_Family__c))
                    	|| (Trigger.isUpdate && 
                            	(  (lOppLineItem.Amend_Gross_Profit_per_unit__c  != null && lOppLineItem.Amend_Gross_Profit_per_unit__c  != oldOli.UnitPrice) 
                                || (lOppLineItem.Amend_Expected_FFE__c != null && lOppLineItem.Amend_Expected_FFE__c != oldOli.Quantity )
                                || ( lOppLineItem.TotalPrice != oldOli.TotalPrice )
                             	||  lOppLineItem.Annualized_Gross_Profit__c	 != oldOli.Annualized_Gross_Profit__c	
                                ||  lOppLineItem.Product2Id != oldOli.Product2Id
                             	||  lOppLineItem.OpportunityId != oldOli.OpportunityId ) 
                        	&& (setOmebProdFamily.contains(lOppLineItem.Product_Family__c) || setOmebProdFamily.contains(oldOli.Product_Family__c))) 
                    ){
                         lstOmebCheck.add(lOppLineItem);
                        
                }

                //SFSE-8606
                if( Trigger.isUpdate && lOppLineItem.Opt_Out_Auto_Quantity_Scheduling__c == true && lOppLineItem.Opt_Out_Auto_Quantity_Scheduling__c  !=  oldOli.Opt_Out_Auto_Quantity_Scheduling__c ){
                    lstOptOutSelected.add(lOppLineItem);
                }
                system.debug('==omep=='+lOppLineItem.Product2Id);
                system.debug('==prodmap=='+prodmap);
                system.debug('==omep=='+prodMap.get(lOppLineItem.Product2Id).Include_in_OMEB_Approvals__c);
                //SFSE-9417
                if( opptyLnItemTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT &&
                   opptyLnItemTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE &&  
                   opptyMap.get(lOppLineItem.OpportunityId).Must_Go_To_OMEB__c &&
                   solutionGateOpportunityStages.contains(opptyMap.get(lOppLineItem.OpportunityId).StageName) && prodMap.containskey(lOppLineItem.Product2Id) && prodMap.get(lOppLineItem.Product2Id).Include_in_OMEB_Approvals__c == true){
                       approvedSGOptyQuoteStage.add(lOppLineItem);
                   }
                
                if( (opptyLnItemTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT || opptyLnItemTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) &&
                   opptyLnItemTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE &&  
                   opptyMap.get(lOppLineItem.OpportunityId).Must_Go_To_OMEB__c &&
                   opptyHasPendingApprovalProcesses.contains(lOppLineItem.OpportunityId) && prodMap.containskey(lOppLineItem.Product2Id) && prodMap.get(lOppLineItem.Product2Id).Include_in_OMEB_Approvals__c == true ){
                       oliOpptyWithPendingApprovals.add(lOppLineItem);
                   }
            }
        }
        if(trigger.isDelete){
            for(OpportunityLineItem lOppLineItem : OldoppLnItems.values())
            {
                lChangedOppSet.add(lOppLineItem.OpportunityId);
                
                if (setOmebProdFamily.contains(lOppLineItem.Product_Family__c)){
                    lstOmebCheck.add(lOppLineItem);
                }
                
                //SFSE-9417
                if( opptyLnItemTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE &&
                   opptyLnItemTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && 
                   opptyMap.get(lOppLineItem.OpportunityId).Must_Go_To_OMEB__c &&
                   solutionGateOpportunityStages.contains(opptyMap.get(lOppLineItem.OpportunityId).StageName) && prodMap.containskey(lOppLineItem.Product2Id) && prodMap.get(lOppLineItem.Product2Id).Include_in_OMEB_Approvals__c == true){
                       approvedSGOptyQuoteStage.add(lOppLineItem);
                   }
                
                if( opptyLnItemTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE &&
                   opptyLnItemTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && 
                   opptyMap.get(lOppLineItem.OpportunityId).Must_Go_To_OMEB__c &&
                   opptyHasPendingApprovalProcesses.contains(lOppLineItem.OpportunityId) && prodMap.containskey(lOppLineItem.Product2Id) && prodMap.get(lOppLineItem.Product2Id).Include_in_OMEB_Approvals__c == true ){
                       oliOpptyWithPendingApprovals.add(lOppLineItem);
                   }
            }           
        }
        
        //get opportunities and unassigned products and store it in variable
        if(lChangedOppSet.size()>0){
            
            opportunityMap = getOpportunities(lChangedOppSet);
            
         }
         
         //store closed opportunity in Map
         if(opportunityMap.size()>0){
             for( Opportunity opp : opportunityMap.values()){
                if(opp.IsClosed==true)
                    closedOppMap.put(opp.Id, opp.IsClosed);                 
            }
         }
    }
    
    //query for getting the opportunities
    public static map<Id,Opportunity> getOpportunities(set<id> OpportunityIdSet) {
        
            map<Id, Opportunity> mapOpptys = new map<Id, Opportunity>([ SELECT id, IsClosed, TotalOpportunityQuantity, First_Shipment_Date__c, Last_Shipment_Date__c,RecordtypeId FROM Opportunity WHERE Id IN: OpportunityIdSet AND (First_Shipment_Date__c !=null OR Last_Shipment_Date__c !=null)]);    //RQ-009201
            return mapOpptys;
        
    }
    
    //query to get all pending approval processes related to Opportunity
    public static Set<Id> getPendingApprovalProcesses(map<Id, Opportunity> opptyMap){
        Set<Id> listOpptyIDWorkItems = new Set<Id>();
        for(ProcessInstanceWorkItem workItem : [SELECT Id, ProcessInstance.TargetObjectId 
                                                FROM ProcessInstanceWorkItem 
                                                WHERE ProcessInstance.TargetObjectId in :opptyMap.keySet() AND 
                                                ProcessInstance.Status = 'Pending']){
			listOpptyIDWorkItems.add(workItem.ProcessInstance.TargetObjectId);
        }
        return listOpptyIDWorkItems;
    }

}