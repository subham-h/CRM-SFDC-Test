/*
* Author    : Ranjan
* Purpose   : Test class for ExtEmailMessageViewer
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-5245     16-Aug-2022 Ranjan@Maersk            Created. 
* 
*
*/
@isTest(SeeAllData=false)
public with sharing class ExtEmailMessageViewer_Test {
    static testMethod void test_getExtEmailMessage() { 
        Test.startTest();
        emailmessagearchival__x emailArchObj=new emailmessagearchival__x();
        emailArchObj.htmlbody__c='<html>Welcome To Maersk</html>';
        emailArchObj.toaddress__c='testtoaddress@maersk.com';
        emailArchObj.fromaddress__c='test@maersk.com';
        emailArchObj.fromname__c='Steve Johnson';
        ExtEmailMessageViewer extEmailMessageViewerObj=new ExtEmailMessageViewer();
        ExtEmailMessageViewer.mockedRecords=emailArchObj;
        System.assertEquals(ExtEmailMessageViewer.getExtEmailMessage(emailArchObj.Id).fromname__c,'Steve Johnson');
        Test.stopTest();
    }
}