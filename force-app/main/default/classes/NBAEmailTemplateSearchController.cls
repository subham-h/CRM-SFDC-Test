public class NBAEmailTemplateSearchController {
    
    @AuraEnabled
    public static List<EmailTemplate> getFoldersAndTemplates(){
        Map<String, List<EmailTemplate>> folderToTemplateList = new Map<String, List<EmailTemplate>>();
        List<String> folderNames = new List<String>();
        List<EmailTemplate> emTemplateList = new List<EmailTemplate>();
        for(General_Key_Value_Configurations__mdt gen : [Select id, First_Field_Name__c, First_Field_Value__c From General_Key_Value_Configurations__mdt Where Key__c = 'NBA Folder Names']){
            folderNames.add(gen.First_Field_Value__c);
        }
        
        if(!folderNames.isEmpty()){
            if(Test.isRunningTest()){
                emTemplateList = [Select Id, Name, Description, DeveloperName, FolderId, Folder.Name, Folder.developername From EmailTemplate Where Folder.developername  IN: folderNames LIMIT 10];
            }
            else {
                emTemplateList = [Select Id, Name, Description, DeveloperName, FolderId, Folder.Name, Folder.developername From EmailTemplate Where Folder.developername  IN: folderNames];
            }
        }
        return emTemplateList ;
    }
    
    @AuraEnabled(cacheable=true)
    public static TemplateWrapper getEmailBody(String caseId, String developername){
        TemplateWrapper tempWrap = new TemplateWrapper();
        List<EmailMessage> emMsgList = new List<EmailMessage>();
        List<EmailMessage> latestEmailMessage = new List<EmailMessage>();
        try{
            emMsgList = [Select id, HtmlBody, FromName, FromAddress, CreatedDate, ToAddress, CcAddress, Subject From EmailMessage Where ParentId =: caseId AND Incoming = true Order By CreatedDate DESC LIMIT 1];
            latestEmailMessage = [Select id, HtmlBody, FromName, FromAddress, CreatedDate, ToAddress, CcAddress, Subject From EmailMessage Where ParentId =: caseId Order By CreatedDate DESC LIMIT 1];
            EmailTemplate emTemplate = [Select Id, DeveloperName, HtmlValue, Subject From EmailTemplate Where DeveloperName =: developername];
            User curUsr = [Select Id, Signature, Email From User Where Id =: UserInfo.getUserId()];
            Case cs = [select id, Liner_Brand__c, Case_Country__c, Case_Cluster__c, Region__r.Name, ContactId, Contact.Name, Contact.Email, closure_language_code__c from case where id =: caseId];
            
            if(emTemplate != null){
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emTemplate.Id, cs.ContactId, cs.Id);
                emTemplate.Subject = email.getSubject();
                emTemplate.HtmlValue = email.getHtmlBody().replaceAll('<table border="0">','').replaceAll('</table>', '');
                 if(curUsr != null && !String.isEmpty(curUsr.Signature)){
                    emTemplate.HtmlValue += '<br/><font face="verdana">'+curUsr.Signature.replaceAll('\n', '<br/>')+'</font>';
                }
                if(!emMsgList.isEmpty() && !latestEmailMessage.isEmpty()){
                    emTemplate.HtmlValue += '<br/><br/><font face="verdana">'+
                        '--------------- Original Message ---------------<br/>'+
                        '<b>From: </b>'+emMsgList[0].FromName +' ['+emMsgList[0].FromAddress+']<br/>'+
                        '<b>Sent: </b>'+emMsgList[0].CreatedDate +'<br/>'+
                        '<b>To: </b>'+emMsgList[0].toAddress +'<br/>'+
                        '<b>Subject: </b>'+emMsgList[0].Subject +'<br/>'+
                        latestEmailMessage[0].HtmlBody+
                        '</font>';
                }
            }
            tempWrap.subject = emTemplate.Subject;
            tempWrap.emailBody = emTemplate.HtmlValue;
            tempWrap.status = true;
        }catch(Exception e){
            tempWrap.status = false;
            tempWrap.message = e.getMessage()+'. '+General_Key_Value_Configurations__mdt.getInstance('NBA_Error_Message1').Second_Field_Value__c;
        }
        return tempWrap;
    }
    
    public class TemplateWrapper{
        @AuraEnabled
        public String subject;
        @AuraEnabled
        public String emailBody;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public Boolean status;
    }
}