/*
* Author   : Ranjini@UST
* Purpose  : Utility class to hold simple and reusable functionalities for auto populating Survey fields. 
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0     RQ-008231    18/04/2018  Ranjini@Ust             Follow up Age in Business Hours
* 2.0     SC-1041      16/02/2021  Sreya@Maersk			   Implementation of Task Survey
* 3.0     SC-9293     22-12-2023  Shahanawaz@maersk       	Create feeditem on parent Case
*/
public class SurveyFieldPopulator {
    
    public static void populateFollowUpAgeInBusinessHours(List<Survey__c> lstSurveysToUpdateAge,Map<Id,Id> lstCaseIdSvyBH,List<String> lstTaskIdentifier){
        try{
            Id VoiceCallTaskRecordTypeId = StaticFactory.getRecordTypeIdByName('Task', 'Voice Call');
            Id TaskSurveyRecordTypeId = StaticFactory.getRecordTypeIdByName('Survey__c', 'Task Survey');
            map<String,String> mapTaskBH = new map<String,String>();
            for(Task taskRec : [Select CallObject, Business_Hours__c from Task Where CallObject IN: lstTaskIdentifier and RecordTypeId =: VoiceCallTaskRecordTypeId]){
                mapTaskBH.put(taskRec.CallObject, taskRec.Business_Hours__c);
            }
            for(Survey__c svy : lstSurveysToUpdateAge){
                if(svy.Case__c != null && lstCaseIdSvyBH.get(svy.Case__c) != null){
                    //= Double dTimeSinceLastStatus
                    svy.Follow_Up_Age_BH__c  = BusinessHours.diff(lstCaseIdSvyBH.get(svy.Case__c), svy.Created_Date_Time__c , System.now()) / 3600000.0;
                }
                //SC-1401 - Updating Follow_Up_Age_BH__c field for task survey
                else if(svy.RecordTypeId == TaskSurveyRecordTypeId && mapTaskBH.get(svy.Task_Identifier__c) != null){
                    svy.Follow_Up_Age_BH__c  = BusinessHours.diff(mapTaskBH.get(svy.Task_Identifier__c), svy.Created_Date_Time__c , System.now()) / 3600000.0;
                }
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Survey__c', 'SurveyFieldPopulator.populateFollowUpAgeInBusinessHours', new list<Exception>{ex});  
        } 
        
    }
    //SC-1041 : Updating Survey created by cisco
    public static void populateTaskSurvey(List<Survey__c> lstTaskSurvey,List<String> lstTaskIds){
        try{ 
            Id VoiceCallTaskRecordTypeId = StaticFactory.getRecordTypeIdByName('Task', 'Voice Call');
            Id TaskSurveyRecordTypeId = StaticFactory.getRecordTypeIdByName('Survey__c', 'Task Survey');
            // Getting the map of task identified by Task Identifier field on Survey
            Map<String,Task> mapVoiceCallTask = new Map<String,Task>();  
            for(Task ts : [select Id,Subject,CallObject,Brand_CM__c,OwnerId,ciscocjs__ANI__c,Team_Name__c,Country__c from Task where CallObject in: lstTaskIds and RecordTypeId =: VoiceCallTaskRecordTypeId]){
                mapVoiceCallTask.put(ts.CallObject,ts);
            }
            
            List<Id> lstTaskOwnerIds = new List<Id>(); 
            if(mapVoiceCallTask.size()>0){
                for(Task ts : mapVoiceCallTask.values()){
                    lstTaskOwnerIds.add(ts.OwnerId);
                }    
            }
            
            // Getting the map of survey owner
            Map<Id,User> mapTaskOwner = new Map<Id,User>([select Id,CM_Visibility__c from User where Id in: lstTaskOwnerIds]);       
            
            //Updating all the required fields on survey
            for(Survey__c svy : lstTaskSurvey){
                svy.RecordTypeId = TaskSurveyRecordTypeId;
                svy.survey_Channel__c= 'Telephone';
                if(mapVoiceCallTask.get(svy.Task_Identifier__c) != null){
                    svy.Liner_Brand__c = mapVoiceCallTask.get(svy.Task_Identifier__c).Brand_CM__c;               
                    svy.OwnerId = mapVoiceCallTask.get(svy.Task_Identifier__c).OwnerId; 
                    svy.Customer_Number__c = mapVoiceCallTask.get(svy.Task_Identifier__c).ciscocjs__ANI__c;
                    svy.Team_Name__c = mapVoiceCallTask.get(svy.Task_Identifier__c).Team_Name__c;
                    svy.Country__c = mapVoiceCallTask.get(svy.Task_Identifier__c).Country__c;
                    svy.Task__c = '<a href=' +System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+mapVoiceCallTask.get(svy.Task_Identifier__c).Id+' target= _self'+' >'+ mapVoiceCallTask.get(svy.Task_Identifier__c).subject+'</a>';
                }
                // Updating Survey Visibility based on Survey owner CM Visibility
                if(mapTaskOwner.get(svy.OwnerId) != null){
                    if(mapTaskOwner.get(svy.OwnerId).CM_Visibility__c == 'Single Carrier'){
                        svy.Survey_Visibility__c = 'All Users';                   
                    }
                    else if(mapTaskOwner.get(svy.OwnerId).CM_Visibility__c == 'Multi-Carrier'){
                        svy.Survey_Visibility__c = 'Multi-Carrier'; 
                    } 
                }
                if(svy.Ease_to_Resolve_Issue__c == 3 ){
                    svy.Response_Actions__c = 'None';
                    svy.Followed_Up_Date__c = null;
                    svy.Follow_Up_Age_BH__c = null;
                } 
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Survey__c', 'SurveyFieldPopulator.populateTaskSurvey', new list<Exception>{ex});  
        } 
    }
    
    /** 
    * @description | create feed item
    * @param surveyList accepts list of Survey__c
    */
    public static void createFeedItem(List<Survey__c> surveyList){
        List<Feed_Item_Event__e> feedItemEvtList = new List<Feed_Item_Event__e>();
        for(Survey__c sur : surveyList){
            Feed_Item_Event__e fItemEvt = new Feed_Item_Event__e();
            fItemEvt.Record_Id__c = sur.Id;
            fItemEvt.Parent_Id__c = sur.Case__c;
            fItemEvt.Object_Name__c = 'Survey';
            feedItemEvtList.add(fItemEvt);
        }
        
        if(!feedItemEvtList.isEmpty()){
            EventBus.publish(feedItemEvtList);
        }
    }
}