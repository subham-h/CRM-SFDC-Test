/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      SFMC-7512   15-Feb-2024 Ranjan@maersk           Created
*/
public without sharing class EngagementTrackerSelector implements RecordSelector {
    private TriggerHandler trgHandler;
    Public List<Engagement_Tracker__c> engtckrWithoutLdCon = new List<Engagement_Tracker__c> ();
    public Set<Id> leadToMakeEmVerTrueIds=new Set<Id>();
    public Set<Id> conToMakeEmVerTrueIds=new Set<Id>();
    public Map<Id,Engagement_Tracker__c> conIdETMap=new Map<Id,Engagement_Tracker__c>();
    public Map<Id,Engagement_Tracker__c> leadIdETMap=new Map<Id,Engagement_Tracker__c>();
    Public static Map<Id,Engagement_Tracker__c> contactPointMap=new Map<Id,Engagement_Tracker__c>();
    public EngagementTrackerSelector(List<Engagement_Tracker__c> lstEngageTrack, 
                                            Map<Id, Engagement_Tracker__c> mapOldEngTrack, 
                                            EngagementTrackerTriggerHandler engTraTriggerHandler) 
    {
        
        this.trgHandler = engTraTriggerHandler;
        if(lstEngageTrack==null){return;} //avoid running on the delete condition 
        selectRecords(lstEngageTrack, mapOldEngTrack);
        
    }
    public void selectRecords(List<Engagement_Tracker__c> lstEngageTrack, map<Id, sObject> mapOldEngTrack) {
        for (Engagement_Tracker__c engTrackObj : lstEngageTrack)
        {
            // if record is updated, get old lead record 
            Engagement_Tracker__c oldETObj;
            if (mapOldEngTrack != null){
                oldETObj = (Engagement_Tracker__c) mapOldEngTrack.get(engTrackObj.Id);
            }
            if(
                (trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT ||
                    (trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE)
                ) &&
                trgHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && 
                engTrackObj.lead__c==null && 
                engTrackObj.contact__c==null)
            {
                engtckrWithoutLdCon.add(engTrackObj);
            }
            if(
                (trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT ||
                    (trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && !oldETObj.Email_Verified__c)
                ) &&
                trgHandler.trigType == TriggerHandler.TriggerType.ISAFTER && 
                engTrackObj.Email_Verified__c==true &&
                engTrackObj.lead__c!=null)
            {
                    leadToMakeEmVerTrueIds.add(engTrackObj.lead__c);
            }
            if((trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT ||
                    (trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && !oldETObj.Email_Verified__c)
                ) &&
                trgHandler.trigType == TriggerHandler.TriggerType.ISAFTER && 
                engTrackObj.Email_Verified__c &&
                engTrackObj.contact__c!=null)
            {
                    conToMakeEmVerTrueIds.add(engTrackObj.contact__c);
            }
            if((trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT ||
                (trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && 
                    (!oldETObj.Email_Verified__c||!oldETObj.Marketing_Opt_In__c||oldETObj.contact__c==null)
                    )
                )&&
                trgHandler.trigType == TriggerHandler.TriggerType.ISAFTER &&
                engTrackObj.Email_Verified__c && engTrackObj.Marketing_Opt_In__c && engTrackObj.contact__c!=null)
            {
                conIdETMap.put(engTrackObj.contact__c,engTrackObj);
            }
            if((trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT ||
                    (trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && 
                        (!oldETObj.Email_Verified__c||!oldETObj.Marketing_Opt_In__c||oldETObj.lead__c==null)
                    )
                )&&
                trgHandler.trigType == TriggerHandler.TriggerType.ISAFTER &&
                engTrackObj.Email_Verified__c && engTrackObj.Marketing_Opt_In__c && engTrackObj.lead__c!=null)
            {
                leadIdETMap.put(engTrackObj.lead__c,engTrackObj);
            } 
              
        }
    }
    public void getRelatedRecords(List<Engagement_Tracker__c> lstEngageTrack) {
    }

}