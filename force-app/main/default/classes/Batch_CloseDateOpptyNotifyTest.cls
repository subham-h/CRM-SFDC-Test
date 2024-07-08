/**
 * 1.0     SFSE-11001 9-sep-2023  ramya          Test class for Batch_CloseDateOpptyNotification (for chatter notification)
*/
@isTest
private class Batch_CloseDateOpptyNotifyTest {
    static testmethod void Setup() {
       
        TriggerExecutionController.skipAllTriggers(true);
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', true);
        Opportunity mslOppty = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
       mslOppty.CloseDate =  date.today(); 
        update mslOppty;
         TriggerExecutionController.skipAllTriggers(false);
   }    
    @IsTest(SeeAllData=true)
    static void testBatch_CloseDateDueIn7Days(){
        Test.startTest();
        Database.executeBatch(new Batch_CloseDateOpptyNotification(), 100);
        Test.stopTest();
        
    }
    static testMethod void Test_Batch_CloseDateOpptyNotifyScheduler(){
        
            Test.StartTest();  
            
            Batch_CloseDateOpptyNotifyScheduler bScheduler= new Batch_CloseDateOpptyNotifyScheduler();
            String timeSchedule = '0 0 * * * ? *';
       
            System.schedule('Scheduler Batch_CloseDateOpptyNotifyScheduler Testing', timeSchedule, bScheduler);        
    
            Test.StopTest();    
    }
          static testMethod void Test_Batch_ClosePastOppsScheduler(){
        
            Test.StartTest();  
            
            Batch_ClosePastOppsScheduler bScheduler= new Batch_ClosePastOppsScheduler();
            String timeSchedule = '0 0 * * * ? *';
       
            System.schedule('Scheduler Batch_ClosePastOppsScheduler Testing', timeSchedule, bScheduler);        
    
            Test.StopTest();    
    }
}