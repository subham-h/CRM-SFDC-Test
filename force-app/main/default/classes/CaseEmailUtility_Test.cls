/**
* Purpose  : Test class for CaseEmailUtility
* 
* Revision     Ref Number      Date         Owner                               Description
* --------     ----------      -----------  -------------------                 -----------
* 1.0         RQ-006949    16/11/2017   Nisha@Ust                              Created
* 2.0         RQ-007847    12-Feb-2018  Nisha@Ust                              Closue email for vendor cases.
* 3.0         SC-556       30-06-2020   Sreya@Maersk                           test_sendSCMEmails() method created.Closure email for SCM cases.
* 4.0         SC-1160      14-10-2020   Sreya@Maersk                           CSAT for LNS BA. 
* 5.0          SC-3706      30-03-2022   Richa@Maersk                        Closue email for Dispute cases. 
* 6.0          SPI-100      27-06-2022   Ronnie@SF                           Removed brand hardcoding
* 7.0		SC-7849		    17-07-2023	 Nayana@maersk						 Added testSendECLEmails() method to test ECL CSAT logic
*/

@isTest
public class CaseEmailUtility_Test {
    
    @testSetup static void createErrLoggerRecords() {
        Error_Log_Configuration__c errorConfig = new Error_Log_Configuration__c();
        errorConfig = new Error_Log_Configuration__c();
        errorConfig.Name = 'Default';
        //errorConfig.Source_System__c = 'SFDC';
        //errorConfig.SFDC_Object_Name__c = 'Contact';
        errorConfig.Total_Errors__c = 0;
        errorConfig.Max_Errors__c = 200;
        errorConfig.Time_Period_Minutes__c = 1;
        
        insert errorConfig;     
    } 
    
    @isTest
    public static void testSendEmails(){
        
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email =  'test@gmail.com';
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list<Case> lstParentCse = new list<Case>();        
        CaseData_Test.createExternalCases();
        lstparentCse =  CaseData_Test.lstCases;
        insert lstParentCse; 
        
        for(Case caseIterator : lstParentCse ){
            caseIterator.Type = 'Booking';
            caseIterator.Sub_Type__c = 'New Booking Request';  
            caseIterator.Reason_For_Case__c = 'Booking Request';
            caseIterator.Resolution_Summary__c = 'Solved';
            caseIterator.Send_Case_Closure__c  = 'Yes';
            caseIterator.Case_Closure_Opt_Out_Reason__c=' ';
            caseIterator.Liner_Brand__c  = BrandUtilities.MCC;
            caseIterator.Country__c = BDAGeographyData_Test.countryRU.Id;
            caseIterator.Status = 'Closed - Resolved';
        }
        Test.startTest();
        update lstParentCse;
        Test.stopTest();
        
        Case c = [Select Id, Count_Case_Outbound_Email__c From Case
                  Where Id =:lstParentCse[0].Id ];
        //System.assertEquals(c.Count_Case_Outbound_Email__c,1);
        
    }
    
    @isTest
    public static void testSendBulkEmails(){
        
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email =  'test@gmail.com';
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 05;
        CaseData_Test.conInstance = conInstance;
        list<Case> lstParentCse = new list<Case>();        
        CaseData_Test.createExternalCases();
        lstparentCse =  CaseData_Test.lstCases;
        insert lstParentCse; 
        List<Id> caseIds = new List<Id>();
        for(Integer i=0;i<05;i++){
            caseIds.add(lstParentCse[i].Id);
            lstParentCse[i].Type = 'Booking';
            lstParentCse[i].Sub_Type__c = 'New Booking Request';  
            lstParentCse[i].Reason_For_Case__c = 'Booking Request';
            lstParentCse[i].Resolution_Summary__c = 'Solved';
            lstParentCse[i].Send_Case_Closure__c  = 'Yes';
            lstParentCse[i].Case_Closure_Opt_Out_Reason__c=' ';
            lstParentCse[i].Liner_Brand__c  = BrandUtilities.MCC;
            lstParentCse[i].Country__c = BDAGeographyData_Test.countryRU.Id;
            lstParentCse[i].Status = 'Closed - Resolved';
        }
        Test.startTest();
        update lstParentCse;
        Test.stopTest();
        List<Case> updatedCase = [Select Id, Count_Case_Outbound_Email__c From Case Where Id In:caseIds]; 
        // for(Integer i=0;i<15;i++){
        //System.assertEquals(updatedCase[i].Count_Case_Outbound_Email__c,1);
        // }     
    }
    
    @isTest
    public static void test_notSendEmails(){
        
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email =  'test@gmail.com';
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list<Case> lstParentCse = new list<Case>();        
        CaseData_Test.createExternalCases();
        lstparentCse =  CaseData_Test.lstCases;
        insert lstParentCse; 
        
        for(Case caseIterator : lstParentCse ){
            caseIterator.Type = 'Booking';
            caseIterator.Sub_Type__c = 'New Booking Request';  
            caseIterator.Reason_For_Case__c = 'Booking Request';
            caseIterator.Resolution_Summary__c = 'Solved';
            caseIterator.Send_Case_Closure__c  = 'Yes';
            caseIterator.Case_Closure_Opt_Out_Reason__c=' ';
            caseIterator.Liner_Brand__c  = BrandUtilities.SEAGO;
            caseIterator.Country__c = BDAGeographyData_Test.countryCH.Id;
            caseIterator.Status = 'Closed - Resolved';
        }
        Test.startTest();
        update lstParentCse;
        Test.stopTest();
        
        /*Case c = [Select Id, Count_Case_Outbound_Email__c From Case Where Id =:lstParentCse[0].Id ];
System.assertEquals(c.Count_Case_Outbound_Email__c,1);*/
        
    }
    
    // v2.0 : #RQ-007847 (Closue email for vendor cases.)
    @isTest
    public static void test_sendBulkEmailsVendorCases(){
        
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createVendorNonShippingPartyAccounts();
        Account accInstance = AccountData_Test.lstAccounts[0];
        
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email =  'test@gmail.com';
        conInstance.AccountId = accInstance.id;
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 01;
        CaseData_Test.conInstance = conInstance;
        list<Case> lstParentCse = new list<Case>();        
        CaseData_Test.createExternalCases();
        lstparentCse =  CaseData_Test.lstCases;
        insert lstParentCse; 
        list<Id> caseIds = new list<Id>();
        
        for(Integer i=0;i<1;i++){
            caseIds.add(lstParentCse[i].Id);
            lstParentCse[i].Type = 'Booking';
            lstParentCse[i].Sub_Type__c = 'New Booking Request';  
            lstParentCse[i].Reason_For_Case__c = 'Booking Request';
            lstParentCse[i].Resolution_Summary__c = 'Solved';
            lstParentCse[i].Send_Case_Closure__c  = 'Yes';
            lstParentCse[i].Case_Closure_Opt_Out_Reason__c=' ';
            lstParentCse[i].Liner_Brand__c  = BrandUtilities.MCC;
            lstParentCse[i].Country__c = BDAGeographyData_Test.countryUS.Id;
            lstParentCse[i].Status = 'Closed - Resolved';
            lstParentCse[i].Origin = 'MSLUSIMP';
        }
        Test.startTest();
        update lstParentCse;
        Test.stopTest();
        
        List<Case> updatedCase = [Select Id, Count_Case_Outbound_Email__c From Case Where Id In:caseIds]; 
        // for(Integer i=0;i<15;i++){
        //System.assertEquals(updatedCase[i].Count_Case_Outbound_Email__c,1);
        // }     
    }
    
    //SC-556 : testmethod for covering closure email logic for SCM cases.
    @isTest
    public static void testSendSCMEmails(){
        
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email =  'test@gmail.com';
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list<Case> lstParentCse = new list<Case>();        
        CaseData_Test.createExternalCases();
        lstparentCse =  CaseData_Test.lstCases;
        insert lstParentCse; 
        
        for(Case caseIterator : lstParentCse ){
            caseIterator.Product__c = 'SCM';
            caseIterator.Type = 'Carrier booking';
            caseIterator.Sub_Type__c = 'Amend Booking Details';  
            caseIterator.Reason_For_Case__c = 'Amendment initiated by carriers';
            caseIterator.Resolution_Summary__c = 'Solved';
            caseIterator.Send_Case_Closure__c = 'Yes';
            caseIterator.Case_Closure_Opt_Out_Reason__c=' ';
            caseIterator.Liner_Brand__c  = BrandUtilities.MAERSKLS;
            caseIterator.Country__c = BDAGeographyData_Test.countryRU.Id;
            caseIterator.Status = 'Closed - Resolved';
        }
        Test.startTest();
        update lstParentCse;
        Test.stopTest();
    }
    //SC-1160 : testmethod for covering closure email logic for LNS cases.
    @isTest
    public static void testSendLNSEmails(){
        
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email =  'test@gmail.com';
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list<Case> lstParentCse = new list<Case>();        
        CaseData_Test.createLNSCases();
        lstparentCse =  CaseData_Test.lstCases;     
        insert lstParentCse; 
        
        for(Case caseIterator : lstParentCse ){
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Booking';
            caseIterator.Sub_Type__c = 'New Booking Request';  
            caseIterator.Reason_For_Case__c = 'Booking Request';
            caseIterator.Resolution_Summary__c = 'Solved';
            caseIterator.Send_Case_Closure__c = 'Yes';
            caseIterator.Case_Closure_Opt_Out_Reason__c=' ';
            caseIterator.Liner_Brand__c  = BrandUtilities.MAERSKLS;
            caseIterator.Origin ='';
            caseIterator.Country__c = BDAGeographyData_Test.countryUS.Id;
            caseIterator.Direction__c = 'Domestic';
            caseIterator.Status = 'Closed - Resolved';
        }
        Test.startTest();
        lstParentCse[0].Product__c = 'Ocean';
        lstParentCse[0].Type = 'Booking';
        lstParentCse[0].Sub_Type__c = 'New Booking Request';  
        lstParentCse[0].Reason_For_Case__c = 'Booking Request';
        lstParentCse[0].Resolution_Summary__c = 'Solved';
        lstParentCse[0].Send_Case_Closure__c = 'Yes';
        lstParentCse[0].Case_Closure_Opt_Out_Reason__c=' ';
        lstParentCse[0].Liner_Brand__c  = BrandUtilities.MAERSKLS;
        lstParentCse[0].Origin ='';
        lstParentCse[0].Country__c =BDAGeographyData_Test.countryUS.Id;
        lstParentCse[0].Direction__c = 'Domestic';
        lstParentCse[0].Status = 'Closed - Resolved';
        update lstParentCse;
        Test.stopTest();
    }
    
    @isTest
    public static void testSendVenLNSEmails(){
        
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createVendorNonShippingPartyAccounts();
        Account accInstance = AccountData_Test.lstAccounts[0];
        
        
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email =  'test@gmail.com';
        conInstance.AccountId = accInstance.id;
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.conInstance = conInstance;
        list<Case> lstParentCse = new list<Case>();        
        CaseData_Test.createLNSCases();
        lstparentCse =  CaseData_Test.lstCases;
        insert lstParentCse; 
        
        for(Case caseIterator : lstParentCse ){
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Booking';
            caseIterator.Sub_Type__c = 'New Booking Request';  
            caseIterator.Reason_For_Case__c = 'Booking Request';
            caseIterator.Resolution_Summary__c = 'Solved';
            caseIterator.Send_Case_Closure__c = 'Yes';
            caseIterator.Case_Closure_Opt_Out_Reason__c=' ';
            caseIterator.Liner_Brand__c  = BrandUtilities.MAERSKLS;
            caseIterator.Origin ='LNSITEXE';
            caseIterator.Country__c = BDAGeographyData_Test.countryRU.Id;
            caseIterator.Status = 'Closed - Resolved';
        }
        lstParentCse[1].Country__c = BDAGeographyData_Test.countryUS.Id;
        lstParentCse[1].Direction__c = 'Export';
        lstParentCse[1].Origin = null;
        lstParentCse[1].Product__c = 'SCM';
        lstParentCse[1].Type = 'Carrier booking';
        lstParentCse[1].Sub_Type__c = 'Amend Booking Details';  
        lstParentCse[1].Reason_For_Case__c = 'Amendment initiated by carriers';
        Test.startTest();
        update lstParentCse;
        Test.stopTest();
    }
    
    @isTest
    public static void testSEAGLOBALCCL(){
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email =  'test@gmail.com';
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list<Case> lstParentCse = new list<Case>();        
        CaseData_Test.createExternalCases();
        lstparentCse =  CaseData_Test.lstCases;
        insert lstParentCse; 
        
        for(Case caseIterator : lstParentCse ){
            caseIterator.Type = 'Booking';
            caseIterator.Sub_Type__c = 'New Booking Request';  
            caseIterator.Reason_For_Case__c = 'Booking Request';
            caseIterator.Resolution_Summary__c = 'Solved';
            caseIterator.Send_Case_Closure__c  = 'Yes';
            caseIterator.Case_Closure_Opt_Out_Reason__c=' ';
            caseIterator.Liner_Brand__c  = BrandUtilities.SEALAND;//'SEAGLOBALCCL';
            caseIterator.Origin  = BrandUtilities.SEALAND;
            caseIterator.Country__c = BDAGeographyData_Test.countryRU.Id;
            caseIterator.Status = 'Closed - Resolved';
        }
        Test.startTest();
        update lstParentCse;
        Test.stopTest();
    }
    
    //SC-3706 : testmethod for covering closure email logic for Dispute cases.
    @isTest
    public static void testSendDisputeEmails(){
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email =  'test@gmail.com';
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 4;
        CaseData_Test.conInstance = conInstance;
        list<Case> lstParentCse = new list<Case>();        
        CaseData_Test.createDisputeCases();
        lstparentCse =  CaseData_Test.lstCases;
        insert lstParentCse; 
        
        for(Case caseIterator : lstParentCse ){             
            caseIterator.Case_Channel__c = 'E-mail';
            caseIterator.Resolution_Summary__c = 'Solved';
            caseIterator.Send_Case_Closure__c  = 'Yes';
            caseIterator.Case_Closure_Opt_Out_Reason__c=' ';
            caseIterator.Liner_Brand__c  = BrandUtilities.MCC;
            caseIterator.Country__c = BDAGeographyData_Test.countryRU.Id;
            caseIterator.Status = 'Closed - Resolved';
            caseIterator.Resolved_Reason__c = 'Accepted';
            caseIterator.OwnerId = UserInfo.getUserId();
        }
        lstParentCse[1].Liner_Brand__c = BrandUtilities.MAERSKLINE;
        lstParentCse[2].Liner_Brand__c = BrandUtilities.SEALAND;
        lstParentCse[3].Liner_Brand__c = BrandUtilities.SEAGO;
        Test.startTest();
        update lstParentCse;
        Test.stopTest();
        
    }
    
    @isTest
    public static void testSend4plEmails(){
        
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email =  'test@gmail.com';
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.conInstance = conInstance;
        list<Case> lstParentCse = new list<Case>();        
        CaseData_Test.createExternalCases();
        lstparentCse =  CaseData_Test.lstCases;
        insert lstParentCse; 
        
        for(Case caseIterator : lstParentCse ){
            caseIterator.Product__c = '4PL';
            caseIterator.Type = 'Carrier booking';
            caseIterator.Sub_Type__c = 'Amend Booking Details';  
            caseIterator.Reason_For_Case__c = 'Amendment initiated by carriers';
            caseIterator.Resolution_Summary__c = 'Solved';
            caseIterator.Send_Case_Closure__c = 'Yes';
            caseIterator.Case_Closure_Opt_Out_Reason__c=' ';
            caseIterator.Liner_Brand__c  = BrandUtilities.MAERSKLS;
            caseIterator.Country__c = BDAGeographyData_Test.countryRU.Id;
            caseIterator.Status = 'Closed - Resolved';
            caseIterator.Origin = '';
            caseIterator.SF_4PL_Account__c = 'Unilever';
            caseIterator.Case_Visibility__c = '4PL';
        }
        Test.startTest();
        update lstParentCse;
        Test.stopTest();
    }
    
    @isTest
    public static void testSendMultipleRecipients(){
        
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email =  'test@gmail.com';
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list<Case> lstParentCse = new list<Case>();        
        CaseData_Test.createExternalCases();
        lstparentCse =  CaseData_Test.lstCases;
        insert lstParentCse; 
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        insert cv; 
        
        List<ContentVersion> cvList = [Select Id, ContentDocumentId, ContentBodyId From ContentVersion Where Id =: cv.Id];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = lstParentCse[0].Id;
        cdl.ContentDocumentId = cvList[0].ContentDocumentId;
        insert cdl;
        
        String docIds = '[{"name":"TestDocument.pdf","documentId":"'+cvList[0].ContentDocumentId+'","contentVersionId":"'+cvList[0].Id+'","contentBodyId":"'+cvList[0].ContentBodyId+'","mimeType":"image/png"}]';
        for(Case caseIterator : lstParentCse ){
            caseIterator.Type = 'Booking';
            caseIterator.Sub_Type__c = 'New Booking Request';  
            caseIterator.Reason_For_Case__c = 'Booking Request';
            caseIterator.Resolution_Summary__c = 'Solved';
            caseIterator.Send_Case_Closure__c  = 'Yes';
            caseIterator.Case_Closure_Opt_Out_Reason__c=' ';
            caseIterator.Liner_Brand__c  = BrandUtilities.SEAGO;
            caseIterator.Country__c = BDAGeographyData_Test.countryCH.Id;
            caseIterator.Status = 'Closed - Resolved';
            caseIterator.Multiple_Recipients__c = 'test@gmail.com';
            caseIterator.Closure_Content_Document_Ids__c = docIds;
            caseIterator.Additional_Resolution_Summary__c = 'Test Resolution';
        }
        Test.startTest();
        update lstParentCse;
        Test.stopTest();
        
        /*Case c = [Select Id, Count_Case_Outbound_Email__c From Case Where Id =:lstParentCse[0].Id ];
System.assertEquals(c.Count_Case_Outbound_Email__c,1);*/
        
    }
    @isTest
    public static void test_sendEmailsVendorIMDCases(){
        
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createVendorNonShippingPartyAccounts();
        Account accInstance = AccountData_Test.lstAccounts[0];
        
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email =  'test@gmail.com';
        conInstance.AccountId = accInstance.id;
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.conInstance = conInstance;
        list<Case> lstParentCse = new list<Case>();        
        CaseData_Test.createExternalCases();
        lstparentCse =  CaseData_Test.lstCases;
        insert lstParentCse; 
        list<Id> caseIds = new list<Id>();
        
        for(Integer i=0;i<02;i++){
            caseIds.add(lstParentCse[i].Id);
            lstParentCse[i].Type = 'Booking';
            lstParentCse[i].Sub_Type__c = 'New Booking Request';  
            lstParentCse[i].Reason_For_Case__c = 'Booking Request';
            lstParentCse[i].Resolution_Summary__c = 'Solved';
            lstParentCse[i].Send_Case_Closure__c  = 'Yes';
            lstParentCse[i].Case_Closure_Opt_Out_Reason__c=' ';
            lstParentCse[i].Liner_Brand__c  = BrandUtilities.MCC;
            lstParentCse[i].Country__c =  BDAGeographyData_Test.countryUS.Id;
            lstParentCse[i].Status = 'Closed - Resolved';
            lstParentCse[i].Origin = 'MCCIDIMD';
        }
        Test.startTest();
        update lstParentCse;
        Test.stopTest();
        
        List<Case> updatedCase = [Select Id, Count_Case_Outbound_Email__c,Case_Country__c From Case Where Id In:caseIds]; 
        
    }   
    
    @isTest
    public static void testSendECLEmails(){
        
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email =  'test@gmail.com';
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.conInstance = conInstance;
        list<Case> lstParentCse = new list<Case>();        
        CaseData_Test.createExternalCases();
        lstparentCse =  CaseData_Test.lstCases;
        insert lstParentCse; 
        
        for(Case caseIterator : lstParentCse ){
            caseIterator.Product__c = 'E-Delivery';
            caseIterator.Type = 'General Business';
            caseIterator.Sub_Type__c = 'Workload';  
            caseIterator.Reason_For_Case__c = 'Meetings';
            caseIterator.Resolution_Summary__c = 'Solved';
            caseIterator.Send_Case_Closure__c = 'Yes';
            caseIterator.Case_Closure_Opt_Out_Reason__c=' ';
            caseIterator.Liner_Brand__c  = BrandUtilities.MAERSKLINE;
            caseIterator.Country__c = BDAGeographyData_Test.countryUS.Id;
            caseIterator.Status = 'Closed - Resolved';
            caseIterator.Origin = '';
            caseIterator.Case_Visibility__c = 'All Users';
        }
        Test.startTest();
        lstParentCse[0].Origin = 'EFRCXNAM';
        update lstParentCse;
        Test.stopTest();
    }
    
    @isTest
    public static void testLandsideClosureEmail(){
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
        insert con;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 224069341';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        cs.Origin = 'LSAMAZONCXNAM';
        cs.Send_Case_Closure__c = 'Yes';
        insert cs;
        TriggerExecutionController.skipAllTriggers(false);
        
        Test.startTest();
        cs.Product__c = 'Landside Transportation';
        cs.Type = 'Charges, Invoice & Payment';
        cs.Sub_Type__c = 'Invoice / Payer Party';  
        cs.Reason_For_Case__c = 'Invoice Query';
        cs.Resolution_Summary__c = 'Solved';
        cs.Case_Closure_Opt_Out_Reason__c='';
        cs.Liner_Brand__c  = BrandUtilities.MAERSKLINE;
        cs.Status = 'Closed - Resolved'; 
        update cs;
        Test.stopTest();
    }
    
}