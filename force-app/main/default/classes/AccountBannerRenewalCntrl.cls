/*
Date			   Story			Developer 	Description
22-April-2024		SFSE-13827		Anjali		Code Created; Controller class to display Banner on AccountFlexiPages to show upcoming& overdue Renewals
*/
public with sharing class AccountBannerRenewalCntrl {
    @auraEnabled(cacheable=true)
    public static Map<String,Integer> getRenewalCounts(Id accountId) { 
        Map<String,Integer> mapRenewalOpportnityCount = new Map<String,Integer>();
        Integer numberOfUpcomingRenwals=0,numberOfOverdueRenewals=0;
        Date todayDt = system.TODAY();
        try{
            for(Opportunity opp: [SELECT Id, CloseDate FROM Opportunity 
                                  WHERE (Renewal_Opportunitity__c=true OR Type='Renewal') AND AccountId =:accountId AND isClosed=false]){
                                      if(opp.CloseDate >= todayDt){
                                          numberOfUpcomingRenwals+=1;
                                      } 
                                      if(opp.CloseDate < todayDt){
                                          numberOfOverdueRenewals+=1;
                                      } 
                                  }
            mapRenewalOpportnityCount.put('upcomingRenewals',numberOfUpcomingRenwals);
            mapRenewalOpportnityCount.put('overdueRenewals',numberOfOverdueRenewals); 
        }
        catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Renewals', 'AccountBannerRenewalCntrl', new list<Exception>{ex}); 
        }
        
        return mapRenewalOpportnityCount;
    } 
}