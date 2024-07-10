//  For SFSE- 10398 Shilpa Nagtode - Added logic to fetch contract Lifecycle metadata and pass it to LWC
public without sharing class ContractStatusCtrlr {
    
    
    @AuraEnabled(cacheable=true)
    public static Contract_Lifecycle_Management_URL__mdt getContractPath(){
        Contract_Lifecycle_Management_URL__mdt contractpath;
        Map<String, Contract_Lifecycle_Management_URL__mdt> mapContractMdt = Contract_Lifecycle_Management_URL__mdt.getAll();
        for(String keySetString : mapContractMdt.keySet()){
            if(mapContractMdt.get(keySetString).Active__c) {
                contractpath = mapContractMdt.get(keySetString);
                System.debug('----->'+mapContractMdt.get(keySetString));
            }
        }  
        return contractpath;
    }
    
    @AuraEnabled(cacheable=true)
    public static responseWrapper getOpportunityContracts(Id OppId){
        responseWrapper response = new responseWrapper();
        List<Opportunity_Contract__c> lstOppContract = [SELECT Id, Opportunity__c, Opportunity__r.Opp_Contract_Count__c, Contract__c, Status__c, Effective_Date__c 
                                                        FROM Opportunity_Contract__c WHERE Opportunity__c =:OppId AND Status__c !=NULL];        
        Map<String, Contract_Lifecycle_Management_URL__mdt> mapContractMdt = Contract_Lifecycle_Management_URL__mdt.getAll();
        response.optyContractList = lstOppContract;
        response.contractLCMmetadataList = mapContractMdt.values();
        return response;
    }
    
    
    @AuraEnabled
    public static Boolean hasAccessToContract(List<Id> lstContractId, Id userId){
        Boolean blnHasAccess = false;
        for(UserRecordAccess recAccess : [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId=:userId AND RecordId IN :lstContractId]) {
            if(recAccess.HasReadAccess && !blnHasAccess)   {
                blnHasAccess = true;     
            }                        
        } 
        system.debug('blnHasAccess' + blnHasAccess);
        return blnHasAccess;
    }
    
    public class responseWrapper{
        @AuraEnabled public List<Opportunity_Contract__c> optyContractList {get; set;}
        @AuraEnabled public Opportunity_Contract__c optyContract {get; set;}
        @AuraEnabled public List<Contract_Lifecycle_Management_URL__mdt> contractLCMmetadataList {get; set;}
        public responseWrapper(){
            contractLCMmetadataList = new List<Contract_Lifecycle_Management_URL__mdt>();
            optyContractList = new List<Opportunity_Contract__c>();
        }
    }
}