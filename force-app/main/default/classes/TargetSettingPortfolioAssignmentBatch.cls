public without sharing class TargetSettingPortfolioAssignmentBatch implements Database.Batchable<sObject>, Database.Stateful {
    private Id targetId { private get; private set; }

    public TargetSettingPortfolioAssignmentBatch(Id targetId) {
        this.targetId = targetId;
    }

    public Database.QueryLocator start(Database.BatchableContext batchableCtx) {
        List<Target_Setting_Batch_Query__mdt> listQuery = [ SELECT Query__c
                                                            FROM Target_Setting_Batch_Query__mdt
                                                            WHERE DeveloperName = 'PORTFOLIO_ASSIGNMENT' ];
        // TODO: MOVE STRING TO CONSTANTS CLASS
        String queryString = String.format(listQuery.get(0).Query__c
            , new List<String>{ '\'' + this.targetId + '\'', '\'' + 'Target' + '\'' });
      return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext batchableCtx, List<Target_Measure__c> listTargetMeasure) {
      
        TargetsAssignToSalesRep.getSalesTargetItemMeasure(listTargetMeasure);
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