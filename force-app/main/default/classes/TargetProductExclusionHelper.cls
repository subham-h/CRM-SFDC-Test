public class TargetProductExclusionHelper {
    
    public static void checkStageValidation(List<Target_Product_Exclusion__c> newList) {
        Set<Id> targetIdSet = new Set<Id>();
        List<RecordType> recordTypeList = [SELECT Id FROM RecordType WHERE DeveloperName = :TargetSettingConstants.TARGET_EXCLUSION_RECORD_TYPE];
        for(Target_Product_Exclusion__c prodExclusion : newList) {
            targetIdSet.add(prodExclusion.Target__c);
        }
        Map<Id,Target__c> targetMap = new Map<Id, Target__c>([SELECT Id, Stage__c FROM Target__c WHERE Id IN :targetIdSet]);
        for(Target_Product_Exclusion__c prodExclusion : newList) {
            if ((targetMap.containsKey(prodExclusion.Target__c) && recordTypeList.size() > 0 && recordTypeList[0].Id == prodExclusion.RecordTypeId &&
                 (targetMap.get(prodExclusion.Target__c).Stage__c != TargetSettingConstants.STAGE_INIT && 
                  targetMap.get(prodExclusion.Target__c).Stage__c != TargetSettingConstants.STAGE_EXCLUSIONS))) {
                      prodExclusion.addError(LABEL.Product_Exclusions_Error);
                  }
        }
    }
    
    public static void updateTargetStage(List<Target_Product_Exclusion__c> newList) {
        Set<Id> targetIdSet = new Set<Id>();
        List<RecordType> recordTypeList = [SELECT Id FROM RecordType WHERE DeveloperName = :TargetSettingConstants.TARGET_EXCLUSION_RECORD_TYPE];
        for(Target_Product_Exclusion__c prodExclusion : newList) {
            if (recordTypeList.size() > 0 && recordTypeList[0].Id == prodExclusion.RecordTypeId) {
            	targetIdSet.add(prodExclusion.Target__c);    
            }
        }
        
        List<Target__c> targetList = [SELECT Id, Stage__c FROM Target__c WHERE Id IN :targetIdSet and Stage__c != :TargetSettingConstants.STAGE_EXCLUSIONS AND Status__c = :TargetSettingConstants.STATUS_NEW];
        for(Target__c target : targetList) {
            target.Stage__c = TargetSettingConstants.STAGE_EXCLUSIONS;
            target.Stage_Status__c = TargetSettingConstants.STAGE_STATUS_IN_PROGRESS;
        }
        if (targetList.size() > 0) update targetList;
    }
    
}