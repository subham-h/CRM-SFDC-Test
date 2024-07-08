/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      RQ-007189   21-Feb-2019 Meghana.Gupta@UST       Code created
* 2.0      SC-9293     22-12-2023  Shahanawaz@maersk       Create feeditem on parent Case
*/

public class ApprovalRequestUtilities {
    
    // Method to handle currency conversion based on input Amount and Currency Code
    public static void calculateStandardCurrency ( List<Approval_Request__c> lstApprovalRequests, map<Id, Approval_Request__c> oldMap) {
        
        Set<String> setCurrCodes = new Set<String>();
        
        for(Approval_Request__c recAppReq : lstApprovalRequests) {
            
            setCurrCodes.add(recAppReq.Requested_Amount_Currency__c);
            setCurrCodes.add(recAppReq.Approved_Amount_Currency__c); 
        }
        
        // Fetch the exchange rate which matches the currency ISO code selected from the picklist in Approval Request      
        List<Exchange_Rate__c> lstExRate = [SELECT ConversionRate__c, CurrencyISOCode__c FROM Exchange_Rate__c WHERE CurrencyISOCode__c in :setCurrCodes];
        
        // Creating a map for exchange rate records with key value as Currency ISO code fetched from the approval records
        Map<String, Exchange_Rate__c> mapCurrCodeToExchangeRate = new Map<String, Exchange_Rate__c>();
        for(Exchange_Rate__c recExRate : lstExRate) {
            mapCurrCodeToExchangeRate.put(recExRate.CurrencyISOCode__c, recExRate);
        }
        
        // Updating the Converted Amount field
        for (Approval_Request__c recAppReq : lstApprovalRequests) {
            
            // if record is updated, get old record 
            Approval_Request__c oldAppReq;  
            if (oldMap != null){
                oldAppReq = (Approval_Request__c) oldMap.get(recAppReq.Id);
            }
            
            if (recAppReq.Requested_Amount__c != null  && (oldMap == null || recAppReq.Requested_Amount__c != oldAppReq.Requested_Amount__c || recAppReq.Requested_Amount_Currency__c != oldAppReq.Requested_Amount_Currency__c)){
                
                if(mapCurrCodeToExchangeRate.containsKey(recAppReq.Requested_Amount_Currency__c)) {
                    recAppReq.Converted_Requested_Amount_USD__c = recAppReq.Requested_Amount__c * mapCurrCodeToExchangeRate.get(recAppReq.Requested_Amount_Currency__c).ConversionRate__c;
                }        
            }
            // Convert Approved amount to USD.
            if (recAppReq.Approved_Amount__c != null  && (oldMap == null || recAppReq.Approved_Amount__c != oldAppReq.Approved_Amount__c || recAppReq.Approved_Amount_Currency__c != oldAppReq.Approved_Amount_Currency__c)){
                
                if(mapCurrCodeToExchangeRate.containsKey(recAppReq.Approved_Amount_Currency__c)) {
                    recAppReq.Converted_Approved_Amount_USD__c = recAppReq.Approved_Amount__c * mapCurrCodeToExchangeRate.get(recAppReq.Approved_Amount_Currency__c).ConversionRate__c;
                }        
            }           
        }
    }
    
    /** 
    * @description | create feed item
    * @param appReqList accepts list of Approval_Request__c
    */
    public static void createFeedItem(List<Approval_Request__c> appReqList){
        List<FeedItemUtility.FeedItemWrapper> feedItemWrapList = new List<FeedItemUtility.FeedItemWrapper>();
        for(Approval_Request__c app : appReqList){
            FeedItemUtility.FeedItemWrapper feedWrap = new FeedItemUtility.FeedItemWrapper(app.Id, app.Case__c, 'Approval Request');
            feedItemWrapList.add(feedWrap);
        }
        
        if(!feedItemWrapList.isEmpty()){
            FeedItemUtility.createFeedItem(feedItemWrapList);
        }
    }
    
}