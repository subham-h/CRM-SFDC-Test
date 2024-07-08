/*
* Author   : Sreya
* Purpose  : Make the API call to pull the call report from WxCC Analzer report to salesforce DB.
*        
* Revision Ref Number  Date        Owner                 Description
* -------- ----------  ----------- -------------------   -----------
* 1.0      SC-2079     15/04/2021  Sreya@maersk          Test Class for CallReportScheduler
*/  
@istest
public class CallReportScheduler_Test {
    @isTest static void testgetAnalyzerReport() {
        BDAGeographyData_Test geo = new BDAGeographyData_Test();   
        Test.setMock(HttpCalloutMock.class, new CallReportSchedulerCalloutMock());
        Test.StartTest();
        CallReportScheduler testsche = new CallReportScheduler(null,null);
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
    @isTest static void testgetAnalyzerReportError() {       
        BDAGeographyData_Test geo = new BDAGeographyData_Test();   
        Test.setMock(HttpCalloutMock.class, new CallReportSchedulerErrorCalloutMock());
        Test.StartTest();
        CallReportScheduler testsche = new CallReportScheduler(null,null);
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
}