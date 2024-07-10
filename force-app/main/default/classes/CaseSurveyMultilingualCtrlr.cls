/**
 * Author   : Ranjini@UST
 * Purpose  : Case Survey Page Controller.
 * 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-006949   21-Sep-2017 Ranjini@UST             Created.
 * 2.0      RQ-007487   19-Dec-2017 Ranjini@ust             Ease To Resolve description be retained.
 * 3.0      RQ-007602   19-Dec-2017 Ranjini@ust             Case Liner brand is assigned to the Survey Liner Brand.
 * 4.0      RQ-007491   05-Jan-2017 Ranjini@ust             CaseOwner is assigned as Survey Owner. Primary agent email is added to Survey Case_Owner_Email__c field.
 * 5.0      RQ-007849   07-Feb-2018 Ranjini@ust             Prevent duplicate survey records and display an error message when duplicate records created.
 * 6.0      RQ-008037   12-Mar-2018 Nisha@ust               Removed the code segment assigning null value to the Response_Actions__c field.
 * 7.0      RQ-008631   25-May-2018 Ranjini@ust             New email flag on case should not be checked for positive rating
 * 8.0      RQ-008548   12-Jun-2018 Ranjini@ust             Resetting 'Response Action' to 'None' for Survey.
 * 9.0      RQ-009647   12-dec-2018 Partha@Maersk           Updated to not auto uncheck the new email flag when a neutral survey response is received
 * 10.0     RQ-008890   30-Jan-2019 Partha@Maersk           Updated to support case chat survey page
 * 11.0     RQ-009714   19-Feb-2019 Partha@Maersk           Updated to add expiry mechanism
 * 12.0     RQ-012315   21-11-2019  Ranjini@ust             Updated to add Twill changes.
 * 13.0     SC-276      10-04-2019  Ramadevi@ust            Do not show survey for Transfer failed chats.
 * 14.0     SC-490      22-05-2020  Ramadevi@ust            Fix for Case Owner Change 
 * 15.0     SC-173      27-050-2020 Naved@maersk            Change field for was_your_case_resolved__c to survey_channel__c   
 * 16.0     SC-495      08-07-2020  ramadevi@ust            Changed the condition to identify twill cases  
 * 17.0     SC-1249     10-11-2020  Sreya@Maersk            Introducing Maersk L&S as new Brand.
 * 18.0     SC-2117     11-03-2020  Chakshu@Maersk          Updated Tranfer Failed values to prevent CSAT in failed transfer scenarios
 * 19.0     SC-2809     09-07-2021  Chakshu@Maersk          Fix for Security Code check on update of Survey
 * 20.0     SPI-100     17-06-2022  Ronnie@SF               Removed brand hardcoding
 * 21.0     SPI-100     12-07-2022  Joris@SF                Brand logos and css are now dynamically referenced from the brands cmdt config
 * 22.0     CRM0000030  13-09-2022  Ronnie@SF               Improved retrieval of recordtype info 
 * 23.0     SC-6289     14-11-2022  Richa@Maersk            Exclude Internal domain users from Chat CSAT Survey
 * 24.0     SC-7964     24-05-2023  Sandhya@Maersk          Added the condition to handle 5 smilies for Rating Agents Performance
*/

public class CaseSurveyMultilingualCtrlr {
    
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
    public string selectedLang{get;set;} //SC-1131
    public Boolean Checkbox1{get;set;}
    public Boolean Checkbox2{get;set;}
    public Boolean Checkbox3{get;set;}
    public Boolean Checkbox4{get;set;}

    private static final List<String> BOT_LAST_ACTION_TRANSFER_FAILED = Label.Transfer_Failed.toLowerCase().split(';'); //SC-2117
    
    //Constructor
    public CaseSurveyMultilingualCtrlr() {
        pageName = ApexPages.currentPage().getUrl().substringAfter('/apex/').substringBefore('?');
        if(pageName == 'CaseChatSurveyMultilingual'){
            try{
                successMessage = true;
                detailedFeedback='';
                string jsonStr=ApexPages.currentPage().getParameters().get('attachedRecords');
                system.debug(jsonStr +'*jsonStr');
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
                 caseid = (id)m.get('CaseId');
                system.debug(caseid +'*caseid ');
                if(caseid != null){
                    // surveyCase =[select id,ownerid,Security_Code__c from case where id=:caseid];
                    //system.debug(surveyCase +'surveyCase * in constructor');
                    //SC-276
                         surveyCase1 = [Select Id,contactid ,Contact_Email__c,Security_Code__c, Value_Proposition__c, RecordTypeId, Origin, New_Mail__c, Liner_Brand__c, OwnerId, Priority, Care_Relationship__r.Care_Business_Partner__r.Email,closeddate,Bot_Last_Action__c,Send_Case_Closure__c,Delivery_Channel__c From Case Where Id =:caseId];
                         LiveChatTranscript RelatedLct = [Select Id,Proactive__c,Proactive_Feedback__c,Customer_Selected_Lang__c from LiveChatTranscript where caseid =:caseId];
                    	 if(RelatedLct.Proactive__c == 'Proactive'|| RelatedLct.Proactive_Feedback__c!= Null){
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,Label.Error_Message_Transfer_Failed));
                            successMessage = false;
                         }
                    	 if(RelatedLct.Customer_Selected_Lang__c!= Null && RelatedLct.Customer_Selected_Lang__c == 'ja'){
                        	selectedLang = RelatedLct.Customer_Selected_Lang__c;
                         }else{
                             selectedLang = 'en_US';
                    	 }
                         system.debug('surveyCase1##### '+surveyCase1.contactid );
                         system.debug('surveyCase1 : ' + JSON.serialize(surveyCase1));
                         // SC-2117
                         if(surveyCase1.contactid == null ||checkInternalContactDomain(surveyCase1) || BOT_LAST_ACTION_TRANSFER_FAILED.contains(surveyCase1.Bot_Last_Action__c?.toLowerCase())){
                             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,Label.Error_Message_Transfer_Failed));
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
            if(pageName == 'CaseChatSurveyMultilingual' && BOT_LAST_ACTION_TRANSFER_FAILED.contains(surveyCase1.Bot_Last_Action__c?.toLowerCase())) {
                //Calling the future method 
                CaseSurveyMultilingualCtrlr.updateCaseClosure(surveyCase1.Id);
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
                    if(pageName != 'CaseChatSurveyMultilingual'){
                        svy.Case_Security_Code__c = securityCode;
                    }
                    if (feedback == null || feedback==''){
                        throw new UserException('Please select How satisfied are you');
                    }
                    if (pageName == 'CaseChatSurvey') {
						Integer feedbackValue = Integer.valueOf(feedback);
						if (feedbackValue == 4 || feedbackValue == 5) {
							svy.Ease_to_Resolve_Issue__c = 3;
						} else if (feedbackValue == 1 || feedbackValue == 2) {
							svy.Ease_to_Resolve_Issue__c = 1;
						} else if (feedbackValue == 3) {
							svy.Ease_to_Resolve_Issue__c = 2;
						}
					} else {
						svy.Ease_to_Resolve_Issue__c = Integer.valueOf(feedback);
					}
                    svy.Liner_Brand__c = surveyCase.Liner_Brand__c;
                    if(String.isNotBlank(surveyCase.Care_Relationship__r.Care_Business_Partner__r.Email)) {
                        svy.Case_Owner_Email__c = surveyCase.Care_Relationship__r.Care_Business_Partner__r.Email;//#RQ-007491
                    }
                    svy.RecordTypeId = Label.Survey_Case_RecordTypeId;
                    svy.OwnerId = surveyCase.OwnerId;//#RQ-007491
                    
                    if(pageName == 'CaseChatSurveyMultilingual'){
                       svy.survey_Channel__c= 'Chat';
                        String Checkvalue = '';
                        Datetime myDT = Datetime.now();
                        if(Checkbox1 == true){
                            Checkvalue = Checkvalue + Label.Case_Agent_Not_Helpful+'\n';
                        }
                        if(Checkbox2 == true){
                            Checkvalue = Checkvalue + Label.Case_Closed_Fast+'\n';
                        }
                        if(Checkbox3 == true){
                            Checkvalue = Checkvalue + Label.Case_Didn_t_like+'\n';
                        }
                        if(Checkbox4 == true){
                            Checkvalue = Checkvalue + Label.Case_Other+'\n';
                        }
                            String strConvertedDate = myDT.format('dd/MM/yyyy HH:mm', 'GMT')+' UTC';
                            svy.Ease_to_Resolve_Issue_Description__c = strConvertedDate +'\n'+Integer.valueOf(feedback)+'\n'+Checkvalue +detailedFeedback;
                        	svy.Case_Security_Code__c =surveyCase.Security_Code__c ;
                    }
                    else{
                        svy.survey_Channel__c= 'Email';

                    }
                    
                    insert svy;
                    
                    if(pageName == 'CaseChatSurveyMultilingual'){
                         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,label.Survey_End_Page));
                        successMessage = false;
                    }
                                   
                    surveyRec = [Select Id,Name, Ease_to_Resolve_Issue__c, Ease_to_Resolve_Issue_Description__c FROM Survey__c Where Id=:svy.Id];
                    system.debug('surveyRec *'+surveyRec );
                }
                else{
                    if (pageName == 'CaseChatSurvey') {
						Integer feedbackValue = Integer.valueOf(feedback);
						if (feedbackValue == 4 || feedbackValue == 5) {
							svyList[0].Ease_to_Resolve_Issue__c= 3;
						} else if (feedbackValue == 1 || feedbackValue == 2) {
							svyList[0].Ease_to_Resolve_Issue__c = 1;
						} else if (feedbackValue == 3) {
							svyList[0].Ease_to_Resolve_Issue__c = 2;
						}
					} else {
						svyList[0].Ease_to_Resolve_Issue__c = Integer.valueOf(feedback);
					}
                    //if(svyList[0].Ease_to_Resolve_Issue__c != Integer.ValueOf(feedback))
                    //svyList[0].Ease_to_Resolve_Issue__c = Integer.ValueOf(feedback);
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
                    if(pageName != 'CaseChatSurveyMultilingual'){
                        svyList[0].Case_Security_Code__c = securityCode;
                    }
                    
                    update svyList[0];               
                    surveyRec = svyList[0];
                    
                    if(pageName == 'CaseChatSurveyMultilingual'){
                         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,label.Survey_End_Page));
                        successMessage = false;
                    }
                }  
                
                //Update the Case Priority if feedback is 3 and Response Recieved flag to true for any feedback.              
                
                if(Integer.ValueOf(feedback) == 3 && pageName != 'CaseChatSurvey') {
                    surveyCase.Priority = 'High';
                }
                else if((Integer.ValueOf(feedback) == 4 || Integer.ValueOf(feedback) == 5) &&  pageName == 'CaseChatSurvey'){
                    surveyCase.Priority = 'High';
                }
                if((Integer.ValueOf(feedback) !=1 )&&  pageName != 'CaseChatSurvey' ){
                    surveyCase.New_Mail__c = true; //for neutral & negative response recied flag will be set to true #RQ-008631
                }  
                else if((Integer.ValueOf(feedback) !=1 || Integer.ValueOf(feedback) !=2) &&  pageName == 'CaseChatSurvey'){
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
                if(pageName == 'CaseChatSurveyMultilingual'){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,exceptionMsg));
                }
            }            
            System.debug('##### inisde exception page'+ex.getMessage());
            //Added case id to the errror logger to debug easily.
            ErrorLogger.writeErrors( 'SFDC', 'Survey', 'CaseSurveyMultilingualCtrlr.createSurvey'+caseId, new list<Exception>{ex}); // #RQ-005636 
        }
        
    }
    public void exception1(){
         exceptionMsg = label.RequiredInfo+'-'+Label.Case_Closure_Survey_Request;
        if(pageName == 'CaseChatSurveyMultilingual'){
            system.debug('Exception inside'+exceptionMsg);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,exceptionMsg));
        }
        
    }
    public void exception2(){
        
         exceptionMsg = Label.Survey_Unique_Error_Msg;
        if(pageName == 'CaseChatSurveyMultilingual'){
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
            ErrorLogger.writeErrors( 'SFDC', 'Survey', 'CaseSurveyMultilingualCtrlr.createSurvey'+caseId, new list<Exception>{ex}); 
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
            ErrorLogger.writeErrors( 'SFDC', 'Survey', 'CaseSurveyMultilingualCtrlr.createSurvey'+caseId, new list<Exception>{ex});
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