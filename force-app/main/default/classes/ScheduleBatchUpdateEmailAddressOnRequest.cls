/*
* Version  Date             Owner                                    RQ#           Description
***********************************************************************************************************************************************
* 1.0      03/11/2016   ramadevi.palaniswamy@ust-global.com           #RQ-005369       Batch apex job to update the All Email address field if there is any change in Request Contact object.

*/

global class ScheduleBatchUpdateEmailAddressOnRequest  implements Schedulable {
        
    global void execute( SchedulableContext sc ) {

        BatchUpdateEmailAddressOnRequest b = new BatchUpdateEmailAddressOnRequest();
        Database.ExecuteBatch( b);

    }

}