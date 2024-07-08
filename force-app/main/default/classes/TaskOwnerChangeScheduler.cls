/*
Description  : Resolve Call Classification Issue (Task Visibility) on Transferred Calls

* version    Ref Number      Date                Owner                                       Description
*******************************************************************************************************************
* V1.0       SC-2555         04/05/2022          Richa@Maersk                      Update Task owner as Createdby.name for edge cases
* V2.0       SC-5948         07/09/2022          Harmeet@Maersk                    Update related Survey owner of Task as Createdby.name for edge cases
*-------------------------------------------------------------------------------------------------------------------
*/
public class TaskOwnerChangeScheduler implements Schedulable{
    public void execute(SchedulableContext sc){
        Id VoiceCallTaskRecordTypeId = Task.sObjectType.getDescribe().getRecordTypeInfosByName().get('Voice Call').getRecordTypeId();
		Map<String, String> mapTaskOwner = new Map<String, String>();
		list<Survey__c> surveyList = new list<Survey__c>();
        try{
		    list<Task> lstTasks = new list<Task>([SELECT Id,CreatedById,OwnerId,CallObject from Task where RecordtypeId =: VoiceCallTaskRecordTypeId and OwnerId =: Label.AllCarrierUserQueueId]);
    
            for(Task objTask : lstTasks){
                objTask.OwnerId = objTask.CreatedById;
                mapTaskOwner.put(objTask.CallObject, objTask.CreatedById);
            } 
             
            if(!mapTaskOwner.isEmpty()){
              surveyList = [SELECT Id,OwnerId,Task_Identifier__c from Survey__c where Task_Identifier__c IN :mapTaskOwner.keySet()];
              for(Survey__c svy : surveyList){
			     if(svy.ownerId != mapTaskOwner.get(svy.Task_Identifier__c)){
			       svy.OwnerId = mapTaskOwner.get(svy.Task_Identifier__c); 
			     }
			  }
			} 
 
            if(lstTasks.size() > 0){
                List<Database.SaveResult> lstTaskUpdateResult = Database.update(lstTasks,false);   //update task
            } 
			if(surveylist.size() > 0){
			   Database.update(surveyList, false);   //update related Survey Records 
			}
        }catch(Exception ex){
            ErrorLogger.writeErrors('SFDC', 'Task', 'TaskOwnerChangeScheduler.execute', new list<Exception>{ex});
        }
    }
}