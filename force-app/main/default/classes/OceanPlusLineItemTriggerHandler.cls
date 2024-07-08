/*
* Author    : Richa
* Purpose   : To handle all logic related to OceanPlusLineItem
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-8872     23-08-2023  Richa@Maersk            Update parent status
* 2.0       SC-9198     06-10-2023  Richa@Maersk            Populate date of last status update
* 3.0       SC-9221     10-10-2023  Richa@Maersk            Populate the externalid of OPLIs
*/
public class OceanPlusLineItemTriggerHandler extends TriggerHandler {
    public map<Id, Ocean_Plus_Line_Item__c> newMap;
    public map<Id, Ocean_Plus_Line_Item__c> oldMap;
    public OceanPlusLineItemTriggerHandler() {
        this.newMap = (map<Id, Ocean_Plus_Line_Item__c>)Trigger.newMap;
        this.oldMap = (map<Id, Ocean_Plus_Line_Item__c>)Trigger.oldMap; 
    }
    
    public OceanPlusLineItemRecordSelector oceanPlusLineItemRecordSelector;
    
    public override void getRecordSelector() {
        oceanPlusLineItemRecordSelector = new OceanPlusLineItemRecordSelector(Trigger.new, this.oldMap, this);
    }
    public override void onBeforeInsert() {
        if(!oceanPlusLineItemRecordSelector.setOPLForLastUpdateDate.isEmpty()){
            OceanPlusLineItemFieldPopulator.updateStatusLastModifiedDate(oceanPlusLineItemRecordSelector.setOPLForLastUpdateDate);
        }   
        if(!oceanPlusLineItemRecordSelector.setBookingNumbers.isEmpty()){
            OceanPlusLineItemFieldPopulator.updateExternalId(oceanPlusLineItemRecordSelector.setNewOPLIs,oceanPlusLineItemRecordSelector.setExternalIds);
        }
        if(!oceanPlusLineItemRecordSelector.setBookingNumbers.isEmpty()){
            OceanPlusLineItemFieldPopulator.updateOPLIOwner(oceanPlusLineItemRecordSelector.setNewOPLIs);
        }        
    }
    public override void onBeforeUpdate() {
        if(!oceanPlusLineItemRecordSelector.setOPLForLastUpdateDate.isEmpty()){
            OceanPlusLineItemFieldPopulator.updateStatusLastModifiedDate(oceanPlusLineItemRecordSelector.setOPLForLastUpdateDate);
        }         
    }
    public override void onAfterInsert() {  
        OceanPlusLineItemFieldPopulator.updateParentOPLStatus(oceanPlusLineItemRecordSelector.setOPLIParentId);
    }
    public override void onAfterUpdate() {  
        if(!oceanPlusLineItemRecordSelector.setOPLIParentId.isEmpty()){
            OceanPlusLineItemFieldPopulator.updateParentOPLStatus(oceanPlusLineItemRecordSelector.setOPLIParentId);
        }
        if(!oceanPlusLineItemRecordSelector.updateExcludedUsers.contains(UserInfo.getUserId())){
        OceanPlusLineItemFieldPopulator.updateParentOPLLastModifiedDate(oceanPlusLineItemRecordSelector.setOPLIParentIdUpdate,this.newMap,this.oldMap);
        }
    }
    public override void onAfterDelete() {
        if(!oceanPlusLineItemRecordSelector.setOPLIParentId.isEmpty()){
            OceanPlusLineItemFieldPopulator.updateParentOPLStatus(oceanPlusLineItemRecordSelector.setOPLIParentId);
        }
    }
}