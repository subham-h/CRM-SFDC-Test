/**
 * 1.0     SFSE-11001 9-sep-2023  ramya          Test class for CloseDateOpptyNotifyScheduler (for chatter notification)
*/
@isTest
private class Test_Batch_CloseDateOpptyNotifyScheduler {
  
   
    static testMethod void Test_Batch_CloseDateOpptyNotifyScheduler(){
        
            Test.StartTest();  
            
            Batch_CloseDateOpptyNotifyScheduler bScheduler= new Batch_CloseDateOpptyNotifyScheduler();
            String timeSchedule = '0 0 * * * ? *';
       
            System.schedule('Scheduler Batch_CloseDateOpptyNotifyScheduler Testing', timeSchedule, bScheduler);        
    
            Test.StopTest();    
    }
          
}