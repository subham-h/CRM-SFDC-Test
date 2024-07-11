/*
* Trigger Handler Class for MSL/SCL Support Level
* 
*Version  Date         Owner                                    RQ#           Description
**********************************************************************************************************
*2.0      06/10/2015   Sandhya.Sambasivan@ust-global.com        #RQ-001522    Created 
*3.0      25/08/2023   Richa@Maersk                             SC-8922	      Update Service Relationship lookup on OPL
*4.0	  23-01-2024   Nayana@maersk.com						SC-6992		  Modified the framework in accordance with case trigger framework
*/

Public Class CareTriggerHandler extends TriggerHandler{
    
    public map<Id, Care_Relationship__c> newMap;
    public map<Id, Care_Relationship__c> oldMap;
    public CareTriggerHandler() {
        this.newMap = (map<Id, Care_Relationship__c>)Trigger.newMap;
        this.oldMap = (map<Id, Care_Relationship__c>)Trigger.oldMap;
    }
    
    public CareRecordSelector careRecordSelector;
    
    public override void getRecordSelector() {
        careRecordSelector = new CareRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert() {
        if(!careRecordSelector.setAccountIds.isEmpty() || !careRecordSelector.setCountryIds.isEmpty()){
            CareRelationshipUtility.populateMatchRuleFields(trigger.new, this.oldMap);
        }
        if(!careRecordSelector.setValidateGeoCountry.isEmpty() || !careRecordSelector.setValidateGeoCluster.isEmpty()){
        	GeoDataUtility.validateGeoData(null, trigger.new);
        }
    }
    
    public override void onBeforeUpdate() {
        if(!careRecordSelector.setAccountIds.isEmpty() || !careRecordSelector.setCountryIds.isEmpty()){
        	CareRelationshipUtility.populateMatchRuleFields(trigger.new, this.oldMap);
        }
        if(!careRecordSelector.setValidateGeoCountry.isEmpty() || !careRecordSelector.setValidateGeoCluster.isEmpty()){
        	GeoDataUtility.validateGeoData(null, trigger.new);
        }
    }
    
    public override void onAfterInsert() {        
        if(!careRecordSelector.setOplCareId.isEmpty()){            
            CareRelationshipUtility.populateCareRelationship(careRecordSelector.setOplCareId,careRecordSelector.setOplAccountChange,careRecordSelector.setOplCountryIds);
        }
    }
    
    public override void onAfterUpdate() {
        if(!careRecordSelector.setOplCareId.isEmpty()){
            CareRelationshipUtility.populateCareRelationship(careRecordSelector.setOplCareId,careRecordSelector.setOplAccountChange,careRecordSelector.setOplCountryIds);
        }
    }
    
}