/*
 * Author   : Jiji.Jayasingh@UST
 * Purpose  : To validate 1:1 relationship beteween opportunity and project template
 * 
 * Revision Ref Number      Date        Owner                			  Description
 * -------- ----------   -----------  -------------------   			  -----------
 * 1.0      #RQ-008175	 24-Apr-2018  Jiji.Jayasingh@ust-global.com	  	  To validate 1:1 relationship beteween opportunity and project template
 *
 */
public class ProjectTemplateRecordSelector implements RecordSelector{
	public List<Project_Template__c> lstValidateOpportunity = new List<Project_Template__c>();
    public Set<Id> setOpportunityId = new Set<Id>();
    public Set<Id> setProjectTemplateId = new Set<Id>();
	public map<Id, Opportunity> mapRelatedOpportunity = new map<Id, Opportunity>();
    private ProjectTemplateTriggerHandler projTempTriggerHandler;
    
    public ProjectTemplateRecordSelector( List<Project_Template__c> pjtTempList, map<Id, Project_Template__c> oldProjTempoMap, ProjectTemplateTriggerHandler projTempTriggerHandler) {
        
        this.projTempTriggerHandler = projTempTriggerHandler;
        selectRecords(pjtTempList, oldProjTempoMap); // call method to set all required project template lists
        getRelatedRecords( pjtTempList ); 
        getLoggedInUser();
        
    }
    public void selectRecords(list<Project_Template__c> pjtTempList, map<Id, sObject> mapOldProjTemp) {
    	 if (pjtTempList != null){	
        	for (Project_Template__c prjTempRecord : pjtTempList ){
                Project_Template__c oldProjTemp = new Project_Template__c();  
                if(projTempTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE){
                    if ( projTempTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE){
                        oldProjTemp = (Project_Template__c) mapOldProjTemp.get(prjTempRecord.Id);
                        lstValidateOpportunity.add(prjTempRecord); 
                    }
                }
                if (projTempTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE &&
                    projTempTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT &&
                    prjTempRecord.Opportunity__c != null ){          
                	lstValidateOpportunity.add(prjTempRecord); 
			    }
            }
         }
    }
    public void getRelatedRecords( list<Project_Template__c> newPjtTempList ) {
    }
    public void getLoggedInUser() {
    }
                
}