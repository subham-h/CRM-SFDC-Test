/*
 * Author   : Jiji
 * Purpose  : Handler class for IncidentTrigger written on Incident__c object
 *        
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-002946   10-Feb-2016 Jiji@UST                Trigger Handler class called by the IncidentTrigger written on Incident__c object
 *  
 */

public class IncidentTriggerHandler extends TriggerHandler{
    
    public map<Id, Incident__c> newMap;
    public map<Id, Incident__c> oldMap;
    public IncidentTriggerHandler() {
        this.newMap = (map<Id, Incident__c>)Trigger.newMap;
        this.oldMap = (map<Id, Incident__c>)Trigger.oldMap; 
    }
    
    // Get valid records based on criteria
    public IncidentRecordSelector incidentRecordSelector;
    public override void getRecordSelector() {
        IncidentRecordSelector = new IncidentRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert() {
		if(!incidentRecordSelector.validIncidentList.isEmpty()) {
			// Link vessel policy to a new incident
        	IncidentFieldPopulator.linkVesselPolicyToIncident(incidentRecordSelector.validIncidentList, incidentRecordSelector.mapRelatedVessels);
		}
    }
    
    public override void onBeforeUpdate() {
        if(!incidentRecordSelector.validIncidentList.isEmpty()) {
        	// Link vessel policy to an incident when Vessel/Date of incident is changed.
        	IncidentFieldPopulator.linkVesselPolicyToIncident(incidentRecordSelector.validIncidentList, incidentRecordSelector.mapRelatedVessels);
        }
    }

}