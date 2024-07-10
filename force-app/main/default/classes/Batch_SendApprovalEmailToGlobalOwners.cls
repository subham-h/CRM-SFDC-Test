public class Batch_SendApprovalEmailToGlobalOwners implements Database.Batchable<sObject>,Database.Stateful{
    
    private String targetId;
    private Boolean isReadAccess;
    
    public Batch_SendApprovalEmailToGlobalOwners(String targetId,Boolean isReadAccess) {
        this.targetId = targetId;
        this.isReadAccess = isReadAccess;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        String query = 'SELECT Id,Global_Account_Owner__c, Global_Account_Owner_Email__c FROM Target_Item__c WHERE Target__c = :targetId AND Global_Account_Owner__c != NULL';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Target_Item__c> targetItemList){
        List<Target_Item__Share> lstItemShare = new List<Target_Item__Share>();
        if(!isReadAccess){
            List<String> emailAddressList = new List<String>();
            for (Target_Item__c item : targetItemList) {
                emailAddressList.add(item.Global_Account_Owner_Email__c);
            }
            
            Batch_UpdateSalesTargetItemStageHelper.createEmail(emailAddressList, targetId);   
        }else{
            for (Target_Item__c item : targetItemList){
                Target_Item__Share itemShare = new Target_Item__Share();
                itemShare.AccessLevel = 'Read';
                itemShare.ParentId = item.Id;
                itemShare.UserOrGroupId = item.Global_Account_Owner__c;
                lstItemShare.add(itemShare);
                if(!lstItemShare.isEmpty()){
                    List<Database.upsertResult > listSaveResult = Database.upsert(lstItemShare, false);
                    ErrorLogger.writeErrors('SFDC', 'Item Sharing Update', 'SharingHelper', listSaveResult, lstItemShare);
                }
            }
        }
        
    }
    
    public void finish(Database.BatchableContext bc) {
        
    }
    
}