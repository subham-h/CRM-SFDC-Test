/*
 * Revision Ref Number    Date          Owner                Description
 * -------- ----------   -----------  -------------------   --------------------------------------------------------
 * 1.0      SFSE-11402   04-04-2024     Vinay                Capture This year actuals
 */
 
public inherited sharing class TargetLoadDataTriggerHelper {
	
	//When Sales Target Data Load's status changed to completed and its Data Load Type is Actuals invoke the batch to purge ALL actuals
	//that are present in the org. 
    public static void invokeBatchForActuals(List<Target_Data_Load__c> newList, Map<Id,Target_Data_Load__c> oldMap) {
        for(Target_Data_Load__c dataLoad : newList){
            if(dataLoad.Data_Load_Type__c==TargetSettingConstants.CY_ACTUALS && dataLoad.Status__c != oldMap.get(dataLoad.Id).Status__c && dataLoad.Status__c ==TargetSettingConstants.DATA_LOAD_STATUS_COMPLETED){
                Database.executeBatch(new BatchToPurgeCYActuals(dataLoad.Sales_Targets_Year__c,dataLoad.Correlation_Id__c,TargetSettingConstants.QUERY_ID_CYACTUALS), Integer.valueOf(Target_Setting_Batch_Query__mdt.getInstance('Purge_Actuals').Batch_Size__c));             	              
    }}}
}