public with sharing class SingleRelatedListCtrl {
    public class ResponseWrapper{
        @AuraEnabled
        public List < SObject > listRecords;
    }
    @AuraEnabled( cacheable=true ) 
    public static ResponseWrapper fetchInitData(Id recId,String fieldList){
        ResponseWrapper resWrapperObj=new ResponseWrapper();
        List<String> fieldStrList= fieldList.split(';');
        String selectStr='Select id';
        for(String fieldObj:fieldStrList){
            selectStr=selectStr+', '+fieldObj;
        }

        String query='';
        List<ContentDocumentLink> contentDocList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recId];
        if(contentDocList.isEmpty()){
            resWrapperObj.listRecords=new List<ContentDocument>();
            return resWrapperObj;
        }
        Set <Id> contentDocId = new Set <Id> ();
        for (ContentDocumentLink cdObj : contentDocList) {
            contentDocId.add(cdObj.ContentDocumentId); 
        }        
        query=selectStr+' From ContentDocument where Id IN :contentDocId';
        resWrapperObj.listRecords=Database.query(query);
        return resWrapperObj;
    }
       
}