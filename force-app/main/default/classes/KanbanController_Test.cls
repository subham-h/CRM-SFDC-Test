/*      
* Revision Ref Number  Date             Owner                                Description
* -------- ----------  -----------    -------------------                 -------------------------
* 1.0       SFSE-12515  25-11-23     aleena.akhtar@maersk.com              Test class for KanbanController class
*/
@isTest
public class KanbanController_Test {
@isTest
    static void testGetRelatedRecords() {
        // Create test data
        Account acc = TestBusinessHelper.createAccount('Client_Account', true); 
        Business_Plan__c testBusinessPlan = TestBusinessHelper.createBusinessPlan(acc, BrandUtilities.MAERSKLINE, true);

        Action__c testAction = new Action__c(Account_Plan__c = testBusinessPlan.Id, Name = 'Test Action');
        insert testAction;

        // Call the method to test
        KanbanController.Wrapper result = KanbanController.getRelatedRecords(
            'Account_Plan__c', 
            testBusinessPlan.Id, 
            'Action__c', 
            'Priority__c', 
            'Name,Priority__c'  // Exclude Id from the query
        );


    }

    @isTest
    static void testUpdateRecord() {
        // Create test data
        System.runAs(new User(Id = UserInfo.getUserId())) {
                  Account acc = TestBusinessHelper.createAccount('Client_Account', true); 
        Business_Plan__c testBusinessPlan = TestBusinessHelper.createBusinessPlan(acc,BrandUtilities.MAERSKLINE,true);
       // List<Business_Plan__c> bp = [SELECT Id, Lead_Account__c, Liner_Brand__c FROM Business_Plan__c WHERE Liner_Brand__c = :BrandUtilities.MAERSKLINE];                     


        Action__c testAction = new Action__c(Account_Plan__c =testBusinessPlan.Id, Name = 'Test Action');
        insert testAction;

        // Call the method to test
        KanbanController.Wrapper result = KanbanController.updateRecord(testAction.Id, 'NewStatus', 'Status__c');

       
    }
    }

    @isTest
    static void testCreateRecord() {
        // Call the method to test
        Id newRecordId = KanbanController.createRecord('Action__c', new Map<String, Object>{'Name' => 'New Action'});

    
        System.assertNotEquals(null, newRecordId);
       
    }

    @isTest
    static void testGetPicklistValues() {
        // Call the method to test
        List<String> picklistValues = KanbanController.getPicklistValues();

      
    }

    @isTest
    static void testGetAccountPlans() {
        // Call the method to test
        System.runAs(new User(Id = UserInfo.getUserId())) {
        List<Business_Plan__c> accountPlans = KanbanController.getAccountPlans();
        
        }
       
    }

    @isTest
    static void testActionList() {
        // Create test data
        System.runAs(new User(Id = UserInfo.getUserId())) {
        
      Account acc = TestBusinessHelper.createAccount('Client_Account', true); 
        Business_Plan__c testBusinessPlan = TestBusinessHelper.createBusinessPlan(acc,BrandUtilities.MAERSKLINE,true);        
        Action__c testAction = new Action__c(Account_Plan__c = testBusinessPlan.Id, Name = 'Test Action');
        insert testAction;

        // Call the method to test
        List<Action__c> actions = KanbanController.ActionList(testBusinessPlan.Id);

        // Perform assertions
        System.assertEquals(1, actions.size());
        
    }
    }
    @isTest
    static void testGoalList() {
        // Create test data
        System.runAs(new User(Id = UserInfo.getUserId())) {
      Account acc = TestBusinessHelper.createAccount('Client_Account', true); 
        Business_Plan__c testBusinessPlan = TestBusinessHelper.createBusinessPlan(acc,BrandUtilities.MAERSKLINE,true);

        Focus_Area__c testGoal = new Focus_Area__c(Account_Plan__c = testBusinessPlan.Id, Name = 'Test Goal');
        insert testGoal;

       
        List<Focus_Area__c> goals = KanbanController.GoalList(testBusinessPlan.Id);

        
        System.assertEquals(1, goals.size());
       
    }
    }
    @isTest
    static void testActionunderGoal() {
        // Create test data
        Account acc = TestBusinessHelper.createAccount('Client_Account', true); 
        Business_Plan__c testBusinessPlan = TestBusinessHelper.createBusinessPlan(acc, BrandUtilities.MAERSKLINE, true);

        Action__c testAction = new Action__c(Account_Plan__c = testBusinessPlan.Id, Name = 'Test Action');
        insert testAction;

   
        List<Action__c> result = KanbanController.ActionunderGoal(testAction.Id);

       
       

    }

    @isTest
    static void testDeleteRecordAction() {
      
        Account acc = TestBusinessHelper.createAccount('Client_Account', true); 
        Business_Plan__c testBusinessPlan = TestBusinessHelper.createBusinessPlan(acc, BrandUtilities.MAERSKLINE, true);

        Action__c testAction = new Action__c(Account_Plan__c = testBusinessPlan.Id, Name = 'Test Action');
        insert testAction;

     
        Test.startTest();
        KanbanController.deleteRecord('Action__c', testAction.Id);
        Test.stopTest();

        
    }

    @isTest
    static void testDeleteRecordFocusArea() {
      
        Account acc = TestBusinessHelper.createAccount('Client_Account', true); 
        Business_Plan__c testBusinessPlan = TestBusinessHelper.createBusinessPlan(acc, BrandUtilities.MAERSKLINE, true);

        Focus_Area__c testGoal = new Focus_Area__c(Account_Plan__c = testBusinessPlan.Id, Name = 'Test Goal');
        insert testGoal;

        Test.startTest();
        KanbanController.deleteRecord('Focus_Area__c', testGoal.Id);
        Test.stopTest();

        
    }
    @isTest
    static void testUpdateActionRecord() {
        // Create test data
        Account acc = TestBusinessHelper.createAccount('Client_Account', true); 
        Business_Plan__c testBusinessPlan = TestBusinessHelper.createBusinessPlan(acc, BrandUtilities.MAERSKLINE, true);
        
        Focus_Area__c testGoal = new Focus_Area__c(Account_Plan__c = testBusinessPlan.Id, Name = 'Test Goal');
        insert testGoal;
        Action__c testAction = new Action__c(Account_Plan__c = testBusinessPlan.Id, Name = 'Test Action');
         
        insert testAction;
        
        // Call the method to test
        Map<String, Object> fieldsToUpdate = new Map<String, Object>{
            'Status__c' => 'At Risk',
            'Priority__c' => 'High'
        };

        KanbanController.updateActionRecord(testAction.Id, fieldsToUpdate);

        // Perform assertions
        
    }

}