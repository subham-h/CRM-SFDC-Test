/*
* Author   : Naveen
* Purpose  : Test class for Process the engagement tracker records on daily basis for create the lead records. 
*
* Version       Date            Owner                               Description
******************************************************************************************************************************************************
* v1.0      07-Jun-2024    naveen.k@maersk.com    SFMC-7701->Test class for  Lead has to be created for Enangement tracker records without Lead and contact .
------------------------------------------------------------------------------------------------------------------------------------------------------>
*/

@isTest
public class EngagementTrackMap_BatchTest {

    @testSetup
    static void setup() {
        // Create test data for Engagement_Tracker__c
        Id recordTypeId = SObjectType.Engagement_Tracker__c.getRecordTypeInfosByName().get('User Registration').getRecordTypeId();

        List<Engagement_Tracker__c> etList = new List<Engagement_Tracker__c>();
        for (Integer i = 0; i < 50; i++) {
            etList.add(new Engagement_Tracker__c(
                First_Name__c = 'TestFirstName' + i,
                Last_Name__c = 'TestLastName' + i,
                Email__c = 'test' + i + '@example.com',
                Marketing_Opt_In__c = true,
                Capture_Source__c = 'Test Source',
                Source_Brand__c = 'Maersk',
                Phone__c = '123456' + i,
                Email_Verified__c = true,
                Lead_Source__c = 'LinkedIn',
                CreatedDate = Date.valueOf(Datetime.now().addDays(-1).format('yyyy-MM-dd')),
                RecordTypeId = recordTypeId,
                Registration_Status__c = 'Account Email Verified'
            ));
        }

        insert etList;
    }

    @isTest
    static void testBatch() {
        // Create instance of the batch class
        EngagementTrackMap_Batch batch = new EngagementTrackMap_Batch();

        // Execute the batch class
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        // Verify that Leads are created
        Id leadRecordTypeId = SObjectType.Lead.getRecordTypeInfosByName().get('Email Subscriber').getRecordTypeId();
        List<Lead> leads = [SELECT Id, FirstName, LastName, Email, Company, Marketing_Opt_In__c, Capture_Source__c, Phone, MobilePhone, Email_Verified__c, Country_lk__c, Source_Brand__c, LeadSource, RecordTypeId FROM Lead WHERE RecordTypeId = :leadRecordTypeId];
        
        System.assertEquals(60, leads.size(), 'Expected 60 leads to be created');

        // Verify that Engagement Tracker records are updated
        List<Engagement_Tracker__c> etRecords = [SELECT Id, Lead__c, First_Name__c, Last_Name__c, Phone__c, Marketing_Opt_In__c FROM Engagement_Tracker__c WHERE Lead__c != NULL];

        System.assertEquals(60, etRecords.size(), 'Expected 60 Engagement Tracker records to be updated');
        
    }
}