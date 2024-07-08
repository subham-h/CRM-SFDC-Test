public with sharing class OpportunityReportController {

    // Method to retrieve Opportunity report data
    @AuraEnabled(cacheable=true)
    public static List<AccountReportRow> getOpportunityReportData(String ownerAreaCode) {
        // Initialize map to store report data grouped by Account Id
        List <AccountReportRow> accountReportList= new List <AccountReportRow>();
        Map<String, String> accountIdNameMap = new Map<String, String>();
        Map<Id, List<Opportunity>> accountOppMap = new Map<Id, List<Opportunity>>();

        for (Opportunity opp : [
            SELECT AccountId, Account_Name__c, Opportunity_Score__c, Owner_Area_Code__c,Total_Opportunity_Revenue__c,Estimated_Total_Opp_Gross_Profit_Cus__c
            FROM Opportunity
            WHERE Opportunity_Score__c != null limit 200
        ]) {
            if(accountOppMap.containsKey(opp.AccountId)){
                accountOppMap.get(opp.AccountId).add(opp);
            }else{
                accountOppMap.put(opp.AccountId,new List<Opportunity>{opp});
            }
            accountIdNameMap.put(opp.AccountId,opp.Account_Name__c);


        }
        for (Id accId : accountOppMap.keySet()){
            // Extract data from opportunity record
            AccountReportRow row = new AccountReportRow(accId, accountIdNameMap.get(accId));
            for (Opportunity opp : accountOppMap.get(accId)){
                Integer oppScore = Integer.valueOf(opp.Opportunity_Score__c);
                Decimal oppRev = opp.Total_Opportunity_Revenue__c;
                Decimal oppProfit = opp.Estimated_Total_Opp_Gross_Profit_Cus__c;
                if (oppScore >= 0 && oppScore <= 20) {
                    row.zeroToTwenty++;
                    row.totalRevzeroToTwenty+=oppRev;
                    row.totalProfitzeroToTwenty+=oppProfit;
                } else if (oppScore >= 21 && oppScore <= 50) {
                    row.twentyOneToFifty++;
                    row.totalRevtwentyOneToFifty+=oppRev;
                    row.totalProfittwentyOneToFifty+=oppProfit;
                } else if (oppScore >= 51 && oppScore <= 75) {
                    row.fiftyOneToSeventyFive++;
                    row.totalRevfiftyOneToSeventyFive+=oppRev;
                    row.totalProfitfiftyOneToSeventyFive+=oppProfit;
                } else if (oppScore >= 76 && oppScore <= 100) {
                    row.seventySixToHundred++;
                    row.totalRevseventySixToHundred+=oppRev;
                    row.totalProfitseventySixToHundred+=oppProfit;
                }
            }
            accountReportList.add(row);
        }
           

        // Convert map values to list and return
        return accountReportList;
    }

    // Inner class to represent each row in the report
    public class AccountReportRow {
        @AuraEnabled
        public Id accountId { get; set; }
        @AuraEnabled
        public String accountName { get; set; }
        @AuraEnabled
        public Integer zeroToTwenty { get; set; }
        @AuraEnabled
        public Integer twentyOneToFifty { get; set; }
        @AuraEnabled
        public Integer fiftyOneToSeventyFive { get; set; }
        @AuraEnabled
        public Integer seventySixToHundred { get; set; }

        @AuraEnabled
        public Decimal totalRevzeroToTwenty { get; set; }
        @AuraEnabled
        public Decimal totalProfitzeroToTwenty { get; set; }

        @AuraEnabled
        public Decimal totalRevtwentyOneToFifty { get; set; }
        @AuraEnabled
        public Decimal totalProfittwentyOneToFifty { get; set; }

        @AuraEnabled
        public Decimal totalRevfiftyOneToSeventyFive { get; set; }
        @AuraEnabled
        public Decimal totalProfitfiftyOneToSeventyFive { get; set; }

        @AuraEnabled
        public Decimal totalRevseventySixToHundred { get; set; }
        @AuraEnabled
        public Decimal totalProfitseventySixToHundred { get; set; }

        public AccountReportRow(Id accId, String accName) {
            accountId = accId;
            accountName = accName;
            zeroToTwenty = 0;
            twentyOneToFifty = 0;
            fiftyOneToSeventyFive = 0;
            seventySixToHundred = 0;
            totalRevzeroToTwenty = 0;
            totalProfitzeroToTwenty = 0;
            totalRevtwentyOneToFifty = 0;
            totalProfittwentyOneToFifty = 0;
            totalRevfiftyOneToSeventyFive = 0;
            totalProfitfiftyOneToSeventyFive = 0;
            totalRevseventySixToHundred = 0;
            totalProfitseventySixToHundred = 0;
        }
    }
}