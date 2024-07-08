global class TestPresenceConfigUser {
	
    public class requestBodyWrapper {
    public List<CompositeRequest> compositeRequest;
}

public class CompositeRequest {
    public String method;
    public String url;
    public String referenceId;
    public Object body;
    CompositeRequest(string componentType){            
        if(componentType == 'PresenceUserConfigUserAddition'){
            this.Body = new PresenceUserConfigUserBody();
        }
        
    }
}


public class PresenceUserConfigUserBody {
    public String PresenceUserConfigId;
    public String UserId;
}   

@InvocableMethod(label='Create PresenceUserConfig' description='Returns nothing' category='PresenceUserConfig')
public static List<String> makeRequestMethod(List<String> userId){
    //DateTime start = System.Now();
        //while(System.Now().getTime()< start.getTime()+2000){ //Delay
    system.debug('In the makeRequestMethod invocable method');
 	createPresenceConfigFuture();
 	/*List<CompositeRequest> compositeRequestList = new List<CompositeRequest>();
         CompositeRequest comp = new CompositeRequest('PresenceUserConfigUserAddition');
    comp.method = 'POST';
    comp.url = '/services/data/v55.0/sobjects/PresenceUserConfigUser';
    comp.referenceId = String.valueOf(0);
    PresenceUserConfigUserBody bod = new PresenceUserConfigUserBody();
    
    bod.PresenceUserConfigId = '0Nd2o0000004CAu';                 
        bod.userid = '0052o000009NAc6AAG';
        comp.body = bod;
    compositeRequestList.add(comp);
    
    //Code piece for callout
    requestBodyWrapper requestBodyWrapperInstance = new requestBodyWrapper();
    requestBodyWrapperInstance.compositeRequest = compositeRequestList;
    
    Http h = new Http();
    HttpRequest req = new HttpRequest();
    req.setMethod('POST');        
    req.setHeader('content-type', 'application/json');
    req.setHeader ('Authorization', 'Bearer ' + userinfo.getSessionId()); 
    req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+ '/services/data/v55.0/composite/');
    req.setBody(JSON.serialize(requestBodyWrapperInstance));   
    system.debug('Request '+JSON.serialize(requestBodyWrapperInstance));
    HttpResponse res = h.send(req);
    system.debug('Response Status ===== '+res.getStatus());
                system.debug('Response Status Code ===== '+res.getStatusCode());
                system.debug('Response Body ===== '+res.getBody());
            //}*/
    return new List<string>();
        
}
    
    @future(callout=true)
    public static void createPresenceConfigFuture()
    {   List<CompositeRequest> compositeRequestList = new List<CompositeRequest>();
         CompositeRequest comp = new CompositeRequest('PresenceUserConfigUserAddition');
    comp.method = 'POST';
    comp.url = '/services/data/v55.0/sobjects/PresenceUserConfigUser';
    comp.referenceId = String.valueOf(0);
    PresenceUserConfigUserBody bod = new PresenceUserConfigUserBody();
    
    bod.PresenceUserConfigId = '0Nd2o0000004CAu';                 
        bod.userid = '0052o000009NAc6AAG';
        comp.body = bod;
    compositeRequestList.add(comp);
    
    //Code piece for callout
    requestBodyWrapper requestBodyWrapperInstance = new requestBodyWrapper();
    requestBodyWrapperInstance.compositeRequest = compositeRequestList;
    
    Http h = new Http();
    HttpRequest req = new HttpRequest();
    req.setMethod('POST');        
    req.setHeader('content-type', 'application/json');
    req.setHeader ('Authorization', 'Bearer ' + userinfo.getSessionId()); 
    req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+ '/services/data/v55.0/composite/');
    req.setBody(JSON.serialize(requestBodyWrapperInstance));   
    system.debug('Request '+JSON.serialize(requestBodyWrapperInstance));
    HttpResponse res = h.send(req);
    system.debug('Response Status ===== '+res.getStatus());
                system.debug('Response Status Code ===== '+res.getStatusCode());
                system.debug('Response Body ===== '+res.getBody());
    }
                
}