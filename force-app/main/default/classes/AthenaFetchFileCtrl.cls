/**
* Revision Ref Number  Date          Owner                   Description
* -------- ----------  -----------   -----------------       -----------
* 1.0	   SFSE-14161  16-may-2024	 Samar					 Sending Quote file for p2q Oppty.	 	
**/
public with sharing class AthenaFetchFileCtrl {
    
    public static String getAccessToken() {
        String resp;
        String orgName = System.DomainParser.parse(URL.getOrgDomainUrl()).getSandboxName() == null ? 'production' : System.DomainParser.parse(URL.getOrgDomainUrl()).getSandboxName() ;
        String accesstoken =  (String)Cache.Org.get('AthenaQuoteFile'+orgName);
        if(accesstoken == '' || accesstoken == null){
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint('callout:AthenaFetchQuote');
            req.setTimeout(120000);
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            String jsonBody ='client_id=' + '{!$Credential.Username}' + '&client_secret=' + '{!$Credential.Password}' + '&grant_type=' + 'client_credentials';
            req.setBody(jsonBody);
            try {
                res = http.send(req);
                String responseJson = res.getBody();
                system.debug(responseJson);
                ClientCredentialResponse responseData = (ClientCredentialResponse)JSON.deserialize(responseJson, ClientCredentialResponse.class);
                accesstoken = (String)responseData.access_token;
                if(accessToken != null){
                    if(!Test.isRunningTest()){
                        Cache.Org.put('AthenaQuoteFile'+orgName, accessToken,7000);
                    }
                }
            } catch(System.CalloutException e) {
                System.debug('Callout error: '+ e);
                ErrorLogger.writeErrors( 'SFDC', 'Quote Access Token', 'AthenaFetchFileCtrl.getAccessToken', new list<Exception>{e});
            }
        }
        

        return accessToken;
    }

    @AuraEnabled
    public static responsewrap fetchQuoteFile (Id opptyId) {
        responsewrap respwrap = new responsewrap();
        string resp='';
        String accesstoken;
        String endPoint ; 
        Opportunity opp =[SELECT Id,Customer_Journey__c,StageName,  (SELECT Id,Quote_Copo_Link__c,Status__c FROM Quotes1__r where Quote_Copo_Link__c != null) FROM Opportunity WHERE Id =: opptyId ];
        endPoint  = opp.Customer_Journey__c =='Instant Quote (Non Negotiable)' && opp.Quotes1__r.size() == 1 ? opp.Quotes1__r[0].Quote_Copo_Link__c: null;
        
        if(endPoint!= null){
            accesstoken = Test.isRunningTest() ? '9999999' : getAccessToken();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPoint);
            req.setMethod('GET');
            req.setTimeout(60000);   
            req.setHeader('Authorization', 'Bearer ' + accesstoken);
            try {
                res = http.send(req);
                String fileName;
           		String header = res.getHeader('Content-Disposition');
                if(header != null){
                    List<String> setOfHeader= header.split(';');
                    fileName =  setOfHeader.size() >= 3? (setOfHeader[2].split('='))[1]: null;
                }
                system.debug(fileName);
                if(res.getStatusCode() == 200) {		
                    respwrap.description = EncodingUtil.base64Encode(res.getBodyAsBlob());
                    respwrap.status = 'Success';
                    respwrap.filename = fileName.replaceAll('"','');
                    resp = JSON.serialize(respwrap);

                } else {
                    ErrorResponse errRes = (ErrorResponse) System.JSON.deserialize(res.getBody(), ErrorResponse.class);
                    respwrap.description = errRes.message;
                    respwrap.status = 'Error';
                    resp = JSON.serialize(respwrap);
                    ErrorLogger.writeError( 'SFDC', 'Athena fetch File Api', 'AthenaFetchFileCtrl.fetchQuoteFile', res.getBody(),resp, resp);
                    System.debug('Callout error: '+ res.getBody()); 
                }
         
            } catch(System.CalloutException e) {
                respwrap.description = 'Error while fetching file';
                respwrap.status = 'Error';
                System.debug('Callout error: '+ e);
                ErrorLogger.writeErrors( 'SFDC', 'Athena fetch File Api', 'AthenaFetchFileCtrl.fetchQuoteFile', new list<Exception>{e});
            }
        }else{
            respwrap.description = 'Error while fetching file';
            respwrap.status = 'Error';
        }
		system.debug(respwrap);
        return respwrap;
    }



    public class ClientCredentialResponse {
        public String access_token;
        public String scope;
        public String id_token;
        public String token_type;
        public Integer expires_in;
    }

    public class ErrorResponse{
        public String method;	//POST
        public String requestUri;	///global-mdm/customers/IN02329380/contacts/validate
        public String status;	//400
        public String statusText;	//Bad Request
        public String timestamp;	//18-02-2023 16:30:45
        public String message;	//Validation errors
    }


    public class responsewrap {
        @AuraEnabled
        public string status;
        @AuraEnabled
        public string description;
        @AuraEnabled
        public string filename;
    }
}