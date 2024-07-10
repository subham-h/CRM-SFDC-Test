/*
* Author   : Nisha
* Purpose  : Email Utility class for Task Trigger
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-004102   08/07/2016 nisha.arjunan@UST        Created for implementing CBO (Centralized By Org) trigger architecture.
* 
*/  

public class TaskEmailUtility {
    
    public static void sendEmail(list<Task> lstNewTasks, TaskTriggerHandler tasTriggerHandler){
       	list<Messaging.SingleEmailMessage> mailList = new list<Messaging.SingleEmailMessage>(); 
        list<Task> updateTasksList = new list<Task>();
		
        for(Task tsk : lstNewTasks) {
			// #RQ-000187 Create mailing list only when Notify Owner email field is set to true
            if(tsk.Notify_Assignee__c == true) { 
                Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();   
                mail.setSenderDisplayName('donotreply@salesforce.com');                                
                mail.setReplyTo('donotreply@salesforce.com');  
                mail.setSaveAsActivity(false);
                
                // RQ-002059 - Test Coverage Improvement -> Do not set TargetId if trigger called from a test class 
                if(!Test.isRunningTest()) {
                    mail.setTargetObjectId(tsk.ownerid); // Set target of email to Task Owner 
				}
				
                // Commented below code as part of #RQ-000187
                //mail.setTemplateId(template.Id); // #RQ-000202 setting the email template id
                //mail.setWhatId(tsk.Id); // #RQ-000202 setting the task id
				
                mail.setSubject(tsk.Subject);
                mail.setHtmlBody(Label.Task_Email_Content+ '<br></br> <a href="'+ URL.getSalesforceBaseUrl().toExternalForm() + '/' + tsk.id + '"> Task Link </a> <br></br>'); 
                
                mailList.add(mail);
				
                updateTasksList.add( new Task(Id = tsk.id, Notify_Assignee__c = false)); // #RQ-000187 :Setting Notify_Owner_Email to false
            }        
        }
        
        if(!mailList.isEmpty()) {                  
            list<Messaging.SendEmailResult> sendResult = Messaging.sendEmail(mailList, false); // Send email to Task Owner                   
        }
		
		TriggerExecutionController.skipTaskTrigger(true);
        update updateTasksList;
		TriggerExecutionController.skipTaskTrigger(false);
    }
    
}