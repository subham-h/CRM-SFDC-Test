/**
 * 1.0     SFSE-8515  15-Dec-2022  Jothsana Devi          Test class for Batch_OpptyCloseDateChatterNotification (for chatter notification)
 * 2.0     SFSE-11001 18-sep-2022  ramya                  upgraded to latest framework
*/
@isTest
private class Batch_ClosePastOpps_Test {
    static testmethod void Setup() {
       
        TriggerExecutionController.skipAllTriggers(true);

    Validation_Rules_Bypass__c newRecord = new Validation_Rules_Bypass__c();
    newRecord.Active__c = true;
    newRecord.SetupOwnerId = UserInfo.getUserId();
    insert newRecord;

    Account clientAccount = TestBusinessHelper.createAccount('Client_Account', true);
    Opportunity mslOppty = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
    mslOppty.CloseDate = Date.today().addDays(-90);
    update mslOppty;

    newRecord.Active__c = false;
    newRecord.SetupOwnerId = UserInfo.getUserId();
    update newRecord;

    TriggerExecutionController.skipAllTriggers(false);     
   }    
    @IsTest(SeeAllData=true)
    static void testBatch_CloseDateDueIn7Days(){
        Test.startTest();
        Database.executeBatch(new Batch_ClosePastOpps(), 500);
        Test.stopTest();
        
    }
}