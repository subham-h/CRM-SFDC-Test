global class StopFlowHandler {
    
    @InvocableMethod(label='stopsObjectFlow' description='Stop the sObject flow for this transaction')
    public static List<Results> stopTrigger(List<String> objectNameList){
        List<Results> responseWrapper = new List<Results> ();
        
        List<Trigger_and_Flow_Execution_Controller__mdt> trigFlowMetadataList = new List<Trigger_and_Flow_Execution_Controller__mdt>();
        
        trigFlowMetadataList = [Select MasterLabel, Bypass_Capability__c, User_Ids__c From Trigger_and_Flow_Execution_Controller__mdt Where MasterLabel =: objectNameList[0] AND User_Ids__c != null LIMIT 1];
        Flow_execution_controller_setting__c flowSetting = Flow_execution_controller_setting__c.getInstance();
        for(String req : objectNameList){
            Results response = new Results();
            if(req == 'Case'){
                if(TriggerExecutionController.skipCaseFlow()){
                    response.stopFlow = TriggerExecutionController.skipCaseFlow();
                    responseWrapper.add(response);
                }
                else if(!Test.isRunningTest() && !trigFlowMetadataList.isEmpty() && !String.isEmpty(trigFlowMetadataList[0].Bypass_Capability__c) && (trigFlowMetadataList[0].Bypass_Capability__c.contains(flowSetting.Skip_flow_execution_only__c) || trigFlowMetadataList[0].Bypass_Capability__c.contains(flowSetting.Skip_flow_and_trigger_execution__c)) &&
                        !String.isEmpty(trigFlowMetadataList[0].User_Ids__c) && flowSetting != null && (trigFlowMetadataList[0].User_Ids__c.contains(flowSetting.Skip_all_users_indicator__c) || trigFlowMetadataList[0].User_Ids__c.contains(String.valueOf(UserInfo.getUserId()).left(15)))){
                            response.stopFlow = true;
                            responseWrapper.add(response);
                        }
                else{
                    response.stopFlow = false;
                    responseWrapper.add(response);
                }
            }
        }
        return responseWrapper;
    }
    
    global class Results {
        @InvocableVariable(label = 'Stop Flow' description = '' required = true)
        public Boolean stopFlow;
    }
    
}