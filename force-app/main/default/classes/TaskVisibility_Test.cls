/*
Description  : Test Class for TaskVisibility

* version       Date                Owner                                       Description
*******************************************************************************************************************
* V1.0          02/06/2021          richa.singh@maersk.com                      Test TaskVisibility classs
* V2.0          04/05/2022          richa.singh@maersk.com                      Test TaskOwnerChangeScheduler classs
*-------------------------------------------------------------------------------------------------------------------
*/

@isTest
public class TaskVisibility_Test {   
    @isTest static void testTaskVisibility(){    
        User u = [SELECT Id,UserName,CM_Visibility__c FROM User WHERE CM_Visibility__c != Null limit 1];
        if(u.Id != Null){
        String userId = u.Id;        
        String queueId = TaskVisibility.getQueue(userId);
        System.assert(queueId != Null);
        }
    }
    
    @isTest static void testOwnerChange() {
        User usr = [SELECT Id,UserName,CM_Visibility__c FROM User WHERE CM_Visibility__c != Null limit 1];
        Survey__c sv = new Survey__c(); 
        sv.Task_Identifier__c = '45ed4e6d06a94c8cacc9a9b6b5e68dd9';
        sv.Ease_to_Resolve_Issue__c = 3; 
        System.Test.startTest();
         insert sv; 
        system.debug('PVA survey ownerId ' +sv.ownerId);
		sv.ownerId = usr.id;
		update sv;
        System.Test.stopTest();
        system.debug('PVA Updated survey ownerId ' +sv.ownerId);
        String Country = BDAGeographyData_Test.countryUS.Id;
        Id voiceTaskRTId = StaticFactory.getRecordTypeIdByName('Task', 'Voice Call');
        Task tsk = new Task();
        tsk.Subject = 'Call';
        tsk.Status = 'Not Started';
        tsk.Priority = 'Normal';
        tsk.ActivityDate = date.today();
        tsk.type = 'Call';
        tsk.WhatId = null;
        tsk.WhoId = null;
        tsk.OwnerId = Label.AllCarrierUserQueueId;
        tsk.CallObject = '45ed4e6d06a94c8cacc9a9b6b5e68dd9';
        tsk.RecordTypeId = voiceTaskRTId;
        tsk.ciscocjs__ANI__c = '123456789';
        tsk.Country_Code__c = 'US';
    
        insert tsk;  
        system.debug('PVA owner of Task' +tsk.ownerId);
  
        List<Task> lstTask = [SELECT Id,CreatedById, OwnerId from Task where Id =: tsk.Id];
        System.assertEquals(Label.AllCarrierUserQueueId,lstTask[0].OwnerId, 'Owner is group');
        
        TaskOwnerChangeScheduler sh = new TaskOwnerChangeScheduler();  
        String sch = '0 30 0 * * ?'; 
        System.schedule('Test TaskOwnerChangeScheduler', sch, sh);
         
    } 
}