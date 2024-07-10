/*
* Author   : Sreya@Maersk
* Purpose  : Handle the Update of the Parent Dispute Case on closure of all the child dispute cases. 
*            And handle the validation error on Parent Dispute case closure, if all the child cases are not closed.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-007915   31-Oct-2018 Sreya@Maersk            Handle the Update of the Parent Dispute Case on closure of all the child dispute cases.And handle the validation error on Parent Dispute case closure if all the child cases are not closed.
* 2.0      RQ-009662   05-12-2018  Sreya@Maersk            Auto Closure of Parent Dispute Cases enabled only for Bulk Dispuite Parent Case
* 3.0      SC-160      02-04-2020  Ramadevi@ust            Implemented Trigger recurrsion for methods.
* 4.0      SC-5392     11-07-2022  Richa@Maersk            Send Missing information mail to customer method
* 5.0      SC-6080     05-09-2022  Nayana@Maersk           Missing Information Notification to Customers - No Case Country
* 6.0      SC-6018     08-09-2022  Raksha@maersk           Missing Information Notification to Customers (Payer)
* 7.0      SC-3706     22-09-2022  Nayana@Maersk           Acceptance notification to the customer on Dispute resolution
*/

public class DisputeCaseClosureHelper {
    
    public static set<String> setCaseClosedStatuses = new set<String>();
    
    //RQ-007915: Handle the validation error on Parent Dispute case closure if all the child cases are not closed.
    public static void validateParentDISPCaseClosure(Map<Id,Case> mapNewCase){ 
        //SC-160 : Trigger Recurrsion controller
        if(Generic_TriggerHandler.validateRunForMethod('DisputeCaseClosureHelper.validateParentDISPCaseClosure()', 1)){
            // Get the closed statuses (because at the point of this trigger Case.IsClosed won't be set yet)...
            for(CaseStatus status : CaseTrigger_DataSetUtilities.getCaseStatusList()) {
                setCaseClosedStatuses.add(status.MasterLabel);
            }
            
            List<Case> parentToChildCases = [select Id,status,(select Id,status,RecordType.DeveloperName from Cases where status NOT IN: setCaseClosedStatuses  AND RecordType.DeveloperName = 'Dispute') from Case where Id in : mapNewCase.keyset()];
            
            for(Case cs : parentToChildCases){
                if(cs.cases.size()>0){  
                    Case actualCase = mapNewCase.get(cs.Id);
                    actualCase.addError('You cannot close a parent dispute case until all child dispute cases are closed. Parent cases are automatically closed once all child cases are resolved.');
                }         
            }  
        }      
    }
    
    //RQ-007915: Handle the Update of the Parent Dispute Case on closure of all the child dispute cases.
    public static void updateParentDISPCaseStatus(Set<String> lstDISPCaseIDs){
        //SC-160 : Trigger Recurrsion controller
        if(Generic_TriggerHandler.validateRunForMethod('DisputeCaseClosureHelper.updateParentDISPCaseStatus()', 1)){
            set<Id> parentCaseIds = new set<Id>();
            List<Case> casesToUpdate = new List<Case>(); 
            
            List<Case> lstChildCases = [select Id,ParentId from Case where Id in:lstDISPCaseIDs];
            try{
                for(Case newCase : lstChildCases){          
                    parentCaseIds.add(newCase.ParentId);                  
                }
                //RQ-009662 : Query all the Bulk Dispute Parent Cases
                List<Case> parentToChildCases = [select Id,(select Id,status, RecordType.DeveloperName from Cases where status != 'Closed - Resolved' AND RecordType.DeveloperName = 'Dispute'),
                                                 status from Case where Id in : parentCaseIds AND RecordType.DeveloperName = 'Dispute' AND Bulk_Dispute__c = 'True'];
                
                for(Case cs : parentToChildCases){
                    if(cs.cases.isEmpty()){
                        cs.Status = 'Closed - Resolved';
                        casesToUpdate.add(cs);
                    }         
                }
                if(casesToUpdate.size()>0){
                    //update casesToUpdate;
                    Database.SaveResult[] srList = Database.update(casesToUpdate, false);
                    ErrorLogger.writeErrors( 'SFDC', 'Case', 'DisputeCaseClosureHelper.updateParentDISPCaseStatus(set<string> lstDISPCaseIDs)',srList,casesToUpdate ); 
                    
                }  
            }
            catch(Exception ex){
                system.debug('Exception'+ex);
                ErrorLogger.writeErrors( 'SFDC', 'Case', 'DisputeCaseClosureHelper.updateParentDISPCaseStatus(set<string> lstDISPCaseIDs)', new list<Exception>{ex}); 
            }
        }
    }    
 
    /** 
    * @description | SC-5392 Missing Information Notification to Customers |
    * @param caseInput accepts Case Record     
    */ 
    public class caseInput{
        @InvocableVariable(label='caseId')
        public String caseId;
        @InvocableVariable(label='caseLanguage')
        public String caseLanguage;
        @InvocableVariable(label='triggerCondition')
        public String triggerCondition;
        @InvocableVariable(label='contactId')
        public String contactId; 
        @InvocableVariable(label='brand')
        public String brand; 
        @InvocableVariable(label='direction')
        public String direction;
        @InvocableVariable(label='country')
        public String country;
        @InvocableVariable(label='webEmail')
        public String webEmail;
        @InvocableVariable(label='CaseNumber')
        public String CaseNumber;
        @InvocableVariable(label='Subject')
        public String Subject;
        @InvocableVariable(label='ThreadId')
        public String ThreadId;
    }
    
    /** 
    * @description | SC-5392 Missing Information Notification to Customers |
    * @param lstCaseInput accepts Case Records     
    */ 
    @InvocableMethod(label='Send Missing Information Email')
    public static void sendMissingInformationEmail(list<caseInput> lstCaseInput){
        try{
            List<Messaging.SingleEmailMessage> lstEmailMessages = new List<Messaging.SingleEmailMessage>(); 
            Map<String,String> mapGenKeyValueMetaData = new Map<String,String>();
            Map<String,String> mapDispBA = new Map<String,String>();
            Map<String,String> mapGenKeyValuePayerMetaData = new Map<String,String>();
            Map<String,String> mapAcceptanceMetaData = new Map<String,String>();
            Map<string,string> mapReplyTo= new Map<string,string>();
            Map<string,EmailTemplate> mapTemplate= new Map<string,EmailTemplate>();  
            for(General_Key_Value_Configurations__mdt mdt : [SELECT Id,First_Field_Name__c,First_Field_Value__c,Second_Field_Name__c,Second_Field_Value__c,Key__c FROM General_Key_Value_Configurations__mdt WHERE Key__c IN ('DisputeEmailTriggerCondition','DisputeBA','PayerEmailTriggerCondition','AcceptanceEmailTriggerCondition')]){
                if(mdt.Key__c == 'DisputeEmailTriggerCondition'){
                    mapGenKeyValueMetaData.put(mdt.First_Field_Name__c+mdt.Second_Field_Value__c,mdt.First_Field_Value__c); 
                }
                if(mdt.Key__c == 'DisputeBA'){
                    mapDispBA.put(mdt.First_Field_Name__c,mdt.First_Field_Value__c);    
                }
                if(mdt.Key__c == 'PayerEmailTriggerCondition'){
                    mapGenKeyValuePayerMetaData.put(mdt.First_Field_Name__c+mdt.Second_Field_Value__c,mdt.First_Field_Value__c); 
                }
                if(mdt.Key__c == 'AcceptanceEmailTriggerCondition'){
                    mapAcceptanceMetaData.put(mdt.First_Field_Name__c,mdt.First_Field_Value__c); 
                }                
            }
            
            Map<String, Org_Wide_Email_Address__mdt> mapLinerBrandOrgId = new Map<String, Org_Wide_Email_Address__mdt> ();
            for(Org_Wide_Email_Address__mdt orgId : [Select DeveloperName, MasterLabel, Email_Address__c, Email_Address_Id__c From Org_Wide_Email_Address__mdt ]) {
                mapLinerBrandOrgId.put(orgId.MasterLabel,orgId);
            }
                      
            if(!lstCaseInput.isEmpty()){
                system.debug('lstCaseInput@@'+lstCaseInput);
                for(caseInput cs : lstCaseInput){
                    if(!mapGenKeyValueMetaData.isEmpty() && cs.triggerCondition!='Payer' && cs.triggerCondition!='Acceptance'){
                    if(mapGenKeyValueMetaData.containsKey(cs.triggerCondition+cs.caseLanguage) || mapGenKeyValueMetaData.containsKey(cs.triggerCondition+'en_US')){
                        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
                        if(mapGenKeyValueMetaData.containsKey(cs.triggerCondition+cs.caseLanguage)){
                            emailMessage.setTemplateId(mapGenKeyValueMetaData.get(cs.triggerCondition+cs.caseLanguage));
                        }else{
                            emailMessage.setTemplateId(mapGenKeyValueMetaData.get(cs.triggerCondition+'en_US'));
                        }
                        if(String.isNotBlank(cs.contactId)){
                            emailMessage.setTargetObjectId(cs.contactId);
                        }
                        else{
                            emailMessage = Messaging.renderStoredEmailTemplate(mapGenKeyValueMetaData.get(cs.triggerCondition+'en_US'), UserInfo.getUserId(), cs.caseId); 
                            emailMessage.setTargetObjectId(UserInfo.getUserId());
                            emailMessage.setTreatTargetObjectAsRecipient(false);
                            emailMessage.setToAddresses(new List<String> {cs.webEmail});
                        }                        
                        emailMessage.setWhatId(cs.caseId); 
                        emailMessage.setUseSignature(false);                   
                        emailMessage.setOrgWideEmailAddressId(mapLinerBrandOrgId.get(cs.brand).Email_Address_Id__c);
                        emailMessage.setReplyTo(mapDispBA.get(cs.brand));                    
                        lstEmailMessages.add(emailMessage);
                    }
                }
                    //SC-6018 - Missing Information Email Notification to Customers for Payer Dispute           
                    if(!mapGenKeyValuePayerMetaData.isEmpty() && cs.triggerCondition=='Payer'){
                        for(LinerBrand_Direction_and_Country__mdt lbdc : [Select id,Liner_Brand__c, Direction__c,Country_Name__c, Reply_To_Email__c From LinerBrand_Direction_and_Country__mdt ]) {
                            mapReplyTo.put(lbdc.Liner_Brand__c + '-' + lbdc.Direction__c + '-' + lbdc.Country_Name__c, lbdc.Reply_To_Email__c); 
                        }
                        
                        for(EmailTemplate template: [select id,HTMLValue,subject,Markup,DeveloperName from EmailTemplate where DeveloperName like 'Payer_Invoice%']){
                            mapTemplate.put(template.id,template);
                        }                
                        if(mapGenKeyValuePayerMetaData.containsKey(cs.triggerCondition+cs.caseLanguage) || mapGenKeyValuePayerMetaData.containsKey(cs.triggerCondition+'en_US')){
                            Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
                            if(mapGenKeyValuePayerMetaData.containsKey(cs.triggerCondition+cs.caseLanguage)){
                                emailMsg.setTemplateId(mapGenKeyValuePayerMetaData.get(cs.triggerCondition+cs.caseLanguage));
                            }else{
                                emailMsg.setTemplateId(mapGenKeyValuePayerMetaData.get(cs.triggerCondition+'en_US'));
                            }
                            emailMsg.setTargetObjectId(cs.contactId);
                            emailMsg.setWhatId(cs.caseId);
                            emailMsg.setUseSignature(false);                   
                            emailMsg.setOrgWideEmailAddressId(mapLinerBrandOrgId.get(cs.brand).Email_Address_Id__c);
                            if(mapReplyTo.Containskey(cs.brand + '-' + cs.direction + '-' + cs.country)){
                                emailMsg.setReplyTo(mapReplyTo.get(cs.brand + '-' + cs.direction + '-' + cs.country));
                                if(mapGenKeyValuePayerMetaData.containsKey(cs.triggerCondition+cs.caseLanguage)){ 
                                    cs.caseLanguage= cs.caseLanguage;
                                }else{
                                    cs.caseLanguage = 'en_US';
                                }
                                EmailTemplate template = mapTemplate.get(mapGenKeyValuePayerMetaData.get(cs.triggerCondition+cs.caseLanguage));                                
                                String htmlBody= template.Markup;
                                htmlBody = htmlBody.replace('{!relatedTo.CaseNumber}', cs.CaseNumber);
                                htmlBody = htmlBody.replace('{!relatedTo.Subject}', cs.Subject);
                                htmlBody = htmlBody.replace('{!relatedTo.Dispute_Email_Dynamic_Info__c}', mapReplyTo.get(cs.brand + '-' + cs.direction + '-' + cs.country));
                                htmlBody = htmlBody.replace('{!relatedTo.ThreadId__c}', cs.ThreadId);                           
                            

                                emailMsg.setHTMLBody(htmlBody);
                                String sub= template.subject;
                                sub= sub.replace('{!relatedTo.CaseNumber}', cs.CaseNumber);
                                sub= sub.replace('{!relatedTo.Subject}', cs.Subject);
                                sub= sub.replace('{!relatedTo.ThreadId__c}', cs.ThreadId);           
                                emailMsg.setSubject(sub);
                                system.debug('subject@@'+sub + 'htmlBody@@' + htmlBody);
                            }  
                            system.debug('emailMsg@@'+emailMsg);             
                            lstEmailMessages.add(emailMsg);
                        }                
                    }   
                    
                    //SC-3706 - Acceptance notification to the customer on Dispute resolution           
                    if(!mapAcceptanceMetaData.isEmpty() && cs.triggerCondition=='Acceptance'){                 
                        if(mapAcceptanceMetaData.containsKey(cs.triggerCondition)){   
                            Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
                            if(mapAcceptanceMetaData.containsKey(cs.triggerCondition)){                                                
                                emailMsg.setTemplateId(mapAcceptanceMetaData.get(cs.triggerCondition));                        
                            }
                            if(String.isNotBlank(cs.contactId)){
                                emailMsg.setTargetObjectId(cs.contactId);
                            }
                            else{
                                emailMsg = Messaging.renderStoredEmailTemplate(mapAcceptanceMetaData.get(cs.triggerCondition), UserInfo.getUserId(), cs.caseId); 
                                emailMsg.setTargetObjectId(UserInfo.getUserId());
                                emailMsg.setTreatTargetObjectAsRecipient(false);
                                emailMsg.setToAddresses(new List<String> {cs.webEmail});
                            }                    
                            emailMsg.setWhatId(cs.caseId);
                            emailMsg.setUseSignature(false);                   
                            emailMsg.setOrgWideEmailAddressId(mapLinerBrandOrgId.get(cs.brand).Email_Address_Id__c);
                            emailMsg.setReplyTo(mapDispBA.get(cs.brand));               
                            lstEmailMessages.add(emailMsg);                        
                        }
                    }
                }
            }
            
            if(!lstEmailMessages.isEmpty()) {                
                List<Messaging.SendEmailResult> lstEmailResults = Messaging.sendEmail(lstEmailMessages);
                for(Integer i=0; i<lstEmailResults.size(); i++) {                   
                    Messaging.SendEmailResult emailResult = lstEmailResults[i];
                    if(!emailResult.isSuccess()) {                      
                        ErrorLogger.writeError( 'SFDC', 'Case', 'DisputeCaseClosureHelper.sendMissingInformationEmail','Email notification error',JSON.serialize(emailResult.getErrors()),JSON.serialize(lstCaseInput)); 
                        break;  
                    }
                }
            }
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'DisputeCaseClosureHelper.sendMissingInformationEmail', new list<Exception>{ex});
        }        
    }    
}