/**
* Purpose : Test class for LeadMELUpdator class
*        
* Revision Ref Number  Date            Owner                      Description
* -------- ----------  -----------     -------------------        -----------
* 1.0      SFMC-7512   20-Fev-2024     amrutha@maersk             Code created for Lead Movement Automation NEW Stage to MEL Stage
*/


@isTest
public class LeadMELUpdator_Test {
    
    // Test data setup method
    @testSetup static void dataSetup() {
        
        // Retrieve system owner user
        User usrSysOwner = [SELECT Id, Name FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        
        // Create DataUseLegalBasis records
        List<DataUseLegalBasis> legalbasisList = new List<DataUseLegalBasis>();
        legalbasisList.add(new DataUseLegalBasis(name = 'Legitimate Interest'));
        legalbasisList.add(new DataUseLegalBasis(name = 'Consent'));
        Insert legalbasisList;
        
        // Create DataUsePurpose and BusinessBrand records
        List<DataUsePurpose> lstDataUsePurpose = new List<DataUsePurpose>();
        List<String> lstBrand = new List<String>{BrandUtilities.MAERSK, BrandUtilities.SEALAND};
            DataUsePurpose recDUP1 = new DataUsePurpose(Name='Marketing - ' + lstBrand[0]);
        DataUsePurpose recDUP2 = new DataUsePurpose(Name='Marketing - ' + lstBrand[1]);
        lstDataUsePurpose.add(new DataUsePurpose(name = 'Marketing', LegalBasisId = legalbasisList[1].Id, CanDataSubjectOptOut = true));
        lstDataUsePurpose.add(new DataUsePurpose(name = 'Customer Advisory', LegalBasisId = legalbasisList[0].Id, CanDataSubjectOptOut = true));
        
        lstDataUsePurpose.add(recDUP1);
        lstDataUsePurpose.add(recDUP2);
        
        insert lstDataUsePurpose;
        
        // Create BusinessBrand records
        List<BusinessBrand> busBrandList = new List<BusinessBrand>();
        busBrandList.add(new BusinessBrand(Name = BrandUtilities.MAERSK));
        busBrandList.add(new BusinessBrand(Name = BrandUtilities.SEALAND));
        busBrandList.add(new BusinessBrand(Name = BrandUtilities.TWILL));
        busBrandList.add(new BusinessBrand(Name = BrandUtilities.HAMBURGSUD));
        busBrandList.add(new BusinessBrand(Name = BrandUtilities.ALIANCA));
        insert busBrandList;
        
        // Create Individual record
        Individual recInd = new Individual(FirstName='Test', LastName='Ind1');
        insert recInd;
        
        //Create Country
        Geography__c geography = TestBusinessHelper.createGeography('Japan', 'Country', null, true);
        
        // Run test setup as system owner
        System.runAs(usrSysOwner){
            
            // Create Lead records with and without skipping triggers
            Lead recLead = new Lead(FirstName='Test', LastName='Lead1', Company='TestLead1',Country_lk__c = geography.id, Email='testlead_cm1@test.com', Source_Brand__c=BrandUtilities.MAERSK,Marketing_Opt_In__c=true, Capture_Source__c='TestLead1_CS', LeadSource = 'LinkedIn');
            insert recLead;
            
            Campaign recCampaign = new Campaign (Name = 'testCamp', Campaign_Category__c = 'Marketing', Liner_Brand__c = 'Maersk Line', Region__c = 'Africa Region', Description ='test', StartDate = Date.valueOf(Datetime.now().format('yyyy-MM-dd')), Target_Vertical__c = 'Lifestyle', Target_Segment__c = 'Ease', BudgetedCost = 89, IsActive = True);
            insert recCampaign;
            
            CampaignMember lCampaignMember = new CampaignMember(CampaignId=recCampaign.Id, LeadId = recLead.Id,Status='Sent');
            insert lCampaignMember;
            
            TriggerExecutionController.skipLeadTrigger(true);
            Lead recLeadAnother = new Lead(FirstName='Test', LastName='Lead1', Company='TestLead1', Email='testlead_cm1@test.com', Source_Brand__c=BrandUtilities.MAERSK, Marketing_Opt_In__c=true, Capture_Source__c='TestLead1a_CS', LeadSource = 'LinkedIn');
            insert recLeadAnother;
            
            TriggerExecutionController.skipLeadTrigger(false);
            Account ClientAccount = AccountDataHelper_Test.createClientAccount();
            TriggerExecutionController.skipContactTrigger(true);
            
            // Create Contact records with and without IndividualId
            String strCntAnotherEmail = 'testlead_cm1@test.com';
            Contact recCntAnother =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MAERSKLINE,ClientAccount.Id,strCntAnotherEmail,usrSysOwner); 
            
            String strCntwithIndIdEmail = 'testindId_cm@test.com';
            Contact recCntwithIndId =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MAERSKLINE,ClientAccount.Id,strCntwithIndIdEmail,usrSysOwner); 
            recCntwithIndId.IndividualId = recInd.Id;
            
            update recCntwithIndId;
            TriggerExecutionController.skipContactTrigger(false);
            
        }
        
    }
    
    
   
            
 @isTest
    static void testLeadwithcampaign(){
        User usrSysOwner = [SELECT Id, Name FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        System.runAs(usrSysOwner){ 
            Geography__c geography = TestBusinessHelper.createGeography('Japan', 'Country', null, true);
            Lead lead1 = new Lead(FirstName='Test', LastName='Lead1', Company='TestLead1',Country_lk__c = geography.id,  Email='testlead_cm1@test.com', Source_Brand__c=BrandUtilities.MAERSK, Marketing_Opt_In__c=False, Capture_Source__c='TestLead1_CS', LeadSource = 'LinkedIn');
            test.startTest();
            insert lead1;
            test.stopTest();
            
            Lead leadToCheck = [SELECT Id, IndividualId FROM Lead WHERE Id =: lead1.Id];
            System.assert(leadToCheck.IndividualId != null, 'Lead with Leadsource, IndividualId is populated');
            
            Campaign recCampaign = new Campaign (Name = 'testCamp1', Campaign_Category__c = 'Marketing', Liner_Brand__c = 'Maersk Line', Region__c = 'Africa Region', Description ='test', StartDate = Date.valueOf(Datetime.now().format('yyyy-MM-dd')), Target_Vertical__c = 'Lifestyle', Target_Segment__c = 'Ease', BudgetedCost = 89, IsActive = True);
            insert recCampaign;
            
            CampaignMember lCampaignMember = new CampaignMember(CampaignId=recCampaign.Id, LeadId = Lead1.Id,Status='Sent');
            insert lCampaignMember;
            
                        
        }
    }
    
 @isTest
    static void testBulkLeadInserts() {
        
        Campaign recCampaign = new Campaign (Name = 'testCamp1', Campaign_Category__c = 'Marketing', Liner_Brand__c = 'Maersk Line', Region__c = 'Africa Region', Description ='test', StartDate = Date.valueOf(Datetime.now().format('yyyy-MM-dd')), Target_Vertical__c = 'Lifestyle', Target_Segment__c = 'Ease', BudgetedCost = 89, IsActive = True);
            insert recCampaign;
        Geography__c geography = TestBusinessHelper.createGeography('Japan', 'Country', null, true);
        // Test bulk inserts for Lead records
        List<Lead> leadList = new List<Lead>();
        for (Integer i = 0; i < 50; i++) {
            leadList.add(new Lead(FirstName = 'BulkTest',LastName = 'Lead' + i,Email = 'bulktestlead' + i + '@test.com',Country_lk__c = geography.id, Company = 'TestLead2',Source_Brand__c = BrandUtilities.MAERSK,LeadSource = 'LinkedIn', Marketing_Opt_In__c = true,Capture_Source__c = 'BulkTest_CS', Primary_Campaign__c = recCampaign.Id));
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
        
             
        System.assertEquals(50, insertedLeads.size(), 'Unexpected number of inserted leads');
        test.stopTest();
   

            }
    
    @isTest
    static void testLeadwithmandatoryfields(){
        User usrSysOwner = [SELECT Id, Name FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        System.runAs(usrSysOwner){ 
            Geography__c geography = TestBusinessHelper.createGeography('Japan', 'Country', null, true);
        
            Lead lead1 = new Lead(LastName='Lead1', Company='TestLead1', Email='testlead_cm1@test.com',Country_lk__c = geography.id, Source_Brand__c=BrandUtilities.MAERSK, Marketing_Opt_In__c=True, Capture_Source__c='TestLead1_CS', Maersk_Marketing_Consent__c = False, LeadSource = 'LinkedIn');
            test.startTest();
            insert lead1;
            test.stopTest();
                       
            Campaign recCampaign = new Campaign (Name = 'testCamp1', Campaign_Category__c = 'Marketing', Liner_Brand__c = 'Maersk Line', Region__c = 'Africa Region', Description ='test', StartDate = Date.valueOf(Datetime.now().format('yyyy-MM-dd')), Target_Vertical__c = 'Lifestyle', Target_Segment__c = 'Ease', BudgetedCost = 89, IsActive = True);
            insert recCampaign;
            
            CampaignMember lCampaignMember = new CampaignMember(CampaignId=recCampaign.Id, LeadId = Lead1.Id,Status='Sent');
            insert lCampaignMember;
            
            
            Lead leadToCheck = [SELECT Id,IndividualId,Maersk_Marketing_Consent__c, FirstName,LastName,Company,Email,Country_lk__c,LeadSource,Status FROM Lead WHERE Id =: lead1.Id];
            leadToCheck.FirstName = 'Test';
            leadToCheck.LeadSource ='Content Syndication';
            update leadToCheck;
                 
        }
    }
    
    @isTest
    static void testLeadwithoutIndWithMarkCnst(){
        User usrSysOwner = [SELECT Id, Name FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        System.runAs(usrSysOwner){ 
            Geography__c geography = TestBusinessHelper.createGeography('Japan', 'Country', null, true);
            Lead leadSource = new Lead(FirstName='Test', LastName='Lead3', Country_lk__c = geography.id,Company='TestLead3', Email='testlead_cm3@test.com', Source_Brand__c=BrandUtilities.MAERSK, Marketing_Opt_In__c=False, Capture_Source__c='TestLead8_CS',Maersk_Marketing_Consent__c = True, LeadSource='LinkedIn' );
            test.startTest();
            insert leadSource;
            test.stopTest();
            
            Lead leadToCheck = [SELECT Id, IndividualId FROM Lead WHERE Id =: leadSource.Id];
            System.assert(leadToCheck.IndividualId == null, 'Lead with Leadsource, IndividualId not populated');
        }
    }
    
    
    @isTest
    static void testLeadwithCPTCOptout(){
        
        User usrSysOwner = [SELECT Id, Name FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        System.runAs(usrSysOwner){      
            Geography__c geography = TestBusinessHelper.createGeography('Japan', 'Country', null, true);
            Lead leadEmail = new Lead(FirstName='Test', LastName='Lead4', Company='TestLead4',Country_lk__c = geography.id, Email='testlead_cm4@test.com', Source_Brand__c=BrandUtilities.MAERSK, Marketing_Opt_In__c=true, Capture_Source__c='TestLead2_CS', Maersk_Marketing_Consent__c = True, LeadSource = 'LinkedIn');
            test.startTest();            
            insert leadEmail;
            consentPointCntrl.getConsent(leadEmail.Id);
            test.stopTest();
            
            Lead leadToCheck = [SELECT Id, IndividualId, Capture_Source__c FROM Lead WHERE Id =: leadEmail.Id];
            ContactPointTypeConsent cptcToCheck = [SELECT Id, Name, CaptureSource FROM ContactPointTypeConsent WHERE PartyId=:leadToCheck.IndividualId];
            cptcToCheck.PrivacyConsentStatus ='OptOut';
            update cptcToCheck;
            
        }
    }
    
    @isTest
    static void testCPTCwithDiffDUP(){
        
        User usrSysOwner = [SELECT Id, Name FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        System.runAs(usrSysOwner){ 
             Campaign recCampaign = new Campaign (Name = 'testCamp1', Campaign_Category__c = 'Marketing', Liner_Brand__c = 'Maersk Line', Region__c = 'Africa Region', Description ='test', StartDate = Date.valueOf(Datetime.now().format('yyyy-MM-dd')), Target_Vertical__c = 'Lifestyle', Target_Segment__c = 'Ease', BudgetedCost = 89, IsActive = True);
            insert recCampaign;
            Lead leadEmail = new Lead(FirstName='Test', LastName='Lead4', Company='TestLead4', Email='testlead_cm4@test.com', Source_Brand__c=BrandUtilities.MAERSK, Marketing_Opt_In__c=true, Capture_Source__c='TestLead2_CS',LeadSource = 'LinkedIn', Maersk_Marketing_Consent__c = True, Primary_Campaign__c = recCampaign.Id);
            test.startTest();            
            insert leadEmail;
            consentPointCntrl.getConsent(leadEmail.Id);
            
            
            Lead leadToCheck = [SELECT Id, IndividualId, Capture_Source__c FROM Lead WHERE Id =: leadEmail.Id];
            
            test.stopTest();
        }
        
    }
    
    @isTest
    static void testLeadwithLeadQueue(){
        
        Geography__c geography = TestBusinessHelper.createGeography('Japan', 'Country', null, true);
        
            Campaign recCampaign = new Campaign (Name = 'testCamp1', Campaign_Category__c = 'Marketing', Liner_Brand__c = 'Maersk Line', Region__c = 'Africa Region', Description ='test', StartDate = Date.valueOf(Datetime.now().format('yyyy-MM-dd')), Target_Vertical__c = 'Lifestyle', Target_Segment__c = 'Ease', BudgetedCost = 89, IsActive = True);
            insert recCampaign;
        
        Group recQueueGroup = new Group(name = 'test lead queue', type = 'Queue');
        insert recQueueGroup;

        System.runAs(new User(Id=UserInfo.GetUserId())){
            QueuesObject recQueuesObj = new QueueSObject(QueueId = recQueueGroup.Id, SObjectType = 'Lead');
            insert recQueuesObj;
        }
            Lead lead1 = new Lead( LastName='Lead5', Company='TestLead1',Country_lk__c = geography.id,LeadSource = 'LinkedIn', Email='testlead_cm5@test.com', Source_Brand__c=BrandUtilities.MAERSK, Marketing_Opt_In__c=True, Capture_Source__c='TestLead1_CS', OwnerId = recQueueGroup.Id);
            test.startTest();
            insert lead1;
                      
        CampaignMember lCampaignMember = new CampaignMember(CampaignId=recCampaign.Id, LeadId = Lead1.Id,Status='Sent');
            insert lCampaignMember;
            
        CampaignMember campmembr = [SELECT id,Campaign.OwnerId,Campaign.Owner.IsActive,leadId from CampaignMember 
                                                where Campaign.Campaign_Category__c='Marketing' and LeadId =: Lead1.Id ];
         System.assert(campmembr.Id != null, 'Campaign Member is populated');
            Lead leadToCheck = [SELECT Id, IndividualId FROM Lead WHERE Id =: lead1.Id];
            System.assert(leadToCheck.IndividualId != null, 'Lead with Leadsource, IndividualId is populated');
            leadToCheck.FirstName='Test';
            update leadToCheck;
            test.stopTest();
            
            
    }
 
}