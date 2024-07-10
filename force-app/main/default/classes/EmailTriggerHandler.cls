/*
 * Author   : Manohar@maersk
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on EmailObject trigger.
 * 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-2143   24-Mar-2020   Manohar@maersk         Created for moving workflows on email to trigger.
 * 2.0      SC-5430   22-Nov-2022   Vivek@Maersk           Added call to class FilesIntegrationWithIDA
 * 3.0      SC-8488   20-July-2023  Vivek@Maersk           Added call to class IDAIntegrationForEmailRecommendation
 * 4.0      SC-9942   17-Apr-2024   Shahanawaz@Maersk      SCM (Internal & Customer) Email Communication

*/
public class EmailTriggerHandler extends TriggerHandler{
    
    public List<EmailMessage> emails;
    
    public EmailRecordSelector emailRecSelector;
     public map<Id, EmailMessage> newMap;
    public map<Id, EmailMessage> oldMap=new Map<Id,EmailMessage>();
    public EmailTriggerHandler() {
    }
    
    public override void getRecordSelector() {
        emailRecSelector = new EmailRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onAfterInsert() {
        RelatedCaseFieldUpdator.updateCaseFields(emailRecSelector);
        
        //SC-9942 
        if(General_Settings__c.getInstance() != null && !General_Settings__c.getInstance().Disable_SCM_Scenarios__c && !EmailRecordSelector.stopSCMCollaborationFlow){
            RelatedCaseFieldUpdator.createCollaborationTaskForSCM(emailRecSelector);
        }
        //SC-5430
        if(General_Settings__c.getInstance() != null && !General_Settings__c.getInstance().Disable_IDA_File_Extraction__c){
            FilesIntegrationWithIDA.fetchEmailMessageDetails(emailRecSelector);
        } 
         //SC-8488 call to send case details for Email recommendations api        
        if(General_Settings__c.getInstance() != null && !General_Settings__c.getInstance().Disable_IDA_Email_Recommendation_Int__c){
            
            IDAIntegrationForEmailRecommendation.fetchEmailAndCaseDetails(emailRecSelector);
        }

    }  
}