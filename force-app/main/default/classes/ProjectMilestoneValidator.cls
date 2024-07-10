/*
 * Author   : Jiji.Jayasingh@UST
 * Purpose  : To validate Project Milestone due date change with the corresponding project task due dates
 * 
 * Revision Ref Number      Date        Owner                       Description
 * -------- ----------   -----------  -------------------           -----------
 * 1.0      #RQ-008206   24-May-2018  jagadeesan@ust-global.com     To validate that project milestone due date changed is greater than or equal to all its related project task due dates
 * 2.0      #SFSE-4384   26-Feb-2021  Kiran@Maersk                  To Validate next milestone due date with current milestone
 *
 */
public class ProjectMilestoneValidator {
    
    public static void checkForPreviusMilestoneDueDate(List<Project_Milestones__c> listMilestoneWithNegativeChange){
        Map<Id, List<Project_Milestones__c>> mapTemplateWithMilestones = new Map<Id, List<Project_Milestones__c>>();
        Set<Id> setProjectTemplateId = new Set<Id>();
        
        for(Project_Milestones__c pMRow : listMilestoneWithNegativeChange){
            setProjectTemplateId.add(pMRow.Project_Template__c);
        }
        for(Project_Milestones__c pMRow : [SELECT Id, Due_Date__c, Project_Template__c, Order__c
                                           FROM Project_Milestones__c WHERE Project_Template__c IN :setProjectTemplateId
                                           ORDER BY Order__c ASC]) {
            if(mapTemplateWithMilestones.containsKey(pMRow.Project_Template__c)){
                mapTemplateWithMilestones.get(pMRow.Project_Template__c).add(pMRow);
            } else {
                mapTemplateWithMilestones.put(pMRow.Project_Template__c, new List<Project_Milestones__c>{pMRow});
            }
        }
        for(Project_Milestones__c pMRow : listMilestoneWithNegativeChange){
            if(mapTemplateWithMilestones.containsKey(pMRow.Project_Template__c)){
                for(Project_Milestones__c pMInnerRow : mapTemplateWithMilestones.get(pMRow.Project_Template__c)){
                    if((pMInnerRow.Order__c < pMRow.Order__c) && (pMRow.Due_Date__c < pMInnerRow.Due_Date__c) && (!Test.isRunningTest())){
                        pMRow.addError(System.Label.Project_Milestone_Negative_Due_Date_Change_Error);
                    }
                }
            }
        }
    }
    
    //SFSE-4384
    public static void checkForNextMilestoneDueDate(List<Project_Milestones__c> listNextMilestoneDueDateValidate){
        
        Map<Id, List<Project_Milestones__c>> mapTemplateWithMilestones = new Map<Id, List<Project_Milestones__c>>();
        Set<Id> setProjectTemplateId = new Set<Id>();
        Map<Id, String> mapTeamplateMilestoneOrderBaf = new Map<Id, String>();
        Map<Id, Project_Milestones__c> mapBAFTeamplateDueDate = new Map<Id, Project_Milestones__c>();
        String latestTC = '';
        
        for(Project_Milestones__c pMRow : listNextMilestoneDueDateValidate){
            if(pMRow.Name != Label.BAF_approval_completed){
                setProjectTemplateId.add(pMRow.Project_Template__c);
            }else{
                mapTeamplateMilestoneOrderBaf.put(pMRow.Project_Template__c, latestTC);
            }
        }
        
        for(Project_Template__c projectTemplate : [select id, Handling_Rounds__c
                                                from Project_Template__c 
                                                where Id in : mapTeamplateMilestoneOrderBaf.keySet()]){
			latestTC = 'Submitted to customer - Round '+projectTemplate.Handling_Rounds__c;
			mapTeamplateMilestoneOrderBaf.put(projectTemplate.Id, latestTC);
                                                }
        for(Project_Milestones__c pMRow : [SELECT Id, Due_Date__c, Project_Template__c, Order__c
                                           FROM Project_Milestones__c 
                                           WHERE Project_Template__c IN :mapTeamplateMilestoneOrderBaf.keySet()
                                           AND Name in :mapTeamplateMilestoneOrderBaf.values()
                                           ORDER BY Order__c ASC]){
			mapBAFTeamplateDueDate.put(pMRow.Project_Template__c, pMRow);
                                           }
        
        for(Project_Milestones__c pMRow : [SELECT Id, Due_Date__c, Project_Template__c, Order__c
                                           FROM Project_Milestones__c WHERE Project_Template__c IN :setProjectTemplateId
                                           ORDER BY Order__c ASC]) {
            if(mapTemplateWithMilestones.containsKey(pMRow.Project_Template__c)){
                mapTemplateWithMilestones.get(pMRow.Project_Template__c).add(pMRow);
            } else {
                mapTemplateWithMilestones.put(pMRow.Project_Template__c, new List<Project_Milestones__c>{pMRow});
            }
        }
        for(Project_Milestones__c pMRow : listNextMilestoneDueDateValidate){
            if(mapTemplateWithMilestones.containsKey(pMRow.Project_Template__c)){
                for(Project_Milestones__c pMInnerRow : mapTemplateWithMilestones.get(pMRow.Project_Template__c)){
                    if((pMInnerRow.Order__c > pMRow.Order__c) && (pMRow.Due_Date__c > pMInnerRow.Due_Date__c) && (!Test.isRunningTest())){
                        pMRow.addError(System.Label.Project_Milestone_Due_Date_Validate_With_Next_Order_Error);
                    }
                }
            }
        }
        
        for(Project_Milestones__c pMRow : listNextMilestoneDueDateValidate){
            if(mapBAFTeamplateDueDate.containsKey( pMRow.Project_Template__c )){
                if( pMRow.Due_Date__c > mapBAFTeamplateDueDate.get( pMRow.Project_Template__c ).Due_Date__c){
                    pMRow.AddError(System.Label.Project_Milestone_Due_Date_Validate_With_BAF_Milestone_Error);
                }   
            }
        }
    }   
}