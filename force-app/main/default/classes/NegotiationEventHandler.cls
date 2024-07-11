/*
* Version    Date            Owner                    Description
* --------   -----------     -------------------      -----------
* 1.0        31-May-2023     Vazid                    To update Negotiation Information from CoPo
*/

public with sharing class NegotiationEventHandler extends TriggerHandler{
    public List<Negotiation_Message_Event__e> newNegotiationMsg;
    public String jsonStr;
    public static List<Quotes__c> quoteDataToUpsert;
    //public static Map<String,Opportunity> mapOfOpportunity;
    public static Map<String,String> mapQuoteIdOppId;
    public static List<Opportunity> lstOppToUpdate;
    Map<Id,Quotes__c> mapQuoteToUpdate;
    
    public NegotiationEventHandler() {
        this.newNegotiationMsg = (List<Negotiation_Message_Event__e>) Trigger.new;
        quoteDataToUpsert = new  List<Quotes__c>();
        mapQuoteIdOppId = new Map<String,String>();
        //mapOfOpportunity = new Map<String,Opportunity>();
        lstOppToUpdate = new List<Opportunity>();
        mapQuoteToUpdate = new Map<Id,Quotes__c>();
    }
    
    public override void onAfterInsert() {
        Message message;
        set<string> setOfOptyRef = new set<String>();
        try{
            for(Negotiation_Message_Event__e negotiationMsg : newNegotiationMsg){
                Quotes__c quoteRec = new Quotes__c();
                jsonStr = negotiationMsg.JSON_1__c;
                if(jsonStr != null){
                    NegotiationWrapper jsonDeserialized = parse(jsonStr);
                    if(jsonDeserialized.message != null && jsonDeserialized.message.opportunityNumber != null) {
                        setOfOptyRef.add(jsonDeserialized.message.opportunityNumber);
                        if(!String.isBlank(jsonDeserialized.message.QuoteId) && !String.isEmpty(jsonDeserialized.message.QuoteId)){
                            if(jsonDeserialized.message.eventType == 'RFQ_FILE_RECEIVED_EVENT'){
                            	quoteRec.Status__c = 'Negotiation in Progress';    
                            }else if(jsonDeserialized.message.eventType == 'ROUND_COMPLETED'){
                                quoteRec.Status__c = 'Negotiation Round Completed';
                                //quoteRec.Negotiation_Round__c = jsonDeserialized.message.negotiationRoundNumber; // round number derived in SFDC
                            }
                            quoteRec.Id = jsonDeserialized.message.QuoteId;
                            quoteRec.Collaboration_Portal_Link__c= jsonDeserialized.message.link;
                            //quoteRec.Negotiation_Source__c = jsonDeserialized.message.systemSource;// if quote Id null, then its Naas
                           // quoteRec.Negotiation_Round__c = jsonDeserialized.message.negotiationRoundNumber;
                            quoteRec.Negotiation_Id__c = jsonDeserialized.message.negotiationNumber;
                            mapQuoteToUpdate.put(quoteRec.Id,quoteRec);
                        }else{
                            //create a new quote
                        }
                    }
                }
            }
            /*List<Opportunity> lstOfOptys =[select Id, Opportunity_Ref__c,(Select Id,Status__c,Opportunity__c from Quotes1__r order by lastModifiedDate DESC) from Opportunity where Opportunity_Ref__c in :setOfOptyRef];
            for(Opportunity optyRec: lstOfOptys){
                for(Quotes__c quo : optyRec.Quotes1__r){
                   system.debug('quoteRec'+quo.Id+quo.Opportunity__c);
                   mapQuoteIdOppId.put(quo.Id, quo.Opportunity__c);  
                }                                              
            }*/
            if(!mapQuoteToUpdate.isEmpty()){
                List<Quotes__c> tempLstQuote = [Select Id, Status__c from Quotes__c where Id IN : mapQuoteToUpdate.keySet()];
                if(!tempLstQuote.isEmpty()){
                    for(Quotes__c qt : tempLstQuote){
                        if(mapQuoteToUpdate.containsKey(qt.id) && mapQuoteToUpdate.get(qt.Id).Status__c == 'Negotiation in Progress' && qt.Status__c == 'Negotiation Round Completed') {
                            mapQuoteToUpdate.get(qt.id).status__c = 'Negotiation Round Completed';
                        }  
                    }
                    
                }
                /*for(Quotes__c quoteRec : lstQuoteToUpdate){
                    if( mapQuoteIdOppId.containsKey(quoteRec.Id)){
                		quoteRec.Opportunity__c = mapQuoteIdOppId.get(quoteRec.Id);
            		}
                }*/
                List<Database.SaveResult> negotiationresults = Database.update(mapQuoteToUpdate.values());
                ErrorLogger.writeErrors('SFDC', 'Negotiation Message', 'NegotiationEventHandler.onAfterInsert', negotiationresults, quoteDataToUpsert);
            }
       }catch(Exception ex){
          System.debug('NegotiationEventHandler Exception '+ex.getMessage());
          ErrorLogger.writeError('SFDC', 'Negotiation Message', 'NegotiationEventHandler.onAfterInsert', JSON.serialize(ex),ex.getMessage(),ex.getMessage());
      }
    }   
   
    public class NegotiationWrapper {
        public Message message;
        public Header header;
    }
    public class Header {
        public String eventNotificationName;    //negotiationRoundChangeEvent / newNegotiationObjectBuilt
        public String version;    //v1
        //public String system;    //NAAS
        public Integer eventTimestamp;    //0
        public String messageId;    //be77c45a-3a79-4ab7-91b2-8cd6c496cda5
        public String correlationId;    //37976bed-2ff5-45b4-aa05-cbd138856418
    }
    public class Message {
        public String quoteId;
        public String eventType;
        public String negotiationNumber;
        public String opportunityNumber;
        public Integer negotiationRoundNumber;
        public String link;
        public String systemSource;
    }
    public static NegotiationWrapper parse(String json) {
        return (NegotiationWrapper) System.JSON.deserialize(json, NegotiationWrapper.class);
    }
}