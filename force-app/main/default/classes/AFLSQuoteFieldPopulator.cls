/*
 * Created By   : Ramadevi@UST
 * Purpose      : Utility class to hold simple and reusable functionalities for auto populating AFLS Quote fields
 *              
 * Revision Ref Number    Date            Owner                   Description
 * -------- ----------   -----------  -------------------   --------------------------------------------------------
 * 1.0      #RQ-005525  21-Jul-2017     Ramadevi.palanisamy@ust-global.com   Formatted the trigger and introduced CBO architecture.
 *
 */

public class AFLSQuoteFieldPopulator { 

    public static void setQuoteAccOppOwner(List<Qt_Quote__c> quoteToBeProcessed,Map<String, Opportunity> oppDetails,Map<String, Account> accDetails,Map<String, User> userDetails ){
        
        list<Qt_Quote__c> quoteList = new list<Qt_Quote__c>();
        Id currentUser = UserInfo.getUserId(); 

        for (Qt_Quote__c quote : quoteToBeProcessed) {
             
             // Populate the Account look up on AFLS Quote
             if (quote.Qt_Customer_Code__c != null && accDetails.containsKey(quote.Qt_Customer_Code__c)) {
                    quote.Account__c = accDetails.get(quote.Qt_Customer_Code__c).Id;
            }
            // Populate the Opportunity look up on AFLS Quote
             if(quote.Qt_External_Id__c != null && oppDetails.ContainsKey(quote.Qt_External_Id__c)) {
                    quote.Opportunity__c = oppDetails.get(quote.Qt_External_Id__c).Id;
            }
             
            // If opportunity exists and opportunity owner is active
            if(quote.Qt_External_Id__c != null && oppDetails.get(quote.Qt_External_Id__c) != null && oppDetails.get(quote.Qt_External_Id__c).Owner.IsActive == true) {                        
                quote.OwnerId = oppDetails.get(quote.Qt_External_Id__c).OwnerId;
            } else if (quote.Qt_Created_by__c != null && userDetails.get(quote.Qt_Created_by__c) != null && userDetails.get(quote.Qt_Created_by__c).IsActive == true){ // If above condition fails and AFLS Quote created by user is active
                quote.OwnerId = userDetails.get(quote.Qt_Created_by__c).Id;
            } 
			else {
                quote.OwnerId = currentUser; // If the corresponding Account Liner brand owner is inactive, then Interface user will be the owner of AFLS Quote
            }
                                
                                
        }
    }
}