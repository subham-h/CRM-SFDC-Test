/*
* Author   : Sreya
* Purpose  : Make the API call to pull the call report from WxCC Analzer report to salesforce DB.
*        
* Revision Ref Number  Date        Owner                 Description
* -------- ----------  ----------- -------------------   -----------
* 1.0      SC-2079     16/03/2021  Sreya@maersk          Make the API call to pull the call report data from WxCC Analzer report to salesforce DB.
* 2.0      SC-7966     23-05-2023  ramadevi.p@maersk.com Replacing future method with multiple callout to Queuable method.
*/  

public class CallReportScheduler implements Schedulable { 
    
    public Long beginParam;
    public Long endParam;
    
    public CallReportScheduler(Long begin1,Long end1){
        beginParam = begin1;
        endParam = end1;
    }
    
    public void execute(SchedulableContext SC){        
        getAnalyzerReport(beginParam,endParam);
    }
    
    public static void getAnalyzerReport(Long beginVal,Long endVal){
        List<WxCC_Report_Configurations__mdt> lstReportConfigurations=[select API_Query__c,Brand__c,Report_Name__c from WxCC_Report_Configurations__mdt Order by Report_Name__c ASC];
        System.enqueueJob(new CallReportQueueable(beginVal,endVal,lstReportConfigurations));
    }
        
}