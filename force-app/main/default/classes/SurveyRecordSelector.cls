/*
* Author   : Ranjini@UST
* Purpose  : Centralize the record selection process for Survey object.
*            Defines the methods which iterate and segregate the Survey records for further use.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0     RQ-008231    18/04/2018  Ranjini@Ust             Follow up Age in Business Hours
* 2.0     SC-1401      16/02/2021  Sreya@maersk            Implementation of Task Survey
* 3.0     SC-4859      07-04-2022  Richa@Maersk            Added condition for 4PL Case Survey apex sharing
* 4.0     SC-9293     22-12-2023  Shahanawaz@maersk       	Create feeditem on parent Case
*/
public class SurveyRecordSelector implements RecordSelector {
    
    private TriggerHandler svyTriggerHandler;
    
    public list<Survey__c> lstSurveysToUpdateAge = new list<Survey__c>();
    public list<Id> lstCaseIdSvyBH = new List<Id>();
    public map<Id,Id> mapCaseBH = new map<Id,Id>();
    
    //SC-1041
    public List<Survey__c> lstTaskSurvey = new List<Survey__c>();
    public List<String> lstTaskIds = new List<String>();
    public List<String> lstTaskIdentifier = new List<String>();
    public Set<Id> set4PLSurveyIds  = new Set<Id>();// SC-4859
    public List<Survey__c> surveyList = new List<Survey__c>();
    
    public SurveyRecordSelector(list<Survey__c> lstSurveys, map<Id, Survey__c> mapOldSurveys, TriggerHandler svyTriggerHandler) {
        this.svyTriggerHandler = svyTriggerHandler;
        
        this.selectRecords(lstSurveys, mapOldSurveys);
        
        if(lstSurveys != null) {
            this.getRelatedRecords(lstSurveys);
        }
        
    }
    
    public void selectRecords(list<Survey__c> lstSurveys, map<Id, sObject> mapOldSurveys) {
        Id TaskSurveyRecordTypeId = StaticFactory.getRecordTypeIdByName('Survey__c', 'Task Survey');
        Id CaseSurveyRecordTypeId = StaticFactory.getRecordTypeIdByName('Survey__c', 'Case Survey');
        for(Survey__c newSurvey : (list<Survey__c>)lstSurveys) {
            
            Survey__c oldSurvey;
            if(mapOldSurveys != null && !mapOldSurveys.isEmpty()) {
                oldSurvey = (Survey__c)mapOldSurveys.get(newSurvey.Id);                   
            }
            
            if(svyTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) {
                // SC-1041 : getting the list of surveys created by cisco identified with Task_Identifier__c field. 
                if(svyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                    if(string.isNotBlank(newSurvey.Task_Identifier__c)) {
                        lstTaskSurvey.add(newSurvey);
                        lstTaskIds.add(newSurvey.Task_Identifier__c);
                    } 
                }
                if(svyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                    if((newSurvey.Response_Actions__c == 'Followed Up' && oldSurvey.Response_Actions__c != 'Followed Up')  ||   oldSurvey.Followed_Up_Date__c != newSurvey.Followed_Up_Date__c ) {
                        lstSurveysToUpdateAge.add(newSurvey);
                        lstCaseIdSvyBH.add(newSurvey.Case__c);
                        if(newSurvey.RecordTypeId == TaskSurveyRecordTypeId && string.isNotBlank(newSurvey.Task_Identifier__c)) {
                            lstTaskIdentifier.add(newSurvey.Task_Identifier__c);
                        }
                    }
                } 
            }
            if(svyTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER) {
                if(svyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                    //SC-4859 - Get the list of 4PL surveys          
                    if(newSurvey.RecordTypeId == CaseSurveyRecordTypeId && newSurvey.Multi_Carrier_Restricted_Account__c==Null){
                        set4PLSurveyIds.add(newSurvey.Id); 
                    }
                    //SC-9293
                    if(newSurvey.Case__c != null){
                        surveyList.add(newSurvey);
                    }
                }
                if(svyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                    //SC-4859 - Get the list of 4PL Surveys for update      
                    if(newSurvey.RecordTypeId == CaseSurveyRecordTypeId && newSurvey.Multi_Carrier_Restricted_Account__c==Null &&  newSurvey.SF_4PL_Account__c != oldSurvey.SF_4PL_Account__c || oldSurvey.OwnerId != newSurvey.OwnerId || newSurvey.Survey_Visibility__c != oldSurvey.Survey_Visibility__c){
                        set4PLSurveyIds.add(newSurvey.Id); 
                    } 
                }
                
            }
        }
    }
    
    public void getRelatedRecords(list<Survey__c> lstSurveys) {
        //Add code here if needed
        getmapSurveyBH();
    }
    
    public void getmapSurveyBH(){
        for(Case caseRec : [Select Id, BusinessHoursId from Case Where Id IN: lstCaseIdSvyBH]){
            mapCaseBH.put(caseRec.Id, caseRec.BusinessHoursId);
        }
    }
}