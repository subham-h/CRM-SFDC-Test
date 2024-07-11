/**
 * Revision Ref Number  Date            Owner                            Description
 * -------- ----------  -----------     -------------------              -----------
 * 1.0     SFMC-7352    30-05-2023      amrutha.manjunath@maersk.com     Lead Process and Email Subscriber recordtype addition test <Capture Newsletter Subscribers as Sales Cloud LEADS>
 */




@isTest()
//Inserting lead with "Lead Process" record type
public class LeadCreationWithRecord_Test {

    private static testMethod void createLeadForLeadProcess() {

        // Get Lead Record Type Id
        Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Lead_Process').getRecordTypeId();

        System.debug('leadRecordTypeId::' + leadRecordTypeId);

        // Create Lead
        Lead leadRec = new Lead();
        leadRec.LastName = 'Angelina1';
        leadRec.Company = 'Google';
        leadRec.Email = 'angelina1@google.com';
        leadRec.Status = 'New';
        leadRec.Source_Brand__c = 'Maersk';
        leadRec.LeadSource = 'Cold Lead';
        leadRec.Phone = '+1-4675628682';
        leadRec.RecordTypeId = leadRecordTypeId;

        Test.startTest();
        Insert leadRec;
        Test.stopTest();

        System.debug('leadRec::' + leadRec);

        Lead leadRec1 = [SELECT Name, Phone, RecordTypeId FROM Lead WHERE RecordTypeId =: leadRecordTypeId];
        System.assertEquals(leadRec1.RecordTypeId, leadRecordTypeId, 'Lead not inserted.');

    }

    //Inserting lead with "Email Subscriber" record type
   private static testMethod void createLeadForEmailSubsciber() {

        // Get Lead Record Type Id
        Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Email_Subscriber').getRecordTypeId();

        System.debug('leadRecordTypeId::' + leadRecordTypeId);

        // Create Lead
        Lead leadRec = new Lead();
        leadRec.LastName = 'Jennifer1';
        leadRec.Company = 'Amazon';
        leadRec.Email = 'jennifer1@amazon.com';
        leadRec.Status = 'New';
        leadRec.Source_Brand__c = 'Maersk';
        leadRec.LeadSource = 'Cold Lead';
        leadRec.RecordTypeId = leadRecordTypeId;

        Test.startTest();
        Insert leadRec;
        Test.stopTest();

        System.debug('leadRec::' + leadRec);

        Lead leadRec1 = [SELECT Name, RecordTypeId FROM Lead WHERE RecordTypeId =: leadRecordTypeId];
        System.assertEquals(leadRec1.RecordTypeId, leadRecordTypeId, 'Lead not inserted.');

    }
}