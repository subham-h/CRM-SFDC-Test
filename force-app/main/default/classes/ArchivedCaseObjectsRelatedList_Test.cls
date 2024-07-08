/*
* Author    : Ranjan
* Purpose   : Test class for ExtEmailMessageViewer
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-5245     20-Jan-2023 Ranjan@Maersk            Created. 
* 
*
*/
@isTest(SeeAllData=false)
public with sharing class ArchivedCaseObjectsRelatedList_Test {
    static testMethod void test_getArchivedCaseObjects() { 
        Test.startTest();
        emailmessagearchival__x emailArchObj=new emailmessagearchival__x();
        emailArchObj.htmlbody__c='<html>Welcome To Maersk</html>';
        emailArchObj.toaddress__c='testtoaddress@maersk.com';
        emailArchObj.fromaddress__c='test@maersk.com';
        emailArchObj.fromname__c='Steve Johnson';
        List<emailmessagearchival__x> emailList=new List<emailmessagearchival__x> ();
        ArchivedCaseObjectsRelatedList extEmailMessageViewerObj=new ArchivedCaseObjectsRelatedList();
        emailList.add(emailArchObj);
        ArchivedCaseObjectsRelatedList.mockedRecords=emailList;
        ArchivedCaseObjectsRelatedList.fetchInitData(emailArchObj.Id,'emailmessagearchival__x','case');
        ArchivedCaseObjectsRelatedList.fetchInitData(emailArchObj.Id,'emailmessagearchival__x','email');
        ArchivedCaseObjectsRelatedList.fetchInitData(emailArchObj.Id,'Approvalrequestarchival__x','case');
        ArchivedCaseObjectsRelatedList.fetchInitData(emailArchObj.Id,'Attchmentarchival__x','case');
        ArchivedCaseObjectsRelatedList.fetchInitData(emailArchObj.Id,'Bookinginformationarchival__x','case');
        ArchivedCaseObjectsRelatedList.fetchInitData(emailArchObj.Id,'Casecommentarchival__x','case');
        ArchivedCaseObjectsRelatedList.fetchInitData(emailArchObj.Id,'Casehistoryarchival__x','case');
        ArchivedCaseObjectsRelatedList.fetchInitData(emailArchObj.Id,'Financialdetailsarchival__x','case');
        ArchivedCaseObjectsRelatedList.fetchInitData(emailArchObj.Id,'Livechatarchival__x','case');
        Test.setMock(HttpCalloutMock.class, new CaseRelatedObjDataSourceProviderMock());
        ArchivedCaseObjectsRelatedList.downloadAttachment();
        ArchivedCaseObjectsRelatedList.fetchCaseDetails('a0I7Y00000S9E3BUAV');
        Test.stopTest();
    }
}