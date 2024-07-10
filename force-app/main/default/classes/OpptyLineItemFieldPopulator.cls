/* Author  : Madhava
 * Purpose  : Utility class to hold simple and reusable functionalities
 *        
 * Revision Ref Number  Date        Owner                          Description
 * -------- ----------  ----------- -------------------            -----------
 * 1.0      #RQ-003743  04-May-2016  Madhava.kotte@ust-global.com  Created for implementing CBO (Centralized By Org) trigger architecture.
 * 4.0      #RQ-009597  26/11/2018   Sidhartha Mohapatra           Removing auto creation of Unassigned Product and updating FFE
 * 5.0		#RQ-013090  17/03/2020	 Meghana@ust				   Method addded to update Amend Quantity
 *                                  
 */
public class OpptyLineItemFieldPopulator{

    public static void updateOpptyLineFields(list<OpportunityLineItem> lstOpptyLineItems, map<Id, OpportunityLineItem> oldOpptyLineItmsMap, Boolean VRBypassIsActive, Map<id,Boolean> OpportunityClosedmap) {
        
            String OtherProductName = Label.OtherProductRouteCode;
            Boolean optOutchk;
            for( OpportunityLineitem oli : lstOpptyLineItems )
            {         

                //#RQ-000139 - Start - Added condition to exclude the below validation error for Unassigned product 
                //#RQ-000601 - Allow user to edit the Revenue Schedule on a closed Opportunity. 
            
                if( OpportunityClosedmap.get(oli.OpportunityId)!=null && OpportunityClosedmap.get(oli.OpportunityId) == True  && !Trigger.isUpdate && VRBypassIsActive != true ){

                    oli.addError(' '+Label.ExpectedErrorLabel);
                    
                }/* RQ-009597else {
                    if(Trigger.isUpdate){
                        
                        if( oli.PricebookEntryId == Label.UnassignedPriceBookEntryId && ( ( oli.Quantity != oldOpptyLineItmsMap.get(oli.Id).Quantity ) ) )
                        {
                            oli.addError(Label.CannotUpdateUnassigned);
                        }
                    }
                }
				RQ-009597 */
            }
    }
    
    // v5.0 - method to update Amend Quantity based on Product Owner Target or Nominated Qunatity
    public static void updateAmendQty (list<OpportunityLineItem> lstOli_ProductOwnerTarget, list<OpportunityLineItem> lstoli_NominatedQty){
        
        for (OpportunityLineItem recOli : lstOli_ProductOwnerTarget){
            recOli.Amend_Expected_FFE__c = recOli.Tender_Target__c;
        }
    
        for (OpportunityLineItem recOli : lstoli_NominatedQty){
            recOli.Amend_Expected_FFE__c = recOli.Nominated_Quantity__c;
        }
        system.debug('@@@ lstOli_ProductOwnerTarget '+ lstOli_ProductOwnerTarget);
    }
}