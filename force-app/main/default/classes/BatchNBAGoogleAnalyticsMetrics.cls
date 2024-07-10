/*
 * Author   : Sunil BS
 * Purpose  : Batch class to Pull Data from Google Analytics for NBA back to salesforce
 *         
 * Revision Ref Number  Date               Owner                     Description
 * -------- ----------  -----------        -------------------       -----------
 * 1.0      SC - 4042   14-Jan-2021        Sunil.bs@maersk.com       Pull Data from GA to SFDC using JWT Token Exchange
 * 
 */

 global class  BatchNBAGoogleAnalyticsMetrics implements Database.Batchable<Sobject>,Database.AllowsCallouts{
    
    
    // Start Method Includes Making an intitial callout to get Access token using JWT Token Exchange
    // Subsequently the Token is used to get GA Data back to SFDC in the format JSON Response 
    // The Response is parsed to Form 'Google Analytics Metrics' Record list to be upserted into the system in the execute method
    global list<Sobject> start(Database.BatchableContext BC) { 
       
        GA_JWT_Token_Exchange_Credentials__mdt NBACalloutCredentials = [select Audiences__c,Endpoint_URL__c,Issuer__c,JWT_Signing_Certificate__c,Scope__c,Token_Endpoint_Url__c from GA_JWT_Token_Exchange_Credentials__mdt where label = 'NBA Google Analytics Metrics'] ;
        
        // Authentication Credentials are stored in Custom Metadata called NBACalloutCredentials
        String AUTH_ENDPOINT = NBACalloutCredentials.Token_Endpoint_Url__c;
	    String SCOPE = NBACalloutCredentials.Scope__c;
        String ISSUER = NBACalloutCredentials.Issuer__c;
        String JWTSigningCertificate = NBACalloutCredentials.JWT_Signing_Certificate__c;
        String EndpointURL = NBACalloutCredentials.Endpoint_URL__c;
     
        list<Case> GACaseList = new list<case>();
            
        try{
        // First Callout to get Token using JWT Token Exchange Credentials
            String token = '';
        
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
           
            
        //Second Callout is made to retrieve Data from GA in JSON format
        DateTime todaysDate = System.today();
        String todaysDateStr = todaysDate.format('yyyy-MM-dd');
        DateTime todaysDateminussev = System.today()-7;
        String todaysDateStrminussev = todaysDateminussev.format('yyyy-MM-dd');
            
        // In Future if any new metrics or Dimention are additionally Queried Dev need to check if Page views are summed for a caseid and sent by GA, or else it needs to be handled in our code        
        String body = '{"reportRequests":[{"viewId":"130808795","dateRanges":[{"startDate":"'+todaysDateStrminussev+'","endDate":"'+todaysDateStr+'"}],"dimensions":[{"name":"ga:Keyword"},{"name":"ga:source"},{"name":"ga:Campaign"}],"metrics":[{"expression":"ga:Pageviews"},],"dimensionFilterClauses":[{"filters":[{"dimensionName":"ga:source","operator":"EXACT","expressions":["CMSF"]}]}],"pageSize":"100000"}]}';       
        //String body = '{"reportRequests":[{"viewId":"130808795","dateRanges":[{"startDate":"2021-11-29","endDate":"2022-01-14"}],"dimensions":[{"name":"ga:Keyword"},{"name":"ga:source"},{"name":"ga:Campaign"}],"metrics":[{"expression":"ga:Pageviews"},],"dimensionFilterClauses":[{"filters":[{"dimensionName":"ga:source","operator":"EXACT","expressions":["CMSF"]}]}],"pageSize":"100000"}]}';
        
        Http h = new Http();       
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(EndpointURL);
        req.setHeader('Authorization', 'Bearer '+token);      
        req.setMethod('POST');
        req.setBody(body);
        HTTPResponse res = h.send(req);
       
   
         		 if(res.getStatusCode() == 200){ 
                   // The Response is parsed to Form 'Google Analytics Metrics' Record list to be upserted into the system in the execute method
                             NBAGoogleAnalyticsWrapper datacls =  NBAGoogleAnalyticsWrapper.parse(res.getBody());
                             NBAGoogleAnalyticsWrapper.reports rowinst= new NBAGoogleAnalyticsWrapper.reports();
                             rowinst = datacls.reports[0];
                                                      
                            for(NBAGoogleAnalyticsWrapper.Rows GAinst:rowinst.data.rows){
                                    //Data which has no CaseId's are ignored                                                              
                                	 if(GAinst.dimensions[0].length() <= 18 && GAinst.dimensions[0].length() >= 15 && GAinst.dimensions[0].startsWithIgnoreCase('5002')){
                                     Decimal GAPageviews = decimal.valueOf(GAinst.metrics[0].values[0]);                              
                                     GACaseList.add(new case(id=GAinst.dimensions[0], NBA_Customer_Page_Views__c = GAPageviews));
                                }   
                            }  
                 }
            
                 else if(res.getStatusCode() != 200){                    
                     system.debug('Error on Batch Execution');
                     ErrorLogger.writeError( 'SFDC', '', 'BatchNBAGoogleAnalyticsMetrics',string.ValueOf(res.getStatusCode()) , res.getStatus(),res.getBody());               
                 }
                       
        }
        catch(Exception e){
                     system.debug('Error on Batch Execution'+e.getMessage());
                     ErrorLogger.writeErrors( 'SFDC', 'case', 'BatchNBAGoogleAnalyticsMetrics.start()', new list<Exception>{e});             
        }
       
        return GACaseList;
    }
    
    
    global void execute(Database.BatchableContext BC, List<Sobject> GACaseList) {
                   
        // Try updating the GA Data with allOrNone set to false so the whole update isn't rolled back if just one record fails...
        try{
            
          	if(GACaseList!=null){                       
            TriggerExecutionController.skipAllTriggers(true);
            Database.SaveResult[] lstSaveResults = Database.Update(GACaseList,false);
            TriggerExecutionController.skipAllTriggers(false);
            ErrorLogger.writeErrors('SFDC', 'Case', 'BatchNBAGoogleAnalyticsMetrics', lstSaveResults, GACaseList);
   		    }
            
        }catch (Exception e){
            system.debug('Error on Batch Execution'+e.getMessage());
            ErrorLogger.writeErrors( 'SFDC','Case', 'BatchNBAGoogleAnalyticsMetrics', new list<Exception>{e}); 
          }
    }

    global void finish(Database.BatchableContext BC) {     
    } 
    
 }