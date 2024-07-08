/*
 * Author   : Jiji.Jayasingh@UST
 * Purpose  : RecordSelector class for ProjectMilestoneTrigger as per CBO Architecture
 * 
 * Revision Ref Number      Date        Owner                         Description
 * -------- ----------   -----------  -------------------             -----------
 * 1.0      #RQ-008206   24-May-2018  Jagadeesan@ust-global.com       Code Created
 * 2.0      #RQ-008208   30-Jul-2018  Junaid.Khader@ust-global.com    Adding milestone Ids with change in due date
 * 3.0		#RQ-008779	 05-Sep-2019  Jiji.Jayasingh@ust-global.com	  Salesforce deletes related tasks when user deletes milestone
 * 4.0      #RQ-009468   12-Nov-2018  Meghana.Gupta@ust-global.com       To remove cascading of due dates for project milestones related to project template of current modified milestone
 *
 */

public class ProjectMilestoneRecordSelector implements RecordSelector{
    private ProjectMilestoneTriggerHandler projMilestoneTriggerHandler;
    public Set<Id> setMilestoneId = new Set<Id>();
    public Set<Id> setProjectMilestoneId = new Set<Id>();
    public List<Project_Milestones__c> listMilestoneWithNegativeChange = new List<Project_Milestones__c>();
    public Map<Id, Integer> mapMilestoneWithDueDateChange = new Map<Id, Integer>();
    public List<Project_Milestones__c> listNextMilestoneDueDateValidate = new List<Project_Milestones__c>();
    
    public ProjectMilestoneRecordSelector( List<Project_Milestones__c> lstProjMilestone, map<Id, Project_Milestones__c> mapOldProjMilestone, ProjectMilestoneTriggerHandler projMilestoneTriggerHandler) {
        
        this.projMilestoneTriggerHandler = projMilestoneTriggerHandler;
        selectRecords(lstProjMilestone, mapOldProjMilestone); // call method to set all required project Milestone lists
        getLoggedInUser();
        
    }
    public void selectRecords(list<Project_Milestones__c> lstProjMilestone, map<Id, sObject> mapOldProjMilestone) {
        if (lstProjMilestone != null){  
            for (Project_Milestones__c prjMSRecord : lstProjMilestone ){
                Project_Milestones__c oldPrjMSRecord = (Project_Milestones__c)mapOldProjMilestone.get(prjMSRecord.Id);
                if(projMilestoneTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && prjMSRecord.Due_Date__c != oldPrjMSRecord.Due_Date__c){ 
                    if(projMilestoneTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE){
                        if(oldPrjMSRecord.Due_Date__c != null && prjMSRecord.Due_Date__c != null){
                            if( oldPrjMSRecord.Due_Date__c.DaysBetween(prjMSRecord.Due_Date__c) < 0 ){
                                listMilestoneWithNegativeChange.add(prjMSRecord);
                                setMilestoneId.add(prjMSRecord.Id);
                            }
                            listNextMilestoneDueDateValidate.add( prjMSRecord );
                        }
                    }
                    if(projMilestoneTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER && oldPrjMSRecord.Due_Date__c != null && prjMSRecord.Due_Date__c != null){
                        mapMilestoneWithDueDateChange.put(prjMSRecord.Id, oldPrjMSRecord.Due_Date__c.DaysBetween(prjMSRecord.Due_Date__c));                        
                    }
                }
            }
        }
        //RQ-008779: Start
        If(mapOldProjMilestone.Size() >0){
			for( sObject objRec:mapOldProjMilestone.Values()){
                Project_Milestones__c prjMSRecord = (Project_Milestones__c)objRec;
                if(projMilestoneTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE &&
                   prjMSRecord.Project_Template__c != null){
                       setProjectMilestoneId.add(prjMSRecord.Id);
                }      
            }
        }
        //RQ-008779: End
    }
    
    public void getRelatedRecords( list<Sobject> records ) {
       
    }
    public void getLoggedInUser() {
    }
}