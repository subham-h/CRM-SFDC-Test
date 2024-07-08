/*
Description  : Resolve Call Classification Issue (Task Visibility) on Transferred Calls

* version    Ref Number      Date                Owner                                       Description
*******************************************************************************************************************
* V1.0       SC-2555         01/06/2021          richa.singh@maersk.com                      Return Single/Multi carrier queue Id for Task visibility
*-------------------------------------------------------------------------------------------------------------------
*/
global class TaskVisibility {
    webService static String getQueue(String agentId) {
        String queueId= '';
        if(agentId != Null){
            queueId= Label.AllCarrierUserQueueId;           
        }
        return queueId;
    }
}