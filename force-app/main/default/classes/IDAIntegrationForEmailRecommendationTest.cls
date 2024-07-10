/**
* Test class for IDAIntegrationForEmailRecommendationTest
* 
* Version  Date         Owner                   RQ#           Description
*******************************************************************************************************************

* 1.0          20/07/2023          Vivek@maersk                SC-8488- Perform callout to send CaseDetails to IDA
*/

@isTest
public class IDAIntegrationForEmailRecommendationTest {
    
    Public static List<Case> lstCases = new List<case>();
    public static List<Case_Recommendation__c> caseRecomList = new List<Case_Recommendation__c>();

    @TestSetup
    static void setupTestData(){
        
        Geography__c countryIN = TestBusinessHelper.createGeography('India', 'Country', null,'IN',true);
        BDA__c parentBDA = TestBusinessHelper.createBDA('India and Bangladesh Area and Region', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true);
        BDA__c childBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'null', parentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, countryIN.Id, null, true);
        
        Account acc = TestBusinessHelper.createAccount('Unassigned', false);
        acc.Id = null;
        acc.Name = 'Test Account';
        acc.Country__c = countryIN.Id;
        insert acc;
        
        Contact con = TestBusinessHelper.createContact(acc, 'Internal_Contact', BrandUtilities.MAERSKLINE, false);
        con.Id = null;
        con.Country__c = acc.Country__c;
        insert con;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 224069341';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        cs.Product__c = 'Ocean';
        cs.Case_Channel__C = 'E-mail';
        cs.Origin = 'MSLINEXP';
        cs.Country__c = countryIN.Id;
        cs.type = 'Charges, Invoice & Payment';
        cs.Sub_Type__c = 'Invoice / Payer Party';
        cs.Reason_For_Case__c = 'Invoice Query';
        cs.suppliedEmail = 'abc@gmail.com';
		cs.Cluster__c = childBDA.id;
        cs.Region__c  = parentBDA.id;
        lstCases.add(cs);

        
        Case cs2 = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs2.Id = null;
        cs2.Subject = 'Test2 224069341';
        cs2.Case_Channel__c = 'E-mail';
        cs2.Description = 'Test2 new case';
        cs2.Product__c = 'Ocean';
        cs2.Case_Channel__C = 'E-mail';
        cs2.Origin = 'MSLINEXP';
        cs2.Country__c = countryIN.Id;
        cs2.type = 'Charges, Invoice & Payment';
        cs2.Sub_Type__c = 'Invoice / Payer Party';
        cs2.Reason_For_Case__c = 'Invoice Query';
        cs.suppliedEmail = 'abc@gmail.com';
		cs2.Cluster__c = childBDA.id;
        cs2.Region__c  = parentBDA.id;
        
        lstCases.add(cs2);
        insert lstCases;
                
        Case_Recommendation__c emailRecommendationRecord1 = TestBusinessHelper.createCaseRecommendation( 'Email_Recommendation', false);
        emailRecommendationRecord1.id = null;
        emailRecommendationRecord1.Case__c = cs.Id;
		caseRecomList.add(emailRecommendationRecord1);
        Case_Recommendation__c emailRecommendationRecord2 = TestBusinessHelper.createCaseRecommendation('Email_Recommendation',  false);
        emailRecommendationRecord2.Email_Recommendation__c = 'Dear Chris, \n\n Please proceed with the case updates.\n\n thanks and Regards\n\n';
        emailRecommendationRecord2.id = null;
        emailRecommendationRecord2.Case__c = cs.Id;
        emailRecommendationRecord2.Priority__c = 1;
        emailRecommendationRecord2.Recommendation_Summary__c = '[Proceed further]';
		caseRecomList.add(emailRecommendationRecord2);
        Case_Recommendation__c resolutionRecommendationRecord2 = TestBusinessHelper.createCaseRecommendation('Resolution_Recommendation',  false);
        resolutionRecommendationRecord2.Email_Recommendation__c = 'Dear Chris, \n\n BL and shipments are released.\n\n thanks and Regards\n\n';
        resolutionRecommendationRecord2.id = null;
        resolutionRecommendationRecord2.Case__c = cs2.Id;
        resolutionRecommendationRecord2.Priority__c = 1;
        resolutionRecommendationRecord2.Recommendation_Summary__c = 'BL has been released, Shipment has been shipped';
		caseRecomList.add(resolutionRecommendationRecord2);
        insert caseRecomList;
        
        
    }
    
    @isTest
    public static void sendEmailRecommendationData(){
        
        Test.startTest();
        Case thisCase = [select id,Country__c,Product__c,Case_Channel__C,Count_Case_Emails__c,Cluster__c,Region__r.BDA_Code__C from case limit 1];
        EmailMessage newEmail = new EmailMessage(FromAddress = 'test@gmail.com', Incoming = True, ToAddress= 'hello@dummy.com', Subject = 'Test email', TextBody = '23456 ', ParentId = thisCase.Id,CcAddress='dummy.import@maersk.com');
        insert newEmail;
        
        Case caseRec=[Select Id,CC_Flag__c,Priority from case where Id=:thisCase.Id];
        
        Test.stopTest();
    }
    
    @isTest
    public static void sendResolutionRecommendationData(){
        
        Test.startTest();
        Case thisCase = [select id,Country__c,Product__c,Case_Channel__C,Count_Case_Emails__c,Cluster__c,Region__r.BDA_Code__C from case where subject = 'Test2 224069341' limit 1];
        EmailMessage newEmail = new EmailMessage(FromAddress = 'test@gmail.com', Incoming = True, ToAddress= 'hello@dummy.com', Subject = 'Test email', TextBody = '23456 ', ParentId = thisCase.Id,CcAddress='dummy.import@maersk.com');
        insert newEmail;
        
        Case caseRec=[Select Id,CC_Flag__c,Priority from case where Id=:thisCase.Id];
        
        Test.stopTest();
    }
    
    @isTest
    public static void sendEmailWithRecommendation(){
        
        Test.startTest();
        Case thisGen1Case = [select id,Country__c,Product__c,Email_Recommendation_Acceptance__c,Case_Channel__C,Count_Case_Emails__c,Total_Outbound_Emails_minus_Handshake__c,Cluster__c,Region__r.BDA_Code__C from case limit 1];
        Case thisGen2Case = [select id,Country__c,Product__c,Email_Recommendation_Acceptance__c,Case_Channel__C,Count_Case_Emails__c,Total_Outbound_Emails_minus_Handshake__c,Cluster__c,Region__r.BDA_Code__C from case where subject = 'Test2 224069341' limit 1];
        List<Case_Recommendation__c> thisRecommendation =EmailRecommendationsWithAIController.getEmailRecommendations(thisGen1Case.Id,'Email Recommendation');
        List<Case_Recommendation__c> thisResolutionRecommendation =EmailRecommendationsWithAIController.getResolutionRecommendations(thisGen2Case.Id,'Resolution Recommendation');

        thisGen1Case.Count_Case_Emails__c =2;
        thisGen1Case.Email_Recommendation_Acceptance__c = 'Recommendations Available';
        TriggerExecutionController.skipCaseTrigger(true);
		
        Update thisGen1Case;
        TriggerExecutionController.skipCaseTrigger(false);
        
        EmailRecommendationsWithAIController.updateActionStatus(thisRecommendation[0].Id, thisGen1Case.Id,'Email Recommendation');
        EmailRecommendationsWithAIController.updateActionStatus(thisResolutionRecommendation[0].Id, thisGen2Case.Id,'Resolution Recommendation');


        EmailMessage newEmail = new EmailMessage(FromAddress = 'test@maersk.com', Incoming = False, ToAddress= 'hello@dummy.com', Subject = 'Test email', TextBody = 'Dear User, \n\n Please accept this recommendation.\\n thanks', ParentId = thisGen1Case.Id,CcAddress='dummy.import@maersk.com');
        insert newEmail;
        
        Integer difference = IDAIntegrationForEmailRecommendation.getLevenshteinDistance(newEmail.TextBody, thisRecommendation[0].email_recommendation__c);
        Case caseRec=[Select Id,CC_Flag__c,Priority from case where Id=:thisGen1Case.Id];
        
        Test.stopTest();
    }
    
    @isTest
    public static void checkAIAgentFlagUpdate(){
        
        Test.startTest();
        
        Case thisCase = [select id,Country__c,origin,Direction__c,Product__c,Email_Recommendation_Acceptance__c,Case_Channel__C,Count_Case_Emails__c,Total_Outbound_Emails_minus_Handshake__c,Cluster__c,Region__r.BDA_Code__C from case limit 1];
		thisCase.status = 'Closed - Resolved';
        thisCase.Resolution_Summary__c = 'Check if AI agent flag is updated';
        Update thisCase;
        
        Case caseRec=[Select Id,CC_Flag__c,AI_Agent_Email_Recommendation_User__c, Priority from case where Id=:thisCase.Id];
        
        Test.stopTest();
    }
    

    
        @isTest
    	public static void checkrecommendationFlagTest(){
        
        Test.startTest();
        Case thisGen1Case = [select id,Country__c,Product__c,Email_Recommendation_Acceptance__c,Case_Channel__C,Count_Case_Emails__c,Total_Outbound_Emails_minus_Handshake__c,Cluster__c,Region__r.BDA_Code__C from case limit 1];
        List<Case_Recommendation__c> thisRecommendation =EmailRecommendationsWithAIController.getEmailRecommendations(thisGen1Case.Id,'Email Recommendation');

        thisGen1Case.Count_Case_Emails__c =2;
        thisGen1Case.Email_Recommendation_Acceptance__c = 'Recommendations Available';
        TriggerExecutionController.skipCaseTrigger(true);
		
        Update thisGen1Case;
        TriggerExecutionController.skipCaseTrigger(false);
        
        EmailRecommendationsWithAIController.updateActionStatus(thisRecommendation[0].Id, thisGen1Case.Id,'Email Recommendation');


        EmailMessage newEmail = new EmailMessage(FromAddress = 'test@maersk.com', Incoming = False, ToAddress= 'hello@dummy.com', Subject = 'Test email', TextBody = 'Dear User, \n\n Please accept this recommendation.\\n thanks', ParentId = thisGen1Case.Id,CcAddress='dummy.import@maersk.com');
        insert newEmail;
        
        EmailRecommendationsWithAIController.getCaseRecommendationFlag(thisGen1Case.Id);
        Case caseRec=[Select Id,CC_Flag__c,Priority,AI_Relevance_percentage_Flag__c from case where Id=:thisGen1Case.Id];
        Test.stopTest();
    }
    
    	@isTest
        public static void sendCaseWithRecommendationTest(){
            
                   
        Test.startTest();
        Case thisGen1Case = [select id,Country__c,Product__c,Email_Recommendation_Acceptance__c,Case_Channel__C,Count_Case_Emails__c,Total_Outbound_Emails_minus_Handshake__c,Cluster__c,Region__r.BDA_Code__C from case limit 1];
        List<Case_Recommendation__c> thisRecommendation =EmailRecommendationsWithAIController.getEmailRecommendations(thisGen1Case.Id,'Email Recommendation');
        //thisGen1Case.Count_Case_Emails__c =1;
        thisGen1Case.Email_Recommendation_Acceptance__c = 'Recommendations Available';
        TriggerExecutionController.skipCaseTrigger(true);
		
        Update thisGen1Case;
        TriggerExecutionController.skipCaseTrigger(false);
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String sampleres = '{"recommendation1Score": 0.8230167031288147,"recommendation2Score": 0.8114129900932312,"recommendation3Score": 0.8516194820404053,"caseID": "5002o00003NtgVYAAZ"}';
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleres, headers));
        


        EmailMessage newEmail = new EmailMessage(FromAddress = 'test@maersk.com', Incoming = False, ToAddress= 'hello@dummy.com', Subject = 'Test email', TextBody = 'Dear User, \n\n Please accept this recommendation.\\n thanks', ParentId = thisGen1Case.Id,CcAddress='dummy.import@maersk.com');
        insert newEmail;
        
        Case caseRec=[Select Id,CC_Flag__c,Priority from case where Id=:thisGen1Case.Id];
        
        Test.stopTest();
 
    }
    
    @isTest
    public static void changeOwnerToPreviousQueueTest(){
        User maerskLineUser = TestBusinessHelper.createUser('Sales', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
        
        Test.startTest();
        
        Case thisGen1Case = [select id,Country__c,Product__c,Email_Recommendation_Acceptance__c,Case_Channel__C,Count_Case_Emails__c,Total_Outbound_Emails_minus_Handshake__c,Cluster__c,Region__r.BDA_Code__C from case where subject = 'Test2 224069341' limit 1];
        List<Case_Recommendation__c> thisRecommendation =EmailRecommendationsWithAIController.getEmailRecommendations(thisGen1Case.Id,'Resolution Recommendation');
        
        thisGen1Case.Count_Case_Emails__c =2;
        thisGen1Case.Email_Recommendation_Acceptance__c = 'Recommendations Available';
        thisGen1Case.OwnerId = maerskLineUser.Id;
        TriggerExecutionController.skipCaseTrigger(true);

        Update thisGen1Case;
         TriggerExecutionController.skipCaseTrigger(false);
         
        EmailRecommendationsWithAIController.changeOwnerToPreviousQueue(thisGen1Case.Id,thisRecommendation[0].Id,'Test');
       
        Test.stopTest();
    }
    
     @isTest
    public static void sendCaseWithRecommendationUpdateTest(){
        
        
        Test.startTest();
        
        Case thisGen1Case = [select id,Country__c,RecordTypeId, Origin, Status, Direction__c, SCV_Code__c, Product__c,Case_Country__c,Email_Recommendation_Acceptance__c,AccountId,Case_Channel__C,Count_Case_Emails__c,Total_Outbound_Emails_minus_Handshake__c,Cluster__c,Region__r.BDA_Code__C from case limit 1];
        EmailMessage newEmail = new EmailMessage(FromAddress = 'test@gmail.com', Incoming = True, ToAddress= 'hello@dummy.com', Subject = 'Test email', TextBody = '23456 ', ParentId = thisGen1Case.Id,CcAddress='dummy.import@maersk.com');
        insert newEmail;
        List<Case> caseList = new List<Case>();
        caseList.add(thisGen1Case);
        Map<Id, Case> mapOfCases = new Map<Id, Case>(caseList);       
        thisGen1Case.Email_Recommendation_Acceptance__c = 'Recommendations Available';
        thisGen1Case.Count_Case_Emails__c = 1;
        TriggerExecutionController.skipCaseTrigger(true);
        
        Update thisGen1Case;
        TriggerExecutionController.skipCaseTrigger(false);
        IDAIntegrationForEmailRecommendation.getEmailAndCaseDetailsOnUpdate(mapOfCases);
        
        
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String sampleres = '{"recommendation1Score": 0.8230167031288147,"recommendation2Score": 0.8114129900932312,"recommendation3Score": 0.8516194820404053,"caseID": "5002o00003NtgVYAAZ"}';
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleres, headers));
        
        Case caseRec = [Select Id,CC_Flag__c,Priority from case where Id =:thisGen1Case.Id];
        
        Test.stopTest();
        
    }
}