/**              
* Revision Ref Number    Date            Owner                   Description
* -------- ----------   -----------  -------------------   --------------------------------------------------------
* 1.0      SFSE-9685	10-Nov-2022	 shilpa.nagtode		   Add logic to handle change in quantity/revenue on OLI Schedule records

*/
public class OppoLineItemSchUtilities {
    
    
    public static void setCloneFlag(List<OpportunityLineItemSchedule> newList){
        
        for(OpportunityLineItemSchedule opsc : newList){
            if(opsc.getCloneSourceId()!=null){
                opsc.isClonedrecord__c =false;
            }
        }
    }

    public static void validateAgreementDates(List<OpportunityLineItemSchedule> newList){
        
        for(OpportunityLineItemSchedule sch : newList){
            sch.addError('Please review if Schedule Date is within original Agreement Start and End Date');
        }
    }
    
    public static void preventToUpdateQuantityAndRevenue(List<OpportunityLineItemSchedule> scheduleList, Map<Id,OpportunityLineItemSchedule> oldmap, String eventType){
        
        Set<Id> oliIds = new Set<Id>();    
        Map<Id,Decimal> mapOfOLIQuantity = new Map<Id,Decimal>();
        Map<Id,Decimal> mapOfOLIRevenue  = new Map<Id,Decimal>();
        
        Map <Id, Decimal> mapChangedQty = new Map<Id, decimal>();
        Map <Id, Decimal> mapChangedRevenue = new Map<Id, decimal>();

        for(OpportunityLineItemSchedule oliSch : scheduleList) {
            decimal qty;
            decimal rev;
            if (mapChangedQty.containsKey(oliSch.OpportunityLineItemId)){
                qty = mapChangedQty.get(oliSch.OpportunityLineItemId);
                rev = mapChangedRevenue.get (oliSch.OpportunityLineItemId);
            } else {
                qty = 0;
                rev = 0;
            }
            
            If (eventType == 'Insert'){
                qty = qty + oliSch.Quantity;
                rev = rev + oliSch.Revenue;
                
            } else if (eventType == 'Delete'){
                OpportunityLineItemSchedule oldRec = oldmap.get(oliSch.Id);
                qty = qty - oldRec.Quantity;
                rev = rev - oldRec.Revenue;
            } else {
                OpportunityLineItemSchedule oldRec = oldmap.get(oliSch.Id);
                qty = qty + oliSch.Quantity - oldRec.Quantity;
                rev = rev + oliSch.Revenue - oldRec.Revenue;
            }
            mapChangedQty.put(oliSch.OpportunityLineItemId, qty);
            mapChangedRevenue.put(oliSch.OpportunityLineItemId, rev);
        }  
        
		for(OpportunityLineItemSchedule oliSch : scheduleList) {
            
            if (mapChangedQty.get(oliSch.OpportunityLineItemId) <> 0 || mapChangedRevenue.get(oliSch.OpportunityLineItemId) <> 0 ){
                oliSch.addError('Revised seasonality is not matching with closed won quantity/revenue - please ensure total quantity remains the same');
            }
        }
    }    
}