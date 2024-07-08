public class ActivityReferenceRecordSelector implements RecordSelector {
    
    private TriggerHandler ARRTriggerHandler;
    
    public Map<Id,Integer> caseCountMap = new Map<Id,Integer>();
    public List<Activity_Related_Reference__c> arfList = new List<Activity_Related_Reference__c>();
    
    public ActivityReferenceRecordSelector(list<Activity_Related_Reference__c> lstActivityRef, map<Id, Activity_Related_Reference__c> mapOldActivityRef, TriggerHandler ARRTriggerHandler) {
        this.ARRTriggerHandler= ARRTriggerHandler;
        this.selectRecords(lstActivityRef, mapOldActivityRef);
        
        /*if(lstActivityRef != null) {
this.getRelatedRecords(lstActivityRef);
}
else if(mapOldActivityRef != null) {
this.getRelatedRecords(mapOldActivityRef.values());
}*/
    }
    
    public void selectRecords(list<Activity_Related_Reference__c> lstActivityRef, map<Id, sObject> mapOldActivityRef) {
        system.debug('Inside record selector');
        List<Id> caseIdList = new List<Id>();
        for(Activity_Related_Reference__c ar : lstActivityRef){
            if(ar.Case__c <> NULL) {
                caseIdList.add(ar.Case__c);
            }
            //SC-9293
            if(ARRTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER && ARRTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT){
                if(ar.Case__c != NULL) {
                    arfList.add(ar);
                } 
            }
        }
        if(caseIdList <> NULL){
            List<Activity_Related_Reference__c> existingList = [SELECT id,Case__c from Activity_Related_Reference__c where Case__c in :caseIdList ];
            system.debug('existingList ###'+existingList );
            if(existingList <> null){
                for(Activity_Related_Reference__c arr: existingList ){
                    if(!caseCountMap.keyset().contains(arr.Case__c)){
                        caseCountMap.put(arr.Case__c,1);
                    } else {
                        caseCountMap.put(arr.Case__c,caseCountMap.get(arr.Case__c)+1);
                    }
                }
            }
        }
    }
    
    
    public void getRelatedRecords(list<Activity_Related_Reference__c> lstActivityRef) {
    }
}