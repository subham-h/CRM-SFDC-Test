/*
Date			Story			Developer 	Description
27-05-2024		SFSE-13862		Anjali		Controller class to display Banner on Sales Home Page to show upcoming & overdue Renewals where logged in user is the Owner
*/
public with sharing class OpportunityRenewalHomeCntrl {
    
    //Method to pass Total No. of Overdue and Upcoming Renewals for logged in user, where user the Opportunity Owner
    @AuraEnabled(cacheable=true)
    public static Map<String,Integer> getUserRenewalCounts() { 
        Map<String,Integer> mapRenewalOpportnityCount = new Map<String,Integer>();
        Integer numberOfUpcomingRenwals=0,numberOfOverdueRenewals=0;
        Date todayDt = system.TODAY();
        String currentUserId = UserInfo.getUserId();
        for(Opportunity opp: [SELECT Id, CloseDate FROM Opportunity 
                              WHERE (Renewal_Opportunitity__c = true OR Type='Renewal') AND OwnerId = :currentUserId AND isClosed=false]){
                                  if(opp.CloseDate >= todayDt){
                                      numberOfUpcomingRenwals+=1;
                                  } else{
                                      numberOfOverdueRenewals+=1;
                                  } 
                              }
        mapRenewalOpportnityCount.put('upcomingRenewals',numberOfUpcomingRenwals);
        mapRenewalOpportnityCount.put('overdueRenewals',numberOfOverdueRenewals);     
        return mapRenewalOpportnityCount;
    } 
}