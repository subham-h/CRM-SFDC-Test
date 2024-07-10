/*
 * Created By   : Shahanawaz@Maersk
 * Purpose  : Centralize the record selection process for Integration Staging object.
 *            Defines the methods which iterate and segregate the Integration Staging records for further use.
 *              
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      #SC-8789   22-Sept-2023  Shahanawaz@Maersk      Trigger Handler on Integration Results Object
 * 2.0		SC-10036	31-May-2024		Sid/Vazid/Kiran		Case WAIT for omni auto assignment
 * 
*/
public class IntegrationStagingRecordSelector implements RecordSelector{
    
    private TriggerHandler insTriggerHandler;
    public Map<Id, Integration_Staging__c> stagingRecordsMap = new Map<Id, Integration_Staging__c>();
    
    public set<Id> setKeyClientIds = new set<Id>();
    public map<Id, Case> caseMap = new map<Id, Case>();
    public set<Id> setCaseIds = new set<Id>();
    public Set<Id> setCareIds = new Set<Id>();
    public map<id, Care_Relationship__c> mapRelatedCareRelations = new map<id, Care_Relationship__c>();
    public map<id, Client_Case_Assignments__c> mapKeyClients = new map<id, Client_Case_Assignments__c>();
    public List<Case> caseListToOmniRoute = new List<Case>();
    
    public IntegrationStagingRecordSelector(list<Integration_Staging__c> insList, map<Id, Integration_Staging__c> oldMap, TriggerHandler insTriggerHandler) {
        this.insTriggerHandler = insTriggerHandler;
        
        for(Integration_Staging__c intStaging : insList){
            if(intStaging.Related_Record_Id__c != '' && intStaging.Related_Record_Id__c != null){
                setCaseIds.add(intStaging.Related_Record_Id__c);   
            }
        }
        
        getCaseDetails(setCaseIds);

        this.selectRecords(insList, oldMap);
    }
    
    public void selectRecords(list<Integration_Staging__c> insList, map<Id, sObject> mapOldInsRecords) {
        for (Integration_Staging__c newStagingRecord : insList) {
            if(insTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER){
                if(insTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                    Integration_Staging__c oldStagingRecord = (Integration_Staging__c)mapOldInsRecords.get(newStagingRecord.Id);
                    
                    // Check if the Roll-up Summary field (No of results processed) has changed
                    if (newStagingRecord.No_of_results_processed__c != oldStagingRecord.No_of_results_processed__c) {
                        if (newStagingRecord.No_of_results_processed__c == newStagingRecord.Operations_Count__c) {
                            stagingRecordsMap.put(newStagingRecord.Id, newStagingRecord);
                        }
                    }
                    
                    //Call omni assignments when IDA Status updated from Wait to "Proceed" for Non Gen2 cases
                    if (newStagingRecord.Wait_Status__c != oldStagingRecord.Wait_Status__c && newStagingRecord.Wait_Status__c == 'Proceed' && 
                        caseMap.containsKey(newStagingRecord.Related_Record_Id__c) && 
                        caseMap.get(newStagingRecord.Related_Record_Id__c).AI_Recommendation_Type__c != 'Resolution Recommendation' && 
                        caseMap.get(newStagingRecord.Related_Record_Id__c).AI_Recommendation_Status__c != 'On Hold'
                       ) {
                           caseListToOmniRoute.add(caseMap.get(newStagingRecord.Related_Record_Id__c));
                    }
                }
            }
        }
    }
    
    public void getCaseDetails(set<Id> setCaseIds) {
        
        Set<Id> carerelationshipidstoquery = new Set<id>();
        Set<String> shipmentNumberSet = new Set<String>();
        Set<Id> keyClientIdstoquery = new Set<id>();
        Map<String, Shipment__c> shipmentMap = new Map<string, Shipment__c>();
        if(!setCaseIds.isEmpty()){
            caseMap = new Map<Id, Case>([Select Id, CaseNumber, OwnerId, Subject, Description, Origin, Status, MLL__c, Cargo_Classification__c, Type, Sub_Type__c, 
                                         Case_Channel__c, Delivery_Channel__c, Case_Country__c, Shipment_Number__c, Care_Relationship__c, Omni_Skill_Type__c, 
                                         Value_Proposition__c, Product__c, Country__c,country__r.name, Account.Name, Account.SCV_Code__c, Care_Relationship_Business_Partner__c, 
                                         Backup_Agent__c,Care_Relationship_GSC_Agent__c,Owner.Name,Cargo_Flow__c,On_Behalf_Account__c,AccountId,Direction__c, AI_Recommendation_Type__c,
                                         Reason_For_Case__c, Short_Transit__c, Cargo_Type__c, AI_Recommendation_Status__c
                                         From Case Where Id In : setCaseIds]);
            for(case caseinput : caseMap.values()){
                if(caseinput.Care_Relationship__c != null){
                    carerelationshipidstoquery.add(caseinput.Care_Relationship__c);
                }
                if(caseinput.On_Behalf_Account__c!=null){
                    keyClientIdstoquery.add(caseinput.On_Behalf_Account__c);
                }
                else if(caseinput.On_Behalf_Account__c==null && caseinput.AccountId!=null){
                    keyClientIdstoquery.add(caseinput.AccountId);
                }
            }
            if(!carerelationshipidstoquery.isEmpty()){
                mapRelatedCareRelations = new map<id, Care_Relationship__c>([select Id, Care_Business_Partner__c,GSC_Agent__c,Frontline_backup__c, GSC_Backup_Agent__c from Care_Relationship__c where Id IN: carerelationshipidstoquery]);
            }
            if(!keyClientIdstoquery.isEmpty()){
                mapKeyClients = new map<id, Client_Case_Assignments__c>([select id, Active__c,Account__c, Direction__c,Country__c,Dedicated_Agent__c,Back_up_Dedicated_Agent__c from Client_Case_Assignments__c where Id in:keyClientIdstoquery]);
            }
            
        }
        
        
    }
    
    public void getRelatedRecords(list<Integration_Staging__c> insList) {
        
    }
    
}