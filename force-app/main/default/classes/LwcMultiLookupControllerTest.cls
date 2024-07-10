@isTest
public class LwcMultiLookupControllerTest {
    
    @isTest
    public static void searchUserorContact(){
        UserData_Test.bCreate = false;
        UserData_Test.iNumberOfUsers = 1;
        UserData_Test.createCustomerusers();
        
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        
        Test.startTest();
        LwcMultiLookupController.getResults('Contact', 'Name', 'Test', null, '', '');
        LwcMultiLookupController.getResults('Contact, User', 'Name', 'Test', null, '', 'NBA');
        Test.stopTest();
    }
    
}