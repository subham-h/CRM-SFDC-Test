/*
Date			   Story			Developer 	Description
30-April-2024		SFSE-14047		Anjali		Code Created; Controller class to display 'Renewal Opportunities' related to an Account
*/
public with sharing class AccountOpportunityRenewalCntrl {
    
/*SFSE-14047
* @description Fetch the overdue/upcoming renewal opportunities for selected account and return them to the UI
* @param  Id of the Account
* @param  No. of records to be fetched
* @param  Starting index for the Opportunity query
* @param  Column field to sort
* @param  Sorting direction
* @return Returns the list of opportunities to be displayed 
*/
    @AuraEnabled(cacheable=true)
    public static List<AccountOpportunityWrapper> fetchAccOppData(Id accountId , Integer limitSize, Integer offset,String sortedBy, String sortDirection) {
        List<AccountOpportunityWrapper> dataWrapperList = new List<AccountOpportunityWrapper>();
        String orderByClause = '';
        if (String.isNotBlank(sortedBy)) {
            if(sortedBy=='ownerfname')
                sortedBy='Owner.Name';
            else if (sortedBy=='brand')
                sortedBy='Liner_Brand__c';
            orderByClause = ' ORDER BY ' +  sortedBy +' '+ sortDirection;
        }
        // Querying Opportunities related to the specified Account with related fields
        String query ='SELECT Id, Name, AccountId, Account_Name__c, StageName, isClosed,CloseDate, Close_Date_Status__c, Opportunity_Owner__c, OwnerID, Owner.Name, Liner_Brand__c ' +
                       'FROM Opportunity ' +
                       'WHERE (Renewal_Opportunitity__c=true OR Type=\'Renewal\') AND AccountId = :accountId and isclosed =false';
        if(orderByClause !=null){
        query+= orderByClause;
        }
        query+= ' LIMIT :limitSize OFFSET :offset';
        List<Opportunity> opportunities = Database.query(query);
        List<AggregateResult> lstfinalcount= [SELECT COUNT(Id)total FROM Opportunity WHERE (Renewal_Opportunitity__c=true OR Type='Renewal') AND AccountId = :accountId AND isClosed=false];
        Integer finalcountrenew = (Integer)lstfinalcount[0].get('total');
        // Populating data into wrapper class
        for(Opportunity opp : opportunities) {
            AccountOpportunityWrapper wrapper = new AccountOpportunityWrapper();
            wrapper.oppId=opp.Id;
            wrapper.oppname = opp.Name;
            wrapper.accountId = opp.AccountId;
            wrapper.accname = opp.Account_Name__c;
            wrapper.StageName = opp.StageName;
            wrapper.closedate = String.valueOf(opp.CloseDate);
            wrapper.ownerfname = opp.Owner.Name;
            wrapper.brand = opp.Liner_Brand__c;
            wrapper.grandtotalopp=finalcountrenew;
            dataWrapperList.add(wrapper);
        }
        return dataWrapperList;
    }
    // Wrapper class to hold Opportunity data
    public class AccountOpportunityWrapper {
        @AuraEnabled
        public String oppId { get; set; }
        @AuraEnabled
        public String oppname { get; set; }
        @AuraEnabled
        public String accname { get; set; }
        @AuraEnabled
        public String accountId { get; set; }
        @AuraEnabled
        public String StageName { get; set; }
        @AuraEnabled
        public String closedate { get; set; }
        @AuraEnabled
        public String ownerfname { get; set; }
        @AuraEnabled
        public String brand { get; set; }
        @AuraEnabled
        public Integer grandtotalopp { get; set; }
    }
}