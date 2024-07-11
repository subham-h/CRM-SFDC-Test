/*******************************************************  
 * Class Name    : ContentDocumentLinkTrigger_Test
 * Description   : Test class for ContentDocumentLinkTrigger and its associated classed.
 * -----------------------  Revision History -------------------
 *
 * Sno      Version      Author        Date            Description                  
 * 1.       1.0          Neha-TCS      06/10/2019      Initial Development. 
 * 2.       1.1          Nitin@Maersk  19/01/2021      SFSE-5472 fixed datasetup method to create unique user.
 * 3.       1.2          Ronnie@SF     08/06/2022      Removed brand hardcoding
 *********************************************************/
@isTest
public class ContentDocumentLinkTrigger_Test {

    // This is set up method for test class
    @testSetup static void dataSetup() {
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account testclAcc = AccountData_Test.lstAccounts[0];
        
        Event eventRecord = new Event();
        eventRecord.whatId = testclAcc.id; 
        eventRecord.Subject = 'UnitTest1';
        eventRecord.StartDateTime = system.now();
        eventRecord.EndDateTime = system.now() + 1;
        eventRecord.ownerId = UserInfo.getUserId();        
        eventRecord.Type = 'Sales Call (Face-to-Face)';
        insert eventRecord;
        Geography__c geoRecord = new Geography__c(Name='UK',Type_Of_Location__c='Country');
        insert geoRecord;
    }
    
    // Method to test the content document trigger
    public static testMethod void test_ContentDocumentLinkTrigger(){
        Id pid = [SELECT Id FROM Profile WHERE Name = 'Sales'].Id;
        User usrRecord = new User(LastName = 'contentDocumentTriggerTest',Email = 'testrecord@maersk.com',Liner_Brand__c=BrandUtilities.MAERSKLINE,Cluster__c='GSC',Country='UK',Username = 'test999999@maersk.com',CompanyName = 'TEST',Title = 'title',Alias = 'alias',Industry_Focus__c='Retail',Segment_Focus__c='Advancement',Sales_Job_Function__c='Area Sales Manager',TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',CM_Visibility__c = 'Single Carrier',ProfileId = pid);
        insert usrRecord; 
        System.runAs(usrRecord){
            Test.startTest();
                Event queryEventRecord =  [SELECT Id FROM Event LIMIT 1]; // Query the event created in test methd
                ContentVersion contentVersionInsert = new ContentVersion(Title = 'Test', PathOnClient = 'Test.snote',VersionData = Blob.valueOf('Test Content Data'),IsMajorVersion = true);
                insert contentVersionInsert; // Insert the content version 
                ContentVersion verRecord = [Select id, ContentDocumentId,FileType from ContentVersion limit 1];
                System.assertEquals(verRecord.FileType,'SNOTE');
                
                // Insert the note record
                ContentDocumentLink conDoc = new ContentDocumentLink();
                conDoc.ContentDocumentId = verRecord.ContentDocumentId;
                conDoc.LinkedEntityId = queryEventRecord.id;
                conDoc.ShareType = 'V';
                conDoc.Visibility = 'AllUsers';
                insert conDoc;
                
                ContentDocumentLink conDocRecord = [Select id,LinkedEntityId,ShareType from ContentDocumentLink where LinkedEntityId =:queryEventRecord.id];
                System.assertEquals(conDocRecord.ShareType,'V');
            Test.stopTest();
        }
    }
}