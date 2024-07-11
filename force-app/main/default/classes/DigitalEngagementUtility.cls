/*              
* Revision Ref Number  Date        Owner				Description
* -------- ----------  ----------- -----------------   -----------
* 1.0      SFMC-7400   1-April-2024  ranjan@maersk		Code created
*/
public without sharing class DigitalEngagementUtility {
      /*********************************************************************
     * Method Name:getSFMCDigitalEngageToken
     * Purpose: Make a callout to SFMC and 
     *          get the Access token to access the digital engagement data
     * Parameter:"contactId" to take the id of the contact supplied from marketingEngagement.js
     */
    public static String getSFMCDigitalEngageToken(AO_Services__mdt custommetadata) {       
        //check the cache for the cached token     
        String accessToken = (String)Cache.Org.get('DigitalEngagementToken'+custommetadata.Environment__c);    
        if (accessToken == null || accessToken == '') {            
            HttpRequest req = new HttpRequest();           
            String reqbody = '{\"grant_type\":\"client_credentials\",\"client_id\":\"{!$Credential.Username}\",\"client_secret\":\"{!$Credential.Password}\"}';           
            req.setEndpoint('callout:'+custommetadata.NamedCred__c); //use of named credentials           
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('POST');
            req.setBody(reqbody);
            Http http = new Http();
            HTTPResponse res = http.send(req);           
            String resStr =  res.getBody();            
            Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(resStr);
            accessToken = (String)mapResponse.get('access_token'); 
            Integer epiresIn= Integer.valueOf(mapResponse.get('expires_in'));          
            if(accessToken != null){   //place the token in the cache for "expires_in" seconds             
                Cache.Org.put('DigitalEngagementToken'+custommetadata.Environment__c, accessToken,epiresIn);                               
            }
            
        }
        return  accessToken;        
    }
    /*********************************************************************
     * Method Name:sendSFMCDigitalEngRequest
     * Purpose: Make a callout to SFMC and 
     *          get the Digital engagement data related to supplied contact id.
     * Parameter:"contactId" to take the id of the contact supplied from marketingEngagement.js
     */
    @AuraEnabled(cacheable=false)
    public static string sendSFMCDigitalEngRequest(String contactId) {
        AO_Services__mdt AOServiceDetail=AO_Services__mdt.getInstance('DigitalEngagement');
        HttpRequest req=new HttpRequest();
        http httpobj = new http();
        httpresponse res;
        String accessToken = getSFMCDigitalEngageToken(AOServiceDetail);
        String status = '';
        if(accessToken != null){ 
            //setting Authorization header with the access token
            req.setHeader('Authorization','Bearer '+accessToken);
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('GET');
            req.setEndpoint(AOServiceDetail.End_point_URL__c+'\''+contactId+'\'');
            try{ 
                res = httpobj.send(req);
                if(res.getStatusCode() == 201){
                  status = res.getStatus(); 
                }               
                return res.getBody();                
            }
            catch(Exception e){               
                ErrorLogger.writeErrors( 'SFDC', 'Case', 'WebserviceUtilities.sendAzureOHPRequest', new list<Exception>{e});
                return e.getMessage();
            }
        }
        return null;
    }   
}