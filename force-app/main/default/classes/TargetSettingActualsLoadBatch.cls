public without sharing class TargetSettingActualsLoadBatch implements Database.Batchable<sObject> {
    private String targetId { private get; private set; }
    private String corelationId { private get; private set; }
    private String loadType { private get; private set; }
    
    // CONSTRUCTOR
    public TargetSettingActualsLoadBatch(String targetId, String corelationId, String loadType) {
        this.targetId = targetId;
        this.corelationId = corelationId;
        this.loadType = loadType;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<Target_Setting_Batch_Query__mdt> listQuery = [ SELECT Query__c
                                                            FROM Target_Setting_Batch_Query__mdt
                                                            WHERE DeveloperName = :this.loadType ];
        String queryString = String.format(listQuery.get(0).Query__c
            , new List<String>{ '\'' + this.corelationId + '\'' });
		return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext batchContext, List<Target_Setting_Staging__c> listIncomingStaging) {
        // COLLECT STAGING BY ITEM UNIQUE ID BY MEASUERE TYPE
        Set<String> setTargetItemId = new Set<String>();
        Set<String> setTargetItemIdForOverrides = new Set<String>();
        // CURRENT CONTEXT FROM STAGING WHICH WILL BE INCLUDED WITH DB DATA
        Map<String, List<Target_Setting_Staging__c>> mapStagingByGroupIdentifier = new Map<String, List<Target_Setting_Staging__c>>();
        // COLLECT STAGING IDs FOR ITEM ERROR HANDLING
        Map<String, Set<String>> mapStagingIdByItemUId = new Map<String, Set<String>>();

        System.debug('Line 31 Current Heap Size ' + Limits.getHeapSize());
        
        //SFSE-11402 - Creates Budget Groups if doesnt exists for the given TargetId.
        TargetSettingBatchHelper.createBudgetGroups(listIncomingStaging, this.targetId);
        
        // COLLECT STAGING DATA BY UNIQUE IDENTIFIER
        TargetSettingBatchHelper.getStagingByGroupUniqueId(listIncomingStaging
            , this.targetId, mapStagingByGroupIdentifier, setTargetItemId, mapStagingIdByItemUId);
        
        

        // GET MEASURES IF ALREADY EXISTS FOR INCOMING ITEM GROUPS
        Map<String, Map<String, Target_Measure__c>> mapMeasureByMeasureIdByItemIdContext = TargetSettingBatchHelper.getExistingMeasures(setTargetItemId);
           System.debug('mapMeasureByMeasureIdByItemIdContext' + mapMeasureByMeasureIdByItemIdContext.values());
        // CLEAR DS
      
        
        setTargetItemId.clear();
        setTargetItemIdForOverrides.clear();

        

          Map<String,Target_Item__c> mapUpsertTIWithOverrides = new Map<String,Target_Item__c>();
        // COLLECT ITEM AND MEASURE DATA FOR DMLs
        Map<String, Target_Item__c> mapUpsertTargetItem = TargetSettingBatchHelper.getItemsAndMeasuresForDml(mapMeasureByMeasureIdByItemIdContext, mapStagingByGroupIdentifier);
       
       System.debug('map values' + mapUpsertTargetItem.values());
        List<Target_Item__c> listTargetItem = mapUpsertTargetItem.values();

        

        // UPDATE/CREATE TARGET ITEM AND HANDLE DML FAILURES
        List<Target_Setting_Staging__c> listStagingUpdate;
        if (!listTargetItem.isEmpty()) {
            listStagingUpdate = TargetSettingBatchHelper.upsertAndvalidateTargetItems(
                listTargetItem, mapStagingIdByItemUId , mapMeasureByMeasureIdByItemIdContext);
        }
        mapUpsertTargetItem.clear();
        listTargetItem.clear();

        
        
        // UPDATE/CREATE MEASURES
        List<Target_Measure__c> listUpsertTargetMeasure = new List<Target_Measure__c>();
     
        for (String eachItemId :mapMeasureByMeasureIdByItemIdContext.keySet()) {
            System.debug('eachitemId'+ eachItemId );
            for (String eachMeasureId :mapMeasureByMeasureIdByItemIdContext.get(eachItemId).keySet()) {
                  
                listUpsertTargetMeasure.add(mapMeasureByMeasureIdByItemIdContext.get(eachItemId).get(eachMeasureId));
            }
        }

        
        
        // SKIP MEASURE AND ITEM TRIGGER
        TriggerExecutionController.isMeasureTriggerSkip = false;
        TriggerExecutionController.isTargetItemTriggerSkip = true;
        if (!listUpsertTargetMeasure.isEmpty()) {
            // UPDATE/CREATE MEASURES
            Database.upsert(listUpsertTargetMeasure, false);
            
            
            // TODO: MEASURE ERROR HANDLING - CURRENT ASSUMPTION IS: MEASURE DML WILL NOT FAIL
        }

        

        if (listStagingUpdate != null && !listStagingUpdate.isEmpty()) {
            // UPDATE STAGING
            Database.update(listStagingUpdate, false);
        }
        
       
    }

    public void finish(Database.BatchableContext bc) {
        // TODO: CALL TARGET BATCH WITH EMAIL FUNCTIONALITY
        // TODO: CONFIGURE BATCH SIZE IN QUERY CUSTOM METADATA TYPE
        //TargetSettingCreateTargetsBatch targetBatch = new TargetSettingCreateTargetsBatch(targetId, false);
        //Database.executeBatch(targetBatch, 2000);
        List<Target__c> lTargetRecord = [ SELECT Id, Owner.Email FROM Target__c WHERE Id = :targetId LIMIT 1 ];
        if (!lTargetRecord.isEmpty()) {
            TargetSettingBatchHelper.sendEmail(TargetSettingConstants.STAGE_STATUS_COMPLETED, TargetSettingConstants.TARGET, lTargetRecord.get(0).Owner.Email);
        }
    }
}