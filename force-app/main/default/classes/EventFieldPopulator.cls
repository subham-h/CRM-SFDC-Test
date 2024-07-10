/*
* Author   : Sidhartha
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-009006   09/08/2018  sidhartha               Code created
* 1.1      RQ-009409   05/10/2018  Sidhartha               Added subject in before insert
* 2.0      RQ-012152   05-10-2019 Neha@TCS                 Remove reference of Sales and Business review call record type 
* 
*/  
public class EventFieldPopulator {
    
    public static void populatecontact(List<Event> lstEvent,set<Id> Whatids){
        if(Generic_TriggerHandler.validateRunForMethod('EventFieldPopulator.populatecontact()', 1)) {
            List<Sales_Call__c> SalesCalls = new List<Sales_Call__c>([SELECT Id,Type__c, Name, Contact__c, Lead__c 
                                                                      FROM Sales_Call__c WHERE Id IN :Whatids]);
      Map<Id,Id> contactMapToEvent = new Map<Id,Id>();
            Map<Id,String> typeMapToEvent = new Map<Id,String>();
            Map<Id,String> subjectMapToEvent = new Map<Id,String>();
            Set<Id> salesLeadIds = new Set<Id>();
            for(Sales_Call__c sc :SalesCalls) {
        contactMapToEvent.put(sc.Id,sc.Contact__c);
        typeMapToEvent.put(sc.Id,sc.Type__c);
                salesLeadIds.add(sc.Lead__c);
                subjectMapToEvent.put(sc.Id,sc.Name);
      }        
            Id salesCallId;
            for(Id id :Whatids){
                salesCallId = id;
            }
            if(salesCallId != null && String.valueOf(salesCallId).substring(0,3) == Label.Sales_Call_Object_Key_Prefix) {
                
                for(Event e: lstEvent) {
                    if(e.Subject ==null) {
                        if(subjectMapToEvent !=null) {
                            e.Subject = subjectMapToEvent.get(e.WhatId);
                        }
                    }
                    if(String.isBlank(e.WhoId) && contactMapToEvent!=null){
                        e.WhoId = contactMapToEvent.get(e.WhatId);
                        e.Type = typeMapToEvent.get(e.WhatId);
                    }else if(!String.isBlank(e.WhoId) && contactMapToEvent!=null) {
                        e.Type = typeMapToEvent.get(e.WhatId);
                    }
                    else{
                        if(String.isBlank(e.WhoId) && salesLeadIds!=null){
                            
                        }   
                    }
                    
                }  
            }
        }
    }
    
    /*public static void makeSalescallstartdatenull( List<Event> whatids) {
        Id salesCallRTID = StaticFactory.getRecordTypeIdByName('Sales_Call__c', 'Sales Call');
        Id businessReviewRTID = StaticFactory.getRecordTypeIdByName('Sales_Call__c', 'Business Review');
        Set<Id> salesId = new Set<Id>();
        for(Event e :whatids){
            salesId.add(e.WhatId);
        }
        List<Sales_Call__c> lstSalesCall = [select RecordTypeId,StartDateTime__c,EndDateTime__c from Sales_Call__c where Id IN :salesId];
        List<Sales_Call__c> lstSalesCalltoUpdate = new List<Sales_Call__c>();
        For(Sales_Call__c sc :lstSalesCall) {
            sc.StartDateTime__c = null;
            sc.EndDateTime__c = null;
            sc.Status__c = 'Cancelled';
            if(sc.RecordTypeId == salesCallRTID || sc.RecordTypeId ==businessReviewRTID){
                
                lstSalesCalltoUpdate.add(sc);
            }
        }
        try{
            update lstSalesCalltoUpdate;
        }catch(Exception e) {
            system.debug('@@@@' + e);
        }
    }*/
}