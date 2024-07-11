@isTest(SeeAllData=true)
public class MessagingForWebTest{
    public static list<MessagingSession> listMessagingSession = new List<MessagingSession>();
    public static boolean bCreate = true;
    public static integer iNumberOfChats = 1;
    public static User userInstance = null;
    public static contact conInstance = null;
    public static List<LiveChatVisitor> listChatVisitor = null;
    
    @isTest(SeeAllData=true)
    public static void populateChatTranscript() {
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
                
        if(conInstance == null) {
            conInstance = conIterator;
        } 
        //conInstance = [SELECT id from contact where email like '%test%' limit 1][0];
        MessagingChannel msgChannel = [select id, IsActive from MessagingChannel  where IsActive = true and MessageType='EmbeddedMessaging' limit 1];

        MessagingEndUser objMsgUser = new MessagingEndUser();
        objMsgUser.ContactId = conInstance.Id;
        objMsgUser.MessagingChannelId = msgChannel.Id;
        objMsgUser.MessagingConsentStatus = 'ImplicitlyOptedIn';
        objMsgUser.MessageType = 'EmbeddedMessaging';//For MIAW Channel
        objMsgUser.MessagingPlatformKey = 'test';
        objMsgUser.Name='test';
        insert objMsgUser;        
        Conversation conv = [SELECT Id from Conversation limit 1][0];
        
        listMessagingSession = new list<MessagingSession>();
        for(integer i=0; i<iNumberOfChats; i++) {
            MessagingSession MessageIterator = new MessagingSession();
            MessageIterator.OwnerId = UserInfo.getUserId();
            MessageIterator.Status  = 'Active';
            //MessageIterator.Customer_Code__c  = '123456';
            //MessageIterator.Customer_Email__c  = 'Testone@gmail.com'; // RQ-004464 
            //MessageIterator.CaseId = caseIterator.Id;
            MessageIterator.MessagingEndUserId = objMsgUser.Id;
            MessageIterator.MessagingChannelId = msgChannel.Id;
            MessageIterator.ConversationId  = conv.Id;

            listMessagingSession.add(MessageIterator);           
            
        }
        if(bCreate) {
            insert listMessagingSession;
        }
        
        Test.Starttest();
        MessagingForWeb.inputs msgInputs = new MessagingForWeb.inputs();
        msgInputs.actionToBePerformed = 'CreateCaseAndUpdateMessaging';
        msgInputs.custEmailId = conIterator.Email ;
        msgInputs.brand = 'Maersk Line';
        msgInputs.msgId = String.valueof(listMessagingSession[0].Id);
        //msgInputs.caseType = '';
        msgInputs.caseOrigin = 'MSLMyMaerskLine';
        //msgInputs.caseDeliveryChannel = '';
        msgInputs.caseCustomerCode = '123456789';
        msgInputs.caseChannel = 'Chat';
        msgInputs.caseSubject = 'TO BE UPDATED BY CHAT AGENT';
        msgInputs.caseRecordType = String.valueof(extCaseRTId);
        msgInputs.caseDirection = 'Not Known';
        //msgInputs.casePortalOnbehalf = '';
        msgInputs.msgCustomerSelectedLang = 'en_US';
        msgInputs.msgBotIntercept = 'https://cdt.maersk.com';
        //msgInputs.msgProactive = '';
        msgInputs.countryCode = 'CN';
        
        
        Message_Routing_Configuration__c  newConfig = new Message_Routing_Configuration__c ();
        newConfig.Country_Code__c = 'CN';
        newConfig.Country_Name__c='China';
        newConfig.Queue_Id__c = '00G2o000008KwDwEAK';
        newConfig.Queue_Name__c= 'Chat - MSL CS - China';
        newConfig.Route_Type__c='Bot';
        newConfig.Technical_Queue_Id__c = '00G2o000008KwIsEAK';
        newConfig.Technical_Queue_Name__c='Chat - Technical - Chinese';
        newConfig.Liner_Brand__c='Maersk Line';
        insert newConfig;
        
        List<MessagingForWeb.inputs> msgInputList = new List<MessagingForWeb.inputs>();
        msgInputList.add(msgInputs);
        MessagingForWeb.MessagingAction(msgInputList);
        
        MessagingForWeb.inputs msgInputs1 = new MessagingForWeb.inputs();
        msgInputs1.actionToBePerformed ='getQueuedetails';
        msgInputs1.brand = 'Maersk Line';
        msgInputs1.custEmailId = conIterator.Email;
        msgInputs1.msgId = String.valueof(listMessagingSession[0].Id);
        List<MessagingForWeb.inputs> msgInputList1 = new List<MessagingForWeb.inputs>();
        msgInputList1.add(msgInputs1);
        MessagingForWeb.MessagingAction(msgInputList1);
        Test.Stoptest();
        
    }
    
    @isTest(SeeAllData=true)
    public static void populateChatTranscript1() {
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
                
        if(conInstance == null) {
            conInstance = conIterator;
        } 
        //conInstance = [SELECT id from contact where email like '%test%' limit 1][0];
        MessagingChannel msgChannel = [select id, IsActive from MessagingChannel  where IsActive = true and MessageType='EmbeddedMessaging' limit 1];

        MessagingEndUser objMsgUser = new MessagingEndUser();
        objMsgUser.ContactId = conInstance.Id;
        objMsgUser.MessagingChannelId = msgChannel.Id;
        objMsgUser.MessagingConsentStatus = 'ImplicitlyOptedIn';
        objMsgUser.MessageType = 'EmbeddedMessaging';//For MIAW Channel
        objMsgUser.MessagingPlatformKey = 'test';
        objMsgUser.Name='test';
        insert objMsgUser;        
        Conversation conv = [SELECT Id from Conversation limit 1][0];
        
        listMessagingSession = new list<MessagingSession>();
        for(integer i=0; i<iNumberOfChats; i++) {
            MessagingSession MessageIterator = new MessagingSession();
            MessageIterator.OwnerId = UserInfo.getUserId();
            MessageIterator.Status  = 'Active';
            //MessageIterator.Customer_Code__c  = '123456';
            //MessageIterator.Customer_Email__c  = 'Testone@gmail.com'; // RQ-004464 
            //MessageIterator.CaseId = caseIterator.Id;
            MessageIterator.MessagingEndUserId = objMsgUser.Id;
            MessageIterator.MessagingChannelId = msgChannel.Id;
            MessageIterator.ConversationId  = conv.Id;

            listMessagingSession.add(MessageIterator);           
            
        }
        if(bCreate) {
            insert listMessagingSession;
        }
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
        caseIterator.SuppliedEmail = Null;
        caseIterator.Origin = 'MSLUSEXP';
        caseIterator.Case_Visibility__c = 'All Users';
        caseIterator.RecordTypeId = extCaseRTId;
        caseIterator.OwnerId = UserInfo.getUserId();
        caseIterator.Bot_Last_Action__c = 'Closed - Resolved';
        caseIterator.Case_Visibility__c ='All Users';
        Insert caseIterator;
        
        MessagingSession toUpdate = new MessagingSession();
        toUpdate.id=listMessagingSession[0].Id;
        toUpdate.caseId=caseIterator.Id;
        update toUpdate;        
        
        MessagingBotSurvey.inputs surveyInputs = new MessagingBotSurvey.inputs();
        surveyInputs.action ='CaseChatSurveyMIAW';
        surveyInputs.brand = 'Maersk Line';
        surveyInputs.caseId = caseIterator.Id;
        surveyInputs.msgId=listMessagingSession[0].Id;
        surveyInputs.language = 'en_US';
        
        List<MessagingBotSurvey.inputs> surveyInputList = new List<MessagingBotSurvey.inputs>();
        surveyInputList.add(surveyInputs);
        
        MessagingBotSurvey.checkSurveyAction(surveyInputList);
    }
    
    @isTest(SeeAllData=true)
    public static void TransferFailedSurvey() {
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
                
        if(conInstance == null) {
            conInstance = conIterator;
        } 
        //conInstance = [SELECT id from contact where email like '%test%' limit 1][0];
        MessagingChannel msgChannel = [select id, IsActive from MessagingChannel  where IsActive = true and MessageType='EmbeddedMessaging' limit 1];

        MessagingEndUser objMsgUser = new MessagingEndUser();
        objMsgUser.ContactId = conInstance.Id;
        objMsgUser.MessagingChannelId = msgChannel.Id;
        objMsgUser.MessagingConsentStatus = 'ImplicitlyOptedIn';
        objMsgUser.MessageType = 'EmbeddedMessaging';//For MIAW Channel
        objMsgUser.MessagingPlatformKey = 'test';
        objMsgUser.Name='test';
        insert objMsgUser;        
        Conversation conv = [SELECT Id from Conversation limit 1][0];
        
        listMessagingSession = new list<MessagingSession>();
        for(integer i=0; i<iNumberOfChats; i++) {
            MessagingSession MessageIterator = new MessagingSession();
            MessageIterator.OwnerId = UserInfo.getUserId();
            MessageIterator.Status  = 'Active';
            //MessageIterator.Customer_Code__c  = '123456';
            //MessageIterator.Customer_Email__c  = 'Testone@gmail.com'; // RQ-004464 
            //MessageIterator.CaseId = caseIterator.Id;
            MessageIterator.MessagingEndUserId = objMsgUser.Id;
            MessageIterator.MessagingChannelId = msgChannel.Id;
            MessageIterator.ConversationId  = conv.Id;

            listMessagingSession.add(MessageIterator);           
            
        }
        if(bCreate) {
            insert listMessagingSession;
        }
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
        caseIterator.SuppliedEmail = Null;
        caseIterator.Origin = 'MSLUSEXP';
        caseIterator.Case_Visibility__c = 'All Users';
        caseIterator.RecordTypeId = extCaseRTId;
        caseIterator.OwnerId = UserInfo.getUserId();        
        caseIterator.Case_Visibility__c ='All Users';
        Insert caseIterator;
        
        MessagingSession toUpdate = new MessagingSession();
        toUpdate.id=listMessagingSession[0].Id;
        toUpdate.caseId=caseIterator.Id;
        update toUpdate; 
        caseIterator.Reason_for_case__c = '';
        caseIterator.Bot_Last_Action__c = 'Transfer Failed';
        triggerExecutionController.skipCaseTrigger(true);
        update caseIterator;
        TriggerExecutionController.skipCaseTrigger(false);
        
        MessagingBotSurvey.inputs surveyInputs = new MessagingBotSurvey.inputs();
        surveyInputs.action ='CaseChatSurveyMIAW';
        surveyInputs.brand = 'Maersk Line';
        surveyInputs.caseId = caseIterator.Id;
        surveyInputs.msgId=listMessagingSession[0].Id;
        surveyInputs.language = 'en_US';
        
        List<MessagingBotSurvey.inputs> surveyInputList = new List<MessagingBotSurvey.inputs>();
        surveyInputList.add(surveyInputs);
        
        MessagingBotSurvey.checkSurveyAction(surveyInputList);
    }
    
    @isTest(SeeAllData=true)
    public static void SurveyWithException() {
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
                
        if(conInstance == null) {
            conInstance = conIterator;
        } 
        //conInstance = [SELECT id from contact where email like '%test%' limit 1][0];
        MessagingChannel msgChannel = [select id, IsActive from MessagingChannel  where IsActive = true and MessageType='EmbeddedMessaging' limit 1];

        MessagingEndUser objMsgUser = new MessagingEndUser();
        objMsgUser.ContactId = conInstance.Id;
        objMsgUser.MessagingChannelId = msgChannel.Id;
        objMsgUser.MessagingConsentStatus = 'ImplicitlyOptedIn';
        objMsgUser.MessageType = 'EmbeddedMessaging';//For MIAW Channel
        objMsgUser.MessagingPlatformKey = 'test';
        objMsgUser.Name='test';
        insert objMsgUser;        
        Conversation conv = [SELECT Id from Conversation limit 1][0];
        
        listMessagingSession = new list<MessagingSession>();
        for(integer i=0; i<iNumberOfChats; i++) {
            MessagingSession MessageIterator = new MessagingSession();
            MessageIterator.OwnerId = UserInfo.getUserId();
            MessageIterator.Status  = 'Active';
            //MessageIterator.Customer_Code__c  = '123456';
            //MessageIterator.Customer_Email__c  = 'Testone@gmail.com'; // RQ-004464 
            //MessageIterator.CaseId = caseIterator.Id;
            MessageIterator.MessagingEndUserId = objMsgUser.Id;
            MessageIterator.MessagingChannelId = msgChannel.Id;
            MessageIterator.ConversationId  = conv.Id;

            listMessagingSession.add(MessageIterator);           
            
        }
        if(bCreate) {
            insert listMessagingSession;
        }
        
        
        MessagingBotSurvey.inputs surveyInputs = new MessagingBotSurvey.inputs();
        surveyInputs.action ='CaseChatSurveyMIAW';
        surveyInputs.brand = 'Maersk Line';
        //surveyInputs.caseId = caseIterator.Id;
        surveyInputs.msgId=listMessagingSession[0].Id;
        surveyInputs.language = 'en_US';
        
        List<MessagingBotSurvey.inputs> surveyInputList = new List<MessagingBotSurvey.inputs>();
        surveyInputList.add(surveyInputs);
        
        MessagingBotSurvey.checkSurveyAction(surveyInputList);
    }
}