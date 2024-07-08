/*
 * Created By   : Aleena@Maersk
 * Purpose      : Centralize the record selection process for Offer Information object.Defines the methods which iterate and segregate the Offer Information records for further use.
 *              
 * Revision Jira Number    Date            Owner                   Description
 * -------- ----------   -----------  -------------------   --------------------------------------------------------
 * 1.0      SFSE-12888   11-Oct-2023     Aleena@Maersk      Added logic for Opportunity V3 and V4 event record selection on update
 * 
 */
public class OfferInformationRecordSelector {
    private OfferInformationTriggerHandler offerInformationTriggerHandler;
    public Set<Id> lstOfOpptyonOffInfoForEvent = new Set<Id>(); //12888
    
    public OfferInformationRecordSelector(list<Offer_Information__c> lstNewofferInfo, map<Id,Offer_Information__c > OldofferInfo, TriggerHandler offerInformationTriggerHandler){
        Offer_Information__c oldOffinfo;
        if(trigger.isInsert || trigger.isUpdate){
            for(Offer_Information__c newOfferinfo : lstNewofferInfo){  
                if(OldofferInfo != null){
                    oldOffinfo = OldofferInfo.get(newOfferinfo.id);
                }
                
                if(offerInformationTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && offerInformationTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER && (newOfferinfo.Offer_Status__c!= null && newOfferinfo.Offer_Status__c=='Accepted/Completed') ){
                    lstOfOpptyonOffInfoForEvent.add(newOfferinfo.Opportunity__c);  
                }
                
            }
        }
    }
}