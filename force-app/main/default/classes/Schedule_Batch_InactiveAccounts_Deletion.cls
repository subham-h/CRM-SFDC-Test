/*
* version       Date                Owner                                       Description
*******************************************************************************************************
* V1.0          09/Aug/2018       John.Christopher@ust-global.com               #RQ-008412 -Code Created
*
*/

global class Schedule_Batch_InactiveAccounts_Deletion implements Schedulable{

  
  global void execute(SchedulableContext sc) {
      
    Batch_InactiveAccounts_Deletion b = new Batch_InactiveAccounts_Deletion();
    ID batchprocessid = Database.executeBatch(b,200);
  }

}