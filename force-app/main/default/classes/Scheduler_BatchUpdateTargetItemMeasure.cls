/*   
 * Revision Ref Number  Date            Owner                                  Description
 * -------- ----------  -----------     -------------------                    -----------
 * 1.0      SFSE-11477  08-Nov-2023      Vinay      							Code created
 * 
*/
global class Scheduler_BatchUpdateTargetItemMeasure implements Schedulable{

    global void execute( SchedulableContext SC ) {		      
        BatchUpdateTargetItemMeasure b = new BatchUpdateTargetItemMeasure();
        Database.executeBatch(b, Target_Setting_Batch_Query__mdt.getInstance('Update_Credit_Eligibility')?.Batch_Size__c?.intValue());
    }
}