public without sharing class TargetSettingBatchUpdateQueueable implements Queueable {
    private List<Target_Measure__c> listUpsertTargetMeasure { private get; private set; }
    private List<Target_Setting_Staging__c> listStagingUpdate { private get; private set; }
    
    public TargetSettingBatchUpdateQueueable(List<Target_Measure__c> listUpsertTargetMeasure
        , List<Target_Setting_Staging__c> listStagingUpdate) {
        this.listStagingUpdate = listStagingUpdate;
        this.listUpsertTargetMeasure = listUpsertTargetMeasure;
    }
    
    public void execute(QueueableContext qbContext) {
        if (this.listUpsertTargetMeasure != null) {
            TriggerExecutionController.isMeasureTriggerSkip = false;
            if (!listUpsertTargetMeasure.isEmpty()) {
                // UPDATE/CREATE MEASURES
                Database.upsert(listUpsertTargetMeasure, false);
                // TODO: MEASURE ERROR HANDLING - CURRENT ASSUMPTION IS: MEASURE DML WILL NOT FAIL
            }

            if (listStagingUpdate != null && !listStagingUpdate.isEmpty()) {
                // UPDATE STAGING
                Database.update(listStagingUpdate, false);
            }

        } else {
            if (this.listStagingUpdate != null && !this.listStagingUpdate.isEmpty()) {
                // UPDATE STAGING RECORDS
                Database.update(this.listStagingUpdate, false);
            }
        }
    }
}