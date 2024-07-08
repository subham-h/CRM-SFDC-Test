/*
 * Author   : Jiji
 * Purpose  : Record Selector class for Incident rigger
 *        
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-002716   29-Mar-2016 Jiji@UST                Code created
 * 
 */  

public class IncidentRecordSelector  implements RecordSelector {

    // Variable Declaration
    private TriggerHandler incTriggerHandler;
    
    public set<Id> vesselIdSet = new set<Id>();
    public list<Incident__c> validIncidentList = new list<Incident__c>();
    public map<Id, Vessel__c> mapRelatedVessels = new map<Id, Vessel__c>();
    
    // Constructor
    public IncidentRecordSelector(list<Incident__c> newIncidentList, map<Id, Incident__c> oldIncidentMap, TriggerHandler incTriggerHandler) {
        this.incTriggerHandler = incTriggerHandler;
        this.selectRecords(newIncidentList, oldIncidentMap);
        if(newIncidentList != null) {
            this.getRelatedRecords(newIncidentList);
        }
    }
    
    // Select valid records based on the criteria
    public void selectRecords(list<Incident__c> IncidentList, map<Id, sObject> oldIncidentMap) {
       if(incidentList.Size() > 0){
            // Iterate over the new incident records to check the criteria
            for(Incident__c incidentRecord : incidentList){
                // Get the old incident record if it is not blank
                Incident__c oldIncident;
                if(oldIncidentMap != null && !oldIncidentMap.isEmpty()) {
                    oldIncident = (Incident__c)oldIncidentMap.get(incidentRecord.Id);
                }
                
                // Incident can be linked to vessel policy only if it is associated to a vessel and a date of incident.
                if((incTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT 
                   || (incTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE 
                        && (incidentRecord.Insured_Vessel__c != oldIncident.Insured_Vessel__c || incidentRecord.Date_of_Incident__c != oldIncident.Date_of_Incident__c)))
                   && incidentRecord.Insured_Vessel__c != NULL && incidentRecord.Date_of_Incident__c != NULL
                ){
                   // Collect the VesselId and the valid incident records
                   vesselIdSet.add(incidentRecord.Insured_Vessel__c); 
                   validIncidentList.add(incidentRecord);
                }
            }
        } 
    }

    // Get the records related to the incident
    public void getRelatedRecords(list<Incident__c> incidentList) {
        getRelatedVessels();
    }
    
    // Get the Vessel records related to the incident.  
    public void getRelatedVessels() {
        if(!vesselIdSet.isEmpty()) {
            mapRelatedVessels = new map<Id, Vessel__c>([select Id, (select Id, Vessel__c, Vessel_Policy_Start_Date__c, Vessel_Policy_End_Date__c from Vessel_Policies__r) 
                                                 from Vessel__c where Id in :vesselIdSet]);
        }
    }
    
}