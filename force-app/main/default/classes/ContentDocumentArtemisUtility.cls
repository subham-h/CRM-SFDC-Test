public without sharing class ContentDocumentArtemisUtility {
    public static void sendArtemisFiles(map<Id, ContentDocument> ContentDocumentOldMap){
        String artemisIdStr='';
        Map<Id,ContentVersion> contentVerMap=new Map<Id,ContentVersion>([select id,artemis_id__c from ContentVersion where ContentDocumentId in:ContentDocumentOldMap.keySet()]);
        for (ContentVersion cvObj : contentVerMap.values()) {
            if(cvObj.artemis_id__c!=null){
                artemisIdStr=cvObj.artemis_id__c+','+artemisIdStr;
            }
        }
        if(artemisIdStr=='')
        {
            return;
        }
        artemisIdStr=artemisIdStr.removeEnd(',');
        File_Producer_Event__e evt=new File_Producer_Event__e();
        evt.JSON_1__c= '{'+'\"artemis_ids\":'+'\"'+artemisIdStr+'\"'+'}';
        evt.put('Event_Notification_Name__c',ArtemisEMPUtility.getPETopicNameMetadata('File_Delete_Event'));
        evt.put('topic__c',ArtemisEMPUtility.getPETopicNameMetadata('File_Topic'));
        Database.SaveResult sveEvtResult  = EventBus.publish(evt);

    }
}