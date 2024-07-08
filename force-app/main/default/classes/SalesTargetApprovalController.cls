/*              
* Revision Ref Number  Date          Owner                   Description
* -------- ----------  -----------   -----------------       -----------
* 1.0      SFSE-11482   03-Oct-2023   Vinay                  Created.
* 2.0      SFSE-13231   07-Nov-2023   Shubham                Custom Permission Check Added for STS Admin's
* 3.0      SFSE-13353   23-Nov-2023   Shubham                Added check if all Sales target Approval User records are marked as approved 
* 4.0      SFSE-13332   24-Nov-2023   Aditi                  Added condition to check the current user is Level 1 approver - Area Head of Sales Channel Verticalized 
                                                            and mark all Sales Target Approval User records available for the current user setup for the stage as Approved.
*/
public with sharing class SalesTargetApprovalController {
    
    @AuraEnabled    
    public static String validateCurrentUser(String salesTargetId){
        
        String returnStatus = '';
        
        Target__c target = [SELECT Id, Review_Stage__c,Status__c FROM Target__c WHERE Id=: salesTargetId];
        
        if(target.Status__c != TargetSettingConstants.STATUS_IN_PROGRESS) {            
            returnStatus='StatusisNotInProgress';
        } else {
            Boolean hasPermission = FeatureManagement.checkPermission('Sales_Target_Admin');
            if (!hasPermission || Test.isRunningTest()) {
                if(target.Review_Stage__c == TargetSettingConstants.APPROVAL_STAGE_2){
                    
                    List<Target_Item__c> targetItemsList = [SELECT Id, Review_Stage__c, Global_Account_Owner__c FROM Target_Item__c 
                                                            WHERE  Target__c =:salesTargetId AND 
                                                            Global_Account_Owner__c = :String.valueOf(UserInfo.getUserId()).substring(0, 15) LIMIT 1];
                    
                    if(targetItemsList.size() == 0){
                        returnStatus = 'UnAuthorizedUser';  
                    }         
                } else {
                    List<Target_Reviewer__c> reviewers = [SELECT Id, Target_Approval_Matrix__r.Target_Stage__c FROM Target_Reviewer__c 
                                                          WHERE Target_Approval_Matrix__r.Target__c = :salesTargetId
                                                          AND Related_User__c = :UserInfo.getUserId()
                                                          AND Target_Approval_Matrix__r.Target_Stage__c = :target.Review_Stage__c];
                    if (reviewers.size() == 0){
                        returnStatus = 'UnAuthorizedUser'; 
                    }
                }
            }
           
            if (returnStatus == '') {
                List<Target_Reviewer__c> reviewers = [SELECT Id, Target_Approval_Matrix__r.Target_Stage__c FROM Target_Reviewer__c 
                                                      WHERE Target_Approval_Matrix__r.Target__c = :salesTargetId
                                                      AND Related_User__c = :UserInfo.getUserId()
                                                      AND Target_Approval_Matrix__r.Target_Stage__c = :target.Review_Stage__c AND Approved__c = false];
                if (reviewers.size() == 0 && !hasPermission) {
                    returnStatus = 'All items are updated with Target Stage';
                } 
                //SFSE-13332-start
                else if((target.Review_Stage__c == TargetSettingConstants.APPROVAL_STAGE_3 && !hasPermission && FeatureManagement.checkPermission(TargetSettingConstants.LEVEL1_APPROVER_PERMISSION_SET))|| Test.isRunningTest()){
                    returnStatus = 'Level 1 - approval';
                }   
                //SFSE-13332-end             
                else {
                    List<Target_Item__c> listTargetItems = [SELECT Id, Review_Stage__c, Global_Account_Owner__c FROM Target_Item__c 
                                                            WHERE Target__c = :salesTargetId AND Review_Stage__c != :target.Review_Stage__c LIMIT 1];
                    if(listTargetItems.size() > 0) {
                        returnStatus = 'Call batch';
                    } else {
                        returnStatus = 'All items are updated with Target Stage';
                    }   
                }                               
            }      
        }
        return returnStatus; 
    }
    
    //Added isInitiateBatch parameter - SFSE-13332
    @AuraEnabled
    public static void updateTargetItems(String salesTargetId, Boolean isInitiateBatch){        
        Target__c target = [SELECT Id,Review_Stage__c,Status__c FROM Target__c WHERE Id = :salesTargetId]; 
        if(isInitiateBatch)         
            Database.executeBatch(new Batch_UpdateSalesTargetItemStage(salesTargetId, target.Review_Stage__c), Integer.valueOf(Label.Items_Approval_Batch_Size));
        //SFSE-13332
        else{
            List<Target_Reviewer__c> reviewers = [SELECT Id, Target_Approval_Matrix__r.Target_Stage__c FROM Target_Reviewer__c 
                                                      WHERE Target_Approval_Matrix__r.Target__c = :salesTargetId
                                                      AND Related_User__c = :UserInfo.getUserId()
                                                      AND Target_Approval_Matrix__r.Target_Stage__c = :target.Review_Stage__c AND Approved__c = false];
            Batch_UpdateSalesTargetItemStageHelper.updateTargetApprover(reviewers);
        }
        
    }
}