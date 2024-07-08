@isTest
public class PopulateBotFieldsTest {
    @isTest
    static void testgetChatInfo() {
        Test.startTest();
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];

        LiveChatData_Test.bCreate = false;
        List<LiveChatTranscript> lstLiveChatTranscript = new List<LiveChatTranscript>();
        LiveChatData_Test.populateChatTranscript();
        lstLiveChatTranscript.addAll(LiveChatData_Test.listChatTranscript);
        TriggerExecutionController.skipAllTriggers(false);
        insert lstLiveChatTranscript;

        // Existing code from testgetChatInfo
        List<LiveChatTranscript> newList = [SELECT Id, Bot_Intercept__c, ContactId, Proactive__c, Liner_Brand__c, CaseId, LiveChatButtonId, LiveChatButton.DeveloperName FROM LiveChatTranscript WHERE Id = :lstLiveChatTranscript[0].Id];
        newList[0].Liner_Brand__c = 'Maersk Line';
        update newList;

        String liveChatButtonId = newList[0].LiveChatButtonId;

        List<PopulateBotFields.botInput> lstbotinput = new List<PopulateBotFields.botInput>();
        PopulateBotFields.botInput input = new PopulateBotFields.botInput();
        input.lctid = newList[0].Id;
        input.proactive = 'Proactive';
        lstbotinput.add(input);

        List<PopulateBotFields.chatInfo> lstchatInfo = PopulateBotFields.getChatInfo(lstbotinput);
        String expectedStatus = 'www.maersk.com';
        //System.assertEquals(expectedStatus, lstchatInfo[0].BrandLink);
        Test.stopTest();
    }

}