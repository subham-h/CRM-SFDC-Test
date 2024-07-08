/*
* Author    : Ranjan
* Purpose   : Send EmailMessages to External Object using the batch. 
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-5245     16-Aug-2022 Ranjan@Maersk            Created. 
* 2.0                   18-Oct-2022 Ranjan@Maersk           For new email archival,
*                                                           the record will be considered if active is true. 
*                                                           If start and end date is given, the start and 
*                                                           end date will be considered else date calculation based on backlog and default number of days field will be done.
*3.0                    31-Oct-2022 Ranjan@maersk           Accomodated Odata_Batch_EmailMessage_Archiver__mdt metadata related changes
*/
 
global class Batch_EmailMessageExtArchiver implements Database.Batchable<SObject>,Database.AllowsCallouts {
    
    
    Integer iBatchSize;
    
    // Constructor for scheduled regular run
    list<Odata_Batch_EmailMessage_Archiver__mdt> lstBatchEmailMessageArchivers;
    public Batch_EmailMessageExtArchiver() {
        // Soql back log records
        lstBatchEmailMessageArchivers = [select DeveloperName, 
                                                Default_Number_of_Days__c,
                                                Backlog_Days__c,
                                                End_Date__c,
                                                Additional_Conditions__c,
                                                Start_Date__c,
                                                Is_One_Time_Batch__c,Migrate_Attached_Emails__c
                                                from Odata_Batch_EmailMessage_Archiver__mdt 
                                                where Is_One_Time_Batch__c=:false];
    }
    public Batch_EmailMessageExtArchiver(String metaDataDevName, boolean bBacklog) {
        // Soql back log records
        if(bBacklog){
            lstBatchEmailMessageArchivers = [select DeveloperName, 
                                                    Default_Number_of_Days__c,
                                                    Backlog_Days__c,
                                                    End_Date__c,
                                                    Additional_Conditions__c,
                                                    Start_Date__c,
                                                    Is_One_Time_Batch__c,Migrate_Attached_Emails__c
                                                    from Odata_Batch_EmailMessage_Archiver__mdt 
                                                    where Is_One_Time_Batch__c=false and DeveloperName=:metaDataDevName];
        }
    }
    // Constructor for first time dated archival process
    Odata_Batch_EmailMessage_Archiver__mdt datedEMArchiver = null;
    public Batch_EmailMessageExtArchiver(String metaDataDevName, Integer batchSize) {
        lstBatchEmailMessageArchivers = [select DeveloperName, 
                                                Default_Number_of_Days__c,
                                                Backlog_Days__c,
                                                End_Date__c,
                                                Additional_Conditions__c,
                                                Start_Date__c,
                                                Is_One_Time_Batch__c,Migrate_Attached_Emails__c
                                                from Odata_Batch_EmailMessage_Archiver__mdt 
                                                where DeveloperName=:metaDataDevName];
        this.iBatchSize = (batchSize != null ? batchSize : 50);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String strDelimiter = '; ';
        String strQuery = '';
        String strSelect = 'select Id, ParentId, TextBody, ValidatedFromAddress, HtmlBody, Subject, FromName,HasAttachment, FromAddress, ToAddress, CcAddress,CreatedById,CreatedDate, BccAddress, Incoming, Status,LastModifiedById,LastModifiedDate, MessageDate, IsExternallyVisible, Parent.Case_Visibility__c from EmailMessage';
        String strWhere = ' where';
        List<Batch_Error_Logger__c> loggerInfoList=null;
        if(lstBatchEmailMessageArchivers == null || lstBatchEmailMessageArchivers.isEmpty()) { // no custom metadata record exists
            ErrorLogger.writeError('SFDC', 'EmailMessage', 'EmailMessageSender.sendEmailMessages', 'Warning', 'No Custom Metadata', 'No Email Messages to process! Please check the Batch EmailMessage Archiver custom metadata.');
            return Database.getQueryLocator('select Id from EmailMessage limit 0');
        }
        Odata_Batch_EmailMessage_Archiver__mdt batchEMArchiver=lstBatchEmailMessageArchivers.get(0);
        // Prepare query for scheduled regular archival process
        String searchLogRecName='Email Archival Current Date Tracker: '+batchEMArchiver.DeveloperName;
        if(batchEMArchiver.Is_One_Time_Batch__c){
            loggerInfoList=[select id,name,Exception_Summary__c from Batch_Error_Logger__c where name=:searchLogRecName];
        }
        if(batchEMArchiver.Is_One_Time_Batch__c && (loggerInfoList==null ||loggerInfoList.isEmpty())){
            loggerInfoList=new List<Batch_Error_Logger__c>();
            Batch_Error_Logger__c infoObj=new Batch_Error_Logger__c ();
            infoObj.Name =searchLogRecName;
            infoObj.Operation_Type__c ='Info';
            infoObj.Exception_Summary__c = String.valueOf(batchEMArchiver.Start_Date__c);
            infoObj.Batch_Name__c ='Batch_EmailMessageExtArchiver';
            loggerInfoList.add(infoObj);
        }
        Integer iBacklog = (batchEMArchiver.Backlog_Days__c != null ? Integer.valueOf(batchEMArchiver.Backlog_Days__c) : 1);
        //date calculations    
        DateTime dtStartArchival;
        DateTime dtEndArchival;
        date dateToConsider;
        if(batchEMArchiver.Start_Date__c!=null && batchEMArchiver.End_Date__c!=null){
            dateToConsider=(loggerInfoList!=null && !loggerInfoList.isEmpty()?
                                    date.valueof(loggerInfoList.get(0).Exception_Summary__c):
                                    batchEMArchiver.Start_Date__c);
            dtStartArchival=DateTime.newInstanceGMT(dateToConsider.year(), dateToConsider.month(), dateToConsider.day());
            dtEndArchival=DateTime.newInstanceGMT(dateToConsider.year(), dateToConsider.month(), dateToConsider.day()).addDays(1).addSeconds(-1);
            loggerInfoList.get(0).Exception_Summary__c=String.valueOf(dateToConsider);
        }else{
            dtStartArchival=System.today().addDays(-(Integer.valueOf(batchEMArchiver.Default_Number_of_Days__c) + iBacklog));
            dtEndArchival= System.today().addDays(-(Integer.valueOf(batchEMArchiver.Default_Number_of_Days__c)));
        }
        strWhere += ' CreatedDate >= :dtStartArchival and CreatedDate <= :dtEndArchival ';
        strWhere+='and '+batchEMArchiver.Additional_Conditions__c+' ';
        //strWhere += ' and (not Subject like \'Archived __________:%\') and Status != \'5\' order by CreatedDate';
        strQuery = strSelect+strWhere;
        if(Test.isRunningTest()){
            strQuery = 'select Id, ParentId, TextBody, ValidatedFromAddress, HtmlBody, Subject, FromName,HasAttachment, FromAddress, ToAddress, CcAddress,CreatedById,CreatedDate, BccAddress, Incoming, Status,LastModifiedById,LastModifiedDate, MessageDate, IsExternallyVisible, Parent.Case_Visibility__c from EmailMessage LIMIT 2';
        }
        if(loggerInfoList!=null && !loggerInfoList.isEmpty()){
            loggerInfoList.get(0).Exception_Detail__c=strQuery;
            upsert loggerInfoList;
        }
        createInfoErrRec('Email Archival Run Info '+Datetime.now(),
                        (batchEMArchiver.Is_One_Time_Batch__c?'One Time ':'Backlog ')+'Batch Started at '+Datetime.now()+' with Archival date from '+ 
                        String.valueOf(dtStartArchival)+' and end date '+String.valueOf(dtEndArchival),
                        ''+batchEMArchiver+'');
        // Set the Batch_EmailMessage_Archiver_Config__c of current user to true to skip EmailMessage workflow rules
        setBatchEmailMessageArchiverConfig(true);
        return Database.getQueryLocator(strQuery);
    }
    @TestVisible
    private void performBatchActions(list<EmailMessage> lstEmailMessages){
        ErrorStormHandler.skipErrorStormCheck(true);
        try {
            EmailMessageSender.sendEmailMessages(lstEmailMessages,lstBatchEmailMessageArchivers.get(0).Migrate_Attached_Emails__c,true);
            if(EmailArchivalDataSourceConnection.errList!=null && !EmailArchivalDataSourceConnection.errList.isEmpty()){
                Database.insert(EmailArchivalDataSourceConnection.errList, false);
            }
        }
        catch(Exception ex) {
            System.debug('Error while processing Email Messages: ' + ex + '. StackTraceString: ' + ex.getStackTraceString());
            Integer iFailures = 0;
            iFailures += lstEmailMessages!= null ? lstEmailMessages.size() : 0;
            // Log the errors in Global Error Logger
            String strMessage = ex.getMessage();
            String strDetail = ex.getStackTraceString();
            if(strMessage.indexOf('on row ') >= 0 && strMessage.indexOf(';') >= 0) {
                String strRowNumber = strMessage.substring(strMessage.indexOf('on row ') + 7, strMessage.indexOf(';')).trim();
                if(strRowNumber.isNumeric() && lstEmailMessages != null) {
                    strDetail += '\nID: ' + lstEmailMessages[Integer.valueOf(strRowNumber)].Id;
                }
                else {
                    strDetail += '\n' + strRowNumber;
                }
            }
            
            ErrorLogger.writeError('SFDC', 'EmailMessage', 'EmailMessageSender.sendEmailMessages', ex.getTypeName(), strMessage, strDetail); // #RQ-005636
        }
    }
    
    global void execute(Database.BatchableContext BC, list<EmailMessage> lstEmailMessages) {
        performBatchActions(lstEmailMessages);
    }
    
    global void finish(Database.BatchableContext BC) {
        Boolean runMoreBatch=false;
        if(lstBatchEmailMessageArchivers == null || lstBatchEmailMessageArchivers.isEmpty()) {
            return;
        }
        Odata_Batch_EmailMessage_Archiver__mdt batchEMArchiver=lstBatchEmailMessageArchivers.get(0);
        String searchLogRecName='Email Archival Current Date Tracker: '+batchEMArchiver.DeveloperName;
        List<Batch_Error_Logger__c> loggerInfoList=[select id,name,Exception_Summary__c from Batch_Error_Logger__c where name=:searchLogRecName];
        if(batchEMArchiver.Is_One_Time_Batch__c && loggerInfoList!=null && !loggerInfoList.isEmpty()){
            createInfoErrRec('Email Archival Run Info '+Datetime.now(),
                        'One Time Batch Ended at '+Datetime.now()+' with Archival date from '+ 
                        loggerInfoList.get(0).Exception_Summary__c+' and end date '+loggerInfoList.get(0).Exception_Summary__c,
                        ''+batchEMArchiver+'');            
        }else{
            Integer iBacklog = (batchEMArchiver.Backlog_Days__c != null ? Integer.valueOf(batchEMArchiver.Backlog_Days__c) : 1);
            Datetime dtStartArchival=System.today().addDays(-(Integer.valueOf(batchEMArchiver.Default_Number_of_Days__c) + iBacklog));
            DateTime dtEndArchival= System.today().addDays(-(Integer.valueOf(batchEMArchiver.Default_Number_of_Days__c)));
            createInfoErrRec('Email Archival Run Info '+Datetime.now(),
                        'Backlog Batch Ended at '+Datetime.now()+' with Archival date from '+ 
                        String.valueOf(dtStartArchival)+' and end date '+String.valueOf(dtEndArchival),
                        ''+batchEMArchiver+'');
        }
        
        if(!batchEMArchiver.Is_One_Time_Batch__c || loggerInfoList==null || loggerInfoList.isEmpty() ){
            return;
        }
        if(batchEMArchiver.End_Date__c!=null && 
            batchEMArchiver.Start_Date__c!=null && 
            date.valueof(loggerInfoList.get(0).Exception_Summary__c)<batchEMArchiver.End_Date__c)
        {
            loggerInfoList.get(0).Exception_Summary__c=String.valueOf(date.valueof(loggerInfoList.get(0).Exception_Summary__c).addDays(1));
            update loggerInfoList;
            runMoreBatch=true;
        }else{
            delete loggerInfoList;
        }
           
    
        if(runMoreBatch && !Test.isRunningTest()){
            Batch_EmailMessageExtArchiver batch=new Batch_EmailMessageExtArchiver(batchEMArchiver.DeveloperName ,this.iBatchSize);
            database.executeBatch(batch, this.iBatchSize);
        }
    }
    
    // Update Batch_EmailMessage_Archiver_Config__c hierarchy custom setting to decide whether to skip or execute EmailMessage workflow rules
    public void setBatchEmailMessageArchiverConfig(Boolean bFlag) {
        Batch_EmailMessage_Archiver_Config__c emArchiverConfig = Batch_EmailMessage_Archiver_Config__c.getValues(UserInfo.getUserId());
        if(emArchiverConfig == null) {
            emArchiverConfig = new Batch_EmailMessage_Archiver_Config__c(SetupOwnerId = UserInfo.getUserId(), Active__c = bFlag);
            insert emArchiverConfig;
        }
        else if(emArchiverConfig.Active__c != bFlag) {
            emArchiverConfig.Active__c = bFlag;
            update emArchiverConfig;
        }
    }
    public void createInfoErrRec(String name,String summary,String exceptionDetail)
    {
        Batch_Error_Logger__c infoObj=new Batch_Error_Logger__c ();
        infoObj.Name =name;
        infoObj.Operation_Type__c ='Info';
        infoObj.Exception_Summary__c = summary;
        infoObj.Batch_Name__c ='Batch_EmailMessageExtArchiver';
        infoObj.Exception_Detail__c=exceptionDetail;
        insert infoObj;
    }
    
}