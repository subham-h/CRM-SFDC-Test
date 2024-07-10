global class EmailArchivalDataSourceConnection extends DataSource.Connection{
    private DataSource.ConnectionParams connectionInfo;
    public static List<Batch_Error_Logger__c> errList=new List<Batch_Error_Logger__c>();
    
    /**
     *   Constructor for DriveDataSourceConnection.
     **/
    global EmailArchivalDataSourceConnection(
        DataSource.ConnectionParams connectionInfo) {
        this.connectionInfo = connectionInfo;
    }
    override global List<DataSource.Table> sync() {
        List<DataSource.Table> tables =
            new List<DataSource.Table>();
        List<DataSource.Column> columns;
        columns = new List<DataSource.Column>();
        //columns.add(DataSource.Column.boolean('istracked'));
        columns.add(DataSource.Column.text('parentid', 18));
        columns.add(DataSource.Column.boolean('incoming'));
        //columns.add(DataSource.Column.text('headers', 3000));
        //columns.add(DataSource.Column.text('firstopeneddate',50));
        //columns.add(DataSource.Column.boolean('isclientmanaged'));
        //columns.add(DataSource.Column.text('activityid', 18));
        columns.add(DataSource.Column.text('fromaddress', 1000));
        //columns.add(DataSource.Column.text('replytoemailmessageid', 18));
        columns.add(DataSource.Column.text('subject', 3000));
        columns.add(DataSource.Column.textarea('htmlbody'));
        //columns.add(DataSource.Column.text('lastopeneddate',50));
        columns.add(DataSource.Column.text('lastmodifieddate',50));
        columns.add(DataSource.Column.textarea('textbody'));
        //columns.add(DataSource.Column.boolean('isdeleted'));
        //columns.add(DataSource.Column.text('systemmodstamp',50));
        //columns.add(DataSource.Column.boolean('isexternallyvisible'));
        //columns.add(DataSource.Column.text('messageidentifier', 765));
        columns.add(DataSource.Column.text('lastmodifiedbyid', 18));
        //columns.add(DataSource.Column.text('emailtemplateid', 18));
        columns.add(DataSource.Column.text('status', 255));
        columns.add(DataSource.Column.text('bccaddress', 1000));
        //columns.add(DataSource.Column.boolean('isbounced'));
        //columns.add(DataSource.Column.boolean('isopened'));
        //columns.add(DataSource.Column.text('threadidentifier', 765));
        columns.add(DataSource.Column.text('ccaddress', 1000));
        columns.add(DataSource.Column.text('messagedate',50));
        columns.add(DataSource.Column.text('fromname', 1000));
        columns.add(DataSource.Column.text('createddate',50));
        columns.add(DataSource.Column.text('toaddress', 1000));
        columns.add(DataSource.Column.text('createdbyid', 18));
        columns.add(DataSource.Column.text('validatedfromaddress', 255));
        columns.add(DataSource.Column.boolean('hasattachment'));
        //columns.add(DataSource.Column.text('emailid', 18));
        columns.add(DataSource.Column.text('casevisibility', 100));
        columns.add(DataSource.Column.text('created__in_heroku',50));
        columns.add(DataSource.Column.url('DisplayUrl'));
        columns.add(DataSource.Column.text('ExternalId', 255));
        columns.add(DataSource.Column.text('heroku_id', 18));
        tables.add(DataSource.Table.get('emailmessagearchival','id',
            columns));
        return tables;
    }
    /**
     *   Called to query and get results from the external 
     *   system for SOQL queries, list views, and detail pages 
     *   for an external object that’s associated with the 
     *   external data source.
     *   
     *   The QueryContext argument represents the query to run 
     *   against a table in the external system.
     *   
     *   Returns a list of rows as the query results.
     **/
    override global DataSource.TableResult query(
        DataSource.QueryContext context) {
        DataSource.Filter filter = context.tableSelection.filter;
        List<DataSource.ColumnSelection> cs=context.tableSelection.columnsSelected;
        Set<String> columnSet=new Set<String>();
        String url;
        Archival_Config__mdt mdtObj = EmailArchivalDataSourceConnection.getArchivalMetadata('Email Archival');
        url = mdtObj.End_point_URL__c+'?select=';
        if(cs!=null)
        {
        for(DataSource.ColumnSelection tempcs:cs){
            columnSet.add(tempcs.columnName);
        }
        columnSet.removeAll(new List<String>{'ExternalId','emailid'});
        columnSet.add('heroku_id');
        }
        for(String cols:columnSet){
            url=url+cols+',';
        }
        url =url.removeEnd(',')+'&';
        if (filter != null) {
            String thisColumnName = filter.columnName;
            if(filter.subfilters != null && filter.subfilters.size()>1 
            && filter.subfilters[0].columnName.contains('heroku_id')){
                url = url+
                + 'heroku_id=in.(';
                for(DataSource.Filter filterObj:filter.subfilters){
                    url =url +filterObj.columnValue+',';
                }
                url =url.removeEnd(',')+')';
            }else if (filter.subfilters != null && filter.subfilters!=null 
                && filter.subfilters[0].columnName!=null &&filter.subfilters[0].columnName.contains('parentid')
                    ){
                        url = url+
                + 'parentid=in.(';
                for(DataSource.Filter filterObj:filter.subfilters){
                    url =url +filterObj.columnValue+',';
                }
                url =url.removeEnd(',')+')';
            }else if(thisColumnName.contains('parentid')){ 
                url = url+
                thisColumnName+'=eq.' + filter.columnValue;
            }else{
                 
                url = url+
                + 'heroku_id=eq.' + filter.columnValue;

            }//'?'+thisColumnName+'=eq.' + filter.columnValue;
        } else {
            url = url+
                + 'heroku_id=eq.' + filter.columnValue;
        }
        /**
         * Filters, sorts, and applies limit and offset clauses.
         **/
        /*List<Map<String, Object>> rows = 
            DataSource.QueryUtils.process(context, getData(url));*/
            DataSource.TableResult dResObj=DataSource.TableResult.get(true, null,
            context.tableSelection.tableSelected, getData(url));
        return dResObj;
    }
    /**
     *   Called to do a full text search and get results from
     *   the external system for SOSL queries and Salesforce
     *   global searches.
     *   
     *   The SearchContext argument represents the query to run 
     *   against a table in the external system.
     *   
     *   Returns results for each table that the SearchContext 
     *   requested to be searched.
     **/
    override global List<DataSource.TableResult> search(DataSource.SearchContext context) 
    {
        
        String url;
        Archival_Config__mdt mdtObj = EmailArchivalDataSourceConnection.getArchivalMetadata('Email Archival');
        List<DataSource.TableResult> results =
            new List<DataSource.TableResult>();
        String targetString= mdtObj.Search_Parameter__c; 
        try{  
            for (Integer i =0;i< context.tableSelections.size();i++) {
                String entity = context.tableSelections[i].tableSelected;
                String searchStr=context.searchPhrase;
                url = mdtObj.End_point_URL__c+targetString.replace('$context.searchPhrase$', searchStr.replace(' ', '%20'));
                results.add(DataSource.TableResult.get(
                    true, null, entity, getData(url)));
            }
        }catch(Exception exObj){
            return results;
        }

        return results;
    }

     /**
     *   Helper method to parse the data.
     *   The url argument is the URL of the external system.
     *   Returns a list of rows from the external system.
     **/
    public List<Map<String, Object>> getData(String url) {
        HttpResponse res = getResponse(url,'GET','');
        String responseBody = res.getBody();
        List<Map<String, Object>> rows =
                new List<Map<String, Object>>();
        try{
            List<object> objList=(List<object>)JSON.deserializeUntyped(responseBody);
            Archival_Config__mdt mdtObj = EmailArchivalDataSourceConnection.getArchivalMetadata('Email Archival');
            List<user> currentUserList=[Select Id,Name,Email,CM_Visibility__c from User where Id=:userinfo.getuserId()]; 
            Boolean matchRestrictionCond=false;
            String caseVisibility='';
            String cmVisibilty=mdtObj.CM_Visibility__c;
            if(currentUserList.get(0)!=null && cmVisibilty.equalsIgnoreCase(currentUserList.get(0).CM_Visibility__c)){
                matchRestrictionCond=true;
                caseVisibility=mdtObj.Case_Visibility__c;
            }   
            for(Object obj:objList){
                Map<String,Object> strObjMap=new Map<String,Object>();
                Map<String, Object> row = (Map<String, Object>)obj;
                strObjMap.put(String.valueof(row.get('id')),obj);
                if(matchRestrictionCond){
                    if( String.valueof(row.get('casevisibility')).equalsIgnoreCase(caseVisibility)){
                        rows.add(createRow(row));
                    }
                }else{
                    rows.add(createRow(row));
                }
            }
        }catch(Exception exObj){
            errList.add(EmailArchivalDataSourceConnection.getGlobalErrorLogger('SFDC', 'EmailArchivalDataSourceConnection', 'EmailArchivalDataSourceConnection.getData', exObj.getTypeName(), 'Status Code:'+res.getStatusCode()+'', String.valueOf(res)));
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
    public Map<String, Object> createRow(
        Map<String, Object> item){
        Map<String, Object> row = new Map<String, Object>();
        for ( String key : item.keySet() ) {
            if (key == 'heroku_id') {
                row.put('ExternalId', item.get(key));
                row.put('heroku_id', item.get(key));
                row.put('emailid', item.get(key));
            } else if (key=='selfLink') {
                row.put(key, item.get(key));
                row.put('DisplayUrl', item.get(key));
            } else{
                row.put(key, item.get(key));
            }
        }
        return row;
    }
     /**
     *   Helper method to make the HTTP GET call.
     *   The url argument is the URL of the external system.
     *   Returns the response from the external system.
     **/
    public HttpResponse getResponse(String url,String method,String input) {
        
        // Perform callouts for production (non-test) results.
        Archival_Config__mdt mdtObj = EmailArchivalDataSourceConnection.getArchivalMetadata('Email Archival');
        string jwtToken = WebserviceUtilities.getJWTBearer(mdtObj.Certificate_Name__c,mdtObj.Role__c,mdtObj.Audience__c);
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndPoint(url);
        request.setMethod(method);
        request.setTimeout(120000);
        request.setHeader('Authorization', 'Bearer '+jwtToken);
        if(method.equals('POST')){
          request.setHeader('Content-Type', 'application/json; charset=utf-8'); 
          request.setBody(input);
        }
        system.debug('JT==>'+jwtToken);
        HttpResponse response = httpProtocol.send(request);
        return response;
      
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
    /*upsert the row*/
    global override List<DataSource.UpsertResult> upsertRows(DataSource.UpsertContext context) 
    {
        if(context.tableSelected != 'emailmessagearchival'){
            return null;
        }
        List<DataSource.UpsertResult> results = new List<DataSource.UpsertResult>();
        List<Map<String, Object>> rows = context.rows;
        Boolean isCallout=false;
        //make a post call to insert the data.
        HttpResponse response = makePostCallout(rows,'POST');
        if (response.getStatusCode()<200 || response.getStatusCode()>299){
            //error has happened
            results.add(DataSource.UpsertResult.failure(
                String.valueOf(''), 
                'The callout resulted in an error: ' + response+
                response.getStatusCode()));
                errList.add(EmailArchivalDataSourceConnection.getGlobalErrorLogger('SFDC', 
                'EmailArchivalDataSourceConnection', 'EmailArchivalDataSourceConnection.upsertRows',
                'Error','Status Code:'+response.getStatusCode()+'', String.valueOf(response)));
        }else{
            Archival_Config__mdt mdtObj = EmailArchivalDataSourceConnection.getArchivalMetadata('Email Archival');
            string url = mdtObj.End_point_URL__c+'?limit=1&order=heroku_id.desc';
            //since the response does not return the id, we are explicitly querying the highest id.
            for (Map<String, Object> row : rows){
                results.add(DataSource.UpsertResult.success(String.valueOf(row.get('ExternalId'))));
            }
        }
        return results;             
    }

    /*make a post callout*/
    public HttpResponse makePostCallout(List<Map<String, Object>> rows,String methodName){
        //string recId = (String.valueof(row.get('sf_record_id')) == null) ? '' : String.valueOf(row.get('sf_record_id'));
        // setting up input parameters
        List<EmailMessageArchival> lstEmailMessageArchival=new List<EmailMessageArchival>();
        for (Map<String, Object> row : rows){
            EmailMessageArchival inputs = new EmailMessageArchival();
            //inputs.istracked = String.valueOf(row.get('istracked'));
            inputs.parentid = String.valueOf(row.get('parentid'));
            inputs.incoming = String.valueOf(row.get('incoming'));
            //inputs.headers = String.valueOf(row.get('headers'));
            //inputs.firstopeneddate = String.valueOf(row.get('firstopeneddate'));
            //inputs.isclientmanaged = String.valueOf(row.get('isclientmanaged'));
            //inputs.activityid = String.valueOf(row.get('activityid'));
            inputs.fromaddress = String.valueOf(row.get('fromaddress'));
            //inputs.replytoemailmessageid = String.valueOf(row.get('replytoemailmessageid'));
            inputs.subject = String.valueOf(row.get('subject'));
            inputs.htmlbody = String.valueOf(row.get('htmlbody'));
            //inputs.lastopeneddate = String.valueOf(row.get('lastopeneddate'));
            inputs.lastmodifieddate = String.valueOf(row.get('lastmodifieddate'));
            inputs.textbody = String.valueOf(row.get('textbody'));
            //inputs.isdeleted = String.valueOf(row.get('isdeleted'));
            //inputs.systemmodstamp = String.valueOf(row.get('systemmodstamp'));
            //inputs.isexternallyvisible = String.valueOf(row.get('isexternallyvisible'));
            //inputs.messageidentifier = String.valueOf(row.get('messageidentifier'));
            inputs.lastmodifiedbyid = String.valueOf(row.get('lastmodifiedbyid'));
            //inputs.emailtemplateid = String.valueOf(row.get('emailtemplateid'));
            inputs.status = String.valueOf(row.get('status'));
            inputs.bccaddress = String.valueOf(row.get('bccaddress'));
            //inputs.isbounced = String.valueOf(row.get('isbounced'));
            //inputs.isopened = String.valueOf(row.get('isopened'));
            //inputs.threadidentifier = String.valueOf(row.get('threadidentifier'));
            inputs.ccaddress = String.valueOf(row.get('ccaddress'));
            inputs.messagedate = String.valueOf(row.get('messagedate'));
            inputs.fromname = String.valueOf(row.get('fromname'));
            inputs.createddate = String.valueOf(row.get('createddate'));
            inputs.toaddress = String.valueOf(row.get('toaddress'));
            inputs.createdbyid = String.valueOf(row.get('createdbyid'));
            inputs.validatedfromaddress = String.valueOf(row.get('validatedfromaddress'));
            inputs.hasattachment = String.valueOf(row.get('hasattachment'));
            //inputs.emailid = String.valueOf(row.get('emailid'));
            inputs.casevisibility = String.valueOf(row.get('casevisibility'));
            inputs.heroku_id = String.valueOf(row.get('emailid'));
            //inputs.istracked = String.valueOf(row.get('istracked'));
            inputs.subject = String.valueOf(row.get('subject'));
            lstEmailMessageArchival.add(inputs);
        }
        Archival_Config__mdt mdtObj = EmailArchivalDataSourceConnection.getArchivalMetadata('Email Archival');
        string url = mdtObj.End_point_URL__c;
        return getResponse(url,methodName,JSON.serialize(lstEmailMessageArchival));//JSON.serialize(inputs)
    }
    /*wrapper class for sending the data*/
    Public class EmailMessageArchival{
        //Public String istracked;
        Public String parentid;
        Public String incoming;
        //Public String headers;
        //Public String firstopeneddate;
        //Public String isclientmanaged;
        //Public String activityid;
        Public String fromaddress;
        //Public String replytoemailmessageid;
        Public String subject;
        Public String htmlbody;
        //Public String lastopeneddate;
        Public String lastmodifieddate;
        Public String textbody;
        //Public String isdeleted;
        //Public String systemmodstamp;
        //Public String isexternallyvisible;
        //Public String messageidentifier;
        Public String lastmodifiedbyid;
        //Public String emailtemplateid;
        Public String status;
        Public String bccaddress;
        //Public String isbounced;
        //Public String isopened;
        //Public String threadidentifier;
        Public String ccaddress;
        Public String messagedate;
        Public String fromname;
        Public String createddate;
        Public String toaddress;
        Public String createdbyid;
        Public String validatedfromaddress;
        Public String hasattachment;
        //Public String emailid;
        Public String casevisibility;
        Public String heroku_id;
    }

    /*error logging for batch*/
    @TestVisible
    private static Batch_Error_Logger__c getGlobalErrorLogger(String strSourceSystem, String strObjectName, String strMethodName, String strExceptionCode, String strExceptionSummary, String strExceptionDetails) {
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
}