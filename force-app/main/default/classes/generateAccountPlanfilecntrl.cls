/********************************************************************************************
* Sno		Version		Story		  Author		      Date			  Descrition
* 1.		1.0		    SFSE-9838	  Sidhartha@Maersk	  12/11/2022	  Loki Document Generation.
* 2.        2.0         SFSE-13430    Anjali@Maersk       09/02/2024      Removed references of Maersk_Addressable_Spend__c field of Customer Metric Object
* 3.        3.0         SFSE-12520    Avinash@Maersk      16/02/2024      Added generatePPT method
* 4.        3.0         SFSE-12520    Seba@Maersk         19/03/2024      Modified code to handle incoming PPT sections and to send Goals and Actions  
* 5.		4.0			SFSE-13853	  Avinash@Maersk	  25/03/2024	  Track usage of executive summary generation
* 6.		4.0			SFSE-13853	  Seba@Maersk	      04/04/2024	  Modified code to improve the behaviour of status component
********************************************************************************************/
public with sharing class generateAccountPlanfilecntrl {
    public static Map<Id,List<Triple_Fit_Canvas__c>> mapofAccountPlanToTripleCanvas;
    public static Map<Id,List<Stakeholder__c>> mapofAccountPlanToStakeholders;
    public static Map<Id,List<Customer_Metrics__c>> mapofAccountPlanToCustomerMetrics;
    public static Map<Id,List<Customer_Coverage__c>> mapofAccountPlanToCustomerCoverage;
    public static Map<Id,List<Operational_Development__c>> mapofAccountPlanToOperationDevelops;
    public static Map<Id,List<Action__c>> mapofAccountPlanToActions;
    public static Map<Id,List<goalAndActions>> mapofAccountPlanToGoalAndActions;//SFSE-12520
    public generateAccountPlanfilecntrl() {
        mapofAccountPlanToTripleCanvas = new Map<Id,List<Triple_Fit_Canvas__c>>();
        mapofAccountPlanToStakeholders = new  Map<Id,List<Stakeholder__c>>();
        mapofAccountPlanToCustomerMetrics = new  Map<Id,List<Customer_Metrics__c>>();
        mapofAccountPlanToCustomerCoverage = new Map<Id,List<Customer_Coverage__c>>();
        mapofAccountPlanToOperationDevelops = new Map<Id,List<Operational_Development__c>>();
        mapofAccountPlanToActions = new  Map<Id,List<Action__c>>();
        mapofAccountPlanToGoalAndActions = new  Map<Id,List<goalAndActions>>();//SFSE-12520
    }
    
    @AuraEnabled
    public static fileWrapper checkFileIfPresent(Id recId){ 
        Business_Plan__c bp = [SELECT Id, Name FROM Business_Plan__c WHERE Id =:recId];
        String strcdl = '';
        fileWrapper fW = new fileWrapper();
        fw.recName = bp.Name;
        for(ContentDocumentLink cdl : [SELECT ContentDocument.Description, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink 
                                       WHERE LinkedEntityId =: recId AND ContentDocument.Description = 'Account Plan Output']) {                            
                                           fW.fileStatus = 'file present';
                                           fW.fileurl = cdl.ContentDocumentId;
                                           fw.fileName = cdl.ContentDocument.Title;  
                                           
                                       }
        return fW;
    }
    public class fileWrapper {
        @AuraEnabled
        public string fileStatus {get;set;}
        @AuraEnabled
        public string fileName {get;set;}
        @AuraEnabled
        public string recName {get;set;}
        @AuraEnabled
        public string fileurl {get;set;}
        public fileWrapper(){
            fileStatus = 'file is not present';
            fileurl = '';
            fileName = '';
            recName = '';
        }
    }
    
    //SFSE-12520
    public class DeleteFileReqWrapper {
        public string contentdocumentlinkId {get;set;}
        public string contentdocumentId {get;set;}
    }
    
 	@AuraEnabled
    public static string deletefile(String fileId, String linkId){  
        String filestatus = '';
        if(fileId != null && fileId != '' && linkId != null && linkId != ''){
            List<ContentDocumentLink> cdl = [SELECT Id,ContentDocument.Id,ContentDocument.Title, LinkedEntityId,ContentDocument.CreatedDate,  
                                             ContentDocument.FileType FROM ContentDocumentLink WHERE ContentDocument.Id =:fileId AND LinkedEntityId =:linkId]; 
            try{
                //SFSE-12520 - start
                if(cdl != null && cdl.size() > 0){
                    DeleteFileReqWrapper delWrapper = new DeleteFileReqWrapper();
                    delWrapper.contentdocumentlinkId = cdl[0].id;
                    delWrapper.contentdocumentId = fileId;
                    string sBody = JSON.serialize(delWrapper); 
                    
                    Http h = new Http();
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint('callout:LokiHerokuAppConnector'+'/api/auth/deleteaccountplanoutputfile');
                    req.setMethod('POST');
                    req.setHeader('Accept', 'application/json');
                    req.setHeader('Content-Type', 'application/json');
                    req.setBody(sBody);
                    HttpResponse res = h.send(req);
                    if(res.getBody() != null && res.getBody() != '' && res.getBody().contains('Deleted Successfully')) {
                        filestatus = 'File Successfully Deleted';
                    }
                }
                //SFSE-12520 - end
            }catch (exception e) {
                filestatus = e.getMessage();
                system.debug('@@@@@ ' + e.getMessage());
            } 
        }
        return filestatus;
    }

    
    @AuraEnabled 
    public static string generatefile(String recId, List<String> listOfSectionsToDisplay){ 
        String filestatus = '';
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:LokiHerokuAppConnector'+'/api/auth/registerData');
        req.setMethod('POST');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(getAccountPlanDetails(recId, listOfSectionsToDisplay)); //SFSE-12520 No sections for WORD file
        HttpResponse res = h.send(req); 
        accountplanresponsewrapper wrapper = (accountplanresponsewrapper)JSON.deserialize(res.getBody(), accountplanresponsewrapper.class);
        for(accountplanresponsewrapper.compositeResponse aaaa: wrapper.compositeResponse) { 
            if(aaaa.httpStatusCode == 200 || aaaa.httpStatusCode == 201) {
                filestatus =  'File Successfully Created';
            }
        }
        return filestatus;
    }
    
    /* SFSE-13853
    * @description Fetch Account Plan Document Generation Usage Data
    * @return Queried data in JSON format
    */
    @auraEnabled
    public static String fetchAccPlanDocGenerationUsageData(){
        try{
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:LokiHerokuAppConnector'+'/api/auth/getdocumentgenerationusagedata');
            req.setMethod('GET');
            Http http = new Http();
            HTTPResponse res = http.send(req); 
            return res.getBody();
        }
        catch (exception e) {
            system.debug('@@@@@ ' + e.getMessage());
            return null;
        } 
    }
    
    /* SFSE-12520
    * @description Creates PPT document for the account plan
    * @param  recId: Id of the account plan 
    * @param  listOfSectionsToDisplay: The sections selected from LWC component 
    * @return Status of file creation
    */
    @auraEnabled
    public static string generatePPT(String recId, List<String> listOfSectionsToDisplay){
        
        //SFSE-13853 Store the current(incoming) account plan id in cache to indicate the ppt generation for it is in progress
        String cacheKeyStr = 'local.accountPlanLokiFileStatusOrgCache.'+UserInfo.getUserId()+recId;
        if(!Cache.Org.contains(cacheKeyStr)){
           Cache.Org.put(cacheKeyStr, recId);//SFSE-13853  
        }  
        String filestatus = '';
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:LokiHerokuAppConnector'+'/api/auth/pptgenerator');
        req.setMethod('POST');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
        req.setBody(getAccountPlanDetails(recId,listOfSectionsToDisplay));
        HttpResponse res = h.send(req); 
        /* Heroku sends 503 after 30 second limit - Service Unavailable response*/
        if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
            accountplanresponsewrapper wrapper = (accountplanresponsewrapper)JSON.deserialize(res.getBody(), accountplanresponsewrapper.class);
            for(accountplanresponsewrapper.compositeResponse aaaa: wrapper.compositeResponse) {
                
                if(aaaa.httpStatusCode == 200 || aaaa.httpStatusCode == 201) {   
                    filestatus =  'File Successfully Created';
                }
            }  
        }  
        return filestatus;
    }
     
    /* SFSE-13853
    * @description Removes the incoming account plan id from cache 
    * 			   This will be called in 2 scenarios:
    * 			   1. When ppt generation is initiated and in progress
    * 			   2. When ppt generation do not succeed even after 3 minutes.
    * @param  Account Plan Id which needs to be removed from Cache    
    * @return List of account plan ids in cache if it exists or return empty set<String> 
    */ 
    @auraEnabled
    public static void removeAccountPlanFromCache(String accountPlanId){ 
        String cacheKeyStr = 'local.accountPlanLokiFileStatusOrgCache.'+UserInfo.getUserId()+accountPlanId;
        if(Cache.Org.contains(cacheKeyStr) && Cache.Org.get(cacheKeyStr) == accountPlanId){
          Cache.Org.remove(cacheKeyStr);  
        } 
    }
        
        
    //SFSE-12520 Adding parameter listOfPPTSections
    public static string getAccountPlanDetails(String recId, List<String> listOfPPTSections) { 
        mapofAccountPlanToTripleCanvas =  getTripefitCanvasDetails(recId);
        mapofAccountPlanToStakeholders = getStakeholderDetails(recId);
        mapofAccountPlanToCustomerMetrics = getCustomerMetricDetails(recId);
        mapofAccountPlanToCustomerCoverage = getCustomerCoverageDetails(recId);
        mapofAccountPlanToOperationDevelops = getOperationDevelopmentsDetails(recId);
        mapofAccountPlanToActions = getPlans(recId); 
        mapofAccountPlanToGoalAndActions = getGoalAndActions(recId); //SFSE-14253
        List<accountplanwrapper> lstaccWrapper = new List<accountplanwrapper>();
        User usr = getLoggedInUserInfo();
        for(Business_Plan__c businessplans :[SELECT Id, Name, Account_Plan_Concern__c, Lead_Account__r.Name, Lead_Account__r.Parent.Customer_Code__c,Lead_Account__c,Liner_Brand__c, Address__c,
                                             Customer_Website__c, Vertical__c, Customer_Mission_Statement__c, Recent_Developments__c,Business_Model__c,Drivers_for_Logistics_Buying_Decisions__c,Key_Incumbent_Logistics_Players__c,Key_Supply_Chain_Logistics_Challenges__c,Supply_Chain_Logistics_Priorities_LT__c,Supply_Chain_Logistics_Priorities_ST__c,Top_Business_Priorities_LT__c,Top_Business_Priorities_ST__c ,Key_Joint_Successes_To_Leverage__c, Awards_Recognition_by_the_Customer__c,Significant_Past_Complaints_or_Conflicts__c,Success_in_Relationship__c ,Share_of_Wallet_Comments__c
                                             FROM Business_Plan__c WHERE Id =: recId]) {
                                                 accountplanwrapper accWrapper = new accountplanwrapper();
                                                 accWrapper.accountplanname = businessplans.Name;
                                                 accWrapper.accname =  businessplans.Name;
                                                 accWrapper.brand = businessplans.Liner_Brand__c == 'Hamburg Sud' ? 'hbdsud':'msk';
                                                 accWrapper.accPlanId = businessplans.Id;
                                                 accWrapper.userEmailAddress = usr?.Email;/*SFSE-12520*/
                                                 accWrapper.userName = usr?.Name;/*SFSE-12520*/
                                                 accWrapper.maerskUserId = usr?.Maersk_User_Id__c;/*SFSE-12520*/
                                                 accWrapper.accConcernCode = businessplans.Lead_Account__r?.Parent?.Customer_Code__c;/*SFSE-12520*/
                                                 accWrapper.accountplanconcern = businessplans.Account_Plan_Concern__c;
                                                 accWrapper.leadaccount = businessplans.Lead_Account__r.Name;
                                                 accWrapper.leadaccountid = businessplans.Lead_Account__c; /*SFSE-12520*/
                                                 accWrapper.address = businessplans.Address__c.replace('<br>', '');
                                                 accWrapper.customerwebsite = businessplans.Customer_Website__c;
                                                 accWrapper.maerskvertical = businessplans.Vertical__c;
                                                 accWrapper.customervision = businessplans.Customer_Mission_Statement__c;
                                                 accWrapper.recentdevelopments = businessplans.Recent_Developments__c;
                                                 accWrapper.businessmodel = businessplans.Business_Model__c;
                                                 accWrapper.topbusinesspriorityst = businessplans.Top_Business_Priorities_ST__c;
                                                 accWrapper.topbusinessprioritylt = businessplans.Top_Business_Priorities_LT__c;
                                                 accWrapper.supplychainpriorityst = businessplans.Supply_Chain_Logistics_Priorities_ST__c;
                                                 accWrapper.supplychainprioritylt = businessplans.Supply_Chain_Logistics_Priorities_LT__c;
                                                 accWrapper.keysupplychainchallenges = businessplans.Key_Supply_Chain_Logistics_Challenges__c;
                                                 accWrapper.driversforlogistics =  businessplans.Drivers_for_Logistics_Buying_Decisions__c;
                                                 accWrapper.keyincumbentlogisticsplayer = businessplans.Key_Incumbent_Logistics_Players__c; 
                                                 accWrapper.successinrelationship = businessplans.Success_in_Relationship__c;/*SFSE-12520*/
                                                 accWrapper.successinpast = businessplans.Significant_Past_Complaints_or_Conflicts__c;/*SFSE-12520*/
                                                 /*SFSE-12520*/
                                                 if(listOfPPTSections!= null && listOfPPTSections.size() > 0){  
                                                     accWrapper.selectedPPTSections = listOfPPTSections;
                                                 }
                                                 /*SFSE-12520*/
                                                 if(mapofAccountPlanToTripleCanvas !=null && mapofAccountPlanToTripleCanvas.size() > 0) {
                                                     for(Triple_Fit_Canvas__c tfc: mapofAccountPlanToTripleCanvas.get(businessplans.Id)){
                                                         triplefitcanvas tfit = new triplefitcanvas();  
                                                         tfit.canvasname = tfc.Name;
                                                         tfit.currentscore = String.valueOf(tfc.Current_Score__c) != null ? String.valueOf(tfc.Current_Score__c) : null;
                                                         tfit.targetscore =  String.valueOf(tfc.Target_Score__c) != null ? String.valueOf(tfc.Target_Score__c) : null;
                                                         tfit.priority =  String.valueOf(tfc.Priority__c) !=null ? String.valueOf(tfc.Priority__c) : null;
                                                         tfit.competitorscore =  String.valueOf(tfc.Main_Competitor_Score__c) !=null ? String.valueOf(tfc.Main_Competitor_Score__c) : null;
                                                         tfit.remarks =  String.valueOf(tfc.Remarks__c) !=null ? String.valueOf(tfc.Remarks__c) : null;
                                                         accWrapper.triplefitcanvas.add(tfit);
                                                     }
                                                 }
                                                 if(mapofAccountPlanToStakeholders !=null && !mapofAccountPlanToStakeholders.isEmpty()) {
                                                     for(Stakeholder__c stk: mapofAccountPlanToStakeholders.get(businessplans.Id)) {
                                                         /*SFSE-12520*/
                                                         if(listOfPPTSections!= null && listOfPPTSections.size() > 0){
                                                             if(stk.RecordType.DeveloperName == 'Internal') {
                                                                 if(stk.Account_Plan_Team_Role__c != 'Local Client Manager' && stk.Account_Plan_Team_Role__c != 'Other'){
                                                                     accountteam actteam = new accountteam();
                                                                     actteam.stakeholdername = stk.Name != null && stk.Name != '' ? stk.Name.replaceAll('\\(.*\\)', '') : '';//removing numbers from stakeholder name
                                                                     actteam.teamrole = stk.Account_Plan_Team_Role__c;
                                                                     actteam.country = stk.Internal_Stakeholder__r.Country__r.Name; 
                                                                     actteam.phone = stk.Internal_Stakeholder__r.Phone;
                                                                     actteam.email = stk.Internal_Stakeholder__r.Email;
                                                                     accWrapper.accountteam.add(actteam);
                                                                 }
                                                             }
                                                             else{
                                                                 if(stk.Decision_Making_Power__c != null && stk.Decision_Making_Power__c == 'Decision Maker' && stk.Primary_Stakeholder__c != null){
                                                                     customerstakeholders custoStk = new customerstakeholders();
                                                                     custoStk.stakeholder = stk.Name != null && stk.Name != '' ? stk.Name.replaceAll('\\(.*\\)', '') : '';//removing numbers from stakeholder name
                                                                     custoStk.reportsto = stk.External_Stakeholder__r.ReportsTo.Name;
                                                                     custoStk.decisionmakingpower = stk.Decision_Making_Power__c;
                                                                     custoStk.supportformsk = stk.Support_for_Maersk__c;
                                                                     custoStk.primaryrelationship = stk.Primary_Stakeholder__r.Name != null && stk.Primary_Stakeholder__r.Name != '' ? stk.Primary_Stakeholder__r.Name.replaceAll('\\(.*\\)', '') : '';//removing numbers from stakeholder name
                                                                     accWrapper.customerstakeholders.add(custoStk);
                                                                 }
                                                             }
                                                         }/*SFSE-12520*/
                                                         else{
                                                             if(stk.RecordType.DeveloperName == 'Internal') {
                                                                 accountteam actteam = new accountteam();
                                                                 actteam.stakeholdername = stk.Name;
                                                                 actteam.teamrole = stk.Account_Plan_Team_Role__c;
                                                                 actteam.country = stk.Internal_Stakeholder__r.Country__r.Name; 
                                                                 actteam.phone = stk.Internal_Stakeholder__r.Phone;
                                                                 actteam.email = stk.Internal_Stakeholder__r.Email;
                                                                 accWrapper.accountteam.add(actteam);
                                                             }
                                                             else{    
                                                                 customerstakeholders custoStk = new customerstakeholders();
                                                                 custoStk.stakeholder = stk.Name;
                                                                 custoStk.reportsto = stk.External_Stakeholder__r.ReportsTo.Name;
                                                                 custoStk.decisionmakingpower = stk.Decision_Making_Power__c;
                                                                 custoStk.supportformsk = stk.Support_for_Maersk__c;
                                                                 custoStk.primaryrelationship = stk.Primary_Stakeholder__r.Name;
                                                                 accWrapper.customerstakeholders.add(custoStk);
                                                             }
                                                         }
                                                         
                                                     }
                                                 }
                                                 chart chrtdata = new chart();
                                                 if(mapofAccountPlanToCustomerMetrics !=null && mapofAccountPlanToCustomerMetrics.size() > 0) {
                                                     for(Customer_Metrics__c cust : mapofAccountPlanToCustomerMetrics.get(businessplans.Id)) {
                                                         customermetrics custmetrics = new customermetrics();
                                                         
                                                         chrtdata.label.add(cust.Year__c);
                                                         chrtdata.datas.add(string.valueof(cust.Maersk_Share_of_Wallet__c));
                                                         custmetrics.year = cust.Year__c;
                                                         custmetrics.metricstatus = cust.Metrics_Status__c;
                                                         custmetrics.customerannualrevenue = string.valueOf(cust.Customers_Annual_Revenue__c);
                                                         custmetrics.ebit = string.valueof(cust.EBIT__c);
                                                         custmetrics.netprofit = string.valueof(cust.Net_Profit__c);
                                                         custmetrics.mskaddressablespend = string.valueof(cust.Maersk_Addressable_Spend__c);
                                                         custmetrics.mskrevenue= string.valueof(cust.Maersk_Revenue__c); 
                                                         custmetrics.mskshareofwallet = string.valueof(cust.Maersk_Share_of_Wallet__c);
                                                         accWrapper.customermetrics.add(custmetrics);
                                                         
                                                     }
                                                 }
                                                 accWrapper.chart.add(chrtdata);
                                                 if(mapofAccountPlanToCustomerCoverage !=null && mapofAccountPlanToCustomerCoverage.size() > 0) {
                                                     for(Customer_Coverage__c customcoverage : mapofAccountPlanToCustomerCoverage.get(businessplans.Id)) {
                                                         customercoverage customcover = new customercoverage();
                                                         customcover.customerbusinessunit = customcoverage.Name;
                                                         customcover.customerfootprintcurrent = customcoverage.Maersk_Footprint_Current__c;
                                                         customcover.mskfootprintambition = customcoverage.Maersk_Footprint_Ambition__c;
                                                         customcover.comments = customcoverage.Comments__c;
                                                         accWrapper.customercoverage.add(customcover);
                                                     }
                                                 }
                                                 if(mapofAccountPlanToOperationDevelops !=null && mapofAccountPlanToOperationDevelops.size() > 0) {
                                                     for(Operational_Development__c opds: mapofAccountPlanToOperationDevelops.get(businessplans.Id)) {
                                                         operationaloperations opd = new operationaloperations();
                                                         opd.projectname = opds.Name;
                                                         opd.status = opds.Status__c;
                                                         opd.location = opds.Status__c;
                                                         opd.productinvolved = opds.Products_Involved__c;
                                                         opd.comments = opds.Comments__c;
                                                         accWrapper.operationaloperations.add(opd);
                                                     }
                                                 }
                                                 if(mapofAccountPlanToActions !=null && mapofAccountPlanToActions.size() > 0) {
                                                     for(Action__c act: mapofAccountPlanToActions.get(businessplans.Id)) {
                                                         plan pl = new plan();
                                                         pl.focusareaname = act.Maersk_Deliverables__r.Focus_Area__r.Name;
                                                         pl.mskdeliverablename = act.Maersk_Deliverables__r.Name;
                                                         pl.actionname= act.Name;
                                                         pl.completiondate = act.Completion_Date__c;
                                                         pl.status = act.Status__c;
                                                         pl.duedate = act.Due_Date__c;
                                                         pl.owner = act.Owner.Name;
                                                         pl.goalname = act.Goals__r.Name;
                                                         pl.supportneeded = act.Support_Needed__c;
                                                         accWrapper.plan.add(pl);
                                                     }  
                                                 }
                                                 //SFSE-14253
                                                 if(mapofAccountPlanToGoalAndActions != null && mapofAccountPlanToGoalAndActions.size() >0){
                                                     accWrapper.goalAndActions = mapofAccountPlanToGoalAndActions.get(recId);  
                                                 }//SFSE-14253 
                                                 lstaccWrapper.add(accWrapper);                                                 
                                             }
        string sbody = JSON.serialize(lstaccWrapper[0]);  
        return sbody;
    }
    
    
    public static Map<Id,List<Operational_Development__c>> getOperationDevelopmentsDetails(Id recId) {
        Map<Id,List<Operational_Development__c>> mapOfIdtoOperationDevelopments = new Map<Id,List<Operational_Development__c>>(); 
        for(Operational_Development__c opds: [SELECT Name, Account_Plan__c, Comments__c, Location__c, Products_Involved__c, Status__c 
                                              FROM Operational_Development__c WHERE Account_Plan__c =: recId]){
                                                  
                                                  if(mapOfIdtoOperationDevelopments.containsKey(opds.Account_Plan__c) && mapOfIdtoOperationDevelopments.get(opds.Account_Plan__c) != null) {
                                                      List<Operational_Development__c> lst_opds = mapOfIdtoOperationDevelopments.get(opds.Account_Plan__c);
                                                      lst_opds.add(opds);
                                                      mapOfIdtoOperationDevelopments.put(opds.Account_Plan__c,lst_opds); 
                                                  }   
                                                  else {
                                                      mapOfIdtoOperationDevelopments.put(opds.Account_Plan__c, new List<Operational_Development__c> {opds});
                                                  }
                                                  
                                              }
        
        return mapOfIdtoOperationDevelopments; 
        
    }
    
    public static Map<Id,List<Customer_Coverage__c>> getCustomerCoverageDetails(Id recId) {
        Map<Id,List<Customer_Coverage__c>> mapOfIdtoCustomerMetrics = new Map<Id,List<Customer_Coverage__c>>(); 
        for(Customer_Coverage__c custm: [SELECT Name, Comments__c, Account_Plan__c, Maersk_Footprint_Ambition__c, Maersk_Footprint_Current__c 
                                         FROM Customer_Coverage__c WHERE Account_Plan__c =: recId]){
                                             
                                             if(mapOfIdtoCustomerMetrics.containsKey(custm.Account_Plan__c) && mapOfIdtoCustomerMetrics.get(custm.Account_Plan__c) != null) {
                                                 List<Customer_Coverage__c> lst_custm = mapOfIdtoCustomerMetrics.get(custm.Account_Plan__c);
                                                 lst_custm.add(custm);
                                                 mapOfIdtoCustomerMetrics.put(custm.Account_Plan__c,lst_custm); 
                                             }   
                                             else {
                                                 mapOfIdtoCustomerMetrics.put(custm.Account_Plan__c, new List<Customer_Coverage__c> {custm});
                                             }
                                             
                                         }
        
        return mapOfIdtoCustomerMetrics; 
        
    }
    
    public static Map<Id,List<Stakeholder__c>> getStakeholderDetails(Id recId) {
        Map<Id,List<Stakeholder__c>> mapOfIdtoStakeHolder = new Map<Id,List<Stakeholder__c>>();
        for(Stakeholder__c stk: [SELECT Primary_Stakeholder__r.Name, Internal_Stakeholder__r.Email, External_Stakeholder__r.ReportsTo.Name, Internal_Stakeholder__r.Phone, RecordType.DeveloperName,Internal_Stakeholder__r.Country__r.Name, Account_Plan_Team_Role__c,Business_Plan__c,CreatedById,CreatedDate,Decision_Making_Power__c,Dummy_Id__c,Executional_Broad_Need_Areas__c,Executive__c,
                                 External_Stakeholder__c,Frequency__c,Id,Influence_Level__c,Internal_Stakeholder_Support__c,Internal_Stakeholder__c,Liner_Brand_Logo__c,
                                 Liner_Brand__c,Name,Number_Of_Sales_Calls__c,OwnerId,Primary_Key__c,Primary_Stakeholder__c,RecordTypeId,Stakeholder_Counter__c,
                                 Stakeholder__c,Strategic_Change_Drivers__c,Support_for_Maersk__c FROM Stakeholder__c WHERE Business_Plan__c =: recId]){
                                     
                                     if(mapOfIdtoStakeHolder.containsKey(stk.Business_Plan__c) && mapOfIdtoStakeHolder.get(stk.Business_Plan__c) != null) {
                                         List<Stakeholder__c> lst_stk = mapOfIdtoStakeHolder.get(stk.Business_Plan__c);
                                         lst_stk.add(stk);
                                         mapOfIdtoStakeHolder.put(stk.Business_Plan__c,lst_stk); 
                                     }   
                                     else {
                                         mapOfIdtoStakeHolder.put(stk.Business_Plan__c, new List<Stakeholder__c> {stk});
                                     }
                                     
                                 }
        
        return mapOfIdtoStakeHolder;
    }
    
    public static Map<Id,List<Triple_Fit_Canvas__c>> getTripefitCanvasDetails(Id recId) {
        Map<Id,List<Triple_Fit_Canvas__c>> mapOfIdtoTriplefitCanvas = new Map<Id,List<Triple_Fit_Canvas__c>>();
        for(Triple_Fit_Canvas__c tfc: [SELECT Account_Plan__c,Current_Score__c,Id, Main_Competitor_Score__c,Name,Order__c,Priority__c,Remarks__c,Target_Score__c 
                                       FROM Triple_Fit_Canvas__c WHERE Account_Plan__c =: recId ORDER BY Priority__c ASC NULLS LAST]){
                                           
                                           if(mapOfIdtoTriplefitCanvas.containsKey(tfc.Account_Plan__c) && mapOfIdtoTriplefitCanvas.get(tfc.Account_Plan__c) != null) {
                                               List<Triple_Fit_Canvas__c> lst_tfc = mapOfIdtoTriplefitCanvas.get(tfc.Account_Plan__c);
                                               lst_tfc.add(tfc);
                                               mapOfIdtoTriplefitCanvas.put(tfc.Account_Plan__c,lst_tfc); 
                                           }   
                                           else {
                                               mapOfIdtoTriplefitCanvas.put(tfc.Account_Plan__c, new List<Triple_Fit_Canvas__c> {tfc});
                                           }
                                           
                                       }
        
        return mapOfIdtoTriplefitCanvas;   
        
    }
    
    public static Map<Id,List<Customer_Metrics__c>> getCustomerMetricDetails(Id recId) {
        Map<Id,List<Customer_Metrics__c>> mapOfIdtoCustomMetrics = new Map<Id,List<Customer_Metrics__c>>();
        for(Customer_Metrics__c cms: [SELECT Maersk_Revenue__c,Maersk_Addressable_Spend__c,Customers_Annual_Revenue__c, Net_Profit__c, EBIT__c, Business_Plan__c, Maersk_Share_of_Wallet__c,Year__c,Metrics_Status__c FROM Customer_Metrics__c 
                                      WHERE Business_Plan__c =: recId]){
                                          
                                          if(mapOfIdtoCustomMetrics.containsKey(cms.Business_Plan__c) && mapOfIdtoCustomMetrics.get(cms.Business_Plan__c) != null) {
                                              List<Customer_Metrics__c> lst_cms = mapOfIdtoCustomMetrics.get(cms.Business_Plan__c);
                                              lst_cms.add(cms);
                                              mapOfIdtoCustomMetrics.put(cms.Business_Plan__c,lst_cms); 
                                          }   
                                          else {
                                              mapOfIdtoCustomMetrics.put(cms.Business_Plan__c, new List<Customer_Metrics__c> {cms});
                                          }
                                          
                                      }
        
        return mapOfIdtoCustomMetrics;   
        
    }
    
    public static Map<Id,List<Action__c>> getPlans (Id recId) {
        Map<Id,List<Action__c>> mapOfIdtoActions = new Map<Id,List<Action__c>>();
        for(Action__c cms: [select Id, Name,Owner.Name,Support_Needed__c,Goals__r.Name,Maersk_Deliverables__r.Name, Account_Plan__c, Maersk_Deliverables__r.Focus_Area__r.Name, Completion_Date__c, Status__c, Due_Date__c from Action__c
                            WHERE Account_Plan__c =: recId AND Maersk_Deliverables__c !=null]){
                                
                                if(mapOfIdtoActions.containsKey(cms.Account_Plan__c) && mapOfIdtoActions.get(cms.Account_Plan__c) != null) {
                                    List<Action__c> lst_cms = mapOfIdtoActions.get(cms.Account_Plan__c);
                                    lst_cms.add(cms);
                                    mapOfIdtoActions.put(cms.Account_Plan__c,lst_cms); 
                                }   
                                else {
                                    mapOfIdtoActions.put(cms.Account_Plan__c, new List<Action__c> {cms});
                                }
                                
                            }
        
        return mapOfIdtoActions;   
        
    } 
    
    /* SFSE-12520
    * @description Creates a wrapper of Goal and its Actions for each Account Plan
    * @param Account Plan Record Id 
    * @return A wrapper of  3 Goals and its (maximum 2) Actions for the incoming Account Plan
    */
    public static  Map<Id,List<goalAndActions>> getGoalAndActions(String recId){ 
        Map<Id,List<goalAndActions>> mapAccountPlanIdtoGoalActionsLst = new Map<Id,List<goalAndActions>>();  
        List<goalAndActions> listGoalActionWrapper = new List<goalAndActions>(); 
        Map<Id,Focus_Area__c> mapPriorityGoals = new Map<Id,Focus_Area__c>(); 
        Map<Id,List<Action>> mapGoalIdToActionWrapperLst = new Map<Id,List<Action>>();
        Map<Decimal,String> mapTCFPriorityToName = new Map<Decimal, String>(); 
        //Map holds key as top priority TFC name --> the most valid Goal Id --> Its list of action wrapper
        //There can be multiple goals with the same TFC Value Driver field for the same account plan.
        //Most valid Goal --> Goal with valid actions of nearest due date > Goal with valid(future/greater due dates) actions > Goal with zero actions
        Map<String, Map<Id,List<Action>>> mapKeyToGoalIdListActionWrapper = new Map<String, Map<Id,List<Action>>>();  
        Map<String, Map<Id,List<Action__c>>> mapKeyToGoalIdListAction = new Map<String, Map<Id,List<Action__c>>>();  
        
        //Get first 3 TFC records (related to Account Plan) in the ascending order of Priority 
        for(Triple_fit_Canvas__c tcfRec :[SELECT Id, Name, Priority__c from Triple_fit_Canvas__c WHERE Account_Plan__c = :recId AND Priority__c != null ORDER BY Priority__c]){
            mapTCFPriorityToName.put(tcfRec.Priority__c,tcfRec.Name);
            if(mapTCFPriorityToName.size() == 3) break; 
        }      
        
        //Send Goal and Action data to Loki app for PPT generation only if the Account Plan has TFC with Priority 
        if(mapTCFPriorityToName.size() > 0){
            
            //Query the priority goals along with the maximum 2 actions with active due date.
            //At the end of loop, we have a map of Eg: Strategy --> Most Valid Goald Id --> List ( Action Wrapper)
            for(Focus_Area__c goalRec :[Select Id,Name,TFC_Value_Driver__c,Right_to_Win__c,(SELECT Goals__c,Due_Date__c,Owner.Name, Name,Status__c,
                                                                                            Support_Needed__c,Goals__r.TFC_Value_Driver__c from Actions__r WHERE Archived__c = false AND Due_Date__c != null 
                                                                                            AND Due_Date__c >= TODAY ORDER BY Due_date__c) FROM Focus_Area__c where Archived__c = false AND 
                                        Account_Plan__c = :recId AND TFC_Value_Driver__c IN :mapTCFPriorityToName.values()]){
                                            
                                            //If the Goal for the incoming Priority is not yet added in the map, add the incoming goal      
                                            if(!mapKeyToGoalIdListActionWrapper.containsKey(goalRec.TFC_Value_Driver__c)){
                                                mapKeyToGoalIdListActionWrapper.put(goalRec.TFC_Value_Driver__c,new Map<Id,List<Action>>());
                                                mapKeyToGoalIdListAction.put(goalRec.TFC_Value_Driver__c,new Map<Id,List<Action__c>>());
                                                List<Action> lstActionWrapper = createListOfActionWrapper(goalRec.Actions__r);
                                                mapKeyToGoalIdListActionWrapper.get(goalRec.TFC_Value_Driver__c).put(goalRec.Id,lstActionWrapper); 
                                                mapKeyToGoalIdListAction.get(goalRec.TFC_Value_Driver__c).put(goalRec.Id,goalRec.Actions__r); 
                                                mapPriorityGoals.put(goalRec.Id,goalRec);
                                            }  
                                            
                                            //If the priority and goal is already added, check if the incoming goal is more relavant than the one added
                                            if(mapKeyToGoalIdListActionWrapper.containsKey(goalRec.TFC_Value_Driver__c)){
                                                
                                                //If incoming goal has action records and existing goal in map do not have action records, replace it
                                                if(goalRec.actions__r.size() > 0 && mapKeyToGoalIdListActionWrapper.get(goalRec.TFC_Value_Driver__c).values().size() == 0){
                                                    
                                                    //Replace the existing goal with incoming one
                                                    mapKeyToGoalIdListActionWrapper.get(goalRec.TFC_Value_Driver__c).clear(); 
                                                    mapKeyToGoalIdListAction.get(goalRec.TFC_Value_Driver__c).clear(); 
                                                    List<Action> lstActionWrapper = createListOfActionWrapper(goalRec.Actions__r);  
                                                    mapKeyToGoalIdListActionWrapper.get(goalRec.TFC_Value_Driver__c).put(goalRec.Id,lstActionWrapper);
                                                    mapKeyToGoalIdListAction.get(goalRec.TFC_Value_Driver__c).put(goalRec.Id,goalRec.Actions__r);
                                                    mapPriorityGoals.put(goalRec.Id,goalRec);
                                                }
                                                
                                                //If existing one has actions and incoming one also has actions, then take the goal which has action with nearest due date  
                                                else if(goalRec.actions__r.size() > 0 && mapKeyToGoalIdListActionWrapper.get(goalRec.TFC_Value_Driver__c).values().size() > 0){
                                                    
                                                    List<Action__c> validActionsToCompare = new List<Action__c>();
                                                    validActionsToCompare.addAll(goalRec.actions__r);
                                                    
                                                    //Using for loop here since this will not exceed more than 5 loops mostly
                                                    for(Integer i= 0; i < mapKeyToGoalIdListAction.get(goalRec.TFC_Value_Driver__c).values().size(); i++){
                                                        validActionsToCompare.addAll(mapKeyToGoalIdListAction.get(goalRec.TFC_Value_Driver__c).values()[i]);    
                                                    }   
                                                    
                                                    //Check Goal that has smallest due date withing 6 months or, after 6 months if prior is none
                                                    String  mostValidGoal;
                                                    if(validActionsToCompare.size() == 1){
                                                        mostValidGoal =  validActionsToCompare[0].Goals__c; 
                                                    }else{
                                                        List<Action__c> mostValidActionsFound = compareAndGetValidActionsLst(validActionsToCompare); 
                                                        //This list will contain 2 most valid actions 
                                                        if(mostValidActionsFound.size() == 2){
                                                            //If both the valid goals fall in next 6 months, take the most nearest(smallest) among them
                                                            if(mostValidActionsFound[0].Due_Date__c <= Date.today().addMonths(6)){
                                                                //If next due date is more than 6 months, then take the one within 6 months
                                                                if(mostValidActionsFound[1].Due_Date__c > Date.today().addMonths(6)){
                                                                    mostValidGoal =  mostValidActionsFound[0].Goals__c;
                                                                }else if(mostValidActionsFound[1].Due_Date__c <= Date.today().addMonths(6)){
                                                                    if(mostValidActionsFound[0].Due_Date__c < mostValidActionsFound[1].Due_Date__c){
                                                                        mostValidGoal = mostValidActionsFound[0].Goals__c;
                                                                    }else{
                                                                        mostValidGoal = mostValidActionsFound[1].Goals__c;
                                                                    }
                                                                }
                                                            } 
                                                        }else{
                                                            mostValidGoal = mostValidActionsFound[0].Goals__c;
                                                        }
                                                    }  
                                                    if(!mapKeyToGoalIdListActionWrapper.get(goalRec.TFC_Value_Driver__c).containsKey(mostValidGoal)){
                                                        //i.e we need to replace the existing goal with the incoming one
                                                        mapKeyToGoalIdListActionWrapper.get(goalRec.TFC_Value_Driver__c).clear(); 
                                                        List<Action> lstActionWrapper = createListOfActionWrapper(goalRec.Actions__r);  
                                                        mapKeyToGoalIdListActionWrapper.get(goalRec.TFC_Value_Driver__c).put(goalRec.Id,lstActionWrapper); 
                                                        mapPriorityGoals.put(goalRec.Id,goalRec);
                                                    }
                                                } 
                                            } 
                                          
                                            /*for(String tfcName: mapTCFPriorityToName.values()){
                                                //If the TFC do not contain the goal 
                                                if(!mapKeyToGoalIdListActionWrapper.containsKey(tfcName)){
                                                   mapKeyToGoalIdListActionWrapper.put(tfcName, new Map<Id,List<Action>>()); 
                                                }
                                            }*/
                                        }
            
            
            //Preparing Map of Goal Id --> (List of Action wrapper) from mapKeyToGoalIdListAction
            for(Map<Id,List<Action>> goalToActionLst : mapKeyToGoalIdListActionWrapper.values()){ 

            }  
            system.debug('mapGoalIdToActionWrapperLst'+mapGoalIdToActionWrapperLst);
            //Loop over the Goals to create the final goalAndActions wrapper list   
            for(Id goalId : mapGoalIdToActionWrapperLst.keySet()){ 
                goalAndActions goalActionWrapper = new goalAndActions(); 
                
                Goal goalWrapper = new Goal();
                goalWrapper.TFCValueDriver = mapPriorityGoals.get(goalId).TFC_Value_Driver__c;
                goalWrapper.goalName = mapPriorityGoals.get(goalId).Name;
                goalWrapper.customerSuccessCriteria = mapPriorityGoals.get(goalId).Right_to_Win__c;  
                //Inserting goal in the wrapper
                goalActionWrapper.goal = goalWrapper;
                
                //Checking if the Goal has actions related to it
                if(mapGoalIdToActionWrapperLst.containsKey(goalId) && mapGoalIdToActionWrapperLst.get(goalId) != null && mapGoalIdToActionWrapperLst.get(goalId).size()>0){
                    goalActionWrapper.actions = mapGoalIdToActionWrapperLst.get(goalId); //Inserting actions to the goal in wrapper 
                }
                listGoalActionWrapper.add(goalActionWrapper);
            }   
        }  
        
        mapAccountPlanIdtoGoalActionsLst.put(recId,listGoalActionWrapper);  
        return mapAccountPlanIdtoGoalActionsLst;  
    }
    
    /* SFSE-12520
    * @description Method to create action wrapper
    * @param List<Action__c>
    * @return List of 2 Action Wrappers
    */
    static List<Action> createListOfActionWrapper(List<Action__c> lstActionsToAdd){
        List<Action__c> selectedActions = new List<Action__c>();
        List<Action> lstActionWrapper = new List<Action>();
        
        if (lstActionsToAdd.size() == 0) {
            return null;
        }else if(lstActionsToAdd.size() == 1){
            //No comparison required. Just create the wrapper
            selectedActions = lstActionsToAdd;
        } else{ //If there are more than one actions, do the comparison
            selectedActions = compareAndGetValidActionsLst(lstActionsToAdd); 
        } 
        
        //To display nearest date in Action 1 column and larger one in Action 2 column in PPT
        selectedActions.sort(); 
        
        if(selectedActions.size() > 0){ 
            action actionWrapper = new action(); 
            actionWrapper.actionName = selectedActions[0].Name;
            actionWrapper.actionOwnerName = selectedActions[0].Owner.Name;
            actionWrapper.actionStatus = selectedActions[0].Status__c;
            actionWrapper.actionDueDate = selectedActions[0].Due_Date__c;
            actionWrapper.actionSupportNeeded = selectedActions[0].Support_Needed__c;  
            lstActionWrapper.add(actionWrapper);  
            
            if(selectedActions.size() == 2){ 
                actionWrapper = new action(); 
                actionWrapper.actionName = selectedActions[1].Name;
                actionWrapper.actionOwnerName = selectedActions[1].Owner.Name;
                actionWrapper.actionStatus = selectedActions[1].Status__c;
                actionWrapper.actionDueDate = selectedActions[1].Due_Date__c;
                actionWrapper.actionSupportNeeded = selectedActions[1].Support_Needed__c; 
                lstActionWrapper.add(actionWrapper);                                  
            } 
        }                                   
        return lstActionWrapper;
    }
    
    /* SFSE-12520
    * @description Method to find the 2 most valid actions from the incoming list 
    * Valid action --> Due date Within 6 months is more valid than due date after 6 months
    * If all actions are within 6 months, consider the nearest one as valid
    * @param List<Action__c>
    * @return List of 2 Action__c
    */
    static List<Action__c> compareAndGetValidActionsLst(List<Action__c> lstActionsToCompare){   
        
        if (lstActionsToCompare.size() == 0) {
            return null;
        }
        
        //List to hold dates withing 6 months (to prevent adding 
        //dates greater than 6 months if already there exists 2 dates within 6 months) 
        List<Date> datesWithinSixMonths = new List<Date>(); 
        Date sixMonthsFromNow = Date.today().addMonths(6); 
        List<Action__c> lstValidActions = new List<Action__c>{lstActionsToCompare[0]}; 
        if(lstActionsToCompare.size() > 1) lstValidActions.add(lstActionsToCompare[1]); 
        
        //Choose the most nearest date within 6 months. Else pick the nearest date from the available
        for (Action__c incomingAction : lstActionsToCompare) { 
            
            Date incomingDt = incomingAction.Due_Date__c;   
            if (incomingDt <= sixMonthsFromNow) { 
                datesWithinSixMonths.add(incomingAction.Due_Date__c); 
                //If the date is lesser than the current nearest date 
                if(incomingDt < lstValidActions[0].Due_Date__c){ 
                    lstValidActions[0] = incomingAction; 
                    lstValidActions[1] = lstValidActions[0]; 
                }else if (lstValidActions[1].Due_Date__c != null && incomingDt != lstValidActions[0].Due_Date__c && incomingDt < lstValidActions[1].Due_Date__c ) { 
                    lstValidActions[1] = incomingAction;
                }    
                
                
            } else { 
                if(datesWithinSixMonths.size()<2){ 
                    // If the date is not within the next six months and we have not got 2 dates yet, check if it's smaller than the current smallest dates
                    if(incomingDt < lstValidActions[0].Due_Date__c){  
                        lstValidActions[0] = incomingAction; 
                        lstValidActions[1] = lstValidActions[0];  
                    } else if (lstValidActions[1].Due_Date__c != null && incomingDt != lstValidActions[0].Due_Date__c && incomingDt < lstValidActions[1].Due_Date__c) {
                        lstValidActions[1] = incomingAction;
                    }  
                }
                
            }
            
        }  
        return lstValidActions;
    } 
    
   /* SFSE-12520
    * @description Method to get the sections to be displayed for PPT generation 
    * @param  
    * @return List AccountPlanPPTSections__mdt values
    */
    @AuraEnabled(cacheable=true)
    public static list<AccountPlanPPTSections__mdt> fetchAccountPlanPPTSectionMetadata(){ 
        return AccountPlanPPTSections__mdt.getAll().values();
    } 
    
    /* SFSE-12520
    * @description Method used in accountPlanFileStatusComponent LWC component
    * to check the if the document is generated or not and indicate in the UI
    * @param  Account Plan Id
    * @return File type 'pptx' or 'docx' if file is generated, OR 'inprogress' if acc plan found in cache or return null
    */
    @auraEnabled 
    public static String checkIfFileisGenerated(String accountPlanId){ 
        String filetype; 
        list<ContentDocumentLink> lstContentDocRec =  [select id,ContentDocument.FileExtension from ContentDocumentLink where ContentDocument.Description = 'Account Plan Output' AND LinkedEntityId = :accountPlanId];
        
        if(lstContentDocRec.size() > 0){   
          filetype = lstContentDocRec[0].ContentDocument != null ? lstContentDocRec[0].ContentDocument.FileExtension : null; 
          //Remove the current account plan from the cache when file is found 
          removeAccountPlanFromCache(accountPlanId);   
        }else {//SFSE-13853 If no file is created, check the cache for status
            String cacheKeyStr = 'local.accountPlanLokiFileStatusOrgCache.'+UserInfo.getUserId()+accountPlanId;
            if(Cache.Org.contains(cacheKeyStr) && Cache.Org.get(cacheKeyStr) == accountPlanId){
                //return value  - 'inprogress' for the current account plan
                filetype =  'inprogress';
            }   
        } 
        return filetype;
    }
    
    public class accountplanwrapper {
        public string userEmailAddress;//SFSE-12520
        public string userName;//SFSE-12520
        public string maerskUserId;//SFSE-12520
        public string accConcernCode;//SFSE-12520
        public string accountplanname;
        public string accname;
        public string brand;
        public string accountplanconcern;
        public string leadaccount;
        public string leadaccountid;
        public string address;
        public List<chart> chart;
        public string accPlanId;
        public string customerwebsite;
        public string maerskvertical;
        public string customervision;
        public string recentdevelopments;
        public string businessmodel;
        public string topbusinesspriorityst;
        public string topbusinessprioritylt;
        public string supplychainpriorityst;
        public string supplychainprioritylt;
        public string keysupplychainchallenges;
        public string driversforlogistics;
        public string keyincumbentlogisticsplayer;
        public string successinpast;
        public string successinrelationship;
        public string awardsrecognitioncustomer;
        public string significantpastcomplaintsconflicts;
        public list<accountteam> accountteam;
        public list<triplefitcanvas> triplefitcanvas;
        public string shareofwalletcomments;
        public list<customermetrics> customermetrics;
        public list<customercoverage> customercoverage;
        public list<operationaloperations> operationaloperations;
        public list<customerstakeholders> customerstakeholders;
        public list<plan> plan;
        public list<String> selectedPPTSections; //SFSE-12520
        public list<goalAndActions> goalAndActions; //SFSE-12520
        public accountplanwrapper() {
            accountplanname = '';
            triplefitcanvas = new list<triplefitcanvas>();
            customermetrics = new list<customermetrics>();
            customercoverage = new list<customercoverage>();
            operationaloperations = new list<operationaloperations>();
            customerstakeholders = new list<customerstakeholders>();
            accountteam = new list<accountteam>();
            chart = new List<chart>();
            plan = new List<plan>();
            selectedPPTSections = new List<String>();//SFSE-12520
            goalAndActions = new List<goalAndActions>();//SFSE-12520
        }
    }
    
    public class accountteam {
        public string stakeholdername;
        public string teamrole;
        public string country;
        public string phone;
        public string email;
        
        public accountteam(){
            
        }
    }
    
    public class triplefitcanvas {
        public string canvasname;
        public string currentscore;
        public string targetscore;
        public string priority;
        public string competitorscore;
        public string remarks;
        public triplefitcanvas(){
            
        }
    }
    
    public class customercoverage {
        public string customerbusinessunit;
        public string customerfootprintcurrent;
        public string mskfootprintambition;
        public string comments;
        public customercoverage(){
            
        }
    }
    
    public class operationaloperations {
        public string projectname;
        public string status;
        public string location;
        public string productinvolved;
        public string comments;
        public operationaloperations(){
            
        }
    }
    
    public class customerstakeholders {
        public string stakeholder;
        public string reportsto;
        public string decisionmakingpower;
        public string supportformsk;
        public string primaryrelationship;
        public customerstakeholders(){}
    }
    
    public class plan {
        public string focusareaname;
        public string mskdeliverablename;
        public string actionname;
        public date completiondate;
        public string status;
        public date duedate;
        public string supportneeded;
        public string goalname;
        public string owner;
        public plan(){}
    }
    
    public class customermetrics {
        public string year;
        public string metricstatus;
        public string customerannualrevenue;
        public string ebit;
        public string netprofit;
        public string mskaddressablespend;
        public string mskrevenue;
        public string mskshareofwallet;
        public customermetrics(){}
    }
    
    public class chart {
        public List<string> label;
        public list<string> datas;
        public chart(){
            label = new  List<string>();
            datas = new list<string>();
        }
    }
    //SFSE-12520
    public class goalAndActions{
        public goal goal;
        public List<action> actions;
        
        public goalAndActions(){
            goal = new goal();
            actions = new List<action>();
        }
    }
    //SFSE-12520
    public class goal {   
        public String TFCValueDriver;
        public String goalName;  
        public String customerSuccessCriteria;//Points to Why is this important field from Goal
        public goal(){}  
    }
    
    //SFSE-12520
    public class action {
        public String actionName;
        public String actionOwnerName;
        public String actionStatus;
        public Date actionDueDate;    
        public String actionSupportNeeded;
        public action(){}
    }
    
    //SFSE-12520
    public static user getLoggedInUserInfo(){
        User usr = new User();
        usr = [Select Id,Maersk_User_Id__c,Email,Name from User where Id =: UserInfo.getUserId()];
        return usr;
    }
}