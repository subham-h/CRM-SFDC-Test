public class ExtDataSourceUtility {
    /**
*   Helper method to make the HTTP GET call.
*   The url argument is the URL of the external system.
*   Returns the response from the external system.
**/
    public static HttpResponse getResponse(String url,String method,String input,String metadataName) {
        
        // Perform callouts for production (non-test) results.
        Archival_Config__mdt mdtObj = EmailArchivalDataSourceConnection.getArchivalMetadata(metadataName);//'Email Archival'
        string jwtToken = WebserviceUtilities.getJWTBearer(mdtObj.Certificate_Name__c,mdtObj.Role__c,mdtObj.Audience__c);
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndPoint(url);
        request.setMethod(method);
        request.setTimeout(120000);
        Boolean isSandBox = [SELECT Id, IsSandbox FROM Organization].IsSandbox;
        if(!isSandBox && !Test.isRunningTest()){
            request.setHeader('Authorization', 'Bearer '+jwtToken);  
        }
        if(method.equals('POST')){
            request.setHeader('Content-Type', 'application/json; charset=utf-8'); 
            request.setBody(input);
        }
        HttpResponse response = httpProtocol.send(request);
        return response;
        
    }
    
    public static HttpResponse getResponse(String method,String input,String metadataName) {        
        // Perform callouts for production (non-test) results.
        Archival_Config__mdt mdtObj = EmailArchivalDataSourceConnection.getArchivalMetadata(metadataName);//'Email Archival'
        string jwtToken = WebserviceUtilities.getJWTBearer(mdtObj.Certificate_Name__c,mdtObj.Role__c,mdtObj.Audience__c);
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndPoint(mdtObj.End_point_URL__c);
        request.setMethod(method);
        request.setTimeout(120000);
        Boolean isSandBox = [SELECT Id, IsSandbox FROM Organization].IsSandbox;
        if(!isSandBox && !Test.isRunningTest()){
            request.setHeader('Authorization', 'Bearer '+jwtToken);  
        }
        if(method.equals('POST')){
            request.setHeader('Content-Type', 'application/json; charset=utf-8'); 
            request.setBody(input);
        }
        HttpResponse response = httpProtocol.send(request);
        return response;
        
    }
    /*for error logging*/
    public static Batch_Error_Logger__c getGlobalErrorLogger(String strSourceSystem, String strObjectName, String strMethodName, String strExceptionCode, String strExceptionSummary, String strExceptionDetails) {
        Batch_Error_Logger__c globalErrorLogger = new Batch_Error_Logger__c();
        String nameString = (String.isBlank(strSourceSystem) ? System.label.Default_Error_Logger_Category : (String.isBlank(strObjectName) ? strSourceSystem : strSourceSystem + ':' + strObjectName));
        globalErrorLogger.Name = nameString.left(55) + ' - ' + System.now().format();
        globalErrorLogger.Source_System__c = strSourceSystem;
        globalErrorLogger.Object__c = strObjectName;
        globalErrorLogger.Batch_Name__c = strMethodName;
        globalErrorLogger.Operation_Type__c = 'Execution Error';
        globalErrorLogger.Exception_Code__c = strExceptionCode;
        if(!String.isBlank(strExceptionSummary)) {
            globalErrorLogger.Exception_Summary__c = strExceptionSummary.left(254);
        }
        globalErrorLogger.Exception_Detail__c = strExceptionDetails;
        return globalErrorLogger;
    }
    // utility method for fetching archival connectivity metadata
    public static Map<String,Archival_Config__mdt> archivalMetadataMap=new  Map<String,Archival_Config__mdt>();
    public static Archival_Config__mdt getArchivalMetadata(string apiName){
        if(!archivalMetadataMap.containsKey(apiName)){
            Archival_Config__mdt achObj=[select End_point_URL__c,Search_Parameter__c,Certificate_Name__c,Audience__c,Role__c,Case_Visibility__c,CM_Visibility__c from Archival_Config__mdt where Active__c = true and MasterLabel =: apiName limit 1];
            archivalMetadataMap.put(apiName,achObj);
        }
        return archivalMetadataMap.get(apiName);
    }
    /**
*   Helper method to parse the data.
*   The url argument is the URL of the external system.
*   Returns a list of rows from the external system.
**/
    public static List<Map<String, Object>> getData(String url, String metadataName,List<Batch_Error_Logger__c> errList,String className) {
        HttpResponse res = ExtDataSourceUtility.getResponse(url,'GET','',metadataName);
        String responseBody = res.getBody();
        List<Map<String, Object>> rows =
            new List<Map<String, Object>>();
        try{
            List<object> objList=(List<object>)JSON.deserializeUntyped(responseBody);
            for(Object obj:objList){
                Map<String, Object> row = (Map<String, Object>)obj;
                rows.add(createRow(row));
                
            }
        }catch(Exception exObj){
            errList.add(ExtDataSourceUtility.getGlobalErrorLogger('SFDC', className, className+'.getData', exObj.getTypeName(), 'Status Code:'+res.getStatusCode()+'', String.valueOf(res)));
        }
        
        return rows;
    }
    /**
*   Helper method to populate the External ID and Display 
*   URL fields on external object records based on the 'id' 
*   value that’s sent by the external system.
*   
*   The Map<String, Object> item parameter maps to the data 
*   that represents a row.
*   
*   Returns an updated map with the External ID and 
*   Display URL values.
**/
    public static Map<String, Object> createRow(
        Map<String, Object> item){
            Map<String, Object> row = new Map<String, Object>();
            for ( String key : item.keySet() ) {
                if (key == 'id') {
                    row.put('ExternalId', item.get(key));
                    row.put('SfId', item.get(key));
                } else if (key=='selfLink') {
                    row.put(key, item.get(key));
                    row.put('DisplayUrl', item.get(key));
                } else{
                    row.put(key, item.get(key));
                }
            }
            return row;
        }
    /* */
    public static void createInfoErrRec(String name,String summary,String exceptionDetail,String opType,String batchName)
    {
        Batch_Error_Logger__c infoObj=new Batch_Error_Logger__c ();
        infoObj.Name =name;
        infoObj.Operation_Type__c =opType;
        infoObj.Exception_Summary__c = summary;
        infoObj.Batch_Name__c =batchName;
        infoObj.Exception_Detail__c=exceptionDetail;
        insert infoObj;
    }
    
    public static set<id> createContentDocLinks(Map<Id, Archived_case__c> mapOldNewArchIds){
        List<ContentDocumentLink> conDocLinkList = new List<ContentDocumentLink>();
        Map<id,id> newArchCaseidOldCaseid=new Map<id,id>();
        Map<String,ContentDocumentLink> conDocLinkListToInsert = new Map<String,ContentDocumentLink>();
        Set<id> caseidSet=mapOldNewArchIds.keyset();
        List<String> idList= new List<String>();
        for(id idObj:caseidSet){
            idList.add(String.valueOf(idObj));  
        }
        if(caseidSet.isEmpty()){
            return null;
        }
        conDocLinkList = [Select Id, LinkedEntityId, ContentDocumentId,Visibility,ShareType From ContentDocumentLink Where LinkedEntityId =: idList ];
        if(!conDocLinkList.isEmpty()){
            for(ContentDocumentLink con : conDocLinkList){
                if(mapOldNewArchIds.containsKey(con.LinkedEntityId)){
                    ContentDocumentLink cn = new ContentDocumentLink();
                    cn.ContentDocumentId = con.ContentDocumentId;
                    cn.LinkedEntityId = mapOldNewArchIds.get(con.LinkedEntityId).id;//changes to send the Archived_case__c object
                    newArchCaseidOldCaseid.put(cn.LinkedEntityId,con.LinkedEntityId);
                    //cn.Visibility=con.Visibility;
                    //cn.ShareType=con.ShareType;
                    String contentKey=cn.ContentDocumentId+''+cn.LinkedEntityId;
                    conDocLinkListToInsert.put(contentKey,cn);
                }
            }
        }
        List<ContentDocumentLink> conLinkInsertList=conDocLinkListToInsert.values();
        Set<id> IdsToRemoveDel=new Set<id>();
        String reparentingFailedReason='';
        if(!conDocLinkListToInsert.isEmpty()){
            Database.SaveResult[] srList=Database.insert(conLinkInsertList,false); 
            for(Integer count=0;count<srList.size();count++){
                if(!srList.get(count).isSuccess()){
                    reparentingFailedReason=reparentingFailedReason+'Case Rec: '+conLinkInsertList.get(count).LinkedEntityId+';File id:'+conLinkInsertList.get(count).ContentDocumentId+'Reason: '+srList.get(count).getErrors()+';';
                    IdsToRemoveDel.add(newArchCaseidOldCaseid.get(conLinkInsertList.get(count).LinkedEntityId));
                }
            }
        }
        if(!reparentingFailedReason.equalsIgnoreCase('')){
            ErrorLogger.writeError('SFDC', 'CaseArchival-Reparent Failure', 'ExtDataSourceUtility.createContentDocLinks', 'Warning', 'Reparenting Failure', reparentingFailedReason);
        }
        return IdsToRemoveDel;
    }
    /* delete rows in heroku*/
    Public Static HttpResponse deleteRows(Set<id> parentIds){
        ExtDataSourceUtility.HerokuInput hkObj=new ExtDataSourceUtility.HerokuInput();
        hkObj.idar=new List<id>();
        hkObj.idar.addall(parentIds);
        String input=JSON.serialize(hkObj);
        String metadataName='Archived Case Deletion';
        Archival_Config__mdt mdtObj = ExtDataSourceUtility.getArchivalMetadata(metadataName);
        String url=mdtObj.End_point_URL__c;  //end point to be supplied
        HttpResponse res = ExtDataSourceUtility.getResponse(url,'POST',input,metadataName);
        return res;
    }
    public class HerokuInput{
        public List<id> idar;
    }
}