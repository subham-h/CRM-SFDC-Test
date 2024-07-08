/*
* Author    : Aditya
* Purpose   : Test Class to get the Archived LiveChatTranscript body
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-7180     13-Feb-2023 Aditya@Maersk            In Progress. 
* 
*
*/
@isTest(SeeAllData=false)
public with sharing class ExtLiveChatTranscriptMessageViewer_Test {
    static testMethod void test_getExtLiveChatTranscriptBody() { 
        Test.startTest();
        Livechatarchival__x lctArchObj=new Livechatarchival__x();
        ExtLiveChatTranscriptMessageViewer extlctMessageViewerObj=new ExtLiveChatTranscriptMessageViewer();
        ExtLiveChatTranscriptMessageViewer.mockedRecords=lctArchObj;
        ExtLiveChatTranscriptMessageViewer.getExtLiveChatTranscriptBody(lctArchObj.Id);
        Test.stopTest();
    }
}