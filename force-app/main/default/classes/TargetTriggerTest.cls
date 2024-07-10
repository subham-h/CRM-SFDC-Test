@isTest
public class TargetTriggerTest {
    @testSetup
    static void setupTestData() {
        // Create test data for Target__c records
        User user1 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
        List<String> cadence= new List<String>{'Monthly','Monthly','Monthly'};
        List<String> year= new List<String>{'2074','2065','2096'};
        List<String> curr= new List<String>{'USD','USD','USD'};
        List<Target__c> testTargets = TestBusinessHelper.createSalesTargets(user1, year,curr,cadence, 3, true);
        Target_Data_Load__c targetDataLoad = TestBusinessHelper.createSalesTargetDataLoad('Test123','Rolling Forecast','Q42073','Completed',true);
        Target_Data_Load__c targetDataLoad1 = TestBusinessHelper.createSalesTargetDataLoad('Test143','Previous Year Actuals','','Completed',true);
        Target_Stage_Matrix__c stageMatrix = new Target_Stage_Matrix__c();
        stageMatrix.Target__c = testTargets[0].Id;
        stageMatrix.Target_Stage__c = TargetSettingConstants.APPROVAL_STAGE_1;
        insert stageMatrix;
        Target_Reviewer__c reviewer = new Target_Reviewer__c();
        reviewer.Target_Approval_Matrix__c = stageMatrix.Id;
        reviewer.Related_User__c = UserInfo.getUserId();
        insert reviewer;
    }
    
    @isTest
    static void testSalesTarget() {
        List<Target__c> targetList = [SELECT Id, Name, Status__c, Applicable_Year__c FROM target__c WHERE Applicable_Year__c = '2074'];
        Test.startTest();
        targetList[0].Stage__c = TargetSettingConstants.STAGE_EXCLUSIONS;
        update targetList[0];
        try {
            targetList[0].Stage__c = TargetSettingConstants.STATUS_NEW;
            update targetList[0];
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(LABEL.Target_Stage_Path_Error1));
        }
        try {
            targetList[0].Stage__c = TargetSettingConstants.STAGE_BUDGET;
            update targetList[0];
            targetList[0].Stage_Status__c = 'Completed';
            targetList[0].Stage__c = TargetSettingConstants.STAGE_PRE_CALCULATE_SALES;
            update targetList[0];
            targetList[0].Stage_Status__c = 'Completed';
            targetList[0].Stage__c = TargetSettingConstants.STAGE_PIPELINE;
            update targetList[0];
            targetList[0].Stage__c = TargetSettingConstants.STAGE_SETUP_CREATOR_AND_APPROVER;
            targetList[0].Stage_Status__c = 'Completed';
            update targetList[0];
            targetList[0].Stage__c = TargetSettingConstants.STAGE_COMPLETED;
            targetList[0].Stage_Status__c = 'Completed';
            update targetList[0];
        } catch (Exception ex) {
            //System.assert(ex.getMessage().contains(LABEL.Target_Stage_Path_Last_Yr_Actuals_Error));
        }
        Test.stopTest();        
    }
    
    @isTest
    static void testSalesTarget1() {
        List<Target__c> targetList= [SELECT Id, Name, Status__c, Applicable_Year__c FROM target__c WHERE Applicable_Year__c = '2096'];
        Test.startTest();
        targetList[0].Stage__c = TargetSettingConstants.STAGE_EXCLUSIONS;
        update targetList[0];
        try {
            targetList[0].Stage__c = TargetSettingConstants.STAGE_BUDGET;
            update targetList[0];
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(LABEL.Target_Stage_Path_Budget_Error));
        }
        Test.stopTest();        
    }
    
}