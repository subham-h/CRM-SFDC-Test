/*
 * Author   : Naved
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on task trigger.
 *        
 * Revision Ref Number  Date          Owner                          Description
 * -------- ----------  -----------   -------------------            -----------
 * 1.0      RQ-009492   13/11/2016    mohammad.naved@maersk          Code created
 * 
 */  
public class FeedItemHandler extends TriggerHandler {
    public FeedItemRecordSelector FeeItemRecordSelector;
    public map<Id, FeedItem> newMap;
    public map<Id, FeedItem> oldMap;
    public FeedItemHandler() {
        this.newMap = (map<Id, FeedItem>)Trigger.newMap;
        this.oldMap = (map<Id, FeedItem>)Trigger.oldMap; 
    }
    public override void getRecordSelector() {
        FeeItemRecordSelector = new FeedItemRecordSelector(Trigger.new, this.oldMap, this);
    } 
    public override void onAfterInsert() {
        Map<Id,Case> twillCaseMap; 
        if(!FeeItemRecordSelector.setCaseId.isEmpty()) {
            /* for Twill Japan Case's Non japanese comment translation*/
            String deliveryChannel = General_Key_Value_Configurations__mdt.getInstance('Delivery_Channel').first_field_value__c;
            List<String> delChannelList=deliveryChannel.split(',');
            twillCaseMap=new Map<Id,Case>([select Id from Case where id in:FeeItemRecordSelector.setCaseId and Case_Country__c='Japan' and Delivery_Channel__c in:delChannelList]);
            // Updates the Last Activity date on the account for which the task exists.
            TriggerExecutionController.skipCaseTrigger(true);
            CaseLastActivityUtility.updateCasefield(FeeItemRecordSelector.setCaseId);
            TriggerExecutionController.skipCaseTrigger(false);
           
        }
        if(twillCaseMap!=null && !twillCaseMap.isEmpty()){
            List<FeedItem> itemsToBeTranslated=new List<FeedItem>();
            for(FeedItem feedObj:this.newMap.values()){
                if(twillCaseMap.containsKey(feedObj.ParentId)){
                    itemsToBeTranslated.add(feedObj);
                }
            }
            if(!itemsToBeTranslated.isEmpty()){
                System.enqueueJob(new FeedTranslatorQueueable(itemsToBeTranslated));
            }
            
        }
        // No need to fire Task trigger again during workflow field update
        TriggerExecutionController.skipTaskTrigger(true);
    }
}