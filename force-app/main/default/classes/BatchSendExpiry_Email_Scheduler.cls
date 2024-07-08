/****
 * Story Number      Date        Owner                        Description
***********************************************************************************************
*  SFSE-12961        16/10/2023     Bharti rana            Code Created
* 
* ***/

global class BatchSendExpiry_Email_Scheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      BatchSendEmailForOfferInfoExpired b = new BatchSendEmailForOfferInfoExpired(); 
      database.executebatch(b, 10);
   }
}