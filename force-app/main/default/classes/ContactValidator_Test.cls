/*
 * Author   : Hitha
 * Purpose  : Test ContactValidator
 *
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-004708     3/15/2017   Hitha@UST               Created.
 * 
 */
 
@isTest
public class ContactValidator_Test{
    
    public static list<Contact> lstContact = new list<Contact>();
    public static list<Account> lstAccount= new list<Account>();

    public static testMethod void test_customerContact() {
        ContactData_Test.createCustomerContacts();          
        lstContact = ContactData_Test.lstContacts;  
        
        Test.startTest();
        Database.deleteResult[] drList = Database.delete(lstContact, false);
        for(Database.deleteResult dr : drList) {
            if(dr.isSuccess()) {
                System.assertEquals(dr.isSuccess(), false, 'User is able to delete the Customer Contact which should not be the case.');
            }
        }
        Test.stopTest();   
    }
    
}