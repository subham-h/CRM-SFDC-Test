/**
* Author   : Ragu
* Purpose  : Utility test class for creating Case related data. 
*
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-002633   06-May-2016 Ragu@UST                Created.
* 1.2      RQ-004058   07-Jun-2016 Sandhya@UST             Assign ISR Queues based on Case Liner Brand
* 1.3      RQ-004895   23-Mar-2017 Nisha@Ust               Updated the Contact's Email in test_findUniqueLinerBrandContact() method.
* 1.4      RQ-008334   02-May-2018 Nisha@Ust               Cannot convert External Case record type to ISR and ISR to External Case
* 2.0      Rq-008811  10-Aug-2018  Meenakshi@UST           Included Dispute case records to test
* 3.0      RQ-009192  10-Aug-2018  Nisha@UST               Milestone for ISR cases
* 4.0      RQ-008889  24-Sep-2018  Nisha@Ust               Prevent survey sent to internal contacts.
* 5.0      RQ-011196  23-July-2018 Ranjini@ust             CSAT Exclusion Criteria - Enable closure email to @lns.maersk.com
* 6.0      RQ-011549   02-03-2020  Ramadevi@ust            Resolve Milestone removed
* 7.0      SC-160   20-04-2020  Ramadevi@ust            Trigger Recurrsion on assignISRCaseToQueue method
* 8.0      SC-390   10-06-2020  Sreya@Maersk               Portal Case Visibility update.
* 9.0      SC-2977     08/17/2021    ramadevi@ust            All multicarrier cases need not be competitor claim. However all competitor claim has to be multicarrier
* 10.0     SC-4044     12/07/2021    Urvish@ust              Validation for financial details for Closed - Paid claim cases
* 11.0     SC-4847     05/04/2021    Thippeswamy@UST         Fixing the test class to accomodate restricting the subType Picklist
* 12.0     SPI-100     01/07/2022    Ronnie@SF               Removed brand hardcoding
* 13.0     CRM0000030  12/09/2022    Ronnie@SF               Improved retrieval of recordtype info
* 14.0     SC-7347    27-03-2023    Vivek@maersk.com          Changes for CLaim/Claim Recovery records fields from Sub_Type->Type , RFC->Sub_Type to resolve RFC limits
*/
@isTest
public class CaseFieldPopulator_Test {
    
    @isTest
    public static void testGetShipmentSummery() {
        TriggerExecutionController.skipAllTriggers(true);
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCasesII();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {
            caseIterator.Direction__c = 'Export';
            caseIterator.status = 'Triaged';
            caseIterator.Type = 'Prior To Booking'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Cargo Restrictions/Support Enquiry';
            
        }  
        Test.startTest();
        insert lstCases[0];        
        Test.stopTest();
        list<Case> newList = new List<Case>();
        newList = [Select Id,Liner_Brand__c from Case where Id = :lstCases[0].Id];
        Test.setMock(HttpCalloutMock.class, new GcssTasksControllerMock());   
        //CaseFieldPopulator.getShipmentSummery(newList[0].id,'205384309');
        TriggerExecutionController.skipAllTriggers(false);     
        
    }
    
    
    //To cover Negative scenario with Orgin = null
    @isTest
    public static void createCasewithOriginNUll() {
        TriggerExecutionController.skipAllTriggers(true);
        
        // Create Cases
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCasesII();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {
            //caseIterator.SuppliedEmail = Null;
            caseIterator.Direction__c = 'Export';
            // caseIterator.Liner_Brand__c = BrandUtilities.MCC;
            caseIterator.status = 'Triaged';
            caseIterator.Type = 'Prior To Booking'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            //caseIterator.origin = '';
            caseIterator.sub_type__c = 'Cargo Restrictions/Support Enquiry';
            
        }
        TriggerExecutionController.skipAllTriggers(false);
        
        Test.startTest();
        
        insert lstCases;
        
        Test.stopTest();
    }
    
    @isTest
    public static void testPopulateFieldsOnBeforeInsertUpdate() {
        TriggerExecutionController.skipAllTriggers(true);
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.conInstance = conInstance;
        
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {
            caseIterator.SuppliedEmail = 'ContactTestData0@test.com';
            caseIterator.City__c = BDAGeographyData_Test.citySterling.Id;
        }
        
        CaseData_Test.createClaimCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        CaseData_Test.createClaimRecoveryCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        //Dispute cases
        CaseData_Test.createDisputecases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        TriggerExecutionController.skipAllTriggers(false);
        
        
        
        Test.startTest();
        insert lstCases;
        lstCases[0].Country__c = BDAGeographyData_Test.countryUK.Id;
        lstCases[0].AccountId = null;
        update lstCases[0];
        
        Test.stopTest();
    }
    
    @isTest
    public static void testPopulateLinerBrand() {
        TriggerExecutionController.skipAllTriggers(true);
        list<Case> lstCases = new list<Case>();
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.createExternalCases();
        for(Case caseIterator : CaseData_Test.lstCases) {
            caseIterator.SuppliedEmail = 'ContactTestData0@test.com';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            lstCases.add(caseIterator);
        }
        
        // Create USF Case
        CaseData_Test.createExternalUSFCases();
        for(Case caseIterator : CaseData_Test.lstCases) {
            caseIterator.Liner_Brand__c = null;
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            lstCases.add(caseIterator);         
        }
        
        
        
        TriggerExecutionController.skipAllTriggers(false);
        Test.startTest();
        insert lstCases;
        List<Case> newList = new List<Case>();
        newList = [Select Id, Liner_Brand__c, Country__c,  AccountId from Case where Id = :lstCases[0].Id];
        newList[0].Country__c = BDAGeographyData_Test.countryUK.Id;
        newList[0].AccountId = null;
        update newList[0];
        Test.stopTest();
    }
    
    @isTest
    public static void testPopulateAccountfromContact() {
        TriggerExecutionController.skipAllTriggers(true);
        list<Case> lstCases = new list<Case>();
        list<case> lstdispcases = new list<case>();
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 3;
        CaseData_Test.createClaimCases();
        for(Case caseIterator : CaseData_Test.lstCases) {
            caseIterator.AccountId = Null;
            caseIterator.Refresh_GCSS_Data__c = TRUE;
            lstCases.add(caseIterator);
        }
        lstCases[0].Bol_Number__c = '510135369';
        lstCases[2].Bol_Number__c = '510135368';
        lstCases[2].Liner_Brand__c = 'Hamburg Sud';        
        
        TriggerExecutionController.skipAllTriggers(false);
        Test.startTest();
        insert lstCases;
        insert lstdispcases;
        List<Case> newList = new List<Case>();
        newList = [Select Id, Liner_Brand__c, Country__c,  AccountId from Case where Id = :lstCases[0].Id];
        Test.stopTest();
    }
    
    @isTest
    public static void testFindUniqueLinerBrandContact() {
        TriggerExecutionController.skipAllTriggers(true);
        // Create Contacts in the system with duplicate emails for testing
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact customerContact = ContactData_Test.lstContacts[0];
        customerContact.Liner_Brand__c = BrandUtilities.SEALAND;
        customerContact.Email = 'ContactTestData0@test.com';// v1.3 : RQ-004895
        insert customerContact;
        
        // Create Cases
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        
        
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {
            caseIterator.SuppliedEmail = 'ContactTestData0@test.com';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        }
        TriggerExecutionController.skipAllTriggers(false);
        
        Test.startTest();
        insert lstCases;
        Test.stopTest();
    }
    
    @isTest
    public static void testFindCareRelationship() {
        TriggerExecutionController.skipAllTriggers(true);
        // Create Cases
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        
        // Create Care Relationship for the associated Account
        AccountData_Test.createCareRelationship();
        TriggerExecutionController.skipAllTriggers(false);
        
        Test.startTest();
        insert lstCases;
        lstCases[1].On_Behalf_Account__c = lstCases[1].AccountId;
        update lstCases;
        Test.stopTest();
    }
    
    // v1.2 : Start
    @isTest
    public static void testCaseOwnerUpdateForISRCase() {
        Id isrrtid = StaticFactory.getRecordTypeIdByName('Case', 'ISR');
        Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        Case parentcase = new Case();
        parentcase.Subject = 'Parent Case Test Booking 2m';
        parentcase.Description = 'Parent Case Test Booking Description_2';
        parentcase.RecordTypeId = extCaseRTId;
        parentcase.Thread_topic__c = 'Test'; // RQ-004464 
        parentcase.ContactId = conInstance.Id;
        parentcase.AccountId = conInstance.AccountId;
        parentcase.Status = 'New';
        parentcase.Type = 'Booking';
        parentcase.Sub_Type__c = 'New Booking Request';
        parentcase.Reason_For_Case__c = 'Booking Request';
        parentcase.Country__c = conInstance.Country__c;
        parentcase.Cargo_Classification__c ='US Military (USM)';
        parentcase.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        parentcase.Direction__c = 'Export';
        parentcase.Case_Channel__c = 'Telephone';
        parentcase.Origin = 'MSLUSEXP';
        parentcase.Case_Visibility__c = 'All Users';
        insert parentcase;
        
        Test.startTest(); 
        Case cs = new Case();
        cs.Subject = 'Parent Case Test Booking';
        cs.Description = 'Parent Case Test Booking Description_1';
        cs.RecordTypeId = isrrtid;
        cs.Thread_topic__c = 'Test'; // RQ-004464 
        cs.ContactId = conInstance.Id;
        cs.AccountId = conInstance.AccountId;
        cs.Status = 'New';
        cs.Country__c = conInstance.Country__c;
        cs.Cargo_Classification__c ='US Military (USM)';
        cs.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        cs.Direction__c = 'Export';
        cs.Case_Channel__c = 'Telephone';
        cs.Origin = 'MSLUSEXP';
        cs.Case_Visibility__c = 'All Users';
        cs.Type = 'Non-Case';
        cs.Requestor_Dept__c = 'Single Carrier';
        cs.Resolver_Dept__c = 'Ocean: Sales';
        cs.Sub_Type__c = 'Spam/Case Created in Error';
        cs.ParentId = parentcase.Id;
        insert cs;
        
        // #RQ-008334
        //Group queueId = [SELECT Id FROM Group WHERE Name = 'Safmarine ISR' and Type = 'Queue'];
        //Case caseInst = [SELECT Id, OwnerId  FROM Case WHERE Id =:lstCases[0].id];
        //System.assertEquals(caseInst.OwnerId , queueId.Id);
        
        Id claimCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claim').getRecordTypeId();
        cs.RecordTypeId = claimCaseRTId; 
        cs.Product__c = 'Ocean';
        cs.OwnerId  = '00G57000005HkdrEAC';
        
        try{            
            update cs;
            Test.stopTest();
        }
        catch(DmlException e){
            System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'FIELD_CUSTOM_VALIDATION_EXCEPTION' );
        }
    }
    
    @isTest
    public static void testNewISRCase() {
        //Test.startTest();
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.createISRCases();
        //Test.stopTest();
    }
    
    @isTest
    public static void testClusterMapping(){
        list<Case> lstCases = new list<Case>();
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.createExternalCases();
        for(Case caseIterator : CaseData_Test.lstCases) {
            caseIterator.SuppliedEmail = 'ContactTestData0@test.com';
            caseIterator.Liner_Brand__c = BrandUtilities.SEAGO;
            caseIterator.Direction__c = 'Export';
            lstCases.add(caseIterator);
        }
        insert lstCases;
        
    }
    //SC - 390 : Case Visibility update on portal cases.
    @isTest
    public static void portalCaseUpdates(){
        Case_Type_Sub_Type_Direction_Mapping__mdt tsdList = [SELECT Id, DeveloperName,Case_Visibility__c, Direction__c, Label,Product__c, Sub_Type__c, Type__c FROM Case_Type_Sub_Type_Direction_Mapping__mdt limit 1];
        
        list<Case> lstCases1 = new list<Case>();
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.createPortalCases();
        
        for(Case caseIterator : CaseData_Test.lstCases) {
            caseIterator.Type = tsdList.Type__c;
            caseIterator.Sub_Type__c = tsdList.Sub_Type__c;         
            lstCases1.add(caseIterator);
        }
        insert lstCases1;
        
    }
    
    
    //To cover Negative scenario with update
    @isTest 
    public static void createCasewithcitycountryupdate() {
        TriggerExecutionController.skipAllTriggers(true);
        
        // Create Cases
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCasesII();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {
            caseIterator.SuppliedEmail = Null;
            caseIterator.Direction__c = 'Export';
            caseIterator.Liner_Brand__c = BrandUtilities.MCC;
            caseIterator.status = 'Triaged';
            caseIterator.Type = 'Prior To Booking'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.Country__c = BDAGeographyData_Test.countryUK.Id;
            caseIterator.City__c = BDAGeographyData_Test.cityEdinburgh.id;
            caseIterator.origin = null;
            caseIterator.sub_type__c = 'Cargo Restrictions/Support Enquiry';
            
        }
        TriggerExecutionController.skipAllTriggers(false);
        
        Test.startTest();
        
        insert lstCases;
        List<case>updateCase =  [select id from case where country__c =:  BDAGeographyData_Test.countryUK.Id limit 1];
        updateCase[0].country__c = BDAGeographyData_Test.countryUS.Id;
        updateCase[0].City__c = BDAGeographyData_Test.citySterling.id;
        
        update updateCase;
        Test.stopTest();
    }
    
    @isTest
    public static void testNotSendClosureEmail() {
        TriggerExecutionController.skipAllTriggers(true);
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createInternalContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email = 'test@maersk.com';
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.conInstance = conInstance;
        
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {
            caseIterator.SuppliedEmail = 'test@maersk.com';
            caseIterator.City__c = BDAGeographyData_Test.citySterling.Id;
            caseIterator.Case_Channel__c = 'Proactive';
            caseIterator.MLL__c = True;
            caseIterator.Send_Case_Closure__c = 'Yes';
        }
        
        TriggerExecutionController.skipAllTriggers(false);
        Test.startTest();
        insert lstCases;        
        Test.stopTest();
        
        Case caseInst  = [SELECT Send_Case_Closure__c,Case_Closure_Opt_Out_Reason__c  FROM Case WHERE Id =: lstCases[0].Id];
        System.assertEquals(caseInst.Send_Case_Closure__c,'No', 'CASE NOT CLOSED YET');
        System.assertEquals(caseInst.Case_Closure_Opt_Out_Reason__c ,'System Exclusion', 'OPTED OUT REASON IS SYSTEM EXCLUSION');
    }
    
    // RQ-008889
    @isTest
    public static void testSendClosureEmail() {
        TriggerExecutionController.skipAllTriggers(true);
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {
            caseIterator.SuppliedEmail = 'ContactTestData0@test.com';
            caseIterator.City__c = BDAGeographyData_Test.citySterling.Id;
            caseIterator.Case_Channel__c = 'Proactive';
            caseIterator.Send_Case_Closure__c = 'No';            
            caseIterator.Case_Closure_Opt_Out_Reason__c='Technical limitations';
            caseIterator.Type = 'Charges, Invoice & Payment';
            caseIterator.Sub_Type__c = 'Dispute';
            caseIterator.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Dispute').getRecordTypeId();
            caseIterator.Disputed_Invoice_Number__c = '1234567891'; 
            caseIterator.Department__c = 'Disputes';
            caseIterator.Invoice_Type__c = 'Export D&D';
            caseIterator.Nature_of_Dispute_case__c = 'InCorrect Rates';
            
        }
        
        TriggerExecutionController.skipAllTriggers(false);
        Test.startTest();
        insert lstCases;                
        for(Case caseIterator : lstCases) {
            caseIterator.Case_Channel__c = 'Email';
            caseIterator.Sub_Type__c = 'Additional Charges';
            caseIterator.Type ='Booking';
        }               
        // update lstCases;
        Test.stopTest();
        
        Case caseInst  = [SELECT Send_Case_Closure__c, Case_Closure_Opt_Out_Reason__c  FROM Case WHERE Id =: lstCases[0].Id];
        System.assertEquals(caseInst.Send_Case_Closure__c,'No', 'CASE NOT CLOSED YET');
        //System.assertEquals(caseInst.Case_Closure_Opt_Out_Reason__c ,null);
    }
    
    // RQ-008889
    @isTest
    public static void testSentCaseClosureValueOnConversionScenario1() {    
        TriggerExecutionController.skipCaseTrigger(false);
        CaseData_Test.iNumberOfCases = 5;
        CaseData_Test.createClaimCases();
        list<Case> lstCases = new list<Case>();
        lstCases.addAll(caseData_Test.lstCases);
        Id extCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('External_Case').getRecordTypeId();
        
        for(Case caseIterator : lstCases){
            caseIterator.Type='Booking';
            caseIterator.Sub_Type__c='New Booking Request'; 
            caseIterator.Reason_For_Case__c = 'Booking Request';
            caseIterator.RecordTypeId = extCaseRTId;
        }
        
        TriggerExecutionController.skipCaseTrigger(false);
        Test.startTest();
        update lstCases;
        Test.stopTest();
        
        // list<Case> lstCasesUpdated = new list<Case>();
        list<String> listCasesIds = new list<String>();
        for(Case itr:lstCases){
            listCasesIds.add(itr.Id);
        }
        
        list<Case> lstCasesUpdated = [SELECT Id,RecordTypeId, Send_Case_Closure__c, Case_Closure_Opt_Out_Reason__c  FROM Case WHERE Id IN :listCasesIds];
        // for(Case caseIterator : lstCases){
        //     lstCasesUpdated = [SELECT Id,RecordTypeId, Send_Case_Closure__c, Case_Closure_Opt_Out_Reason__c  FROM Case WHERE Id =: caseIterator.Id];
        // }
        
        System.assertEquals(lstCasesUpdated[0].Send_Case_Closure__c,'No', 'CASE NOT CLOSED YET');
        System.assertEquals(lstCasesUpdated[0].RecordTypeId,extCaseRTId,'RECORD TYPE ID IS EXTERNAL TYPE');
        System.assertEquals(lstCasesUpdated[0].Case_Closure_Opt_Out_Reason__c ,'System Exclusion', 'OPTED OUT REASON IS SYSTEM EXCLUSION');
        
    }
    
    // RQ-008889
    public static void testSentCaseClosureValueOnConversionScenario2() {   
        TriggerExecutionController.skipCaseTrigger(false);
        CaseData_Test.iNumberOfCases = 5;
        CaseData_Test.createClaimCases();
        list<Case> lstCases = new list<Case>();
        lstCases.addAll(caseData_Test.lstCases);
        Id extCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('External_Case').getRecordTypeId();
        
        for(Case caseIterator : lstCases){
            caseIterator.Type='Booking';
            caseIterator.MLL__c = True;
            caseIterator.Sub_Type__c='New Booking Request'; 
            caseIterator.Reason_For_Case__c = 'Booking Request';
            caseIterator.RecordTypeId = extCaseRTId;
        }
        
        TriggerExecutionController.skipCaseTrigger(false);
        Test.startTest();
        update lstCases;
        Test.stopTest();
        
        // list<Case> lstCasesUpdated = new list<Case>(); 
        list<String> listCasesIds = new list<String>();
        for(Case itr:lstCases){
            listCasesIds.add(itr.Id);
        }
        list<Case> lstCasesUpdated = [SELECT Id, RecordTypeId, Send_Case_Closure__c, Case_Closure_Opt_Out_Reason__c  FROM Case WHERE Id IN :listCasesIds];
        // for(Case caseIterator : lstCases){
        //     lstCasesUpdated = [SELECT Id, RecordTypeId, Send_Case_Closure__c, Case_Closure_Opt_Out_Reason__c  FROM Case WHERE Id =: caseIterator.Id];
        // }
        
        System.assertEquals(lstCasesUpdated[0].Send_Case_Closure__c,'No', 'CASE NOT CLOSED YET');
        System.assertEquals(lstCasesUpdated[0].RecordTypeId,extCaseRTId,'RECORD TYPE ID IS EXTERNAL TYPE');
        System.assertEquals(lstCasesUpdated[0].Case_Closure_Opt_Out_Reason__c ,'System Exclusion', 'OPTED OUT REASON IS SYSTEM EXCLUSION');
        
    }
    
    // RQ-009451
    @isTest
    public static void testSentCaseClosureValueOnConversionScenario3() {   
        TriggerExecutionController.skipCaseTrigger(false);
        CaseData_Test.iNumberOfCases = 5;
        CaseData_Test.createExternalCases();
        list<Case> lstCases = new list<Case>();
        lstCases.addAll(caseData_Test.lstCases);
        Id claimRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claim').getRecordTypeId();
        Integer bolNumberIncrement = 0;
        
        for(Case caseIterator : lstCases){
            caseIterator.RecordTypeId = claimRTId;
            caseIterator.Type = 'Claim - Ocean';
            caseIterator.BoL_Number__c = '12345678'+bolNumberIncrement; 
            caseIterator.P_I_Cover__c = 'Yes';
            caseIterator.Court_Case__c = 'Yes';
            caseIterator.Chance_Winning_Court_Case__c = 67;
            caseIterator.Location_Indicator_Jurisdiction__c = caseIterator.Country__c;
            caseIterator.Court_Case_Status__c = 'On Appeal';
            caseIterator.MLL__c = True;
            caseIterator.Claim_Filed_Date__c = System.today() - 1;
            bolNumberIncrement++;
        }
        
        TriggerExecutionController.skipCaseTrigger(false);
        Test.startTest();
        update lstCases;
        Test.stopTest();
        
        // list<Case> lstCasesUpdated = new list<Case>(); 
        list<String> listCasesIds = new list<String>();
        for(Case itr:lstCases){
            listCasesIds.add(itr.Id);
        }
        list<Case> lstCasesUpdated = [SELECT Id, RecordTypeId, Send_Case_Closure__c, Case_Closure_Opt_Out_Reason__c  FROM Case WHERE Id IN :listCasesIds]; 
        
        // for(Case caseIterator : lstCases){
        //     lstCasesUpdated = [SELECT Id, RecordTypeId, Send_Case_Closure__c, Case_Closure_Opt_Out_Reason__c  FROM Case WHERE Id =: caseIterator.Id];
        // }
        
        System.assertEquals(lstCasesUpdated[0].Send_Case_Closure__c,'No', 'CASE NOT CLOSED YET');
        System.assertEquals(lstCasesUpdated[0].RecordTypeId,claimRTId,'RECORD TYPE ID IS CLAIM TYPE');
        System.assertEquals(lstCasesUpdated[0].Case_Closure_Opt_Out_Reason__c ,'System Exclusion', 'OPTED OUT REASON IS SYSTEM EXCLUSION');
        
    }
    
    //  RQ-009429
    @isTest
    public static void testOnCreateSetSendCaseClosureNo(){
        TriggerExecutionController.skipAllTriggers(true);
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        // In actual scenario mail should be sent but we are forcefully setting the Send Case Closure as No.
        for(Case caseIterator : lstCases) {
            caseIterator.Case_Channel__c = 'Telephone';
            caseIterator.MLL__c = False;
            caseIterator.Send_Case_Closure__c = 'No';            
            caseIterator.Case_Closure_Opt_Out_Reason__c='Technical limitations';
            caseIterator.Type='Booking';
            caseIterator.Sub_Type__c='New Booking Request'; 
            caseIterator.Reason_For_Case__c = 'Booking Request';
        }
        
        TriggerExecutionController.skipAllTriggers(false);
        Test.startTest();
        insert lstCases;        
        Test.stopTest();
        
        Case caseInst  = [SELECT Send_Case_Closure__c, Case_Closure_Opt_Out_Reason__c  FROM Case WHERE Id =: lstCases[0].Id];
        System.assertEquals(caseInst.Send_Case_Closure__c,'No', 'CASE NOT CLOSED YET');
        
        
    }
    
    @isTest
    public static void testOnTwillCases(){
        TriggerExecutionController.skipAllTriggers(true);
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        Id quillQId = StaticFactory.getQueueIdByName(Label.twillQueue);
        for(Case caseIterator : lstCases) {
            caseIterator.Case_Channel__c = 'Telephone';
            caseIterator.MLL__c = False;
            caseIterator.Send_Case_Closure__c = 'No';            
            caseIterator.Case_Closure_Opt_Out_Reason__c='Technical limitations';
            caseIterator.Type='Booking';
            caseIterator.Sub_Type__c='New Booking Request'; 
            caseIterator.Reason_For_Case__c = 'Booking Request';
            caseIterator.Delivery_Channel__c= 'MaerskGo';
            caseIterator.OwnerId = quillQId;
            
        }
        TriggerExecutionController.skipAllTriggers(false);
        Test.startTest();
        insert lstCases;  
        
        id globalQueueId = StaticFactory.getQueueIdByName('GLO - Inland');
        Case updOwnerGrpCase = lstCases[1];
        updOwnerGrpCase.OwnerId = globalQueueId;
        update updOwnerGrpCase;      
        Test.stopTest();
        
        //Case caseInst  = [SELECT Value_Proposition__c FROM Case WHERE Id =: lstCases[0].Id];
        //System.assertEquals(caseInst.Value_Proposition__c,'Advancement');
    }
    
    @isTest
    public static void populateBECode(){
        TriggerExecutionController.skipAllTriggers(true);
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {
            caseIterator.Case_Channel__c = 'Telephone';
            caseIterator.MLL__c = False;
            caseIterator.Send_Case_Closure__c = 'No';            
            caseIterator.Case_Closure_Opt_Out_Reason__c='Technical limitations';
            caseIterator.Type='Booking';
            caseIterator.Sub_Type__c='New Booking Request'; 
            caseIterator.Reason_For_Case__c = 'Booking Request';
            //caseIterator.OwnerId = quillQId;
        }
        TriggerExecutionController.skipAllTriggers(false);
        Test.startTest();
        insert lstCases;        
        Test.stopTest();
        
        //Case caseInst  = [SELECT BE_Code__c FROM Case WHERE Id =: lstCases[0].Id];
        //System.assertEquals(caseInst.Value_Proposition__c,'Advancement');
        //COMMENT
    }
    //SC - 675 - Cover updateCompetitorClaimVisibility() method
    @isTest
    public static void updateCompetitorClaimVisibility(){
        TriggerExecutionController.skipAllTriggers(true);
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2; 
        
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createSCMCases();
        lstCases.addAll(CaseData_Test.lstCases);      
        for(Case caseIterator : lstCases) {
            caseIterator.Case_Visibility__c = 'Multi-Carrier';
            caseIterator.Type = 'Carrier booking'; 
            caseIterator.sub_type__c = 'Booking confirmation';
            caseIterator.Reason_For_Case__c = 'New booking confirmation';
            
        }
        list<Case> lstClaimCases = new list<Case>();
        CaseData_Test.createClaimCases();
        lstClaimCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstClaimCases) {
            caseIterator.Competitor_Claim__c = true;             
        }
        
        TriggerExecutionController.skipAllTriggers(false);
        Test.startTest();
        insert lstCases;  
        insert lstClaimCases;
        Test.stopTest();
        List<Case> allCases = [select id,Competitor_Claim__c,Case_Visibility__c from case ];
        allCases[0].Case_Visibility__c = 'All Users';
        allCases[1].Competitor_Claim__c = false;
        update allCases;
        List<Case> allCases1 = [select id,Competitor_Claim__c,Case_Visibility__c from case where Case_Visibility__c = 'All Users' and Competitor_Claim__c = false];
        allCases1[0].Case_Visibility__c = 'Multi-Carrier';
        //Commenting as part of SC-2977: all multicarrier cases need not be competitor claim. However all competitor claim has to be multicarrier
        //allCases1[1].Competitor_Claim__c = true;
        
        update allCases1;
        
    }
    
    //SC-825 - Cover updateCaseOwnerManger() method
    @isTest
    public static void updateCaseOwnerManger(){
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        for(Case case1:lstCases ){
            case1.OwnerId = UserInfo.getUserId();
        }
        lstCases.addAll(CaseData_Test.lstCases);
        //for(Case caseIterator : lstCases) {
        
        
        Test.startTest();
        insert lstCases;  
        Test.stopTest();
        List<Case> allCases =new List<Case>();
        for(Case cs: [select id,OwnerId from case ]){
            if(cs.OwnerId==null){
                cs.OwnerId=UserInfo.getUserId();
            }
            allCases.add(cs);
        }
        update allCases;
    }
    
    //comment
    
    //SC-1005 -> Identify Shipment Number from Case
    @isTest
    public static void testPopuateShipmentNumberFromSubject(){
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 3;
        
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        lstCases[0].Subject = 'TestingAA 123456789';
        lstCases[0].Case_Channel__c = 'E-mail';
        lstCases[1].Subject = 'RE: REQUEST TO PROVIDE SHIPMENTS ADVICE. //203638667';
        lstCases[1].Case_Channel__c = 'E-mail';
        lstCases[2].Origin = 'MSLGBIMP';
        lstCases[2].Case_Channel__c = 'E-mail';
        lstCases[2].Description = '203638667';
        
        Test.startTest();
        insert lstCases;  
        Test.stopTest();        
    }
    
    @isTest
    public static void testPopuateShipmentNumberFromSubject3(){
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 3;
        
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        lstCases[0].Subject = 'TestingAA 123456789';
        lstCases[0].Case_Channel__c = 'E-mail';
        lstCases[1].Subject = 'RE: REQUEST TO PROVIDE SHIPMENTS ADVICE. //203638667';
        lstCases[1].Case_Channel__c = 'E-mail';
        lstCases[2].Origin = 'MSLGBIMP';
        lstCases[2].Case_Channel__c = 'E-mail';
        lstCases[2].Description = '203638667';
        lstCases[2].liner_brand__c = 'Maersk Line';
        
        Test.startTest();
        insert lstCases;  
        Test.stopTest();        
    }
    @isTest
    public static void testPopuateShipmentNumberFromSubject4(){
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 3;
        
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        lstCases[0].Subject = 'TestingAA 123456789';
        lstCases[0].Case_Channel__c = 'E-mail';
        lstCases[1].Subject = 'RE: REQUEST TO PROVIDE SHIPMENTS ADVICE. //203638667';
        lstCases[1].Case_Channel__c = 'E-mail';
        lstCases[2].Origin = 'MSLGBIMP';
        lstCases[2].Case_Channel__c = 'E-mail';
        lstCases[2].Description = '203638667';
        lstCases[2].liner_brand__c = 'Hamburg Sud';
        
        Test.startTest();
        insert lstCases;  
        Test.stopTest();        
    }
    //SC-1256 -> updateSendCaseClosure
    @isTest
    public static void testUpdateSendCaseClosure(){
        
        TriggerExecutionController.skipAllTriggers(true);
        
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email =  'test@gmail.com';
        conInstance.CSAT_Opt_Out__c = true;
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list<Case> lstParentCse = new list<Case>();        
        CaseData_Test.createLNSCases();
        lstparentCse =  CaseData_Test.lstCases;
        
        Test.startTest();
        insert lstParentCse;      
        Test.stopTest();
        
        TriggerExecutionController.skipAllTriggers(false);        
        List<Case> lstParentCse1 = new List<Case>();
        for(Case cs : [select id,ContactId,Send_Case_Closure__c from case]){         
            cs.Send_Case_Closure__c = 'Yes';
            cs.Case_Closure_Opt_Out_Reason__c = '';
            lstParentCse1.add(cs);            
            // update lstParentCse1; 
        }       
        update lstParentCse1;  //Need to clarify
    }  
    // SC-1256 : 
    @isTest 
    public static void testUpdateSendCaseClosure1(){
        
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email =  'test@gmail.com';
        conInstance.CSAT_Opt_Out__c = true;
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list<Case> lstParentCse = new list<Case>();        
        CaseData_Test.createLNSCases();
        lstparentCse =  CaseData_Test.lstCases;
        
        Test.startTest();
        insert lstParentCse;      
        Test.stopTest();
        
    }    
    
    @isTest
    public static void testUpdateSendCaseClosure2(){
        TriggerExecutionController.skipAllTriggers(true);
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email =  'test@gmail.com';
        conInstance.CSAT_Opt_Out__c = true;
        insert conInstance;
        
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance1 = ContactData_Test.lstContacts[0];
        conInstance1.Email =  'nonopted@gmail.com';
        conInstance1.CSAT_Opt_Out__c = false;
        insert conInstance1;      
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list<Case> lstParentCse = new list<Case>();        
        CaseData_Test.createLNSCases();
        lstparentCse =  CaseData_Test.lstCases;
        
        Test.startTest();
        insert lstParentCse;      
        Test.stopTest();
        
        TriggerExecutionController.skipAllTriggers(false);        
        List<Case> lstParentCse1 = new List<Case>();
        List<Contact> conList = [select id from contact where CSAT_Opt_Out__c = false];
        for(Case cs : [select id,ContactId,Send_Case_Closure__c from case]){         
            cs.contactId = conList[0].Id;
            lstParentCse1.add(cs);               
        }    
        update lstParentCse1;
    }   
    
    @isTest
    public static void testUpdateOnBehalfofAccountOnCase(){
        TriggerExecutionController.skipAllTriggers(true);
        
        General_Settings__c gs = new General_Settings__c();
        gs.Case_shipment_API_status__c = true;
        gs.Case_shipment_API_Count__c = 1;
        insert gs;
        //Commenting as part of SPI - 74
        //BDA__c germanyBD = new BDA__c(Name = 'North West Continent Area', GEO_ID__c = 'NA-Trade', Default_Account_Owner__c = UserInfo.getUserId(), Type__c = 'Cluster');
        BDA__c germanyBD = new BDA__c(Name = 'North Europe Continent Area', GEO_ID__c = 'NA-Trade', Default_Account_Owner__c = UserInfo.getUserId(), Type__c = 'Cluster');
        insert germanyBD;
        
        Geography__c geo = new Geography__c();
        geo.Name = 'Germany';
        geo.Active__c = true;
        geo.GEO_ID__c = '10Z2W9ZTH2RUM';
        geo.GEO_Code__c = 'DE';
        geo.Type_Of_Location__c = 'Country';
        insert geo;
        
        BDA_Geography__c bdaGeo = new BDA_Geography__c(BDA__c = germanyBD.Id, Geography__c = geo.Id);
        insert bdaGeo;
        
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account acc =AccountData_Test.lstAccounts[0];
        acc.SCV_Code__c = '10000007951';
        acc.Value_Proposition__c = 'Ease';
        acc.Country__c = geo.Id;
        update acc;
        
        AccountData_Test.createCareRelationship();
        
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createInternalContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email = 'test@maersk.com';
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCasesII();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case cs : lstCases){
            cs.ContactId = conInstance.Id;
            cs.Shipment_Number__c = '507333790';
            cs.Country__c = geo.Id;
            cs.Direction__c = 'Import';
        }
        TriggerExecutionController.skipAllTriggers(false);
        insert lstCases;
        
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Accept','application/json');
        String sampleBody = '{"access_token":"R2FyQUEiLCJuYmYiOjE2MDAwNjA5MDgsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJzY29wZSI6W","parties":[{"partyRoleTypeId":"1","partyRoleTypeName":"Booked By","scvCustomerCode":"10000007951"},{"partyRoleTypeId":"3","partyRoleTypeName":"Consignee","scvCustomerCode":"10000007951"}]}';        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'Success',sampleBody,headers)); 
        String casejson = JSON.serialize(lstCases[0]);
        //CaseFieldPopulator.populateOnBehalfOfAccount(casejson, lstCases[0].Shipment_Number__c, lstCases[0].Direction__c, lstCases[0].Liner_Brand__c, lstCases[0].Origin);
        //CaseFieldPopulator.populateOnBehalfOfAccount(lstCases);        
        Test.stopTest();
        Case cs = [Select Id, On_Behalf_Account__c From Case Where Id =: lstCases[0].Id];
        // system.assertEquals(acc.Id, cs.On_Behalf_Account__c);
        
    }
    
    @isTest    
    public static void testUpdateOnBehalfofAccountOnCase1(){
        Case_OmniSkill_Mappings__c skillmap1 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap1',Developer_Name__c ='SkillMap1', Active__c = true, Case_Field__c = 'Unassigned', Origin__c = 'Global', Value__c = 'General', Skill_Id__c = '0C52o000000L2nY');
        Case_OmniSkill_Mappings__c skillmap5 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap5',Developer_Name__c ='SkillMap5', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLCLIMP', Value__c = 'Case_MSL_Chile_Import', Skill_Id__c = '0C57E0000008WIU');
        
        List < Case_OmniSkill_Mappings__c > omnimap = new List < Case_OmniSkill_Mappings__c > ();
        omnimap.add(skillmap1);
        omnimap.add(skillmap5);
        insert omnimap;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        list<user> userlist = [select id,name from user where name like '%test%' LIMIT 2];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        CaseData_Test.conInstance = conInstance;
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        for(Case caseIterator : lstCases) {      
            caseIterator.Direction__c = 'Import';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Documentation'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Certificate/Letter';
            caseIterator.Reason_For_Case__c = 'Certificate/Letter Request';
            caseIterator.Case_Channel__c ='E-mail';   
            caseIterator.origin = 'MSLCLIMP';
            caseIterator.contactid = conInstance.id;
            caseIterator.Country__c = BDAGeographyData_Test.countryCL.Id;
            caseIterator.City__c = BDAGeographyData_Test.citySantiago.id;         
            caseIterator.ownerid = userlist[0].Id;
            caseIterator.Subject = 'TO BE UPDATED BY CHAT AGENT 224069341';
            caseIterator.description = 'TO BE UPDATED BY CHAT AGENT 224069341';
        }  
        
        TriggerExecutionController.skipAllTriggers(true);         
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account acc =AccountData_Test.lstAccounts[0];
        acc.SCV_Code__c = '10000007951';
        acc.Value_Proposition__c = 'Ease';
        acc.Country__c = BDAGeographyData_Test.countryCL.Id;
        update acc;
        TriggerExecutionController.skipAllTriggers(false);  
        
        Care_Relationship__c maerskLineCR = new Care_Relationship__c();
        maerskLineCR.Account__c = acc.id;
        maerskLineCR.Direction__c = 'Import';
        maerskLineCR.Status__c = 'Active';
        maerskLineCR.Service_Level__c = 'CARE';
        maerskLineCR.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        maerskLineCR.Country__c = BDAGeographyData_Test.countryCL.Id;
        //maerskLineCR.GSC_Agent__c = userlist[0].id;
        //maerskLineCR.Care_Business_Partner__c = userlist[1].id;
        insert maerskLineCR;
        
        shipment__c s = new shipment__c();
        s.Shipment_Number__c = '224069341';
        insert s;
        
        Party__c p = new party__c();
        p.Scv_Customer_Code__c = '10000007951';
        p.Party_Role_Type_Id__c = '3ECU6SEW31GIB';
        p.Shipment__c = s.id;
        p.Party_Role_Type_Name__c = 'Consignee';
        p.Shipment_Number__c = '224069341';
        insert p;
        
        
        insert lstCases;
        
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String sampleBody = '{"Results": [{"Case_number": "'+lstCases[0].CaseNumber+'", "Class_Probability": {"Delivery Order/Container Release": 0.003354905638843775, "Delivery Order/Container Release": 0.0026299203746020794, "Booking Confirmation Request": 0.003429069649428129, "COD DIT Transhipment": 4.076581899425946e-05, "Cancel Booking": 0.00045322056394070387, "Cargo Restrictions/Support Enquiry": 0.001217402401380241, "Certificate/Letter": 0.00018847470346372575, "Container Damaged": 9.735977073432878e-05, "Container Longstanding": 0.00012844604498241097, "Container Status": 0.004746004473417997, "Container Tracking Information": 0.017384301871061325, "Credit / Statement": 0.0006784289726056159, "Customer Registration/User ID/Password": 0.03919510543346405, "Cut-off/Deadline Request": 0.00026194844394922256, "Delivery Order/Container Release": 0.0162273608148098, "Demurrage / Detention": 0.009068586863577366, "Depot / Terminal": 0.003147900803014636, "Invoice / Payer Party": 0.3668147325515747, "Mandatory Documents": 5.518203033716418e-05, "Manifest / Customs": 0.0002456871443428099, "New Booking Request": 0.000670662266202271, "Onboarding/How To": 0.49637532234191895, "Payment": 0.003403052920475602, "Rates/Quotes": 0.003337888978421688, "Release SI/BL/VC": 0.009786400012671947, "Request Arrival Notice": 0.0026085772551596165, "Request SI/BL/VC": 0.0029985548462718725, "Sales coordination activities": 0.0003184553643222898, "Schedule/Vessel/Container/Space Availability": 0.00011187034397153184, "Spam/Case Created in Error": 0.006153902038931847, "Submit SI/BL/VC": 0.003116634441539645, "Verified Gross Mass (VGM)": 0.00028399977600201964, "Website Error": 0.0014697937294840813}, "Prediction": "Onboarding/How To", "Error_Reason": ""}]}';              
        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'OK',sampleBody,headers));
        Set<Id> caseIds = new Set<Id>();
        caseIds.add(lstCases[0].id);
    }
    
    @isTest
    public static void testUpdateOnBehalfofAccountOnCase3(){
        TriggerExecutionController.skipAllTriggers(true);
        
        General_Settings__c gs = new General_Settings__c();
        gs.Case_shipment_API_status__c = true;
        gs.Case_shipment_API_Count__c = 1;
        insert gs;
        
        //Commenting as part of SPI - 74
        //BDA__c germanyBD = new BDA__c(Name = 'North West Continent Area', GEO_ID__c = 'NA-Trade', Default_Account_Owner__c = UserInfo.getUserId(), Type__c = 'Cluster');
        BDA__c germanyBD = new BDA__c(Name = 'North Europe Continent Area', GEO_ID__c = 'NA-Trade', Default_Account_Owner__c = UserInfo.getUserId(), Type__c = 'Cluster');
        insert germanyBD;
        
        Geography__c geo = new Geography__c();
        geo.Name = 'Germany';
        geo.Active__c = true;
        geo.GEO_ID__c = '10Z2W9ZTH2RUM';
        geo.GEO_Code__c = 'DE';
        geo.Type_Of_Location__c = 'Country';
        insert geo;
        
        BDA_Geography__c bdaGeo = new BDA_Geography__c(BDA__c = germanyBD.Id, Geography__c = geo.Id);
        insert bdaGeo;
        
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account acc =AccountData_Test.lstAccounts[0];
        acc.SCV_Code__c = '10000007951';
        acc.Value_Proposition__c = 'Ease';
        acc.Country__c = geo.Id;
        update acc;
        
        AccountData_Test.createCareRelationship();
        
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createInternalContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email = 'test@maersk.com';
        insert conInstance;
        
        shipment__c s = new shipment__c();
        s.Shipment_Number__c = '224069341';
        insert s;
        
        list<Party__c> partyList = new list<Party__c>();
        
        Party__c p1 = new party__c();
        p1.Scv_Customer_Code__c = '10000007951';
        p1.Party_Role_Type_Id__c = '3ECU6SEW31GAB';
        p1.Shipment__c = s.id;
        p1.Party_Role_Type_Name__c = 'Consignee';
        p1.Shipment_Number__c = '224069341';
        partyList.add(p1);
        insert p1;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCasesII();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case cs : lstCases){
            cs.ContactId = conInstance.Id;
            cs.Shipment_Number__c = '507333790';
            cs.Origin = 'MSLPEIMP'; 
            cs.Country__c = BDAGeographyData_Test.countryRU.Id; 
            cs.Direction__c = 'Export';
            cs.Subject = 'Test Amend 224069341';
            cs.description = 'Test Amend Booking Details 224069341';
        }        
        TriggerExecutionController.skipAllTriggers(false);
        insert lstCases;
        
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Accept','application/json');
        String sampleBody = '{"access_token":"R2FyQUEiLCJuYmYiOjE2MDAwNjA5MDgsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJzY29wZSI6W","debugMessage":{"error":"Read timed out"}}';        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'Success',sampleBody,headers)); 
        String casejson = JSON.serialize(lstCases[0]);
        // CaseFieldPopulator.populateOnBehalfOfAccount(casejson, lstCases[0].Shipment_Number__c, lstCases[0].Direction__c, lstCases[0].Liner_Brand__c, lstCases[0].Origin);
        CaseFieldPopulator.populateOnBehalfOfAccount(lstCases);
        Test.stopTest();
        Case cs = [Select Id, On_Behalf_Account__c From Case Where Id =: lstCases[0].Id];
        //system.assertEquals(null, cs.On_Behalf_Account__c, 'FIELD IS EMPTY');
        
    }
    
    @isTest
    public static void financialdetailscheckForLNSClaims(){
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createClaimCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        IncidentData_Test.createClaimEventIncidentsForLNS();
        List<Incident__c> testIncident = new List<incident__c>();
        testincident.addall(IncidentData_Test.lstIncidents);
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createInternalContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email = 'test@maersk.com';
        insert conInstance;
        
        Test.startTest();
        insert lstCases;
        List<Financial_Details__c> lstfin = new List<Financial_Details__c>();
        Financial_Details__c objfin = new Financial_Details__c();
        objfin.type__c = 'Cargo Claim Paid';
        objfin.Claim__c = lstCases[0].Id;
        objfin.Local_Currency__c =  'USD';
        objfin.Local_Amount__c =  100;
        
        Financial_Details__c objfin1 = new Financial_Details__c();
        objfin1.type__c = 'Other Legal Claim Paid';
        objfin1.Claim__c = lstCases[0].Id;
        objfin1.Local_Currency__c =  'USD';
        objfin1.Local_Amount__c =  100;
        lstfin.add(objfin);
        lstfin.add(objfin1);
        insert lstfin;
        
        for(Case case1:lstCases ){
            case1.status = 'Closed - Paid';
            case1.Claim_Event__c = testincident[0].id;
            case1.Type = 'Claim - L&S';
            case1.BoL_Number__c = '1234';
            case1.ContactId = conInstance.Id;
            case1.sub_type__c = 'Cargo Liabilities';
            case1.Nature_of_damage__c ='Cargo Loss/Damage';
            case1.Cause_of_damage__c = 'Fire/Explosion';
        }
        try{
            update lstCases;
        } catch(Exception e){
            //System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , e.getDmlStatusCode(0) );
            //System.assertEquals(e.getMessage().contains('Please capture Activity Related References and the Claim Activity fields before updating the status.'),true);
            //System.debug(LoggingLevel.WARN, e.getMessage());
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , e.getDmlStatusCode(0), 'EXCEPTION CAUGHT' );
        }
        Test.stopTest();        
    }
    
    @isTest
    public static void financialdetailscheckForLNSClaims2(){
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createClaimCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        IncidentData_Test.createClaimEventIncidentsForLNS();
        List<Incident__c> testIncident = new List<incident__c>();
        testincident.addall(IncidentData_Test.lstIncidents);
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createInternalContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email = 'test@maersk.com';
        insert conInstance;
        
        Test.startTest();
        insert lstCases;
        
        for(Case case1:lstCases ){
            case1.status = 'Closed - Paid';
            case1.Claim_Event__c = testincident[0].id;
            case1.Type = 'Claim - L&S';
            case1.BoL_Number__c = '1234';
            case1.ContactId = conInstance.Id;
            case1.sub_type__c = 'Cargo Liabilities';
            case1.Nature_of_damage__c ='Cargo Loss/Damage';
            case1.Cause_of_damage__c = 'Fire/Explosion';
        }
        try{
            update lstCases;
        } catch(Exception e){
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , e.getDmlStatusCode(0), 'EXCEPTION CAUGHT' );
            System.assertEquals(e.getMessage().contains('Please update Paid Financial Details before closing the case as Closed-Paid.'),true, 'CONTAINS THE ERROR MESSAGE Please update Paid Financial Details before closing the case as Closed-Paid.');
        }
        Test.stopTest();        
    }
    
    @isTest
    public static void testCaseVisibilityANDProductOnCase(){
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCasesII();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {
            caseIterator.Direction__c = 'Export';
            caseIterator.status = 'Triaged';
            caseIterator.Type = 'Carrier booking'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Booking confirmation';
            caseIterator.Reason_For_Case__c = 'New booking confirmation';
            caseIterator.Origin = 'SCMAESVC';
            caseIterator.SuppliedEmail = 'test@maersk.com';
        }  
        Test.startTest();
        insert lstCases[0];        
        Test.stopTest();
        list<Case> newList = new List<Case>();
        newList = [Select Id,Liner_Brand__c, Product__c from Case where Id = :lstCases[0].Id];
        system.assertEquals('SCM', newList[0].Product__c, 'PRODUCT TYPE IS SCM');
        system.debug('XYZ Test 1606 list of cases queried' +newList);
    }
    
    @isTest
    public static void testvalidateCaseVisibilityExternal(){
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCasesII();
        lstCases.addAll(CaseData_Test.lstCases);
        //User runUser = UserDataGeneratorHelper_Test.MSLIntegrationUser;
        test.startTest();
        //User u=[SELECT Id,CM_Visibility__c FROM User WHERE UserName='br6testuser3@ust-global.com.regdev01'];
        for(Case caseIterator : lstCases) {
            caseIterator.Direction__c = 'Export';
            caseIterator.status = 'Triaged';
            caseIterator.Type = 'Prior To Booking'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Cargo Restrictions/Support Enquiry';
            caseIterator.Origin = 'MSLESIMP';
            caseIterator.SuppliedEmail = 'test@maersk.com';
            caseIterator.Case_Visibility__c='Multi-Carrier';
            caseIterator.SF_4PL_Account__c='Unilever';
        }  
        try{
            //system.debug('Test Class');
            if (UserDataGeneratorHelper_Test.MSLCustomerServiceUser == null){
                
                UserDataGeneratorHelper_Test.initializeCustomerServiceUser(); 
                
            }   
            //User u=[Select id,name,CM_Visibility__c from User where UserName='br6testuser3@ust-global.com.regdev01'];
            System.runAs(UserDataGeneratorHelper_Test.MSLCustomerServiceUser){
                insert lstCases[0];
            }
            
        }
        catch(Exception e)
        {
            //System.assertEquals(e.getMessage().contains(Label.External_Case_4PL_Validation),true, 'VALIDATION ERROR CAUGHT');
        }
        test.stopTest();
        
        
    }
    
    @isTest
    public static void testvalidateCaseVisibilityISR(){
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createISRCases();
        lstCases.addAll(CaseData_Test.lstCases);
        Test.startTest();
        Integer index = 0;
        for(Case caseIterator : lstCases) {
            caseIterator.SuppliedEmail = 'ContactTestData0@test.com';
            caseIterator.Requestor_Dept__c = 'All Users';
            caseIterator.Resolver_Dept__c = 'Ocean: Sales'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.SuppliedEmail = 'test@maersk.com';
            caseIterator.Security_Code__c = '1235' + index++;
            caseIterator.SF_4PL_Account__c='Unilever';
            
        }  
        
        try{
            UserDataGeneratorHelper_Test.initializeCustomerServiceUser();
            System.runAs(UserDataGeneratorHelper_Test.MSLCustomerServiceUser){
                insert lstCases;
            }
        } catch(Exception e){
            //System.assertEquals(e.getMessage().contains(Label.ISR_Case_4PL_Validation),true, 'VALIDATION ERROR CAUGHT');
        }
        Test.stopTest();
        
    }
    
    @isTest
    public static void testISRLineBrand(){
        TriggerExecutionController.skipAllTriggers(true);
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createISRCases();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {
            caseIterator.SuppliedEmail = 'ContactTestData0@test.com';
            caseIterator.Requestor_Dept__c = 'All Users';
            caseIterator.Resolver_Dept__c = 'Ocean: Sales'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.SuppliedEmail = 'test@maersk.com';
            caseIterator.Requestor_Dept__c = '4PL';
            caseIterator.SF_4PL_Account__c = 'Unilever';
        }  
        insert lstCases;
        TriggerExecutionController.skipAllTriggers(false);
        
        Test.startTest();
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        list<Case> lstCasesnew = new list<Case>();
        CaseData_Test.createISRCases();
        lstCasesnew.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCasesnew) {
            caseIterator.SuppliedEmail = 'ContactTestData0@test.com';       
            caseIterator.SuppliedEmail = 'test@maersk.com';
            caseIterator.Requestor_Dept__c = '4PL';
            //caseIterator.ParentId = lstCases[0].Id;
            caseIterator.Liner_Brand__c = null;
            caseIterator.SF_4PL_Account__c = 'Nvidia';
        }  
        insert lstCasesnew;
        Test.stopTest();
    }
    
    @isTest
    public static void testCaseDetailsBasedonQueue(){
        TriggerExecutionController.skipAllTriggers(true);
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCasesII();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {
            caseIterator.Direction__c = 'Export';
            caseIterator.status = 'Triaged';
            caseIterator.Type = 'Prior To Booking'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Cargo Restrictions/Support Enquiry';
            caseIterator.Origin = 'SCMAESVC';
            caseIterator.SuppliedEmail = 'test@maersk.com';
        }
        
        insert lstCases;
        TriggerExecutionController.skipAllTriggers(false);
        /*Group gp = [Select id From Group Where Type = 'Queue' AND DeveloperName LIKE 'Case%' Order By DeveloperName DESC LIMIT 1];
        
        lstCases[0].OwnerId = gp.Id;
        update lstCases;*/
    }
    
    @isTest
    public static void testassignISRCaseToQueue()
    {
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createISRCases();
        lstCases.addAll(CaseData_Test.lstCases);
        Test.startTest();
        Integer index = 0;
        for(Case caseIterator : lstCases) {
            caseIterator.SuppliedEmail = 'ContactTestData0@test.com';
            caseIterator.Requestor_Dept__c = 'All Users';
            caseIterator.Resolver_Dept__c = '4PL COE'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLS;
            caseIterator.SuppliedEmail = 'test@maersk.com';
            caseIterator.Security_Code__c = '1235' + index++;
            caseIterator.SF_4PL_Account__c='Unilever';
            
        }  
        
        TriggerExecutionController.skipAllTriggers(false);
        insert lstCases;
        Group queueId = [SELECT Id FROM Group WHERE Name = '4PL Unilever COE ISR' and Type = 'Queue'];
        Case caseInst = [SELECT Id, OwnerId,Owner.Name  FROM Case WHERE Id =:lstCases[0].id];
        System.assertEquals(queueId.Id,caseInst.OwnerId, 'OWNER ID MATCHES');
        
        Test.stopTest();
        
    }
    //Ramesh Changes
    @isTest
    static void testUpdateCaseClassificationforCustomModel(){
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCasesII();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case cs : lstCases){
            cs.Description = 'This email is for invoice booking';
            cs.Subject = 'TO BE UPDATED BY CHAT AGENT';
            cs.Case_Channel__c = 'E-mail';
            cs.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            
        }
        
        TriggerExecutionController.skipAllTriggers(false);
        insert lstCases;//maersk--dev01.sandbox.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#
        Set<Case> setcases = new Set<Case>();
        setcases.addAll(lstCases);
        Set<Id> lstCaseIds = new Set<Id>();
        List<Id> caseIdList = new List<Id>();
        lstCaseIds.add(lstCases[0].Id);
        caseIdList.add(lstCases[0].Id);
        Test.startTest();
        CaseTriggerHandler.updateOwnership(caseIdList);
        Test.stopTest();
        
    }
    @isTest
    public static void test4PLEmergencyOrderCases(){
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {
            caseIterator.Subject = 'testvvh Spot Emergency Order';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLS;
            caseIterator.Product__c = '4PL';
            caseIterator.Type = 'Carrier booking'; 
            caseIterator.sub_type__c = 'Booking Exceptions/Query';
            caseIterator.Reason_For_Case__c = 'Equipment issue';
            caseIterator.origin = 'FPLUNITAO';
            
        }  
        
        Test.startTest();
        insert lstCases;
        Case caseInst = [SELECT Id, X4PL_Type__c  FROM Case WHERE Id =:lstCases[0].id];
        System.assertEquals(caseInst.X4PL_Type__c, 'Emergency Order Request', '4 PL type is EMERGENCY ORDER REQUEST');
        Test.stopTest();
    }
    
    @isTest
    public static void test4PLAirSpotCases(){
        Map<Id, Case> oldMap = new Map<Id, case>();
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {
            caseIterator.Subject = 'test AIR-Spot test';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLS;
            caseIterator.Product__c = '4PL';
            caseIterator.Type = 'Carrier booking'; 
            caseIterator.sub_type__c = 'Booking Exceptions/Query';
            caseIterator.Reason_For_Case__c = 'Equipment issue';
            caseIterator.origin = 'FPLUNITAO';
            
        }               
        Test.startTest();
        insert lstCases;
        Case caseInst = [SELECT Id, X4PL_Type__c  FROM Case WHERE Id =:lstCases[0].id];
        System.assertEquals(caseInst.X4PL_Type__c, 'Air Spot', '4PL Type is AIR SPOT');
        Test.stopTest();
    }
    
    @isTest
    public static void testpopulateISRCaseVisibilityValue(){
        User usr = [SELECT Id, Name,CM_Visibility__c FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        usr.CM_Visibility__c = 'Multi-Carrier';
        //update usr;
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {
            caseIterator.Subject = 'test populateISRCaseVisibilityValue';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLS;
            caseIterator.Product__c = '4PL';
            caseIterator.origin = 'FPLUNITAO';
            caseIterator.Case_Visibility__c = null;
            caseIterator.Resolver_Dept__c = 'Ocean: Legal';
            caseIterator.Type = 'Carrier booking'; 
            caseIterator.sub_type__c = 'Booking Exceptions/Query';
            caseIterator.Reason_For_Case__c = 'Equipment issue';
        }
        Test.startTest();
        try{
            UserDataGeneratorHelper_Test.initializeCustomerServiceUser();
            System.runAs(UserDataGeneratorHelper_Test.MSLCustomerServiceUser){
                insert lstCases;
            }
        } catch(Exception e){
            system.debug('Error is' +e.getMessage());
        }
        Test.stopTest();
        
        
    }             
    
    
    @isTest
    public static void populateFieldsOnBeforeInsertUpdate_test(){
        list<Contact> lstContact = new list<Contact>();
        Id profileId = [SELECT Id FROM Profile WHERE Name = '501 - Customer Community User'].Id;
        ContactData_Test.iNumberOfContacts = 5;
        ContactData_Test.createCustomerContacts();
        lstContact = ContactData_Test.lstContacts;
        Map<Id, Case> oldMap = new Map<Id, Case>();
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {
            caseIterator.Subject = 'test populateISRCaseVisibilityValue';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLS;
            caseIterator.Product__c = '4PL';
            caseIterator.Type = 'Carrier booking'; 
            caseIterator.sub_type__c = 'Booking Exceptions/Query';
            caseIterator.Reason_For_Case__c = 'Equipment issue';
            caseIterator.origin = 'FPLUNITAO';
            caseIterator.Case_Visibility__c = 'All Users';
            caseIterator.Resolver_Dept__c = 'Ocean: Legal';
        }
        
        insert lstcases;
        for(Case caseIterator : lstCases) {
            caseIterator.subject = '';
            oldMap.put(caseIterator.Id, caseIterator);
        }
        
        Test.startTest();
        update lstcases;
        CaseTriggerHandler casTriggerHandler = new CaseTriggerHandler();
        CaseRecordSelector caseRecord = new CaseRecordSelector(lstcases, oldMap, casTriggerHandler);
        caseRecord.checkNBAActionStatusOnCaseClose(lstCases);
        CaseFieldPopulator.populateFieldsOnBeforeInsertUpdate(lstcases, oldMap,casTriggerHandler, caseRecord);
        Test.stopTest();
        
        
    }             
    
    
    @isTest
    public static void testupdateWorkflowOnCaseClosure(){
        Map<Id, Case> oldMap = new Map<Id, Case>();
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {
            caseIterator.Subject = 'test updateWorkflowOnCaseClosure';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLS;
            caseIterator.Product__c = '4PL';
            caseIterator.Type = 'Carrier booking'; 
            caseIterator.sub_type__c = 'Booking Exceptions/Query';
            caseIterator.Reason_For_Case__c = 'Equipment issue';
            caseIterator.origin = 'FPLUNITAO';
        }               
        Test.startTest();
        insert lstCases;
        Agent_Workflow__c AW1 = new Agent_Workflow__c( Status__c = 'In-progress',Sender_Email__c = 'test@test.com',Case_ID__c = lstCases[0].Id, Run_Instant_DO__c = true );
        insert AW1;
        for(Case caseIterator : lstCases) {
            oldMap.put(caseIterator.Id, caseIterator);
            caseIterator.status = 'Closed - Not a case';
            caseIterator.Product__c = '4PL';
            caseIterator.Type = 'Carrier booking'; 
            caseIterator.sub_type__c = 'Booking Exceptions/Query';
            caseIterator.Reason_For_Case__c = 'Equipment issue';
            caseIterator.origin = 'FPLUNITAO';
            caseIterator.Resolved_Reason__c = 'Accepted';
            
        }
        update lstCases;
        list<case> caseList = [select id, status, origin, subject, Product__c from Case WHERE subject = 'test updateWorkflowOnCaseClosure LIMIT 1'];
        CaseTriggerHandler casTriggerHandler = new CaseTriggerHandler();
        system.debug('XYZ Test 1953 list of cases queried' +caselist);
        CaseFieldPopulator.updateWorkflowOnCaseClosure(caselist, oldMap, casTriggerHandler);
        Test.stopTest();
        
    }
    
    
    @isTest
    public static void testupdateWorkflowOwner(){
        list<SCM_Key_Client_Country_Mapping__mdt> scm = [Select id,On_Behalf_of_Account_ID__c,SCM_KC_Indicator__c from SCM_Key_Client_Country_Mapping__mdt where On_Behalf_of_Account_ID__c!=null AND SCM_KC_Indicator__c!=null limit 5 ];
        Map<Id, Case> oldMap = new Map<Id, Case>();
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        Account acc = AccountDataHelper_Test.createClientAccount();
        for(Case caseIterator : lstCases) {
            caseIterator.Subject = 'test updateWorkflowOwner';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLS;
            caseIterator.Product__c = '4PL';
            caseIterator.Product__c = 'Carrier Booking';
            caseIterator.Product__c = 'Cancel Booking';
            caseIterator.Product__c = 'Shipper booking cancelled';
            caseIterator.origin = 'FPLUNITAO';
            caseIterator.OwnerId = UserInfo.getUserId();
            caseIterator.Shipment_Number__c = '';
            caseIterator.Description = 'Test Description';
            caseIterator.On_Behalf_Account__c = acc.Id;
            caseIterator.SCM_KC_Indicator__c = 'Primark - Pakistan';
        }               
        Test.startTest();
        insert lstCases;
        Agent_Workflow__c AW1 = new Agent_Workflow__c( Status__c = 'In-progress',Sender_Email__c = 'test@test.com',Case_ID__c = lstCases[0].Id, Run_Instant_DO__c = true );
        insert AW1;
        for(Case caseIterator : lstCases) {
            oldMap.put(caseIterator.Id, caseIterator);
            caseIterator.OwnerId = userinfo.getUserId();
        }
        update lstCases;
        list<case> caseList = [select id, status, origin, subject, Product__c from Case WHERE subject='test updateWorkflowOwner' LIMIT 2];
        CaseTriggerHandler casTriggerHandler = new CaseTriggerHandler();
        CaseRecordSelector caseRecord = new CaseRecordSelector(lstcases, oldMap, casTriggerHandler);       
        Test.stopTest();
    }
    
    @istest
    public static void populateISRCaseVisibilityValue_Test(){
        User usr = [SELECT Id, Name,CM_Visibility__c FROM User WHERE username like 'system.owner@maersk.com%' AND IsActive = true];
        usr.CM_Visibility__c = 'Multi-Carrier';
        //update usr;
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {
            caseIterator.Subject = 'test populateISRCaseVisibilityValue';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLS;
            caseIterator.Product__c = '4PL';
            caseIterator.origin = 'FPLUNITAO';
            caseIterator.Case_Visibility__c = null;
            caseIterator.Resolver_Dept__c = 'Ocean: Legal';
        }
        Test.startTest();
        try{
            UserDataGeneratorHelper_Test.initializeCustomerServiceUser();
            System.runAs(UserDataGeneratorHelper_Test.MSLCustomerServiceUser){
                CAseFieldPopulator.populateISRCaseVisibilityValue(lstCases);
            }
        } catch(Exception e){
            system.debug('Error is' +e.getMessage());
        }
        Test.stopTest();
        
    }
    
    @isTest
    static void testcreateSubTypeTypeMap(){
        CaseFieldPopulator.createSubTypeTypeMap();
    }
    
    @isTest
    static void testpopulateDeliveryChannel(){
        Shipment__c shp = new Shipment__c();
        shp.Shipment_Number__c = '224069341';
        shp.Service_Mode__c = 'CY/CY';
        shp.Business_Unit_Id__c = '1384';
        shp.Business_Unit_Code__c = 'OMMCTMSL1';
        shp.Business_Unit__c = 'Maersk Shipping (Muscat)';
        shp.Shipment_Version_Id__c = '1CQTOFCHH6GLA';
        shp.Place_of_Receipt__c = 'Nouakchott';
        shp.Place_of_Delivery__c = 'Umm Qasr';
        shp.Shipment_Status__c = 'Active';
        shp.Operator__c = 'MAEU';
        shp.Product_Delivery_Agreement_Type__c = 'Sealand Twill';
        insert shp;
        
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        list<user> userlist = [select id,name from user where name like '%test%' LIMIT 2];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2; 
        CaseData_Test.conInstance = conInstance;
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        for(Case caseIterator : lstCases) {      
            caseIterator.Direction__c = 'Import';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Documentation'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Certificate/Letter';
            caseIterator.Reason_For_Case__c = 'Certificate/Letter Request';
            caseIterator.Case_Channel__c ='E-mail';   
            caseIterator.origin = 'MSLCLIMP';
            caseIterator.contactid = conInstance.id;
            caseIterator.Country__c = BDAGeographyData_Test.countryCL.Id;
            caseIterator.City__c = BDAGeographyData_Test.citySantiago.id;         
            caseIterator.ownerid = userlist[0].Id;
            caseIterator.Subject = 'TO BE UPDATED BY CHAT AGENT 224069341';
            caseIterator.description = 'TO BE UPDATED BY CHAT AGENT 224069341';
            caseIterator.MLL__c = false;
            caseIterator.shipment_number__c = '';
        }  
        insert lstCases;
    }
    
    @isTest
    public static void testassignISRCaseToQueueECL()
    {
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createISRCases();
        lstCases.addAll(CaseData_Test.lstCases);
        Test.startTest();
        Integer index = 0;
        for(Case caseIterator : lstCases) {
            caseIterator.SuppliedEmail = 'ContactTestData0@test.com';
            caseIterator.Resolver_Dept__c = 'ECL: Claim & Dispute'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.Collaboration_Reason__c = 'Claim';
            
        }  
        TriggerExecutionController.skipAllTriggers(false);
        insert lstCases;
        Group queueId = [SELECT Id FROM Group WHERE Name = 'Maersk Line ISR' and Type = 'Queue'];
        Case caseInst = [SELECT Id, OwnerId,Owner.Name  FROM Case WHERE Resolver_Dept__c='ECL: Claim & Dispute' limit 1];
        System.assertEquals(queueId.Id,caseInst.OwnerId, 'OWNER ID MATCHES');
        Test.stopTest(); 
    }
    
    @isTest
    static void testBeforeSaveOperations1(){
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        list<user> userlist = [select id,name from user where name like '%test%' LIMIT 2];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        CaseData_Test.conInstance = conInstance;
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        for(Case caseIterator : lstCases) {      
            caseIterator.Direction__c = 'Import';
            caseIterator.status = 'New';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Documentation'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Certificate/Letter';
            caseIterator.Reason_For_Case__c = 'Certificate/Letter Request';
            caseIterator.Case_Channel__c ='E-mail';   
            caseIterator.origin = 'MSLCLIMP';
            caseIterator.contactid = conInstance.id;
            caseIterator.Country__c = BDAGeographyData_Test.countryCL.Id;
            caseIterator.City__c = BDAGeographyData_Test.citySantiago.id;         
            caseIterator.ownerid = userlist[0].Id;
            caseIterator.Subject = 'Test';
            caseIterator.description = 'Test';
            caseIterator.MLL__c = false;
            caseIterator.shipment_number__c = '224069341';
        }  
        insert lstCases;
        Test.startTest();
        lstCases[0].Status = 'Closed - Resolved';
        lstCases[0].Resolution_Summary__c = 'Test';
        lstCases[0].OwnerId = userlist[1].Id;
        lstCases[0].New_Mail__c = true;
        update lstCases;
        lstCases[0].AccountId = null;
        lstCases[0].Status = 'Awaiting Customer Input';
        update lstCases;
        Test.stopTest();
    }
    
    @isTest
    static void testBeforeSaveOperations2(){
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        Case caseIterator = new Case();
        caseIterator.ContactId = conInstance.Id;
        caseIterator.AccountId = conInstance.AccountId;
        caseIterator.Subject = 'CaseTestData Subject';
        caseIterator.Description = 'CaseTestData Description';
        caseIterator.Thread_topic__c = 'Test';           
        caseIterator.Status = 'New';
        caseIterator.Type = 'Non-Case';
        caseIterator.Sub_Type__c = 'Spam/Case Created in Error';
        caseIterator.Country__c = BDAGeographyData_Test.countryCL.Id;
        caseIterator.City__c = BDAGeographyData_Test.citySantiago.id;  
        caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        caseIterator.Direction__c = 'Export';
        caseIterator.SuppliedEmail = 'test@maersk.com';
        caseIterator.Origin = 'MSLUSEXP';
        caseIterator.Disputed_Invoice_Number__c = '2345678909';
        caseIterator.Department__c = 'Customer Service';            
        caseIterator.Nature_of_Dispute_case__c = 'Invoice Amendment/Clarification';
        caseIterator.Invoice_Amendment_Clarification__c = 'Missing or wrong reference in the invoice';
        caseIterator.Service_Contract_Number__c = '123456ABC';
        caseIterator.Invoice_Type__c = 'Freight';
        caseIterator.Country__c = BDAGeographyData_Test.countryCL.Id;
        caseIterator.City__c = BDAGeographyData_Test.citySantiago.id; 
        caseIterator.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get(Label.Dispute).getRecordTypeId();
        insert caseIterator;
        Test.startTest();
        caseIterator.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get(Label.External_Case).getRecordTypeId();
        update caseIterator;
        Test.stopTest();
    }
    
    @isTest
    static void testBeforeSaveOperations3(){
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        list<user> userlist = [select id,name from user where name like '%test%' LIMIT 1];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        CaseData_Test.conInstance = conInstance;
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        for(Case caseIterator : lstCases) {      
            caseIterator.Direction__c = 'Import';
            caseIterator.status = 'Closed - Not a case';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = ''; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = '';
            caseIterator.Reason_For_Case__c = '';
            caseIterator.Case_Channel__c ='Chat';   
            caseIterator.origin = 'MSLCLIMP';
            caseIterator.contactid = conInstance.id;
            caseIterator.Country__c = BDAGeographyData_Test.countryCL.Id;
            caseIterator.City__c = BDAGeographyData_Test.citySantiago.id;         
            caseIterator.ownerid = userlist[0].Id;
            caseIterator.Subject = null;
            caseIterator.SuppliedEmail = null;
            caseIterator.description = 'Test';
            caseIterator.MLL__c = false;
            caseIterator.shipment_number__c = '224069341';
        }  
        insert lstCases;
        Test.startTest();
        lstCases[0].Subject = null;
        lstCases[0].AccountId = null;
        update lstCases;
        lstCases[0].contactid = conInstance.id;
        lstCases[0].AccountId = conInstance.AccountId;
        update lstCases;
        Test.stopTest();
    }
    
    @isTest
    static void testBeforeSaveOperations4(){
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        list<user> userlist = [select id,name from user where name like '%test%' LIMIT 1];
        
        Case caseIterator = new Case();
        caseIterator.ContactId = conInstance.Id;
        caseIterator.AccountId = conInstance.AccountId;
        caseIterator.Subject = 'CaseTestData Subject';
        caseIterator.Description = 'CaseTestData Description';
        caseIterator.Thread_topic__c = 'Test';           
        caseIterator.Status = 'New';
        caseIterator.Type = 'Non-Case';
        caseIterator.Sub_Type__c = 'Spam/Case Created in Error';
        caseIterator.Country__c = BDAGeographyData_Test.countryCL.Id;
        caseIterator.City__c = BDAGeographyData_Test.citySantiago.id;  
        caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        caseIterator.Direction__c = 'Export';
        caseIterator.SuppliedEmail = 'test@maersk.com';
        caseIterator.Origin = 'MSLUSEXP';
        caseIterator.Disputed_Invoice_Number__c = '2345678909';
        caseIterator.Department__c = 'Customer Service';            
        caseIterator.Nature_of_Dispute_case__c = 'Invoice Amendment/Clarification';
        caseIterator.Invoice_Amendment_Clarification__c = 'Missing or wrong reference in the invoice';
        caseIterator.Service_Contract_Number__c = '123456ABC';
        caseIterator.Invoice_Type__c = 'Freight';
        caseIterator.Country__c = BDAGeographyData_Test.countryCL.Id;
        caseIterator.City__c = BDAGeographyData_Test.citySantiago.id;
        caseIterator.Cluster__c = BDAGeographyData_Test.clusterCL.Id;
        insert caseIterator;
        Test.startTest();
        caseIterator.OwnerId = userlist[0].Id;
        caseIterator.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get(Label.Dispute).getRecordTypeId();
        update caseIterator;
        Test.stopTest();
    }
    
    @isTest
    public static void testBeforeSaveOperations5() {
        General_Settings__c gs = new General_Settings__c();
        gs.Bol_Date_for_ISR__c = System.now() - 365;
        insert gs;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.bCreate = false;
        CaseData_Test.createISRCases();
        if(!CaseData_Test.lstCases.isEmpty()){
            insert CaseData_Test.lstCases;
        }
        Id isrrtid = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get(Label.ISR).getRecordTypeId();
        Case cs = [Select Id From Case WHere RecordTypeId =: isrrtid LIMIT 1];
        cs.Compound_Index_for_BoL_Number__c = 'Test';
        cs.Collaboration_Reason__c = 'Claim Task';
        update cs;
        Test.startTest();
        cs.Resolver_Dept__c = 'Ocean: Finance - AFR Team';
        cs.Collaboration_Reason__c = 'AFR Closure';
        cs.BoL_Number__c = '123456787';
        update cs;
        Test.stopTest();
    }
    
    @isTest
    public static void testBeforeSaveOperations6() {
        List<Case> claimCaseList = new List<Case>();
        CaseData_Test.bCreate = false;
        CaseData_Test.createClaimCases();
        claimCaseList.addAll(CaseData_Test.lstCases);
        for(Case cs1 : claimCaseList){
            cs1.Sub_Type__c = 'Damage/Loss of Cargo';
        }
        insert claimCaseList;
    }
    
    @isTest
    static void testBeforeSaveOperations7(){
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        list<user> userlist = [select id,name from user where name like '%test%' LIMIT 2];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        CaseData_Test.conInstance = conInstance;
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        Entitlement entl = new Entitlement(name=Label.DefaultEntitlementName,accountid=conInstance.AccountId, StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
        insert entl;
        
        for(Case caseIterator : lstCases) {      
            caseIterator.Direction__c = 'Import';
            caseIterator.status = 'New';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Non-Case';
            caseIterator.Sub_Type__c = 'Spam/Case Created in Error'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.Reason_For_Case__c = '';
            caseIterator.Case_Channel__c ='E-mail';   
            caseIterator.origin = 'MSLCLIMP';
            caseIterator.contactid = conInstance.id;
            caseIterator.Country__c = BDAGeographyData_Test.countryCL.Id;
            caseIterator.City__c = BDAGeographyData_Test.citySantiago.id;         
            caseIterator.ownerid = userlist[0].Id;
            caseIterator.Subject = 'Test';
            caseIterator.description = 'Test';
            caseIterator.MLL__c = false;
            caseIterator.shipment_number__c = '224069341';
            caseIterator.SuppliedEmail = 'test@gmail.com';
        }  
        insert lstCases;
        
        Test.startTest();
        lstCases[0].Status = 'Closed - Not a case';
        lstCases[0].shipment_number__c = '224069342';
        update lstCases;
        Test.stopTest();
    }
    
    @isTest
    static void testBeforeSaveOperations8(){
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        
        list<Case> lstCases = new list<Case>();
        list<Case> claimRecoveryCaseList = new list<Case>();
        
        CaseData_Test.createClaimCases();
        lstCases.addAll(CaseData_Test.lstCases);
        insert lstCases;
        
        CaseData_Test.createClaimRecoveryCases();
        claimRecoveryCaseList.addAll(CaseData_Test.lstCases);
        for(Case cs : claimRecoveryCaseList){
            cs.ParentId = lstCases[0].Id;
        }
        Test.startTest();
        insert claimRecoveryCaseList;
        Test.stopTest();
    }
    
    @isTest
    public static void testExternalCaseHistory(){
        Geography__c geography = TestBusinessHelper.createGeography('United Kingdom', 'Country', null, true);
        Geography__c indGeography = TestBusinessHelper.createGeography('India', 'Country', null, true);
        
        Account acc = TestBusinessHelper.createAccount('Unassigned', false);
        acc.Id = null;
        acc.Name = 'Test Account';
        acc.Country__c = geography.Id;
        insert acc;
        
        Contact con = TestBusinessHelper.createContact(acc, 'Internal_Contact', BrandUtilities.MAERSKLINE, false);
        con.Id = null;
        con.Country__c = acc.Country__c;
        insert con;
        
        Contact con1 = TestBusinessHelper.createContact(acc, 'Internal_Contact', BrandUtilities.MAERSKLINE, false);
        con1.Id = null;
        con1.LastName = 'Test Con 2';
        con1.Email = 'test2@maersk.com';
        con1.Country__c = acc.Country__c;
        insert con1;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 224069341';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        cs.Auto_Assignment_Indicator__c = 'Auto Assigned';
        insert cs;
        
        Test.startTest();
        cs.Case_Channel__c = 'Telephone';
        cs.Case_Visibility__c = 'Multi-Carrier';
        cs.Cargo_Type__c = 'Reefer';
        cs.Priority = 'High';
        cs.ContactId = con1.Id;
        cs.Country__c = indGeography.Id;
        cs.Cluster_CSCE__c = true;
        cs.Auto_Assignment_Indicator__c = 'Manually Assigned';
        update cs;
        
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String sampleBody = '[{"id":"42799667443741083252","createdbyid":"0052o000009rvLRAAY","createddate":"2023-10-26T17:45:23","caseid":"5001X00000LQcaNQAT","datatype":"Text","field":"CaseVisibility","newvalue":"Multi-Carrier","oldvalue":"AllUsers","created__in_heroku":"2023-10-26"}]';
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));        
        Test.stopTest();
    }
    
    @isTest
    public static void testClaimCaseHistory(){
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        
        List<Case> lstCases = new List<Case>();
        
        CaseData_Test.createClaimCases();
        lstCases.addAll(CaseData_Test.lstCases);
        insert lstCases;
        
        Controlling_Entity__c cEntity = new Controlling_Entity__c();
        cEntity.Name = 'Test';
        cEntity.Status__c = 'Active';
        insert cEntity;
        
        Test.startTest();
        lstCases[0].Controlling_Entity__c = cEntity.Id;
        update lstCases;
        
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String sampleBody = '[{"id":"42799667443741083252","createdbyid":"0052o000009rvLRAAY","createddate":"2023-10-26T17:45:23","caseid":"5001X00000LQcaNQAT","datatype":"Text","field":"CaseVisibility","newvalue":"Multi-Carrier","oldvalue":"AllUsers","created__in_heroku":"2023-10-26"}]';
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers)); 
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateShipmentFromTpDocNumber(){
        Shipment__c ship = TestBusinessHelper.createShipment('224069341', false);
        ship.Id = null;
        insert ship;
        
        TP_Doc__c tp = new TP_Doc__c();
        tp.TP_Doc_Number__c = '224069342';
        tp.Shipment_Number__c = ship.Id;
        insert tp;
        
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        list<user> userlist = [Select id,name from user where name like '%test%' LIMIT 1];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        CaseData_Test.conInstance = conInstance;
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        for(Case caseIterator : lstCases) {      
            caseIterator.Direction__c = 'Import';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = ''; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = '';
            caseIterator.Reason_For_Case__c = '';
            caseIterator.Case_Channel__c ='E-mail';   
            caseIterator.origin = 'MSLCLIMP';
            caseIterator.contactid = conInstance.id;
            caseIterator.Country__c = BDAGeographyData_Test.countryCL.Id;
            caseIterator.City__c = BDAGeographyData_Test.citySantiago.id;         
            caseIterator.ownerid = userlist[0].Id;
            caseIterator.Subject = 'Test 224069342';
            caseIterator.SuppliedEmail = null;
            caseIterator.description = 'Test 224069342';
            caseIterator.MLL__c = false;
            caseIterator.Shipment_Number__c = '';
        }  
        insert lstCases;
    }
    
    @isTest
    public static void testcalculateBHonOwnerchange1(){
        list<case> lstCases2 = new list<case>();
        list<case> lstCases3 = new list<case>();
        list<user> u2 = [select id,name from user where name like '%System Owner%'];
        list<group> u = [select id,name from group where Type = 'Queue' and name like 'MSL%' limit 1];
        
        TriggerExecutionController.skipAllTriggers(true);
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.conInstance = conInstance;
        
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {
            caseIterator.SuppliedEmail = 'ContactTestData0@test.com';
            caseIterator.City__c = BDAGeographyData_Test.citySterling.Id;
            caseIterator.Case_Channel__c = 'E-mail';
            caseIterator.ownerid = u[0].id;
        }
        
        CaseData_Test.createClaimCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        CaseData_Test.createClaimRecoveryCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        //Dispute cases
        CaseData_Test.createDisputecases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        TriggerExecutionController.skipAllTriggers(false);
        
        
        
        Test.startTest();
        insert lstCases;
        
        Test.stopTest(); 
        
        
        for(Case cs : lstCases){         
            cs.Send_Case_Closure__c = 'Yes';
            cs.Case_Closure_Opt_Out_Reason__c = '';
            cs.ownerid = u2[0].id;
            cs.Country__c = BDAGeographyData_Test.countryUK.Id;
            lstCases2.add(cs);            
        }       
        update lstCases2; 
    } 
    
    @isTest
    public static void testcalculateBHonOwnerchange2(){
        list<case> lstCases2 = new list<case>();
        list<case> lstCases3 = new list<case>();
        list<user> u2 = [select id,name from user where name like '%System Owner%'];
        list<group> u = [select id,name from group where Type = 'Queue' and name like 'MSL%' limit 2];
                
        TriggerExecutionController.skipAllTriggers(true);
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.conInstance = conInstance;
        
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {
            caseIterator.SuppliedEmail = 'ContactTestData0@test.com';
            caseIterator.City__c = BDAGeographyData_Test.citySterling.Id;
            caseIterator.Case_Channel__c = 'E-mail';
            caseIterator.ownerid = u[0].id;
        }
        
        CaseData_Test.createClaimCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        CaseData_Test.createClaimRecoveryCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        //Dispute cases
        CaseData_Test.createDisputecases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        TriggerExecutionController.skipAllTriggers(false);
        
        Test.startTest();
        insert lstCases;
        
        Test.stopTest(); 
        
        for(Case cs : lstCases){         
            cs.Send_Case_Closure__c = 'Yes';
            cs.Case_Closure_Opt_Out_Reason__c = '';
            cs.ownerid = u[1].id;
            cs.Country__c = BDAGeographyData_Test.countryUK.Id;
            lstCases2.add(cs);            
        }       
        update lstCases2; 
    } 
    
    @isTest
    public static void testEntitlementUpdate(){
        Geography__c geography = TestBusinessHelper.createGeography('United Kingdom', 'Country', null, true);
        Geography__c indGeography = TestBusinessHelper.createGeography('India', 'Country', null, true);
        
        Account acc = TestBusinessHelper.createAccount('Unassigned', false);
        acc.Id = null;
        acc.Name = 'Test Account';
        acc.Country__c = geography.Id;
        insert acc;
        
        Contact con = TestBusinessHelper.createContact(acc, 'Internal_Contact', BrandUtilities.MAERSKLINE, false);
        con.Id = null;
        con.Country__c = acc.Country__c;
        insert con;
        
        Contact con1 = TestBusinessHelper.createContact(acc, 'Internal_Contact', BrandUtilities.MAERSKLINE, false);
        con1.Id = null;
        con1.LastName = 'Test Con 2';
        con1.Email = 'test2@maersk.com';
        con1.Country__c = acc.Country__c;
        insert con1;
        
        Validation_Rules_Bypass__c vb = new Validation_Rules_Bypass__c();
        vb.SetupOwnerId = UserInfo.getUserId();
        vb.Active__c = true;
        insert vb;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = '';
        cs.Type = null;
        cs.Sub_Type__c = null;
        insert cs;
        
        Case cs1 = [Select Id, EntitlementId From Case Where Id =: cs.Id];
        Assert.areEqual(Label.Default_Entitlement_Id, cs1.EntitlementId, 'Entitlement Assigned');
        
        Test.startTest();
        cs.Type = 'Charges, Invoice & Payment';
        cs.Sub_Type__c = 'Invoice / Payer Party';
        cs.Status = 'Triaged';
        update cs;
        
        Test.stopTest();
    }
    
    @isTest
    public static void testRRF(){
        Geography__c geography = TestBusinessHelper.createGeography('United Kingdom', 'Country', null, true);
        Geography__c indGeography = TestBusinessHelper.createGeography('India', 'Country', null, true);
        
        Account acc = TestBusinessHelper.createAccount('Unassigned', false);
        acc.Id = null;
        acc.Name = 'Test Account';
        acc.Country__c = geography.Id;
        insert acc;
        
        Contact con = TestBusinessHelper.createContact(acc, 'Internal_Contact', BrandUtilities.MAERSKLINE, false);
        con.Id = null;
        con.Country__c = acc.Country__c;
        insert con;
                
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', true);
        cs.Subject = 'Test';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = '';
        cs.Type = 'Charges, Invoice & Payment';
        cs.Sub_Type__c = 'Invoice / Payer Party';
        cs.Status = 'Triaged';
        cs.New_Mail__c = true;
        update cs;
        
        Case csISR = TestBusinessHelper.createCase(acc, con, 'ISR', false);
        csISR.Id = null;
        csISR.Subject = 'Test';
        csISR.Case_Channel__c = 'E-mail';
        csISR.Description = 'Test';
        csISR.ParentId = cs.Id;
        csISR.Resolver_Dept__c = 'Ocean: Sales';
        csISR.Collaboration_Reason__c = 'Different / Changed Service Contract Number';
        insert csISR;
        
        Case cs1 = [Select Id, New_Mail__c From Case Where Id =: cs.Id];
        Assert.areEqual(false, cs1.New_Mail__c, 'RRF unchecked');
        
        Test.startTest();
        TriggerExecutionController.skipCaseTrigger(true);
        cs1.New_Mail__c = true;
        update cs1;
        TriggerExecutionController.skipCaseTrigger(false);
        
        cs1.Status = 'In Progress';
        update cs1;
        
        Case cs2 = [Select Id, New_Mail__c From Case Where Id =: cs.Id];
        Assert.areEqual(false, cs2.New_Mail__c, 'RRF unchecked');
        Test.stopTest();
    }
    
    @isTest
    public static void testUpdateBAFromAddress(){
        Geography__c geography = TestBusinessHelper.createGeography('United Kingdom', 'Country', null, true);
        Geography__c indGeography = TestBusinessHelper.createGeography('India', 'Country', null, true);
        
        Account acc = TestBusinessHelper.createAccount('Unassigned', false);
        acc.Id = null;
        acc.Name = 'Test Account';
        acc.Country__c = geography.Id;
        insert acc;
        
        Contact con = TestBusinessHelper.createContact(acc, 'Internal_Contact', BrandUtilities.MAERSKLINE, false);
        con.Id = null;
        con.Country__c = acc.Country__c;
        insert con;
        
        Group grp = [Select Id From Group Where Type = 'Queue' AND Name = 'MSL - India - Export' LIMIT 1];
        
        List<Custom_Email_Service__c> eservicelist = new List<Custom_Email_Service__c>();
        Custom_Email_Service__c em = new Custom_Email_Service__c();
        em.BA_Address__c = 'testemailservice@maersk.com';
        em.Origin__c = 'MSLINEXP';
        em.Queue_Id__c = grp.Id;
        em.Service_Address__c = 'testemailservice@0-w9m230acs75ubo8tzlcdvy0varwhp0kqgio3wc0a2mui85ili.5r-4cc1eai.cs160.apex.sandbox.salesforce.com';
        em.Active__c = true;
        eservicelist.add(em);
        insert eservicelist;
                
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', true);
        cs.Subject = 'Test';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = '';
        cs.Type = 'Charges, Invoice & Payment';
        cs.Sub_Type__c = 'Invoice / Payer Party';
        cs.Status = 'Triaged';
        cs.New_Mail__c = true;
        cs.OwnerId = grp.Id;
        update cs;
        
        Case newCs = [Select Id, BA_From_Address__c From Case Where Id =: cs.Id];
        Assert.areEqual('testemailservice@maersk.com', newCs.BA_From_Address__c);
    }
    
}