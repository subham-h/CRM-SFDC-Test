/**
* Author   : Shahanawaz@Maersk
* Purpose  : Used in AttachmentSelectionISRForm LWC for ISR creation
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-6171   21-Sept-2022   Shahanawaz@Maersk      Used in AttachmentSelectionForm for ISR creation
* 1.1      SC-6170   18-Oct-2022    Shahanawaz@Maersk      Used in AttachmentSelectionForm for Proactive Case Creation
* 1.2      SC-6459   16-Nov-2022    ramadevi@Maersk        Add banner in proactive case & give file select option
*/
public class ISRAttachmentController {
    
    /*
    * @description | SC-6170  Get Record type name
    * @param recId accepts the recId
    */
    @AuraEnabled(cacheable=true)
    public static String getRecordTypeName(String recId){
        Case cs = [Select Id, RecordType.Name From Case Where Id =: recId];
        return cs.RecordType.Name;
    }
    
    /*
    * @description | SC-6171  Get Case records
    * @param searchKey accepts the searchKey
    * @param sObjectApiName accepts the sObjectApiName
    * @param sObjectApiName accepts the sObjectApiName
    * @param idsToRemove accepts the idsToRemove
    */
    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName, List<String> idsToRemove) {    
        List < sObject > returnList = new List < sObject > ();
        string sWildCardText = searchKey + '%';
        string sQuery = 'Select Id,CaseNumber, Priority, ContactId, AccountId, Status, Subject, Type, Contact.Name, Account.Name, Country__r.Name ,createdDate, Owner.Name From ' + sObjectApiName + ' Where CaseNumber Like : sWildCardText';
        if(!idsToRemove.isEmpty()){
            sQuery += ' AND Id NOT IN: idsToRemove';
        }
        sQuery += '  order by createdDate DESC LIMIT '+General_Key_Value_Configurations__mdt.getInstance('ISR_Case_LIMIT').First_Field_Value__c;
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    /*
    * @description | SC-6171  get files attached to cases
    * @param parentIdList accepts the parentIdList
    */
    @AuraEnabled
    public static CaseWrapper getFilesList(List<String> parentIdList){
        CaseWrapper csWrap = new CaseWrapper();
        List<CaseListWrapper> caseWrapList = new List<CaseListWrapper>();
        Set<String> caseIdSet = new Set<String>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Map<Id, Id> emMsgToCaseIdMap = new Map<Id, Id>();
        Map<Id, List<ContentDocumentLink>> caseIdToConDocListMap = new Map<Id, List<ContentDocumentLink>>();
        try{
            List<EmailMessage> emList = [Select Id, ParentId From EmailMessage Where ParentId =: parentIdList];            
            caseIdSet.addAll(parentIdList);
            if(!emList.isEmpty()){
                for(EmailMessage em : emList){
                    emMsgToCaseIdMap.put(em.Id, em.ParentId);
                    caseIdSet.add(em.ParentId);
                }
            }
            
            for(Case cs : [Select id, CaseNumber From Case Where Id =: caseIdSet]){
                caseMap.put(cs.Id, cs);
            }
            if(!parentIdList.isEmpty() || !emMsgToCaseIdMap.isEmpty()){
                List<ContentDocumentLink> cdlList = [Select Id, ContentDocumentId, ContentDocument.Title, ContentDocument.ContentSize, ContentDocument.FileType, LinkedEntityId From ContentDocumentLink Where LinkedEntityId =: parentIdList OR LinkedEntityId =: emMsgToCaseIdMap.keyset()];
                if(!cdlList.isEmpty()){
                    for(ContentDocumentLink cdl : cdlList){
                        if(parentIdList.contains(cdl.LinkedEntityId)){
                            if(caseIdToConDocListMap.isEmpty() || !caseIdToConDocListMap.containsKey(cdl.LinkedEntityId)){
                                caseIdToConDocListMap.put(cdl.LinkedEntityId, new List<ContentDocumentLink>{cdl});
                            }
                            else{
                                caseIdToConDocListMap.get(cdl.LinkedEntityId).add(cdl);
                            }
                        }
                        else if(emMsgToCaseIdMap.containsKey(cdl.LinkedEntityId)){
                            if(caseIdToConDocListMap.isEmpty() || !caseIdToConDocListMap.containsKey(emMsgToCaseIdMap.get(cdl.LinkedEntityId))){
                                caseIdToConDocListMap.put(emMsgToCaseIdMap.get(cdl.LinkedEntityId), new List<ContentDocumentLink>{cdl});
                            }
                            else{
                                caseIdToConDocListMap.get(emMsgToCaseIdMap.get(cdl.LinkedEntityId)).add(cdl);
                            }
                        }
                    }
                }
            }
            
            //create wrapper
            if(!caseIdToConDocListMap.isEmpty()){
                for(String csId : caseIdToConDocListMap.keyset()){
                    CaseListWrapper cs = new CaseListWrapper();
                    cs.caseno = caseMap.get(csId).CaseNumber;
                    List<AttachmentWrapper> attList = new List<AttachmentWrapper>();
                    for(ContentDocumentLink cdl : caseIdToConDocListMap.get(csId)){
                        AttachmentWrapper att = new AttachmentWrapper();
                        att.selectedFlag = false;
                        att.conDocId = cdl.ContentDocumentId;
                        att.title = cdl.ContentDocument.Title;
                        att.conSize = fileSizeToString(cdl.ContentDocument.ContentSize);
                        att.conType = cdl.ContentDocument.FileType;
                        attList.add(att);
                    }
                    cs.attWrapList = attList;
                    caseWrapList.add(cs);
                }
            }
            if(!caseWrapList.isEmpty()){
                csWrap.status = true;
                csWrap.message = 'Success';
                csWrap.caseWrapList = caseWrapList;
            }
            else{
                csWrap.status = false;
                csWrap.message = 'No files found.';
                csWrap.caseWrapList = null;
            }
        }catch(Exception e){
            csWrap.status = false;
            csWrap.message = e.getMessage()+' '+e.getLineNumber();
            csWrap.caseWrapList = null;
        }
        return csWrap;
    }
    
    /*
    * @description | SC-6171  Convert bytes in readable string format
    * @param value accepts the value
    */
    public static String fileSizeToString(Long value){
        if(value < 1024){
            return string.valueOf(value) + ' Bytes';
        }
        else if(value >= 1024 && value < (1024*1024)){
            //KB
            Decimal kb = Decimal.valueOf(value);
            kb = kb.divide(1024,2);
            return string.valueOf(kb) + ' KB';
        }
        else if(value >= (1024*1024) && value < (1024*1024*1024)){
            //MB
            Decimal mb = Decimal.valueOf(value);
            mb = mb.divide((1024*1024),2);
            return string.valueOf(mb) + ' MB';
        }
        else{
            //GB
            Decimal gb = Decimal.valueOf(value);
            gb = gb.divide((1024*1024*1024),2);
            return string.valueOf(gb) + ' GB';
        }    
    }
    
    /*
    * @description | SC-6171  get the fields data from fieldset
    * @param recordId accepts the recordId
    * @param objectName accepts the objectName
    * @param fieldSetName accepts the fieldSetName
    */
    @AuraEnabled
    public static FieldSetForm getForm(Id recordId, String objectName, String fieldSetName) {
        FieldSetForm form = new FieldSetForm();
        try{
            if(recordId != null){
                form.csDetails = [Select Id, AccountId, Liner_Brand__c, ContactId, Description, MLL__c, On_Behalf_Account__c, ParentId, Subject, Country__c, Priority, Short_Transit__c, Case_Visibility__c, SF_4PL_Account__c, Direction__c From Case Where Id =: recordId];
            }
            form.isrRTId = Label.ISR_Case_RT_Id;
            form.Fields = getFields(recordId, objectName, fieldSetName);
            form.message = 'Success';
            form.status = true;
        }catch(Exception e){
            form.message = e.getMessage()+' '+e.getLineNumber();
            form.status = false;
        }        
        return form;
    }
    
    /*
    * @description | SC-6171  get the fields data from fieldset
    * @param recordId accepts the recordId
    * @param objectName accepts the objectName
    * @param fieldSetName accepts the fieldSetName
    */
    private static List<FormField> getFields(Id recordId, String objectName, String fieldSetName) {
        Schema.SObjectType objectType = null;
        if(recordId != null){
            objectType = recordId.getSobjectType();
        }
        else if(!String.isEmpty(objectName)){
            objectType = Schema.getGlobalDescribe().get(objectName);
        }
        
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
        List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();
        
        List<FormField> fields = new List<FormField>();
        for (Schema.FieldSetMember fsm : fieldSetMembers) {
            FormField f = new FormField(fsm);
            fields.add(f);
        }
        return fields;
    }
    
    /*
    * @description | SC-6171  create contentDocumentLink
    * @param caseId accepts the caseId
    * @param conDocIds accepts the conDocIds
    */
    @AuraEnabled
    public static CaseWrapper attachFiles(String caseId, List<String> conDocIds){
        CaseWrapper csWrap = new CaseWrapper();
        Map<String, ContentDocumentLink> cdlMap = new Map<String, ContentDocumentLink>();
        try{
            for(String cdId : conDocIds){
                if(cdlMap.isEmpty() || !cdlMap.containsKey(caseId+cdId)){
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.LinkedEntityId = caseId;
                    cdl.ContentDocumentId = cdId;
                    cdlMap.put((String.valueOf(caseId)+String.valueOf(cdId)), cdl);
                }
            }
            if(!cdlMap.isEmpty()){
                insert cdlMap.values();
            }
            csWrap.status = true;
            csWrap.message = 'Success';
        }catch(Exception e){
            csWrap.status = false;
            csWrap.message = Label.System_Error;
        }
        return csWrap;
    }
    
    /*
    * @description | SC-6170  get emails related to case
    * @param caseId accepts the caseId
    */
    @AuraEnabled(cacheable=true)
    public static List<EmailMessage> getEmailMessagesFromCase(String caseId){
        User curUsr = [Select Id, Signature, Email From User Where Id =: UserInfo.getUserId()];
        List<EmailMessage> emList = [Select Id, Subject, FromName, FromAddress, ToAddress, CcAddress, HtmlBody, ParentId, Parent.ContactId, CreatedDate From EmailMessage Where ParentId =: caseId AND Incoming = true Order By CreatedDate DESC];
        for(EmailMessage em : emList){
            if(!String.isEmpty(em.Subject) && em.Subject.indexOf('ref') != -1){
                em.Subject = em.Subject.subString(0, em.Subject.indexOf('ref'));
            }
            String body = '';
            if(curUsr != null && !String.isEmpty(curUsr.Signature)){
                body += '<br/><font face="verdana">'+curUsr.Signature.replaceAll('\n', '<br/>')+'</font>';
            }
            body += '<br/><br/><font face="verdana">'+
                '--------------- Original Message ---------------<br/>'+
                '<b>From: </b>'+em.FromName +' ['+em.FromAddress+']<br/>'+
                '<b>Sent: </b>'+em.CreatedDate +'<br/>'+
                '<b>To: </b>'+em.toAddress +'<br/>'+
                '<b>Subject: </b>'+em.Subject +'<br/><br/>'+
                em.HtmlBody+
                '</font>';
            em.HtmlBody = body;
        }
        return emList;
    }

    /*
    * @description | SC-6170  clone case & attach emails & files to cloned case
    * @param recId accepts the recId
    * @param condocIdsList accepts the condocIdsList
    * @param cloneEmails accepts the cloneEmails
    * @param selectedData accepts the selectedData
    */    
    @AuraEnabled
    public static CaseWrapper cloneCase(String recId, List<String> condocIdsList, String docIdsList, Boolean cloneEmails, String selectedData){
        CaseWrapper cwrap = new CaseWrapper();
        String newCaseId = CaseCloneAttachmentController.cloneCaseRecord(recId);
        try{
            TriggerExecutionController.skipCaseTrigger(true);            
            List<ContentDocumentLink> clListToDelete = new List<ContentDocumentLink>();
            Case csToUpdate = new Case();
            csToUpdate.Id = newCaseId;
            csToUpdate.ParentId = recId;
            csToUpdate.Case_Channel__c = General_Key_Value_Configurations__mdt.getInstance('ProactiveFieldMap4').First_Field_Value__c;
            update csToUpdate;
            TriggerExecutionController.skipCaseTrigger(false);
            Constants.stopEmailParentRRFUpdate = true;
            
            cwrap.caseId = newCaseId;
            String[] toEmails = new List<String>();
            String[] ccEmails = new List<String>();
            List<Id> cvIds = new List<Id>();
            List<EmailMessage> emMsgList = new List<EmailMessage>();
            List<Org_Wide_Email_Address__mdt> orgwideDataList = new List<Org_Wide_Email_Address__mdt>();
            List<OrgWideEmailAddress> orgWideAddList = new List<OrgWideEmailAddress>();
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            List<ContentDocumentLink> clListToInsert = new List<ContentDocumentLink>();
            List<String> fileIds = new List<String>();
            if(!String.isEmpty(docIdsList)){
                fileIds = docIdsList.split(',');
            }
            if(!fileIds.isEmpty()){
                condocIdsList.addAll(fileIds);
            }
            
            if(cloneEmails == false || (cloneEmails == true && String.isEmpty(selectedData))){
                //clone all incoming emails of recId && attach to new case along with files
                List<EmailMessage> emailListToInsert = createEmailMessages(recId, newCaseId);
                if(!emailListToInsert.isEmpty()){
                    insert emailListToInsert;
                }
                    
                if(!condocIdsList.isEmpty()){
                    Map<String, ContentDocumentLink> conDocLinkMap = createContentDocLinkList(newCaseId, condocIdsList);
                    if(!conDocLinkMap.isEmpty() && !conDocLinkMap.values().isEmpty()){
                        try{
                            insert conDocLinkMap.values();
                        }catch(Exception e){
                            cwrap.status = true;
                            cwrap.message = 'Case created successfully but please attach the files manually to the case.';
                            return cwrap;
                        }
                    }
                }
                cwrap.status = true;
                cwrap.message = 'Case created successfully.';
            }
            else{
                //send email along with attachments & attach the email to case
                EmailContent emailContent = (EmailContent) JSON.deserialize(selectedData, EmailContent.class);
                Case cs = [select id, Subject, ContactId, Liner_Brand__c from case where id =: recId];
                emMsgList = [Select id, HtmlBody, FromName, FromAddress, ToAddress, CreatedDate, Subject From EmailMessage Where Id =: emailContent.emlId];
                orgwideDataList = [Select DeveloperName, MasterLabel, Email_Address__c, Email_Address_Id__c From Org_Wide_Email_Address__mdt Where MasterLabel =: cs.Liner_Brand__c];
                if(!emMsgList.isEmpty() && !String.isEmpty(emMsgList[0].ToAddress)){
                    List<String> emlList = new List<String>();
                    for(String eml : emMsgList[0].ToAddress.split(';')){
                        if(!emlList.contains(eml.trim())){
                            emlList.add(eml.trim());
                        }
                    }
                    if(!emlList.isEmpty()){
                        orgWideAddList = [Select id, Address, DisplayName from OrgWideEmailAddress WHERE Address =: emlList limit 1];
                    }
                }
                
                if(emailContent != null){
                    if(!String.isEmpty(emailContent.contactId)){
                        Contact con = [Select Id, Email From Contact Where Id =: emailContent.contactId];
                        if(!String.isEmpty(con.Email)){
                            toEmails.add(con.Email.trim());
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
                    
                    for(Contentversion file: [SELECT title,PathOnClient, FileType,versiondata FROM contentversion WHERE ContentDocumentId IN: condocIdsList]){
                        cvIds.add(file.Id);
                    }                    
                    
                    if(!orgWideAddList.isEmpty()){
                        email.setOrgWideEmailAddressId(orgWideAddList[0].Id);
                    }
                    else if(!orgwideDataList.isEmpty()){
                        email.setOrgWideEmailAddressId(orgwideDataList[0].Email_Address_Id__c);
                    }
                    Case newCase = [Select Id, CaseNumber, ThreadId__c  From Case Where Id =: newCaseId]; 
                    email.setSubject(emailContent.subject + ' ' + newCase.CaseNumber + ' ' + newCase.ThreadId__c);
                    email.setToAddresses(toEmails);
                    if(!ccEmails.isEmpty()){
                        email.setCcAddresses(ccEmails);
                    }
                    email.setHtmlBody(emailContent.bodyHTML);
                    if(!cvIds.isEmpty()){
                        email.setEntityAttachments(cvIds);
                    }
                    email.setWhatId(newCaseId);
                    Messaging.SendEmailResult [] emailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                    Boolean emailSent = false;
                    for(Messaging.SendEmailResult mr : emailResult){
                        if(mr.isSuccess()){                         
                            emailSent = true;
                            break;
                        }
                        else{
                            cwrap.status = true;
                            cwrap.message = 'Case created successfully but please send an email & attach the files manually.';
                            return cwrap;
                        }
                    }
                    if(emailSent == true){
                        EmailMessage emailMsg = [Select Id From EmailMessage Where ParentId =: newCaseId Order By CreatedDate DESC LIMIT 1];
                        
                        if(!condocIdsList.isEmpty()){                           
                            Map<String, ContentDocumentLink> conDocLinkMap = createContentDocLinkList(emailMsg.Id, condocIdsList);
                            if(!conDocLinkMap.isEmpty() && !conDocLinkMap.values().isEmpty()){
                                try{
                                    insert conDocLinkMap.values();
                                    //deleting the contentdocumentlink of case - rama
                                    clListToDelete = [Select Id From ContentDocumentLink Where LinkedEntityId =: cs.Id AND ContentDocumentId IN: fileIds];
                                    if(!clListToDelete.isEmpty()){
                                        delete clListToDelete;
                                    }
                                }catch(Exception e){
                                    cwrap.status = true;
                                    cwrap.message = 'Case created successfully but please attach the files manually to the case.';
                                    return cwrap;
                                }
                            }
                        }
                    }
                }
                cwrap.status = true;
                cwrap.message = 'Case created successfully.';
            }
        }       
        catch(Exception e){
            cwrap.status = false;
            cwrap.message = Label.System_Error;
        }
        return cwrap;        
    }
    
    /*
    * @description | SC-6170  create email message records
    * @param recId accepts the recId
    * @param newCaseId accepts the newCaseId
    */
    private static List<EmailMessage> createEmailMessages(String recId, String newCaseId){
        List<EmailMessage> emailListToInsert = new List<EmailMessage>();
        for(EmailMessage em : [Select Id, Subject, FromAddress, FromName, ToAddress, CcAddress, HtmlBody, TextBody From EmailMessage Where ParentId =: recId AND Incoming = true]){
            EmailMessage cloneEm = new EmailMessage();
            cloneEm.ParentId = newCaseId;
            cloneEm.Subject = em.Subject;
            cloneEm.FromAddress = em.FromAddress;
            cloneEm.FromName = em.FromName;
            cloneEm.ToAddress = em.ToAddress;
            cloneEm.CcAddress = em.CcAddress;
            cloneEm.HtmlBody = em.HtmlBody;
            cloneEm.TextBody = em.TextBody;
            cloneEm.Incoming = true;
            emailListToInsert.add(cloneEm);
        }
        return emailListToInsert;       
    }
    
    /*
    * @description | SC-6170  create contentdocumentlink records
    * @param objId accepts the objId
    * @param condocIdsList accepts the condocIdsList
    */
    private static Map<String, ContentDocumentLink> createContentDocLinkList(String objId, List<String> condocIdsList){
        Map<String, ContentDocumentLink> conDocLinkMap = new Map<String, ContentDocumentLink>();
        for(String cdId : condocIdsList){
            if(!conDocLinkMap.containsKey(cdId+objId)){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.LinkedEntityId = objId;
                cdl.ContentDocumentId = cdId;
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
                conDocLinkMap.put(cdId+objId, cdl);
            }            
        }
        return conDocLinkMap;        
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
        public String contactId;
        @AuraEnabled
        public String emlId;
    }
    
    public class CaseWrapper{
        @AuraEnabled
        public String caseId;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public Boolean status;
        @AuraEnabled
        public List<CaseListWrapper> caseWrapList;
    }
    
    public class CaseListWrapper{
        @AuraEnabled
        public String caseno;
        @AuraEnabled
        public List<AttachmentWrapper> attWrapList;
    }
    
    public class AttachmentWrapper{
        @AuraEnabled
        public Boolean selectedFlag;
        @AuraEnabled
        public String conDocId;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String conSize;
        @AuraEnabled
        public String conType;
    }
    
    public class FieldSetForm {
        @AuraEnabled
        public List<FormField> Fields;        
        @AuraEnabled
        public Case csDetails;
        @AuraEnabled
        public String isrRTId;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public Boolean status;
        
        public FieldSetForm() {
            Fields = new List<FormField>();
        }
    }
    
    public class FormField {
        public FormField(Schema.FieldSetMember f) {
            this.IsRequired = f.DBRequired;
            this.APIName = f.fieldPath;
            this.Label = f.label;
            this.Required = f.required;
            this.Type = String.valueOf(f.getType());
        }
        
        public FormField(Boolean required) {
            this.IsRequired = required;
        }
        
        @AuraEnabled
        public Boolean IsRequired;
        @AuraEnabled
        public String APIName;  
        @AuraEnabled
        public String Label;
        @AuraEnabled
        public Boolean Required;
        @AuraEnabled
        public String Type;
    }
    
}