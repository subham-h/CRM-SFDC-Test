/*
* Author   : Ragu
* Purpose  : Batch class to identify and relink all the related records of wrongly merged contacts. This batch is created to solve critical PROD issue and might be used only one time. 
*          Scope: Case, Opportunity, Sales Call, Task and Event.
*          Incident: INC1255412
* 2.0      RQ-005636   26-Sep-2017 Nisha@UST               Update references of GlobalErrorLogger 
*/

global class Batch_RelinkContactChilds implements Database.Batchable<sObject>, Database.Stateful {
    
    Integer iDMLRowsLimit;
    public String strMode; // This should be either "Count" / "Run".
    public String strQuery;
    static final String STATUS_NEW = 'New';
    static final String STATUS_INPROGRESS = 'In Progress';
    static final String STATUS_ERROR = 'Errors';
    static final String STATUS_COMPLETED = 'Completed';
    
    
    global Batch_RelinkContactChilds(String strMode, String strQuery) {
        iDMLRowsLimit = Limits.getLimitDMLRows() - 10;
        this.strMode = strMode;
        if(String.isBlank(strQuery)) {
            this.strQuery = 'select Id, Master_Contact_Id__c, New_Contact_Id__c, New_Contacts_Account_Id__c, Cases__c, Opportunities__c, Sales_Calls__c, Tasks__c, Events__c, Status__c from Relink_Contact_Childs__c where Status__c = \'New\' order by Name';
        }
        else {
            this.strQuery = strQuery;
        }
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(String.isBlank(strMode)) {
            throw new ModeNotDefinedException('Please set the Mode.');
        }
        
        return Database.getQueryLocator(strQuery);    
    }
    
    
    global void execute(Database.BatchableContext BC, list<Relink_Contact_Childs__c> lstRelinkContactChilds) {
        // This execute method can process maximum of 2 Relink_Contact_Childs__c at a time, else we will end up with Governor Limits.
        if(lstRelinkContactChilds.size() > 2) {
            throw new BatchSizeExceededException('Batch size should not exceed 2 for this batch class.');
        }
        
        for(Relink_Contact_Childs__c relink : lstRelinkContactChilds) {
            relink.Status__c = STATUS_INPROGRESS;
            Database.update(relink, false);
            
            Integer rowCount = 0;
            Boolean bLimitReached = false;
            Boolean bExceptions = false;
            try {
                list<Case> lstCases = [select Id, AccountId, ContactId from Case where ContactId = :relink.Master_Contact_Id__c and AccountId = :relink.New_Contacts_Account_Id__c];
                list<Opportunity> lstOpportunities = [select Id, AccountId, Primary_Contact__c from Opportunity where Primary_Contact__c = :relink.Master_Contact_Id__c and AccountId = :relink.New_Contacts_Account_Id__c];
                list<Sales_Call__c> lstSalesCalls = [select Id, Account__c, Contact__c from Sales_Call__c where Contact__c = :relink.Master_Contact_Id__c and Account__c = :relink.New_Contacts_Account_Id__c];
                list<Task> lstTasks = [select Id, AccountId, WhoId, WhatId from Task where WhoId = :relink.Master_Contact_Id__c and AccountId = :relink.New_Contacts_Account_Id__c];
                list<Event> lstEvents = [select Id, AccountId, WhoId, WhatId from Event where WhoId = :relink.Master_Contact_Id__c and AccountId = :relink.New_Contacts_Account_Id__c];
                
                if(strMode == 'Count') {
                    relink.Cases__c = lstCases != null ? lstCases.size() : 0;
                    relink.Opportunities__c = lstOpportunities != null ? lstOpportunities.size() : 0;
                    relink.Sales_Calls__c = lstSalesCalls != null ? lstSalesCalls.size() : 0;
                    relink.Tasks__c = lstTasks != null ? lstTasks.size() : 0;
                    relink.Events__c = lstEvents != null ? lstEvents.size() : 0;
                    Database.update(relink);
                    
                    relink.Status__c = STATUS_NEW;
                    Database.update(relink, false);
                    
                    continue;
                }
                else if(strMode == 'Run') {
                    // 1. Process Cases
                    list<Case> lstCasesToProcess = new list<Case>();
                    for(Case caseIterator : lstCases) {
                        caseIterator.ContactId = relink.New_Contact_Id__c;
                        lstCasesToProcess.add(caseIterator);
                        
                        if(++rowCount > iDMLRowsLimit) {
                            bLimitReached = true;
                            break;
                        }
                    }
                    TriggerExecutionController.skipCaseTrigger(true);
                    Database.update(lstCasesToProcess, false); 
                    TriggerExecutionController.skipCaseTrigger(false);
                    
                    // 2. Process Opportunities
                    if(!bLimitReached) {
                        list<Opportunity> lstOppsToProcess = new list<Opportunity>();
                        for(Opportunity oppIterator : lstOpportunities) {
                            oppIterator.Primary_Contact__c = relink.New_Contact_Id__c;
                            lstOppsToProcess.add(oppIterator);
                            
                            if(++rowCount > iDMLRowsLimit) {
                                bLimitReached = true;
                                break;
                            }
                        }
                        TriggerExecutionController.skipOpportunityTrigger(true);
                        Database.update(lstOppsToProcess, false); 
                        TriggerExecutionController.skipOpportunityTrigger(false);
                    }
                    
                    // 3. Process Sales Calls
                    if(!bLimitReached) {
                        list<Sales_Call__c> lstSCToProcess = new list<Sales_Call__c>();
                        for(Sales_Call__c scIterator : lstSalesCalls) {
                            scIterator.Contact__c = relink.New_Contact_Id__c;
                            lstSCToProcess.add(scIterator);
                            
                            if(++rowCount > iDMLRowsLimit) {
                                bLimitReached = true;
                                break;
                            }
                        }
                        // To skip Event trigger which will be called from Sales Call trigger. 
                        TriggerExecutionController.skipEventTrigger(true); 
                        Database.update(lstSCToProcess, false);
                        TriggerExecutionController.skipEventTrigger(false);
                    }
                    
                    // 4. Process Tasks
                    if(!bLimitReached) {
                        list<Task> lstTasksProcess = new list<Task>();
                        for(Task taskIterator : lstTasks) {
                            taskIterator.WhoId = relink.New_Contact_Id__c;
                            lstTasksProcess.add(taskIterator);
                            
                            if(++rowCount > iDMLRowsLimit) {
                                bLimitReached = true;
                                break;
                            }
                        }
                        TriggerExecutionController.skipTaskTrigger(true);
                        Database.update(lstTasksProcess, false); 
                        TriggerExecutionController.skipTaskTrigger(false);
                    }
                    
                    // 5. Process Events
                    if(!bLimitReached) {
                        list<Event> lstEventsProcess = new list<Event>();
                        for(Event eventIterator : lstEvents) {
                            eventIterator.WhoId = relink.New_Contact_Id__c;
                            lstEventsProcess.add(eventIterator);
                            
                            if(++rowCount > iDMLRowsLimit) {
                                bLimitReached = true;
                                break;
                            }
                        }
                        TriggerExecutionController.skipEventTrigger(true);
                        Database.update(lstEventsProcess, false); 
                        TriggerExecutionController.skipEventTrigger(false);
                    }
                }
            }
            catch(Exception ex) {
                bExceptions = true;         
                ErrorLogger.writeErrors( 'SFDC', 'RelinkContactChilds', 'Batch_RelinkContactChilds', new list<Exception>{ex}); // RQ-005636
            }
            
            // Update Status for the processed Relink_Contact_Childs__c
            if(bLimitReached || bExceptions) {
                relink.Status__c = STATUS_ERROR;
            }
            else {
                relink.Status__c = STATUS_COMPLETED;
            }
            Database.update(relink, false);
        }
    }
    
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    public class ModeNotDefinedException extends Exception {}
    public class BatchSizeExceededException extends Exception {}
    
}