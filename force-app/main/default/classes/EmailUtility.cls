/*
* Author   : Ranjini@UST
* Purpose  : Utility class for sending Single Message Emails.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-006949   21-Sep-2017 Ranjini@UST             Created.
* 2.0      RQ-007489   05-Dec-2017 Nisha@UST               Auto-Closure Resolution Emails will never contain the indivudal signatures of Agents
* 3.0      RQ-008079   15-Mar-2018 Ranjini@ust             Commented one line of as this was cuasing issues in Dispute Site page.
*/

public class EmailUtility {
    
    private static map<String, Email_Rule__mdt> mapEmailRule = null;
    
    //Get the Email Rule details.
    public static Email_Rule__mdt getEmailRule(String strObject, String strType) {
        if(mapEmailRule == null || !mapEmailRule.containsKey(strObject + strType)) {
            mapEmailRule = new map<String, Email_Rule__mdt>();
            for(Email_Rule__mdt emailRule : [Select Id, Object__c, Type__c, Filters__c, Target_Object__c, Save_As_Activity__c, Do_Chatter_Post__c, Is_Active__c From Email_Rule__mdt]) {
                mapEmailRule.put(emailRule.Object__c + emailRule.Type__c, emailRule);
            }
        }
        return mapEmailRule.get(strObject + strType);
    }
    
    //Sends the email and if specified in the EmailRule post chatter for the successfully sent emails.
    public static void sendEmails(EmailWrapper mailWrapper) {
        try{
            Map<String, Email_Template_Mapping__mdt> mapEmailTemplates = EmailTemplateMappingUtility.getEmailTemplateMapping(mailWrapper.strObject, mailWrapper.strType);
            List<Id> lstIds = new List<Id>();
            list<EmailWrapper.EmailDetail> lstEmailDetails = new list<EmailWrapper.EmailDetail>();
            list<Messaging.SingleEmailMessage> lstEmailMessages = new list<Messaging.SingleEmailMessage>();
            Map<Id, String> mapChatterPostContent = new Map<Id, String>();
            List<String> toAddList = new List<String>();
            
            //SC-7154
            Set<Id> caseIdSet = new Set<Id>();
            for(EmailWrapper.EmailDetail emailDetail : mailWrapper.lstEmailDetails) {
                caseIdSet.add(emailDetail.sObj.Id);
            }
            Map<Id, Case> caseMap = new Map<Id, Case>();
            if(!caseIdSet.isEmpty()){
                caseMap = new Map<Id, Case>([Select Id, ContactId, Contact.Email, Closure_Content_Document_Ids__c, Multiple_Recipients__c, Additional_Resolution_Summary__c From Case Where Id =: caseIdSet]);
            }
            
            for(EmailWrapper.EmailDetail emailDetail : mailWrapper.lstEmailDetails) {
                emailDetail.mailStatus = EmailWrapper.EmailStatus.TEMPLATE_NOT_FOUND;                
                for(String filter : emailDetail.lstFilterValues) {
                    if(mapEmailTemplates.containsKey(filter)) {
                        emailDetail.mailStatus = EmailWrapper.EmailStatus.TEMPLATE_FOUND;                   
                        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
                        Id templateId = mapEmailTemplates.get(filter).Email_Template_Id__c;
                        Case cs = (Case)emailDetail.sObj;
                        Case newCs = new Case();
                        newCs.Id = cs.Id;
                        newCs.Send_to_Contact__c = true;
                        newCs.ContactId = cs.ContactId;
                        TriggerExecutionController.skipCaseTrigger(true);
                        update newCs;
                        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, newCs.ContactId, newCs.Id);
                        emailMessage.setSubject(email.getSubject());
                        List<String> toAddressList = new List<String>();
                        if(!caseMap.isEmpty() && caseMap.containsKey(cs.Id)){                            
                            if(!String.isEmpty(caseMap.get(cs.Id).Contact.Email)){
                                toAddressList.add(caseMap.get(cs.Id).Contact.Email);
                            }
                            if(!String.isEmpty(caseMap.get(cs.Id).Multiple_Recipients__c)){
                                toAddList.addAll(caseMap.get(cs.Id).Multiple_Recipients__c.replaceAll(' ', '').replaceAll(';', ',').split(','));
                            }
                            if(!String.isEmpty(caseMap.get(cs.Id).Closure_Content_Document_Ids__c)){
                                List<Id> cvIds = new List<Id>();
                                List<Id> docIds = new List<Id>();
                                List<DocumentWrapper> docWrapList = (List<DocumentWrapper>)JSON.deserialize(caseMap.get(cs.Id).Closure_Content_Document_Ids__c, List<DocumentWrapper>.class);
                                if(!docWrapList.isEmpty()){
                                    for(DocumentWrapper doc : docWrapList){
                                        cvIds.add(doc.contentVersionId);
                                        docIds.add(doc.documentId);
                                    }
                                    if(!cvIds.isEmpty()){
                                        emailMessage.setEntityAttachments(cvIds);
                                    }
                                }
                            }
                        }
                        emailMessage.setToAddresses(toAddressList);
                        emailMessage.setHtmlBody(email.getHtmlBody());
                        emailMessage.setWhatId(emailDetail.sObj.Id);
                        emailMessage.setSaveAsActivity(mailWrapper.bSaveAsActivity);
                        emailMessage.setUseSignature(false); // #RQ-007489
                        if(emailDetail.idOrgWideEmailAddress != null) {
                            emailMessage.setOrgWideEmailAddressId(emailDetail.idOrgWideEmailAddress);
                        }
                        system.debug('****emailDetail.idOrgWideEmailAddress--->'+emailDetail.idOrgWideEmailAddress);
                        if(emailDetail.strReplyToAddress != null) {
                            emailMessage.setReplyTo(emailDetail.strReplyToAddress);
                        }
                        
                        //To populate the email template name in the chatter post body for each case record.
                        mapChatterPostContent.put(emailDetail.sObj.Id, emailDetail.strChatterContent.replace('{Email Template Name}',mapEmailTemplates.get(filter).Email_Template__c));                        
                        lstEmailMessages.add(emailMessage);
                        lstEmailDetails.add(emailDetail); 
                        break;
                    }
                }
            }
            system.debug('****lstEmailMessages '+lstEmailMessages);
            if(!lstEmailMessages.isEmpty()) {                
                list<Messaging.SendEmailResult> lstEmailResults = Messaging.sendEmail(lstEmailMessages);                
                for(Integer i=0; i<lstEmailResults.size(); i++) {
                    Messaging.SendEmailResult emailResult = lstEmailResults[i];
                    EmailWrapper.EmailDetail emailDetail = lstEmailDetails[i];
                    if(emailResult.isSuccess()) {
                        system.debug('****in success');
                        emailDetail.mailStatus = EmailWrapper.EmailStatus.SUCCESS;
                        if(mailWrapper.bDoChatterPost)
                            lstIds.add(emailDetail.sObj.Id);
                    }
                    else {
                        emailDetail.mailStatus = EmailWrapper.EmailStatus.FAILED;
                        emailDetail.lstSendEmailErrors = emailResult.getErrors();
                    }
                }
                
                //Chatter posts for the cases for which the emails are sent successfully.
                if(lstIds.size() > 0 && mailWrapper.bDoChatterPost){
                    List<FeedItem> post = new List<FeedItem>();
                    for(Id objId : lstIds){
                        FeedItem postObj = new FeedItem();
                        //postObj.createdById = UserInfo.getUserId();//#RQ-008079.Commenting this line as this was cuasing issues in Dispute Site page.
                        postObj.Body = mapChatterPostContent.get(objId);
                        postObj.ParentId = objId;
                        post.add(postObj);
                    }
                    ChatterPostUtilities.doChatterPost(post,'CaseChatterPostUtility');                    
                }
            }
            TriggerExecutionController.skipCaseTrigger(false);
            //send email to additional owners
            if(!toAddList.isEmpty()){
                sendEmailToAdditionalOwners(mailWrapper, mapEmailTemplates, caseMap);
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Email', 'EmailUtility.sendEmails(EmailWrapper mailWrapper)', new list<Exception>{ex}); 
        }
    }
    
    public static void sendEmailToAdditionalOwners(EmailWrapper mailWrapper, Map<String, Email_Template_Mapping__mdt> mapEmailTemplates, Map<Id, Case> caseMap){
        List<Id> lstIds = new List<Id>();
        list<EmailWrapper.EmailDetail> lstEmailDetails = new list<EmailWrapper.EmailDetail>();
        list<Messaging.SingleEmailMessage> lstEmailMessages = new list<Messaging.SingleEmailMessage>();
        
        for(EmailWrapper.EmailDetail emailDetail : mailWrapper.lstEmailDetails) {
            emailDetail.mailStatus = EmailWrapper.EmailStatus.TEMPLATE_NOT_FOUND;                
            for(String filter : emailDetail.lstFilterValues) {
                if(mapEmailTemplates.containsKey(filter)) {
                    emailDetail.mailStatus = EmailWrapper.EmailStatus.TEMPLATE_FOUND;                   
                    Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
                    Id templateId = mapEmailTemplates.get(filter).Email_Template_Id__c;
                    Case cs = (Case)emailDetail.sObj;
                    Case newCs = new Case();
                    newCs.Id = cs.Id;
                    newCs.Send_to_Contact__c = false;
                    newCs.ContactId = cs.ContactId;
                    TriggerExecutionController.skipCaseTrigger(true);
                    update newCs;
                    Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, cs.ContactId, cs.Id);
                    emailMessage.setSubject(email.getSubject());
                    List<String> toAddressList = new List<String>();
                    if(!caseMap.isEmpty() && caseMap.containsKey(cs.Id)){                            
                        if(!String.isEmpty(caseMap.get(cs.Id).Multiple_Recipients__c)){
                            toAddressList.addAll(caseMap.get(cs.Id).Multiple_Recipients__c.replaceAll(' ', '').replaceAll(';', ',').split(','));
                        }
                        if(!String.isEmpty(caseMap.get(cs.Id).Closure_Content_Document_Ids__c)){
                            List<Id> cvIds = new List<Id>();
                            List<Id> docIds = new List<Id>();
                            List<DocumentWrapper> docWrapList = (List<DocumentWrapper>)JSON.deserialize(caseMap.get(cs.Id).Closure_Content_Document_Ids__c, List<DocumentWrapper>.class);
                            if(!docWrapList.isEmpty()){
                                for(DocumentWrapper doc : docWrapList){
                                    cvIds.add(doc.contentVersionId);
                                    docIds.add(doc.documentId);
                                }
                                if(!cvIds.isEmpty()){
                                    emailMessage.setEntityAttachments(cvIds);
                                }
                            }
                        }
                    }
                    emailMessage.setToAddresses(toAddressList);
                    emailMessage.setHtmlBody(email.getHtmlBody());
                    emailMessage.setWhatId(emailDetail.sObj.Id);
                    emailMessage.setSaveAsActivity(mailWrapper.bSaveAsActivity);
                    emailMessage.setUseSignature(false); // #RQ-007489
                    if(emailDetail.idOrgWideEmailAddress != null) {
                        emailMessage.setOrgWideEmailAddressId(emailDetail.idOrgWideEmailAddress);
                    }
                    if(emailDetail.strReplyToAddress != null) {
                        emailMessage.setReplyTo(emailDetail.strReplyToAddress);
                    }
                    lstEmailMessages.add(emailMessage);
                    lstEmailDetails.add(emailDetail);  
                    break;
                }
            }
        }
        system.debug('****lstEmailMessages '+lstEmailMessages);
        if(!lstEmailMessages.isEmpty()) {                
            list<Messaging.SendEmailResult> lstEmailResults = Messaging.sendEmail(lstEmailMessages);                
            for(Integer i=0; i<lstEmailResults.size(); i++) {
                Messaging.SendEmailResult emailResult = lstEmailResults[i];
                EmailWrapper.EmailDetail emailDetail = lstEmailDetails[i];
                if(emailResult.isSuccess()) {
                    system.debug('****in success');
                    emailDetail.mailStatus = EmailWrapper.EmailStatus.SUCCESS;
                    if(mailWrapper.bDoChatterPost)
                        lstIds.add(emailDetail.sObj.Id);
                }
                else {
                    emailDetail.mailStatus = EmailWrapper.EmailStatus.FAILED;
                    emailDetail.lstSendEmailErrors = emailResult.getErrors();
                }
            }
        }
        TriggerExecutionController.skipCaseTrigger(false);
    }
    
    public class DocumentWrapper {
        public String name;
        public String documentId;
        public String contentVersionId;
        public String contentBodyId;
        public String mimeType;
    }
    
}