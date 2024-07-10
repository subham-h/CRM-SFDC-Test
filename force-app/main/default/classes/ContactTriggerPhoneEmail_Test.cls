/**
 * Description : Test class for ContactTrigger Phone/Email validation using http callout.
 * 
 * Date         Owner               RQ#         Description
 ************************************************************************************************************
 * 27/03/2019   Nitin@Maersk        RQ-010026   Class created.
 * 22/09/2020   Sidahrtha@Maersk    SFSE-3924   Class modified for new functionality!!!.
 * 15/06/2022   Ronnie@SF           SPI-100     Removed brand hardcoding
 * 10/04/2023   Vazid 				SFSE-9907	Fix test failure - VALIDATION_EXCEPTION
 */

@isTest
private class ContactTriggerPhoneEmail_Test {
    
    @testSetup static void setup() {       
        TriggerExecutionController.skipAllTriggers(true);
        Account ClientAccount = AccountDataHelper_Test.createClientAccount();
        Contact CustContact = ContactDataGeneratorHelper_Test.createCustomerContact(ClientAccount.Id, BrandUtilities.MAERSKLINE);
        TriggerExecutionController.skipAllTriggers(false);
    }
    
    /* Contact with Email Unit Test */
    static testmethod void TestContactWithValidEmail() {
        String strEmail = 'test_cust_email'+ Math.random()+'@gmail.com';
        String strOtherEmail = 'test_cust_otheremail'+ Math.random()+'@gmail.com';
        
        Contact_Informatica_Webservice__mdt contPhoneInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
        Contact_Informatica_Webservice__mdt contEmailInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
        List<Contact_Informatica_Webservice__mdt> lstContactInformaticaWebservice = [SELECT Chatter_UserName__c, License_Key__c, Label, DeveloperName, Active__c, Host_Name__c, Query_Path__c, Record_Type__c, Timeout__c, Send_Chatter_Post__c, Send_Email_To_Last_Modified__c 
                                                                                     FROM Contact_Informatica_Webservice__mdt
                                                                                     WHERE DeveloperName in ('Contact_Phone_Validation','Contact_Email_Validation')];
        
        if (lstContactInformaticaWebservice.size() > 0) {
            for (Contact_Informatica_Webservice__mdt ciw : lstContactInformaticaWebservice) {
                contPhoneInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Phone_Validation') ? ciw : contPhoneInformaticaWebserviceDetails;
                contEmailInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Email_Validation') ? ciw : contEmailInformaticaWebserviceDetails;
            }
        }
        
        Account testClientAccount = [SELECT Id, Name FROM Account LIMIT 1];
        Contact testCustContactToInsert = new Contact();
        testCustContactToInsert.LastName = 'Test Create Contact' + Math.random();
        testCustContactToInsert.FirstName = BrandUtilities.MAERSKLINE ;
        testCustContactToInsert.Email = strEmail.toLowerCase();
        testCustContactToInsert.Duplicate_Email__c = strOtherEmail.toLowerCase();
        testCustContactToInsert.Preferred_Language__c = 'English';
        testCustContactToInsert.Liner_Brands__c = BrandUtilities.MAERSKLINE ;
        testCustContactToInsert.RecordTypeId = Label.Customer_Contact_Record_Type;
        testCustContactToInsert.AccountId = testClientAccount.Id;
        insert testCustContactToInsert;
        
        Map<String, String> mapPhoneNumberToFieldNm = new  Map<String, String>();
        Map<String, String> mapPhoneNumberWithoutCountryCodeToFieldNm = new Map<String, String>();
        Map<String, String> mapEmailIdsToFieldName = new Map<String, String>();
        Map<Id, Contact> mapContactFieldName = new Map<Id, Contact>();
        mapContactFieldName.put(testCustContactToInsert.Id, testCustContactToInsert);
        mapEmailIdsToFieldName.put(testCustContactToInsert.Email,'Email');
        mapEmailIdsToFieldName.put(testCustContactToInsert.Duplicate_Email__c,'Duplicate_Email__c');
        
        Map<String, String> mapEmailStatus = new Map<String, String>();
        mapEmailStatus.put(testCustContactToInsert.Email, Label.Informatica_Email_Valid_Description);
        mapEmailStatus.put(testCustContactToInsert.Duplicate_Email__c, Label.Informatica_Email_Valid_Description);
        
        List<String> lstPhone = new List<String>();
        lstPhone.add(testCustContactToInsert.Phone);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ContactEmailMockHttpResponse());
        HttpResponse testEmailRes = ContactPhoneEmailValidateUtility.getEmailValidationResponse(strEmail, contEmailInformaticaWebserviceDetails);
        Map<String, String> emailMap = ContactPhoneEmailValidateUtility.processEmailResponse(testEmailRes, strEmail);
        system.debug('emailMap' + emailMap);
        ContactPhoneEmailValidate.makeCallout = false;
        ContactPhoneEmailValidate.contactEmailStatusmap = mapEmailStatus;
        System.enqueueJob(new ContactPhoneEmailValidate(mapContactFieldName, testCustContactToInsert.Id, mapPhoneNumberToFieldNm, mapPhoneNumberWithoutCountryCodeToFieldNm, mapEmailIdsToFieldName, contPhoneInformaticaWebserviceDetails ,contEmailInformaticaWebserviceDetails));
        test.stopTest();
        
        Contact checkContact = [SELECT Id, Name, Email, Duplicate_Email__c, Email_Phone_Verification_Results__c FROM Contact WHERE Id =: testCustContactToInsert.Id LIMIT 1];
        System.assertEquals(strEmail, checkContact.Email, 'Contact Email does not match');
        System.assertEquals(strOtherEmail, checkContact.Duplicate_Email__c, 'Contact OtherEmail does not match');
    }
    
    static testmethod void TestContactWithEmail_ServiceUnavailable() {
        String strEmail = 'test_cust_email'+ Math.random()+'@gmail.com';
        String strOtherEmail = 'test_cust_otheremail'+ Math.random()+'@gmail.com';
        
        Contact_Informatica_Webservice__mdt contPhoneInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
        Contact_Informatica_Webservice__mdt contEmailInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
        List<Contact_Informatica_Webservice__mdt> lstContactInformaticaWebservice = [SELECT Chatter_UserName__c, License_Key__c, Label, DeveloperName, Active__c, Host_Name__c, Query_Path__c, Record_Type__c, Timeout__c,Send_Chatter_Post__c, Send_Email_To_Last_Modified__c 
                                                                                     FROM Contact_Informatica_Webservice__mdt
                                                                                     WHERE DeveloperName in ('Contact_Phone_Validation','Contact_Email_Validation')];
        
        if (lstContactInformaticaWebservice.size() > 0) {
            for (Contact_Informatica_Webservice__mdt ciw : lstContactInformaticaWebservice) {
                contPhoneInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Phone_Validation') ? ciw : contPhoneInformaticaWebserviceDetails;
                contEmailInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Email_Validation') ? ciw : contEmailInformaticaWebserviceDetails;
            }
        }
        
        Account testClientAccount = [SELECT Id, Name FROM Account LIMIT 1];
        Contact testCustContactToInsert = new Contact();
        testCustContactToInsert.LastName = 'Test Create Contact' + Math.random();
        testCustContactToInsert.FirstName = BrandUtilities.MAERSKLINE ;
        testCustContactToInsert.Email = strEmail.toLowerCase();
        testCustContactToInsert.Duplicate_Email__c = strOtherEmail.toLowerCase();
        testCustContactToInsert.Preferred_Language__c = 'English';
        testCustContactToInsert.Liner_Brands__c = BrandUtilities.MAERSKLINE ;
        testCustContactToInsert.RecordTypeId = Label.Customer_Contact_Record_Type;
        testCustContactToInsert.AccountId = testClientAccount.Id;
        insert testCustContactToInsert;
        Map<Id, Contact> mapContactFieldName = new Map<Id, Contact>();
        mapContactFieldName.put(testCustContactToInsert.Id, testCustContactToInsert);
        Map<String, String> mapPhoneNumberToFieldNm = new  Map<String, String>();
        Map<String, String> mapPhoneNumberWithoutCountryCodeToFieldNm = new Map<String, String>();
        Map<String, String> mapEmailIdsToFieldName = new Map<String, String>();
        mapEmailIdsToFieldName.put(testCustContactToInsert.Email,'Email');
        mapEmailIdsToFieldName.put(testCustContactToInsert.Duplicate_Email__c,'Duplicate_Email__c');
        
        Map<String, String> mapEmailStatus = new Map<String, String>();
        mapEmailStatus.put(testCustContactToInsert.Email, Label.Informatica_Service_Status_Unavailable);
        mapEmailStatus.put(testCustContactToInsert.Duplicate_Email__c, Label.Informatica_Service_Status_Unavailable);
        
        List<String> lstPhone = new List<String>();
        lstPhone.add(testCustContactToInsert.Phone);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ContactEmailMockHttpResponse());
        HttpResponse testEmailRes = ContactPhoneEmailValidateUtility.getEmailValidationResponse(strEmail, contEmailInformaticaWebserviceDetails);
        system.debug('@@@@' + testEmailRes.getBody());
        Map<String, String> emailMap = ContactPhoneEmailValidateUtility.processEmailResponse(testEmailRes, strEmail);
        
        ContactPhoneEmailValidate.makeCallout = false;
        ContactPhoneEmailValidate.contactEmailStatusmap = mapEmailStatus;
        System.enqueueJob(new ContactPhoneEmailValidate(mapContactFieldName, testCustContactToInsert.Id, mapPhoneNumberToFieldNm, mapPhoneNumberWithoutCountryCodeToFieldNm, mapEmailIdsToFieldName, contPhoneInformaticaWebserviceDetails ,contEmailInformaticaWebserviceDetails));
        test.stopTest();
        
        Contact checkContact = [SELECT Id, Name, Email, Duplicate_Email__c, Email_Phone_Verification_Results__c FROM Contact WHERE Id =: testCustContactToInsert.Id LIMIT 1];
        System.assertEquals(strEmail, checkContact.Email, 'Contact Email does not match');
        System.assertEquals(strOtherEmail, checkContact.Duplicate_Email__c, 'Contact OtherEmail does not match');
    }
    
    static testmethod void TestContactWithValidEmail_InvalidOtherEmail() {
        String strEmail = 'test_cust_email'+ Math.random()+'@gmail.com';
        String strOtherEmail = 'test_cust_otheremail'+ Math.random()+'@gmail.com';
        
        Contact_Informatica_Webservice__mdt contPhoneInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
        Contact_Informatica_Webservice__mdt contEmailInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
        List<Contact_Informatica_Webservice__mdt> lstContactInformaticaWebservice = [SELECT Chatter_UserName__c, License_Key__c, Label, DeveloperName, Active__c, Host_Name__c, Query_Path__c, Record_Type__c, Timeout__c, Send_Chatter_Post__c, Send_Email_To_Last_Modified__c 
                                                                                     FROM Contact_Informatica_Webservice__mdt
                                                                                     WHERE DeveloperName in ('Contact_Phone_Validation','Contact_Email_Validation')];
        
        if (lstContactInformaticaWebservice.size() > 0) {
            for (Contact_Informatica_Webservice__mdt ciw : lstContactInformaticaWebservice) {
                contPhoneInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Phone_Validation') ? ciw : contPhoneInformaticaWebserviceDetails;
                contEmailInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Email_Validation') ? ciw : contEmailInformaticaWebserviceDetails;
            }
        }
        
        Account testClientAccount = [SELECT Id, Name FROM Account LIMIT 1];
        Contact testCustContactToInsert = new Contact();
        testCustContactToInsert.LastName = 'Test Create Contact' + Math.random();
        testCustContactToInsert.FirstName = BrandUtilities.MAERSKLINE ;
        testCustContactToInsert.Email = strEmail.toLowerCase();
        testCustContactToInsert.Duplicate_Email__c = strOtherEmail.toLowerCase();
        testCustContactToInsert.Preferred_Language__c = 'English';
        testCustContactToInsert.Liner_Brands__c = BrandUtilities.MAERSKLINE ;
        testCustContactToInsert.RecordTypeId = Label.Customer_Contact_Record_Type;
        testCustContactToInsert.AccountId = testClientAccount.Id;
        insert testCustContactToInsert;
        
        Map<String, String> mapPhoneNumberToFieldNm = new  Map<String, String>();
        Map<String, String> mapPhoneNumberWithoutCountryCodeToFieldNm = new Map<String, String>();
        Map<String, String> mapEmailIdsToFieldName = new Map<String, String>();
        Map<Id, Contact> mapContactFieldName = new Map<Id, Contact>();
        mapContactFieldName.put(testCustContactToInsert.Id,testCustContactToInsert);
        mapEmailIdsToFieldName.put(testCustContactToInsert.Email,'Email');
        mapEmailIdsToFieldName.put(testCustContactToInsert.Duplicate_Email__c,'Duplicate_Email__c');
        
        Map<String, String> mapEmailStatus = new Map<String, String>();
        mapEmailStatus.put(testCustContactToInsert.Email, Label.Informatica_Email_Valid_Description);
        mapEmailStatus.put(testCustContactToInsert.Duplicate_Email__c, Label.Informatica_Email_Invalid_Description);
        
        List<String> lstPhone = new List<String>();
        lstPhone.add(testCustContactToInsert.Phone);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ContactEmailMockHttpResponse());
        HttpResponse testEmailRes = ContactPhoneEmailValidateUtility.getEmailValidationResponse(strEmail, contEmailInformaticaWebserviceDetails);
        Map<String, String> emailMap = ContactPhoneEmailValidateUtility.processEmailResponse(testEmailRes, strEmail);
        
        ContactPhoneEmailValidate.makeCallout = false;
        ContactPhoneEmailValidate.contactEmailStatusmap = mapEmailStatus;
        System.enqueueJob(new ContactPhoneEmailValidate(mapContactFieldName, testCustContactToInsert.Id, mapPhoneNumberToFieldNm, mapPhoneNumberWithoutCountryCodeToFieldNm, mapEmailIdsToFieldName, contPhoneInformaticaWebserviceDetails ,contEmailInformaticaWebserviceDetails));
        test.stopTest();
        
        Contact checkContact = [SELECT Id, Name, Email, Duplicate_Email__c, Email_Phone_Verification_Results__c FROM Contact WHERE Id =: testCustContactToInsert.Id LIMIT 1];
        System.assertEquals(strEmail, checkContact.Email, 'Contact Email does not match');
        System.assertEquals(strOtherEmail, checkContact.Duplicate_Email__c, 'Contact OtherEmail does not match');
    }
    
    static testmethod void TestContactWithInvalidEmail() {
        String strEmail = 'test_cust_email'+ Math.random()+'@gmail.com';
        
        Contact_Informatica_Webservice__mdt contPhoneInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
        Contact_Informatica_Webservice__mdt contEmailInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
        List<Contact_Informatica_Webservice__mdt> lstContactInformaticaWebservice = [SELECT Chatter_UserName__c, License_Key__c, Label, DeveloperName, Active__c, Host_Name__c, Query_Path__c, Record_Type__c, Timeout__c, Send_Chatter_Post__c, Send_Email_To_Last_Modified__c 
                                                                                     FROM Contact_Informatica_Webservice__mdt
                                                                                     WHERE DeveloperName in ('Contact_Phone_Validation','Contact_Email_Validation')];
        
        if (lstContactInformaticaWebservice.size() > 0) {
            for (Contact_Informatica_Webservice__mdt ciw : lstContactInformaticaWebservice) {
                contPhoneInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Phone_Validation') ? ciw : contPhoneInformaticaWebserviceDetails;
                contEmailInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Email_Validation') ? ciw : contEmailInformaticaWebserviceDetails;
            }
        }
        
        Account testClientAccount = [SELECT Id, Name FROM Account LIMIT 1];
        Contact testCustContactToInsert = new Contact();
        testCustContactToInsert.LastName = 'Test Create Contact' + Math.random();
        testCustContactToInsert.FirstName = BrandUtilities.MAERSKLINE ;
        testCustContactToInsert.Email = strEmail.toLowerCase();
        testCustContactToInsert.Preferred_Language__c = 'English';
        testCustContactToInsert.Liner_Brands__c = BrandUtilities.MAERSKLINE ;
        testCustContactToInsert.RecordTypeId = Label.Customer_Contact_Record_Type;
        testCustContactToInsert.AccountId = testClientAccount.Id;
        insert testCustContactToInsert;
        
        Map<String, String> mapPhoneNumberToFieldNm = new  Map<String, String>();
        Map<String, String> mapPhoneNumberWithoutCountryCodeToFieldNm = new Map<String, String>();
        Map<String, String> mapEmailIdsToFieldName = new Map<String, String>();
        Map<Id, Contact> mapContactFieldName = new Map<Id, Contact>();
        mapContactFieldName.put(testCustContactToInsert.Id,testCustContactToInsert);
        mapEmailIdsToFieldName.put(testCustContactToInsert.Email,'Email');
        
        Map<String, String> mapEmailStatus = new Map<String, String>();
        mapEmailStatus.put(testCustContactToInsert.Email, Label.Informatica_Email_Invalid_Description);
        
        List<String> lstPhone = new List<String>();
        lstPhone.add(testCustContactToInsert.Phone);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ContactEmailMockHttpResponse());
        HttpResponse testEmailRes = ContactPhoneEmailValidateUtility.getEmailValidationResponse(strEmail, contEmailInformaticaWebserviceDetails);
        Map<String, String> emailMap = ContactPhoneEmailValidateUtility.processEmailResponse(testEmailRes, strEmail);
        
        ContactPhoneEmailValidate.makeCallout = false;
        ContactPhoneEmailValidate.contactEmailStatusmap = mapEmailStatus;
        System.enqueueJob(new ContactPhoneEmailValidate(mapContactFieldName, testCustContactToInsert.Id, mapPhoneNumberToFieldNm, mapPhoneNumberWithoutCountryCodeToFieldNm, mapEmailIdsToFieldName, contPhoneInformaticaWebserviceDetails ,contEmailInformaticaWebserviceDetails));
        test.stopTest();
        
        Contact checkContact = [SELECT Id, Name, Email, Duplicate_Email__c, Email_Phone_Verification_Results__c FROM Contact WHERE Id =: testCustContactToInsert.Id LIMIT 1];
        System.assertEquals(strEmail, checkContact.Email, 'Contact Email does not match');
    }
    
    static testmethod void TestContactWithValidOtherEmail_InvalidEmail() {
        String strEmail = 'test_cust_email'+ Math.random()+'@gmail.com';
        String strOtherEmail = 'test_cust_otheremail'+ Math.random()+'@gmail.com';
        
        Contact_Informatica_Webservice__mdt contPhoneInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
        Contact_Informatica_Webservice__mdt contEmailInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
        List<Contact_Informatica_Webservice__mdt> lstContactInformaticaWebservice = [SELECT Chatter_UserName__c, License_Key__c, Label, DeveloperName, Active__c, Host_Name__c, Query_Path__c, Record_Type__c, Timeout__c, Send_Chatter_Post__c, Send_Email_To_Last_Modified__c 
                                                                                     FROM Contact_Informatica_Webservice__mdt
                                                                                     WHERE DeveloperName in ('Contact_Phone_Validation','Contact_Email_Validation')];
        
        if (lstContactInformaticaWebservice.size() > 0) {
            for (Contact_Informatica_Webservice__mdt ciw : lstContactInformaticaWebservice){
                contPhoneInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Phone_Validation') ? ciw : contPhoneInformaticaWebserviceDetails;
                contEmailInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Email_Validation') ? ciw : contEmailInformaticaWebserviceDetails;
            }
        }
        
        Account testClientAccount = [SELECT Id, Name FROM Account LIMIT 1];
        Contact testCustContactToInsert = new Contact();
        testCustContactToInsert.LastName = 'Test Create Contact' + Math.random();
        testCustContactToInsert.FirstName = BrandUtilities.MAERSKLINE ;
        testCustContactToInsert.Email = strEmail.toLowerCase();
        testCustContactToInsert.Duplicate_Email__c = strOtherEmail.toLowerCase();
        testCustContactToInsert.Preferred_Language__c = 'English';
        testCustContactToInsert.Liner_Brands__c = BrandUtilities.MAERSKLINE ;
        testCustContactToInsert.RecordTypeId = Label.Customer_Contact_Record_Type;
        testCustContactToInsert.AccountId = testClientAccount.Id;
        insert testCustContactToInsert;
        
        Map<String, String> mapPhoneNumberToFieldNm = new  Map<String, String>();
        Map<String, String> mapPhoneNumberWithoutCountryCodeToFieldNm = new Map<String, String>();
        Map<String, String> mapEmailIdsToFieldName = new Map<String, String>();
        mapEmailIdsToFieldName.put(testCustContactToInsert.Email,'Email');
        mapEmailIdsToFieldName.put(testCustContactToInsert.Duplicate_Email__c,'Duplicate_Email__c');
        
        Map<String, String> mapEmailStatus = new Map<String, String>();
        Map<Id, Contact> mapContactFieldName = new Map<Id, Contact>();
        mapContactFieldName.put(testCustContactToInsert.Id,testCustContactToInsert);
        mapEmailStatus.put(testCustContactToInsert.Email, Label.Informatica_Email_Invalid_Description);
        mapEmailStatus.put(testCustContactToInsert.Duplicate_Email__c, Label.Informatica_Email_Valid_Description);
        
        List<String> lstPhone = new List<String>();
        lstPhone.add(testCustContactToInsert.Phone);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ContactEmailMockHttpResponse());
        HttpResponse testEmailRes = ContactPhoneEmailValidateUtility.getEmailValidationResponse(strEmail, contEmailInformaticaWebserviceDetails);
        Map<String, String> emailMap = ContactPhoneEmailValidateUtility.processEmailResponse(testEmailRes, strEmail);
        
        ContactPhoneEmailValidate.makeCallout = false;
        ContactPhoneEmailValidate.contactEmailStatusmap = mapEmailStatus;
        System.enqueueJob(new ContactPhoneEmailValidate(mapContactFieldName, testCustContactToInsert.Id, mapPhoneNumberToFieldNm, mapPhoneNumberWithoutCountryCodeToFieldNm, mapEmailIdsToFieldName, contPhoneInformaticaWebserviceDetails ,contEmailInformaticaWebserviceDetails));
        test.stopTest();
        
        Contact checkContact = [SELECT Id, Name, Email, Duplicate_Email__c, Email_Phone_Verification_Results__c FROM Contact WHERE Id =: testCustContactToInsert.Id LIMIT 1];
        System.assertEquals(strEmail, checkContact.Email, 'Contact Email does not match');
        System.assertEquals(strOtherEmail, checkContact.Duplicate_Email__c, 'Contact OtherEmail does not match');
    }
    
    /* Contact with Single Phone Unit Test */
    static testmethod void TestContactValidOfficePhone() {
        String strPhone = '+91 8046562674';
        String strPhoneWithoutCountry = '8046562674';
        String strEmail = 'test_cust_email'+ Math.random()+'@gmail.com';//SFSE-9907
        
        Contact_Informatica_Webservice__mdt contPhoneInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
        Contact_Informatica_Webservice__mdt contEmailInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
        List<Contact_Informatica_Webservice__mdt> lstContactInformaticaWebservice = [SELECT Chatter_UserName__c, License_Key__c, Label, DeveloperName, Active__c, Host_Name__c, Query_Path__c, Record_Type__c, Timeout__c, Send_Chatter_Post__c, Send_Email_To_Last_Modified__c 
                                                                                     FROM Contact_Informatica_Webservice__mdt
                                                                                     WHERE DeveloperName in ('Contact_Phone_Validation','Contact_Email_Validation')];
        
        if (lstContactInformaticaWebservice.size() > 0) {
            for (Contact_Informatica_Webservice__mdt ciw : lstContactInformaticaWebservice) {
                contPhoneInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Phone_Validation') ? ciw : contPhoneInformaticaWebserviceDetails;
                contEmailInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Email_Validation') ? ciw : contEmailInformaticaWebserviceDetails;
            }
        }
        
        Account testClientAccount = [SELECT Id, Name FROM Account LIMIT 1];
        Contact testCustContactToInsert = new Contact();
        testCustContactToInsert.LastName = 'Test Create Contact' + Math.random();
        testCustContactToInsert.FirstName = BrandUtilities.MAERSKLINE ;
        testCustContactToInsert.Phone = strPhone;
        testCustContactToInsert.Preferred_Language__c = 'English';
        testCustContactToInsert.Liner_Brands__c = BrandUtilities.MAERSKLINE ;
        testCustContactToInsert.RecordTypeId = Label.Customer_Contact_Record_Type;
        testCustContactToInsert.AccountId = testClientAccount.Id;
        testCustContactToInsert.Email = strEmail.toLowerCase();//SFSE - 9907
        insert testCustContactToInsert;
        
        Map<Id, Contact> mapContactFieldName = new Map<Id, Contact>();
        mapContactFieldName.put(testCustContactToInsert.Id,testCustContactToInsert);
        
        Map<String, String> mapPhoneNumberToFieldNm = new  Map<String, String>();
        mapPhoneNumberToFieldNm.put(testCustContactToInsert.Phone.replace('+','').deleteWhitespace(),'Phone');
        
        Map<String, String> mapPhoneNumberWithoutCountryCodeToFieldNm = new Map<String, String>();
        mapPhoneNumberWithoutCountryCodeToFieldNm.put(strPhoneWithoutCountry, 'Phone');
        Map<String, String> mapEmailIdsToFieldName = new Map<String, String>();
        Map<String, String> mapPhoneStatus = new Map<String, String>();
        mapPhoneStatus.put(testCustContactToInsert.Phone.replace('+','').deleteWhitespace(), Label.Informatica_Phone_Valid_Description);
        
        List<String> lstPhone = new List<String>();
        lstPhone.add(testCustContactToInsert.Phone);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ContactPhoneSingleMockHttpResponse());
        HttpResponse testPhoneRes = ContactPhoneEmailValidateUtility.getPhoneValidationResponse(lstPhone, contPhoneInformaticaWebserviceDetails);
        Map<String, String> phoneMap = ContactPhoneEmailValidateUtility.processSinglePhoneResponse(testPhoneRes, testCustContactToInsert.Phone, mapPhoneNumberToFieldNm, mapPhoneNumberWithoutCountryCodeToFieldNm);
        
        ContactPhoneEmailValidate.makeCallout = false;
        ContactPhoneEmailValidate.contactPhoneStatusmap = mapPhoneStatus;
        System.enqueueJob(new ContactPhoneEmailValidate(mapContactFieldName, testCustContactToInsert.Id, mapPhoneNumberToFieldNm, mapPhoneNumberWithoutCountryCodeToFieldNm, mapEmailIdsToFieldName, contPhoneInformaticaWebserviceDetails ,contEmailInformaticaWebserviceDetails));
        test.stopTest();
        
        Contact checkContact = [SELECT Id, Name, Phone, Email_Phone_Verification_Results__c FROM Contact WHERE Id =: testCustContactToInsert.Id LIMIT 1];
        System.assertEquals(strPhone, checkContact.Phone, 'Contact Phone does not match');
    }
    
    /* Contact with Multiple Phone Unit Test */
    static testmethod void TestContactWithAllValidPhone() {
        String strPhone = '+91 8046562674';
        String strMobilePhone = '+91 7250000750';
        String strOtherPhone = '+91 8046562677';
        String strFax = '+91 8046562678';
        String strPhoneWithoutCountry = '8046562678';
        String strEmail = 'test_cust_email'+ Math.random()+'@gmail.com';//SFSE-9907
        
        Contact_Informatica_Webservice__mdt contPhoneInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
        Contact_Informatica_Webservice__mdt contEmailInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
        List<Contact_Informatica_Webservice__mdt> lstContactInformaticaWebservice = [SELECT Chatter_UserName__c, License_Key__c, Label, DeveloperName, Active__c, Host_Name__c, Query_Path__c, Record_Type__c, Timeout__c, Send_Chatter_Post__c, Send_Email_To_Last_Modified__c 
                                                                                     FROM Contact_Informatica_Webservice__mdt
                                                                                     WHERE DeveloperName in ('Contact_Phone_Validation','Contact_Email_Validation')];
        
        if (lstContactInformaticaWebservice.size() > 0) {
            for (Contact_Informatica_Webservice__mdt ciw : lstContactInformaticaWebservice) {
                contPhoneInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Phone_Validation') ? ciw : contPhoneInformaticaWebserviceDetails;
                contEmailInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Email_Validation') ? ciw : contEmailInformaticaWebserviceDetails;
            }
        }
        
        Account testClientAccount = [SELECT Id, Name FROM Account LIMIT 1];
        Contact testCustContactToInsert = new Contact();
        testCustContactToInsert.LastName = 'Test Create Contact' + Math.random();
        testCustContactToInsert.FirstName = BrandUtilities.MAERSKLINE ;
        testCustContactToInsert.Phone = strPhone;
        testCustContactToInsert.MobilePhone = strMobilePhone;
        testCustContactToInsert.OtherPhone = strOtherPhone;
        testCustContactToInsert.Fax = strFax;
        testCustContactToInsert.Preferred_Language__c = 'English';
        testCustContactToInsert.Liner_Brands__c = BrandUtilities.MAERSKLINE ;
        testCustContactToInsert.RecordTypeId = Label.Customer_Contact_Record_Type;
        testCustContactToInsert.AccountId = testClientAccount.Id;
        testCustContactToInsert.Email = strEmail.toLowerCase();//SFSE - 9907
        insert testCustContactToInsert;
        
        Map<Id, Contact> mapContactFieldName = new Map<Id, Contact>();
        mapContactFieldName.put(testCustContactToInsert.Id,testCustContactToInsert);
        Map<String, String> mapPhoneNumberToFieldNm = new  Map<String, String>();
        mapPhoneNumberToFieldNm.put(testCustContactToInsert.Phone.replace('+','').deleteWhitespace(),'Phone');
        mapPhoneNumberToFieldNm.put(testCustContactToInsert.MobilePhone.replace('+','').deleteWhitespace(),'MobilePhone');
        mapPhoneNumberToFieldNm.put(testCustContactToInsert.OtherPhone.replace('+','').deleteWhitespace(),'OtherPhone');
        mapPhoneNumberToFieldNm.put(testCustContactToInsert.Fax.replace('+','').deleteWhitespace(),'Fax');
        
        Map<String, String> mapPhoneNumberWithoutCountryCodeToFieldNm = new Map<String, String>();
        mapPhoneNumberWithoutCountryCodeToFieldNm.put(strPhoneWithoutCountry, 'Phone');
        Map<String, String> mapEmailIdsToFieldName = new Map<String, String>();
        Map<String, String> mapPhoneStatus = new Map<String, String>();
        mapPhoneStatus.put(testCustContactToInsert.Phone.replace('+','').deleteWhitespace(), Label.Informatica_Phone_Valid_Description);
        mapPhoneStatus.put(testCustContactToInsert.MobilePhone.replace('+','').deleteWhitespace(), Label.Informatica_Phone_Valid_Description);
        mapPhoneStatus.put(testCustContactToInsert.OtherPhone, Label.Informatica_Phone_Valid_Description);
        mapPhoneStatus.put(testCustContactToInsert.Fax.replace('+','').deleteWhitespace(), Label.Informatica_Phone_Valid_Description);
        
        List<String> lstPhone = new List<String>();
        lstPhone.add(testCustContactToInsert.Phone);
        lstPhone.add(testCustContactToInsert.MobilePhone);
        lstPhone.add(testCustContactToInsert.OtherPhone);
        lstPhone.add(testCustContactToInsert.Fax);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ContactPhoneMultiMockHttpResponse());
        HttpResponse testPhoneMultiRes = ContactPhoneEmailValidateUtility.getPhoneValidationResponse(lstPhone, contPhoneInformaticaWebserviceDetails);
        Map<String, String> phoneMultiMap = ContactPhoneEmailValidateUtility.processMultiplePhoneResponse(testPhoneMultiRes, lstPhone, mapPhoneNumberToFieldNm, mapPhoneNumberWithoutCountryCodeToFieldNm);
        
        ContactPhoneEmailValidate.makeCallout = false;
        ContactPhoneEmailValidate.contactPhoneStatusmap = mapPhoneStatus;
        System.enqueueJob(new ContactPhoneEmailValidate(mapContactFieldName, testCustContactToInsert.Id, mapPhoneNumberToFieldNm, mapPhoneNumberWithoutCountryCodeToFieldNm, mapEmailIdsToFieldName, contPhoneInformaticaWebserviceDetails ,contEmailInformaticaWebserviceDetails));
        test.stopTest();
        
        Contact checkContact = [SELECT Id, Name, Phone, MobilePhone, OtherPhone, Fax, Email_Phone_Verification_Results__c FROM Contact WHERE Id =: testCustContactToInsert.Id LIMIT 1];
        System.assertEquals(strPhone, checkContact.Phone, 'Contact Phone does not match');
        System.assertEquals(strMobilePhone, checkContact.MobilePhone, 'Contact MobilePhone does not match');
        System.assertEquals(strOtherPhone, checkContact.OtherPhone, 'Contact OtherPhone does not match');
        System.assertEquals(strFax, checkContact.Fax, 'Contact Fax does not match');
    }
    
    static testmethod void TestContactWithAllPhone_ServiceUnavailable() {
        String strPhone = '+91 8046562674';
        String strPhoneWithoutCountry = '8046562678';
        String strMobilePhone = '+91 7250000750';
        String strOtherPhone = '+91 8046562677';
        String strFax = '+91 8046562678';
        String strEmail = 'test_cust_email'+ Math.random()+'@gmail.com';//SFSE-9907
        
        Contact_Informatica_Webservice__mdt contPhoneInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
        Contact_Informatica_Webservice__mdt contEmailInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
        List<Contact_Informatica_Webservice__mdt> lstContactInformaticaWebservice = [SELECT Chatter_UserName__c, License_Key__c, Label, DeveloperName, Active__c, Host_Name__c, Query_Path__c, Record_Type__c, Timeout__c, Send_Chatter_Post__c, Send_Email_To_Last_Modified__c 
                                                                                     FROM Contact_Informatica_Webservice__mdt
                                                                                     WHERE DeveloperName in ('Contact_Phone_Validation','Contact_Email_Validation')];
        
        if (lstContactInformaticaWebservice.size() > 0) {
            for (Contact_Informatica_Webservice__mdt ciw : lstContactInformaticaWebservice) {
                contPhoneInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Phone_Validation') ? ciw : contPhoneInformaticaWebserviceDetails;
                contEmailInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Email_Validation') ? ciw : contEmailInformaticaWebserviceDetails;
            }
        }
        
        Account testClientAccount = [SELECT Id, Name FROM Account LIMIT 1];
        Contact testCustContactToInsert = new Contact();
        testCustContactToInsert.LastName = 'Test Create Contact' + Math.random();
        testCustContactToInsert.FirstName = BrandUtilities.MAERSKLINE ;
        testCustContactToInsert.Phone = strPhone;
        testCustContactToInsert.MobilePhone = strMobilePhone;
        testCustContactToInsert.OtherPhone = strOtherPhone;
        testCustContactToInsert.Fax = strFax;
        testCustContactToInsert.Preferred_Language__c = 'English';
        testCustContactToInsert.Liner_Brands__c = BrandUtilities.MAERSKLINE ;
        testCustContactToInsert.RecordTypeId = Label.Customer_Contact_Record_Type;
        testCustContactToInsert.AccountId = testClientAccount.Id;
        testCustContactToInsert.Email = strEmail.toLowerCase();//SFSE - 9907
        insert testCustContactToInsert;
        
        Map<Id, Contact> mapContactFieldName = new Map<Id, Contact>();
        mapContactFieldName.put(testCustContactToInsert.Id,testCustContactToInsert);
        
        Map<String, String> mapPhoneNumberToFieldNm = new  Map<String, String>();
        mapPhoneNumberToFieldNm.put(testCustContactToInsert.Phone.replace('+','').deleteWhitespace(),'Phone');
        mapPhoneNumberToFieldNm.put(testCustContactToInsert.MobilePhone.replace('+','').deleteWhitespace(),'MobilePhone');
        mapPhoneNumberToFieldNm.put(testCustContactToInsert.OtherPhone.replace('+','').deleteWhitespace(),'OtherPhone');
        mapPhoneNumberToFieldNm.put(testCustContactToInsert.Fax.replace('+','').deleteWhitespace(),'Fax');
        
        Map<String, String> mapPhoneNumberWithoutCountryCodeToFieldNm = new Map<String, String>();
        mapPhoneNumberWithoutCountryCodeToFieldNm.put(strPhoneWithoutCountry, 'Phone');
        Map<String, String> mapEmailIdsToFieldName = new Map<String, String>();
        Map<String, String> mapPhoneStatus = new Map<String, String>();
        mapPhoneStatus.put(testCustContactToInsert.Phone.replace('+','').deleteWhitespace(), Label.Informatica_Service_Status_Unavailable);
        mapPhoneStatus.put(testCustContactToInsert.MobilePhone.replace('+','').deleteWhitespace(), Label.Informatica_Service_Status_Unavailable);
        mapPhoneStatus.put(testCustContactToInsert.OtherPhone.replace('+','').deleteWhitespace(), Label.Informatica_Service_Status_Unavailable);
        mapPhoneStatus.put(testCustContactToInsert.Fax.replace('+','').deleteWhitespace(), Label.Informatica_Service_Status_Unavailable);
        
        List<String> lstPhone = new List<String>();
        lstPhone.add(testCustContactToInsert.Phone);
        lstPhone.add(testCustContactToInsert.MobilePhone);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ContactPhoneMultiMockHttpResponse());
        HttpResponse testPhoneMultiRes = ContactPhoneEmailValidateUtility.getPhoneValidationResponse(lstPhone, contPhoneInformaticaWebserviceDetails);
        Map<String, String> phoneMultiMap = ContactPhoneEmailValidateUtility.processMultiplePhoneResponse(testPhoneMultiRes, lstPhone, mapPhoneNumberToFieldNm, mapPhoneNumberWithoutCountryCodeToFieldNm);
        
        ContactPhoneEmailValidate.makeCallout = false;
        ContactPhoneEmailValidate.contactPhoneStatusmap = mapPhoneStatus;
        System.enqueueJob(new ContactPhoneEmailValidate(mapContactFieldName, testCustContactToInsert.Id, mapPhoneNumberToFieldNm, mapPhoneNumberWithoutCountryCodeToFieldNm, mapEmailIdsToFieldName, contPhoneInformaticaWebserviceDetails ,contEmailInformaticaWebserviceDetails));
        test.stopTest();
        
        Contact checkContact = [SELECT Id, Name, Phone, MobilePhone, OtherPhone, Fax, Email_Phone_Verification_Results__c FROM Contact WHERE Id =: testCustContactToInsert.Id LIMIT 1];
        System.assertEquals(strPhone, checkContact.Phone, 'Contact Phone does not match');
        System.assertEquals(strMobilePhone, checkContact.MobilePhone, 'Contact MobilePhone does not match');
        System.assertEquals(strOtherPhone, checkContact.OtherPhone, 'Contact OtherPhone does not match');
        System.assertEquals(strFax, checkContact.Fax, 'Contact Fax does not match');
    } 
    
    static testmethod void TestContactWithValidPhoneAndInvalidPhones() {
        String strPhone = '+91 8046562674';
        String strPhoneWithoutCountry = '8046562678';
        String strMobilePhone = '+91 7250000750';
        String strOtherPhone = '+91 8046562677';
        String strFax = '+91 8046562678'; 
        String strEmail = 'test_cust_email'+ Math.random()+'@gmail.com';//SFSE-9907
        
        Contact_Informatica_Webservice__mdt contPhoneInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
        Contact_Informatica_Webservice__mdt contEmailInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
        List<Contact_Informatica_Webservice__mdt> lstContactInformaticaWebservice = [SELECT Chatter_UserName__c, License_Key__c, Label, DeveloperName, Active__c, Host_Name__c, Query_Path__c, Record_Type__c, Timeout__c, Send_Chatter_Post__c, Send_Email_To_Last_Modified__c 
                                                                                     FROM Contact_Informatica_Webservice__mdt
                                                                                     WHERE DeveloperName in ('Contact_Phone_Validation','Contact_Email_Validation')];
        
        if (lstContactInformaticaWebservice.size() > 0) {
            for (Contact_Informatica_Webservice__mdt ciw : lstContactInformaticaWebservice) {
                contPhoneInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Phone_Validation') ? ciw : contPhoneInformaticaWebserviceDetails;
                contEmailInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Email_Validation') ? ciw : contEmailInformaticaWebserviceDetails;
            }
        }
        
        Account testClientAccount = [SELECT Id, Name FROM Account LIMIT 1];
        Contact testCustContactToInsert = new Contact();
        testCustContactToInsert.LastName = 'Test Create Contact' + Math.random();
        testCustContactToInsert.FirstName = BrandUtilities.MAERSKLINE ;
        testCustContactToInsert.Phone = strPhone;
        testCustContactToInsert.MobilePhone = strMobilePhone;
        testCustContactToInsert.OtherPhone = strOtherPhone;
        testCustContactToInsert.Fax = strFax;
        testCustContactToInsert.Preferred_Language__c = 'English';
        testCustContactToInsert.Liner_Brands__c = BrandUtilities.MAERSKLINE ;
        testCustContactToInsert.RecordTypeId = Label.Customer_Contact_Record_Type;
        testCustContactToInsert.AccountId = testClientAccount.Id;
        testCustContactToInsert.Email = strEmail.toLowerCase();//SFSE - 9907
        insert testCustContactToInsert;
        Map<Id, Contact> mapContactFieldName = new Map<Id, Contact>();
        mapContactFieldName.put(testCustContactToInsert.Id,testCustContactToInsert);
        Map<String, String> mapPhoneNumberToFieldNm = new  Map<String, String>();
        mapPhoneNumberToFieldNm.put(testCustContactToInsert.Phone.replace('+','').deleteWhitespace(),'Phone');
        mapPhoneNumberToFieldNm.put(testCustContactToInsert.MobilePhone.replace('+','').deleteWhitespace(),'MobilePhone');
        mapPhoneNumberToFieldNm.put(testCustContactToInsert.OtherPhone.replace('+','').deleteWhitespace(),'OtherPhone');
        mapPhoneNumberToFieldNm.put(testCustContactToInsert.Fax.replace('+','').deleteWhitespace(),'Fax');
        
        Map<String, String> mapPhoneStatus = new Map<String, String>();
        mapPhoneStatus.put(testCustContactToInsert.Phone.replace('+','').deleteWhitespace(), Label.Informatica_Phone_Valid_Description);
        mapPhoneStatus.put(testCustContactToInsert.MobilePhone.replace('+','').deleteWhitespace(), Label.Informatica_Phone_Invalid_Description);
        mapPhoneStatus.put(testCustContactToInsert.OtherPhone.replace('+','').deleteWhitespace(), Label.Informatica_Phone_Invalid_Description);
        mapPhoneStatus.put(testCustContactToInsert.Fax.replace('+','').deleteWhitespace(), Label.Informatica_Phone_Invalid_Description);
        List<String> lstPhone = new List<String>();
        lstPhone.add(testCustContactToInsert.Phone);
        lstPhone.add(testCustContactToInsert.MobilePhone);
        
        Map<String, String> mapEmailIdsToFieldName = new Map<String, String>();
        Map<String, String> mapPhoneNumberWithoutCountryCodeToFieldNm = new Map<String, String>();
        mapPhoneNumberWithoutCountryCodeToFieldNm.put(strPhoneWithoutCountry, 'Phone');
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ContactPhoneMultiMockHttpResponse());
        HttpResponse testPhoneMultiRes = ContactPhoneEmailValidateUtility.getPhoneValidationResponse(lstPhone, contPhoneInformaticaWebserviceDetails);
        Map<String, String> phoneMultiMap = ContactPhoneEmailValidateUtility.processMultiplePhoneResponse(testPhoneMultiRes, lstPhone, mapPhoneNumberToFieldNm, mapPhoneNumberWithoutCountryCodeToFieldNm);
        
        ContactPhoneEmailValidate.makeCallout = false;
        ContactPhoneEmailValidate.contactPhoneStatusmap = mapPhoneStatus;
        System.enqueueJob(new ContactPhoneEmailValidate(mapContactFieldName, testCustContactToInsert.Id, mapPhoneNumberToFieldNm, mapPhoneNumberWithoutCountryCodeToFieldNm, mapEmailIdsToFieldName, contPhoneInformaticaWebserviceDetails ,contEmailInformaticaWebserviceDetails));
        test.stopTest();
        
        Contact checkContact = [SELECT Id, Name, Phone, MobilePhone, OtherPhone, Fax, Email_Phone_Verification_Results__c FROM Contact WHERE Id =: testCustContactToInsert.Id LIMIT 1];
        System.assertEquals(strPhone, checkContact.Phone, 'Contact Phone does not match');
        System.assertEquals(checkContact.MobilePhone, checkContact.MobilePhone, 'Contact MobilePhone does not match');
        System.assertEquals(checkContact.OtherPhone, checkContact.OtherPhone, 'Contact OtherPhone does not match');
        System.assertEquals(checkContact.Fax, checkContact.Fax, 'Contact MobilePhone does not match');
    }
    
    static testmethod void TestContactWithAllInvalidPhone() {
        String strPhone = '+91 8046562674';
        String strPhoneWithoutCountry = '8046562678';
        String strMobilePhone = '+91 7250000750';
        String strOtherPhone = '+91 8046562677';
        String strFax = '+91 8046562678';
        String strEmail = 'test_cust_email'+ Math.random()+'@gmail.com';//SFSE-9907
        
        Contact_Informatica_Webservice__mdt contPhoneInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
        Contact_Informatica_Webservice__mdt contEmailInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
        List<Contact_Informatica_Webservice__mdt> lstContactInformaticaWebservice = [SELECT Chatter_UserName__c, License_Key__c, Label, DeveloperName, Active__c, Host_Name__c, Query_Path__c, Record_Type__c, Timeout__c, Send_Chatter_Post__c, Send_Email_To_Last_Modified__c 
                                                                                     FROM Contact_Informatica_Webservice__mdt
                                                                                     WHERE DeveloperName in ('Contact_Phone_Validation','Contact_Email_Validation')];
        
        if (lstContactInformaticaWebservice.size() > 0) {
            for (Contact_Informatica_Webservice__mdt ciw : lstContactInformaticaWebservice) {
                contPhoneInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Phone_Validation') ? ciw : contPhoneInformaticaWebserviceDetails;
                contEmailInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Email_Validation') ? ciw : contEmailInformaticaWebserviceDetails;
            }
        }
        
        Account testClientAccount = [SELECT Id, Name FROM Account LIMIT 1];
        Contact testCustContactToInsert = new Contact();
        testCustContactToInsert.LastName = 'Test Create Contact' + Math.random();
        testCustContactToInsert.FirstName = BrandUtilities.MAERSKLINE ;
        testCustContactToInsert.Phone = strPhone;
        testCustContactToInsert.MobilePhone = strMobilePhone;
        testCustContactToInsert.OtherPhone = strOtherPhone;
        testCustContactToInsert.Fax = strFax;
        testCustContactToInsert.Preferred_Language__c = 'English';
        testCustContactToInsert.Liner_Brands__c = BrandUtilities.MAERSKLINE ;
        testCustContactToInsert.RecordTypeId = Label.Customer_Contact_Record_Type;
        testCustContactToInsert.AccountId = testClientAccount.Id;
        testCustContactToInsert.Email = strEmail.toLowerCase();//SFSE - 9907
        insert testCustContactToInsert;
        Map<Id, Contact> mapContactFieldName = new Map<Id, Contact>();
        mapContactFieldName.put(testCustContactToInsert.Id,testCustContactToInsert);
        
        Map<String, String> mapPhoneNumberToFieldNm = new  Map<String, String>();
        mapPhoneNumberToFieldNm.put(testCustContactToInsert.Phone.replace('+','').deleteWhitespace(),'Phone');
        mapPhoneNumberToFieldNm.put(testCustContactToInsert.MobilePhone.replace('+','').deleteWhitespace(),'MobilePhone');
        mapPhoneNumberToFieldNm.put(testCustContactToInsert.OtherPhone.replace('+','').deleteWhitespace(),'OtherPhone');
        mapPhoneNumberToFieldNm.put(testCustContactToInsert.Fax.replace('+','').deleteWhitespace(),'Fax');
        
        Map<String, String> mapPhoneNumberWithoutCountryCodeToFieldNm = new Map<String, String>();
        mapPhoneNumberWithoutCountryCodeToFieldNm.put(strPhoneWithoutCountry, 'Phone');
        Map<String, String> mapEmailIdsToFieldName = new Map<String, String>();
        Map<String, String> mapPhoneStatus = new Map<String, String>();
        mapPhoneStatus.put(testCustContactToInsert.Phone.replace('+','').deleteWhitespace(), Label.Informatica_Phone_Invalid_Description);
        mapPhoneStatus.put(testCustContactToInsert.MobilePhone.replace('+','').deleteWhitespace(), Label.Informatica_Phone_Invalid_Description);
        mapPhoneStatus.put(testCustContactToInsert.OtherPhone.replace('+','').deleteWhitespace(), Label.Informatica_Phone_Invalid_Description);
        mapPhoneStatus.put(testCustContactToInsert.Fax.replace('+','').deleteWhitespace(), Label.Informatica_Phone_Invalid_Description);
        
        List<String> lstPhone = new List<String>();
        lstPhone.add(testCustContactToInsert.Phone);
        lstPhone.add(testCustContactToInsert.MobilePhone);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ContactPhoneMultiMockHttpResponse());
        HttpResponse testPhoneMultiRes = ContactPhoneEmailValidateUtility.getPhoneValidationResponse(lstPhone, contPhoneInformaticaWebserviceDetails);
        Map<String, String> phoneMultiMap = ContactPhoneEmailValidateUtility.processMultiplePhoneResponse(testPhoneMultiRes, lstPhone, mapPhoneNumberToFieldNm, mapPhoneNumberWithoutCountryCodeToFieldNm);
        
        ContactPhoneEmailValidate.makeCallout = false;
        ContactPhoneEmailValidate.contactPhoneStatusmap = mapPhoneStatus;
        System.enqueueJob(new ContactPhoneEmailValidate(mapContactFieldName, testCustContactToInsert.Id, mapPhoneNumberToFieldNm, mapPhoneNumberWithoutCountryCodeToFieldNm, mapEmailIdsToFieldName, contPhoneInformaticaWebserviceDetails ,contEmailInformaticaWebserviceDetails));
        test.stopTest();
        
        Contact checkContact = [SELECT Id, Name, Phone, MobilePhone, OtherPhone, Fax, Email_Phone_Verification_Results__c FROM Contact WHERE Id =: testCustContactToInsert.Id LIMIT 1];
        System.assertEquals(strPhone, checkContact.Phone, 'Contact Phone does not match');
        System.assertEquals(strMobilePhone, checkContact.MobilePhone, 'Contact MobilePhone does not match');
        System.assertEquals(strOtherPhone, checkContact.OtherPhone, 'Contact OtherPhone does not match');
        System.assertEquals(strFax, checkContact.Fax, 'Contact Fax does not match');
    }
    
    /* Unit test to check Update*/
    static testmethod void TestContactWithValidEmailAfterupdate() {
        
        String strEmail = 'test_cust_email'+ Math.random()+'@gmail.com';
        //String strOtherEmail = 'test_cust_otheremail'+ Math.random()+'@gmail.com';
        
        Contact_Informatica_Webservice__mdt contPhoneInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
        Contact_Informatica_Webservice__mdt contEmailInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
        List<Contact_Informatica_Webservice__mdt> lstContactInformaticaWebservice = [SELECT Chatter_UserName__c, License_Key__c, Label, DeveloperName, Active__c, Host_Name__c, Query_Path__c, Record_Type__c, Timeout__c, Send_Chatter_Post__c, Send_Email_To_Last_Modified__c FROM Contact_Informatica_Webservice__mdt
                                                                                     WHERE DeveloperName in ('Contact_Phone_Validation','Contact_Email_Validation')];
        
        if (lstContactInformaticaWebservice.size() > 0) {
            for (Contact_Informatica_Webservice__mdt ciw : lstContactInformaticaWebservice) {
                contPhoneInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Phone_Validation') ? ciw : contPhoneInformaticaWebserviceDetails;
                contEmailInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Email_Validation') ? ciw : contEmailInformaticaWebserviceDetails;
            }
        }
        
        Account testClientAccount = [SELECT Id, Name FROM Account LIMIT 1];
        Contact testContact = [SELECT Id, Name, Email FROM Contact LIMIT 1];
        String strEmailBeforeUpdate = testContact.Email;
        testContact.Email = strEmail.toLowerCase();
        
        update testContact;
        Map<Id, Contact> mapContactFieldName = new Map<Id, Contact>();
        mapContactFieldName.put(testContact.Id,testContact);
        
        Map<String, String> mapPhoneNumberToFieldNm = new  Map<String, String>();
        Map<String, String> mapPhoneNumberWithoutCountryCodeToFieldNm = new Map<String, String>();
        Map<String, String> mapEmailIdsToFieldName = new Map<String, String>();
        mapEmailIdsToFieldName.put(testContact.Email,'Email');
        //mapEmailIdsToFieldName.put(testContact.Duplicate_Email__c,'Duplicate_Email__c');
        
        Map<String, String> mapEmailStatus = new Map<String, String>();
        mapEmailStatus.put(testContact.Email, Label.Informatica_Email_Valid_Description);
        //mapEmailStatus.put(testContact.Duplicate_Email__c, Label.Informatica_Email_Valid_Description);
        
        List<String> lstPhone = new List<String>();
        //lstPhone.add(testContact.Phone);
        
        test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new ContactEmailMockHttpResponse());
        HttpResponse testEmailRes = ContactPhoneEmailValidateUtility.getEmailValidationResponse(strEmail, contEmailInformaticaWebserviceDetails);
        Map<String, String> emailMap = ContactPhoneEmailValidateUtility.processEmailResponse(testEmailRes, strEmail);
        
        ContactPhoneEmailValidate.makeCallout = false;
        ContactPhoneEmailValidate.contactEmailStatusmap = mapEmailStatus;
        System.enqueueJob(new ContactPhoneEmailValidate(mapContactFieldName, testContact.Id, mapPhoneNumberToFieldNm, mapPhoneNumberWithoutCountryCodeToFieldNm, mapEmailIdsToFieldName, contPhoneInformaticaWebserviceDetails ,contEmailInformaticaWebserviceDetails));
        test.stopTest();
        
        Contact checkContact = [SELECT Id, Name, Email, Email_Phone_Verification_Results__c FROM Contact WHERE Id = :testContact.Id LIMIT 1];
        
        system.assertEquals(strEmail, checkContact.Email);
        system.assertNotEquals(strEmailBeforeUpdate, checkContact.Email);
    }
}