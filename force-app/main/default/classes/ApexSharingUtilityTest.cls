/*
* Author   : Richa
* Purpose  : Test class for ApexSharingUtility class.
*
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-4859     13-06-2022  Richa@Maersk            Created.
* 2.0      CRM0000030  12-09-2022  Ronnie@SF               Improved retrieval of recordtype info
* 3.0      SPI-100     23/09/2022  Ronnie@SF               Removed brand hardcoding
* 4.0      SPI-100     27/02/2023  Saradha@UST             To Cover delete
*/
@isTest
public class ApexSharingUtilityTest {
    @isTest
    public static void test4PLApexSharingExternal(){
        General_Settings__c gs = new General_Settings__c();
        gs.Apex_Sharing_Retry_status__c = true;
        insert gs;
        
        Group unileverGroup = [SELECT Id from Group WHERE DeveloperName = 'SFU_All_4PL_Unilever_Users' LIMIT 1];
        // Group syngentaGroup = [SELECT Id from Group WHERE DeveloperName = 'SFU_All_4PL_Syngenta_Users' LIMIT 1];
        List<User_Group_Assignment__c> lstUserGroupAssignmentToInsert = new List<User_Group_Assignment__c>();
        lstUserGroupAssignmentToInsert.add(new User_Group_Assignment__c(User_Field__c ='SF_4PL_Account__c', Name = 'Unilever', Public_Group_Ids__c = unileverGroup.Id ));
        // lstUserGroupAssignmentToInsert.add(new User_Group_Assignment__c(User_Field__c ='SF_4PL_Account__c', Name = 'Syngenta', Public_Group_Ids__c = syngentaGroup.Id ));
        insert lstUserGroupAssignmentToInsert;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCasesII();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {
            caseIterator.Direction__c = 'Export';
            caseIterator.status = 'Triaged'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLS;
            caseIterator.Origin = '';
            caseIterator.SuppliedEmail = 'test@maersk.com';
            caseIterator.Type='Booking';
            caseIterator.Sub_Type__c='New Booking Request'; 
            caseIterator.Reason_For_Case__c = 'Booking Request';   
            caseIterator.Case_Visibility__c = '4PL';
            caseIterator.SF_4PL_Account__c = 'Unilever';
        } 
        
        Test.startTest();
        insert lstCases;
        Test.stopTest(); 
        List<CaseShare> lstCaseShare = [SELECT Id FROM CaseShare WHERE CaseId =: lstCases[0].Id AND RowCause = 'Manual'];
        system.assertEquals(1,lstCaseShare.size(),'CaseShare created'); 
        lstCases[0].Case_Visibility__c = 'All Users';
        lstCases[0].SF_4PL_Account__c = '';   
        update lstCases;
    }
    
    @isTest
    public static void test4PLApexSharingISR(){
        General_Settings__c gSetting = new General_Settings__c();
        gSetting.Apex_Sharing_Retry_status__c = true;
        insert gSetting;
        
        Group all4PLGroup = [SELECT Id from Group WHERE DeveloperName = 'SFU_All_4PL_Users' LIMIT 1];
        List<User_Group_Assignment__c> lstUserGroupAssignmentToInsert = new List<User_Group_Assignment__c>();
        lstUserGroupAssignmentToInsert.add(new User_Group_Assignment__c(User_Field__c ='SF_4PL_Account__c', Name = 'All 4PL Users', Public_Group_Ids__c = all4PLGroup.Id ));
        insert lstUserGroupAssignmentToInsert;
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createISRCases();
        lstCases.addAll(CaseData_Test.lstCases);
        Integer index = 0;
        for(Case caseIterator : lstCases) {
            caseIterator.SuppliedEmail = 'ContactTestData0@test.com';
            caseIterator.Requestor_Dept__c = 'All Users';
            caseIterator.Resolver_Dept__c = 'Ocean: Sales'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.SuppliedEmail = 'test@maersk.com';
            caseIterator.Security_Code__c = '1235' + index++;
        }  
        
        Test.startTest();
        insert lstCases;
        Survey__c svy = new Survey__c(); 
        svy.Case__c = lstCases[0].Id;
        svy.RecordTypeId = Schema.SObjectType.Survey__c.getRecordTypeInfosByDeveloperName().get('Case_Survey').getRecordTypeId();
        svy.Case_Security_Code__c = lstCases[0].Security_Code__c;
        insert svy;     
        Test.stopTest(); 
        List<CaseShare> lstCaseShare = [SELECT Id FROM CaseShare WHERE CaseId =: lstCases[0].Id AND RowCause = 'Manual'];
        system.assertEquals(1,lstCaseShare.size(),'CaseShare created');       
    }
    
    @isTest
    public static void test4PLApexSharingError(){
        General_Settings__c gSetting = new General_Settings__c();
        gSetting.Apex_Sharing_Retry_status__c = true;
        insert gSetting;
        
        List<User_Group_Assignment__c> lstUserGroupAssignmentToInsert = new List<User_Group_Assignment__c>();
        lstUserGroupAssignmentToInsert.add(new User_Group_Assignment__c(User_Field__c ='SF_4PL_Account__c', Name = 'All 4PL Users', Public_Group_Ids__c = '' ));
        insert lstUserGroupAssignmentToInsert;
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createISRCases();
        lstCases.addAll(CaseData_Test.lstCases);
        //Integer index = 0;
        for(Case caseIterator : lstCases) {
            caseIterator.SuppliedEmail = 'ContactTestData0@test.com';
            caseIterator.Requestor_Dept__c = 'All Users';
            caseIterator.Resolver_Dept__c = 'Ocean: Sales'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.SuppliedEmail = 'test@maersk.com';
        }  
        
        Test.startTest();
        insert lstCases;  
        
        Test.stopTest(); 
        List<CaseShare> lstCaseShare = [SELECT Id FROM CaseShare WHERE CaseId =: lstCases[0].Id AND RowCause = 'Manual'];
        system.assertEquals(0,lstCaseShare.size(),'CaseShare not created');      
    }
    
    @isTest
    public static void test4PLApexSharingPortal(){
        General_Settings__c gs = new General_Settings__c();
        gs.Apex_Sharing_Retry_status__c = true;
        insert gs;
        
        Group unileverGroup = [SELECT Id from Group WHERE DeveloperName = 'SFU_All_4PL_Unilever_Users' LIMIT 1];
        List<User_Group_Assignment__c> lstUserGroupAssignmentToInsert = new List<User_Group_Assignment__c>();
        lstUserGroupAssignmentToInsert.add(new User_Group_Assignment__c(User_Field__c ='SF_4PL_Account__c', Name = 'Unilever', Public_Group_Ids__c = unileverGroup.Id ));
        insert lstUserGroupAssignmentToInsert;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createPortalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) { 
            caseIterator.Case_Visibility__c = 'All Users';
        } 
        
        Test.startTest();
        insert lstCases;
        Test.stopTest(); 
        //List<CaseShare> lstCaseShare = [SELECT Id FROM CaseShare WHERE CaseId =: lstCases[0].Id AND RowCause = 'Manual'];
        lstCases[0].Case_Visibility__c = '4PL';
        lstCases[0].SF_4PL_Account__c = 'Unilever';  
        update lstCases;
    }
    
    @isTest
    public static void test4PLApexSharingISRDelete(){
        General_Settings__c gSetting = new General_Settings__c();
        gSetting.Apex_Sharing_Retry_status__c = true;
        insert gSetting;
        
        Group all4PLGroup = [SELECT Id from Group WHERE DeveloperName = 'SFU_All_4PL_Users' LIMIT 1];
        Group testGroupBE_MSL = new Group();
        testGroupBE_MSL.Name  = Label.TestClean_PublicGroupNameMSL_DE;
        testGroupBE_MSL.DeveloperName = 'Test_Id';
        Database.insert(testGroupBE_MSL);
        
        List<User_Group_Assignment__c> lstUserGroupAssignmentToInsert = new List<User_Group_Assignment__c>();
        lstUserGroupAssignmentToInsert.add(new User_Group_Assignment__c(User_Field__c ='SF_4PL_Account__c', Name = 'All 4PL Users', Public_Group_Ids__c = all4PLGroup.Id ));
        
        insert lstUserGroupAssignmentToInsert;
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createISRCases();
        lstCases.addAll(CaseData_Test.lstCases);
        Integer index = 0;
        for(Case caseIterator : lstCases) {
            caseIterator.SuppliedEmail = 'ContactTestData0@test.com';
            caseIterator.Requestor_Dept__c = 'All Users';
            caseIterator.Resolver_Dept__c = 'Ocean: Sales'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.SuppliedEmail = 'test@maersk.com';
            caseIterator.Security_Code__c = '1235' + index++;
        }  
        
        Test.startTest();
        insert lstCases;
        Set<Id> setRecordIds = new Set<Id>();
        for(Case casrecTmp : lstCases){
            setRecordIds.add(casrecTmp.Id);
        }
        List<CaseShare> lstCaseShare = [SELECT Id FROM CaseShare WHERE CaseId =: lstCases[0].Id AND RowCause = 'Manual'];
        CaseShare caseShrTmp = new CaseShare();
        caseShrTmp.RowCause = 'Manual';
        caseShrTmp.CaseAccessLevel = 'Edit';
        caseShrTmp.UserOrGroupId = testGroupBE_MSL.Id;
        caseShrTmp.CaseId = lstCases[0].Id;
        insert caseShrTmp;
        
        ApexSharingUtility.createShareRecord(setRecordIds, 'Case', 'Case_Visibility__c', 'Edit', 'Manual', True);   
        Test.stopTest(); 
        
        system.assertEquals(1,lstCaseShare.size(),'CaseShare created');         
    }
    
}