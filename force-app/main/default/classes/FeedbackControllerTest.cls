/*  
* Version   Date            Referance               Owner                   Description
* --------  -----------     -------------------     -----------				------------
* 1.0       07-Jun-2023     SFSE-10705              Vazid@UST               This is the test class for FeedbackController
* 2.0       11-Aug-2023     SFSE-11844              Vazid@UST               Added test class coverage for opportunity functionality
*/
@isTest
private class FeedbackControllerTest {
    @testSetup static void setup() {
        //create Feedback record
        List<Feedback_Data__c> feedbackList = new List<Feedback_Data__c>();
        Feedback_Data__c feedbackData = new Feedback_Data__c();
        feedbackData.Functionality__c = Label.SIP_Functionality;
        feedbackData.isActive__c = true;
        feedbackData.Overlay_Restriction_Days__c = 30;
        feedbackData.Header_Text__c = 'Help Improve SIP Experience';
        feedbackData.Type__c = 'Functionality';
        feedbackData.What_Object__c = 'Opportunity';
        feedbackList.add(feedbackData);
        Feedback_Data__c feedbackDataOpty = new Feedback_Data__c();
        feedbackDataOpty.Functionality__c = Label.Opportunity_Functionality;
        feedbackDataOpty.isActive__c = true;
        feedbackDataOpty.Overlay_Restriction_Days__c = 30;
        feedbackDataOpty.Header_Text__c = 'Help Improve Opportunity Experience';
        feedbackDataOpty.Type__c = 'Functionality';
        feedbackDataOpty.What_Object__c = 'Opportunity';
        feedbackList.add(feedbackDataOpty);
        insert feedbackList;
        
        List<Feedback_Question__c> feedbackQuesList = new List<Feedback_Question__c>();
        Feedback_Question__c feedbackQuestion = new Feedback_Question__c();
        feedbackQuestion.Feedback__c = feedbackList[0].Id;
        feedbackQuestion.isMandatory__c = true;
        feedbackQuestion.Question_Order__c = 1;
        feedbackQuestion.Question_Text__c = 'How would you rate your overall experience with SIP?';
        feedbackQuestion.Question_Type__c = 'starReview';
        feedbackQuesList.add(feedbackQuestion);
        Feedback_Question__c feedbackQuestionOpty = new Feedback_Question__c();
        feedbackQuestionOpty.Feedback__c = feedbackList[1].Id;
        feedbackQuestionOpty.isMandatory__c = true;
        feedbackQuestionOpty.Question_Order__c = 1;
        feedbackQuestionOpty.Question_Text__c = 'How would you rate your overall experience with Opportunity?';
        feedbackQuestionOpty.Question_Type__c = 'starReview';
        feedbackQuesList.add(feedbackQuestionOpty);
        insert feedbackQuesList;
        
        List<Feedback_Invite__c> feedbackInviteList = new List<Feedback_Invite__c>();
        Feedback_Invite__c feedbackInvite = new Feedback_Invite__c();
        feedbackInvite.Feedback__c = feedbackList[0].Id;
        feedbackInvite.Invite_Date__c = system.today().addDays(-35);
        feedbackInvite.Participant__c = UserInfo.getUserId();
        feedbackInvite.Status__c = 'Cancelled';
        
        Feedback_Invite__c feedbackInviteOpty = new Feedback_Invite__c();
        feedbackInviteOpty.Feedback__c = feedbackList[1].Id;
        feedbackInviteOpty.Invite_Date__c = system.today().addDays(-35);
        feedbackInviteOpty.Participant__c = UserInfo.getUserId();
        feedbackInviteOpty.Status__c = 'Cancelled';
        
        feedbackInviteList.add(feedbackInvite);
        
        
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', false);
        clientAccount.Id = null;
        insert clientAccount;
        Opportunity opportunity = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'Supply_Chain_Services', BrandUtilities.MAERSKLINE, false);
        opportunity.Id = null;
        opportunity.Requires_IT_Integration__c = 'Yes, I am sure this is required basis my discussion with customer';
        TriggerExecutionController.skipOpportunityTrigger(true);
        insert opportunity;
        TriggerExecutionController.skipOpportunityTrigger(false);
        
        
        
        
        Feedback_What_Object__c fwoRecord = new Feedback_What_Object__c();
        fwoRecord.Opportunity__c = opportunity.Id;
        insert fwoRecord;
        
        feedbackInviteOpty.whatId__c = fwoRecord.Id;
        feedbackInviteList.add(feedbackInviteOpty);
        insert feedbackInviteList;
        
    }
    
    static testMethod void testcreateFBInviteRecordLevel(){
        Opportunity optyRec = [select Id from Opportunity LIMIT 1];
        FeedbackController.createFBInviteRecordLevel('Opportunity_Management', true, optyRec.Id);
        FeedbackController.getFeedbackData(null,optyRec.Id);
    }
    
    static testmethod void TestInviteData(){  
        List<SObject> Records =  [    SELECT Id
                                  , Header_text__c
                                  , Overlay_Restriction_Days__c
                                  , ( SELECT Id
                                     , Question_Text__c
                                     , Question_Type__c
                                     , Question_Order__c
                                     , isMandatory__c
                                     , Question_Response_Data_Type__c
                                     FROM Feedback_Questions__r
                                     ORDER BY Question_Order__c)
                                  , ( SELECT Id
                                     , Status__c
                                     , Invite_Date__c
                                     FROM Feedback_Invites__r
                                     WHERE Participant__c = :UserInfo.getUserId()
                                     AND Status__c != 'Closed')
                                  FROM Feedback_Data__c 
                                  WHERE isActive__c = true 
                                  AND Functionality__c = 'Sales_Incentive_Plan' ];
        FeedbackController.getFeedbackData('Sales_Incentive_Plan',null);
        FeedbackController.getFbInvite('Sales_Incentive_Plan');
    }
    
    static testmethod void TestCancelData(){ 
        Feedback_Invite__c fbRec = [ SELECT Id , Status__c , Invite_Date__c FROM Feedback_Invite__c LIMIT 1];
        fbRec.Status__c = 'Cancelled';
        FeedbackController.cancelInvite(fbRec);
    }
    
    static testmethod void TestcreateFBInvite(){ 
        FeedbackController.createFBInvite('Sales_Incentive_Plan', TRUE);
    }
    
    static testmethod void TestsaveFBdetails(){
        Feedback_Data__c fbRec = [ SELECT Id FROM Feedback_Data__c LIMIT 1];
        Feedback_Question__c fbQuestions = [SELECT Id, Question_Text__c , Question_Type__c , Question_Order__c
                                            , isMandatory__c  , Question_Response_Data_Type__c FROM Feedback_Question__c limit 1];
        Feedback_Invite__c fbInviteRec = [ SELECT Id , Status__c , Invite_Date__c FROM Feedback_Invite__c LIMIT 1];
        
        Feedback_Response__c fbResponseToInsert = new Feedback_Response__c(Feedback_Invite__c = fbInviteRec.Id,
                                                                           Completed_Date__c = system.today(),
                                                                           Feedback__c = fbRec.Id);
        Feedback_Question_Response__c fqResponse = new Feedback_Question_Response__c();
        fqResponse.Feedback_Question__c = fbQuestions.Id;
        fqResponse.Feedback_Response__c = fbResponseToInsert.Id;
        fqResponse.Response__c = '4';
        fqResponse.Response_Integer__c = 4;
        List<Feedback_Question_Response__c> lstQuestionsResponses = new List<Feedback_Question_Response__c>();
        lstQuestionsResponses.add(fqResponse);
        FeedbackController.saveFBdetails(fbRec.Id,fbInviteRec,lstQuestionsResponses);
        
    }
    static testmethod void TestInvocableFBInvite(){ 
        List<FeedbackController.feedbackInviteRequest> feedInvRequest = new List<FeedbackController.feedbackInviteRequest>();
        FeedbackController.feedbackInviteRequest feedsingleRec = new FeedbackController.feedbackInviteRequest();
        feedsingleRec.blnpublishEvent = true;
        feedsingleRec.strfunctionality = 'Sales_Incentive_Plan';
        feedInvRequest.add(feedsingleRec);
        FeedbackController.createFBInvitefromFlow(feedInvRequest);
    }
    
    static testmethod void TestcreateFBInvite2(){ 
        Feedback_Invite__c fbRec = [ SELECT Id , Status__c , Invite_Date__c FROM Feedback_Invite__c LIMIT 1];
        delete fbRec;
        FeedbackController.createFBInvite('Sales_Incentive_Plan', TRUE);
    }
    static testmethod void TestcreateFBInviteRecordLevel2(){ 
        Feedback_Invite__c fbRec = [ SELECT Id , Status__c , Invite_Date__c FROM Feedback_Invite__c where Feedback__r.Functionality__c = 'Opportunity_Management' LIMIT 1];
        delete fbRec;
        Opportunity optyRec = [select Id from Opportunity LIMIT 1];
        FeedbackController.createFBInviteRecordLevel('Opportunity_Management', true, optyRec.Id);
    }
}