/*
Class Name : BatchSharingRule_ToAccountTeamMember   
Description: This is a Scheduler class that is scheduled to accomplish following:
            1. Run the Batch Apex Class on Specified time.
Created By    : Cognizant Technology Solutions
Created On   : 11/23/2012
Change Log
--------------------------------------------------------------------------
Sr# Description                                Updated By       Updated On
--------------------------------------------------------------------------  
*/

global class Scheduled_InactiveAccountDelete implements Schedulable 
{

    global void execute(SchedulableContext SC) 
    {
        Batch_Inactive_ClientAccount_Deletion controller= new Batch_Inactive_ClientAccount_Deletion(); 
        controller.query = 'SELECT id, SCV_Code__c from Account where SCV_Status__c = \'Inactive\' and IsConcern__c = \'FALSE\' and Is_Opportunity__c = 0 limit 100';
        ID batchprocessid = Database.executeBatch(controller,200);
    }
    
}