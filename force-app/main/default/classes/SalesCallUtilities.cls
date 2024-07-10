/*
 * Author   : Nisha
 * Purpose  : Utility class for Sales Call trigger.
 *        
 * Revision Ref Number  Date        Owner                                   Description
 * -------- ----------  ----------- -------------------                     -----------
 * 1.0     PR-0013     23/06/2014   Ranjini-UST                             Code created as part of #PR-0013.
 * 2.0     RQ-000204   12/09/2014   Krishnamoorthi.murugesan@ust-global.com Updated to delete the corresponding Events when Sales Call Status is 'Cancelled' 
 * 4.0     RQ-000185   30/10/2014   Krishnamoorthi.Murugesan@ust-global.com To fix the error caused by child Event records                                                                                     
 * 3.0     RQ-004292   03/08/2016   nisha.arjunan@UST                       Created class for CBO Architecture
 * 4.0     RQ-009006   24/08/2018   Sidhartha                               Removed Auto Creation of Event.
 * 
 */  

public class SalesCallUtilities {
    
    // Recursion control...
    private static boolean bSalesCallToEvent = false;
    static Id serviceCallRTID = StaticFactory.getRecordTypeIdByName('Sales_Call__c', 'Service Call');
    public static boolean salesCallUpdatingEvent() {
        return bSalesCallToEvent;
    }
   
    public static void createEvents(map<Id, Sales_Call__c> mapSCToCreateEvents) {
        list<Event> lstEventsToBeInserted = new list <Event>();//List of events to be created.
        for(Sales_Call__c sc : mapSCToCreateEvents.Values()){  
            Event eventRecord = new Event ();
            eventRecord.Subject = sc.Name;
            eventRecord.StartDateTime = sc.StartDateTime__c;
            eventRecord.EndDateTime = sc.EndDateTime__c;
            eventRecord.Description = sc.Event_Description__c;
            eventRecord.WhatId = sc.Id;
            eventRecord.WhoId = sc.Contact__c;
            eventRecord.Type = sc.Type__c; 
            eventRecord.OwnerId = sc.OwnerId;
            eventRecord.Location = sc.Location__c;
            
            lstEventsToBeInserted.add(eventRecord);
        }
        
        if(!lstEventsToBeInserted.isEmpty()) {
            try {
                bSalesCallToEvent = true;
                insert lstEventsToBeInserted;
                bSalesCallToEvent = false;
                System.debug('#####lstEventsToBeInserted'+lstEventsToBeInserted);
            }
            catch (Exception e) {
                System.debug('##### Exception in update lstEventsToBeInserted : '+e);
            }
        }
}
    public static void syncToEvtRelationManager(map<Id, Sales_Call__c> mapSCToUpdateEvents) {
        system.debug('@@@@@' + mapSCToUpdateEvents);
        Sales_Call__c salesCall;
        Id evtId;
            for(Event eventRecord : [SELECT Id, WhatId,WhoId FROM Event WHERE WhatId IN: mapSCToUpdateEvents.keyset() AND IsChild = FALSE]) {
            salesCall = mapSCToUpdateEvents.get(eventRecord.WhatId);
             evtId = eventRecord.Id;
             
         }
        system.debug('@@@@@' + evtId);
        if(evtId !=null) {
            List<EventRelation> lstEvtR = [select Id,EventId,RelationId from EventRelation where EventId =:evtId];
         system.debug('@@@@@' + lstEvtR);
        List<EventRelation> lstUpdatedManagerToInsert = new List<EventRelation>();
        Map<Id,String> evtRmap =  new Map<Id,String>();
         if(lstEvtR.size() >0 && lstEvtR !=null) {
             for(EventRelation eR : lstEvtR) {
                 system.debug('@@@@@nullloop');
                 if(eR.RelationId != salesCall.Manager__c) {
                     evtRmap.put(eR.EventId,salesCall.Manager__c);
                 }
             } 
         } else {
            EventRelation evtRelation = new EventRelation();
            evtRelation.EventId = evtId;
             if(salesCall.Manager__c !=null) {
                evtRelation.RelationId = salesCall.Manager__c; 
             }
            
            lstUpdatedManagerToInsert.add(evtRelation);  
         }
         
        if(evtRmap !=null) {
            for(Id d: evtRmap.keyset()) {
                EventRelation evtRelation = new EventRelation();
                evtRelation.EventId = d;
                evtRelation.RelationId = evtRmap.get(d);
                lstUpdatedManagerToInsert.add(evtRelation); 
            }

        }
        system.debug('@@@@@' + lstUpdatedManagerToInsert);
        try {
            insert lstUpdatedManagerToInsert;
        } catch (Exception e) {
            
        } 
        }
       
    }
    
    public static void synchronizeToEvents(map<Id, Sales_Call__c> mapSCToUpdateEvents) {
        system.debug('@@@@@' + mapSCToUpdateEvents);
        list <Event> lstEventsToBeUpdated = new list <Event>(); // List of events to be updated.
        list <Event> lstEventsToBeDeleted = new list <Event>(); // #RQ-000204 List of events to be deleted.  
        
        // #RQ-000185 - Updated the below query with WHERE condition 'IsChild = FALSE' to avoid error while sync with Event
        for(Event eventRecord : [SELECT Id, WhatId, StartDateTime, EndDateTime, WhoId, Subject, OwnerId, Type FROM Event WHERE WhatId IN: mapSCToUpdateEvents.keyset() AND IsChild = FALSE]) {
            Sales_Call__c salesCall = mapSCToUpdateEvents.get(eventRecord.WhatId);
            system.debug('@@@@@' + salesCall);
            // #RQ-000204 Add Cancelled Sales Call Events in the to be deleted list
            if(salesCall.Status__c == 'Cancelled') {
                lstEventsToBeDeleted.add(eventRecord);
            }
            else {
                if(salesCall.RecordTypeId == serviceCallRTID) {
                 eventRecord.Subject = salesCall.Name; 
                }
                //eventRecord.Subject = salesCall.Name;	RQ-009413
                eventRecord.StartDateTime = salesCall.StartDateTime__c;
                eventRecord.EndDateTime = salesCall.EndDateTime__c;
                eventRecord.Description = salesCall.Event_Description__c;
                eventRecord.WhatId = salesCall.Id;
                eventRecord.WhoId = salesCall.Contact__c;
                eventRecord.Type = salesCall.Type__c;
                eventRecord.OwnerId = salesCall.OwnerId;
                eventRecord.Location = salesCall.Location__c;
                
                lstEventsToBeUpdated.add(eventRecord);
            }
        }
        
        if(!lstEventsToBeUpdated.isEmpty()) {
            try {
                System.debug('Inside update method lstEventsToBeUpdated '+lstEventsToBeUpdated);
                bSalesCallToEvent = true;
                update lstEventsToBeUpdated;
                bSalesCallToEvent = false;
            }
            catch (Exception e) {
                System.debug('##### Exception in update lstEventsToBeUpdated : '+e);
            }
        }       
        
        // #RQ-000204 Delete the Cancelled Sales Call Events -- Start
        if(!lstEventsToBeDeleted.isEmpty()) {
            try {
                System.debug('Inside delete method lstEventsToBeDeleted '+lstEventsToBeDeleted);
                bSalesCallToEvent = true;
                delete lstEventsToBeDeleted;
                bSalesCallToEvent = false;
            }
            catch (Exception e) {
                System.debug('##### Exception in delete lstEventsToBeDeleted : '+e);
            }  
        }
        // #RQ-000204 --End         
    }
    
}