/*
* Author    : Ranjan
* Purpose   : Send EmailMessages to External Object using the batch. 
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-4508     03-Jan-2023 Ranjan@Maersk            Created. Part of Case Archival 
*            
*/
 
global class Batch_EmailMessageExtCseArchiver implements Database.Batchable<SObject>,Database.AllowsCallouts {
    
    
    Integer iBatchSize;
    
    // Constructor for scheduled regular run
    list<Odata_Batch_EmailMessage_Case_Archiver__mdt> lstBatchEmailMessageArchivers;
    public Batch_EmailMessageExtCseArchiver(Integer batchSize) {
        // Soql back log records
        lstBatchEmailMessageArchivers = [select DeveloperName, 
                                                Default_Number_of_Days__c,
                                                Backlog_Days__c,
                                                End_Date__c,
                                                Additional_Conditions__c,
                                                Start_Date__c,
                                                Start_Chained_Case_Batch__c,
                                                Chained_Case_Batch_Size__c,
                                                Is_One_Time_Batch__c,Migrate_Attached_Emails__c,
                                                Number_Of_Hours__c
                                                from Odata_Batch_EmailMessage_Case_Archiver__mdt 
                                                where Is_One_Time_Batch__c=:false];
        this.iBatchSize = (batchSize != null ? batchSize : 50);                                        
    }
    
    // Constructor for first time dated archival process
    Odata_Batch_EmailMessage_Case_Archiver__mdt datedEMArchiver = null;
    public Batch_EmailMessageExtCseArchiver(String metaDataDevName, Integer batchSize) {
        lstBatchEmailMessageArchivers = [select DeveloperName, 
                                                Default_Number_of_Days__c,
                                                Backlog_Days__c,
                                                End_Date__c,
                                                Additional_Conditions__c,
                                                Start_Date__c,
                                                Start_Chained_Case_Batch__c,
                                                Chained_Case_Batch_Size__c,
                                                Is_One_Time_Batch__c,Migrate_Attached_Emails__c,Number_Of_Hours__c
                                                from Odata_Batch_EmailMessage_Case_Archiver__mdt 
                                                where DeveloperName=:metaDataDevName];
        this.iBatchSize = (batchSize != null ? batchSize : 50);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String strDelimiter = '; ';
        String strQuery = '';
        String strSelect = 'select Id, ParentId, TextBody, ValidatedFromAddress, HtmlBody, Subject, FromName,HasAttachment, FromAddress, ToAddress, CcAddress,CreatedById,CreatedDate, BccAddress, Incoming, Status,LastModifiedById,LastModifiedDate, MessageDate, IsExternallyVisible, Parent.Case_Visibility__c from EmailMessage';
        String strWhere = ' where';
        DateTime dtStartArchival;
        DateTime dtEndArchival;
        if(lstBatchEmailMessageArchivers == null || lstBatchEmailMessageArchivers.isEmpty()) { // no custom metadata record exists
            ErrorLogger.writeError('SFDC', 'EmailMessage', 'EmailMessageSender.sendEmailMessages', 'Warning', 'No Custom Metadata', 'No Email Messages to process! Please check the Batch EmailMessage Archiver custom metadata.');
            return Database.getQueryLocator('select Id from EmailMessage limit 0');
        }
        Odata_Batch_EmailMessage_Case_Archiver__mdt batchEMArchiver=lstBatchEmailMessageArchivers.get(0);
        // Prepare query for scheduled regular archival process
        String searchLogRecName='Case Email Archival Current Date Tracker: '+batchEMArchiver.DeveloperName;
        List<Batch_Error_Logger__c> loggerInfoList=[select id,name,Exception_Summary__c from Batch_Error_Logger__c where name=:searchLogRecName];
        if(!batchEMArchiver.Is_One_Time_Batch__c){
            Integer iBacklog = (batchEMArchiver.Backlog_Days__c != null ? Integer.valueOf(batchEMArchiver.Backlog_Days__c)-1 : 0);
            batchEMArchiver.Start_Date__c=System.today().addDays(-(Integer.valueOf(batchEMArchiver.Default_Number_of_Days__c) + iBacklog));
            batchEMArchiver.End_Date__c=System.today().addDays(-(Integer.valueOf(batchEMArchiver.Default_Number_of_Days__c)));
        }
        if(loggerInfoList==null ||loggerInfoList.isEmpty()){
            loggerInfoList=new List<Batch_Error_Logger__c>();
            Batch_Error_Logger__c infoObj=new Batch_Error_Logger__c ();
            infoObj.Name =searchLogRecName;
            infoObj.Operation_Type__c ='Info';
            infoObj.Exception_Summary__c = String.valueOf(DateTime.newInstanceGMT(batchEMArchiver.Start_Date__c.year(),batchEMArchiver.Start_Date__c.month(),batchEMArchiver.Start_Date__c.day()));
            infoObj.Batch_Name__c ='Batch_EmailMessageExtCseArchiver';
            loggerInfoList.add(infoObj);
        }
        //date calculations    
        date dateToConsider;
        if(batchEMArchiver.Start_Date__c!=null && batchEMArchiver.End_Date__c!=null){
            dtStartArchival=DateTime.valueOf(loggerInfoList.get(0).Exception_Summary__c);
            dtEndArchival=DateTime.valueOf(loggerInfoList.get(0).Exception_Summary__c).addHours(Integer.valueof(lstBatchEmailMessageArchivers.get(0).Number_Of_Hours__c));
            loggerInfoList.get(0).Exception_Summary__c=String.valueOf(dtEndArchival);
        }
        strWhere += ' parent.CreatedDate >= :dtStartArchival and parent.CreatedDate <= :dtEndArchival ';
        strWhere+='and '+batchEMArchiver.Additional_Conditions__c+' ';
        //strWhere += ' and (not Subject like \'Archived __________:%\') and Status != \'5\' order by CreatedDate';
        strQuery = strSelect+strWhere;
        if(loggerInfoList!=null && !loggerInfoList.isEmpty()){
            loggerInfoList.get(0).Exception_Detail__c=strQuery;
            upsert loggerInfoList;
        }
        createInfoErrRec('Case Email Archival Run Info '+Datetime.now(),
                        (batchEMArchiver.Is_One_Time_Batch__c?'One Time ':'Backlog ')+'Batch Started at '+Datetime.now()+' with Archival date from '+ 
                        String.valueOf(dtStartArchival)+' and end date '+String.valueOf(dtEndArchival),
                        ''+batchEMArchiver+'');
        // Set the Batch_EmailMessage_Archiver_Config__c of current user to true to skip EmailMessage workflow rules
        setBatchEmailMessageArchiverConfig(true);
        
        if(Test.isRunningTest()){
            strQuery = strSelect;
        }
        return Database.getQueryLocator(strQuery);
    }
    @TestVisible
    private void performBatchActions(list<EmailMessage> lstEmailMessages){
        ErrorStormHandler.skipErrorStormCheck(true);
        try {
            CaseEmailMessageSender.sendEmailMessages(lstEmailMessages,lstBatchEmailMessageArchivers.get(0).Migrate_Attached_Emails__c,true);
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
        Odata_Batch_EmailMessage_Case_Archiver__mdt batchEMArchiver=lstBatchEmailMessageArchivers.get(0);
        if(!batchEMArchiver.Is_One_Time_Batch__c){
            Integer iBacklog = (batchEMArchiver.Backlog_Days__c != null ? Integer.valueOf(batchEMArchiver.Backlog_Days__c)-1 : 0);
            batchEMArchiver.Start_Date__c=System.today().addDays(-(Integer.valueOf(batchEMArchiver.Default_Number_of_Days__c) + iBacklog));
            batchEMArchiver.End_Date__c=System.today().addDays(-(Integer.valueOf(batchEMArchiver.Default_Number_of_Days__c)));
        }
        String searchLogRecName='Case Email Archival Current Date Tracker: '+batchEMArchiver.DeveloperName;
        List<Batch_Error_Logger__c> loggerInfoList=[select id,name,Exception_Summary__c from Batch_Error_Logger__c where name=:searchLogRecName];
        Odata_Batch_Case_Archiver__mdt caseOdataObj=new Odata_Batch_Case_Archiver__mdt();
        if(loggerInfoList!=null && !loggerInfoList.isEmpty()){
            createInfoErrRec('Case Email Archival Run Info '+Datetime.now(),(batchEMArchiver.Is_One_Time_Batch__c?'One Time ':'Backlog ')+
            'Batch Ended at '+Datetime.now()+' with Archival date from '+ 
            DateTime.valueOf(loggerInfoList.get(0).Exception_Summary__c).addHours(-(Integer.valueof(batchEMArchiver.Number_Of_Hours__c)))+' and end date '+loggerInfoList.get(0).Exception_Summary__c,
            ''+batchEMArchiver+'');   
            caseOdataObj.Start_Date__c=Datetime.valueof(loggerInfoList.get(0).Exception_Summary__c).addSeconds(-1).date();
            caseOdataObj.End_Date__c=Datetime.valueof(loggerInfoList.get(0).Exception_Summary__c).addSeconds(-1).date();
            caseOdataObj.Is_One_Time_Batch__c=true;
            caseOdataObj.DeveloperName='CaseArchival'+caseOdataObj.Start_Date__c;
            caseOdataObj.Is_Chained_From_Email_Batch__c=true;

        }
       
        
        if(loggerInfoList==null || loggerInfoList.isEmpty() ){
            return;
        }
        DateTime endTime=DateTime.newInstanceGMT(batchEMArchiver.End_Date__c.year(),batchEMArchiver.End_Date__c.month(),batchEMArchiver.End_Date__c.day()).addDays(1).addSeconds(-1);
        if(batchEMArchiver.End_Date__c!=null && 
            batchEMArchiver.Start_Date__c!=null && 
            Datetime.valueof(loggerInfoList.get(0).Exception_Summary__c)<endTime)
        {
            runMoreBatch=true;
        }else{
            delete loggerInfoList;
        }
        Datetime endDateTimeOfCurrentBtch=Datetime.valueof(loggerInfoList.get(0).Exception_Summary__c);
        DateTime endDateTimeOfCurrentBtchOne=Datetime.valueof(loggerInfoList.get(0).Exception_Summary__c).addSeconds(-1);
        if(batchEMArchiver.Start_Chained_Case_Batch__c && endDateTimeOfCurrentBtch.day()!=endDateTimeOfCurrentBtchOne.day()){
            Integer batchSize=(batchEMArchiver.Chained_Case_Batch_Size__c!=null?Integer.valueof(batchEMArchiver.Chained_Case_Batch_Size__c):25);
            Batch_ArchivedCases archCaseBatchObj=new Batch_ArchivedCases(caseOdataObj,batchSize);
            Database.executeBatch(archCaseBatchObj,batchSize);
        }
           
    
        if(runMoreBatch){
            Batch_EmailMessageExtCseArchiver batch=new Batch_EmailMessageExtCseArchiver(batchEMArchiver.DeveloperName ,this.iBatchSize);
            database.executeBatch(batch, (this.iBatchSize!=null?this.iBatchSize:100));
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
        infoObj.Batch_Name__c ='Batch_EmailMessageExtCseArchiver';
        infoObj.Exception_Detail__c=exceptionDetail;
        insert infoObj;
    }
    
}