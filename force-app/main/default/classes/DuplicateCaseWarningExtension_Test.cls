/*
* Test Class for DuplicateCaseWarningExtension
* 
*Version    Date           Owner                              RQ#            Description
*********************************************************************************************************************************  
1.0       12-11-2015      meghana.gupta@ust-global.com     RQ-002150        Code created.
2.0       01-Jan-2016     meghana.gupta@ust-global.com     RQ-002192        Rename test class, add comments and optimization
3.0       07-Nov-2016     nisha.arjunan@ust-global.com     RQ-004464        Rewrite according to the new standards.
4.0       04-Apr-2023     Nayana@maersk.com                SC-6887          Calling LWC method for coverage of LWC part
*/
@isTest
public class DuplicateCaseWarningExtension_Test {
    
    static testMethod void test_duplicateCaseWarningExtension() {
        list<EmailMessage> lstEmailMessge = new list<EmailMessage>();
        list<Attachment> lstAttachment = new list<Attachment>();
        list<Case> lstCases = new list<Case>();
        
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createDraftAccounts();
        Account accInstance =AccountData_Test.lstAccounts[0];
        
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        CaseData_Test.iNumberOfCases = 4;
        // Create duplicate cases by calling createExternalCases() two times
        CaseData_Test.createExternalCases();
        Test.startTest();
        CaseData_Test.createExternalCases();
        lstCases = CaseData_Test.lstCases; 
        
        AccountData_Test.createEntitlements();
        
        EmailMessageData_Test.iNumberOfAttachments = 5;
        EmailMessageData_Test.addAttachment();
        lstAttachment = EmailMessageData_Test.lstAttachments;
        Test.stopTest(); 
        
        //Construct your pagereference
        PageReference testPage = new PageReference( '/apex/DuplicateCaseWarning' );
        testPage.getParameters().put( 'id', lstCases[0].Id );
        Test.setCurrentPage(testPage);       
        
        DuplicateCaseWarningExtension controller = new DuplicateCaseWarningExtension( new ApexPages.StandardController( lstCases[0] ) );
        System.assertEquals(2, controller.possibleDupes );

        //Testing LWC method
        Integer duplicates = 0;
        duplicates = DuplicateCaseWarningExtension.getPossibleDupes(lstCases[0].id); 
        System.assertEquals(2, duplicates );
    }
}