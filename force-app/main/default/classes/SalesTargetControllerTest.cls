@isTest
public class SalesTargetControllerTest {
    
    @testSetUp
    static void testData() {
        User user1 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
        TestBusinessHelper.createSalesTarget(user1,'2078','USD','Monthly',true);
    }
    
    @isTest
    static void testCreateSalesTarget() {
        Test.startTest();
        Map<String, User> userMap = TestBusinessHelper.createUsers(new List<String>{'Super User'}, 'MaerskLine', true);
        User user = userMap.values()[0];
        Target__c target = TestBusinessHelper.createSalesTarget(user,'3048','USD','Monthly',false);
        target.Id = null;
        String targetId = SalesTargetController.createSalesTarget(target);
        SalesTargetController.getTargetApprovalStage(targetId);
        try {
            SalesTargetController.createSalesTarget(target);
        } catch (Exception ex) {
            
        }
        Test.stopTest();
    }
    
}