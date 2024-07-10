/**
 * 1.0     SFSE-11001 9-sep-2023  ramya          Test class for Batch_ClosePastOppsScheduler (for chatter notification)
*/
@isTest
private class Test_Batch_ClosePastOppsScheduler {
     
   
   
          static testMethod void Test_Batch_ClosePastOppsScheduler(){
        
            Test.StartTest();  
            
            Batch_ClosePastOppsScheduler bScheduler= new Batch_ClosePastOppsScheduler();
            String timeSchedule = '0 0 * * * ? *';
       
            System.schedule('Scheduler Batch_ClosePastOppsScheduler Testing', timeSchedule, bScheduler);        
    
            Test.StopTest();    
    }
}