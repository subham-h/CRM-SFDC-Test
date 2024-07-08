@isTest
public class EnhancedDownloadEM_Test {
    
    @isTest
    static void testgetBase64HTML(){
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        List<Case> lstCases = new List<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        Test.startTest();
        
        insert lstCases;
        EmailMessageData_Test.bCreate = false;
        EmailMessageData_Test.iNumberOfEmailMessages = 1;
        EmailMessageData_Test.createEmailMessage();
        List<EmailMessage> lstEM = new List<EmailMessage>();
        lstEM.addAll(EmailMessageData_Test.lstEmailMessages);
        for(EmailMessage em: lstEM){
            em.HTMLBody = '<div>test</div>';
            em.fromName='test';
            em.parentid = lstCases[0].id;
        }
        insert lstEM;
        Case parentCase =[SELECT Id, Description  FROM Case WHERE Id =:lstCases[0].id];
        EmailMessage em = [Select id,htmlbody,fromName,toaddress,subject from EmailMessage where parentid=:lstCases[0].id];
        system.debug('email message created'+em);
        String convertbase64= EncodingUtil.base64Encode(Blob.valueof(em.HtmlBody));
        List<EnhancedDownloadEM.WrapperEM> wrapper= new List<EnhancedDownloadEM.WrapperEM>();
        wrapper.add(EnhancedDownloadEM.getBase64HTML(em.id));
        Test.stopTest();
    }
    
}