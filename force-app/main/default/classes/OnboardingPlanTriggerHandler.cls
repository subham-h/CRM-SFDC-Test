/*
* Author   : Abby 
* Purpose  : Gives abstract view of all the business logic / functionality implemented on Onboarding Plan trigger.
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0       RQ-004392  28/12/2016  abby.abraham@ust        Code created
* 
*/  

public class OnboardingPlanTriggerHandler extends TriggerHandler{
    
    public map<Id,Onboarding_Plan__c> newMap;
    public map<Id,Onboarding_Plan__c> oldMap;
    
    
    public OnboardingPlanTriggerHandler(){
        
        this.newMap = (map<Id,Onboarding_Plan__c>)Trigger.newMap;
        this.oldMap = (map<Id,Onboarding_Plan__c>)Trigger.oldMap; 
    
    }
    
    
    
    public override void onBeforeInsert(){
        
        OnboardingPlanUtilities.updateOwner(trigger.old, trigger.new);
        OnboardingPlanUtilities.updateOnboardStatus(trigger.new, trigger.old);
        OnboardingPlanUtilities.lockOnboardingPlan (trigger.old, trigger.new, 'isBefore');
       
    }
    
    
    
    public override void onBeforeUpdate(){
        
        OnboardingPlanUtilities.updateOwner(trigger.old, trigger.new);
        OnboardingPlanUtilities.updateOnboardStatus(trigger.new,trigger.old);
        OnboardingPlanUtilities.lockOnboardingPlan (trigger.old,trigger.new, 'isBefore');
        
    }
    
    
    
    public override void onAfterInsert(){
         
        OnboardingPlanUtilities.onboarderShare(trigger.old,trigger.new);
           
    }
    
    
    
    public override void onAfterUpdate(){
          
        OnboardingPlanUtilities.updateModuleCompletionDate(trigger.old,trigger.new);
        OnboardingPlanUtilities.lockOnboardingPlan (trigger.old,trigger.new, 'isAfter'); 
        OnboardingPlanUtilities.onboarderShare(trigger.old,trigger.new);
            
    }
    
}