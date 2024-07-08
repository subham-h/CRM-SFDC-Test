/**
* -------------------------------------------------------------------------------------------------------------------------------------------------------
* Rev  Story       Name            Date                Comments
* 1. SFSE-12961   Bharti           20/09/2023        Batch created to invoke sendOfferEmailforExpired and sendOfferEmailAboutToExpire class .  
**/



public class BatchSendEmailForOfferInfoExpired implements Database.Batchable<SObject>  {
  private List<Offer_Information__c> listIdOfExpiredOpp =  new List<Offer_Information__c>();
   private List<Offer_Information__c> listIdOfAboutToExpiredOpp = new  List<Offer_Information__c>();
    
    
    public Database.QueryLocator start( Database.BatchableContext BC ){
        String strValue =System.Label.Offer_Sent;
        String query = 'SELECT id,Offer_Status__c, Opportunity__r.CloseDate,To_Recipient__c,CreatedById,Opportunity__c,CC_Recipients__c from Offer_Information__c'+ 
            ' WHERE Offer_Status__c = :strValue And (Opportunity__r.CloseDate  <= Tomorrow) ';
         System.debug('query' + query);       
        return  Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext info,List<Offer_Information__c> lstOffer) {
         DateTime closeDate;
      for(Offer_Information__c offer :lstOffer ){
           closeDate = offer.Opportunity__r.CloseDate;
       
             if(offer.Offer_Status__c == System.Label.Offer_Sent && offer.Opportunity__r.CloseDate <= Date.today()){
                   listIdOfExpiredOpp.add(offer); 
                
                }
            if(offer.Offer_Status__c == System.Label.Offer_Sent && offer.Opportunity__r.CloseDate == Date.today().addDays(1)){
              listIdOfAboutToExpiredOpp.add(offer);
                
          }
            
        }
         if(!listIdOfExpiredOpp.isEmpty()){
           
         sendOfferEmailforExpired.sendEmailOfferExpired(listIdOfExpiredOpp);
         
        }
        
        if(!listIdOfAboutToExpiredOpp.isEmpty()){
           sendOfferEmailAboutToExpire.sendEmailOfferToExpire(listIdOfAboutToExpiredOpp);  
             
        }
        
        
    }
    
    public void finish( Database.BatchableContext BC ) {
        
       
    }


}