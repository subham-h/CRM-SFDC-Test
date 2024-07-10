/* 
 * Purpose  : Batch class scheduled to populate field 'FCR_Post_Closure_Activity_Date__c' which captures the first Task activity (Type  = Call, Direction = Inbound) date
 *            after the Case has been marked as 'Closed -Resolved'.
 * 
 * Revision     Ref Number      Date            Owner                                   Description
 * --------     ----------      -----------     -------------------                     -----------
 * 1.0          RQ-001479       30/06/2015      Sandhya.Sambasivan@ust-global.com       Code created as part of #RQ-001479
 * 2.0          RQ-001740       22/07/2015      Sandhya.Sambasivan@ust-global.com       Fix for Case FCR Batch Apex test class
 * 3.0          RQ-002633       23/02/2015      Ragupathivel.Thangavel@ust-global.com   Added filter condition to process External Cases alone.
 * 4.0          RQ-004570       19/12/2016      Nisha.Arjunan@ust-global.com            Update the comments to replace references to email with task, copy paste error
 * 5.0          RQ-007163       16/10/2017      Nisha.Arjunan@ust-global.com           Replace BatchErrorLogger with ErrorLogger
 *
 */
 

global class BatchFCRTaskDetails implements Database.Batchable<sObject> , Database.Stateful {

    // Class variables...
    map<Id, String> mapCaseIdErrorDes = new map<Id, String>(); // To be used in creating Batch Error Logger

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // RQ-001740 : Use this label only when running test class. This ensures even if the date raneg changes in FCR_Batch_Date_Range, the test class will not break.
        String periodStr = (Test.isRunningTest() ? Label.FCR_Batch_Date_Range_Testing : Label.FCR_Batch_Date_Range);
        String query = 'SELECT Id, WhatId, CreatedDate FROM Task WHERE What.Type = \'Case\' AND CreatedDate = ' + periodStr + ' AND TYPE =\'Call\' AND Direction__c = \'Inbound\' ORDER BY CreatedDate ASC';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Task> scope) {
        list<Case> lstCasesToUpdate = new list<Case>();
        map<Id, list<Task>> mapCasdIdTasks = new map<Id, list<Task>>();
        Id externalCaseRTId = StaticFactory.getRecordTypeIdByName('Case', Label.External_Case);
        
        for(Task taskIterator : scope) {
            // If the map already contains an entry for that Task's Case, just add the it to the map entry's list...
            if(mapCasdIdTasks.containsKey(taskIterator.WhatId)) {
                mapCasdIdTasks.get(taskIterator.WhatId).add(taskIterator);
            }
            else {
                // There isn't an entry in the map yet so add a new entry into the map and the task that caused it, in a list of course...
                mapCasdIdTasks.put(taskIterator.WhatId, new list<Task> {taskIterator});
            }
        }
        
        // Now get the Cases for any Tasks that were included in the scope and that have been resolved, RESOLVED I say, not just closed!!!
        for(Case caseIterator : [SELECT Id, Date_First_Resolved__c, FCR_Post_Closure_Activity_Date__c FROM Case WHERE Id IN :mapCasdIdTasks.keySet() AND RecordTypeId = :externalCaseRTId AND Is_Resolved__c = true AND FCR__c = 'TRUE']) {
            // list of Date/Times used to hold Task Date which are after FCR_First_Closure_Date__c...
            list<DateTime> lstTaskCreatedDates = new list<DateTime>();
            
            // For each Case get the tasks from mapCasdIdTasks and if the task created date is more recent than FCR_First_Closure_Date__c add it to the list... 
            for(Task taskIterator : mapCasdIdTasks.get(caseIterator.Id)) {
                if(taskIterator.CreatedDate> caseIterator.Date_First_Resolved__c) {
                    lstTaskCreatedDates.add(taskIterator.CreatedDate);
                }
            }

            // Sort the list to get the smallest date which will be at position 0...
            if(lstTaskCreatedDates.size() > 0) {
                lstTaskCreatedDates.sort();
                
                // Remember we're trying to accurately set the FCR_Post_Closure_Activity_Date__c. 
                // To do this we need to check if another interaction (remember we're multi-channel) happened before a task in scope.
                // If FCR_Post_Closure_Activity_Date__c is null then of course set it immediately...
                if(lstTaskCreatedDates[0] != null && caseIterator.FCR_Post_Closure_Activity_Date__c == null) {
                    caseIterator.FCR_Post_Closure_Activity_Date__c = lstTaskCreatedDates[0];
                    lstCasesToUpdate.add(caseIterator);
                } 
                else if(lstTaskCreatedDates[0] != null &&(caseIterator.FCR_Post_Closure_Activity_Date__c != null && lstTaskCreatedDates[0] < caseIterator.FCR_Post_Closure_Activity_Date__c)) {
                    caseIterator.FCR_Post_Closure_Activity_Date__c = lstTaskCreatedDates[0];
                    lstCasesToUpdate.add(caseIterator);
                }
            }
        }
        
        if(lstCasesToUpdate != null && lstCasesToUpdate.size() > 0) {
            // Try updating the Cases with allOrNone set to false so the whole update isn't rolled back if just one record fails...
            Database.SaveResult[] lstSaveResults = Database.Update(lstCasesToUpdate, false);
            ErrorLogger.writeErrors('SFDC', 'Case', 'BatchFCRTaskDetails', lstSaveResults, lstCasesToUpdate); // #RQ-007163
        }
    }

    global void finish(Database.BatchableContext BC) {
       
    }

}