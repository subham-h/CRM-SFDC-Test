/*
* Author    : Richa
* Purpose   : To handle all logic related to Shipment data
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-9041   	11-09-2023  Richa@Maersk            Shipment data related logic
* 2.0      	SC-9582     18-12-2023  Richa@Maersk            Show Booked By Customer SCV on OPL
* 3.0       SC-9586    07-Feb-2024  Richa@Maersk           Modified the code to accomodate changes for Cancelled Event consumption    
* 4.0       SC-9985	   	02-04-2024  Nayana@Maersk           In Progress OceanPlusLead records related logic for Cancelled shipment
*/
public class ShipmentTriggerHandler extends TriggerHandler {
    public map<Id, Shipment__c> newMap;
    public map<Id, Shipment__c> oldMap;
    public ShipmentTriggerHandler() {
        this.newMap = (map<Id, Shipment__c>)Trigger.newMap;
        this.oldMap = (map<Id, Shipment__c>)Trigger.oldMap; 
    }
    
    public ShipmentRecordSelector shipmentRecordSelector;
    
    public override void getRecordSelector() {
        shipmentRecordSelector = new ShipmentRecordSelector(Trigger.new, this.oldMap, this);
    }   
    
    public override void onAfterInsert() { 
        if(shipmentRecordSelector.lstOceanPlusLeadsToUpdate != null && shipmentRecordSelector.lstOceanPlusLeadsToUpdate.size()>0){           
            ShipmentUtility.updateOPLsWithShipmentAndSCV(shipmentRecordSelector.lstOceanPlusLeadsToUpdate,shipmentRecordSelector.mapBookingNumbersAndShipment);
        } 
        //SC-9586
        if(shipmentRecordSelector.lstOceanPlusLeadsToDelete != null && shipmentRecordSelector.lstOceanPlusLeadsToDelete.size()>0){           
            ShipmentUtility.deleteOPLs(shipmentRecordSelector.lstOceanPlusLeadsToDelete);
        } 
        
        //SC-9985
        if(shipmentRecordSelector.lstOceanPlusLeadsToCancel != null && shipmentRecordSelector.lstOceanPlusLeadsToCancel.size()>0){           
            ShipmentUtility.updateOPLsToCancelled(shipmentRecordSelector.lstOceanPlusLeadsToCancel);
        } 
    }
    
    public override void onAfterUpdate() {
        if(shipmentRecordSelector.lstOceanPlusLeadsToDelete != null && shipmentRecordSelector.lstOceanPlusLeadsToDelete.size()>0){           
            ShipmentUtility.deleteOPLs(shipmentRecordSelector.lstOceanPlusLeadsToDelete);
        } 
        
        //SC-9985
        if(shipmentRecordSelector.lstOceanPlusLeadsToCancel != null && shipmentRecordSelector.lstOceanPlusLeadsToCancel.size()>0){           
            ShipmentUtility.updateOPLsToCancelled(shipmentRecordSelector.lstOceanPlusLeadsToCancel);
        } 
    }
}