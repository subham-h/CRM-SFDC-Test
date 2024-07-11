/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      SC-9293     22-12-2023  Shahanawaz@maersk       Create feeditem on parent Case
*/
public class ActivityReferenceTriggerHelper {
    
    /** 
    * @description | create feed item
    * @param arfList accepts list of Activity_Related_Reference__c
    */
    public static void createFeedItem(List<Activity_Related_Reference__c> arfList){
        List<FeedItemUtility.FeedItemWrapper> feedItemWrapList = new List<FeedItemUtility.FeedItemWrapper>();
        for(Activity_Related_Reference__c arf : arfList){
            FeedItemUtility.FeedItemWrapper feedWrap = new FeedItemUtility.FeedItemWrapper(arf.Id, arf.Case__c, 'Activity Related Reference');
            feedItemWrapList.add(feedWrap);
        }
        
        if(!feedItemWrapList.isEmpty()){
            FeedItemUtility.createFeedItem(feedItemWrapList);
        }
    }

}