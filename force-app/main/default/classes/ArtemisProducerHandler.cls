public with sharing class ArtemisProducerHandler {
    

    public class Requests {
        @InvocableVariable
        public sObject sObjRq;
        @InvocableVariable
        public string child_object_field1; 
        @InvocableVariable
        public string child_object_field2;
        @InvocableVariable
        public string child_object_field3;
        @InvocableVariable
        public string child_object_field4; 
        @InvocableVariable
        public string child_object_field5;
        @InvocableVariable
        public string child_object_field6;
        @InvocableVariable
        public string child_object_field7; 
        @InvocableVariable
        public string child_object_field8;
        @InvocableVariable
        public string child_object_field9;
        @InvocableVariable
        public string sobjectName;
        @InvocableVariable
        public String flag;
    }
    
    public class Results {

        @InvocableVariable
        public String serializedJSON1;
        @InvocableVariable
        public String serializedJSON2;
        @InvocableVariable
        public String serializedJSON3;
        @InvocableVariable
        public String serializedJSON4;
        @invocableVariable
        public String flag;
        
        public Results(){
            serializedJSON1 = '';
            serializedJSON2 = '';
            serializedJSON3 = '';
            serializedJSON4 = '';
            flag        = '';
        }
       
    }


    @InvocableMethod
    public static List <Results> preparePERecord (List<Requests> requestList) {

        List<Results> responses = new List<Results>();
        Map<String, String> fieldToFromMap = getArchivalMetadata(requestList[0].sObjectName);
        //get metadata map
        Map<String, Map<String, String>> childObjectFieldsMap = new Map<String, Map<String, String>>();
       
        For(Artemis_PE_Object_Config__mdt response : [SELECT Id, MasterLabel, DeveloperName, From_Field__c, To_Field__c, SObject__c FROM Artemis_PE_Object_Config__mdt WHERE DeveloperName Like '%ArtemisProducerChildFields%']){
            
            if(childObjectFieldsMap.containsKey(response.SObject__c)){
                
                childObjectFieldsMap.get(response.SObject__c).put(response.From_Field__c,response.To_Field__c);
            }else{
                
                childObjectFieldsMap.put(response.SObject__c, new Map<String, String>{response.From_Field__c =>response.To_Field__c});
            }
        }
        //for map of case field, metadata field
        SObjectType thisSObject;
        sobject genericObject;
        Map<String, String> peRecord ;
        String thisTempSObject;
        for(Requests re:requestList){
             peRecord = new Map<String, String>();

             Map<String, Object> row = (Map<String, Object>) JSON.deserializeUntyped(Json.serialize(re.sObjRq));
             thisTempSObject = String.valueOf(re.sObjRq.getSobjectType());
             Map<String, String> rowSObjectMap = new Map<String, String>(); 
            
            for(String rowTemp : row.keySet()){
                
                rowSObjectMap.put(rowTemp.toLowerCase(), row.get(rowTemp) != null ? String.valueOf(row.get(rowTemp)) : '');
            }
  
            for(String keyStr : fieldToFromMap.keySet()){
                //Thread_token needs to be sent for Case object via EmailMessages.getFormattedThreadingToken function.
                if(keyStr!=null && fieldToFromMap.get(keyStr) != null && fieldToFromMap.get(keyStr) == 'thread_token'){
                   peRecord.put(fieldToFromMap.get(keyStr), EmailMessages.getFormattedThreadingToken(rowSObjectMap.get('id')));
                }
               else if(keyStr!=null && fieldToFromMap.get(keyStr) != null ){
                   peRecord.put(fieldToFromMap.get(keyStr), rowSObjectMap.containsKey(keyStr) ? rowSObjectMap.get(keyStr) : '');
                }
            }
             //populating extra child object fields to send to artemis based on metadata 
          if(re.child_object_field1 != null || re.child_object_field2 != null ||re.child_object_field3 != null ||re.child_object_field4 != null ||re.child_object_field5 != null ||re.child_object_field6 != null ||re.child_object_field7 != null ||re.child_object_field8 != null ||re.child_object_field9 != null ){
            if(childObjectFieldsMap.containsKey(thisTempSObject) && childObjectFieldsMap.get(thisTempSObject).keySet()!= null){
                for( String tempField : childObjectFieldsMap.get(thisTempSObject).keySet()){
                    String tempChildFieldValue = tempField.equalsIgnoreCase('child_object_field1') ? re.child_object_field1 : (tempField.equalsIgnoreCase('child_object_field2') ? re.child_object_field2 : (tempField.equalsIgnoreCase('child_object_field3') ? re.child_object_field3 :  (tempField.equalsIgnoreCase('child_object_field4') ? re.child_object_field4 :  (tempField.equalsIgnoreCase('child_object_field5') ? re.child_object_field5 :  (tempField.equalsIgnoreCase('child_object_field6') ? re.child_object_field6 :  (tempField.equalsIgnoreCase('child_object_field7') ? re.child_object_field7 : (tempField.equalsIgnoreCase('child_object_field8') ? re.child_object_field8 : (tempField.equalsIgnoreCase('child_object_field9') ? re.child_object_field9 : ''))))))));

                   peRecord.put(childObjectFieldsMap.get(thisTempSObject).get(tempField),tempChildFieldValue);
                }
             }
          }
            thisSObject = ((SObject) Type.forName(String.valueOf(re.sObjectName)).newInstance()).getSObjectType();   
            genericObject = thisSObject.newSObject();
            
            //Convert Map to JSON string replace
            String strJson = '{';
            for(string temp: peRecord.keySet()){
                
                strJson  = strJson + '"'+temp+'":'+JSON.serialize(peRecord.get(temp).replaceAll('"','\"'))+',';

            }
            strjson  = strJson.removeEnd(',') + '}';

            String tempString = String.valueOf(strjson);
            Integer sliceBy = 130000;       
    
            Integer countinstance = tempString.length();
           for(integer counter=0;countinstance>(sliceBy*counter);counter++){
                if(countinstance>sliceBy*counter && countinstance<sliceBy*(counter+1)){
                    genericObject.put('Json_'+(counter+1)+'__c',tempString.substring(sliceBy*(counter),countinstance));
                }else{
                    genericObject.put('Json_'+(counter+1)+'__c',tempString.substring(sliceBy*(counter),sliceBy*(counter+1)));
                }

           }
            Results res = new Results();
            if(genericObject.get('Json_1__c')!=null){
                res.serializedJSON1 = String.valueOf(genericObject.get('Json_1__c'));
            }
            if(genericObject.get('Json_2__c')!=null){
                res.serializedJSON2 = String.valueOf(genericObject.get('Json_2__c'));

            }       
            if(genericObject.get('Json_3__c')!=null){
                res.serializedJSON3 = String.valueOf(genericObject.get('Json_3__c'));

            }       
            if(genericObject.get('Json_4__c')!=null){
                res.serializedJSON4 =String.valueOf(genericObject.get('Json_4__c'));

            }
            if(re.flag != null || re.flag!= '')
                res.flag = re.flag;
            responses.add(res);
        }

        return responses;
    }

     // utility method for fetching archival connectivity metadata
     public static Map<String,Map<String,String>> ptEvtMetadataMap=new  Map<String,Map<String,String>>();
     public static Map<String,String> getArchivalMetadata(string evtName){
         if(!ptEvtMetadataMap.containsKey(evtName)){
             List<Artemis_PE_Object_Config__mdt> evtPEList=[select Platform_Event__c,Is_Parent_Field__c, Is_Updatable__c, SObject__c, From_Field__c,To_Field__c from Artemis_PE_Object_Config__mdt where Platform_Event__c =: evtName AND Is_Parent_Field__c = False];
             Map<String,String> fieldToFromMap= new Map<String,String>();
             for(Artemis_PE_Object_Config__mdt peMetaObj:evtPEList){
                 fieldToFromMap.put(peMetaObj.From_Field__c.toLowerCase(),peMetaObj.To_Field__c.toLowerCase());
             }
             ptEvtMetadataMap.put(evtName,fieldToFromMap);
         }
         return ptEvtMetadataMap.get(evtName);
     }

    //method to convert saperate fields Json 1, Json 2, .. into serialized string
     public static String getSerializedPeObject(sObject peRecord, String sObjectName){
          
         SObjectType thisSObject = ((SObject) Type.forName(String.valueOf(sObjectName)).newInstance()).getSObjectType();   
         sobject genericObject = thisSObject.newSObject();
         genericObject = peRecord;
                  
         String serializedString;
         String serializedSObjectString = '';

         if(genericObject.get('JSON_1__c') != null && genericObject.get('JSON_1__c') != '')
            serializedString = (String)genericObject.get('Json_1__c');
         if(genericObject.get('Json_2__c') != '' && genericObject.get('Json_2__c') != null)
            serializedString = serializedString + genericObject.get('Json_2__c');
         if(genericObject.get('Json_3__c') != '' && genericObject.get('Json_3__c') != null)
            serializedString = serializedString + genericObject.get('Json_3__c');
         if(genericObject.get('Json_4__c') != '' && genericObject.get('Json_4__c') != null)
            serializedString = serializedString + genericObject.get('Json_4__c');
         
        Map<String, String> serializedMap = new Map<String, String>();

         String serializedFString =serializedString;//.endsWith('"}')?serializedString:serializedString+'"}';

        ArtemisProducerHandler.ProducerEventWrapper finalmsg = new ArtemisProducerHandler.ProducerEventWrapper(ArtemisProducerHandler.getheaderWrapper((String)genericObject.get('EventUuid'),(string)genericObject.get('Event_Notification_Name__c')), serializedFString ,(string)genericObject.get('topic__c'));
        if(finalmsg.message !=null) {
            serializedSObjectString = JSON.serialize(finalmsg);
            serializedSObjectString = serializedSObjectString.replace('#JSON#', serializedFString);
        }           
       
         return serializedSObjectString;
    }
     
   
    public class ProducerEventWrapper {
        public header header;
        public String message;
        public string topic;
        
        public ProducerEventWrapper(header header, string message, string topic) {
            this.header = header;
            this.message = '#JSON#';
            this.topic = topic;
        }
    }
    
      public class header{
        public string eventNotificationName;
        public string version;
        public string systemName;
        public string messageId;
        public long eventTimestamp;
        public header(){
            eventNotificationName = '';
            version = '';
            systemName = '';
            messageId = '';
            eventTimestamp = 0;
        }
    }
    
    public Static header getheaderWrapper(String evtId, String evtNotificationName){
        Datetime dt = Datetime.now();
        header pRec = new header();
        pRec.eventNotificationName = evtNotificationName;
        pRec.version = '1.0.0';
        pRec.systemName = 'sfdc';
        pRec.messageId = evtId !=null ? evtId : String.valueOf(math.random());
        pRec.eventTimestamp = dt.getTime()/1000;
        return pRec;
    }
    

}