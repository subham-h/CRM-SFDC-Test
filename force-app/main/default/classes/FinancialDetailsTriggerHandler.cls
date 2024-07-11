/*
 * Author   : Ragu@UST
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on Case trigger.
 * 
 * Revision Ref Number  Date        Owner                                      Description
 * -------- ----------  ----------- --------------------------------------     -----------
 * 1.0      #SP-0032    23-Feb-2016   Sandhya.Sambasivan@ust-global.com         Created for implementing CBO (Centralized By Org) trigger architecture.
 * 2.0      SC-9293     22-12-2023  Shahanawaz@maersk       					Create feeditem on parent Case
 * 
 */

public class FinancialDetailsTriggerHandler extends TriggerHandler {
    
    public map<Id, Financial_Details__c> newMap;
    public map<Id, Financial_Details__c> oldMap;
    public FinancialDetailsTriggerHandler() {
        this.newMap = (map<Id, Financial_Details__c>)Trigger.newMap;
        this.oldMap = (map<Id, Financial_Details__c>)Trigger.oldMap; 
    }
    
    public FinancialDetailsRecordSelector finDetailsRecordSelector;
    public override void getRecordSelector() {
        finDetailsRecordSelector = new FinancialDetailsRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert() {
        // Populate fields on before insert
        FinancialDetailsFieldPopulator.populateFieldsOnBeforeInsertUpdate(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeUpdate() {
        // Populate fields on before insert
        FinancialDetailsFieldPopulator.populateFieldsOnBeforeInsertUpdate(Trigger.new, this.oldMap, this);
        
        if(!finDetailsRecordSelector.mapFinDetForExRate.isEmpty()) {
            // Call ESB to recalculate USD_Amount__c, if any of the critical fields are updated in the Financial Details record
            ExchangeRate.calculateExchangeRate(finDetailsRecordSelector.mapFinDetForExRate.values(), 'Financial_Details__c', 'SFDC.CURRENCYCONVERSION.REQUEST');
        }
    }
    
    public override void onAfterInsert() {
        if(!finDetailsRecordSelector.mapFinDetForExRate.isEmpty()) {
            // After creation of the Financial Details record call ESB to calculate USD_Amount__c, if it has all the mandatory fields
            ExchangeRate.calculateExchangeRate(finDetailsRecordSelector.mapFinDetForExRate.values(), 'Financial_Details__c', 'SFDC.CURRENCYCONVERSION.REQUEST');
        }
        
        if(!finDetailsRecordSelector.finDetailsList.isEmpty()){
            FinancialDetailsFieldPopulator.createFeedItem(finDetailsRecordSelector.finDetailsList);
        }
    }
    
}