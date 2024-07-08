/*      
* Revision      Ref Number      Date            Owner                       Description
* --------      ----------      -----------     -------------------         -------------------------
* 1.1           SFSE-10984      24-May-2023     Kiran@Maersk                To replicate standard OLI Trigger Logic on cutom object Opportunity Product. Created from OpportunityToLineItemUtilities.
*/
public class OpportunityToProductUtilities {
    
    public static void AdjustUnassignedProdFEE_ProdSchedule( Map<Id, Opportunity> newOpptyMap, Map<Id, Opportunity> oldOpptyMap ){
        
        try{//ver 11.0
            //RQ-004470-Improve Opportunity Trigger Recursion Control
            Integer MaxLoopCount=1;
            if(Generic_TriggerHandler.validateRunForMethod('OpportunityToProductUtilities.AdjustUnassignedProdFEE_ProdSchedule',MaxLoopCount)){
                
                Set<id> UpdateProductScheduleOppIdSet = new Set<Id>(); // Stores Opportunity Ids when the shipment Dates are changed.  
                
                // Do not execute when Opportunity FFE is Updated within code for adjustments
                if( !ScheduleOppProducts.UpdatedFromOppProductTrigger ) {
                    
                    for( Opportunity opp : newOpptyMap.values() ) {
                        if( opp.First_Shipment_Date__c != oldOpptyMap.get(opp.Id).First_Shipment_Date__c || opp.Last_Shipment_Date__c != oldOpptyMap.get(opp.Id).Last_Shipment_Date__c ) {
                            UpdateProductScheduleOppIdSet.add( opp.Id );
                        }
                    }                    
                    // Delete Line Item Scedules and then re-generate with new shipment dates
                    if( UpdateProductScheduleOppIdSet.size() > 0 ) {     
                        
                        ScheduleOppProducts.getSchedulingLogic( newOpptyMap.keySet(), 'Opportunity'); 
                        
                    } 
                }
                
            }
        } Catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OpportunityLineItem', 'OpportunityToProductUtilities.AdjustUnassignedProdFEE_ProdSchedule', new list<Exception>{ex}); // #RQ-005636 
        }
    }
    
}