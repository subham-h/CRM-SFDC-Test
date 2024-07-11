/*
 * Author   : Nisha
 * Purpose  : Record Selector class for Event Trigger.
 *        
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-004102   08/07/2016 nisha.arjunan@UST         Code created
 * 2.0      RQ-004102   10/08/2018 sidhartha                 added after delete
 * 3.0      RQ-012152   07/10/2019  Neha@TCS                Remove after delete section method is commented from Trigger handler
 */  

public class EventRecordSelector implements RecordSelector {
    
    private TriggerHandler eveTriggerHandler;
    
    // To store related Account details
    public set<Id> setAccountIds = new set<Id>();
    public set<Id> setWhatIds = new set<Id>();
    public set<Id> setWhatIdsDel = new set<Id>();
    public set<Id> setevtIds = new set<Id>();
    public list<Event> lstEventContact = new list<Event>();
    public EventRecordSelector(list<Event> lstEvent, map<Id, Event> mapOldEvents, TriggerHandler eveTriggerHandler) {
        this.eveTriggerHandler = eveTriggerHandler;
        this.selectRecords(lstEvent, mapOldEvents);
        
        if(lstEvent != null) {
            this.getRelatedRecords(lstEvent);
        }
        else if(mapOldEvents != null) {
            this.getRelatedRecords(mapOldEvents.values());
        }    
    }
    
    public void selectRecords(list<Event> lstEvent, map<Id, sObject> oldEventMap) {
        if(lstEvent != null) {
            
            // Iterate over the new task records to check the criteria
            for(Event eventRecord : lstEvent){
                
                // Get the old task record if it is not blank
                Event oldEvent;
                if(oldEventMap != null && !oldEventMap.isEmpty()) {
                    oldEvent = (Event)oldEventMap.get(eventRecord.Id);
                }
                
                if(eveTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) {
                    if(eveTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                        if(eventRecord.WhatId != null) {
                            setWhatIds.add(eventRecord.WhatId);
                            lstEventContact.add(eventRecord);
                        }
                    }
                    if(eveTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                        if(eventRecord.WhatId != null) {
                            setWhatIds.add(eventRecord.WhatId);
                            lstEventContact.add(eventRecord);
                        }
                    }
                }                
                if(eveTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER){
                    if((eveTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT)||(eveTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE)){                
                        if(eventRecord.AccountId != null) {
                            setAccountIds.add(eventRecord.AccountId);
                        }
                        setevtIds.add(eventRecord.Id);
                    }
                } 
            }
        }
        
        /*if(eveTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER && eveTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE) {       
            for(Event dele : (List <Event>)oldEventMap.values()){
                setWhatIdsDel.add(dele.WhatId);  
                system.debug('@@@@' + setWhatIdsDel);
            }
            
        }*/
    }
    
    public void getRelatedRecords(list<Event> lstEvent){
    }
}