/*
 * Author   : Nisha
 * Purpose  : Utility test class for creating EmailMessage related data. 
 *
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-004464   04-Nov-2016 Nisha@UST                Created.
 * 
 */

@isTest
public class EmailMessageData_Test {
    
    public static boolean bCreate = true;
    public static integer iNumberOfEmailMessages = 5;
    public static list< EmailMessage> lstEmailMessages = new list<EmailMessage>();
    
    public static integer iNumberOfAttachments = 5;
    public static list<Attachment> lstAttachments;
    
    // Use this caseInstance, emailMessageInstance if you have already created a Case or EmailMessage.
    public static Case caseInstance = null;
    public static EmailMessage emailMessageInstance = null;
    
    public static testMethod void createEmailMessage() {
        if(caseInstance == null) {
            CaseData_Test.iNumberOfCases = 1;
            CaseData_Test.createExternalCases();
            caseInstance = CaseData_Test.lstCases[0];
            System.debug('#####EmailTestData caseInstance'+caseInstance);
        }
        
        lstEmailMessages = new list<EmailMessage>();
        for(integer i=0; i<iNumberOfEmailMessages; i++){
            EmailMessage emailMssg = new EmailMessage();
            emailMssg.fromaddress = 'Test@maersk.com';
            emailMssg.incoming = true;
            emailMssg.toaddress = 'test1@test.com';
            emailMssg.subject = 'Test Email';
            emailMssg.textbody = 'testing';
            emailMssg.Subject = 'testing';
            emailMssg.parentid = caseInstance.Id;
            lstEmailMessages.add(emailMssg);
        }
        
        if(bCreate) {
            insert lstEmailMessages;
        }
        }
    
    public static testMethod void addAttachment (){  
        if(lstEmailMessages.isEmpty()){
            EmailMessageData_Test.iNumberOfEmailMessages = 5;
            EmailMessageData_Test.createEmailMessage();
            emailMessageInstance = EmailMessageData_Test.lstEmailMessages[0];
        }
        
        lstAttachments = new list<Attachment>();
        for(integer i=0; i<iNumberOfAttachments; i++){     
            Attachment attach = new Attachment();
            attach.Body = Blob.valueOf( 'test data ' );
            attach.Name = 'Test Attachement';
            attach.ContentType = 'img';
            attach.ParentId = emailMessageInstance.Id; 
            lstAttachments.add(attach);
        }
        
        if(bCreate) {
            insert lstAttachments;
        }   
    }
    
}