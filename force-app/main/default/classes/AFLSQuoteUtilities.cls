/*
* Created By   : Ramadevi@UST
* Purpose      : Utility class to hold simple and reusable functionalities for auto populating AFLS Quote fields
*              
* Revision Ref Number    Date            Owner                   Description
* -------- ----------   -----------  -------------------   --------------------------------------------------------
* 1.0      #RQ-005525  21-Jul-2017     Ramadevi.palanisamy@ust-global.com   Formatted the trigger and introduced CBO architecture.
* 2.0      #RQ-005636  22-Sep-2017     Nisha.Arjunan@ust-global.com         Update references of GlobalErrorLogger
*/

Public class AFLSQuoteUtilities{
    
    public static void setAFLSCountOnOpp(Set<String> oppIds){
        
        List<Opportunity> oppToUpdate = new List<Opportunity>();  
        List<AggregateResult> Quotes = new List<AggregateResult>();
        map<Id, Decimal> oppAggregateMap = new map <Id, Decimal>(); //Map will contain one parent record Id per one aggregate object
        
        // Aggreate Query to get the count of AFLS Quotes for given opportunities
        for(AggregateResult q : [SELECT Opportunity__c, Count(Id) FROM Qt_Quote__c 
                                 WHERE Opportunity__c IN: oppIds Group By Opportunity__c]){
                                     oppAggregateMap.put((Id)q.get('Opportunity__c'),Decimal.ValueOf(String.ValueOf(q.get('expr0') )));
                                 }
        
        for( Opportunity p: oppToUpdate ){
            p.Count_of_AFLS_Quotes__c = oppAggregateMap.get(p.Id);//Copy the count to Opportunity record
        }
        
        TriggerExecutionController.skipOpportunityTrigger( true ); // #RQ-005517
        Database.SaveResult[] oppSrList = Database.update(oppToUpdate,false); //Update count of Quotes in Opp List after deletion of Quotes.       
        ErrorLogger.writeErrors('SFDC', 'Opportunity', 'AFLSQuoteUtilities.setAFLSCountOnOpp', oppSrList, oppToUpdate) ; // #RQ-005636      
    }
    
}