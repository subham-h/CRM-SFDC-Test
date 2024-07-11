/*
* Author    : Richa
* Purpose   : Delete OceanPlusLead records with cancelled shipment status
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-9041	   	11-09-2023  Richa@Maersk            Delete OceanPlusLead records with cancelled shipment status
* 2.0      	SC-9582     18-12-2023  Richa@Maersk            Show Booked By Customer SCV on OPL
* 3.0       SC-9985	   	02-04-2024  Nayana@Maersk           Update In progress OceanPlusLead records with Cancelled status when shipment is cancelled
*/
public without sharing class ShipmentUtility { 
    
    /** 
* @description | SC-9041: Method to delete OPLs with Cancelled Shipments
* @param setOceanPlusLeadsToDelete accepts list of OPLs to delete
*/     
    
    public static void deleteOPLs(List<Ocean_Plus_Lead__c> lstOceanPlusLeadsToDelete){
        try{ 
            if(lstOceanPlusLeadsToDelete != null && lstOceanPlusLeadsToDelete.size()>0){
                TriggerExecutionController.skipOceanPlusLeadTrigger(true);
                delete lstOceanPlusLeadsToDelete;
                TriggerExecutionController.skipOceanPlusLeadTrigger(false);
            }
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Shipment', 'ShipmentUtility.deleteOPLs', new list<Exception>{ex});   
        }
    }

   /** 
* @description | SC-9582: Method to show Booked By Customer SCV on OPL
* @param lstOceanPlusLeadsToUpdate accepts list of OPLs to update
* @param mapBookingNumberAndShipment accepts map of key Booking Number and value shipment record
*/     
    
    public static void updateOPLsWithShipmentAndSCV(List<Ocean_Plus_Lead__c> lstOceanPlusLeadsToUpdate, Map<String,Shipment__c> mapBookingNumberAndShipment){
        try{ 
            List<Ocean_Plus_Lead__c> lstOPLToUpdate = new List<Ocean_Plus_Lead__c>();  
            for(Ocean_Plus_Lead__c opl: lstOceanPlusLeadsToUpdate){
                opl.Shipment__c = mapBookingNumberAndShipment.get(opl.Booking_Number__c).Id;
                if(mapBookingNumberAndShipment.get(opl.Booking_Number__c).Booked_By_Customer_SCV_Code__c != null){
                    opl.Booked_By_SCV_Code__c = mapBookingNumberAndShipment.get(opl.Booking_Number__c).Booked_By_Customer_SCV_Code__c;
                }
                lstOPLToUpdate.add(opl);
            }
             if(lstOPLToUpdate != null && lstOPLToUpdate.size()>0){
                update lstOPLToUpdate;
            }
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Shipment', 'ShipmentUtility.updateOPLsWithShipmenAndSCV', new list<Exception>{ex});   
        }
    }      
    
/** 
* @description | SC-9985: Method to update OPLs with Cancelled Shipments to Cancelled status
* @param lstOceanPlusLeadsToCancel accepts list of OPLs to update
*/     
    
    public static void updateOPLsToCancelled(List<Ocean_Plus_Lead__c> lstOceanPlusLeadsToCancel){
        try{ 
            if(lstOceanPlusLeadsToCancel != null && lstOceanPlusLeadsToCancel.size()>0){
                for(Ocean_Plus_Lead__c opl:lstOceanPlusLeadsToCancel){
                    opl.Status__c = Label.OPLCancelStatus;
                }
                TriggerExecutionController.skipOceanPlusLeadTrigger(true);
                update lstOceanPlusLeadsToCancel;
                TriggerExecutionController.skipOceanPlusLeadTrigger(false);
            }
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OceanPlusLeads', 'ShipmentUtility.updateOPLsToCancelled', new list<Exception>{ex});   
        }
    }
}