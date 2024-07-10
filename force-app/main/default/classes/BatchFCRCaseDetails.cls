/* 
 * Purpose  : Purpose of this class is to count the number of INBOUND emails and Activities WITH IN  the Case has been "Closed - Resolved".
 * 
 * Revision     Ref Number      Date         Owner                                  Description
 * --------     ----------      -----------  -------------------                    -----------
 * 1.0          RQ-001479       30/06/2015   Sandhya.Sambasivan@ust-global.com      Code created as part of #RQ-001479
 * 2.0          RQ-001740       22/07/2015   Sandhya.Sambasivan@ust-global.com      Fix for Case FCR Batch Apex test class
 * 3.0          RQ-001748       22/07/2015   Ranjini.Janardhanan@ust-global.com     Added filter to check the inbound email is from Case Contact Email.
 * 4.0          RQ-002633       23/02/2015   Ragupathivel.Thangavel@ust-global.com  Added filter condition to process External Cases alone.
 * 5.0          RQ-003320       08/04/2016   Sandhya.Sambasivan@ust-global.com      Replace MessageDate with CreatedDate for email message
 * 6.0          RQ-004570       19/12/2016   Nisha.Arjunan@ust-global.com           Scheduled BatchFCRTaskDetails instead of  BatchFCREmailMessageDetails and commented email related entries.
 * 7.0          RQ-004667       20/04/2017   Nisha.Arjunan@ust-global.com           If a case is already having value in FCR_Inbound_Calls__c, system should add it to the calculated value instead of overwriting.
 * 8.0          RQ-005378       24/05/2017   Ranjini.Janardhanan@ust-global.com     Rolledback the FCR Email Count logic from WF to Batch class.
 * 9.0          RQ-007163       16/10/2017   Nisha.Arjunan@ust-global.com           Replace BatchErrorLogger with ErrorLogger
 * 10.0         RQ-009034       1/08/2018    Ranjini@ust                            Added dispute records also to FCR.
 * 11.0							10/02/2023	 Vivek@Maersk							Removed Database.Stateful from definition to prevent delay in processing time

 */

global class BatchFCRCaseDetails implements Database.Batchable<sObject>  {

    // Class variables...
    map<Id, String> mapCaseIdErrors = new map<Id, String>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Id externalCaseRTId = StaticFactory.getRecordTypeIdByName('Case', Label.External_Case);
        
        //#RQ-009034
        List <String> recordTypeIds = new List <String> ();
        recordTypeIds.add(StaticFactory.getRecordTypeIdByName('Case', Label.External_Case));
        recordTypeIds.add(StaticFactory.getRecordTypeIdByName('Case', Label.Dispute));
        // Get all Cases set to a resolved Status today and that have not gone through the FCR batch calculation process yet.
        // RQ-001740 : Use this label only when running test class. This ensures even if the date raneg changes in FCR_Batch_Date_Range, the test class will not break.
        
        // Get all Cases set to a resolved Status today and that have not gone through the FCR batch calculation process yet.
        // RQ-001740 : Use this label only when running test class. This ensures even if the date raneg changes in FCR_Batch_Date_Range, the test class will not break.
        String periodStr = (Test.isRunningTest() ? Label.FCR_Batch_Date_Range_Testing : Label.FCR_Batch_Date_Range);
        //String query = 'SELECT Id, ClosedDate, Contact.Email, FCR_Process_Date__c, Is_Resolved__c, Date_First_Resolved__c, FCR_Inbound_Contact_Emails__c, FCR_Inbound_Calls__c FROM Case WHERE RecordTypeId = \'' + externalCaseRTId + '\' AND ClosedDate = ' + periodStr + ' AND Is_Resolved__c = true AND FCR_Process_Date__c = null';
        String query = 'SELECT Id, ClosedDate, Contact.Email, FCR_Process_Date__c, Is_Resolved__c, Date_First_Resolved__c, FCR_Inbound_Contact_Emails__c, FCR_Inbound_Calls__c FROM Case WHERE  RecordTypeId IN :recordTypeIds AND ClosedDate = ' + periodStr + ' AND Is_Resolved__c = true AND FCR_Process_Date__c = null';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Case> scope) {
        // Iterate through the scope and build a map of Case Id's adn date first resolved to use later...
        map<Id, String> mapCaseIdContactEmail = new map<Id, String> ();
        map<Id, DateTime> mapCaseIdDateFirstResolved = new map<Id, DateTime> ();
        for(Case caseIterator : scope) {
            if(caseIterator.Contact.Email != null) {
                mapCaseIdContactEmail.put(caseIterator.Id, caseIterator.Contact.Email);
            }
            mapCaseIdDateFirstResolved.put(caseIterator.Id, caseIterator.Date_First_Resolved__c);
        }
        
        // RQ-005378 - Added back the below code block to calculate FCR_Inbound_Contact_Emails__c instead of populating it in workflow. 
        // Get the number of inbound Email Messages with in the time of case closure. 
        // We can not use Aggreage Query here as we need to get the count of emails before the case first resolved date.
        map<Id, Integer> mapCaseIdEmailCount = new map<Id, Integer>();
        for(Emailmessage emailIterator : [SELECT Id, ParentId, CreatedDate, FromAddress FROM EmailMessage
                        WHERE Incoming = true AND FromAddress IN :mapCaseIdContactEmail.values() AND ParentId IN :mapCaseIdContactEmail.keySet() order by ParentId, CreatedDate] // RQ-003320
            ) {
            // RQ-001748.Added filter to check the inbound email is from Case Contact Email.
            if(emailIterator.CreatedDate <= mapCaseIdDateFirstResolved.get(emailIterator.ParentId) && emailIterator.FromAddress == mapCaseIdContactEmail.get(emailIterator.ParentId)) { // RQ-003320
                if(mapCaseIdEmailCount.containsKey(emailIterator.ParentId)) {
                    mapCaseIdEmailCount.put(emailIterator.ParentId, mapCaseIdEmailCount.get(emailIterator.ParentId) + 1);
                }
                else {
                  mapCaseIdEmailCount.put(emailIterator.ParentId, 1);
                }
            }
        }
        
        // Get the number of inbound Calls with in the time of case closure. 
        // We can not use Aggreage Query here as we need to get the count of calls before the case first resolved date.
        map<Id, Integer> mapCaseIdTaskCount = new map<Id, Integer>();
        for(Task taskIterator : [SELECT Id, WhatId, CreatedDate FROM Task WHERE Type = 'Call' AND Direction__c = 'Inbound' AND WhatId IN :mapCaseIdDateFirstResolved.keySet()]) {
            if(taskIterator.CreatedDate <= mapCaseIdDateFirstResolved.get(taskIterator.WhatId)) {
                if(mapCaseIdTaskCount.containsKey(taskIterator.WhatId)) {
                    mapCaseIdTaskCount.put(taskIterator.WhatId, mapCaseIdTaskCount.get(taskIterator.WhatId) + 1);
                } 
                else {
                    mapCaseIdTaskCount.put(taskIterator.WhatId, 1);
                }
            }
        }

        // Copy the count of interactions to the parent Cases...
        for(Case caseIterator : scope) {
            caseIterator.FCR_Process_Date__c = System.now();
      
          // RQ-005378 - We also need to cosider the email message count came via the merged child cases if any. We should not override this count.
            if(mapCaseIdEmailCount.get(caseIterator.Id) != null) {
                caseIterator.FCR_Inbound_Contact_Emails__c = caseIterator.FCR_Inbound_Contact_Emails__c + mapCaseIdEmailCount.get(caseIterator.Id);
            }
      
          // RQ-004667 - We also need to cosider the task count came via the merged child cases if any. We should not override this count.
            if(mapCaseIdTaskCount.get(caseIterator.Id) != null) {
                caseIterator.FCR_Inbound_Calls__c = caseIterator.FCR_Inbound_Calls__c + mapCaseIdTaskCount.get(caseIterator.Id); 
            }
        }

        if(scope != null && scope.size() > 0) {
            // Try updating with allOrNone set to false so the whole update isn't rolled back if just one record fails...
            Database.SaveResult[] lstSaveResults = Database.Update(scope, false);
            ErrorLogger.writeErrors('SFDC', 'Case', 'BatchFCRCaseDetails', lstSaveResults, scope); // #RQ-007163
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Skip the chaining of batch classes for test run
        if(!Test.isRunningTest()) {
           // RQ-004570: Scheduled BatchFCRTaskDetails instead of BatchFCREmailMessageDetails
           Id newbacthID = Database.executeBatch(new BatchFCRTaskDetails());
        }
    }
    
}