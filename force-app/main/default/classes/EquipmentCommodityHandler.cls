/*
 * Author   : Shahanawaz@Maersk
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on Equipment Commodity trigger.
 * 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0     SC-9293     22-12-2023  Shahanawaz@maersk       	Create feeditem on parent Case
*/
public class EquipmentCommodityHandler extends TriggerHandler{
    
    public map<Id, Equipment_Commodity__c> newMap;
    public map<Id, Equipment_Commodity__c> oldMap;
    public EquipmentCommodityHandler() {
        this.newMap = (map<Id, Equipment_Commodity__c>)Trigger.newMap;
        this.oldMap = (map<Id, Equipment_Commodity__c>)Trigger.oldMap; 
    }
    
    public EquipmentCommodityRecordSelector equipComRecordSelector;
    
    public override void getRecordSelector() {
        equipComRecordSelector = new EquipmentCommodityRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onAfterInsert() {
        if(!equipComRecordSelector.equipComList.isEmpty()){
            EquipmentCommodityHelper.createFeedItem(equipComRecordSelector.equipComList);
        }
    }

}