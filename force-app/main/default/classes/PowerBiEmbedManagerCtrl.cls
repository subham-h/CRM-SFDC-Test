/**
 * Date         Owner            Description
 ************************************************************************************************************
 * 20/10/2022  Sidhartha@Maersk  Class created for powerBi report embeded data.
 * 04/12/2023  Vinay@Maersk		 SFSE-12521- Added a method to return Custom Metadata	
 */
public class PowerBiEmbedManagerCtrl {
    public PowerBiEmbedManagerCtrl() {
    }
    public class ClientCredentialResponse {
        public String access_token;
        public String expires_in;
        public String ext_expires_in;
        public String token_type;
    }
    public class PowerBiReport    {
        public String id { get; set; } 
        public String reportType { get; set; } 
        public String name { get; set; } 
        public String webUrl { get; set; } 
        public String embedUrl { get; set; } 
        public boolean isFromPbix { get; set; } 
        public boolean isOwnedByMe { get; set; } 
        public String datasetId { get; set; } 
    }
    
    public class PowerBiEmbedToken    {
        public string token { get; set; } 
        public string tokenId { get; set; } 
        public DateTime expiration { get; set; } 
    }
    public class PowerBiReportData    {
        @AuraEnabled
        public String workspaceId { get; set; } 
        @AuraEnabled
        public String reportId { get; set; } 
        @AuraEnabled
        public String name { get; set; } 
        @AuraEnabled
        public String embedUrl { get; set; } 
        @AuraEnabled
        public String embedToken { get; set; } 
        @AuraEnabled
        public DateTime embedTokenExpires { get; set; } 
        @AuraEnabled
        public String error { get; set; } 
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String,Power_BI_Configuration__mdt> getReportWrkSpaceId(){
        Map<String, Power_BI_Configuration__mdt> mapEd = Power_BI_Configuration__mdt.getAll();
        system.debug('mapEd ' + mapEd);
        return mapEd;
    }
    
    public static String getPowerBiAccessToken() {
        
        // prepare HTTP request 
        HttpRequest reqClientCredentialsFlow = new HttpRequest();
        reqClientCredentialsFlow.setMethod('POST');
        reqClientCredentialsFlow.setEndpoint('callout:Power_Bi');        
        reqClientCredentialsFlow.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String jsonBody ='client_id=' + '{!$Credential.Username}' + '&client_secret=' + '{!$Credential.Password}' + '&client_info=1' + '&scope=' + 'https://analysis.windows.net/powerbi/api/.default' + '&grant_type=' + 'client_credentials';
        system.debug('postBody ' + jsonBody);
        reqClientCredentialsFlow.setBody(jsonBody);
        
        // send HTTP POST to execute client credentials flow
        Http http = new Http();        
        HttpResponse response = http.send(reqClientCredentialsFlow);
        
        // extract and return app-only access token for service principal
        String responseJson = response.getBody();
        ClientCredentialResponse responseData = (ClientCredentialResponse)JSON.deserialize(responseJson, ClientCredentialResponse.class);
        system.debug('responseData ' + responseData);
        String access_token = responseData.access_token;         
        return access_token;
    }
    
    @AuraEnabled(cacheable=true)
    public static PowerBiReportData getEmbeddingDataForReport(String WorkspaceId, String ReportId) {
        
        // get logged in user email address
        String loggedInUserEmail = UserInfo.getUserEmail();
        // get access token for Authorization header
        String access_token = getPowerBiAccessToken();        
        
        // Call to Power BI Service API to get report data for embedding        
        HttpRequest reqGetReport = new HttpRequest();
        reqGetReport.setMethod('GET');
        String urlGetReport = 'https://api.powerbi.com/v1.0/myorg/groups/' + WorkspaceId + '/reports/' + ReportId;
        reqGetReport.setEndpoint(urlGetReport);
        reqGetReport.setHeader('Authorization', 'Bearer ' + access_token);
        
        Http http = new Http();        
        HttpResponse response = http.send(reqGetReport);
        
        // check response for success
        if(response.getStatusCode()!=200){
            System.debug('ERROR --- Getting Report Data --- ERROR');
            System.debug('Status Code: ' + response.getStatusCode());
            PowerBiReportData getReportError = new PowerBiReportData();
            getReportError.error = 'Get Report Error: ' + response.getStatus();
            return getReportError;            
        }            
        
        // extract Power BI report data from JSON response
        String responseJson = response.getBody();
        PowerBiReport powerBiReport = (PowerBiReport)JSON.deserialize(responseJson, PowerBiReport.class);
        
        // send report info to debug window
        System.debug('id: ' + powerBiReport.id);        
        System.debug('reportType: ' + powerBiReport.reportType);        
        System.debug('name: ' + powerBiReport.name);  
        System.debug('webUrl: ' + powerBiReport.webUrl);      
        System.debug('embedUrl: ' + powerBiReport.embedUrl);        
        System.debug('isFromPbix: ' + powerBiReport.isFromPbix);        
        System.debug('isOwnedByMe: ' + powerBiReport.isOwnedByMe);        
        System.debug('datasetId: ' + powerBiReport.datasetId);        
        
        Map<String, Power_BI_Configuration__mdt> mapEd = Power_BI_Configuration__mdt.getAll();
        String rLs = '';
        for(String ss : mapEd.keySet()) {
            if(mapEd.get(ss).Label == powerBiReport.name) {
                rLs = mapEd.get(ss).Row_Level_Securities__c;
            }
        }
        // Call to Power BI Service API to get embed token for report     
        HttpRequest reqGetEmbedToken = new HttpRequest();
        reqGetEmbedToken.setMethod('POST');
        String urlGetEmbedToken = 'https://api.powerbi.com/v1.0/myorg/groups/' + WorkspaceId + '/reports/' + ReportId + '/GenerateToken';
        reqGetEmbedToken.setEndpoint(urlGetEmbedToken);
        reqGetEmbedToken.setHeader('Authorization', 'Bearer ' + access_token);
        reqGetEmbedToken.setHeader('Content-Type', 'application/json; charset=utf-8');
        reqGetEmbedToken.setHeader('Accept', 'application/json');
        reqGetEmbedToken.setBody('{"accessLevel":"view","identities":[{"username":"c9d8cfb8-05f0-43f6-acf6-a66a9837444c","roles":[ ' + rLs + '],"customData":"' + loggedInUserEmail + '","datasets":[ "' + powerBiReport.datasetId + '"]}]}'); 
        System.debug('reqGetEmbedToken ' + reqGetEmbedToken);
        HttpResponse responseEmbedToken = http.send(reqGetEmbedToken);
        
        // check response for success
        if(responseEmbedToken.getStatusCode()!=200){
            System.debug('ERROR --- Getting Embed Token --- ERROR');
            System.debug('Status Code: ' + responseEmbedToken.getStatusCode());    
            System.debug('Status Code: ' + responseEmbedToken.getStatus());  
            PowerBiReportData getEmbedTokenError = new PowerBiReportData();
            getEmbedTokenError.error = 'Get Embed Token Error: ' + response.getStatus();
            return getEmbedTokenError;            
        }            
        
        // extract Power BI embed token and expiration
        PowerBiEmbedToken embedToken = (PowerBiEmbedToken)JSON.deserialize(responseEmbedToken.getBody(), PowerBiEmbedToken.class);
        
        // send report info to debug window
        System.debug('EmbedToken: ' + embedToken.token);        
        System.debug('EmbedToken ID: ' + embedToken.tokenId);        
        System.debug('expiration: ' + embedToken.expiration);
        
        // create custom remote-able object to return to caller in browser 
        PowerBiReportData powerBiReportData = new PowerBiReportData();        
        powerBiReportData.workspaceId = WorkspaceId;
        powerBiReportData.reportId = ReportId;
        powerBiReportData.name = powerBiReport.name;
        powerBiReportData.embedUrl = powerBiReport.embedUrl;
        powerBiReportData.embedToken = embedToken.token;
        powerBiReportData.embedTokenExpires = embedToken.expiration;
        
        return powerBiReportData;            
        
    }
    /*SFSE-12521
     * Method to Fetch the Power_BI_Configuration__mdt, which stores info about Performance Dashboard of Power Bi
     * Input : Nothing
     * Output: Power_BI_Configuration__mdt
	*/
    /*@AuraEnabled(cacheable=true)
    public static Power_BI_Configuration__mdt getPerformanceDashboardInfo(){        
        return Power_BI_Configuration__mdt.getInstance('Account_Plan_Performance_Dashboard');
    }*/ 
}