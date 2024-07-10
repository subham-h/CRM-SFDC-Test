/*
* Author   : Ragu
* Purpose  : Utility class to hold simple and reusable functionalities for auto populating Financial_Details__c fields. 
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------   -----------  -------------------   -----------
* 1.0    #RQ-002683  24-Mar-2016  Ragu@UST         	Update back the Recalculate_XRate__c.
* 2.0    #RQ-005636  25-Sep-2017  Nisha@UST        	Update references of GlobalErrorLogger
* 3.0      SC-9293     22-12-2023 Shahanawaz@maersk Create feeditem on parent Case
*/

public class FinancialDetailsFieldPopulator {
    
    // Generic Financial_Details__c field population during OnBeforeInsert and OnBeforeUpdate
    public static void populateFieldsOnBeforeInsertUpdate(list<Financial_Details__c> lstFinancialDetails, map<Id, Financial_Details__c> mapOldFinancialDetails, FinancialDetailsTriggerHandler finDetailsTriggerHandler) {
        Map<Id, Financial_Details__c> mapFinDetToBeUpdated = new Map<Id, Financial_Details__c>();
        List<Financial_Details__c> lstFinDetToBeUpdated = new List<Financial_Details__c>();
        
        try{
            for(Financial_Details__c newFinDetail : lstFinancialDetails) {
                Financial_Details__c oldFinDetail;
                if(mapOldFinancialDetails != null && !mapOldFinancialDetails.isEmpty()) {
                    oldFinDetail = mapOldFinancialDetails.get(newFinDetail.Id);
                }
                
                if(finDetailsTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) {
                    // v1.0 - Start
                    // Regardless of insert or update set it back to false. 
                    // By this time FinancialDetailsRecordSelector already collected all the Financial_Details__c records for processing.
                    if(newFinDetail.Recalculate_XRate__c == true) {
                        newFinDetail.Recalculate_XRate__c = false;
                    }
                    // v1.0 - End
                    if( finDetailsTriggerHandler.finDetailsRecordSelector.mapUSDLocalCurFinDet.containsKey(newFinDetail.Id)){
                        newFinDetail.USD_Amount__c = newFinDetail.Local_Amount__c;
                    }
                }
                
            }
        }
        Catch(Exception e){
            ErrorLogger.writeErrors( 'SFDC', 'Financial_Details__c', 'FinancialDetailsFieldPopulator.populateFieldsOnBeforeInsertUpdate', new list<Exception>{e}); // #RQ-005636 
        }
    }
    
    /** 
    * @description | create feed item
    * @param finDetailsList accepts list of Financial_Details__c
    */
    public static void createFeedItem(List<Financial_Details__c> finDetailsList){
        List<FeedItemUtility.FeedItemWrapper> feedItemWrapList = new List<FeedItemUtility.FeedItemWrapper>();
        for(Financial_Details__c finDet : finDetailsList){
            FeedItemUtility.FeedItemWrapper feedWrap = new FeedItemUtility.FeedItemWrapper(finDet.Id, finDet.Claim__c, 'Financial Details');
            feedItemWrapList.add(feedWrap);
        }
        
        if(!feedItemWrapList.isEmpty()){
            FeedItemUtility.createFeedItem(feedItemWrapList);
        }
    }
}