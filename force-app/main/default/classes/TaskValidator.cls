/*
* Author   : Nisha
* Purpose  : Task Validator class for Task Trigger.
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-004102   08/07/2016 nisha.arjunan@UST        Created for implementing CBO (Centralized By Org) trigger architecture.
* 
*/  
public class TaskValidator {
    
    public static void validateTaskForUnassignedAccount(list<Task> lstNewTasks, set<Id> setAccountIds) {
        if(!lstNewTasks.isEmpty()) {
            Id unassignedRTId = StaticFactory.getRecordTypeIdByName('Account', 'Unassigned');
            map<Id, Account> mapUnAssignedAccounts = new map<Id, Account>([select Id from Account where Id in :setAccountIds and RecordTypeId = :unassignedRTId]);
			            
            if(mapUnAssignedAccounts != null && !mapUnAssignedAccounts.isEmpty()) {
                for(Task taskIterator : lstNewTasks) {
                    if(mapUnAssignedAccounts.containsKey(taskIterator.WhatId)) {
                        taskIterator.addError('Task can not be created for Unassigned Account.');
                    }
                }
            }
        }    
    }
    
}