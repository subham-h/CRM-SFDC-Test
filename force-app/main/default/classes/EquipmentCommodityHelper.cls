/*
* Author   : Shahanawaz@Maersk
* Purpose  : Utility class to hold simple and reusable functionalities for Equipment Commodity.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0     SC-9293     22-12-2023  Shahanawaz@maersk       	Create feeditem on parent Case
*/
public class EquipmentCommodityHelper {
    
    /** 
    * @description | create feed item
    * @param equipComList accepts list of Equipment_Commodity__c
    */
    public static void createFeedItem(List<Equipment_Commodity__c> equipComList){
        List<FeedItemUtility.FeedItemWrapper> feedItemWrapList = new List<FeedItemUtility.FeedItemWrapper>();
        for(Equipment_Commodity__c equip : equipComList){
            FeedItemUtility.FeedItemWrapper feedWrap = new FeedItemUtility.FeedItemWrapper(equip.Id, equip.Claim__c, 'Equipment Commodity');
            feedItemWrapList.add(feedWrap);
        }
        
        if(!feedItemWrapList.isEmpty()){
            FeedItemUtility.createFeedItem(feedItemWrapList);
        }
    }

}