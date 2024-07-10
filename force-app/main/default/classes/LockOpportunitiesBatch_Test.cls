/**
 * Version     RQ           Date             Dev          Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------
 * 1.0     SFSE-13391    17-May-2024    Shashi@Maersk     Test class for Batch_OpptyCloseDateChatterNotification (for chatter notification)
 */
@isTest
public class LockOpportunitiesBatch_Test {
    @TestSetup
    static void testSetup() {       
    TriggerExecutionController.skipAllTriggers(true);
    Validation_Rules_Bypass__c newRecord = new Validation_Rules_Bypass__c();
    newRecord.Active__c = true;
    newRecord.SetupOwnerId = UserInfo.getUserId();
    insert newRecord;
    Account clientAccount = TestBusinessHelper.createAccount('Client_Account', true);
    Opportunity mslOppty = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        mslOppty.CloseDate = Date.today().addDays(-90);
        mslOppty.StageName = 'Closed Won'; 
        mslOppty.Opportunity_Unlocked_Date__c = System.now().addDays(-10); 
        mslOppty.Record_Locked__c = false; 
        update mslOppty;
        delete newRecord;
    TriggerExecutionController.skipAllTriggers(false);     
   }     
    @isTest(seeAllData=false)
    static void test_LockOpportunitiesBatch(){
        Test.startTest();
        LockOpportunitiesBatchScheduler schedulableInstance = new LockOpportunitiesBatchScheduler();
        String cronExpression = '0 0 0 1 1 ? 2099'; 
        String jobId = System.schedule('Test Lock Opportunities Batch Job', cronExpression, schedulableInstance);
        Test.stopTest();   
    }
}