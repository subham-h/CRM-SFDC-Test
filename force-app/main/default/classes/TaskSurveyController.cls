/*
* Author   : Sreya V
* Purpose  : TaskSurveyComponent Controller
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-1041	    12/04/2021   Sreya@Maersk          Return the Matching Survey for the Task
*/
public class TaskSurveyController {
    @AuraEnabled
    public static Object GetSurveyDetails(string recordId){
        List<Survey__c> surRecList;
        try{
            List<Task> taskRecList = new List<Task>([select CallObject from Task where Id =: recordId limit 1]);
            
            if(!taskRecList.isEmpty() && String.isNotBlank(taskRecList[0].CallObject)){
                surRecList = new List<Survey__c>([select Id,Name,Ease_to_Resolve_Issue__c,Response_Actions__c,Followed_Up_Date__c from Survey__c where Task_Identifier__c =: taskRecList[0].CallObject limit 1]);
            }           
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Survey__c', 'TaskSurveyController.GetSurveyDetails', new list<Exception>{ex});  
        }
        return (surRecList != null && surRecList.isEmpty()) ? surRecList[0] : null;
    }
}