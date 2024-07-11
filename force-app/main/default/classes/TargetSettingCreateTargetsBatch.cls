public without sharing class TargetSettingCreateTargetsBatch implements Database.Batchable<sObject> {
    private Id targetId { private get; private set; }
    private Boolean skipMeasureTrigger { private get; private set; }
    private Boolean aggregateExistingTargets { private get; private set; }

    public TargetSettingCreateTargetsBatch(Id targetId, Boolean skipMeasureTrigger, Boolean aggregateExistingTargets) {
        this.targetId = targetId;
        this.skipMeasureTrigger = skipMeasureTrigger;
        this.aggregateExistingTargets = aggregateExistingTargets;
    }

    public Database.QueryLocator start(Database.BatchableContext batchableCtx) {
        List<Target_Setting_Batch_Query__mdt> listQuery = [ SELECT Query__c
                                                            FROM Target_Setting_Batch_Query__mdt
                                                            WHERE DeveloperName = 'TARGET' ];
        String queryString = String.format(listQuery.get(0).Query__c
            , new List<String>{ '\'' + this.targetId + '\'', '\'' + TargetSettingConstants.PY_ACTUALS + '\'' });
        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext batchableCtx, List<Target_Measure__c> listTargetMeasure) {
        Set<Id> setTargetItemId = new Set<Id>();
        List<Target_Measure__c> listTargetMeasureUpsert = new List<Target_Measure__c>();
        Map<Id, Map<String, Set<Target_Measure__c>>> mapPyActualsByBudgetGrpId = new Map<Id, Map<String, Set<Target_Measure__c>>>();
        // GET PREVIOUS YEAR MEASURE BY BUDGET GROUP ID
        for (Target_Measure__c eachMeasure :listTargetMeasure) {
            TargetSettingBatchHelper.prepareMapByIdByMeasureType(eachMeasure.Target_Item__r.Sales_Target_Item_Group__r.Budget_Group__c, eachMeasure, mapPyActualsByBudgetGrpId);
            setTargetItemId.add(eachMeasure.Target_Item__c);
        }

        // GET EXISTING TARGET MEASURE BY PY MEASURE ID
        Map<Id, Target_Measure__c> mapTargetByPyId = TargetSettingBatchHelper.getTargetByPyId(setTargetItemId, TargetSettingConstants.TARGET);
        
        // CLEAR NO LONGER NEEDED
        setTargetItemId.clear();

        // CREATE / UPDATE TARGETS
        List<Target_Measure__c> listInsertUpdateTarget = TargetSettingBatchHelper.createTargetsFromPyActuals(mapPyActualsByBudgetGrpId, mapTargetByPyId, aggregateExistingTargets);
        
        // SKIP MEASURE TRIGGER
        TriggerExecutionController.isMeasureTriggerSkip = !this.skipMeasureTrigger;

        // LOG ERROR IN GLOBAL ERROR LOGGER
        ErrorLogger.writeErrors('SFDC', 'Target Update', 'TargetSettingCreateTargetsBatch'
            , Database.upsert(listInsertUpdateTarget, false)
            , new List<Target_Measure__c>(listInsertUpdateTarget));
    }

    public void finish(Database.BatchableContext batchableCtx) {
        List<Target__c> lTargetRecord = [ SELECT Id, Owner.Email FROM Target__c WHERE Id = :targetId LIMIT 1 ];
        if (!lTargetRecord.isEmpty()) {
            TargetSettingBatchHelper.sendEmail(TargetSettingConstants.STAGE_STATUS_FAILED, TargetSettingConstants.TARGET, lTargetRecord.get(0).Owner.Email);
        } else {
            TargetSettingBatchHelper.sendEmail(TargetSettingConstants.STAGE_STATUS_COMPLETED, TargetSettingConstants.TARGET, lTargetRecord.get(0).Owner.Email);
        }
    }
}