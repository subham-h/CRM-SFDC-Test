/*
 * Author   : Ranjini@UST
 * Purpose  : Test class for Survey trigger.
 * 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0     RQ-008231    18/04/2018  Ranjini@Ust             Follow up Age in Business Hours
 * 2.0     SC-1041      19/02/2021  Sreya@Maersk            task Survey implemenattion
*/

@isTest
public class SurveyTrigger_Test {
    
    private static List<Survey__c> getSurveyList() {
        return [Select Id, Name, Case__c,  
            //Case_Owner_Role__c, 
            Case_Security_Code__c, 
            Created_Date_Time__c, 
            Ease_to_Resolve_Issue__c, 
            Ease_to_Resolve_Issue_Description__c, 
            Followed_Up_Date__c, 
            Follow_Up_Age_Hours__c, 
            Follow_Up_Age_BH__c, 
            Liner_Brand__c, 
            Case_Owner_Email__c, 
            Response_Actions__c FROM Survey__c];
    }
    
    static testMethod void testSurveyTrigger() {
        
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.createExternalCasesAndSurveys();
        
        List<Survey__c> lstSurvey = getSurveyList();
        for (Survey__c s: lstSurvey) {
            Test.setCreatedDate(s.Id, DateTime.newInstance(2017, 01, 01));         
            s.Response_Actions__c = 'Followed Up';
            System.debug('BEFORE:' + s);
        }
               
        System.Test.startTest();
        update lstSurvey;
        System.Test.stopTest();
        
        List<Survey__c> lstResultSurvey = getSurveyList();
        
        for (Survey__c s: lstResultSurvey) {
            System.debug('AFTER:' + s);
            System.assert(s.Follow_Up_Age_BH__c > 0);
        }       
    } 
    //SC-1041 : test method to cover SurveyFieldPopulator.populateTaskSurvey
    static testMethod void testTaskSurvey(){
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
        TriggerExecutionController.skipAllTriggers(true);
        insert tsk;
        TriggerExecutionController.skipAllTriggers(false);
        
        Task ts =[select id from Task limit 1];
        
        Survey__c sv = new Survey__c(); 
        sv.Task_Identifier__c = '45ed4e6d06a94c8cacc9a9b6b5e68dd9';
        sv.Ease_to_Resolve_Issue__c = 3;
        
        System.Test.startTest();
        insert sv; 
        System.Test.stopTest();
    }
}