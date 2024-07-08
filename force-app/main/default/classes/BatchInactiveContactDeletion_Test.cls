/*******************************************************  
 * Class Name    : BatchInactiveContactDeletion_Test 
 * Description   : Test class for Batch_InactiveContact_Deletion 
 * -----------------------  Revision History -------------------
 * 
 * Sno      Version      Author      Date            Description                  
 * 1.       1.0          Neha-TCS    20/08/2020      This is test class for created for Batch_InactiveContact_Deletion
 * 2.       2.0          Ronnie@SF   15/06/2022      Removed brand hardcoding
 **********************************************************/

@isTest
public class BatchInactiveContactDeletion_Test {
    
    @testSetup static void setup() {        
         Test.startTest();
        TriggerExecutionController.skipAllTriggers(true);
        //create test account1-Account with Transactional data
        Account ClientAccount = TestBusinessHelper.createAccount('Client_Account', true);
        User RunUser = UserDataGeneratorHelper_Test.MSLIntegrationUser;
        
        //Relate a Contact with Account1
        Contact MSLContact = TestBusinessHelper.createContact(clientAccount, 'Customer_Contact', BrandUtilities.MAERSKLINE, true);
        Contact customerContactMaersk = TestBusinessHelper.createContact(clientAccount, 'Customer_Contact', BrandUtilities.SEAGO, false);
       	customerContactMaersk.Id = null;
        customerContactMaersk.LastName = 'CustomerContactMaersk';
        customerContactMaersk.Phone = '+44 123456';
        customerContactMaersk.MobilePhone = '+44 123456';
        customerContactMaersk.OtherPhone = '+44 123456';
        customerContactMaersk.Fax = '+44 123456';
        insert customerContactMaersk;
        
         Contact customerContactMaersk1 = TestBusinessHelper.createContact(clientAccount, 'Customer_Contact', BrandUtilities.SEALAND, false);
       	customerContactMaersk1.Id = null;
        customerContactMaersk1.LastName = 'CustomerContactMaersk1';
        customerContactMaersk1.Phone = '+44 1234561';
        customerContactMaersk1.MobilePhone = '+44 1234561';
        customerContactMaersk1.OtherPhone = '+44 1234561';
        customerContactMaersk1.Fax = '+44 1234561';
        insert customerContactMaersk1;
        //Contact MSLContact2 = ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MAERSKLINE,ClientAccount.Id,'testsafmarine@testingsaf.com',RunUser);
        Opportunity mslOppty = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);  
        
        //Relate tasks & events with Contact
        List<Task> msltask = DataGeneratorHelper1_Test.createTasks( 2, ClientAccount.id );
        msltask[0].WhoId= MSLContact.id;
        update msltask;
        List<Event> mslevent = DataGeneratorHelper1_Test.createEvents( 1, ClientAccount.id ); 
        mslevent[0].WhoId= MSLContact.id;
        update mslevent; 
         TriggerExecutionController.skipAllTriggers(false);
        Test.stopTest();
    }
    
    @isTest static void testBatchInactiveContactDeletion() {
        
        User usrRecord = new User(id=UserInfo.getUserId()); // Run as System admin User since batch will be invoked by Data Interface user which is admin User
        System.runAs(usrRecord){
            Test.startTest();
            // Fetch the account which is created
            Account clientAcc1 = [ SELECT Id,Name FROM Account  limit 1];
            // Fetch the contact associated with this account
            Contact lstContact = [SELECT Id,FirstName , Email FROM Contact where accountid=:clientAcc1.id  limit 1];         
            lstContact.Contact_Status__c = 'Inactive';  
            Validation_Rules_Bypass__c newRecord = new Validation_Rules_Bypass__c();
            newRecord.Active__c = true;
            newRecord.SetupOwnerId = UserInfo.getUserId();
            insert newRecord;
            update lstContact; // set the contact status as inactive which needs to be passed to the batch class 
            List<Contact> updatedContact = [SELECT Id,Contact_Status__c  FROM Contact where accountid=:clientAcc1.id and Contact_Status__c ='Inactive'];
            System.assertEquals(updatedContact[0].Contact_Status__c,'Inactive'); // assert to check if the contact is inactivated           
            Batch_InactiveContact_Deletion  batchTest = new Batch_InactiveContact_Deletion();            
            Database.executeBatch( batchTest); 
            batchTest.execute(null,updatedContact);            
            Test.stopTest();
        }
    }
}