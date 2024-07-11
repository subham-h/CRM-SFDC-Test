/*
 * Revision Ref Number    Date          Owner                Description
 * -------- ----------   -----------  -------------------   --------------------------------------------------------
 * 1.0      SFSE-11402   04-04-2024     Vinay                Purge existing Actual records.
 */

public class BatchToPurgeCYActuals implements Database.Batchable<sObject>{
    
    private String applicableYear { private get; private set; }
    private String corelationId { private get; private set; }
    private String loadType { private get; private set; }
    
    // CONSTRUCTOR
    public BatchToPurgeCYActuals(String applicableYr, String corelationId, String loadType) {
        this.applicableYear = applicableYr;
        this.corelationId = corelationId;
        this.loadType = loadType;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
     List<Target_Setting_Batch_Query__mdt> listQuery = [SELECT Query__c FROM Target_Setting_Batch_Query__mdt WHERE DeveloperName =: TargetSettingConstants.PURGE_STR];
     return Database.getQueryLocator(listQuery.get(0).Query__c);  
    }
    
    public void execute(Database.BatchableContext bc, List<Target_Measure__c> measuresList){
           Database.DeleteResult[] results = Database.delete(measuresList, FALSE);
           ErrorLogger.writeErrors('SFDC', 'Sales Target', 'BatchToPurgeCYActuals.execute()', results, measuresList);	
    }
    
    public void finish(Database.BatchableContext bc){
        
        List<Target__c> salesTarget = [SELECT Id FROM Target__c WHERE Applicable_Year__c=:applicableYear AND Status__c!=: TargetSettingConstants.TARGET_STATUS_CANCELLED  LIMIT 1];
        if(!salesTarget.isEmpty()){
            Database.executeBatch(new TargetSettingActualsLoadBatch(salesTarget[0].Id,corelationId,loadType), Integer.valueOf(Target_Setting_Batch_Query__mdt.getInstance('CY_ACTUALS').Batch_Size__c));     
    }}
}