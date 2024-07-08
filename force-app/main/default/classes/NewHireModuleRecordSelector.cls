/*              
* Revision     Ref Number      Date            Owner                               Description
* -----------------------------------------------------------------------------------------
* 1.0          RQ-009682       14-Jan-2019     Junaid.Khader@ust-global.com        Code created
*/
public class NewHireModuleRecordSelector implements RecordSelector {
    
    private TriggerHandler nHMTriggerHandler; 
    public Map<Id, List<New_Hire_Module__c>> mapOnboardingPlanToLastModuleWithChangedStatus = new Map<Id, List<New_Hire_Module__c>>();
    public Set<Id> setOnboardingPlanIds = new Set<Id>();
    
    public NewHireModuleRecordSelector(list<New_Hire_Module__c> listNewHireModule, Map<Id, New_Hire_Module__c> mapOldNewHireModule, NewHireModuleTriggerHandler nHMTriggerHandler) {
        this.nHMTriggerHandler = nHMTriggerHandler;
        selectRecords(listNewHireModule, mapOldNewHireModule);
    }
    
    public void selectRecords(list<New_Hire_Module__c> listNewHireModule, Map<Id, SObject> mapOldNewHireModule) {
        New_Hire_Module__c oldNewHireModule;
        
        if(listNewHireModule.size() > 0){
            for(New_Hire_Module__c rowNewHireModule : listNewHireModule) {
                if((nHMTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) && (nHMTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE)) {
                    if(rowNewHireModule.Last_Module__c && mapOldNewHireModule.size() > 0 && mapOldNewHireModule.containsKey(rowNewHireModule.Id) && (mapOldNewHireModule.get(rowNewHireModule.Id) != null)){
                        oldNewHireModule = (New_Hire_Module__c) mapOldNewHireModule.get(rowNewHireModule.Id);
                        if((rowNewHireModule.Confirm_Declaration__c && rowNewHireModule.Confirm_Declaration__c != oldNewHireModule.Confirm_Declaration__c) ||
                                        (rowNewHireModule.Status__c == 'Completed' && rowNewHireModule.Status__c != oldNewHireModule.Status__c)){
                            if(mapOnboardingPlanToLastModuleWithChangedStatus.containsKey(rowNewHireModule.Onboarding_Plan__c)){
                                mapOnboardingPlanToLastModuleWithChangedStatus.get(rowNewHireModule.Onboarding_Plan__c).add(rowNewHireModule);
                            } else{
                                mapOnboardingPlanToLastModuleWithChangedStatus.put(rowNewHireModule.Onboarding_Plan__c, new List<New_Hire_Module__c>{rowNewHireModule});
                            }
                        }
                    }
                }
                if(nHMTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER) {
                    if(nHMTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                    	if(rowNewHireModule.Last_Module__c)
                            setOnboardingPlanIds.add(rowNewHireModule.Onboarding_Plan__c);
                    }
                    if(nHMTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                        if(rowNewHireModule.Last_Module__c && mapOldNewHireModule.size() > 0 && mapOldNewHireModule.containsKey(rowNewHireModule.Id) && (mapOldNewHireModule.get(rowNewHireModule.Id) != null)){
                            oldNewHireModule = (New_Hire_Module__c) mapOldNewHireModule.get(rowNewHireModule.Id);
                            if(rowNewHireModule.Status__c != oldNewHireModule.Status__c)
                                setOnboardingPlanIds.add(rowNewHireModule.Onboarding_Plan__c);
                        }
                    }
                }
            }
        }
        getRelatedRecords(listNewHireModule);
    }
    
    public void getRelatedRecords(list<SObject> listNewHireModule) {
        
    }
}