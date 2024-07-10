/*
Description  : Perform callout to get Id_Token for AO API

* version       Date                Owner                                       Description
*******************************************************************************************************************
* V1.0          21/01/2020          sreya.v@maersk.com                    Perform callout to get Id_Token for AO API.
* V2.0          11/09/2020          Sriram.kalluri@maersk.com             Perform callout to get FRToken for GCSS Apis.
* V3.0          27/04/2021          Richa@maersk                          Created sendAzureOHPRequest and added getAzureOHPToken method to perform callout to Azure EventHub for OHP Disputes.
* V4.0          20/07/2021          Richa@maersk                          Perform callout to get FRToken for GCSS Writeback Apis.
* V5.0          11/01/2024          Vivek@maersk                          Added new header akamaiRequestHeader to authorize at Akamai for getFRToken() Method
*-------------------------------------------------------------------------------------------------------------------
*/
public class AO_APILoginUtility {   
    
    public static General_Key_Value_Configurations__mdt akamaiHeader = General_Key_Value_Configurations__mdt.getInstance('AkamaiRequestHeader');

    public static String getLoginIdToken(string operator,AO_Services__mdt custommetadata) {
        string accessToken;
        //Getting the access token from org cache
        accessToken = (String)Cache.Org.get('tokenId'+operator+custommetadata.Environment__c);            
        //Making the call out to get access token if it is lost in cache.
        if (accessToken == null) {
            system.debug('cache lost');
            
            // Setting operator parameter dynamically to the end point fetched from the named credential.
            String urlParameterString = Label.AOLoginParameterString+operator;
            HttpRequest req = new HttpRequest();
            //req.setEndpoint('https://api.maersk.com/oauthTokens?customerCode=10000007951&brandCode=MAEU');
            req.setEndpoint(
                String.format(
                    'callout:'+custommetadata.NamedCred__c+'/{0}?{1}',
                    new String[]{'oauthTokens', urlParameterString}
                )
            );
            
            
            req.setHeader('userName', '{!$Credential.Username}');
            req.setHeader('password', '{!$Credential.Password}');
            //System.debug('username '+req.getHeader('password'));
            
            req.setMethod('GET');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            String resStr =  res.getBody();
            System.debug('>>>access token end point : ' + req.getEndpoint());
            //System.debug('>>>getLoginIdToken : ' + resStr +'nive');
            Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(resStr);
            accessToken = (String)mapResponse.get('idToken');
            System.debug('accessToken ==> '+accessToken);
            if(accessToken != null){
                Cache.Org.put('tokenId'+operator+custommetadata.Environment__c, accessToken,6900);
            }
        } 
        System.debug('accessToken '+accessToken);
        return  accessToken;           
        
    }
    
    public static String getFRToken(AO_Services__mdt custommetadata) {
        string accessToken;
        //Getting the access token from org cache
        if(!Test.isRunningTest()){
            accessToken = (String)Cache.Org.get('FRToken'+custommetadata.Environment__c+custommetadata.Authorization_Key__c);            
        }
        //Making the call out to get access token if it is lost in cache.
        if (accessToken == null || accessToken == '') {
            
            system.debug('****accessToken '+accessToken);
            HttpRequest req = new HttpRequest();
            String reqbody = 'grant_type=client_credentials&client_id={!$Credential.Username}&client_secret={!$Credential.Password}';
            req.setEndpoint('callout:'+custommetadata.NamedCred__c);            
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            if(akamaiHeader!= null && akamaiHeader.First_Field_Value__c != null )
            	req.setHeader('x-requestor',akamaiHeader.First_Field_Value__c);//added new header as part of Token api issue resolution from akamai
            req.setMethod('POST');
            req.setBody(reqbody);
            System.debug('****reqbody ==> '+reqbody);
            System.debug('****req ==> '+req);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            system.debug('****res--->'+res);
            String resStr =  res.getBody();
            System.debug('****res.getBody() ==> '+res.getBody());
            
            
            Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(resStr);
            accessToken = (String)mapResponse.get('access_token');
            System.debug('accessToken ==> '+accessToken);
            if(accessToken != null){
                if(!Test.isRunningTest()){
                    Cache.Org.put('FRToken'+custommetadata.Environment__c+custommetadata.Authorization_Key__c, accessToken,7000);
                }
            }
            
        }
        System.debug('accessToken '+accessToken);
         return accessToken;        
    }
    
     public static String getFRTokenMyfinance(AO_Services__mdt custommetadata) {
        
        string id_token;
        //Getting the access token from org cache
        id_token = (String)Cache.Org.get('FRTokenMyfinance'+custommetadata.Environment__c);            
        //Making the call out to get access token if it is lost in cache.
        if (id_token == null || id_token == '') {
            
            HttpRequest req = new HttpRequest();
            String reqbody = 'grant_type=client_credentials&client_id={!$Credential.Username}&client_secret={!$Credential.Password}';
            req.setEndpoint('callout:'+custommetadata.NamedCred__c);            
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            if(akamaiHeader!= null && akamaiHeader.First_Field_Value__c != null )
            	req.setHeader('x-requestor',akamaiHeader.First_Field_Value__c);//added new header as part of Token api issue resolution from akamai
       
            req.setMethod('POST');
            req.setBody(reqbody);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('req ==> '+req);
            String resStr =  res.getBody();
            System.debug('****res.getBody() ==> '+res.getBody());
            
            
            Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(resStr);
            id_token = (String)mapResponse.get('id_token');
            System.debug('id_token ==> '+id_token);
            if(id_token != null){
                Cache.Org.put('FRTokenMyfinance'+custommetadata.Environment__c, id_token,7000);
            }
            
        }
        System.debug('id_token '+id_token);
         return  id_token;        
    }


    
    public static string sendRequest(HttpRequest req,AO_Services__mdt AOServiceDetail) {
        message msg = new message();
        http httpobj = new http();
        httpresponse res;
        string  accessToken = getFRToken(AOServiceDetail);
        if(accessToken != null ||Test.isRunningTest()){ 
            //setting Authorization header with the access token
            req.setHeader('Authorization','Bearer '+accessToken);
            try{
                res = httpobj.send(req);
                return res.getBody();
            }
            catch(Exception e){
                //throwing the exception message in case of any service exception
                system.debug('error:'+e.getMessage());
                return e.getMessage();
            }
        }else{
            //Setting custom message if access token is not retrieved correctly.               
            msg.message = Label.AccessTokenFailed;
            return JSON.serialize( msg);
        }
    }    

   /* public static string sendRequestForShipmentParty(HttpRequest req,AO_Services__mdt AOServiceDetail){
        message msg = new message();
        http httpobj = new http();
        httpresponse res;
        string  accessToken = getFRToken(AOServiceDetail);
        if(accessToken != null){ 
            //setting Authorization header with the access token
            req.setHeader('Authorization','Bearer '+accessToken);
            req.setHeader('API-version','1');
            try{ 
                res = httpobj.send(req);
                return res.getBody();
            }
            catch(Exception e){
                //throwing the exception message in case of any service exception
                system.debug('error:'+e.getMessage()+' '+e.getLineNumber());
                return e.getMessage();
            }
        }else{
            //Setting custom message if access token is not retrieved correctly.               
            msg.message = Label.AccessTokenFailed;
            return JSON.serialize( msg);
        }
    }*/

    public static String getFRTokenForWriteBack(GCSS_Write_Back_Services__mdt custommetadata) {        
        String accessToken;
        //Getting the access token from org cache
        accessToken = (String)Cache.Org.get('FRToken'+custommetadata.Environment__c);            
        //Making the call out to get access token if it is lost in cache.
        if (accessToken == null || accessToken == '') {            
            system.debug('setEndpoint '+accessToken);
            HttpRequest req = new HttpRequest();
            String reqbody = 'grant_type=client_credentials&client_id={!$Credential.Username}&client_secret={!$Credential.Password}';
            req.setEndpoint('callout:'+custommetadata.NamedCred__c);            
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            if(akamaiHeader!= null && akamaiHeader.First_Field_Value__c != null )
            	req.setHeader('x-requestor',akamaiHeader.First_Field_Value__c);//added new header as part of Token api issue resolution from akamai
        
            req.setMethod('POST');
            req.setBody(reqbody);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('req ==> '+req);
            String resStr =  res.getBody();
            System.debug('****res.getBody() ==> '+res.getBody());            
            
            Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(resStr);
            accessToken = (String)mapResponse.get('access_token');
            System.debug('accessToken ==> '+accessToken);
            if(accessToken != null){
                Cache.Org.put('FRToken'+custommetadata.Environment__c, accessToken,7000);
            }
            
        }
        System.debug('accessToken '+accessToken);
         return  accessToken;        
    }
    
    public static string sendWriteBackRequest(HttpRequest req,GCSS_Write_Back_Services__mdt GCSSWBDetail) {
        message msg = new message();
        http httpobj = new http();
        httpresponse res;
        String accessToken = getFRTokenForWriteBack(GCSSWBDetail);        
        if(accessToken != null){               
            req.setHeader('Authorization','Bearer '+accessToken);
            try{ 
                res = httpobj.send(req);               
                if(!String.isEmpty(res.getBody())){               
                return res.getBody(); 
                }
                else{                
                return String.valueOf(res.getStatusCode());  
                }
            }
            catch(Exception e){              
                system.debug('error:'+e.getMessage());
                return e.getMessage();
            }
        }else{                 
            msg.message = Label.AccessTokenFailed;
            return JSON.serialize( msg);
        }
    }  

  //SC-2183 
    public static String getAzureOHPToken(AO_Services__mdt custommetadata) {       
        String accessToken = (String)Cache.Org.get('OHPToken'+custommetadata.Environment__c);    
        if (accessToken == null || accessToken == '') {            
            HttpRequest req = new HttpRequest();           
            String reqbody = 'grant_type=client_credentials&resource=https://eventhubs.azure.net&client_id={!$Credential.Username}&client_secret={!$Credential.Password}';           
            req.setEndpoint('callout:'+custommetadata.NamedCred__c);            
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
               
            req.setMethod('POST');
            req.setBody(reqbody);
            Http http = new Http();
            HTTPResponse res = http.send(req);           
            String resStr =  res.getBody(); 
            System.debug('***OHP token received'+res.getBody());            
            Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(resStr);
            accessToken = (String)mapResponse.get('access_token');            
            if(accessToken != null){                
                Cache.Org.put('OHPToken'+custommetadata.Environment__c, accessToken,3600);                               
            }
            
        }
        System.debug('***accessToken '+accessToken);
        return  accessToken;        
    }
    
     //SC-2183 
    public static string sendAzureOHPRequest(HttpRequest req,AO_Services__mdt AOServiceDetail) {
        message msg = new message();
        http httpobj = new http();
        httpresponse res;
        String accessToken = getAzureOHPToken(AOServiceDetail);
        String status = '';
        if(accessToken != null){ 
            //setting Authorization header with the access token
            req.setHeader('Authorization','Bearer '+accessToken);
            try{ 
                res = httpobj.send(req);
                system.debug('response returned--'+res.getStatus()+'--code--'+res.getStatusCode()+'--body--'+res.getBody());
                if(res.getStatusCode() == 201){
                  status = res.getStatus(); 
                }               
                return status;                
            }
            catch(Exception e){               
                System.debug('error:'+e.getMessage());
                ErrorLogger.writeErrors( 'SFDC', 'Case', 'WebserviceUtilities.sendAzureOHPRequest', new list<Exception>{e});
                return e.getMessage();
            }
        }else{
            //Setting custom message if access token is not retrieved correctly.               
            msg.message = Label.AccessTokenFailed;
            return JSON.serialize( msg);
        }
    }   
    
     
     //TMS request
    public static string sendTMSRequest(HttpRequest req,AO_Services__mdt AOServiceDetail) {
        message msg = new message();
        http httpobj = new http();
        httpresponse res;
        string  accessToken = getFRTokenForTms(AOServiceDetail);
        if(accessToken != null){ 
            //setting Authorization header with the access token
            req.setHeader('Authorization','Bearer '+accessToken);
            try{
                  res = httpobj.send(req);
                
                if(res.getStatusCode() == 200){
                    system.debug('test1--->:'+res);
                      return res.getBody(); 
                }else if(res.getStatusCode() == 500){
                    system.debug('test2--->:'+res);
                    return 'Internal Server Error';
                }else {
                    system.debug('test3--->:'+res);
                    return res.getBody();
                }
              
            }
            catch(Exception e){
                //throwing the exception message in case of any service exception
                system.debug('error:'+e.getMessage());
                return e.getMessage();
            }
        }else{
            //Setting custom message if access token is not retrieved correctly.               
            msg.message = Label.AccessTokenFailed;
            return JSON.serialize( msg);
        }
    }

    public static String getFRTokenForTms(AO_Services__mdt custommetadata) {
        
        string accessToken;
        //Getting the access token from org cache
        accessToken = (String)Cache.Org.get('FRTokenTMS'+custommetadata.Environment__c);            
        //Making the call out to get access token if it is lost in cache.
        if (accessToken == null || accessToken == '') {
            
            system.debug('setEndpoint '+accessToken);
            HttpRequest req = new HttpRequest();
            String reqbody = 'grant_type=client_credentials&client_id={!$Credential.Username}&client_secret={!$Credential.Password}';
            req.setEndpoint('callout:'+custommetadata.NamedCred__c);            
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
             if(akamaiHeader!= null && akamaiHeader.First_Field_Value__c != null )
            	req.setHeader('x-requestor',akamaiHeader.First_Field_Value__c);//added new header as part of Token api issue resolution from akamai
            req.setMethod('POST');
            req.setBody(reqbody);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('req ==> '+req);
            String resStr =  res.getBody();
            System.debug('****res.getBody() ==> '+res.getBody());
            
            
            Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(resStr);
            accessToken = (String)mapResponse.get('access_token');
            System.debug('accessToken ==> '+accessToken);
            if(accessToken != null){
                Cache.Org.put('FRTokenTMS'+custommetadata.Environment__c, accessToken,7000);
            }
            
        }
        System.debug('accessToken '+accessToken);
         return  accessToken;        
    }
       
    public class message{
        @AuraEnabled public string message{get;set;}
    }
}