/*
* Author    : Richa
* Purpose   : To handle all logic related to OceanPlusLead
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-8485     19-06-2023  Richa@Maersk            Shipment and Country lookup population
* 2.0       SC-8746     03-08-2023  Richa@Maersk            Service Relationship lookup population
* 3.0       SC-8782     12-08-2023  Richa@Maersk            Populate Area and Region lookup
* 4.0       SC-8872     22-08-2023  Richa@Maersk            Insert/Delete OPLI items on Product update
* 5.0       SC-9001     06-09-2023  Richa@Maersk			Update related account fields on insert and update of opl
* 6.0       SC-9001     06-09-2023  Richa@Maersk			Update related contact fields on insert and update of opl
* 7.0       SC-9148    	26-09-2023  Richa@Maersk			Validate OPL status on update
* 8.0       SC-9234     12-10-2023  Richa@Maersk            Add Owner Manager field for Ocean Plus Leads
* 9.0       SC-9582     18-12-2023  Richa@Maersk            Show Booked By Customer and Contact information on OPL
* 10.0      SC-9662     25-01-2024  Nayana@Maersk           Moved updateAccountFields() before populateServiceRelationship() method for Bookedby and Contractual
*/
public class OceanPlusLeadTriggerHandler extends TriggerHandler {
    public map<Id, Ocean_Plus_Lead__c> newMap;
    public map<Id, Ocean_Plus_Lead__c> oldMap;
    public OceanPlusLeadTriggerHandler() {
        this.newMap = (map<Id, Ocean_Plus_Lead__c>)Trigger.newMap;
        this.oldMap = (map<Id, Ocean_Plus_Lead__c>)Trigger.oldMap; 
    }
    
    public OceanPlusLeadRecordSelector oceanPlusLeadRecordSelector;
    
    public override void getRecordSelector() {
        oceanPlusLeadRecordSelector = new OceanPlusLeadRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    
    public override void onBeforeInsert() {
        if(!oceanPlusLeadRecordSelector.mapRelatedShipments.isEmpty()){ 
            OceanPlusLeadFieldPopulator.populateShipmentLookup(Trigger.new, oceanPlusLeadRecordSelector.mapRelatedShipments,oceanPlusLeadRecordSelector,null,this);
        }        
        if(!oceanPlusLeadRecordSelector.mapBookedByParty.isEmpty()){
            OceanPlusLeadFieldPopulator.populateBookedByPartyDetails(Trigger.new,oceanPlusLeadRecordSelector.mapBookedByParty);
        }
        if(!oceanPlusLeadRecordSelector.setCountryCode.isEmpty()){
            OceanPlusLeadFieldPopulator.populateGeography(Trigger.new,oceanPlusLeadRecordSelector.setCountryCode);
        }
        if(!oceanPlusLeadRecordSelector.mapSCVAccount.isEmpty()){
            OceanPlusLeadFieldPopulator.updateAccountFields(Trigger.new,oceanPlusLeadRecordSelector.mapSCVAccount,null,this);
        }
        if(!oceanPlusLeadRecordSelector.setToPopulateSR.isEmpty() && !oceanPlusLeadRecordSelector.mapCareRelationships.isEmpty()){
            OceanPlusLeadFieldPopulator.populateServiceRelationship(oceanPlusLeadRecordSelector.setToPopulateSR,oceanPlusLeadRecordSelector.mapCareRelationships,null,this);
        }
        if(!oceanPlusLeadRecordSelector.mapEmailContact.isEmpty()){
            OceanPlusLeadFieldPopulator.updateContactFields(Trigger.new,oceanPlusLeadRecordSelector.mapEmailContact,null,this);
        }         
        
    }
    public override void onBeforeUpdate() { 

        if(!oceanPlusLeadRecordSelector.mapBookedByParty.isEmpty()){
            OceanPlusLeadFieldPopulator.populateBookedByPartyDetails(Trigger.new,oceanPlusLeadRecordSelector.mapBookedByParty);
        }
        if(!oceanPlusLeadRecordSelector.setCountryCode.isEmpty()){
            OceanPlusLeadFieldPopulator.populateGeography(Trigger.new,oceanPlusLeadRecordSelector.setCountryCode);
        }
        if(oceanPlusLeadRecordSelector.lstOPLsWithSCVCode != null && oceanPlusLeadRecordSelector.lstOPLsWithSCVCode.size() >0){
       		OceanPlusLeadFieldPopulator.updateAccountFields(oceanPlusLeadRecordSelector.lstOPLsWithSCVCode,oceanPlusLeadRecordSelector.mapSCVAccount,this.oldMap,this);
        }
        if(!oceanPlusLeadRecordSelector.setToPopulateSR.isEmpty()){
            OceanPlusLeadFieldPopulator.populateServiceRelationship(oceanPlusLeadRecordSelector.setToPopulateSR,oceanPlusLeadRecordSelector.mapCareRelationships,this.oldMap,this);
        } 
        if(oceanPlusLeadRecordSelector.lstOPLsWithEmails != null && oceanPlusLeadRecordSelector.lstOPLsWithEmails.size() >0){
            OceanPlusLeadFieldPopulator.updateContactFields(oceanPlusLeadRecordSelector.lstOPLsWithEmails,oceanPlusLeadRecordSelector.mapEmailContact,this.oldMap,this);
        }
        if(!oceanPlusLeadRecordSelector.mapOPLStatusUpdate.isEmpty()) {
            OceanPlusLeadFieldPopulator.validateOPLStatus(oceanPlusLeadRecordSelector.mapOPLStatusUpdate);           
        } 
        if(!oceanPlusLeadRecordSelector.setOPLManagerUpdate.isEmpty()) {
            OceanPlusLeadFieldPopulator.updateOwnerManger(oceanPlusLeadRecordSelector.setOPLManagerUpdate,oceanPlusLeadRecordSelector.mapUserManager);           
        }
		if(!oceanPlusLeadRecordSelector.lstOPLwithMarketingLead.isEmpty()){
            OceanPlusLeadFieldPopulator.updateMarketingEngagedFlag(oceanPlusLeadRecordSelector.lstOPLwithMarketingLead);
        }

    }
    public override void onAfterUpdate() {
        if(!oceanPlusLeadRecordSelector.updateExcludedUsers.contains(UserInfo.getUserId())){
            OceanPlusLeadFieldPopulator.updateOPLLastModifiedDate(this.newMap,this.oldMap);
        }
        if(!oceanPlusLeadRecordSelector.mapInsertAndDeleteOPLI.isEmpty()){
            OceanPlusLeadFieldPopulator.insertAndDeleteOPLI(oceanPlusLeadRecordSelector.mapInsertAndDeleteOPLI,this.oldMap,this);
        }

    }
}