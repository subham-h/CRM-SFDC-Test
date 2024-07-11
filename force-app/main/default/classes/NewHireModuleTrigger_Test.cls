/*              
* Revision     Ref Number      Date            Owner                               Description
* -----------------------------------------------------------------------------------------
* 1.0          RQ-009682       14-Jan-2019     Junaid.Khader@ust-global.com        Code created
*/

@isTest(seeAllData = false)
private class NewHireModuleTrigger_Test {
    @testSetup static void setupTestData(){
        // Creating module 1 and its assignment
        New_Hire_Module__c module1 = DataGeneratorHelper1_Test.createNewHireModule( 'College Educated' );
        New_Hire_Assignments__c assignmentforModule1 = DataGeneratorHelper1_Test.createNewHireModule( module1.id );
        
        // Creating module 2 (last module) and its assignment
        New_Hire_Module__c module2 = new New_Hire_Module__c();
            module2.name = 'test nhm';
            module2.status__c = 'In Progress';
            module2.Order__c = 2;    
            module2.Onboarding_Plan__c = module1.Onboarding_Plan__c;
            module2.Duration__c = 2  ;  
            module2.Last_Module__c = true; 
            module2.Category__c = 'Our Company';
            module2.Badge_Name__c = 'College Educated';
            insert module2;
        New_Hire_Assignments__c recAssgmt = DataGeneratorHelper1_Test.createNewHireModule( module2.id );
    }
    // To test the positive scenario when all previous modules are completed while completing last module
    testMethod static void testPreviousModuleCompletionWithIncompleteModules() {
        New_Hire_Module__c previousHireModule = [SELECT ID, Confirm_Declaration__c FROM New_Hire_Module__c
                                            WHERE Badge_Name__c = 'College Educated' AND Last_Module__c = false LIMIT 1];
        New_Hire_Module__c lastHireModule = [SELECT ID, Confirm_Declaration__c FROM New_Hire_Module__c
                                            WHERE Badge_Name__c = 'College Educated' AND Last_Module__c = true LIMIT 1];
        
        New_Hire_Assignments__c newHireAssignmentPreviousModule = [SELECT Id, Status__c FROM New_Hire_Assignments__c WHERE New_Hire_Module__c = :previousHireModule.id AND Status__c = 'Not Started' LIMIT 1];
        New_Hire_Assignments__c newHireAssignmentLastModule = [SELECT Id, Status__c FROM New_Hire_Assignments__c WHERE New_Hire_Module__c = :lastHireModule.id AND Status__c = 'Not Started' LIMIT 1];
        
        
        newHireAssignmentPreviousModule.Status__c = 'Completed';
        update newHireAssignmentPreviousModule;
        
        previousHireModule.Confirm_Declaration__c = true;
        update previousHireModule;
        
        Test.StartTest();
        newHireAssignmentLastModule.Status__c = 'Completed';
        update newHireAssignmentLastModule;
            
        lastHireModule.Confirm_Declaration__c = true;
        update lastHireModule;
        
        
        Test.StopTest();
        New_Hire_Assignments__c newHireAssignment2 = [SELECT Id, Status__c FROM New_Hire_Assignments__c WHERE New_Hire_Module__c = :lastHireModule.id LIMIT 1];
        system.assertEquals('Completed', newHireAssignment2.Status__c);
    }
    // To test the negative scenario when  previous modules are incomplete while completing last module
    testMethod static void testLastModuleCompletionWithIncompleteModules() {
        New_Hire_Module__c lastHireModule = [SELECT ID, Confirm_Declaration__c FROM New_Hire_Module__c
                                            WHERE Badge_Name__c = 'College Educated' AND Last_Module__c = true LIMIT 1];
        
        New_Hire_Assignments__c newHireAssignmentLastModule = [SELECT Id, Status__c FROM New_Hire_Assignments__c WHERE New_Hire_Module__c = :lastHireModule.id AND Status__c = 'Not Started' LIMIT 1];
        
        
        Test.StartTest();
        try{
            newHireAssignmentLastModule.Status__c = 'Completed';
            update newHireAssignmentLastModule;
                
            lastHireModule.Confirm_Declaration__c = true;
            update lastHireModule;
        } catch(Exception e){}
        
        Test.StopTest();
        New_Hire_Module__c newHireModule2 = [SELECT Id, Status__c FROM New_Hire_Module__c WHERE Id = :lastHireModule.id LIMIT 1];
        system.assertNotEquals('Completed', newHireModule2.Status__c);
    }
}