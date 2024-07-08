public class AzureRequestCalloutCls {
    
    public static String getAzureAccessToken(){
        HttpRequest req = new HttpRequest();
        
        //req.setEndpoint('https://api.loopio.com/oauth2/access_token');
        //String reqbody = 'grant_type=client_credentials&scope=user:read user:write&client_id=bKUEoeFtGceGys2WbKR14VKr0unqaTcR%2BdKFKxVDtdA=&client_secret=kdI3nnvGUVcDGW7zXRpRslFkmOPAD8SvZFCeu9Xf9Xg=';
        string resource='api://f82a45c6-6fd6-4392-aadd-4c8429877ed2';
        req.setEndpoint('callout:Azure_token');
        String reqbody = 'grant_type=client_credentials&client_id={!$Credential.Username}&client_secret={!$Credential.Password}&resource=api://f82a45c6-6fd6-4392-aadd-4c8429877ed2';
        
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        req.setBody(reqbody);       
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        String resStr =  res.getBody();
        system.debug(resStr);
        
        Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(resStr);
        string accessToken = (String)mapResponse.get('access_token');
        
        return accessToken;
    }
    @future(callout=true) 
    public static void AzureDisableUsersByEmail(string userEmail){
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint('https://api.maersk.com/cloud-id-api/api/GroupUpdate');
        req.setMethod('POST'); 
        req.setHeader('content-type', 'application/json'); 
        req.setTimeout(120000);
        
        RequestbodyWrap reqWrap=new RequestbodyWrap();
        reqWrap.groupId=label.GroupId;
        reqWrap.groupAction='removeMember';
        reqWrap.refObject=userEmail;
        
        String strBody = JSON.serialize(reqWrap);
        
        req.setbody(strBody); 
        
        
        Http http = new http();
        Httpresponse res;
        string  accessToken = getAzureAccessToken();
        if(accessToken != null){ 
            //setting Authorization header with the access token
            req.setHeader('Authorization','Bearer ' + accessToken);
            try{
                res = http.send(req);
                system.debug('response'+res);
                
            }
            catch(Exception e){
                system.debug('error:'+e.getMessage());
                ErrorLogger.writeError('SFDC', 'User', 'AzureRequestCalloutCls.AzureDisableUsersByEmail', e.getTypeName(), e.getMessage(), e.getStackTraceString());    
                
                
            }
        }
    } 
    
    public class RequestbodyWrap {
        
        public string groupId;
        public string groupAction;
        public string refObject;
    }
}