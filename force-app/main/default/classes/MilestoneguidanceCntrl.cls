public class MilestoneguidanceCntrl {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Tender_Milestone_Guidance__mdt> getAllTMG() {
        Map<String, Tender_Milestone_Guidance__mdt> mapTMG = new Map<String, Tender_Milestone_Guidance__mdt>();
        List<Tender_Milestone_Guidance__mdt> lstTMG  = [SELECT Id, MasterLabel, Label, Guidance_Notes__c, Milestone_Name__c
                                                        ,Order__c, DeveloperName FROM Tender_Milestone_Guidance__mdt];
        
        for(Tender_Milestone_Guidance__mdt tmg: lstTMG) {
            mapTMG.put(tmg.DeveloperName, tmg);
        }
        
        return mapTMG;

    }
    
}