/*
* Author    : Aditya
* Purpose   : Class to get the Archived LiveChatTranscript body
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-7180     13-Feb-2023 Aditya@Maersk            Completed. 
* 
*
*/


public class ExtLiveChatTranscriptMessageViewer {
    Public static Livechatarchival__x mockedRecords; 
    public ExtLiveChatTranscriptMessageViewer(){
        mockedRecords =new Livechatarchival__x();    // Object for test class
    }
    @AuraEnabled(cacheable=true)
    public static Livechatarchival__x getExtLiveChatTranscriptBody(Id livechatTranscriptRecordId) {
        return (Test.isRunningTest()?mockedRecords:[
            SELECT Id,body__c
            FROM Livechatarchival__x
            WHERE Id=:livechatTranscriptRecordId                   
        ]);
    }
    
    
}