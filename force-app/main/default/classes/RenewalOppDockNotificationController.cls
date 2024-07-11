/********************************************************************************************************************************************
* No.   Version	     Story		     Author			 Date		 Description
* 1.	 1.0		SFSE-13549	   Seba@Maersk	  15/05/2024	 Controller to fetch and display the upcoming/overdue opportunities in Dock notification
*********************************************************************************************************************************************/
public with sharing class RenewalOppDockNotificationController { 
    public static Map<Id,Notification_and_Subscription__c> mapofOpptyToNotfcnSubcpn = new Map<Id, Notification_and_Subscription__c>();
    public static Map<String,Decimal> mapRenewalNotificnDuration = new Map<String,Decimal>();
    public static Date currentDate = SYSTEM.TODAY(); 
    public static Map<String,Integer> mapReminderOptionToHours = new Map<String,Integer>();//Holds reminder option(1 Day / 1 Week) to the number of hours
    public static String OPPORTUNITY_OBJECT_CONST = 'Opportunity'; 
    public static String FEATURE_CONST = 'Renewals'; 
    
    /*SFSE-13549
    * @description Fetch the overdue/ upcoming renewal opportunities for the logged in user and return them to the UI
    * @param  None
    * @return Returns the list of opportunities to be displayed. 
    * Note: If any exception/error occures, it will be handled in the LWC component
    */
    @AuraEnabled 
    public static Map<String,Object> fetchRenewalOpportunities(){  
        Map<String,Object> mapStringToOppListAndCount = new Map<String,Object>();
        List<Opportunity> lstOppToDisplay = new List<Opportunity>(); 
        Map<Id,Opportunity> mapCurrentUserOppsToDisplay = new Map<Id,Opportunity>();
        List<Notification_and_Subscription__c> lstNotifcnSubscptn = new List<Notification_and_Subscription__c>();  
        Decimal numberOfDaysBeforeCDToNotify; 
        String monthRange ='';   
        List<Opportunity> renewalOppList = new List<Opportunity>();
        Date lastModifiedDateByUser;
        Integer numberOfDaysSinceUserOptedTheSelection;
        String reminderOptionSelectedByUser; 
        Integer numberOfUpcomingRenewals = 0,numberOfOverdueRenewals = 0; 
        
        //Get the number of days before close date to send the notification for opportunities from custom metadata
        mapRenewalNotificnDuration = getRenewalNotificationDurationFromCustomMetdata(); 
        
        //Query all the renewal opportunities of current logged in user
        for(Opportunity opp: [SELECT Id,Name,CloseDate,Actual_Duration__c,First_Shipment_Date__c,Last_Shipment_Date__c FROM Opportunity WHERE OwnerId =: UserInfo.getUserId() AND (Renewal_Opportunitity__c = true OR Type = 'Renewal') AND CloseDate != NULL AND  isClosed = FALSE ORDER BY CreatedDate DESC]){
            renewalOppList.add(opp);
            if(opp.CloseDate >= SYSTEM.TODAY()){
                 numberOfUpcomingRenewals+=1;
            } else{
                 numberOfOverdueRenewals+=1;
            }
        }
        mapStringToOppListAndCount.put('upcomingRenewalsCount',numberOfUpcomingRenewals);
        mapStringToOppListAndCount.put('overdueRenewalsCount',numberOfOverdueRenewals);
        
        //Get map of upcoming opportunity(eligible to be notified) id's along with the notification duration        
        mapCurrentUserOppsToDisplay = getOpportunityNotificationDays(renewalOppList, mapRenewalNotificnDuration); 
        
        
        //Create map of Key: opportunity id and value: Notification_and_Subscription__c record
        for(Notification_and_Subscription__c notfSubRec : [SELECT Id,Name,Object_Name__c,Record_Id__c,User__c,Reminder_Date__c FROM Notification_and_Subscription__c WHERE Object_Name__c = 'Opportunity' AND Feature__c = 'Renewals' AND User__c = :UserInfo.getUserId() AND Reminder_Date__c != NULL AND Record_Id__c IN :mapCurrentUserOppsToDisplay.keySet() ORDER BY CreatedDate DESC]){
            mapofOpptyToNotfcnSubcpn.put(notfSubRec.Record_Id__c, notfSubRec);
        }  
        
        //Loop over the renewal opportunities to display
        for(Opportunity renewalOppRec : mapCurrentUserOppsToDisplay.values()){ 
            //If the user had opted for remind me later option for this opportunity earlier 
            if(mapofOpptyToNotfcnSubcpn.containsKey(renewalOppRec.Id)){ 
                //Check if today's date time is greater than or equal to the reminder date set
                if(SYSTEM.NOW() >= mapofOpptyToNotfcnSubcpn.get(renewalOppRec.Id).Reminder_Date__c)
                    lstOppToDisplay.add(renewalOppRec); 
            }else{
                //If the user never opted for a reminder on this opportunity, then display the opportunity
                lstOppToDisplay.add(renewalOppRec);
            }
            
        }
        mapStringToOppListAndCount.put('renewalsToDisplay',lstOppToDisplay); 
        return mapStringToOppListAndCount;
    }
    
    /*SFSE-13549
    * @description Fetch the Renewals_Closed_Date_Notification__mdt custom metadata with the agreement duration - notification days details 
    * @param none
    * @return Returns map with key: start & end date range and value: number of days before the close date when the notification should be sent
    */
    public static Map<String,Decimal> getRenewalNotificationDurationFromCustomMetdata(){
        Map<String,Decimal> mapAgreementDatesStrToNotificationDays = new Map<String,Decimal>(); 
        for(Renewals_Closed_Date_Notification__mdt metadtRec : Renewals_Closed_Date_Notification__mdt.getAll().values()){
            mapAgreementDatesStrToNotificationDays.put(metadtRec.Start_Months__c+'-'+metadtRec.End_Months__c,metadtRec.Notification_before_days__c);
        }
        return mapAgreementDatesStrToNotificationDays;
    }
    
    /*SFSE-13549
    * @description For the upcoming renewals, it checks the number of days before which the notification should be sent.
    * 			   If the closeDate is too far in the future and today's date do not fall under the notification period, we do not display the opportunity.
    *              (The logic does n't have to be checked for overdue renewals since their close date is already passed and they should be displyed anyways).   
    * @param List of all queried renewal opportunities of current user 
    * @param Map with key: Concatenated string of Start and End Month range (as in custom metadata) and value: Notification before days field value
    * @return Returns map with key: Upcoming Renewal Opportunity Ids to be displayed and value: number of days before the close date of opp when the notification should be sent
    * @return Returns Set<Id> of Eligible Upcoming Renewal Opportunity Ids to be displayed  
    */
    public static Map<Id,Opportunity> getOpportunityNotificationDays(List<Opportunity> oppList, Map<String,Decimal> mapAgreementDatesStrToNotificationDays){
        
        String startMonth,endMonth ='';  
        Integer numberOfDaysBeforeCDToNotify = 0;
        Map<Id,Opportunity> mapOppToDisplay = new Map<Id,Opportunity>();
        
        for(Opportunity opp : oppList){ 
            //If opp is approaching closeDate, evaluate the notification duration
            if(opp.CloseDate >= currentDate){  
                //this for loop will not exceed the CPU time limit since the metadata contains a maximum of 5 records
                for(String strStartEndMonth : mapAgreementDatesStrToNotificationDays.keySet()){ 
                    
                    startMonth = strStartEndMonth.subStringBefore('-') != null ? strStartEndMonth.subStringBefore('-') : '';
                    endMonth = strStartEndMonth.subStringAfter('-') != null ? strStartEndMonth.subStringAfter('-') : '' ;
                    
                    if((startMonth != '' && opp.Actual_Duration__c >= Decimal.valueOf(startMonth)) && ((String.isNotBlank(endMonth) 
                                                                                                        && endMonth != 'null' && opp.Actual_Duration__c <= Decimal.valueOf(endMonth)) || (endMonth == 'null'))){
                                                                                                            
                                                                                                            //Ideally all the opporunities should fall under at least one range in the metadata
                                                                                                            numberOfDaysBeforeCDToNotify = Integer.valueOf(mapAgreementDatesStrToNotificationDays.get(strStartEndMonth));
                                                                                                            
                                                                                                            //If today's date lies between any of the days the opportunity needs to get notified
                                                                                                            if(currentDate >= opp.CloseDate.addDays(-numberOfDaysBeforeCDToNotify) && currentDate <= opp.CloseDate){     
                                                                                                                mapOppToDisplay.put(opp.Id,opp);
                                                                                                            }  
                                                                                                        }  
                } 
            }else if(opp.CloseDate < currentDate){ 
                //If opportunity closedate is already passed, display the overdue renewal opportunity
                mapOppToDisplay.put(opp.Id,opp); 
            }
        } 
        return mapOppToDisplay;
    } 
    
    /*SFSE-13549
    * @description Once the user opts for a reminder option, insert of update the notification_subscription record for the incoming opportunity
    * @param  Id of the opportunity for which reminder option is selected
    * @param  The value selected for reminder me after (1 Day / 1 Week)
    * @return Returns map with key: start & end date range and value: number of days before the close date when the notification should be sent
    */
    @AuraEnabled
    public static Boolean upsertRenewalNotificnSubscriptionRecords(Id OpportunityId, String remindMeAfterValueSelected){ 
        List<Notification_and_Subscription__c> lstToUpsert = new List<Notification_and_Subscription__c>();
        Map<String,Integer> mapReminderOptionToHours =  RenewalOppDockNotificationController.fetchRenewalOptionsMetadata(); 
        
        List<Notification_and_Subscription__c> lstnNotifcnSubscrptn = [select Id,Name,Object_Name__c,Record_Id__c,Reminder_Date__c from Notification_and_Subscription__c where Object_Name__c = 'Opportunity' AND Feature__c = 'Renewals' AND Record_Id__c =: OpportunityId AND User__c = :UserInfo.getUserId()];
        
        //If there is no notification subscription record already for the opportunity, then create new one
        if(lstnNotifcnSubscrptn.isEmpty()){
            //Insert a new record
            Notification_and_Subscription__c notifcnSubRec = new Notification_and_Subscription__c();
            notifcnSubRec.User__c = UserInfo.getUserId();
            notifcnSubRec.Object_Name__c = OPPORTUNITY_OBJECT_CONST;
            notifcnSubRec.Feature__c = FEATURE_CONST;
            notifcnSubRec.Record_Id__c = OpportunityId;  
            if(mapReminderOptionToHours.containsKey(remindMeAfterValueSelected)) 
                notifcnSubRec.Reminder_Date__c  = System.Now().addHours(mapReminderOptionToHours.get(remindMeAfterValueSelected));
            
            lstToUpsert.add(notifcnSubRec);
        }else{
            //Update existing records if any
            for(Notification_and_Subscription__c rec : lstnNotifcnSubscrptn){ 
                if(mapReminderOptionToHours.containsKey(remindMeAfterValueSelected))
                    rec.Reminder_Date__c  = System.Now().addHours(mapReminderOptionToHours.get(remindMeAfterValueSelected));
                
                lstToUpsert.add(rec);
            }
        } 
        if(!lstToUpsert.isEmpty()){
            try{ 
                upsert lstToUpsert;
            }catch(Exception ex){
                //If any exception/error occurs, it will be handled in the LWC component while receiving return value as false
                return false;
            }	
        } 
        return true;
    }
    
    /*SFSE-13549
    * @description The reminder options (1 Day/ 1 Month) are stored in custom metadata. This method fetched the metadata records
    * @param  None
    * @return Returns map with key: Reminder option(1 Day/ 1 Week) and value: number of hours in the reminder option (1 hour/ 1 Week)
    */
    @auraEnabled(cacheable=true)
    public static Map<String,Integer> fetchRenewalOptionsMetadata(){
        Map<String,Integer> mapReminderOptionToHours = new Map<String,Integer>();
        for(Renewal_Reminder_Options__mdt reminderOpt : Renewal_Reminder_Options__mdt.getAll().values()){
            mapReminderOptionToHours.put(reminderOpt.Label, Integer.valueOf(reminderOpt.Hours__c));
        }
        return mapReminderOptionToHours;  
    }
}