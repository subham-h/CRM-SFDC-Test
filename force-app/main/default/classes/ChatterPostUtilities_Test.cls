/*
* Purpose  : Test Class for ChatterPostUtilities class
*       
* Revision Ref Number  Date          Owner                              Description
* -------- ----------  -----------    -------------------               -----------
* 1.0      RQ-004635   03/05/2017     john.christopher@ust-global.com   Test Class for ChatterPostUtilities class
* 2.0      RQ-008020   20-Mar-2018    peter.ryan@ust-global.com         Added testDoChatterMention()
*/

@isTest 
public class ChatterPostUtilities_Test {
    
    public static final String LOGMARK = '##### ChatterPostUtilities_Test : ';

    //Test Method to Post a single chatter based on the parameters recieved. 
    static testMethod void testCreateChatterPost(){
    
        List<FeedItem> post = new List<FeedItem>();
        
        FeedItem postObj = new FeedItem();
        
        postObj.createdById = UserInfo.getUserId();
        postObj.relatedRecordId = getCVId();
        postObj.parentId = UserInfo.getUserId();
        postObj.body = 'Test method for CreateChatterPost';
        
        post.add(postObj);
        
        FeedItem postObj1 = new FeedItem();
        
        postObj1.createdById = UserInfo.getUserId();
        postObj1.relatedRecordId = UserInfo.getUserId();
        postObj1.parentId = UserInfo.getUserId();
        postObj1.body = 'Test method for CreateChatterPost';
        
         post.add(postObj1);
         
        Test.startTest();
        ChatterPostUtilities.doChatterPost(post,'test1');
        Test.stopTest();
    
    }
    
    private static Id getCVId() {
        String myContent = 'aabbcc';
        blob data = Blob.valueOf(myContent);  
        ContentVersion cv = new ContentVersion();
        cv.VersionData = data;
        cv.Title = 'Example';
        cv.PathOnClient = '/foo.txt';
        insert cv;
        return cv.Id;
    }
    
    private static List<FeedItem> getFeedItemList() {
        Id idUser = UserInfo.getUserId();
        Id idCV = getCVId();
        List<FeedItem> lstFeedItem = new List<FeedItem>();
        lstFeedItem.add(new FeedItem(CreatedById = idUser, RelatedRecordId = idCv, ParentId = idUser, Body = 'test text'));
        lstFeedItem.add(new FeedItem(CreatedById = idUser, RelatedRecordId = idCv, ParentId = idUser, Body = 'test text'));
        lstFeedItem.add(new FeedItem(CreatedById = idUser, RelatedRecordId = idCv, ParentId = idUser, Body = 'test text'));
        insert lstFeedItem;
        return lstFeedItem;
    }
    
    private static Map<Id, Id> getFeedItemIdUserIdMap() {
        Id idUser = UserInfo.getUserId();
        Map<Id, Id> mapFeedItemIdUserId = new Map<Id, Id>();
        for (FeedItem fi: getFeedItemList()) {
            mapFeedItemIdUserId.put(fi.Id, idUser);
        }
        return mapFeedItemIdUserId;
    }
    
	@IsTest(SeeAllData=true)
    static void testDoChatterMention() {
        Map<Id, Id> mapFeedItemIdUserId = getFeedItemIdUserIdMap();
        Test.startTest();
        ChatterPostUtilities.doChatterMention(mapFeedItemIdUserId, 'test mention text',null,null);
        Test.stopTest();
        List<FeedItem> fiList = [SELECT Id, Body FROM FeedItem WHERE Id IN: mapFeedItemIdUserId.keySet()];
        System.debug(Logginglevel.DEBUG, LOGMARK + 'testDoChatterMention - fiList=' + fiList);
    }
    
    
}