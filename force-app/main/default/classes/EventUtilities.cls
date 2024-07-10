/*
 * Author   : Nisha
 * Purpose  : Field Populator class for Event Trigger
 *        
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 2.0      RQ-000190                                       When trying to link an Event with a sales call, if the sales call is linked to a Lead, then Name field in Event should be blank.
 * 3.0      RQ-000256                                       Added the null check (ar.get('scId')!= null) against scId.
 * 4.0      RQ-004102   08/07/2016  nisha.arjunan@UST       Created for implementing CBO (Centralized By Org) trigger architecture.
 * 5.0      RQ-009006   24/8/2018   Sidhartha               Updated to Include Manager and Whoid as an attendee in an Event.
 * 5.1      RQ-009409   02/10/2018  Nitin                   Added check to see if Event subject is populated or not 
 * 5.2      RQ-009413   03/10/2018  Sidhartha               Removed subject field, not to get sync with Event and SalesCall
 * 5.3      RQ-009412   03/10/2018  Sidhartha               Removed contact to get added as Attendee automatically. 
 * 6.0      RQ-009511   30/11/2018  Meghana                 If Event type is blank then do not sync it to Customer Call 
 * 7.0      RQ-012152   05/10/2019 Neha@TCS                 Remove reference of Sales Call and Business Review record type
 */  

public class EventUtilities {
    
    // Recursion control...
    private static boolean bEventToSalesCall = false;
    static Id serviceCallRTID = StaticFactory.getRecordTypeIdByName('Sales_Call__c', 'Service Call');
    public static boolean eventUpdatingSalesCall() {
        return bEventToSalesCall;
    }
    
    /*@future
    public static void createEventRelation (Set<id> eventId) {
        Id salesCallRTID = StaticFactory.getRecordTypeIdByName('Sales_Call__c', 'Sales Call');
        Id businessReviewRTID = StaticFactory.getRecordTypeIdByName('Sales_Call__c', 'Business Review');

        system.debug('@@@@@setId' + eventId);
        List<Event> lstEvtId = [select Id, WhatId, WhoId from Event where ID IN:eventId];
        system.debug('@@@@@lstEvtId' + lstEvtId);

    Map<Id, Id> mapWhatIdToEvtId = new Map<Id, Id>();*/
    //Map<Id, Id> mapEvtIdToWhoId = new Map<Id, Id>();RQ-009412
    /*Set<Id> setEvtWhatId = new Set<Id>();
    
    for (Event evtRecord : lstEvtId){
      setEvtWhatId.add(evtRecord.WhatId);
      mapWhatIdToEvtId.put(evtRecord.WhatId, evtRecord.Id);
      //mapEvtIdToWhoId.put(evtRecord.Id, evtRecord.WhoId); RQ-009412
    }

        List<Sales_Call__c> lstSalesCall = [select RecordTypeId, Manager__c from Sales_Call__c where Id in :setEvtWhatId];
        List<EventRelation> lstERToinsert = new List<EventRelation>();
        
        for (Sales_Call__c scRecord : lstSalesCall){
          if( scRecord.RecordTypeId == salesCallRTID || scRecord.RecordTypeId == businessReviewRTID ) {
            Id idEvent = mapWhatIdToEvtId.get(scRecord.Id);*/
            //Id idWho = mapEvtIdToWhoId.get(idEvent);   RQ-009412
            
                /* RQ-009412
                 * EventRelation eR = new EventRelation();
                  eR.EventId = idEvent;
                  eR.RelationId = idWho; 
                  lstERToinsert.add(eR);
                  */
              /*if(scRecord.Manager__c != null) {
                  EventRelation eR1 = new EventRelation();
                  eR1.EventId = idEvent;
                  eR1.RelationId = scRecord.Manager__c; 
                  lstERToinsert.add(eR1);
                  system.debug('@@@@@lstERToinsert' + lstERToinsert);    
              }    
          }
        }
        try{
          insert lstERToinsert;  
        } catch (Exception e) {
            system.debug('@@@@@error' + e);
        }
        
    }*/

    // Update the Sales Call object  fields whenever  the event record is updated.
    public static void updateSalesCallOnEventUpdation(list<Event> lstNewEvents, map<Id, Event> mapOldEvents) {
        // Will create the map of sales call ids to be updated on insert/update of sales call events.
        map<Id, Event> mapWhatIdEvent = new map<Id, Event>(); // Will be used to store SalesCall Ids and corresponding Event...
        
        for(Event newEvent : lstNewEvents) {
            if(newEvent.WhatId != null && String.valueOf(newEvent.WhatId).substring(0,3) == Label.Sales_Call_Object_Key_Prefix) {
                if(mapOldEvents != null) { // This will be executed only on event record update...
                    Event oldEvent = mapOldEvents.get(newEvent.Id);                    
                    if(newEvent.Subject != oldEvent.Subject || newEvent.StartDateTime != oldEvent.StartDateTime || newEvent.EndDateTime != oldEvent.EndDateTime || newEvent.WhoId != oldEvent.WhoId || newEvent.WhatId != oldEvent.WhatId || newEvent.Type != oldEvent.Type || newEvent.OwnerId != oldEvent.OwnerId || newEvent.Description != oldEvent.Description || newEvent.Location != oldEvent.Location) {
                        mapWhatIdEvent.put(newEvent.WhatId, newEvent);
                    }               
                }               
                else { // This will be executed only on event record creation... 
                    mapWhatIdEvent.put(newEvent.WhatId, newEvent);                     
                }
            }
        }
        
        System.debug('###### mapWhatIdEvent: '+ mapWhatIdEvent);
        syncEventToSalesCall(mapWhatIdEvent);
    }
    
    // This method will sync the events and sales calls.
    public static void syncEventToSalesCall(Map<Id, Event> mapWhatIdEvent){
        list<Sales_Call__c> lstSalesCalls = new list<Sales_Call__c>();
        map<Id, Sales_Call__c> mapSalesCalls = new map<Id, Sales_Call__c>([SELECT Id, Name, RecordTypeId,Contact__c, Lead__c, StartDateTime__c, EndDateTime__c, Objective__c, Type__c, OwnerId 
                                                                          FROM Sales_Call__c WHERE Id IN :mapWhatIdEvent.keyset()]);
        
        // #RQ-000185 - Updated the below query with WHERE condition 'IsChild = FALSE' to avoid error while sync with Sales Call 
        for(AggregateResult ar : [SELECT count(Id) numRecs, WhatId scId FROM Event WHERE WhatId IN :mapWhatIdEvent.keyset() AND IsChild = FALSE GROUP BY WhatId]) {
            System.debug('###### ar: ' + ar );
            
            Id salesCallId = (Id)ar.get('scId');            
            if(salesCallId != null && String.valueOf(salesCallId).substring(0,3) == Label.Sales_Call_Object_Key_Prefix) {
                // If there is more than one Event related to the Sales Call then throw an error...
                if((Integer)ar.get('numRecs') > 1) {
                    mapWhatIdEvent.get(salesCallId).AddError(Label.Too_Many_Events_On_Sales_Call_Error);
                } 
                // v2.0 - Start
                else if(mapSalesCalls.get(salesCallId).Lead__c != null && mapWhatIdEvent.get(salesCallId).WhoId != null) {
                    mapWhatIdEvent.get(salesCallId).WhoId.AddError(Label.Name_Should_Be_Blank_For_Lead_Sales_Call);                          
                } 
                // v2.0 - End
                else if(mapSalesCalls.get(salesCallId).Contact__c != null && mapWhatIdEvent.get(salesCallId).WhoId == null){
                    mapWhatIdEvent.get(salesCallId).WhoId.AddError(Label.Name_Should_Not_Be_Blank_For_Contact_Sales_Call);                           
                }
                else {
                    // Sync both sales call record with corresponding Event...
                    Event currentEvent = mapWhatIdEvent.get(salesCallId);
                    Sales_Call__c salesCall = mapSalesCalls.get(salesCallId);
                    if(currentEvent.Subject !=null && salesCall.RecordTypeId == serviceCallRTID) {
                        salesCall.Name = currentEvent.Subject;
                    }
                    /*
                     *   RQ-009413
                    if (currentEvent.Subject != null){
                      if(currentEvent.Subject.Length() > 80) {
                         salesCall.Name = currentEvent.Subject.subString(0,79).replaceAll('(\\r|\\n)+', ''); 
                      }else {
                          salesCall.Name = currentEvent.Subject.replaceAll('(\\r|\\n)+', ''); 
                      }
                    }*/
                    salesCall.StartDateTime__c = currentEvent.StartDateTime;
                    salesCall.EndDateTime__c = currentEvent.EndDateTime;
                    // As per the standard functionality, only contacts can be added as WhoId, when WhatId is not null...
                    salesCall.Contact__c = currentEvent.WhoId;
                    if (currentEvent.Type != null && currentEvent.Type != '')
                      salesCall.Type__c = currentEvent.Type;
                    salesCall.OwnerId = currentEvent.OwnerId;
                    salesCall.Do_Not_Create_Event__c = false;
                    salesCall.Event_Description__c = currentEvent.Description;
                    salesCall.Location__c = currentEvent.Location;
                    lstSalesCalls.add(salesCall);
                    system.debug('@@@@' + lstSalesCalls);
                }
            }                                        
        }
        
        if(!lstSalesCalls.isEmpty()) {
            try {
                bEventToSalesCall = true;
                update lstSalesCalls;
                bEventToSalesCall = false;
            }
            catch(Exception e) {
                System.debug('##### Exception in update lstSalesCalls : ' + e);
                ErrorLogger.writeError( 'SFDC', 'Event', 'EventUtilities.syncEventToSalesCall', String.valueOf(e.getCause()), e.getMessage(), e.getStackTraceString()); 
   
            }
        }
    }
}