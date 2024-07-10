/*
 * Author   : Shahanawaz@Maersk
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on Feed Item Event trigger.
 * 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0     SC-9293     17-01-2024  Shahanawaz@maersk       	Create feeditem on parent Case
*/
public class FeedItemEventHandler {
    
    /** 
    * @description | create feed item
    * @param feedItemEventList accepts list of Feed_Item_Event__e
    */
    public static void processFeedItemEvent(List<Feed_Item_Event__e> feedItemEventList){
        List<FeedItemUtility.FeedItemWrapper> feedItemWrapList = new List<FeedItemUtility.FeedItemWrapper>();
        for(Feed_Item_Event__e fe : feedItemEventList){
            FeedItemUtility.FeedItemWrapper feedWrap = new FeedItemUtility.FeedItemWrapper(fe.Record_Id__c, fe.Parent_Id__c, fe.Object_Name__c);
            feedItemWrapList.add(feedWrap);
        }
        if(!feedItemWrapList.isEmpty()){
            FeedItemUtility.createFeedItem(feedItemWrapList);
        }
    }

}