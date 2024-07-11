/*
* Author    : Richa
* Purpose   : Query records related to Shipment
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-9041    11-09-2023  Richa@Maersk            Query Shipment records with Cancelled status
* 2.0     	SC-9582    18-12-2023  Richa@Maersk            Show Booked By Customer SCV on OPL
* 3.0       SC-9586    07-Feb-2024  Richa@Maersk           Modified the code to accomodate changes for Cancelled Event consumption      
* 4.0       SC-9985	   02-04-2024  Nayana@Maersk           Query In progress OceanPlusLead records when shipment is cancelled
*/
public class ShipmentRecordSelector implements RecordSelector{
    private TriggerHandler shipmentTriggerHandler; 
    public Set<String> setCancelledShipmentNumbers = new Set<String>();   
    public Map<String,Shipment__c> mapBookingNumbersAndShipment = new Map<String,Shipment__c>();   
    public List<Ocean_Plus_Lead__c> lstOceanPlusLeadsToDelete = new List<Ocean_Plus_Lead__c>();
    public List<Ocean_Plus_Lead__c> lstOceanPlusLeadsToUpdate = new List<Ocean_Plus_Lead__c>();
    public Set<String> setCancelledStatusValues = new Set<String>();   
    public Set<String> setOplCancelStatusValues = new Set<String>();  //SC-9985
    public List<Ocean_Plus_Lead__c> lstOceanPlusLeadsToCancel = new List<Ocean_Plus_Lead__c>(); // SC-9985
    
    public ShipmentRecordSelector(list<Shipment__c> lstShipments, map<Id, Shipment__c> mapOldShipments, ShipmentTriggerHandler shipmentTriggerHandler) {
        this.shipmentTriggerHandler= shipmentTriggerHandler;
        this.selectRecords(lstShipments, mapOldShipments);
        if(lstShipments != null && lstShipments.size() >0) {
            this.getRelatedRecords(lstShipments);
        }
    }
    public void selectRecords(list<Shipment__c> lstShipments, map<Id, sObject> mapOldShipments) {
        if(lstShipments != null && lstShipments.size() >0) {
            for(General_Key_Value_Configurations__mdt mdt : [SELECT Id,Second_Field_Value__c,Key__c FROM General_Key_Value_Configurations__mdt WHERE Key__c = 'ShipmentCancelledStatus' OR Key__c = 'OPLCancelStatus']){
                if(mdt.Key__c=='ShipmentCancelledStatus'){
                    setCancelledStatusValues.add(mdt.Second_Field_Value__c); 
                }
                else if(mdt.Key__c=='OPLCancelStatus'){ //SC-9985
                    setOplCancelStatusValues.add(mdt.Second_Field_Value__c); 
                }
            }             
            
            for(Shipment__c newShp : lstShipments) {
                Shipment__c oldShp;
                if(mapOldShipments != null && !mapOldShipments.isEmpty()) {
                    oldShp = (Shipment__c)mapOldShipments.get(newShp.Id);
                }
                
                if(shipmentTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER) {
                    if(shipmentTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                        mapBookingNumbersAndShipment.put(newShp.Shipment_Number__c,newShp);
                        if(setCancelledStatusValues.contains(newShp.Shipment_Status__c)){//SC-9586
                            setCancelledShipmentNumbers.add(newShp.Shipment_Number__c);
                        }
                    }
                    else if(shipmentTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                        if(newShp.Shipment_Status__c != oldshp.Shipment_Status__c && setCancelledStatusValues.contains(newShp.Shipment_Status__c)){
                            setCancelledShipmentNumbers.add(newShp.Shipment_Number__c);
                        }
                    }
                }                
            }
        }
    }
    
    public void getRelatedRecords(list<Shipment__c> lstShipments) {
        getRelatedOPLsToBeCancelled();
       	getRelatedOPLsToBeUpdated();
        getRelatedOPLsToCancel();
    }
    // Retrieve related OPLs to be cancelled
    public void getRelatedOPLsToBeCancelled() {
        if(!setCancelledShipmentNumbers.isEmpty()) {
            for(Ocean_Plus_Lead__c opl: [Select Id from Ocean_Plus_Lead__c where Booking_Number__c IN :setCancelledShipmentNumbers and OwnerId =: Label.CrossSellInterface and Status__c = 'New']){
                lstOceanPlusLeadsToDelete.add(opl);   
            }    
        } 
    }
    
    // SC-9985 - Retrieve related OPLs to be cancelled when shipment is cancelled
    public void getRelatedOPLsToCancel() {
        if(!setCancelledShipmentNumbers.isEmpty() && !setOplCancelStatusValues.isEmpty()) {
            for(Ocean_Plus_Lead__c opl: [Select Id,Status__c from Ocean_Plus_Lead__c where Booking_Number__c IN :setCancelledShipmentNumbers and Status__c IN :setOplCancelStatusValues]){
                lstOceanPlusLeadsToCancel.add(opl);   
            }
        } 
    }
 
     public void getRelatedOPLsToBeUpdated() {
        if(!mapBookingNumbersAndShipment.isEmpty()) {
            for(Ocean_Plus_Lead__c opl: [Select Id,Booking_Number__c,Shipment__c,Booked_By_SCV_Code__c from Ocean_Plus_Lead__c where Shipment__c = null and Booking_Number__c IN :mapBookingNumbersAndShipment.keySet() and Status__c IN ('New','In Progress')]){
                lstOceanPlusLeadsToUpdate.add(opl);   
            } 
        } 
    }
    
}