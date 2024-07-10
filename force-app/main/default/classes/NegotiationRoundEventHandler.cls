/*  
* Version   Date           Owner                  Description
* --------  -----------    -------------------    -----------
* 1.0       25-March-2024   Samar@Maserk.com      Trigger to update Negotiation with Quote Information from CoPo
*/
public without sharing class NegotiationRoundEventHandler  extends TriggerHandler{
    public List<Negotiation_Round_Event__e> newNegotiationRoundMsg;
    public String jsonStr;
    public Map<String, NegotiationRoundWrapper> mapofOpportunityReftoWrappper = new Map<String, NegotiationRoundWrapper>();
    public Map<String,string> mapOfOpptyQuery = new Map<String,String>();
    public Map<String,Quotes__c> mapOfQuotesToOpp = new Map<String,Quotes__c>();
    public List<Quotes__c> quoteToUpdate = new List<Quotes__c>();


    public NegotiationRoundEventHandler() {
        newNegotiationRoundMsg = (List<Negotiation_Round_Event__e>) Trigger.new;
    }
    
    public override void onAfterInsert() {
        Message message;

        try{
            for(Negotiation_Round_Event__e negotiationRoundMsg : newNegotiationRoundMsg){
                jsonStr = negotiationRoundMsg.JSON_1__c;
                system.debug(jsonStr);
                if(jsonStr != null){
                    NegotiationRoundWrapper jsonDeserialized = parse(jsonStr);
                    system.debug(jsonDeserialized);
                     system.debug(jsonDeserialized.header.eventNotificationName);
					system.debug(jsonDeserialized.message.negotiationRoundStatus);
                    if(jsonDeserialized.header.eventNotificationName == 'NegotiationRoundStatusEvent' && jsonDeserialized.message.negotiationRoundStatus == 'FINALISED' 
                        && jsonDeserialized.message.businessProcess.contains('instantQuote') ){
                        String oppRef = jsonDeserialized.message.opportunityNumber;
                        String agreementNumber =  jsonDeserialized.message.AgreementNumber;
                        Integer round =  jsonDeserialized.message.negotiationRoundNumber;
                        String query = '( Opportunity__r.Opportunity_Ref__c =' + '\'' +oppRef+ '\'' + ' and Negotiation_Round__c =' +round+ ' and  Negotiation_Id__c ='+ '\'' +agreementNumber+ '\'' +')';
                        System.debug('query'+query);
						if(!mapOfOpptyQuery.containsKey(oppRef)){
                            mapOfOpptyQuery.put(oppRef,query);
                        }
                        if(!mapofOpportunityReftoWrappper.containsKey(oppRef)){
                            mapofOpportunityReftoWrappper.put(oppRef,jsonDeserialized);
                        }
                    }
                }
            }

            if(!mapofOpportunityReftoWrappper.keySet().isEmpty()){
                queryToQupote();
                updateQuote();
            }
            
       }catch(Exception ex){
          System.debug('NegotiationRoundEventHandler Exception '+ex.getMessage());
          ErrorLogger.writeError('SFDC', 'Negotiation Round Message', 'NegotiationRoundEventHandler.onAfterInsert', JSON.serialize(ex),ex.getMessage(),ex.getMessage());
      }
    }  

    public void updateQuote(){
        try{
            if(!mapOfQuotesToOpp.keyset().isEmpty()){
                for(String oppRef:mapofOpportunityReftoWrappper.keyset()){
                    NegotiationRoundWrapper wrapper = mapofOpportunityReftoWrappper.get(oppRef);
                    if(!wrapper.message.negotiationInstruments.isEmpty() && mapOfQuotesToOpp.containsKey(oppRef)){
                        for(NegotiationInstrument inst:wrapper.message.negotiationInstruments){
                            if(inst.negotiationInstrumentType =='Rate Output' && inst.negotiationInstrumentDomain=='Athena' && inst.negotiationInstrumentStatus=='Active'){
                                Quotes__c quote=mapOfQuotesToOpp.get(oppRef);
                                quote.Quote_Copo_Link__c = inst.negotiationDetailOutputReference != null ? inst.negotiationDetailOutputReference:null;
                                quoteToUpdate.add(quote);
                            }
                        }
                    }
                }
            }
            if(!quoteToUpdate.isEmpty()){
                List<Database.SaveResult> negotiationresults = Database.update(quoteToUpdate);
                ErrorLogger.writeErrors('SFDC',  'Negotiation Round Message', 'NegotiationRoundEventHandler.onAfterInsert', negotiationresults, quoteToUpdate);
            }
        }catch(Exception ex){
            System.debug('NegotiationRoundEventHandler Exception '+ex.getMessage());
            ErrorLogger.writeError('SFDC', 'Negotiation Round Message', 'NegotiationRoundEventHandler.onAfterInsert', JSON.serialize(ex),ex.getMessage(),ex.getMessage());
        }
        
    }

    public void queryToQupote(){
        if(!mapOfOpptyQuery.keySet().isEmpty()){
            String query ='';
            for(String oppQuery:mapOfOpptyQuery.values()){
                query = query=='' ? oppQuery : 'OR'+ oppQuery;
            }
			System.debug('query'+query);
            String finalQuery= 'SELECT id,Negotiation_Id__c,Status__c,Negotiation_Round__c,Negotiation_Link__c,Opportunity__r.Opportunity_Ref__c,Quote_Copo_Link__c FROM Quotes__c WHERE ' + query;
            map<Id,Quotes__c> mapofQuotes = new Map<Id,Quotes__c>( (List<Quotes__c>) database.query(finalQuery));
            if(!mapofQuotes.values().isEmpty()){
                for(Quotes__c quote: mapofQuotes.values()){
                    if(!mapOfQuotesToOpp.containsKey(quote.Opportunity__r.Opportunity_Ref__c)){
                        mapOfQuotesToOpp.put(quote.Opportunity__r.Opportunity_Ref__c,quote);
                    }
                }
            }
        }
    }

    public class NegotiationRoundWrapper {
        public Message message;
        public Header header;
        
    }
    public class Header {
        public String eventNotificationName;    //negotiationRoundChangeEvent / newNegotiationObjectBuilt
        public String version;    //v1
        public long eventTimestamp;    //0
        public String messageId;    //be77c45a-3a79-4ab7-91b2-8cd6c496cda5
        public String correlationId;    //37976bed-2ff5-45b4-aa05-cbd138856418
    }

    public class Message {
        public String negotiationRoundStatus;
        public String statusDescription;
        public String opportunityNumber;
        public String agreementNumber;
        public List<String> businessProcess;
        public String productFlow;
        public String masterfFlow;
        public Integer negotiationRoundNumber;
        public List<NegotiationInstrument> negotiationInstruments;
        public Message(){
            negotiationInstruments = new List<NegotiationInstrument>();
            businessProcess = new list<String>();
        }
    }

    public class NegotiationInstrument{
        public String negotiationInstrumentReference;
        public String instrumentGroupReference;
        public String negotiationInstrumentDomain;
        public String negotiationInstrumentType;
        public String negotiationInstrumentRequest;
        public String negotiationInstrumentStatus;
        public String negotiationDetailOutputReference;
    }

    public static NegotiationRoundWrapper parse(String json) {
        return (NegotiationRoundWrapper) System.JSON.deserialize(json, NegotiationRoundWrapper.class);
    }
}