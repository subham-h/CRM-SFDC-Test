public without sharing class SurveyConsumerEventHandler {
    public static void createSFSurveys(List<Survey_Consumer_Event__e> newList) {
        List<Map<String, Object>> artemisSurveyList=new List<Map<String, Object>> ();
        for(Survey_Consumer_Event__e emailConsumerEvObj:newList){
            String responseStr=emailConsumerEvObj.Json_1__c+(emailConsumerEvObj.Json_2__c!=null?emailConsumerEvObj.Json_2__c:'');
            Map<String, Object> objMap=(Map<String, Object>)JSON.deserializeUntyped(responseStr);
            artemisSurveyList.add(objMap);
        }
        Map<String,String> fieldFromToMap=ArtemisEMPUtility.getPtEvtMetadata('Survey Consumer');
        List<Survey__c> surveyToUpsert=new List<Survey__c>();
        for(Map<String, Object> obj:artemisSurveyList){
            Map<String, Object> row = (Map<String, Object>)obj.get('message');
            Survey__c surveyObj=new Survey__c();
            for(String keyStr:row.keySet()){
                if(!fieldFromToMap.containsKey(keyStr)){continue;}
                if((fieldFromToMap.get(keyStr).equalsIgnoreCase('id')&&row.get(keyStr)!='')||!fieldFromToMap.get(keyStr).equalsIgnoreCase('id')){
                surveyObj.put(fieldFromToMap.get(keyStr), ArtemisEMPUtility.formatValue('Survey__c',fieldFromToMap.get(keyStr),row.get(keyStr)));
                }
            }
            surveyObj.put('recordtypeid',Schema.SObjectType.Survey__c.getRecordTypeInfosByName().get('Case Survey').getRecordTypeId());
            surveyToUpsert.add(surveyObj);
        }
        Database.UpsertResult[] surveyUpsertResList=Database.upsert(surveyToUpsert,false);
        ErrorLogger.writeErrors('SFDC', 'Survey_Consumer_Event__e', 'SurveyConsumerEventHandler.createSFSurveys', surveyUpsertResList, surveyToUpsert);
    }
}