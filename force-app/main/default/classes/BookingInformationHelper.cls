/*
* Author   : Shahanawaz@Maersk
* Purpose  : Utility class to hold simple and reusable functionalities for Booking Information.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0     SC-9293     22-12-2023  Shahanawaz@maersk       	Create feeditem on parent Case
*/
public class BookingInformationHelper {

    /** 
    * @description | create feed item
    * @param bookingInfoCaseList accepts list of Booking_Information__c
    */
    public static void createFeedItem(List<Booking_Information__c> bookingInfoCaseList){
        List<FeedItemUtility.FeedItemWrapper> feedItemWrapList = new List<FeedItemUtility.FeedItemWrapper>();
        for(Booking_Information__c bookInfo : bookingInfoCaseList){
            FeedItemUtility.FeedItemWrapper feedWrap = new FeedItemUtility.FeedItemWrapper(bookInfo.Id, bookInfo.Related_Case__c , 'Booking Information');
            feedItemWrapList.add(feedWrap);
        }
        
        if(!feedItemWrapList.isEmpty()){
            FeedItemUtility.createFeedItem(feedItemWrapList);
        }
    }
    
}