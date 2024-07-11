/*
 * Author   : Nisha
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on task trigger.
 *        
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-004102   08/07/2016 nisha.arjunan@UST         Code created
 * 2.0      RQ-009492   21/11/2016 mohammed.naved@maersk     Code updated
 * 3.0      RQ-004146   04/12/2018 sreya.v@Maersk            Code updated 
 * 4.0      SC-1041	    07/04/2021 Sreya@Maersk              Implementation of Country & Business Hours on Voice Call Task
 * 5.0      SC-5350     16/06/2022 ayush.k@maersk			 Account Name of Customer on Task
 * 6.0      SC-5404     21/06/2022 Richa@maersk			     Task Survey Owner update
 * 7.0      SC-5948     07/09/2022 Harmeet@maersk			 Removed logic for Task Survey Owner update
 * 8.0     SC-6304     07/11/2022 Shahanawaz@maersk          Update Additional Owners on Case
 */
public class TaskTriggerHandler extends TriggerHandler {
    
    public map<Id, Task> newMap;
    public map<Id, Task> oldMap;
    public TaskTriggerHandler() {
        this.newMap = (map<Id, Task>)Trigger.newMap;
        this.oldMap = (map<Id, Task>)Trigger.oldMap; 
    }
    
    public TaskRecordSelector tasRecordSelector;
    public override void getRecordSelector() {
        tasRecordSelector = new TaskRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert() {
        if(!tasRecordSelector.lstTasksAgainstAccounts.isEmpty()) {
            // Task creation is not possible for those accounts whose Record Type  is unassigned.
            TaskValidator.validateTaskForUnassignedAccount(tasRecordSelector.lstTasksAgainstAccounts, tasRecordSelector.setUnassignedAccountIds);
        }
         // RQ-004146 - Update Contact on Task related to Case and of type Call
         if(!tasRecordSelector.lstTaskAgainstCases.isEmpty()) { 
            TaskContactUtility.populateContact(tasRecordSelector.lstTaskAgainstCases,tasRecordSelector.setCaseId);
        }
        //SC-1041 - Update Country and Business Hours on Voice Task
        if(!tasRecordSelector.lstVoiceCallTask.isEmpty()){
            TaskFieldPopulator.populateCountryAndBusinessHours(tasRecordSelector.lstVoiceCallTask,tasRecordSelector.lstCountryCode);
        }
        	
        //SC-5350 -  Account Name of Customer on Task
        if(!tasRecordSelector.lstTasksAgainstContacts.isEmpty()){
            TaskFieldPopulator.populateAccountName(tasRecordSelector.lstTasksAgainstContacts, tasRecordSelector.mapRelatedContacts);
        }
        
    }
    
    
     public override void onBeforeUpdate() {
        // RQ-004146 - Update Contact on Task related to Case and of type Call
        if(!tasRecordSelector.lstTaskAgainstCases.isEmpty()) { 
            TaskContactUtility.populateContact(tasRecordSelector.lstTaskAgainstCases,tasRecordSelector.setCaseId);
        }
		//SC-5350 -  Account Name of Customer on Task
        if(!tasRecordSelector.lstTasksAgainstContacts.isEmpty()){
            TaskFieldPopulator.populateAccountName(tasRecordSelector.lstTasksAgainstContacts, tasRecordSelector.mapRelatedContacts);
        }
         
    }
    
    public override void onAfterInsert() {
        if(!tasRecordSelector.setAccountIds.isEmpty()) {
            // Updates the Last Activity date on the account for which the task exists.
            AccountUtilities.populateLastActivityDate(tasRecordSelector.setAccountIds);
        }
       
        if (!tasRecordSelector.setCaseIds.isEmpty()) {
            system.debug('Insideout');
            //Updates the Last Activity date on the Case for which the task exists.
            TriggerExecutionController.skipCaseTrigger(true);
            CaseLastActivityUtility.updateCasefield(tasRecordSelector.setCaseIds);
            TriggerExecutionController.skipCaseTrigger(false);
        }   
        // Send Email-notification to Task Owner.
        TaskEmailUtility.sendEmail(Trigger.new, this);
        
 		//SC-6304
        if(!tasRecordSelector.caseIdSet.isEmpty()){
            TaskFieldPopulator.updateCaseAdditionalOwners(tasRecordSelector.caseIdSet, this.oldMap);
        }
    }
    
    public override void onAfterUpdate() {
        if(!tasRecordSelector.setAccountIds.isEmpty()) {
            // Updates the Last Activity date on the account for which the task exists. 
            AccountUtilities.populatelastActivityDate(tasRecordSelector.setAccountIds);
        }
       
        
        //Update Related Surveys owner when Task owner is changed
        if(!tasRecordSelector.MapTaskOwner.isEmpty()){
          TaskFieldPopulator.updateRelatedSurveys(tasRecordSelector.MapTaskOwner);
        }
        
        //SC-6304
        if(!tasRecordSelector.caseIdSet.isEmpty()){
            TaskFieldPopulator.updateCaseAdditionalOwners(tasRecordSelector.caseIdSet, this.oldMap);
        } 
        
        //SC-6304
        if(!tasRecordSelector.tskList.isEmpty()){
            TaskFieldPopulator.createCaseTeamMembers(tasRecordSelector.tskList);
        } 
    }  
    
}