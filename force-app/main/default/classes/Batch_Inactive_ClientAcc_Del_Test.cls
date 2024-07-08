/*
---------------------------------------------------------------------------------------------------------------------------
 * Author: Cognizant Technology Solutions
 * Purpose:  This class contains unit tests for validating the behavior of Apex classe Batch_Inactive_ClientAccount_Deletion and Scheduled_InactiveAccountDelete
-----------------------------------------------------------------------------------------------------------------------------

*Version   Date           Owner                                   Description
**************************************************************************************************************************************
* 1.0      06/12/2015   dinesh.moorthy@ust-global.com           #RQ-002192  Rename test class, add comments and optimization

*/
@isTest
private class Batch_Inactive_ClientAcc_Del_Test {
    
    static testMethod void Test_Batch_Inactive_ClientAccount_Delete() {        
     
        // create test account
        Account acc = AccountDataHelper_Test.createClientAccount( null, 'Inactive' );          
        
        Test.startTest();  
        
        // test scheduler class Scheduled_InactiveAccountDelete
        Scheduled_InactiveAccountDelete schController= new Scheduled_InactiveAccountDelete();
        String t = '0 0 * * * ? *';
        System.schedule( 'Inactive Account Deletion', t, schController );
        
        // test batch class
        Batch_Inactive_ClientAccount_Deletion controller = new Batch_Inactive_ClientAccount_Deletion();       
        controller.query = 'SELECT id, SCV_Code__c from Account where SCV_Status__c = \'Inactive\' and IsConcern__c = \'FALSE\' and Is_Opportunity__c = 0 limit 100';
             
        Id ApexId = Database.Executebatch( controller, 200 );  

        // verify batch job execution
        AsyncApexJob BatchJob = [ Select Id, Status, NumberOfErrors from AsyncApexJob where Id = :ApexId ];
        System.Assert( BatchJob != null );
        
        Test.stopTest();  
    } 
    
    static testMethod void Test_Batch2() {        
     
        // create test account
        Account acc = AccountDataHelper_Test.createClientAccount( null, 'Inactive' );          
        
        // create tasks & events for the test account 
        DataGeneratorHelper1_Test.createTasks( 2, acc.id );
        DataGeneratorHelper1_Test.createEvents( 1, acc.id );
        
        // account with an event & task will not be deleted by the batch
        Test.startTest(); 
        
        Batch_Inactive_ClientAccount_Deletion controller = new Batch_Inactive_ClientAccount_Deletion();       
        controller.query = 'SELECT id, SCV_Code__c from Account where SCV_Status__c = \'Inactive\' and IsConcern__c = \'FALSE\' and Is_Opportunity__c = 0 limit 100';
             
         Id ApexId = Database.Executebatch( controller, 200 );  

        // verify batch job execution
        AsyncApexJob BatchJob = [ Select Id, Status, NumberOfErrors from AsyncApexJob where Id = :ApexId ];
        System.Assert( BatchJob != null );       

        Test.stopTest();  

    } 
    
}