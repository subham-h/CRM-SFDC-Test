/*
* Created By   : sriram.kalluri@maersk.com
* Purpose      : To handle all logic associated with the OpportunityProductSchedule trigger.
*              
* Revision Ref Number    Date            Owner                   Description
* -------- ----------   -----------  -------------------   --------------------------------------------------------
*  1.0      SFSE-10986   17-May-2023  sriram.kalluri@maersk.com  replicated the trigger logic from standard OLI trigger
*/

public class OppoProductSchTriggerHandler extends TriggerHandler {
    
    public Map<Id, Opportunity_Product_Schedule__c> newMap;
    public Map<Id, Opportunity_Product_Schedule__c> oldMap;
    
    public OppoProductSchTriggerHandler() {
        
        this.newMap = ( map<Id, Opportunity_Product_Schedule__c> ) Trigger.newMap;
        this.oldMap = ( map<Id, Opportunity_Product_Schedule__c> ) Trigger.oldMap; 
        
    }
    
    public OppProductScheduleRecordSelector oppProductScheduleRecordSelector;
    
    public override void getRecordSelector() {
        oppProductScheduleRecordSelector = new OppProductScheduleRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert(){
        
        if(!this.oppProductScheduleRecordSelector.lstClonedRecords.isEmpty()){
            OppoProductSchUtilities.setCloneFlag(this.oppProductScheduleRecordSelector.lstClonedRecords);
        } 
        
        //if(!this.oppProductScheduleRecordSelector.closedWonOpp.isEmpty()){
          //  OppoProductSchUtilities.PreventToUpdateQuantityAndRevenue(this.oppProductScheduleRecordSelector.closedWonOpp, this.oldMap, 'Insert');
        //}  
        
        if(!this.oppProductScheduleRecordSelector.lstToCheckScheduleDates.isEmpty()){
            // OppoProductSchUtilities.validateAgreementDates(this.oppProductScheduleRecordSelector.lstToCheckScheduleDates);
        } 
    }
    
    
    public override void onBeforeUpdate(){
        /*if(!this.oppProductScheduleRecordSelector.closedWonOpp.isEmpty()){
            OppoProductSchUtilities.PreventToUpdateQuantityAndRevenue(this.oppProductScheduleRecordSelector.closedWonOpp, this.oldMap, 'Update');
        }*/
        
        if(!this.oppProductScheduleRecordSelector.lstToCheckScheduleDates.isEmpty()){
            //OppoProductSchUtilities.validateAgreementDates(this.oppProductScheduleRecordSelector.lstToCheckScheduleDates);
        }             
    }

/*public override void onAfterUpdate() {
    if (!this.oppProductScheduleRecordSelector.lstToOLIScheduleUpdate.isEmpty()) {
        // Enqueue the Queueable job to process the schedules asynchronously
        ProcessOpportunitySchedules job = new ProcessOpportunitySchedules(this.oppProductScheduleRecordSelector.lstToOLIScheduleUpdate);
        System.enqueueJob(job);
    }
}*/



    public override void onAfterUpdate(){
        if(!this.oppProductScheduleRecordSelector.lstToOLIScheduleUpdate.isEmpty()){
            OppoProductSchUtilities.updateCustomOLI(this.oppProductScheduleRecordSelector.lstToOLIScheduleUpdate);
        }
    }
        
    public override void onBeforeDelete(){ 
        
        //if(!this.oppProductScheduleRecordSelector.closedWonOpp.isEmpty()){
          //  OppoProductSchUtilities.PreventToUpdateQuantityAndRevenue(this.oppProductScheduleRecordSelector.closedWonOpp, this.oldMap, 'Delete');
        //}
    }
     
    
}