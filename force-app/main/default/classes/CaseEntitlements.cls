/*
* Author   : Ragu
* Purpose  : Utility class to hold simple and reusable functionalities related to Entitlements, Milestones. 
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-002633   22-Feb-2016 Ragu@UST                Created for implementing CBO (Centralized By Org) trigger architecture.
* 2.0      RQ-004502   23-Nov-2016 Sunu@UST                Include cases with origin SEAGLOBALDISP along with manual cases to set the Triaged milestone to completed.
* 3.0      RQ-004691   27-Jan-2017 Rathish@UST             Included "Awaiting External Party Input" case status. If Case Status is set as 'Qualified / Awaiting Colleague Input / Awaiting Customer Input / Awaiting External Party Input', then set 'Qualify' Milestone as completed
* 3.1      RQ-001360   30-Jan-2017 Ragu@UST                Deleted the updateMilestones() and completeMilesones() methods since they are no longer used.
* 4.0      RQ-005636   25-Sep-2017 Nisha@UST               Update references of GlobalErrorLogger
* 5.0      RQ-007938   04-04-2018  Meenakshi@UST           Included "Awaiting Vendor Input" case status. to set 'Qualify' Milestone as completed.
* 6.0      RQ-009192   11-Sep-2018 Nisha@ust               Milestone for ISR Cases
* 7.0      RQ-009838   25-Jan-2019 Sreya@Maersk            Remove the code to update completion date for Qualify milestone as the milestone is being deleted.
* 8.0      SC-147      12-03-2020  Ranjini@ust             Removal of Traige Milestone for non Email channels
* 9.0      SC-160      02-04-2020  Ramadevi@ust            Implemented Trigger recurrsion for few methods.
* 10.0     SC-8989     22-02-2024  Shahanawaz@maersk.com   Completed the milestones assigned by optimizing the method
*/

public class CaseEntitlements {
    /*
    // Method to associate Entitlement to all created cases
    public static void associateEntitlement(list<Case> lstCases) {
        try {
            List<Case> csListToUpdate = new List<Case>();
            // RQ-002250: Improve Case Trigger Recursion Control
            if(Generic_TriggerHandler.validateRunForMethod('CaseEntitlements.associateEntitlement()', 1)) {
               System.debug('inside method'); 
                // New Code - Only default Entitlement will be assigned to External and dispute cases     - Rama 
                Entitlement defaultEntitlement;
                for(Entitlement entitle : CaseTrigger_DataSetUtilities.getEntList()){
                    if(Label.DefaultEntitlementName == entitle.Name){
                        defaultEntitlement = entitle;
                    }                    
                }
                for(Case caseIterator : lstCases) {
                    if(defaultEntitlement != NULL){  
                        Case cs = new Case();
                        cs.Id = caseIterator.Id;
                        cs.EntitlementId = defaultEntitlement.Id;
                        cs.AssetId = defaultEntitlement.AssetId; 
                        csListToUpdate.add(cs);
                    }                   
                }
                
                if(!csListToUpdate.isEmpty()){
                    TriggerExecutionController.skipCaseTrigger(true);
                    update csListToUpdate;
                    TriggerExecutionController.skipCaseTrigger(false);
                }
                
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseEntitlements.associateEntitlement(list<Case> lstCases)', new list<Exception>{ex}); // #RQ-005636 
        }
    }
    */
    
    @future
    public static void completeMilestones(Set<Id> setCaseIds) {
        try {
            //SC-160 : Trigger Recurrsion controller
            if(Generic_TriggerHandler.validateRunForMethod('CaseEntitlements.completeMilestones()', 1)){
                List<Case> csList = [Select Id From Case Where Id =: setCaseIds FOR UPDATE];
                List<CaseMilestone> lstCompletedMilestones = new List<CaseMilestone>();
                // Updating the Triaged milestone as completed on the associated cases
                if(setCaseIds.size() > 0) {
                    for(CaseMilestone tMilestone : [SELECT Id, CompletionDate, CaseId FROM CaseMilestone WHERE CaseId IN: setCaseIds AND MilestoneType.Name = :Label.Triage AND CompletionDate = null]) {
                        tMilestone.CompletionDate = System.now(); 
                        lstCompletedMilestones.add(tMilestone);
                    }
                }

                if(!lstCompletedMilestones.isEmpty()) {
                    update lstCompletedMilestones;
                }
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseEntitlements.completeMilestones(set<Id> setCaseIds)', new list<Exception>{ex}); // #RQ-005636 
        }
    }
    
}