/*
* version       Date                Owner                                       Description
*******************************************************************************************************
* V1.0          09/Aug/2018       Abhinav.Ankit@maersk.com               #RQ-013222 -Code Created
*
*/

global class InactiveContact_Deletion_Schedule implements Schedulable{

  
  global void execute(SchedulableContext sc) {
      
    InActiveContact_Deletion_Batch b = new InActiveContact_Deletion_Batch();
    ID batchprocessid = Database.executeBatch(b,200);
  }

}