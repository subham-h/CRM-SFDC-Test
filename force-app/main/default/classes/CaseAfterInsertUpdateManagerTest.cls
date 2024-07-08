/** 
* @description 
* Author   : Vivek
* Purpose  : Test class to cover scenarios for CaseAfterInsertUpdateManager class
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-8791     01-09-2023   Vivek@Maersk            Created new class for covering scenarios for after insert/update case flows

*/
@isTest
public class CaseAfterInsertUpdateManagerTest {
    
    Public static List<Case> lstCases = new List<case>();
    
    @isTest
    public static void sendNotificationOnClosedISRTest(){
        TriggerExecutionController.skipAllTriggers(true); 
        Account shipperAcc = TestBusinessHelper.createAccount('Client_Account', true);
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        TestDataFactoryHelper.createISRCaseML();
        
        TriggerExecutionController.skipAllTriggers(false); 
        Test.startTest();
        
        Case thisCase = [select id,Country__c,Product__c,Case_Channel__C,Count_Case_Emails__c,Cluster__c,Region__r.BDA_Code__C from case limit 1];
        
        thisCase.Status = 'Closed - Resolved';
        thisCase.Resolution_Summary__c = 'Test case';
        
        update thisCase;
        
        Test.stopTest();
    }
    @isTest
    public static void disputeNotificationsOnEmailTrgCondTest1(){
        
        Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
        Account shipperAcc = TestBusinessHelper.createAccount('Client_Account', true);
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.createDisputecases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        for(Case thisCase: lstCases){
            
            thisCase.Product__c = 'Ocean';
            thisCase.Case_Channel__C = 'E-mail';
            thisCase.Origin = 'MSLINEXP';
            
        }
        
        Test.startTest();
        insert lstCases;
        
        Case thisCase = [select id,Country__c,Product__c,Case_Channel__C,Count_Case_Emails__c,Cluster__c,Region__r.BDA_Code__C from case where recordtype.name = 'Dispute' limit 1];
        
        thisCase.Status = 'Closed - Not a case';
        thisCase.Resolution_Summary__c = 'Test case';
        thisCase.Dispute_Email_Trigger_Condition__c = 'LOI';
        
        update thisCase;
        
        Test.stopTest();
        
    }
    @isTest
    public static void disputeNotificationsOnEmailTrgCondTest2(){
        
        Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
        Account shipperAcc = TestBusinessHelper.createAccount('Client_Account', true);
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.createDisputecases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        for(Case thisCase: lstCases){
            
            thisCase.Product__c = 'Ocean';
            thisCase.Case_Channel__C = 'E-mail';
            thisCase.Origin = 'MSLINEXP';
            
        }
        Test.startTest();
        
        insert lstCases;
        
        
        Case thisCase = [select id,Country__c,Product__c,Case_Channel__C,Count_Case_Emails__c,Cluster__c,Region__r.BDA_Code__C from case where recordtype.name = 'Dispute' limit 1];
        
        thisCase.Dispute_Email_Trigger_Condition__c = 'Acceptance';
        update thisCase;
        
        
        Test.stopTest();
        
    }
    
    @isTest
    public static void preparePublishCaseToPlatformEventTest(){
        
        TriggerExecutionController.skipAllTriggers(true); 
        Account shipperAcc = TestBusinessHelper.createAccount('Client_Account', true);
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        for(Case thisCase: lstCases){
            
            thisCase.Product__c = 'Ocean';
            thisCase.Case_Channel__C = 'E-mail';
            thisCase.Origin = 'MSLINEXP';
            
        }
        insert lstCases;
        
        TriggerExecutionController.skipAllTriggers(false); 
        Test.startTest();
        
        Case thisCase = [select id,Resolver_Dept__c, Country__c,Product__c,Case_Channel__C,Count_Case_Emails__c,Cluster__c,Region__r.BDA_Code__C from case   limit 1];
        
        thisCase.Resolver_Dept__c ='Ocean: Finance - Account Receivables' ;
        
        update thisCase;
        
        Test.stopTest();
    }
    
    @isTest
    public static void sendCaseEscalationSendEmailAlertsTest(){
        TriggerExecutionController.skipAllTriggers(true); 
        Account shipperAcc = TestBusinessHelper.createAccount('Client_Account', true);
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        for(Case thisCase: lstCases){
            
            thisCase.Product__c = 'Ocean';
            thisCase.Case_Channel__C = 'E-mail';
            thisCase.Origin = 'MSLINEXP';
        }
        insert lstCases;
        
        TriggerExecutionController.skipAllTriggers(false); 
        Test.startTest();
        
        Case thisCase = [select id,IsEscalated, Resolver_Dept__c, Country__c,Product__c,Case_Channel__C,Count_Case_Emails__c,Cluster__c,Region__r.BDA_Code__C from case   limit 1];
        
        thisCase.IsEscalated =true ;
        
        update thisCase;
        
        Test.stopTest();
    }
    
    @isTest
    public static void taskcreationAndSendEmailAlertsTest() {
        ConnectiveTaskTestUtility.bypassValidationRulesForUser(UserInfo.getUserId());
        IncidentData_Test.createClaimEventIncidentsForLNS();
        List<Incident__c> testIncident = new List<incident__c>();
        testincident.addall(IncidentData_Test.lstIncidents);
        
        List<Case> claimCaseList = new List<Case>();
        CaseData_Test.bCreate = false;
        CaseData_Test.createClaimCases();
        claimCaseList.addAll(CaseData_Test.lstCases);
        for(Case cs1 : claimCaseList){
            cs1.Product__c = 'Ocean Contract;Ocean Freesale';
            cs1.Sub_Type__c = 'Damage/Loss of Cargo';
            cs1.status = 'Potential Claim';
            cs1.Claim_Event__c = testincident[0].Id;
            cs1.Nature_Of_Damage__c = 'Damage To Cargo - Dry';
            cs1.Cause_of_Damage__c = 'Booking Error';
            cs1.Number_Of_Public_Case_Comments__c = 1;
        }
        insert claimCaseList;
        Test.startTest();
        claimCaseList[0].Number_Of_Public_Case_Comments__c = 2;
        claimCaseList[0].Status = 'In Progress';
        update claimCaseList;
        Test.stopTest();
    }
    
    @isTest
    public static void testSCMGlobalHandshakeEmail(){
        Geography__c geography = TestBusinessHelper.createGeography('Denmark', 'Country', null, true);
        
        Account acc = TestBusinessHelper.createAccount('Unassigned', false);
        acc.Id = null;
        acc.Name = 'Test Account';
        acc.Country__c = geography.Id;
        insert acc;
        
        Contact con = TestBusinessHelper.createContact(acc, 'Internal_Contact', BrandUtilities.MAERSKLINE, false);
        con.Id = null;
        con.Country__c = acc.Country__c;
        insert con;
        
       	Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 234559625';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        cs.Origin = 'SCMGLOBALACT';
        cs.SCM_KC_Indicator__c = 'Action - Bangladesh';
        cs.Liner_Brand__c = 'Maersk L&S';
        insert cs;
    }    
}