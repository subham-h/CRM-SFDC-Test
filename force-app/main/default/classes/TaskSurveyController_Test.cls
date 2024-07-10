/*
* Author   : Sreya@Maersk
* Purpose  : Test class for TaskSurveyController
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0     SC-1041      16/04/2021  Sreya@Maersk            Test Class for TaskSurveyController
*/

@isTest
public class TaskSurveyController_Test {
    //SC-1041 : test method to cover SurveyFieldPopulator.populateTaskSurvey
    static testMethod void testVoiceTask(){
        string Country = BDAGeographyData_Test.countryUS.Id;
        Id voiceTaskRTId = StaticFactory.getRecordTypeIdByName('Task', 'Voice Call');
        Task tsk = new Task();
        tsk.Subject = 'Call';
        tsk.Status = 'Not Started';
        tsk.Priority = 'Normal';
        tsk.ActivityDate = date.today();
        tsk.type = 'Call';
        tsk.WhatId = null;
        tsk.WhoId = null;
        tsk.CallObject = '45ed4e6d06a94c8cacc9a9b6b5e68dd9';
        tsk.RecordTypeId = voiceTaskRTId;
        tsk.ciscocjs__ANI__c = '123456789';
        tsk.Country_Code__c = 'US';
        
        TriggerExecutionController.skipAllTriggers(true);
        insert tsk;
        TriggerExecutionController.skipAllTriggers(false);
        
        Task ts =[select id from Task limit 1];
        
        Survey__c sv = new Survey__c(); 
        sv.Task_Identifier__c = '45ed4e6d06a94c8cacc9a9b6b5e68dd9';
        sv.Ease_to_Resolve_Issue__c = 3;
        
        TriggerExecutionController.skipAllTriggers(true);
        insert sv; 
        TriggerExecutionController.skipAllTriggers(false);
        
        Object sv1 = TaskSurveyController.GetSurveyDetails(ts.Id);
        
    }
}