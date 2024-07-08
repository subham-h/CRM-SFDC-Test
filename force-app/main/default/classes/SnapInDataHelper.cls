/**
 * Author     : Pete Ryan
 * Purpose    : Used by SnapinCodeGen VF / SnapinCodeGenController delete/create snapins and generate Javascript code.
 * Desciption : Uses the tooling API to query meta data around chat buttons / live chat deplyments / 
 *              snapins to allow snapin deletion and ceration so that snapins are bounnd to existin active chat buttons.
 *        
 * Revision Ref Number            Date        Owner                   Description
 * -------- --------------------  ----------- -------------------     -----------
 * 1.0      RQ-008801/RQ-008799   12-Jul-2018 Pete@UST                Created.
 * 1.1                            23-Jul-2018 Pete@UST                changed langNameSet and lcbList to filter out LCBs with a Dev Name ending with a language
 * 1.2      RQ-012931             10-Jan-2020                         Updating label in Snapin  
 * 1.3      RQ-013026             10-feb-2020 Sunil@Maerk             Updating label in Snapin  for chat in progress header      
 * 1.4      SC-509                07-Jul-2020 Avinash@UST             Brand Alignment basis SFDC Summer Release
 * 1.5      SPI-100               27-Jun-2022 Ronnie@SF               Removed brand hardcoding
 */
public class SnapInDataHelper {
    
    public static final String LOGMARK = '##### SnapInDataHelper : ';
    string strid;
    public class SnapInDataHelperException extends Exception {}
    
    // version - Tooling API version to use
    public String version {
        get {
            if (version == null) {
                version = 'v47.0';
            }
            return version;
        }
        set;
    }
    
    // calloutLimit - Might need to reduce in some environments to get around CPU time limits
    public Integer calloutLimit {
        get {
            if (calloutLimit == null) {
                calloutLimit = 40;
            }
            return calloutLimit;
        }
        set;
    }

    public Integer calloutCount {
        get {
            if (calloutCount == null) {
                calloutCount = 50;
            }
            return calloutCount;
        }
        set;
    }

    @TestVisible
    private String baseUrl {
        get {
            if (baseUrl == null) {
                baseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/' + version + '/tooling/';
            }
            return baseUrl;
        }
        set;
    }
    
    @TestVisible
    private String queryAllEmbeddedServiceLiveAgent {
        get {
            if (queryAllEmbeddedServiceLiveAgent == null) {
                queryAllEmbeddedServiceLiveAgent = baseUrl + 'query?q=Select+Id,MasterLabel,EmbeddedServiceConfigId+from+EmbeddedServiceLiveAgent';
            }
            return queryAllEmbeddedServiceLiveAgent;
        }
        set;
    }

    // langNameSet - defines languages that may appear in live chat button names - to aid with excluding bad setup in an org
    public Set<String> langNameSet {
        get {
            if (langNameSet == null) {
                langNameSet = new Set<String>();                
       
//                langNameSet.add('Mediterranean');
//                langNameSet.add('Caribbean');
//                langNameSet.add('Continent');
//                langNameSet.add('Central_West_Africa');
//                langNameSet.add('Eastern_Africa');
//                langNameSet.add('MCC_CS_Sub_cluster_within_PRC');

                langNameSet.add('Chinese');
                langNameSet.add('English');
                langNameSet.add('French');
                langNameSet.add('Spanish');
                langNameSet.add('Japanese');
                langNameSet.add('Korean');
                langNameSet.add('Italian');
                langNameSet.add('Portuguese');
                langNameSet.add('Amharic');
                langNameSet.add('Swahili');
                langNameSet.add('Czech');
                langNameSet.add('Estonian');
                langNameSet.add('Hungarian');
                langNameSet.add('Latvian');
                langNameSet.add('Lithuanian');
                langNameSet.add('Polish');
                langNameSet.add('Russian');
                langNameSet.add('Slovak');
                langNameSet.add('Arabic');
                langNameSet.add('Bulgarian');
                langNameSet.add('Georgian');
                langNameSet.add('Hebrew');
                langNameSet.add('Romanian');
                langNameSet.add('Russian');
                langNameSet.add('Turkish');
                langNameSet.add('Ukrainian');
                langNameSet.add('Dutch');
                langNameSet.add('German');
                langNameSet.add('Vietnamese');
                langNameSet.add('Arabic');
                langNameSet.add('Finnish');
                langNameSet.add('Latvian');
                langNameSet.add('Danish');
                langNameSet.add('Norwegian');
                langNameSet.add('Swedish');
            }
            return langNameSet;
        }
        set;
    }
    
    // allEmbeddedServiceLiveAgent - Json response
    @TestVisible
    private String allEmbeddedServiceLiveAgent {
        get {
            if (allEmbeddedServiceLiveAgent == null) {
                if (!System.Test.isRunningTest()) {
                    HttpResponse res = getResp('GET', queryAllEmbeddedServiceLiveAgent);
                    allEmbeddedServiceLiveAgent = res.getBody();
                } else {
                    allEmbeddedServiceLiveAgent = getMockAPIResponse('GET', queryAllEmbeddedServiceLiveAgent);
                }
            }
            return allEmbeddedServiceLiveAgent;
        }
        set;
    }

    // getMockAPIResponse - returns mock tooling API query results
    public String getMockAPIResponse(String method, String query) {
        System.debug(Logginglevel.DEBUG, LOGMARK + 'getMockAPIResponse - query=' + query);
        if (query.contains('EmbeddedServiceConfig')) {
            return '{  "size" : 2,  "totalSize" : 2,  "done" : true,  "queryLocator" : null,  "entityTypeName" : "EmbeddedServiceConfig",  "records" : [ {    "attributes" : {      "type" : "EmbeddedServiceConfig",      "url" : "/services/data/v43.0/tooling/sobjects/EmbeddedServiceConfig/04I250000004FiYEAU"    },    "Id" : "04I250000004FiYEAU",    "DeveloperName" : "MSL_CS_AL_SI",    "MasterLabel" : "MSL_CS_AL_SI"  }, {    "attributes" : {      "type" : "EmbeddedServiceConfig",      "url" : "/services/data/v43.0/tooling/sobjects/EmbeddedServiceConfig/04I250000004FiZEAU"    },    "Id" : "04I250000004FiZEAU",    "DeveloperName" : "MSL_CS_DO_SI",    "MasterLabel" : "MSL_CS_DO_SI"  } ]}';
        } else if (query.contains('EmbeddedServiceLiveAgent') && query.contains('EmbeddedServiceConfigId')) {
            return '{  "size" : 1,  "totalSize" : 1,  "done" : true,  "queryLocator" : null,  "entityTypeName" : "EmbeddedServiceLiveAgent",  "records" : [ {    "attributes" : {      "type" : "EmbeddedServiceLiveAgent",      "url" : "/services/data/v43.0/tooling/sobjects/EmbeddedServiceLiveAgent/08h250000004FiYAAU"    },    "Id" : "08h250000004FiYAAU",    "Metadata" : {      "avatarImg" : null,      "customPrechatComponent" : null,      "embeddedServiceConfig" : "MSL_CS_DZ_SI",      "embeddedServiceQuickActions" : null,      "enabled" : true,      "fontSize" : "Medium",      "headerBackgroundImg" : null,      "isOfflineCaseEnabled" : false,      "isQueuePositionEnabled" : true,      "liveAgentChatUrl" : null,      "liveAgentContentUrl" : null,      "liveChatButton" : "MSL_CS_Algeria",      "liveChatDeployment" : "Maersk_Line",      "masterLabel" : "MSL_CS_DZ_SI",      "offlineCaseBackgroundImg" : null,      "prechatBackgroundImg" : null,      "prechatEnabled" : false,      "prechatJson" : null,      "scenario" : "Service",      "smallCompanyLogoImg" : null,      "urls" : null,      "waitingStateBackgroundImg" : null    }  } ]}';
        } else if (query.contains('EmbeddedServiceLiveAgent')) {
            return '{  "size" : 2,  "totalSize" : 2,  "done" : true,  "queryLocator" : null,  "entityTypeName" : "EmbeddedServiceLiveAgent",  "records" : [ {    "attributes" : {      "type" : "EmbeddedServiceLiveAgent",      "url" : "/services/data/v43.0/tooling/sobjects/EmbeddedServiceLiveAgent/08h250000004FiTAAU"    },    "Id" : "08h250000004FiTAAU",    "MasterLabel" : "MSL_CS_AL_SI",    "EmbeddedServiceConfigId" : "04I250000004FiYEAU"  }, {    "attributes" : {      "type" : "EmbeddedServiceLiveAgent",      "url" : "/services/data/v43.0/tooling/sobjects/EmbeddedServiceLiveAgent/08h250000004FiYAAU"    },    "Id" : "08h250000004FiYAAU",    "MasterLabel" : "MSL_CS_DZ_SI",    "EmbeddedServiceConfigId" : "04I250000004FidEAE"  }   ]}';
        }
        
        return null;
    }
    
    @TestVisible
    private String getIdVal(String jsonStr) {
        if (String.isNotBlank(jsonStr) && jsonStr.contains('"Id":"')) {
            String idStr = jsonStr.substringAfterLast('"Id":"').substringBefore('"');
            if (String.isNotBlank(idStr) && idStr.length() == 18) {
                return idStr;
            }
        }
        return null;
    }
    
    @TestVisible
    private String getAttVal(String attName, String jsonStr) {
        if (String.isNotBlank(jsonStr) && jsonStr.contains('"' + attName + '":"')) {
            String attValStr = jsonStr.substringAfterLast('"' + attName + '":"').substringBefore('"');
            if (String.isNotBlank(attValStr)) {
                return attValStr;
            }
        }
        return null;
    }
    
    @TestVisible
    private Set<String> getIdSetFromJsonRecords(String jsonRecords) {
        Set<String> idSet = new Set<String>();
        if (String.isNotBlank(jsonRecords) && jsonRecords.contains('"records"') && jsonRecords.contains('"attributes"')) {
            for (String s: jsonRecords.split('}')) {
                if (String.isNotBlank(s)) {
                    String testStr = s.trim();
                    testStr = testStr.replaceAll('(\\s+)', '');
                    //System.debug(Logginglevel.DEBUG, LOGMARK + 'getIdSetFromJsonRecords - testStr=' + testStr);
                    String idStr = getIdVal(testStr);
                    if (String.isNotBlank(idStr)) {
                        idSet.add(idStr);
                    }
                }
            }
        }
        return idSet;
    }
    
    @TestVisible
    private Set<String> getAttValSetFromJsonRecords(String attName, String jsonRecords) {
        Set<String> idSet = new Set<String>();
        if (String.isNotBlank(jsonRecords) && jsonRecords.contains('"records"') && jsonRecords.contains('"attributes"')) {
            for (String s: jsonRecords.split('}')) {
                if (String.isNotBlank(s)) {
                    String testStr = s.trim();
                    testStr = testStr.replaceAll('(\\s+)', '');
                    String attValStr = getAttVal(attName, testStr);        
                    if (String.isNotBlank(attValStr)) {
                        idSet.add(attValStr);
                    }
                }
            }
        }
        return idSet;
    }
    
    // getQueryOneEmbeddedServiceLiveAgentById - tooling API query
    @TestVisible
    private String getQueryOneEmbeddedServiceLiveAgentById(String idStr) {
        return baseUrl + 'query?q=Select+Id,MetaData+from+EmbeddedServiceLiveAgent+where+Id=\'' + idStr + '\'';
    }
    
    // getOneEmbeddedServiceLiveAgentById - produces a tooling API query and uses it to get metadata
    @TestVisible
    private String getOneEmbeddedServiceLiveAgentById(String idStr) {
        System.debug(Logginglevel.DEBUG, LOGMARK + 'getOneEmbeddedServiceLiveAgentById - idStr=' + idStr);
        String queryStr = getQueryOneEmbeddedServiceLiveAgentById(idStr);
        System.debug(Logginglevel.DEBUG, LOGMARK + 'getOneEmbeddedServiceLiveAgentById - queryStr=' + queryStr);
        
        if (!System.Test.isRunningTest()) {
            HttpResponse res = getResp('GET', queryStr);
            System.debug(Logginglevel.DEBUG, LOGMARK + 'getOneEmbeddedServiceLiveAgentById - res.getBody()=' + res.getBody());
            return res.getBody();
        }
        return getMockAPIResponse('GET', queryStr);
    }
    
    private HttpResponse getResp(String method, String endPoint) {
        calloutCount++;
        Http h = new Http();
        return h.send(getHttpRequest(endPoint, method));
    }

    // mapLiveChatDeployment - lc deployment to 15 char id mapping
    @TestVisible
    private Map<String, String> mapLiveChatDeployment {
        get {
            if (mapLiveChatDeployment == null) {
                mapLiveChatDeployment = new Map<String, String>();
                for (LiveChatDeployment lcd: [SELECT Id, DeveloperName FROM LiveChatDeployment]) {
                    String idStr = lcd.Id;
                    mapLiveChatDeployment.put(lcd.DeveloperName, idStr.substring(0, 15));
                }
            }
            return mapLiveChatDeployment;
        }
        set;
    }
    
    @TestVisible
    private Map<String, String> mapLiveChatButton {
        get {
            if (mapLiveChatButton == null) {
                mapLiveChatButton = new Map<String, String>();
                for (LiveChatButton lcb: [SELECT Id, DeveloperName FROM LiveChatButton ]) {
                    
                    String idStr = lcb.Id;
                    mapLiveChatButton.put(lcb.DeveloperName, idStr.substring(0, 15));
                }
            }
            return mapLiveChatButton;
        }
        set;
    }

    // EslaOrgInfo - Embedded Service Live Agent Organisation Info
    public EslaOrgInfo eslaOrgInf {
        get {
            if (eslaOrgInf == null) {
                eslaOrgInf = new EslaOrgInfo();
            }
            return eslaOrgInf;
        }
        set;
    }
    
    // eslaOrgInfoJson - EslaOrgInfo as Json
    public String eslaOrgInfoJson {
        get {
            return JSON.serialize(this.eslaOrgInf);
        }
        set;
    }
    
    // doneIdSet - Embedded Service Live Agent Ids created so far
    @TestVisible
    private Set<String> doneIdSet {
        get {
            if (doneIdSet == null) {
                doneIdSet = new Set<String>();
            }
            return doneIdSet;
        }
        set;
    }
                
    @TestVisible
    private Integer innerHitCount {
        get {
            if (innerHitCount == null) {
                innerHitCount = 0;
            }
            return innerHitCount;
        }
        set;
    }

    public List<Esla> listEsla {
        get {
            if (listEsla == null) {
                listEsla = new List<Esla>();
            }
            return listEsla;
        }
        set;
    }
    
    @TestVisible
    private Set<String> eslaIdSet {
        get {
            if (eslaIdSet == null) {
                eslaIdSet = getIdSetFromJsonRecords(allEmbeddedServiceLiveAgent);
            }
            return eslaIdSet;
        }
        set;
    }
    
    public Boolean complete {
        get {
            return (listEsla.size() == eslaIdSet.size());
        }
        set;
    }

    // getMoreEsla - to be called via a UI / VF
    public void getMoreEsla() {
        this.innerHitCount = 0;
        for (String idStr: eslaIdSet) {
            
            System.debug(Logginglevel.DEBUG, LOGMARK + 'getMoreEsla - idStr=' + idStr);
            System.debug(Logginglevel.DEBUG, LOGMARK + 'getMoreEsla - innerHitCount=' + innerHitCount + ', this.calloutLimit=' + this.calloutLimit);
            
            // Halt to prevent CPU Time Limit or similar being hit
            if (this.innerHitCount >= this.calloutLimit) {
                break;
            }
            
            System.debug(Logginglevel.DEBUG, LOGMARK + 'getMoreEsla - doneIdSet=' + doneIdSet);
            
            // Only add items not yet done to listEsla
            if (!doneIdSet.contains(idStr)) {
                System.debug(Logginglevel.DEBUG, LOGMARK + 'getMoreEsla - idStr NOT FOUND in doneIdSet- ADD IT');
                String eslaJson = getOneEmbeddedServiceLiveAgentById(idStr);
                doneIdSet.add(idStr);
                this.innerHitCount++;
                Map<String, Object> om = (Map<String, Object>) JSON.deserializeUntyped(eslaJson);
                System.debug(Logginglevel.DEBUG, LOGMARK + 'getMoreEsla - om.keySet()=' + om.keySet());
                List<Object> recList = (List<Object>)om.get('records');
                for (Object r: recList) {
                    String recJson = JSON.serialize(r);
                    if (String.isNotBlank(recJson) && !System.Test.isRunningTest()) {
                        System.debug(Logginglevel.DEBUG, LOGMARK + 'getMoreEsla - recJson=' + recJson);
                        Map<String, Object> mm = (Map<String, Object>) JSON.deserializeUntyped(recJson.replace('{"Metadata":', '').replace('}}', '}'));
                        System.debug(Logginglevel.DEBUG, LOGMARK + 'getMoreEsla - mm.keySet()=' + mm.keySet());
                        String eslaEmbeddedServiceConfig = (String)mm.get('embeddedServiceConfig');
                        String eslaMasterLabel = (String)mm.get('masterLabel');
                        String eslaLiveChatButton = (String)mm.get('liveChatButton');
                        String eslaLiveChatDeployment = (String)mm.get('liveChatDeployment');
                        String eslaLiveChatButtonLang = lcbDevNameLangMap.get(eslaLiveChatButton);
                        System.debug(Logginglevel.DEBUG, LOGMARK + 'getMoreEsla - eslaLiveChatButton=' + eslaLiveChatButton + 'eslaLiveChatButtonLang=' + eslaLiveChatButtonLang);
                        listEsla.add( new Esla(idStr, eslaEmbeddedServiceConfig, eslaMasterLabel, eslaLiveChatButton, this.mapLiveChatButton.get(eslaLiveChatButton), eslaLiveChatDeployment, this.mapLiveChatDeployment.get(eslaLiveChatDeployment), eslaLiveChatButtonLang));
                    }
                }
            }
        }
    }

    // Esla - Describes a Snapin
    public class Esla {
        public String ml {get;set;}
        public String liveChatButton {get;set;} // todo: maybe make a shorter name
        public String lcbId {get;set;}
        public String liveChatDeployment {get;set;} // todo: maybe make a shorter name
        public String lcdId {get;set;}
        public string lang {get;set;}

        public Esla(String embeddedServiceLiveAgentId, String embeddedServiceConfig, String masterLabel, String liveChatButton, String liveChatButtonId, String liveChatDeployment, String liveChatDeploymentId, String lang) {
            this.ml = masterLabel;
            this.liveChatButton = liveChatButton;
            this.lcbId = liveChatButtonId;
            this.liveChatDeployment = liveChatDeployment;            
            this.lcdId = liveChatDeploymentId;
            this.lang = lang;
        }
    }
    
    public class EslaOrgInfo {
        
        public String orgId {
            get {
                if (orgId == null) {
                    orgId = UserInfo.getOrganizationId().substring(0, 15);
                }
                return orgId;
            }
            set;
        }
        
        @TestVisible
        private Boolean isProd {
            get {
                if (isProd == null) {
                    if (UserInfo.getOrganizationId() == '00DD0000000n6xFMAQ') {
                        isProd = true;    
                    } else {
                        isProd = false;
                    }
                }
                return isProd;
            }
            set;
        }
        
        public String envUrl {
            get {
                if (envURL == null) {
                    if (isProd) {
                        envUrl = 'https://maersk.my.salesforce.com';
                    } else {
                        envURL = System.URL.getSalesforceBaseUrl().toExternalForm().replace('visual.force.com', 'my.salesforce.com');
                        String envName = envURL.substringAfter('--').substringBefore('--');
                        envURL = envURL.replace(envName + '--', envName.toUpperCase()).replace('c.cs', '.cs');
                    }
                }
                return envURL;
            }
            set;
        }
        
        public String siteName {
            get {
                if (siteName == null) {
                    siteName = 'Case_Survey'; // Customers
                }
                return siteName;
            }
            set;
        }
        
        public String siteUrl {
            get {
                if (siteUrl == null) {
                    siteUrl = '';
                }
                return siteUrl;
            }
            set;
        }
        
        public String baseLiveAgentContentUrl {
            get {
                if (baseLiveAgentContentUrl == null) {
                    baseLiveAgentContentUrl = 'https://c.la1-c1cs-lon.salesforceliveagent.com/content';
                }
                return baseLiveAgentContentUrl;
            }
            set;
        }
        
        public String baseLiveAgentUrl {
            get {
                if (baseLiveAgentUrl == null) {
                    baseLiveAgentUrl = 'https://d.la1-c1cs-lon.salesforceliveagent.com/chat';
                }
                return baseLiveAgentUrl;
            }
            set;
        }
        
        public String eswJsSource {
            get {
                if (eswJsSource == null) {
                    eswJsSource = envUrl + '/embeddedservice/5.0/esw.min.js';
                }
                return eswJsSource;
            }
            set;
        }
        
        public List<Esla> listEsla {get;set;}
        
    }
    
    // nameEndsWithLanguage - function to determine if a string / chat button name has a language and the end - so should be ignored
    @TestVisible
    private Boolean nameEndsWithLanguage(String name) {
        Boolean hasLang = false;
        for (String langName: langNameSet) {
            if (name.endsWithIgnoreCase(langName)) {
                hasLang = true;
                break;
            }
        }
        return hasLang;
    }
    
    // lcbList - a list
    @TestVisible
    public List<LiveChatButton> lcbList {
        get {
            if (lcbList == null) {
                lcbList = new List<LiveChatButton>();
                for (LiveChatButton lcb: [SELECT DeveloperName, WindowLanguage FROM LiveChatButton WHERE IsActive = true AND Type = 'Standard' ORDER BY DeveloperName ASC NULLS FIRST]) {
                        system.debug('lcb######'+lcb.DeveloperName);
                        //|| lcb.DeveloperName.startsWithIgnoreCase('Technical') -the condition is removed to create the Technical Snapin.
                    if ((nameStartsWithPrefixOfInterest(lcb.DeveloperName) && !nameEndsWithLanguage(lcb.DeveloperName))|| lcb.DeveloperName == '' || lcb.DeveloperName == 'MSL_CS_Technical_Chinese' ||lcb.DeveloperName == 'MSL_CS_Technical_English' ||lcb.DeveloperName == 'MSL_CS_Technical_Spanish' ||lcb.DeveloperName == 'MCC_CS_Technical_English') {
                        system.debug('lcb####'+lcb);
                        lcbList.add(lcb);
                    }
                }
            }
            system.debug('lcbList#'+lcbList);
            return lcbList;
        }
        set;
    }
    
    
    @TestVisible
    private Set<String> lcbDevNameSet {
        get {
            if (lcbDevNameSet == null) {
                lcbDevNameSet = new Set<String>();
                for (LiveChatButton lcb: lcbList) {
                    lcbDevNameSet.add(lcb.DeveloperName);
                }
            }
            return lcbDevNameSet;
        }
        set;
    }
    
    // lcbDevNameLangMap - maps Live Chat Button Names to Language Codes
    @TestVisible
    private Map<String, String> lcbDevNameLangMap {
        get {
            if (lcbDevNameLangMap == null) {
                lcbDevNameLangMap = new Map<String, String>();
                for (LiveChatButton lcb: lcbList) {
                    //lcbDevNameLangMap.put(lcb.DeveloperName, lcb.WindowLanguage);
                    //Snapins do not support '_'. So languages need to be replaced with '-'.
                    lcbDevNameLangMap.put(lcb.DeveloperName, lcb.WindowLanguage.replace('_', '-')); //#RQ-009144
                }
            }
            return lcbDevNameLangMap;
        }
        set;
    }
    
    // nameStartsWithPrefixOfInterest - function to help make  sure we only deal with buttons and deployments we care about
    @TestVisible
    private Boolean nameStartsWithPrefixOfInterest(String name) {
        Boolean isOfInterest = false;
        for (String s: liveChatPrefixSet) {
            if (name.startsWithIgnoreCase(s)) {
                isOfInterest = true;
                break;
            }
        }
        return isOfInterest;
    }
    
    @TestVisible
    private List<LiveChatDeployment> lcdList {
        get {
            if (lcdList == null) {
                lcdList = new List<LiveChatDeployment>();
                for (LiveChatDeployment lcd: [SELECT DeveloperName FROM LiveChatDeployment]) {
                    if (BrandUtilities.hasLiveChatDeployment(lcd.DeveloperName)) {
                        lcdList.add(lcd);
                    }
                }
            }
            return lcdList;
        }
        set;
    }
    
    @TestVisible
    private Set<String> lcdDevNameSet {
        get {
            if (lcdDevNameSet == null) {
                lcdDevNameSet = new Set<String>();
                for (LiveChatDeployment lcd: lcdList) {
                    lcdDevNameSet.add(lcd.DeveloperName);
                }
            }
            return lcdDevNameSet;
        }
        set;
    }
    
    // queryAllEmbeddedServiceConfig - tooling API query
    @TestVisible
    private String queryAllEmbeddedServiceConfig {
        get {
            if (queryAllEmbeddedServiceConfig == null) {
                queryAllEmbeddedServiceConfig = baseUrl + 'query?q=Select+Id,DeveloperName,MasterLabel+from+EmbeddedServiceConfig';
            }
            return queryAllEmbeddedServiceConfig;
        }
        set;
    }
    
    // allEmbeddedServiceConfig - Json representing all Embedded Service Configs
    public String allEmbeddedServiceConfig {
        get {
            if (allEmbeddedServiceConfig == null) {
                if (!System.Test.isRunningTest()) {
                    HttpResponse res = getResp('GET', queryAllEmbeddedServiceConfig);
                    allEmbeddedServiceConfig = res.getBody();
                } else {
                    allEmbeddedServiceConfig = getMockAPIResponse('GET', queryAllEmbeddedServiceConfig);
                }
            }
            return allEmbeddedServiceConfig;
        }
        set;
    }

    @TestVisible
    private Set<String> embeddedServiceConfigDevNameSet {
        get {
            if (embeddedServiceConfigDevNameSet == null) {
                embeddedServiceConfigDevNameSet = getAttValSetFromJsonRecords('DeveloperName', allEmbeddedServiceConfig);
            }
            return embeddedServiceConfigDevNameSet;
        }
        set;
    }
    
    @TestVisible
    private Set<String> embeddedServiceConfigIdSet {
        get {
            if (embeddedServiceConfigIdSet == null) {
                embeddedServiceConfigIdSet = getAttValSetFromJsonRecords('Id', allEmbeddedServiceConfig);
            }
            return embeddedServiceConfigIdSet;
        }
        set;
    }
    
    @TestVisible
    private void createEmbeddedServiceConfig(String masterLabel, String siteDevName) {
        if (String.isBlank(siteDevName) || String.isBlank(masterLabel)) throw new SnapInDataHelperException('siteDevName and masterLabel are both required!');
        if (embeddedServiceConfigDevNameSet.contains(masterLabel)) {
            //return;
            throw new SnapInDataHelperException('EmbeddedServiceConfig allready exists for masterLabel=' + masterLabel);  
        }      
        EmbeddedServiceConfig escObj = new EmbeddedServiceConfig(masterLabel, siteDevName);
        String esc = JSON.serialize(escObj);
        System.debug(Logginglevel.DEBUG, LOGMARK + 'createEmbeddedServiceConfig - esc=' + esc);
        
        HTTPRequest req = getHttpRequest(baseUrl + 'sobjects/EmbeddedServiceConfig', 'POST');   
        req.setBody(esc);
        Http h = new Http();
        if (!System.Test.isRunningTest()) {
            HttpResponse res = h.send(req);
            System.debug('res#### '+res.getStatusCode());
            // Response to a create should be 201
            if (res.getStatusCode() != 201) {
                System.debug(res.getBody());
                throw new SnapInDataHelperException(res.getStatus() + ' : masterLabel=' + masterLabel);
            }
            if(res.getStatusCode() == 201){
                //updateLabel(res.getBody());
                Map<String,Object> m = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
                strid = (String)m.get('id');
                updateEmbeddedServiceBranding(masterLabel,strid);
            }
        }
        calloutCount++;
        
        embeddedServiceConfigDevNameSet.add(masterLabel);
        
    }
    
    public class EmbeddedServiceConfig {
        public String FullName {get;set;}
        public EmbeddedServiceConfigMetadata Metadata {get;set;}
        public EmbeddedServiceConfig(String masterLabel, String site) {
            this.FullName = masterLabel;
            this.Metadata = new EmbeddedServiceConfigMetadata(masterLabel, site);
        }
    }
    
    public class EmbeddedServiceConfigMetadata {
        public String masterLabel {get;set;}
        public String site {get;set;}
        public EmbeddedServiceConfigMetadata(String masterLabel, String site) {
            this.masterLabel = masterLabel;
            this.site = site;
        }
    }
    
    //SC-509 Brand Alignment basis SFDC Summer Release
    @TestVisible
    private void updateEmbeddedServiceBranding(String escName,String escId){
        //To Update the EmbeddedServiceBranding NavbarColor
        String navBarColor = escName.contains('SCL') ? '#004994' : '#003e5e';
        EmbeddedServiceBranding esbObj = new EmbeddedServiceBranding(escName,'EmbeddedServiceBranding_Parent'+escId,navBarColor);
        String esb = JSON.serialize(esbObj);
        System.debug(Logginglevel.DEBUG, LOGMARK + 'updateEmbeddedServiceBranding - esb=' + esb);
        HTTPRequest req = getHttpRequest(baseUrl + 'sobjects/EmbeddedServiceBranding', 'POST'); 
        req.setBody(esb);
        Http h = new Http();
        if (!System.Test.isRunningTest()) {
            HttpResponse res = h.send(req);
            System.debug('res#### '+res.getStatusCode());
            if (res.getStatusCode() != 201) {
                System.debug(res.getBody());
                throw new SnapInDataHelperException(res.getStatus());
            }
        }
    }
    
    public class EmbeddedServiceBranding {
        public String fullName {get;set;}
        public EmbeddedServiceBrandingMetadata metadata {get;set;}
        public EmbeddedServiceBranding(String escName,String masterLabel,String navBarColor){
            this.fullName = masterLabel;
            this.metadata = new EmbeddedServiceBrandingMetadata(escName,masterLabel,navBarColor);
        }
    }
    
    public class EmbeddedServiceBrandingMetadata {
        public String embeddedServiceConfig {get;set;}
        public String masterLabel {get;set;}
        public String navBarColor {get;set;}
        public EmbeddedServiceBrandingMetadata(String escName,String masterLabel,String navBarColor){
            this.embeddedServiceConfig = escName;
            this.masterLabel = masterLabel;
            this.navBarColor = navBarColor;
        }
    }

    @TestVisible
    public Set<String> embeddedServiceLiveAgentMasterLabelSet {
        get {
            if (embeddedServiceLiveAgentMasterLabelSet == null) {
                embeddedServiceLiveAgentMasterLabelSet = getAttValSetFromJsonRecords('MasterLabel', allEmbeddedServiceLiveAgent);
            }
            return embeddedServiceLiveAgentMasterLabelSet;
        }
        set;
    }
    
    @TestVisible
    private void createEmbeddedServiceLiveAgent(String masterLabel, String embeddedServiceConfig, String liveChatButton, String liveChatDeployment, Brand brnd) {
        if (String.isBlank(masterLabel)) throw new SnapInDataHelperException('masterLabel required!');
        if (String.isBlank(embeddedServiceConfig)) throw new SnapInDataHelperException('embeddedServiceConfig required!');
        if (String.isBlank(liveChatButton)) throw new SnapInDataHelperException('liveChatButton required!');
        if (!lcbDevNameSet.contains(liveChatButton)) throw new SnapInDataHelperException('unknown liveChatButton:' + liveChatButton);
        if (String.isBlank(liveChatDeployment)) throw new SnapInDataHelperException('liveChatDeployment required!');
        if (!lcdDevNameSet.contains(liveChatDeployment)) {
            //return;
            throw new SnapInDataHelperException('unknown liveChatDeployment:' + liveChatDeployment);
            }
        if (embeddedServiceLiveAgentMasterLabelSet.contains(masterLabel)) {
            return;
            //throw new SnapInDataHelperException('EmbeddedServiceLiveAgent allready exists for masterLabel=' + masterLabel);  
        }      
        
        EmbeddedServiceLiveAgent eslaObj = new EmbeddedServiceLiveAgent(masterLabel, embeddedServiceConfig, liveChatButton, liveChatDeployment, brnd);
        String esla = JSON.serialize(eslaObj);
        System.debug(Logginglevel.DEBUG, LOGMARK + 'createEmbeddedServiceLiveAgent - esla=' + esla);
        system.debug('baseUrl#### '+baseUrl );
        HTTPRequest req = getHttpRequest(baseUrl + 'sobjects/EmbeddedServiceLiveAgent', 'POST');
        req.setBody(esla);
     
        Http h = new Http();
        if (!System.Test.isRunningTest()) {
            HttpResponse res = h.send(req);
            
            if (res.getStatusCode() != 201) {
                System.debug(res.getBody());
                throw new SnapInDataHelperException(res.getStatus());
            }
            
        }
        calloutCount++;
        
        embeddedServiceLiveAgentMasterLabelSet.add(masterLabel);
        
    }
    //RQ-012931
    @TestVisible
    private void updateSnapInLabel(String strLabel){
        system.debug('strLabel---------'+strLabel);
        string strJson ='{"labelKey":"LA_Waiting_WithoutQueuePos_WaitingMessage","CustomLabelId":"'+System.Label.SnapInLabelId+'","EmbeddedServiceConfigId":'+'"'+strLabel+'"'+'}';
        system.debug(strJson);
      //  HTTPRequest req = getHttpRequest('https://maersk--regdev01--c.cs108.visual.force.com/services/data/v47.0/tooling/sobjects/EmbeddedServiceCustomLabel', 'POST');
        HTTPRequest req = getHttpRequest(baseUrl + 'sobjects/EmbeddedServiceCustomLabel', 'POST');
        req.setBody(strJson);
        req.setHeader('Accept', 'application/json');
        Http h = new Http();
        if (!System.Test.isRunningTest()) {
            HttpResponse res = h.send(req);
            system.debug('Label Creted'+res);
            if (res.getStatusCode() != 201) {
                System.debug(res.getBody());
                throw new SnapInDataHelperException(res.getStatus());
            }
            
        }
    
    }
    
    @TestVisible
    private void updateSnapInLabelChatheader(String strLabel){
        system.debug('strLabel---------'+strLabel);
        string strJson ='{"labelKey":"LA_Chat_ExtendedHeader_ChatStateHeaderGreeting","CustomLabelId":"'+System.Label.SnapInHeaderLabel+'","EmbeddedServiceConfigId":'+'"'+strLabel+'"'+'}';
        system.debug(strJson);
      //  HTTPRequest req = getHttpRequest('https://maersk--regdev01--c.cs108.visual.force.com/services/data/v47.0/tooling/sobjects/EmbeddedServiceCustomLabel', 'POST');
        HTTPRequest req = getHttpRequest(baseUrl + 'sobjects/EmbeddedServiceCustomLabel', 'POST');
        req.setBody(strJson);
        req.setHeader('Accept', 'application/json');
        Http h = new Http();
        if (!System.Test.isRunningTest()) {
            HttpResponse res = h.send(req);
            system.debug('Label Created'+res);
            if (res.getStatusCode() != 201) {
                System.debug(res.getBody());
                throw new SnapInDataHelperException(res.getStatus());
            }
            
        }
    
    }
    
    
    @TestVisible
    private HttpRequest getHttpRequest(String endpoint, String method){
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(endpoint);
        req.setMethod(method);
        return req;
    }    
    
    public class EmbeddedServiceLiveAgent {
        public String FullName {get;set;}
        public EmbeddedServiceLiveAgentMetadata Metadata {get;set;}
        public EmbeddedServiceLiveAgent(String masterLabel, String embeddedServiceConfig, String liveChatButton, String liveChatDeployment, Brand brnd) {
            this.FullName = masterLabel;
            this.Metadata = new EmbeddedServiceLiveAgentMetadata(masterLabel, embeddedServiceConfig, liveChatButton, liveChatDeployment, brnd);
        }
    }
    
    public class EmbeddedServiceLiveAgentMetadata {
        
        public String masterLabel {get;set;}
        public String embeddedServiceConfig {get;set;}
        public Boolean enabled {get;set;}
        public String fontSize {get;set;}
        public Boolean isOfflineCaseEnabled {get;set;}
        public Boolean isQueuePositionEnabled {get;set;}
        public String liveChatButton {get;set;}
        public String liveChatDeployment {get;set;}
        public Boolean prechatEnabled {get;set;}
        public String scenario {get;set;}
        public String avatarImg {get;set;}
        public String headerBackgroundImg {get;set;}
        public String prechatBackgroundImg {get;set;}
        public String smallCompanyLogoImg {get;set;}
        public String waitingStateBackgroundImg {get;set;}

        public EmbeddedServiceLiveAgentMetadata(String masterLabel, String embeddedServiceConfig, String liveChatButton, String liveChatDeployment, Brand brnd) {
            this.masterLabel = masterLabel;
            this.embeddedServiceConfig = embeddedServiceConfig;
            this.enabled = true;
            this.fontSize = 'Medium';
            this.isOfflineCaseEnabled = false;
            this.isQueuePositionEnabled = true;
            this.liveChatButton = liveChatButton;
            this.liveChatDeployment = liveChatDeployment;
            this.prechatEnabled = false;
            this.scenario = 'Service';
            
            System.debug(Logginglevel.DEBUG, LOGMARK + 'EmbeddedServiceLiveAgentMetadata - brnd=' + brnd);
            if (brnd != null) {
                this.avatarImg = brnd.avatarImg;
                this.headerBackgroundImg = brnd.headerBackgroundImg;
                this.prechatBackgroundImg = brnd.prechatBackgroundImg;
                this.smallCompanyLogoImg = brnd.smallCompanyLogoImg;
                this.waitingStateBackgroundImg = brnd.waitingStateBackgroundImg;
            }
            
        }
    }
    
    public void createSnapin(String snapinMasterLabel, String siteDevName, String liveChatButton, String liveChatDeployment, Brand brnd) {
        if (calloutCount < calloutLimit) {
            strid='';
            System.debug(Logginglevel.DEBUG, LOGMARK + 'createSnapin - snapinMasterLabel=' + snapinMasterLabel);
            createEmbeddedServiceConfig(snapinMasterLabel, siteDevName);
            createEmbeddedServiceLiveAgent(snapinMasterLabel, snapinMasterLabel, liveChatButton, liveChatDeployment, brnd);
            system.debug('strid#####'+strid);
            //RQ-012931  
            if(String.isNotBlank(strid)){
                updateSnapInLabel(strid);
                updateSnapInLabelChatheader(strid);
            }
        }
    }
    
    @TestVisible
    private Map<String, String> liveChatPrefixDeploymentMap {
        get {
            if (liveChatPrefixDeploymentMap == null) {
                liveChatPrefixDeploymentMap = BrandUtilities.getLiveChatPrefixAndBrandMap();
            }
            return liveChatPrefixDeploymentMap;
        }
        set;
    }
    
    @TestVisible
    private Set<String> liveChatPrefixSet {
        get {
            if (liveChatPrefixSet == null) {
                liveChatPrefixSet = liveChatPrefixDeploymentMap.keySet();
            }
            return liveChatPrefixSet;
        }
        set;
    }
    
    public void createSnapins() {
        for (String lcdDevName: lcdDevNameSet) {
            createSnapins(lcdDevName);
        }
    }
    
    public void createSnapins(String liveChatDeployment) {
        System.debug(Logginglevel.DEBUG, LOGMARK + 'createSnapins - liveChatDeployment=' + liveChatDeployment);
        createSnapins(this.eslaOrgInf.siteName, liveChatDeployment);
    }
    
    @TestVisible
    private String stripPrefix(String fullName) {
        String stripped = fullName;
        for (String lcbPrefix: liveChatPrefixSet) {
            stripped = stripped.replace(lcbPrefix, '');
        }
        return stripped;
    }
    
    public Set<String> lcbDevNameNoCountryMatchSet {
        get {
            if (lcbDevNameNoCountryMatchSet == null) {
                lcbDevNameNoCountryMatchSet = new Set<String>();
            }
            return lcbDevNameNoCountryMatchSet;
        }
        set;
    }
    
    @TestVisible
    private String getTidyCNameStr(String raw) {
        if (String.isNotBlank(raw)) {
            return raw.replace('_', '').replace(' ', '').replace('.', '').replace('(', '').replace(')', '').replace('-', '');
        }
        return raw;
    }
    
    public Map<String, String> lcbDevNameTargetNameMap {
        get {
            if (lcbDevNameTargetNameMap == null) {
                lcbDevNameNoCountryMatchSet = new Set<String>();
                lcbDevNameTargetNameMap = new Map<String, String>();
                for (String lcbDevName: lcbDevNameSet) {
                    String prefixlessDevName = stripPrefix(lcbDevName);
                    String tidyPrefixlessDevName = getTidyCNameStr(prefixlessDevName);
                    String prefix = lcbDevName.replace(prefixlessDevName, '');
                    Boolean gotMatch = false;
//                  System.debug(Logginglevel.DEBUG, LOGMARK + 'lcbDevNameTargetNameMap - lcbDevName=' + lcbDevName + ', prefixlessDevName=' + prefixlessDevName);
                    for (PortalCountry pc: portalCountryList) {
                        String portalCName = pc.countryName;
                        //system.debug('pc.countryName####'+pc.countryName);
                         system.debug('portalCName ####'+portalCName );
                        if (String.isNotBlank(portalCName)) {
                            portalCName = getTidyCNameStr(portalCName);
                           
                            if (tidyPrefixlessDevName.equalsIgnoreCase(portalCName)) {
                                lcbDevNameTargetNameMap.put(lcbDevName, prefix + pc.country);
                                gotMatch = true;
                                break;
                            }
                        }
                    }
                    if (!gotMatch) {
                        lcbDevNameNoCountryMatchSet.add(lcbDevName);
                        lcbDevNameTargetNameMap.put(lcbDevName, prefix + 'XX_' + prefixlessDevName); // If you see XX then adjust the country json static resource
                    }
                    
                }
                for (String s: lcbDevNameNoCountryMatchSet) {
                    System.debug('lcbDevNameTargetNameMap - NO COUNTRY MATCH for ' + s);
                }
            }
            system.debug('lcbDevName##'+lcbDevNameTargetNameMap.get('MSL_CS_Technical_Chinese'));
            return lcbDevNameTargetNameMap;
        }
        set;
    }
    public void createSnapins(String siteDevName, String liveChatDeployment) {
        for (String lcbDevName: lcbDevNameSet) {
            // if (lcbDevName.containsIgnoreCase('Nicaragua')) {
                String lcbTargetDevNameIncCountry = lcbDevNameTargetNameMap.get(lcbDevName);
                System.debug(Logginglevel.DEBUG, LOGMARK + 'createSnapins - liveChatDeployment=' + liveChatDeployment + ', lcbTargetDevNameIncCountry=' + lcbTargetDevNameIncCountry);
                
                if (String.isBlank(lcbTargetDevNameIncCountry)) throw new SnapInDataHelperException('createSnapins - lcbTargetDevNameIncCountry should not be blank!');
                
                if (calloutCount >= calloutLimit) {
                    break;
                }
                for (String lcbPrefix: liveChatPrefixSet) {
                    //System.debug(Logginglevel.DEBUG, LOGMARK + 'createSnapins - lcbPrefix=' + lcbPrefix + ', embeddedServiceLiveAgentMasterLabelSet=' + embeddedServiceLiveAgentMasterLabelSet);
                    //System.debug(Logginglevel.DEBUG, LOGMARK + 'createSnapins - lcbPrefix=' + lcbPrefix + ', liveChatPrefixBrandMap=' + liveChatPrefixBrandMap);
                    if (lcbTargetDevNameIncCountry.contains(lcbPrefix) && !embeddedServiceLiveAgentMasterLabelSet.contains(lcbTargetDevNameIncCountry + '_SI')) {
                        Brand brnd = liveChatPrefixBrandMap.get(lcbPrefix);
                        //System.debug(Logginglevel.DEBUG, LOGMARK + 'createSnapins - lcbDevName=' + lcbDevName + ', lcbTargetDevNameIncCountry=' + lcbTargetDevNameIncCountry);
                        //System.debug(Logginglevel.DEBUG, LOGMARK + 'createSnapins - brnd=' + brnd);
                        createSnapin(lcbTargetDevNameIncCountry + '_SI', siteDevName, lcbDevName, liveChatPrefixDeploymentMap.get(lcbPrefix), brnd);
                    }
                }
            // }
        }
    }
    
    public List<Brand> brandList {
        get {
            if (brandList == null) {
                brandList = new List<Brand>();
                for (String liveChatPrefix: liveChatPrefixSet) {
                    brandList.add(new Brand(liveChatPrefix, null, null, null, null, null));
                }
            }
            return brandList;
        }
        set;
    }
    
    @TestVisible
    private Map<String, Brand> liveChatPrefixBrandMap {
        get {
            if (liveChatPrefixBrandMap == null) {
                liveChatPrefixBrandMap = new Map<String, Brand>();
                for (Brand b: brandList) {
                    liveChatPrefixBrandMap.put(b.liveChatPrefix, b);
                }
            }
            return liveChatPrefixBrandMap;
        }
        set;
    }

    public class PortalCountry {
        public String id {get;set;}
        public String country {get;set;}
        public String countryName {get;set;}
        public String brand {get;set;}
        public String active {get;set;}
    }

    @TestVisible
    private String portalCountryJson {
        get {
            if (portalCountryJson == null) {
                for (StaticResource sr: [SELECT Id, Name, Body from StaticResource WHERE Name = 'SnapinPortalCountryList' LIMIT 1]) {
                    portalCountryJson = sr.Body.toString();    
                }
            }
            return portalCountryJson;
        }
        set;
    }
    
    @TestVisible
    private List<PortalCountry> portalCountryList {
        get {
            if (portalCountryList == null) {
                portalCountryList = (List<PortalCountry>)JSON.deserialize(portalCountryJson, List<PortalCountry>.class);
            }
            return portalCountryList;
        }
        set;
    }
    
    
    public class Brand {
        public String liveChatPrefix {get;set;}
        public String avatarImg {get;set;}
        public String headerBackgroundImg {get;set;}
        public String prechatBackgroundImg {get;set;}
        public String smallCompanyLogoImg {get;set;}
        public String waitingStateBackgroundImg {get;set;}
        public Brand(String liveChatPrefix, String avatarImg, String headerBackgroundImg, String prechatBackgroundImg, String smallCompanyLogoImg, String waitingStateBackgroundImg) {
            this.liveChatPrefix = liveChatPrefix;
            this.avatarImg = avatarImg;
            this.headerBackgroundImg = headerBackgroundImg;
            this.prechatBackgroundImg = prechatBackgroundImg;
            this.smallCompanyLogoImg = smallCompanyLogoImg;
            this.waitingStateBackgroundImg = waitingStateBackgroundImg;    
        }
    }
    
    public void deleteEmbeddedServiceConfigs() {
        for (String escId: embeddedServiceConfigIdSet) {
            if (calloutCount >= calloutLimit) {
                break;
            }
            deleteOneEmbeddedServiceConfigById(escId);
        }
        embeddedServiceConfigIdSet = null;
    }
    
    public void deleteEmbeddedServiceLiveAgents() {
        for (String eslaId: eslaIdSet) {
            if (calloutCount >= calloutLimit) {
                break;
            }
            deleteOneEmbeddedServiceLiveAgentById(eslaId);
        }
        embeddedServiceLiveAgentMasterLabelSet = null;
    }
    
    @TestVisible
    private String getQueryDeleteOneEmbeddedServiceLiveAgentById(String eslaId) {
        return baseUrl + 'sobjects/EmbeddedServiceLiveAgent/' + eslaId + '/';
    }
    
    @TestVisible
    private String getQueryDeleteOneEmbeddedServiceConfigById(String escId) {
        return baseUrl + 'sobjects/EmbeddedServiceConfig/' + escId + '/';
    }
    
    public Integer countSnapins() {
        return eslaIdSet.size();
    }
    
    // deleteSnapins - removes all existing EmbeddedServiceLiveAgents EmbeddedServiceConfigs
    public void deleteSnapins() {
        if (!eslaIdSet.isEmpty()) {
            System.debug(Logginglevel.DEBUG, LOGMARK + 'deleteSnapins - eslaIdSet.size()=' + eslaIdSet.size());
            deleteEmbeddedServiceLiveAgents();
        }
        if (!embeddedServiceConfigIdSet.isEmpty()) {
            System.debug(Logginglevel.DEBUG, LOGMARK + 'deleteSnapins - embeddedServiceConfigIdSet.size()=' + embeddedServiceConfigIdSet.size());
            deleteEmbeddedServiceConfigs();
        }
        eslaIdSet = null;
        embeddedServiceConfigIdSet = null;
    }
    
    public Integer snapinCount {
        get {
            return embeddedServiceConfigIdSet.size();
        }
    }
    
    public Boolean snapinsExist {
        get {
            return !(eslaIdSet.isEmpty() && embeddedServiceConfigIdSet.isEmpty());
        }
    }
    
    public void deleteOneEmbeddedServiceConfigById(String escId) {
        String queryStr = getQueryDeleteOneEmbeddedServiceConfigById(escId);
        System.debug(Logginglevel.DEBUG, LOGMARK + 'deleteOneEmbeddedServiceConfigById - queryStr=' + queryStr);
        if (!System.Test.isRunningTest()) {
            HttpResponse res = getResp('DELETE', queryStr);
            System.debug(Logginglevel.DEBUG, LOGMARK + 'deleteOneEmbeddedServiceConfigById - res.getStatusCode()=' + res.getStatusCode());
            /*
            if (res.getStatusCode() != 201) {
                System.debug(Logginglevel.DEBUG, LOGMARK + 'deleteOneEmbeddedServiceConfigById - res.getBody()=' + res.getBody());
                throw new SnapInDataHelperException(res.getStatus());
            }
            */
        }
   }
    
    public void deleteOneEmbeddedServiceLiveAgentById(String eslaId) {
        String queryStr = getQueryDeleteOneEmbeddedServiceLiveAgentById(eslaId);
        System.debug(Logginglevel.DEBUG, LOGMARK + 'deleteOneEmbeddedServiceLiveAgentById - queryStr=' + queryStr);
        if (!System.Test.isRunningTest()) {
            HttpResponse res = getResp('DELETE', queryStr);
            System.debug(Logginglevel.DEBUG, LOGMARK + 'deleteOneEmbeddedServiceLiveAgentById - res.getStatusCode()=' + res.getStatusCode());
            /*
            if (res.getStatusCode() != 201) {
                System.debug(Logginglevel.DEBUG, LOGMARK + 'deleteOneEmbeddedServiceLiveAgentById - res.getBody()=' + res.getBody());
                throw new SnapInDataHelperException(res.getStatus());
            }
            */
        }
   }
    
}