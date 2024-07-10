/**
* Purpose : Test class for Consent Mgmt Utility class
*        
* Revision Ref Number  Date            Owner                      Description
* -------- ----------  -----------     -------------------        -----------
* 1.0      SFMC-7693   29-May-2024    naveen.k@maersk.com          Code created
*/

@isTest
public class CiamUserEventTest {
    @testSetup static void dataSetup() {
        
        User usrSysOwner = [SELECT Id, Name FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        List<DataUseLegalBasis> legalbasisList = new List<DataUseLegalBasis>();
        legalbasisList.add(new DataUseLegalBasis(name = 'Legitimate Interest'));
        legalbasisList.add(new DataUseLegalBasis(name = 'Consent'));
        Insert legalbasisList;
        
        List<DataUsePurpose> lstDataUsePurpose = new List<DataUsePurpose>();
        List<String> lstBrand = new List<String>{BrandUtilities.MAERSK, BrandUtilities.SEALAND};
            DataUsePurpose recDUP1 = new DataUsePurpose(Name='Marketing - ' + lstBrand[0]);
        DataUsePurpose recDUP2 = new DataUsePurpose(Name='Marketing - ' + lstBrand[1]);
        lstDataUsePurpose.add(new DataUsePurpose(name = 'Marketing', LegalBasisId = legalbasisList[1].Id, CanDataSubjectOptOut = true));
        lstDataUsePurpose.add(new DataUsePurpose(name = 'Customer Advisory', LegalBasisId = legalbasisList[0].Id, CanDataSubjectOptOut = true));
        
        lstDataUsePurpose.add(recDUP1);
        lstDataUsePurpose.add(recDUP2);
        
        insert lstDataUsePurpose;
        
        List<BusinessBrand> busBrandList = new List<BusinessBrand>();
        busBrandList.add(new BusinessBrand(Name = BrandUtilities.MAERSK));
        busBrandList.add(new BusinessBrand(Name = BrandUtilities.SEALAND));
        busBrandList.add(new BusinessBrand(Name = BrandUtilities.TWILL));
        busBrandList.add(new BusinessBrand(Name = BrandUtilities.HAMBURGSUD));
        busBrandList.add(new BusinessBrand(Name = BrandUtilities.ALIANCA));
        insert busBrandList;
        
        Lead recLead1 = new Lead(FirstName='Test', LastName='Lead2', Company='TestLead1', Email='testlead_cm2@test.com', Source_Brand__c=BrandUtilities.MAERSK, Marketing_Opt_In__c=true, Capture_Source__c='TestLead1_CS', Lead_Submission_Date__c = null, CreatedDate = Date.valueOf(Datetime.now().format('yyyy-MM-dd')), LeadSource = 'LinkedIn' );
        insert recLead1;
        
        Individual recInd = new Individual(FirstName='Test', LastName='Ind1');
        insert recInd;
        
        ContactPointEmail recCPE = new ContactPointEmail(EmailAddress = recLead1.Email, ParentId =recInd.Id );
        insert recCPE;
        
        EngagementChannelType recEng = new EngagementChannelType(Name='Email');
        insert recEng;
        
        List<CommSubscription> CommSubscription = new List<CommSubscription>();
        CommSubscription.add(new CommSubscription(Name = 'Regional market updates Email', DataUsePurposeId =recDUP1.Id ));
        CommSubscription.add(new CommSubscription(Name = 'New solutions, products and services Email',DataUsePurposeId =recDUP1.Id ));
        Insert CommSubscription;
        
        List<CommSubscriptionChannelType> CommSubscriptionChannelType = new List<CommSubscriptionChannelType>();
        CommSubscriptionChannelType.add(new CommSubscriptionChannelType(name = 'Regional market updates Email', CommunicationSubscriptionId = CommSubscription[0].Id, EngagementChannelTypeId = recEng.Id  ));
        CommSubscriptionChannelType.add(new CommSubscriptionChannelType(name = 'New solutions, products and services Email', CommunicationSubscriptionId = CommSubscription[1].Id, EngagementChannelTypeId = recEng.Id));
        Insert CommSubscriptionChannelType;
        
        
    }
    
      @isTest  
    static void testLeadIfExists() {
        // Create test data for lead
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'ystmanu+qqastsit21@gmail.com',
            Company = 'TestLead',
            Marketing_Opt_In__c = true,
            Capture_Source__c = 'Test Source',
            Source_Brand__c = 'MAERSK',
            Lead_Submission_Date__c = Date.valueOf(Datetime.now().format('yyyy-MM-dd')),
            CreatedDate = Date.valueOf(Datetime.now().format('yyyy-MM-dd')), LeadSource = 'LinkedIn'
        );
        
        test.startTest();
        insert testLead;
        

       
        Database.SaveResult results = EventBus.publish( new CIAM_User_Profile_Event__e(JSON_1__c= '{\"userId\":\"85e8c5c0-49d1-4673-87ba-ee067d1a9de3\",\"userName\":\"prespptest454325mn\",\"firstName\":\"neebe\",\"lastName\":\"pres\",\"emailAddress\":\"ystmanu+qqastsit21@gmail.com\",\"landLine\":\"44-123123123\",\"mobile\":\"44-1231231231\",\"country\":\"United Kingdom\",\"status\":\"active\",\"isNewsAndMarketingAccepted\":true,\"Campaign\":{\"urchinTrackingModuleTerm\":\"\",\"urchinTrackingModuleContent\":\"\",\"urchinTrackingModuleCampaign\":\"\",\"urchinTrackingModuleSource\":\"\",\"urchinTrackingModuleMedium\":\"\"},\"eventType\":\"ACCOUNT_DEREGISTERED\",\"registrationSource\":\"https://www.maersk.com\",\"timestamp\":\"2024-05-24 12:53:38\"}'));
        
        //Assert.isTrue(!etrackList.isEmpty());
        test.stopTest();
        List<Engagement_Tracker__c> etrackList=[Select Id,Lead__c from Engagement_Tracker__c];
        Assert.isTrue(!etrackList.isEmpty());
        // Perform assertions
        //System.assertEquals(cscToCheck.ConsentCapturedSource,leadToCheck.Capture_Source__c , 'ConsentCapturedSource should match test lead capturesource');
        //Assert.
    }
    
    @isTest  
    static void testContactIfExists() {
        // Create test data for contact
            Account clientAcc = TestBusinessHelper.createAccount('Client_Account', true);
            Contact contact = TestBusinessHelper.createContact(clientAcc, 'Customer_Contact', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
            
        
        test.startTest();

        Database.SaveResult results = EventBus.publish( new CIAM_User_Profile_Event__e(JSON_1__c= '{\"userId\":\"85e8c5c0-49d1-4673-87ba-ee067d1a9de3\",\"userName\":\"prespptest454325mn\",\"firstName\":\"neebe\",\"lastName\":\"pres\",\"emailAddress\":\"CustomerContactMaerskLine@test.com\",\"landLine\":\"44-123123123\",\"mobile\":\"44-1231231231\",\"country\":\"United Kingdom\",\"status\":\"active\",\"isNewsAndMarketingAccepted\":false,\"Campaign\":{\"urchinTrackingModuleTerm\":\"\",\"urchinTrackingModuleContent\":\"\",\"urchinTrackingModuleCampaign\":\"\",\"urchinTrackingModuleSource\":\"\",\"urchinTrackingModuleMedium\":\"\"},\"eventType\":\"ACCOUNT_REGISTERED\",\"registrationSource\":\"https://accounts-stage.maersk.com/ocean-maeu/auth/register\",\"timestamp\":\"2024-05-24 12:53:38\"}'));
        test.stopTest();
        // Perform assertions
        //System.assertEquals(cscToCheck.ConsentCapturedSource,leadToCheck.Capture_Source__c , 'ConsentCapturedSource should match test lead capturesource');
    }
    @isTest  
    static void testConsentIndvidNotIfExists() {
        // Create test data for contact
            Account clientAcc = TestBusinessHelper.createAccount('Client_Account', true);
            Contact contact = TestBusinessHelper.createContact(clientAcc, 'Customer_Contact', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
            system.System.debug('Email Id--->'+contact.Email);
        
        test.startTest();

        Database.SaveResult results = EventBus.publish( new CIAM_User_Profile_Event__e(JSON_1__c= '{\"userId\":\"90e8c0-49d1-4673-87a-ee067d1a9de3678\",\"userName\":\"prespptestNaven454325mn\",\"firstName\":\"neebe\",\"lastName\":\"pres\",\"emailAddress\":\"CustomerContactMaerskLine@test.com\",\"landLine\":\"44-123123123\",\"mobile\":\"44-1231231231\",\"country\":\"United Kingdom\",\"status\":\"active\",\"isNewsAndMarketingAccepted\":true,\"Campaign\":{\"urchinTrackingModuleTerm\":\"\",\"urchinTrackingModuleContent\":\"\",\"urchinTrackingModuleCampaign\":\"\",\"urchinTrackingModuleSource\":\"\",\"urchinTrackingModuleMedium\":\"\"},\"eventType\":\"ACCOUNT_DEREGISTERED\",\"registrationSource\":\"https://www.maersk.com\",\"timestamp\":\"2024-05-24 12:53:38\"}'));
        test.stopTest();
        // Perform assertions
        //System.assertEquals(cscToCheck.ConsentCapturedSource,leadToCheck.Capture_Source__c , 'ConsentCapturedSource should match test lead capturesource');
    }
    @isTest  
    static void testConsentIndvidIfExists() {
        // Create test data for contact
            Account clientAcc = TestBusinessHelper.createAccount('Client_Account', true);
            Contact contactObj = TestBusinessHelper.createContact(clientAcc, 'Customer_Contact', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
            system.System.debug('Email Id--->'+contactObj.Email);
            Map<Id,Contact> conWithoutIndividualMap=new Map<Id,Contact>();
            conWithoutIndividualMap.put(contactObj.id,contactObj);
            Map<Id,Individual> conIdIndividualMap=SoftRegistrationUtility.createIndividual(conWithoutIndividualMap.values());
            TriggerExecutionController.skipAllTriggers(true);
            contactObj.IndividualId=conIdIndividualMap.get(contactObj.Id).Id;
            Update contactObj;
            TriggerExecutionController.skipAllTriggers(false);
        
        test.startTest();

        Database.SaveResult results = EventBus.publish( new CIAM_User_Profile_Event__e(JSON_1__c= '{\"userId\":\"90e8c0-49d1-4673-87a-ee067d1a9de3678\",\"userName\":\"prespptestNaven454325mn\",\"firstName\":\"neebe\",\"lastName\":\"pres\",\"emailAddress\":\"CustomerContactMaerskLine@test.com\",\"landLine\":\"44-123123123\",\"mobile\":\"44-1231231231\",\"country\":\"United Kingdom\",\"status\":\"active\",\"isNewsAndMarketingAccepted\":true,\"Campaign\":{\"urchinTrackingModuleTerm\":\"\",\"urchinTrackingModuleContent\":\"\",\"urchinTrackingModuleCampaign\":\"\",\"urchinTrackingModuleSource\":\"\",\"urchinTrackingModuleMedium\":\"\"},\"eventType\":\"ACCOUNT_DEREGISTERED\",\"registrationSource\":\"https://www.maersk.com\",\"timestamp\":\"2024-05-24 12:53:38\"}'));
        test.stopTest();
        // Perform assertions
        //System.assertEquals(cscToCheck.ConsentCapturedSource,leadToCheck.Capture_Source__c , 'ConsentCapturedSource should match test lead capturesource');
    }

    @isTest  
    static void testContactInsertIfExists() {
        // Create test data for contact
        test.startTest();
        Database.SaveResult results = EventBus.publish( new CIAM_User_Profile_Event__e(JSON_1__c= '{\"userId\":\"90e8c0-49d1-4673-87a-ee067d1a9de3678\",\"userName\":\"prespptestNaven454325mn\",\"firstName\":\"neebe\",\"lastName\":\"pres\",\"emailAddress\":\"CustomerContactMaerskLine@test.com\",\"landLine\":\"44-123123123\",\"mobile\":\"44-1231231231\",\"country\":\"United Kingdom\",\"status\":\"active\",\"isNewsAndMarketingAccepted\":true,\"Campaign\":{\"urchinTrackingModuleTerm\":\"\",\"urchinTrackingModuleContent\":\"\",\"urchinTrackingModuleCampaign\":\"\",\"urchinTrackingModuleSource\":\"\",\"urchinTrackingModuleMedium\":\"\"},\"eventType\":\"ACCOUNT_DEREGISTERED\",\"registrationSource\":\"https://www.maersk.com\",\"timestamp\":\"2024-05-24 12:53:38\"}'));
        test.stopTest();
            
        
        
        Account clientAcc = TestBusinessHelper.createAccount('Client_Account', true);
        Contact contact = TestBusinessHelper.createContact(clientAcc, 'Customer_Contact', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
        
        // Perform assertions
        //System.assertEquals(cscToCheck.ConsentCapturedSource,leadToCheck.Capture_Source__c , 'ConsentCapturedSource should match test lead capturesource');
    }
    @isTest  
    static void testLeadInsertionExists() {
       
        
        
        test.startTest();
        // Create test data for lead
        Database.SaveResult results = EventBus.publish( new CIAM_User_Profile_Event__e(JSON_1__c= '{\"userId\":\"85e8c5c0-49d1-4673-87ba-ee067d1a9de3\",\"userName\":\"prespptest454325mn\",\"firstName\":\"neebe\",\"lastName\":\"pres\",\"emailAddress\":\"ystmanu+qqastsit21@gmail.com\",\"landLine\":\"44-123123123\",\"mobile\":\"44-1231231231\",\"country\":\"United Kingdom\",\"status\":\"active\",\"isNewsAndMarketingAccepted\":true,\"Campaign\":{\"urchinTrackingModuleTerm\":\"\",\"urchinTrackingModuleContent\":\"\",\"urchinTrackingModuleCampaign\":\"\",\"urchinTrackingModuleSource\":\"\",\"urchinTrackingModuleMedium\":\"\"},\"eventType\":\"ACCOUNT_DEREGISTERED\",\"registrationSource\":\"https://www.maersk.com\",\"timestamp\":\"2024-05-24 12:53:38\"}'));
       
        

       
        
        //Assert.isTrue(!etrackList.isEmpty());
        test.stopTest();
        List<Engagement_Tracker__c> etrackList=[Select Id,Lead__c from Engagement_Tracker__c];
        Assert.isTrue(!etrackList.isEmpty());
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'ystmanu+qqastsit21@gmail.com',
            Company = 'TestLead',
            Marketing_Opt_In__c = true,
            Capture_Source__c = 'Test Source',
            Source_Brand__c = 'MAERSK',
            Lead_Submission_Date__c = Date.valueOf(Datetime.now().format('yyyy-MM-dd')),
            CreatedDate = Date.valueOf(Datetime.now().format('yyyy-MM-dd')), LeadSource = 'LinkedIn'
        );
        insert testLead;
        // Perform assertions
        //System.assertEquals(cscToCheck.ConsentCapturedSource,leadToCheck.Capture_Source__c , 'ConsentCapturedSource should match test lead capturesource');
        //Assert.
    }

}