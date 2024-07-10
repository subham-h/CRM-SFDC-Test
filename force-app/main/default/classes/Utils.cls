/*
* version       Date                Owner                                       Description
******************************************************************************************************************
* V1.0          03/10/2017         meghana.gupta@ust-global.com         RQ-007147 - Attachments to Files AppExchange product code          

*/

public class Utils {
    
     
    public static Integer SEND_ATTACHMENTS_ON_EMAIL = 25; //* if user is migratting less than this number then we send the list in the email.
    public static Integer NUMBER_ERRORS = 5;
    public static Integer BATCH_SIZE = 100;
    public static Boolean SHARETYPE_OBJECT_RESTRICTION_AS_V = true;
    
     /**
    * @description After a success migration we rename the attachments with the ContentVersion id (the file created). 
    * All migrated attachments start with this pattern. This way we are able to distinguish the migrated attachments
    */
    public static String MIGRATED_ATTACHMENTS_STARTS_WIDTH_PATTERN = '[068%';
    
    public static void sendMailWithHTML(Id address, String subject, String body, String signature, String footer) {
        
        // Create an email message object
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setTargetObjectId(address);
        mail.saveAsActivity = false;
        mail.setSubject(subject);
        String bodyemail = '<html><head></head><body>' + body +'<div><br/>' + signature +'<div><br/>' + '<footer>' + footer + '</footer></body></html>';
        system.debug('bodyemail');
        system.debug(bodyemail);
        
        mail.setHtmlBody(bodyemail);
        
        // Pass this email message to the built-in sendEmail method 
        // of the Messaging class
        Messaging.SendEmailResult[] results = Messaging.sendEmail(
            new Messaging.SingleEmailMessage[] { mail });
        
        // Call a helper method to inspect the returned results
        inspectResults(results);
    }
    
    /**
    * @description converts the attachments to a ContentVersion (CV). It does not save it, only returns a new instance of CV
    * @param attachment  the attachment to convert
    * @param bulkMigration true if we are ina context of bulk migration. 
    * Bulk migrations refers to a massive migration of ONLY public attachments
    * @return
    */ 
    public static ContentVersion convertToFile(Attachment attachment, Boolean bulkMigration) {
        ContentVersion file = new ContentVersion();
        if(Schema.sObjectType.ContentVersion.fields.PathOnClient.isCreateable()
           && Schema.sObjectType.ContentVersion.fields.Origin.isCreateable()
           && Schema.sObjectType.ContentVersion.fields.VersionData.isCreateable()
           && Schema.sObjectType.ContentVersion.fields.Description.isCreateable()
           && Schema.sObjectType.ContentVersion.fields.ContentModifiedDate.isCreateable()
           && Schema.sObjectType.ContentVersion.fields.VersionData.isUpdateable()
           && Schema.sObjectType.ContentVersion.fields.Description.isUpdateable()){
               
               file.PathOnClient = attachment.Name;
               file.Origin='H';
               file.VersionData = attachment.Body;
               file.Description = attachment.Description;
               file.ContentModifiedDate = attachment.LastModifiedDate;
               if(bulkMigration){
                   if(Schema.sObjectType.ContentVersion.fields.OwnerId.isCreateable()
                      && Schema.sObjectType.ContentVersion.fields.CreatedDate.isCreateable()
                      && Schema.sObjectType.ContentVersion.fields.CreatedById.isCreateable()
                      && Schema.sObjectType.ContentVersion.fields.LastModifiedById.isCreateable()
                      && Schema.sObjectType.ContentVersion.fields.LastModifiedDate.isCreateable()){
                          file.CreatedDate = attachment.CreatedDate;
                          file.OwnerId = attachment.OwnerId;
                          file.CreatedById = attachment.OwnerId;                
                          file.LastModifiedById = attachment.LastModifiedById;
                          file.LastModifiedDate = attachment.LastModifiedDate;
                      }else{
                          System.debug('ContentVersion - convertToFile access');
                          throw new ForbiddenException('ContentVersion - convertToFile access ERROR: OwnerId, CreatedById or CreatedDate not able to set');
                      }
               }else{
                   /*
                   * We are migrating private attachments. Most of the time the user won't have audit fields on, so 
                   * CreatedDate, and LastModifiedDate will be the current date.
                   */
               }
           }else{
               System.debug('ContentVersion - convertToFile access');
               throw new ForbiddenException('ContentVersion - convertToFile access ERROR: isCreateable() for PathOnClient, Origin, VersionData, Description, ContentModifiedDate or isUpdateable() for VersionData, Description');
           }        
        
        return file;
    }
    
    private static Boolean inspectResults(Messaging.SendEmailResult[] results) {
        Boolean sendResult = true;
        
        // sendEmail returns an array of result objects.   // Iterate through the list to inspect results. 
        // In this class, the methods send only one email, so we should have only one result.
        for (Messaging.SendEmailResult res : results) {
            if (res.isSuccess()) {
                System.debug('Email sent successfully.');
            }
            else {
                sendResult = false;
                System.debug('The following errors occurred: ' + res.getErrors());                 
            }
        }        
        return sendResult;
    }
    
    public static String createContentLinks(Map<Id, ContentVersion> mapToLink, Map<Id, Id> mapToLinkParent, String objectName, Integer errorCounter, List<Id> listAttachmentsFail){
        String errorsWithinLink = '';
        if (Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isCreateable()
            && Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable()
            && Schema.sObjectType.ContentDocumentLink.fields.ShareType.isCreateable()) {  
                Map<Id, Id> mapLink = new Map<Id, Id>();                
                //mapFileIdWithAttachmentId --> file(contentVersion) Id, Id of attahcment (used in case of contentDocumentLink error)           
                Map<Id, Id> mapFileIdWithAttachmentId = new Map<Id, Id>();
                //Like File at this point dont have the info ContentDocumentId we need to create an aux map so we can link later 
                //mapFileContentDocumentIdWithAttachmentId ---> contentDocumentId of file(ContentVersion), id of attachment to add to error msg
                Map<Id, Id> mapFileContentDocumentIdWithAttachmentId = new Map<Id, Id>();
                List<Id> fileIds = new List<Id>();
                for (Id attachmentId : mapToLink.keySet() ){
                    Id fileId = mapToLink.get(attachmentId).Id;
                    Id fileContentDocumentId = mapToLink.get(attachmentId).ContentDocumentId;
                    Id attachmentParentId = mapToLinkParent.get(attachmentId);
                    if(fileId != null && attachmentParentId != null){
                        mapLink.put(fileId, attachmentParentId);  
                        fileIds.add(fileId);
                        mapFileIdWithAttachmentId.put(fileId, attachmentId);
                    }                        
                }
                List<ContentDocumentLink> contentLinkToSave = new List<ContentDocumentLink>();  
                List<ContentVersion> listOfFilesWithDocData = [SELECT Id, ContentDocumentId, ContentSize  
                                                               FROM ContentVersion 
                                                               WHERE Id in :fileIds];
                
                
                for(ContentVersion file: listOfFilesWithDocData){
                    ContentVersion cv = file;
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = cv.ContentDocumentId;
                    mapFileContentDocumentIdWithAttachmentId.put(cv.ContentDocumentId, mapFileIdWithAttachmentId.get(cv.Id));
                    cdl.LinkedEntityId = mapLink.get(cv.Id);
                    if(SHARETYPE_OBJECT_RESTRICTION_AS_V && (objectName == 'Product2' || objectName == 'Quote' || objectName == 'Solution')){
                        cdl.ShareType = 'V'; 
                    }else{
                        cdl.ShareType = 'I'; 
                    }                    
                    cdl.Visibility = 'AllUsers';
                    contentLinkToSave.add(cdl);
            }
            
            // insert contentLinkToSave;                
            Integer counter = 0;
            Database.SaveResult[] srList = Database.insert(contentLinkToSave, false);               
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    ContentDocumentLink cdl = contentLinkToSave.get(counter);
                    Id fileId = cdl.ContentDocumentId;                                
                    Id attachmentId = mapFileContentDocumentIdWithAttachmentId.get(fileId);
                    listAttachmentsFail.add(attachmentId);                        
                    for(Database.Error err : sr.getErrors()) { 
                        if(errorCounter < Utils.NUMBER_ERRORS){                               
                            errorsWithinLink += '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() +'/'
                                +attachmentId + '">'+ attachmentId +'</a> - ' + err.getStatusCode() + ': '+ err.getMessage() +'<br/>';   
                            errorCounter++; 
                        }    
                        
                    }     
                  
                }
                counter++;
            }               
        }else{
            system.debug('ContentDocumentLink - createContentLinks access / You have insufficient permission to insert a ContentDocumentLink');
            throw new ForbiddenException('You have insufficient permission to insert a ContentDocumentLink');
            
        }       
        return errorsWithinLink;
    }  
        
    /**
    * @description This method takes the list of attachments and the map with the attachment Id and file create for it (contentversion)
    * and calls the transformNames method to retrive the new name (put the file id (ContentVersion Id) on the begining of the name) 
    * @param mapToLink 
    * @param attachments 
    */
    public static void changeNames(Map<Id, ContentVersion> mapToLink, List<Attachment> attachments){
        String newName = '';
        for (Attachment attachment : attachments){
            if(mapToLink.get(attachment.Id).Id != null){                
                newName = transformNames(mapToLink.get(attachment.Id).Id, attachment.Name);  
                attachment.Name = newName; 
            }
        }
    }
    
    /**
    * @description used to create the new name (put the file id (ContentVersion Id) on the begining of the name) 
    * @param contentVersionId 
    * @param nameAttachment 
    * @return
    */
    public static String transformNames(Id contentVersionId, String nameAttachment){
        String contentVersionIdString = '';
        contentVersionIdString = contentVersionId;
        return '[' + contentVersionIdString.substring(0,15) +']' + ' ' + nameAttachment;
        
    }
    
}