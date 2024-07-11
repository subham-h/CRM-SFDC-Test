public without sharing class TargetSettingBatchQ4Update implements Database.Batchable<sObject> {
    private Id targetId { private get; private set; }

    public TargetSettingBatchQ4Update(Id targetId) {
        this.targetId = targetId;
    }

    public Database.QueryLocator start(Database.BatchableContext batchableCtx) {
        List<Target_Setting_Batch_Query__mdt> listQuery = [ SELECT Query__c
                                                            FROM Target_Setting_Batch_Query__mdt
                                                            WHERE DeveloperName = 'PY_ACTUALS_Q4' ];
        String queryString = String.format(listQuery.get(0).Query__c
            , new List<String>{ '\'' + this.targetId + '\'', '\'' + TargetSettingConstants.PY_ACTUALS + '\'' });
        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext batchableCtx, List<Target_Measure__c> listTargetMeasure) {
        // UPDATE EXPECTED Q4 ACTUALS FOR PY
        for (Target_Measure__c eachMeasure :listTargetMeasure) {
            eachMeasure.Jul__c = eachMeasure.Jul__c != null ? eachMeasure.Jul__c : 0;
            eachMeasure.Aug__c = eachMeasure.Aug__c != null ? eachMeasure.Aug__c : 0;
            eachMeasure.Sep__c = eachMeasure.Sep__c != null ? eachMeasure.Sep__c : 0;

            eachMeasure.Oct__c = ((eachMeasure.Jul__c + eachMeasure.Aug__c + eachMeasure.Sep__c)/3).setScale(2, System.RoundingMode.HALF_UP);
            eachMeasure.Nov__c = ((eachMeasure.Aug__c + eachMeasure.Sep__c + eachMeasure.Oct__c)/3).setScale(2, System.RoundingMode.HALF_UP);
            eachMeasure.Dec__c = ((eachMeasure.Sep__c + eachMeasure.Oct__c + eachMeasure.Nov__c)/3).setScale(2, System.RoundingMode.HALF_UP);
        }

        Database.update(listTargetMeasure);
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