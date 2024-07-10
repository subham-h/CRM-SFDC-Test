@istest
public class Email2CaseCustomHandler_test {  
    
    @testSetup
    static void setup() {
        List<Custom_Email_Service__c> eservicelist = new List<Custom_Email_Service__c>();
        Custom_Email_Service__c em = new Custom_Email_Service__c();
        em.BA_Address__c = 'testemailservice@maersk.com';
        em.Origin__c='MSLUSIMP';
        em.Queue_Id__c='00GD0000004FoNj';
        em.Service_Address__c='testemailservice@0-w9m230acs75ubo8tzlcdvy0varwhp0kqgio3wc0a2mui85ili.5r-4cc1eai.cs160.apex.sandbox.salesforce.com';
        em.Active__c=true;
        eservicelist.add(em);
        Custom_Email_Service__c em2 = new Custom_Email_Service__c();
        em2.BA_Address__c = 'testemailservice2@maersk.com';
        em2.Origin__c='MSLUSIMP';
        //em2.Queue_Id__c='00GD0000004FoNj';
        em2.Service_Address__c='testemailservice2@0-w9m230acs75ubo8tzlcdvy0varwhp0kqgio3wc0a2mui85ili.5r-4cc1eai.cs160.apex.sandbox.salesforce.com';
        em2.Active__c=true;
        eservicelist.add(em2);
        Custom_Email_Service__c em3 = new Custom_Email_Service__c();
        em3.BA_Address__c = 'testemailservice3@maersk.com';
        em3.Origin__c='MSLCHIMP';
        em3.Service_Address__c='testemailservice3@0-w9m230acs75ubo8tzlcdvy0varwhp0kqgio3wc0a2mui85ili.5r-4cc1eai.cs160.apex.sandbox.salesforce.com';
        em3.Active__c=true;
        em3.Remove_header_based_threading__c = true;
        eservicelist.add(em3);
        
        insert eservicelist;
    }
    
    static testMethod void TestinBoundEmail(){       
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        // intialize the list string to store emails.
        List<string> emails = new List<string>{'testemailservice@maersk.com'};      
            email.subject = 'Create case';
        email.fromAddress = 'someaddress@email.com';
        //assigning the emails to toAddresses 
        email.toAddresses = emails;
        email.plainTextBody = 'email body';
        email.htmlBody = 'email body';
        Messaging.InboundEmail.Header header= new Messaging.InboundEmail.Header();
        email.headers=new Messaging.InboundEmail.Header[1];
        header.name='Content-ID'; header.value='<ii_lmzx1el40>';
        email.headers[0]=header;
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        Messaging.InboundEmail.Header iheader = new Messaging.InboundEmail.Header();
        iheader.name='Content-ID'; 
        iheader.value='<ii_lmzx1el40>';
        attachment.headers = new Messaging.InboundEmail.Header[]{iheader};
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };  
            Messaging.InboundEmail.textAttachment txtAttachment = new Messaging.InboundEmail.textAttachment();
        txtAttachment.body = 'Sample text attachment';
        txtAttachment.fileName = 'textfileone.txt';
        txtAttachment.mimeTypeSubType = 'text/plain';
        email.textAttachments = new Messaging.inboundEmail.textAttachment[] { txtAttachment };  
        env.toAddress = 'testemailservice@0-w9m230acs75ubo8tzlcdvy0varwhp0kqgio3wc0a2mui85ili.5r-4cc1eai.cs160.apex.sandbox.salesforce.com';
        Email2CaseCustomHandler  testInbound = new Email2CaseCustomHandler();
        testInbound.handleInboundEmail(email, env);
        Test.startTest();
        Email2CaseCustomHandler  testInbound2 = new Email2CaseCustomHandler();        
        testInbound2.handleInboundEmail(email, env);
        Test.stopTest();
    }
    
    //Test Email clipping
    static testMethod void TestinBoundEmail2(){ 
        String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz';
        String randStr = '';
        while (randStr.length() < 150000) {
            randStr += chars;
        }
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        // intialize the list string to store emails.
        List<string> emails = new List<string>{'testemailservice2@maersk.com'};      
            email.subject = 'Create case';
        email.fromAddress = 'someaddress@email.com';
        //assigning the emails to toAddresses 
        email.toAddresses = emails;
        email.ccAddresses = emails;
        system.debug('randStr++'+randStr.length());
        email.plainTextBody = '';
        email.htmlBody = randStr;
        Messaging.InboundEmail.Header header= new Messaging.InboundEmail.Header();
        email.headers=new Messaging.InboundEmail.Header[1];
        header.name='Date'; header.value='test';
        email.headers[0]=header;
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };  
            Messaging.InboundEmail.textAttachment txtAttachment = new Messaging.InboundEmail.textAttachment();
        txtAttachment.body = 'Sample text attachment';
        txtAttachment.fileName = 'textfileone.txt';
        txtAttachment.mimeTypeSubType = 'text/plain';
        email.textAttachments = new Messaging.inboundEmail.textAttachment[] { txtAttachment };  
            env.toAddress = 'testemailservice2@0-w9m230acs75ubo8tzlcdvy0varwhp0kqgio3wc0a2mui85ili.5r-4cc1eai.cs160.apex.sandbox.salesforce.com';
        Test.startTest();
        Email2CaseCustomHandler  testInbound = new Email2CaseCustomHandler();
        testInbound.handleInboundEmail(email, env);
        Test.stopTest();
    }
    
    static testMethod void TestinBoundEmailUndelivered(){ 
        String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz';
        String randStr = '';
        while (randStr.length() < 150000) {
            randStr += chars;
        }
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        // intialize the list string to store emails.
        List<string> emails = new List<string>{'testemailservice@maersk.com'};      
            email.subject = 'undeliverable:ss';
        email.fromAddress = 'someaddress@email.com';
        //assigning the emails to toAddresses 
        email.toAddresses = emails;
        email.ccAddresses = emails;
        email.plainTextBody = randStr;
        email.htmlBody = randStr;
        Messaging.InboundEmail.Header header= new Messaging.InboundEmail.Header();
        email.headers=new Messaging.InboundEmail.Header[1];
        header.name='Date'; header.value='test';
        email.headers[0]=header;      
        env.toAddress = 'testemailservice@0-w9m230acs75ubo8tzlcdvy0varwhp0kqgio3wc0a2mui85ili.5r-4cc1eai.cs160.apex.sandbox.salesforce.com';
        Test.startTest();
        Email2CaseCustomHandler  testInbound = new Email2CaseCustomHandler();
        testInbound.handleInboundEmail(email, env);
        Test.stopTest();
    }
    
    static testMethod void TestHeaderBasedBypass(){       
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        // intialize the list string to store emails.
        List<string> emails = new List<string>{'testemailservice@maersk.com'};      
            email.subject = 'Create case';
        email.fromAddress = 'someaddress@email.com';
        //assigning the emails to toAddresses 
        email.toAddresses = emails;
        email.plainTextBody = 'email body';
        email.htmlBody = 'email body';
        Messaging.InboundEmail.Header header= new Messaging.InboundEmail.Header();
        email.headers=new Messaging.InboundEmail.Header[1];
        header.name='Content-ID'; header.value='<ii_lmzx1el40>';
        email.headers[0]=header;
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        Messaging.InboundEmail.Header iheader = new Messaging.InboundEmail.Header();
        iheader.name='Date'; iheader.value='test';
        attachment.headers = new Messaging.InboundEmail.Header[]{iheader};
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };  
            Messaging.InboundEmail.textAttachment txtAttachment = new Messaging.InboundEmail.textAttachment();
        txtAttachment.body = 'Sample text attachment';
        txtAttachment.fileName = 'textfileone.txt';
        txtAttachment.mimeTypeSubType = 'text/plain';
        email.textAttachments = new Messaging.inboundEmail.textAttachment[] { txtAttachment };  
        env.toAddress = 'testemailservice3@0-w9m230acs75ubo8tzlcdvy0varwhp0kqgio3wc0a2mui85ili.5r-4cc1eai.cs160.apex.sandbox.salesforce.com';
        Email2CaseCustomHandler  testInbound = new Email2CaseCustomHandler();
        testInbound.handleInboundEmail(email, env);
        Test.startTest();
        Email2CaseCustomHandler  testInbound2 = new Email2CaseCustomHandler();        
        testInbound2.handleInboundEmail(email, env);
        Test.stopTest();
    }
    
}