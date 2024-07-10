@isTest(seeAllData=true)
public class BatchCaseQueueTimeBHCalculation_Test {
    
    public static TestMethod void testCaseTimeSpentUpdateBatch(){
        Test.startTest();
        Database.executeBatch(new BatchCaseQueueTimeBHCalculation(null, null, null));
        Test.stopTest();
    }
    
    public static TestMethod void testCaseTimeSpentUpdateBatch2(){
        Test.startTest();
        Date startDate = System.today() - 10;
        Date endDate = System.today() - 5;        
        Database.executeBatch(new BatchCaseQueueTimeBHCalculation(startDate, endDate, null));
        Test.stopTest();
    }
    
}