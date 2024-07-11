/**
 * Version  Date           Owner                    RQ#           Description
 ****************************************************************************************************************************************
 * 1.0      
 * 2.0      15/06/2022     Ronnie@SF                SPI-100       Removed brand hardcoding
 */

@isTest
public class Batch_InactiveContact_Deletion_Test {
    
    @testSetup static void setup() {
        Test.startTest();
       TriggerExecutionController.skipAllTriggers(true);
        //create test account1-Account with Transactional data
        Account ClientAccount = TestBusinessHelper.createAccount('Client_Account', true);
        
        //Relate a Contact with Account1
        Contact MSLContact =TestBusinessHelper.createContact(clientAccount, 'Customer_Contact', BrandUtilities.MAERSKLINE, true);
        Opportunity mslOppty = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        //Relate a SalesMetrics with Account1
        List <Product2> prodList = DataGeneratorHelper1_Test.createProduct2(1,'A','DE','MSL');
        
        //Relate tasks & events with Account1
        List<Task> msltask = DataGeneratorHelper1_Test.createTasks( 2, ClientAccount.id );
        msltask[0].WhoId=MSLContact.id;
        update msltask;
        List<Event> mslevent = DataGeneratorHelper1_Test.createEvents( 1, ClientAccount.id ); 
        mslevent[0].WhoId=MSLContact.id;
        update mslevent;
        
        ClientAccount.SCV_Status__c = 'Inactive';
        ClientAccount.Customer_Status_Reason__c='Duplicate';
        update ClientAccount;
        /*
        //Create Test Account2 - Account with No transactional data
        Account ClientAcc2 = AccountDataHelper_Test.createClntAccountWithMSLUser();
        
        ClientAcc2.SCV_Status__c = 'Inactive';
        ClientAccount.Customer_Status_Reason__c='Duplicate';
        update ClientAcc2; 
        */
        /* MSLContact.Contact_Status__c = 'Inactive';
        MSLContact.email = '1111111@gmail.co';
        update MSLContact;*/
        TriggerExecutionController.skipAllTriggers(false);
        Test.stopTest();
    }
    
    @isTest static void testBatchInactiveAccountsDeletion() {
        
        User usrRecord = new User(id=UserInfo.getUserId()); // Run as System admin User since batch will be invoked by Data Interface user which is admin User
        System.runAs(usrRecord){
            Test.startTest();
            Account clientAcc1 = [ SELECT Id,Name FROM Account Limit 1 ];
            system.debug('$$$clientAcc1: '+ clientAcc1);
            List<Contact> lstContact = [SELECT Id,Name FROM Contact limit 1 ];
            InActiveContact_Deletion_Batch batchTest = new InActiveContact_Deletion_Batch();
            Database.executeBatch( batchTest); 
            batchTest.execute(null,lstContact);
            InactiveContact_Deletion_Schedule schClass = new InactiveContact_Deletion_Schedule();
            String strSchTime = '0 8 13 14 3 ? *';
            System.schedule( 'deleteInactiveAccount', strSchTime, schClass );
            Test.stopTest();
        }
    }
}