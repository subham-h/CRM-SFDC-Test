/*
 * Author   : Jiji.Jayasingh@UST
 * Purpose  : To validate 1:1 relationship beteween opportunity and project template
 * 
 * Revision Ref Number      Date        Owner                             Description
 * -------- ----------   -----------  -------------------                 -----------
 * 1.0      #RQ-008175   24-Apr-2018  Jiji.Jayasingh@ust-global.com       To validate 1:1 relationship beteween opportunity and project template
 *
 */
public class ProjectTemplateTriggerHandler extends TriggerHandler{
    public Map<Id, Project_Template__c> newMap;
    public Map<Id, Project_Template__c> oldMap;
    public boolean isPresent = false;
     
    public ProjectTemplateTriggerHandler() {
        this.newMap = ( map<Id, Project_Template__c> ) Trigger.newMap;
        this.oldMap = ( map<Id, Project_Template__c> ) Trigger.oldMap; 
    }
    
    // Use ProjectTemplateRecordSelector instance to initiate the records to be processed by trigger for each context
    public ProjectTemplateRecordSelector projTempRecordSelector;
    
    public override void getRecordSelector() {
        if (projTempRecordSelector == null){
            projTempRecordSelector = new ProjectTemplateRecordSelector( Trigger.new, this.oldMap, this);
        }
    }
    
    public override void onBeforeInsert() {
        // Validate 1:1 relationship beteween opportunity and project template
        if ( !projTempRecordSelector.lstValidateOpportunity.IsEmpty()){
            ProjectTemplateValidator.checkExistingProjTemplate ( projTempRecordSelector.lstValidateOpportunity);
        }
    }
    
    public override void onBeforeUpdate() {
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();     
        if ( !projTempRecordSelector.lstValidateOpportunity.IsEmpty()){
            isPresent = chckBAFTemplateExists(projTempRecordSelector.lstValidateOpportunity, Label.BAF_Approval);
            system.debug('isPresent' + isPresent);
            if(!isPresent){
                for(Project_Template__c pLst: projTempRecordSelector.lstValidateOpportunity) {
                    if(pLst.CreatedDate > Date.valueof(Label.Project_Template_Create_Date) && pLst.Does_the_Customer_Require_a_SBF_Clause__c == 'Yes' ) {
                        mapOpportunity  = AddRoundsToTemplateLightningCntrl.getOpportunityMap(pLst); 
                    }
                }
                if(!mapOpportunity.IsEmpty() && mapOpportunity.size() > 0) {
                    TenderWorkflowUtilities.CreateProjectMilestones(Trigger.new, Label.BAF_Approval,  null,null, 0, mapOpportunity, null);
                }
            }
        }
        
    }
    
    public static Boolean chckBAFTemplateExists(List<Project_Template__c> lstNewPjtTemp, String tmpName) {
        Set<id> setOppId = new Set<Id>();
        Boolean isBAFApprovalPresent = false;
        string tempInput = '%' + tmpName + '%';
        List<String> dupLst = new List<String>();
        for(Project_Template__c oppId: lstNewPjtTemp) {
            setOppId.add(oppId.Id);
        }
        for(Project_Milestones__c prjTempRecord : [SELECT Id, Name ,Project_Template__c
                                                 FROM Project_Milestones__c 
                                                 WHERE Project_Template__c IN :setOppId and Name like :tempInput]){
                         dupLst.add(prjTempRecord.Name);
                                                 }
		system.debug('dupLst ' + dupLst);
        if(!dupLst.isEmpty()) {
            isBAFApprovalPresent = true;
        }
        return isBAFApprovalPresent;
    }
}