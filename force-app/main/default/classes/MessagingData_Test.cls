@isTest(SeeAllData=true)
public class MessagingData_Test {
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
        
        listMessagingSession = new list<MessagingSession>();
        for(integer i=0; i<iNumberOfChats; i++) {
            MessagingSession MessageIterator = new MessagingSession();
            MessageIterator.OwnerId = UserInfo.getUserId();
            MessageIterator.Status  = 'Active';
            MessageIterator.Customer_Code__c  = '123456';
            MessageIterator.Customer_Email__c  = 'Testone@gmail.com'; // RQ-004464 
            MessageIterator.CaseId = caseIterator.Id;
            MessageIterator.MessagingEndUserId = objMsgUser.Id;
            MessageIterator.MessagingChannelId = msgChannel.Id;
            MessageIterator.ConversationId  = conv.Id;

            listMessagingSession.add(MessageIterator);           
            
        }
        if(bCreate) {
            insert listMessagingSession;
        }
    }
    
    @isTest(SeeAllData=true)
    public static void transcriptcaseOwnerChange() {
        Id profileId = [select id from profile where name='102 - Customer Service'].id;  //RQ-012996
        User userIterator = new User();
        userIterator.FirstName = 'Test';
        userIterator.LastName = 'User';
        userIterator.alias = 'tstUser';
        userIterator.ProfileId = profileId;
        // fix on production validation error, changed the email domain to maersk.com
        userIterator.email='ContactData_Test'+ '@maersk.com';
        userIterator.TimeZoneSidKey = 'America/Los_Angeles';
        userIterator.LocaleSidKey = 'en_US';
        userIterator.LanguageLocaleKey = 'en_US';
        userIterator.EmailEncodingKey = 'UTF-8';
        userIterator.country='China';
        userIterator.IsActive =true;
        //userIterator.Quoting_Tool__c='AFLS';
        userIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        userIterator.MLL__C = True;
        userIterator.Cluster__c='Greater China Area';
        userIterator.username='userinstance'+'@noemail.com';
        userIterator.CM_Visibility__c = 'Single Carrier';
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) { 
             insert userIterator;
        }
        MessagingSession ms = [SELECT Id,ownerId,MessagingChannel.MessageType from MessagingSession where MessagingChannel.MessageType='EmbeddedMessaging' order by createddate desc limit 1 ][0];
        system.debug('***ms*** '+ms );
        //ms.OwnerId = userIterator.Id;
        //update ms;
        
    }
    
    

}