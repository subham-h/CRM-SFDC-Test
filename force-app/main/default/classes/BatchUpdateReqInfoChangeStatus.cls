/*

Note: This batch class is to fix Change Status on Migrated Request Contact based on Original Request Contacts.

* version       Date              Owner                                    Description
*******************************************************************************************************
* V1.0          28/04/2018        Nitin                                    Code created
* V2.0          15/07/2019        Junaid.Khader@Ust-Global.com             RQ-010654: Removed reference of field Z_No_of_Request_Routes__c which is deprecated.
*/
global class BatchUpdateReqInfoChangeStatus implements Database.Batchable<SObject>{

    global Database.queryLocator start( Database.BatchableContext ctx ) {
        String strRecordTypeRequest = Schema.SObjectType.Request__c.getRecordTypeInfosByName().get( Label.RateSheetRequestRecordType ).getRecordTypeId();
        
        // fetch all Rate Sheet Requests
        String strQuery = 'SELECT Account_SCV_Code__c, Legacy_Request_Number__c, Migrated_From_Request_Route_Id__c, Name, Status__c'; 
            strQuery += ' FROM Request__c ';
            strQuery += ' WHERE Legacy_Request_Number__c = null';
            strQuery += ' AND Migrated_From_Request_Route_Id__c != null';
            strQuery += ' AND RecordTypeId = \'' + strRecordTypeRequest + '\'';
        
        if ( Label.RequestInformationChangeStatusUpdateWhereClause != 'Not Applicable' && !Test.isRunningTest() ){
            strQuery += ' AND ' + Label.RequestInformationChangeStatusUpdateWhereClause;
        }
        
        System.debug(' # strQuery: ' + strQuery);
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute( Database.BatchableContext BC, List<sObject> scope ) {
        
        List<Request__c> lstReqOriginal = ( List<Request__c> ) scope;   
        String strRecordTypeReqInformation = Schema.SObjectType.Request_Information__c.getRecordTypeInfosByName().get(Label.RequestDetail_ContactRecordType).getRecordTypeId();
        List<String> lstRequestIdORG = new List<String>();

        for (Request__c req : lstReqOriginal){
            lstRequestIdOrg.add(req.Id);
        }

        //System.debug('# lstRequestIdOrg size:' + lstRequestIdOrg.size());

        List<Request_Information__c> lstRCOriginalRequest = [SELECT Change_Status__c,Contact__c, User__c, Id, Name, Request__c 
                                        FROM Request_Information__c 
                                        Where Request__c in :lstRequestIdOrg
                                        AND RecordTypeId = :strRecordTypeReqInformation];

        //System.debug('# lstRCOriginalRequest size :' + lstRCOriginalRequest.size());

        Map<String, String> mapOrgReqIdRecCONTACTIdToRecInfoChngStatus = new Map<String, String>();
        Map<String, String> mapOrgReqIdRecUSERIdToRecInfoChngStatus = new Map<String, String>();

        for (Request_Information__c ri : lstRCOriginalRequest ){
        
            if (ri.Contact__c != null) {
                String strReqIdANDRecCONTACTId = String.valueOf(ri.Request__c) + String.valueOf(ri.Contact__c);
                mapOrgReqIdRecCONTACTIdToRecInfoChngStatus.put(strReqIdANDRecCONTACTId, ri.Change_Status__c);
            }
         
            if (ri.User__c != null) {
                String strReqIdANDRecUSERId = String.valueOf(ri.Request__c) + String.valueOf(ri.User__c);
                mapOrgReqIdRecUSERIdToRecInfoChngStatus.put(strReqIdANDRecUSERId, ri.Change_Status__c);
            }
             
        }

        System.debug('# mapOrgReqIdRecCONTACTIdToRecInfoChngStatus  :' + mapOrgReqIdRecCONTACTIdToRecInfoChngStatus);
        System.debug('# mapOrgReqIdRecUSERIdToRecInfoChngStatus  :' + mapOrgReqIdRecUSERIdToRecInfoChngStatus);

        //get list of migrated Contacts from migrated Requests
        List<Request_Information__c> lstReqCONTACTMigratedRequest = [SELECT Change_Status__c,Contact__c, User__c, Id, Name, Request__c, Request__r.Legacy_Request_Number__c
                                            FROM Request_Information__c 
                                            Where Request__r.Legacy_Request_Number__c in :lstRequestIdOrg
                                            AND Request__r.Migrated_From_Request_Route_Id__c != null 
                                            AND Change_Status__c = 'New'
                                            AND RecordTypeId = :strRecordTypeReqInformation];
            
        //System.debug('# lstRCMigratedRequest size :' + lstRCMigratedRequest.size());

        for (Request_Information__c rm : lstReqCONTACTMigratedRequest ){
                
            if (rm.Contact__c != null){
                String strRCMigratedLegacyReqContact = String.valueOf(rm.Request__r.Legacy_Request_Number__c) + String.valueOf(rm.Contact__c);
                String strOrgContactChangeStatus = mapOrgReqIdRecCONTACTIdToRecInfoChngStatus.get(strRCMigratedLegacyReqContact);
                rm.Change_Status__c = strOrgContactChangeStatus;
            }
            
            if (rm.User__c != null) {
                String strRCMigratedLegacyReqUser = String.valueOf(rm.Request__r.Legacy_Request_Number__c) + String.valueOf(rm.User__c);
                String strOrgUserChangeStatus = mapOrgReqIdRecUSERIdToRecInfoChngStatus.get(strRCMigratedLegacyReqUser);
                rm.Change_Status__c = strOrgUserChangeStatus;
            }
        }

        TriggerExecutionController.skipAllTriggers (true);
         
        //database.update(lstReqCONTACTMigratedRequest, false);
        update lstReqCONTACTMigratedRequest;
        
        TriggerExecutionController.skipAllTriggers (false); 
    }
   
    global void finish(Database.BatchableContext BC){
            
    }
    
}