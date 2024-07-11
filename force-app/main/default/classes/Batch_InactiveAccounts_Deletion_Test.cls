/**
 * Version       Date               Owner                               Ref           Description
 *******************************************************************************************************
 * v1.0          09/08/2018         John.Christopher@ust-global.com     #RQ-008412    Code Created
 * v2.0          11/07/2019         Junaid.Khader@ust-global.com        #RQ-010654    Removed invocation of method DataGeneratorHelper1_Test.createTarget which creates deprecated object Target__c
 * v3.0          17/09/2019         Neha - TCS                          ##RQ-007086   modified to include Customer_Status_Reason__c field as this is checked in Batch
 * v4.0	         21/12/2021	        Meghana.gupta@UST                                 Remove references to SalesMetricsDataGeneratorHelper
 * v5.0          15/06/2022         Ronnie@SF                           SPI-100       Removed brand hardcoding
 */
@isTest
public class Batch_InactiveAccounts_Deletion_Test {
    
    @testSetup static void setup() {
        
        //create test account1-Account with Transactional data
        Account ClientAccount = AccountDataHelper_Test.createClientAccount();
        
        //Relate a Contact with Account1
        Contact MSLContact = ContactDataGeneratorHelper_Test.createCustomerContact(ClientAccount.Id, BrandUtilities.MAERSKLINE);
        
        //Relate a SalesMetrics with Account1
        List <Product2> prodList = DataGeneratorHelper1_Test.createProduct2(1,'A','DE','MSL');
        
        //Relate tasks & events with Account1
        DataGeneratorHelper1_Test.createTasks( 2, ClientAccount.id );
        DataGeneratorHelper1_Test.createEvents( 1, ClientAccount.id ); 
        
        ClientAccount.SCV_Status__c = 'Inactive';
        ClientAccount.Customer_Status_Reason__c='Duplicate';
        ClientAccount.BillingCity = '';
        update ClientAccount;
        
        //Create Test Account2 - Account with No transactional data
        Account ClientAcc2 = AccountDataHelper_Test.createClntAccountWithMSLUser();
        
        ClientAcc2.SCV_Status__c = 'Inactive';
        ClientAccount.Customer_Status_Reason__c='Duplicate';
        update ClientAcc2; 
    }
    
    @isTest static void testBatchInactiveAccountsDeletion() {
        User usrRecord = new User(id=UserInfo.getUserId()); // Run as System admin User since batch will be invoked by Data Interface user which is admin User
        System.runAs(usrRecord){
            Test.startTest();
            Account clientAcc1 = [ SELECT Id,Name FROM Account WHERE Name = : 'Test Class Client Account' ];
            system.debug('$$$clientAcc1: '+ clientAcc1);
            Account clientAcc2 = [ SELECT Id,Name FROM Account WHERE Name = : 'Test Account - MSL User' ];
            system.debug('$$$clientAcc2: '+ clientAcc2);
            Batch_InactiveAccounts_Deletion batchTest = new Batch_InactiveAccounts_Deletion();
            Database.executeBatch( batchTest); 
            
            // test scheduler class
            // Schedule_Batch_InactiveAccounts_Deletion.scheduleBatch();
            Schedule_Batch_InactiveAccounts_Deletion schClass = new Schedule_Batch_InactiveAccounts_Deletion();
            String strSchTime = '0 8 13 14 3 ? *';
            System.schedule( 'deleteInactiveAccount', strSchTime, schClass );
            Test.stopTest();
            
            List<Account> lstClientAcc1AfterBatch = [ SELECT Id,Name FROM Account WHERE Name = : 'Test Class Client Account' ];
            System.assertEquals(1,lstClientAcc1AfterBatch.size()); // this confirms the account with transactional data did not deleted via batch
        }
    }
}