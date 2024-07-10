@isTest(SeeAllData=false)
public with sharing class SingleObjectRelatedList_Test {
    static testMethod void test_fetchInitData() { 
        Test.startTest();
        emailmessagearchival__x emailArchObj=new emailmessagearchival__x();
        emailArchObj.htmlbody__c='<html>Welcome To Maersk</html>';
        emailArchObj.toaddress__c='testtoaddress@maersk.com';
        emailArchObj.fromaddress__c='test@maersk.com';
        emailArchObj.fromname__c='Steve Johnson';
        SingleObjectRelatedList extEmailMessageViewerObj=new SingleObjectRelatedList();
        SingleObjectRelatedList.fetchInitData(emailArchObj.Id);
        Test.stopTest();
    }
    
}