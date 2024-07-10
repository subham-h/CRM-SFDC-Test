@isTest
public class LiveChatData_Test {
    public static list<LiveChatTranscript> listChatTranscript = new List<LiveChatTranscript>();
    public static boolean bCreate = true;
    public static integer iNumberOfChats = 5;
    public static Contact conInstance = null;
    public static Case caseInstance = null;
    public static User userInstance = null;
    public static List<LiveChatVisitor> listChatVisitor = null;
    
    @isTest
    public static void populateChatTranscript() {
        if(conInstance == null) {
            ContactData_Test.iNumberOfContacts = 1;
            ContactData_Test.createCustomerContacts();
            conInstance = ContactData_Test.lstContacts[0];
        } 
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        CaseData_Test.createExternalCasesII();
        CaseInstance = CaseData_Test.lstCases[0];
        CaseInstance.OwnerId = UserInfo.getUserId();
        Insert CaseInstance;
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        
        listChatTranscript = new list<LiveChatTranscript>();
        for(integer i=0; i<iNumberOfChats; i++) {
            LiveChatTranscript charTranscriptIterator = new LiveChatTranscript();
            charTranscriptIterator.OwnerId = UserInfo.getUserId();
            charTranscriptIterator.Status  = 'InProgress';
            charTranscriptIterator.Customer_Code__c  = '123456';
            charTranscriptIterator.Customer_Email__c  = 'Testone@gmail.com'; // RQ-004464 
            charTranscriptIterator.VisitorNetwork  = 'Unknown';
            charTranscriptIterator.Platform = 'Win10';
            charTranscriptIterator.Body = 'Test 123';
            charTranscriptIterator.ContactId = conInstance.Id;
            charTranscriptIterator.CaseId = CaseInstance.Id;
            charTranscriptIterator.LiveChatVisitorId = lcv.Id;
            listChatTranscript.add(charTranscriptIterator);
            
            
        }
        if(bCreate) {
            insert listChatTranscript;
        }
    }
    
    @isTest
    public static void transcriptcaseOwnerChange() {
        
        
        userInstance = UserData_Test.createUsersForChat();
        //Insert userInstance;
        
        User user1 = TestBusinessHelper.createUser('102 - Customer Service', 'MaerskLine', true);
		UserData_Test.bCreate = false;
        
         if(conInstance == null) {
            ContactData_Test.iNumberOfContacts = 1;
            ContactData_Test.createCustomerContacts();
            conInstance = ContactData_Test.lstContacts[0];
        }
        System.runAs(user1) {
        	CaseData_Test.bCreate = false;
        	CaseData_Test.iNumberOfCases = 1; 
        	CaseData_Test.createExternalCasesII();
        	CaseInstance = CaseData_Test.lstCases[0];
        	Insert CaseInstance;
        }
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        
        listChatTranscript = new list<LiveChatTranscript>();
        for(integer i=0; i<iNumberOfChats; i++) {
            LiveChatTranscript charTranscriptIterator = new LiveChatTranscript();
            charTranscriptIterator.OwnerId =  userinfo.getUserId();
            charTranscriptIterator.Status  = 'InProgress';
            
            charTranscriptIterator.Customer_Code__c  = '123456';
            charTranscriptIterator.Customer_Email__c  = 'Testone@gmail.com'; // RQ-004464 
            charTranscriptIterator.VisitorNetwork  = 'Unknown';
            charTranscriptIterator.Platform = 'Win10';
            charTranscriptIterator.Body = 'Test 123';
            charTranscriptIterator.ContactId = conInstance.Id;
            charTranscriptIterator.CaseId = CaseInstance.Id;
            charTranscriptIterator.LiveChatVisitorId = lcv.Id;
            listChatTranscript.add(charTranscriptIterator);
            
            
        }
        if(bCreate) {
            insert listChatTranscript;
        }
    }
    
    
    @isTest
    public static void missedChatTranscript() {
        if(conInstance == null) {
            ContactData_Test.iNumberOfContacts = 1;
            ContactData_Test.createCustomerContacts();
            conInstance = ContactData_Test.lstContacts[0];
        } 
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        CaseData_Test.createExternalCasesII();
        CaseInstance = CaseData_Test.lstCases[0];
        CaseInstance.OwnerId = Label.ChatBotUserId ;
        CaseInstance.Priority = 'High';
        Insert CaseInstance;
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        
        listChatTranscript = new list<LiveChatTranscript>();
        for(integer i=0; i<iNumberOfChats; i++) {
            LiveChatTranscript charTranscriptIterator = new LiveChatTranscript();
            charTranscriptIterator.OwnerId = UserInfo.getUserId();
            charTranscriptIterator.Status  = 'Missed';
            charTranscriptIterator.Customer_Code__c  = '123456';
            charTranscriptIterator.Customer_Email__c  = 'Testone@gmail.com'; // RQ-004464 
            charTranscriptIterator.VisitorNetwork  = 'Unknown';
            charTranscriptIterator.Platform = 'Win10';
            charTranscriptIterator.Body = 'Test 123';
            charTranscriptIterator.ContactId = conInstance.Id;
            charTranscriptIterator.CaseId = CaseInstance.Id;
            charTranscriptIterator.LiveChatVisitorId = lcv.Id;
            listChatTranscript.add(charTranscriptIterator);
            
            
        }
        if(bCreate) {
            insert listChatTranscript;
        }
    }
    
    @isTest
    public static void testCompletedLiveChatTranscript() {
        if(conInstance == null) {
            ContactData_Test.iNumberOfContacts = 1;
            ContactData_Test.createCustomerContacts();
            conInstance = ContactData_Test.lstContacts[0];
        } 
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        CaseData_Test.createExternalCasesII();
        CaseInstance = CaseData_Test.lstCases[0];
        Insert CaseInstance;
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        
        listChatTranscript = new list<LiveChatTranscript>();
        for(integer i=0; i<iNumberOfChats; i++) {
            LiveChatTranscript charTranscriptIterator = new LiveChatTranscript();
            charTranscriptIterator.OwnerId = UserInfo.getUserId();
            charTranscriptIterator.Status  = 'Completed';
            charTranscriptIterator.Customer_Code__c  = '123456';
            charTranscriptIterator.Customer_Email__c  = 'Testone@gmail.com'; // RQ-004464 
            charTranscriptIterator.VisitorNetwork  = 'Unknown';
            charTranscriptIterator.Platform = 'Win10';
            charTranscriptIterator.Body = 'Test 123';
            charTranscriptIterator.ContactId = conInstance.Id;
            charTranscriptIterator.CaseId = CaseInstance.Id;
            charTranscriptIterator.LiveChatVisitorId = lcv.Id;
            listChatTranscript.add(charTranscriptIterator);
            
            
        }
        if(bCreate) {
            insert listChatTranscript;
        }
    }
    
    @isTest
    public static void twillChatTranscript() {
        if(conInstance == null) {
            ContactData_Test.iNumberOfContacts = 1;
            ContactData_Test.createCustomerContacts();
            conInstance = ContactData_Test.lstContacts[0];
        } 
        
        userInstance = UserData_Test.createUser();
      //  insert userInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        CaseData_Test.createExternalCasesII();
        CaseInstance = CaseData_Test.lstCases[0];
        CaseInstance.OwnerId = UserInfo.getUserId() ;
        CaseInstance.Priority = 'High';
        Insert CaseInstance;
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        
        
        
        listChatTranscript = new list<LiveChatTranscript>();
        for(integer i=0; i<iNumberOfChats; i++) {
            LiveChatTranscript charTranscriptIterator = new LiveChatTranscript();
            charTranscriptIterator.OwnerId = UserInfo.getUserId();
            charTranscriptIterator.Customer_Code__c  = '123456';
            charTranscriptIterator.Customer_Email__c  = 'Testone@gmail.com'; // RQ-004464 
            charTranscriptIterator.VisitorNetwork  = 'Unknown';
            charTranscriptIterator.Platform = 'Win10';
            charTranscriptIterator.Body = 'Test 123';
            charTranscriptIterator.ContactId = conInstance.Id;
            charTranscriptIterator.CaseId = CaseInstance.Id;
            charTranscriptIterator.LiveChatVisitorId = lcv.Id;
            
            listChatTranscript.add(charTranscriptIterator);
            
        }
        if(bCreate) {
            insert listChatTranscript;
        }
    }
    
    public static void twillMissedChatTranscript() {
        if(conInstance == null) {
            ContactData_Test.iNumberOfContacts = 1;
            ContactData_Test.createCustomerContacts();
            conInstance = ContactData_Test.lstContacts[0];
        } 
        
        userInstance = UserData_Test.createUser();
        userInstance.FirstName = '';
        userInstance.LastName = '01 Chat Bot - AGENT';
        insert userInstance;
        
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        CaseData_Test.createExternalCasesII();
        CaseInstance = CaseData_Test.lstCases[0];
        CaseInstance.OwnerId = userInstance.Id ;
        CaseInstance.Priority = 'Low';
        CaseInstance.Sub_Type__c = null;
        CaseInstance.Delivery_Channel__c = 'MaerskGo';
        CaseInstance.SuppliedEmail = 'test@maersk.com';
        CaseInstance.Status = 'New';
        Insert CaseInstance;
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        
        listChatTranscript = new list<LiveChatTranscript>();
        for(integer i=0; i<iNumberOfChats; i++) {
            LiveChatTranscript charTranscriptIterator = new LiveChatTranscript();
            charTranscriptIterator.OwnerId = UserInfo.getUserId();
            charTranscriptIterator.Customer_Code__c  = '123456';
            //charTranscriptIterator.Status = 'InProgress';
            charTranscriptIterator.Customer_Email__c  = 'Testone@gmail.com'; // RQ-004464 
            charTranscriptIterator.VisitorNetwork  = 'Unknown';
            charTranscriptIterator.Platform = 'Win10';
            charTranscriptIterator.Body = 'Test 123';
            charTranscriptIterator.ContactId = conInstance.Id;
            charTranscriptIterator.CaseId = CaseInstance.Id;
            charTranscriptIterator.LiveChatVisitorId = lcv.Id;
            
            listChatTranscript.add(charTranscriptIterator);
            
            
        }
        if(bCreate) {
            insert listChatTranscript;
        }
    }
    
    public static void spamChatTranscript() {
        if(conInstance == null) {
            ContactData_Test.iNumberOfContacts = 1;
            ContactData_Test.createCustomerContacts();
            conInstance = ContactData_Test.lstContacts[0];
        } 
        
        userInstance = UserData_Test.createUser();
        userInstance.FirstName = '';
        userInstance.LastName = '01 Chat Bot - AGENT';
        insert userInstance;
        
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        CaseData_Test.createExternalCasesII();
        CaseInstance = CaseData_Test.lstCases[0];
        CaseInstance.OwnerId = userInstance.Id ;
        CaseInstance.Priority = 'Low';
        CaseInstance.Sub_Type__c = null;
        CaseInstance.SuppliedEmail = 'test@maersk.com';
        CaseInstance.Status = 'New';
        Insert CaseInstance;
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        
        
        
        listChatTranscript = new list<LiveChatTranscript>();
        for(integer i=0; i<iNumberOfChats; i++) {
            LiveChatTranscript charTranscriptIterator = new LiveChatTranscript();
            charTranscriptIterator.OwnerId = UserInfo.getUserId();
            charTranscriptIterator.Customer_Code__c  = '123456';
            //charTranscriptIterator.Status = 'InProgress';
            charTranscriptIterator.Customer_Email__c  = 'Testone@gmail.com'; // RQ-004464 
            charTranscriptIterator.VisitorNetwork  = 'Unknown';
            charTranscriptIterator.Platform = 'Win10';
            charTranscriptIterator.Body = 'Test 123';
            charTranscriptIterator.ContactId = conInstance.Id;
            charTranscriptIterator.CaseId = CaseInstance.Id;
            charTranscriptIterator.LiveChatVisitorId = lcv.Id;
            
            listChatTranscript.add(charTranscriptIterator);
            
        }
        if(bCreate) {
            insert listChatTranscript;
        }
    }
    
    public static void timeoutChatTranscript() {
        if(conInstance == null) {
            ContactData_Test.iNumberOfContacts = 1;
            ContactData_Test.createCustomerContacts();
            conInstance = ContactData_Test.lstContacts[0];
        } 
        
        userInstance = UserData_Test.createUser();
        insert userInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        CaseData_Test.createExternalCasesII();
        CaseInstance = CaseData_Test.lstCases[0];
        CaseInstance.ContactId = conInstance.Id;
        CaseInstance.OwnerId = userInstance.Id;
        CaseInstance.Priority = 'Low';
        CaseInstance.Type = 'Booking';
        CaseInstance.Sub_Type__c = 'Cancel Booking';
        CaseInstance.Reason_For_Case__c = 'Cancel Booking';
        Insert CaseInstance;
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        
        listChatTranscript = new list<LiveChatTranscript>();
        for(integer i=0; i<iNumberOfChats; i++) {
            LiveChatTranscript charTranscriptIterator = new LiveChatTranscript();
            charTranscriptIterator.OwnerId = userInstance.Id;
            charTranscriptIterator.Customer_Code__c  = '123456';
            //charTranscriptIterator.Status = 'InProgress';
            charTranscriptIterator.Customer_Email__c  = 'Testone@gmail.com'; // RQ-004464 
            charTranscriptIterator.VisitorNetwork  = 'Unknown';
            charTranscriptIterator.Platform = 'Win10';
            charTranscriptIterator.Body = 'Test 123';
            charTranscriptIterator.ContactId = conInstance.Id;
            charTranscriptIterator.CaseId = CaseInstance.Id;
            charTranscriptIterator.LiveChatVisitorId = lcv.Id;
            
            listChatTranscript.add(charTranscriptIterator);
            
            
        }
        if(bCreate) {
            insert listChatTranscript;
        }
    }
    
}