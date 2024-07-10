/*
 * Author   : Nisha
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on event trigger.
 *        
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-004102   08/07/2016  nisha.arjunan@UST       Code created
 * 2.0      RQ-009006   09/08/2018  Sidhartha               Added before insert & after delete
 * 3.0      RQ-012152   05-10-2019 Neha@TCS                 Remove makeSalescallstartdatenull() method
 */  

public class EventTriggerHandler extends TriggerHandler {
    
    public map<Id, Event> newMap;
    public map<Id, Event> oldMap;
    public EventTriggerHandler() {
        this.newMap = (map<Id, Event>)Trigger.newMap;
        this.oldMap = (map<Id, Event>)Trigger.oldMap; 
    }
    
    public EventRecordSelector evntRecordSelector;
    public override void getRecordSelector() {
        evntRecordSelector = new EventRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert() {
        if(!evntRecordSelector.lstEventContact.isEmpty()) { 
            EventFieldPopulator.populatecontact(evntRecordSelector.lstEventContact,evntRecordSelector.setWhatIds);
        }
        
    }
    
    public override void onBeforeUpdate(){    
        if(!evntRecordSelector.lstEventContact.isEmpty()) { 
            EventFieldPopulator.populatecontact(evntRecordSelector.lstEventContact,evntRecordSelector.setWhatIds);
        }
    }
    
    public override void onAfterInsert(){

        //EventUtilities.createEventRelation(evntRecordSelector.setevtIds);        
        if(!evntRecordSelector.setAccountIds.isEmpty()) {
            // Updates the Last Activity date on the account for which the event exists
            AccountUtilities.populateLastActivityDate(evntRecordSelector.setAccountIds);
        }
        
        if(!SalesCallUtilities.salesCallUpdatingEvent()) {
            // Update the Sales Call object  fields whenever  the event record is updated.
            EventUtilities.updateSalesCallOnEventUpdation(Trigger.new, null);
            
        }
       
        // No need to fire Event trigger again during workflow field update
        TriggerExecutionController.skipEventTrigger(true);

    }
    
    public override void onAfterUpdate(){        
        
        if(!evntRecordSelector.setAccountIds.isEmpty()) {
            // Updates the Last Activity date on the account for which the event exists
            AccountUtilities.populateLastActivityDate(evntRecordSelector.setAccountIds);
        }
        
        if(!SalesCallUtilities.salesCallUpdatingEvent()) {
            // Update the Sales Call object  fields whenever  the event record is updated.
            EventUtilities.updateSalesCallOnEventUpdation(Trigger.new, this.oldMap);
        }
        
        // No need to fire Event trigger again during workflow field update
        TriggerExecutionController.skipEventTrigger(true);

    }
    
    /*public override void onAfterDelete() {
        EventFieldPopulator.makeSalescallstartdatenull(trigger.old);
    }*/
}