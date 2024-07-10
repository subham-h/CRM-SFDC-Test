/*      
* Revision 	Ref Number  	Date          Owner                          Description
* -------- 	----------  	-----------   -------------------            -----------
* 1.0      	RQ-012785   	30/12/2019    sidhartha         			 Code created
* 
*/ 

public class QuoteLineItemValidator {
    public static void validateQuoteLineItem (List<QuoteLineItem> lstQuoteLineItem) {
        system.debug('lstQuoteLineItem before insert' + lstQuoteLineItem.size());
        Set<Id> quoteId = New Set<Id>();
        String qId; 
        List<String> duplicateqLList = new List<String>();
        set<String> setTempString = new set<String>();
        set<String> duplicateTempString = new set<String>();
        
        for(QuoteLineItem qL: lstQuoteLineItem) {
            duplicateqLList.add(String.valueof(qL.Origin__c) + String.valueof(qL.Destination__c) + String.valueof(qL.Insurance_Commodity__c));
            quoteId.add(qL.QuoteId);
            qId = qL.QuoteId;
            system.debug('duplicateqLList '+duplicateqLList);
        }
        
        Map<Id,Quote> quoteWithLineItems = New Map<Id,Quote>(
            [Select Id, (Select Origin__c,Id, Destination__c, Insurance_Commodity__c 
                         From QuoteLineItems Where Id Not In :lstQuoteLineItem AND Origin__c!=NULL AND Destination__c!=NULL 
                        AND Insurance_Commodity__c !=NULL) From Quote Where Id In :quoteId] 
        );
        
        Quote tmp = quoteWithLineItems.get(qId);
        system.debug('quoteWithLineItems ' + tmp.QuoteLineItems);
        system.debug('tmp ' + tmp);
        for(QuoteLineItem qlDupch : tmp.QuoteLineItems){ 
            duplicateqLList.add(String.valueof(qlDupch.Origin__c) + String.valueof(qlDupch.Destination__c) + String.valueof(qlDupch.Insurance_Commodity__c));	  
        }
        
        for(String s: duplicateqLList ){
            if(!setTempString.add(s)){
                duplicateTempString.add(s);
                system.debug('duplicateTempString '+duplicateTempString);
            }
        }
        
        for(QuoteLineItem qL: lstQuoteLineItem) {
            system.debug('duplicateTempString '+duplicateTempString);
            if(!duplicateTempString.IsEmpty() && duplicateTempString !=null) {
                qL.addError('Duplicate Combination Found');
            }
        }
        
    }
}