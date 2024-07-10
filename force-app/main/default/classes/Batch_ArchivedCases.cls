/*
* Author    : Raksha
* Purpose   : Archive Case Records into Archived Case object. 
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-4508     10-Jan-2023 Raksha@Maersk           For case archival, the start and end date is picked up from Odata Batch Case Archiver metadata and case record will be archived into Archived case object. 
                                                            If the case has to be archived without specifying start and end date, the date calculation based on backlog and default number of days field.
*/
global class Batch_ArchivedCases implements Database.Batchable<sObject>{
    Integer iBatchSize;
    
    // Constructor for scheduled regular run
    list<Odata_Batch_Case_Archiver__mdt> lstBatchCaseArchivers;
    public Batch_ArchivedCases(Odata_Batch_Case_Archiver__mdt caseObjOdata, Integer batchSize) {
        //Soql is triggered once the email is archived.
        String metadataName='Chained_From_Email_Batch_Dont_Modify';
        if(caseObjOdata.Is_Chained_From_Email_Batch__c)
        {
            lstBatchCaseArchivers=[select DeveloperName, 
                                    Default_Number_of_Days__c,
                                    Backlog_Days__c,
                                    End_Date__c,
                                    Additional_Conditions__c,
                                    Start_Date__c,
                                    Is_One_Time_Batch__c,
                                    Number_Of_Hours__c,Is_Chained_From_Email_Batch__c
                                    from Odata_Batch_Case_Archiver__mdt
                                    where DeveloperName=:metadataName];
            lstBatchCaseArchivers.get(0).Start_Date__c=caseObjOdata.Start_Date__c;
            lstBatchCaseArchivers.get(0).End_Date__c=caseObjOdata.End_Date__c;
            lstBatchCaseArchivers.get(0).Default_Number_of_Days__c=caseObjOdata.Default_Number_of_Days__c;
            lstBatchCaseArchivers.get(0).Backlog_Days__c=caseObjOdata.Backlog_Days__c;
            lstBatchCaseArchivers.get(0).Is_One_Time_Batch__c=caseObjOdata.Is_One_Time_Batch__c;
            lstBatchCaseArchivers.get(0).DeveloperName=caseObjOdata.DeveloperName;
        }else{
            lstBatchCaseArchivers=new list<Odata_Batch_Case_Archiver__mdt>();
            lstBatchCaseArchivers.add(caseObjOdata);

        }
        this.iBatchSize = (batchSize != null ? batchSize : 50);
    }
    public Batch_ArchivedCases() {
        // Soql for backlog records
        lstBatchCaseArchivers = [select DeveloperName, 
                                                Default_Number_of_Days__c,
                                                Backlog_Days__c,
                                                End_Date__c,
                                                Additional_Conditions__c,
                                                Start_Date__c,
                                                Is_One_Time_Batch__c,
                                                Number_Of_Hours__c,Is_Chained_From_Email_Batch__c 
                                                from Odata_Batch_Case_Archiver__mdt
                                                where Is_One_Time_Batch__c=:false];
    }
    
    // Constructor for One time dated archival process
    Odata_Batch_Case_Archiver__mdt datedEMArchiver = null;
    public Batch_ArchivedCases(String metaDataDevName, Integer batchSize) {
        lstBatchCaseArchivers = [select DeveloperName, 
                                                Default_Number_of_Days__c,
                                                Backlog_Days__c,
                                                End_Date__c,
                                                Additional_Conditions__c,
                                                Start_Date__c,
                                                Is_One_Time_Batch__c,
                                                Number_Of_Hours__c,Is_Chained_From_Email_Batch__c
                                                from Odata_Batch_Case_Archiver__mdt
                                                where DeveloperName=:metaDataDevName];
        this.iBatchSize = (batchSize != null ? batchSize : 50);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        List<Batch_Error_Logger__c> loggerInfoList=null;
        if(lstBatchCaseArchivers == null || lstBatchCaseArchivers.isEmpty()) { // no custom metadata record exists
            ErrorLogger.writeError('SFDC', 'Batch_ArchivedCases', 'Batch_ArchivedCases.start', 'Warning', 'No Custom Metadata', 'No Case to process! Please check the Batch Case Archiver custom metadata.');
            return Database.getQueryLocator('select Id from Case limit 0');
        }
        Odata_Batch_Case_Archiver__mdt batchCaseArchiver=lstBatchCaseArchivers.get(0);
        // Prepare query for scheduled regular archival process
        String searchLogRecName='Case Archival Current Date Tracker: '+batchCaseArchiver.DeveloperName;
        if(!batchCaseArchiver.Is_One_Time_Batch__c){
            Integer iBacklog = (batchCaseArchiver.Backlog_Days__c != null ? Integer.valueOf(batchCaseArchiver.Backlog_Days__c)-1 : 0);
            batchCaseArchiver.Start_Date__c=System.today().addDays(-(Integer.valueOf(batchCaseArchiver.Default_Number_of_Days__c) + iBacklog));
            batchCaseArchiver.End_Date__c=System.today().addDays(-(Integer.valueOf(batchCaseArchiver.Default_Number_of_Days__c)));
            batchCaseArchiver.Is_One_Time_Batch__c=true;
        }
        if(batchCaseArchiver.Is_One_Time_Batch__c){
            loggerInfoList=[select id,name,Exception_Summary__c from Batch_Error_Logger__c where name=:searchLogRecName];
        }
        if(batchCaseArchiver.Is_One_Time_Batch__c && (loggerInfoList==null ||loggerInfoList.isEmpty())){
            loggerInfoList=new List<Batch_Error_Logger__c>();
            Batch_Error_Logger__c infoObj=new Batch_Error_Logger__c ();
            infoObj.Name =searchLogRecName;
            infoObj.Operation_Type__c ='Info';
            infoObj.Exception_Summary__c = String.valueOf(DateTime.newInstanceGMT(batchCaseArchiver.Start_Date__c.year(),batchCaseArchiver.Start_Date__c.month(),batchCaseArchiver.Start_Date__c.day()));
            infoObj.Batch_Name__c ='Batch_ArchivedCases';
            loggerInfoList.add(infoObj);
        }
        //date calculations    
        DateTime dtStartArchival;
        DateTime dtEndArchival;
        date dateToConsider;
        if(batchCaseArchiver.Start_Date__c!=null && batchCaseArchiver.End_Date__c!=null){
            dtStartArchival=DateTime.valueOf(loggerInfoList.get(0).Exception_Summary__c);
            dtEndArchival=DateTime.valueOf(loggerInfoList.get(0).Exception_Summary__c).addHours(Integer.valueof(batchCaseArchiver.Number_Of_Hours__c));
            loggerInfoList.get(0).Exception_Summary__c=String.valueOf(dtEndArchival);
        }
        String strWhere = ' CreatedDate >= :dtStartArchival and CreatedDate <= :dtEndArchival ';
        if(!String.isBlank( batchCaseArchiver.Additional_Conditions__c)){
            strWhere=strWhere+'and '+batchCaseArchiver.Additional_Conditions__c+' ';
        }
        
        //Check if the case field names exists in the Archived case config custom metadata and pass it to the execute method
        Map<String,Archived_Case_Config__mdt> archCaseMap = Archived_Case_Config__mdt.getAll();
        list<String> CaseFieldNames = new List<String>(); 
        for(String archCase: archCaseMap.keySet()){
                CaseFieldNames.add(archCaseMap.get(archCase).From__c);
        }
        String query = 'SELECT ' + String.join(CaseFieldNames, ',') + ' FROM Case where';
        if(!String.isEmpty(strWhere)){
            query=query+strWhere;
        }
        if(loggerInfoList!=null && !loggerInfoList.isEmpty()){
            loggerInfoList.get(0).Exception_Detail__c=query;
            upsert loggerInfoList;
        }
        ExtDataSourceUtility.createInfoErrRec('Case Archival Run Info '+Datetime.now(),
                        (batchCaseArchiver.Is_One_Time_Batch__c?'One Time ':'Backlog ')+'Batch Started at '+Datetime.now()+' with Archival date from '+ 
                        String.valueOf(dtStartArchival)+' and end date '+String.valueOf(dtEndArchival),
                        ''+batchCaseArchiver+'','Info','Batch_ArchivedCases');
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> caseList) {
        Map<id,Case> caseMap= new Map<id,Case>(caseList);
        Map<id,Case> caseArcCaseMapDelete= new Map<id,Case>();
        Schema.SObjectField ftoken = Archived_Case__c.Fields.Case_Id__c;
        List<Archived_Case__c> updateArchObjList = new List<Archived_Case__c>();
        Map<Id,Archived_Case__c> updateArchObjMap = new map<id,Archived_Case__c>();
        Map<string, string> recTypeMap = New Map<string,string>();
        Set<Id> caseSet= new Set<Id>();
        String caseDeletionFailedReason=''; 
        String caseArchivalFailedReason= '';
        String reparentingFailedReason= '';
        List<RecordType> recType=[Select ID, Developername,Name From RecordType Where sObjectType = 'Archived_Case__c'];
        for(RecordType rec:recType){
            recTypeMap.put(rec.Developername,rec.Id);
        }

        //Condition to check if the case does not contain email 
        List<EmailMessage> emailMsgList=[select id,parentId from EmailMessage where ParentId IN:caseMap.keySet()];
        for(EmailMessage em:emailMsgList){
            caseSet.add(em.parentId);
        }
        for(Case cs : caseMap.values() ){
            //if contains, then it should be ignored
            if(caseSet.contains(cs.id)){
                continue;
            }

            //Storing case field values into the Archived Case field values 
            Archived_Case__c archCaseInstance = new Archived_Case__c(); 
            Map<String,Archived_Case_Config__mdt> archCaseMdtMap = Archived_Case_Config__mdt.getAll();
            for(String mdtMap : archCaseMdtMap.keySet()){
                String fromField = archCaseMdtMap.get(mdtMap).From__c.tolowercase();
                String toField = archCaseMdtMap.get(mdtMap).To__c.tolowercase();
                if(fromField=='account.name'){
                    archCaseInstance.put(toField,cs.account.name);
                }else if(fromField=='On_Behalf_Account__r.Name'){
                    archCaseInstance.put(toField,cs.On_Behalf_Account__r.Name);
                }
                else if(fromField=='RecordType.DeveloperName'){
                    archCaseInstance.RecordTypeId=recTypeMap.get(cs.RecordType.Developername);
                }else if(fromField=='Owner.Name') {
                    archCaseInstance.put(toField,cs.Owner.Name);
                }else if(fromField=='Parent.CaseNumber'){
                    archCaseInstance.put(toField,cs.Parent.CaseNumber);
                }else{
                    archCaseInstance.put(toField,cs.get(fromField));
                }
            } 
            if(String.valueOf(archCaseInstance.OwnerId).startsWith('00G')){
                archCaseInstance.Case_Owner_Queue_Id__c=archCaseInstance.OwnerId;
                archCaseInstance.OwnerId=UserInfo.getUserId();
            }else{
                archCaseInstance.Case_Owner_Queue_name__c='';
            }
            updateArchObjList.add(archCaseInstance);  
            updateArchObjMap.put(archCaseInstance.case_id__c,archCaseInstance);             
        }
        Map<Id,Archived_case__c> caseIdArchiveCaseMap=new Map<Id,Archived_case__c>();//reparenting files
        if(!updateArchObjList.isEmpty()){  
        Database.UpsertResult[] caseUpsertList=Database.Upsert(updateArchObjList,ftoken,false); 
        Integer caseUpsertList_size = caseUpsertList.size();
            for(Integer count=0;count<caseUpsertList_size;count++){
                if(caseUpsertList.get(count).isSuccess()){
                    caseIdArchiveCaseMap.put(updateArchObjList.get(count).Case_Id__c,updateArchObjList.get(count));//reparenting files
                    caseArcCaseMapDelete.put(updateArchObjList.get(count).Case_Id__c,caseMap.get(updateArchObjList.get(count).case_id__c));
                }else{
                    caseArchivalFailedReason = caseArchivalFailedReason + ' Case Id: ' +updateArchObjList.get(count).Case_Id__c + ' Reason: '+(JSON.serialize(caseUpsertList.get(count).getErrors())).left(300)+';';                                                   
                }
            }
            if(!caseArchivalFailedReason.equalsIgnoreCase('')){
                ExtDataSourceUtility.createInfoErrRec('SFDC:CaseArchival Fail-'+Datetime.now(), 'CaseArchival Failure', caseArchivalFailedReason, 'Warning', 'Batch_ArchivedCases.Execute');
            }
        }
        /*reparenting files*/
        Set<id> failedFileIdSet=ExtDataSourceUtility.createContentDocLinks(caseIdArchiveCaseMap);
        if(failedFileIdSet!=null && !failedFileIdSet.isEmpty()){
            for(id idObj:failedFileIdSet){
                caseArcCaseMapDelete.remove(idObj);
            }
        }
        /*end of Reparenting files*/
        List<SObject> reparentUpsert = new list<SObject>();
        //Reparenting Survey
        for(Survey__c survey : [select id,Archived_Case__c,Case__c from Survey__c where Case__c IN: caseArcCaseMapDelete.keyset()]){
            survey.Archived_Case__c=updateArchObjMap.get(survey.Case__c).id;
            reparentUpsert.add(Survey);
        }        
        
        
        //Reparenting Agent workflow
        for(Agent_Workflow__c agentWF: [select id,Archived_Case__c,Case_ID__c from Agent_Workflow__c where Case_ID__c IN: caseArcCaseMapDelete.keyset()]){
            agentWF.Archived_Case__c=updateArchObjMap.get(agentWF.Case_ID__c).id;
            reparentUpsert.add(agentWF);
        }    

        //Reparenting External party
        for(External_Party__c extPty : [select id,Archived_Case__c,Claim__c from External_Party__c where Claim__c IN: caseArcCaseMapDelete.keyset()]){
            extPty.Archived_Case__c=updateArchObjMap.get(extPty.Claim__c).id;
            reparentUpsert.add(extPty);
        }        
        
        //Reparenting Activity related reference
        for(Activity_Related_Reference__c relatedRef : [select id,Archived_Case__c,Case__c from Activity_Related_Reference__c where Case__c IN: caseArcCaseMapDelete.keyset()]){
            relatedRef.Archived_Case__c=updateArchObjMap.get(relatedRef.Case__c).id;
            reparentUpsert.add(relatedRef);
        }   
        
        //Reparenting Equipment/commodity
        for(Equipment_Commodity__c EqpCom : [select id,Archived_Case__c,Claim__c from Equipment_Commodity__c where Claim__c IN: caseArcCaseMapDelete.keyset()]){
            EqpCom.Archived_Case__c=updateArchObjMap.get(EqpCom.Claim__c).id;
            reparentUpsert.add(EqpCom);
        }    
        Boolean isSuccess = true;
        Savepoint sp = Database.setSavepoint();
        if(!reparentUpsert.isEmpty()){  
            Database.UpsertResult[] reparentUpsertList=Database.Upsert(reparentUpsert,false);
            for(Database.UpsertResult rpUpsert :reparentUpsertList){
                if(!rpUpsert.isSuccess()){
                    isSuccess=false;
                    reparentingFailedReason=reparentingFailedReason+'Id: '+rpUpsert.getId()+'Reason: '+rpUpsert.getErrors()+';';
                }
            }
        }
        if(isSuccess == true){
            //Case Deletion post archival       
            if(!caseArcCaseMapDelete.isEmpty()){  
                Database.DeleteResult[] delResList=Database.delete(caseArcCaseMapDelete.values(),false);
                for(Database.DeleteResult drObj : delResList) {
                    if (!drObj.isSuccess()) {
                        caseDeletionFailedReason=caseDeletionFailedReason+'Id: '+drObj.getId()+'Reason: '+drObj.getErrors()+';';
                    }
                }
                Database.emptyRecycleBin(caseArcCaseMapDelete.values());//Hard Delete- Empty recycle bin
            }
            if(!caseDeletionFailedReason.equalsIgnoreCase('')){
                ErrorLogger.writeError('SFDC', 'CaseArchival-CaseDelFail', 'Batch_ArchivedCases.Execute', 'Warning', 'Deletion Failure', caseDeletionFailedReason);
            }   
        } else{
            Database.RollBack(sp);
            if(!reparentingFailedReason.equalsIgnoreCase('')){
                ErrorLogger.writeError('SFDC', 'CaseArchival-ReprtFail', 'Batch_ArchivedCases.Execute', 'Warning', 'Reparenting Failure', reparentingFailedReason);
            } 
        }       
    }
    
    global void finish(Database.BatchableContext BC) {
        Boolean runMoreBatch=false;
        if(lstBatchCaseArchivers == null || lstBatchCaseArchivers.isEmpty()) {
            return;
        }
        Odata_Batch_Case_Archiver__mdt batchCaseArchiver=lstBatchCaseArchivers.get(0);
        if(!batchCaseArchiver.Is_One_Time_Batch__c){
            Integer iBacklog = (batchCaseArchiver.Backlog_Days__c != null ? Integer.valueOf(batchCaseArchiver.Backlog_Days__c)-1 : 0);
            batchCaseArchiver.Start_Date__c=System.today().addDays(-(Integer.valueOf(batchCaseArchiver.Default_Number_of_Days__c) + iBacklog));
            batchCaseArchiver.End_Date__c=System.today().addDays(-(Integer.valueOf(batchCaseArchiver.Default_Number_of_Days__c)));
            batchCaseArchiver.Is_One_Time_Batch__c=true;
        }
        String searchLogRecName='Case Archival Current Date Tracker: '+batchCaseArchiver.DeveloperName;
        List<Batch_Error_Logger__c> loggerInfoList=[select id,name,Exception_Summary__c from Batch_Error_Logger__c where name=:searchLogRecName];
        if(batchCaseArchiver.Is_One_Time_Batch__c && loggerInfoList!=null && !loggerInfoList.isEmpty()){
            ExtDataSourceUtility.createInfoErrRec('Case Archival Run Info '+Datetime.now(),
                        'One Time Batch Ended at '+Datetime.now()+' with Archival date from '+ 
                        DateTime.valueOf(loggerInfoList.get(0).Exception_Summary__c).addHours(-(Integer.valueof(batchCaseArchiver.Number_Of_Hours__c)))+
                        ' and end date '+loggerInfoList.get(0).Exception_Summary__c,
                        ''+batchCaseArchiver+'','Info','Batch_ArchivedCases');            
        }
        
        if(!batchCaseArchiver.Is_One_Time_Batch__c || loggerInfoList==null || loggerInfoList.isEmpty() ){
            return;
        }
        DateTime endTime=DateTime.newInstanceGMT(batchCaseArchiver.End_Date__c.year(),batchCaseArchiver.End_Date__c.month(),batchCaseArchiver.End_Date__c.day()).addDays(1).addSeconds(-1);
        if(batchCaseArchiver.End_Date__c!=null && 
        batchCaseArchiver.Start_Date__c!=null && 
        Datetime.valueof(loggerInfoList.get(0).Exception_Summary__c)<endTime)
        {
            //loggerInfoList.get(0).Exception_Summary__c=String.valueOf(date.valueof(loggerInfoList.get(0).Exception_Summary__c).addDays(1));
            //update loggerInfoList;
            runMoreBatch=true;
        }else{
            delete loggerInfoList;
        }
           
        this.iBatchSize=(this.iBatchSize!=null?this.iBatchSize:200);
        if(runMoreBatch){
            Batch_ArchivedCases batch=new Batch_ArchivedCases(batchCaseArchiver,this.iBatchSize);
            database.executeBatch(batch, this.iBatchSize);
        }
    }
}