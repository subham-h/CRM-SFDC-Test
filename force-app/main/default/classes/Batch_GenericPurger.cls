/*
* Author   : Nisha
* Purpose  : Batch class to clean up any object records.
*         
* Revision Ref Number  Date        Owner               Description
* -------- ----------  ----------- ----------          -----------
* 1.0      RQ-003324   08-Jun-2016 Nisha.Arjunan@UST   Created.
* 2.0      RQ-005636   26-Sep-2017 Nisha@UST           Update references of GlobalErrorLogger
* 3.0      RQ-012969   10-Feb-2020 Avinash@UST         Deletion of 2017 case data
* 4.0      SC-146      03-Apr-2020 Avinash@UST         Call Task Deletion - Rolling 3 Year Window
* 5.0	   sc-9435	   21-Nov-2023 Partha@maersk	   Added the capability to delete files and archived emails
*/ 
global class Batch_GenericPurger implements Database.Batchable<sObject>,Database.AllowsCallouts{
    
    global String strObjectName;
    global Integer jobNumber;
    global boolean delFiles;
    global boolean delHerokuEmails;
    
    // Constructor to assign the object for clean up
    // #SC-146 - Added JobNumber parameter to ctor
    global Batch_GenericPurger(String strObjectName,Integer jobNumber) {
        this.strObjectName = strObjectName; 
        this.jobNumber = jobNumber;
        delFiles = false;
        delHerokuEmails = false;
    }
    global Batch_GenericPurger(String strObjectName,Integer jobNumber, boolean delFiles) {
        this.strObjectName = strObjectName; 
        this.jobNumber = jobNumber;
        this.delFiles = delFiles;
        delHerokuEmails = false;
    }
    global Batch_GenericPurger(String strObjectName,Integer jobNumber, boolean delFiles,boolean delHerokuEmails) {
        this.strObjectName = strObjectName; 
        this.jobNumber = jobNumber;
        this.delFiles = delFiles;
        this.delHerokuEmails = delHerokuEmails;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(String.isBlank(strObjectName)) {
            throw new ObjectNameNotSpecifiedException('Please specify API Name of the object for purging.');
        }
        
        // Query custom setting
        list<Purge_Configuration__c> lstPurgeCriterias = [SELECT Object_Name__c, Field_Name__c, Operation__c, Value__c,Order__c,Days_To_Skip__c, No_Of_Days_To_Delete__c FROM Purge_Configuration__c WHERE Object_Name__c = :strObjectName AND Job_Number__c =: jobNumber ORDER BY Order__c ASC];
        system.debug('##### lstPurgeCriterias --> ' + lstPurgeCriterias);  
        
        String strQuery = 'SELECT Id FROM ' + strObjectName;
        if(lstPurgeCriterias != null && !lstPurgeCriterias.isEmpty()) {
            strQuery += ' WHERE ';
            
            // Construct where clause from custom setting
            for(Purge_Configuration__c purgeCriteria : lstPurgeCriterias) {
                //#RQ-012969 - Added below If condition
                if(purgeCriteria.Days_To_Skip__c != NULL && purgeCriteria.No_Of_Days_To_Delete__c != NULL){
                    Date strtDate = Date.Today().addDays(- Integer.valueOf(purgeCriteria.Days_To_Skip__c)); 
                    system.debug('strtDate :'+strtDate);
                    Date endDate = Date.Today().addDays(- Integer.valueOf((purgeCriteria.Days_To_Skip__c - purgeCriteria.No_Of_Days_To_Delete__c)));
                    system.debug('endDate :'+endDate);
                    strQuery = strQuery+ 'CreatedDate >=: strtDate AND CreatedDate <=: endDate AND ' + purgeCriteria.Field_Name__c +' '+purgeCriteria.Operation__c +' '+purgeCriteria.Value__c +' AND ';
                }
                else{
                    strQuery = strQuery + purgeCriteria.Field_Name__c +' '+purgeCriteria.Operation__c +' '+purgeCriteria.Value__c + ' AND ';
                }
            }
            strQuery = strQuery.left(strQuery.lastIndexOf(' AND '));
        }
        else {
            //Construct query that doesn't return any records by appending LIMIT 0 for else part.
            strQuery += ' LIMIT 0';
            String exceptionSummary = 'Configuration not found';
            String exceptionDetails = 'Configuration for purging ' + strObjectName + ' is not found in the Purge_Configuration__c custom setting.';   
            ErrorLogger.writeError('SFDC', strObjectName, 'Batch_GenericPurger.start()', 'NO_DATA_FOUND', exceptionSummary, exceptionDetails); // #RQ-005636
        }
        system.debug('##### strQuery --> '+ strQuery);
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext BC, list<sObject> scope) {
        try {            
            if(scope != null) {
                if(delFiles || delHerokuEmails){
                    set<id> sIdSet = new set<id>();
                    for(sobject s:scope){
                        sIdSet.add(s.id);
                    }
                    
                    if(delHerokuEmails){
                        Set<Id> emailIdSet=ArchivedCaseDeleter.retrieveExtEmailIds(sIdSet);
                        ExtDataSourceUtility.deleteRows(sIdSet); // deletes heroku emails
                        if(!emailIdSet.isEmpty()){
                            ArchivedCaseDeleter.deleteFiles(emailIdSet); // delete files related to archived emails
                        }
                        set<id> emailset = new set<id>();
                        for(emailmessage e :[select id from emailmessage where parentid =:sIdSet]){
                            emailset.add(e.id);
                        }
                        if(!emailset.isEmpty()){
                            ArchivedCaseDeleter.deleteFiles(emailset); // delete files related to emails
                        }
                    }
                    if(delfiles){
                        ArchivedCaseDeleter.deleteFiles(sIdSet); // delete files related to object records getting deleted
                    }
                }
                delete scope;
                DataBase.emptyRecycleBin(scope);
            }
        }
        catch(Exception e) {
            System.debug(Logginglevel.ERROR, 'Exception! ' + e.getMessage());
            ErrorLogger.writeErrors('SFDC', strObjectName, 'Batch_GenericPurger.execute()', new list<Exception>{e}); // #RQ-005636          
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    public class ObjectNameNotSpecifiedException extends Exception {}
    
}