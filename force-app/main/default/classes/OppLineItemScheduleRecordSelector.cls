/**              
* Revision Ref Number    Date            Owner                   Description
* -------- ----------   -----------  -------------------   --------------------------------------------------------
* 1.0      SFSE-9685	10-Nov-2022	 shilpa.nagtode		   Add logic to handle change in quantity/revenue on OLI Schedule records

*/
public class OppLineItemScheduleRecordSelector {
    
    private OppoLineItemSchTriggerHandler oliScheduleTriggerHandler;
    Map<Id,OpportunityLineItem> oliMap = new Map<Id,OpportunityLineItem>();
    
    public List<OpportunityLineItemSchedule> closedWonOpp = new List<OpportunityLineItemSchedule>(); // List of schedules related to Closed Won Opportunities
    public List<OpportunityLineItemSchedule> lstClonedRecords = new List<OpportunityLineItemSchedule>();
    public List<OpportunityLineItemSchedule> lstToCheckScheduleDates = new list<OpportunityLineItemSchedule>();

    public OppLineItemScheduleRecordSelector(List<OpportunityLineItemSchedule> newlist, Map<Id,OpportunityLineItemSchedule> oldMap, OppoLineItemSchTriggerHandler oliScheduleTriggerHandler){
        
        this.oliScheduleTriggerHandler = oliScheduleTriggerHandler;
        
        Set<Id> oliIds = new Set<Id>(); // get Ids of related OLI records
        
        if (newlist != null){
            for (OpportunityLineItemSchedule sch : newlist){
                oliIds.add(sch.OpportunityLineItemId);
            }
        }else{
            for (OpportunityLineItemSchedule sch : oldMap.values()){
                oliIds.add(sch.OpportunityLineItemId);
            }
        }
        this.oliMap = this.getRelatedOpptyLineItems(oliIds);
        this.selectRecords(newlist, oldMap);
    }   
        
    public void selectRecords(List<OpportunityLineItemSchedule> newlist, Map<Id,OpportunityLineItemSchedule> oldMap){
        if (newlist != null){
            
            for(OpportunityLineItemSchedule sch : newlist){		
                
                OpportunityLineItemSchedule oldSchedule;
                if (Trigger.IsUpdate){
                    oldSchedule = oldMap.get(sch.Id);
                }
                
                Opportunity opp = this.oliMap.get(sch.OpportunityLineItemId).Opportunity;
                
                if( Trigger.isBefore && (Trigger.isInsert || (Trigger.IsUpdate && (sch.Quantity != oldSchedule.Quantity || sch.Revenue != oldSchedule.Revenue ) )) 
                   && opp.StageName == 'Closed Won' ){
                       closedWonOpp.add(sch);  
                   }
                
                if( Trigger.isBefore && Trigger.isInsert && sch.getCloneSourceId() != null){
                    lstClonedRecords.add(sch);
                }
                if(Trigger.isBefore && (Trigger.isInsert || (Trigger.isUpdate && sch.ScheduleDate != oldSchedule.ScheduleDate)) && 
                   	((opp.First_Shipment_Date__c != null && opp.First_Shipment_Date__c > sch.ScheduleDate )
                    || (opp.Last_Shipment_Date__c != null && opp.Last_Shipment_Date__c < sch.ScheduleDate))){
                          lstToCheckScheduleDates.add(sch);
                    }
            }
        }else {
            for(OpportunityLineItemSchedule sch : oldMap.values()){		
                
                if( Trigger.isBefore && Trigger.IsDelete && this.oliMap.get(sch.OpportunityLineItemId).Opportunity.StageName == 'Closed Won' ){
                    closedWonOpp.add(sch);  
                }
            }
        }
        
    }
        
    public  map<Id,OpportunityLineItem> getRelatedOpptyLineItems(Set<id> oliId) {       
        Map<Id,OpportunityLineItem> olimap = new map<Id,OpportunityLineItem>([select Id, Opportunity.StageName,Opportunity.First_Shipment_Date__c,Opportunity.Last_Shipment_Date__c from OpportunityLineItem where id In:oliId]);
        return olimap;        
    }
    
    
    
}