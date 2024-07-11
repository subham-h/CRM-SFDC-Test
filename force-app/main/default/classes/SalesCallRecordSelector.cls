/*
 * Author   : Nisha
 * Purpose  : Record Selector class for Sales Call Trigger.
 *        
 * Revision Ref Number  Date        Owner                                       Description
 * -------- ----------  ----------- -------------------                         -----------
 * 1.0      RQ-000228   11/09/2014   Krishnamoorthi.murugesan@ust-global.com    Create an Event while updating the Sales Call 
 * 2.0      RQ-004292   03/08/2016   nisha.arjunan@UST                          Implemented the record selector for CBO Architecture.
 * 3.0      RQ-009006   09/08/2018   sidhartha                                  Added logic to stop creating events for Sales Call
 * 4.0      RQ-012152   05-10-2019 Neha@TCS                                     Remove reference of Sales and Business review call record type 
 * 5.0					05-01-2020   Sreya										CSAT onboarding for Service Call.
 * 6.0      SC-1996     15/02/2021   Sreya                                      Bug Fix: get related contact contact informaton to check contact email is not blank.
 * 7.0      SC-2471     09/06/2021   Urvish@UST                                 CSAT opt out logic for Service Call(Send Onboarding survey field)
 */  

public class SalesCallRecordSelector implements RecordSelector {
    
    private TriggerHandler salCallTriggerHandler;
    
    //Map of Sales Calls updated.
    public map <Id,Sales_Call__c> mapSCToUpdateEvents =  new map <Id,Sales_Call__c>();
    
    //Map of sales calls created.
    public map <Id,Sales_Call__c> mapSCToCreateEvents =  new map <Id,Sales_Call__c>();
    
    //SC-1662 : List of completed service call
    public List<Sales_Call__c> listCompletedServiceCalls = new List<Sales_Call__c>();
    
    //SC-1996 :Related Contact Map
    public set<Id> setContactIds = new set<ID>();
    public map<Id, Contact> mapRelatedContacts = new map<Id, Contact>();
    
    
    public SalesCallRecordSelector(list<Sales_Call__c> lstSalesCall, map<Id, Sales_Call__c> mapOldSalesCall, TriggerHandler salCallTriggerHandler) {
        this.salCallTriggerHandler = salCallTriggerHandler;
        this.selectRecords(lstSalesCall, mapOldSalesCall);
        
        if(lstSalesCall != null) {
            this.getRelatedRecords(lstSalesCall);
        }
        else if(mapOldSalesCall != null) {
            this.getRelatedRecords(mapOldSalesCall.values());
        }
    }
    
    public void selectRecords(list<Sales_Call__c> lstSalesCall, map<Id, sObject> mapOldSalesCall) {
      
        if(!lstSalesCall.isEmpty()) {
            // Iterate over the new Sales_Call__c records to check the criteria
            for(Sales_Call__c newSalesCall : lstSalesCall) {
                // Get the old Sales_Call__c record if it is not blank
                Sales_Call__c oldSalesCall;
                if(mapOldSalesCall != null && !mapOldSalesCall.isEmpty()) {
                    oldSalesCall = (Sales_Call__c)mapOldSalesCall.get(newSalesCall.Id);
                } 
                //SC-1996 Get related contact Ids
                if(newSalesCall.Contact__c != null) {
                    setContactIds.add(newSalesCall.Contact__c);
                } 
                //Id salesCallRTID = StaticFactory.getRecordTypeIdByName('Sales_Call__c', 'Sales Call');
                //Id businessReviewRTID = StaticFactory.getRecordTypeIdByName('Sales_Call__c', 'Business Review');
                Id serviceCallRTID = StaticFactory.getRecordTypeIdByName('Sales_Call__c', 'Service Call');
                if(salCallTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) {                   
                   if(salCallTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                         //SC-1662 : Getting the list of completed onboarding service call
                         //SC-2471 : CSAT opt out logic for Service Call(Send Onboarding survey field)
                        if((newSalesCall.Status__c != oldSalesCall.Status__c ) && ( newSalesCall.Service_Type__c == 'Onboarding' && newSalesCall.Status__c == 'Completed' && newSalesCall.RecordTypeId == serviceCallRTID && newSalesCall.Survey_sent__c == false && newSalesCall.Send_Onboarding_Survey__c == 'Yes') ){
                            listCompletedServiceCalls.add(newSalesCall);
                        }
                    }
                }
                if(salCallTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER) {
                    if(salCallTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                        //if(newSalesCall.RecordTypeId != salesCallRTID || newSalesCall.RecordTypeId !=businessReviewRTID)
                        if(newSalesCall.RecordTypeId == serviceCallRTID){
                            if(newSalesCall.Do_Not_Create_Event__c == false && !EventUtilities.eventUpdatingSalesCall()) {
                                System.debug('###### entered');
                                mapSCToCreateEvents.put(newSalesCall.Id, newSalesCall); 
                            }   
                        }
                    }
                    else if(salCallTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                        // RQ-000228 - Added condition to check the status for updating the Sales Call
                        system.debug('@@@@@@' + newSalesCall.RecordTypeId);
                        if(oldSalesCall != null && !EventUtilities.eventUpdatingSalesCall()) {
                            //if(newSalesCall.RecordTypeId != salesCallRTID || newSalesCall.RecordTypeId !=businessReviewRTID) 
                            if(newSalesCall.RecordTypeId == serviceCallRTID ) {
                                if(newSalesCall.Do_Not_Create_Event__c == oldSalesCall.Do_Not_Create_Event__c) { // This will be executed only on sales call update...
                                    if(newSalesCall.Name != OldSalesCall.Name
                                       || newSalesCall.StartDateTime__c != OldSalesCall.StartDateTime__c
                                       || newSalesCall.EndDateTime__c != OldSalesCall.EndDateTime__c
                                       || newSalesCall.Contact__c != OldSalesCall.Contact__c
                                       || newSalesCall.Type__c != OldSalesCall.Type__c
                                       || newSalesCall.OwnerId != OldSalesCall.OwnerId
                                       || newSalesCall.Event_Description__c != OldSalesCall.Event_Description__c
                                       || newSalesCall.Location__c != OldSalesCall.Location__c
                                       || (newSalesCall.Status__c != OldSalesCall.Status__c && newSalesCall.Status__c == 'Cancelled') // RQ-000204 - Cancelled Status check
                                      ) { 
                                          
                                          mapSCToUpdateEvents.put(newSalesCall.Id, newSalesCall); 
                                          system.debug('@@@@@' + mapSCToUpdateEvents);
                                      }
                                } 
                                else if(newSalesCall.Do_Not_Create_Event__c == false) { // This will be executed only when sales call created...
                                    mapSCToCreateEvents.put(newSalesCall.Id, newSalesCall);
                                }
                            }
                            /* else {
                                if(newSalesCall.Name != OldSalesCall.Name 
                                   || newSalesCall.Manager__c != OldSalesCall.Manager__c
                                   || newSalesCall.StartDateTime__c != OldSalesCall.StartDateTime__c
                                   || newSalesCall.EndDateTime__c != OldSalesCall.EndDateTime__c
                                   || newSalesCall.Contact__c != OldSalesCall.Contact__c
                                   || newSalesCall.Type__c != OldSalesCall.Type__c
                                   || newSalesCall.OwnerId != OldSalesCall.OwnerId
                                   || newSalesCall.Event_Description__c != OldSalesCall.Event_Description__c
                                   || newSalesCall.Location__c != OldSalesCall.Location__c
                                   || (newSalesCall.Status__c != OldSalesCall.Status__c && newSalesCall.Status__c == 'Cancelled') // RQ-000204 - Cancelled Status check
                                  ) { 
                                      mapSCToUpdateEvents.put(newSalesCall.Id, newSalesCall);
                                  }
                            }*/
                        }                       
                    }
                }
            }
        }
    }
    
    public void getRelatedRecords(list<Sales_Call__c> lstSalesCall){
        getRelatedContacts();
    }
    //SC-1996: Get related contact details
    public void getRelatedContacts() {
        if(!setContactIds.isEmpty()) {           
            mapRelatedContacts = new map<Id, Contact>([select Id, Email from Contact where Id in :setContactIds]); 
        }
    }    
}