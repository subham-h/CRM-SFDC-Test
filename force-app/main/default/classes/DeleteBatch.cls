/**
* @author Jessica Bernal, Andres Canavesi
* @description Batch for deleting huge amounts of records. It also deletes the records from the recycle bin
* @date 2017-01
*/
global class DeleteBatch implements Database.Batchable<sObject>, Database.stateful {
    
    /**
    * @description the query to get the records to delete
    */
    public String query;
    private final String objectName;
    public Integer totalDeleted = 0;
    public List<Id> listAttachmentsFail = new List<Id>();
    public String errors = '';
    
    global DeleteBatch(String query, String objectName){
        if(objectName != null){
            //we are in a bulk migration context
            AttachmentConversionStatus.changeToInProgressByObjectNameDeletion(objectName);
        } 
        this.query = query;
        this.objectName = objectName;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        if(scope.size() > 0){
            if (scope.getSObjectType().getDescribe().isDeletable()) {  
                Integer idsFails = 0;
                Integer idsSuccess = 0;
                Integer counter = 0;
                List<sObject> attachmentsSuccess = new List<sObject>();
                Database.DeleteResult[] srList = Database.delete(scope, false);
                for (Database.DeleteResult sr : srList) {
                    if (sr.isSuccess()) {
                        idsSuccess++;
                        attachmentsSuccess.add(scope.get(counter));
                        
                    }else{
                        idsFails++; 
                        listAttachmentsFail.add(scope.get(counter).Id);
                        for(Database.Error err : sr.getErrors()) {
                            if(listAttachmentsFail.size() <= Utils.NUMBER_ERRORS){
                             errors += scope.get(counter).Id + ' - ' + err.getStatusCode() + ': '+ err.getMessage() +'<br/>'; 
                            }
                            
                        } 
                    }    
                    counter++;
                }
                totalDeleted += attachmentsSuccess.size();
                try{
                    if(attachmentsSuccess.size() > 0){
                        DataBase.emptyRecycleBin(attachmentsSuccess); 
                    }
                    
                }catch(Exception e){
                    System.debug('Something went wrong trying to delete attachments from Recycle Bin');                
                }
                
                
                
                // delete scope;
                //DataBase.emptyRecycleBin(scope);
                // totalDeleted += scope.size();
            }else{
                system.debug('DeleteBatch class - access');
                throw new ForbiddenException('DeleteBatch class - access ERROR: isDeletable() for Object - objectType.getSObjectType().getDescribe().isDeletable()');
                
            }
        }        
    }
    
    global void finish(Database.BatchableContext BC){ 
        if(objectName != null){
                AttachmentConversionStatus.changeToCompletedByObjectNameDeletion(objectName);
            }
         
        String subjectEmail = 'Your '+ objectName +' attachments were deleted';        
        String signature = '<br/><br/><br/>Salesforce';
        String footer = 'You’re registered as '+UserInfo.getUserEmail()+' in the Salesforce org '+UserInfo.getOrganizationName()+'. Need help? Contact Salesforce Support.';
        String name = UserInfo.getFirstName();
        String emailReport = '';
        if(name != null){
            emailReport = '<p>Hello '+UserInfo.getFirstName()+',</p>';
        }else{
            emailReport = '<p>Hello '+UserInfo.getLastName()+',</p>';
        }    
        
        Integer deleteError = listAttachmentsFail.size();
        emailReport += '<div>' + totalDeleted + ' ' + objectName +' attachments were deleted from your org.</div><br>';
        if(deleteError > 0){
            emailReport += '<br>These attachments could not be deleted: <br>' + errors;
            subjectEmail = 'Some '+ objectName +' attachments have been deleted. Please open for errors.';            
        }
        
        try{
            //send an email to the user with the result of the deletion.
            Utils.sendMailWithHTML(UserInfo.getUserId(), subjectEmail, emailReport, signature, footer);
        }catch(Exception e){
            System.debug('ERROR sending the email. '+e);
        }        
        
        
    }
}