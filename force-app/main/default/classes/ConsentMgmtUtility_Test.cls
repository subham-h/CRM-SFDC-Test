/**
* Purpose : Test class for Consent Mgmt Utility class
*        
* Revision Ref Number  Date            Owner                      Description
* -------- ----------  -----------     -------------------        -----------
* 1.0      SFSE-5757   26-May-2021     nitin@maersk               Code created
* 2.0      SPI-100     08-Jun-2022     Ronnie@SF                  Removed brand hardcoding
* 3.0      CRM0000030  12-Sep-2022     Ronnie@SF                  Improved retrieval of recordtype info
* 4.0		SFSE-9375	22-Sep-2022	   Kiran@Maersk			      Contact Point Type Consent (CPTC) record Name format change
* 5.0      SFMC-7365   13-06-2023	   amrutha@maersk			  Existing code to work when Lead Source value is not equal to ‘Email Subscriber/Newsletter’
* 6.0      SFMC-7484   3-Nov-2023      amrutha@maersk.com         CPE & CSC record testcases included
*/

@isTest
public class ConsentMgmtUtility_Test {
    
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
        
        
        
        System.runAs(usrSysOwner){
            
            Lead recLead = new Lead(FirstName='Test', LastName='Lead1', Company='TestLead1', Email='testlead_cm1@test.com', Source_Brand__c=BrandUtilities.MAERSK, Marketing_Opt_In__c=true, Capture_Source__c='TestLead1_CS', LeadSource = 'LinkedIn');
            insert recLead;
            
            TriggerExecutionController.skipLeadTrigger(true);
            Lead recLeadAnother = new Lead(FirstName='Test', LastName='Lead1', Company='TestLead1', Email='testlead_cm1@test.com', Source_Brand__c=BrandUtilities.MAERSK, Marketing_Opt_In__c=true, Capture_Source__c='TestLead1a_CS', LeadSource = 'LinkedIn');
            insert recLeadAnother;
            
            TriggerExecutionController.skipLeadTrigger(false);
            Account ClientAccount = AccountDataHelper_Test.createClientAccount();
            TriggerExecutionController.skipContactTrigger(true);
            
            String strCntAnotherEmail = 'testlead_cm1@test.com';
            Contact recCntAnother =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MAERSKLINE,ClientAccount.Id,strCntAnotherEmail,usrSysOwner); 
            
            String strCntwithIndIdEmail = 'testindId_cm@test.com';
            Contact recCntwithIndId =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MAERSKLINE,ClientAccount.Id,strCntwithIndIdEmail,usrSysOwner); 
            recCntwithIndId.IndividualId = recInd.Id;
            
            update recCntwithIndId;
            TriggerExecutionController.skipContactTrigger(false);
            
        }
        
    }
    
    static void setRecursionFlags() {
        TriggerRecursionCounter.invokedFromRecUpdate = false;
        TriggerRecursionCounter.isEmailValidationOnLead = false;
    }
    
    @isTest
    static void testLeadwithSameEmail(){
        
        User usrSysOwner = [SELECT Id, Name FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        System.runAs(usrSysOwner){                      
            Lead leadDifferentEmail = new Lead(FirstName='Test', LastName='Lead2', LeadSource = 'LinkedIn',Company='TestLead2', Email='testlead_cm1@test.com', Source_Brand__c=BrandUtilities.MAERSK, Marketing_Opt_In__c=true, Capture_Source__c='TestLead2_CS');
            test.startTest();            
            insert leadDifferentEmail;
            consentPointCntrl.getConsent(leadDifferentEmail.Id);
            test.stopTest();
            
            Lead leadToCheck = [SELECT Id, IndividualId, Capture_Source__c FROM Lead WHERE Id =: leadDifferentEmail.Id];
            ContactPointTypeConsent cptcToCheck = [SELECT Id, Name, CaptureSource FROM ContactPointTypeConsent WHERE PartyId=:leadToCheck.IndividualId];
            System.assert(cptcToCheck.CaptureSource == leadToCheck.Capture_Source__c, 'Lead same Email, CPTC Capture_Source__c not updated');
            // Check if ContactPointEmail EmailAddress matches Lead's Email
            ContactPointEmail cpeToCheck = [SELECT EmailAddress FROM ContactPointEmail WHERE ParentId = :leadToCheck.IndividualId];
            System.assert(cpeToCheck.EmailAddress == leadDifferentEmail.Email, 'ContactPointEmail EmailAddress does not match Lead Email');
            
        }
    }
    
    
    @isTest
    static void testLeadwithLeadsource(){
        User usrSysOwner = [SELECT Id, Name FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        System.runAs(usrSysOwner){ 
            Lead leadSource = new Lead(FirstName='Test', LastName='Lead8', Company='TestLead8', Email='testlead_cm8@test.com', Source_Brand__c=BrandUtilities.MAERSK, Marketing_Opt_In__c=False, Capture_Source__c='TestLead8_CS',Leadsource = 'Email Subscriber/Newsletter' );
            test.startTest();
            insert leadSource;
            test.stopTest();
            
            Lead leadToCheck = [SELECT Id, IndividualId FROM Lead WHERE Id =: leadSource.Id];
            System.assert(leadToCheck.IndividualId == null, 'Lead with Leadsource, IndividualId not populated');
        }
    }
    
    @isTest
    static void testLeadwithSameEmailNotOptIn(){
        User usrSysOwner = [SELECT Id, Name FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        System.runAs(usrSysOwner){ 
            Lead leadDifferentEmail = new Lead(FirstName='Test', LastName='Lead3', Company='TestLead3', Email='testlead_cm1@test.com', Source_Brand__c=BrandUtilities.MAERSK, Marketing_Opt_In__c=false, Capture_Source__c='TestLead3_CS', LeadSource = 'LinkedIn');
            test.startTest();
            insert leadDifferentEmail;
            test.stopTest();
            
            Lead leadToCheck = [SELECT Id, IndividualId FROM Lead WHERE Id =: leadDifferentEmail.Id];
            System.assert(leadToCheck.IndividualId != null, 'Lead same Email Not Opt In, IndividualId not populated');
        }
    }
    
    @isTest
    static void testLeadwithSameEmailDifferntBrand(){
        User usrSysOwner = [SELECT Id, Name FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        System.runAs(usrSysOwner){ 
            Lead leadDifferentEmail = new Lead(FirstName='Test', LastName='Lead4', Company='TestLead4', Email='testlead_cm2@test.com', Source_Brand__c='Maersk Go', Marketing_Opt_In__c=true, Capture_Source__c='TestLead4_CS', LeadSource = 'LinkedIn');
            test.startTest();
            insert leadDifferentEmail;
            test.stopTest();
            
            Lead leadToCheck = [SELECT Id, Name, Email, IndividualId, Source_Brand__c FROM Lead WHERE Name = 'Test Lead2'];
            ContactPointTypeConsent cptcToCheck = [SELECT Id, Name FROM ContactPointTypeConsent WHERE PartyId=:leadToCheck.IndividualId AND Name=: leadToCheck.Name +'-'+ Datetime.now().format('yyyy-MM-dd') +'-' +leadToCheck.Email AND BusinessBrand.Name =: BrandUtilities.Maersk ];
            System.assert(cptcToCheck.Name ==leadToCheck.Name +'-'+ Datetime.now().format('yyyy-MM-dd') +'-' +leadToCheck.Email, 'Lead Different Email, CPTC record not created');
            
        }
    }  
    
    
    @isTest
    static void testLeadwithDifferentEmail(){
        User usrSysOwner = [SELECT Id, Name FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        System.runAs(usrSysOwner){ 
            Lead leadDifferentEmail = new Lead(FirstName='Test', LastName='Lead5', Company='TestLead5', Email='testlead5_cm@test.com', Source_Brand__c=BrandUtilities.MAERSK, Marketing_Opt_In__c=true, Capture_Source__c='TestLead5_CS', LeadSource = 'LinkedIn');
            test.startTest();
            insert leadDifferentEmail;
            test.stopTest();
            
            Lead leadToCheck = [SELECT Id, Name, Email, IndividualId, Source_Brand__c FROM Lead WHERE Id =: leadDifferentEmail.Id];
            ContactPointTypeConsent cptcToCheck = [SELECT Id, Name FROM ContactPointTypeConsent WHERE PartyId=:leadToCheck.IndividualId];
            ContactPointEmail cpeToCheck = [SELECT Id, EmailAddress FROM ContactPointEmail WHERE ParentId=:leadToCheck.IndividualId and EmailAddress = :leadToCheck.Email];
            System.assert(leadToCheck.IndividualId != null, 'Lead Different Email, Indvidual Id not populated');
            System.assert(cptcToCheck.Name == leadToCheck.Name +'-'+ Datetime.now().format('yyyy-MM-dd') +'-' +leadToCheck.Email , 'Lead Different Email, CPTC record not found');
            System.assert(cpeToCheck.EmailAddress == leadToCheck.Email , 'Lead Different Email, CPE record not found');
        }
    }
    
    @isTest
    static void testLeadWhereIndIDExistForContact(){
        User usrSysOwner = [SELECT Id, Name FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        System.runAs(usrSysOwner){ 
            Lead leadIndIdExist = new Lead(FirstName='Test', LastName='Lead6', Company='TestLead6', Email='testindId_cm@test.com', Source_Brand__c=BrandUtilities.MAERSK, Marketing_Opt_In__c=false, Capture_Source__c='TestLead6_CS', LeadSource = 'LinkedIn');
            test.startTest();
            insert leadIndIdExist;
            test.stopTest();
            
            Lead leadToCheck = [SELECT Id, IndividualId, Source_Brand__c FROM Lead WHERE Id =: leadIndIdExist.Id];
            System.assert(leadToCheck.IndividualId != null, 'Lead where Ind Id exists for Contact, Indvidual Id not populated');
            
        }
    }
    
    @isTest
    static void testLeadWhereIndIDExistForContactPopulates(){
        User usrSysOwner = [SELECT Id, Name FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        System.runAs(usrSysOwner){ 
            Lead leadIndIdExist = new Lead(FirstName='Test', LastName='Lead6', Company='TestLead6', Email='testindId_cm@test.com', Source_Brand__c=BrandUtilities.MAERSK, Marketing_Opt_In__c=True, Capture_Source__c='TestLead6_CS', LeadSource = 'LinkedIn');
            test.startTest();
            insert leadIndIdExist;
            consentPointCntrl.getConsent(leadIndIdExist.Id);
            test.stopTest();
            
            Lead leadToCheck = [SELECT Id,Capture_Source__c, IndividualId, Source_Brand__c FROM Lead WHERE Id =: leadIndIdExist.Id];
            System.assert(leadToCheck.IndividualId != null, 'Lead where Ind Id exists for Contact, Indvidual Id populated');
        }
    }
    
    @isTest
    static void testContactWhereIndIDExistForLead(){
        User usrSysOwner = [SELECT Id, Name FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        System.runAs(usrSysOwner){ 
            Account rAcc = [SELECT Id, Name FROM Account limit 1];
            
            Id cntRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer_Contact').getRecordTypeId();
            Lead recLead = new Lead(FirstName='Test', LastName='Lead7', Company='TestLead7', Email='testlead_cm7@test.com', Source_Brand__c=BrandUtilities.MAERSK, Marketing_Opt_In__c=true, Capture_Source__c='TestLead7_CS', LeadSource = 'LinkedIn');
            insert recLead;
            
            String strMailingCity = BDAGeographyData_Test.citySterling.Name;
            Contact recCnt = new Contact(FirstName='Test', LastName='Contact2', Email='testlead_cm7@test.com', AccountId=rAcc.Id, Liner_Brands__c=BrandUtilities.MAERSKLINE, MailingCity=strMailingCity,RecordTypeId=cntRTId);
            
            test.startTest();
            insert recCnt;
            consentPointCntrl.getConsent(recCnt.Id);
            test.stopTest();
            
            Contact cntToCheck = [SELECT Id, IndividualId FROM Contact WHERE Id =: recCnt.Id];
            System.assert(cntToCheck.IndividualId != null, 'Contact where Ind Id exists for Lead, Indvidual Id not populated');
        }
    }
    
    @isTest
    static void testContactWhereIndIDExistForLeadwithCSC(){
        User usrSysOwner = [SELECT Id, Name FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        System.runAs(usrSysOwner) {
            Account rAcc = [SELECT Id, Name FROM Account LIMIT 1];
            Id cntRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer_Contact').getRecordTypeId();
            Lead recLead = new Lead(FirstName = 'Test', LastName = 'Lead9', Company = 'TestLead9', Email = 'testlead_cm9@test.com', Source_Brand__c = BrandUtilities.MAERSK, Marketing_Opt_In__c = true, Capture_Source__c = 'TestLead9_CS', LeadSource = 'LinkedIn');
            insert recLead;
            String strMailingCity = BDAGeographyData_Test.citySterling.Name;
            Contact recCnt = new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'testlead_cm9@test.com', AccountId = rAcc.Id, Liner_Brands__c = BrandUtilities.MAERSKLINE, MailingCity = strMailingCity, RecordTypeId = cntRTId);
            test.startTest();
            insert recCnt;
            consentPointCntrl.getConsent(recCnt.Id);
            test.stopTest();
            Contact cntToCheck = [SELECT Id, IndividualId FROM Contact WHERE Id = :recCnt.Id];
            
        }
    }
    @isTest
    static void testCpeCreation(){
        
        Lead recLeadAnother = new Lead(FirstName='TestCPS', LastName='Lead1a', Company='TestLead1a', Email='testlead_CPS@test.com', Source_Brand__c=BrandUtilities.MAERSK, Marketing_Opt_In__c=true, Capture_Source__c='TestLead1a_CS', LeadSource = 'LinkedIn');
        insert recLeadAnother;
        
        Lead leadCPS = [select id, name, IndividualId from Lead WHERE FirstName = 'TestCPS'];
        System.assertEquals(leadCPS.IndividualId != null, true, 'Individual Id should not equals to null');
        Id partyId = leadCPS.IndividualId;
        
        List<ContactPointTypeConsent> lstCPTCtoInsert = [select id from ContactPointTypeConsent where PartyId =:partyId ];
        System.assertEquals(lstCPTCtoInsert.size() > 0, true, 'CPTC record must be createds');
        Id cptcId = lstCPTCtoInsert[0].Id;      
        
        List<ContactPointEmail> lstCPEtoInsert = [select id from ContactPointEmail where ParentId =:partyId ];
        System.assertEquals(lstCPEtoInsert.size() > 0, true, 'CPE record must be createds');
        Id cpeId = lstCPEtoInsert[0].Id; 
        
    }
    
    @isTest
    static void testBulkLeadInserts() {
        // Test bulk inserts for Lead records
        List<Lead> leadList = new List<Lead>();
        for (Integer i = 0; i < 50; i++) {
            leadList.add(new Lead(FirstName = 'BulkTest',LastName = 'Lead' + i,Email = 'bulktestlead' + i + '@test.com',Company = 'TestLead2',Source_Brand__c = BrandUtilities.MAERSK,Marketing_Opt_In__c = true,Capture_Source__c = 'BulkTest_CS', LeadSource = 'LinkedIn'));
        }
        
        test.startTest();
        insert leadList;
        
        // Read IndividualId for each inserted lead
        List<Id> leadIndividualIds = new List<Id>();
        for (Lead lead : leadList) {
            leadIndividualIds.add(lead.IndividualId);
        }   
        
        // Read IndividualId from inserted leads using SOQL
        List<Lead> insertedLeads = [SELECT Id, Email,  IndividualId FROM Lead WHERE Capture_Source__c = 'BulkTest_CS'];
        
        // Extract Email and IndividualId values from insertedLeads
        List<String> insertedEmails = new List<String>();
        List<Id> insertedIndividualIds = new List<Id>();
        for (Lead lead : insertedLeads) {
            insertedEmails.add(lead.Email);
            insertedIndividualIds.add(lead.IndividualId);
        }
        
        List<ContactPointEmail> cpeList = [SELECT Id FROM ContactPointEmail WHERE ParentId IN :insertedIndividualIds AND EmailAddress IN :insertedEmails];
        
        System.assertEquals(50, insertedLeads.size(), 'Unexpected number of inserted leads');
        System.assertEquals(50, cpeList.size(), 'Unexpected number of CPE inserted');
        test.stopTest();
    }
    
    @isTest
    static void testLeadOptOutRevokesConsent() {
        User usrSysOwner = [SELECT Id, Name FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        System.runAs(usrSysOwner) {
            Lead leadOptOut = new Lead(FirstName = 'Test',LastName = 'LeadOptOut',Company = 'TestLeadOptOut',Email = 'testlead_optout@test.com',Source_Brand__c = BrandUtilities.MAERSK,Marketing_Opt_In__c = true,Capture_Source__c = 'TestLeadOptOut_CS', LeadSource = 'LinkedIn');
            insert leadOptOut;
            test.startTest();
            leadOptOut.Marketing_Opt_In__c = false;
            update leadOptOut;
            test.stopTest();
            
            List<ContactPointTypeConsent> cptcList = [SELECT Id FROM ContactPointTypeConsent WHERE PartyId = :leadOptOut.IndividualId];
            System.assertEquals(0, cptcList.size(), 'Consent not revoked for Opt-Out lead.');
            
            List<ContactPointEmail> cpeList = [select Id from ContactPointEmail where ParentId =:leadOptOut.IndividualId and EmailAddress='testlead_optout@test.com'];
            System.assertEquals(0, cpeList.size(), 'Consent not revoked for Opt-Out lead.');
            
        }
    }
    @isTest
    static void testCscCreationIfExists() {
        // Create test data
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'testlead_cm3@test.com',
            Company = 'TestLead',
            Marketing_Opt_In__c = true,
            Capture_Source__c = 'Test Source',
            Source_Brand__c = 'MAERSK Go',
            Lead_Submission_Date__c = Date.valueOf(Datetime.now().format('yyyy-MM-dd')),
            CreatedDate = Date.valueOf(Datetime.now().format('yyyy-MM-dd')), LeadSource = 'LinkedIn'
        );
        
        test.startTest();
        insert testLead;
        Lead leadToCheck = [SELECT Id,Capture_Source__c, IndividualId, Source_Brand__c FROM Lead WHERE Email ='testlead_cm2@test.com' ];
        Id partyId = leadToCheck.IndividualId;
        ContactPointEmail testCPE = [SELECT Id FROM ContactPointEmail WHERE ParentId=:leadToCheck.IndividualId];
        List<DataUseLegalBasis> legalbasisList = new List<DataUseLegalBasis>();
        legalbasisList.add(new DataUseLegalBasis(name = 'Legitimate Interest'));
        legalbasisList.add(new DataUseLegalBasis(name = 'Consent'));
        Insert legalbasisList;
        
        List<DataUsePurpose> lstDataUsePurpose = new List<DataUsePurpose>();
        List<String> lstBrand = new List<String>{BrandUtilities.MAERSK};
            DataUsePurpose recDUP1 = new DataUsePurpose(Name='Marketing - ' + lstBrand[0]);
        lstDataUsePurpose.add(new DataUsePurpose(name = 'Marketing', LegalBasisId = legalbasisList[1].Id, CanDataSubjectOptOut = true));
        lstDataUsePurpose.add(recDUP1);
        
        BusinessBrand busBrandList = new BusinessBrand(Name = BrandUtilities.MAERSK );
        insert busBrandList;
        
        EngagementChannelType recEng = new EngagementChannelType(Name='Email');
        insert recEng;
        CommSubscription comsub = new CommSubscription(Name = 'New solutions, products and services Email', DataUsePurposeId =recDUP1.Id);
        insert comsub;
        Date EffectiveFromDate = null;
        Date ConsentCapturedDateTime = null;
        if(testLead.Lead_Submission_Date__c !=null) {	 
            EffectiveFromDate = Date.valueOf(testLead.Lead_Submission_Date__c.format('yyyy-MM-dd'));  
            ConsentCapturedDateTime = Date.valueOf(testLead.Lead_Submission_Date__c); 
        }else {	 
            EffectiveFromDate = Date.valueOf(testLead.CreatedDate.format('yyyy-MM-dd')); 
            ConsentCapturedDateTime =  Date.valueOf(testLead.CreatedDate);
        }   
        CommSubscriptionChannelType testCSCT = new CommSubscriptionChannelType(name = 'New solutions, products and services Email', CommunicationSubscriptionId = comsub.Id,EngagementChannelTypeId = recEng.Id);
        insert testCSCT;
        
        CommSubscriptionConsent cscToCheck = new CommSubscriptionConsent(Name = 'testlead_cm2@test.com-New solutions, products and services',ConsentCapturedDateTime = ConsentCapturedDateTime,ConsentCapturedSource = 'TestLead1_CS',EffectiveFromDate = EffectiveFromDate,BusinessBrandId = busBrandList.Id,Privacy_Consent_Status__c = 'OptIn',ContactPointId = testCPE.Id,CommSubscriptionChannelTypeId = testCSCT.Id);
        insert cscToCheck;
        
        test.stopTest();
        // Perform assertions
        System.assertEquals(cscToCheck.ConsentCapturedSource,leadToCheck.Capture_Source__c , 'ConsentCapturedSource should match test lead capturesource');
        
    }
    
    @isTest
    static void testCpeCscDeleteandCreate() {
        
         Test.startTest();
        Lead leadSameEmail = new Lead(FirstName = 'TestCPE',LastName = 'duplead',Company = 'TestLead4',Email = 'testleaddel_cm2@test.com',Source_Brand__c = BrandUtilities.MAERSK,Marketing_Opt_In__c = true,Capture_Source__c = 'Test', LeadSource = 'LinkedIn');
        insert leadSameEmail;
        
        Lead leadCPS = [select id, name, IndividualId from Lead WHERE FirstName = 'TestCPE'];
        System.assertEquals(leadCPS.IndividualId != null, true, 'Individual Id should not equals to null');
        Id partyId = leadCPS.IndividualId;
        
        List<ContactPointEmail> cpeToCheck = [SELECT Id FROM ContactPointEmail WHERE ParentId = :partyId AND EmailAddress = :leadSameEmail.Email]; 
        System.assertEquals(1, cpeToCheck.size(), 'CPE is Created.');
        
        List<CommSubscriptionConsent> cscToCheck = [SELECT Id FROM CommSubscriptionConsent WHERE ContactPointId = :cpeToCheck[0].Id];
        System.assertEquals(2, cscToCheck.size(), 'CSC is Created.');
        
        // Delete CSC & CPE
        delete cscToCheck;
        delete cpeToCheck;
        Test.stopTest();
        List<ContactPointEmail> cpedeleted = [SELECT Id FROM ContactPointEmail WHERE EmailAddress = :leadSameEmail.Email and ParentId =:leadSameEmail.IndividualId];
        System.assertEquals(0, cpedeleted.size(), 'CPE is deleted.');
        
        Lead SameEmail = new Lead(FirstName = 'Testdup',LastName = 'lead',Company = 'TestLead4',Email = 'testleaddel_cm2@test.com',Source_Brand__c = BrandUtilities.MAERSK,Marketing_Opt_In__c = true,Capture_Source__c = 'Test', LeadSource = 'LinkedIn');
        setRecursionFlags();
        insert SameEmail;
        
        Lead leadCPS1 = [select id, name, IndividualId from Lead WHERE FirstName = 'Testdup'];
        System.assertEquals(leadCPS1.IndividualId != null, true, 'Individual Id should not equals to null');
        Id partyId1 = leadCPS1.IndividualId;
        
        List<ContactPointEmail> cpeCreateCheck = [SELECT Id FROM ContactPointEmail WHERE ParentId = :partyId1 AND EmailAddress = :SameEmail.Email];
        System.assertEquals(1, cpeCreateCheck.size(), 'CPE is Created.');
        
        List<CommSubscriptionConsent> cscCreateCheck = [SELECT Id FROM CommSubscriptionConsent WHERE ContactPointId = :cpeCreateCheck[0].Id];
        System.assertEquals(2, cscCreateCheck.size(), 'CSC is Created.');
        
        
        
    }
    
    
}