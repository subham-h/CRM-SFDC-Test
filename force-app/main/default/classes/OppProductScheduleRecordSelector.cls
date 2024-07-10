/*
* Created By   : sriram.kalluri@maersk.com
* Purpose      : To handle all logic associated with the OpportunityProductSchedule trigger.
*              
* Revision Ref Number    Date           Owner                   		Description
* -------- ----------   -----------  	-------------------   			--------------------------------------------------------
*  1.0      SFSE-10986	22-May-2023  	sriram.kalluri@maersk.com		replicated the trigger logic from standard OLI record selector 
 * 2.0		SFSE-12722	20-Oct-2023		Kiran@Maersk					SOQL101 Error fixes
* 3.0       SFSE-14428  23-Apr-2024    avinash@Maersk               Refine the code to overcome the governor limits.
*/

public class OppProductScheduleRecordSelector {
    public static boolean oppProductScheduleTrigger = true; 
    private OppoProductSchTriggerHandler oppProductScheduleTriggerHandler;
    Map<Id,Opportunity_Product__c> opportunityProductMap = new Map<Id,Opportunity_Product__c>();
    
    public List<Opportunity_Product_Schedule__c> closedWonOpp = new List<Opportunity_Product_Schedule__c>(); // List of schedules related to Closed Won Opportunities
    public List<Opportunity_Product_Schedule__c> lstClonedRecords = new List<Opportunity_Product_Schedule__c>();
    public List<Opportunity_Product_Schedule__c> lstToCheckScheduleDates = new list<Opportunity_Product_Schedule__c>();
    public List<Opportunity_Product_Schedule__c> lstToOLIScheduleUpdate = new List<Opportunity_Product_Schedule__c>();
    
    public OppProductScheduleRecordSelector(List<Opportunity_Product_Schedule__c> newlist, Map<Id,Opportunity_Product_Schedule__c> oldMap, OppoProductSchTriggerHandler oppProductScheduleTriggerHandler){
        
        this.oppProductScheduleTriggerHandler = oppProductScheduleTriggerHandler;
        
        Set<Id> opsIds = new Set<Id>(); // get Ids of related Opportunity Product records
        
        if (newlist != null){
            for (Opportunity_Product_Schedule__c osch : newlist){
                opsIds.add(osch.Opportunity_Product__c);
            }
        }else{
            for (Opportunity_Product_Schedule__c osch : oldMap.values()){
                opsIds.add(osch.Opportunity_Product__c);
            }
        }
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate || Trigger.IsDelete)){
            if(this.opportunityProductMap.isEmpty()){//SFSE-14428
                this.opportunityProductMap = this.getRelatedOpptyProducts(opsIds);
            }
        }
        this.selectRecords(newlist, oldMap);
    }
    
    /*old code  public  map<Id,Opportunity_Product__c> getRelatedOpptyProducts(Set<id> opsIds) {       
        Map<Id,Opportunity_Product__c> opsmap = new map<Id,Opportunity_Product__c>([select Id, OpportunityId__r.StageName,OpportunityId__r.First_Shipment_Date__c,OpportunityId__r.Last_Shipment_Date__c from Opportunity_Product__c where id In:opsIds]);
        return opsmap;        
    }*/
//try 
     
public map<Id,Opportunity_Product__c> getRelatedOpptyProducts(Set<id> opsIds) {       
    Map<Id,Opportunity_Product__c> opsmap = new Map<Id,Opportunity_Product__c>();
    for (Opportunity_Product__c oppProduct : [SELECT Id, OpportunityId__r.StageName, OpportunityId__r.First_Shipment_Date__c, OpportunityId__r.Last_Shipment_Date__c FROM Opportunity_Product__c WHERE Id IN :opsIds]) {
        opsmap.put(oppProduct.Id, oppProduct);
    }
    return opsmap;        
}

    
    public void selectRecords(List<Opportunity_Product_Schedule__c> newlist, Map<Id,Opportunity_Product_Schedule__c> oldMap){
        if (newlist != null){
            Opportunity_Product__c oppsc;
            for(Opportunity_Product_Schedule__c sch : newlist){		
                
                Opportunity_Product_Schedule__c oldSchedule;
                if (Trigger.IsUpdate){
                    oldSchedule = oldMap.get(sch.Id);
                }
                
                oppsc = new Opportunity_Product__c();
                if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
                    oppsc = this.opportunityProductMap.get(sch.Opportunity_Product__c);
                }
                
                /*if( Trigger.isBefore && (Trigger.isInsert || (Trigger.IsUpdate && (sch.Quantity__c != oldSchedule.Quantity__c || sch.Revenue__c != oldSchedule.Revenue__c ) )) 
                   && oppsc.OpportunityId__r.StageName == 'Closed Won' ){
                       closedWonOpp.add(sch);  
                   }*/
                
                if( Trigger.isBefore && Trigger.isInsert && sch.getCloneSourceId() != null){
                    lstClonedRecords.add(sch);
                }
                if(Trigger.isBefore && (Trigger.isInsert || (Trigger.isUpdate && sch.Schedule_Date__c != oldSchedule.Schedule_Date__c)) && 
                   ((oppsc.OpportunityId__r.First_Shipment_Date__c != null && oppsc.OpportunityId__r.First_Shipment_Date__c > sch.Schedule_Date__c )
                    || (oppsc.OpportunityId__r.Last_Shipment_Date__c != null && oppsc.OpportunityId__r.Last_Shipment_Date__c < sch.Schedule_Date__c))){
                        lstToCheckScheduleDates.add(sch);
                    }

                if(Trigger.isAfter && Trigger.isUpdate && (sch.Quantity__c != oldSchedule.Quantity__c  ||   sch.Description__c != oldSchedule.Description__c) ){
                    lstToOLIScheduleUpdate.add(sch);
                }
            }
        }else {
            for(Opportunity_Product_Schedule__c sch : oldMap.values()){		
                
                if( Trigger.isBefore && Trigger.IsDelete && this.opportunityProductMap.get(sch.Opportunity_Product__c).OpportunityId__r.StageName == 'Closed Won' ){
                    closedWonOpp.add(sch);  
                }
            }
        }
        
    }
    
}