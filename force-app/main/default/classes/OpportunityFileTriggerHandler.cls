/*
 * Created By   : Aleena@Maersk
 * Purpose      : Gives abstract view of all the business logic / functionality implemented on Opportunity File trigger.
 *              
 * Revision Jira Number    Date            Owner                   Description
 * -------- ----------   -----------  -------------------   --------------------------------------------------------
 * 1.0      SFSE-12888   10-Oct-2023     Aleena@Maersk      added logic for Opportunity Event v3 and v4
 * 
 */
public class OpportunityFileTriggerHandler extends TriggerHandler {
    public map<Id, Opportunity_File__c> newMap;
    public map<Id, Opportunity_File__c> oldMap;
    public OpportunityFileTriggerHandler() {
        this.newMap = (map<Id, Opportunity_File__c>)Trigger.newMap;
        this.oldMap = (map<Id, Opportunity_File__c>)Trigger.oldMap; 
        
    }
    public OpportunityFileRecordSelector opptyfileRecordSelector;
    public override void getRecordSelector() {
        if(opptyfileRecordSelector==null){
            opptyfileRecordSelector = new OpportunityFileRecordSelector(Trigger.new, this.oldMap, this);
        }
    }
    public override void onAfterUpdate() {
        if (opptyfileRecordSelector.lstOfOpptyonOpptyFileForEvent.size() > 0 && (!System.isFuture() && !System.isBatch() && !System.isQueueable() && !System.isScheduled())){
            OpportunityEventUtilities.toFireQueableforOpptyEvent(new List<Id>(opptyfileRecordSelector.lstOfOpptyonOpptyFileForEvent),true,true,true);
        }else if(opptyfileRecordSelector.lstOfOpptyonOpptyFileForEvent.size() > 0 && (System.isFuture() || System.isBatch() || System.isQueueable() || System.isScheduled())){
            OpportunityEventUtilities.toFireOpptyEvent(new List<Id>(opptyfileRecordSelector.lstOfOpptyonOpptyFileForEvent),true,true,true);

        }
    }
}