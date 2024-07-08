/*  
* Revision   Date           Owner                   Description
* --------   -----------    -------------------     -----------
* 1.0        23-Aug-2022 	sidhartha@maersk     TriggerHandler class Opportunity Contract 
*/
public with sharing class OpportunityContractTriggerHandler extends TriggerHandler {

    public Map<Id, Opportunity_Contract__c> newMap;
    public Map<Id, Opportunity_Contract__c> oldMap;

    public OpportunityContractRecordSelector oppContractRecordSelector;
    public override void getRecordSelector() {
        
        if (oppContractRecordSelector == null)
            oppContractRecordSelector = new OpportunityContractRecordSelector( Trigger.new, this.oldMap, this);
        
    }
    public OpportunityContractTriggerHandler() {
        this.newMap = ( map<Id, Opportunity_Contract__c> ) Trigger.newMap;
        this.oldMap = ( map<Id, Opportunity_Contract__c> ) Trigger.oldMap; 
    }
    
    public override void onAfterInsert() {
        if ( !oppContractRecordSelector.oppIdtouserIdMap.IsEmpty()){
            OppContractUtilities.createContractShare(oppContractRecordSelector.newOpptyContractList, oppContractRecordSelector.oppIdtouserIdMap);

        }
    }
}