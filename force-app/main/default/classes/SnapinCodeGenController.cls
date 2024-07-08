/*
 * Author   : Pete Ryan
 * Purpose  : Controller for SnapinCodeGen VF
 *        
 * Revision Ref Number            Date        Owner                   Description
 * -------- --------------------  ----------- -------------------     -----------
 * 1.0      RQ-008801/RQ-008799   12-Jul-2018 Pete@UST                Created.
 * 2.0      RQ-010291             21-Mar-2018 naved@maersk            Update code for genrating Mobile Json                          
 *  
 */
public with sharing class SnapinCodeGenController {
    
    public static final String LOGMARK = '##### SnapinCodeGenController : ';
    public static  String MobileJson ;//=' "preChatSetupInfo":[{ "entityFieldMaps": [{ "doCreate": false, "doFind": false, "fieldName": "LastName", "isExactMatch": false, "label": "Last Name" }, { "doCreate": false, "doFind": false, "fieldName": "FirstName", "isExactMatch": false, "label": "First Name" }, { "doCreate": false, "doFind": true, "fieldName": "Email", "isExactMatch": true, "label": "Email" }], "entityName": "Contact", "showOnCreate": true, "linkToEntityName": "Case", "linkToEntityField": "ContactId", "saveToTranscript": "ContactId" }, { "entityFieldMaps": [{ "doCreate": true, "doFind": false, "fieldName": "RecordTypeId", "isExactMatch": false, "label": "CaseRecordType" }, { "doCreate": true, "doFind": false, "fieldName": "Status", "isExactMatch": false, "label": "CaseStatus" }, { "doCreate": true, "doFind": false, "fieldName": "Case_Channel__c", "isExactMatch": false, "label": "CaseChannel" }, { "doCreate": true, "doFind": false, "fieldName": "Subject", "isExactMatch": false, "label": "CaseSubject" }, { "doCreate": true, "doFind": false, "fieldName": "SuppliedEmail", "isExactMatch": false, "label": "Email" }, { "doCreate": true, "doFind": false, "fieldName": "Origin", "isExactMatch": false, "label": "CaseOrigin" }, { "doCreate": true, "doFind": false, "fieldName": "Type", "isExactMatch": false, "label": "CaseType" }, { "doCreate": true, "doFind": false, "fieldName": "Direction__c", "isExactMatch": false, "label": "CaseDirection" }, { "doCreate": true, "doFind": false, "fieldName": "Liner_Brand__c", "isExactMatch": false, "label": "CaseLinerBrand" }, { "doCreate": true, "doFind": false, "fieldName": "Portal_On_Behalf_Of__c", "isExactMatch": false, "label": "PortalOnBehalfOf" }], "entityName": "Case", "saveToTranscript": "CaseId", "showOnCreate": true }]}'; 
    public string strJson{get;set;}
    // Generate Javascript from a template using Snapin info
    public PageReference regenerate() {
        if (validRegenerateForm()) {
            sdh.calloutCount = 0;
            sdh.getMoreEsla();
            sdh.eslaOrgInf.listEsla = sdh.listEsla;
          //  strJson = sdh.eslaOrgInfoJson.substring(0,sdh.eslaOrgInfoJson.length()-1)+','+MobileJson;
           
           
            
        }
        return null;
    }
    
    public PageReference deleteSnapins() {
        sdh.calloutCount = 0;
    sdh.deleteSnapins();
        return null;
    }
    
    public PageReference createSnapins() {
        if (validCreateSnapinsForm()) {
            sdh.calloutCount = 0;
      sdh.createSnapins();
        }
        return null;
    }
    
    private Boolean validCreateSnapinsForm() {
        apexPages.getMessages().clear();
        if (String.isBlank(sdh.eslaOrgInf.siteName)) {
             apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'siteName required!'));
        }
        return !apexPages.hasMessages();
    }
    
    private Boolean validRegenerateForm() {
        apexPages.getMessages().clear();

        System.debug(Logginglevel.DEBUG, LOGMARK + 'validRegenerateForm - sdh.eslaOrgInf.orgId=' + sdh.eslaOrgInf.orgId);
        System.debug(Logginglevel.DEBUG, LOGMARK + 'validRegenerateForm - sdh.eslaOrgInf.envUrl=' + sdh.eslaOrgInf.envUrl);
        System.debug(Logginglevel.DEBUG, LOGMARK + 'validRegenerateForm - sdh.eslaOrgInf.siteUrl=' + sdh.eslaOrgInf.siteUrl);
        System.debug(Logginglevel.DEBUG, LOGMARK + 'validRegenerateForm - sdh.eslaOrgInf.baseLiveAgentContentUrl=' + sdh.eslaOrgInf.baseLiveAgentContentUrl);
        System.debug(Logginglevel.DEBUG, LOGMARK + 'validRegenerateForm - sdh.eslaOrgInf.baseLiveAgentUrl=' + sdh.eslaOrgInf.baseLiveAgentUrl);
        System.debug(Logginglevel.DEBUG, LOGMARK + 'validRegenerateForm - sdh.eslaOrgInf.eswJsSource=' + sdh.eslaOrgInf.eswJsSource);
        System.debug(Logginglevel.DEBUG, LOGMARK + 'validRegenerateForm - sdh.eslaOrgInf.siteName=' + sdh.eslaOrgInf.siteName);
        
        if (String.isBlank(sdh.eslaOrgInf.orgId) || String.isBlank(sdh.eslaOrgInf.envUrl) || 
            String.isBlank(sdh.eslaOrgInf.siteUrl) || String.isBlank(sdh.eslaOrgInf.baseLiveAgentContentUrl) || 
            String.isBlank(sdh.eslaOrgInf.baseLiveAgentUrl) || String.isBlank(sdh.eslaOrgInf.eswJsSource) || String.isBlank(sdh.eslaOrgInf.siteName)) {
             apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'All fields required!'));
        }
        return !apexPages.hasMessages();
    }
    
    // Only show code if all Snapin info is included
    public String javaSriptCode {
        get {
          
            if (sdh.complete) {
                return mobilesnapinCode();
            }
            return null; 
        }
        
        set;
    }
    public string mobilesnapinCode(){
        for (StaticResource sr: [SELECT Id, Name, Body from StaticResource WHERE Name = 'SnapinCodeTemplate' LIMIT 1]) {
                  MobileJson = sr.Body.toString().substring(sr.Body.toString().indexof('extraPrechatInfo ='),sr.Body.toString().indexof('embedded_svc.init') );
                  system.debug('MobileJson###'+MobileJson.substring(0,MobileJson.length()-1));
                  MobileJson = MobileJson.remove('"siteUrl"');
                  MobileJson=  MobileJson.replace('extraPrechatInfo = ','"preChatSetupInfo":');
                  MobileJson=  MobileJson.replace(';','}');
                  strJson = sdh.eslaOrgInfoJson.substring(0,sdh.eslaOrgInfoJson.length()-1)+','+MobileJson;
                  SnapInMobileJSONtoApex obj = SnapInMobileJSONtoApex.parse(strJson);
                  system.debug('obj '+obj );
                  strJson = JSON.serialize(obj );
                  return sr.Body.toString().replace('[GENERATEDJSON]', sdh.eslaOrgInfoJson);    
                }         
        return null;
    }
    public SnapInDataHelper sdh {
        get {
            if (sdh == null) {
                sdh = new SnapInDataHelper();
            }
            return sdh;
        }
        set;
    }
    
    public String eslaOrgInfo {
        get {
            eslaOrgInfo = sdh.eslaOrgInfoJson;
            system.debug('eslaOrgInfo###'+eslaOrgInfo);
            return eslaOrgInfo;
        }
        set;
    }

}