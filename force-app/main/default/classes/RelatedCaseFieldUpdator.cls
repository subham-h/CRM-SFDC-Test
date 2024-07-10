/*
* Author   : Ragu
* Purpose  : Utility class to hold simple and reusable functionalities for auto updating Case fields. 
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-2143   24-Mar-2202   Manohar@maersk        Created and optimized for moving email workflows to email triggers
* 2.0      RQ-2138   19-Apr-2021   Sunilbs@maersk        To update RRF of the current case's(incoming mail parentcase) parent and child case when inbound/outbound mail is received
* 3.0      SC-2183   27-Apr-2021   Richa@maersk          Added condition to identify Dispute Cases with incoming emails for OHP Workflow
* 4.0      SC-2492     20-May-2021  ramadevi@ust         update Business hours fields after the status is updated upon closure
* 5.0 	   SC-5744     19-10-2022   Vivek@Maersk		 Added filter to prevent integration call from Maersk LnS brand for Dispute cases                      
* 6.0      SC-9942   17-Apr-2024   Shahanawaz@Maersk     SCM (Internal & Customer) Email Communication
*/

public class RelatedCaseFieldUpdator {
    
    public Static void updateCaseFields(EmailRecordSelector emailRecSelector){
        set<Id> caseId = new Set<Id>();
        Map<Id,Id> caseEmailMap=new Map<Id,Id>();
        Map<Id,Case> caseMap=new Map<Id,Case>();
        List<EmailMessage> emails=new List<EmailMessage>();
        emails=emailRecSelector.emailRecords;
        caseEmailMap=emailRecSelector.emailCaseIdMap;
        caseMap=emailRecSelector.mapRelatedCases;
        Map<Id, Case> parentCaseMap = new Map<Id, Case>();
        Id externalCaseRTId = Label.External_Case_RT_Id;
        Map<Id, Case> caseMapToUpdate = new Map<Id, Case>();
        
        //SC-2183
        Id disputeRTId = Label.Dispute_Case_RT_Id;
        Map<Id,EventTypeWrapper> mapCasesToPublish = new Map<Id,EventTypeWrapper>(); //SC-9978
        //SC-2492 : to get the old values of the case
        Map<Id,Case> OldCaseMap = emailRecSelector.oldCaseValue ;
        General_Key_Value_Configurations__mdt regionValues = General_Key_Value_Configurations__mdt.getInstance('IDARegionFieldCriteriaEmailRecommendatio'); //SC-9154
        List<EmailMessage> emailMsgList = new List<EmailMessage>();
        Set<String> fromAddList = new Set<String>();
        Map<String, Custom_Email_Service__c> fromAddToCustEmailServiceMap = new Map<String, Custom_Email_Service__c>();
        
        try{
            Batch_EmailMessage_Archiver_Config__c be=Batch_EmailMessage_Archiver_Config__c.getOrgDefaults();
            for(EmailMessage email:emails){
                if(caseMap.containsKey(caseEmailMap.get(email.Id))){
                    Case caseToUpdate=caseMap.get(caseEmailMap.get(email.Id));
                    //SC-6683 update response flag as false for outgoing mail
                    if(!email.Incoming && !String.isBlank(email.FromAddress) && !String.isBlank(email.ToAddress) && caseToUpdate.New_Mail__c ){
                        caseToUpdate.New_Mail__c=false;
                    }
                    
                    //UTL: Case Priority to Low and CC Flag to TRUE on CRE
                    if(email.Incoming
                       &&
                       (
                           !String.isBlank(email.FromAddress)
                           &&
                           (email.FromAddress.contains('@maersk.com')||email.FromAddress.contains('@mcc.com.sg')||email.FromAddress.contains('@seagoline.com')||email.FromAddress.contains('@sealand.com')||email.FromAddress.contains('@sealandmaersk.com'))
                       )
                       &&
                       (
                           !String.isBlank(email.CcAddress)&&                           
                           (email.CcAddress.contains('@maersk.com')||email.CcAddress.contains('@mcc.com.sg')||email.CcAddress.contains('@seagoline.com')||email.CcAddress.contains('@sealand.com')||email.CcAddress.contains('@sealandmaersk.com')) && 
                           (email.CcAddress.contains('import')||email.CcAddress.contains('export')||email.CcAddress.contains('support')||email.CcAddress.contains('customerservice'))
                       )
                       &&
                       !(
                           !String.isBlank(email.ToAddress) 
                           &&
                           (
                               (email.ToAddress.contains('@maersk.com')||email.ToAddress.contains('@mcc.com.sg')||email.ToAddress.contains('@seagoline.com')||email.ToAddress.contains('@sealand.com')||email.ToAddress.contains('@sealandmaersk.com'))
                               &&
                               (email.ToAddress.contains('import')||email.ToAddress.contains('export')||email.ToAddress.contains('support')||email.ToAddress.contains('customerservice'))
                           )
                       )
                       &&
                       !(email.Subject.contains('ref:_'))
                       &&
                       ((((System.now().getTime()-caseToUpdate.createdDate.getTime())/1000)/60)<1)
                       &&
                       !(be.Active__c)){
                           caseToUpdate.CC_Flag__c=true;
                           caseToUpdate.Priority='Low';
                       }
                    //Increment Inbound email from contact count
                    
                    if((email.Incoming && !String.isBlank(caseToUpdate.Contact.Email) && email.FromAddress==caseToUpdate.Contact.Email)&& !(be.Active__c)){
                        caseToUpdate.Count_Emails_From_Contact__c+=1; 
                    }
                    
                    //Case Internal Email counter
                    
                    if(!email.Incoming
                       &&
                       (!string.isBlank(email.ToAddress) 
                        &&                        
                        (email.ToAddress.contains('@maersk.com')||email.ToAddress.contains('@mcc.com.sg')||email.ToAddress.contains('@seagoline.com')||email.ToAddress.contains('@sealand.com')||email.ToAddress.contains('@sealandmaersk.com'))
                       )
                       ||
                       (!String.isBlank(email.CcAddress)
                        &&
                        (email.CcAddress.contains('@maersk.com')||email.CcAddress.contains('@mcc.com.sg')||email.CcAddress.contains('@seagoline.com')||email.CcAddress.contains('@sealand.com')||email.CcAddress.contains('@sealandmaersk.com'))
                       )
                       &&
                       !(be.Active__c)){
                           caseToUpdate.Count_Emails_To_Internal_Contact__c+=1;
                       }
                    
                    //Increment Outbound email to contact count
                    
                    if((!email.Incoming && (!String.isBlank(caseToUpdate.Contact.Email) && (email.ToAddress==caseToUpdate.Contact.Email || email.CcAddress==caseToUpdate.Contact.Email)))
                       &&(!be.Active__c)){
                           caseToUpdate.Count_Emails_To_Contact__c+=1;  
                       }
                    //Count Case Outbound Emails                    
                    if(!email.Incoming && !be.Active__c){
                        caseToUpdate.Count_Case_Outbound_Email__c+=1;
                    }
                    
                    //UTL: Set FCR Post Closure Activity Date                    
                    if((!String.isBlank(caseToUpdate.Contact.Email) && caseToUpdate.Contact.Email==email.FromAddress 
                        && 
                        (caseToUpdate.RecordType.DeveloperName=='External_Case' || caseToUpdate.RecordType.DeveloperName=='Dispute')
                        &&
                        caseToUpdate.Is_Resolved__c
                        &&
                        caseToUpdate.FCR_Post_Closure_Activity_Date__c==null)
                       &&
                       (!be.Active__c)){
                           caseToUpdate.FCR_Post_Closure_Activity_Date__c=System.now();
                       }
                    
                    //Count Case Incoming Emails
                    
                    if(email.Incoming && !be.Active__c){
                        //SC-2183: OHP Integration
                        //SC-5744 - added filter to prevent integration call from Maersk LnS brand 
                        if(caseToUpdate.RecordTypeId == disputeRTId && caseToUpdate.Count_Case_Emails__c > 0 && caseToUpdate.Liner_Brand__c != BrandUtilities.MAERSKLS){                       
                            mapCasesToPublish.put(caseToUpdate.Id,new EventTypeWrapper('Update', 'Case_Event')); //Modified for SC-9978 
                        }
                        caseToUpdate.Count_Case_Emails__c +=1;						                        
                        //UTL: New Email Flag to TRUE on ETIE
                        if((email.Incoming && caseToUpdate.Count_Case_Emails__c>1 && !String.isBlank(caseToUpdate.SuppliedEmail))||(String.isBlank(caseToUpdate.SuppliedEmail)) || (!String.isBlank(caseToUpdate.SuppliedEmail) && caseToUpdate.Case_Channel__c!='E-mail' && caseToUpdate.Case_Channel__c!='E-mail (Outlook)')){
                            caseToUpdate.New_Mail__c=true;
                        }
                    }
                    
                    //SC-2138 To update RRF of the current case's parent and child case when inbound/outbound mail is received.
                    //SC-6683
                    if((email.Incoming && caseToUpdate.status != 'Closed - Not a case' && caseToUpdate.status != 'Closed - Duplicate' && caseToUpdate.status != 'Closed - Merged') && !be.Active__c){
                        for (Case childCaseToUpdateRRF :emailRecSelector.mapRelatedChildCases.values()){
                            if(childCaseToUpdateRRF.RecordTypeId == externalCaseRTId && childCaseToUpdateRRF.status != 'Closed - Not a case' && childCaseToUpdateRRF.status!= 'Closed - Duplicate' && childCaseToUpdateRRF.status!= 'Closed - Merged'){
                                childCaseToUpdateRRF.New_Mail__c = true;                    
                                caseMapToUpdate.put(childCaseToUpdateRRF.Id, childCaseToUpdateRRF);
                            }
                        }
                        
                        if(!Constants.stopEmailParentRRFUpdate){
                            for(Case parentCaseToUpdateRRF :emailRecSelector.mapRelatedParentCases.values()){
                                if(parentCaseToUpdateRRF.RecordTypeId == externalCaseRTId && parentCaseToUpdateRRF.status != 'Closed - Not a case' && parentCaseToUpdateRRF.status!= 'Closed - Duplicate' && parentCaseToUpdateRRF.status!= 'Closed - Merged'){
                                    parentCaseToUpdateRRF.New_Mail__c = true;                                          
                                    caseMapToUpdate.put(parentCaseToUpdateRRF.Id, parentCaseToUpdateRRF);
                                }
                            }
                        }
                    }
                    
                    //UTL: Re-open Case for Case Resolution Pilot
                    if(email.Incoming 
                       && 
                       caseToUpdate.IsClosed
                       &&
                       (caseToUpdate.RecordType.DeveloperName=='External_Case' || caseToUpdate.RecordType.DeveloperName=='Dispute' || caseToUpdate.RecordType.DeveloperName=='ISR')
                       &&
                       email.CreatedById==System.Label.System_Owner
                      ){
                          caseToUpdate.Status='In Progress';
                      }
                    
                    //SC-9154 - update field First_Email_Response_Record_Id__c on case with the emailmessage record id for fetching the data from maerstro
                    if(!email.Incoming && caseToUpdate.RecordTypeId == externalCaseRTId && caseToUpdate.Count_Case_Emails__c <= 2 && caseToUpdate.Total_Outbound_Emails_minus_Handshake__c <= 1 && caseToUpdate.Product__c == 'Ocean' && caseToUpdate.case_channel__c == 'E-mail' && caseToUpdate.Email_Recommendation_Acceptance__c == 'Recommendations Available' && !String.isEmpty(caseToUpdate.Country__c) && ((regionValues.First_Field_Value__c == 'True' ) ||( regionValues.First_Field_Value__c == 'False' && Label.IDACountryFieldCriteriaEmailRecommendation.containsIgnoreCase(CaseToUpdate.Country__r.name)))){                              
                        
                        caseToUpdate.First_Email_Response_Record_Id__c = email.Id;
                    }
                    
                    parentCaseMap.put(caseToUpdate.Id, caseToUpdate);
                    
                    if(!email.Incoming && !caseToUpdate.CreatedBy.Name.containsIgnoreCase('System Owner') && String.isBlank(caseToUpdate.First_Queue_Owner_Id__c)){
                        emailMsgList.add(email);
                        fromAddList.add(email.FromAddress);
                    }
                }
            }
            
            if(!fromAddList.isEmpty()){
                for(Custom_Email_Service__c cs : [Select Id, BA_Address__c, Queue_Id__c From Custom_Email_Service__c Where BA_Address__c =: fromAddList]){
                    fromAddToCustEmailServiceMap.put(cs.BA_Address__c, cs);
                }
            }
            
            if(!emailMsgList.isEmpty() && !fromAddToCustEmailServiceMap.isEmpty()){
                for(EmailMessage em : emailMsgList){
                    if(parentCaseMap.containsKey(em.ParentId) && fromAddToCustEmailServiceMap.containsKey(em.FromAddress)){
                        parentCaseMap.get(em.ParentId).First_Queue_Owner_Id__c = fromAddToCustEmailServiceMap.get(em.FromAddress).Queue_Id__c;
                    }
                }
            }
            
            if(!caseMapToUpdate.isEmpty() && !caseMapToUpdate.values().isEmpty()){
                TriggerExecutionController.skipCaseTrigger(true);
                update caseMapToUpdate.values();
                TriggerExecutionController.skipCaseTrigger(false);
            }
            if(!mapCasesToPublish.isEmpty()){               
                CaseIntegrations.publishCases(mapCasesToPublish,'live'); //Modified for SC-9978
            }
            if(!parentCaseMap.isEmpty()){
                Case newCase = parentCaseMap.values()[0];
                Set<Id> artemisQueueIds = new Set<Id>();
                List<String> artemisQueueList = StaticFactory.getArtemisQueueList();
                for(Group gp : [Select Id From Group Where DeveloperName =: artemisQueueList]){
                    artemisQueueIds.add(gp.Id);
                }
                if(!(newCase.Artemis_Id__c != null || newCase.Resolver_Dept__c =='Ocean: Finance - Account Receivables' || (String.valueOf(newCase.ownerId).startsWith('00G') && !artemisQueueIds.isEmpty() && artemisQueueIds.contains(newCase.OwnerId)))) {
                    TriggerExecutionController.skipCaseTrigger(true);
                }
                else{
                    TriggerExecutionController.skipCaseTrigger(false);
                }
                //SC-2492 : Call calculateBusinessHoursAges to update fields required for business hours calculation
                CaseBusinessHours.calculateBusinessHoursAges(parentCaseMap.values(), OldCaseMap);
                update parentCaseMap.values(); 
                TriggerExecutionController.skipCaseTrigger(false);
            }
        }
        catch(Exception ex) {
            if(!String.isBlank(ex.getMessage()) && !ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                ErrorLogger.writeErrors('SFDC', 'Case', 'RelatedCaseFieldUpdator.updateCaseFields', new list<Exception>{ex});  
            }
        }        
    }
    
    public static void createCollaborationTaskForSCM(EmailRecordSelector emailRecSelector){
        try{
            List<EmailMessage> emails = emailRecSelector.emailRecords;
            Map<Id,Case> caseMap = new Map<Id, Case>([Select Id, Total_Outbound_Emails_minus_Handshake__c, Count_Case_Emails__c, Product__c, RecordTypeId, Additional_Teams_Involved__c, First_Queue_Owner_Id__c From Case Where Id =: emailRecSelector.mapRelatedCases.keyset()]);
            List<EmailMessage> emailMessageToProcess = new List<EmailMessage>();
            List<String> emailsList = new List<String>();
            Map<String, Custom_Email_Service__c> emailServiceMap = new Map<String, Custom_Email_Service__c>();
            Map<Id, List<String>> emailIdToEmailsListMap = new Map<Id, List<String>>();
            Map<Id, Set<String>> caseIdsToQueueIdsListMap = new Map<Id, Set<String>>();
            List<Task> taskList = new List<Task>();
            Set<Id> tskCaseIds = new Set<Id>();
            List<Task> tskListToUpdate = new List<Task>();
            
            Id externalCaseRTId = Label.External_Case_RT_Id;
            Id caseCollaborationRecTypeId = StaticFactory.getRecordTypeIdByName('Task', 'Case Collaboration');
            
            for(EmailMessage email : emails){
                if(caseMap.containsKey(email.ParentId) && (caseMap.get(email.ParentId).Total_Outbound_Emails_minus_Handshake__c > 0 || caseMap.get(email.ParentId).Count_Case_Emails__c > 1) && caseMap.get(email.ParentId).RecordTypeId == externalCaseRTId && (caseMap.get(email.ParentId).Product__c == 'SCM' || caseMap.get(email.ParentId).Product__c == '4PL')){
                    emailMessageToProcess.add(email);
                    if(!String.isBlank(email.ToAddress)){
                        emailsList.addAll(email.ToAddress.replace(' ', '').split(';'));
                    }
                    if(!String.isBlank(email.CcAddress)){
                        emailsList.addAll(email.CcAddress.replace(' ', '').split(';'));
                    }
                    emailIdToEmailsListMap.put(email.Id, emailsList);
                    tskCaseIds.add(email.ParentId);
                }
            }
            
            if(!emailsList.isEmpty()){
                for(Custom_Email_Service__c ces : [Select Id, BA_Address__c, Queue_Id__c, Service_Address__c, Origin__c From Custom_Email_Service__c Where BA_Address__c =: emailsList]){
                    emailServiceMap.put(ces.BA_Address__c, ces);
                }
            }
            
            if(!emailIdToEmailsListMap.isEmpty() && !emailServiceMap.isEmpty()){
                for(EmailMessage email : emailMessageToProcess){
                    Case cs = caseMap.get(email.ParentId);
                    if(emailIdToEmailsListMap.containsKey(email.Id)){
                        for(String str : emailIdToEmailsListMap.get(email.Id)){
                            if(emailServiceMap.containsKey(str) && !String.isBlank(emailServiceMap.get(str).Origin__c) && (emailServiceMap.get(str).Origin__c.startsWith('SCM') || emailServiceMap.get(str).Origin__c.startsWith('FPL')) && (String.isBlank(cs.Additional_Teams_Involved__c) || !cs.Additional_Teams_Involved__c.contains(emailServiceMap.get(str).Queue_Id__c)) && emailServiceMap.get(str).Queue_Id__c != cs.First_Queue_Owner_Id__c){
                                if(caseIdsToQueueIdsListMap.isEmpty() || !caseIdsToQueueIdsListMap.containsKey(cs.Id)){
                                    caseIdsToQueueIdsListMap.put(cs.Id, new Set<String>{emailServiceMap.get(str).Queue_Id__c});
                                }
                                else{
                                    caseIdsToQueueIdsListMap.get(cs.Id).add(emailServiceMap.get(str).Queue_Id__c);
                                }
                            }
                        }
                    }
                }
            }
            
            if(!caseIdsToQueueIdsListMap.isEmpty()){
                for(Id caseId : caseIdsToQueueIdsListMap.keyset()){
                    for(String str : caseIdsToQueueIdsListMap.get(caseId)){
                        Task newtask = new Task();
                        newtask.OwnerId = str;
                        newtask.Description = 'Case Collaboration Description';
                        newtask.Subject = 'Case Collaboration';
                        newtask.Status= 'Not Started';
                        newtask.type = 'Other';
                        newtask.RecordTypeId = caseCollaborationRecTypeId;
                        newtask.WhatId = caseId;
                        taskList.add(newtask);
                    }
                }
            }
            
            if(!taskList.isEmpty()){
                insert taskList;
            }
            
            if(!tskCaseIds.isEmpty()){
                for(Task tsk : [Select Id, Status From Task Where WhatId =: tskCaseIds AND Status = 'Completed' AND RecordTypeId =: caseCollaborationRecTypeId]){
                    tsk.Status = 'In Progress';
                    tskListToUpdate.add(tsk);
                }
            }
            
            if(!tskListToUpdate.isEmpty()){
                TriggerExecutionController.skipTaskTrigger(true);
                update tskListToUpdate;
                TriggerExecutionController.skipTaskTrigger(false);
            }
        }
        catch(Exception ex){
            if(!String.isBlank(ex.getMessage()) && !ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                ErrorLogger.writeErrors('SFDC', 'Case', 'RelatedCaseFieldUpdator.createCollaborationTaskForSCM', new List<Exception>{ex});  
            }
        }
    }
    
}