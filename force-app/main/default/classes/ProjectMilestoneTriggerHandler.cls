/*
 * Author   : Jiji.Jayasingh@UST
 * Purpose  : To validate Project Milestone due date change with the corresponding project task due dates
 * 
 * Revision Ref Number      Date        Owner                             Description
 * -------- ----------   -----------  -------------------                 -----------
 * 1.0      #RQ-008206   24-May-2018  Jagadeesan@ust-global.com          To validate Project Milestone due date change with the corresponding project task due dates
 * 2.0      #RQ-008208   30-Jul-2018  Junaid.Khader@ust-global.com       To update milestones and tasks due date in a go.
 * 3.0		#RQ-008779	 05-Sep-2019  Jiji.Jayasingh@ust-global.com		 Salesforce deletes related tasks when user deletes milestone
 */
public class ProjectMilestoneTriggerHandler extends TriggerHandler{
    
    public Map<Id, Project_Milestones__c> newMap;
    public Map<Id, Project_Milestones__c> oldMap;
        
    public ProjectMilestoneTriggerHandler() {
        this.newMap = ( map<Id, Project_Milestones__c> ) Trigger.newMap;
        this.oldMap = ( map<Id, Project_Milestones__c> ) Trigger.oldMap; 
    }
    
    // Use ProjectMilestoneRecordSelector instance to initiate the records to be processed by trigger for each context
    public ProjectMilestoneRecordSelector projMSRecordSelector;
    
    public override void getRecordSelector() {
        if (projMSRecordSelector == null){
            projMSRecordSelector = new ProjectMilestoneRecordSelector( Trigger.new, this.oldMap, this);
        }
    }
   
    public override void onBeforeUpdate() {
        // To validate Project Milestone due date change with the corresponding project task due dates
        // SFSE-4384 - uncommenting code
       /*if ( !projMSRecordSelector.mapMilestoneWithDueDateChangeValidate.IsEmpty() && !projMSRecordSelector.mapOfProjMSToTaskwithMaxDueDate.IsEmpty()){
            ProjectMilestoneValidator.checkForRelatedProjectTaskDueDates (projMSRecordSelector.mapMilestoneWithDueDateChangeValidate, projMSRecordSelector.mapOfProjMSToTaskwithMaxDueDate );
        }*/ 
        // RQ-008208
        if(projMSRecordSelector.listMilestoneWithNegativeChange.size() > 0){
            ProjectMilestoneValidator.checkForPreviusMilestoneDueDate(projMSRecordSelector.listMilestoneWithNegativeChange);
        }
        if( projMSRecordSelector.listNextMilestoneDueDateValidate.size() > 0){
            ProjectMilestoneValidator.checkForNextMilestoneDueDate(projMSRecordSelector.listNextMilestoneDueDateValidate);
        }
    }
    public override void onAfterUpdate() {
        // RQ-008208
        // SFSE-4384 - uncommenting code
        /*if(projMSRecordSelector.mapMilestoneWithDueDateChange.size() > 0){
            ProjectMilestoneUtilities.amendMilestonesAndTaskDueDates(projMSRecordSelector.mapMilestoneWithDueDateChange);
        }*/
    }
    //RQ-008779: Start
    public override void onBeforeDelete() {
        
    }
    //RQ-008779: End
}