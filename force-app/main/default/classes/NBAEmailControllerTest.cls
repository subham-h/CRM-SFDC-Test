/**
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -----------------       -----------
 * 1.0                                                      Class created
 * 2.0      CRM0000030  09/09/2022  Ronnie@SF               Improved retrieval of recordtype info
 * 3.0      SPI-100     23/09/2022  Ronnie@SF               Removed brand hardcoding
 */
@isTest
public class NBAEmailControllerTest {
    
    public static TestMethod void testNBAEmailTemplate(){
        //Geography__c portugalCntry = new Geography__c(Name = 'Portugal',Type_Of_Location__c = 'Country');
        //insert portugalCntry;
        
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        CaseData_Test.conInstance = conInstance;
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {  
            caseIterator.recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('External_Case').getRecordTypeId();
            caseIterator.Direction__c = 'Export';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Documentation'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Amend SI/BL/VC';
            caseIterator.Case_Channel__c ='E-mail';
            //caseIterator.Country__c= portugalCntry.Id;
        }
        insert lstCases;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        insert cv;  
        
        List<ContentDocument> conDocs = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        EmailMessage emsg = new EmailMessage();
        emsg.FromAddress = 'test1@maersk.com';
        emsg.ToAddress = 'test2@gmail.com';
        emsg.CcAddress = 'test3@gmail.com';
        emsg.Subject = 'Test 1';
        emsg.TextBody = 'Test 2';
        emsg.ParentId = lstCases[0].Id;
        emsg.Incoming = true;
        insert emsg;
        
        Recommendation rec = new Recommendation();
        rec.Name = 'Amend Bill of Lading/Switch Bill';
        rec.AcceptanceLabel = 'Read & Action the Recommendation';
        rec.ActionReference = 'Run_NBA_Recommendation_Action';
        rec.Description = 'Share Amended Bill Of Lading and link to customer for self-service option on website.';
        rec.RejectionLabel = 'Reject Recommendation';
        insert rec;
        
         //Create NBA
        List<NBA_Action_Map__c> nbaList = new List<NBA_Action_Map__c>();
        NBA_Action_Map__c nba = new NBA_Action_Map__c();
        nba.Actions__c = 'Send an Email';
        nba.Flow_Name__c = 'Custom_NBA_Action';
        nba.Recommendation_Name__c = 'Charges, Invoice & Payment (Provide Invoice Copy)';
        nba.Recommendation_Id__c = rec.id;
        nba.Object__c ='Case';
        insert nba;
        nbaList.add(nba);
        
        NBAEmailController.EmailContent emailContent = new NBAEmailController.EmailContent();
        emailContent.fromaddress = 'test1@maersk.com';
        emailContent.to = 'test1@maersk.com';
        emailContent.cc = 'test2@maersk.com';
        emailContent.subject = 'Test 2';
        emailContent.bodyHTML = 'Test 2';
        emailContent.selectedEmailList = new List<String>{'test4@gmail.com'};
        emailContent.docIds = conDocs[0].Id;
        
        Test.startTest();
        NBAEmailController.getEmailBA();
        NBAEmailController.EmailWrapper ewrap1 = NBAEmailController.getEmailTemplate(lstCases[0].Id, rec.Id);
        //system.assertEquals(ewrap1.showTemplate, true);
        NBAEmailController.EmailWrapper ewrap2 = NBAEmailController.sendEmail(lstCases[0].Id, JSON.serialize(emailContent));
        //system.assertEquals(ewrap2.emailSent, true);
        Test.stopTest(); 
    }
    
}