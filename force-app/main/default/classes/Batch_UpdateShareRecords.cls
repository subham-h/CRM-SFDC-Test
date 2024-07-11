public class Batch_UpdateShareRecords implements Database.Batchable<sObject>{
    
    private String targetId;
    private String stageName;
    private String limitStr;

    
    public Batch_UpdateShareRecords(String targetId,String limitStr) {
        this.targetId = targetId;
        this.limitStr = limitStr;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        String query = 'Select Id,AccessLevel, UserOrGroupId , parentId,rowcause from Target_Item__Share where parent.target__c = :targetId AND rowcause = \'Manual\' AND AccessLevel = \'Edit\'' + limitStr ;
        
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Target_Item__Share> scope){
        Batch_UpdateShareRecordsQueueable bq = new Batch_UpdateShareRecordsQueueable(scope);
        System.enqueueJob(bq);
    }
    
    public void finish(Database.BatchableContext bc) {
        
    }
}