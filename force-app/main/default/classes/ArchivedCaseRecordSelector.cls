/*
* Author    : Raksha
* Purpose   : Leverage Case Sharing into Archived Case object once the Cases are archived. 
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-4508     10-Jan-2023 Raksha@Maersk           Case record sharing once created/Updated
*/
public class ArchivedCaseRecordSelector implements RecordSelector {
     public TriggerHandler archivedCaseTriggerHandler; 
     public List<Archived_Case__c> lstIdeaVote = new List<Archived_Case__c>();
     public Set<Id> set4PLCaseIds  = new Set<Id>();
     public Set<Id> set4PLCaseIdsPortal = new Set<Id>();
     public ArchivedCaseRecordSelector(list<Archived_Case__c> listIdeaVote, map<Id, Archived_Case__c> mapOldIdeaVotes, ArchivedCaseTriggerHandler archivedCaseTriggerHandler) {
        this.archivedCaseTriggerHandler= archivedCaseTriggerHandler;
        selectRecords(listIdeaVote, mapOldIdeaVotes);
    }
     public void selectRecords(list<Archived_Case__c> listIdeaVote, map<Id, sObject> mapOldIdeaVotes) {
        Id externalCaseRTId = Archived_Case__c.sObjectType.getDescribe().getRecordTypeInfosByName().get(Label.External_Case).getRecordTypeId();
        Id isrRTId = Archived_Case__c.sObjectType.getDescribe().getRecordTypeInfosByName().get(Label.ISR).getRecordTypeId();
         if(listIdeaVote != null) {
             for(Archived_Case__c newArchCase : (list<Archived_Case__c>)listIdeaVote) {
                 Archived_Case__c oldCase;
                 if(mapOldIdeaVotes != null && !mapOldIdeaVotes.isEmpty()) {
                    oldCase = (Archived_Case__c)mapOldIdeaVotes.get(newArchCase.Id);
                 }
                 if(archivedCaseTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER){
                     if(archivedCaseTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                         //Get cases for 4PL sharing
                         if(newArchCase.RecordTypeId == externalCaseRTId || newArchCase.RecordTypeId == isrRTId) {
                           set4PLCaseIds.add(newArchCase.Id); 
                        }
                     }
                     else if(archivedCaseTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                         //Get cases for 4PL sharing
                        if((newArchCase.RecordTypeId == externalCaseRTId || newArchCase.RecordTypeId == isrRTId) && (oldCase.SF_4PL_Account__c != newArchCase.SF_4PL_Account__c || oldCase.OwnerId != newArchCase.OwnerId  || newArchCase.Case_Visibility__c !=  oldCase.Case_Visibility__c || newArchCase.RecordTypeId != oldCase.RecordTypeId)){
                           set4PLCaseIds.add(newArchCase.Id); 
                        }
                     }
                 
                 }
              }
         }    
     }
     
     public void getRelatedRecords(list<Archived_Case__c> lstarcCases) {
     
     }
}