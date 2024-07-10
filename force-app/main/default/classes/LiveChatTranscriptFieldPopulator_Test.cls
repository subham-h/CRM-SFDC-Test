@isTest
public class LiveChatTranscriptFieldPopulator_Test {
    public static list<LiveChatTranscript> listChatTranscript = new List<LiveChatTranscript>();
    public static boolean bCreate = true;
    public static integer iNumberOfChats = 5;
    public static List<Case> externalCaselist = new List<Case>(); 
    
    public static testMethod void testChatRequestCreatedOrLinked(){
        TriggerExecutionController.skipAllTriggers(true);
        
        LiveChatData_Test.bCreate = false;
        list<LiveChatTranscript> lstLiveChatTranscript = new list<LiveChatTranscript>();
        LiveChatData_Test.populateChatTranscript();
        lstLiveChatTranscript.addAll(LiveChatData_Test.listChatTranscript);
        TriggerExecutionController.skipAllTriggers(false);
        
        Test.startTest();
        insert lstLiveChatTranscript; 
        Test.stopTest();
        List<LiveChatTranscript> newList = new List<LiveChatTranscript>();
        newList = [Select Id,LiveChatTranscript.Case.FCR_Inbound_Chats__c  from LiveChatTranscript where Id =: lstLiveChatTranscript[0].Id];     
    }
    
    public static testMethod void testChatOwnerChange(){
        TriggerExecutionController.skipAllTriggers(true);
        
        LiveChatData_Test.bCreate = false;
        list<LiveChatTranscript> lstLiveChatTranscript = new list<LiveChatTranscript>();
        LiveChatData_Test.populateChatTranscript();
        Case caserecord = [Select id, OwnerId from Case limit 1];
        caserecord.OwnerId = Label.ChatBotUserId;
        Update caserecord;
        lstLiveChatTranscript.addAll(LiveChatData_Test.listChatTranscript);
        TriggerExecutionController.skipAllTriggers(false);
        insert lstLiveChatTranscript; 
        
        Test.startTest();
        for(LiveChatTranscript chatIterator: lstLiveChatTranscript){
            chatIterator.OwnerId = UserInfo.getUserId();
        }
        Update lstLiveChatTranscript;
        /*
LiveChatTranscriptEvent le = new LiveChatTranscriptEvent();
le.LiveChatTranscriptId = lstLiveChatTranscript[0].id;
le.type = 'ChatbotEndChat';
le.time = system.now();
insert le;
*/
        Test.stopTest();
        List<LiveChatTranscript> newList = new List<LiveChatTranscript>();
        newList = [Select Id,LiveChatTranscript.Case.FCR_Inbound_Chats__c  from LiveChatTranscript where Id =: lstLiveChatTranscript[0].Id];     
    }
    
    public static testMethod void testMissedChat(){
        TriggerExecutionController.skipAllTriggers(true);
        
        LiveChatData_Test.bCreate = false;
        list<LiveChatTranscript> lstLiveChatTranscript = new list<LiveChatTranscript>();
        LiveChatData_Test.MissedChatTranscript();
        lstLiveChatTranscript.addAll(LiveChatData_Test.listChatTranscript);
        TriggerExecutionController.skipAllTriggers(false);
        
        for(LiveChatTranscript chatIterator: lstLiveChatTranscript){
            chatIterator.OwnerId = UserInfo.getUserId();
            
        }
        Test.startTest();
        insert lstLiveChatTranscript; 
        Test.stopTest();
        List<LiveChatTranscript> newList = new List<LiveChatTranscript>();
        newList = [Select Id,LiveChatTranscript.Case.FCR_Inbound_Chats__c  from LiveChatTranscript where Id =: lstLiveChatTranscript[0].Id];     
    }
    
    public static testMethod void twillChatOwnerChange(){
        TriggerExecutionController.skipAllTriggers(true);
        
        LiveChatData_Test.bCreate = false;
        list<LiveChatTranscript> lstLiveChatTranscript = new list<LiveChatTranscript>();
        LiveChatData_Test.TwillChatTranscript();
        lstLiveChatTranscript.addAll(LiveChatData_Test.listChatTranscript);
        TriggerExecutionController.skipAllTriggers(false);
        insert lstLiveChatTranscript;
        
        for(LiveChatTranscript chatIterator: lstLiveChatTranscript){
            chatIterator.OwnerId = UserInfo.getUserId();
            chatIterator.Status = 'Completed'; 
        }
        update lstLiveChatTranscript;
        
        Test.startTest();
        LiveChatTranscript lct = [select id,status from LiveChatTranscript where id =: lstLiveChatTranscript[0].Id];
        Test.stopTest();
        List<LiveChatTranscript> newList = new List<LiveChatTranscript>();
        newList = [Select Id,LiveChatTranscript.Case.FCR_Inbound_Chats__c  from LiveChatTranscript where Id =: lstLiveChatTranscript[0].Id];     
    }
    
    public static testMethod void twillMissedChatOwnerChange(){
        TriggerExecutionController.skipAllTriggers(true);
        
        LiveChatData_Test.bCreate = false;
        list<LiveChatTranscript> lstLiveChatTranscript = new list<LiveChatTranscript>();
        LiveChatData_Test.TwillMissedChatTranscript();
        lstLiveChatTranscript.addAll(LiveChatData_Test.listChatTranscript);
        TriggerExecutionController.skipAllTriggers(false);
        insert lstLiveChatTranscript;
        
        for(LiveChatTranscript chatIterator: lstLiveChatTranscript){
            chatIterator.OwnerId = UserInfo.getUserId();
            chatIterator.Status = 'Completed'; 
        }
        update lstLiveChatTranscript;
        
        Test.startTest();
        LiveChatTranscript lct = [select id,status from LiveChatTranscript where id =: lstLiveChatTranscript[0].Id];
        Test.stopTest();
        List<LiveChatTranscript> newList = new List<LiveChatTranscript>();
        newList = [Select Id,LiveChatTranscript.Case.FCR_Inbound_Chats__c  from LiveChatTranscript where Id =: lstLiveChatTranscript[0].Id];     
    }
    
    public static testMethod void spamChatTest(){
        Test.startTest();
        TriggerExecutionController.skipAllTriggers(true);
        
        LiveChatData_Test.bCreate = false;
        list<LiveChatTranscript> lstLiveChatTranscript = new list<LiveChatTranscript>();
        LiveChatData_Test.spamChatTranscript();
        lstLiveChatTranscript.addAll(LiveChatData_Test.listChatTranscript);
        TriggerExecutionController.skipAllTriggers(false);
        insert lstLiveChatTranscript;
        
        for(LiveChatTranscript chatIterator: lstLiveChatTranscript){
            chatIterator.OwnerId = UserInfo.getUserId();
            chatIterator.Status = 'Completed'; 
        }
        update lstLiveChatTranscript;
        Test.stopTest();
        
    }
    
    public static testMethod void timeoutChatTest(){
        Test.startTest();
        TriggerExecutionController.skipAllTriggers(true);
        
        LiveChatData_Test.bCreate = false;
        list<LiveChatTranscript> lstLiveChatTranscript = new list<LiveChatTranscript>();
        LiveChatData_Test.timeoutChatTranscript();
        lstLiveChatTranscript.addAll(LiveChatData_Test.listChatTranscript);
        TriggerExecutionController.skipAllTriggers(false);
        insert lstLiveChatTranscript;
        
        for(LiveChatTranscript chatIterator: lstLiveChatTranscript){
            chatIterator.Status = 'Completed'; 
        }
        update lstLiveChatTranscript;
        Test.stopTest();
        
    }
}