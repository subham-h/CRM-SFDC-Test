/*
* Author    : Ragu
* Purpose   : Send EmailMessages to External Object. 
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-5245     11-Aug-2022 Ranjan@Maersk            Created. 
* 2.0                   12-Oct-2022 Ranjan@Maersk            Changes related to apex connector
* 3.0                   27-Dec-2022 Ranjan@Maersk            commenting the system fields
* 4.0                   03-Jan-2022 Ranjan@Maersk            added the Boolean variable "isEmailsToBeDeleted" if mails are to be deleted 
*/
public with sharing class EmailMessageSender {
    static Integer iRestrictedDML = Limits.getLimitDMLStatements()-10;
    static Integer iRestrictedSOQL = Limits.getLimitQueries()-10;
    public class DMLLimitReachedException extends Exception {}
    public class QueryLimitReachedException extends Exception {}
    final static String STATUS_NEW = 'New';
    final static String ARCHIVED_EMAIL = 'Archived Email';
    // This method will be called from Developer Console to initiate the scheduled regular Email Message archival process. 
    // RQ-007250 - Added iBatchSize variable. 
    public static void initiateScheduledEMSExtArchival(String strName, String strSchedule, Integer iBatchSize) {
        if(String.isBlank(strName) && !Test.isRunningTest()) {
            strName = 'Batch EmailMessage External Archival';
        }else if(String.isBlank(strName) && Test.isRunningTest()){
            strName = 'Batch EmailMessage External Archival Test';
        }
        if(String.isBlank(strSchedule)) {
            strSchedule = '0 0 19 ? * *';
        }
        System.schedule(strName, strSchedule, new Scheduler_BatchEmailMessageExtArchiver(iBatchSize));
    }
    // clone the email
    public static void sendEmailMessages(list<EmailMessage> lstEmailMessages,Boolean isArchMailsConsidered,Boolean isEmailsToBeDeleted) {
        Map<id,emailmessagearchival__x> emailArchMap=new Map<id,emailmessagearchival__x>();
        Map<Id,emailmessagearchival__x> mapOldNewEmailIds=new Map<id,emailmessagearchival__x>();
        Set<Id> emailId =new Set<Id>();
        /*logic to remove the case having the attchments*/
        for(EmailMessage emailMsgObj:lstEmailMessages){
            emailId.add(emailMsgObj.Id);
        }
        List<Attachment> attchList = [select ParentId,Name from Attachment where ParentId in :emailId];
        Set<Id> emailIdHasAttachSet=new Set<Id>();
        Set<Id> emailIdHasArchivedMails=new Set<Id>();
        Set<Id> emailIdHasOtherAttch=new Set<Id>(); 
        for(Attachment attchObj:attchList)
        {
            emailIdHasAttachSet.add(attchObj.ParentId);
            if(attchObj.Name.startsWithIgnoreCase(ARCHIVED_EMAIL)){
                emailIdHasArchivedMails.add(attchObj.ParentId);
            }else{
                emailIdHasOtherAttch.add(attchObj.ParentId);
            }
        }
        emailIdHasArchivedMails.removeAll(emailIdHasOtherAttch);
        List<Attachment> archivedMailAttchList = new List<Attachment>();
        if(isArchMailsConsidered)
        {
            archivedMailAttchList = [select ParentId,Name,Body,BodyLength from Attachment where ParentId in :emailIdHasArchivedMails];
        }
        Map<Id,Attachment> emailIdAttchmentMap=new Map<Id,Attachment>();
        for(Attachment attchObj:archivedMailAttchList){
            emailIdAttchmentMap.put(attchObj.ParentId, attchObj);
        }
        Map<Id,EmailMessage> emailMessageToDelMap = new Map<Id,EmailMessage>();
        Map<Id,EmailMessage> emailMessageToFinDelMap = new Map<Id,EmailMessage>();
        /*end of logic to remove the case having the attchments*/
        for(EmailMessage emailMsgObj:lstEmailMessages){
            if(!emailIdHasAttachSet.contains(emailMsgObj.Id)){//casIdHasAttachSet does not have the case id of the email
                emailmessagearchival__x emailArchObj=EmailMessageSender.cloneEmailValues(emailMsgObj);
                emailArchMap.put(emailMsgObj.id,emailArchObj);
                emailMessageToDelMap.put(emailMsgObj.id,emailMsgObj);
            }else if( isArchMailsConsidered && !emailIdAttchmentMap.isEmpty() && emailIdAttchmentMap.containsKey(emailMsgObj.Id)){
                //built the email body
                emailMsgObj.HtmlBody=emailIdAttchmentMap.get(emailMsgObj.Id).Body.toString();
                emailMsgObj.Subject=emailMsgObj.Subject.Right(emailMsgObj.Subject.length()-21);
                emailmessagearchival__x emailArchObj=EmailMessageSender.cloneEmailValues(emailMsgObj);
                emailArchMap.put(emailMsgObj.id,emailArchObj);
                emailMessageToDelMap.put(emailMsgObj.id,emailMsgObj);
            }
        }
        //Archive email to external object
        Boolean deleteEmails=true;
        if(!emailArchMap.isEmpty() && !Test.isRunningTest()){
            List<Database.SaveResult>  saveResults = Database.insertImmediate( emailArchMap.values());
        }
        List<emailmessagearchival__x> savedEmailList=[select id,heroku_id__c from emailmessagearchival__x where heroku_id__c in:emailArchMap.keyset()];
        //System.debug('email Message Id'+emailobj);
        for(emailmessagearchival__x con:savedEmailList){
            
            mapOldNewEmailIds.put(con.heroku_id__c,con);
            emailMessageToFinDelMap.put(con.heroku_id__c,emailMessageToDelMap.get(con.heroku_id__c));
        }
        String idsMissingInHeroku='';
        for(id emailIdObj:emailMessageToDelMap.keyset()){
            if(!emailMessageToFinDelMap.containsKey( emailIdObj)){
                idsMissingInHeroku=idsMissingInHeroku+String.valueOf(emailIdObj)+';';
            }
        }
        if(!idsMissingInHeroku.equalsIgnoreCase('')){
            ErrorLogger.writeError('SFDC', 
                                   'EmailMessage', 
                                   'EmailMessageSender.sendEmailMessages',
                                   'Warning', 
                                   'Emails skipped by heroku archival process due to issues while sending data to heroku', idsMissingInHeroku);
            
        }
        Set<id> IdsToRemoveDel;
        if(!mapOldNewEmailIds.isEmpty()){
            //System.debug('Savres---------------'+saveResults);
            IdsToRemoveDel=createContentDocLinks(mapOldNewEmailIds);
        }
        
        
        String failedRec='';
        //Delete the old EmailMessages
        if(!emailMessageToFinDelMap.isEmpty() && isEmailsToBeDeleted){
            for(id idObj:IdsToRemoveDel){
                emailMessageToFinDelMap.remove(idObj);
            }
            //added the boolean isEmailsToBeDeleted to delete the archived mails as part of SC-4508
            TriggerExecutionController.skipEmailMessageTrigger(true);
            Database.DeleteResult[] delResList=Database.delete(emailMessageToFinDelMap.values(),false);
            for(Database.DeleteResult drObj : delResList) {
                if (!drObj.isSuccess()) {
                    failedRec=failedRec+'Id: '+drObj.getId()+'Reason: '+drObj.getErrors()+';';
                }
                
            }
            if(!emailMessageToFinDelMap.isEmpty() &&  emailMessageToFinDelMap.values() != null && !emailMessageToFinDelMap.values().isEmpty())
            {
                Database.emptyRecycleBin(emailMessageToFinDelMap.values());//Empty recycle bin
            }
            TriggerExecutionController.skipEmailMessageTrigger(false);
        }
        if(!failedRec.equalsIgnoreCase('')){
            ErrorLogger.writeError('SFDC', 'EmailMessage', 'EmailMessageSender.sendEmailMessages','Warning', 'Deletion Failure for Emails while Heroku Archival', failedRec);
        }
    }
    public static emailmessagearchival__x cloneEmailValues(EmailMessage emailMsgObj){
        
        emailmessagearchival__x emailArchObj=new emailmessagearchival__x ();
        //emailArchObj.activityid__c=emailMsgObj.ActivityId;//
        emailArchObj.bccaddress__c=emailMsgObj.BccAddress;
        emailArchObj.ccaddress__c=emailMsgObj.CcAddress;
        emailArchObj.createdbyid__c=emailMsgObj.CreatedById;
        emailArchObj.createddate__c=String.valueOf(emailMsgObj.CreatedDate);
        //emailArchObj.emailtemplateid__c=emailMsgObj.EmailTemplateId;
        //emailArchObj.firstopeneddate__c=String.valueOf(emailMsgObj.FirstOpenedDate);
        emailArchObj.fromaddress__c=emailMsgObj.FromAddress;
        emailArchObj.fromname__c=emailMsgObj.FromName;
        emailArchObj.hasattachment__c=emailMsgObj.HasAttachment;
        //emailArchObj.headers__c=emailMsgObj.Headers;
        emailArchObj.htmlbody__c=emailMsgObj.HtmlBody;
        emailArchObj.incoming__c=emailMsgObj.Incoming;
        //emailArchObj.isbounced__c=emailMsgObj.IsBounced;//
        //emailArchObj.isclientmanaged__c=emailMsgObj.IsClientManaged;//
        //emailArchObj.isdeleted__c=emailMsgObj.IsDeleted;
        //emailArchObj.isexternallyvisible__c=emailMsgObj.IsExternallyVisible;//
        //emailArchObj.isopened__c=emailMsgObj.IsOpened;//
        //emailArchObj.istracked__c=emailMsgObj.IsTracked;//to be removed
        emailArchObj.lastmodifiedbyid__c=emailMsgObj.LastModifiedById;
        emailArchObj.lastmodifieddate__c=String.valueOf(emailMsgObj.LastModifiedDate);
        //emailArchObj.lastopeneddate__c=String.valueOf(emailMsgObj.LastOpenedDate);
        emailArchObj.messagedate__c=String.valueOf(emailMsgObj.MessageDate);
        //emailArchObj.messageidentifier__c=emailMsgObj.MessageIdentifier;
        emailArchObj.parentid__c=emailMsgObj.ParentId;
        //emailArchObj.replytoemailmessageid__c=emailMsgObj.ReplyToEmailMessageId;//
        emailArchObj.status__c=emailMsgObj.Status;
        emailArchObj.subject__c=emailMsgObj.Subject;
        //emailArchObj.systemmodstamp__c=String.valueOf(emailMsgObj.systemmodstamp);//
        emailArchObj.textbody__c=emailMsgObj.TextBody;
        //emailArchObj.threadidentifier__c=emailMsgObj.ThreadIdentifier;//
        emailArchObj.toaddress__c=emailMsgObj.ToAddress;
        emailArchObj.validatedfromaddress__c=emailMsgObj.ValidatedFromAddress;//
        emailArchObj.emailid__c=emailMsgObj.id;
        emailArchObj.fromaddress__c=emailMsgObj.FromAddress;
        emailArchObj.casevisibility__c=emailMsgObj.Parent.Case_Visibility__c;
        return emailArchObj;
    }
    public static set<id> createContentDocLinks(Map<Id, emailmessagearchival__x> mapOldNewEmailIds){
        List<ContentDocumentLink> conDocLinkList = new List<ContentDocumentLink>();
        Map<id,id> newEmailidOldEmailid=new Map<id,id>();
        Map<String,ContentDocumentLink> conDocLinkListToInsert = new Map<String,ContentDocumentLink>();
        conDocLinkList = [Select Id, LinkedEntityId, ContentDocumentId,Visibility,ShareType From ContentDocumentLink Where LinkedEntityId =: mapOldNewEmailIds.keyset()];
        if(!conDocLinkList.isEmpty()){
            for(ContentDocumentLink con : conDocLinkList){
                if(mapOldNewEmailIds.containsKey(con.LinkedEntityId)){
                    ContentDocumentLink cn = new ContentDocumentLink();
                    cn.ContentDocumentId = con.ContentDocumentId;
                    cn.LinkedEntityId = mapOldNewEmailIds.get(con.LinkedEntityId).id;//changes to send the emailmessagearchival__x object
                    newEmailidOldEmailid.put(cn.LinkedEntityId,con.LinkedEntityId);
                    //cn.Visibility=con.Visibility;
                    //cn.ShareType=con.ShareType;
                    String contentKey=cn.ContentDocumentId+''+cn.LinkedEntityId;
                    conDocLinkListToInsert.put(contentKey,cn);
                }
            }
        }
        List<ContentDocumentLink> conLinkInsertList=conDocLinkListToInsert.values();
        Set<id> IdsToRemoveDel=new Set<id>();
        if(!conDocLinkListToInsert.isEmpty()){
            if(Limits.getDMLStatements() > iRestrictedDML) {
                throw (new DMLLimitReachedException('Number of DML Statements Limit Reached.'));
            }
            else if(Limits.getQueries() > iRestrictedSOQL) {
                throw (new QueryLimitReachedException('Number of SOQL Query Limit Reached.'));
            }
            Database.SaveResult[] srList=Database.insert(conLinkInsertList,false); 
            for(Integer count=0;count<srList.size();count++){
                if(!srList.get(count).isSuccess()){
                    IdsToRemoveDel.add(newEmailidOldEmailid.get(conLinkInsertList.get(count).LinkedEntityId));
                }
            }
        }
        return IdsToRemoveDel;
    }
}