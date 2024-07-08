/*      
* Revision 	Ref Number  	Date          Owner                          Description
* -------- 	----------  	-----------   -------------------            -----------
* 1.0      	RQ-012785   	30/12/2019    sidhartha         			 Code created
* 
*/
public class QuoteLineItemRecordSelector implements RecordSelector {
    
    public set<Id> qId = new set<Id>();
    public map<Id,Quote> MapQuote = New map<Id,Quote>();
    //public List<QuoteLineItem> mapRelatedQuoteLineItems = new List<QuoteLineItem>();
    public Map<Id,QuoteLineItem> mapRelatedQuoteLineItems = new Map<Id,QuoteLineItem>();
    public list<QuoteLineItem> listQuoteLineItemRecords = New list<QuoteLineItem>();
    public Set<Id> setQuoteIds = new Set<Id>();
    public boolean bolTrue = false;
    
    private QuoteLineItemTriggerHandler quoteLineItemTriggerHandler;
    public AO_Services__mdt ao_Services_WebserviceDetails = new AO_Services__mdt();
    
    public QuoteLineItemRecordSelector(List<QuoteLineItem> lstQl, map<Id, QuoteLineItem> mapOldQl, QuoteLineItemTriggerHandler qLTriggerHandler) {
        this.quoteLineItemTriggerHandler = qLTriggerHandler; 
        selectRecords(lstQl, mapOldQl);
        getRelatedRecords(lstQl ); 
    }
    
    public void selectRecords(list<QuoteLineItem> triggerNewQLList, map<Id, sObject> mapOldOQL) {
        
        for(QuoteLineItem qL : triggerNewQLList){
            system.debug('qL ' + triggerNewQLList);
            if(quoteLineItemTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) {
                if(quoteLineItemTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE || quoteLineItemTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                    if(qL.Origin__c !=null && qL.Destination__c !=null && qL.Insurance_Commodity__c !=null) {
                        listQuoteLineItemRecords.add(qL);
                    }
                }
            }
            if ( quoteLineItemTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER ) {
                if( quoteLineItemTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE ) {
                    // for(QuoteLineItem qL : triggerNewQLList){
                    QuoteLineItem oldQuoteLineItem = (QuoteLineItem) mapOldOQL.get(qL.Id);
                    if(qL.Agreement_Status__c == 'Submit for Quotation' && oldQuoteLineItem.Agreement_Status__c != 'Submit for Quotation') {
                        qId.add(qL.Id);
                    }
                    if(qL.Agreement_Status__c == 'Cancelled' && oldQuoteLineItem.Agreement_Status__c != 'Cancelled') {
                        system.debug('11111111111111');
                        listQuoteLineItemRecords.add(qL);
                        setQuoteIds.add(qL.QuoteId);
                    }
                    //  }
                    system.debug('setQuoteIds' +setQuoteIds);
                    if(setQuoteIds.size()>0){
                        MapQuote = getQuoteRecords(setQuoteIds);
                        system.debug('MapQuote' +MapQuote);
                    }
                    if(MapQuote.size()>0){
                        for( Quote quo : MapQuote.values()){
                            system.debug('quo.Status' +quo.Status);
                            system.debug('quo.Reason_for_Closure__cs' +quo.Reason_for_Closure__c);
                            system.debug('quo.Agreement_Status__c' +quo.Agreement_Status__c);
                            if(quo.Status=='Closed' && quo.Reason_for_Closure__c=='Approved by Customer' && quo.Agreement_Status__c=='Success'){
                                system.debug('22222222222222222');
                                bolTrue=true;       
                            }
                        }
                    }
                }  else {
                    if(quoteLineItemTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                        if(qL.Agreement_Status__c == 'Submit for Quotation') {
                            qId.add(qL.Id);
                        }    
                    } 
                }
            }
        }
    }
    
    public void getRelatedRecords( list<QuoteLineItem> newQLList ) {       
        if(!qId.isEmpty()) {
            mapRelatedQuoteLineItems = getRelatedQuoteLineItemValues(qId);
        } 
    }
    
   /* public static List<QuoteLineItem> getRelatedQuoteLineItemValues(set<Id> qId) {        
        List<QuoteLineItem> mapQuoteLineItemCommodity = new List<QuoteLineItem>([SELECT Id,Agreement_Id__c, CreatedBy.Maersk_User_Id__c, Destination_Geo_Code__c, Origin_Geo_Code__c, Quote.Price_Owner_Code__c, Quote.Carrier_Code__c, Insurance_Commodity__r.Name FROM QuoteLineItem WHERE Id IN :qId]);
        system.debug('mapQuoteLineItemCommodity' + mapQuoteLineItemCommodity);
        return mapQuoteLineItemCommodity;
    }*/
    public static Map<Id,QuoteLineItem> getRelatedQuoteLineItemValues(set<Id> qId) {        
        Map<Id,QuoteLineItem> mapQuoteLineItemCommodity = new Map<Id,QuoteLineItem>([SELECT Id,Agreement_Id__c, CreatedBy.Maersk_User_Id__c, Destination_Geo_Code__c, Origin_Geo_Code__c, Quote.Price_Owner_Code__c, Quote.Carrier_Code__c, Insurance_Commodity__r.Name FROM QuoteLineItem WHERE Id IN :qId]);
        system.debug('mapQuoteLineItemCommodity' + mapQuoteLineItemCommodity);
        return mapQuoteLineItemCommodity;
    }
    
    public static map<Id,Quote> getQuoteRecords(set<id> QuoteIdSet) {
        system.debug('QuoteIdSet' +QuoteIdSet);
        map<Id,Quote> mapQuote = new map<Id, Quote>([ SELECT id,Status,Reason_for_Closure__c,Agreement_Status__c,Agreement_Status_Description__c FROM Quote WHERE Id IN: QuoteIdSet]); 
        system.debug('mapQuote' +mapQuote);
        return mapQuote;
    }
}