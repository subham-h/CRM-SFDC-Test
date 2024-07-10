/*
* Author   : Nisha
* Purpose  : Record Selector class for Task Trigger
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-004102   08/07/2016 nisha.arjunan@UST         Code created
* 2.0      RQ-009492   21/11/2018 mohammed.naved@maersk     Code updated
* 3.0      RQ-004146   04/12/2018 sreya.v@maersk.com        Code updated 
* 4.0      RQ-009492   28/05/2019 mohammed.naved@maersk     Code updated
* 5.0      SC-1041	   07/04/2021 Sreya@Maersk              Implementation of Country & Business Hours on Voice Call Task
* 6.0      SC-5350     16/06/2022 ayush.k@maersk			Add Voice Call list in BeforeUpdate to update account name of task.
* 7.0      SC-5404     21/06/2022 Richa@maersk			    Update Task survey owner
* 8.0      SC-5948     07/09/2022 Harmeet@maersk			Removed logic for Update Task survey owner
* 9.0      SC-6309     30/10/2022 Harmeet@maersk			Added back the logic for Update Task survey owner
* 10.0     SC-6304     07/11/2022 Shahanawaz@maersk			Update Additional Owners on Case
* 11.0     SC-5415     12-Jan-2022 Saradha@UST 				Case trigger optimisation reduced recordtypeid query
*/ 

public class TaskRecordSelector implements RecordSelector {
    
    private TriggerHandler tskTriggerHandler;
    
    // To store related Account details
    public set<Id> setAccountIds = new set<Id>();
    
    
    //To store related task id
    public set<Id> setCaseIds = new set<Id>();
    
    //To store related contact id - SC-5350
    public set<Id> setContactIds = new set<Id>();
    public map<Id, Contact> mapRelatedContacts = new map<Id, Contact>();
    public list<Task> lstTasksAgainstContacts = new list<Task>();
    
    // To validate creation of Task for Unassigned Accounts
    public set<Id> setUnassignedAccountIds = new set<Id>();
    public list<Task> lstTasksAgainstAccounts = new list<Task>();
    
    //RQ-004146
    public List<task> lstTaskAgainstCases = new List<task>();
    public Set<Id> setCaseId = new Set<Id>();
    
    //SC-1041 List of Voice Call Tasks
    public List<Task> lstVoiceCallTask = new List<Task>();
    public List<String> lstCountryCode = new List<String>();
    
    //update Related Surveys for Tasks
    public Map<String, String> MapTaskOwner = new Map<String, String>();
    public String caseDataInterfaceUserId = Label.CaseDataInterfaceUserId;
    public String allCarrierUserId = Label.AllCarrierUserQueueId;
    
    //SC-6304
    public Set<Id> caseIdSet = new Set<Id>();
    public List<Task> tskList = new List<Task>();
    
    public TaskRecordSelector(list<Task> lstTask, map<Id, Task> mapOldTasks, TriggerHandler tskTriggerHandler) {
        this.tskTriggerHandler = tskTriggerHandler;
        this.selectRecords(lstTask, mapOldTasks);
        
        if(lstTask != null) {
            this.getRelatedRecords(lstTask);
        }
        else if(mapOldTasks != null) {
            this.getRelatedRecords(mapOldTasks.values());
        }
    }
    
    public void selectRecords(list<Task> lstTask, map<Id, sObject> oldTaskMap) {
        if(!lstTask.isEmpty()) {
            //SC-5414 reduced soql query by 2
            Id VoiceCallTaskRecordTypeId = Task.sObjectType.getDescribe().getRecordTypeInfosByName().get('Voice Call').getRecordTypeId();
            Id caseCollaborationRecTypeId = Task.sObjectType.getDescribe().getRecordTypeInfosByName().get('Case Collaboration').getRecordTypeId();

            // Iterate over the new task records to check the criteria
            String strCasePrefix = Case.SObjectType.getDescribe().getKeyPrefix();
            String strUserPrefix = User.SObjectType.getDescribe().getKeyPrefix();
            for(Task newTask : lstTask) {
                // Get the old task record if it is not blank
                Task oldTask;
                if(oldTaskMap != null && !oldTaskMap.isEmpty()) {
                    oldTask = (Task)oldTaskMap.get(newTask.Id);
                }   
                if(tskTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE){
                    if(tskTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                        if(newTask.WhatId != null && String.valueOf(newTask.WhatId).startsWith('001')) {
                            setUnassignedAccountIds.add(newTask.WhatId);
                            lstTasksAgainstAccounts.add(newTask);
                        }
                        
                        // RQ-004146 : Get the task list if related to case and of type call
                        if(newTask.WhatId != null){
                            if(String.valueOf(newTask.WhatId).startsWith(strCasePrefix)  && newTask.WhoId == null  && newTask.type == 'Call'){
                                lstTaskAgainstCases.add(newTask);
                                setCaseId.add(newTask.WhatId);
                            }
                        } 
                        //SC-1041 : Get the list of Voice Call tasks
                        if(newTask.RecordTypeId == VoiceCallTaskRecordTypeId){
                            lstVoiceCallTask.add(newTask);
                            if(string.isNotBlank(newTask.Country_Code__c)){
                                lstCountryCode.add(newTask.Country_Code__c); 
                            }                                                     
                        }
                        //SC-5350
                        if(newTask.RecordTypeId == VoiceCallTaskRecordTypeId && newTask.WhoId != null){
                            lstTasksAgainstContacts.add(newTask);
                            setContactIds.add(newTask.WhoId);
                        }
                        
                    }
                    // RQ-004146 : Get the task list if related to is changed to case and of type call
                    else if(tskTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE){
                        if(newTask.WhatId != null){
                            if(newTask.WhatId != oldTask.WhatId && String.valueOf(newTask.WhatId).startsWith(strCasePrefix) && newTask.WhoId == null && newTask.type == 'Call'){
                                lstTaskAgainstCases.add(newTask);
                                setCaseId.add(newTask.WhatId);
                            }
                        }
                        
                        //SC-5350 -  Account Name of Customer on Task
                        if(newTask.RecordTypeId == VoiceCallTaskRecordTypeId && newTask.WhoId != oldTask.WhoId){
                            lstTasksAgainstContacts.add(newTask);
                            setContactIds.add(newTask.WhoId);
                        }
                    }
                    
                }
                else if(tskTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER){
                    if(tskTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT || tskTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                        if(string.isnotblank(newTask.subject)){
							if(string.isnotblank(newTask.AccountId) && !newTask.subject.startsWith('Email')) {
                            setAccountIds.add(newTask.AccountId);
                        	}
                        }
                        //Get the case id related to task
                        //Code Updated on 28/05/2019 due to Production Issue.Put a null check for subject and task subtype
                        if(newTask.whatid != null && newTask.subject!= null && newTask.TaskSubtype != null ){
                            system.debug('newTask.WhatId##'+newTask.WhatId);
                            if(String.valueOf(newTask.WhatId).startsWith(strCasePrefix) &&  newTask.TaskSubtype != 'Email' && !newTask.subject.startsWith('Email')){
                                setCaseIds.add(newTask.whatid);
                                system.debug('setCaseIds##'+setCaseIds);
                            }  
                        } 
                        //update Related Surveys owner when Task owner is updated
                    }
                    
                    //SC-6304
                    if(newTask.RecordTypeId == caseCollaborationRecTypeId && newTask.WhatId != null && String.valueOf(newTask.WhatId).startsWith(strCasePrefix) && (oldTask == null || (oldTask != null && newTask.OwnerId != oldTask.OwnerId))){
                        if(String.valueOf(newTask.OwnerId).startsWith('00G')){
                            caseIdSet.add(newTask.WhatId);
                        }
                        if(oldTask != null && newTask.OwnerId != oldTask.OwnerId && String.valueOf(newTask.OwnerId).startsWith(strUserPrefix)){
                            tskList.add(newTask);
                        }
                    }
                    
                    if(tskTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE){
                        if(userInfo.getUserId() != CaseDataInterfaceUserId && newTask.ownerId != oldTask.ownerId && newTask.ownerId != allCarrierUserId && !String.isEmpty(newTask.callObject)){
                            MapTaskOwner.put(newTask.CallObject, newTask.CreatedById);
                        }
                    }
                }
            }
        }
    }
    
    /** 
    * @description | Get realted records  |
    * @param lstTask accepts list of task
    */  
    public void getRelatedRecords(list<task> lstTask){
        getRelatedContacts(); //SC-5350
    }
    
    /** 
    * @description | SC-5350 - Add Related Contact From the contact  |
    */  
    public void getRelatedContacts() {
        if(!setContactIds.isEmpty()) {
            mapRelatedContacts = new map<Id, Contact>([SELECT Id, Account.name from Contact where id IN :setContactIds]);
        }
    }
}