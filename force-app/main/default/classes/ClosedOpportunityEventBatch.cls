/*
* Version	Date			Owner					RQ#					Description
***********************************************************************************************************************************************
* 1.0		8/8/23      Samarpreet@maers.com     SFSE-10236          This batch would be used to send sync events for the Open Opportunity for V4 Events
* 
*
*/
public class ClosedOpportunityEventBatch implements Database.Batchable<SObject> {
   
    private String eventNotification;

    public ClosedOpportunityEventBatch(String eventName) {
        this.eventNotification = eventName;
    }

    public Database.QueryLocator start( Database.BatchableContext bc ){
        String soqlQuery = '';
        
        soqlQuery = 'SELECT id, OldValue,OpportunityId, NewValue, Field FROM OpportunityFieldHistory WHERE Field =\'StageName\' and createddate = LAST_N_DAYS:30 ';

        if(Test.isRunningTest()){
            soqlQuery = 'SELECT Id FROM Opportunity where Stagename=\'Closed Won\' LIMIT 10';
        } 
        
        System.debug('soqlQuery ' +soqlQuery);
        return Database.getQueryLocator(soqlQuery);

    }

    public void execute( Database.BatchableContext bc,  List<sObject> scope ){
        Set<Id> setOppId = new Set<Id>();
        List<OpportunityEventResponseWrapper.Requests> listOfReq= new List<OpportunityEventResponseWrapper.Requests>();
        List<OpportunityData_Event__e> listOfEvents = new List<OpportunityData_Event__e>();
        List<OpportunityEventResponseWrapper.Results> listofResult = new  List<OpportunityEventResponseWrapper.Results>();
        try{
            if(!Test.isRunningTest()){
                List<OpportunityFieldHistory> lsthistory = ( List<OpportunityFieldHistory> )scope; 
                for(OpportunityFieldHistory history:lsthistory){
                    if(history.NewValue == 'Closed Won' || history.NewValue == 'Closed Lost' ){
                        setOppId.add(history.OpportunityId);
                    }
                }
            }else{
                List<Opportunity> lstOppty =  ( List<Opportunity> )scope;
                for(Opportunity opp: lstOppty){
                    setOppId.add(opp.Id);
                }
            }
       

            for(Opportunity oppty :[SELECT id FROM Opportunity WHERE Id IN :setOppId]){
                OpportunityEventResponseWrapper.Requests request= new OpportunityEventResponseWrapper.Requests();
                request.oppReq = oppty;
                listOfReq.add(request);
            }

            Map<String,String> mapOfTopic = new Map<String,String>();
            
            for(Producer_Platform_Event_Config__mdt event: Producer_Platform_Event_Config__mdt.getAll().values()){
                if( event.DeveloperName == 'OpportunityData_Event'){
                    mapOfTopic.put(event.DeveloperName, event.Topic_Name__c);
                }
            } 
        
            if(!listOfReq.isEmpty()){
                OpportunityEventUtilities.opportunityEvent(listOfReq,mapOfTopic,false,true,eventNotification);
            }
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OpportunityEventBatch', 'OpportunityEventBatch', new list<Exception>{ex});
        }
    }

    public void finish( Database.BatchableContext bc ) {
        
    }
}