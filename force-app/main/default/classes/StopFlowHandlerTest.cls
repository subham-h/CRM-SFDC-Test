@isTest
public class StopFlowHandlerTest {
     
    @isTest
    public static void testSkipFlow(){
        Flow_execution_controller_setting__c flowSetting = new Flow_execution_controller_setting__c();
        flowSetting.Skip_flow_and_trigger_execution__c = 'Trigger and Flow';
        flowSetting.Skip_flow_execution_only__c = 'Flow only';
        flowSetting.Skip_all_users_indicator__c = '*all*';
        insert flowSetting;
        
        List<String> objectNameList = new List<String>();
        objectNameList.add('Case');
        TriggerExecutionController.skipCaseTrigger(true);
        StopFlowHandler.stopTrigger(objectNameList);
        TriggerExecutionController.skipCaseTrigger(false);
        StopFlowHandler.stopTrigger(objectNameList);
    }

}