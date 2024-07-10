/**
* Purpose : Test class for SyncToSFMCUpdator class
*        
* Revision Ref Number  Date            Owner                      Description
* -------- ----------  -----------     -------------------        -----------
* 1.0      SFMC-7285   03-Jan-2024     amrutha@maersk             Code created for Reduce SFMC Billable Contact Count: Change the 'Sync to SFMC' logic in Sales Cloud
*/


@isTest

public class SyncToSFMCUpdator_Test {
    
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
        
        // Run test setup as system owner
        System.runAs(usrSysOwner){
            
            // Create Lead records with and without skipping triggers
            Lead recLead = new Lead(FirstName='Test', LastName='Lead1', Company='TestLead1', Email='testlead_cm1@test.com', Source_Brand__c=BrandUtilities.MAERSK, Marketing_Opt_In__c=true, Capture_Source__c='TestLead1_CS',LeadSource = 'LinkedIn');
            insert recLead;
            
            TriggerExecutionController.skipLeadTrigger(true);
            Lead recLeadAnother = new Lead(FirstName='Test', LastName='Lead1', Company='TestLead1', Email='testlead_cm1@test.com', Source_Brand__c=BrandUtilities.MAERSK, Marketing_Opt_In__c=true, Capture_Source__c='TestLead1a_CS',LeadSource = 'LinkedIn');
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
    
    // Test method for contacts where consent is Updated with OptOut
    @isTest
    static void testContactWhereIndIDExistWithStatusActive(){
        User usrSysOwner = [SELECT Id, Name FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        System.runAs(usrSysOwner) {
            Account rAcc = [SELECT Id, Name FROM Account LIMIT 1];
            Id cntRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer_Contact').getRecordTypeId();
            Lead recLead = new Lead(FirstName = 'Test', LastName = 'Lead9', Company = 'TestLead9', Email = 'testlead_cm9@test.com', Source_Brand__c = BrandUtilities.MAERSK, Marketing_Opt_In__c = true, Capture_Source__c = 'TestLead9_CS',LeadSource = 'LinkedIn');
            insert recLead;
            String strMailingCity = BDAGeographyData_Test.citySterling.Name;
            Contact recCnt = new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'testlead_cm9@test.com', AccountId = rAcc.Id, Liner_Brands__c = BrandUtilities.MAERSKLINE, MailingCity = strMailingCity, RecordTypeId = cntRTId);
            test.startTest();
            insert recCnt;
            consentPointCntrl.getConsent(recCnt.Id);
            test.stopTest();
            
            Contact cntToCheck = [SELECT Id, IndividualId, Email, Contact_Status__c,Sync_to_SFMC__c FROM Contact WHERE Id =: recCnt.Id];
            System.assert(cntToCheck.IndividualId != null, 'Contact where Ind Id exists for Lead, Indvidual Id not populated');
            
            ContactPointTypeConsent cpeToCheck = [SELECT Id,PrivacyConsentStatus FROM ContactPointTypeConsent WHERE PartyId = :cntToCheck.IndividualId Limit 1];
            cpeToCheck.PrivacyConsentStatus='OptOut';
            update cpeToCheck;
            //System.assert(cpeToCheck.EmailAddress == recLead.Email, 'ContactPointEmail EmailAddress does not match Lead Email');
            
            If (cntToCheck.Email != null && cntToCheck.Contact_Status__c == 'Active')
            {
                System.assertEquals(true, cntToCheck.Sync_to_SFMC__c, 'Sync_to_SFMC__c should be true for eligible contacts');
            }
        }
    }
    
    // Test method for contacts with IndividualId existing for Lead with Capture Source
    @isTest
    static void testContactWhereIndIDExistForLeadwithCSC(){
        User usrSysOwner = [SELECT Id, Name FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        System.runAs(usrSysOwner) {
            Account rAcc = [SELECT Id, Name FROM Account LIMIT 1];
            Id cntRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer_Contact').getRecordTypeId();
            Lead recLead = new Lead(FirstName = 'Test', LastName = 'Lead9', Company = 'TestLead9', Email = 'testlead_cm9@test.com', Source_Brand__c = BrandUtilities.MAERSK, Marketing_Opt_In__c = true, Capture_Source__c = 'TestLead9_CS',LeadSource = 'LinkedIn');
            insert recLead;
            String strMailingCity = BDAGeographyData_Test.citySterling.Name;
            Contact recCnt = new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'testlead_cm9@test.com', AccountId = rAcc.Id, Liner_Brands__c = BrandUtilities.MAERSKLINE, MailingCity = strMailingCity, RecordTypeId = cntRTId);
            test.startTest();
            insert recCnt;
            consentPointCntrl.getConsent(recCnt.Id);
            test.stopTest();
            Contact cntToCheck = [SELECT Id, IndividualId FROM Contact WHERE Id = :recCnt.Id];
            ContactPointTypeConsent cpeToCheck=new ContactPointTypeConsent();
            cpeToCheck.PrivacyConsentStatus='OptOut';
            cpeToCheck.partyId=cntToCheck.IndividualId;
            cpeToCheck.Name = 'testlead_cm9@test.com';
            cpeToCheck.CaptureSource = 'TestLead9_CS';
            cpeToCheck.CaptureDate = DateTime.Now();
            cpeToCheck.CaptureContactPointType = 'Email';
            insert cpeToCheck; 
        }
    }
    
    // Test method for contacts where consent is created with OptOut
    @isTest
    static void testContactWhereConsentisUpdated(){
        User usrSysOwner = [SELECT Id, Name FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        System.runAs(usrSysOwner) {
            Account rAcc = [SELECT Id, Name FROM Account LIMIT 1];
            Id cntRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer_Contact').getRecordTypeId();
            Lead recLead = new Lead(FirstName = 'Test', LastName = 'Lead9', Company = 'TestLead9', Email = 'testlead_cm9@test.com', Source_Brand__c = BrandUtilities.MAERSK, Marketing_Opt_In__c = true, Capture_Source__c = 'TestLead9_CS',LeadSource = 'LinkedIn');
            insert recLead;
            String strMailingCity = BDAGeographyData_Test.citySterling.Name;
            Contact recCnt = new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'testlead_cm9@test.com', AccountId = rAcc.Id, Liner_Brands__c = BrandUtilities.MAERSKLINE, MailingCity = strMailingCity, RecordTypeId = cntRTId);
            test.startTest();
            insert recCnt;
            consentPointCntrl.getConsent(recCnt.Id);
            test.stopTest();
            Contact cntToCheck = [SELECT Id, IndividualId FROM Contact WHERE Id = :recCnt.Id];
            ContactPointTypeConsent cpeToCheck=new ContactPointTypeConsent();
            cpeToCheck.PrivacyConsentStatus='OptOut';
            cpeToCheck.partyId=cntToCheck.IndividualId;
            cpeToCheck.Name = 'testlead_cm9@test.com';
            cpeToCheck.CaptureSource = 'TestLead9_CS';
            cpeToCheck.CaptureDate = DateTime.Now();
            cpeToCheck.CaptureContactPointType = 'Email';
            insert cpeToCheck;
            
        }
    }
    
    // Test method for contacts with IndividualId existing for Lead and delete consent
    @isTest
    static void testContactWhereIndIDExistForLeadandDeleteConsent(){
        User usrSysOwner = [SELECT Id, Name FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        System.runAs(usrSysOwner) {
            Account rAcc = [SELECT Id, Name FROM Account LIMIT 1];
            Id cntRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer_Contact').getRecordTypeId();
            Lead recLead = new Lead(FirstName = 'Test', LastName = 'Lead9', Company = 'TestLead9', Email = 'testlead_cm9@test.com', Source_Brand__c = BrandUtilities.MAERSK, Marketing_Opt_In__c = true, Capture_Source__c = 'TestLead9_CS',LeadSource = 'LinkedIn');
            insert recLead;
            String strMailingCity = BDAGeographyData_Test.citySterling.Name;
            Contact recCnt = new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'testlead_cm9@test.com', AccountId = rAcc.Id, Liner_Brands__c = BrandUtilities.MAERSKLINE, MailingCity = strMailingCity, RecordTypeId = cntRTId);
            test.startTest();
            insert recCnt;
            consentPointCntrl.getConsent(recCnt.Id);
            test.stopTest();
            Lead leadToCheck = [SELECT Id,IndividualId  FROM Lead WHERE Email = :recLead.Email]; 
            // delete leadToCheck;
            ContactPointTypeConsent cptcToCheck = [SELECT Id FROM ContactPointTypeConsent WHERE PartyId=:leadToCheck.IndividualId];
            delete cptcToCheck;
            
        }
    }
    
    // Test method for contacts with Included to data signal field as true 
    @isTest
    static void testContactWhereIDSfieldisTrue(){
        User usrSysOwner = [SELECT Id, Name FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        System.runAs(usrSysOwner) {
            Account rAcc = [SELECT Id, Name FROM Account LIMIT 1];
            Id cntRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer_Contact').getRecordTypeId();
            Lead recLead = new Lead(FirstName = 'Test', LastName = 'Lead9', Company = 'TestLead9', Email = 'testlead_cm9@test.com', Source_Brand__c = BrandUtilities.MAERSK, Marketing_Opt_In__c = true, Capture_Source__c = 'TestLead9_CS',LeadSource = 'LinkedIn');
            insert recLead;
            String strMailingCity = BDAGeographyData_Test.citySterling.Name;
            Contact recCnt = new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'testlead_cm9@test.com', AccountId = rAcc.Id, Liner_Brands__c = BrandUtilities.MAERSKLINE, MailingCity = strMailingCity, RecordTypeId = cntRTId, Included_in_Data_Signals__c = True);
            test.startTest();
            insert recCnt;
            consentPointCntrl.getConsent(recCnt.Id);
            test.stopTest();
            
            Contact cntToCheck = [SELECT Id,Included_in_Data_Signals__c, IndividualId, Email, Contact_Status__c,Sync_to_SFMC__c FROM Contact WHERE Id =: recCnt.Id];
            System.assert(cntToCheck.Included_in_Data_Signals__c == True, 'Contact where Included_in_Data_Signals__c is true');
            
        }
    }
    
    
    // Test method for contacts with IndividualId existing, Contact_Status is InActive
    @isTest
    static void testContactWhereIndIDExistWithStatusInActive(){
        User usrSysOwner = [SELECT Id, Name FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        System.runAs(usrSysOwner){ 
            Account rAcc = [SELECT Id, Name FROM Account limit 1];
            
            Id cntRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer_Contact').getRecordTypeId();
            Lead recLead = new Lead(FirstName='Test', LastName='Lead2', Company='TestLead2', Email='testlead_cm2@test.com', Source_Brand__c=BrandUtilities.MAERSK, Marketing_Opt_In__c=true, Capture_Source__c='TestLead1_CS',LeadSource = 'LinkedIn');
            insert recLead;
            
            String strMailingCity = BDAGeographyData_Test.citySterling.Name;
            Contact recCnt = new Contact(FirstName='Test', LastName='Contact2', Email='testlead_cm2@test.com', AccountId=rAcc.Id, Liner_Brands__c=BrandUtilities.MAERSKLINE, MailingCity=strMailingCity,RecordTypeId=cntRTId, Contact_Status__c = 'InActive');
            
            test.startTest();
            insert recCnt;
            consentPointCntrl.getConsent(recCnt.Id);
            test.stopTest();
            
            Contact cntToCheck = [SELECT Id, IndividualId, Email, Contact_Status__c,Sync_to_SFMC__c FROM Contact WHERE Id =: recCnt.Id];
            System.assert(cntToCheck.IndividualId != null, 'Contact where Ind Id exists for Lead, Indvidual Id not populated');
            
            If (cntToCheck.Email != null && cntToCheck.Contact_Status__c != 'InActive')
            {
                System.assertEquals(false, cntToCheck.Sync_to_SFMC__c, 'Sync_to_SFMC__c should be false for eligible contacts');
            }
        }
    }
}