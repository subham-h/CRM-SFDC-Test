@isTest
public class Batch_ContactLoader_Test{
    @testSetup static void setup() {       
        TriggerExecutionController.skipAllTriggers(true);
        Account clientAcc = AccountDataHelper_Test.createClientAccount();
        clientAcc.Customer_Code__c = 'VN00829521';
        update clientAcc;
        Contact CustContact = ContactDataGeneratorHelper_Test.createCustomerContact(clientAcc.Id, BrandUtilities.MAERSKLINE);
        CustContact.Email='cmdtest@gmail.com';
        CustContact.External_Id__c='';
        update CustContact;
        Contact CustContactext = ContactDataGeneratorHelper_Test.createCustomerContact(clientAcc.Id, BrandUtilities.MAERSKLINE);
        CustContactext.Email='cmdtest125@gmail.com';
        CustContactext.External_Id__c='VN00829521';
        update CustContactext;
        TriggerExecutionController.skipAllTriggers(false);
    }
    
    static testMethod void testloadupdate() {  
        list<Contact_loader__c> ContactList= new list<Contact_loader__c>();
        Contact_loader__c conload= new Contact_loader__c();
        conload.External_Id__c='';
        conload.customer_code__c='VN00829521';
        conload.Dataload_Status__c='New';
        conload.contact_type__c='Finance';
        conload.Unique_Email_Address__c='cmdtest1@gmail.com';
        conload.Liner_Brands__c=brandutilities.MAERSKLINE;
        conload.Contact_Status__c='Active';
        conload.Department__c='Testdept';
        conload.Email__c='cmdtest1@gmail.com';
        conload.Extension_Number__c='567';
        conload.fax_dialing_code__c='32';
        conload.fax_number__c='32456';
        conload.First_Name__c='Test CMD User';
        conload.Job_Role__c='CUST_CONT';
        conload.Last_Name__c='CMD user';
        conload.mobile_dialing_code__c='91';
        conload.mobile_number__c='9876543210';
        conload.Duplicate_Email__c='cmdtest12@gmail.com';
        conload.telephone_dialing_code__c='65';
        conload.telephone_number__c='598786';
        conload.Preferred_Language__c='EN';
        conload.Salutation__c='Mr.';
        conload.Title__c='testtitle';
        ContactList.add(conload);
        insert ContactList;
        Test.starttest();
        Batch_ContactLoader bc = new Batch_ContactLoader();
        database.executeBatch(bc,2);
        Test.stopTest();
        }
                
        static testMethod void testloadinsert() {  
        list<Contact_loader__c> ContactList= new list<Contact_loader__c>();
        Contact_loader__c conload= new Contact_loader__c();
        conload.External_Id__c='VN00829522';
        conload.customer_code__c='VN00829521';
        conload.Dataload_Status__c='New';
        conload.contact_type__c='Finance';
        conload.Unique_Email_Address__c='cmdtest2@gmail.com';
        conload.Liner_Brands__c=brandutilities.MAERSKLINE;
        conload.Contact_Status__c='Active';
        conload.Department__c='Testdept';
        conload.Email__c='cmdtest2@gmail.com';
        conload.Extension_Number__c='567';
        conload.fax_dialing_code__c='323';
        conload.fax_number__c='32455';
        conload.First_Name__c='Test CMD User Cnv';
        conload.Job_Role__c='CUST_CONT';
        conload.Last_Name__c='CMD user';
        conload.mobile_dialing_code__c='91';
        conload.mobile_number__c='9876543220';
        conload.Duplicate_Email__c='cmdtest2@gmail.com';
        conload.telephone_dialing_code__c='652';
        conload.telephone_number__c='5987865';
        conload.Preferred_Language__c='EN';
        conload.Salutation__c='Mr.';
        conload.Title__c='testuser';
        ContactList.add(conload);
        insert ContactList;
        Test.starttest();
        Batch_ContactLoader bc = new Batch_ContactLoader();
        database.executeBatch(bc,2);
        Test.stopTest();
        }
        
        static testMethod void testloadconvert() {  
        list<Contact_loader__c> ContactList= new list<Contact_loader__c>();
        Contact_loader__c conload= new Contact_loader__c();
        conload.External_Id__c='';
        conload.customer_code__c='VN00829521';
        conload.Dataload_Status__c='New';
        conload.contact_type__c='Finance';
        conload.Unique_Email_Address__c='cmdtest@gmail.com';
        conload.Liner_Brands__c=brandutilities.MAERSKLINE;
        conload.Contact_Status__c='Active';
        conload.Department__c='Testdept';
        conload.Email__c='cmdtest@gmail.com';
        conload.Extension_Number__c='567';
        conload.fax_dialing_code__c='323';
        conload.fax_number__c='32455';
        conload.First_Name__c='Test CMD User Ins';
        conload.Job_Role__c='CUST_CONT';
        conload.Last_Name__c='CMD user';
        conload.mobile_dialing_code__c='91';
        conload.mobile_number__c='9876543220';
        conload.Duplicate_Email__c='cmdtest21@gmail.com';
        conload.telephone_dialing_code__c='652';
        conload.telephone_number__c='5987865';
        conload.Preferred_Language__c='EN';
        conload.Salutation__c='Mr.';
        conload.Title__c='testuser';
        ContactList.add(conload);
        insert ContactList;
        Test.starttest();
        Batch_ContactLoader bc = new Batch_ContactLoader();
        database.executeBatch(bc,2);
        Test.stopTest();
        }
        
        static testMethod void testloadupdateext() {  
        list<Contact_loader__c> ContactList= new list<Contact_loader__c>();
        Contact_loader__c conload= new Contact_loader__c();
        conload.External_Id__c='VN00829521';
        conload.customer_code__c='VN00829521';
        conload.Dataload_Status__c='New';
        conload.contact_type__c='Finance';
        conload.Unique_Email_Address__c='cmdtest125@gmail.com';
        conload.Liner_Brands__c=brandutilities.MAERSKLINE;
        conload.Contact_Status__c='Active';
        conload.Department__c='Testdept';
        conload.Email__c='cmdtest125@gmail.com';
        conload.Extension_Number__c='567';
        conload.fax_dialing_code__c='32';
        conload.fax_number__c='32456';
        conload.First_Name__c='Test CMD User';
        conload.Job_Role__c='CUST_CONT';
        conload.Last_Name__c='CMD user';
        conload.mobile_dialing_code__c='91';
        conload.mobile_number__c='9876543210';
        conload.Duplicate_Email__c='cmdtest12@gmail.com';
        conload.telephone_dialing_code__c='65';
        conload.telephone_number__c='598786';
        conload.Preferred_Language__c='EN';
        conload.Salutation__c='Mr.';
        conload.Title__c='testtitle';
        ContactList.add(conload);
        insert ContactList;
        Test.starttest();
        Batch_ContactLoader bc = new Batch_ContactLoader();
        database.executeBatch(bc,2);
        Test.stopTest();
        }
        
}