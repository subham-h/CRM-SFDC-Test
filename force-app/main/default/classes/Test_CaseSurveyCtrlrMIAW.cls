@isTest
private class Test_CaseSurveyCtrlrMIAW{
@isTest(seeAllData=True)
public static void testCaseSurvey() {   
    Geography__c chinaCountry=[SELECT Active__c,GEO_Code__c,GEO_ID__c,Id,Is_Port__c,Name,Parent_Geography__c,Port_City__c,SFDC_Record_Id__c,Trade_Type__c,Type_Of_Location__c FROM Geography__c WHERE GEO_Code__c = 'CN' AND Type_Of_Location__c = 'Country' limit 1][0];

        Geography__c chinaCity = [SELECT Active__c,GEO_Code__c,GEO_ID__c,Id,Is_Port__c,Name,Parent_Geography__c,Port_City__c,SFDC_Record_Id__c,Trade_Type__c,Type_Of_Location__c FROM Geography__c WHERE Parent_Geography__c = 'a0JD0000006SxKsMAK' and  Type_Of_Location__c='City' limit 1][0];

        Account accIterator = new Account();
        Id clientRTId = StaticFactory.getRecordTypeIdByName('Account', 'Client Account');
        accIterator.Name = 'Test Account_' + Math.round(Math.random()*1000);
        accIterator.Country__c = chinaCountry.Id;
        accIterator.BillingCity = chinaCity.Name;
        accIterator.Name =  'Client ' +  Math.random() + DateTime.now().millisecond();
        accIterator.RecordTypeId  = clientRTId;
        insert accIterator;

        Id customerRTId = StaticFactory.getRecordTypeIdByName('Contact', 'Customer Contact');
        Contact conIterator = new Contact();
        conIterator.AccountId = accIterator.Id;

        Double randomVal = Math.random() * 100;
        Integer roundval = Math.round(randomVal);

        conIterator.Email = DateTime.now().millisecond() + 'TestContact' + Math.random() + '@test.com';
        conIterator.Phone = '+44 123412' + roundval;
        conIterator.FirstName = 'Test' + Math.random() + DateTime.now().millisecond();
        conIterator.Liner_Brands__c = BrandUtilities.MAERSKLINE;
        conIterator.Country__c = accIterator.Country__c;
        conIterator.Contact_Status__c = 'Active';
        conIterator.LastName = 'Customer Contact' + Math.random() + DateTime.now().millisecond(); 
        conIterator.RecordTypeId = customerRTId;
        conIterator.OtherPhone='+86 91234567891';
        conIterator.MobilePhone='+86 91234567891';
        conIterator.Phone ='+86 91234567891';
        conIterator.Fax='+86 9123456789';
        insert conIterator;
        
        //createEntitlements();

        Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
        Case caseIterator = new Case();
        caseIterator.Subject = 'CaseTestData Subject_MIAW';
        caseIterator.Description = 'CaseTestData Description_MIAW';
        caseIterator.Thread_topic__c = 'Test'; // RQ-004464            
        caseIterator.Status = 'Triaged';
        caseIterator.Type = 'Prior To Booking';
        caseIterator.Sub_Type__c = 'Cargo Restrictions/Support Enquiry';
        caseIterator.Country__c = chinaCountry.Id;
        caseIterator.Cargo_Classification__c ='US Military (USM)';
        caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        caseIterator.Direction__c = 'Export';
        caseIterator.Case_Channel__c = 'Chat';
        caseIterator.contactId = conIterator.Id;
        caseIterator.SuppliedEmail = Null;
        caseIterator.Origin = 'MSLMYMaerskLine';
        caseIterator.Case_Visibility__c = 'All Users';
        caseIterator.RecordTypeId = extCaseRTId;
        caseIterator.OwnerId = UserInfo.getUserId();
        Insert caseIterator;
        system.debug('caseIterator----'+caseIterator);
                
         
        MessagingChannel msgChannel = [select id, IsActive from MessagingChannel  where IsActive = true and MessageType='EmbeddedMessaging'  limit 1];

        MessagingEndUser objMsgUser = new MessagingEndUser();
        objMsgUser.ContactId = conIterator.Id;
        objMsgUser.MessagingChannelId = msgChannel.Id;
        objMsgUser.MessagingConsentStatus = 'ImplicitlyOptedIn';
        objMsgUser.MessageType = 'EmbeddedMessaging';//For MIAW Channel
        objMsgUser.MessagingPlatformKey = 'test';
        objMsgUser.Name='test';
        insert objMsgUser;        
        Conversation conv = [SELECT Id from Conversation limit 1][0];
    
            MessagingSession msgIterator = new MessagingSession();
            msgIterator.Status  = 'Ended';
            msgIterator.Customer_Code__c  = '123456';
            msgIterator.Customer_Email__c  = 'Testone@gmail.com';
            msgIterator.CaseId = caseIterator.Id;
            msgIterator.Proactive__c= 'Proactive';
            msgIterator.Proactive_Feedback__c ='Satisfied';
            msgIterator.MessagingEndUserId = objMsgUser.Id;
            msgIterator.MessagingChannelId = msgChannel.Id;
            msgIterator.ConversationId =conv.Id;
            insert msgIterator;
            
        
        Case testCase = [SELECT Id, CaseNumber, ContactEmail,ContactId,closeddate, Security_Code__c, ContactMobile FROM Case where id=:caseIterator.Id][0];
        system.debug('test case*'+testcase);
    Test.startTest();
    
    PageReference pageRef = Page.CaseSurvey;
    pageRef.getParameters().put('lang', 'en_US');
    pageRef.getParameters().put('LB', BrandUtilities.MAERSKLINE);        
    pageRef.getParameters().put('Id', testCase.Id);
    pageRef.getParameters().put('Fb','3');
    pageRef.getParameters().put('Sc', testCase.Security_Code__c);
    
    Test.setCurrentPage(pageRef); 
    CaseSurveyCtrlrMIAW caseSurveyCtrlInst = new  CaseSurveyCtrlrMIAW();
    caseSurveyCtrlInst.pageName='CaseChatSurveyMIAW';
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
    CaseSurveyCtrlrMIAW caseSurveyCtrlInst2 = new  CaseSurveyCtrlrMIAW();
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


/*@isTest(seeAllData=True)
public static void testCaseChatSurvey() {
    Geography__c chinaCountry=[SELECT Active__c,GEO_Code__c,GEO_ID__c,Id,Is_Port__c,Name,Parent_Geography__c,Port_City__c,SFDC_Record_Id__c,Trade_Type__c,Type_Of_Location__c FROM Geography__c WHERE GEO_Code__c = 'CN' AND Type_Of_Location__c = 'Country' limit 1][0];

        Geography__c chinaCity = [SELECT Active__c,GEO_Code__c,GEO_ID__c,Id,Is_Port__c,Name,Parent_Geography__c,Port_City__c,SFDC_Record_Id__c,Trade_Type__c,Type_Of_Location__c FROM Geography__c WHERE Parent_Geography__c = 'a0JD0000006SxKsMAK' and  Type_Of_Location__c='City' limit 1][0];

        Account accIterator = new Account();
        Id clientRTId = StaticFactory.getRecordTypeIdByName('Account', 'Client Account');
        accIterator.Name = 'Test Account_' + Math.round(Math.random()*1000);
        accIterator.Country__c = chinaCountry.Id;
        accIterator.BillingCity = chinaCity.Name;
        accIterator.Name =  'Client ' +  Math.random() + DateTime.now().millisecond();
        accIterator.RecordTypeId  = clientRTId;
        insert accIterator;

        Id customerRTId = StaticFactory.getRecordTypeIdByName('Contact', 'Customer Contact');
        Contact conIterator = new Contact();
        conIterator.AccountId = accIterator.Id;

        Double randomVal = Math.random() * 100;
        Integer roundval = Math.round(randomVal);

        conIterator.Email = DateTime.now().millisecond() + 'TestContact' + Math.random() + '@test.com';
        conIterator.Phone = '+44 123412' + roundval;
        conIterator.FirstName = 'Test' + Math.random() + DateTime.now().millisecond();
        conIterator.Liner_Brands__c = BrandUtilities.MAERSKLINE;
        conIterator.Country__c = accIterator.Country__c;
        conIterator.Contact_Status__c = 'Active';
        conIterator.LastName = 'Customer Contact' + Math.random() + DateTime.now().millisecond(); 
        conIterator.RecordTypeId = customerRTId;
        conIterator.OtherPhone='+86 91234567891';
        conIterator.MobilePhone='+86 91234567891';
        conIterator.Phone ='+86 91234567891';
        conIterator.Fax='+86 9123456789';
        insert conIterator;
        
        //createEntitlements();

        Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
        Case caseIterator = new Case();
        caseIterator.Subject = 'CaseTestData Subject_MIAW';
        caseIterator.Description = 'CaseTestData Description_MIAW';
        caseIterator.Thread_topic__c = 'Test'; // RQ-004464            
        caseIterator.Status = 'Triaged';
        caseIterator.Type = 'Prior To Booking';
        caseIterator.Sub_Type__c = 'Cargo Restrictions/Support Enquiry';
        caseIterator.Country__c = chinaCountry.Id;
        caseIterator.Cargo_Classification__c ='US Military (USM)';
        caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        caseIterator.Direction__c = 'Export';
        caseIterator.Case_Channel__c = 'Chat';
        caseIterator.contactId = conIterator.Id;
        caseIterator.SuppliedEmail = Null;
        caseIterator.Origin = 'MSLMYMaerskLine';
        caseIterator.Case_Visibility__c = 'All Users';
        caseIterator.RecordTypeId = extCaseRTId;
        caseIterator.OwnerId = UserInfo.getUserId();
        Insert caseIterator;
        system.debug('caseIterator----'+caseIterator);
                
         
        MessagingChannel msgChannel = [select id, IsActive from MessagingChannel  where IsActive = true and MessageType='EmbeddedMessaging'  limit 1];

        MessagingEndUser objMsgUser = new MessagingEndUser();
        objMsgUser.ContactId = conIterator.Id;
        objMsgUser.MessagingChannelId = msgChannel.Id;
        objMsgUser.MessagingConsentStatus = 'ImplicitlyOptedIn';
        objMsgUser.MessageType = 'EmbeddedMessaging';//For MIAW Channel
        objMsgUser.MessagingPlatformKey = 'test';
        objMsgUser.Name='test';
        insert objMsgUser;        
        Conversation conv = [SELECT Id from Conversation limit 1][0];
    
            MessagingSession msgIterator = new MessagingSession();
            msgIterator.Status  = 'Ended';
            msgIterator.Customer_Code__c  = '123456';
            msgIterator.Customer_Email__c  = 'Testone@gmail.com';
            msgIterator.CaseId = caseIterator.Id;
            msgIterator.Proactive__c= 'Proactive';
            msgIterator.Proactive_Feedback__c ='Satisfied';
            msgIterator.MessagingEndUserId = objMsgUser.Id;
            msgIterator.MessagingChannelId = msgChannel.Id;
            msgIterator.ConversationId =conv.Id;
            insert msgIterator;
            
        
        Case testCase = [SELECT Id, CaseNumber, ContactEmail,ContactId,closeddate, Security_Code__c, ContactMobile FROM Case where id=:caseIterator.Id][0];
        system.debug('test case*'+testcase);
    //SC-276
    testCase.Bot_Last_Action__c = 'Transfer Failed';
    triggerExecutionController.skipCaseTrigger(true);
    update testCase;
    TriggerExecutionController.skipCaseTrigger(false);
    //SC-276 End
    system.debug('testCase'+testCase);
    PageReference pageRef = Page.CaseChatSurveyMIAW;
    string attachedRecords = '{"CaseId":"'+ testcase.id+'"}';
    pageRef.getParameters().put('attachedRecords',attachedRecords);
    //pageRef.getParameters().put('lang', 'en_US');
    //pageRef.getParameters().put('LB', BrandUtilities.MAERSKLINE); 
    // Commented the below code to cover the exception part.
    //pageRef.getParameters().put('Id', testCase.Id);
    //pageRef.getParameters().put('Fb','1');
    //pageRef.getParameters().put('Sc', testCase.Security_Code__c);
    Test.setCurrentPage(pageRef); 
    
    System.test.startTest();
    CaseSurveyCtrlrMIAW caseSurveyCtrlInst = new  CaseSurveyCtrlrMIAW();
    caseSurveyCtrlInst.createSurvey();
    caseSurveyCtrlInst.setSendCaseClosureForTransferFailed();
    CaseSurveyCtrlrMIAW caseSurveyCtrlInst1 = new  CaseSurveyCtrlrMIAW();
    caseSurveyCtrlInst1.detailedFeedback='test';
    
    caseSurveyCtrlInst1.createSurvey();
    caseSurveyCtrlInst1.updateSurvey();
    caseSurveyCtrlInst1.selectSmiley();
    System.test.stopTest();
    
    //list<Survey__c> lstSurvey = [SELECT Id FROM Survey__c];
}*/

/*@isTest(seeAllData=True)
static void testLctProactiveSurvey() {
   
        Geography__c chinaCountry=[SELECT Active__c,GEO_Code__c,GEO_ID__c,Id,Is_Port__c,Name,Parent_Geography__c,Port_City__c,SFDC_Record_Id__c,Trade_Type__c,Type_Of_Location__c FROM Geography__c WHERE GEO_Code__c = 'CN' AND Type_Of_Location__c = 'Country' limit 1][0];

        Geography__c chinaCity = [SELECT Active__c,GEO_Code__c,GEO_ID__c,Id,Is_Port__c,Name,Parent_Geography__c,Port_City__c,SFDC_Record_Id__c,Trade_Type__c,Type_Of_Location__c FROM Geography__c WHERE Parent_Geography__c = 'a0JD0000006SxKsMAK' and  Type_Of_Location__c='City' limit 1][0];

        Account accIterator = new Account();
        Id clientRTId = StaticFactory.getRecordTypeIdByName('Account', 'Client Account');
        accIterator.Name = 'Test Account_' + Math.round(Math.random()*1000);
        accIterator.Country__c = chinaCountry.Id;
        accIterator.BillingCity = chinaCity.Name;
        accIterator.Name =  'Client ' +  Math.random() + DateTime.now().millisecond();
        accIterator.RecordTypeId  = clientRTId;
        insert accIterator;

        Id customerRTId = StaticFactory.getRecordTypeIdByName('Contact', 'Customer Contact');
        Contact conIterator = new Contact();
        conIterator.AccountId = accIterator.Id;

        Double randomVal = Math.random() * 100;
        Integer roundval = Math.round(randomVal);

        conIterator.Email = DateTime.now().millisecond() + 'TestContact' + Math.random() + '@test.com';
        conIterator.Phone = '+44 123412' + roundval;
        conIterator.FirstName = 'Test' + Math.random() + DateTime.now().millisecond();
        conIterator.Liner_Brands__c = BrandUtilities.MAERSKLINE;
        conIterator.Country__c = accIterator.Country__c;
        conIterator.Contact_Status__c = 'Active';
        conIterator.LastName = 'Customer Contact' + Math.random() + DateTime.now().millisecond(); 
        conIterator.RecordTypeId = customerRTId;
        conIterator.OtherPhone='+86 91234567891';
        conIterator.MobilePhone='+86 91234567891';
        conIterator.Phone ='+86 91234567891';
        conIterator.Fax='+86 9123456789';
        insert conIterator;
        
        //createEntitlements();

        Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
        Case caseIterator = new Case();
        caseIterator.Subject = 'CaseTestData Subject_MIAW';
        caseIterator.Description = 'CaseTestData Description_MIAW';
        caseIterator.Thread_topic__c = 'Test'; // RQ-004464            
        caseIterator.Status = 'Triaged';
        caseIterator.Type = 'Prior To Booking';
        caseIterator.Sub_Type__c = 'Cargo Restrictions/Support Enquiry';
        caseIterator.Country__c = chinaCountry.Id;
        caseIterator.Cargo_Classification__c ='US Military (USM)';
        caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        caseIterator.Direction__c = 'Export';
        caseIterator.Case_Channel__c = 'Chat';
        caseIterator.contactId = conIterator.Id;
        caseIterator.SuppliedEmail = Null;
        caseIterator.Origin = 'MSLMYMaerskLine';
        caseIterator.Case_Visibility__c = 'All Users';
        caseIterator.RecordTypeId = extCaseRTId;
        caseIterator.OwnerId = UserInfo.getUserId();
        Insert caseIterator;
        system.debug('caseIterator----'+caseIterator);
                
         
        MessagingChannel msgChannel = [select id, IsActive from MessagingChannel  where IsActive = true and MessageType='EmbeddedMessaging'  limit 1];

        MessagingEndUser objMsgUser = new MessagingEndUser();
        objMsgUser.ContactId = conIterator.Id;
        objMsgUser.MessagingChannelId = msgChannel.Id;
        objMsgUser.MessagingConsentStatus = 'ImplicitlyOptedIn';
        objMsgUser.MessageType = 'EmbeddedMessaging';//For MIAW Channel
        objMsgUser.MessagingPlatformKey = 'test';
        objMsgUser.Name='test';
        insert objMsgUser;        
        Conversation conv = [SELECT Id from Conversation limit 1][0];
    
            MessagingSession msgIterator = new MessagingSession();
            msgIterator.Status  = 'Ended';
            msgIterator.Customer_Code__c  = '123456';
            msgIterator.Customer_Email__c  = 'Testone@gmail.com';
            msgIterator.CaseId = caseIterator.Id;
            msgIterator.Proactive__c= 'Proactive';
            msgIterator.Proactive_Feedback__c ='Satisfied';
            msgIterator.MessagingEndUserId = objMsgUser.Id;
            msgIterator.MessagingChannelId = msgChannel.Id;
            msgIterator.ConversationId =conv.Id;
            insert msgIterator;
            
        
        Case testCase = [SELECT Id, CaseNumber, ContactEmail,ContactId,closeddate, Security_Code__c, ContactMobile FROM Case where id=:caseIterator.Id][0];
        system.debug('test case*'+testcase);
        
        PageReference pageRef = Page.CaseChatSurveyMIAW;
        string attachedRecords = '{"CaseId":"'+ testcase.id+'"}';
        pageRef.getParameters().put('attachedRecords',attachedRecords);
        Test.setCurrentPage(pageRef); 

        Test.startTest();
        CaseSurveyCtrlrMIAW caseSurveyCtrlInst = new  CaseSurveyCtrlrMIAW();
        caseSurveyCtrlInst.pageName = 'CaseChatSurveyMIAW';
        caseSurveyCtrlInst.caseid = testCase.Id;
        caseSurveyCtrlInst.createSurvey();
        Boolean successMessage = caseSurveyCtrlInst.successMessage;
        
        Test.stopTest();
        System.assertEquals(false, successMessage);
}
*/
/*@isTest(seeAllData=True)
static void testCaseChatSurveyWithFeedback() {
    Geography__c chinaCountry=[SELECT Active__c,GEO_Code__c,GEO_ID__c,Id,Is_Port__c,Name,Parent_Geography__c,Port_City__c,SFDC_Record_Id__c,Trade_Type__c,Type_Of_Location__c FROM Geography__c WHERE GEO_Code__c = 'CN' AND Type_Of_Location__c = 'Country' limit 1][0];

        Geography__c chinaCity = [SELECT Active__c,GEO_Code__c,GEO_ID__c,Id,Is_Port__c,Name,Parent_Geography__c,Port_City__c,SFDC_Record_Id__c,Trade_Type__c,Type_Of_Location__c FROM Geography__c WHERE Parent_Geography__c = 'a0JD0000006SxKsMAK' and  Type_Of_Location__c='City' limit 1][0];

        Account accIterator = new Account();
        Id clientRTId = StaticFactory.getRecordTypeIdByName('Account', 'Client Account');
        accIterator.Name = 'Test Account_' + Math.round(Math.random()*1000);
        accIterator.Country__c = chinaCountry.Id;
        accIterator.BillingCity = chinaCity.Name;
        accIterator.Name =  'Client ' +  Math.random() + DateTime.now().millisecond();
        accIterator.RecordTypeId  = clientRTId;
        insert accIterator;

        Id customerRTId = StaticFactory.getRecordTypeIdByName('Contact', 'Customer Contact');
        Contact conIterator = new Contact();
        conIterator.AccountId = accIterator.Id;

        Double randomVal = Math.random() * 100;
        Integer roundval = Math.round(randomVal);

        conIterator.Email = DateTime.now().millisecond() + 'TestContact' + Math.random() + '@test.com';
        conIterator.Phone = '+44 123412' + roundval;
        conIterator.FirstName = 'Test' + Math.random() + DateTime.now().millisecond();
        conIterator.Liner_Brands__c = BrandUtilities.MAERSKLINE;
        conIterator.Country__c = accIterator.Country__c;
        conIterator.Contact_Status__c = 'Active';
        conIterator.LastName = 'Customer Contact' + Math.random() + DateTime.now().millisecond(); 
        conIterator.RecordTypeId = customerRTId;
        conIterator.OtherPhone='+86 91234567891';
        conIterator.MobilePhone='+86 91234567891';
        conIterator.Phone ='+86 91234567891';
        conIterator.Fax='+86 9123456789';
        insert conIterator;
        
        //createEntitlements();

        Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
        Case caseIterator = new Case();
        caseIterator.Subject = 'CaseTestData Subject_MIAW';
        caseIterator.Description = 'CaseTestData Description_MIAW';
        caseIterator.Thread_topic__c = 'Test'; // RQ-004464            
        caseIterator.Status = 'Triaged';
        caseIterator.Type = 'Prior To Booking';
        caseIterator.Sub_Type__c = 'Cargo Restrictions/Support Enquiry';
        caseIterator.Country__c = chinaCountry.Id;
        caseIterator.Cargo_Classification__c ='US Military (USM)';
        caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        caseIterator.Direction__c = 'Export';
        caseIterator.Case_Channel__c = 'Chat';
        caseIterator.contactId = conIterator.Id;
        caseIterator.SuppliedEmail = Null;
        caseIterator.Origin = 'MSLMYMaerskLine';
        caseIterator.Case_Visibility__c = 'All Users';
        caseIterator.RecordTypeId = extCaseRTId;
        caseIterator.OwnerId = UserInfo.getUserId();
        Insert caseIterator;
        system.debug('caseIterator----'+caseIterator);
                
         
        MessagingChannel msgChannel = [select id, IsActive from MessagingChannel  where IsActive = true and MessageType='EmbeddedMessaging'  limit 1];

        MessagingEndUser objMsgUser = new MessagingEndUser();
        objMsgUser.ContactId = conIterator.Id;
        objMsgUser.MessagingChannelId = msgChannel.Id;
        objMsgUser.MessagingConsentStatus = 'ImplicitlyOptedIn';
        objMsgUser.MessageType = 'EmbeddedMessaging';//For MIAW Channel
        objMsgUser.MessagingPlatformKey = 'test';
        objMsgUser.Name='test';
        insert objMsgUser;        
        Conversation conv = [SELECT Id from Conversation limit 1][0];
    
            MessagingSession msgIterator = new MessagingSession();
            msgIterator.Status  = 'Ended';
            msgIterator.Customer_Code__c  = '123456';
            msgIterator.Customer_Email__c  = 'Testone@gmail.com';
            msgIterator.CaseId = caseIterator.Id;
            msgIterator.Proactive__c= 'Proactive';
            msgIterator.Proactive_Feedback__c ='Satisfied';
            msgIterator.MessagingEndUserId = objMsgUser.Id;
            msgIterator.MessagingChannelId = msgChannel.Id;
            msgIterator.ConversationId =conv.Id;
            insert msgIterator;
            
        
        Case testCase = [SELECT Id, CaseNumber, ContactEmail,ContactId,closeddate, Security_Code__c, ContactMobile FROM Case where id=:caseIterator.Id][0];
        system.debug('test case*'+testcase);
    PageReference pageRef = Page.CaseChatSurveyMIAW;
    pageRef.getParameters().put('attachedRecords', '{"CaseId":"' + testCase.Id + '"}');
    Test.setCurrentPage(pageRef);
                
    Test.startTest();
    CaseSurveyCtrlrMIAW caseSurveyCtrlInst = new CaseSurveyCtrlrMIAW();
    caseSurveyCtrlInst.pageName = 'CaseChatSurveyMIAW';
    caseSurveyCtrlInst.feedback = '4';
                
    caseSurveyCtrlInst.createSurvey();
    caseSurveyCtrlInst.updateSurvey();
    Test.stopTest();
                
     List<Survey__c> lstSurvey = [SELECT Id, Ease_to_Resolve_Issue__c, Ease_to_Resolve_Issue_Description__c FROM Survey__c WHERE Case__c = :testCase.Id LIMIT 1];     
      if (caseSurveyCtrlInst.pageName == 'CaseChatSurvey') {
                 Survey__c svy = lstSurvey[0];
                 svy.survey_Channel__c = 'Chat';
                 String Checkvalue = '';
                 Datetime myDT = Datetime.now();
                 
                   String strConvertedDate = myDT.format('dd/MM/yyyy HH:mm', 'GMT') + ' UTC';
                   svy.Ease_to_Resolve_Issue_Description__c = strConvertedDate + '\n' + caseSurveyCtrlInst.feedback + '\n' + Checkvalue + caseSurveyCtrlInst.detailedFeedback;
              }
}*/

    /*@isTest
    public static void testDupedSurvey() {
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
        CaseSurveyCtrlrMIAW caseSurveyCtrlInst = new  CaseSurveyCtrlrMIAW();
        caseSurveyCtrlInst.createSurvey();
        CaseSurveyCtrlrMIAW caseSurveyCtrlInst1 = new  CaseSurveyCtrlrMIAW();    
        caseSurveyCtrlInst1.createSurvey();
        caseSurveyCtrlInst1.updateSurvey();
        System.test.stopTest();
        
        list<Survey__c> lstSurvey = [SELECT Id FROM Survey__c];
        //System.assertEquals(0, lstSurvey.size());        
    } */   
    
}