/*
* Author   : Naveen
* Purpose  : Process the engagement tracker records on daily basis for create the lead records. 
*
* Version       Date            Owner                               Description
******************************************************************************************************************************************************
* v1.0      07-Jun-2024    naveen.k@maersk.com    SFMC-7701->Lead has to be created for Enangement tracker records without Lead and contact .
------------------------------------------------------------------------------------------------------------------------------------------------------>
*/
global class EngagementTrackMap_Batch implements Database.Batchable<sobject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        DateTime last24Hours = DateTime.now().addDays(0);
        String registrationStatus = 'Account Email Verified';
        Id erecordTypeId = SObjectType.Engagement_Tracker__c.getRecordTypeInfosByName().get('User Registration').getRecordTypeId();
        String query = 'SELECT First_Name__c,Last_Name__c,Email__c,Source_Brand__c,Marketing_Opt_In__c,Capture_Source__c,Phone__c,Lead_Source__c,MobilePhone__c,Country__c,Email_Verified__c FROM Engagement_Tracker__c WHERE Contact__c=NULL AND Lead__c=NULL AND RecordTypeId=:erecordTypeId AND CreatedDate <= :last24Hours AND Registration_Status__c = :registrationStatus ORDER BY Email__c'; 
        return Database.getQueryLocator(query);  
    }
    
     global void execute(Database.BatchableContext BC, List<Engagement_Tracker__c> scope) { 
         List<Lead> recordToInsert = new List<Lead>();
         String companyName;
         Integer index;
         Id erecordTypeId = SObjectType.Engagement_Tracker__c.getRecordTypeInfosByName().get('User Registration').getRecordTypeId();
         Id recordTypeId = SObjectType.Lead.getRecordTypeInfosByName().get('Email Subscriber').getRecordTypeId();
         for(Engagement_Tracker__c etObj: scope){
            companyName =  etObj.Email__c?.split('@')?.get(1);
            index = companyName?.indexOf('.');
            companyName = companyName.subString(0,index); 
            recordToInsert.add(new Lead(FirstName = etObj.First_Name__c,
            LastName = etObj.Last_Name__c,
            Email = etObj.Email__c,
            Company = companyName,
            Marketing_Opt_In__c = etObj.Marketing_Opt_In__c,
            Capture_Source__c = etObj.Capture_Source__c,
            Phone = etObj.Phone__c,
            MobilePhone = etObj.MobilePhone__c,
            Email_Verified__c= etObj.Email_Verified__c,
            Country_lk__c =etObj.Country__c,
            Source_Brand__c = etObj.Source_Brand__c,
            LeadSource = etObj.Lead_Source__c,
            RecordTypeId = recordTypeId) );           
         }
                    
         Database.SaveResult[] srList=Database.insert(recordToInsert,false);
        
         Set<Id> leadIds = new Set<Id>();
         for(Database.SaveResult sr: srList){
             if(sr.isSuccess()){
               leadIds.add(sr.getId());  
             }  
         }
         Map<String, Lead> leadMap = new Map<String, Lead>();
         Set<String> emails = new Set<String>();
         for(Lead ld: [Select id,Email from Lead where Id IN: leadIds]){
            leadMap.put(ld.Email, ld);
            emails.add(ld.Email); 
         }
         Map<String, List<Engagement_Tracker__c>> mapEmailandETs= new Map<String, List<Engagement_Tracker__c>>();
         for(Engagement_Tracker__c et: [SELECT Id,Email__c,First_Name__c,Last_Name__c,Marketing_Opt_In__c,Phone__c FROM Engagement_Tracker__c WHERE Email__c IN:emails AND RecordTypeId=:erecordTypeId]){
             if(!mapEmailandETs.containskey(et.Email__c)){
                 mapEmailandETs.put(et.Email__c, new List<Engagement_Tracker__c>{});  
             }
             mapEmailandETs.get(et.Email__c).add(et);  
         }
         List<Engagement_Tracker__c> etListToUpdate = new List<Engagement_Tracker__c>();
         Id leadId;
         for(String email: mapEmailandETs.keySet()){
             leadId = leadMap.get(email)?.Id;
             if(mapEmailandETs.get(email).size() > 1){
               //assign Lead   
               etListToUpdate.add(new Engagement_Tracker__c(Id = mapEmailandETs.get(email)[0].Id, Lead__c = leadId));  
             }
              else if(mapEmailandETs.get(email).size() == 1){
                 for(Engagement_Tracker__c et: mapEmailandETs.get(email)){
                    etListToUpdate.add(new Engagement_Tracker__c(Id=et.Id,Lead__c=leadId,First_Name__c='',Last_Name__c='Team',Phone__c=NULL,Marketing_Opt_In__c=FALSE));     
                 }   
             }
         }
         
         if(!etListToUpdate.isEmpty()){
             Database.update(etListToUpdate, False);
         }
     } 
        
    global void finish(Database.BatchableContext BC) 
    { 
    
    }


}