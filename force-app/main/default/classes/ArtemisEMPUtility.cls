public without sharing class ArtemisEMPUtility {
    // utility method for fetching archival connectivity metadata
    public static Map<String,Map<String,String>> ptEvtMetadataMap=new  Map<String,Map<String,String>>();
    public static Map<String,String> getPtEvtMetadata(string evtName){
        if(!ptEvtMetadataMap.containsKey(evtName)){
            List<Artemis_PE_Object_Config__mdt> evtPEList=[select Platform_Event__c,From_Field__c,To_Field__c from Artemis_PE_Object_Config__mdt where Platform_Event__c =: evtName];
            Map<String,String> fieldFromToMap= new Map<String,String>();
            for(Artemis_PE_Object_Config__mdt peMetaObj:evtPEList){
                fieldFromToMap.put(peMetaObj.From_Field__c.toLowerCase(),peMetaObj.To_Field__c);
            }
            ptEvtMetadataMap.put(evtName,fieldFromToMap);
        }
        return ptEvtMetadataMap.get(evtName);
    }
    public static Map<String,String> topicDevNameValueMap=new Map<String,String>();
    public static String getPETopicNameMetadata(string topicDevName){
        if(!topicDevNameValueMap.containsKey(topicDevName)){
            List<Producer_Platform_Event_Config__mdt> topicPEList=[select DeveloperName,Topic_Name__c from Producer_Platform_Event_Config__mdt];
            for(Producer_Platform_Event_Config__mdt peMetaObj:topicPEList){
                topicDevNameValueMap.put(peMetaObj.DeveloperName,peMetaObj.Topic_Name__c);
            }
        }
        return topicDevNameValueMap.get(topicDevName);
    }
    public static Map<String,Map<String,String>> fieldDataTypeMappings=new Map<String,Map<String,String>>();
    public static object formatValue(String objectName,String fieldApiName,Object fieldValue){
        Object formattedFieldValue=null;
        if((''+fieldValue+'').equalsIgnoreCase('null')){
            return formattedFieldValue;
        }
        if(!fieldDataTypeMappings.containsKey(objectName)){
            fieldDataTypeMappings.put(objectName,EMPConsumerHandler.getFieldDataType(objectName));
        }
        Map<String,String> fieldDataTypeMap=fieldDataTypeMappings.get(objectName);
        if(fieldDataTypeMap.containsKey(fieldApiName) && fieldDataTypeMap.get(fieldApiName).Contains('Number') ){
            formattedFieldValue=(Decimal)Json.deserialize('"'+fieldValue+'"', Decimal.class);
        }else if(fieldDataTypeMap.containsKey(fieldApiName) && fieldDataTypeMap.get(fieldApiName) == 'Checkbox' ){
            formattedFieldValue=(Boolean)Json.deserialize('"'+fieldValue+'"', Boolean.class);//Boolean.valueof(ArtemisEMPUtility.getBooleanValue((String)fieldValue));
        }else if(fieldDataTypeMap.containsKey(fieldApiName) && fieldDataTypeMap.get(fieldApiName) == 'Date/Time' ){
            formattedFieldValue=ArtemisEMPUtility.getDateTimeValue((String)fieldValue);
        }else{
            formattedFieldValue=''+fieldValue+'';
        }
            
        return formattedFieldValue;
    }
    public static Boolean getBooleanValue(String value){
        Boolean booleanValue =false;
        if(value == 'N' || value == 'n' || value == 'No' || value == 'NO' || value == 'InActive' || value == 'INACTIVE' || value == 'false' || value == 'FALSE')
            booleanValue = false;
        else if(value == 'Y' || value == 'y' || value == 'Yes' || value == 'YES' || value == 'Active' || value == 'ACTIVE' || value == 'true' || value == 'TRUE')
            booleanValue = true;
            
        return booleanValue;
        
    }
    /* */
    public static Batch_Error_Logger__c createInfoErrRec(String name,String summary,String exceptionDetail,String opType,String batchName)
    {
        Batch_Error_Logger__c infoObj=new Batch_Error_Logger__c ();
        infoObj.Name =name;
        infoObj.Operation_Type__c =opType;
        infoObj.Exception_Summary__c = summary;
        infoObj.Batch_Name__c =batchName;
        infoObj.Exception_Detail__c=exceptionDetail;
        return infoObj;
    }
    Public static void processUpsertResults(List<Database.UpsertResult> upsertResList){
        List<Batch_Error_Logger__c> errorLogInsertList=new List<Batch_Error_Logger__c>();
        for(Database.UpsertResult csUpsertObj :upsertResList){
            if(!csUpsertObj.isSuccess()){
                String upsertFail='Id: '+csUpsertObj.getId()+'Reason: '+csUpsertObj.getErrors()+';';
                errorLogInsertList.add(ArtemisEMPUtility.createInfoErrRec('CaseEMPSaveError','Error While saving the Case record from Case Consumer PE',upsertFail,'Execution Error','CaseConsumerEventHandler'));
            }
        }
        if(!errorLogInsertList.isEmpty()){
            Database.insert(errorLogInsertList,false);
        }
    }
    public static DateTime getDateTimeValue(String value){
        DateTime dt;
        dt=(DateTime)Json.deserialize('"'+value+'"', DateTime.class);
        return dt;
        
    }

    public static Date getDateValue(String value){
        Date dt;

        return dt;
        
    }
    public static FileProducerEventHandler.fileWrapper createFileWrapper(Map<id,List<String>> conDocIdConverIdMap,ContentDocumentLink cdlObj,String artemisId,String typeEmailorCase){
        FileProducerEventHandler.fileWrapper fileWrapObj=null;
        if('Email'.equalsIgnoreCase(typeEmailorCase)){
            fileWrapObj=new FileProducerEventHandler.fileWrapper(String.valueof(cdlObj.ContentDocumentId),
                                                        conDocIdConverIdMap.get(cdlObj.ContentDocumentId)[0],
                                                        '',artemisId,
                                                        '',
                                                        cdlObj.ContentDocument.title,
                                                        conDocIdConverIdMap.get(cdlObj.ContentDocumentId)[1],
                                                        cdlObj.Id,
                                                        cdlObj.ContentDocument.FileExtension,
                                                        conDocIdConverIdMap.get(cdlObj.ContentDocumentId)[2],
                                                        cdlObj.contentdocument.CreatedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX'));
                                                        
                                                        // cdlObj.contentdocument.LastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX'));
        }else{
            fileWrapObj=new FileProducerEventHandler.fileWrapper(String.valueof(cdlObj.ContentDocumentId),
                                                        conDocIdConverIdMap.get(cdlObj.ContentDocumentId)[0],
                                                        '','',
                                                        artemisId,
                                                        cdlObj.ContentDocument.title,
                                                        conDocIdConverIdMap.get(cdlObj.ContentDocumentId)[1],
                                                        cdlObj.Id,
                                                        cdlObj.ContentDocument.FileExtension,
                                                        conDocIdConverIdMap.get(cdlObj.ContentDocumentId)[2],
                                                        cdlObj.contentdocument.CreatedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX'));
                                                        
                                                        // cdlObj.contentdocument.LastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX'));

        }
        return fileWrapObj;
    }
    public static void produceFileEvent(List<FileProducerEventHandler.fileWrapper> fileWrapperList){
        List<File_Producer_Event__e> fileEvtList=new List<File_Producer_Event__e>();
        for (FileProducerEventHandler.fileWrapper fileWrap : fileWrapperList) {
            File_Producer_Event__e evt=new File_Producer_Event__e();
            evt.JSON_1__c= JSON.serialize(fileWrap);
            evt.Event_Notification_Name__c='com.file.insert';
            evt.topic__c=getPETopicNameMetadata('File_Topic');
            fileEvtList.add(evt);
            
        }
        List<Database.SaveResult> sveEvtResults  = EventBus.publish(fileEvtList);
    }
    public static void produceEvent(List<Object> objList,String notificationName,String topic,String objectName){
        SObjectType thisSObject = ((SObject) Type.forName(String.valueOf(objectName)).newInstance()).getSObjectType();    
        List<sObject> evtList=new List<sObject>();
        System.Type objType = Type.forName(objectName);
        for (Object wrapObj : objList) {
            sobject evt = thisSObject.newSObject();
            evt.put('JSON_1__c',JSON.serialize(wrapObj));
            evt.put('Event_Notification_Name__c',getPETopicNameMetadata(notificationName));
            evt.put('topic__c',getPETopicNameMetadata(topic));
            evtList.add(evt);
            
        }
        List<Database.SaveResult> sveEvtResults  = EventBus.publish(evtList);
    }
    public static void createChildFileEvent(Map<Id,String> idArtemisIdMap,String typeEmailorCase){
        List<ContentDocumentLink> conDocList=[ select Id,
                                                        contentdocument.CreatedDate, 
                                                        ContentDocument.title, 
                                                        ContentDocument.FileExtension ,
                                                        LinkedEntityId, 
                                                        LinkedEntity.type, 
                                                        ContentDocumentId 
                                                        from ContentDocumentLink 
                                                        where LinkedEntityId in:idArtemisIdMap.keySet()];
                                                        
        Map<id,ContentDocumentLink> conDocIdMap=new Map<id,ContentDocumentLink>();
        for(ContentDocumentLink conLinkObj:conDocList){
            conDocIdMap.put(conLinkObj.ContentDocumentId,conLinkObj);
        }
        List<ContentVersion> conVerList;
        if(!conDocIdMap.isEmpty()){
            conVerList=[select id,
                                ContentDocumentId,
                                Artemis_Id__c,
                                Checksum,
                                ContentSize 
                                from ContentVersion 
                                where ContentDocumentId =:conDocIdMap.keySet()];                         
        }
        List<FileProducerEventHandler.fileWrapper> fileWrapperList=new List<FileProducerEventHandler.fileWrapper>();
        if(conVerList!=null && !conVerList.isEmpty()){
            Map<id,List<String>> conDocIdConverIdMap=new Map<id,List<String>>();
            for ( ContentVersion cvObj : conVerList) {
                ContentDocumentLink cdlObj= conDocIdMap.get(cvObj.ContentDocumentId);
                List<String> tempList=new List<String>();
                tempList.add(cvObj.id);
                tempList.add(cvObj.Checksum);
                tempList.add(String.valueOf(cvObj.ContentSize));
                conDocIdConverIdMap.put(cvObj.ContentDocumentId,tempList);
                fileWrapperList.add(ArtemisEMPUtility.createFileWrapper(conDocIdConverIdMap,cdlObj,idArtemisIdMap.get(cdlObj.LinkedEntityId),typeEmailorCase));
            }
        }
        if(!fileWrapperList.isEmpty()){
            ArtemisEMPUtility.produceFileEvent(fileWrapperList);
        }
    }
    public static String createQuery(String peName,String objectName){
        String query='Select ';
        Set<String> fieldNameSet=ArtemisEMPUtility.getPtEvtMetadata(peName).keySet();
        for (String fieldName : fieldNameSet) {
            query=query+fieldName+',';
        }
        query=query.removeEnd(',');
        query=query+' From '+objectName;
        return query;
    }
    public static void produceEmailEvent(List<ArtemisProducerHandler.Results> resWrapperList){
        List<Email_Producer_Event__e> emailEvtList=new List<Email_Producer_Event__e>();
        for (ArtemisProducerHandler.Results resObj : resWrapperList) {
            Email_Producer_Event__e evt=new Email_Producer_Event__e();
            evt.JSON_1__c= resObj.serializedJSON1;
            evt.JSON_2__c= resObj.serializedJSON2;
            evt.JSON_3__c= resObj.serializedJSON3;
            evt.JSON_4__c= resObj.serializedJSON4;
            evt.Event_Notification_Name__c='com.email.insert';
            evt.topic__c=getPETopicNameMetadata('Email_Topic');
            emailEvtList.add(evt);
        }
        List<Database.SaveResult> sveEvtResults  = EventBus.publish(emailEvtList);

    }
    public static void produceSurEvent(List<ArtemisProducerHandler.Results> resWrapperList){
        List<Survey_Producer_Event__e> emailEvtList=new List<Survey_Producer_Event__e>();
        for (ArtemisProducerHandler.Results resObj : resWrapperList) {
            Survey_Producer_Event__e evt=new Survey_Producer_Event__e();
            evt.JSON_1__c= resObj.serializedJSON1;
            //evt.JSON_2__c= resObj.serializedJSON2;
            //evt.JSON_3__c= resObj.serializedJSON3;
            //evt.JSON_4__c= resObj.serializedJSON4;
            evt.Event_Notification_Name__c='com.survey.insert';
            evt.topic__c=getPETopicNameMetadata('Survey_Topic');
            emailEvtList.add(evt);
        }
        List<Database.SaveResult> sveEvtResults  = EventBus.publish(emailEvtList);

    }
    public static void createChildEmailEvent(Set<Id> caseIdSet){
        String query=ArtemisEMPUtility.createQuery('Email_Producer_Event__e','EmailMessage');
        query=query+' WHERE parentId IN ';
        query += ':caseIdSet';
        query+=' and Artemis_Id__c=null';
        List<EmailMessage> emailMessageList= Database.query(query);
        if(emailMessageList==null || emailMessageList.isEmpty()){
            return;
        }
        List<ArtemisProducerHandler.Results> resList=new List<ArtemisProducerHandler.Results>();
        for(EmailMessage emailObj:emailMessageList){
            ArtemisProducerHandler.Requests req=new ArtemisProducerHandler.Requests();
            req.sObjRq=emailObj;
            req.sobjectName='Email_Producer_Event__e';
            List<ArtemisProducerHandler.Requests> reqList=new List<ArtemisProducerHandler.Requests>();
            reqList.add(req);
            resList.addAll( ArtemisProducerHandler.preparePERecord(reqList));

        }
        ArtemisEMPUtility.produceEmailEvent(resList);
    }
    public static void createChildSurEvent(Set<Id> caseIdSet){
        String query=ArtemisEMPUtility.createQuery('Survey_Producer_Event__e','Survey__c');
        query=query+' WHERE Case__c IN ';
        query += ':caseIdSet';
        query+=' and Artemis_Id__c=null';
        List<Survey__c> surList= Database.query(query); 
        if(surList==null || surList.isEmpty()){
            return;
        }
        List<ArtemisProducerHandler.Results> resList=new List<ArtemisProducerHandler.Results>();
        for(Survey__c surObj:surList){
            ArtemisProducerHandler.Requests req=new ArtemisProducerHandler.Requests();
            req.sObjRq=surObj;
            req.sobjectName='Survey_Producer_Event__e';
            List<ArtemisProducerHandler.Requests> reqList=new List<ArtemisProducerHandler.Requests>();
            reqList.add(req);
            resList.addAll( ArtemisProducerHandler.preparePERecord(reqList));

        }
        ArtemisEMPUtility.produceSurEvent(resList);
    }
    public static void createChildCaseCommEvent(Set<Id> caseIdSet){
        String query=ArtemisEMPUtility.createQuery('Case_Comment_Producer_Event__e','CaseComment');
        query=query+' WHERE parentid IN ';
        query += ':caseIdSet';
        List<CaseComment> cseComList= Database.query(query); 
        if(cseComList==null || cseComList.isEmpty()){
            return;
        }
        List<CaseCommentConsumerEventHandler.CaseComWrapper> resList=new List<CaseCommentConsumerEventHandler.CaseComWrapper>();
        for(CaseComment ccObj:cseComList){
            CaseCommentConsumerEventHandler.CaseComWrapper wrapObj=new CaseCommentConsumerEventHandler.CaseComWrapper(
                String.valueof(ccObj.id),
                ccObj.parent.owner.firstname,
                ccObj.parent.owner.email,
                ccObj.parent.artemis_id__c,
                ccObj.commentbody,
                String.valueof(ccObj.lastmodifieddate),
                String.valueof(ccObj.createddate));
                resList.add(wrapObj);  
        }
        ArtemisEMPUtility.produceEvent(resList,'CaseComment_Insert_Event','CaseComment_Topic','Case_Comment_Producer_Event__e');
    }


}