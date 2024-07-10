/*
* Author    : Ranjan
* Purpose   : Class to get the Archived email body
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-5245     16-Aug-2022 Ranjan@Maersk            Created. 
* 
*
*/
public with sharing class ExtEmailMessageViewer {
    Public static emailmessagearchival__x mockedRecords; 
    public ExtEmailMessageViewer(){
        mockedRecords =new emailmessagearchival__x();
    }
    @AuraEnabled(cacheable=true)
    public static emailmessagearchival__x getExtEmailMessage(Id emailMesRecordId) {
        return (Test.isRunningTest()?mockedRecords: [
            SELECT Id, htmlbody__c,toaddress__c,fromaddress__c,fromname__c
            FROM emailmessagearchival__x
            WHERE  Id=:emailMesRecordId
        ]);
    }
}