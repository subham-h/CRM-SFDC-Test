/*
* Author       : Shubham Jain
* Description  : Sales Target Helper Class
*        
* Revision  Ref Number  Date         Owner                 Description
* --------  ----------  -----------  -------------------   -----------
* 1.0                   24-09-2023   Shubham@Maersk        Created 
* 
*/
public inherited sharing class TargetTriggerHelper {
    
    public static Map<String,String> targetIdToCorIdMap = new Map<String,String>();
    public static Set<String> targetIdSet = new Set<String>();
    public static Integer BatchSize = Integer.ValueOf(LABEL.BatchShareSize);
    
    public static void checkValidations(List<Target__c> newList, Map<Id, Target__c> oldMap) {
        List<Target__c> filterList = checkForActiveTarget(newList,oldMap);
        stageValidation(filterList,oldMap);
    }
    
    public static List<Target__c> checkForActiveTarget(List<Target__c> newList, Map<Id, Target__c> oldMap) {
        
        Set<String> applicableYearSet = new Set<String>();
        Set<Id> targetIdSet = new Set<Id>();
        List<Target__c> filterTargetList = new List<Target__c>();
        List<Target__c> targetList = new List<Target__c>();
        
        for (Target__c target : newList) {
            if (oldMap == null || (oldMap != null && oldMap.get(target.Id).Status__c != target.Status__c)) {
                if (!applicableYearSet.contains(target.Applicable_year__c)) {
                    applicableYearSet.add(target.Applicable_year__c);
                    targetList.add(target);
                    if (oldMap != null) targetIdSet.add(target.Id);
                } else {
                    target.addError(LABEL.activeTargetPerYearError);
                }
            }
        }
        
        if(targetList.size() > 0) {
            Map<Id,Target__c> targetMap = new Map<Id,Target__c>([SELECT Id, Applicable_year__c FROM Target__c WHERE Applicable_year__c IN :applicableYearSet 
                                                                 AND Status__c != :TargetSettingConstants.TARGET_STATUS_CANCELLED]);
            Set<String> appYearSet = new Set<String>();
            for (Target__c target : targetMap.values()) {
                if (!(oldMap != null && targetIdSet.contains(target.Id))) {
                    appYearSet.add(target.Applicable_year__c);    
                }
            }
            for (Target__c target : targetList) {
                if (appYearSet.contains(target.Applicable_year__c)) {
                    target.addError(LABEL.activeTargetPerYearError);
                } else {
                    filterTargetList.add(target);
                }
            }   
        }
        
        return filterTargetList.size() > 0 ? filterTargetList : newList;
    }
    
    public static void stageValidation(List<Target__c> newList, Map<Id,Target__c> oldMap) {
        
        List<Target__c> targetList = new List<Target__c>();
        Set<String> dataLoadTypeSet = new Set<String>{};
            
            for (Target__c target : newList) {
                
                if (target.Stage__c != oldMap.get(target.Id).Stage__c) {
                    
                    if ((target.Stage__c == TargetSettingConstants.STAGE_INIT && target.Stage_Status__c != TargetSettingConstants.STAGE_STATUS_NEW) ||
                        (target.Stage__c == TargetSettingConstants.STAGE_EXCLUSIONS && oldMap.get(target.Id).Stage__c != TargetSettingConstants.STAGE_INIT) ||
                        (target.Stage__c == TargetSettingConstants.STAGE_BUDGET && oldMap.get(target.Id).Stage__c != TargetSettingConstants.STAGE_EXCLUSIONS) ||
                        (target.Stage__c == TargetSettingConstants.STAGE_PRE_CALCULATE_SALES && oldMap.get(target.Id).Stage__c != TargetSettingConstants.STAGE_BUDGET) ||
                        (target.Stage__c == TargetSettingConstants.STAGE_PIPELINE && oldMap.get(target.Id).Stage__c != TargetSettingConstants.STAGE_PRE_CALCULATE_SALES) ||
                        (target.Stage__c == TargetSettingConstants.STAGE_SETUP_CREATOR_AND_APPROVER && oldMap.get(target.Id).Stage__c != TargetSettingConstants.STAGE_PIPELINE) ||
                        (target.Stage__c == TargetSettingConstants.STAGE_COMPLETED && oldMap.get(target.Id).Stage__c != TargetSettingConstants.STAGE_SETUP_CREATOR_AND_APPROVER)) {
                            target.addError(LABEL.Target_Stage_Path_Error1);
                        }
                    else if ((target.Stage__c == TargetSettingConstants.STAGE_PRE_CALCULATE_SALES 
                              || target.Stage__c == TargetSettingConstants.STAGE_PIPELINE || target.Stage__c == TargetSettingConstants.STAGE_SETUP_CREATOR_AND_APPROVER 
                              || target.Stage_Status__c == TargetSettingConstants.STAGE_COMPLETED)
                             && target.Stage_Status__c != null && target.Stage_Status__c == TargetSettingConstants.STAGE_STATUS_IN_PROGRESS) {
                                 target.addError(LABEL.Target_Stage_Path_Error2);
                             }
                    else if (target.Stage__c == TargetSettingConstants.STAGE_EXCLUSIONS || target.Stage__c == TargetSettingConstants.STAGE_SETUP_CREATOR_AND_APPROVER) {
                        target.Stage_Status__c = TargetSettingConstants.STAGE_STATUS_IN_PROGRESS;
                    }
                    else if (target.Stage__c == TargetSettingConstants.STAGE_BUDGET || (target.Stage__c == TargetSettingConstants.STAGE_PRE_CALCULATE_SALES && target.Stage_Status__c == TargetSettingConstants.STAGE_STATUS_FAILED)) {
                        if (target.Stage__c == TargetSettingConstants.STAGE_PRE_CALCULATE_SALES && target.Stage_Status__c == TargetSettingConstants.STAGE_STATUS_FAILED) {
                            targetIdSet.add(target.Id);
                        }
                        target.Stage__c = TargetSettingConstants.STAGE_BUDGET;
                        targetList.add(target);
                        dataLoadTypeSet.add(TargetSettingConstants.DATA_LOAD_ROLLING_FORECAST);
                    } else if (target.Stage__c == TargetSettingConstants.STAGE_PRE_CALCULATE_SALES) {
                        targetList.add(target);
                        dataLoadTypeSet.add(TargetSettingConstants.DATA_LOAD_LAST_YEAR_ACTUALS);
                    }
                    else if (target.Stage__c == TargetSettingConstants.STAGE_COMPLETED) {
                        if (target.Stage_Status__c != TargetSettingConstants.STAGE_STATUS_COMPLETED) {
                            target.addError(LABEL.Target_Stage_Approval_Error);    
                        } else {
                            if (validateApprovalMatrix(target.Id)) {
                                target.Stage_Status__c = TargetSettingConstants.STAGE_STATUS_IN_PROGRESS;
                                target.Status__c = TargetSettingConstants.STATUS_IN_PROGRESS; 
                                target.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_1;
                            } else {
                                target.addError(LABEL.Target_Stage_Approval_Error);
                            }
                        }
                    }
                }
            }
        
        if (targetList.size() > 0) {
            List<Target_Data_Load__c> targetDataLoadList = [SELECT Id, Rofo_Version__c, Data_Load_Type__c, Correlation_Id__c FROM Target_Data_Load__c 
                                                            WHERE Status__c = :TargetSettingConstants.DATA_LOAD_STATUS_COMPLETED 
                                                            AND Data_Load_Type__c = :dataLoadTypeSet];
            Map<String,String> yearToCorRelationIdMap = new Map<String,String>();
            String key = '';
            for (Target_Data_Load__c dataLoad : targetDataLoadList) {
                if (dataLoad.Data_Load_Type__c == TargetSettingConstants.DATA_LOAD_ROLLING_FORECAST && String.isNotBlank(dataLoad.Rofo_Version__c) && dataLoad.Rofo_Version__c.contains(TargetSettingConstants.QUARTER_FOUR)) {
                    key = dataLoad.Data_Load_Type__c + '_' + dataLoad.Rofo_Version__c.right(4);
                    yearToCorRelationIdMap.put(key,dataLoad.Correlation_Id__c);
                } else if (dataLoad.Data_Load_Type__c == TargetSettingConstants.DATA_LOAD_LAST_YEAR_ACTUALS) {
                    key = dataLoad.Data_Load_Type__c;
                    yearToCorRelationIdMap.put(key,dataLoad.Correlation_Id__c);
                }
            }
            
            for (Target__c target : targetList) {
                key = '';
                if (target.Stage__c == TargetSettingConstants.STAGE_BUDGET) {
                    key = TargetSettingConstants.DATA_LOAD_ROLLING_FORECAST + '_' + (Integer.valueof(target.Applicable_Year__c) - 1);
                } else if (target.Stage__c == TargetSettingConstants.STAGE_PRE_CALCULATE_SALES) {
                    key = TargetSettingConstants.DATA_LOAD_LAST_YEAR_ACTUALS;
                }
                if (yearToCorRelationIdMap.containsKey(key)) {
                    targetIdToCorIdMap.put(target.Id, yearToCorRelationIdMap.get(key));
                } else if (target.Stage__c == TargetSettingConstants.STAGE_BUDGET) {
                    target.addError(LABEL.Target_Stage_Path_Budget_Error);
                } else if (target.Stage__c == TargetSettingConstants.STAGE_PRE_CALCULATE_SALES) {
                    target.addError(LABEL.Target_Stage_Path_Last_Yr_Actuals_Error);
                }
            }
        }
    }
    
    //This method is not for bulk upload of targets
    public static void updateStage(List<Target__c> newList, Map<Id,Target__c> oldMap) {
       
        for (Target__c target : newList) {
            if (target.Stage__c != oldMap.get(target.Id).Stage__c || targetIdSet.contains(target.Id)) {
                if (target.Stage__c == TargetSettingConstants.STAGE_BUDGET) {
                    String stagingStatus = TargetSettingConstants.STAGE_STATUS_NEW;
                    if (target.Stage_Status__c == TargetSettingConstants.STAGE_STATUS_FAILED) {
                        stagingStatus = TargetSettingConstants.STAGE_STATUS_FAILED;
                    }
                    TargetSettingBaseDataBatch bch = new TargetSettingBaseDataBatch(target.Id, TargetSettingConstants.QUERY_ID_BUDGET, 
                                                                                    targetIdToCorIdMap.get(target.Id), stagingStatus);
                    Database.executeBatch(bch, Integer.valueOf(Label.Target_Budget_Batch_Size));                    
                } else if (target.Stage__c == TargetSettingConstants.STAGE_PRE_CALCULATE_SALES) {
                    TargetSettingActualsLoadBatch bch = new TargetSettingActualsLoadBatch(target.Id, targetIdToCorIdMap.get(target.Id), TargetSettingConstants.QUERY_ID_PYACTUALS);
                    Database.executeBatch(bch, Integer.valueOf(Label.Target_Last_Yr_Actuals_Batch_Size));
                } else if (target.Stage__c == TargetSettingConstants.STAGE_PIPELINE) {
                    TargetSettingPipelineDataBatch bch = new TargetSettingPipelineDataBatch(target.Id);
                    DataBase.executeBatch(bch, Integer.valueOf(Label.Target_Pipeline_Batch_Size));
                }
            }
            if (target.Review_Stage__c != oldMap.get(target.Id).Review_Stage__c && target.Review_Stage__c == TargetSettingConstants.APPROVAL_STAGE_1) {
                Batch_ShareRecords batchContext = new Batch_ShareRecords(target.Id, null);
                Database.executeBatch(batchContext,BatchSize);
                Batch_UpdateSalesTargetItemStageHelper.sendReviewEmail(target.Id, target.Review_Stage__c);       
            }
        }
    }
    
    private static Boolean validateApprovalMatrix(String targetId) {
        List<Target_Reviewer__c> targetReviewList = [SELECT Id, Target_Approval_Matrix__r.Target_Stage__c FROM Target_Reviewer__c WHERE Target_Approval_Matrix__r.Target__c = :targetId];
        Set<String> approvalStageSet = new Set<String>();
        for (Target_Reviewer__c targetReview: targetReviewList) {
            if (targetReview.Target_Approval_Matrix__r.Target_Stage__c != null)
                approvalStageSet.add(targetReview.Target_Approval_Matrix__r.Target_Stage__c);
        }
        if (!(approvalStageSet.size() > 0 && 
              approvalStageSet.contains(TargetSettingConstants.APPROVAL_STAGE_1) && 
              approvalStageSet.contains(TargetSettingConstants.APPROVAL_STAGE_3) && 
              approvalStageSet.contains(TargetSettingConstants.APPROVAL_STAGE_4) &&
              approvalStageSet.contains(TargetSettingConstants.APPROVAL_STAGE_5) &&
              approvalStageSet.contains(TargetSettingConstants.APPROVAL_STAGE_6) &&
              approvalStageSet.contains(TargetSettingConstants.APPROVAL_STAGE_7) &&
              approvalStageSet.contains(TargetSettingConstants.APPROVAL_STAGE_8))) {
                  return false;
              }
        return true;
    }
    
}