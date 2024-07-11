public class NBAEmailController {
    
    @AuraEnabled(cacheable=true)
    public static EmailWrapper getEmailTemplate(String caseId, String recomId){
        List<NBA_Action_Map__c> recomList = new List<NBA_Action_Map__c>();
        List<EmailMessage> emMsgList = new List<EmailMessage>();
        List<EmailMessage> latestEmailMessage = new List<EmailMessage>();
        EmailWrapper emailWrap = new EmailWrapper();
        List<EmailMessage> allIncomingEmailsRelToCase = new List<EmailMessage>();
        String fromAddressFirstEmail;
        
        try{
            system.debug('recomId###'+recomId);
            //recomList = [Select Id, Name, AcceptanceLabel, RejectionLabel From Recommendation Where Id =: recomId];
            recomList = [SELECT Id,Actions__c,Email_Template__c,Recommendation_Name__c from NBA_Action_Map__c where Recommendation_Id__c =: recomId and Actions__c includes ('Send an Email')];
            system.debug('recomList ##'+recomList );
            Case cs = [select id, Liner_Brand__c, Case_Country__c, Case_Cluster__c, Region__r.Name, ContactId, Contact.Name, Contact.Email,SuppliedEmail,resolution_summary__c, closure_language_code__c from case where id =: caseId];
            Org_Wide_Email_Address__mdt[] orgwideDataList = [Select DeveloperName, MasterLabel, Email_Address__c, Email_Address_Id__c From Org_Wide_Email_Address__mdt Where MasterLabel =: cs.Liner_Brand__c];
            allIncomingEmailsRelToCase = [Select id, HtmlBody, FromName, FromAddress, CreatedDate, ToAddress, CcAddress, Subject From EmailMessage Where ParentId =: caseId AND Incoming = true Order By CreatedDate DESC];
            //SC-8299
            if(allIncomingEmailsRelToCase <> NULL && !allIncomingEmailsRelToCase.isEmpty()){
                emMsgList = new List<EmailMessage> {allIncomingEmailsRelToCase[0]};
                
                List<String> mailFromList = new List<String>();
                if(!String.IsEmpty(allIncomingEmailsRelToCase[allIncomingEmailsRelToCase.size()-1].ToAddress)) {
                    mailFromList = allIncomingEmailsRelToCase[allIncomingEmailsRelToCase.size()-1].ToAddress.trim().replace(' ','').split(';');
                }
                
                OrgWideEmailAddress[] orgList;
                if(!mailFromList.isEmpty()){
                     orgList= [Select id, Address, DisplayName from OrgWideEmailAddress WHERE Address in :mailFromList];
                }
                
                if(!orgList.isEmpty()){
                    for(OrgWideEmailAddress org : orgList){
                        if(fromAddressFirstEmail == null || String.isBlank(fromAddressFirstEmail)){
                                fromAddressFirstEmail = org.Address; 
                        } else {
                                fromAddressFirstEmail = fromAddressFirstEmail+','+org.Address;
                    	}
                	}
                } 
            }
            
            if(fromAddressFirstEmail == null || String.isBlank(fromAddressFirstEmail)){
                fromAddressFirstEmail = orgwideDataList[0].Email_Address__c;
            }
            system.debug('fromAddressFirstEmail ##'+fromAddressFirstEmail);
            latestEmailMessage = [Select id, HtmlBody, FromName, FromAddress, CreatedDate, ToAddress, CcAddress, Subject From EmailMessage Where ParentId =: caseId Order By CreatedDate DESC LIMIT 1];
            User curUsr = [Select Id, Signature, Email From User Where Id =: UserInfo.getUserId()];
            //Get mapped email template
            EmailTemplate emTemplate = searchEmailTemplate(recomList, cs);
            if(emTemplate != null){
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emTemplate.Id, cs.ContactId, cs.Id);
                emTemplate.Subject = email.getSubject();
                emTemplate.HtmlValue = email.getHtmlBody().replaceAll('<table border="0">','').replaceAll('</table>', '');               
                if(!emMsgList.isEmpty() && !latestEmailMessage.isEmpty()){
                    emTemplate.HtmlValue += '<br/><br/><font face="sans-serif">'+
                        curUsr.Signature+'<br/>'+
                        '</font>'+
                        '<br/><br/><font face="verdana">'+
                        '--------------- Original Message ---------------<br/>'+
                        '<b>From: </b>'+emMsgList[0].FromName +' ['+emMsgList[0].FromAddress+']<br/>'+
                        '<b>Sent: </b>'+emMsgList[0].CreatedDate +'<br/>'+
                        '<b>To: </b>'+emMsgList[0].toAddress +'<br/>'+
                        '<b>Subject: </b>'+emMsgList[0].Subject +'<br/>'+
                        latestEmailMessage[0].HtmlBody+
                        '</font>';
                }
                
                emailWrap.showTemplate = true;
                emailWrap.template = emTemplate;
                emailWrap.caseRecord = cs;
                //SC-8299
                emailWrap.fromAddress = fromAddressFirstEmail;
                String toEmailAddress = cs != NULL && !String.isEmpty(cs.Contact.Email) ? cs.Contact.Email : cs.SuppliedEmail;
                emailWrap.toAddress = (!emMsgList.isEmpty() && !String.isEmpty(emMsgList[0].FromAddress)) ? emMsgList[0].FromAddress.replaceAll(';', ',') : toEmailAddress;
                List<String> ccAddresses = new List<String>();
                if(!emMsgList.isEmpty() && !String.isEmpty(emMsgList[0].CcAddress)){
                    ccAddresses.addAll(emMsgList[0].CcAddress.split(';'));
                }
                if(!ccAddresses.isEmpty()){
                    emailWrap.ccAddress = String.join(ccAddresses, ',');
                }
            }
            else{
                emailWrap.showTemplate = false;
                emailWrap.message = General_Key_Value_Configurations__mdt.getInstance('NBA_Error_Message1').First_Field_Value__c;
            }
        }catch(Exception e){
            ErrorLogger.writeErrors( 'SFDC', 'NBA', 'NBAEmailController.getEmailTemplate', new list<Exception>{e});  
            emailWrap.showTemplate = false;
            emailWrap.message = e.getMessage()+'. '+General_Key_Value_Configurations__mdt.getInstance('NBA_Error_Message1').Second_Field_Value__c;
        }
        return emailWrap;
    }
    
    public static EmailTemplate searchEmailTemplate(List<NBA_Action_Map__c> recomList, Case cs){
        EmailTemplate emTemplate;
        Map<String, NBA_Email_Template_Mapping__mdt> nbaTemplateMap = new Map<String, NBA_Email_Template_Mapping__mdt>();
        String emailTemplateName = '';
        system.debug('Inside Search Email Template');
        try{
            if(recomList.size() > 0){
                if(recomList[0].Email_Template__c == null){
                    for(NBA_Email_Template_Mapping__mdt nbaMapping : [SELECT Brand__c,Cluster__c,Country__c,Region__c,Email_Template_Unique_Name__c from NBA_Email_Template_Mapping__mdt where Recommendation__c =: recomList[0].Recommendation_Name__c AND Brand__c =: cs.Liner_Brand__c AND Is_Resolution_Summary_Template__c = false]){
                        String key = (!String.isEmpty(nbaMapping.Brand__c) ? nbaMapping.Brand__c : '') + (!String.isEmpty(nbaMapping.Region__c) ? nbaMapping.Region__c : '') + 
                            (!String.isEmpty(nbaMapping.Cluster__c) ? nbaMapping.Cluster__c : '') + (!String.isEmpty(nbaMapping.Country__c) ? nbaMapping.Country__c : '');
                        nbaTemplateMap.put(key, nbaMapping);
                    }
                    if(!nbaTemplateMap.isEmpty()){
                        if(nbaTemplateMap.containsKey((!String.isEmpty(cs.Liner_Brand__c) ? cs.Liner_Brand__c : '') + (!String.isEmpty(cs.Region__c) ? cs.Region__r.Name : '') + 
                                                      (!String.isEmpty(cs.Case_Cluster__c) ? cs.Case_Cluster__c : '') + (!String.isEmpty(cs.Case_Country__c) ? cs.Case_Country__c : ''))){
                                                          emailTemplateName = nbaTemplateMap.get((!String.isEmpty(cs.Liner_Brand__c) ? cs.Liner_Brand__c : '') + (!String.isEmpty(cs.Region__c) ? cs.Region__r.Name : '') + 
                                                                                                 (!String.isEmpty(cs.Case_Cluster__c) ? cs.Case_Cluster__c : '') + (!String.isEmpty(cs.Case_Country__c) ? cs.Case_Country__c : '')).Email_Template_Unique_Name__c;
                                                      }
                        else if(nbaTemplateMap.containsKey((!String.isEmpty(cs.Liner_Brand__c) ? cs.Liner_Brand__c : '') + (!String.isEmpty(cs.Region__c) ? cs.Region__r.Name : '') + 
                                                           (!String.isEmpty(cs.Case_Cluster__c) ? cs.Case_Cluster__c : ''))){
                                                               emailTemplateName = nbaTemplateMap.get((!String.isEmpty(cs.Liner_Brand__c) ? cs.Liner_Brand__c : '') + (!String.isEmpty(cs.Region__c) ? cs.Region__r.Name : '') + 
                                                                                                      (!String.isEmpty(cs.Case_Cluster__c) ? cs.Case_Cluster__c : '')).Email_Template_Unique_Name__c;
                                                           }
                        else if(nbaTemplateMap.containsKey((!String.isEmpty(cs.Liner_Brand__c) ? cs.Liner_Brand__c : '') + (!String.isEmpty(cs.Region__c) ? cs.Region__r.Name : '') + 
                                                           (!String.isEmpty(cs.Case_Country__c) ? cs.Case_Country__c : ''))){
                                                               emailTemplateName = nbaTemplateMap.get((!String.isEmpty(cs.Liner_Brand__c) ? cs.Liner_Brand__c : '') + (!String.isEmpty(cs.Region__c) ? cs.Region__r.Name : '') + 
                                                                                                      (!String.isEmpty(cs.Case_Country__c) ? cs.Case_Country__c : '')).Email_Template_Unique_Name__c;
                                                           }
                        else if(nbaTemplateMap.containsKey((!String.isEmpty(cs.Liner_Brand__c) ? cs.Liner_Brand__c : '') + (!String.isEmpty(cs.Region__c) ? cs.Region__r.Name : ''))){
                            emailTemplateName = nbaTemplateMap.get((!String.isEmpty(cs.Liner_Brand__c) ? cs.Liner_Brand__c : '') + (!String.isEmpty(cs.Region__c) ? cs.Region__r.Name : '')).Email_Template_Unique_Name__c;
                        }
                        else if(nbaTemplateMap.containsKey((!String.isEmpty(cs.Liner_Brand__c) ? cs.Liner_Brand__c : '') + (!String.isEmpty(cs.Case_Country__c) ? cs.Case_Country__c : ''))){
                            emailTemplateName = nbaTemplateMap.get((!String.isEmpty(cs.Liner_Brand__c) ? cs.Liner_Brand__c : '') + (!String.isEmpty(cs.Case_Country__c) ? cs.Case_Country__c : '')).Email_Template_Unique_Name__c;
                        }
                        else if(nbaTemplateMap.containsKey(!String.isEmpty(cs.Liner_Brand__c) ? cs.Liner_Brand__c : '')){
                            emailTemplateName = nbaTemplateMap.get(!String.isEmpty(cs.Liner_Brand__c) ? cs.Liner_Brand__c : '').Email_Template_Unique_Name__c;
                        }
                    }
                } else {
                    emailTemplateName = recomList[0].Email_Template__c;
                }
            }
            
            
            if(!String.isEmpty(emailTemplateName)){
                emTemplate = [Select Id, DeveloperName, HtmlValue, Subject, Body From EmailTemplate Where DeveloperName =: emailTemplateName];
            } 
        }catch(Exception e){
            ErrorLogger.writeErrors( 'SFDC', 'NBA', 'NBAEmailController.searchEmailTemplate', new list<Exception>{e});
        }
        
        return emTemplate;
    }
    
    @AuraEnabled
    public static EmailWrapper sendEmail(String caseId, String payload){
        List<Id> documentIdList = new List<Id>();   
        List<Id> cvIds = new List<Id>();
        String[] toEmails = new List<String>();
        String[] ccEmails = new List<String>();
        String fromEmailAddress;
        EmailWrapper emailWrap = new EmailWrapper();
        List<EmailMessage> emMsgList = new List<EmailMessage>();
        List<Org_Wide_Email_Address__mdt> orgwideDataList = new List<Org_Wide_Email_Address__mdt>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<OrgWideEmailAddress> orgWideAddList = new List<OrgWideEmailAddress>();
        List<ContentDocumentLink> clListToDelete = new List<ContentDocumentLink>();
        
        try{
            Case cs = [select id, Subject, ContactId, Liner_Brand__c from case where id =: caseId];
            emMsgList = [Select id, HtmlBody, FromName, FromAddress, ToAddress, CreatedDate, Subject From EmailMessage Where ParentId =: caseId AND Incoming = true Order By CreatedDate ASC LIMIT 1];
            orgwideDataList = [Select DeveloperName, MasterLabel, Email_Address__c, Email_Address_Id__c From Org_Wide_Email_Address__mdt Where MasterLabel =: cs.Liner_Brand__c];
            
            EmailContent emailContent = (EmailContent) JSON.deserialize(payload, EmailContent.class);
            if(emailContent != null){
                if(!emailContent.selectedEmailList.isEmpty()){
                    for(String eml : emailContent.selectedEmailList){
                        if(!String.isEmpty(eml) && (toEmails.isEmpty() || !toEmails.contains(eml.trim()))){
                            toEmails.add(eml.trim());
                        }
                    }
                }
                if(!String.isEmpty(emailContent.to)){
                    for(String eml : emailContent.to.split(',')){
                        if(!String.isEmpty(eml) && (toEmails.isEmpty() || !toEmails.contains(eml.trim()))){
                            toEmails.add(eml.trim());
                        }
                    }
                }
                if(!String.isEmpty(emailContent.cc)){
                    for(String eml : emailContent.cc.split(',')){
                        if(!String.isEmpty(eml) && (ccEmails.isEmpty() || !ccEmails.contains(eml.trim()))){
                            ccEmails.add(eml.trim());
                        }
                    }
                }
                //SC-8299
                system.debug('emailContent.fromaddress===='+emailContent.fromaddress);
                if(!String.isEmpty(emailContent.fromaddress)){
                    fromEmailAddress=emailContent.fromaddress;    
                            if(String.isNotEmpty(fromEmailAddress) && String.isNotBlank(fromEmailAddress)){
                        orgWideAddList = [Select id, Address, DisplayName from OrgWideEmailAddress WHERE Address =: fromEmailAddress limit 1];
                    }
                }
            }
            
            if(!String.isEmpty(emailContent.docIds)) {
                for(String str : emailContent.docIds.split(',')){
                    documentIdList.add(Id.Valueof(str));
                }
            }
            
            for(Contentversion file: [SELECT title,PathOnClient, FileType,versiondata FROM contentversion WHERE ContentDocumentId IN: documentIdList]){
                cvIds.add(file.Id);
            }
            
            if(!orgWideAddList.isEmpty()){
                email.setOrgWideEmailAddressId(orgWideAddList[0].Id);
            }
            else if(!orgwideDataList.isEmpty()){
                email.setOrgWideEmailAddressId(orgwideDataList[0].Email_Address_Id__c);
            }
            email.setSubject(emailContent.subject);
            email.setToAddresses(toEmails);
            if(!ccEmails.isEmpty()){
                email.setCcAddresses(ccEmails);
            }
            email.setHtmlBody(emailContent.bodyHTML);
            if(!cvIds.isEmpty()){
                email.setEntityAttachments(cvIds);
            }
            email.setWhatId(cs.Id);
            email.setUseSignature(false);
            System.debug('email----'+email);
            Messaging.SendEmailResult [] emailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            for(Messaging.SendEmailResult mr : emailResult){
                if(mr.isSuccess()){
                    EmailMessage emailMsg = [Select Id From EmailMessage Where ParentId =: cs.Id Order By CreatedDate DESC LIMIT 1];
                    //Linking content document to email
                    if(!documentIdList.isEmpty()){
                        //deleting the contentdocumentlink of case
                        clListToDelete = [Select Id From ContentDocumentLink Where LinkedEntityId =: cs.Id AND ContentDocumentId IN: documentIdList];
                        if(!clListToDelete.isEmpty()){
                            delete clListToDelete;
                        }
                    }
                    emailWrap.emailSent = true;
                    emailWrap.message = General_Key_Value_Configurations__mdt.getInstance('NBA_Error_Message2').First_Field_Value__c;
                    // @SC-5061 | Update recommendation_acceptance__c to Accepted and Email Sent on Successful email snet. - Commenting as Case Recommendations, Action Status gets updated via flow.
                    //cs.Recommendation_Acceptance__c = General_Key_Value_Configurations__mdt.getInstance('Recommendation_Acceptance_Picklist').First_Field_Value__c;
                    update cs;
                }
                else{
                    emailWrap.emailSent = false;
                    emailWrap.message = General_Key_Value_Configurations__mdt.getInstance('NBA_Error_Message2').Second_Field_Value__c+' '+General_Key_Value_Configurations__mdt.getInstance('NBA_Error_Message1').Second_Field_Value__c;
                }
            }
            return emailWrap;
        }catch(Exception e){
            ErrorLogger.writeErrors( 'SFDC', 'NBA', 'NBAEmailController.sendEmail', new list<Exception>{e});
            emailWrap.emailSent = false;
            emailWrap.message = e.getMessage()+'. '+General_Key_Value_Configurations__mdt.getInstance('NBA_Error_Message1').Second_Field_Value__c;
            return emailWrap;
        }
    }
    
    public class EmailWrapper{
        @AuraEnabled
        public Boolean showTemplate;
        @AuraEnabled
        public EmailTemplate template;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String toAddress;
        @AuraEnabled
        public String ccAddress;
        @AuraEnabled
        public Boolean emailSent;
        @AuraEnabled
        public Case caseRecord; 
        @AuraEnabled
        public String fromAddress;
    }
    
    public class EmailContent {
        @AuraEnabled
        public String to;
        @AuraEnabled
        public String cc;
        @AuraEnabled
        public String subject;
        @AuraEnabled
        public String bodyHTML;
        @AuraEnabled
        public String docIds;
        @AuraEnabled
        public String fromaddress;
        @AuraEnabled
        public List<String> selectedEmailList;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getEmailBA() {
        System.debug('***getEmailBA');
        Map<String,String> mapBA = new Map<String,String>();
        try{        
            for(OrgWideEmailAddress owa : [Select Address from OrgWideEmailAddress]){
                mapBA.put(owa.Address,owa.Address);
            }
            return mapBA;
        } catch (exception e) {           
            System.debug('***exception'+e.getMessage()+'--'+e.getLineNumber());
            return null;
        }
    }
    
}