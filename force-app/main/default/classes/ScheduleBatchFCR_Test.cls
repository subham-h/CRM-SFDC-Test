/*
* Author   : Nirmal Christopher
* Purpose  : Test class to cover ScheduleBatchFCR
*            
* Revision  Ref Number  Date            Owner                           Description
* --------  ----------  -----------     -------------------             --------------------------------------------------------
* 1.0      #RQ-001479   27-April-2017    Nirmal@UST                      Test to cover ScheduleBatchFCR 
*/
@isTest
public class ScheduleBatchFCR_Test{
     public static testmethod void BatchFCRRun1(){
      Test.startTest();
       // This test runs a scheduled job at midnight Sept. 3rd. 2022
         String CRON_EXP = '0 0 0 3 9 ? 2025';
       // Schedule the test job
       String jobId = System.schedule('BatchFCRRun', CRON_EXP, new ScheduleBatchFCR());
      // Get the information from the CronTrigger API object 
         CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
       // Verify the expressions are the same System.assertEquals(CRON_EXP, ct.CronExpression); 
      // Verify the job has not run 
      System.assertEquals(0, ct.TimesTriggered); 
      // Verify the next time the job will run 
      System.assertEquals('2025-09-03 00:00:00', String.valueOf(ct.NextFireTime));   
      Test.stopTest();        
     }
}