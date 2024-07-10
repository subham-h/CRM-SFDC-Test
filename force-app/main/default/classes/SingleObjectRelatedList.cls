/*
* Author    : Ranjan
* Purpose   : Class to Archived email records
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-5245     7-Nov-2022 Ranjan@Maersk            Created. 
* 
*
*/
public with sharing class SingleObjectRelatedList {
    public class ResponseWrapper{
        @AuraEnabled
        public List < SObject > listRecords;
    }
    Public static List < SObject > mockedRecords; 
    public SingleObjectRelatedList(){
        ResponseWrapper resWrapperObj=new ResponseWrapper();
        resWrapperObj.listRecords=new List<sobject>();
        mockedRecords=resWrapperObj.listRecords;
    }
    @AuraEnabled( cacheable=true ) 
    public static ResponseWrapper fetchInitData(String recId){
        ResponseWrapper resWrapObj=new ResponseWrapper();
        List<case> casObjList=[select id,CreatedDate from Case where id=:recId];
        /*if(casObjList!=null && !casObjList.isEmpty() && casObjList.get(0).CreatedDate.dateGMT().daysBetween(datetime.now().dateGMT())<=90){
            return resWrapObj;
        }*/
        resWrapObj.listRecords= (Test.isRunningTest()?mockedRecords: [
            SELECT Id,heroku_id__c, subject__c,toaddress__c,fromaddress__c,fromname__c,messagedate__c,status__c
            FROM emailmessagearchival__x
            WHERE  parentid__c=:recId
        ]);
        return resWrapObj;
    }
}