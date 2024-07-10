@isTest
public class LWC_MetricsAggregateScheduler_Test {
    @isTest static void testschedule() {
        Test.StartTest();
        LWC_MetricsAggregateScheduler sh1 = new LWC_MetricsAggregateScheduler();  
        String sch = '0 30 0 * * ?'; 
        system.schedule('test LWC aggregate', sch, sh1); 
        Test.stopTest(); 
    }   
}