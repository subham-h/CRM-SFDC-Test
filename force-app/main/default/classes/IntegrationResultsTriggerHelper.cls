/*
 * Created By   : Shahanawaz@Maersk
 * Purpose  : Utility class to hold simple and reusable functionalities for Integration Results trigger. 
 *              
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      #SC-8789   22-Sept-2023  Shahanawaz@Maersk      Trigger Handler on Integration Results Object
 * 
*/
public class IntegrationResultsTriggerHelper {
    
    public static void handleFutureCalls(List<Integration_Results__c> newIntegrationResults) {
        Set<Id> caseIdSet = new Set<Id>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Set<Id> stagingIds = new Set<Id>();
        Map<Id, Integration_Staging__c> stagingMap = new Map<Id, Integration_Staging__c>();
        
        for (Integration_Results__c integrationResult : newIntegrationResults) {
            if(integrationResult.Integration_Staging__c != null) {
                stagingIds.add(integrationResult.Integration_Staging__c);
            }
        }
        if(!stagingIds.isEmpty()){
            stagingMap = new Map<Id, Integration_Staging__c>([SELECT Id, Related_Record_Id__c FROM Integration_Staging__c WHERE Id IN :stagingIds]);
        }
        if(!stagingMap.isEmpty()){
            for(Integration_Staging__c ins : stagingMap.values()){
                if(ins.Related_Record_Id__c != null){
                    caseIdSet.add(ins.Related_Record_Id__c);
                }
            }
        }
        if(!caseIdSet.isEmpty()){
            caseMap = new Map<Id, Case>([SELECT Id, CaseNumber, Closure_Language_Code__c, Description, Shipment_Number__c ,Liner_Brand__c FROM Case WHERE Id = :caseIdSet]);
        }
        
        for(Integration_Results__c integrationResult : newIntegrationResults){
            String operationName = integrationResult.Operation_Name__c;
            Id stagingId = integrationResult.Integration_Staging__c;
            
            if (operationName != null && stagingId != null) {
                Id relatedCaseId = stagingMap.get(stagingId).Related_Record_Id__c;
                Case relatedCase = caseMap.get(relatedCaseId);
                if(operationName.equals('Sentiment Analysis') && caseMap.containsKey(relatedCaseId)){
                    // Call the future method for Sentiment Analysis with Case fields
                    IntegrationRecordCreator.updateSentimentOnCase(integrationResult.Id, stagingId, relatedCaseId, relatedCase.Closure_Language_Code__c, relatedCase.Description);
                }else if(operationName.equals('Shipment Summary')){
                    // Call the future method for Shipment Summary
                    IntegrationRecordCreator.populateDangerousCargo(integrationResult.Id, stagingId, relatedCaseId, relatedCase.Shipment_Number__c, relatedCase.CaseNumber);
                }else if(operationName.equals('Short transit')){
                    // Call the future method for Short Transit
                    IntegrationRecordCreator.populateShortTransit(integrationResult.Id, stagingId, relatedCaseId, relatedCase.Shipment_Number__c,relatedCase.Liner_Brand__c,relatedCase.CaseNumber);
                }else if(operationName.equals('IDA Classification')){
                    //Call the future method for IDA Classification
                    IntegrationRecordCreator.updateCaseClassification(integrationResult.Id, stagingId, new Set<Id>{relatedCaseId});
                }else if(operationName.equals('Break bulk')){
                    // Call the future method for Shipment Summary
                    IntegrationRecordCreator.populateCargoTypeBreakBulk(integrationResult.Id, stagingId, relatedCaseId, relatedCase.Shipment_Number__c, relatedCase.Liner_Brand__c, relatedCase.CaseNumber);
                }
            }
        }
    }
    
}