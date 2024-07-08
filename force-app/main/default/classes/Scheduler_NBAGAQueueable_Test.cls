/*
 * Author   : Sunil BS
 * Purpose  : Test class for Scheduler class for Batch class which Pulls Data from Google Analytics for NBA back to salesforce
 *         
 * Revision Ref Number  Date               Owner                     Description
 * -------- ----------  -----------        -------------------       -----------
 * 1.0      SC - 4042   14-Jan-2021        Sunil.bs@maersk.com       Pull Data from GA to SFDC using JWT Token Exchange
 * 
 */
@isTest
public class Scheduler_NBAGAQueueable_Test{
     public static testmethod void QueueRun1(){
         
		// Covers Happly Flow
         Test.startTest();               
         Map<String,String> headers = new Map<String, String>();
         headers.put('Accept','application/json');
         //string sampleBody = '{"reports": [{"columnHeader": {"dimensions": ["ga:source","ga:Campaign"],"metricHeader": {"metricHeaderEntries": [{"name": "ga:Pageviews","type": "INTEGER"}]}},"data": {"rows": [{"dimensions": ["(not set)","CMSF","Tracking"],"metrics": [{"values": ["24"]}]},{"dimensions": ["5002E00000HIC80QAH","CMSF","Tracking"],"metrics": [{"values": ["1"]}]}],"totals": [{"values": ["25"]}],"rowCount": 2,"minimums": [{"values": ["1"]}],"maximums": [{"values": ["24"]}],"isDataGolden": true}}]}';
         string sampleBody= '{"reports":[{"columnHeader":{"dimensions":["ga:Keyword","ga:source","ga:Campaign"],"metricHeader":{"metricHeaderEntries":[{"name":"ga:Pageviews","type":"INTEGER"}]}},"data":{"rows":[{"dimensions":["5002E00000Hn2bcQAB","CMSF","MyFinance"],"metrics":[{"values":["55"]}]},{"dimensions":["5000E00000Hp9p5QAB","CMSF","Tracking"],"metrics":[{"values":["5"]}]}],"totals":[{"values":["6067"]}],"rowCount":82,"minimums":[{"values":["1"]}],"maximums":[{"values":["803"]}],"isDataGolden":true},"nextPageToken":"1"}]}';
         Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'Success',sampleBody,headers));
       // This test runs a scheduled job at midnight Sept. 3rd. 2022
         String CRON_EXP = '0 0 0 3 9 ? 2025';
       // Schedule the test job
         system.debug('came here1');
         General_Settings__c gs =General_Settings__c.getInstance();
         gs.NBA_PageSize__c = 1;
         gs.NBA_API_Callout_Count__c = 3;
         insert gs;
         system.debug('gs'+gs);
         String jobId = System.schedule('NBAGA_Queueable', CRON_EXP, new Scheduler_NBAGAQueueable());
          system.debug('came here2');
      // Get the information from the CronTrigger API object 
         CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
       // Verify the expressions are the same System.assertEquals(CRON_EXP, ct.CronExpression); 
      // Verify the job has not run 
     	 System.assertEquals(0, ct.TimesTriggered); 
          system.debug('came here3');
      // Verify the next time the job will run 
     	 System.assertEquals('2025-09-03 00:00:00', String.valueOf(ct.NextFireTime));   
     	 Test.stopTest();          
         
     }
    
    public static testmethod void QueueRun2(){
        
        
        system.debug('came here4');
        // Covers Bad Request
      	 Test.startTest();                
         Map<String,String> headers = new Map<String, String>();
         headers.put('Accept','application/json');
         string sampleBody = 'metricHeaderEntries": [{"name": "ga:Pageviews","type": "INTEGER"}]}},"data": {"rows": [{"dimensions": ["(not set)","CMSF","Tracking"],"metrics": [{"values": ["24"]}]},{"dimensions": ["5002o00002v8mI4AAI","CMSF","Tracking"],"metrics": [{"values": ["1"]}]}],"totals": [{"values": ["25"]}],"rowCount": 2,"minimums": [{"values": ["1"]}],"maximums": [{"values": ["24"]}],"isDataGolden": true}}]}'; 
         General_Settings__c gs = new General_Settings__c();
         gs.NBA_PageSize__c = 1;
         gs.NBA_API_Callout_Count__c = 1;
         insert gs;
        
          Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'Success',sampleBody,headers));
     	  // This test runs a scheduled job at midnight Sept. 3rd. 2022
          String CRON_EXP = '0 0 0 3 9 ? 2025';
     	  // Schedule the test job
      	  String jobId = System.schedule('NBAGA_Queueable', CRON_EXP, new Scheduler_NBAGAQueueable());
      	  // Get the information from the CronTrigger API object 
          CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
      	  // Verify the expressions are the same System.assertEquals(CRON_EXP, ct.CronExpression); 
      	  // Verify the job has not run 
      	  System.assertEquals(0, ct.TimesTriggered); 
      	  // Verify the next time the job will run 
      	  System.assertEquals('2025-09-03 00:00:00', String.valueOf(ct.NextFireTime));   
      	  Test.stopTest();   
               
     }
    
    public static testmethod void QueueRun3(){
        
         system.debug('came here5');
         // covers bad response
         Test.startTest();                
         Map<String,String> headers = new Map<String, String>();
         headers.put('Accept','application/json');
         string sampleBody = '{"reports": [{"columnHeader": {"dimensions": ["ga:source","ga:Campaign"],"metricHeader": {"metricHeaderEntries": [{"name": "ga:Pageviews","type": "INTEGER"}]}},"data": {"rows": [{"dimensions": ["(not set)","CMSF","Tracking"],"metrics": [{"values": ["24"]}]},{"dimensions": ["5002E00000HIC80QAH","CMSF","Tracking"],"metrics": [{"values": ["hi"]}]}],"totals": [{"values": ["25"]}],"rowCount": 2,"minimums": [{"values": ["1"]}],"maximums": [{"values": ["24"]}],"isDataGolden": true}}]}';

         Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(201,'failure',sampleBody,headers));
      	 // This test runs a scheduled job at midnight Sept. 3rd. 2022
         String CRON_EXP = '0 0 0 3 9 ? 2025';
      	 // Schedule the test job
      	 String jobId = System.schedule('NBAGA_Queueable', CRON_EXP, new Scheduler_NBAGAQueueable());
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