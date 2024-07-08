/*
 * Author   : Ranjini@UST
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on Survey trigger.
 * 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0     RQ-008231    18/04/2018  Ranjini@Ust             Follow up Age in Business Hours
 * 2.0     SC-1041      16/02/2021  Sreya@Maersk			Implementation of Task Survey
 * 3.0     SC-4859      07-04-2022  Richa@Maersk            Added condition for 4PL Case Survey apex sharing
 * 4.0     SC-9293     22-12-2023  Shahanawaz@maersk       	Create feeditem on parent Case
*/
public class SurveyTriggerHandler extends TriggerHandler{
    
    public map<Id, Survey__c> newMap;
    public map<Id, Survey__c> oldMap;
    public SurveyTriggerHandler() {
        this.newMap = (map<Id, Survey__c>)Trigger.newMap;
        this.oldMap = (map<Id, Survey__c>)Trigger.oldMap; 
    }
    
    public SurveyRecordSelector svyRecordSelector;
    
   
    public override void getRecordSelector() {
        svyRecordSelector = new SurveyRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeUpdate() {
        if(!svyRecordSelector.lstSurveysToUpdateAge.isEmpty()) {
           System.debug('##### inside handler'); 
            SurveyFieldPopulator.populateFollowUpAgeInBusinessHours(svyRecordSelector.lstSurveysToUpdateAge, svyRecordSelector.mapCaseBH,svyRecordSelector.lstTaskIdentifier);
        }
    }
    // SC-1041 : Updating Task Survey Fields
    public override void onBeforeInsert() {
        if(!svyRecordSelector.lstTaskSurvey.isEmpty()) {
            SurveyFieldPopulator.populateTaskSurvey(svyRecordSelector.lstTaskSurvey,svyRecordSelector.lstTaskIds);
        }
    }
    
    public override void onAfterInsert() {
        if(!svyRecordSelector.set4PLSurveyIds.isEmpty()) {
            ApexSharingUtility.updateSharing(svyRecordSelector.set4PLSurveyIds,'Survey__c','Survey_Visibility__c','Edit',Schema.Survey__Share.RowCause.Access_To_4PL__c,false);
        }
        
        if(!svyRecordSelector.surveyList.isEmpty()){
            SurveyFieldPopulator.createFeedItem(svyRecordSelector.surveyList);
        }
    }
    
    public override void onAfterUpdate() {
        if(!svyRecordSelector.set4PLSurveyIds.isEmpty()) {
            ApexSharingUtility.updateSharing(svyRecordSelector.set4PLSurveyIds,'Survey__c','Survey_Visibility__c','Edit',Schema.Survey__Share.RowCause.Access_To_4PL__c,true);
        }
    }
}