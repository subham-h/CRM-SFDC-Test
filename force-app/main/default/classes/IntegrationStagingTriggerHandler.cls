/*
 * Created By   : Shahanawaz@Maersk
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on Integration Staging trigger.
 *              
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      #SC-8789   22-Sept-2023  Shahanawaz@Maersk      Trigger Handler on Integration Staging Object
 * 
*/
public class IntegrationStagingTriggerHandler extends TriggerHandler {
    
    public map<Id, Integration_Staging__c> newMap;
    public map<Id, Integration_Staging__c> oldMap;
    public IntegrationStagingTriggerHandler() {
        this.newMap = (map<Id, Integration_Staging__c>)Trigger.newMap;
        this.oldMap = (map<Id, Integration_Staging__c>)Trigger.oldMap;
    }
    
    public IntegrationStagingRecordSelector insRecordSelector;
    
    public override void getRecordSelector() {
        insRecordSelector = new IntegrationStagingRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onAfterUpdate(){
        if(!insRecordSelector.stagingRecordsMap.isEmpty()){
            IntegrationStagingTriggerHelper.processIntegrationResult(insRecordSelector.stagingRecordsMap);
        }
        
        if(!insRecordSelector.caseListToOmniRoute.isEmpty()){
            CaseOmniSkillBasedRouting.defineCaseSkillMap(insRecordSelector.caseListToOmniRoute, insRecordSelector.mapRelatedCareRelations,insRecordSelector.mapKeyClients, false, false, null, new Map<Id,Case>());
        }
    }
}