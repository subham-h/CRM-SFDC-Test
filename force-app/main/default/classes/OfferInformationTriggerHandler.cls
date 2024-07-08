/*
 * Created By   : Aleena@Maersk
 * Purpose      : Gives abstract view of all the business logic / functionality implemented on Offer Information trigger.
 *              
 * Revision Jira Number    Date            Owner                   Description
 * -------- ----------   -----------  -------------------   --------------------------------------------------------
 * 1.0      SFSE-12888   10-Oct-2023     Aleena@Maersk      added logic for Opportunity Event v3 and v4
 * 2.0      SFSE-11535   12-Mar-2024     Samar@maersk.com	deactivate V3 and Adding V5 event logic
 */
public class OfferInformationTriggerHandler extends TriggerHandler{
    public map<Id, Offer_Information__c> newMap;
    public map<Id, Offer_Information__c> oldMap;
    
    public OfferInformationTriggerHandler() {
        this.newMap = (map<Id, Offer_Information__c>)Trigger.newMap;
        this.oldMap = (map<Id, Offer_Information__c>)Trigger.oldMap; 
        
    }
   // Use an OfferInformationRecordSelector instance to initiate and form lists of Offer Information that need to be considered for different functionalities

    public OfferInformationRecordSelector offerinforecordselector;
    public override void getRecordSelector() {
        if(offerinforecordselector==null){
            offerinforecordselector = new OfferInformationRecordSelector(Trigger.new, this.oldMap, this);
        }
    }
    public override void onAfterUpdate() {
        if (offerinforecordselector.lstOfOpptyonOffInfoForEvent.size() > 0 && (!System.isFuture() && !System.isBatch() && !System.isQueueable() && !System.isScheduled())){
            system.debug('Offer Info');
            OpportunityEventUtilities.toFireQueableforOpptyEvent(new List<Id>(offerinforecordselector.lstOfOpptyonOffInfoForEvent),true,true,true);
        }else if(offerinforecordselector.lstOfOpptyonOffInfoForEvent.size() > 0 && (System.isFuture() || System.isBatch() || System.isQueueable() || System.isScheduled())){
            OpportunityEventUtilities.toFireOpptyEvent(new List<Id>(offerinforecordselector.lstOfOpptyonOffInfoForEvent),true,true,true);
            
        }
    }
    
}