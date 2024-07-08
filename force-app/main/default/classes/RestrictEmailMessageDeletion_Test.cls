/*
* Test class to cover  trigger RestrictEmailMessageDeletion,RestrictEmailMessageDeletion_Handler 
*and RestrictEmailMessageDeletion_Utilities classes
* 
*Version    Date           Owner                                      RQ#               Description
*********************************************************************************************************************************  
1.0       26-Oct-2014     prashanth.ds@accenture.com                                   Code created.
2.0       08-Nov-2016     nisha.arjunan@ust-global.com              #RQ-004464         Removed (SeeAllData=true) ,modified to maintain the code coverage
*/

@isTest
private class RestrictEmailMessageDeletion_Test{
    
    public static testmethod void test_restrictEmailMessageDeletion(){
        
       AccountData_Test.iNumberOfAccounts = 1;
       AccountData_Test.createDraftAccounts();
        Account accInstance =AccountData_Test.lstAccounts[0];
        
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.createEmailtoCase();
        Case caseInstance = CaseData_Test.lstCases[0];
        Test.startTest();
        EmailMessageData_Test.bCreate = false;
        EmailMessageData_Test.iNumberOfEmailMessages = 5;
        EmailMessageData_Test.createEmailMessage();
        list<EmailMessage> lstEmailMessages = EmailMessageData_Test.lstEmailMessages;
        
        insert lstEmailMessages;
        
        System.assertEquals(lstEmailMessages.size(), 5);
        // Restricts Users from Deleting EmailMessages and Users listed under the "Validation Rules Bypass" custom setting are exempted.
        try{
            Delete lstEmailMessages;
        }
        Catch(exception e){
        }
        Test.stopTest();
    }
    
}