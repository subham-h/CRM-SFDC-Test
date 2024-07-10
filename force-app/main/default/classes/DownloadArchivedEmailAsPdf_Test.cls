/*
Description  : This Class is designed to parse subject of Archived email message and keep it as file name of pdf.

* version       Date                Owner                                       Description
*******************************************************************************************************************
* V1.0           17/11/2022         Ranjan@Maersk (ranjan.kumar.1@maersk.com)    This is the test class for DownloadArchivedEmailAsPdfController class.     
*-------------------------------------------------------------------------------------------------------------------
*/
@isTest
global class DownloadArchivedEmailAsPdf_Test {
    
     @isTest static void testDownloadArchivedEmail() {
        //Case Data creation
         
        emailmessagearchival__x objEM = new emailmessagearchival__x();
         objEM.Subject__c = 'Your Case Number is';
         objEM.HTMLBody__c = 'This is Just to test all the data';
         objEM.ToAddress__c = 'test@maersk.com';
         objEM.messagedate__c = '2023-09-22T17:18:58';
         objEM.fromname__c = 'QA Team';
         objEM.textbody__c= 'tst mail';
         objEM.fromaddress__c= 'test@maersk.com';

         objEM.ParentId__c = '5007E00000DCB92QAH';
         //database.insertImmediate (objEM);
         
        TriggerExecutionController.skipAllTriggers(false);
         ApexPages.StandardController sc = new ApexPages.StandardController(objEM);
         DownloadArchivedEmailAsPdfController obj = new DownloadArchivedEmailAsPdfController(sc);
         
      
      
     }

}