/*  
* Revision   Date           Owner                   Description
* --------   -----------    -------------------     -----------
* 1.0        23-Aug-2022 	sidhartha@maersk     Selector class OpportunityContractTriggerHandler 
*/
public with sharing class OpportunityContractRecordSelector implements RecordSelector {
    private TriggerHandler oppContractTriggerHandler;
    public Set<Id> contractIdSet = new Set<Id>();
    public Map<Id,Set<Id>> oppIdtouserIdMap = new Map<Id,Set<Id>>();
    public Set<Id> oppIdSet = new Set<Id>();
    public List<Opportunity_Contract__c> newOpptyContractList = new List<Opportunity_Contract__c>();
    public map<Id,Id> mapOfOppIdtoContractId = new map<Id,Id>();
    public map<String, Id> mapOfBrandToAccountOwner = new map<String, Id>();

    public OpportunityContractRecordSelector(List<Opportunity_Contract__c> lstContract, map<Id, Opportunity_Contract__c> mapOldContract, OpportunityContractTriggerHandler oppContractTriggerHandler) {
        this.oppContractTriggerHandler = oppContractTriggerHandler;
        this.getRelatedRecords(lstContract);
        selectRecords(lstContract, mapOldContract);
    }


    public void selectRecords(list<Opportunity_Contract__c> lstContract, map<Id, sObject> mapOldContract) {
        
       for (Opportunity_Contract__c contractRecord : lstContract ){  
            newOpptyContractList.add(contractRecord);
        }
    }
    
    public void getRelatedRecords( list<Opportunity_Contract__c> newContractList ) {
        for (Opportunity_Contract__c contractRecord : newContractList ){  
            contractIdSet.add(contractRecord.Contract__c);
            oppIdSet.add(contractRecord.Opportunity__c);
        }
        for(Opportunity_Contract__c oppContract : [Select Id, Opportunity__c,Opportunity__r.Liner_brand__c,Opportunity__r.OwnerId,Contract__r.Customer__r.MCC_Account_Owner__c,
        Contract__r.Customer__r.MLL_Account_Owner__c, Contract__r.Customer__r.Seago_Account_Owner__c, Contract__r.Customer__r.MSL_Account_Owner__c,
        Contract__r.Customer__r.SEA_Account_Owner__c,Contract__r.Customer__r.HSUD_Account_Owner__c, Contract__c from Opportunity_Contract__c 
                                                   Where Contract__c IN: contractIdSet]){
                                                       
                   mapOfOppIdtoContractId.put(oppContract.Opportunity__c, oppContract.Contract__c);
                   if(oppIdtouserIdMap.containsKey(oppContract.Opportunity__c)) {
                         oppIdtouserIdMap.get(oppContract.Opportunity__c).add(oppContract.Opportunity__r.OwnerId);
                   }else{
                         oppIdtouserIdMap.put(oppContract.Opportunity__c, new Set<Id>{oppContract.Opportunity__r.OwnerId});
                   }
                   
                   if(oppContract.Opportunity__r.Liner_brand__c == BrandUtilities.MAERSKLINE){
                        oppIdtouserIdMap.get(oppContract.Opportunity__c).add(oppContract.Contract__r.Customer__r.MSL_Account_Owner__c);
                   }
                                                       
                   if(oppContract.Opportunity__r.Liner_brand__c == BrandUtilities.MCC){
                        oppIdtouserIdMap.get(oppContract.Opportunity__c).add(oppContract.Contract__r.Customer__r.MCC_Account_Owner__c);
                   }
                                                       
                   if(oppContract.Opportunity__r.Liner_brand__c == BrandUtilities.SEAGO){
                        oppIdtouserIdMap.get(oppContract.Opportunity__c).add(oppContract.Contract__r.Customer__r.Seago_Account_Owner__c);
                   }
                    
				   if(oppContract.Opportunity__r.Liner_brand__c == BrandUtilities.SEALAND){
                        oppIdtouserIdMap.get(oppContract.Opportunity__c).add(oppContract.Contract__r.Customer__r.SEA_Account_Owner__c);
                   }
				   
				   if(oppContract.Opportunity__r.Liner_brand__c == BrandUtilities.HAMBURGSUD){
                        oppIdtouserIdMap.get(oppContract.Opportunity__c).add(oppContract.Contract__r.Customer__r.HSUD_Account_Owner__c);
                   }

        }

        for(OpportunityTeamMember optm: [SELECT Id,OpportunityId, UserId from OpportunityTeamMember WHERE OpportunityId IN: oppIdSet]) {
              oppIdtouserIdMap.get(optm.OpportunityId).add(optm.UserId);
        }
        
       //system.debug('##SM## oppIdtouserIdMap : ' + oppIdtouserIdMap);
    }
}