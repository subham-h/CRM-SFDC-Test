/*
* Author    : Ranjan
* Purpose   : Test class for ExtEmailMessageViewer
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-5245     20-Jan-2023 Ranjan@Maersk            Created. 
* 2.0       SC-7179     16-Mar-2023 Ranjan@maersk            Modified the download downloadAttachment to just return the endpoint
*
*/
public without sharing class ArchivedCaseObjectsRelatedList {
    public class ResponseWrapper{
        @AuraEnabled
        public List < SObject > listRecords;
    }
    Public static List < SObject > mockedRecords; 
    public ArchivedCaseObjectsRelatedList(){
        ResponseWrapper resWrapperObj=new ResponseWrapper();
        resWrapperObj.listRecords=new List<sobject>();
        mockedRecords=resWrapperObj.listRecords;
    }
    @AuraEnabled( cacheable=true ) 
    public static ResponseWrapper fetchInitData(String recId, String objectName,String pageName){
        ResponseWrapper resWrapObj=new ResponseWrapper();
        List<Archived_Case__c> casObjList;
        List<emailmessagearchival__x> emailArchived;
        if(pageName=='case'){
            casObjList=[select id,CreatedDate,Case_Id__c from Archived_Case__c where id=:recId];
        }else{
            emailArchived=(Test.isRunningTest()?mockedRecords:[
            SELECT  Id,
                    heroku_id__c
            FROM emailmessagearchival__x
            WHERE  id=:recId]);
        }
        if(objectName=='Approvalrequestarchival__x'){
            resWrapObj.listRecords= (Test.isRunningTest()?mockedRecords: (List<sObject>)[
            SELECT Id, SfId__c,name__c,
                   requested_amount_c__c,
                   approved_amount_c__c,
                   sfdc_approver_c__c,
                   self_approved_c__c,
                   non_sfdc_approver_c__c,
                   approval_status_c__c
            FROM Approvalrequestarchival__x
            WHERE  case_c__c=:casObjList.get(0).Case_Id__c]);
        }else if(objectName=='Attchmentarchival__x' && pageName=='case' ){
            resWrapObj.listRecords= (Test.isRunningTest()?mockedRecords: (List<sObject>)[
            SELECT  Id, SfId__c,
                    blob_url__c,
                    bodylength__c,
                    contenttype__c,
                    name__c
                FROM Attchmentarchival__x
                WHERE parentid__c=:casObjList.get(0).Case_Id__c]);
        }else if(objectName=='Attchmentarchival__x' && pageName=='email' ){
            resWrapObj.listRecords= (Test.isRunningTest()?mockedRecords: (List<sObject>)[
            SELECT  Id, SfId__c,
                    blob_url__c,
                    bodylength__c,
                    contenttype__c,
                    name__c
            FROM Attchmentarchival__x
            WHERE parentid__c=:emailArchived.get(0).heroku_id__c]);
        }else if(objectName=='Bookinginformationarchival__x'){
            resWrapObj.listRecords= (Test.isRunningTest()?mockedRecords: (List<sObject>)[
            SELECT  Id, SfId__c, 
                    name__c, 
                    booking_number_c__c,
                    bill_of_lading_number_c__c
            FROM Bookinginformationarchival__x
            WHERE  related_case_c__c=:casObjList.get(0).Case_Id__c]);
        }else if(objectName=='Casecommentarchival__x'){
            resWrapObj.listRecords= (Test.isRunningTest()?mockedRecords: (List<sObject>)[
            SELECT Id,
                   commentbody__c, 
                   SfId__c,
                   createddate__c,
                   createdbyid__c
            FROM Casecommentarchival__x
            WHERE  parentid__c=:casObjList.get(0).Case_Id__c]);
        }else if(objectName=='Casehistoryarchival__x'){
            resWrapObj.listRecords= (Test.isRunningTest()?mockedRecords: (List<sObject>)[
            SELECT  Id, SfId__c,
                    createddate__c,
                    field__c,
                    createdbyid__c,
                    oldvalue__c,
                    newvalue__c
            FROM Casehistoryarchival__x
            WHERE  caseid__c=:casObjList.get(0).Case_Id__c]);
        }else if(objectName=='Financialdetailsarchival__x'){
            resWrapObj.listRecords= (Test.isRunningTest()?mockedRecords: (List<sObject>)[
            SELECT Id, SfId__c,
                   usd_amount_c__c,
                   type_c__c,
                   conversion_date_c__c,
                   local_amount_c__c,
                   local_currency_c__c
            FROM Financialdetailsarchival__x
            WHERE  claim_c__c=:casObjList.get(0).Case_Id__c]);
        }else if(objectName=='Livechatarchival__x'){
            resWrapObj.listRecords= (Test.isRunningTest()?mockedRecords:(List<sObject>) [
            SELECT Id, SfId__c,
                   name__c,
                   body__c,
                   ownerid__c,
                   starttime__c,
                   endtime__c,
                   status__c
            FROM Livechatarchival__x
            WHERE  caseid__c=:casObjList.get(0).Case_Id__c]);
        }else if(objectName=='emailmessagearchival__x'){
            resWrapObj.listRecords= (Test.isRunningTest()?mockedRecords: (List<sObject>)[
            SELECT  Id,
                    heroku_id__c, 
                    subject__c,
                    toaddress__c,
                    fromaddress__c,
                    fromname__c,
                    messagedate__c,
                    status__c
            FROM emailmessagearchival__x
            WHERE  parentid__c=:casObjList.get(0).Case_Id__c]);
        }
        

        return resWrapObj;
    }

    @AuraEnabled( cacheable=false )
    public static String downloadAttachment(){
        Archival_Config__mdt mdtObj = ExtDataSourceUtility.getArchivalMetadata('Attachment Archival');
        return mdtObj.Search_Parameter__c;
    }

    //For displaying the columns in archivedCases lwc component 
    @AuraEnabled(Cacheable = true)
    public static list<Archived_Case__c> fetchCaseDetails(String recordId) {    
        return ArchivedCaseFetcher.fetchCaseDetails(recordId);
    }
}