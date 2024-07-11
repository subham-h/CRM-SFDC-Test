/*
Description  : This Class is designed to launch a autolaunchflow when flow is executed on accepting a Recommendation

* version       Date                Owner                                       Description
*******************************************************************************************************************
* V1.0           23/09/2021         sunil.bs@maersk.com                         Update RFC on case with container tracking template
* V2.0           28/03/2022         a.gabale@maersk.com                         SC-4590 : Creation/Modifications of the NBA Templates for Sealand and Maersk Brand
*-------------------------------------------------------------------------------------------------------------------
*/


Global with sharing class CaseRunNBAAction{
   
    public class caseinput{
        @InvocableVariable(label='Case ID')
        public String caseId;
        
        @InvocableVariable(label='Recommendation Name')
        public String recommendationName;
    }
    
    @InvocableMethod(label='Get CaseRunNBAAction')
    public static void GetCaseRunNBAAction(list<caseinput> inputrequests){
        
        
        try{
            String emailTemplateName;
            EmailTemplate emailTemplate = new EmailTemplate();
            
            Case casetoupdate = [select id,Liner_Brand__c,Case_Country__c,Case_Cluster__c,Region__r.Name,contactid,resolution_summary__c,closure_language_code__c from case where id =: inputrequests[0].caseId];
            
            Map<String,NBA_Email_Template_Mapping__mdt> mapNBATemplateMapping = new Map<String,NBA_Email_Template_Mapping__mdt>();
                        
            For(NBA_Email_Template_Mapping__mdt nbaMapping : [SELECT Brand__c,Cluster__c,Country__c,Region__c,Is_Salesforce_Supported_Language__c,Email_Template_Unique_Name__c from NBA_Email_Template_Mapping__mdt where Recommendation__c =: inputrequests[0].recommendationName AND Is_Resolution_Summary_Template__c = true]){
                if(nbaMapping != NULL){
                    
                    mapNBATemplateMapping.put((nbaMapping.Brand__c != NULL ? nbaMapping.Brand__c : '') + (nbaMapping.Region__c != NULL ? nbaMapping.Region__c : '') + 
                                              (nbaMapping.Cluster__c != NULL ? nbaMapping.Cluster__c : '') + (nbaMapping.Country__c != NULL ? nbaMapping.Country__c : ''),
                                              nbaMapping);
                }
            }
           
            if(!mapNBATemplateMapping.isEmpty()){
                if(mapNBATemplateMapping.containsKey((casetoupdate.Liner_Brand__c != NULL ? casetoupdate.Liner_Brand__c : '') + (casetoupdate.Region__c != NULL ? casetoupdate.Region__r.Name : '') + 
                                                    (casetoupdate.Case_Cluster__c != NULL ? casetoupdate.Case_Cluster__c : '') + (casetoupdate.Case_Country__c != NULL ? casetoupdate.Case_Country__c : ''))){
                                                        
                    emailTemplateName = mapNBATemplateMapping.get((casetoupdate.Liner_Brand__c != NULL ? casetoupdate.Liner_Brand__c : '') + (casetoupdate.Region__c != NULL ? casetoupdate.Region__r.Name : '') + 
                                                                 (casetoupdate.Case_Cluster__c != NULL ? casetoupdate.Case_Cluster__c : '') + (casetoupdate.Case_Country__c != NULL ? casetoupdate.Case_Country__c : '')).Email_Template_Unique_Name__c;
                }
                else if(mapNBATemplateMapping.containsKey((casetoupdate.Liner_Brand__c != NULL ? casetoupdate.Liner_Brand__c : '') + (casetoupdate.Region__c != NULL ? casetoupdate.Region__r.Name : '') + 
                                                    (casetoupdate.Case_Cluster__c != NULL ? casetoupdate.Case_Cluster__c : ''))){
                                                        
                    emailTemplateName = mapNBATemplateMapping.get((casetoupdate.Liner_Brand__c != NULL ? casetoupdate.Liner_Brand__c : '') + (casetoupdate.Region__c != NULL ? casetoupdate.Region__r.Name : '') + 
                                                                 (casetoupdate.Case_Cluster__c != NULL ? casetoupdate.Case_Cluster__c : '')).Email_Template_Unique_Name__c;
                }
                else if(mapNBATemplateMapping.containsKey((casetoupdate.Liner_Brand__c != NULL ? casetoupdate.Liner_Brand__c : '') + (casetoupdate.Region__c != NULL ? casetoupdate.Region__r.Name : '') + 
                                                    (casetoupdate.Case_Country__c != NULL ? casetoupdate.Case_Country__c : ''))){
                                                        
                    emailTemplateName = mapNBATemplateMapping.get((casetoupdate.Liner_Brand__c != NULL ? casetoupdate.Liner_Brand__c : '') + (casetoupdate.Region__c != NULL ? casetoupdate.Region__r.Name : '') + 
                                                                 (casetoupdate.Case_Country__c != NULL ? casetoupdate.Case_Country__c : '')).Email_Template_Unique_Name__c;
                }
                else if(mapNBATemplateMapping.containsKey((casetoupdate.Liner_Brand__c != NULL ? casetoupdate.Liner_Brand__c : '') + (casetoupdate.Region__c != NULL ? casetoupdate.Region__r.Name : ''))){
                    
                    emailTemplateName = mapNBATemplateMapping.get((casetoupdate.Liner_Brand__c != NULL ? casetoupdate.Liner_Brand__c : '') + (casetoupdate.Region__c != NULL ? casetoupdate.Region__r.Name : '')).Email_Template_Unique_Name__c;
                }
                else if(mapNBATemplateMapping.containsKey((casetoupdate.Liner_Brand__c != NULL ? casetoupdate.Liner_Brand__c : '') + (casetoupdate.Case_Country__c != NULL ? casetoupdate.Case_Country__c : ''))){
                    
                    emailTemplateName = mapNBATemplateMapping.get((casetoupdate.Liner_Brand__c != NULL ? casetoupdate.Liner_Brand__c : '') + (casetoupdate.Case_Country__c != NULL ? casetoupdate.Case_Country__c : '')).Email_Template_Unique_Name__c;
                }
                else if(mapNBATemplateMapping.containsKey(casetoupdate.Liner_Brand__c != NULL ? casetoupdate.Liner_Brand__c : '')){

                    emailTemplateName = mapNBATemplateMapping.get((casetoupdate.Liner_Brand__c != NULL ? casetoupdate.Liner_Brand__c : '')).Email_Template_Unique_Name__c;
                }
            }
            
            system.debug('emailTemplateName :'+emailTemplateName);
            if(emailTemplateName != NULL){
                emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName =: emailTemplateName];
            }
            else{
                emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName =: Label.Case_NBA_Resolution_Summary_Template_Id];
            }
            
            system.debug('emailTemplate=------>'+emailTemplate);
            
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplate.Id, casetoupdate.contactid, casetoupdate.Id);
            
            String withoutstripedHTMLbody = email.gethtmlBody();
            String stripedHTMLbody = withoutstripedHTMLbody.stripHtmlTags();
            stripedHTMLbody = stripedHTMLbody.trim();
            system.debug('stripedHTMLbody------->'+stripedHTMLbody);
            
            if (casetoupdate.resolution_summary__c == null){
                casetoupdate.resolution_summary__c = stripedHTMLbody;                 
            }
            else if(casetoupdate.resolution_summary__c != null && String.ValueOf(casetoupdate.resolution_summary__c) != stripedHTMLbody){
                casetoupdate.resolution_summary__c = stripedHTMLbody+'\n\n'+casetoupdate.resolution_summary__c;
            }
            //bypassing case trigger for resolution summary updates.
			TriggerExecutionController.skipCaseTrigger(true);  

			update casetoupdate;

			TriggerExecutionController.skipCaseTrigger(false); 
            
        }catch(Exception ex){
              ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseRunNBAAction.GetCaseRunNBAAction', new list<Exception>{ex});
        }
        
    }
    
}