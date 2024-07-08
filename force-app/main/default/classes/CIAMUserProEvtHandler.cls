/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      SFMC-7692   27-May-2024 Ranjan@maersk           Created
*/
public without sharing class CIAMUserProEvtHandler {
    Public static void createEngageTrck(List<CIAM_User_Profile_Event__e> ciamEvtList){
        List<Engagement_Tracker__c> etUpsertList=new List<Engagement_Tracker__c>();
        List<Engagement_Tracker__c> etUpdateList=new List<Engagement_Tracker__c>();
        Set<String> userIdSet=new Set<String>();
        Map<String,String> ciamCriteriaMap=SoftRegistrationUtility.fetchSFMCKeyValueMap('Event Consumption Criteria');
        for(CIAM_User_Profile_Event__e ciamevtObj:ciamEvtList){
            Engagement_Tracker__c engTrackObj=SoftRegistrationUtility.parse(ciamevtObj.Json_1__c);
            if(engTrackObj==null){continue;}
            if(ciamCriteriaMap.get('IsUpdatableOnly'.toLowerCase()).contains(engTrackObj.Registration_Status__c)){
                etUpdateList.add(engTrackObj);
                userIdSet.add(engTrackObj.Forgerock_UserId__c);
                continue;
            }
            etUpsertList.add(engTrackObj);
        }
        if(!etUpsertList.isEmpty()){
            upsert etUpsertList Forgerock_UserId__c;
        }
        if(etUpdateList.isEmpty()){return;}
        List<Engagement_Tracker__c> etTempList=[Select id,Forgerock_UserId__c from Engagement_Tracker__c where Forgerock_UserId__c in:userIdSet];
        userIdSet.clear();
        for (Engagement_Tracker__c etTempObj : etTempList) {
            userIdSet.add(etTempObj.Forgerock_UserId__c);
        }
        List<Engagement_Tracker__c> etToUpdateList=new List<Engagement_Tracker__c>();
        for(Engagement_Tracker__c etTempObj : etUpdateList){
            if(!userIdSet.contains(etTempObj.Forgerock_UserId__c)){continue;}
            etToUpdateList.add(etTempObj);
        }
        if(!etToUpdateList.isEmpty()){
            upsert etToUpdateList Forgerock_UserId__c;
        }
   }
}