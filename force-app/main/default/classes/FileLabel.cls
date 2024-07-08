/*
* Author   : Ayush.k@maersk.com
* Purpose  : Modify the Content Document based on the File Type identified by IDA.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-7054     14-02-2023  Ayush Kumar             Created.
* 2.0 	   SC-7204	   16-03-2023  Ayush Kumar			   Changing the value of contentDocumentId key of the Request Body from Content Document Id to Content Version Id as IDA team will be passing Content Version Id as they donot have access to Content Document Id. Also to change the key of the request Body will require changing the whole swagger file and follow through the whole process hence keeping it the same.
*/

@RestResource(urlmapping = '/custom-content-documents')
global class FileLabel{
    
	public class OtherException extends Exception {}
    public static General_Key_Value_Configurations__mdt FileTypeList = General_Key_Value_Configurations__mdt.getInstance('DocumentTypeForDeletion');
    public static General_Key_Value_Configurations__mdt CaseRecordTypeList = General_Key_Value_Configurations__mdt.getInstance('CaseRecordTypeId');
    
    @HttpPost
    global static void doPost(){
        try{
            List<Id> lstIdDeletion = new List<Id>();
            Map<Id,String> mapIdDeletion = new Map<Id,String>();
            Set<String> setIdFailed = new Set<String>();
            Map<Id,String> mapIdUpdation = new Map<Id,String>();
            Map<Id,Boolean> mapCdlWithCd = new Map<Id,Boolean>();
            Map<Id,Id> mapCdWithCle = new Map<Id,Id>();
            Map<Id,Id> mapCdWithCv = new Map<Id,Id>();
            List<Id> lstCdForUpdate = new List<Id>();
            Set<String> fileTypeSet = new Set<String>();
            List<String> lstIdIdentification = new List<String>();
            
            if(FileTypeList.First_Field_Value__c != null){
            	fileTypeSet.addAll(FileTypeList.First_Field_Value__c.split(';'));
            }
            
            if(FileTypeList.Second_Field_Value__c != null){
            	lstIdIdentification.addAll(FileTypeList.Second_Field_Value__c.split(';'));
            }
            
            Set<Id> setContntDocDeletion = new Set<Id>();
            List<ContentDocumentLink> lstCdlWithCd = new List<ContentDocumentLink>();
            
            RestRequest req = RestContext.request;
            blob body = req.requestBody;
            string requestbody = body.toString().trim();
            List<ContentDocumentObject> reqWrap = (List<ContentDocumentObject>) JSON.deserialize(requestbody.trim(),List<ContentDocumentObject>.class);
            
            RestResponse res = RestContext.response;
            
            for(ContentDocumentObject contntDocObj : reqWrap){
                if(!String.isEmpty(contntDocObj.contentDocumentId) && ((contntDocObj.contentDocumentId.length() == 15 || contntDocObj.contentDocumentId.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', contntDocObj.contentDocumentId) && contntDocObj.contentDocumentId.startsWith(lstIdIdentification[1]))){
                    if(String.isEmpty(contntDocObj.documentContentType)){
                        setIdFailed.add(contntDocObj.contentDocumentId);
                    }else if(!fileTypeSet.isEmpty() && fileTypeSet.contains(contntDocObj.documentContentType)){
                        mapIdDeletion.put(Id.valueOf(contntDocObj.contentDocumentId), contntDocObj.documentContentType);
                    }else{
                        mapIdUpdation.put(Id.valueOf(contntDocObj.contentDocumentId), contntDocObj.documentContentType);
                    }
                }else{
                    setIdFailed.add(contntDocObj.contentDocumentId);
                }
            }
            
            if(!mapIdDeletion.isEmpty()){
                
                Map<Id,ContentVersion> mapContntVrsn = new Map<Id,ContentVersion>([SELECT id,Document_Type__c,ContentDocumentid FROM ContentVersion where id IN :mapIdDeletion.keySet()]);
                for(Id contntVrsnId : mapContntVrsn.keySet()){
                    mapCdWithCv.put(Id.valueOf(mapContntVrsn.get(contntVrsnId).ContentDocumentid),contntVrsnId);
                }
                
                for(Id contntVrsnId : mapIdDeletion.keySet()){
                    setContntDocDeletion.add(mapContntVrsn.get(contntVrsnId).contentdocumentId);
                }
                
                if(!setContntDocDeletion.isEmpty()){
                    
                    lstCdlWithCd.addAll([SELECT linkedentityId,contentdocumentId FROM ContentDocumentLink where contentdocumentId IN :setContntDocDeletion]);
                
                for(ContentDocumentLink CdlWithCd : lstCdlWithCd){
                        String linkedEntityId = String.valueof(CdlWithCd.linkedentityId);
                        if(linkedEntityId.startsWithIgnoreCase(lstIdIdentification[0])){
                            mapCdWithCle.put(Id.valueof(linkedEntityId), Id.valueof(CdlWithCd.ContentDocumentId));
                        }else{
                            mapCdlWithCd.put(Id.valueof(CdlWithCd.ContentDocumentId),False);
                        }
                    }
                }
                
                Map<Id,EmailMessage> mapEmail = new Map<Id,EmailMessage>([SELECT id,parent.RecordTypeId FROM emailmessage WHERE id IN :mapCdWithCle.keySet()]);
                if(!mapCdWithCle.isEmpty()){
                    for(Id cseLnkdEntityId : mapCdWithCle.keySet() ) {
                    	if(mapEmail.get(cseLnkdEntityId).parent.RecordTypeId == CaseRecordTypeList.First_Field_Value__c || mapEmail.get(cseLnkdEntityId).parent.RecordTypeId == CaseRecordTypeList.Second_Field_Value__c){
							mapCdlWithCd.put(mapCdWithCle.get(cseLnkdEntityId),True);
                        }else{
                            mapCdlWithCd.put(mapCdWithCle.get(cseLnkdEntityId),False);
                        }
                    }
                }
                
                for(Id contntDocId : mapCdlWithCd.keySet()){
                    if(mapCdlWithCd.get(contntDocId)){
                        lstIdDeletion.add(Id.valueOf(contntDocId));
                    }else{
                       	mapIdUpdation.put(mapCdWithCv.get(contntDocId), mapIdDeletion.get(mapCdWithCv.get(contntDocId)));
                    }
                }

                TriggerExecutionController.skipAllTriggers(true);
                Database.DeleteResult[] DR_lstIdDeletion = Database.delete(lstIdDeletion,false);
                
                for(Database.DeleteResult DR_IdDeletion: DR_lstIdDeletion){
                    if(!DR_IdDeletion.isSuccess()){
                        setIdFailed.add(String.valueOf(DR_IdDeletion.getId()));
                    } 
                }
            }
            
            if(!mapIdUpdation.isEmpty()){
                
                Map<Id,ContentVersion> mapContntVrsn = new Map<Id,ContentVersion>([SELECT id,Document_Type__c,ContentDocumentid FROM ContentVersion where id IN :mapIdUpdation.keySet()]);
                for(Id contntVrsnId : mapContntVrsn.keySet()){
                    lstCdForUpdate.add(Id.valueOf(mapContntVrsn.get(contntVrsnId).ContentDocumentid));
                }
                
                List<ContentVersion> lstContntVrsn = new List<ContentVersion>([SELECT id,Document_Type__c,ContentDocumentid FROM ContentVersion where ContentDocumentid IN :lstCdForUpdate]);

                for(ContentVersion contntVrsn : lstContntVrsn){
                    contntVrsn.Document_Type__c = mapIdUpdation.get(contntVrsn.id);
                }
                
            	Database.SaveResult[] SR_lstcontntVrsn = Database.update(lstcontntVrsn,false);
                TriggerExecutionController.skipAllTriggers(false);
                
                for(Database.SaveResult SR_contntVrsn: SR_lstcontntVrsn){
                    if(!SR_contntVrsn.isSuccess()){
                        setIdFailed.add(String.valueOf(SR_contntVrsn.getId()));
                    } 	
                }
            }
            
            if(!setIdFailed.isEmpty()){
                res.statusCode = 400;
                res.responseBody = blob.valueOf(System.Label.FileLabelFailed+setIdFailed);
                throw new OtherException(System.Label.FileLabelException + setIdFailed );
            }else{
                res.responseBody = blob.valueOf(System.Label.FileLabelSuccessful);
            }
    
        }catch(Exception ex) {
            ErrorLogger.writeErrors('SFDC', 'ContentDocument', 'FileLabel.doPost', new list<Exception>{ex}); 
        }
    }
    
     public class ContentDocumentObject{
        public String contentDocumentId;
        public String documentContentType;
    }

}