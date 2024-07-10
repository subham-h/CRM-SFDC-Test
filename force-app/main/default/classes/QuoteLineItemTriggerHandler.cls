/*      
 * Revision 	Ref Number  	Date          Owner                          Description
 * -------- 	----------  	-----------   -------------------            -----------
 * 1.0      	RQ-012785   	30/12/2019    sidhartha         			 Code created
 * 2.0			RQ-013124		19/03/2019	  sidhartha						 Added PriceOwnerCheck API
 * 
 */ 
public class QuoteLineItemTriggerHandler extends TriggerHandler {
    
    public Map<Id, QuoteLineItem> newMap;
    public Map<Id, QuoteLineItem> oldMap; 
    public QuoteLineItemRecordSelector qLRecordSelector;
    
    public QuoteLineItemTriggerHandler() {
        this.newMap = (map<Id, QuoteLineItem>) Trigger.NewMap;
        this.oldMap = (map<Id, QuoteLineItem>) Trigger.oldMap;
    }
    
    public override void getRecordSelector() {
        qLRecordSelector = new QuoteLineItemRecordSelector(Trigger.new, this.oldMap, this);
    }
    
        
    public override void onBeforeUpdate() {   
        if(!qLRecordSelector.listQuoteLineItemRecords.IsEmpty() ) {
            QuoteLineItemValidator.validateQuoteLineItem(trigger.new);
        } 
    }
    
    public override void onBeforeInsert() {  
        if(!qLRecordSelector.listQuoteLineItemRecords.IsEmpty() ) {
            QuoteLineItemValidator.validateQuoteLineItem(trigger.new);
        } 
    }
    
    public override void onAfterInsert() { 
        if(!qLRecordSelector.mapRelatedQuoteLineItems.IsEmpty() && qLRecordSelector.mapRelatedQuoteLineItems !=null) {
           // for(QuoteLineItem qLi: qLRecordSelector.mapRelatedQuoteLineItems) {    
                If( Limits.getQueueableJobs() < Limits.getLimitQueueableJobs() && !Test.isRunningTest()) {
                  	System.enqueueJob(new CargoInsuranceStatusQueueable (qLRecordSelector.mapRelatedQuoteLineItems));
                }
            //}
        }  
    }
    
    public override void onAfterUpdate() {       
        if(!qLRecordSelector.mapRelatedQuoteLineItems.IsEmpty() && qLRecordSelector.mapRelatedQuoteLineItems !=null) {
           // for(QuoteLineItem qLi: qLRecordSelector.mapRelatedQuoteLineItems) {    
                If( Limits.getQueueableJobs() < Limits.getLimitQueueableJobs() && !Test.isRunningTest()) {
                   System.enqueueJob(new CargoInsuranceStatusQueueable (qLRecordSelector.mapRelatedQuoteLineItems));
                }
           // }
        }
          if(qLRecordSelector.listQuoteLineItemRecords.size()>0 &&  qLRecordSelector.bolTrue ) {
              system.debug('3333333333333333333');
            If( Limits.getQueueableJobs() < Limits.getLimitQueueableJobs() && !Test.isRunningTest()) {                 
                System.enqueueJob(new InsuranceAgreementsAPI.ApiCalloutQueueable(qLRecordSelector.listQuoteLineItemRecords));  
            }   
    }

    }
}