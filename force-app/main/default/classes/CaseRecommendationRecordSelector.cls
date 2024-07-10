/**
* Author   : Vazid@UST
* Purpose  : Centralize the record selection process for Case Recommendation object.
*          Defines the methods which iterate and segregate the Case Recommendation records for further use.

* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-10036   17-05-2024 	Vazid@UST                Created for implementing logic for checker queue
**/

public class CaseRecommendationRecordSelector implements RecordSelector{
    
    private CaseRecommendationTriggerHandler caseRecommendationTriggerHandler;
    public List<Case_Recommendation__C> lstOfHoldorReleasedCRlist = new List<Case_Recommendation__C>();
    public List<Case_Recommendation__C> lstOfNonHoldCRlist = new List<Case_Recommendation__C>();
    public set<Id> setOfHoldCaseIds = new set<Id>();
    public set<Id> setOfReleasedCaseIds = new set<Id>();
    public Set<Id> setCaseIds = new Set<Id>();
    public map<Id, Case> mapCaseDetails = new map<Id, Case>();
    public set<Id> setOfExistingRecommCaseIds = new set<Id>();

    public static string emailRecommRecTypeId = Case_Recommendation__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Email Recommendation').getRecordTypeId();
    public static string resolutionRecommRecTypeId = Case_Recommendation__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Resolution Recommendation').getRecordTypeId();
    
    public CaseRecommendationRecordSelector(List<Case_Recommendation__C> listcaseRecommendations, Map<Id, Case_Recommendation__C> oldCRMap, CaseRecommendationTriggerHandler caseRecommendationTriggerHandler){
        this.caseRecommendationTriggerHandler = caseRecommendationTriggerHandler;
        
        for(Case_Recommendation__C caseReco : listcaseRecommendations){
            setCaseIds.add(caseReco.Case__c);
        }
        
        mapCaseDetails = getCaseDetails(setCaseIds);
        selectRecords(listcaseRecommendations, oldCRMap); 
    }
    public void selectRecords(list<Case_Recommendation__C> listcaseRecommendations, map<Id, SObject> oldCRMap) {
        
        for(Case_Recommendation__C recordCR: listcaseRecommendations){
            if(caseRecommendationTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && caseRecommendationTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT){
                if(recordCR.RecordTypeId == resolutionRecommRecTypeId && recordCR.Action_Status__c == 'Hold'){
                    setOfHoldCaseIds.add(recordCR.Case__c);
                }else if(recordCR.RecordTypeId == resolutionRecommRecTypeId && recordCR.Action_Status__c == 'Released'){
                    setOfReleasedCaseIds.add(recordCR.Case__c);
                }else{
                    lstOfNonHoldCRlist.add(recordCR);
                    
                    if(recordCR.RecordTypeId == emailRecommRecTypeId && mapCaseDetails.containsKey(recordCR.Case__c) && 
                       mapCaseDetails.get(recordCR.Case__c).AI_Recommendation_Status__c == 'On Hold'){
                        setOfReleasedCaseIds.add(recordCR.Case__c);
                    }
                    
                }
                //To delete existing recommendations if we receive gen2 recommendation in re-trigger scenario
                if(recordCR.RecordTypeId == resolutionRecommRecTypeId){
                    setOfExistingRecommCaseIds.add(recordCR.Case__c);
                }
            }
            
            if(caseRecommendationTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER && caseRecommendationTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT){
                if(recordCR.RecordTypeId == resolutionRecommRecTypeId && (recordCR.Action_Status__c == 'Hold' || recordCR.Action_Status__c == 'Released')){
                    lstOfHoldorReleasedCRlist.add(new Case_Recommendation__C(Id = recordCR.Id));
                }   
            }
        }
    }
    
    public void getRelatedRecords( list<Case_Recommendation__C> listcaseRecommendations ) {
        
    }
    
    //Query for getting the Case details
    public static map<Id, Case> getCaseDetails(Set<Id> setCaseIds) {
        map<Id, Case> mapCaseDetails = new Map<Id, Case>([SELECT Id, CaseNumber, AI_Recommendation_Status__c FROM Case WHERE Id in :setCaseIds]);
        
        return mapCaseDetails;
    }
    
    
}