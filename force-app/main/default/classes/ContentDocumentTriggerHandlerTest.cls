@isTest
public class ContentDocumentTriggerHandlerTest {
    @istest
    public static void createTestData(){
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Version
        List<ContentVersion> cvList = [SELECT Id, Title,artemis_id__c, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        cvList.get(0).artemis_id__c='GJKSGUIWJWLKLANMSLLSLS';
        update cvList;
        //Get Content Documents
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        
        Database.delete(cdList,false);
    }
}