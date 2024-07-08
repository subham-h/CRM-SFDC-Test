/**
 * Description  : Test Class For Get NBA Recommendation
 * 
 * Version       Date                Owner                                         Description
*******************************************************************************************************************
 * v1.0          24/04/2021          Sunil.bs@maersk.com                           Test Scenario to cover Recommendation records return
 * v2.0          27/06/2022          Ronnie@SF                                     Removed brand hardcoding
*-------------------------------------------------------------------------------------------------------------------
*/

@isTest
public class caseGetNBARecommendations_Test {
    
    @isTest
    public static void  testCaseGetNBARecommendations(){
        TriggerExecutionController.skipAllTriggers(true);
        Geography__c geography = TestBusinessHelper.createGeography('Denmark', 'Country', null, true);
        
        Account acc = TestBusinessHelper.createAccount('Client_Account', false);
        acc.Id = null;
        acc.Name = 'Test Account';
        acc.Country__c = geography.Id;
        insert acc;
        
        Contact con = TestBusinessHelper.createContact(acc, 'Customer_Contact', BrandUtilities.MAERSKLINE, false);
        con.Id = null;
        con.Country__c = acc.Country__c;
        con.Phone = '+45 12345678';
        insert con;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 234559625';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        cs.Type = 'Cargo/Container'; 
        cs.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        cs.Sub_Type__c = 'Container Status';
        cs.Reason_For_Case__c = 'Container Maritime Tracking Request';
        insert cs;
        
        caseGetNBARecommendations.recombasedonRFC inputereq = new caseGetNBARecommendations.recombasedonRFC();
        list<caseGetNBARecommendations.recombasedonRFC> inputereqlist = new list<caseGetNBARecommendations.recombasedonRFC>();
        inputereq.caseId = cs.id;
        inputereqlist.add(inputereq);
        
        List<List<Recommendation>> reclistoflist = new List<List<Recommendation>>();
        reclistoflist =  caseGetNBARecommendations.GetNextBestActionRecommendations(inputereqlist);
        
        // To cover Invoice Enquiry recommendation & Invoice Email Correction
        Test.startTest();
        cs.Type = 'Charges, Invoice & Payment';
        cs.Sub_Type__c = 'Invoice / Payer Party';
        cs.Reason_For_Case__c = 'Add Export Payer Rule';
        update cs;
        Test.stopTest();
        reclistoflist =  caseGetNBARecommendations.GetNextBestActionRecommendations(inputereqlist);
    }
    
    @isTest
    public static void testBillOfLading(){
        Test.startTest();
        
        TriggerExecutionController.skipAllTriggers(true);
        Geography__c geography = TestBusinessHelper.createGeography('Denmark', 'Country', null, true);
        
        Account acc = TestBusinessHelper.createAccount('Client_Account', false);
        acc.Id = null;
        acc.Name = 'Test Account';
        acc.Country__c = geography.Id;
        insert acc;
        
        Contact con = TestBusinessHelper.createContact(acc, 'Customer_Contact', BrandUtilities.MAERSKLINE, false);
        con.Id = null;
        con.Country__c = acc.Country__c;
        con.Phone = '+45 12345678';
        insert con;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 234559625';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        cs.Type = 'Documentation'; 
        cs.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        cs.Sub_Type__c = 'Submit SI/BL/VC';
        cs.Reason_For_Case__c = 'Amend Shipping Instructions';
        insert cs;
        
        caseGetNBARecommendations.recombasedonRFC inputereq = new caseGetNBARecommendations.recombasedonRFC();
        list<caseGetNBARecommendations.recombasedonRFC> inputereqlist = new list<caseGetNBARecommendations.recombasedonRFC>();
        inputereq.caseId = cs.id;
        inputereqlist.add(inputereq);
        
        List<List<Recommendation>> reclistoflist = new List<List<Recommendation>>();
        reclistoflist =  caseGetNBARecommendations.GetNextBestActionRecommendations(inputereqlist);
    }
    
    @isTest
    public static void testAmendBillOfLading(){
        Test.startTest();
        
        TriggerExecutionController.skipAllTriggers(true);
        Geography__c geography = TestBusinessHelper.createGeography('Denmark', 'Country', null, true);
        
        Account acc = TestBusinessHelper.createAccount('Client_Account', false);
        acc.Id = null;
        acc.Name = 'Test Account';
        acc.Country__c = geography.Id;
        insert acc;
        
        Contact con = TestBusinessHelper.createContact(acc, 'Customer_Contact', BrandUtilities.MAERSKLINE, false);
        con.Id = null;
        con.Country__c = acc.Country__c;
        con.Phone = '+45 12345678';
        insert con;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 234559625';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        cs.Type = 'Documentation'; 
        cs.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        cs.Sub_Type__c = 'Amend SI/BL/VC';
        cs.Reason_For_Case__c = 'Request Switch Bill';
        insert cs;
        
        caseGetNBARecommendations.recombasedonRFC inputereq = new caseGetNBARecommendations.recombasedonRFC();
        list<caseGetNBARecommendations.recombasedonRFC> inputereqlist = new list<caseGetNBARecommendations.recombasedonRFC>();
        inputereq.caseId = cs.id;
        inputereqlist.add(inputereq);
        
        List<List<Recommendation>> reclistoflist = new List<List<Recommendation>>();
        reclistoflist =  caseGetNBARecommendations.GetNextBestActionRecommendations(inputereqlist);
    }
    
    @isTest
    public static void testBookingConfirmation(){
        Test.startTest();
        
        TriggerExecutionController.skipAllTriggers(true);
        Geography__c geography = TestBusinessHelper.createGeography('Denmark', 'Country', null, true);
        
        Account acc = TestBusinessHelper.createAccount('Client_Account', false);
        acc.Id = null;
        acc.Name = 'Test Account';
        acc.Country__c = geography.Id;
        insert acc;
        
        Contact con = TestBusinessHelper.createContact(acc, 'Customer_Contact', BrandUtilities.MAERSKLINE, false);
        con.Id = null;
        con.Country__c = acc.Country__c;
        con.Phone = '+45 12345678';
        insert con;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 234559625';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        cs.Type = 'Booking'; 
        cs.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        cs.Sub_Type__c = 'Booking Confirmation Request';
        insert cs;
        
        caseGetNBARecommendations.recombasedonRFC inputereq = new caseGetNBARecommendations.recombasedonRFC();
        list<caseGetNBARecommendations.recombasedonRFC> inputereqlist = new list<caseGetNBARecommendations.recombasedonRFC>();
        inputereq.caseId = cs.id;
        inputereqlist.add(inputereq);
        
        List<List<Recommendation>> reclistoflist = new List<List<Recommendation>>();
        reclistoflist =  caseGetNBARecommendations.GetNextBestActionRecommendations(inputereqlist);
    }
    
    @isTest
    public static void testInvoice(){
        Test.startTest();
        
        TriggerExecutionController.skipAllTriggers(true);
        Geography__c geography = TestBusinessHelper.createGeography('Denmark', 'Country', null, true);
        
        Account acc = TestBusinessHelper.createAccount('Client_Account', false);
        acc.Id = null;
        acc.Name = 'Test Account';
        acc.Country__c = geography.Id;
        insert acc;
        
        Contact con = TestBusinessHelper.createContact(acc, 'Customer_Contact', BrandUtilities.MAERSKLINE, false);
        con.Id = null;
        con.Country__c = acc.Country__c;
        con.Phone = '+45 12345678';
        insert con;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 234559625';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        cs.Type = 'Charges, Invoice & Payment'; 
        cs.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        cs.Sub_Type__c = 'Invoice / Payer Party';
        insert cs;
        
        caseGetNBARecommendations.recombasedonRFC inputereq = new caseGetNBARecommendations.recombasedonRFC();
        list<caseGetNBARecommendations.recombasedonRFC> inputereqlist = new list<caseGetNBARecommendations.recombasedonRFC>();
        inputereq.caseId = cs.id;
        inputereqlist.add(inputereq);
        
        List<List<Recommendation>> reclistoflist = new List<List<Recommendation>>();
        reclistoflist =  caseGetNBARecommendations.GetNextBestActionRecommendations(inputereqlist);
    }
    
    @isTest
    public static void testTransportNotification(){
        Test.startTest();
        
        TriggerExecutionController.skipAllTriggers(true);
        Geography__c geography = TestBusinessHelper.createGeography('Denmark', 'Country', null, true);
        
        Account acc = TestBusinessHelper.createAccount('Client_Account', false);
        acc.Id = null;
        acc.Name = 'Test Account';
        acc.Country__c = geography.Id;
        insert acc;
        
        Contact con = TestBusinessHelper.createContact(acc, 'Customer_Contact', BrandUtilities.MAERSKLINE, false);
        con.Id = null;
        con.Country__c = acc.Country__c;
        con.Phone = '+45 12345678';
        insert con;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 234559625';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        cs.Product__c = 'Landside Transportation';
        cs.Type = 'Transportation'; 
        cs.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        cs.Sub_Type__c = 'Container Status';
        insert cs;
        
        caseGetNBARecommendations.recombasedonRFC inputereq = new caseGetNBARecommendations.recombasedonRFC();
        list<caseGetNBARecommendations.recombasedonRFC> inputereqlist = new list<caseGetNBARecommendations.recombasedonRFC>();
        inputereq.caseId = cs.id;
        inputereqlist.add(inputereq);
        
        List<List<Recommendation>> reclistoflist = new List<List<Recommendation>>();
        reclistoflist =  caseGetNBARecommendations.GetNextBestActionRecommendations(inputereqlist);
    }
    
}