/*  
* Version	Date			Owner					Description
* --------	-----------		-------------------		-----------
* 1.0		21-Dec-2022		Vazid@UST				Apex class for Loopio custom solution
*/

public class LoopioProjectCtrl {
    public static List<OpportunityTeamMember> lstOppTeamMember;
    
    @AuraEnabled(cacheable = true)
    public static List<loopioWrapper> getOppDetails(Id oppId) {
        
        List<loopioWrapper> lstlpw = new List<loopioWrapper>();
        
        Loopio_Environment_Detail__mdt loopioConnection = Loopio_Environment_Detail__mdt.getInstance(StaticFactory.getEnvironment());
        
        //Get the user list from Loopio
        List<LoopioUtility.loopioUserWrapper> lstUserRecords = LoopioUtility.getUsers();
        
		//SFSE-10935 : check user has Opportunity record edit access
        boolean hasAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess 
                            WHERE UserId =:UserInfo.getUserId() AND RecordId =: oppId].HasEditAccess;
        //To get the existing templates from Loopio : Commented below line for feature reference
       List<LoopioUtility.projectWrapper> projectTemplateRecords = LoopioUtility.getProjectTemplates();
        
        for(Opportunity opp: [SELECT Id, Name, Owner.Name,AccountId,Opportunity_Ref__c,stageName, Request_Type__c, Account.Name FROM Opportunity WHERE Id =:oppId]) {
            loopioWrapper lpw = new loopioWrapper();
            String requestType = opp.Request_Type__c !=null ? opp.Request_Type__c : 'RFI';
            lpw.projectName = opp.Name +'_'+requestType+'_'+opp.Opportunity_Ref__c;
            lpw.clientName = opp.Account.Name;
            lpw.ownerName = 'RFIP';
			lpw.isOppClosed = opp.stageName.containsIgnoreCase('close') ? true : false;//SFSE-10935
            lpw.accessRestricted = !hasAccess; //SFSE-10935 
            lpw.clientId = opp.AccountId;
            lpw.oppRef = opp.Opportunity_Ref__c;
            lpw.requestType = requestType;
            lpw.oppName = opp.Name;
            lpw.requestPicklstValues = new Set<String>(Lightning_Utilities.GetFieldPikclistValues('Loopio__Loopio_Project__c','Request_Type__c',null));
            lpw.userList = lstUserRecords;
       
            lpw.loopioOwnerId = loopioConnection.Owner_Id__c;
          //  To get the existing templates from Loopio : Commented below line feature reference
            lpw.projectTemplateList = projectTemplateRecords;
            lstlpw.add(lpw);
        }
        return lstlpw;
    }
    
    @AuraEnabled
    public static returnWrapper updateOppWithRequestType(Id oppId, String requestType, Loopio__Loopio_Project__c lp, productWrapper prodWrapper, string projectTemplateId) {
        system.debug('requestType'+requestType);
        system.debug('@@@@ '+ lp);
        system.debug('prodWrapper@@@@'+prodWrapper);
        system.debug('projectTemplateId@@@@'+projectTemplateId);
        
        Loopio_Environment_Detail__mdt loopioConnection = Loopio_Environment_Detail__mdt.getInstance(StaticFactory.getEnvironment());

        String status = '';
        List<OpportunityTeamMember> lstOppTeamMember = [SELECT Name, TeamMemberRole, User.Email FROM OpportunityTeamMember where OpportunityId =: oppId];
        set<string> lstOfoptyMemEmails = new set<string>();
        for(OpportunityTeamMember optyMemberRec: lstOppTeamMember){
            lstOfoptyMemEmails.add(optyMemberRec.User.Email);
        }
        
        LoopioUtility.projectResponseWrapper resWrap= LoopioUtility.createLoopioProject(oppId,prodWrapper,lstOfoptyMemEmails,projectTemplateId);
        Integer ProjectId  = resWrap.projectId;
        
        
        if(lp !=null && ProjectId != null){
            Loopio__Loopio_Project__c lpStandardRec = [Select Id, Name, CreatedBy.Name, Request_Type__c from Loopio__Loopio_Project__c where Loopio__Opportunity__c =:oppId and Request_Type__c  = null Order by CreatedDate desc limit 1];
        	
            try{
                lpStandardRec.Source_Document__c = lp.Source_Document__c+ '_'+ProjectId;
                lpStandardRec.Request_Type__c = lp.Request_Type__c;
                lpStandardRec.Created_By__c = UserInfo.getUserId();
                update lpStandardRec;
                status='success';
                
            } catch(Exception e){
                status = e.getMessage();
            }  
        }
                
        if(status == 'success'){
            Opportunity oppty = [SELECT Id, Request_Type__c FROM Opportunity WHERE Id =:oppId];
            List<Opportunity> lstOppToUpdate = new List<Opportunity>();
            if(requestType !=null && oppty.Request_Type__c == null) {
                Opportunity opp = new Opportunity(Id=oppId, Request_Type__c =requestType);
                lstOppToUpdate.add(opp);
            }else{
                if(requestType !=null && oppty.Request_Type__c != null && !oppty.Request_Type__c.contains(requestType)){
                    Opportunity opp = new Opportunity(Id=oppId, Request_Type__c = oppty.Request_Type__c+':'+requestType);
                    lstOppToUpdate.add(opp);
                }
            }
            
            try{
                if(lstOppToUpdate.size() > 0 && lstOppToUpdate !=null) {
                    update lstOppToUpdate;
                    status = 'success';
                }
            } catch(Exception e){
                status = e.getMessage();
            }
        }
        return new returnWrapper(status, string.valueof(ProjectId),loopioConnection.URL__c,resWrap.loopioaccToken,resWrap.attachSourceDocAPI);    
    }
    
    @AuraEnabled
    public static List<contentDocWrapper> getContentDocs(Id arecordId)
    {   
        system.debug('@@@@@ '+ arecordId);
        List<contentDocWrapper> returnWrapperList= new List<contentDocWrapper>();
        List<ContentDocumentLink> CDLs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :arecordId];
        if (CDLs.size() < 1) return new List<contentDocWrapper>(); 

        // Make a List of ContentDocument IDs
        List <Id> CDIdList = new List <Id> ();
        for (ContentDocumentLink nextCDL : CDLs) {
            CDIdList.add(nextCDL.ContentDocumentId); 
        }       
        system.debug('CDIdList'+CDIdList);
        /*Below snippet is used to get the list of files with versionBody which are less than 5 MB*/
        List<ContentVersion> contentversionslst     =	[SELECT Checksum,ContentSize,ContentBodyId,ContentDocument.FileType,
                                                         ContentDocumentId,ContentLocation,ContentDocument.Title,
                                                         Title,VersionData,VersionNumber
                                                         FROM ContentVersion WHERE ContentDocumentId IN :CDIdList AND ContentSize < 5000000];
        
        for(ContentVersion conVer : contentversionslst){
            contentDocWrapper wrapper = new contentDocWrapper();
            wrapper.fileName  =  conVer.ContentDocument.Title;
            
            
            // To get files less than 5 MB :					   
            if(conVer.ContentSize < 5000000) {
                blob b = conVer.VersionData;
            	String body = EncodingUtil.base64Encode(b);
                wrapper.fileBody  =  body;
                wrapper.fileType  =  ContentType(conVer.ContentDocument.FileType);
                wrapper.fileContentId  =  conVer.Id;
                wrapper.fileSize = setControllerValue(string.valueof(conVer.ContentSize));
                returnWrapperList.add(wrapper);
            }
        }
       
        /*SFSE-12021 : Below snippet is used to get the list of files without versionBody which are larger than 5 MB
			to eliminate the error: Query of LOB fields caused heap usage to exceed limit.
			versionBody is fetched in LWC JS*/
        List<ContentVersion> contentversionslstMoreSize     =	[SELECT Checksum,ContentSize,ContentBodyId,ContentDocument.FileType,
                                                         ContentDocumentId,ContentLocation,ContentDocument.Title,
                                                         Title,VersionNumber
                                                         FROM ContentVersion WHERE ContentDocumentId IN :CDIdList AND ContentSize > 5000000];
        //VersionData
        for(ContentVersion conVerRec : contentversionslstMoreSize){
            contentDocWrapper wrapperRec = new contentDocWrapper();
            wrapperRec.fileName  =  conVerRec.ContentDocument.Title;
            wrapperRec.fileType  =  ContentType(conVerRec.ContentDocument.FileType);
            wrapperRec.fileContentId  =  conVerRec.Id;
            wrapperRec.fileSize = setControllerValue(string.valueof(conVerRec.ContentSize));
            returnWrapperList.add(wrapperRec);
        }
        
        return returnWrapperList;
    }
    
    public static string ContentType(String fileType) {

        switch on fileType.toLowerCase(){
            when 'pdf' {
                return 'pdf';
            }
            when 'csv' {
                return 'csv';
            }
            when 'excel_x' {
                return 'xlsx';
            }
            when 'word_x' {
                return 'docx';
            }
            
            when 'png' {
                return 'png';
                
            }
            when else {
                return fileType.toLowerCase();
            }
        }

    }

    //Convert content document size to KB MB GB
    public static string setControllerValue (String s) {
        string controllerValue;
        controllerValue = s.toUpperCase();
        Long longValue = Long.valueOf(s);
       
        if (longValue < 1024)
            controllerValue =  string.valueOf(longValue) + ' Bytes';
        else
            if (longValue >= 1024 && longValue < (1024*1024))
        {
            //KB
            Decimal kb = Decimal.valueOf(longValue);
            kb = Math.round(kb.divide(1024,2));
            controllerValue = string.valueOf(kb) + ' KB';
        }
        else
            if (longValue >= (1024*1024) && longValue < (1024*1024*1024))
        {
            //MB
            Decimal mb = Decimal.valueOf(longValue);
            mb = mb.divide((1024*1024),2).setScale(1);
            controllerValue = string.valueOf(mb) + ' MB';
        }
        else
        {
            //GB
            Decimal gb = Decimal.valueOf(longValue);
            gb = gb.divide((1024*1024*1024),2).setScale(1);
           
            controllerValue = string.valueOf(gb) + ' GB';
        }   
       return controllerValue;
    }
    
    public class loopioWrapper {     
        @AuraEnabled
        public string projectName {get;set;}
        @AuraEnabled
        public string clientName {get;set;}
        @AuraEnabled
        public string clientId {get;set;}
        @AuraEnabled
        public string ownerName {get;set;}
        @AuraEnabled
        public string ownerEmail {get;set;}
        @AuraEnabled
        public string ownId {get;set;}
        @AuraEnabled
        public string oppRef {get;set;}
        @AuraEnabled
        public string requestType {get;set;}
        @AuraEnabled
        public string oppName {get;set;}
        @AuraEnabled
		public boolean isOppClosed {get;set;}
        @AuraEnabled
        public boolean accessRestricted {get;set;}
        @AuraEnabled
        public set<string> requestPicklstValues {get;set;}
        @AuraEnabled
        public List<LoopioUtility.loopioUserWrapper> userList {get;set;}
        @AuraEnabled
        public string loopioOwnerId {get;set;}
        //To get the store existing templates from Loopio : Commented below line for feature reference
        @AuraEnabled
       public List<LoopioUtility.projectWrapper> projectTemplateList {get;set;}
        
        public loopioWrapper() {
            projectName = '';
            clientName = '';
            ownerName = '';
            ownerEmail = '';
            clientId = '';
            ownId = '';
            oppRef = '';
            requestType = '';
            oppName = '';
			isOppClosed = false;
			accessRestricted = false;
            requestPicklstValues = new set<string>();
            userList = new List<LoopioUtility.loopioUserWrapper>();
            loopioOwnerId = '';
            projectTemplateList = new List<LoopioUtility.projectWrapper>();
        }
    }
    
    public class contentDocWrapper{
        @AuraEnabled public  string fileName  		{get;set;}		
        @AuraEnabled public  string fileBody		{get;set;}	
        @AuraEnabled public  string fileType 		{get;set;}	
        @AuraEnabled public  string fileContentId 	{get;set;}
        @AuraEnabled public  string fileSize	 	{get;set;}
    }
    
    public class productWrapper{
        @AuraEnabled public  string name  			{get;set;}		
        @AuraEnabled public  string projectType		{get;set;}	
        @AuraEnabled public  string description 	{get;set;}	
        @AuraEnabled public  string companyName 	{get;set;}
        @AuraEnabled public  string dueDate  		{get;set;}		
        @AuraEnabled public  ownerId	owner		{get;set;}
        @AuraEnabled public  string opportunityReference {get;set;}	
        
    }
    public class ownerId{
        @AuraEnabled public  string id  			{get;set;}
    }
    
    public class returnWrapper{
        
        @AuraEnabled public  string successMessage  		{get;set;}		
        @AuraEnabled public  string projectId				{get;set;}
        @AuraEnabled public  string strEnvironment			{get;set;}
        @AuraEnabled public  string loopioaccToken			{get;set;}
        @AuraEnabled public  string attachSourceDocAPI		{get;set;}
        
        public returnWrapper(string successMessage, string projectId, string strEnvironment, string loopioaccToken, string attachSourceDocAPI){
            this.successMessage = successMessage;
            this.projectId = projectId;
            this.strEnvironment = strEnvironment;
 			this.loopioaccToken = loopioaccToken;
            this.attachSourceDocAPI = attachSourceDocAPI;
        }
    }
    
}