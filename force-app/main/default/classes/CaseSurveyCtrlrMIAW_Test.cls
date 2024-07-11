@isTest(seeAllData=True)
private class  CaseSurveyCtrlrMIAW_Test {
    public static contact conInstance = null;
    
    @isTest(seeAllData=True)
    public static void caseIteratorSurvey() {
        
        Geography__c chinaCountry=[SELECT Active__c,GEO_Code__c,GEO_ID__c,Id,Is_Port__c,Name,Parent_Geography__c,Port_City__c,SFDC_Record_Id__c,Trade_Type__c,Type_Of_Location__c FROM Geography__c WHERE GEO_Code__c = 'CN' AND Type_Of_Location__c = 'Country' limit 1][0];
        Geography__c chinaCity;
        /*if(chinaCountry <> null) {
            chinaCity = [SELECT Active__c,GEO_Code__c,GEO_ID__c,Id,Is_Port__c,Name,Parent_Geography__c,Port_City__c,SFDC_Record_Id__c,Trade_Type__c,Type_Of_Location__c FROM Geography__c WHERE Parent_Geography__r.Name = 'China'  and  Type_Of_Location__c='City' limit 1][0];
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
        caseIterator.SuppliedEmail = Null;
        caseIterator.Origin = 'MSLUSEXP';
        caseIterator.Case_Visibility__c = 'All Users';
        caseIterator.RecordTypeId = extCaseRTId;
        caseIterator.OwnerId = UserInfo.getUserId();
        caseIterator.Security_Code__c = '1235'; 
        Insert caseIterator;
                
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
        
        
        system.debug('test case*'+caseIterator);
        Test.startTest();
        
        PageReference pageRef = Page.CaseSurvey;
        pageRef.getParameters().put('lang', 'en_US');
        pageRef.getParameters().put('LB', BrandUtilities.MAERSKLINE);        
        pageRef.getParameters().put('Id', caseIterator.Id);
        pageRef.getParameters().put('Fb','3');
        pageRef.getParameters().put('Sc', caseIterator.Security_Code__c);
        
        Test.setCurrentPage(pageRef); 
        CaseSurveyCtrlrMIAW caseSurveyCtrlInst = new  CaseSurveyCtrlrMIAW();
        caseSurveyCtrlInst.pageName='CaseChatSurveyMIAW';
        caseSurveyCtrlInst.createSurvey();
        caseSurveyCtrlInst.updateSurvey(); // #RQ-007849
        caseSurveyCtrlInst.exception2();
        caseSurveyCtrlInst.exception1();
        
        list<Survey__c> lstSvyCreated = [Select Id, Ease_to_Resolve_Issue_Description__c, Response_Actions__c, Ease_to_Resolve_Issue__c From Survey__c Where Case__c =: caseIterator.Id];        

        PageReference pageRef2 = Page.CaseChatSurveyMIAW;
        pageRef2.getParameters().put('lang', 'en_US');
        pageRef2.getParameters().put('LB', BrandUtilities.MAERSKLINE);        
        pageRef2.getParameters().put('Id', caseIterator.Id);
        pageRef2.getParameters().put('Fb','1');
        pageRef2.getParameters().put('Sc', caseIterator.Security_Code__c);
        Test.setCurrentPage(pageRef2);
        CaseSurveyCtrlrMIAW caseSurveyCtrlInst2 = new  CaseSurveyCtrlrMIAW();
        caseSurveyCtrlInst2.pageName='CaseChatSurveyMIAW';
        caseSurveyCtrlInst2.createSurvey(); 
        try{
            //v2.0 : #RQ-007849 (Updated to improve the code coverage)      
            //   lstSvyCreated[0].Ease_to_Resolve_Issue_Description__c = 'Resolved';
            update lstSvyCreated;
        }catch(exception es){}
        caseSurveyCtrlInst2.updateSurvey(); //v2.0
        
        list<Survey__c> lstSvyUpdated = [Select Id, Ease_to_Resolve_Issue_Description__c, Ease_to_Resolve_Issue__c From Survey__c Where Case__c =: caseIterator.Id];
        
        
        PageReference pageRef3 = Page.CaseChatSurveyMIAW;
        pageRef3.getParameters().put('lang', 'en_US');
        pageRef3.getParameters().put('LB', BrandUtilities.MAERSKLINE);        
        pageRef3.getParameters().put('Id', caseIterator.Id);
        pageRef3.getParameters().put('Fb','1');
        pageRef3.getParameters().put('param1','1');
        pageRef3.getParameters().put('Sc', caseIterator.Security_Code__c);
        Test.setCurrentPage(pageRef2);
        CaseSurveyCtrlrMIAW caseSurveyCtrlInst3 = new  CaseSurveyCtrlrMIAW();
        caseSurveyCtrlInst3.pageName='CaseChatSurveyMIAW';
        caseSurveyCtrlInst3.createSurvey(); 
        
        Test.stopTest();                
    }
    
    @isTest(seeAllData=True)
    static void testLctProactiveSurvey() {
       
        Geography__c chinaCountry=[SELECT Active__c,GEO_Code__c,GEO_ID__c,Id,Is_Port__c,Name,Parent_Geography__c,Port_City__c,SFDC_Record_Id__c,Trade_Type__c,Type_Of_Location__c FROM Geography__c WHERE GEO_Code__c = 'CN' AND Type_Of_Location__c = 'Country' limit 1][0];
        Geography__c chinaCity;
        /*if(chinaCountry <> null) {
            chinaCity = [SELECT Active__c,GEO_Code__c,GEO_ID__c,Id,Is_Port__c,Name,Parent_Geography__c,Port_City__c,SFDC_Record_Id__c,Trade_Type__c,Type_Of_Location__c FROM Geography__c WHERE Parent_Geography__r.Name = 'China'  and  Type_Of_Location__c='City' limit 1][0];
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
        caseIterator.SuppliedEmail = Null;
        caseIterator.Origin = 'MSLUSEXP';
        caseIterator.Case_Visibility__c = 'All Users';
        caseIterator.RecordTypeId = extCaseRTId;
        caseIterator.OwnerId = UserInfo.getUserId();
        Insert caseIterator;
        system.debug('caseIterator----'+caseIterator);
                
        if(conInstance == null) {
            conInstance = conIterator;
        } 
        //conInstance = [SELECT id from contact where email like '%test%' limit 1][0];
        MessagingChannel msgChannel = [select id, IsActive from MessagingChannel  where IsActive = true  and MessageType='EmbeddedMessaging' limit 1];

        MessagingEndUser objMsgUser = new MessagingEndUser();
        objMsgUser.ContactId = conInstance.Id;
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
            
            system.debug('msgIterator---'+msgIterator);
            
            PageReference pageRef = Page.CaseChatSurveyMIAW;
            string attachedRecords = '{"Id":"'+ caseIterator.id+'"}';
            system.debug('attachedRecords ---'+attachedRecords );
            pageRef.getParameters().put('attachedRecords',attachedRecords);
            Test.setCurrentPage(pageRef); 

            Test.startTest();
            CaseSurveyCtrlrMIAW caseSurveyCtrlInst = new  CaseSurveyCtrlrMIAW();
            caseSurveyCtrlInst.pageName = 'CaseChatSurveyMIAW';
            caseSurveyCtrlInst.caseid = caseIterator.Id;
            caseSurveyCtrlInst.createSurvey();
            Boolean successMessage = caseSurveyCtrlInst.successMessage;
            
            Test.stopTest();
            System.assertEquals(false, successMessage);

      
    }
    
    @isTest(seeAllData=True)
    static void testLctProactiveSurvey1() {
       
        Geography__c chinaCountry=[SELECT Active__c,GEO_Code__c,GEO_ID__c,Id,Is_Port__c,Name,Parent_Geography__c,Port_City__c,SFDC_Record_Id__c,Trade_Type__c,Type_Of_Location__c FROM Geography__c WHERE GEO_Code__c = 'CN' AND Type_Of_Location__c = 'Country' limit 1][0];
        Geography__c chinaCity;
        /*if(chinaCountry <> null) {
            chinaCity = [SELECT Active__c,GEO_Code__c,GEO_ID__c,Id,Is_Port__c,Name,Parent_Geography__c,Port_City__c,SFDC_Record_Id__c,Trade_Type__c,Type_Of_Location__c FROM Geography__c WHERE Parent_Geography__r.Name = 'China'  and  Type_Of_Location__c='City' limit 1][0];
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
        caseIterator.SuppliedEmail = Null;
        caseIterator.Origin = 'MSLUSEXP';
        caseIterator.Case_Visibility__c = 'All Users';
        caseIterator.RecordTypeId = extCaseRTId;
        caseIterator.OwnerId = UserInfo.getUserId();
        Insert caseIterator;
        system.debug('caseIterator----'+caseIterator);
                
        if(conInstance == null) {
            conInstance = conIterator;
        } 
        //conInstance = [SELECT id from contact where email like '%test%' limit 1][0];
        MessagingChannel msgChannel = [select id, IsActive from MessagingChannel  where IsActive = true  and MessageType='EmbeddedMessaging' limit 1];

        MessagingEndUser objMsgUser = new MessagingEndUser();
        objMsgUser.ContactId = conInstance.Id;
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
            
            system.debug('msgIterator---'+msgIterator);
            
            PageReference pageRef2 = Page.CaseChatSurveyMIAW;
            pageRef2.getParameters().put('lang', 'en_US');
            pageRef2.getParameters().put('LB', BrandUtilities.MAERSKLINE);        
            pageRef2.getParameters().put('Id', caseIterator.Id);
            pageRef2.getParameters().put('Fb','1');
            pageRef2.getParameters().put('Sc', caseIterator.Security_Code__c);
            Test.setCurrentPage(pageRef2);
            //CaseSurveyCtrlrMIAW caseSurveyCtrlInst2 = new  CaseSurveyCtrlrMIAW();
            //caseSurveyCtrlInst2.pageName='CaseChatSurveyMIAW';
            //caseSurveyCtrlInst2.createSurvey();       

            Test.startTest();
            CaseSurveyCtrlrMIAW caseSurveyCtrlInst = new  CaseSurveyCtrlrMIAW();
            caseSurveyCtrlInst.pageName = 'CaseChatSurveyMIAW';
            //caseSurveyCtrlInst.caseid = caseIterator.Id;
            caseSurveyCtrlInst.createSurvey();
            Boolean successMessage = caseSurveyCtrlInst.successMessage;
            
            Test.stopTest();
            System.assertEquals(false, successMessage);
    }
    
    @isTest(seeAllData=True)
    public static void testBrandCSS() {
        
        Geography__c chinaCountry=[SELECT Active__c,GEO_Code__c,GEO_ID__c,Id,Is_Port__c,Name,Parent_Geography__c,Port_City__c,SFDC_Record_Id__c,Trade_Type__c,Type_Of_Location__c FROM Geography__c WHERE GEO_Code__c = 'CN' AND Type_Of_Location__c = 'Country' limit 1][0];
        Geography__c chinaCity;
        /*if(chinaCountry <> null) {
            chinaCity = [SELECT Active__c,GEO_Code__c,GEO_ID__c,Id,Is_Port__c,Name,Parent_Geography__c,Port_City__c,SFDC_Record_Id__c,Trade_Type__c,Type_Of_Location__c FROM Geography__c WHERE Parent_Geography__r.Name = 'China'  and  Type_Of_Location__c='City' limit 1][0];
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
        caseIterator.SuppliedEmail = Null;
        caseIterator.Origin = 'MSLUSEXP';
        caseIterator.Case_Visibility__c = 'All Users';
        caseIterator.RecordTypeId = extCaseRTId;
        caseIterator.OwnerId = UserInfo.getUserId();
        caseIterator.Security_Code__c = '1235'; 
        Insert caseIterator;
                
        if(conInstance == null) {
            conInstance = conIterator;
        } 
        //conInstance = [SELECT id from contact where email like '%test%' limit 1][0];
        MessagingChannel msgChannel = [select id, IsActive from MessagingChannel  where IsActive = true  and MessageType='EmbeddedMessaging' limit 1];

        MessagingEndUser objMsgUser = new MessagingEndUser();
        objMsgUser.ContactId = conInstance.Id;
        objMsgUser.MessagingChannelId = msgChannel.Id;
        objMsgUser.MessagingConsentStatus = 'ImplicitlyOptedIn';
        objMsgUser.MessageType = 'EmbeddedMessaging';//For MIAW Channel
        objMsgUser.MessagingPlatformKey = 'test';
        objMsgUser.Name='test';
        insert objMsgUser;        
        Conversation conv = [SELECT Id from Conversation limit 1][0];
        
        PageReference pageRef = Page.CaseSurvey;
        pageRef.getParameters().put('lang', 'en_US');
        pageRef.getParameters().put('LB', BrandUtilities.MAERSKLINE);    
        pageRef.getParameters().put('Fb','1');
        pageRef.getParameters().put('Sc', caseIterator.Security_Code__c);
        Test.setCurrentPage(pageRef); 
        
        
        System.test.startTest();
        CaseSurveyCtrlrMIAW caseSurveyCtrlInst = new  CaseSurveyCtrlrMIAW();
        caseSurveyCtrlInst.twill = false;
        caseSurveyCtrlInst.getBrandCSSLocation();
        caseSurveyCtrlInst.getBrandLogoCSS();
        caseSurveyCtrlInst.getBrandCSSFileName();
        caseSurveyCtrlInst.getBrandLogoLocation();
        caseSurveyCtrlInst.getBrandLogoFileName();
        
        System.test.stopTest();    
    }
    
    @isTest(seeAllData=True)
    public static void testDupedSurvey() {
        
        Geography__c chinaCountry=[SELECT Active__c,GEO_Code__c,GEO_ID__c,Id,Is_Port__c,Name,Parent_Geography__c,Port_City__c,SFDC_Record_Id__c,Trade_Type__c,Type_Of_Location__c FROM Geography__c WHERE GEO_Code__c = 'CN' AND Type_Of_Location__c = 'Country' limit 1][0];
        Geography__c chinaCity;
        /*if(chinaCountry <> null) {
            chinaCity = [SELECT Active__c,GEO_Code__c,GEO_ID__c,Id,Is_Port__c,Name,Parent_Geography__c,Port_City__c,SFDC_Record_Id__c,Trade_Type__c,Type_Of_Location__c FROM Geography__c WHERE Parent_Geography__r.Name = 'China'  and  Type_Of_Location__c='City' limit 1][0];
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
        caseIterator.SuppliedEmail = Null;
        caseIterator.Origin = 'MSLUSEXP';
        caseIterator.Case_Visibility__c = 'All Users';
        caseIterator.RecordTypeId = extCaseRTId;
        caseIterator.OwnerId = UserInfo.getUserId();
        caseIterator.Security_Code__c = '1235'; 
        Insert caseIterator;
                
        if(conInstance == null) {
            conInstance = conIterator;
        } 
        //conInstance = [SELECT id from contact where email like '%test%' limit 1][0];
        MessagingChannel msgChannel = [select id, IsActive from MessagingChannel  where IsActive = true  and MessageType='EmbeddedMessaging' limit 1];

        MessagingEndUser objMsgUser = new MessagingEndUser();
        objMsgUser.ContactId = conInstance.Id;
        objMsgUser.MessagingChannelId = msgChannel.Id;
        objMsgUser.MessagingConsentStatus = 'ImplicitlyOptedIn';
        objMsgUser.MessageType = 'EmbeddedMessaging';//For MIAW Channel
        objMsgUser.MessagingPlatformKey = 'test';
        objMsgUser.Name='test';
        insert objMsgUser;        
        Conversation conv = [SELECT Id from Conversation limit 1][0];
        
        
        
        PageReference pageRef = Page.CaseChatSurveyMIAW;
        pageRef.getParameters().put('lang', 'en_US');
        pageRef.getParameters().put('LB', BrandUtilities.MAERSKLINE); 
        // Commented the below code to cover the exception part.
        //  pageRef.getParameters().put('Id', caseIterator.Id);
        pageRef.getParameters().put('Fb','1');
        pageRef.getParameters().put('Sc', caseIterator.Security_Code__c);
        Test.setCurrentPage(pageRef); 
        
        System.test.startTest();
        CaseSurveyCtrlrMIAW caseSurveyCtrlInst = new  CaseSurveyCtrlrMIAW();
        caseSurveyCtrlInst.createSurvey();
        CaseSurveyCtrlrMIAW caseSurveyCtrlInst1 = new  CaseSurveyCtrlrMIAW();    
        caseSurveyCtrlInst1.createSurvey();
        caseSurveyCtrlInst1.updateSurvey();
        System.test.stopTest();
        
        //list<Survey__c> lstSurvey = [SELECT Id FROM Survey__c];
        //System.assertEquals(0, lstSurvey.size());        
    }            

    @isTest(seeAllData=True)
    public static void caseIteratorChatSurveyMIAW() {
        Geography__c chinaCountry=[SELECT Active__c,GEO_Code__c,GEO_ID__c,Id,Is_Port__c,Name,Parent_Geography__c,Port_City__c,SFDC_Record_Id__c,Trade_Type__c,Type_Of_Location__c FROM Geography__c WHERE GEO_Code__c = 'CN' AND Type_Of_Location__c = 'Country' limit 1][0];
        Geography__c chinaCity;
        /*if(chinaCountry <> null) {
            chinaCity = [SELECT Active__c,GEO_Code__c,GEO_ID__c,Id,Is_Port__c,Name,Parent_Geography__c,Port_City__c,SFDC_Record_Id__c,Trade_Type__c,Type_Of_Location__c FROM Geography__c WHERE Parent_Geography__r.Name = 'China'  and  Type_Of_Location__c='City' limit 1][0];
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
        caseIterator.SuppliedEmail = Null;
        caseIterator.Origin = 'MSLUSEXP';
        caseIterator.Case_Visibility__c = 'All Users';
        caseIterator.RecordTypeId = extCaseRTId;
        caseIterator.OwnerId = UserInfo.getUserId();
        caseIterator.Security_Code__c = '1235'; 
        caseIterator.Bot_Last_Action__c = 'Transfer Failed';   
        Insert caseIterator;
                
        if(conInstance == null) {
            conInstance = conIterator;
        } 
        //conInstance = [SELECT id from contact where email like '%test%' limit 1][0];
        MessagingChannel msgChannel = [select id, IsActive from MessagingChannel  where IsActive = true  and MessageType='EmbeddedMessaging' limit 1];

        MessagingEndUser objMsgUser = new MessagingEndUser();
        objMsgUser.ContactId = conInstance.Id;
        objMsgUser.MessagingChannelId = msgChannel.Id;
        objMsgUser.MessagingConsentStatus = 'ImplicitlyOptedIn';
        objMsgUser.MessageType = 'EmbeddedMessaging';//For MIAW Channel
        objMsgUser.MessagingPlatformKey = 'test';
        objMsgUser.Name='test';
        insert objMsgUser;        
        Conversation conv = [SELECT Id from Conversation limit 1][0];
        
        //SC-276
        caseIterator.Bot_Last_Action__c = 'Transfer Failed';
        triggerExecutionController.skipCaseTrigger(true);
        update caseIterator;
        TriggerExecutionController.skipCaseTrigger(false);
        //SC-276 End
        system.debug('caseIterator'+caseIterator);
        PageReference pageRef = Page.CaseChatSurveyMIAW;
        string attachedRecords = '{"CaseId":"'+ caseIterator.id+'"}';
        pageRef.getParameters().put('attachedRecords',attachedRecords);
        pageRef.getParameters().put('lang', 'en_US');
        pageRef.getParameters().put('LB', BrandUtilities.MAERSKLINE); 
        // Commented the below code to cover the exception part.
        pageRef.getParameters().put('Id', caseIterator.Id);
        pageRef.getParameters().put('Fb','1');
        pageRef.getParameters().put('Sc', caseIterator.Security_Code__c);
        Test.setCurrentPage(pageRef); 
        
        System.test.startTest();
        CaseSurveyCtrlrMIAW caseSurveyCtrlInst = new  CaseSurveyCtrlrMIAW(); 
        caseSurveyCtrlInst.setSendCaseClosureForTransferFailed();
        caseSurveyCtrlInst.createSurvey();
        CaseSurveyCtrlrMIAW caseSurveyCtrlInst1 = new  CaseSurveyCtrlrMIAW();
        caseSurveyCtrlInst1.detailedFeedback='test';
        
        caseSurveyCtrlInst1.createSurvey();
        caseSurveyCtrlInst1.updateSurvey();
        caseSurveyCtrlInst1.selectSmiley();
        System.test.stopTest();
        
        //list<Survey__c> lstSurvey = [SELECT Id FROM Survey__c];
    }
}