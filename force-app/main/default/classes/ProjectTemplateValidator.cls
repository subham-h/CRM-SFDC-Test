/*
 * Author   : Jiji.Jayasingh@UST
 * Purpose  : To validate 1:1 relationship beteween opportunity and project template
 * 
 * Revision Ref Number      Date        Owner                			  Description
 * -------- ----------   -----------  -------------------   			  -----------
 * 1.0      #RQ-008175	 24-Apr-2018  Jiji.Jayasingh@ust-global.com	  	  To validate 1:1 relationship beteween opportunity and project template
 *
 */
public class ProjectTemplateValidator {
	public static void checkExistingProjTemplate( List<Project_Template__c> lstNewPjtTemp){
        Map<Id, Project_Template__c> mapofExistingTemplate = new Map<Id, Project_Template__c>();
        Set<id> setOppId = new Set<Id>();
        for(Project_Template__c prjTempRec : lstNewPjtTemp){
			setOppId.add(prjTempRec.Opportunity__c);
        }
        for(Project_Template__c prjTempRecord : [SELECT Id, Name, Opportunity__c 
                                              FROM Project_Template__c 
                                              WHERE Opportunity__c IN :setOppId]){
			mapofExistingTemplate.Put(prjTempRecord.Opportunity__c, prjTempRecord);
        }
        for(Project_Template__c prjTempRec : lstNewPjtTemp){
            If(mapofExistingTemplate.get(prjTempRec.Opportunity__c) != NULL){
                prjTempRec.addError(system.label.TenderWorkflowError+mapofExistingTemplate.get(prjTempRec.Opportunity__c).Name);
            }
        }
    }
}