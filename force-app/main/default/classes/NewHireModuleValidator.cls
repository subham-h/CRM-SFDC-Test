/*              
* Revision     Ref Number      Date            Owner                               Description
* -----------------------------------------------------------------------------------------
* 1.0          RQ-009682       14-Jan-2019     Junaid.Khader@ust-global.com        Code created
*/
public class NewHireModuleValidator {
    
    public static void validateForIncompleteModules(Map<Id, List<New_Hire_Module__c>> mapOnboardingPlanToLastModuleWithChangedStatus){
        Set<Id> setPlansWithIncompleteModules = new Set<Id>();
        
        for(Onboarding_Plan__c rowOnboardingPlan : [SELECT Id
                                                   FROM Onboarding_Plan__c
                                                   WHERE Id IN :mapOnboardingPlanToLastModuleWithChangedStatus.keySet()
                                                   AND Plan_Progress__c != 100]){
            setPlansWithIncompleteModules.add(rowOnboardingPlan.Id);
        }
        
        for(Id onboardingPlanId : mapOnboardingPlanToLastModuleWithChangedStatus.keySet()){
            if(setPlansWithIncompleteModules.contains(onboardingPlanId)){
                for(New_Hire_Module__c rowNewHireModule : mapOnboardingPlanToLastModuleWithChangedStatus.get(onboardingPlanId)){
                    rowNewHireModule.addError(Label.OnboardingLastModuleError);
                }
            }
        }
    }
}