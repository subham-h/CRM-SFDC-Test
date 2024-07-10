/*
 * Author   : Sunil BS
 * Purpose  : Queueable class to Pull Data from Google Analytics for NBA back to salesforce
 *         
 * Revision Ref Number  Date               Owner                     Description
 * -------- ----------  -----------        -------------------       -----------
 * 1.0      SC - 4042   14-Jan-2021        Sunil.bs@maersk.com       Pull Data from GA to SFDC using JWT Token Exchange
 * 
 */

public class NBAGAQueueable implements Queueable,Database.AllowsCallouts{

    public  integer GAcalloutCount;
    public  string token;
    public  Boolean isFirstJob;
    public  string nextPageToken;
    
    // Contructor to intiate Token, current Callout count and to check if first Job
    public  NBAGAQueueable(integer GAcalloutCount,string token, Boolean isFirstJob,string nextPageToken){
    this.GAcalloutCount = GAcalloutCount;
    this.token = token;
    this.isFirstJob = isFirstJob;
    this.nextPageToken = nextPageToken;
    }
    
    public void execute (QueueableContext context){
              
        try{
                // Authentication Credentials are stored in Custom Metadata called NBACalloutCredentials
                General_Settings__c gs =General_Settings__c.getInstance();
                GA_JWT_Token_Exchange_Credentials__mdt NBACalloutCredentials = [select Audiences__c,Endpoint_URL__c,Issuer__c,JWT_Signing_Certificate__c,Scope__c,Token_Endpoint_Url__c,ViewId__c,Timeout__c from GA_JWT_Token_Exchange_Credentials__mdt where label = 'NBA Google Analytics Metrics'] ;
                String AUTH_ENDPOINT = NBACalloutCredentials.Token_Endpoint_Url__c;
                String SCOPE = NBACalloutCredentials.Scope__c;
                String ISSUER = NBACalloutCredentials.Issuer__c;
                String JWTSigningCertificate = NBACalloutCredentials.JWT_Signing_Certificate__c;
                String EndpointURL = NBACalloutCredentials.Endpoint_URL__c;
                String ViewId =  NBACalloutCredentials.ViewId__c;
                Integer Timeout = integer.valueOf(NBACalloutCredentials.Timeout__c);             
                list<Case> GACaseList = new list<case>();
            
                // Check if it is the first job that was scheduled from scheduler
                //Note: Token is genrated only once and it has to be the same in subsequent chained Queable jobs
                if (isFirstJob!=null && isFirstJob==true){
                               
                // First Callout to get Token using JWT Token Exchange Credentials
                    token = '';                
                    if (!Test.isRunningTest()){
                        Auth.JWT jwt = new Auth.JWT();
                        jwt.setAud(AUTH_ENDPOINT);
                        jwt.setIss(ISSUER);
                        jwt.setAdditionalClaims(new Map<String, Object>{'scope' => SCOPE});
                             
                        Auth.JWS jws = new Auth.JWS(jwt, JWTSigningCertificate);
                        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(AUTH_ENDPOINT, jws);
                        token = bearer.getAccessToken();
                    }
                    else{
                        token = '';
                    }          
            }

        // Note: There might be 48 hours delay in which cases might get updated at GA itself after customer has done case clicks.
        // Second Callout is made to retrieve Data from GA in JSON format
        // Get Yesterday's updated Cases from GA, so that cases updated after this job as run for the day also comes into our system. 
        DateTime yesterdaysDate = System.today()-1;
        String yesterdaysDateStr = yesterdaysDate.format('yyyy-MM-dd');
        // In Future if any new metrics or Dimention are additionally Queried Dev need to check if Page views are summed for a caseid and sent by GA, or else it needs to be handled in our code        
        String body = '{"reportRequests":[{"viewId":"'+ViewId+'","dateRanges":[{"startDate":"'+yesterdaysDateStr+'","endDate":"'+yesterdaysDateStr+'"}],"dimensions":[{"name":"ga:Keyword"}],"metrics":[{"expression":"ga:Pageviews"},],"dimensionFilterClauses":[{"filters":[{"dimensionName":"ga:source","operator":"EXACT","expressions":["CMSF"]}]}],"pageToken":"'+nextPageToken+'","pageSize":"'+gs.NBA_PageSize__c.format()+'"}]}';               
        
        Http h = new Http();       
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(EndpointURL);
        req.setHeader('Authorization', 'Bearer '+token);      
        req.setMethod('POST');
        req.setBody(body);
        req.setTimeout(Timeout);
        HTTPResponse res = h.send(req);
   
              if(res.getStatusCode() == 200){ 
                   // The Response is parsed to Form 'Google Analytics Metrics' Record list to be upserted into the system in the execute method
                         NBAGoogleAnalyticsWrapper datacls =  NBAGoogleAnalyticsWrapper.parse(res.getBody());
                         NBAGoogleAnalyticsWrapper.reports rowinst= new NBAGoogleAnalyticsWrapper.reports();
                            
                     if(datacls!=null && datacls.reports!=null){  
                             rowinst = datacls.reports[0];
                              if(rowinst.data!=null){  
                                nextPageToken = rowinst.nextPageToken;
                                for(NBAGoogleAnalyticsWrapper.Rows GAinst:rowinst.data.rows){
                                    //Data which has no CaseId's are ignored                                                              
                                   if(GAinst.dimensions[0].length() <= 18 && GAinst.dimensions[0].length() >= 15 && GAinst.dimensions[0].startsWithIgnoreCase('5002')){
                                     Decimal GAPageviews = decimal.valueOf(GAinst.metrics[0].values[0]);                              
                                     GACaseList.add(new case(id=GAinst.dimensions[0], NBA_Customer_Page_Views__c = GAPageviews));
                                     }   
                                }  
                             }
                      }
                         //if Data is returned only then we insert it into our system
                         if (GACaseList!=null && !GACaseList.isempty()){
                               TriggerExecutionController.skipAllTriggers(true);
                               Database.SaveResult[] lstSaveResults = Database.Update(GACaseList,false);
                               TriggerExecutionController.skipAllTriggers(false);
                               ErrorLogger.writeErrors('SFDC', 'Case', 'NBAGAQueueable.execute()', lstSaveResults, GACaseList);
                         }
                            
                           //Increment the API callout counter, stop creating Queable jobs if max counter is reached or there are no further data to process
                          if (GAcalloutCount<gs.NBA_API_Callout_Count__c && String.isNotBlank(gs.NBA_API_Callout_Count__c.format()) && GAcalloutCount!=null  && nextPageToken!=null && String.isNotBlank(nextPageToken)){   
                               GAcalloutCount++;
                               // Chain Next Queable JOb
                               ID jobID = System.enqueueJob(new NBAGAQueueable(GAcalloutCount,token,false,nextPageToken));
                               system.debug('Jobid'+jobID);
                          }       
                 }

                else{                   
                     system.debug('Error on Queaueble Execution');
                     ErrorLogger.writeError( 'SFDC', 'Case', 'NBAGAQueueable.execute()',string.ValueOf(res.getStatusCode()) , res.getStatus(),res.getBody());               
              }  
            
           }catch(Exception e){
                     system.debug('Error on Queaueble Execution'+e.getMessage()+'  line numb:'+e.getLineNumber());
                     ErrorLogger.writeErrors( 'SFDC', 'Case', 'NBAGAQueueable.execute()', new list<Exception>{e});             
            }
    }//End of Execute        
}//End of Class