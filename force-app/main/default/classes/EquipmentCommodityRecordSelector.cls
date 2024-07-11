/*
* Author   : Shahanawaz@Maersk
* Purpose  : Centralize the record selection process for Equipment Commodity object.
*            Defines the methods which iterate and segregate the Equipment Commodity records for further use.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0     SC-9293     22-12-2023  Shahanawaz@maersk       	Create feeditem on parent Case
*/
public class EquipmentCommodityRecordSelector {
    
    private TriggerHandler equipComTriggerHandler;
    
    public List<Equipment_Commodity__c> equipComList = new List<Equipment_Commodity__c>();
    
    public EquipmentCommodityRecordSelector(list<Equipment_Commodity__c> equipCommodityList, map<Id, Equipment_Commodity__c> mapOldEquipCom, TriggerHandler equipComTriggerHandler) {
        this.equipComTriggerHandler = equipComTriggerHandler;
        
        this.selectRecords(equipCommodityList, mapOldEquipCom);
        
        if(equipCommodityList != null) {
            this.getRelatedRecords(equipCommodityList);
        }
        
    }
    
    public void selectRecords(list<Equipment_Commodity__c> equipCommodityList, map<Id, Equipment_Commodity__c> mapOldEquipCom) {
        for(Equipment_Commodity__c equip : equipCommodityList){
            if(equipComTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER) {
                if(equipComTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                    //SC-9293
                    if(equip.Claim__c != null){
                        equipComList.add(equip);
                    }
                }
            }
        }
    }
    
    public void getRelatedRecords(list<Equipment_Commodity__c> equipCommodityList) {
        
    }

}