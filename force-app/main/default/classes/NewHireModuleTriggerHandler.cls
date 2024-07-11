/*              
* Revision     Ref Number      Date            Owner                               Description
* -----------------------------------------------------------------------------------------
* 1.0          RQ-009682       14-Jan-2019     Junaid.Khader@ust-global.com        Code created
*/
public class NewHireModuleTriggerHandler extends TriggerHandler {
    
    public map<Id, New_Hire_Module__c> newMap;
    public map<Id, New_Hire_Module__c> oldMap;
    public NewHireModuleRecordSelector nHMRecordSelector;
    
    public NewHireModuleTriggerHandler() {
        this.newMap = (map<Id, New_Hire_Module__c>)Trigger.newMap;
        this.oldMap = (map<Id, New_Hire_Module__c>)Trigger.oldMap; 
    }
    
    public override void getRecordSelector() {
        nHMRecordSelector = new NewHireModuleRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeUpdate() {
        if(nHMRecordSelector.mapOnboardingPlanToLastModuleWithChangedStatus.size() > 0){
            NewHireModuleValidator.validateForIncompleteModules(nHMRecordSelector.mapOnboardingPlanToLastModuleWithChangedStatus);
        }
    }
    
    public override void onAfterInsert() {
        if(nHMRecordSelector.setOnboardingPlanIds.size() > 0){
            NewHireModuleUtilities.updateLastModuleNamesOnPlan(nHMRecordSelector.setOnboardingPlanIds);
        }
    }
    
    public override void onAfterUpdate() {
        if(nHMRecordSelector.setOnboardingPlanIds.size() > 0){
            NewHireModuleUtilities.updateLastModuleNamesOnPlan(nHMRecordSelector.setOnboardingPlanIds);
        }
    }
}