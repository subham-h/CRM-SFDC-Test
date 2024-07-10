@isTest
public class Scheduler_BatchUpdateTargetMeasureTest {
	@isTest
    static void testschedule(){
        Test.startTest();
        	Scheduler_BatchUpdateTargetItemMeasure scb = new Scheduler_BatchUpdateTargetItemMeasure();
        	system.schedule('Update Measure Credit Eligibility Batch', '1 1 0 * * ?', scb );
        Test.stopTest();
    }
}