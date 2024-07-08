/*
* Controller for sending emails from  ProActive Email communication.
* 
*Version    Date           Owner                                      RQ#           Description
*********************************************************************************************************************************  
1.0       7/9/2021    ramadevi.palaniswamy@ust-global.com        #sc-2675      Code created.
2.0       7/27/2021   ramadevi.palaniswamy@ust-global.com        #sc-2887      Update the reporting fields on Proactive Email Templates Object whenever the template is used
2.0       11/23/2022   ramadevi.p@maersk.com                      #SC-6473     Search Option for searching Templates
3.0       03/09/2023                                             #SC-7285      Update brand,direction from the template and make from address same as “ReplyTo Email Address
4.0       06/18/2024  Shahanawaz@maersk.com                      #SC-10210     Removed the cdl creation. Please check git for old code.
*/

public with sharing class proActiveEmailController {
    public proActiveEmailController() {
        
    }
    //Method to get the Email Template based on the selected template    
    @AuraEnabled(cacheable=true)
    public static List<ProActive_Email_Templates__c> getEmailTemplates(String searchTerm,String proActiveTempList){ 
        Map<String, ProActive_Email_Templates__c> emailTemplatesMap = new Map<String,ProActive_Email_Templates__c>();
        List<ProActive_Email_Templates__c> tempList = new List<ProActive_Email_Templates__c>();
        List<ProActive_Email_Templates__c> templateList = new List<ProActive_Email_Templates__c>();
        String query = 'SELECT Id, Name, Email_Template_API_Name__c, To_Email_Address__c,CC_Email_Address__c, Type__c, Sub_Type__c, Reason_For_Case__c,Product__c, Contact__c, ReplyTo_Email_Address__c, Country__c, Case_Visibility__c,Times_Used__c,Last_used_on__c,On_Behalf_of_Account__c,SF_4PL_Account__c,Direction__c,Brand__c,Multi_Carrier_Restricted_Account__c FROM ProActive_Email_Templates__c ORDER BY Name ASC';
        
        if(String.isNotBlank(searchTerm) && searchTerm <> null){  
            List<Object> pTempList = new List<Object>();
            if(proActiveTempList <> null){
                pTempList = (List<Object>)JSON.deserializeUntyped(proActiveTempList);                
                List<string > finalJsonString = new List<string>();
                
                for (Object instance : pTempList){                    
                    finalJsonString.add(JSON.serialize(instance)); 
                }
                
                for(string s: finalJsonString){
                    ProActive_Email_Templates__c customObject = (ProActive_Email_Templates__c)JSON.deserialize(s, ProActive_Email_Templates__c.class);
                    tempList.add(customObject);
                }                 
            }
            
            templateList.clear();   
            for(ProActive_Email_Templates__c emailTemplate : tempList){
                if(!string.isblank(emailTemplate.Name) && String.isNotBlank(emailTemplate.Name)){
                    if(emailTemplate.Name.toLowerCase().contains(searchTerm.toLowerCase())){
                        templateList.add(emailTemplate);
                    }                    
                }
            }
            templateList.sort();
            
        } else {
            tempList = Database.query(query);            
            templateList.addAll(tempList);
            return templateList;
        }
        
        system.debug('templateList##'+templateList);
        
        return templateList;
    }
    
    @AuraEnabled(cacheable=true)
    public static sObject getEmailTemplateDetails(string selectedTemplateId){
        try {
            string q = 'SELECT Id, DeveloperName, HtmlValue, Subject, Body FROM emailTemplate WHERE Id = :selectedTemplateId';
            System.debug('****Query String + '+q);
            SObject emailTemplateRecord = Database.query(q);
            return emailTemplateRecord;
        } catch (Exception e) {
            system.debug('***in e-->'+e.getMessage()+' '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String, String> createCaseSendEmail(String payload) {
        system.debug('payload@@'+payload);
        Map<String, String> response = new Map<String, String>();
        Map<String, String> ProactiveGenKeyValue = new Map<String, String>();
        Map<String, Id> linerBrandOrgIdMap = BrandUtilities.getBrandAndOrgWideEmailAddressIdMap();
        List<OrgWideEmailAddress> owa = new list<OrgWideEmailAddress>();
        for (General_Key_Value_Configurations__mdt mapvalue :[SELECT Id,First_Field_Name__c, First_Field_Value__c,Key__c FROM General_Key_Value_Configurations__mdt WHERE Key__c LIKE  '%Proactive%']) {           
            ProactiveGenKeyValue.put(mapvalue.Key__c,mapvalue.First_Field_Value__c);                              
        }
        try{
            EmailContent emailContent = (EmailContent) JSON.deserialize(payload, EmailContent.class);
            System.debug('Email Content : '+emailContent);
            //Create Case Record
            String emailbodyStr = emailContent.bodyHTML.stripHtmlTags();
            Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
            Case newCase = new Case();
            newCase.ContactId = emailContent.contactId;
            newCase.Subject = (emailContent.subject.replace(Label.ProActive_ThreadId_Format,'')).replace(Label.ProActive_Lightning_ThreadIdFormat,'');
            newCase.Description = emailbodyStr;
            newCase.Type = emailContent.type;
            newCase.Sub_Type__c = emailContent.subType;
            newCase.SF_4PL_Account__c = emailContent.FPLAccount;
            newCase.Reason_For_Case__c = emailContent.reason;
            newCase.Product__c = emailContent.product;
            newCase.Country__c = emailContent.country;
            newCase.RecordTypeId = extCaseRTId;
            newCase.Case_Visibility__c = emailContent.caseVisibility;
            newCase.On_Behalf_Account__c = emailContent.OnBehalfOfAccount;
            newCase.Resolution_Summary__c = ProactiveGenKeyValue.get('ProactiveResolutionSummary');
            newCase.Status = ProactiveGenKeyValue.get('ProactiveStatus');
            newCase.Direction__c =  emailContent.Direction;
            newCase.Case_Channel__c = ProactiveGenKeyValue.get('ProactiveCaseChannel');
            newCase.Send_Case_Closure__c = ProactiveGenKeyValue.get('ProactiveCaseClosure');
            newCase.Case_Closure_Opt_Out_Reason__c = ProactiveGenKeyValue.get('ProactiveCaseClosureOptOut');
            newCase.Liner_Brand__c =emailContent.Brand;
            newCase.Multi_Carrier_Restricted_Account__c =emailContent.MultiCRestrictedAccount;
            
            
            List<Id> DocumentIdList = new List<Id>();            
            if(emailContent.DocIds <> null) {
                for(String str : emailContent.DocIds.Split(',')){
                    DocumentIdList.add(Id.Valueof(str));
                }
            }
            
            Savepoint sp = Database.setSavepoint();
            try {
                insert newCase;
            }catch(Exception  ex) {
                system.debug('****Exception'+ex.getMessage()+' '+ex.getLineNumber());
                String[] str = ex.getMessage().split(':');
                response.put('Exception','Error while Case creation. '+str[str.size()-1]);
                Database.rollback(sp);
                return response;
            }
            
            System.debug('Case Id : '+newCase.Id);
            Case insertedCase = [SELECT Id, CaseNumber, ThreadId__c FROM Case WHERE Id =:newCase.Id];        
            
            //Get the contentversion to add as attachment to Email
            system.debug('DocumentIdList ###'+DocumentIdList);
            List<Id> cvIds = new List<Id>();           
            for (contentversion file: [SELECT title,PathOnClient, FileType,versiondata FROM contentversion WHERE ContentDocumentId IN :DocumentIdList]) {
                cvIds.add(file.Id);
            }
            
            //SEND EMAIL
            //Updating the from address same as “ReplyTo Email Address”                         
            String orgWideEmailAddressId;
            if (!String.isBlank(emailContent.replyToEmail)) {
                owa = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :emailContent.replyToEmail LIMIT 1];
                if (!owa.isEmpty()) {
                    orgWideEmailAddressId = owa[0].Id;
                }
            }
            
            if (String.isBlank(orgWideEmailAddressId) && linerBrandOrgIdMap.containsKey(emailContent.Brand)) {
                orgWideEmailAddressId = linerBrandOrgIdMap.get(emailContent.Brand);
            }
            
            //emailContent.to = emailContent.to.trim();
            //String[] toEmails = emailContent.to.split(',');
            String[] ccEmails = new List<String>();
            String token = EmailMessages.getFormattedThreadingToken(insertedCase.Id);
            emailContent.subject = emailContent.subject.replace('{!Case.Thread_Id}','').replace(Label.ProActive_Lightning_ThreadIdFormat,'');
            emailContent.bodyHTML = emailContent.bodyHTML.replace('{!Case.Thread_Id}',token).replace(Label.ProActive_Lightning_ThreadIdFormat,token);
            if(!emailContent.bodyHTML.contains(token)){
                emailContent.bodyHTML += '<br/><br/>'+token;
            }    
            /*if(!String.isBlank(emailContent.cc)){
ccEmails = emailContent.cc.split(',');
}*/
            
            // Define the email
            system.debug('emailContent.to'+emailContent.to);
            system.debug('emailContent.cc'+emailContent.cc);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            email.setSubject(emailContent.subject);
            email.setToAddresses(emailContent.to);
            email.setCcAddresses(emailContent.cc);
            email.setHtmlBody( emailContent.bodyHTML);
            email.optOutPolicy = 'FILTER';
            email.setOrgWideEmailAddressId(orgWideEmailAddressId);
            email.setReplyTo(emailContent.replyToEmail);
            email.setEntityAttachments(cvIds);
            email.setWhatId(newCase.Id);
            
            try {
                // Send the email
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }catch(Exception emlExcep){
                system.debug('****Send Email Exception'+emlExcep.getMessage());
                String[] str = emlExcep.getMessage().split(':');
                response.put('Exception','Error while sending the Email. ' +str[str.size()-1]);
                Database.rollback(sp);
                return response;
            }
            
            //SC-2887: Last used and Number of time used Fields for reporting purposes.
            ProActive_Email_Templates__c updProActiveTemplate = new ProActive_Email_Templates__c();
            updProActiveTemplate.Id = emailContent.proActiveTempId;
            updProActiveTemplate.Last_used_on__c = System.now();
            if(emailContent.numberOfTimeUsed == ''|| emailContent.numberOfTimeUsed == NULL || emailContent.numberOfTimeUsed == 'NULL' || emailContent.numberOfTimeUsed == '0'){
                updProActiveTemplate.Times_Used__c = 1;
            } 
            else{
                updProActiveTemplate.Times_Used__c = Integer.ValueOf(emailContent.numberOfTimeUsed)+1;
            }
            update updProActiveTemplate;
            
            response.put(insertedCase.Id, insertedCase.CaseNumber);
            return response;
        }catch(Exception e){
            System.debug('****Error Occoured : '+e.getMessage()+' line no: '+e.getLineNumber());
            response.put('Exception', e.getMessage());
        }
        return response;
    }
    
    //Wrapper Class to represent a Email & Case Content 
    public class EmailContent {
        @AuraEnabled
        public List<String> to;
        @AuraEnabled
        public List<String> cc;
        @AuraEnabled
        public String subject;
        @AuraEnabled
        public String bodyHTML;
        @AuraEnabled
        public String templateAPIName;
        @AuraEnabled
        public String templateId;
        @AuraEnabled
        public String replyToEmail;
        @AuraEnabled
        public String contactId;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String subType;
        @AuraEnabled
        public String product;
        @AuraEnabled
        public String country;
        @AuraEnabled
        public String reason;
        @AuraEnabled
        public String caseVisibility;
        @AuraEnabled
        public String DocIds;
        @AuraEnabled
        public String numberOfTimeUsed;
        @AuraEnabled
        public String proActiveTempId;
        @AuraEnabled
        public String OnBehalfOfAccount;
        @AuraEnabled
        public String FPLAccount;
        @AuraEnabled
        public String Brand;
        @AuraEnabled
        public String Direction;
        @AuraEnabled
        public String MultiCRestrictedAccount;
        
    }
    
}