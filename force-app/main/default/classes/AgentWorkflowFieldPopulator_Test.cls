/**
 * Author   : Avinash
 * Purpose  : Utility test class for creating Agent Workflow related data. 
 *
 * Revision Ref Number  Date         Owner                   Description
 * -------- ----------  -----------  -------------------     -----------
 * 1.0      IIP-149     27-Aug-2020  Avinash@UST             Created
 * 2.0      SPI-100     27-Jun-2022  Ronnie@SF               Removed brand hardcoding
 */
@isTest
public class AgentWorkflowFieldPopulator_Test {
    
    @testSetup
    public static void testDataSetup(){
        TriggerExecutionController.skipAllTriggers(true);
        //Contact Data Creation
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];        
        
        //Case Data creation
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.createExternalCases();
        List<Case> listCase = CaseData_Test.lstCases;
        listCase[0].Product__c = 'Ocean';
        listCase[0].Type = 'Documentation';
        listCase[0].Sub_Type__c = 'Manifest / Customs';
        listCase[0].Reason_For_Case__c = 'Workflow Request - Portal';
        
        listCase[1].Product__c = 'Ocean';
        listCase[1].Type = 'Documentation';
        listCase[1].Sub_Type__c = 'Manifest / Customs';
        listCase[1].Reason_For_Case__c = 'Workflow Request - Portal';
        insert listCase;
        TriggerExecutionController.skipAllTriggers(false);
    }
    
    public static testMethod void beforeInsert_updateCaseOwnerOnAWAutoApproved() {
        Test.startTest();
        List<case>listCase = [ SELECT id,OwnerId,Status,Resolution_Summary__c FROM Case WHERE Type = 'Documentation' AND Sub_Type__c = 'Manifest / Customs' AND Reason_For_Case__c = 'Workflow Request - Portal'];
        Agent_Workflow__c AW1 = new Agent_Workflow__c( Status__c = 'Approved',Sender_Email__c = 'test@test.com',Case_ID__c = listCase[0].Id );
        insert AW1;
        Test.stopTest();
    }
    
    public static testMethod void beforeUpdate_updateAgentWorkflowOwner() {
        Test.startTest();
        List<case>listCase = [ SELECT id,OwnerId,Status,Resolution_Summary__c FROM Case WHERE Type = 'Documentation' AND Sub_Type__c = 'Manifest / Customs' AND Reason_For_Case__c = 'Workflow Request - Portal'];
        Agent_Workflow__c AW1 = new Agent_Workflow__c( Sender_Email__c = 'test@test.com',Case_ID__c = listCase[0].Id );
        insert AW1;
        
        AW1.Status__c = 'Approved';
        update AW1;
        Test.stopTest();
    }
    
    public static testMethod void afterUpdate_updateChildWorkflowStatus(){
        Test.startTest();
        List<case>listCase = [ SELECT id,OwnerId,Status,Resolution_Summary__c FROM Case WHERE Type = 'Documentation' AND Sub_Type__c = 'Manifest / Customs' AND Reason_For_Case__c = 'Workflow Request - Portal'];
        system.debug('****listCase-->'+listCase);
        Agent_Workflow__c parentAW = new Agent_Workflow__c(Status__c = 'In-progress',Sender_Email__c = 'test@test.com',Case_ID__c = listCase[0].Id);
        insert parentAW;
        
        Agent_Workflow__c childAW1 = new Agent_Workflow__c(Status__c = 'In-progress',Sender_Email__c = 'test@test.com',ParentId__c = parentAW.Id);
        insert childAW1;
        
        Agent_Workflow__c childAW2 = new Agent_Workflow__c(Status__c = 'In-progress',Sender_Email__c = 'test@test.com',ParentId__c = parentAW.Id);
        insert childAW2;
        
        parentAW.Status__c = 'Approved';
        update parentAW;
        Test.stopTest();        
    }
    
    public static testMethod void updateCaseOwnerOnAWAutoApprovedNOTFuture(){
        Map<id,case>mapRelatedCases = new Map<id,Case>( [ SELECT id,OwnerId,Status,Resolution_Summary__c FROM Case WHERE Type = 'Documentation' AND Sub_Type__c = 'Manifest / Customs' AND Reason_For_Case__c = 'Workflow Request - Portal'] );
        
        id caseId =  (new list<id>(mapRelatedCases.keyset()) )[0] ;
        
        
        List<Agent_Workflow__c> listAW = new List<Agent_Workflow__c>();        
        Agent_Workflow__c parentAW1 = new Agent_Workflow__c(Status__c = 'Approved',Sender_Email__c = 'test@test.com',Case_ID__c = caseId );
        listAW.add( parentAW1 );
        insert listAW;
        
        AgentWorkflowFieldPopulator.updateCaseOwnerOnAWAutoApprovedNOTFuture( listAW,mapRelatedCases );
    }
    
     public static testMethod void updateSpotFMCFieldsTest() {
        Test.startTest();
        List<Geography__c> lstgeography = StaticFactory.getGetGeoListValues();
        Agent_Workflow__c AW1 = new Agent_Workflow__c(Country__c = lstgeography[0].id, Carrier__c = BrandUtilities.getBrandShortForm(BrandUtilities.SEALAND), Type__c = 'DnD and/or Penalty Fees Missing');
        insert AW1;       
    }
     public static testMethod void updateSpotFMCFieldsWithEmptyCountryTest() {
        Test.startTest();
        Agent_Workflow__c AW1 = new Agent_Workflow__c(Type__c='DnD and/or Penalty Fees Missing');
        insert AW1;       
    }
    
     public static testMethod void updateTypeFieldsWithTypeASHSS() {
        Test.startTest();
        Agent_Workflow__c AW1 = new Agent_Workflow__c(Type__c='HSS');
        insert AW1;       
    }
    
    public static testMethod void updateTypeFieldsWithTypeASHBL() {
        Test.startTest();
        Agent_Workflow__c AW1 = new Agent_Workflow__c(Type__c='House BL');
        insert AW1;       
    }
    
     public static testMethod void updateSpotFMCFieldsWithCountryTest() {
        Test.startTest();
          list<Geography__c> lstgeography = StaticFactory.getGetGeoListValues();
        Agent_Workflow__c AW1 = new Agent_Workflow__c(Country__c = lstgeography[0].id,Type__c='DnD and/or Penalty Fees Missing');
        insert AW1;       
    }
    
    
}