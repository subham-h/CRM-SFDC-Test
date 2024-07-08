/*
* Author    : Richa
* Purpose   : Populate fields on Ocean Plus Line Item records
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-8872     23-07-2023  Richa@Maersk            Update Parent Status
* 2.0       SC-9198     06-10-2023  Richa@Maersk            Populate date of last status update
* 3.0       SC-9221     10-10-2023  Richa@Maersk            Populate the externalid of OPLIs
* 4.0       SC-9237     27-10-2023  Richa@Maersk            Capture Completed date of OPL
* 5.0       SC-9984     29-4-2024   Meghna@Maersk           Populate OwnerID
*/
public without sharing class OceanPlusLineItemFieldPopulator {
    /** 
* @description | SC-8872: Method to update parent (Ocean Plus Lead) status on insert/update/delete of child(OPLI) records
* @param setId accepts a list of Ocean Plus Line Ids
*/      
    public static void updateParentOPLStatus(Set<String> setOPLIIds) {
        try{
            List<Ocean_Plus_Lead__c> lstUpdateOPL = new List<Ocean_Plus_Lead__c>();
            for(Ocean_Plus_Lead__c opl:[Select Id,Status__c,Products_Pitched__c,Completed_Date__c,LastUpdatedDate__c,(Select Id, Status__c, Product__c from Ocean_Plus_Line_Items__r) from Ocean_Plus_Lead__c where Id IN:setOPLIIds]){               
                Set<String> setOPLIStatus = new Set<String>();
                Set<Id> setOPLIId = new Set<Id>();
                for(Ocean_Plus_Line_Item__c opli:opl.Ocean_Plus_Line_Items__r){  
                    setOPLIStatus.add(opli.Status__c); 
                }               
                if(setOPLIStatus.contains('New') || setOPLIStatus.contains('In Progress')){
                    opl.Status__c = 'In Progress'; 
                }else if(setOPLIStatus.contains('Sold')){
                    opl.Status__c = 'Sold';   
                }else if(setOPLIStatus.contains('Lead for Sales')){
                    opl.Status__c = 'Lead for Sales';  
                }else if(setOPLIStatus.contains('Not Sold')){
                    opl.Status__c = 'Not Sold';   
                }   
                if(opl.Status__c == 'Sold' || opl.Status__c == 'Not Sold' || opl.Status__c == 'Lead for Sales'){                    
                    opl.Completed_Date__c = System.today(); //SC-9237
                }else{                  
                    opl.Completed_Date__c = null;  
                }
                lstUpdateOPL.add(opl);  
            }
            if(lstUpdateOPL != null && lstUpdateOPL.size() >0){
               TriggerExecutionController.skipOceanPlusLeadTrigger(true);
                update lstUpdateOPL;
               TriggerExecutionController.skipOceanPlusLeadTrigger(false);
            } 
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OceanPlusLineItem', 'OceanPlusLineItemFieldPopulator.updateParentOPLStatus', new list<Exception>{ex});  
        }        
    }
    /** 
* @description | SC-9934 Add LastUpdatedDate field on OPL record
* @param setId accepts a list of Ocean Plus Line Ids
*/     
    public static void updateParentOPLLastModifiedDate(Set<String> setOPLIIds,Map<Id, Ocean_Plus_Line_Item__c> newMap, Map<Id, Ocean_Plus_Line_Item__c> oldMap) {
        try{
            Map<Id, Ocean_Plus_Lead__c> mapOPLToUpdate = new Map<Id, Ocean_Plus_Lead__c>();
            
            for (Ocean_Plus_Line_Item__c newOPLI : newMap.values()) {
                Ocean_Plus_Line_Item__c oldOPLI = oldMap.get(newOPLI.Id);
                if (oldOPLI.LastModifiedDate != newOPLI.LastModifiedDate) {
                    Ocean_Plus_Lead__c opl = new Ocean_Plus_Lead__c(Id = newOPLI.Ocean_Plus_Lead__c);
                    if (!mapOPLToUpdate.containsKey(opl.Id)) {
                        opl.LastUpdatedDate__c = Datetime.now();
                        mapOPLToUpdate.put(opl.Id, opl);
                    }
                }
            }
            if (!mapOPLToUpdate.isEmpty()) {
                TriggerExecutionController.skipOceanPlusLeadTrigger(true);
                update mapOPLToUpdate.values();
                TriggerExecutionController.skipOceanPlusLeadTrigger(false);
            }
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OceanPlusLineItem', 'OceanPlusLineItemFieldPopulator.updateParentOPLLastModifiedDate', new list<Exception>{ex});  
        }        
    }
    /** 
* @description | SC-9198: Method to update OPLI last status update field by agent
* @param setOPLIs accepts a set of Ocean Plus Line Items
*/      
    public static void updateStatusLastModifiedDate(Set<Ocean_Plus_Line_Item__c> setOPLIs) {
        try{   
            for(Ocean_Plus_Line_Item__c opli:setOPLIs){  
                opli.Last_Status_Update__c = System.now();
            }            
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OceanPlusLineItem', 'OceanPlusLineItemFieldPopulator.updateStatusLastModifiedDate', new list<Exception>{ex});  
        }        
    }
    
    /** 
* @description |  SC-9221: Method to populate externalId
* @param setOPLIs accepts a set of Ocean Plus Line Items
* @param setBookingNumbers accepts a set of BookingNumbers
*/      
    public static void updateExternalId(Set<Ocean_Plus_Line_Item__c> setOPLIs,Set<String> setExternalIds) {
        try{           
            for(Ocean_Plus_Line_Item__c opli:setOPLIs){  
                String exterId = opli.Booking_Number__c + opli.Product__c;
                exterId = exterId.deleteWhitespace();
                if(setExternalIds.isEmpty() || !setExternalIds.contains(exterId)){
                    opli.OPLIExternalId__c = exterId;
                    setExternalIds.add( opli.OPLIExternalId__c);
                }
            }            
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OceanPlusLineItem', 'OceanPlusLineItemFieldPopulator.updateExternalId', new list<Exception>{ex});  
        }        
    }
    
        /** 
* @description |  SC-9984: Method to populate OwnerID
* @param setOPLIs accepts a set of Ocean Plus Line Items
*/      
    public static void updateOPLIOwner(Set<Ocean_Plus_Line_Item__c> setOPLIs) {
        try{           
            for(Ocean_Plus_Line_Item__c opli:setOPLIs){  
                User currentUser = StaticFactory.getCurrentUserDetails();

                    opli.Owner__c = currentUser.Id;
                }
            }            
        catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OceanPlusLineItem', 'OceanPlusLineItemFieldPopulator.updateOPLIOwner', new list<Exception>{ex});  
        }        
    }
    
}