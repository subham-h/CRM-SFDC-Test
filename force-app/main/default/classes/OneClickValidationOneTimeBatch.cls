global class OneClickValidationOneTimeBatch implements Database.Batchable<sObject>{
    global Set<Id> optyId;
	global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'Select Id from Opportunity WHERE IsClosed = false AND Offer_Type__c = \'Offer containing Standard T&Cs\' AND First_Shipment_Date__c != null AND Last_Shipment_Date__c != null AND Qualify_OneClick_Journey__c = false';
        System.debug(Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Opportunity> opps){
        System.debug(opps);
        Set<Id> optyToUpdate = new Set<Id>();
        optyToUpdate.addAll(new Map<Id, Opportunity>(opps).keySet());
        System.debug('Set: '+optyToUpdate);
        OneClickValidationHelper.checkAllValidation(optyToUpdate, 'trigger');
    }

    global void finish(Database.BatchableContext bc){
        System.debug('Finished');
    }
}