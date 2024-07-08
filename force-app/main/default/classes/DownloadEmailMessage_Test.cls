/*
Description  : This Class is designed to parse subject of email message and keep it as file name of pdf.

* version       Date                Owner                                       Description
*******************************************************************************************************************
* V1.0           13/3/2022         sandeep.sankhla@maersk.com                    This is the test class for DownloadEmailMessage class.     
*-------------------------------------------------------------------------------------------------------------------
*/
@isTest
global class DownloadEmailMessage_Test {
    
    @isTest static void testgetBOLNumber() {
        //Case Data creation
        CaseData_Test.bCreate = true;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.createExternalCases();
        List<Case> listCase = CaseData_Test.lstCases;
        listCase[0].Product__c = 'Ocean';
        listCase[0].Type = 'Cargo/Container';
        listCase[0].Sub_Type__c = 'Delivery Order/Container Release';
        
        update listCase;
        
        EmailMessage objEM = new EmailMessage();
        objEM.Subject = 'Your Case Number is';
        objEM.TextBody = 'This is Just to test all the data';
        objEM.ToAddress = 'Sandeep.sankhla@ust-global.com';
        objEM.ParentId = listCase[0].Id;
        insert objEM;
        
        TriggerExecutionController.skipAllTriggers(false);
        ApexPages.StandardController sc = new ApexPages.StandardController(objEM);
        DownloadEmailMessageAsPdfController obj = new DownloadEmailMessageAsPdfController(sc);
    }
    
}