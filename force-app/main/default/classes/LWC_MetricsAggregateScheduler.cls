public class LWC_MetricsAggregateScheduler implements schedulable{
    public void execute(SchedulableContext sc){
        aggregateLWCUsage();
    }
    
    @future (callout=true)
    public static void aggregateLWCUsage(){
        try{
            
            // Querying metadata for certificate and endpoint
            LWC_Heroku_Integration__mdt mdtObj = WebserviceUtilities.getHerokuLWCMetadata('LWC Metrics Aggregate');
            system.debug('metadata'+mdtObj);
            
            // calling getJWTBearer method for getting JWT token
            string jwtToken = WebserviceUtilities.getJWTBearer(mdtObj.Certificate_Name__c,mdtObj.Role__c,mdtObj.Audience__c);
            system.debug('jwtToken'+jwtToken);
            
            // making the heroku post call
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json'); 
            req.setHeader('Authorization', 'Bearer '+jwtToken);           
            req.setEndpoint(mdtObj.End_point_URL__c);
            
            http httpobj = new http();
            HttpResponse res = httpobj.send(req);
            system.debug('heroku response'+res.getBody());
            system.debug('heroku status'+res.getStatusCode());
            if (res.getStatusCode()<200 || res.getStatusCode()>299){
                //Writing the exception details to global error logger record.
                ErrorLogger.writeError( 'SFDC', 'Case', 'WebserviceUtilities.connectServiceUsageToHeroku',string.ValueOf(res.getStatusCode()) , res.getStatus(),res.getBody());               
            }
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
            //Writing the exception details to global error logger record.
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'LWC_MetricsAggregateScheduler.aggregateLWCUsage', new list<Exception>{ex});
        }       
        
    }
}