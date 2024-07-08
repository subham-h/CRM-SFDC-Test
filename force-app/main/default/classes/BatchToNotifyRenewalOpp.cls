/********************************************************
Name : BatchToNotifyRenewalOpp

Author : Arpitha J

Description : Batch to send reminder emails for renewal opportunity based on month duration before Close Date.

*********************************************************/
global class BatchToNotifyRenewalOpp implements Database.Batchable<sObject>,Database.stateful{
    map<Id,Decimal>mapOppXDaysNotify = new map<Id,Decimal>();
    List<opportunity>oppList = new List<opportunity>();
    map<object,List<AggregateResult>>mapOppPRodList = new map<object,List<AggregateResult>>();
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {  
        List<General_Object_Queries_Config__mdt> batchQuery = [SELECT Query__c 
                                                                FROM General_Object_Queries_Config__mdt
                                                                WHERE DeveloperName = 'Renewal_Remider_Email_Notify' 
                                                                LIMIT 1 ];
        String query = batchQuery.get(0).Query__c;
        return Database.getQueryLocator(query);
    }
    
    //execute method to determine days reminder for an opportunity, parent opportunity related products
    global void execute(Database.BatchableContext BC, List<Opportunity> scope)
    {
        map<String,Decimal>mapCDNotificationDays = new map<String,Decimal>();
        set<Id>parentOppRecId = new set<Id>();
        
        mapCDNotificationDays = OpportunityAutoRenewal.getRenewalsClosedDateNotification();//retrive renewal closedate notification.
        for(opportunity opp :scope){
            String range = OpportunityAutoRenewal.fetchXNotifyDays(opp.Actual_Duration__c,mapCDNotificationDays.keyset());
            if(range!=null){
                mapOppXDaysNotify.put(opp.Id,mapCDNotificationDays.get(range));
                oppList.add(opp);
                parentOppRecId.add(opp.Parent_Opportunity__c);
            }
        }
    }
    
    
    global void finish(Database.BatchableContext BC) {//calling a method to send an email
        OpportunityAutoRenewal.sendEmailToRenewalOpp(oppList,mapOppXDaysNotify);
    }
}