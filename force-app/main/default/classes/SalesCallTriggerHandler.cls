/*
 * Author   : Nisha
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on Sales Call trigger.
 *        
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-004292   08/07/2016  nisha.arjunan@UST       Code created
 * 2.0		RQ-004108 	14/07/2016  Jiji@UST        		Update Liner Brand References in Sales Call as part of Single Contact Model 
 * 3.0		SC-1662		05-01-2020  Sreya					CSAT onboarding for Service Call. 
 * 4.0      SC-1996     15/02/2021  Sreya                   Bug Fix: get related contact contact informaton to check contact email is not blank.   
 * 5.0	    SC-2061     09-03-2021	Manik@UST				Country Based List View for Service Calls
 */  

public class SalesCallTriggerHandler extends TriggerHandler {
    
    public map<Id, Sales_Call__c> newMap;
    public map<Id, Sales_Call__c> oldMap;
    public SalesCallTriggerHandler() {
        this.newMap = (map<Id, Sales_Call__c>)Trigger.newMap;
        this.oldMap = (map<Id, Sales_Call__c>)Trigger.oldMap; 
    }
    
    public SalesCallRecordSelector salCallRecordSelector;
    public override void getRecordSelector() {
        salCallRecordSelector = new SalesCallRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert(){
        //  Populate values in Sales Call "Length" and "Has" fields.
        SalesCallFieldPopulator.populateLenghtAndHasFields(Trigger.new); 
        SalesCallFieldPopulator.updateLinerBrand(Trigger.new); //Ver 2.0
        //SC-2061 : Country Based List View for Service Calls
        SalesCallFieldPopulator.updateCountry(Trigger.new);
    }
    
    public override void onBeforeUpdate(){
        //  Populate values in Sales Call "Length" and "Has" fields.
        SalesCallFieldPopulator.populateLenghtAndHasFields(Trigger.new);
        SalesCallFieldPopulator.updateLinerBrand(Trigger.new); // Ver 2.0
        //SC-1662 : Invoking the method for updating "Encrypted Service Call Id "
        //SC-1996 : Passing salCallRecordSelector
        if(!salCallRecordSelector.listCompletedServiceCalls.isEmpty()){
            SalesCallFieldPopulator.populateEncryptedId(salCallRecordSelector.listCompletedServiceCalls,salCallRecordSelector); 
        }
        //SC-2061 : Country Based List View for Service Calls
        SalesCallFieldPopulator.updateCountry(Trigger.new);
    }
    
    public override void onAfterInsert() {
        if(!salCallRecordSelector.mapSCToCreateEvents.isEmpty()){
            // Create new Event for the Sales Call.
            SalesCallUtilities.createEvents(salCallRecordSelector.mapSCToCreateEvents);             
        } 
        
        // To avoid creation of 2nd Event during workflow field update.
        TriggerExecutionController.skipSalesCallTrigger(true);
    }
    
    public override void onAfterUpdate() {
        if(!salCallRecordSelector.mapSCToCreateEvents.isEmpty()){
            // Create new Event for the Sales Call.
            SalesCallUtilities.createEvents(salCallRecordSelector.mapSCToCreateEvents); 
        }
        
        if(!SalCallRecordSelector.mapSCToUpdateEvents.isEmpty()) {
            // Synchronize sales call and events.
            SalesCallUtilities.synchronizeToEvents(salCallRecordSelector.mapSCToUpdateEvents);
        }
        
        // To avoid creation of 2nd Event during workflow field update.
        TriggerExecutionController.skipSalesCallTrigger(true);
    }
    
}