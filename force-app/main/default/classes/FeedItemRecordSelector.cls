/*
 * Author   : Naved
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on FeedItem trigger.
 *        
 * Revision Ref Number  Date          Owner                          Description
 * -------- ----------  -----------   -------------------            -----------
 * 1.0      RQ-009492   13/11/2016    mohammad.naved@maersk          Code created
 * 
 */  
public class FeedItemRecordSelector implements RecordSelector{
     private TriggerHandler feedTriggerHandler;
     public set<Id> setCaseId = new set<Id>();
     public FeedItemRecordSelector(list<FeedItem> lstFeedItem, map<Id, FeedItem> mapOldFeedItems,TriggerHandler feedTriggerHandler) {
        this.feedTriggerHandler = feedTriggerHandler;
        this.selectRecords(lstFeedItem, mapOldFeedItems);
        
        if(lstFeedItem != null) {
            this.getRelatedRecords(lstFeedItem);
        }
        else if(mapOldFeedItems != null) {
            this.getRelatedRecords(mapOldFeedItems.values());
        }
    }
    public void selectRecords(list<FeedItem> lstFeedItem, map<Id, sObject> oldFeedMap) {
                
        if (lstFeedItem!= null && !lstFeedItem.isEmpty()) {
            String strCasePrefix =case.SObjectType.getDescribe().getKeyPrefix();
            for (FeedItem f: lstFeedItem) {
                 FeedItem oldFeedItem;
                if(oldFeedMap != null && !oldFeedMap.isEmpty()) {
                    oldFeedItem = (FeedItem)oldFeedMap.get(f.Id);
                }  
                if(feedTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER){
                    if(feedTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                        if (String.valueOf(f.ParentId).startsWith(strCasePrefix)  && f.Type == 'TextPost') {
                            setCaseId.add(f.ParentId);
                        }
                    }
                }
                
            }
        }
    }
    public void getRelatedRecords(list<FeedItem> lstTask){
        
    }

}