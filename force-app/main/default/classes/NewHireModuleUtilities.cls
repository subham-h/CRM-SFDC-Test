/*              
* Revision     Ref Number      Date            Owner                               Description
* -----------------------------------------------------------------------------------------
* 1.0          RQ-009682       28-Jan-2019     Junaid.Khader@ust-global.com        Code created
*/
public class NewHireModuleUtilities {
    public static void updateLastModuleNamesOnPlan(Set<Id> setOnboardingPlanIds){
        List<Onboarding_Plan__c> listOnboardingPlansToUpdate = new List<Onboarding_Plan__c>();
        
        for(Onboarding_Plan__c rowOnboardingPlan : [SELECT Id, Last_Module_Name__c, Last_Module_Status__c,
                                                    (SELECT Name, Status__c
                                                    FROM New_Hire_Modules__r WHERE Last_Module__c = true
                                                    ORDER BY Order__c ASC)
                                                   FROM Onboarding_Plan__c
                                                   WHERE Id IN :setOnboardingPlanIds]){
			if(rowOnboardingPlan.New_Hire_Modules__r.size() > 0){
                for(New_Hire_Module__c rowNewHireModule : rowOnboardingPlan.New_Hire_Modules__r){
                    rowOnboardingPlan.Last_Module_Name__c = rowNewHireModule.Name;
                    rowOnboardingPlan.Last_Module_Status__c = rowNewHireModule.Status__c;
                }
                listOnboardingPlansToUpdate.add(rowOnboardingPlan);
            }
        }
        if(listOnboardingPlansToUpdate.size() > 0){
            List<Database.SaveResult> listPlanUpdateResult = Database.Update(listOnboardingPlansToUpdate, false);
            ErrorLogger.writeErrors('SFDC', 'NewHireModuleUtilities', 'updateLastModuleNamesOnPlan', listPlanUpdateResult, listOnboardingPlansToUpdate);
        }
    }
}