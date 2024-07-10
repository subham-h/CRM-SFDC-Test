/**
 * 
 * @author Ranjan
 * @date 03/08/2023
 * @description Handler class to proces Email consumer platform event
 */
public without sharing class EmailConsumerEventHandler {
    
    /** 
    * @description | create Email Messages
    * @param newList accepts Email_Consumer_Event__e list
    */
    public static void createSFEmails(List<Email_Consumer_Event__e> newList) {
        List<Map<String, Object>> artemisEmailList=new List<Map<String, Object>>();
        for(Email_Consumer_Event__e emailConsumerEvObj : newList){
            String responseStr = emailConsumerEvObj.Json_1__c+(emailConsumerEvObj.Json_2__c != null ? emailConsumerEvObj.Json_2__c : '');
            Map<String, Object> objMap = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
            artemisEmailList.add(objMap);
        }
        Map<String,String> fieldFromToMap=ArtemisEMPUtility.getPtEvtMetadata('Email Consumer');
        List<EmailMessage> emailToUpsert=new List<EmailMessage>();
        for(Map<String, Object> obj:artemisEmailList){
            Map<String, Object> row = (Map<String, Object>)obj.get('message');
            EmailMessage emailObj=new EmailMessage();
            for(String keyStr:row.keySet()){
                if(!fieldFromToMap.containsKey(keyStr)){continue;}
                if((fieldFromToMap.get(keyStr).equalsIgnoreCase('id') && row.get(keyStr) != '') || !fieldFromToMap.get(keyStr).equalsIgnoreCase('id')){
                    emailObj.put(fieldFromToMap.get(keyStr), ArtemisEMPUtility.formatValue('EmailMessage', fieldFromToMap.get(keyStr), row.get(keyStr)));
                }
            }
            emailToUpsert.add(emailObj);
        }
        TriggerExecutionController.skipAllTriggers(true);
        Database.UpsertResult[] emailUpsertResList = Database.upsert(emailToUpsert,false);
        TriggerExecutionController.skipAllTriggers(false);
        ErrorLogger.writeErrors('SFDC', 'Email_Consumer_Event__e', 'EmailConsumerEventHandler.createSFEmails', emailUpsertResList, emailToUpsert);
        Map<id,String> emailIdArtemisMap=new Map<id,String>();
        for(EmailMessage emailObj : emailToUpsert){
            emailIdArtemisMap.put(emailObj.Id, emailObj.Artemis_Id__c);
        }
        ArtemisEMPUtility.createChildFileEvent(emailIdArtemisMap,'Email');
    }
}