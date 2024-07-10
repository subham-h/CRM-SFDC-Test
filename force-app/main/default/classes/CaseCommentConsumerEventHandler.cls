public without sharing class CaseCommentConsumerEventHandler {
    public class CaseCommentWrapper{
        String sf_case_comment_id;
        String case_comment_external_id;
        public CaseCommentWrapper(String sf_case_comment_id,String case_comment_external_id){
            this.case_comment_external_id=case_comment_external_id;
            this.sf_case_comment_id=sf_case_comment_id;
        }
    }
    public class CaseComWrapper{
        String sf_case_comment_id;
        String sf_owner_name;
        String sf_owner_email;
        String artemis_case_id;
        String comment_body;
        String last_modified_date;
        String creation_date;
        public CaseComWrapper(String sf_case_comment_id,
                                  String sf_owner_name,
                                  String sf_owner_email,
                                  String artemis_case_id,
                                  String comment_body,
                                  String last_modified_date,
                                  String creation_date)
        {
            this.sf_case_comment_id=sf_case_comment_id;
            this.sf_owner_name=sf_owner_name;
            this.sf_owner_email=sf_owner_email;
            this.artemis_case_id=artemis_case_id;
            this.comment_body=comment_body;
            this.last_modified_date=last_modified_date;
            this.creation_date=creation_date;
        }
    }

    public static void createSFcomments(List<Case_Comment_Consumer_Event__e> newList) {
        List<Map<String, Object>> artemisCseComList=new List<Map<String, Object>> ();
        for(Case_Comment_Consumer_Event__e	cseComConsumerEvObj:newList){
            String responseStr=cseComConsumerEvObj.Json_1__c+(cseComConsumerEvObj.Json_2__c!=null?cseComConsumerEvObj.Json_2__c:'');
            Map<String, Object> objMap=(Map<String, Object>)JSON.deserializeUntyped(responseStr);
            artemisCseComList.add(objMap);
        }
        Map<String,String> fieldFromToMap=ArtemisEMPUtility.getPtEvtMetadata('Case Comment Consumer');
        Map<String,CaseComment> cseComToUpsert=new Map<String,CaseComment>();
        Boolean sendSfIdBack=false;
        Set<String> strArtIdSet=new Set<String>();
        for(Map<String, Object> obj:artemisCseComList){
            Map<String, Object> row = (Map<String, Object>)obj.get('message');
            CaseComment cseComObj=new CaseComment();
            if(row.containsKey('sf_case_comment_id') &&
             (((String)Json.deserialize('"'+row.get('sf_case_comment_id')+'"', String.class)).equalsIgnoreCase('null')||
             ((String)Json.deserialize('"'+row.get('sf_case_comment_id')+'"', String.class)).equalsIgnoreCase(''))==false)
            {
                row.remove('sf_parent_case_comment_id');
            }else{
                sendSfIdBack=true;
            }
            for(String keyStr:row.keySet()){
                if(!fieldFromToMap.containsKey(keyStr)){continue;}
                if((fieldFromToMap.get(keyStr).equalsIgnoreCase('id')&&row.get(keyStr)!='')||!fieldFromToMap.get(keyStr).equalsIgnoreCase('id')){
                    cseComObj.put(fieldFromToMap.get(keyStr), ArtemisEMPUtility.formatValue('CaseComment',fieldFromToMap.get(keyStr),row.get(keyStr)));
                }
            }
            String artemisIdStr=(String)Json.deserialize('"'+row.get('case_comment_external_id')+'"', String.class);
            cseComToUpsert.put(artemisIdStr,cseComObj);
            if(sendSfIdBack){
                strArtIdSet.add(artemisIdStr);
            }
        }
        TriggerExecutionController.skipAllTriggers(true);
        Database.UpsertResult[] cseComUpsertResList=Database.upsert(cseComToUpsert.values(),false);
        ErrorLogger.writeErrors('SFDC', 'Case_Comment_Consumer_Event__e', 'CaseCommentConsumerEventHandler.createSFcomments', cseComUpsertResList, cseComToUpsert.values());
        TriggerExecutionController.skipAllTriggers(false);
        if(strArtIdSet.isEmpty()){
            return;
        }
        List<CaseCommentWrapper> cseCommentWrpList=new List<CaseCommentWrapper>();
        for(String strSetId:strArtIdSet){
            CaseCommentConsumerEventHandler.CaseCommentWrapper wrpCseCommObj=new CaseCommentConsumerEventHandler.CaseCommentWrapper(String.valueOf(cseComToUpsert.get(strSetId).id),strSetId);
            cseCommentWrpList.add(wrpCseCommObj);
        }
        ArtemisEMPUtility.produceEvent(cseCommentWrpList,'CaseComment_Update_Event','CaseComment_Topic','Case_Comment_Producer_Event__e');
        
    }
}