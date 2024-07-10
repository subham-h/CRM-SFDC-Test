public inherited sharing class Batch_DataImport implements Database.Batchable<sObject>,Database.Stateful {
    
    public Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
    public Set<String> recordIdSet;
    public String configuration;
    //public Integer totalRecords = 0;
    //public Integer totalSuccessRecords = 0;
    //public Integer totalFailureRecords = 0;
    public String jobUniqueIdentifier = '';
    public List<String> templateHeaders;
    public String operation;
    
    public Batch_DataImport(Set<String> idSet, String config, List<String> headers, String dmlOperation) {
        recordIdSet = new Set<String>();
        recordIdSet = idSet;
        configuration = config;
        templateHeaders = new List<String>();
        templateHeaders = headers;
        operation = dmlOperation;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        String query = generateSOQL('Data_Import_Mapping__c');
        query += ' WHERE Id IN :recordIdSet';
        
        jobUniqueIdentifier = UserInfo.getName() + '_' + DateTime.now();
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        
        //totalRecords += scope.size();
        DataImportUtilityClass util = new DataImportUtilityClass();
        DataImportUtilityClass.DataWrapper dataWrapper;
        dataWrapper = util.processIntermediateRecords(scope,configuration,templateHeaders);
        
        List<sObject> recordList = dataWrapper.targetSobjRecords;        
        List<sObject> dataImportMappingList = dataWrapper.sourceSobjRecords;
        List<sObject> errorDataMappingList = dataWrapper.sourceErrSobjRecords;
        
        if (recordList.size() > 0 && dataImportMappingList.size() > 0) {
            recordsDMLOperation(recordList,dataImportMappingList);
            if (errorDataMappingList.size() > 0) {
                assignJobUniqueId(errorDataMappingList);
                dataImportMappingList.addAll(errorDataMappingList);
            }
            update dataImportMappingList;
        } else if (errorDataMappingList.size() > 0) {
            assignJobUniqueId(errorDataMappingList);
            update errorDataMappingList;
        }
    }
    
    public void finish(Database.BatchableContext bc){
        /*Data_Import_Event__e event = new Data_Import_Event__e();
        event.Total_Record_Count__c = totalRecords;
        event.Success_Record_Count__c = totalSuccessRecords;
        event.Fail_Record_Count__c = totalFailureRecords;
        EventBus.publish(event);*/
    }
    
    private String generateSOQL(String sObjectApiName) {
        Map<String, Schema.SObjectField> fieldMap = globalDescribe.get(sObjectApiName).getDescribe().fields.getMap();
        String commaSeparatedFields = '';
        for (String fieldName : fieldMap.keyset()) {
            if (commaSeparatedFields == null || commaSeparatedFields == '') {
                commaSeparatedFields = fieldName;
            } else {
                commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
            }
        }
        return 'SELECT ' + commaSeparatedFields + ' FROM ' + sObjectApiName;
    }
    
    private void recordsDMLOperation(List<sObject> recordList, List<sObject> dataImportMappingList) {
        Database.SaveResult[] saveResultList;
        if (operation == 'Create') {
            saveResultList = Database.insert(recordList, false);    
        } else if (operation == 'Update') {
            saveResultList = Database.update(recordList, false);
        }
        Integer index = 0;
        for (Database.SaveResult sr : saveResultList) {
            if (sr.isSuccess()) {
                //++totalSuccessRecords;
                if (operation == 'Create') {
                dataImportMappingList[index].put('Message__c','Record Inserted Successfully');
                } else if (operation == 'Update') {
                    dataImportMappingList[index].put('Message__c','Record Updated Successfully');
                }
                dataImportMappingList[index].put('Status__c','Processed');
            } else {
                //++totalFailureRecords;
                for(Database.Error err : sr.getErrors()) {
                    if (err.getMessage().tolowerCase().contains('invalid date')) {
                        dataImportMappingList[index].put('Message__c',LABEL.Mass_Transfer_Invalid_Date_Error);
                    } else {
                        dataImportMappingList[index].put('Message__c',err.getMessage());   
                    }
                    dataImportMappingList[index].put('Status__c','Failed');
                }
            }
            dataImportMappingList[index].put('Job_Unique_Id__c',jobUniqueIdentifier);
            index++;
        }        
    }
    
    private void assignJobUniqueId(List<sObject> sObjList) {
        for (sObject sobj : sObjList) {
            sobj.put('Job_Unique_Id__c',jobUniqueIdentifier);
        }
    }
}