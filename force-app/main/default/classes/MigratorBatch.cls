/**
* @author Jessica Bernal, Andres Canavesi
* @description Batch process for running the migration in a huge collection of data. 
* Depending on the constructor parameters will migrate public or private attachments (never both at the same time)
*/ 
global with sharing class MigratorBatch implements Database.Batchable<sObject>, Database.stateful{    
    
    private final String objectName;
    private final Boolean deleteAfterMigration;
    /**
    * @description attachments ids to migrate. Will be private attachments since this list is given by MyPrivateAttachments page
    */
    private final List<String> listIds;
    private final Integer totalToMigrate;    
    public Integer totalRecords = 0;
    public Integer totalFiles = 0;
    public Integer totalFilesFailed = 0;
    public Integer recordsBatch = 0;
    public String insertErrorMsg = '';
    /**
    * @description true if the context is a bulk migration (public attachments migration)
    */
    public Boolean bulkMigration = true;
    public Integer errorCounter = 0;
    
    public String errors = '';
    
    /**
    * @description a flag to know if and error related to org limits has occurred
    * we have to do this way since LimitException can't be caught
    */
    public Boolean limitError = false;
    public List<Id> listAttachmentsFail = new List<Id>();
    public String attachmentsMigrated ='';
    
    /**
    * @param objectName the parent type of the attachments to migrate (Account, Contact, etc.)
    * @param deleteAfterMigration true to delete attachments after success migration.
    * @param totalToMigrate
    * @param listIds attachments ids to migrate. If not null we are ina private attachments migration context
    */
    public MigratorBatch(String objectName, Boolean deleteAfterMigration, Integer totalToMigrate, List<String> listIds){
        this.objectName = objectName;
        this.totalToMigrate = totalToMigrate;        
        this.deleteAfterMigration = deleteAfterMigration;
        if(listIds != null){
            this.listIds = listIds;
            bulkMigration = false;            
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {        
        String query = 'SELECT Id, Name, Body, Description, ParentId, OwnerId, LastModifiedDate, CreatedDate, LastModifiedById FROM Attachment WHERE ';
        if(listIds == null){
            query += 'Parent.Type = \''+String.escapeSingleQuotes(this.objectName)+'\' AND IsPrivate = false ';
        }        
        if(listIds !=null){
            query += 'Id in :listIds ';            
        }        
        query += 'AND (NOT  Name LIKE \''+ Utils.MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN+'\') ';        
        if(totalToMigrate != null){
            query += ' ORDER BY ParentId ASC' + ' LIMIT '+ totalToMigrate;
        }        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Attachment> attachments){
        limitError = true;
        if(attachments.size() > 0){
            recordsBatch = attachments.size();
            totalRecords += attachments.size();
            migrateToFile(attachments, bulkMigration);
        } 
        
        /*
        * Since we cannot catch LimitException we did this workaround
        * When an error related to org limits ocurrs this line is not executed
        * after all jobs are completed the finish() method is executed and we can
        * warn the user through this flag.
        */
        limitError = false;
        
    }
    
    global void finish(Database.BatchableContext bc){
        try{
            if(listIds == null){
                emailSetupAndSend();
            }else{
                emailSetupAndSendUserPrivate();
            }
        }catch(Exception e){
            System.debug('Error sending the email when the migration has finished. '+e.getMessage());
        }finally{            
            if(objectName != null){
                AttachmentConversionStatus.changeToCompletedByObjectName(objectName);
            } else{
                AttachmentConversionStatus.changeToCompletedByRecordIds(listIds);
            }
        }
    }
    
    private void emailSetupAndSendUserPrivate(){
        String subjectEmail = 'Your private attachment conversion job has completed';
        String signature = '<br/><br/><br/>Salesforce';
        String footer = 'You’re registered as '+UserInfo.getUserEmail()+' in the Salesforce org '+UserInfo.getOrganizationName()+'. Need help? Contact Salesforce Support.';
        String name = UserInfo.getFirstName();
        String emailReport = '';
        if(name != null){
            emailReport = '<p>Hello '+UserInfo.getFirstName()+',</p>';
        }else{
            emailReport = '<p>Hello '+UserInfo.getLastName()+',</p>';
        }    
        
        if(totalFiles == 0 || limitError){
            totalFilesFailed = totalRecords - totalFiles;
        }else{
            totalFilesFailed = listAttachmentsFail.size();
        }
        if(totalFilesFailed > 0 || limitError){
            subjectEmail = 'Your private attachment conversion job has completed. Please open for errors.';               
        }
        
        emailReport += '<div>Your private attachments are converted to Salesforce Files, located in the Owned by Me filter of Files Home.<br/>'
            + 'Number of attachments: ' + totalRecords + '<br/>'+
            + 'Number of files created: ' + totalFiles + '<br/>'+
            + 'Number of errors: ' + totalFilesFailed + '<div>';
        emailReport += '<br/>These attachments were converted to files:<br/>' + attachmentsMigrated +'<br/>';
        
        if(limitError){
            emailReport += '<p>Your org has exceeded at least one daily limit, such as content publication limits or Apex limits. Please contact Salesforce support to resolve this issue. The limit will reset after 24 hours.<p>';           
            
        }
        else if(totalFilesFailed > 0){
            emailReport += '<br/>This is a sample of attachments that could not be converted: <br/>' + errors;
        }
        
        try{
            //send an email to the user with the result of the migration.
            Utils.sendMailWithHTML(UserInfo.getUserId(), subjectEmail, emailReport, signature, footer);
        }catch(Exception e){
            System.debug('ERROR sending the email. '+e);
        }                             
        
    }
    
    private void emailSetupAndSend(){        
        String subjectEmail = 'Your '+ objectName +' attachment conversion job has completed';
        String signature = '<br/><br/><br/>Salesforce';
        String footer = 'You’re registered as '+UserInfo.getUserEmail()+' in the Salesforce org '+UserInfo.getOrganizationName()+'. Need help? Contact Salesforce Support.';
        String name = UserInfo.getFirstName();
        String emailReport = '';
        if(name != null){
            emailReport = '<p>Hello '+UserInfo.getFirstName()+',</p>';
        }else{
            emailReport = '<p>Hello '+UserInfo.getLastName()+',</p>';
        }        
        if(totalFiles == 0 || limitError){
            totalFilesFailed = totalRecords - totalFiles;
        }else{
            totalFilesFailed = listAttachmentsFail.size();
        }
        if(totalFilesFailed > 0 || limitError){
            if(limitError){ 
                subjectEmail = 'Your '+ objectName +' attachment conversion job has completed, but you exceeded your daily limit. Please open for errors.';
            } else{
                if(errors.contains('STORAGE')){
                    subjectEmail = 'Your '+ objectName +' attachment conversion job has completed, but you exceeded your storage limit. Please open for errors.';
                } else{
                    subjectEmail = 'Your '+ objectName +' attachment conversion job has completed. Please open for errors.';             
                }
            }    
        }
        
        emailReport += '<div>The conversion of ' + objectName + ' attachments to Salesforce Files is complete.<br/>'
            + 'Number of attachments: ' + totalRecords + '<br/>'+
            + 'Number of files created: ' + totalFiles + '<br/>'+
            + 'Number of errors: ' + totalFilesFailed + '<div>';
        
        if(totalFiles == totalRecords){
            if(totalToMigrate <= Utils.SEND_ATTACHMENTS_ON_EMAIL){
                emailReport += '<br/>These attachments were converted to files:<br/>' + attachmentsMigrated;
            }
            emailReport += '<p>Since they are converted to files, these attachments can now be deleted.</p>'; 
        }else{
            if(limitError){
                emailReport += '<p>Your org has exceeded at least one daily limit, such as content publication limits or Apex limits. Please contact Salesforce support to resolve this issue. The limit will reset after 24 hours.<p>';
            }else{
                if(errors.contains('STORAGE')){
                    emailReport += '<p>Some attachments could not be converted because your org has exceeded the storage limit. Delete converted attachments or other files to free up storage space. <a href="https://help.salesforce.com/articleView?id=limits_storage_allocation.htm&type=0"  target = "_blank">Learn more</a></p>';
                } else{
                    emailReport += '<br/>This is a sample of attachments that could not be converted: <br/>' + errors;             
                }
                
            }
        }  
        
        try{
            //send an email to the user with the result of the migration.
            Utils.sendMailWithHTML(UserInfo.getUserId(), subjectEmail, emailReport, signature, footer);
        }catch(Exception e){
            System.debug('ERROR sending the email. '+e);
        }                   
        
    }
    
    private void migrateToFile(List<Attachment> attachments, Boolean bulkMigration) {
        if(attachments.size() > 0){
            //this is used to be able to call a rollback in case something goes wrong along the process 
            //when a rollback is executed, It is only for the current job, not for the whole migration
            Savepoint mySavePoint = Database.setSavepoint();            
            List<ContentVersion> filesToSave = new List<ContentVersion>();
            //the key is the attachment id This is for creating the CDL
            Map<Id, ContentVersion> mapToLink = new Map<Id, ContentVersion>();  
            //the key is the attachment id and the value is the attachments parent id
            Map<Id, Id> mapToLinkParent = new Map<Id, Id>();
            //the key is the attachment id This is for creating the CDL, we created an Aux one to remove the maps from the fails attachments when try to insert
            Map<Id, ContentVersion> mapToLinkAux = new Map<Id, ContentVersion>();  
            //the key is the attachment id and the value is the attachments parent id, we created an Aux one to remove the maps from the fails attachments when try to insert
            Map<Id, Id> mapToLinkParentAux = new Map<Id, Id>();
            for(Attachment attachment :attachments){
                ContentVersion file = Utils.convertToFile(attachment, bulkMigration);
                filesToSave.add(file);
                mapToLinkParent.put(attachment.Id, attachment.ParentId);
                mapToLink.put(attachment.Id, file);            
            } 
            
            //  insert filesToSave;
            //  totalFiles += filesToSave.size();
            Integer idsFails = 0;
            Integer idsSuccess = 0;
            Integer counter = 0;
            String attachmentsToFile = '';
            List<Id> attachmentsFailUpdate = new List<Id>();
            List<Attachment> attachmentsSuccess = new List<Attachment>(); 
            Database.SaveResult[] srList = Database.insert(filesToSave, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    idsSuccess++;
                    attachmentsSuccess.add(attachments.get(counter));
                    
                }else{
                    idsFails++; 
                    listAttachmentsFail.add(attachments.get(counter).Id);
                    
                    for(Database.Error err : sr.getErrors()) {
                        if(errorCounter < Utils.NUMBER_ERRORS){
                            errors += '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() +'/'+ attachments.get(counter).Id + '">'+ attachments.get(counter).Name +'</a> - ' + err.getStatusCode() + ': '+ err.getMessage() +'<br/>';                                                                                   
                            errorCounter++;
                        } 
                        
                    }                        
                    
                }    
                counter++;
            }
            if(idsFails < Utils.BATCH_SIZE && attachmentsSuccess.size() > 0){                    
                for (Attachment attachmentId : attachmentsSuccess){
                    if(mapToLinkAux.containsKey(attachmentId.Id)){
                        mapToLink.remove(attachmentId.Id);
                    }
                    if(mapToLinkParentAux.containsKey(attachmentId.Id)){
                        mapToLinkParent.remove(attachmentId.Id);
                    }
                }
                String errorsWithinLink = '';
                if(listIds == null){                    
                    errorsWithinLink = Utils.createContentLinks(mapToLink, mapToLinkParent, objectName, errorCounter, listAttachmentsFail);              
                }
                if(listIds == null && errorsWithinLink != ''){
                    errors += errorsWithinLink;
                    //in case something went wrong with the crate contentDocumentLink stuff we call a rollback so files arent created if we are unable to create link the migrated attahcments
                    System.debug(Logginglevel.ERROR, '[MigratorBatch.migrateToFile]: Error trying to insert contentDocumentLink. ');                                            
                    Database.rollback(mySavePoint); 
                    idsSuccess = 0;
                } else{ 
                    Utils.changeNames(mapToLink, attachmentsSuccess);                            
                    // update attachmentsSuccess;                    
                    counter = 0;
                    Database.SaveResult[] srListUpdate = Database.update(attachmentsSuccess, false);
                    system.debug('attachmentsSuccess');
                    system.debug(attachmentsSuccess);
                    for (Database.SaveResult sr : srListUpdate) {
                        if (!sr.isSuccess()) {
                            for(Database.Error err : sr.getErrors()) {
                                if(errorCounter < Utils.NUMBER_ERRORS){
                                    //we need to remove the id we added before so name of attachment is the correct when we rollback the process
                                   system.debug('counter Err');
                                    system.debug(counter);
                                    system.debug('new name');
                                    system.debug(attachmentsSuccess.get(counter).Name);
                                    String nameAttachment = attachmentsSuccess.get(counter).Name.substringAfter('] ');
                                    system.debug('nameAttachment');
                                    system.debug(nameAttachment);
                                    errors += '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() +'/'+ attachmentsSuccess.get(counter).Id + '">'+ nameAttachment +'</a> - ' + err.getStatusCode() + ': '+ err.getMessage() +'<br/>';                                   
                                    errorCounter++;   
                                    attachmentsFailUpdate.add(attachmentsSuccess.get(counter).Id); 
                                    
                                }           
                              listAttachmentsFail.add(attachmentsSuccess.get(counter).Id);  
                            }  
                        }   
                        counter++;
                    }
                    
                    if(attachmentsFailUpdate.size() > 0){                        
                        //in case something went wrong with the name change stuff we call a rollback so files arent created if we are unable to change the migrated attahcments names
                        System.debug(Logginglevel.ERROR, '[MigratorBatch.migrateToFile]: Error trying to update attachments names. ');                                            
                        Database.rollback(mySavePoint); 
                        idsSuccess = 0;
                    }                
                    
                    if(idsSuccess > 0){
                        if(listIds != null || totalToMigrate <= Utils.SEND_ATTACHMENTS_ON_EMAIL){                                
                            //lists the migrated attachments in the email
                            for(Attachment a : attachmentsSuccess){
                                attachmentsToFile += '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() +'/'+ a.Id + '">'+ a.Name +'</a> ---> ';
                                attachmentsToFile += '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() +'/'+ mapToLink.get(a.Id).Id + '">'+ mapToLink.get(a.Id).PathOnClient +'</a><br/>';
                            }                           
                        }
                        
                        totalFiles += idsSuccess;
                        attachmentsMigrated += attachmentsToFile;
                    }
                    
                }
                               
                
            }     
        }
    }    
    
}