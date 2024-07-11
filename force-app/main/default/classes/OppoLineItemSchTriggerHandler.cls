/*
* Created By   : sowmya.s@maersk.com
* Purpose      : Update isCloned to false before insert
*              
* Revision Ref Number    Date            Owner                   Description
* -------- ----------   -----------  -------------------   --------------------------------------------------------
* 1.0      #RQ-009014   02-Sep-2022  sowmya.s@maersk.com   Update isCloned to false before insert
* 2.0      SFSE-9685	10-Nov-2022	 shilpa.nagtode		   Add logic to handle change in quantity/revenue on OLI Schedule records
* 3.0		SFSE-10005	13-Dec-2022		Kiran@Maersk		Commenting validateAgreementDates which is causing live issue

*/

public class OppoLineItemSchTriggerHandler extends TriggerHandler {
    
    public Map<Id, OpportunityLineItemSchedule> newMap;
    public Map<Id, OpportunityLineItemSchedule> oldMap;
     
    public OppoLineItemSchTriggerHandler() {
        
        this.newMap = ( map<Id, OpportunityLineItemSchedule> ) Trigger.newMap;
        this.oldMap = ( map<Id, OpportunityLineItemSchedule> ) Trigger.oldMap; 
        
    }
        
    public OppLineItemScheduleRecordSelector oliScheduleRecordSelector;
    
    public override void getRecordSelector() {
        oliScheduleRecordSelector = new OppLineItemScheduleRecordSelector(Trigger.new, this.oldMap, this);
    }

    public override void onBeforeInsert(){
        
        if(!this.oliScheduleRecordSelector.lstClonedRecords.isEmpty()){
            OppoLineItemSchUtilities.setCloneFlag(this.oliScheduleRecordSelector.lstClonedRecords);
        } 
        
        if(!this.oliScheduleRecordSelector.closedWonOpp.isEmpty()){
            OppoLineItemSchUtilities.PreventToUpdateQuantityAndRevenue(this.oliScheduleRecordSelector.closedWonOpp, this.oldMap, 'Insert');
        }  
        
         if(!this.oliScheduleRecordSelector.lstToCheckScheduleDates.isEmpty()){
            //OppoLineItemSchUtilities.validateAgreementDates(this.oliScheduleRecordSelector.lstToCheckScheduleDates);
        } 
    }
    
    public override void onBeforeUpdate(){
        if(!this.oliScheduleRecordSelector.closedWonOpp.isEmpty()){
            OppoLineItemSchUtilities.PreventToUpdateQuantityAndRevenue(this.oliScheduleRecordSelector.closedWonOpp, this.oldMap, 'Update');
        }
        
        if(!this.oliScheduleRecordSelector.lstToCheckScheduleDates.isEmpty()){
            //OppoLineItemSchUtilities.validateAgreementDates(this.oliScheduleRecordSelector.lstToCheckScheduleDates);
        } 
    }
    
    public override void onBeforeDelete(){ 
        
        if(!this.oliScheduleRecordSelector.closedWonOpp.isEmpty()){
            OppoLineItemSchUtilities.PreventToUpdateQuantityAndRevenue(this.oliScheduleRecordSelector.closedWonOpp, this.oldMap, 'Delete');
        }
    }
}