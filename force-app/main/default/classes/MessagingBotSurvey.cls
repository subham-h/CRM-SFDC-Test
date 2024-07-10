Public Class MessagingBotSurvey{
    public  class inputs{        
        @InvocableVariable
        public String Action;        

        @InvocableVariable
        public String brand;
        
        @InvocableVariable
        public String caseId; 
        
        @InvocableVariable
        public String msgId;   
        
        @InvocableVariable
        public String language;
    }
    
    public class outputs{
        @InvocableVariable
        public String showSurvey;
        
        @InvocableVariable
        public String errOccured;
    }
    
    @InvocableMethod(label='checkSurveyAction')
    public static List<outputs> checkSurveyAction(List<inputs> msgInputs){
        if(msgInputs[0].Action== 'CaseChatSurveyMIAW'){
            return MessagingBotSurvey.checkforSurvey(msgInputs);
        } else {
            system.debug('In else part');
            return null;
        }
        //return null;
    }
    
    
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
    
    public static boolean checkInternalContactDomain(Case cs){
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
    
    public Static  List<outputs> checkforSurvey(List<inputs> msgInputs) {
        List<String> BOT_LAST_ACTION_TRANSFER_FAILED = Label.Transfer_Failed.toLowerCase().split(';');
        String successMessage = 'True';
        Boolean surveyComplete;
        Boolean exceptionCaught;
        String exceptionMsg;
        String detailedFeedback;
        //Id caseid;
        Case surveyCase1;
        string LinerBrand;
        String securityCode;
        string language=msgInputs[0].language;
        String pageName = msgInputs[0].Action;
        String casenumber= msgInputs[0].caseId; 
        Id caseid;
        system.debug(casenumber+'*casenumber');
        if(pageName == 'CaseChatSurveyMIAW'){
            try{           
                MessagingSession RelatedMsg;     
                detailedFeedback='';      
                if(msgInputs[0].msgId <> null && msgInputs[0].msgId<> '') {
                    RelatedMsg = [Select Id,Proactive__c,Proactive_Feedback__c,caseid from MessagingSession where id=:msgInputs[0].msgId];
                    if(RelatedMsg <> NULL && RelatedMsg.caseId <> NULL){
                    caseid = RelatedMsg.caseId;
                    }
                }         
                
                system.debug('caseid ---'+caseid );
                system.debug('RelatedMsg  ---'+RelatedMsg );
                if(caseid != null){                   
                         surveyCase1 = [Select Id,contactid ,Contact_Email__c,Security_Code__c, Value_Proposition__c, RecordTypeId, Origin, New_Mail__c, Liner_Brand__c, OwnerId, Priority, Care_Relationship__r.Care_Business_Partner__r.Email,closeddate,Bot_Last_Action__c,Send_Case_Closure__c,Delivery_Channel__c From Case Where id=:caseId];
                        
                         system.debug('surveyCase1##### '+surveyCase1.contactid );
                         system.debug('surveyCase1 : ' + JSON.serialize(surveyCase1));
                         Boolean IsInternalContact;
                         if(surveyCase1 <> NULL) {
                         IsInternalContact = MessagingBotSurvey.checkInternalContactDomain(surveyCase1);
                             if(surveyCase1.contactid == null ||MessagingBotSurvey.checkInternalContactDomain(surveyCase1) || BOT_LAST_ACTION_TRANSFER_FAILED.contains(surveyCase1.Bot_Last_Action__c?.toLowerCase())){
                                 //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,Label.Close_Survey_MIAW));
                                 exceptionMsg= 'Thank you for chatting with us.';
                                 successMessage = 'False';                            
                             }
                         }         
                }else{
                    system.debug('error case id is null');
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Survey timed out'));
                    exceptionMsg = 'Survey timed out';
                    successMessage = 'False';
                }  
                  
            }catch(exception ex){
                system.debug('error'+ex.getMessage());
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));
                exceptionMsg = ex.getMessage();
                successMessage = 'False';
            }
        }
         if(pageName == 'CaseChatSurveyMIAW' && surveyCase1<> NULL && BOT_LAST_ACTION_TRANSFER_FAILED.contains(surveyCase1.Bot_Last_Action__c?.toLowerCase())) {
            //Calling the future method 
            MessagingBotSurvey.updateCaseClosure(surveyCase1.Id);
        }
        List<outputs> opList = new List<outputs>();
        outputs res = new outputs();
        res.showSurvey = successMessage;
        res.errOccured = exceptionMsg;
        opList.add(res);
        system.debug('opList--'+opList);
        return opList;
            
    }
}