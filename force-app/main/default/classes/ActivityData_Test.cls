/*
 * Author   : Nisha
 * Purpose  : Utility test class for creating Activity related data. 
 *
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-004102   20/07/2016 Nisha.arjunan@UST         Created.
 * 
 */

@isTest
public class ActivityData_Test {
    
    public static boolean bCreate = true;
    public static integer iNumberOfTask = 5;
    public static list<Task> lstTasks;
    public static integer iNumberOfEvents = 5;
    public static list<Event> lstEvents;
    
    public static testMethod void createTasks() {
        lstTasks = new List<Task>();            
        for( Integer i=0; i < iNumberOfTask; i++ ){
            Task tsk = new Task();
            tsk.Subject = 'Test' + i;
            tsk.Status = 'Not Started';
            tsk.Priority = 'Normal';
            tsk.ActivityDate = date.today();
            tsk.Notify_Assignee__c = true;
            lstTasks.add( tsk );
        }
        
        //System.runAs(UserDataGeneratorHelper_Test.integrationUser){ 
        
        if(bCreate) {
            insert lstTasks;
        }
    }
    
    public static testMethod void createEvents() { 
        lstEvents = new list<Event>();            
        for( Integer i=0; i < iNumberOfEvents; i++ ){
            Event evnt = new Event();
            evnt.Subject = 'Test' + i;
            evnt.StartDateTime = System.today();
            evnt.EndDateTime = System.today()+1;
            lstEvents.add(evnt);
        }
        
        //System.runAs(UserDataGeneratorHelper_Test.integrationUser){ 
        
        if(bCreate) {
            insert lstEvents;
        }
    }
   
}