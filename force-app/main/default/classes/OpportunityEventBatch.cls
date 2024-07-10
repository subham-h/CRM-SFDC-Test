/*
* Version	Date			Owner					RQ#					Description
***********************************************************************************************************************************************
* 1.0		8/8/23      Samarpreet@maers.com     SFSE-10236          This batch would be used to send sync events for the Opportunity V4 Events
* 
*/
public class OpportunityEventBatch implements Database.Batchable<SObject> {

    private String eventNotification;
    private Set<Id> setOfOppId;

    public OpportunityEventBatch(String eventName, Set<Id> setOfOppId){
        this.eventNotification = eventName;
        this.setOfOppId = setOfOppId;
    }
    
    public Database.QueryLocator start( Database.BatchableContext bc ){
        String soqlQuery = '';
        
        soqlQuery = 'SELECT Id FROM Opportunity WHERE ';
        
        if(eventNotification == 'sync - daily' ){
            soqlQuery += ' lastModifiedDate = TODAY';
        }
        
        if(eventNotification == 'sync - monthly'){
            soqlQuery += 'isClosed = false' ;//AND Stagename != '+'\''+ 'Identifying'+'\''
        }
        
        if( setOfOppId != null && setOfOppId.size() > 0 && eventNotification == 'live'){
            soqlQuery += ' Id in : setOfOppId ' ;
        }
        
        if(Test.isRunningTest()){
            soqlQuery += ' LIMIT 10';
        }
        
        System.debug('soqlQuery ' +soqlQuery);
        return Database.getQueryLocator(soqlQuery);

    }

    public void execute( Database.BatchableContext bc,  List<Opportunity> scope ){
        List<OpportunityEventResponseWrapper.Requests> listOfReq= new List<OpportunityEventResponseWrapper.Requests>();
        List<OpportunityData_Event__e> listOfEvents = new List<OpportunityData_Event__e>();
        List<OpportunityEventResponseWrapper.Results> listofResult = new  List<OpportunityEventResponseWrapper.Results>();

        try{

            for(Opportunity oppty:scope){
                OpportunityEventResponseWrapper.Requests request= new OpportunityEventResponseWrapper.Requests();
                request.oppReq = oppty;
                listOfReq.add(request);
            }
    
            Map<String,String> mapOfTopic = new Map<String,String>();
            for(Producer_Platform_Event_Config__mdt event: Producer_Platform_Event_Config__mdt.getAll().values()){
                if( event.DeveloperName=='OpportunityData_Event'){
                    mapOfTopic.put(event.DeveloperName, event.Topic_Name__c);
                }
            } 
    
            if(!listOfReq.isEmpty()){
                OpportunityEventUtilities.opportunityEvent(listOfReq,mapOfTopic,false,true,eventNotification);
            }
          
    
            /*if(!listofResult.isEmpty()){
                for(OpportunityEventResponseWrapper.Results res:listofResult){
                
                    OpportunityData_Event__e event = new OpportunityData_Event__e();
                    event.JSON_1__c = res.serializedJSON5 != null ? res.serializedJSON5: '';
                    event.JSON_2__c = res.serializedJSON6 != null ? res.serializedJSON6: '';
                    event.JSON_3__c = res.serializedJSON7 != null ? res.serializedJSON7: '';
                    event.JSON_4__c = res.serializedJSON8 != null ? res.serializedJSON8: '';
                    event.key__c = res.kafkakey;
                    event.Topic_name__c = topicName;
                    event.Notification_Name__c = eventNotification;
                    listOfEvents.add(event);
                }
            }
            System.debug('platform event =:'+ listOfEvents.size());

            if(!listOfEvents.isEmpty()){
                Database.SaveResult[] results=  EventBus.publish(listOfEvents);
            }*/
    
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OpportunityEventBatch', 'OpportunityEventBatch', new list<Exception>{ex});
        }


    }

    public void finish( Database.BatchableContext bc ) {
        
    }
}