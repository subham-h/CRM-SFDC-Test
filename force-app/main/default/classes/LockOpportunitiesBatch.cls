/*
* Purpose   : Batch class scheduled to lock the Closed Opportunities post 7 days of unlocking. Batch executes daily at 10 PM GMT.
*
* Revision  Ref Number       Date                Dev                   Description
* --------  ----------    -----------      -------------------         -----------
* 1.0       SFSE-13391    30-Apr-2024       Shashi@Maersk              Created.
*/
    
global class LockOpportunitiesBatch implements Database.Batchable<SObject> {
     
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Query for closed & unlocked Opportunities older than 7 days
        String query;
        Datetime sevenDaysAgo = System.now().addDays(-7);
        if(Test.isRunningTest()) {
            query = 'SELECT Id, Record_Locked__c FROM Opportunity WHERE Record_Locked__c = false AND isClosed = true AND Opportunity_Unlocked_Date__c < :sevenDaysAgo LIMIT 50';
        } else {
            query = 'SELECT Id, Record_Locked__c FROM Opportunity WHERE Record_Locked__c = false AND isClosed = true AND Opportunity_Unlocked_Date__c < :sevenDaysAgo';
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Opportunity> lstOppty) {
        
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for(Opportunity opp : lstOppty) {
            opp.Record_Locked__c = true;
            opportunitiesToUpdate.add(opp);
        }
        
        Database.SaveResult[] updateResults;
        
        TriggerExecutionController.skipOpportunityTrigger(true);
        
        Validation_Rules_Bypass__c bt = Validation_Rules_Bypass__c.getInstance();
        if(bt.Active__c != true){
            bt.Active__c = true;
        	insert bt;
        }
        
        try {
            //TriggerExecutionController.skipOpportunityTrigger(true);
            updateResults = Database.update(opportunitiesToUpdate, false);
        } catch (Exception e) {
            ErrorLogger.writeErrors('SFDC', 'Opportunity', 'LockOpportunitiesBatch.execute', new List<Exception> {e}); 
        }
        
        TriggerExecutionController.skipOpportunityTrigger(false);
        
        Validation_Rules_Bypass__c btt = Validation_Rules_Bypass__c.getInstance();
        if(btt.Active__c != true){
            delete btt;
        }
        
        //ErrorLogger.writeErrors('SFDC', 'Opportunity', 'LockOpportunitiesBatch.execute', updateResults, opportunitiesToUpdate); 

    }
    
    global void finish(Database.BatchableContext bc) {}
  }