/****
 * Story Number      Date        Owner                        Description
***********************************************************************************************
*  SFSE-8141        22/08/2022     Meghana Gupta            Code Created
* 
* ***/

global class Batch_Sip_LoadEmpHRData_Scheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      Batch_Sip_LoadEmpHRData b = new Batch_Sip_LoadEmpHRData(); 
      database.executebatch(b, 100);
   }
}