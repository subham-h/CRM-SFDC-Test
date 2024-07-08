global class CaseRelatedObjectsDataSourceConnection extends DataSource.Connection{
    private DataSource.ConnectionParams connectionInfo;
    public static List<Batch_Error_Logger__c> errList=new List<Batch_Error_Logger__c>();
    
    /**
     *   Constructor for DriveDataSourceConnection.
     **/
    global CaseRelatedObjectsDataSourceConnection(
        DataSource.ConnectionParams connectionInfo) {
        this.connectionInfo = connectionInfo;
    }
    override global List<DataSource.Table> sync() {
        List<DataSource.Table> tables =
            new List<DataSource.Table>();
        /*live Chat transcript coulmns*/
        List<DataSource.Column> columns;
        columns = new List<DataSource.Column>();
        columns.add(DataSource.Column.text('accountid', 18));
        columns.add(DataSource.Column.text('averageresponsetimeoperator', 11));
        columns.add(DataSource.Column.text('averageresponsetimevisitor', 11));
        columns.add(DataSource.Column.textarea('body'));
        columns.add(DataSource.Column.text('browser', 200));
        columns.add(DataSource.Column.text('browserlanguage', 200));
        columns.add(DataSource.Column.text('caseid', 18));
        columns.add(DataSource.Column.text('chatduration', 50));
        columns.add(DataSource.Column.text('contactid', 18));
        columns.add(DataSource.Column.text('created__in_heroku',50));
        columns.add(DataSource.Column.text('createdbyid', 18));
        columns.add(DataSource.Column.text('createddate',50));
        columns.add(DataSource.Column.text('customer_code__c', 100));
        columns.add(DataSource.Column.text('customer_email__c', 255));
        columns.add(DataSource.Column.text('endedby', 250));
        columns.add(DataSource.Column.text('endtime', 50));
        columns.add(DataSource.Column.text('SfId', 18));
        columns.add(DataSource.Column.text('ipaddress', 50));
        columns.add(DataSource.Column.text('leadid', 18));
        columns.add(DataSource.Column.text('livechatbuttonid', 18));
        columns.add(DataSource.Column.text('livechatdeploymentid', 18));
        columns.add(DataSource.Column.text('livechatvisitorid', 18));
        columns.add(DataSource.Column.text('location', 200));
        columns.add(DataSource.Column.text('maxresponsetimeoperator', 11));
        columns.add(DataSource.Column.text('maxresponsetimevisitor', 11));
        columns.add(DataSource.Column.text('name', 50));
        columns.add(DataSource.Column.text('operatormessagecount', 11));
        columns.add(DataSource.Column.text('ownerid', 18));
        columns.add(DataSource.Column.text('platform', 200));
        columns.add(DataSource.Column.text('referreruri', 200));
        columns.add(DataSource.Column.text('requesttime', 50));
        columns.add(DataSource.Column.text('screenresolution', 200));
        columns.add(DataSource.Column.text('skillid', 18));
        columns.add(DataSource.Column.text('starttime', 50));
        columns.add(DataSource.Column.text('status', 250));
        columns.add(DataSource.Column.text('useragent', 200));
        columns.add(DataSource.Column.text('visitormessagecount', 11));
        columns.add(DataSource.Column.text('visitornetwork', 200));
        columns.add(DataSource.Column.text('waittime', 20));
        columns.add(DataSource.Column.url('DisplayUrl'));
        columns.add(DataSource.Column.text('ExternalId', 255));
        tables.add(DataSource.Table.get('livechatarchival','id',
            columns));
        /*case history columns*/
        List<DataSource.Column> columnsCaseHistory;
        columnsCaseHistory = new List<DataSource.Column>();
        columnsCaseHistory.add(DataSource.Column.text('caseid', 18));
        columnsCaseHistory.add(DataSource.Column.text('created__in_heroku',50));
        columnsCaseHistory.add(DataSource.Column.text('createdbyid', 18));
        columnsCaseHistory.add(DataSource.Column.text('createddate',50));
        columnsCaseHistory.add(DataSource.Column.text('datatype', 255));
        columnsCaseHistory.add(DataSource.Column.text('field', 255));
        columnsCaseHistory.add(DataSource.Column.textarea('newvalue'));
        columnsCaseHistory.add(DataSource.Column.textarea('oldvalue'));
        columnsCaseHistory.add(DataSource.Column.text('SfId', 18));
        columnsCaseHistory.add(DataSource.Column.url('DisplayUrl'));
        columnsCaseHistory.add(DataSource.Column.text('ExternalId', 255));
        tables.add(DataSource.Table.get('casehistoryarchival','id',
        columnsCaseHistory));
        /*booking information columns*/
        List<DataSource.Column> bookingInfoColumns;
        bookingInfoColumns = new List<DataSource.Column>();
        bookingInfoColumns.add(DataSource.Column.text('bill_of_lading_number__c', 50));
        bookingInfoColumns.add(DataSource.Column.text('created__in_heroku',50));
        bookingInfoColumns.add(DataSource.Column.text('createdbyid', 18));
        bookingInfoColumns.add(DataSource.Column.text('createddate',50));
        bookingInfoColumns.add(DataSource.Column.text('booking_number__c',50));
        bookingInfoColumns.add(DataSource.Column.text('case_account_name__c',250));
        bookingInfoColumns.add(DataSource.Column.text('related_case__c', 18));
        bookingInfoColumns.add(DataSource.Column.text('name',250));
        bookingInfoColumns.add(DataSource.Column.url('DisplayUrl'));
        bookingInfoColumns.add(DataSource.Column.text('ExternalId', 255));
        bookingInfoColumns.add(DataSource.Column.text('SfId', 18));
        tables.add(DataSource.Table.get('bookinginformationarchival','id',
            bookingInfoColumns));
        /*financial details columns*/
        List<DataSource.Column> finDetailsColumns;
        finDetailsColumns = new List<DataSource.Column>();
        finDetailsColumns.add(DataSource.Column.text('charge_type__c', 250));
        finDetailsColumns.add(DataSource.Column.text('claim__c', 18));
        finDetailsColumns.add(DataSource.Column.text('conversion_date__c',50));
        finDetailsColumns.add(DataSource.Column.text('created__in_heroku',50));
        finDetailsColumns.add(DataSource.Column.text('createdbyid', 18));
        finDetailsColumns.add(DataSource.Column.text('createddate',50));
        finDetailsColumns.add(DataSource.Column.text('exchange_rate__c',50));
        finDetailsColumns.add(DataSource.Column.text('expected_amount__c',50));
        finDetailsColumns.add(DataSource.Column.text('expected_days__c',50));
        finDetailsColumns.add(DataSource.Column.text('free_time_charge_type__c', 250));
        finDetailsColumns.add(DataSource.Column.text('local_amount__c',50));
        finDetailsColumns.add(DataSource.Column.text('local_currency__c', 250));
        finDetailsColumns.add(DataSource.Column.text('name',250));
        finDetailsColumns.add(DataSource.Column.boolean('recalculate_xrate__c'));
        finDetailsColumns.add(DataSource.Column.text('recordtypeid', 18));
        finDetailsColumns.add(DataSource.Column.text('type__c', 250));
        finDetailsColumns.add(DataSource.Column.text('usd_amount__c',50));
        finDetailsColumns.add(DataSource.Column.text('SfId', 18));
        finDetailsColumns.add(DataSource.Column.url('DisplayUrl'));
        finDetailsColumns.add(DataSource.Column.text('ExternalId', 255));
        tables.add(DataSource.Table.get('financialdetailsarchival','id',
            finDetailsColumns));
        /*approval request archival*/
        List<DataSource.Column> approvalReqColumns;
        approvalReqColumns = new List<DataSource.Column>();
        approvalReqColumns.add(DataSource.Column.text('actual_cost__c',50));
        approvalReqColumns.add(DataSource.Column.text('actual_cost_currency__c', 250));
        approvalReqColumns.add(DataSource.Column.text('approval_request_type__c', 250));
        approvalReqColumns.add(DataSource.Column.text('approval_status__c', 250));
        approvalReqColumns.add(DataSource.Column.text('approved_amount__c',50));
        approvalReqColumns.add(DataSource.Column.text('approved_amount_currency__c',50));
        approvalReqColumns.add(DataSource.Column.text('approver_s_comments__c',2000));
        approvalReqColumns.add(DataSource.Column.text('bill_of_lading_number__c', 9));
        approvalReqColumns.add(DataSource.Column.text('case__c', 18));
        approvalReqColumns.add(DataSource.Column.text('case_account_name__c', 250));
        approvalReqColumns.add(DataSource.Column.text('converted_approved_amount_usd__c',50));
        approvalReqColumns.add(DataSource.Column.text('converted_requested_amount_usd__c',50));
        approvalReqColumns.add(DataSource.Column.text('country__c', 18));
        approvalReqColumns.add(DataSource.Column.text('created__in_heroku',50));
        approvalReqColumns.add(DataSource.Column.text('createdbyid', 18));
        approvalReqColumns.add(DataSource.Column.text('createddate',50));
        approvalReqColumns.add(DataSource.Column.boolean('dispute_d_d_waiver__c'));
        approvalReqColumns.add(DataSource.Column.text('SfId', 18));
        approvalReqColumns.add(DataSource.Column.text('liner_brand__c', 250));
        approvalReqColumns.add(DataSource.Column.text('name',250));
        approvalReqColumns.add(DataSource.Column.text('new_last_free_day__c',50));
        approvalReqColumns.add(DataSource.Column.text('non_sfdc_approver__c',250));
        approvalReqColumns.add(DataSource.Column.boolean('notify_approver__c'));
        approvalReqColumns.add(DataSource.Column.text('number_of_containers__c',50));
        approvalReqColumns.add(DataSource.Column.text('number_of_extra_days_requested__c',50));
        approvalReqColumns.add(DataSource.Column.text('party_responsible_for_cost__c',250));
        approvalReqColumns.add(DataSource.Column.text('processor__c', 18));
        approvalReqColumns.add(DataSource.Column.text('processor_comments__c', 255));
        approvalReqColumns.add(DataSource.Column.text('reason_for_request__c', 2000));
        approvalReqColumns.add(DataSource.Column.text('recordtypeid', 18));
        approvalReqColumns.add(DataSource.Column.text('requested_amount__c',50));
        approvalReqColumns.add(DataSource.Column.text('requested_amount_currency__c',50));
        approvalReqColumns.add(DataSource.Column.boolean('self_approved__c'));
        approvalReqColumns.add(DataSource.Column.text('sfdc_approver__c', 18));
        approvalReqColumns.add(DataSource.Column.text('sfdc_approver_first_name__c', 250));
        approvalReqColumns.add(DataSource.Column.text('sub_type__c', 255));
        approvalReqColumns.add(DataSource.Column.text('waiver_category__c', 250));
        approvalReqColumns.add(DataSource.Column.text('waiver_reason__c', 250));
        approvalReqColumns.add(DataSource.Column.url('DisplayUrl'));
        approvalReqColumns.add(DataSource.Column.text('ExternalId', 255));
        tables.add(DataSource.Table.get('approvalrequestarchival','id',
            approvalReqColumns));
            /*case comment columns*/
        List<DataSource.Column> caseCommentsColumns;
        caseCommentsColumns = new List<DataSource.Column>();
        caseCommentsColumns.add(DataSource.Column.text('commentbody', 100));
        caseCommentsColumns.add(DataSource.Column.text('created__in_heroku',50));
        caseCommentsColumns.add(DataSource.Column.text('createdbyid', 18));
        caseCommentsColumns.add(DataSource.Column.text('createddate',50));
        caseCommentsColumns.add(DataSource.Column.boolean('isdeleted'));
        caseCommentsColumns.add(DataSource.Column.boolean('ispublished'));
        caseCommentsColumns.add(DataSource.Column.text('lastmodifiedbyid', 18));
        caseCommentsColumns.add(DataSource.Column.text('lastmodifieddate',50));
        caseCommentsColumns.add(DataSource.Column.text('parentid', 18));
        caseCommentsColumns.add(DataSource.Column.text('systemmodstamp',50));
        caseCommentsColumns.add(DataSource.Column.url('DisplayUrl'));
        caseCommentsColumns.add(DataSource.Column.text('ExternalId', 255));
        caseCommentsColumns.add(DataSource.Column.text('SfId', 18));
        tables.add(DataSource.Table.get('casecommentarchival','id',
            caseCommentsColumns));
            /*Attchment columns*/
        List<DataSource.Column> attachColumns;
        attachColumns = new List<DataSource.Column>();
        attachColumns.add(DataSource.Column.text('SfId', 18));
        attachColumns.add(DataSource.Column.url('DisplayUrl'));
        attachColumns.add(DataSource.Column.text('ExternalId', 255));
        attachColumns.add(DataSource.Column.text('parentid', 18));
        attachColumns.add(DataSource.Column.text('name',250));
        attachColumns.add(DataSource.Column.boolean('isprivate'));
        attachColumns.add(DataSource.Column.text('contenttype', 255));
        attachColumns.add(DataSource.Column.text('bodylength', 18));
        attachColumns.add(DataSource.Column.text('ownerid', 18));
        attachColumns.add(DataSource.Column.text('createdbyid', 18));
        attachColumns.add(DataSource.Column.text('createddate',50));
        attachColumns.add(DataSource.Column.text('description', 255));
        attachColumns.add(DataSource.Column.url('blob_url'));
        tables.add(DataSource.Table.get('attchmentarchival','id',attachColumns));
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
        String url;
        string parentid='';
        string metadataName='';
        if(context.tableSelection.tableSelected=='casehistoryarchival'){
            parentid='caseid';
            metadataName='Case History Archival';
        }else if(context.tableSelection.tableSelected=='livechatarchival'){
            parentid='caseid';
            metadataName='Live Chat Archival';
        }else if(context.tableSelection.tableSelected=='bookinginformationarchival'){
            parentid='related_case__c';
            metadataName='Booking Information Archival';
        }else if(context.tableSelection.tableSelected=='financialdetailsarchival'){
            parentid='claim__c';
            metadataName='Financial Detail Archival';
        }else if(context.tableSelection.tableSelected=='approvalrequestarchival'){
            parentid='case__c';
            metadataName='Approval Request Archival';
        }else if(context.tableSelection.tableSelected=='casecommentarchival'){
            parentid='parentid';
            metadataName='Case Comment Archival';
        }else if(context.tableSelection.tableSelected=='attchmentarchival'){
            parentid='parentid';
            metadataName='Attachment Archival';
        }
        Archival_Config__mdt mdtObj = ExtDataSourceUtility.getArchivalMetadata(metadataName);
        
        if (filter != null) {
            String thisColumnName = filter.columnName;
            if(filter.subfilters != null && filter.subfilters.size()>1 
            && (filter.subfilters[0].columnName.contains(parentid)||filter.subfilters[0].columnName.contains('SfId'))){
                url = mdtObj.End_point_URL__c+
                + '?'+filter.subfilters[0].columnName+'=in.(';
                for(DataSource.Filter filterObj:filter.subfilters){
                    url =url +filterObj.columnValue+',';
                }
                url =url.removeEnd(',')+')';
            }else if (filter.subfilters != null && filter.subfilters!=null 
                && filter.subfilters[0].columnName!=null &&filter.subfilters[0].columnName.contains(parentid)
                    ){
                        url = mdtObj.End_point_URL__c+
                + '?limit=200&'+parentid+'=eq.' + filter.subfilters[0].columnValue;
            }else if(thisColumnName.contains(parentid)){ 
                url = mdtObj.End_point_URL__c+
                + '?limit=200&'+thisColumnName+'=eq.' + filter.columnValue;
            }else{
                 
                url = mdtObj.End_point_URL__c+
                + '?limit=200&id=eq.' + filter.columnValue;

            }
        } else {
            url = mdtObj.End_point_URL__c+
                + '?limit=200&id=eq.' + filter.columnValue;
        }
        /**
         * Filters, sorts, and applies limit and offset clauses.
         **/
        /*List<Map<String, Object>> rows = 
            DataSource.QueryUtils.process(context, getData(url));*/
            DataSource.TableResult dResObj=DataSource.TableResult.get(true, null,
            context.tableSelection.tableSelected, ExtDataSourceUtility.getData(url,metadataName,errList,metadataName));
        return dResObj;
    }
}