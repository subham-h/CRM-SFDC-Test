@isTest
public class PopulateBotFieldsMIAWTest {
    @isTest(seeAllData=true)
    static void testgetChatInfo() {
        Test.startTest();
        
        TriggerExecutionController.skipAllTriggers(true);
        Geography__c chinaCountry=[SELECT Active__c,GEO_Code__c,GEO_ID__c,Id,Is_Port__c,Name,Parent_Geography__c,Port_City__c,SFDC_Record_Id__c,Trade_Type__c,Type_Of_Location__c FROM Geography__c WHERE GEO_Code__c = 'CN' AND Type_Of_Location__c = 'Country' limit 1][0];
        Geography__c chinaCity;
        /*if(chinaCountry <> null) {
            chinaCity = [SELECT Active__c,GEO_Code__c,GEO_ID__c,Id,Is_Port__c,Name,Parent_Geography__c,Port_City__c,SFDC_Record_Id__c,Trade_Type__c,Type_Of_Location__c FROM Geography__c WHERE Parent_Geography__r.Name = 'China' and  Type_Of_Location__c='City' limit 1][0];
        }*/
        
        Account accIterator = new Account();
        Id clientRTId = StaticFactory.getRecordTypeIdByName('Account', 'Client Account');
        accIterator.Name = 'Test Account_' + Math.round(Math.random()*1000);
        accIterator.Country__c = chinaCountry.Id;
        //accIterator.BillingCity = chinaCity.Name;
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
        caseIterator.Origin = 'MSLUSEXP';
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

        // Existing code from testgetChatInfo
        List<MessagingSession> newList = [SELECT Id, Bot_Intercept__c,  Proactive__c, Brand__c, CaseId FROM MessagingSession WHERE Id = :msgIterator.Id];
        newList[0].Brand__c = 'Maersk Line';
        update newList;
        TriggerExecutionController.skipAllTriggers(false);
        
        List<PopulateBotFieldsMessaging.botInput> lstbotinput = new List<PopulateBotFieldsMessaging.botInput>();
        PopulateBotFieldsMessaging.botInput input = new PopulateBotFieldsMessaging.botInput();
        input.msgSessionid = newList[0].Id;
        input.proactive = 'Proactive';
        lstbotinput.add(input);

        List<PopulateBotFieldsMessaging.chatInfo> lstchatInfo = PopulateBotFieldsMessaging.getChatInfo(lstbotinput);
        String expectedStatus = 'www.maersk.com';
        //System.assertEquals(expectedStatus, lstchatInfo[0].BrandLink);
        Test.stopTest();
    }

}