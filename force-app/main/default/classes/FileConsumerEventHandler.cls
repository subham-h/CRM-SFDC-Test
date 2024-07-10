public without sharing class FileConsumerEventHandler {
    public static void updateFile(List<File_Consumer_Event__e> newList) {
        List<Map<String, Object>> artemisFileList=new List<Map<String, Object>> ();
        for(File_Consumer_Event__e fileConsumerEvObj:newList){
            String responseStr=fileConsumerEvObj.Json_1__c+(fileConsumerEvObj.Json_2__c!=null?fileConsumerEvObj.Json_2__c:'');
            Map<String, Object> objMap=(Map<String, Object>)JSON.deserializeUntyped(responseStr);
            artemisFileList.add(objMap);
        }
        Map<String,String> fieldFromToMap=ArtemisEMPUtility.getPtEvtMetadata('File Consumer');
        Map<String,ContentVersion> fileToUpsertMap=new Map<String,ContentVersion>();
        List<ContentDocument> contentDocToDelete=new List<ContentDocument>();
        Set<id> contentDocId=new Set<id>();
        for(Map<String, Object> obj:artemisFileList){
            Map<String, Object> row = (Map<String, Object>)obj.get('message');//header
            
            String eventNotificationNameStr=(String)Json.deserialize('"'+obj.get('eventNotificationName')+'"', String.class);
            if(eventNotificationNameStr.contains('insert') ||eventNotificationNameStr.contains('update')){
                ContentVersion fileObj=new ContentVersion();
                for(String keyStr:row.keySet()){
                    if(!fieldFromToMap.containsKey(keyStr)){continue;}
                    fileObj.put(fieldFromToMap.get(keyStr), ArtemisEMPUtility.formatValue('ContentVersion',fieldFromToMap.get(keyStr),row.get(keyStr)));
                }
                fileToUpsertMap.put((String)Json.deserialize('"'+row.get('sf_content_version_id')+'"', String.class),fileObj);
            }else if(eventNotificationNameStr.contains('delete')){
                ContentDocument fileObj=new ContentDocument();
                fileObj.id=(String)Json.deserialize('"'+row.get('sf_content_document_id')+'"', String.class);
                contentDocToDelete.add(fileObj);
            }
        }
        if(!contentDocToDelete.isEmpty()){
            Database.delete(contentDocToDelete);
        }
        if(!fileToUpsertMap.isEmpty()){
            Database.UpsertResult[] fileUpsertResList=Database.upsert(fileToUpsertMap.values(),false);
            ErrorLogger.writeErrors('SFDC', 'File_Consumer_Event__e', 'FileConsumerEventHandler.updateFile', fileUpsertResList, fileToUpsertMap.values());
        }  
    }
}