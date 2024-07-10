/*
 * Scheduler class for Case FCR. This class will schedule - BatchFCRCaseDetails.
 * BatchFCRCaseDetails will inturn call BatchFCRTaskDetails
*
Version    Date            Owner                                       RQ#                 Description
******************************************************************************************************************  
*1.0       30/06/2015   Ranjini.Janrdhanan@ust-global.com             #RQ-001479          Code created as part of #RQ-001479
*/

global class ScheduleBatchFCR implements Schedulable{
    
    global void execute(SchedulableContext sc) {

          BatchFCRCaseDetails b = new BatchFCRCaseDetails();    
          database.executebatch(b,200);

    }

}