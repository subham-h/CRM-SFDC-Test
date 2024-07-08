/*      
 * Revision 	Ref Number  	Date          Owner                          Description
 * -------- 	----------  	-----------   -------------------            -----------
 * 1.0      	RQ-012787   	27/12/2019    Amritesh         			     Class created
 * 
 */ 
public class QuoteRecordSelector implements RecordSelector {
    
    public List<Quote> lstSelectedQuote = new List<Quote>();
    public map<Id, QuoteLineItem> mapRelatedQuoteLineItems = new map<Id, QuoteLineItem>();
    
    private QuoteTriggerHandler quoteTriggerHandler;
    
    public QuoteRecordSelector(List<Quote> lstQuote, map<Id, Quote> mapOldQuote, QuoteTriggerHandler quoteTriggerHandler) {
        this.quoteTriggerHandler = quoteTriggerHandler; 
        selectRecords(lstQuote, mapOldQuote);
        getRelatedRecords(lstQuote); 
    }
    
    public void selectRecords(List<Quote> triggerNewQuoteList, map<Id, sObject> mapOldQuote) {
        system.debug('triggerNewQuoteList' + triggerNewQuoteList);
        if ( quoteTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER ) {
            if( quoteTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE ) {
                for(Quote objQuote : triggerNewQuoteList) {
                    Quote oldQuote = (Quote) mapOldQuote.get(objQuote.Id);
                    if((objQuote.Status=='Closed' && objQuote.Reason_for_Closure__c=='Approved by Customer' &&
                       (oldQuote.Status!='Closed' || oldQuote.Reason_for_Closure__c!='Approved by Customer')) ||
                       (objQuote.Agreement_Status__c=='Resubmit Agreement' && oldQuote.Agreement_Status__c!='Resubmit Agreement'))
                    {
                        lstSelectedQuote.add(objQuote);
                    }
                }
            }  
        }
    }
    
    public void getRelatedRecords( List<Quote> newQuoteList ) {       
        if(!newQuoteList.isEmpty()) {
            mapRelatedQuoteLineItems = getRelatedQuoteLineItems(newQuoteList);
        } 
    }
    
    public static map<Id,QuoteLineItem> getRelatedQuoteLineItems(List<Quote> newQuoteList) {        
        List<String> lstField = new List<String>(QuoteLineItem.SObjectType.getDescribe().fields.getMap().keySet());
        String strQuery = 'SELECT ' + String.join(lstField, ',') + ' FROM QuoteLineItem WHERE QuoteId IN :newQuoteList';
        List<QuoteLineItem> lstQuoteLineItem = Database.query(strQuery);
        Map<Id, QuoteLineItem> mapQuoteLineItems = new Map<Id, QuoteLineItem>(lstQuoteLineItem);
        return mapQuoteLineItems;
    }

}