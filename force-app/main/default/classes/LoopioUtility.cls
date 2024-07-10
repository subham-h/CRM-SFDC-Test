/*  
* Version	Date			Owner					Description
* --------	-----------		-------------------		-----------
* 1.0		21-Dec-2022		Sowmya					Utility class for Loopio
*/

public class LoopioUtility {
    
    public static String getLoginIdToken() {
        string hostName = StaticFactory.getEnvironment() == 'Sandbox' ? 'Loopio_Sandbox_AuthDetails' : 'Loopio_Production_AuthDetails';

        Loopio_Connection_Details__mdt metaRec = Loopio_Connection_Details__mdt.getInstance(hostName); 
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint( metaRec.Auth_Url__c );
        req.setMethod('POST');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setHeader('scope',metaRec.Scope__c);
       
        String clientId = metaRec.Client_ID__c; //---Mention the Consumer Key here of the Connected App record created in the destination SFDC Instance
        String clientSecret = metaRec.Client_Secret__c; //---Mention the Client Secret from the Connected App
        
    	String payload = 'client_id='+EncodingUtil.urlEncode(clientId,'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(clientSecret,'UTF-8')+'&grant_type='+metaRec.Grant_Type__c+'&scope='+metaRec.Scope__c;
    	System.debug(payload);
        req.setBody(payload);
        Http http = new Http();
        HttpResponse response = http.send(req);
        System.debug('REST response is :: '+response.getBody());
        Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
        String accessToken = (String)mapResponse.get('access_token');
        System.debug('############ '+ accessToken);
        return accessToken;
    }
    
    public static projectResponseWrapper createLoopioProject(String oppId,LoopioProjectCtrl.productWrapper prodWrapper,Set<string> OppTeamEmail, string projectTemplateId) {
        string hostName = StaticFactory.getEnvironment() == 'Sandbox' ? 'Loopio_Sandbox_AuthDetails' : 'Loopio_Production_AuthDetails';

        Loopio_Connection_Details__mdt projectDet = Loopio_Connection_Details__mdt.getInstance(hostName);
        String accessToken = getLoginIdToken();
        system.debug('accessToken'+accessToken);
            
        Http http = new Http();
        
      	Integer projectId;
        if(!string.isBlank(projectTemplateId) && projectTemplateId != null){
            //Create Project with template in Loopio : Commented below line feature reference
            projectId = createProjectwithTemplate(accessToken,prodWrapper,projectTemplateId);
        }else{
            
            projectId = createProjectwithOutTemplate(accessToken,prodWrapper,projectDet.Create_Project_EndPoint__c);
        }
        system.debug('####projectId'+projectId);
        
        /* Attach source document to project API call moved to LWC JS : Removed code from apex class */
		// Link Opportunity to Project
        HttpRequest projOpp = new HttpRequest();
        String epUrl = projectDet.Create_Project_EndPoint__c+'/'+projectId+'/opportunityLink';
        projOpp.setEndpoint(epUrl);
        string strBody = '{"type": "SALESFORCE", "opportunityId": "'+oppId+'"}';
        projOpp.setBody( strBody);
        projOpp.setHeader('Content-length',string.valueOf(strBody.length()));
		projOpp.setMethod('POST');        
        projOpp.setHeader('Authorization','Bearer '+accessToken);
        projOpp.setHeader('Content-Type','application/json');
        Http linkProj = new Http();
        HttpResponse linkRes = linkProj.send(projOpp);
        
        System.debug('## Project link status '+ linkRes);
        
		return new projectResponseWrapper(projectId,accessToken,projectDet.Attach_File_EndPoint__c);
    }
        
    public static Integer createProjectwithOutTemplate(string accessToken, LoopioProjectCtrl.productWrapper prodWrapper, string endPointURL){
        Http http = new Http();
        
        HttpRequest createProjectReq = new HttpRequest();
        LoopioProjectCtrl.productWrapper jsonObj = new LoopioProjectCtrl.productWrapper ();
        jsonObj = prodWrapper;  
        // follow for other vaiables as well.
        String jsonBody = json.serialize(jsonObj); 
        system.debug('jsonBodyBefore'+jsonBody);
        jsonBody = jsonBody.replace('opportunityReference','Opportunity_Ref__c');
        system.debug('jsonBodyAfter'+jsonBody);
       
        createProjectReq.setEndpoint( endPointURL );
        if (jsonBody != null){
            createProjectReq.setBody(jsonBody);
            createProjectReq.setHeader('Content-length',string.valueOf(jsonBody.length()));
		}
        
        createProjectReq.setMethod('POST');        
        createProjectReq.setHeader('Authorization','Bearer '+accessToken);
        createProjectReq.setHeader('Content-Type','application/json');
        Http httpCreateProject = new Http();
        HttpResponse createProjectResp = httpCreateProject.send(createProjectReq);
        system.debug('CREATE PROJECT DEBUG'+createProjectResp.getBody());
        Map<String,Object> mapcreateProjectResp = (Map<String,Object>)JSON.deserializeUntyped(createProjectResp.getBody());
        
      	Integer projectId = (Integer)mapcreateProjectResp.get('id');
        return projectId;
    }
   
    //Create loopio project with Template : Commented below method for feature reference
    
    public static Integer createProjectwithTemplate(string accessToken, LoopioProjectCtrl.productWrapper prodWrapper, string templatedId){
        
        string hostName = StaticFactory.getEnvironment() == 'Sandbox' ? 'Loopio_Sandbox_AuthDetails' : 'Loopio_Production_AuthDetails';
        Loopio_Connection_Details__mdt projectWtemplateAPI = Loopio_Connection_Details__mdt.getInstance(hostName);
        
        Http http = new Http();
        system.debug('prodWrapper'+prodWrapper);
        HttpRequest createProjectReq = new HttpRequest();
        LoopioProjectCtrl.productWrapper jsonObj = new LoopioProjectCtrl.productWrapper ();
        jsonObj = prodWrapper;  
        // follow for other vaiables as well.
        String jsonBody = json.serialize(jsonObj); 
        system.debug('jsonBodyBefore'+jsonBody);
        jsonBody = jsonBody.replace('opportunityReference','Opportunity_Ref__c');
        system.debug('jsonBodyAfter'+jsonBody);
        //create project with template 
        string endPointURL = projectWtemplateAPI.Create_Project_w_Template_API__c+templatedId+'/projects';
         createProjectReq.setEndpoint( endPointURL );
        if (jsonBody != null){
            createProjectReq.setBody(jsonBody);
            createProjectReq.setHeader('Content-length',string.valueOf(jsonBody.length()));
		}
        
        createProjectReq.setMethod('POST');        
        createProjectReq.setHeader('Authorization','Bearer '+accessToken);
        createProjectReq.setHeader('Content-Type','application/json');
        Http httpCreateProject = new Http();
        HttpResponse createProjectResp = httpCreateProject.send(createProjectReq);
        system.debug('CREATE PROJECT DEBUG'+createProjectResp.getBody());
        Map<String,Object> mapcreatetaskResp = (Map<String,Object>)JSON.deserializeUntyped(createProjectResp.getBody());
        system.debug('mapcreatetaskResp'+mapcreatetaskResp);
		Integer taskId = (Integer)mapcreatetaskResp.get('taskId');
        system.debug('taskId'+taskId);
        Integer projectId = (Integer)mapcreatetaskResp.get('projectId');
       /* HttpRequest projOpp = new HttpRequest();
        String epUrl = 'https://api.int01.loopio.com/data/v2/asyncTasks/'+taskId+'/projectTemplateCopy';
        projOpp.setEndpoint(epUrl);
        projOpp.setMethod('GET');        
        projOpp.setHeader('Authorization','Bearer '+accessToken);
        projOpp.setHeader('Content-Type','application/json');
        //projOpp.setTimeout(120000);
        Http linkProj = new Http();
         HttpResponse linkRes = new  HttpResponse();
       
             linkRes = linkProj.send(projOpp);
      
        
        Map<String,Object> mapcreateProjectResp = (Map<String,Object>)JSON.deserializeUntyped(linkRes.getBody());
        System.debug('## Project status '+ linkRes.getBody());
        Map<String,Object> mapObject = (Map<String,Object>)mapcreateProjectResp.get('result');
        system.debug('mapObject'+mapObject);
        system.debug('Id'+String.valueOf((Integer)mapObject.get('id')));
        Integer projectId = (Integer)mapObject.get('id');
        system.debug('projectId'+projectId);*/
        return projectId;
    }
    
    public static List<loopioUserWrapper> getUsers(){
        string hostName = StaticFactory.getEnvironment() == 'Sandbox' ? 'Loopio_Sandbox_AuthDetails' : 'Loopio_Production_AuthDetails';

        Loopio_Connection_Details__mdt userEndPoint = Loopio_Connection_Details__mdt.getInstance(hostName);
        String accessToken = getLoginIdToken();
        HttpRequest getUserReq = new HttpRequest();
        getUserReq.setEndpoint( userEndPoint.Get_Users_EndPoint__c );
        getUserReq.setMethod('GET');        
        getUserReq.setHeader('Authorization','Bearer '+accessToken);
        getUserReq.setHeader('Content-Type','application/json');
       
        Http http = new Http();
        HttpResponse getUserResp = http.send(getUserReq);
        
        Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(getUserResp.getBody());
        system.debug('User Response'+mapResponse);
        List<Object> lstItems = (List<Object>)mapResponse.get('items');
        Map<String,loopioUserWrapper> mapEmailUser = new Map<String,loopioUserWrapper>();
        
        for(Object obj : lstItems){
            Map<String,Object> mapObject = (Map<String,Object>)obj;
            loopioUserWrapper luw = new loopioUserWrapper();
            
            luw.email = (String)mapObject.get('email');
            luw.firstName = (String)mapObject.get('firstName');
            luw.guid = (String)mapObject.get('guid');
            luw.id = string.valueOf((Integer) mapObject.get('id'));
            luw.lastName = (String)mapObject.get('lastName');
            luw.status = (String)mapObject.get('status');
            mapEmailUser.put(luw.email,luw);
        }
        return mapEmailUser.values();
    }
    
    //To get the existing project templates : Commented below method for feature reference
    public static List<projectWrapper> getProjectTemplates(){
        string hostName = StaticFactory.getEnvironment() == 'Sandbox' ? 'Loopio_Sandbox_AuthDetails' : 'Loopio_Production_AuthDetails';

        Loopio_Connection_Details__mdt templateEndPoint = Loopio_Connection_Details__mdt.getInstance(hostName);
        
       HttpRequest projTemplateRequest = new HttpRequest();
        string accessToken = LoopioUtility.getLoginIdToken();
        String epUrl = templateEndPoint.Get_Templates_EndPoint__c;	
        projTemplateRequest.setEndpoint(epUrl);
        projTemplateRequest.setMethod('GET');        
        projTemplateRequest.setHeader('Authorization','Bearer '+accessToken);
        projTemplateRequest.setHeader('Content-Type','application/json');
        Http httpProj = new Http();
        HttpResponse httpResponse = httpProj.send(projTemplateRequest);
        
        System.debug('## Project Template status '+ httpResponse);
        System.debug('## Project Template status '+ httpResponse.getBody());
        
        Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(httpResponse.getBody());
        system.debug('Template Response'+mapResponse);
        List<Object> lstItems = (List<Object>)mapResponse.get('items');
        system.debug('Items'+lstItems);
        
        List<projectWrapper> projectWrap = new List<projectWrapper>();
        for(Object obj : lstItems){
            Map<String,Object> mapObject = (Map<String,Object>)obj;
            projectWrapper PrjWrap = new projectWrapper();
            
            PrjWrap.id = String.valueOf((Integer)mapObject.get('id'));
            PrjWrap.name = (String)mapObject.get('name');
            PrjWrap.description = (String)mapObject.get('description');
            
            projectWrap.add(PrjWrap);
        }
        system.debug('projectWrap'+projectWrap);
        return projectWrap;
    }
    
    public class loopioUserWrapper{
        @AuraEnabled
         public string email {get;set;}
        @AuraEnabled
         public string firstName {get;set;}
        @AuraEnabled
         public string guid {get;set;}
        @AuraEnabled
         public string id {get;set;}
        @AuraEnabled
         public string lastName {get;set;}
        @AuraEnabled
         public string status {get;set;}
       		public loopioUserWrapper() {
            email = this.email;
            firstName = this.firstName;
            guid = this.guid;
            id = this.id;
            lastName = this.lastName;
            status = this.status;
        }
        
    }
    //To store existing project templates in wrapper : Commented below wrapper class for feature reference
    public class projectWrapper{
        @AuraEnabled
        public string id 			{get;set;}
        @AuraEnabled
        public string name 			{get;set;}
        @AuraEnabled
        public string description 	{get;set;}
        public projectWrapper() {
            id = this.id;
            name = this.name;
            description = this.description;
        }
    }		
	
      public class projectResponseWrapper{
          
        @AuraEnabled public  Integer projectId				{get;set;}
        @AuraEnabled public  string loopioaccToken			{get;set;}
        @AuraEnabled public  string attachSourceDocAPI		{get;set;}
          
        public projectResponseWrapper(Integer projectId, string loopioaccToken, string attachSourceDocAPI){
            this.projectId = projectId;
            this.loopioaccToken = loopioaccToken;
            this.attachSourceDocAPI = attachSourceDocAPI;
        }
          
    }

}