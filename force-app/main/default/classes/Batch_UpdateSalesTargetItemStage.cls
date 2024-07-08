/*              
* Revision Ref Number  Date          Owner                  Description
* -------- ----------  -----------   -----------------      -----------
* 1.0      SFSE-11471  10-Oct-2023   Shubham                Batch class to approve items and share items records to STS approvers
* 2.0      SFSE-13353  23-Nov-2023   Shubham                Approval matrix - mark it as approved when approver with more than 1 matrix item approves
* 3.0      SFSE-13301  4-Jan-2024    Shubham                On admin approving, approval matrix items should show that the admin user has approved 
*/
public inherited sharing class Batch_UpdateSalesTargetItemStage implements Database.Batchable<sObject>,Database.Stateful{
    
    private String targetId;
    private String stageName;
    public Integer totalRecords = 0;
    public Integer successRecordsCount = 0;
    public Integer errorRecordsCount = 0;
    
    public Batch_UpdateSalesTargetItemStage(String targetId, String stageName) {
        this.targetId = targetId;
        this.stageName = stageName;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        String query = 'SELECT Id, Review_Stage__c FROM Target_Item__c WHERE Target__c = :targetId AND Review_Stage__c != :stageName';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Target_Item__c> scope){
        
        List<String> itemIdList = new List<String>();
        List<Target_Item__c> itemUpdateList = new List<Target_Item__c>();
        for (Target_Item__c item : scope) {
            itemIdList.add(item.Id);
        }
        
        Map<Id, UserRecordAccess> recordaccessMap = new Map<Id,UserRecordAccess>([SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() 
                                                                                  AND RecordId IN :itemIdList]);
        for (Target_Item__c item : scope) {
            if (recordaccessMap.containsKey(item.Id) && recordaccessMap.get(item.Id).HasEditAccess) {
                item.Review_Stage__c = stageName;
                itemUpdateList.add(item);
                totalRecords += 1;
            }
        }
        
        Database.SaveResult[] lstSaveResults = Database.update(itemUpdateList, false);
        ErrorLogger.writeErrors('SFDC', 'Target Items Update', 'Batch_UpdateSalesTargetItemStage', lstSaveResults, itemUpdateList);
        
        for(Integer i=0; i< lstSaveResults.size();i++) {
            if(!lstSaveResults[i].isSuccess()) {
                errorRecordsCount++;
            } else {
                successRecordsCount++;
            }
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        
        // When all Target Items are Approved then check Approved? field in Sales target Approval User Object.
        if (stageName != TargetSettingConstants.APPROVAL_STAGE_2) {
            if (totalRecords > 0 && errorRecordsCount == 0) {
                List<Target_Reviewer__c> approvalUserList = [SELECT Id FROM Target_Reviewer__c WHERE Target_Approval_Matrix__r.Target__c = :targetId
                                                             AND Related_User__c = :UserInfo.getUserId()
                                                             AND Target_Approval_Matrix__r.Target_Stage__c = :stageName and Target_Approval_Matrix__r.Target__c = :targetId];
                if(!approvalUserList.isEmpty()){
                    Batch_UpdateSalesTargetItemStageHelper.updateTargetApprover(approvalUserList);
                } else {
                    Boolean hasPermission = FeatureManagement.checkPermission('Sales_Target_Admin');
                    if (hasPermission) {
                        List<Target_Stage_Matrix__c> stageMatrixList = [SELECT Id FROM Target_Stage_Matrix__c WHERE Target_Stage__c = :stageName 
                                                                        AND Target__c = :targetId AND Area__c = null and Region__c = null 
                                                                        and Sales_Channel__c = null and Vertical__c = null];
                        Target_Stage_Matrix__c stageMatrix;
                        if (stageMatrixList.size() == 0) {
                            stageMatrix = new Target_Stage_Matrix__c();
                            stageMatrix.Target__c = targetId;
                            stageMatrix.Target_Stage__c = stageName;
                            insert stageMatrix;
                        } else {
                            stageMatrix = stageMatrixList[0];
                        }
                        Target_Reviewer__c reviewer = new Target_Reviewer__c();
                        reviewer.Target_Approval_Matrix__c = stageMatrix.Id;
                        reviewer.Related_User__c = UserInfo.getUserId();
                        reviewer.Approved__c = true;
                        insert reviewer;
                    }
                }    
            }  
        }
        
        if (Batch_UpdateSalesTargetItemStageHelper.checkApprovalStageUpdate(targetId, stageName)) {
            Target__c target = new Target__c(Id=targetId);
            if (stageName == TargetSettingConstants.APPROVAL_STAGE_1) {
                target.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_2;
            } else if (stageName == TargetSettingConstants.APPROVAL_STAGE_2) {
                target.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_3;
            } else if (stageName == TargetSettingConstants.APPROVAL_STAGE_3) {
                target.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_4;
            } else if (stageName == TargetSettingConstants.APPROVAL_STAGE_4) {
                target.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_5;
            } else if (stageName == TargetSettingConstants.APPROVAL_STAGE_5) {
                target.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_6;
            } else if (stageName == TargetSettingConstants.APPROVAL_STAGE_6) {
                target.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_7;
            } else if (stageName == TargetSettingConstants.APPROVAL_STAGE_7) {
                target.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_8;
            } else if (stageName == TargetSettingConstants.APPROVAL_STAGE_8) {
                target.Status__c = TargetSettingConstants.STATUS_ACTIVE;
            }
            try {
                Batch_UpdateSalesTargetItemStageHelper.updateTarget(target);
                
                //calling share batch after updating the status and before sending email
                if (stageName != TargetSettingConstants.APPROVAL_STAGE_8) {
                    Batch_ShareRecords batchContext = new Batch_ShareRecords(targetId, null);
                    Database.executeBatch(batchContext,Integer.valueOf(LABEL.BatchShareSize));    
                    Batch_UpdateSalesTargetItemStageHelper.sendReviewEmail(targetId, target.Review_Stage__c);
                } else {
                    //if the stage is 8 then give read access to all target items
                    //Batch_ShareTargetItemRecords batchContext = new Batch_ShareTargetItemRecords(targetId,true);
                    //Database.executeBatch(batchContext,Integer.valueOf(LABEL.BatchShareSize)); 
                    //if stage is 8 then give read access to global account owners
                    Batch_UpdateShareRecords bch = new Batch_UpdateShareRecords(targetId, 'LIMIT ' + LABEL.BatchShareSize);
                    Database.executeBatch(bch,Integer.valueOf(LABEL.BatchShareSize));  
                    Batch_SendApprovalEmailToGlobalOwners bcon = new Batch_SendApprovalEmailToGlobalOwners(targetId,true);
                    Database.executeBatch(bcon,Integer.valueOf(LABEL.BatchShareSize));   
                }
            } catch (Exception ex) {
                ErrorLogger.writeErrors('SFDC', 'Sales Target', 'Batch_UpdateSalesTargetItemStage', new List<Exception>{ex});
            }
        }
        if (totalRecords > 0) {
            sendBatchProcessingEmail();    
        }   
    } 
    
    private void sendBatchProcessingEmail() {
        String subject = 'Sales Target Items Approval Status';
        String body = '<html><body>Dear Approver,<br/><br/>Please find the Status of the Sales Target items';
        body += '<br/><br/>Total Number of Records : ' + totalRecords;
        body += '<br/>Total Number of Successful Records : ' + successRecordsCount;
        body += '<br/>Total Number of Failed Records : ' + errorRecordsCount;
        body += '<br/><br/>Please contact support for any failures.';
        body += '<br/><br/>Note: This is an automated email. Response to this email is not monitored.</body></html>';
        Batch_UpdateSalesTargetItemStageHelper.sendEmail(subject, body, new List<String>{UserInfo.getUserEmail()});
    }
    
}