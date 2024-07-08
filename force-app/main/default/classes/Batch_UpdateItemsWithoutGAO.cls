public class Batch_UpdateItemsWithoutGAO implements Database.Batchable<sObject>,Database.Stateful{
    
    private String targetId;
    private String stageName;
    
    public Batch_UpdateItemsWithoutGAO(String targetId, String stageName) {
        this.targetId = targetId;
        this.stageName = stageName;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        String query = 'SELECT Id, Review_Stage__c FROM Target_Item__c WHERE Target__c = :targetId AND Global_Account_Owner__c = NULL';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Target_Item__c> targetItemList){
        
        for (Target_Item__c item : targetItemList) {
            item.Review_Stage__c = stageName;
        }
        
        Database.SaveResult[] lstSaveResults = Database.update(targetItemList, false);
        ErrorLogger.writeErrors('SFDC', 'Target Items Update', 'Batch_UpdateItemsWithoutGAO', lstSaveResults, targetItemList);
    }
    
    public void finish(Database.BatchableContext bc) {
        
    }
}