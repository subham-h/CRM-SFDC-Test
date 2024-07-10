public class CaseSurveyCtrlrMIAW {
    
    //Variable declaraion. 
    public string LinerBrand{get;set;}
    public string linerBrandCSS{get;set;}
    public Id caseId{get;set;}
    public String feedback{get;set;}
    public String securityCode{get;set;}
    public Survey__c surveyRec{get;set;}
    public String detailedFeedback{get;set;}
    public Boolean surveyComplete{get;set;}
    public string language{get;set;}
    public Boolean exceptionCaught {get;set;} //#RQ-007849
    public String exceptionMsg {get;set;} //#RQ-007849
    public string pageName{get;set;}
    public Boolean successMessage{get;set;}
    public Boolean twill{get;set;}//#RQ-012315
    public Case surveyCase1;//SC-276

    
    private static final List<String> BOT_LAST_ACTION_TRANSFER_FAILED = Label.Transfer_Failed.toLowerCase().split(';'); //SC-2117
    
    //Constructor
    public CaseSurveyCtrlrMIAW() {
        pageName = ApexPages.currentPage().getUrl().substringAfter('/apex/').substringBefore('?');
        if(pageName == 'CaseChatSurveyMIAW'){ 
            try{
                successMessage = true;
                detailedFeedback='';
                /*string jsonStr=ApexPages.currentPage().getParameters().get('attachedRecords');
                system.debug(jsonStr +'*jsonStr');
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
                 caseid = (id)m.get('CaseId');*/
                 caseid = ApexPages.currentPage().getParameters().get('id');
                system.debug(caseid +'*caseid ');
                if(caseid != null){
                    // surveyCase =[select id,ownerid,Security_Code__c from case where id=:caseid];
                    //system.debug(surveyCase +'surveyCase * in constructor');
                    //SC-276
                         surveyCase1 = [Select Id,contactid ,Contact_Email__c,Security_Code__c, Value_Proposition__c, RecordTypeId, Origin, New_Mail__c, Liner_Brand__c, OwnerId, Priority, Care_Relationship__r.Care_Business_Partner__r.Email,closeddate,Bot_Last_Action__c,Send_Case_Closure__c,Delivery_Channel__c From Case Where Id =:caseId];
                         MessagingSession RelatedMsg = [Select Id,Proactive__c,Proactive_Feedback__c from MessagingSession where caseid =:caseId];
                       if(RelatedMsg.Proactive__c == 'Proactive'|| RelatedMsg.Proactive_Feedback__c!= Null){
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,Label.Close_Survey_MIAW));
                            successMessage = false;
                         }
                         system.debug('surveyCase1##### '+surveyCase1.contactid );
                         system.debug('surveyCase1 : ' + JSON.serialize(surveyCase1));
                         // SC-2117
                         if(surveyCase1.contactid == null ||checkInternalContactDomain(surveyCase1) || BOT_LAST_ACTION_TRANSFER_FAILED.contains(surveyCase1.Bot_Last_Action__c?.toLowerCase())){
                             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,Label.Close_Survey_MIAW));
                             successMessage = false;                            
                         }           
                     //SC-276 - END
                   
                }else{
                    system.debug('error case id is null');
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Survey timed out'));
                    successMessage = false;
                }  
                  
            }catch(exception ex){
                system.debug('error'+ex.getMessage());
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));
                successMessage = false;
            }
        }
        else{
            System.debug('##### inisde constructor');
            caseId = ApexPages.currentPage().getParameters().get('Id');          
            language = ApexPages.currentPage().getParameters().get('lang');           
            LinerBrand = ApexPages.currentPage().getParameters().get('LB');
            //SC-1249 : Maersk L&S should follow the survey page same as Maersk Line
            if(BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MAERSKLS).contains(LinerBrand) || LinerBrand == BrandUtilities.MAERSKL) {
                LinerBrand = BrandUtilities.MAERSKLINE;
            }
            linerBrandCSS = LinerBrand.replaceAll('\\s+', '').toLowerCase();                       
            feedback = ApexPages.currentPage().getParameters().get('Fb');
            securityCode = ApexPages.currentPage().getParameters().get('Sc');
            surveyComplete = false;
            //#RQ-007849
            exceptionCaught = false;
            exceptionMsg = ''; 
        }
    }

    /**
     * @description Retrieves the location where the css can be found in the system
     * @return  `String`
     */
    public String getBrandCSSLocation() {
        String tempLinerBrand = LinerBrand.escapeHtml4();
        if (twill) { tempLinerBrand = BrandUtilities.TWILL; }
        return BrandUtilities.getBrandOrSubBrandFileLocation(tempLinerBrand,'SurveyCSS');
    }

    /**
     * @description Retrieves the filename if the css is part of an archive resource
     * @return  `String`
     */
    public String getBrandCSSFileName() {
        String tempLinerBrand = LinerBrand.escapeHtml4();
        if (twill) { tempLinerBrand = BrandUtilities.TWILL; }
        return BrandUtilities.getBrandOrSubBrandFileName(tempLinerBrand,'SurveyCSS');
    }

    /**
     * @description Retrieves the location where the logo can be found in the system
     * @return  `String`
     */
    public String getBrandLogoLocation() {
        String tempLinerBrand = LinerBrand.escapeHtml4();
        if (twill) { tempLinerBrand = BrandUtilities.TWILL; }
        return BrandUtilities.getBrandOrSubBrandFileLocation(tempLinerBrand,'SurveyLogo');
    }

    /**
     * @description Retrieves the filename if the logo is part of an archive resource
     * @return  `String`
     */
    public String getBrandLogoFileName() {
        String tempLinerBrand = LinerBrand.escapeHtml4();
        if (twill) { tempLinerBrand = BrandUtilities.TWILL; }
        return BrandUtilities.getBrandOrSubBrandFileName(tempLinerBrand,'SurveyLogo');
    }

    /**
     * @description Retrieves the inline CSS values for a brand. Default is none.
     * @return  `String`
     */
    public String getBrandLogoCSS() {
        String tempLinerBrand = LinerBrand.escapeHtml4();
        if (twill) { tempLinerBrand = BrandUtilities.TWILL; }
        String inlineCSS = '';
        if (new List<String>{BrandUtilities.MAERSKLINE, BrandUtilities.SEAGO, BrandUtilities.SEALAND, 
                BrandUtilities.MCC, BrandUtilities.TWILL,BrandUtilities.HAMBURGSUD}.contains(tempLinerBrand)) {
            inlineCSS = 'vertical-align: middle; height:48px;';
        } else if (new List<String>{BrandUtilities.SAFMARINE}.contains(tempLinerBrand)) {
            inlineCSS = 'vertical-align: middle; height:32px;';
        }
        return inlineCSS;
    }
    
    //SC-276 - Set send case closure to yes for transfer failed cases
    public void setSendCaseClosureForTransferFailed(){    
        system.debug('pageName 2 : ' + pageName);  
        try  {
            // SC-2117
            if(pageName == 'CaseChatSurveyMIAW' && BOT_LAST_ACTION_TRANSFER_FAILED.contains(surveyCase1.Bot_Last_Action__c?.toLowerCase())) {
                //Calling the future method 
                CaseSurveyCtrlrMIAW.updateCaseClosure(surveyCase1.Id);
            }
        } catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,exceptionMsg));
        }
    }
    
    //If a Survey record is not available , then create a new Survey record.
    //If the Survey is taken second time for a Case, then the existing Survey gets updated.
    public void createSurvey(){
        try{
            exceptionCaught =false;
            System.debug('##### inisde createSurvey');
            List<Survey__c> svyList = [Select Id,Name, Ease_to_Resolve_Issue__c, Ease_to_Resolve_Issue_Description__c, Followed_Up_Date__c, Case_Owner_Email__c, Response_Actions__c, Follow_Up_Age_BH__c,OwnerId  From Survey__c where Case__c =:caseId limit 1];
            
            //#RQ-012315.Added Origin. Case Origin will be checked to show the Twill Logo on the Survey Page.
            //SC-276 : made surveyCase as global variable, it will be queried on constructor for chat survey page
            Case surveyCase;
            if(surveyCase1== NULL){
                surveyCase = [Select Id, Security_Code__c, Value_Proposition__c, RecordTypeId, Origin, New_Mail__c, Liner_Brand__c, OwnerId, Priority, Care_Relationship__r.Care_Business_Partner__r.Email,closeddate,Delivery_Channel__c  From Case Where Id =:caseId];               
            } else {
               surveyCase = surveyCase1;
            }
            
            //#RQ-012315. Conditions to find a twill case.
            Id externalCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('External_Case').getRecordTypeId();
            
            //SC-495:Commented since Twill cases are identified based on Delivery_Channel__c
            /*User caseOwner = [Select Id, Twill__c From User where Id =: surveyCase.OwnerId];
            
            //caseOwner.Twill__c && surveyCase.Value_Proposition__c == 'Advancement' */
            
            //SC-495:Changed the Condition to use Delivery_Channel__c           
            if(surveyCase.Delivery_Channel__c == Label.Twill && surveyCase.RecordTypeId == externalCaseRTId )
                twill = true;
            else 
                twill = false;
            
            if(surveyCase.closeddate != null){
                General_Settings__c gs =General_Settings__c.getInstance();
                if(surveyCase .closeddate.addDays(integer.valueof(gs.Case_Email_Survey_Expiry__c)) < System.today()){
                    exceptionMsg = label.CaseSurveyExpiryError;
                    exceptionCaught = true; 
                }
            }
            if(exceptionCaught != true){
                system.debug('svyList*'+svyList);
                if(svyList.size()== 0){
                    Survey__c svy = new Survey__c();
                    svy.Case__c = caseId;
                    if(pageName != 'CaseChatSurveyMIAW'){
                        svy.Case_Security_Code__c = securityCode;
                    }
                    if (feedback == null || feedback==''){
                        throw new UserException('Please select How satisfied are you');
                    }
                    svy.Ease_to_Resolve_Issue__c = Integer.ValueOf(feedback);
                    svy.Liner_Brand__c = surveyCase.Liner_Brand__c;
                    if(String.isNotBlank(surveyCase.Care_Relationship__r.Care_Business_Partner__r.Email)) {
                        svy.Case_Owner_Email__c = surveyCase.Care_Relationship__r.Care_Business_Partner__r.Email;//#RQ-007491
                    }
                    svy.RecordTypeId = Label.Survey_Case_RecordTypeId;
                    svy.OwnerId = surveyCase.OwnerId;//#RQ-007491
                    
                    if(pageName == 'CaseChatSurveyMIAW'){
                       svy.survey_Channel__c= 'Chat';
                        Datetime myDT = Datetime.now();
                        if(detailedFeedback != null && detailedFeedback != ''){ 
                            String strConvertedDate = myDT.format('dd/MM/yyyy HH:mm', 'GMT')+' UTC';           
                            svy.Ease_to_Resolve_Issue_Description__c = strConvertedDate +'\n'+detailedFeedback;
                        }      
                        svy.Case_Security_Code__c =surveyCase.Security_Code__c ;
                    }
                    else{
                        svy.survey_Channel__c= 'Email';

                    }
                    
                    insert svy;
                    
                    if(pageName == 'CaseChatSurveyMIAW'){
                         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,label.Survey_Thank_You));
                        successMessage = false;
                    }
                                   
                    surveyRec = [Select Id,Name, Ease_to_Resolve_Issue__c, Ease_to_Resolve_Issue_Description__c FROM Survey__c Where Id=:svy.Id];
                    system.debug('surveyRec *'+surveyRec );
                }
                else{
                    
                    //if(svyList[0].Ease_to_Resolve_Issue__c != Integer.ValueOf(feedback))
                    svyList[0].Ease_to_Resolve_Issue__c = Integer.ValueOf(feedback);
                    //#RQ-007491
                    if(svyList[0].Case_Owner_Email__c != surveyCase.Care_Relationship__r.Care_Business_Partner__r.Email && surveyCase.Care_Relationship__r.Care_Business_Partner__r.Email != null) {
                        svyList[0].Case_Owner_Email__c = surveyCase.Care_Relationship__r.Care_Business_Partner__r.Email;
                    }
                    //#RQ-007491 
                    if(svyList[0].OwnerId != surveyCase.OwnerId) {
                        svyList[0].OwnerId = surveyCase.OwnerId;
                    }
                    // removed for RQ-008673
                    /*if(svyList[0].Followed_Up_Date__c != null) {svyList[0].Followed_Up_Date__c = null;}*/
                    //#RQ-008548.
                    if(Integer.ValueOf(feedback) == 3 || test.isRunningTest()){
                        svyList[0].Response_Actions__c = 'None';
                        svyList[0].Followed_Up_Date__c = null;
                        svyList[0].Follow_Up_Age_BH__c = null;
                    }

                    // SC-2809 : Fix for Security Code check on update of Survey
                    if(pageName != 'CaseChatSurveyMIAW'){
                        svyList[0].Case_Security_Code__c = securityCode;
                    }
                    
                    update svyList[0];               
                    surveyRec = svyList[0];
                    
                    if(pageName == 'CaseChatSurveyMIAW'){
                         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,label.Survey_Thank_You));
                        successMessage = false;
                    }
                }  
                
                //Update the Case Priority if feedback is 3 and Response Recieved flag to true for any feedback.              
                
                if(Integer.ValueOf(feedback) == 3) {
                    surveyCase.Priority = 'High'; 
                    
                }
                if(Integer.ValueOf(feedback) !=1 ){
                    surveyCase.New_Mail__c = true; //for neutral & negative response recied flag will be set to true #RQ-008631
                }    
                TriggerExecutionController.skipCaseTrigger(true);
                update surveyCase;
                TriggerExecutionController.skipCaseTrigger(false); 
            //return null;
            }    
        }catch(Exception ex) {
            system.debug('Exception inside'+ex+'*'+ex.getstacktracestring()+'*'+ex.getmessage());
            //#RQ-007849
            exceptionCaught = true; 
            if(ex.getMessage().containsIgnoreCase('Please select How satisfied are you')  ){                
               exception1();
                
            }
            else if(ex.getMessage().containsIgnoreCase('DUPLICATE_VALUE') || ex.getMessage().containsIgnoreCase('duplicate value') ){                
               exception2();
                
            }
            else{
                exceptionMsg = Label.Survey_Default_Error_Msg; 
                if(pageName == 'CaseChatSurveyMIAW'){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,exceptionMsg));
                }
            }            
            System.debug('##### inisde exception page'+ex.getMessage());
            //Added case id to the errror logger to debug easily.
            ErrorLogger.writeErrors( 'SFDC', 'Survey', 'CaseSurveyCtrlrMIAW.createSurvey'+caseId, new list<Exception>{ex}); // #RQ-005636 
        }
        
    }
    public void exception1(){
         exceptionMsg = label.RequiredInfo+'-'+Label.Case_Closure_Survey_Request;
        if(pageName == 'CaseChatSurveyMIAW'){
            system.debug('Exception inside'+exceptionMsg);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,exceptionMsg));
        }
        
    }
    public void exception2(){
        
         exceptionMsg = Label.Survey_Unique_Error_Msg;
        if(pageName == 'CaseChatSurveyMIAW'){
            system.debug('Exception inside'+exceptionMsg);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,exceptionMsg));
        }
    }
    public void selectSmiley(){
        feedback = ApexPages.CurrentPage().getParameters().get('param1');
        system.debug('feedback *'+feedback );
    }
    
    
    //Update Survey record with the customer feedback.
    //#RQ-007487.Append the Ease to resolve issue descrption each time with a time stamp in GMT.
    public PageReference updateSurvey(){
        
        try{
            Datetime myDT = Datetime.now();
            String strConvertedDate = myDT.format('dd/MM/yyyy HH:mm', 'GMT')+' UTC';            
            if( String.isBlank(surveyRec.Ease_to_Resolve_Issue_Description__c )|| surveyRec.Ease_to_Resolve_Issue_Description__c == null) {
                surveyRec.Ease_to_Resolve_Issue_Description__c = strConvertedDate + '\n'+detailedFeedback; 
            }
            else {
                surveyRec.Ease_to_Resolve_Issue_Description__c = surveyRec.Ease_to_Resolve_Issue_Description__c+'\n\n'+strConvertedDate +'\n'+detailedFeedback;
            }            
            update surveyRec;
            surveyComplete = true;          
            return null;            
        } 
        catch(Exception ex) {            
            exceptionCaught = true; //#RQ-007849
            exceptionMsg = Label.Survey_Default_Error_Msg;
            //Added case id to the errror logger to debug easily.
            ErrorLogger.writeErrors( 'SFDC', 'Survey', 'CaseSurveyCtrlrMIAW.createSurvey'+caseId, new list<Exception>{ex}); 
            return null;
        }        
    }
    public class UserException extends Exception{}
     
    /** 
      * @description | Update Send Case Closure |
      * @param caseID accepts the Case record Id
      */
    @future 
    public static void updateCaseClosure(Id caseID) { 
        Case updCase = new Case();
        updCase.Id = caseID;
        updCase.Send_Case_Closure__c = 'Yes';
        updCase.Case_Closure_Opt_Out_Reason__c = '';
        try{
        TriggerExecutionController.skipCaseTrigger(true);
            update updCase;
            system.debug('Updted Case closure'+updCase.Send_Case_Closure__c );
        TriggerExecutionController.skipCaseTrigger(false);
        } catch(Exception ex){            
            //Log added to global error logger
            ErrorLogger.writeErrors( 'SFDC', 'Survey', 'CaseSurveyCtrlrMIAW.createSurvey'+caseId, new list<Exception>{ex});
        }
    }    
    
     /** 
      * @description | SC-6289 : Check if contact is of intrernal domain |
      * @param cs accepts the Case record      *
      */
     public boolean checkInternalContactDomain(Case cs){
        Boolean isInternalDomain = false;        
        if(cs.Contact_Email__c!=null) {        
            String domain = cs.Contact_Email__c.split('@').get(1);
            Set<String> setEmailDomains = new set<String>();
            for(Email_Domains_Excluded_From_Survey__mdt emailDomain : [Select MasterLabel From Email_Domains_Excluded_From_Survey__mdt ]) {
                setEmailDomains.add(emailDomain.MasterLabel);
            }  
            for(String str : setEmailDomains){                
                if(domain.Contains(str)){
                    isInternalDomain = true;
                }
            }
        }
        return isInternalDomain;
    }
}