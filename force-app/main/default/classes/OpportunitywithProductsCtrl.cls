public class OpportunitywithProductsCtrl {
    @AuraEnabled(cacheable=true)
    public static List < Opportunity > fetchOLIs(Id contractId) {
        List<Opportunity_Contract__c> opContracts = [select Id,Opportunity__c,  Name from Opportunity_Contract__c where Contract__c =: contractId ];
        Set<Id> oppsIds = new Set<Id>();
        system.debug('contractId ' + contractId);
        system.debug('opContracts ' + opContracts);
        for(Opportunity_Contract__c opsc: opContracts) {
            oppsIds.add(opsc.Opportunity__c);
        }
        List < Opportunity > opps = [ SELECT Id, Name, First_Shipment_Date__c, Last_Shipment_Date__c, StageName, Opportunity_Ref__c,
                ( SELECT Id, Product2ID__r.Name, Product2ID__r.Family FROM Opportunity_Products__r )
                FROM Opportunity WHERE Id IN:  oppsIds Order By LastModifiedDate DESC];
        
        system.debug('opps ' +opps);
        return opps;
    }
}