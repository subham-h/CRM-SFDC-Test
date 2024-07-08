/*      
 * Revision     Ref Number      Date          Owner                          Description
 * --------     ----------      -----------   -------------------            -----------
 * 1.0          RQ-012787       27/12/2019    Amritesh                       Class created
 * 
 */ 
public class QuoteTriggerHandler extends TriggerHandler {
    
    public Map<Id, Quote> newMap;
    public Map<Id, Quote> oldMap; 
    public QuoteRecordSelector quoteRecordSelector;
    public QuoteTriggerHandler() {
        this.newMap = (map<Id, Quote>) Trigger.NewMap;
        this.oldMap = (map<Id, Quote>) Trigger.oldMap;
    }
    
    public override void getRecordSelector() {
        quoteRecordSelector = new QuoteRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onAfterUpdate() {       
        if(!quoteRecordSelector.lstSelectedQuote.isEmpty()) {
            if( Limits.getQueueableJobs() < Limits.getLimitQueueableJobs() && !Test.isRunningTest()) {                 
                System.enqueueJob(new InsuranceAgreementsAPI.ApiCalloutQueueable(quoteRecordSelector.lstSelectedQuote));  
            }            
        }  
    }

}