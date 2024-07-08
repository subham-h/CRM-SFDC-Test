/*
 * Author   : Junaid.Khader@ust-global.com
 * Purpose  : To select records specifically for each scenarios
 * 
 * Revision Ref Number      Date        Owner                        Description
 * -------- ----------   -----------  -------------------           -----------
 * 1.0      #RQ-009022   13-Aug-2018  Junaid.Khader@ust-global.com   To automate closing of RateStructure based task
 *
 */
public class RateStructureRecordSelector implements RecordSelector {
    public Set<Id> setOpportunityIdWithApprovedRateStructure = new Set<Id>();
    private RateStructureTriggerHandler rateStructureTrigHandler;
    
    public RateStructureRecordSelector(List<Rate_Structure__c> listRateStrutures, Map<Id, Rate_Structure__c> oldRateStructureMap, RateStructureTriggerHandler rateStructTriggerHandler) {
        
        this.rateStructureTrigHandler = rateStructTriggerHandler;
        selectRecords(listRateStrutures, oldRateStructureMap); // call method to set all required project template lists
    }
    public void selectRecords(list<Rate_Structure__c> listRateStrutures, map<Id, SObject> oldRateStructureMap) {
        if(listRateStrutures.size() > 0){  
            Rate_Structure__c oldRateStructure;
            for(Rate_Structure__c rateStructureRow : listRateStrutures){
                oldRateStructure = new Rate_Structure__c();                
                if(rateStructureTrigHandler.trigType == TriggerHandler.TriggerType.ISAFTER){
                    if(rateStructureTrigHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE){
                        oldRateStructure = (Rate_Structure__c) oldRateStructureMap.get(rateStructureRow.Id);
                        if((rateStructureRow.Status__c != oldRateStructure.Status__c) && (rateStructureRow.Status__c == 'Approved')){                                            
                            setOpportunityIdWithApprovedRateStructure.add(rateStructureRow.Opportunity__c);
                        }
                    }
                }
            }
        }
    } 
    public void getRelatedRecords( list<Rate_Structure__c> newRateStructureList ) {
    
    }    
}