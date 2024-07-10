/**
 * Author   : Nisha
 * Purpose  : Test class for CaseSurveyCtrlr
 *
 * Revision Ref Number  Date         Owner                Description
 * -------- ----------  -----------  -------------------  -----------
 * 1.0      RQ-006949   27-Nov-2017  Nisha@UST            Created.
 * 2.0      RQ-007849   14-Feb-2018  Nisha@Ust            Updated to improve the code coverage.
 * 3.0      rq-009714   22-feb-2019  partha@maersk        updated for new functionality
 * 4.0      SC-276      13-Apr-2020  ramadevi@ust         Survey page hided for transfer failed
 * 5.0      SPI-100     08-Feb-2022  Ronnie@SF            Removed brand hardcoding
 */

@isTest
private class  CaseSurveyCtrlr_Test {
    
    @testSetup
    static void testDataSetup() {
        TriggerExecutionController.skipAllTriggers(true);
        ContactData_Test.createInternalContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email = 'test@maersk.com';
        update conInstance;
        
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.createExternalCases();
        CaseData_Test.conInstance = conInstance;
        list<Case> lstCases = CaseData_Test.lstCases;
        list<Case> lstUpdateCase = new list<Case>();
        General_Settings__c settings = General_Settings__c.getOrgDefaults();
        settings.Case_Email_Survey_Expiry__c = 7;
        upsert settings custSettings__c.Id;
        for(Case newCase : lstCases ) {
            newCase.Status ='Closed - Resolved';
            newCase.Resolution_Summary__c = 'Resolved'; 
            newCase.Send_Case_Closure__c ='No';
            newCase.Case_Closure_Opt_Out_Reason__c  = 'Technical limitations';
            newCase.type='Booking';
            newCase.Sub_Type__c='New Booking Request'; 
            newCase.Reason_For_Case__c = 'Booking Request';
            newCase.Liner_Brand__c  = BrandUtilities.MAERSKLINE;
            newCase.Country__c = BDAGeographyData_Test.countryRU.Id;
            newCase.Security_Code__c = '1235'; 
            newCase.ContactId = conInstance.Id;
            lstUpdateCase.add(newCase);
        }
        update lstUpdateCase;     
        TriggerExecutionController.skipAllTriggers(false);
    }
    
    @isTest
    public static void testCaseSurvey() {
        
        Case testCase = [SELECT Id, CaseNumber, ContactEmail,ContactId,closeddate, Security_Code__c, ContactMobile FROM Case][0];
        system.debug('test case*'+testcase);
        Test.startTest();
        
        PageReference pageRef = Page.CaseSurvey;
        pageRef.getParameters().put('lang', 'en_US');
        pageRef.getParameters().put('LB', BrandUtilities.MAERSKLINE);        
        pageRef.getParameters().put('Id', testCase.Id);
        pageRef.getParameters().put('Fb','3');
        pageRef.getParameters().put('Sc', testCase.Security_Code__c);
        
        Test.setCurrentPage(pageRef); 
        CaseSurveyCtrlr caseSurveyCtrlInst = new  CaseSurveyCtrlr();
        caseSurveyCtrlInst.pageName='CaseChatSurvey';
        //caseSurveyCtrlInst.feedback='3';
        caseSurveyCtrlInst.createSurvey();
        caseSurveyCtrlInst.updateSurvey(); // #RQ-007849
        caseSurveyCtrlInst.exception2();
        caseSurveyCtrlInst.exception1();
        
        list<Survey__c> lstSvyCreated = [Select Id, Ease_to_Resolve_Issue_Description__c, Response_Actions__c, Ease_to_Resolve_Issue__c From Survey__c Where Case__c =: testCase.Id];        
        //  caseSurveyCtrlInst.surveylistRecords(lstSvyCreated,testCase);
        // System.assertEquals(lstSvyCreated.size(), 1);
        // System.assertEquals(lstSvyCreated[0].Ease_to_Resolve_Issue__c, 3);
        //Test.stopTest();   
        //Test.startTest();
        PageReference pageRef2 = Page.CaseSurvey;
        pageRef2.getParameters().put('lang', 'en_US');
        pageRef2.getParameters().put('LB', BrandUtilities.MAERSKLINE);        
        pageRef2.getParameters().put('Id', testCase.Id);
        pageRef2.getParameters().put('Fb','1');
        pageRef2.getParameters().put('Sc', testCase.Security_Code__c);
        pageRef2.getParameters().put('Sc', testCase.Security_Code__c);
        Test.setCurrentPage(pageRef2);
        CaseSurveyCtrlr caseSurveyCtrlInst2 = new  CaseSurveyCtrlr();
        caseSurveyCtrlInst2.pageName='CaseSurvey';
        caseSurveyCtrlInst2.createSurvey(); 
        try{
            //v2.0 : #RQ-007849 (Updated to improve the code coverage)      
            //   lstSvyCreated[0].Ease_to_Resolve_Issue_Description__c = 'Resolved';
            update lstSvyCreated;
        }catch(exception es){}
        caseSurveyCtrlInst2.updateSurvey(); //v2.0
        
        list<Survey__c> lstSvyUpdated = [Select Id, Ease_to_Resolve_Issue_Description__c, Ease_to_Resolve_Issue__c From Survey__c Where Case__c =: testCase.Id];
        // System.assertEquals(lstSvyUpdated.size(), 1);
        // System.assertEquals(lstSvyUpdated[0].Ease_to_Resolve_Issue__c, 1);
        
        Test.stopTest();                
    }
    
    @isTest
    public static void testDupedSurvey() {
        
        Case testCase = [SELECT Id, CaseNumber, ContactEmail,ContactId, Security_Code__c, ContactMobile FROM Case][0];
        PageReference pageRef = Page.CaseSurvey;
        pageRef.getParameters().put('lang', 'en_US');
        pageRef.getParameters().put('LB', BrandUtilities.MAERSKLINE); 
        // Commented the below code to cover the exception part.
        //  pageRef.getParameters().put('Id', testCase.Id);
        pageRef.getParameters().put('Fb','1');
        pageRef.getParameters().put('Sc', testCase.Security_Code__c);
        Test.setCurrentPage(pageRef); 
        
        System.test.startTest();
        CaseSurveyCtrlr caseSurveyCtrlInst = new  CaseSurveyCtrlr();
        caseSurveyCtrlInst.createSurvey();
        CaseSurveyCtrlr caseSurveyCtrlInst1 = new  CaseSurveyCtrlr();    
        caseSurveyCtrlInst1.createSurvey();
        caseSurveyCtrlInst1.updateSurvey();
        System.test.stopTest();
        
        list<Survey__c> lstSurvey = [SELECT Id FROM Survey__c];
        //System.assertEquals(0, lstSurvey.size());        
    }    
    
    @isTest
    public static void testCaseChatSurvey() {
        Case testCase = [SELECT Id, CaseNumber, ContactEmail,ContactId, Security_Code__c, ContactMobile,Bot_Last_Action__c FROM Case][0];
        //SC-276
        testCase.Bot_Last_Action__c = 'Transfer Failed';
        triggerExecutionController.skipCaseTrigger(true);
        update testCase;
        TriggerExecutionController.skipCaseTrigger(false);
        //SC-276 End
        system.debug('testCase'+testCase);
        PageReference pageRef = Page.CaseChatSurvey;
        string attachedRecords = '{"CaseId":"'+ testcase.id+'"}';
        pageRef.getParameters().put('attachedRecords',attachedRecords);
        /*pageRef.getParameters().put('lang', 'en_US');
        pageRef.getParameters().put('LB', BrandUtilities.MAERSKLINE); 
        // Commented the below code to cover the exception part.
        pageRef.getParameters().put('Id', testCase.Id);
        pageRef.getParameters().put('Fb','1');
        pageRef.getParameters().put('Sc', testCase.Security_Code__c);*/
        Test.setCurrentPage(pageRef); 
        
        System.test.startTest();
        CaseSurveyCtrlr caseSurveyCtrlInst = new  CaseSurveyCtrlr();
        caseSurveyCtrlInst.createSurvey();
        CaseSurveyCtrlr caseSurveyCtrlInst1 = new  CaseSurveyCtrlr();
        caseSurveyCtrlInst1.detailedFeedback='test';
        
        caseSurveyCtrlInst1.createSurvey();
        caseSurveyCtrlInst1.updateSurvey();
        caseSurveyCtrlInst1.selectSmiley();
        System.test.stopTest();
        
        //list<Survey__c> lstSurvey = [SELECT Id FROM Survey__c];
    }
    
    @isTest
    public static void testBrandCSS() {
        
        Case testCase = [SELECT Id, CaseNumber, ContactEmail,ContactId, Security_Code__c, ContactMobile FROM Case][0];
        PageReference pageRef = Page.CaseSurvey;
        pageRef.getParameters().put('lang', 'en_US');
        pageRef.getParameters().put('LB', BrandUtilities.MAERSKLINE);    
        pageRef.getParameters().put('Fb','1');
        pageRef.getParameters().put('Sc', testCase.Security_Code__c);
        Test.setCurrentPage(pageRef); 
        
        
        System.test.startTest();
        CaseSurveyCtrlr caseSurveyCtrlInst = new  CaseSurveyCtrlr();
        caseSurveyCtrlInst.twill = false;
        caseSurveyCtrlInst.getBrandCSSLocation();
        caseSurveyCtrlInst.getBrandLogoCSS();
        caseSurveyCtrlInst.getBrandCSSFileName();
        caseSurveyCtrlInst.getBrandLogoLocation();
        caseSurveyCtrlInst.getBrandLogoFileName();
        
        System.test.stopTest();    
    }   
     @isTest
    static void testLctProactiveSurvey() {
       
            Case testCase = [SELECT Id, CaseNumber, ContactEmail,ContactId, Security_Code__c, ContactMobile,Bot_Last_Action__c FROM Case][0];

            LiveChatVisitor lcv = new LiveChatVisitor();
            insert lcv;
    
            LiveChatTranscript chatTranscriptIterator = new LiveChatTranscript();
            chatTranscriptIterator.Status  = 'Completed';
            chatTranscriptIterator.Customer_Code__c  = '123456';
            chatTranscriptIterator.Customer_Email__c  = 'Testone@gmail.com';
            chatTranscriptIterator.CaseId = testCase.Id;
            chatTranscriptIterator.LiveChatVisitorId = lcv.Id;
            chatTranscriptIterator.Proactive__c= 'Proactive';
            chatTranscriptIterator.Proactive_Feedback__c ='Satisfied';
            
            insert chatTranscriptIterator;
            PageReference pageRef = Page.CaseChatSurvey;
            string attachedRecords = '{"CaseId":"'+ testcase.id+'"}';
            pageRef.getParameters().put('attachedRecords',attachedRecords);
            Test.setCurrentPage(pageRef); 

            Test.startTest();
            CaseSurveyCtrlr caseSurveyCtrlInst = new  CaseSurveyCtrlr();
            caseSurveyCtrlInst.pageName = 'CaseChatSurvey';
            caseSurveyCtrlInst.caseid = testCase.Id;
            caseSurveyCtrlInst.createSurvey();
            Boolean successMessage = caseSurveyCtrlInst.successMessage;
            
            Test.stopTest();
            System.assertEquals(false, successMessage);

        
    }
       
                                
}