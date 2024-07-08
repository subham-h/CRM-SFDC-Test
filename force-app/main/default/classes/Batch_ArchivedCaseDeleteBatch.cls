/**
* @author Ranjan Kumar
* @description Batch for deleting Archived Case and related objects. 
Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-7165     17-Mar-2023 Ranjan@Maersk            Created. 
*/
global class Batch_ArchivedCaseDeleteBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
    Integer iBatchSize;
    
    // Constructor for scheduled regular run
    list<Odata_Batch_Archived_Case_Delete__mdt> lstBatchEmailMessageArchivers;
    public Batch_ArchivedCaseDeleteBatch(Integer batchSize) {
        // Soql back log records
        lstBatchEmailMessageArchivers = [select DeveloperName, 
                                                Default_Number_of_Days__c,
                                                Backlog_Days__c,
                                                End_Date__c,
                                                Additional_Conditions__c,
                                                Start_Date__c,
                                                Is_One_Time_Batch__c,Number_Of_Hours__c
                                                from Odata_Batch_Archived_Case_Delete__mdt 
                                                where Is_One_Time_Batch__c=:false];
        this.iBatchSize = (batchSize != null ? batchSize : 50);                                        
    }
    
    // Constructor for first time dated archival process
    Odata_Batch_Archived_Case_Delete__mdt datedEMArchiver = null;
    public Batch_ArchivedCaseDeleteBatch(String metaDataDevName, Integer batchSize) {
        lstBatchEmailMessageArchivers = [select DeveloperName, 
                                                Default_Number_of_Days__c,
                                                Backlog_Days__c,
                                                End_Date__c,
                                                Additional_Conditions__c,
                                                Start_Date__c,
                                                Is_One_Time_Batch__c,Number_Of_Hours__c
                                                from Odata_Batch_Archived_Case_Delete__mdt 
                                                where DeveloperName=:metaDataDevName];
        this.iBatchSize = (batchSize != null ? batchSize : 50);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String strDelimiter = '; ';
        String strQuery = '';
        String strSelect = 'select Id,Case_Id__c from Archived_Case__c';
        String strWhere = ' where';
        DateTime dtStartArchival;
        DateTime dtEndArchival;
        if(lstBatchEmailMessageArchivers == null || lstBatchEmailMessageArchivers.isEmpty()) { // no custom metadata record exists
            ErrorLogger.writeError('SFDC', 'Archived_Case__c', 'Batch_ArchivedCaseDeleteBatch.Start', 'Warning', 'No Custom Metadata', 'No Archived Case to delete! Please check the Batch EmailMessage Archiver custom metadata.');
            return Database.getQueryLocator('select Id from Archived_Case__c limit 0');
        }
        Odata_Batch_Archived_Case_Delete__mdt batchEMArchiver=lstBatchEmailMessageArchivers.get(0);
        // Prepare query for scheduled regular archival process
        String searchLogRecName='Archived Case Deletion Current Date Tracker: '+batchEMArchiver.DeveloperName;
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
            infoObj.Batch_Name__c ='Batch_ArchivedCaseDeleteBatch';
            loggerInfoList.add(infoObj);
        }
        //date calculations    
        date dateToConsider;
        if(batchEMArchiver.Start_Date__c!=null && batchEMArchiver.End_Date__c!=null){
            dtStartArchival=DateTime.valueOf(loggerInfoList.get(0).Exception_Summary__c);
            dtEndArchival=DateTime.valueOf(loggerInfoList.get(0).Exception_Summary__c).addHours(Integer.valueof(lstBatchEmailMessageArchivers.get(0).Number_Of_Hours__c));
            loggerInfoList.get(0).Exception_Summary__c=String.valueOf(dtEndArchival);
        }
        strWhere += ' CreatedDate__c >= :dtStartArchival and CreatedDate__c <= :dtEndArchival ';
        if(batchEMArchiver.Additional_Conditions__c!=null){
            strWhere+='and '+batchEMArchiver.Additional_Conditions__c+' ';
        }
        strQuery = strSelect+strWhere;
        if(loggerInfoList!=null && !loggerInfoList.isEmpty()){
            loggerInfoList.get(0).Exception_Detail__c=strQuery;
            upsert loggerInfoList;
        }
        ExtDataSourceUtility.createInfoErrRec('Archived Case Deletion Run Info '+Datetime.now(),
                        (batchEMArchiver.Is_One_Time_Batch__c?'One Time ':'Backlog ')+'Batch Started at '+Datetime.now()+' with Archival date from '+ 
                        String.valueOf(dtStartArchival)+' and end date '+String.valueOf(dtEndArchival),
                        ''+batchEMArchiver+'','Info','Batch_ArchivedCaseDeleteBatch');
        return Database.getQueryLocator(strQuery);
    }
    global void execute(Database.BatchableContext BC, list<Archived_Case__c> lstArchivedCases) {
        Set<Id> caseIdSet=new Set<Id>();
        Set<Id> emailIdSet=new Set<Id>();
        Map<Id,Archived_Case__c> archCaseMap=new Map<Id,Archived_Case__c>();
        for(Archived_Case__c archObj:lstArchivedCases){
            caseIdSet.add(archObj.case_id__c);
            archCaseMap.put(archObj.id,archObj);
        }
        //calling the delete methods.
        ErrorStormHandler.skipErrorStormCheck(true);
        try 
        {
            if(archCaseMap.isEmpty())
            {   
                return;
            } 
            emailIdSet=ArchivedCaseDeleter.retrieveExtEmailIds(caseIdSet);
            ExtDataSourceUtility.deleteRows(caseIdSet);
            if(!emailIdSet.isEmpty()){
                ArchivedCaseDeleter.deleteFiles(emailIdSet);
            }
            ArchivedCaseDeleter.deleteFiles(archCaseMap.keyset());
            ArchivedCaseDeleter.deleteCaseRelRec(archCaseMap);
                
        }catch(Exception ex) {
            ExtDataSourceUtility.createInfoErrRec('Archived Case Deletion Error '+Datetime.now(),'Batch_ArchivedCaseDeleteBatch.execute',
            ex.getMessage()+ex.getStackTraceString(),'Info','Batch_ArchivedCaseDeleteBatch'); 
        }
    }
    global void finish(Database.BatchableContext BC) {
        Boolean runMoreBatch=false;
        if(lstBatchEmailMessageArchivers == null || lstBatchEmailMessageArchivers.isEmpty()) {
            return;
        }
        Odata_Batch_Archived_Case_Delete__mdt batchEMArchiver=lstBatchEmailMessageArchivers.get(0);
        if(!batchEMArchiver.Is_One_Time_Batch__c){
            Integer iBacklog = (batchEMArchiver.Backlog_Days__c != null ? Integer.valueOf(batchEMArchiver.Backlog_Days__c)-1 : 0);
            batchEMArchiver.Start_Date__c=System.today().addDays(-(Integer.valueOf(batchEMArchiver.Default_Number_of_Days__c) + iBacklog));
            batchEMArchiver.End_Date__c=System.today().addDays(-(Integer.valueOf(batchEMArchiver.Default_Number_of_Days__c)));
        }
        String searchLogRecName='Archived Case Deletion Current Date Tracker: '+batchEMArchiver.DeveloperName;
        List<Batch_Error_Logger__c> loggerInfoList=[select id,name,Exception_Summary__c from Batch_Error_Logger__c where name=:searchLogRecName]; 
        if(loggerInfoList==null || loggerInfoList.isEmpty() ){
            return;
        }else{
            ExtDataSourceUtility.createInfoErrRec('Archived Case Deletion Run Info '+Datetime.now(),(batchEMArchiver.Is_One_Time_Batch__c?'One Time ':'Backlog ')+
            'Batch Ended at '+Datetime.now()+' with Archival date from '+ 
            DateTime.valueOf(loggerInfoList.get(0).Exception_Summary__c).addHours(-(Integer.valueof(batchEMArchiver.Number_Of_Hours__c)))+' and end date '+loggerInfoList.get(0).Exception_Summary__c,
            ''+batchEMArchiver+'','Info','Batch_ArchivedCaseDeleteBatch'); 
        }
        DateTime endTime=DateTime.newInstanceGMT(batchEMArchiver.End_Date__c.year(),batchEMArchiver.End_Date__c.month(),batchEMArchiver.End_Date__c.day()).addDays(1).addSeconds(-1);
        if(batchEMArchiver.End_Date__c!=null && 
            batchEMArchiver.Start_Date__c!=null && 
            Datetime.valueof(loggerInfoList.get(0).Exception_Summary__c)<endTime)
        {
            Batch_ArchivedCaseDeleteBatch batch=new Batch_ArchivedCaseDeleteBatch(batchEMArchiver.DeveloperName ,this.iBatchSize);
            database.executeBatch(batch, (this.iBatchSize!=null?this.iBatchSize:100));
        }else{
            delete loggerInfoList;
        }
    }
}