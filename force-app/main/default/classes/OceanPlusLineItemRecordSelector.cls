/*
* Author    : Richa
* Purpose   : Query records related to Ocean Plus Line Items
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-8872     23-07-2023  Richa@Maersk            Update parent Status
* 2.0       SC-9198     06-10-2023  Richa@Maersk            Populate date of last status update
* 3.0       SC-9221     10-10-2023  Richa@Maersk            Populate the externalid of OPLIs
*/
public class OceanPlusLineItemRecordSelector implements RecordSelector{
    private TriggerHandler oceanPlusLineItemTriggerHandler; 
    public Set<String> setOPLIParentId = new Set<String>();
    public Set<String> setOPLIParentIdUpdate = new Set<String>();
    public Set<Ocean_Plus_Line_Item__c> setOPLForLastUpdateDate = new Set<Ocean_Plus_Line_Item__c>();
    public Set<Ocean_Plus_Line_Item__c> setNewOPLIs = new Set<Ocean_Plus_Line_Item__c>();
    public Set<String> setBookingNumbers = new Set<String>();
    public Set<String> setExternalIds = new Set<String>();
    public List<String> updateExcludedUsers = New List<String>();
    
    public OceanPlusLineItemRecordSelector(list<Ocean_Plus_Line_Item__c> lstOceanPlusLineItems, map<Id, Ocean_Plus_Line_Item__c> mapOldOceanPlusLineItems, OceanPlusLineItemTriggerHandler oceanPlusLineItemTriggerHandler) {
        this.oceanPlusLineItemTriggerHandler= oceanPlusLineItemTriggerHandler;
        this.selectRecords(lstOceanPlusLineItems, mapOldOceanPlusLineItems);
        if(lstOceanPlusLineItems != null && lstOceanPlusLineItems.size()>0) {
            this.getRelatedRecords(lstOceanPlusLineItems);
        }
    }
    public void selectRecords(list<Ocean_Plus_Line_Item__c> lstOceanPlusLineItems, map<Id, sObject> mapOldOceanPlusLineItems) {
        if(lstOceanPlusLineItems != null && lstOceanPlusLineItems.size()>0) {
            for(Ocean_Plus_Line_Item__c newOPLI : lstOceanPlusLineItems) {
                Ocean_Plus_Line_Item__c oldOPLI;
                if(mapOldOceanPlusLineItems != null && !mapOldOceanPlusLineItems.isEmpty()) {
                    oldOPLI = (Ocean_Plus_Line_Item__c)mapOldOceanPlusLineItems.get(newOPLI.Id);
                }
                if(oceanPlusLineItemTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) {
                    if(oceanPlusLineItemTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                        if(Userinfo.getUserId() != Label.CrossSellInterface) {     
                            setOPLForLastUpdateDate.add(newOPLI);
                        }     
                        setBookingNumbers.add(newOPLI.Booking_Number__c);
                        setNewOPLIs.add(newOPLI);
                    }
                    else if(oceanPlusLineItemTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                        if(oldOPLI.Status__c != newOPLI.Status__c && Userinfo.getUserId() != Label.CrossSellInterface) {     
                            setOPLForLastUpdateDate.add(newOPLI);
                        }                    
                    }
                }
                else if(oceanPlusLineItemTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER) {
                    if(oceanPlusLineItemTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                        setOPLIParentId.add(newOPLI.Ocean_Plus_Lead__c);
                    }
                    else if(oceanPlusLineItemTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                        setOPLIParentIdUpdate.add(newOPLI.Ocean_Plus_Lead__c);
                        if(oldOPLI.Status__c != newOPLI.Status__c) {     
                            setOPLIParentId.add(newOPLI.Ocean_Plus_Lead__c);
                        }                        
                    }
                }               
            }
        } 
        if(mapOldOceanPlusLineItems != null && !mapOldOceanPlusLineItems.isEmpty()){
            for(Ocean_Plus_Line_Item__c oldOPLI :  (list<Ocean_Plus_Line_Item__c>)mapOldOceanPlusLineItems.values()) {
                if(oceanPlusLineItemTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER) {
                    if(oceanPlusLineItemTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE) {
                        setOPLIParentId.add(oldOPLI.Ocean_Plus_Lead__c);
                    }
                }
            }
            
        }
    }
    
    public void getRelatedRecords(list<Ocean_Plus_Line_Item__c> lstOceanPlusLineItems) {
          getSameBookingNumberOPLIs();
          getExcludedUser();
    }
    
   // Retrieve Excluded User 
   public void getExcludedUser(){  
        if(updateExcludedUsers.isEmpty()){
            General_Key_Value_Configurations__mdt config = General_Key_Value_Configurations__mdt.getInstance('CrossSellExcludedUser');
            if (config != null && !String.isEmpty(config.First_Field_Value__c)) {
                updateExcludedUsers.addAll(config.First_Field_Value__c.trim().split(','));
            }
        }}
    
     // Retrieve OPLIs with same Booking Number
    public void getSameBookingNumberOPLIs() {
        if(!setBookingNumbers.isEmpty()){
           for(Ocean_Plus_Line_Item__c opli: [Select Id, OPLIExternalId__c,Product__c from Ocean_Plus_Line_Item__c where Booking_Number__c IN :setBookingNumbers AND OPLIExternalId__c != null]){
                setExternalIds.add(opli.OPLIExternalId__c);
            }
        }    
    } 
    
}