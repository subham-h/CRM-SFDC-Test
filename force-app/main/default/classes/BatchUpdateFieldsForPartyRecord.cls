/* 
* Purpose  : Purpose of this class is to update the reference fields on Party Records from external ids of those objects
* 
* Revision     Ref Number      Date         Owner                                  Description
* --------     ----------      -----------  -------------------                    -----------
* 1.0			SC-7773			28/04/2023	 Vivek@Maersk							Created the batch class

*/

global class BatchUpdateFieldsForPartyRecord implements Database.Batchable<sObject>, Schedulable  {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        Integer limitRows = 50000;
        String query = 'select id,Shipment_Number__c,Shipment__c,TP_Doc__c,Scv_Customer_Code__c,Tp_Doc_Number__c,Contact_Person__c from party__C where shipment__c = \'\' limit : limitRows ';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Party__c> scope) {
        List<Party__C> partyList = new List<Party__C>();
        
        For(Party__C thisScope: scope){
            Party__C thisParty = new Party__C(Id = thisScope.id);
            if(thisScope.Shipment_Number__c != null && thisScope.Shipment__c == null){
                
                Shipment__c ref = new Shipment__c(Shipment_Number__c = thisScope.Shipment_Number__c);
                
                thisParty.Shipment__r =  ref;
                
            }
            if(thisScope.Tp_Doc_Number__c  != null && thisScope.TP_Doc__c == null){
                
                TP_Doc__c ref = new TP_Doc__c(TP_Doc_Number__c = thisScope.TP_Doc_Number__c);
                
                thisParty.TP_Doc__r =  ref;
            }
            partyList.add(thisParty);
            system.debug('-->partyList'+partyList);
            
        }
        
        if(!partyList.isEmpty())
            Database.update(partyList, false);
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    global void execute(SchedulableContext SC) {
        
        BatchUpdateFieldsForPartyRecord batch = new BatchUpdateFieldsForPartyRecord();
        Database.executeBatch(batch, 10);
        
    }
    
    
}