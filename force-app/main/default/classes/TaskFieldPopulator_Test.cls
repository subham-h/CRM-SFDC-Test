/*
 * Author   : Sreya@Maersk
 * Purpose  : Test class for TaskFieldPopulator
 * 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0     SC-1041      16/04/2021  Sreya@Maersk            Test Class for TaskFieldPopulator
 * 2.0     SC-5350		16/06/2021	Ayush.k@maersk			Add Contact to Task
 * 3.0     SC-6304		17/11/2022	Shahanawaz@maersk		Update Additional Owners on Case & create case team member
*/

@isTest
public class TaskFieldPopulator_Test {

    @testSetup static void setup() {
        Group gp = [Select id From Group Where Type = 'Queue' AND DeveloperName LIKE 'Case%' Order By DeveloperName DESC LIMIT 1];
        QueueSobject queObj = new QueueSobject();
        queObj.QueueId = gp.Id;
        queObj.SobjectType = 'Task';
        insert queObj;
    }
    
    static testMethod void testVoiceTask(){
        //SC-5350:  add contact to task
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0]; 
      
        
		//SC-1041 : test method to cover SurveyFieldPopulator.populateTaskSurvey
        Id voiceTaskRTId = StaticFactory.getRecordTypeIdByName('Task', 'Voice Call');
        Task tsk = new Task();
        tsk.Subject = 'Call';
        tsk.Status = 'Not Started';
        tsk.Priority = 'Normal';
        tsk.ActivityDate = date.today();
        tsk.type = 'Call';
        tsk.WhatId = null;
        tsk.WhoId = conInstance.Id;
        tsk.Country_Code__c = 'US';
        tsk.CallObject = '45ed4e6d06a94c8cacc9a9b6b5e68dd9';
        tsk.RecordTypeId = voiceTaskRTId;
        tsk.ciscocjs__ANI__c = '123456789';
        tsk.Direction__c = 'Outbound';
        tsk.OwnerId = userinfo.getUserId();
        System.Test.startTest();
         insert tsk;
         TriggerExecutionController.skipAllTriggers(true);
          tsk.OwnerId = Label.AllCarrierUserQueueId;
         update tsk;
         TriggerExecutionController.skipAllTriggers(false);
        System.Test.stopTest();
          
         
        
    }
    
    static testMethod void testAllCMVisibilityOwnerChange(){ 
        Map<String, String> taskMap = new Map<String, String>();
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
        tsk.Direction__c = 'Outbound';
        tsk.OwnerId = userinfo.getUserId();
        TriggerExecutionController.skipAllTriggers(true);
        UserDataGeneratorHelper_Test.initializeCustomerServiceUser();
        System.runAs(UserDataGeneratorHelper_Test.MSLCustomerServiceUser){
            insert tsk;
        }  
        TriggerExecutionController.skipAllTriggers(false);        
        
        Task ts =[select id,CallObject,CreatedById from Task limit 1];
        taskMap.put(ts.CallObject, ts.CreatedById);
        Survey__c sv = new Survey__c(); 
        sv.Task_Identifier__c = '45ed4e6d06a94c8cacc9a9b6b5e68dd9';
        sv.Ease_to_Resolve_Issue__c = 3;
        
        System.Test.startTest();
        insert sv; 
        TriggerExecutionController.skipAllTriggers(true);
        tsk.OwnerId = Label.AllCarrierUserQueueId;
        update tsk;
        TriggerExecutionController.skipAllTriggers(false);
        tsk.OwnerId = UserInfo.getUserId();
        update tsk;
        TaskFieldPopulator.updateRelatedSurveys(taskMap);
        System.Test.stopTest();
    }
    
        public static TestMethod void testCollaborationCases(){
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCasesII();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {
            caseIterator.Direction__c = 'Export';
            caseIterator.status = 'Triaged';
            caseIterator.Type = 'Prior To Booking'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Cargo Restrictions/Support Enquiry';
            
        }
        insert lstCases[0]; 
        
        Id caseCollaborationRecTypeId = StaticFactory.getRecordTypeIdByName('Task', 'Case Collaboration');
        Task tsk = new Task();
        tsk.Subject = 'Case Collaboration';
        tsk.Status = 'Not Started';
        tsk.Priority = 'Normal';
        tsk.ActivityDate = date.today();
        tsk.WhatId = lstCases[0].Id;
        tsk.RecordTypeId = caseCollaborationRecTypeId;     
        tsk.OwnerId = [Select Id, QueueId From QueueSobject Where SobjectType = 'Task' LIMIT 1].QueueId;      
        insert tsk;
        
        Test.startTest();
        tsk.OwnerId = userinfo.getUserId();
        update tsk;
        Test.stopTest();
    }
}