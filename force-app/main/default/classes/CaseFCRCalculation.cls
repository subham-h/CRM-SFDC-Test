/*
* Author   : Nisha
* Purpose  : Class to populate FCR related fields in parent case based on closed or duplicate child case
*        
* Revision Ref Number    Date         Owner                  Description
* -------- ----------    -----------  -------------------    -----------
* 1.0      RQ-004667    20-Apr-2017  Nisha@UST               To populate FCR related fields in parent case based on closed or duplicate child case
* 2.0      RQ-005378    24-May-2015  Nisha@UST               Fix FCR Inbound Email Count issue
* 2.1      RQ-005350    24-May-2016  Ragu@UST                Handle and display user friendly error message if parent case update failed due to validation rules
* 3.0      RQ-012417    12-Nov-2019  Naved@Maersk            Create method to stamp single parent to multiple child                 
* 4.0      RQ-013010    27-Jan-2020  Naved@Maersk            Handling error if query didnt return any record
* 5.0      SC-1316      26-11-2020   ramadevi@ust            Adding FCR_Inbound_Messages__c for WhatsApp Messages
*/

public class CaseFCRCalculation {
    
    // RQ-005350
    public static void populateFCRFieldInParent(set<Id> setParentIds, set<Id> setChildIds, map<Id, Case> mapNewCases) {
        if(Generic_TriggerHandler.validateRunForMethod('CaseFCRCalculation.populateFCRFieldInParent()', 1)) {
            list<Case> lstCases = calculateFCRInParent(setParentIds, setChildIds);
            if(lstCases != null && !lstCases.isEmpty()) {
                TriggerExecutionController.skipCaseTrigger(true);
                list<Database.SaveResult> lstSaveResults = Database.update(lstCases, false);
                TriggerExecutionController.skipCaseTrigger(false);
                
                map<Id, list<Case>> mapParentIdChildCases = new map<Id, list<Case>>();
                for(Case newCase : mapNewCases.values()) {
                    if(mapParentIdChildCases.containsKey(newCase.ParentId)) {
                        mapParentIdChildCases.get(newCase.ParentId).add(newCase);
                    }
                    else {
                        mapParentIdChildCases.put(newCase.ParentId, new list<Case>{newCase});
                    }
                }
                
                for(Integer i=0; i<lstSaveResults.size(); i++) {
                    Database.SaveResult savResult = lstSaveResults[i];
                    if(!savResult.isSuccess()) {
                        Id parentId = lstCases[i].Id;
                        for(Case childCase : mapParentIdChildCases.get(parentId)) {
                            childCase.addError(Label.Duplicate_Case_Merge_Error);
                        }
                    }
                }
            }
        }
    }
    
    public static list<Case> calculateFCRInParent(set<Id> setParentIds, set<Id> setChildIds) {
        // RQ-005378: Start
        set<String> setContactEmails = new set<String>();
        for(Case caseIterator : [SELECT Id, Contact.Email FROM Case WHERE Id IN : setChildIds and Contact.Email != null]) {
           setContactEmails.add(caseIterator.Contact.Email);
        }
        
        // Count all the incoming email message associated with the child cases.
        map<Id, Decimal> mapCaseIdEmailsCount = new map<Id, Integer>(); // RQ-005378
        for(AggregateResult ar : [SELECT ParentId, COUNT(Id) emailCount FROM EmailMessage WHERE ParentId IN :setChildIds AND FromAddress IN :setContactEmails AND Incoming = true GROUP BY ParentId]) {
            mapCaseIdEmailsCount.put((Id)ar.get('ParentId'), Integer.valueOf(ar.get('emailCount')));
        }
        // RQ-005378: End
        
        map<Id, Integer> mapCaseIdTasksCount = new map<Id, Integer>();
        for(AggregateResult ar : [SELECT WhatId, count(Id) taskCount FROM Task WHERE Type = 'Call' AND Direction__c = 'Inbound' AND WhatId IN :setChildIds group by WhatId]) {
            mapCaseIdTasksCount.put((Id)ar.get('WhatId'), Integer.valueOf(ar.get('taskCount')));
        }
        
        list<Case> lstCases = [SELECT Id, IsClosed, FCR_Inbound_Contact_Emails__c, FCR_Inbound_Calls__c, FCR_Inbound_Case_Comment__c, FCR_Inbound_Chats__c,FCR_Inbound_Messages__c, FCR_Post_Closure_Activity_Date__c, ClosedDate, (SELECT Id, CreatedDate, FCR_Inbound_Contact_Emails__c, FCR_Inbound_Calls__c, FCR_Inbound_Case_Comment__c, FCR_Inbound_Chats__c,FCR_Inbound_Messages__c FROM Cases WHERE Id in :setChildIds ORDER BY CreatedDate DESC) FROM Case WHERE Id in :setParentIds];
        for(Case parentCase : lstCases) {
            for(Case childCase : parentCase.Cases) {
                if(parentCase.IsClosed) {
                    // Assign CreatedDate of the first child case created for the parent           
                    if(childCase.CreatedDate > parentCase.ClosedDate && (parentCase.FCR_Post_Closure_Activity_Date__c == null || childCase.CreatedDate < parentCase.FCR_Post_Closure_Activity_Date__c)) {
                        parentCase.FCR_Post_Closure_Activity_Date__c = childCase.CreatedDate;
                    }
                }
                else {
                    // Skip FCR_Inbound_Contact_Emails__c calculation for cases merged via duplicate case manager since EmailMessages are reparented to parent case. 
                    if(!DuplicateCaseManagerExtension.bDuplicateCaseManager) {
                        parentCase.FCR_Inbound_Contact_Emails__c = (parentCase.FCR_Inbound_Contact_Emails__c != null ? parentCase.FCR_Inbound_Contact_Emails__c : 0) + (mapCaseIdEmailsCount.containsKey(childCase.Id) ? mapCaseIdEmailsCount.get(childCase.Id) : 0);
                    }
                    parentCase.FCR_Inbound_Calls__c = (parentCase.FCR_Inbound_Calls__c != null ? parentCase.FCR_Inbound_Calls__c : 0) + (mapCaseIdTasksCount.containsKey(childCase.Id) ? mapCaseIdTasksCount.get(childCase.Id) : 0);
                    parentCase.FCR_Inbound_Case_Comment__c = (parentCase.FCR_Inbound_Case_Comment__c != null ? parentCase.FCR_Inbound_Case_Comment__c : 0) + (childCase.FCR_Inbound_Case_Comment__c != null ? childCase.FCR_Inbound_Case_Comment__c : 0);
                    parentCase.FCR_Inbound_Chats__c = (parentCase.FCR_Inbound_Chats__c != null ? parentCase.FCR_Inbound_Chats__c : 0) + (childCase.FCR_Inbound_Chats__c != null ? childCase.FCR_Inbound_Chats__c : 0);
                    parentCase.FCR_Inbound_Messages__c = (parentCase.FCR_Inbound_Messages__c!= null ? parentCase.FCR_Inbound_Messages__c: 0) + (childCase.FCR_Inbound_Messages__c!= null ? childCase.FCR_Inbound_Messages__c: 0);
                }
            }
        }
        return lstCases;
    }
    //RQ-012417
    public static Case calculateFcrInParentDuplicate(Id ParentCaseId, set<Id> setChildIds) {
        // RQ-005378: Start
        set<String> setContactEmails = new set<String>();
        for(Case caseIterator : [SELECT Id, Contact.Email FROM Case WHERE Id IN : setChildIds and Contact.Email != null]) {
           setContactEmails.add(caseIterator.Contact.Email);
        }
        
        // Count all the incoming email message associated with the child cases.
        map<Id, Decimal> mapCaseIdEmailsCount = new map<Id, Integer>(); // RQ-005378
        //RQ-013010
        for( AggregateResult ar :[SELECT ParentId, COUNT(Id) emailCount FROM EmailMessage WHERE ParentId = :ParentCaseId AND FromAddress IN :setContactEmails AND Incoming = true group by parentid]){
             mapCaseIdEmailsCount.put((Id)ar.get('ParentId'), Integer.valueOf(ar.get('emailCount')));
            // RQ-005378: End
         }
        
        map<Id, Integer> mapCaseIdTasksCount = new map<Id, Integer>();
        for(AggregateResult arr : [SELECT WhatId, count(Id) taskCount FROM Task WHERE Type = 'Call' AND Direction__c = 'Inbound' AND WhatId IN :setChildIds group by WhatId]) {
            mapCaseIdTasksCount.put((Id)arr.get('WhatId'), Integer.valueOf(arr.get('taskCount')));
        }
        
        Case parentcase = [SELECT Id, IsClosed, FCR_Inbound_Contact_Emails__c, FCR_Inbound_Calls__c, FCR_Inbound_Case_Comment__c, FCR_Inbound_Chats__c, FCR_Post_Closure_Activity_Date__c, ClosedDate,FCR_Inbound_Messages__c FROM Case WHERE Id = :ParentCaseId];
        //Extra query due to child is not stamp with parent id yet
        list<Case> lstChildCase= [SELECT Id, CreatedDate, FCR_Inbound_Contact_Emails__c, FCR_Inbound_Calls__c, FCR_Inbound_Case_Comment__c, FCR_Inbound_Chats__c,FCR_Inbound_Messages__c FROM Case WHERE Id in :setChildIds ORDER BY CreatedDate DESC];
            
        //Remove parentCase.cases
        for(Case childCase : lstChildCase) {
            if(parentCase.IsClosed) {
                // Assign CreatedDate of the first child case created for the parent           
                if(childCase.CreatedDate > parentCase.ClosedDate && (parentCase.FCR_Post_Closure_Activity_Date__c == null || childCase.CreatedDate < parentCase.FCR_Post_Closure_Activity_Date__c)) {
                    parentCase.FCR_Post_Closure_Activity_Date__c = childCase.CreatedDate;
                }
            }
            else {
                // Skip FCR_Inbound_Contact_Emails__c calculation for cases merged via duplicate case manager since EmailMessages are reparented to parent case. 
                if(!DuplicateCaseManagerExtension.bDuplicateCaseManager) {
                    parentCase.FCR_Inbound_Contact_Emails__c = (parentCase.FCR_Inbound_Contact_Emails__c != null ? parentCase.FCR_Inbound_Contact_Emails__c : 0) + (mapCaseIdEmailsCount.containsKey(childCase.Id) ? mapCaseIdEmailsCount.get(childCase.Id) : 0);
                }
                parentCase.FCR_Inbound_Calls__c = (parentCase.FCR_Inbound_Calls__c != null ? parentCase.FCR_Inbound_Calls__c : 0) + (mapCaseIdTasksCount.containsKey(childCase.Id) ? mapCaseIdTasksCount.get(childCase.Id) : 0);
                
                parentCase.FCR_Inbound_Case_Comment__c = (parentCase.FCR_Inbound_Case_Comment__c != null ? parentCase.FCR_Inbound_Case_Comment__c : 0) + (childCase.FCR_Inbound_Case_Comment__c != null ? childCase.FCR_Inbound_Case_Comment__c : 0);
                
                parentCase.FCR_Inbound_Chats__c = (parentCase.FCR_Inbound_Chats__c != null ? parentCase.FCR_Inbound_Chats__c : 0) + (childCase.FCR_Inbound_Chats__c != null ? childCase.FCR_Inbound_Chats__c : 0);
                
                parentCase.FCR_Inbound_Messages__c= (parentCase.FCR_Inbound_Messages__c!= null ? parentCase.FCR_Inbound_Messages__c: 0) + (childCase.FCR_Inbound_Messages__c != null ? childCase.FCR_Inbound_Messages__c : 0);
            
            }
        }
        
        return parentcase;
    }
    
}