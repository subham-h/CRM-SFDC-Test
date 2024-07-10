/*
 * Created By   : Ramadevi@UST
 * Purpose      : Gives abstract view of all the business logic / functionality implemented on AFLSQuote trigger
 *              
 * Revision Ref Number    Date            Owner                   Description
 * -------- ----------   -----------  -------------------   --------------------------------------------------------
 * 1.0      #RQ-005525  21-Jul-207     Ramadevi.palanisamy@ust-global.com   Created for implementing CBO (Centralized By Org) trigger architecture.
 *
 * NOTE: STRICTLY NO business logic inside this trigger.
 */


Public class AFLSQuoteTriggerHandler extends TriggerHandler {

    public Map<Id, Qt_Quote__c> newMap;
    public Map<Id, Qt_Quote__c> oldMap;

    Public aflsQuoteTriggerHandler () {
        this.newMap = (map<Id, Qt_Quote__c>)trigger.newMap;
        this.oldMap = (map<Id, Qt_Quote__c>)trigger.oldMap;
    }
    
    public aflsQuoteRecordSelector aflsRecordSelector;
    
    public override void getRecordSelector() {
        aflsRecordSelector = new aflsQuoteRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert() {
        
        // Populate Account and Opportunity of AFLS Quote
        if (!aflsRecordSelector.quoteToBeProcessed.isEmpty()) {
            aflsQuoteFieldPopulator.setQuoteAccOppOwner(aflsRecordSelector.quoteToBeProcessed ,aflsRecordSelector.oppDetails ,aflsRecordSelector.accDetails,aflsRecordSelector.userDetails );
        }
    }
    
    public override void onBeforeUpdate() {
        
        // Populate Account and Opportunity of AFLS Quote
        if (!aflsRecordSelector.quoteToBeProcessed.isEmpty()) {
            aflsQuoteFieldPopulator.setQuoteAccOppOwner(aflsRecordSelector.quoteToBeProcessed ,aflsRecordSelector.oppDetails ,aflsRecordSelector.accDetails,aflsRecordSelector.userDetails );
        }
    }
    
    public override void onAfterInsert() {
        
        // To update the number of AFLS Quotes count on the parent opportunity
         if(!aflsRecordSelector.quoteToBeProcessed.isEmpty()) {
            AFLSQuoteUtilities.setAFLSCountOnOpp(aflsRecordSelector.oppToBeQueried);
        }
    }
 }