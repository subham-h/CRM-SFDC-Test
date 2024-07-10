/*
Description  : Perform callout to send EmailMessageID and CaseID to IDA to identify Customer name and SO number from Attachments 

* version       Date                Owner                         Description
*******************************************************************************************************************
* V1.0          22/11/2022          Vivek@maersk                  SC-5430- Perform callout to send CaseDetails to IDA
*-------------------------------------------------------------------------------------------------------------------
*/
public class FilesIntegrationWithIDA {
    
    public static void fetchEmailMessageDetails(EmailRecordSelector emailRecSelector){
        Map<Id,Id> caseEmailMap = new Map<Id,Id>();
        Map<Id,Case> caseMap = new Map<Id,Case>();
        List<EmailMessage> emails=new List<EmailMessage>();
        emails = emailRecSelector.emailRecords;
        caseEmailMap = emailRecSelector.emailCaseIdMap;
        caseMap = emailRecSelector.mapRelatedCases;
        Id externalCaseRTId = StaticFactory.getRecordTypeIdByName('Case', Label.External_Case);
        General_Key_Value_Configurations__mdt originValues = General_Key_Value_Configurations__mdt.getInstance('IDAOriginFieldCriteria');

        try{
            for(EmailMessage email : emails){
                if(!caseMap.isEmpty() && caseMap.containsKey(caseEmailMap.get(email.Id))){
                    Case caseToUpdate = caseMap.get(caseEmailMap.get(email.Id));
                    //recursion method to run the furture method only once per case.
                    if(email.Incoming && caseToUpdate.RecordTypeId == externalCaseRTId && caseToUpdate.Count_Case_Emails__c <= 1 && caseToUpdate.Product__c == 'SCM' && caseToUpdate.case_channel__c == 'E-mail' && !String.isEmpty(caseToUpdate.Origin) && ((caseToUpdate.Origin.startsWith('SCM') && caseToUpdate.Origin.endsWith('SVC') && originValues.First_Field_Value__c == 'True' ) ||( originValues.First_Field_Value__c == 'False' && originValues.Second_Field_Value__c.contains(caseToUpdate.Origin))) && Generic_TriggerHandler.validateRunForMethod('FilesIntegrationWithIDA.sendCaseDetailsToIDA()', 1)){                              
                        CaseWrapper caseRecs = new CaseWrapper(); 
                        caseRecs.caseId = caseToUpdate.Id;
                        caseRecs.emailMessageId = email.Id;
                        String strBody = JSON.serialize(caseRecs);
                        sendCaseDetailsToIDA(strBody, email.Id);
                    }
                }
            }
        }catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'FilesIntegrationWithIDA.fetchEmailMessageDetails', new list<Exception>{ex});  
        }
    }
    
    @future(callout=true)
    public static void sendCaseDetailsToIDA(String strBody, String emailId) {
        ErrorStormHandler.skipErrorStormCheck(true);
        List<EmailMessage> emMsgList = new List<EmailMessage>([Select Id, HasAttachment From EmailMessage Where Id =: emailId AND HasAttachment = true]);
        if(!emMsgList.isEmpty() || Test.isRunningTest()){
            string strObjectName = 'IDAIntegrationForFilesWorkFlow';
            string strModuleName = 'getCaseEmailDetails';
            AO_Services__mdt aoServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName,strModuleName);               
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST'); 
            req.setHeader('Accept','application/json');
            req.setHeader('content-type', 'application/json;type=entry;charset=utf-8'); 
            req.setHeader('Consumer-Key', AOServiceDetail.Authorization_Key__c);
            req.setTimeout(Integer.valueof(aoServiceDetail.Timeout__c));
            req.setEndpoint(aoServiceDetail.End_point_URL__c);
            req.setbody(strBody);
            String res;
            try{  
                res = AO_APILoginUtility.sendRequest(req,AOServiceDetail);
                if(res.contains(Label.Token_Validation_Failed)){    
                    Cache.Org.put('FRToken'+AOServiceDetail.Environment__c+AOServiceDetail.Authorization_Key__c,'',300);
                    res = AO_APILoginUtility.sendRequest(req,AOServiceDetail);
                }
                
                //send the response to Platform event      
                filePEForIntegrationLog(res);
                
            }
            catch(Exception ex) {
                ErrorLogger.writeErrors( 'SFDC', strObjectName, 'FilesIntegrationWithIDA.SendCaseDetailsToIDA', new list<Exception>{ex});
            }
        }
        
    }
    
    public class CaseWrapper{        
        public Id caseId;
        public Id emailMessageId;
        
        public CaseWrapper(){
            caseId = this.caseId;
            emailMessageId = this.emailMessageId;
        }
    }
    
    public static void filePEForIntegrationLog(String response){
        List<Integration_Log_Event__e> thisEventList = new List<Integration_Log_Event__e>();
        Integration_Log_Event__e thisEvent = new Integration_Log_Event__e();
        thisEvent.JSON_Response__c = response;
        thisEventList.add(thisEvent);
        
        EventBus.publish(thisEventList);
        System.debug('****event->'+thisEventList);
        
    }
}