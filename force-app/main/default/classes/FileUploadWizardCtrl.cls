public class FileUploadWizardCtrl {
    
    public static Boolean isRoundComplete = false;
    
    @AuraEnabled(cacheable = true)
    public static Map<String,String> getOptionsForSelectedPicklistField(){
        try {
            Map<String,String> options = new  Map<String,String>(); 
            Map<String, Schema.SObjectField> mapFields = Schema.getGlobalDescribe().get('Opportunity_File__c').getDescribe().fields.getMap();
            Schema.DescribeFieldResult pickFieldResult = mapFields.get('File_Category__c').getDescribe();   
            List<Schema.PicklistEntry> picklistFields1 = pickFieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListFields2 : picklistFields1)
            {
                options.put(pickListFields2.getLabel(),pickListFields2.getValue());
            }
            system.debug('@@@@ ' + options);
            return options;
        } catch (Exception e) {
            return null;
        }
    }
    
    
    @AuraEnabled()  
    public static string allvalidationchk(Id oppId) {
        String strErr = '';
        Opportunity opp = [SELECT Id, StageName ,First_Shipment_Date__c , CloseDate FROM Opportunity WHERE Id =:oppId];
        if(opp.CloseDate < system.today() && (opp.StageName != 'Closed Lost' || opp.StageName != 'Closed Won')){
            strErr = 'Close date is in the past. Please Update the close date to a future date to proceed.';
        }
        return strErr;
    }
    
    @AuraEnabled()  
    public static void errorResponse(String err) {
        ErrorLogger.writeError('SFDC', 'RFQ File Upload', 'FileUploadWizardCtrl.errorResponse', err, err,err);
    }
    
    @AuraEnabled(cacheable=true)  
    public static filewrapper chkIfOppHasProduct(Id oppId) {
        filewrapper fW = new filewrapper();
        List<Opportunity_Product__c> oppProductlst = [SELECT Id, Name FROM Opportunity_Product__c WHERE OpportunityId__c =:oppId];
        if(oppProductlst.size() > 0) {
            fW.hasProduct = true;
        }else{
            fW.hasProduct = false; 
        }
        system.debug('@@@@ ' + oppProductlst);
        system.debug('@@@@ ' + fW);
        return fW;
    }
    
    @AuraEnabled( cacheable=true )  
    public static Opportunity_File__c getoppfiledetails(Id oppfId) {
        Opportunity_File__c oppfile = [SELECT Id, Name, File_Reference__c, File_link__c FROM Opportunity_File__c WHERE ID =:oppfId];
        return oppfile;         
    }
    
    
     @AuraEnabled( cacheable=true )  
    public static List<quotewrapper> getQuotedetails(Id oppId) {
        system.debug('oppId ' + oppId);
        List<quotewrapper> qwlst = new List<quotewrapper>();
        List<Quotes__c> qfile = [SELECT Id, Opportunity__r.First_Round_Submission_Date__c, Collaboration_Portal_Link__c,Negotiation_Id__c,Negotiation_Link__c,Negotiation_Round__c,Negotiation_Source__c,Opportunity__c,Round_Receipt_Date__c,Status__c,Submission_Date__c 
                                 FROM Quotes__c WHERE Opportunity__c =:oppId ORDER BY Negotiation_Round__c DESC];
        system.debug('qfile ' + qfile.size());
        
        if(qfile.size() > 0) {
            Decimal tempCount = 0;
            if(qfile[0].status__c == 'Negotiation Round Completed'){
                quotewrapper qw1 = new quotewrapper();
                qw1.roundnumber = qfile[0].Negotiation_Round__c +1;
                qwlst.add(qw1);
            }
            for(Quotes__c q : qfile) {
                quotewrapper qw = new quotewrapper();
                qw.roundnumber = q.Negotiation_Round__c;
                qw.quoteid = q.Id;
                //tempCount = q.Negotiation_Round__c;
                qw.receiptdate = q.Round_Receipt_Date__c == null ? system.today() : q.Round_Receipt_Date__c;
                qw.submissiondate = q.Submission_Date__c == null ? q.Opportunity__r.First_Round_Submission_Date__c : q.Submission_Date__c;
                qw.status = q.Status__c;
                qw.disabled = q.Status__c == 'Negotiation Round Completed' ? true : false;
                qwlst.add(qw);
                if(qfile[0].status__c == 'Negotiation Round Completed'){
                   // tempCount = q.Negotiation_Round__c;
                   // quotewrapper qw1 = new quotewrapper();
                    //tempCount = q.Negotiation_Round__c + 1;
                    //qwlst.add(qw1);
                }
            }
            
        }else{
            Opportunity op = [SELECT Id , First_Round_Submission_Date__c FROM Opportunity WHERE Id =: oppId];
            quotewrapper qw = new quotewrapper();
            qw.roundnumber = 1;
            qw.receiptdate = system.today();
            qw.submissiondate = op.First_Round_Submission_Date__c;
            qwlst.add(qw);
        }
        system.debug('@@@@ ' + qwlst);
        return qwlst;         
    }
    
    @AuraEnabled( cacheable=true )  
    public static filewrapper checkifRFQ(Id oppId) {
        List<Quotes__c> quoteRec = [SELECT Id, Name, Status__c  FROM Quotes__c WHERE /*Status__c = 'Negotiation Round Completed' AND*/
                                    Opportunity__c =:oppId ORDER BY Status__c DESC];
        filewrapper fw = new filewrapper();
        if(quoteRec.size() > 0){
            if(quoteRec[0].Status__c  == 'Negotiation in Progress' || quoteRec[0].Status__c  == 'Negotiation Initiated'){
                fw.isRFQinProgress = true; 
                fw.isNominationDisabled = true;
            }
            if(quoteRec[0].Status__c  == 'Negotiation Round Completed'){
                fw.isRFQinProgress = false; 
                fw.isNominationDisabled = false;
            }
        }else if(quoteRec.size() == 0) {
            fw.isNominationDisabled = true;   
        }else{
            //fw.isNominationDisabled = false;
        }
        system.debug('@@@ ' + fw);
        return fw;         
    }

    @AuraEnabled( cacheable=true )  
    public static string getHerokufileapi() {
        JWT_Configuration__mdt fileapi = JWT_Configuration__mdt.getInstance('AzureFileUploadJwt');
        return fileapi.heroku_file_api__c;
    }
    
    @AuraEnabled( cacheable=true )  
    public static jwtwrapper getJwtToken() {
        String token = '';
        JWT_Configuration__mdt  fetchMeta = [ SELECT Id, Heroku_URL__c, MasterLabel, Audience__c, Certificate_Name__c,Client_Id__c,Expiry_Time__c,UserName__c
                                             FROM JWT_Configuration__mdt WHERE Active__c = TRUE];
        system.debug('@@@@ ' + fetchMeta);
        Auth.JWT jwt = new Auth.JWT();
        jwt.setIss(fetchMeta.Client_Id__c);
        jwt.setSub(fetchMeta.UserName__c);
        //jwt.setAdditionalClaims(claims);
        jwt.setAud(fetchMeta.Audience__c);
        jwt.setValidityLength(Integer.valueof(fetchMeta.Expiry_Time__c));
        Auth.JWS jws = new Auth.JWS(jwt, fetchMeta.Certificate_Name__c);
        if(!Test.isRunningTest()){
        	token = jws.getCompactSerialization();    
        }else {
            token = 'testToken'; 
        }
       	jwtwrapper jwterap = new jwtwrapper();
        jwterap.jwttoken = token;
        jwterap.heroku_url = fetchMeta.Heroku_URL__c;
        system.debug('@@@@ ' + token);
        return jwterap;
    } 
    
    @AuraEnabled()  
    public static String deleteOppFiledata(sObject record) {
        string resp = '';
        try{
            delete record;
        }catch(exception e){
            system.debug('@@@ ' + e.getMessage());
            resp =  e.getMessage();
        }
        return resp;
    }
    @AuraEnabled
    public static List<filewrapper> createOppfiles(String oppFileRecord,String quoteFileRecord) {
        system.debug('@@@@ ' + quoteFileRecord);
        List<filewrapper> lstfilewrapper = new List<filewrapper>();
        List<Quotes__c> quoteList = new List<Quotes__c>();
        List<Quotes__c> negotiationRoundList = new List<Quotes__c>();
        List<Opportunity_File__c> oppFileList= (List<Opportunity_File__c>) System.JSON.deserialize(oppFileRecord, List<Opportunity_File__c>.Class);
        List<Quotes__c> quoList= (List<Quotes__c>) System.JSON.deserialize(quoteFileRecord, List<Quotes__c>.Class);
        if(quoList.size()>0 && quoList[0].Opportunity__c!=null){
            quoteList = [SELECT Id,Status__c,Opportunity__c FROM Quotes__c where Opportunity__c =: quoList[0].Opportunity__c
                         ORDER BY LastModifiedDate DESC LIMIT 1];    
        } 
        Boolean isRFQPresent = false;
        String quoteId = '';
        String neGotiationquoteId = '';
        String status = '';
        
        for(Quotes__c q: quoteList){
            if(q.Status__c != 'Negotiation Round Completed'){
                quoteId = q.Id;
            }
        }
        try{
            system.debug('@@@@ ' + oppFileList);
            for(Opportunity_File__c oppFiles : oppFileList){
                if(oppFiles.File_Category__c == 'RFQ' /*|| oppFiles.File_Category__c == 'Nomination'|| oppFiles.File_Category__c == 'Freetime'*/){
                    isRFQPresent = true;    
                }
            }
            
            if(oppFileList!=null){
                try{
                    insert oppFileList;   
                }catch(exception e){
                    system.debug('@@@@ ' + e.getMessage());  
                }
            }
            List<Opportunity_File__c> lstOppRef = [SELECT Id, Name, File_Category__c, File_Reference__c, Opportunity__r.Opportunity_Ref__c FROM Opportunity_File__c WHERE Id IN:oppFileList];
            if(lstOppRef.size() > 0 && !lstOppRef.isEmpty()) {
                for(Opportunity_File__c f: lstOppRef) {
                    filewrapper wrap = new filewrapper();
                    wrap.fileref = f.File_Reference__c +'-'+ f.Name;
                    wrap.fileName = f.Opportunity__r.Opportunity_Ref__c;
                    wrap.oppfileId = f.Id;
                    wrap.isRFQPresent = isRFQPresent;
                    wrap.oppsId = f.Opportunity__c;
                    wrap.filecategory = f.File_Category__c;
                    system.debug('@@@@ ' + wrap.fileref);
                    lstfilewrapper.add(wrap);
                }
            }
            status = 'success';
        } catch(Exception ex) {
            system.debug('payload ' + ex); 
            status = 'errorinsert';
        }
        
        return lstfilewrapper;
    }   
    
    @AuraEnabled
    public static String createQuote(String oppFileRecordId, String quoteFileRecord, String oppId, Boolean senttoAzure, String filecategory) {
        system.debug('@@@@ ' + oppId);
        system.debug('@@@@ ' + oppFileRecordId);
        system.debug('@@@@ ' + quoteFileRecord);
        String quoteId = '';
        String status = '';
        String neGotiationquoteId = '';
        
        List<Quotes__c> quoteList = new List<Quotes__c>();
        List<Quotes__c> quoList = new List<Quotes__c>();
        List<Quotes__c> negotiationRoundList = new List<Quotes__c>();  
        if(quoteFileRecord != '""' && !String.isBlank(quoteFileRecord)){     
            system.debug('@@@@ ' + quoteFileRecord);
            quoList = (List<Quotes__c>) System.JSON.deserialize(quoteFileRecord, List<Quotes__c>.Class);
        }
        negotiationRoundList = [SELECT Id,Status__c,Opportunity__c,Negotiation_Round__c FROM Quotes__c where Opportunity__c =: oppId order by Negotiation_Round__c Desc limit 1];
        if(quoteFileRecord !='""' && !String.isBlank(quoteFileRecord)) {
            system.debug('@@@@ ' + Limits.getQueries());
            quoteList = [SELECT Id,Status__c,Opportunity__c FROM Quotes__c where Status__c IN ('Negotiation In Progress','Negotiation Initiated') AND Opportunity__c =: oppId 
                         ORDER BY LastModifiedDate DESC LIMIT 1];
        }else{
            system.debug('@@@@ ' + Limits.getQueries());
            quoteList = [SELECT Id,Status__c,Opportunity__c FROM Quotes__c where Status__c = 'Negotiation Round Completed' AND Opportunity__c =: oppId 
                         ORDER BY LastModifiedDate DESC LIMIT 1];  
        }
        system.debug('@@@@ ' + quoteList);
        for(Quotes__c q: quoteList){
            if(q.Status__c != 'Negotiation Round Completed'){
                quoteId = q.Id;
            }
            if(q.Status__c == 'Negotiation Round Completed'){
                neGotiationquoteId = q.Id;
            }
        }
        system.debug('@@@@ ' + neGotiationquoteId);
        for(Quotes__c q:quoList){
            if(negotiationRoundList.size()>0 && negotiationRoundList[0].Negotiation_Round__c>0 && quoteList.size() > 0){
                q.Negotiation_Source__c = 'CRM'; 
                if(negotiationRoundList[0].Status__c == 'Negotiation Round Completed'){
                    q.Negotiation_Round__c = negotiationRoundList[0].Negotiation_Round__c+1; 
                    isRoundComplete = false;
                }else{
                    q.Negotiation_Round__c = negotiationRoundList[0].Negotiation_Round__c;
                }    
            }else if(quoteList.isEmpty() && !negotiationRoundList.isEmpty()){
                q.Negotiation_Round__c = negotiationRoundList[0].Negotiation_Round__c+1;
            }
        }
        
        system.debug('@@@@ ' + isRoundComplete);
        system.debug('@@@@ ' + quoteId);
        if( quoteFileRecord != '""' && !String.isBlank(quoteFileRecord)){
            
            try{
                
                if(String.isBlank(quoteId)){
                    try{
                        insert quoList;    
                    }catch(exception e){
                        system.debug('@@@@ ' + e);
                    }
                }
                system.debug('@@@@ quoList ' + quoList);
                if(!String.isBlank(quoteId) && quoteList[0].Status__c != 'Negotiation Round Completed'){
                    try{
                        quoList[0].Id = quoteId;
                        update quoList;  
                    }catch(exception e){
                        system.debug('@@@@ ' + e.getMessage());
                    }    
                }
                Opportunity_File__c oppFile = new Opportunity_File__c();
                oppFile.Id = oppFileRecordId;
                oppFile.Send_to_azure__c = senttoAzure;
                oppFile.Quote__c = quoList[0].id != null ? quoList[0].id : quoteId;   
                update oppFile;
            }catch(exception e){
                system.debug('@@@@@ ' + e.getMessage());
            }  
            quoteId = quoList[0].id;   
        }else{
            Opportunity_File__c oppFilewithoutQuote = new Opportunity_File__c();
            oppFilewithoutQuote.Id = oppFileRecordId;
            oppFilewithoutQuote.Send_to_azure__c = senttoAzure; 
            oppFilewithoutQuote.Quote__c = filecategory == 'Freetime' ? null : neGotiationquoteId;
            system.debug('@@@@ ' + oppFilewithoutQuote);
            try{
                update oppFilewithoutQuote;  
            }catch(exception e){
                system.debug('@@@ ' + e.getMessage());
            }
            
        }
        return quoteId;
    }    
    @AuraEnabled
    public static List<Opportunity_File__c>  editOppfiles(String oppFileRecordId) {
        List<Opportunity_File__c>oppFileList = new List<Opportunity_File__c>();
        oppFileList = [Select id,name,File_Category__c,File_link__c,Opportunity__c from Opportunity_File__c where id=:oppFileRecordId];
        system.debug('==oppFileList=='+oppFileList);
        return oppFileList;
    }    
    
    public class filewrapper {
        @AuraEnabled
        public string fileref {get;set;}
        @AuraEnabled
        public string filename {get;set;}
        @AuraEnabled
        public string oppfileId {get;set;}
        @AuraEnabled
        public string oppsId {get;set;}
        @AuraEnabled
        public boolean isRFQPresent {get;set;}
        @AuraEnabled
        public boolean hasProduct {get;set;}
        @AuraEnabled
        public string filecategory {get;set;}
        @AuraEnabled
        public boolean isRFQinProgress{get;set;}
        @AuraEnabled
        public boolean isNominationDisabled{get;set;}
        @AuraEnabled
        public boolean isp2qFileupload{get;set;}
        public filewrapper(){
            /*hasProduct = false;
            isRFQinProgress = false;
            isNominationDisabled = false;*/
        }
    }
    
    public class quotewrapper {
        @AuraEnabled public decimal roundnumber{get;set;}
        @AuraEnabled public date receiptdate{get;set;}
        @AuraEnabled public date submissiondate{get;set;}
        @AuraEnabled public string status{get;set;}
        @AuraEnabled public string quoteid{get;set;}
        @AuraEnabled public Boolean disabled{get;set;}
        public quotewrapper() {
            receiptdate = system.today();
           //ubmissiondate = system.today() + 1;
            roundnumber = 1;
        }
    }
    
    public class jwtwrapper {
        @AuraEnabled public string jwttoken{get;set;}
        @AuraEnabled public string heroku_url{get;set;}
    }
    
    @AuraEnabled(cacheable=true)  
    public static filewrapper chkIfOppIsP2Q(Id oppId) {
        filewrapper fW = new filewrapper();
        System.debug('opptyId!!=='+oppId);
        Opportunity opp = [SELECT Id, Customer_Journey__c FROM Opportunity WHERE Id =:oppId];
        if(opp.Customer_Journey__c == Label.Instant_Quote){
            fw.isp2qFileupload = true;
        }else{
            fw.isp2qFileupload = false;
        } 
        return fW;
    }
    
    @AuraEnabled(cacheable=true)  
    public static Boolean chkRFQFileUploadedP2Q(Id oppId){
            List<Opportunity_File__c> opptyFiles = [SELECT Id, File_Category__c FROM Opportunity_File__c WHERE Opportunity__c = :oppId AND File_Category__c = 'RFQ' AND Opportunity__r.Customer_Journey__c = 'Instant Quote (Non Negotiable)' LIMIT 1];
            if(!opptyFiles.isEmpty()){
                return true;
            }else{
                return false;
            }
     }
        
}