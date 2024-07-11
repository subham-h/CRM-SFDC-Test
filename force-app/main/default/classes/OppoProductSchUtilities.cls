/**              
* Revision Ref Number    Date            Owner                   Description
* -------- ----------   -----------  -------------------   --------------------------------------------------------
* 1.0      SFSE-10986  17-May-2023   sriram.kalluri@maersk.com    Replicated standard OpportunityLineItemSchedule logic 
                                                                  Add logic to handle change in quantity/revenue on Opportunity Product Schedule records
* 2.0     SFSE-12889  16-Oct-2023    Jothsana@maersk.com      	  To make OLI event publish queable
* 3.0     SFSE-14128  16-Oct-2023    ramya.s@maersk.com      	  Remove the sync between standard and custom objects 
* 4.0	  SFSE-14428  29-Apr-2024	 Avinash@maersk.com			  Refine the code to overcome the governor limits.
*/
public class OppoProductSchUtilities {
    
    //Set clone flag on cloned record
    public static void setCloneFlag(List<Opportunity_Product_Schedule__c> newList){
        for(Opportunity_Product_Schedule__c opsc : newList){
            if(opsc.getCloneSourceId()!=null){
                opsc.isClonedrecord__c =false;                
            }
        }
    }
    
    public static void validateAgreementDates(List<Opportunity_Product_Schedule__c> newList){
        for(Opportunity_Product_Schedule__c sch : newList){
            sch.addError('Please review if Schedule Date is within original Agreement Start and End Date');
        }
    }
    
    /**public static void preventToUpdateQuantityAndRevenue(List<Opportunity_Product_Schedule__c> scheduleList, Map<Id,Opportunity_Product_Schedule__c> oldmap, String eventType){
        
        Set<Id> oliIds = new Set<Id>();    
        Map<Id,Decimal> mapOfOLIQuantity = new Map<Id,Decimal>();
        Map<Id,Decimal> mapOfOLIRevenue  = new Map<Id,Decimal>();
        
        Map <Id, Decimal> mapChangedQty = new Map<Id, decimal>();
        Map <Id, Decimal> mapChangedRevenue = new Map<Id, decimal>();
        
        for(Opportunity_Product_Schedule__c oliSch : scheduleList) {
            decimal qty;
            decimal rev;
            if (mapChangedQty.containsKey(oliSch.Opportunity_Product__c)){
                qty = mapChangedQty.get(oliSch.Opportunity_Product__c);
                rev = mapChangedRevenue.get (oliSch.Opportunity_Product__c);
            } else {
                qty = 0;
                rev = 0;
            }
            
            If (eventType == 'Insert'){
                qty = qty + oliSch.Quantity__c;
                rev = rev + oliSch.Revenue__c;
                
            } else if (eventType == 'Delete'){
                Opportunity_Product_Schedule__c oldRec = oldmap.get(oliSch.Id);
                qty = qty - oldRec.Quantity__c;
                rev = rev - oldRec.Revenue__c;
            } else {
                Opportunity_Product_Schedule__c oldRec = oldmap.get(oliSch.Id);
                qty = qty + oliSch.Quantity__c - oldRec.Quantity__c;
                rev = rev + oliSch.Revenue__c - oldRec.Revenue__c;
            }
            mapChangedQty.put(oliSch.Opportunity_Product__c, qty);
            mapChangedRevenue.put(oliSch.Opportunity_Product__c, rev);
        }  
        
        for(Opportunity_Product_Schedule__c oliSch : scheduleList) {
            if (mapChangedQty.get(oliSch.Opportunity_Product__c) <> 0 || mapChangedRevenue.get(oliSch.Opportunity_Product__c) <> 0 ){
                oliSch.addError('Revised seasonality is not matching with closed won quantity/revenue - please ensure total quantity remains the same');
            }
        }
    }*/

    //SFSE : 14428
    public static void updateCustomOLI(List<Opportunity_Product_Schedule__c> newOpptyProdList){
        Set<Id> lstOliId = new Set<Id>();
        Set<Id> setOfOliToProcessEvents = new Set<Id>();
        Map<Id,Id> mapOfCustomOLItoOLI = new Map<Id,Id>();
        map<Id,Decimal> mapofOLIandQuantity = new map<Id,Decimal>();
        List<Opportunity_Product__c> lstCustomOLI = new List<Opportunity_Product__c>();
        
        for(Opportunity_Product_Schedule__c sch:newOpptyProdList){
            lstOliId.add(sch.Opportunity_Product__c);
        }
        
        //Query OLI and related olischedules 
        //SFSE : 14428 Removed inner SOQL to avoid 'Aggregate query has too many rows for direct assignment' Error. 
        //Error is coming for large agreement duration and try to edit schedule
        //Also removed code reference for sync
        for(Opportunity_Product__c oli: [select id,Quantity__c,UnitPrice__c, OpportuntityLineItemId__c, OpportunityId__r.IsClosed from Opportunity_Product__c where Id In: lstOliId]){
            lstCustomOLI.add(oli);
            setOfOliToProcessEvents.add(oli.id);
        }
        
        for(Opportunity_Product_Schedule__c olisch: [select id,Description__c,Quantity__c,Revenue__c,Schedule_Date__c,Opportunity_Product__c from Opportunity_Product_Schedule__c where Opportunity_Product__c In: lstOliId]){
            if(olisch != null){
                if(mapofOLIandQuantity.containsKey(olisch?.Opportunity_Product__c)){
                    Decimal quantity= mapofOLIandQuantity.get(olisch?.Opportunity_Product__c)+ olisch?.quantity__c;
                    mapofOLIandQuantity.put(olisch?.Opportunity_Product__c,quantity);
                }else{
                    mapofOLIandQuantity.put(olisch?.Opportunity_Product__c,olisch?.quantity__c);
                }
            }
        }
        
        if(!mapofOLIandQuantity.keyset().isEmpty()){
            for(Opportunity_Product__c oliCustom:lstCustomOLI){
                if(mapofOLIandQuantity.containsKey(oliCustom?.id)){
                    oliCustom.quantity__c = mapofOLIandQuantity.get(oliCustom?.id);
                }
            }
        }
        
        if(!lstCustomOLI.isEmpty()){
            OppProductScheduleRecordSelector.oppProductScheduleTrigger = false;
            // List<Database.SaveResult> lstOliResult=   Database.update(lstCustomOLI,false);//commenting out to get error message while update schedule
            List<Database.SaveResult> lstOliResult = Database.update(lstCustomOLI);
            ErrorLogger.writeErrors('SFDC', 'OppoProductSchUtilities', 'OppoProductSchUtilities.updateCustomOLI', lstOliResult, lstCustomOLI) ; 
        }
        
        if(!setOfOliToProcessEvents.isEmpty() && (!System.isFuture() && !System.isBatch() && !System.isQueueable() && !System.isScheduled())){
            OLIEventResponseHandler.fireQueableOliEventsAsync(new List<Id>(setOfOliToProcessEvents), false, true, true,false);
        }else if(!setOfOliToProcessEvents.isEmpty() && (System.isFuture() || System.isBatch() || System.isQueueable() || System.isScheduled())){
            OLIEventResponseHandler.fireOliEventAsync(new List<Id>(setOfOliToProcessEvents), false, true, true,false);
        }
    }
  
    
    public static void createstdOli(List<Opportunity_Product__c> newOpptyProdList, Map<Id,Opportunity> opportunityMap, Map<id,Boolean> OpportunityClosedmap){
        
        InsertStdOppProductQueueable queueable = new InsertStdOppProductQueueable(newOpptyProdList,null,opportunityMap,OpportunityClosedmap);
        System.enqueueJob(queueable);
        
    }
}