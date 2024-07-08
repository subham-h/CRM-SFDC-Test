/**
* Test class for Apex class ChatterPostOnNewHireModuleComplete  
* Vesrion    Date                Owner                                  RQ#                   Description
**************************************************************************************************************************
   1.0         21/12/2018      meghana.gupta@ust-global.com          #RQ-005543             Code created
*/

@isTest
private class ChatterPostOnNewHireModuleComplete_Test {

    @testSetup static void createTestData(){
    
        New_Hire_Module__c recModule = DataGeneratorHelper1_Test.createNewHireModule( 'College Educated' );        
        New_Hire_Assignments__c recAssgmt = DataGeneratorHelper1_Test.createNewHireModule( recModule.id );
        
    }
        
    /*** Chatter feed for Modules with Badge Name */    
    testMethod static void BagdeChatterPostWithBadgeName() {
        
        New_Hire_Module__c recModule = [SELECT Id, Status__c FROM New_Hire_Module__c LIMIT 1];  
        New_Hire_Assignments__c recAssgmt = [SELECT Id, Status__c FROM New_Hire_Assignments__c WHERE New_Hire_Module__c= :recModule.Id LIMIT 1];        

        Test.StartTest();
        recAssgmt.Status__c = 'Completed';
        update recAssgmt;              
        
        recModule.Confirm_Declaration__c = true;
        recModule.Status__c = 'Completed';
        update recModule;
        Test.StopTest();
        
    }
}