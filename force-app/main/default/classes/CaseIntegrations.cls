/*
* Author   : Jiji
* Purpose  : Utility class to hold integration with external services. 
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-002679   08-Apr-2016 Jiji@UST                To handle GCSS integration for Claim RT on AfterInsert and AfterUpdate.
* 2.0      RQ-004427   29-Nov-2016 Nisha@UST               Connection errors to the ESB are logged in the source system error fields.
* 3.0      RQ-005636   26-Sep-2017 Nisha@UST               Update references of GlobalErrorLogger
* 4.0      RQ-007793   07-Feb-2018 Meenakshi@UST           RQ-007793 ESB service calls from salesforce through USI - New URL 
* 5.0      RQ-010056   28-Feb-2019 moudas01@in.ibm.com     Fix for getting commodity details by passing recordtype id
* 6.0      SC-160      02-04-2020  Ramadevi@ust            Implemented Trigger recurrsion for few methods.
* 7.0      SC-2183     27-04-2021  Richa@maersk            To handle OHP Workflow integration for Dispute RT on AfterInsert and AfterUpdate.
* 8.0	   SC-9978	   06-May-2024	Richa@maersk		   Publish Cases through Custom Event framework
*/

public class CaseIntegrations {
    
    public static void GCSSIntegraionForClaims(list<Case> lstCases, String strObjectName , String strModuleName) {
        try {
            //SC-160 : Trigger Recurrsion controller
            //if(Generic_TriggerHandler.validateRunForMethod('CaseIntegrations.GCSSIntegraionForClaims()', 1)){
            // Custom Metadata Type to store webservice details
            ESB_Webservice__mdt esbServiceDetail = WebserviceUtilities.esbMetadataValue(strObjectName, strModuleName);
            String strHeader = WebserviceUtilities.getHeader(esbServiceDetail.Module__c, esbServiceDetail.OSB_Username__c, esbServiceDetail.Password__c); // Generate XML header
            String strFooter = WebserviceUtilities.getFooter(); // Generate XML footer
            String strBody = formRequestBody(esbServiceDetail, lstCases, strObjectName, strModuleName); // Generate XML body
            String strXMLRequest = strHeader + strBody + strFooter; // Generate complete XML
            System.debug('GCSSIntegraionForClaims.strXMLRequest: ' + strXMLRequest);
            
            // Invoke the webservice
            // v2.0 - Added additional parameters (Object name and set of ids to the WebserviceUtilities.sendHTTPRequest)
            WebserviceUtilities.sendHTTPRequest(strXMLRequest, String.valueof(esbServiceDetail.Timeout__c),esbServiceDetail.End_point_URL__c, 'Case', SObjectUtilities.getIds(lstCases));
            //}
        }
        catch(Exception e) {
            System.debug(Logginglevel.ERROR, 'Exception! ' + e.getMessage());
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseIntegrations.GCSSIntegraionForClaims', new list<Exception>{e}); // #RQ-005636  
        }
    }
    
    // Form XML body required for Exchange Rate Integration from the sObject record list passed.
    // The fields names to be retrieved from custom metatdata type 'Webservice Field List' based on the order field.
    public static String formRequestBody(ESB_Webservice__mdt esbServiceDetail, List<sObject> lstObjects, String strObjectName, String strModuleName) {
        String strXMLStart = '<v21:TransportDocumentDetailsRequestInfo xmlns:v21="http://services.apmoller.net/AMM/UpsertEquipmentCommodity/v1">';
        String strXMLEnd = '</v21:TransportDocumentDetailsRequestInfo>';
        map<Integer, Webservice_Field_List__mdt> mapFieldList = WebserviceUtilities.getWebServiceFieldMetadataValue(strObjectName, strModuleName);
        Id commodityRecTypeId =  (ID)Schema.SObjectType.Equipment_Commodity__c.getRecordTypeInfosByName().get('Commodity').getRecordTypeId(); // RQ-010056
        
        // Iterate sObject to get the field details of corresponding object
        String strXMLBody = '';
        for(sObject sObj : lstObjects ) {
            String strObjectTag =   '<v21:GetTransportDocumentDetailsRequest>' +
                '<v21:CaseID>' + getXMlMapping(1, sObj, mapFieldList) + '</v21:CaseID>' + // Case Id
                '<v21:TransportDocumentNumber>' + getXMlMapping(2, sObj, mapFieldList) + '</v21:TransportDocumentNumber>' + // BoL Number
                '<v21:EquipmentCommodityRecordTypeId>' + commodityRecTypeId + '</v21:EquipmentCommodityRecordTypeId>' + // Equipement Commodity Record Type Id (RQ-010056)
                '</v21:GetTransportDocumentDetailsRequest>';
            
            // Append the parameter details to a string
            strXMLBody = strXMLBody + strObjectTag;
        }
        return strXMLStart + strXMLBody + strXMLEnd;
    }
    
    /** 
* @description | SC-9978 - Prepare Records to be published to Kafka
* @param mapCases accepts key value pair of Case Ids and combination of transactiontype and event type
* @param eventNotificationName accepts the notification name of the event - live/async
*/
    public static void publishCases(Map<Id,EventTypeWrapper> mapCases,String eventNotificationName){
        try{            
            Map<String,String> mapOfTopic = new Map<String,String>();
            if(!mapCases.isEmpty()){ 
                Producer_Platform_Event_Config__mdt evtMdt = Producer_Platform_Event_Config__mdt.getInstance('Case_Event');
                if(evtMdt != null){
                    mapOfTopic.put(evtMdt.DeveloperName, evtMdt.Topic_Name__c);
                    createCaseEvent(mapCases,mapOfTopic,eventNotificationName);   
                }
            }
        }catch(Exception ex){   
            ErrorLogger.writeError( 'SFDC', 'Case', 'CaseIntegrations.publishCases',ex.getTypeName(),ex.getMessage(),JSON.serialize(mapCases.keySet()));
        }        
    }
    
    /** 
* @description | SC-2183/SC-9978 - Create custom event record to publish cases to Kafka
* @param mapCases accepts key value pair of Case Ids and combination of transactiontype and event type
* @param mapOfTopic accepts Kafka Topic name
* @param eventNotification accepts the notification name of the event - live/async
*/
    public static void createCaseEvent(Map<Id,EventTypeWrapper> mapCases,Map<String,String> mapOfTopic,String eventNotification) {
        List<CaseEventResponseWrapper.Results> lstOfResponse = new List<CaseEventResponseWrapper.Results> ();
        List<Custom_Event__c> lstCaseCustomEvent= new List<Custom_Event__c>();
        try{
            if(!mapCases.isEmpty()){
                lstOfResponse= CaseEventResponseWrapper.prepareCaseEventData(mapCases);
                
                if(!lstOfResponse.isEmpty() && lstOfResponse != Null){
                    for(CaseEventResponseWrapper.Results result: lstOfResponse){
                        if(result.serializedJSON1!= null){
                            lstCaseCustomEvent.add(CustomEventUtility.createCustomEvent(result,mapOfTopic,eventNotification));
                        }
                    }
                }                
                if(lstCaseCustomEvent != null && lstCaseCustomEvent.size() >0){            
                    insert lstCaseCustomEvent;           
                }
            }
        }catch(Exception ex){   
            ErrorLogger.writeError( 'SFDC', 'Case', 'CaseIntegrations.createCaseEvent',ex.getTypeName(),ex.getMessage(),JSON.serialize(mapCases.keySet()));
        }        
    }
    
    
    
    // Retrive values baed on custom metdata mapping 
    static String getXMlMapping(Integer i, sObject sObj, map<Integer, Webservice_Field_List__mdt> mapFieldList) {
        String xmlMapping = String.valueof(mapFieldList.get(i).Type__c == 'Field' ? sObj.get(mapFieldList.get(i).Value__c) : (String)mapFieldList.get(i).Value__c);
        return xmlMapping;
    }   
    
}