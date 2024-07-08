/*
* Trigger Handler Utility Class for Opportunity
* 
* Version  Date         Owner                                   RQ#             Description
****************************************************************************************************************************************
* 1.0     08/02/2016    meghana.gupta@ust-global.com            #RQ-002301      Code created. Opportunity Trigger - Refactoring. 
* 2.0     28/10/2016    kishore.dupam@ust-global.com            #RQ-004470      Fixed Unassigned OLI quantity for Tender Opportunities
* 3.0     22-May-2017   Meghana.Gupta@UST-Global.com            #RQ-004742      Need to call oli trigger method on unassigned delete
* 4.0     25/09/2017    Nisha.arjunan@ust-global.com            #RQ-005636      Update references of GlobalErrorLogger
* 5.0     10-Sep-2018   manjunath.c.holekade@maersk.com         #RQ-009201      Mod-01 to Mod-02 -> Logic to auto create Corridor Guidance on insertion of Routes against the Quarterly Deals
* 6.0     26/11/2018    Sidhartha Mohapatra                     #RQ-009597      Removing auto creation of Unassigned Product and updating FFE on Opportunity
* 6.1     01/05/2019    Nitin More                              #RQ-010374      Added Commiment__c field. 
* 7.0     06-Jun-2019   manjunath.c.holekade@maersk.com         #RQ-010819      Removal of references of deprecated fields
* 8.0     05-Sep-2019   Junaid.Khader@ust-global.com            #RQ-011734      Replaces assigning of Commitment__c field with custom label.
* 9.0     26-May-2020   manjunath@maersk                        SFSE-111        Removed references and logic related to "Expected_FFE_Lead__c" object
* 10.0    24-May-2023   Kiran@Maersk                            SFSE-10984      OLI standard to Custom
* 11.0    24-feb-2024   ramya@Maersk                            SFSE-14128      Remove the sync between standard and custom objects 
*/

public class OpportunityToLineItemUtilities {
 
    public static void AdjustUnassignedProdFEE_ProdSchedule( Map<Id, Opportunity> newOpptyMap, Map<Id, Opportunity> oldOpptyMap ){
        
        try{//ver 11.0
            //RQ-004470-Improve Opportunity Trigger Recursion Control
            Integer MaxLoopCount=1;
            if(Generic_TriggerHandler.validateRunForMethod('OpportunityToLineItemUtilities.AdjustUnassignedProdFEE_ProdSchedule',MaxLoopCount)){
                
                Set<id> UpdateProductScheduleOppIdSet = new Set<Id>(); // Stores Opportunity Ids when the shipment Dates are changed.  
                
                // Do not execute when Opportunity FFE is Updated within code for adjustments
                if( !ScheduleOpportunityProducts.UpdatedFromOppProductTrigger ) {
                    
                    for( Opportunity opp : newOpptyMap.values() ) {
                        if( opp.First_Shipment_Date__c != oldOpptyMap.get(opp.Id).First_Shipment_Date__c || opp.Last_Shipment_Date__c != oldOpptyMap.get(opp.Id).Last_Shipment_Date__c || Test.isRunningTest()  ) {
                            UpdateProductScheduleOppIdSet.add( opp.Id );
                        }
                    }                    
                    // Delete Line Item Scedules and then re-generate with new shipment dates
                    if( UpdateProductScheduleOppIdSet.size() > 0 ) {     
                        ScheduleOpportunityProducts.getSchedulingLogic( newOpptyMap.keyset(), 'Opportunity');
                        //commented below line for 14128 removal of sync between std and custom obj of opp prod and sch
                        // ScheduleOppProducts.getSchedulingLogic( newOpptyMap.keySet(), 'Opportunity'); 
                      
                    } 
                }
                
            }
        } Catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OpportunityLineItem', 'OpportunityToLineItemUtilities.AdjustUnassignedProdFEE_ProdSchedule', new list<Exception>{ex}); // #RQ-005636 
        }
    }    
}