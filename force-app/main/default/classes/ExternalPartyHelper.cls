/*
* Author   : Shahanawaz@Maersk
* Purpose  : Utility class to hold simple and reusable functionalities for External Party.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0     SC-9293     22-12-2023  Shahanawaz@maersk       	Create feeditem on parent Case
*/
public class ExternalPartyHelper {
    
    /** 
    * @description | create feed item
    * @param extPartyList accepts list of External_Party__c
    */
    public static void createFeedItem(List<External_Party__c> extPartyList){
        List<FeedItemUtility.FeedItemWrapper> feedItemWrapList = new List<FeedItemUtility.FeedItemWrapper>();
        for(External_Party__c ext : extPartyList){
            FeedItemUtility.FeedItemWrapper feedWrap = new FeedItemUtility.FeedItemWrapper(ext.Id, ext.Claim__c, 'External Party');
            feedItemWrapList.add(feedWrap);
        }
        
        if(!feedItemWrapList.isEmpty()){
            FeedItemUtility.createFeedItem(feedItemWrapList);
        }
    }

}