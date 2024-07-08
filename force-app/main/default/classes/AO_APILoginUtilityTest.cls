/**
 * Test class for AO_APILoginUtility
 * 
 * Version  Date         Owner                   RQ#           Description
 *******************************************************************************************************************
 * 1.0                                                         Class created
 * 2.0      28/06/2022   Ronnie@SF               SPI-100       Removed brand operator code hardcoding
 */

@isTest
public class AO_APILoginUtilityTest {
    
    @isTest static void testGetLoginIdToken() {
        Test.setMock(HttpCalloutMock.class, new AO_ServiceHttpCalloutMock()); 
        string strObjectName = 'Tracking';
        string modulename = 'getContainerDetails';
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename);
        string accessToken = AO_APILoginUtility.getLoginIdToken(BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase(), AOServiceDetail);
    }
    
    @isTest static void testGetFRToken() {
        Test.setMock(HttpCalloutMock.class, new AO_ServiceHttpCalloutMock()); 
        string strObjectName = 'Tracking';
        string modulename = 'getContainerDetails';
        General_Key_Value_Configurations__mdt akamaiHeaderTest = General_Key_Value_Configurations__mdt.getInstance('AkamaiRequestHeader');
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename);
        string accessToken = AO_APILoginUtility.getFRToken(AOServiceDetail);
    }
    
     @isTest static void testGetFRTokenMyFinance() {
        Test.setMock(HttpCalloutMock.class, new AO_ServiceHttpCalloutMock()); 
        string strObjectName = 'Tracking';
        string modulename = 'getContainerDetails';
        General_Key_Value_Configurations__mdt akamaiHeaderTest = General_Key_Value_Configurations__mdt.getInstance('AkamaiRequestHeader');
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename);
        string accessToken = AO_APILoginUtility.getFRToken(AOServiceDetail);
    }
    
    @isTest static void testSendRequest() {
        Test.setMock(HttpCalloutMock.class, new AO_ServiceHttpCalloutMock()); 
        string strObjectName = 'Tracking';
        string modulename = 'getContainerDetails';
        General_Key_Value_Configurations__mdt akamaiHeaderTest = General_Key_Value_Configurations__mdt.getInstance('AkamaiRequestHeader');
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename);
        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Atmosphere '+ 'atmosphere_app_id='+AOServiceDetail.Authorization_Key__c);
        req.setTimeout(Integer.valueof(AOServiceDetail.Timeout__c));
        req.setEndpoint(AOServiceDetail.End_point_URL__c + '?operator=' + BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase());
        string accessToken = AO_APILoginUtility.sendRequest(req,AOServiceDetail);        
        string accessToken1 = AO_APILoginUtility.sendAzureOHPRequest(req,AOServiceDetail);
    }
    
    @isTest static void testSendWriteBackRequest() {
        Test.setMock(HttpCalloutMock.class, new AO_ServiceHttpCalloutMock()); 
        String strObjectName = 'Equipment';
        String strModuleName = 'deleteEquipment';
        // Getting the Endpoint and Security details from metadata.
        GCSS_Write_Back_Services__mdt gcssSWBDetail = WebserviceUtilities.getGCSSWriteBackMetadataValue(strObjectName,strModuleName);
        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Atmosphere '+ 'atmosphere_app_id='+gcssSWBDetail.Authorization_Key__c);
        req.setTimeout(Integer.valueof(gcssSWBDetail.Timeout__c));
        req.setEndpoint(gcssSWBDetail.End_point_URL__c + '?operator=' + BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase());
        string accessToken = AO_APILoginUtility.sendWriteBackRequest(req,gcssSWBDetail);
    }
    
    @isTest static void testSendTMSRequest() {
        Test.setMock(HttpCalloutMock.class, new AO_ServiceHttpCalloutMock()); 
        
        string strObjectName = 'InlandTMS';
        string modulename = 'getInlandTMS';
        
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename); 
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Atmosphere '+ 'atmosphere_app_id='+AOServiceDetail.Authorization_Key__c);
        req.setTimeout(Integer.valueof(AOServiceDetail.Timeout__c));
        req.setEndpoint(AOServiceDetail.End_point_URL__c + '?operator=' + BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase());
        string accessToken = AO_APILoginUtility.sendTMSRequest(req,AOServiceDetail);   
    }
}