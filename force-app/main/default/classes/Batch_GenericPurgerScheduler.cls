/*
* Author   : Nisha
* Purpose  : Scheduler for Batch class to clean up any object records.
*         
* Revision Ref Number  Date        Owner               Description
* -------- ----------  ----------- ----------          -----------
* 1.0      RQ-003324   08-Jun-2016 Nisha.Arjunan@UST   Created.
* 2.0      SC-146      03-Apr-2020 Avinash@UST         Call Task Deletion - Rolling 3 Year Window
*/

global class Batch_GenericPurgerScheduler implements Schedulable{
    
    global final String strObjectName;
    global final Integer jobNumber;
    global boolean delFiles = false;
    global boolean delHerokuEmails = false;
    
    // Constructor to assign the clean up object
    // #SC-146 - Added JobNumber parameter to ctor
    public Batch_GenericPurgerScheduler(String strObjectName,Integer jobNumber){
        this.strObjectName = strObjectName;   
        this.jobNumber = jobNumber;        
    }
    
    public Batch_GenericPurgerScheduler(String strObjectName,Integer jobNumber,boolean delFiles){
        this.strObjectName = strObjectName;   
        this.jobNumber = jobNumber;
        this.delFiles = delFiles;        
    }
    public Batch_GenericPurgerScheduler(String strObjectName,Integer jobNumber,boolean delFiles,boolean delHerokuEmails){
        this.strObjectName = strObjectName;   
        this.jobNumber = jobNumber;
        this.delFiles = delFiles;
        this.delHerokuEmails = delHerokuEmails;        
    }
    
    // Method to execute batch class
    global void execute(SchedulableContext sc) {
        if(delFiles || delHerokuEmails){
            Batch_GenericPurger batchPurger = new Batch_GenericPurger(strObjectName,jobNumber,delFiles,delHerokuEmails);
            Id batchId = Database.executeBatch(batchPurger);
        }else{
            Batch_GenericPurger batchPurger = new Batch_GenericPurger(strObjectName,jobNumber);
            Id batchId = Database.executeBatch(batchPurger);
        }
    }
    
    public class ObjectNameNotSpecifiedException extends Exception {}
    
}