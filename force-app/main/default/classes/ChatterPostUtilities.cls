/*
* Purpose  : Generic Class to Post Chatter
*       
* Revision Ref Number  Date          Owner                          Description
* -------- ----------  -----------    -------------------           -----------
* 1.0      RQ-004635   03/05/2017     abby.abraham@ust              Generic Class to Post Chatter
* 2.0      RQ-005636   25-Sep-2017    Nisha@UST                     Update references of GlobalErrorLogger
* 3.0      RQ-008020   20-Mar-2018    peter.ryan@ust-global.com     Added doChatterMention()
* 4.0      SC-5766     25-07-2022     Richa@Maersk                  Modified ISR ChatterPost method call on case closure
* 5.0      SC-6294     19/10/2022     Sriram@maersk                 ISR Resolution Summary - Shipment Number
*/
public class ChatterPostUtilities{
    
    public static final String LOGMARK = '##### ChatterPostUtilities : ';

    // Generic method to insert chatter, capture errors in global error logger if any and from where the chatter post is involked
    public static Database.SaveResult[] doChatterPost(List<FeedItem> post,String methodName){             
        Database.SaveResult[] srList;
        if( post.Size() > 0 ){
            srList = Database.Insert(post, false);// create chatter posts.
            ErrorLogger.writeErrors('SFDC', 'FeedItem', 'ChatterPostUtilities.doChatterPost', srList, post) ; // #RQ-005636
        }                     
        return srList;
    }
    
    @future
    public static void doChatterMentionFuture(Map<Id, Id> mapFeedItemIdUserId, String mentionText, Map<Id, String> mapFeedItemIdComments,Map<Id, String> mapshipmentNumbers) {
        doChatterMention(mapFeedItemIdUserId, mentionText,mapFeedItemIdComments,mapshipmentNumbers);
    }
    
    public static void doChatterMention(Map<Id, Id> mapFeedItemIdUserId, String mentionText, Map<Id, String> mapFeedItemIdComments,Map<Id, String> mapshipmentNumbers) {
        System.debug(Logginglevel.DEBUG, LOGMARK + 'doChatterMention - mapFeedItemIdUserId=' + mapFeedItemIdUserId);
        String resComments; 
        for (Id idFeedItem: mapFeedItemIdUserId.keySet()) {
            Id idUser = mapFeedItemIdUserId.get(idFeedItem);
            //SC-5766
            if(mapFeedItemIdComments != null && !mapFeedItemIdComments.isEmpty() && mapFeedItemIdComments.containsKey(idFeedItem) &&  mapFeedItemIdComments.get(idFeedItem) != Null){
                String resolution = mapFeedItemIdComments.get(idFeedItem);
                String shipmentNumber = mapshipmentNumbers.get(idFeedItem);
                resComments = mentionText+ '\n' +(shipmentNumber!= null?'Shipment Number : '+ shipmentNumber+ '\n' :'')+ 'Resolution Summary:' + '\n' + resolution;
                resComments = resComments.length() > 9900 ? resComments.left(9900) + '...': resComments;
            }else{
                resComments = mentionText; 
            }
            doChatterMention(idFeedItem, idUser, resComments);
        }
    }
    
    
    public static void doChatterMention(Id feedElementId, Id idUser, String mentionText) {
        System.debug(Logginglevel.DEBUG, LOGMARK + 'doChatterMention - feedElementId=' + feedElementId +', idUser=' + idUser + ', mentionText=' + mentionText);
		String communityId = null;
        ConnectApi.CommentInput commentInput = new ConnectApi.CommentInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
		messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
		textSegmentInput.text = mentionText + ' ';
		messageBodyInput.messageSegments.add(textSegmentInput);
        mentionSegmentInput.id = idUser;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
		commentInput.body = messageBodyInput;
		ConnectApi.Comment commentRep = ConnectApi.ChatterFeeds.postCommentToFeedElement(communityId, feedElementId, commentInput, null);
    }
    
}