public class SalesTargetController {
    
    @AuraEnabled
    public static String createSalesTarget(Target__c target) {
        try {
            insert target;
            return target.Id;
        } catch (Exception ex) {
            AuraHandledException e = new AuraHandledException(ex.getMessage());
            throw e;
        }
    }
    
    @AuraEnabled
    public static String getTargetApprovalStage(String targetId) {
        return [SELECT Id, Review_Stage__c FROM Target__c WHERE Id = :targetId]?.Review_Stage__c;
    }
}