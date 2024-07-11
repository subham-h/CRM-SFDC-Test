/*
 * Author   : Nisha
 * Purpose  : Test Batch_GenericPurger
 *
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-003324    13-Jun-2016 Nisha.arjunan@UST       Created.
 * 2.0      SC-146       03-Apr-2020 Avinash@UST             Call Task Deletion - Rolling 3 Year Window
 */

@isTest
public class Batch_GenericPurger_Test {
    
    public static testMethod void test_batchPrugeAccount() {
        String recordDeletionObject = 'Account';
        
        //test data
       AccountData_Test.iNumberOfAccounts = 200;
       AccountData_Test.bCreate = False;
       AccountData_Test.createDraftAccounts(); 
        list<Account> lstAccounts =AccountData_Test.lstAccounts; 
        for(Account accIterator : lstAccounts) {
            accIterator.Type = 'Test Account';
            accIterator.AnnualRevenue = 12345;
            accIterator.Description = 'Account Test Data';
            accIterator.NumberOfEmployees = 23456;
        }
        insert lstAccounts;
        Purge_Configuration__c customCln1 = new Purge_Configuration__c(Name = 'Account1',
                                                                       Object_Name__c = 'Account',
                                                                       Field_Name__c = 'AnnualRevenue',
                                                                       Order__c = 1,
                                                                       Job_Number__c = 1,
                                                                       Operation__c = '<=',
                                                                       Value__c = '12345');
        insert customCln1;
        
        Test.StartTest();       
        // test batch class
        // #SC-146 - Added JobNumber parameter to ctor
        Batch_GenericPurger batchCleanUp= new Batch_GenericPurger(recordDeletionObject,1);
        Id ApexId = Database.executeBatch(batchCleanUp);
        Test.StopTest();
        
        // verify batch job execution
        AsyncApexJob BatchJob = [ Select Id, Status, NumberOfErrors from AsyncApexJob where Id = :ApexId ];
        System.Assert( BatchJob != null );   
    }
    
    public static testMethod void  test_batchPrugeCase() {
        String recordDeletionObject = 'Case';
        
        //test data
        CustomSettingData_Test.createCleanupTestData();
        
        Test.StartTest();    
        // test batch class
        Batch_GenericPurger batchCleanUp= new Batch_GenericPurger(recordDeletionObject,1);
        Id ApexId = Database.executeBatch(batchCleanUp);    
        Test.StopTest();
        
        // verify batch job execution
        AsyncApexJob BatchJob = [ Select Id, Status, NumberOfErrors from AsyncApexJob where Id = :ApexId ];
        System.Assert( BatchJob != null );   
    }
    public static testMethod void  test_batchPrugeOOOCase() {
        String recordDeletionObject = 'Case';
        
        //test data
        CaseData_Test.bCreate=False;
        CaseData_Test.createExternalCases();
        CaseData_Test.closeNotACase();
        List<Case> lstCases=CaseData_Test.lstCases;
        
        insert lstCases;
        CustomSettingData_Test.createCleanupTestData();
        
        Test.StartTest();    
        // test batch class
        Batch_GenericPurger batchCleanUp= new Batch_GenericPurger(recordDeletionObject,3);
        Id ApexId = Database.executeBatch(batchCleanUp);    
        Test.StopTest();
        
        // verify batch job execution
        AsyncApexJob BatchJob = [ Select Id, Status, NumberOfErrors from AsyncApexJob where Id = :ApexId ];
        System.Assert( BatchJob != null );   
    }
    public static testMethod void  test_batchPrugeOOOCase2() {
        String recordDeletionObject = 'Case';
        
        //test data
        CaseData_Test.bCreate=False;
        CaseData_Test.createExternalCases();
        CaseData_Test.closeNotACase();
        List<Case> lstCases=CaseData_Test.lstCases;
        
        insert lstCases;
        CustomSettingData_Test.createCleanupTestData();
        
        Test.StartTest();    
        // test batch class
        Batch_GenericPurger batchCleanUp= new Batch_GenericPurger(recordDeletionObject,3,true);
        Id ApexId = Database.executeBatch(batchCleanUp);    
        Test.StopTest();
        
        // verify batch job execution
        AsyncApexJob BatchJob = [ Select Id, Status, NumberOfErrors from AsyncApexJob where Id = :ApexId ];
        System.Assert( BatchJob != null );   
    }
    public static testMethod void  test_batchPrugeOOOCase3() {
        String recordDeletionObject = 'Case';
        
        //test data
        CaseData_Test.bCreate=False;
        CaseData_Test.createExternalCases();
        CaseData_Test.closeNotACase();
        List<Case> lstCases=CaseData_Test.lstCases;
        
        insert lstCases;
        CustomSettingData_Test.createCleanupTestData();
        
        Test.StartTest();    
        // test batch class
        Batch_GenericPurger batchCleanUp= new Batch_GenericPurger(recordDeletionObject,3,true,true);
        Id ApexId = Database.executeBatch(batchCleanUp);    
        Test.StopTest();
        
        // verify batch job execution
        AsyncApexJob BatchJob = [ Select Id, Status, NumberOfErrors from AsyncApexJob where Id = :ApexId ];
        System.Assert( BatchJob != null );   
    }
}