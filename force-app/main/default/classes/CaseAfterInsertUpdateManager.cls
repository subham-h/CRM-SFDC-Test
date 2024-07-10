/** 
* @description 
* Author   : Vivek
* Purpose  : Utility class to hold simple and reusable functionalities from afterinsert update scenarios for case
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-8791     01-09-2023   Vivek@Maersk            Migrate After Save Flow to After apex trigger
* 2.0         SC-8791              01-09-2023   Vivek@Maersk                                sendNotificationOnClosedISR method to send notifications on ISR case closure
* 3.0         SC-8791              02-09-2023   Vivek@Maersk                                publishCaseToPlatformEvent method to publish Case Producer Event for artemis data sync
* 4.0         SC-8791              04-09-2023   Vivek@Maersk                                disputeNotificationsOnEmailTrgCond method to send dispute email notifications

*/
public without sharing class CaseAfterInsertUpdateManager {
    
    //SC-8791 
    public static void sendNotificationOnClosedISR(List<Case> lstCases){
        
        List<StopFlowHandler.results> apexFlowResults = new List<StopFlowHandler.Results>();
        List<String> objectNameList ;
        //check if flow is not bypassed for this user
        apexFlowResults=  StopFlowHandler.stopTrigger(new List<String>{'Case'});
        try {
            if(apexFlowResults[0].stopFlow == false){
                //query custom notification object
                CustomNotificationType caseResolvedNotification = [SELECT Id, 
                                                                   DeveloperName  
                                                                   FROM CustomNotificationType  
                                                                   WHERE DeveloperName='case_resolved' 
                                                                   LIMIT 1]; 
                
                if(caseResolvedNotification != null){
                    for(Case thisCase : lstCases){
                        //create a notification object and send notification to users 
                        String body = 'Your ISR '+thisCase.caseNumber+' has been marked as closed.'; 
                        Messaging.CustomNotification Notification = new Messaging.CustomNotification(); 
                        Notification.setNotificationTypeId(caseResolvedNotification.id); 
                        Notification.setSenderId(Userinfo.getUserId()); 
                        Notification.setBody(body); 
                        Notification.setTitle('Case resolved'); 
                        Notification.setTargetId(thisCase.Id); 
                        //send notifications per case, Note: this code can be changed to bulk sending notifications Once bulk notification functionality is enabled by salesforce
                        Notification.send(new Set<String> {thisCase.createdById}); 
                        
                    } 
                }
            }
        }
        catch(Exception ex){
            
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseAfterInsertUpdateManager.sendNotificationOnClosedISR' , new list<Exception>{ex});  
            
        }
    }
    
    //SC-8791 
    public static void disputeNotificationsOnEmailTrgCond(Map<Case, Case> mapCases){
        
        List<StopFlowHandler.results> apexFlowResults = new List<StopFlowHandler.Results>();
        List<DisputeCaseClosureHelper.caseInput> listRequestInput  = new List<DisputeCaseClosureHelper.caseInput>();
        //check if flow is not bypassed for this user
        List<Case> clonedCaseList =  new List<Case>();
        Id disputeRTId = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get(Label.Dispute).getRecordTypeId();
        Id externalCaseRTId = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get(Label.External_Case).getRecordTypeId();
        apexFlowResults=  StopFlowHandler.stopTrigger(new List<String>{'Case'});
        Boolean flagSendEmail; 
        try {
            if(apexFlowResults[0].stopFlow == false){
                
                DisputeCaseClosureHelper.caseInput thisRequestInput ;
                
                //Check if email notification trigger field updated
                for(case thisCase : mapCases.keySet()){
                    
                    flagSendEmail = false;
                    
                    //Dispute case where email trigger condition is not equal to payer and acceptance
                    if(thisCase.recordTypeId == disputeRTId && thisCase.Case_Channel__c == 'E-mail' && thisCase.status == 'Closed - Not a case' && thisCase.Dispute_Email_Trigger_Condition__c != null && mapCases.get(thisCase)!= null && thisCase.Dispute_Email_Trigger_Condition__c != mapCases.get(thisCase).Dispute_Email_Trigger_Condition__c && thisCase.Dispute_Email_Trigger_Condition__c != 'Payer' && thisCase.Dispute_Email_Trigger_Condition__c != 'Acceptance')
                    {
                        flagSendEmail = true;
                    }
                    //Dispute case is changed to external case and where email trigger condition is equal to payer
                    else if(mapCases.get(thisCase).recordTypeId == disputeRTId && thisCase.recordTypeId == externalCaseRTId && thisCase.Case_Channel__c == 'E-mail' && thisCase.Dispute_Email_Trigger_Condition__c != null && mapCases.get(thisCase)!= null && thisCase.Dispute_Email_Trigger_Condition__c != mapCases.get(thisCase).Dispute_Email_Trigger_Condition__c && thisCase.Dispute_Email_Trigger_Condition__c == 'Payer' )
                    {
                        flagSendEmail = true;                        
                    }
                    //Dispute case is  where email trigger condition is equal to Acceptance and case channel not equalt to My Finance and Proactive
                    else if(thisCase.recordTypeId == disputeRTId && thisCase.Case_Channel__c != 'Proactive' && thisCase.Case_Channel__c != 'MyFinance' && thisCase.Dispute_Email_Trigger_Condition__c != null && mapCases.get(thisCase)!= null && thisCase.Dispute_Email_Trigger_Condition__c != mapCases.get(thisCase).Dispute_Email_Trigger_Condition__c && thisCase.Dispute_Email_Trigger_Condition__c == 'Acceptance' )
                    {
                        flagSendEmail = true;      
                        
                    }//Check for Cloned Case Record With Parent Case id
                    else if(thisCase.IsCloned__c == true && thisCase.ParentId != null && mapCases.get(thisCase) != null && mapCases.get(thisCase).ParentId != thisCase.ParentId )
                    {
                        // Send a chatter Post by calling CaseChatterPoster.postChildDetailsToParentFeed()
                        clonedCaseList.add(thisCase);
                    }
                    
                    //form thisRequestInput data if flagSendEmail = true and add it to collection thisRequestInput to send email action for all cases
                    if(flagSendEmail == true )
                    {
                        thisRequestInput = new DisputeCaseClosureHelper.caseInput();
                        thisRequestInput.brand = thisCase.Liner_Brand__c;
                        thisRequestInput.caseId = thisCase.Id;
                        thisRequestInput.caseLanguage = thisCase.Closure_Language_Code__c;
                        thisRequestInput.contactId = thisCase.ContactId;
                        thisRequestInput.CaseNumber = thisCase.CaseNumber;
                        thisRequestInput.direction = thisCase.Direction__c;
                        thisRequestInput.country = thisCase.Case_Country__c;
                        thisRequestInput.Subject = thisCase.Subject;
                        thisRequestInput.ThreadId = thisCase.ThreadId__c;
                        thisRequestInput.triggerCondition = thisCase.Dispute_Email_Trigger_Condition__c;
                        thisRequestInput.webEmail = thisCase.SuppliedEmail;
                        
                        listRequestInput.add(thisRequestInput);
                    }
                }
                
                //if listRequestInput is not null call method DisputeCaseClosureHelper.sendMissingInformationEmail() 
                if(listRequestInput != null && !listRequestInput.isEmpty())
                {
                    DisputeCaseClosureHelper.sendMissingInformationEmail(listRequestInput);
                }
                //if clonedCaseList is not null call method CaseChatterPoster
                if(clonedCaseList != null && !clonedCaseList.isEmpty())
                {
                    CaseChatterPoster.postChildDetailsToParentFeed(clonedCaseList);
                    
                }
                
            }
        }
        catch(Exception ex){
            
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseAfterInsertUpdateManager.disputeNotificationsOnEmailTrgCond' , new list<Exception>{ex});  
            
        }
    }
    
    //SC-8791 
    public static void preparePublishCaseToPlatformEvent(Map<Case, Case> artemisCases, Set<Id> artemisQueueIds){
        try{
            List<ArtemisProducerHandler.Results> jsonResultsList = new List<ArtemisProducerHandler.Results>();
            List<ArtemisProducerHandler.Requests> caseRequestList = new List<ArtemisProducerHandler.Requests>();
            List<Case> caseList = new List<case>();
            caseList.addALL(artemisCases.keySet());
            String query=ArtemisEMPUtility.createQuery('Case_Producer_Event__e','Case');
            query=query.removeEnd('From Case');
            query=query.replace('thread_token,','');
            query=query.replace(',thread_token','');
            query=query+',Parent_Case_Number__c, LastmodifiedBy.Username, Owner.Name, Owner.Email, Parent.Artemis_Id__c FROM Case WHERE Id IN'; 
            query +=':caseList';
            List<Case> caseListQuery= Database.query(query);
            for(Case thisCase :  caseListQuery){
                ArtemisProducerHandler.Requests thisCaseRequest = new ArtemisProducerHandler.Requests();
                thisCaseRequest.child_object_field1 = thisCase.Parent_Case_Number__c != null  ? thisCase.Parent_Case_Number__c : '';
                thisCaseRequest.child_object_field2 = thisCase.Owner.Name != null ? thisCase.Owner.Name : '';
                thisCaseRequest.child_object_field3 = thisCase.Owner.Email != null ? thisCase.Owner.Email : '';
                thisCaseRequest.child_object_field4 = thisCase.Parent.Artemis_Id__c != null ? thisCase.Parent.Artemis_Id__c: '' ;
                thisCaseRequest.sobjectName = 'Case_Producer_Event__e';
                thisCaseRequest.sObjRq = thisCase;
                
                if(thisCase.Artemis_Id__c != null || ((artemisCases.ContainsKey(thisCase) && artemisCases.get(thisCase)!= null &&  thisCase.OwnerId!= artemisCases.get(thisCase).ownerId) && !thisCase.LastModifiedBy.Username.contains('empinterface@maersk.com') && !artemisQueueIds.isEmpty() && artemisQueueIds.contains(thisCase.OwnerId)))
                {
                    thisCaseRequest.flag = 'Update';
                }
                else
                {    
                    thisCaseRequest.flag = 'Insert';
                }
                caseRequestList.add(thisCaseRequest);
                
            }
            
            if(!caseRequestList.isEmpty())
            {
                //call artemisProducerHandler class method preparePERecord to get the list of json serialized data for publishing a Platform Event
                jsonResultsList =  ArtemisProducerHandler.preparePERecord(caseRequestList);
                
                if(!jsonResultsList.isEmpty()){
                    publishCasePlatformEvents(jsonResultsList);
                }
            }
        }
        catch(Exception ex){            
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseAfterInsertUpdateManager.publishCaseToPlatformEvent' , new list<Exception>{ex});              
        }
    }
    
    public static void publishCasePlatformEvents(List<ArtemisProducerHandler.Results> jsonResultsList){        
        try{
            //PE collection List
            List<Case_Producer_Event__e> casePEList = new List<Case_Producer_Event__e>();
            
            String caseUpdateEvent;
            String caseInsertEvent;
            String caseTopicName;
            
            //fetching topic and event name to publish to kafka from metadata 
            for(Producer_Platform_Event_Config__mdt peObject : Producer_Platform_Event_Config__mdt.getAll().values()){                
                if(peObject.DeveloperName == 'Case_Update_Event'){
                    caseUpdateEvent = peObject.Topic_Name__c;
                }
                if(peObject.DeveloperName == 'Case_Insert_Event'){
                    caseInsertEvent = peObject.Topic_Name__c;
                }
                if(peObject.DeveloperName == 'Case_Topic'){
                    caseTopicName = peObject.Topic_Name__c;
                }
            }
            
            for(ArtemisProducerHandler.Results thisResultList : jsonResultsList){
                //create Case_Producer_Event__e record
                Case_Producer_Event__e thisPE = new Case_Producer_Event__e();
                thisPE.JSON_1__c = thisResultList.serializedJSON1;
                thisPE.JSON_2__c = thisResultList.serializedJSON2;
                thisPE.topic__c  = caseTopicName;
                thisPE.Event_Notification_Name__c = thisResultList.flag == 'Update' ? caseUpdateEvent: caseInsertEvent;
                casePEList.add(thisPE);
                
            }
            
            //publish events
            if(!casePEList.isEmpty())
            {
                List<Database.SaveResult> srList = EventBus.publish(casePEList);
            }
            
        }
        catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseAfterInsertUpdateManager.PublishCasePlatformEvents', new list<Exception>{ex}); 
        }
    }
    
    public static void sendEmailAlerts(map<case,string> mapcasesandalerts){
        try{
            for(case caseinstance:mapcasesandalerts.keyset()){
                Map<String, Object> flowemailalertParams = new Map<String, Object>();
                string emailalertid = mapcasesandalerts.get(caseinstance);
                flowemailalertParams.put('recordId',caseinstance.id); 
                flowemailalertParams.put('emailAlertId',emailAlertId);
                //create instance of Interview 
                Flow.Interview.Send_Email_Alerts flowInstance = new Flow.Interview.Send_Email_Alerts(flowemailalertParams); 
                //Invoke start method 
                flowInstance.start();
            }
        }
        catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseAfterInsertUpdateManager.sendEmailAlerts', new list<Exception>{ex}); 
        }
    }
    
    /** 
* @description |  Generic method during OnAfterInsert and OnAfterUpdate to create task and also if criteria matches to send email alerts |
* @param lstCases accepts the list of Case Records
* @param mapOldCases Accepts key value pair for Id and Case
* @param casTriggerHandler accepts record for type CaseTriggerHandler
* @param casRecordSelector accepts a record of type CaseRecordSelector
*/ 
    public static void taskcreationAndSendEmailAlerts(list<Case> lstCases, map<Id, Case> mapOldCases, CaseTriggerHandler casTriggerHandler, CaseRecordSelector casRecordSelector){       
        try{ list<case> caseswithalertsneeded = new list<case>();
            Id externalCaseRTId = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get(Label.External_Case).getRecordTypeId();
            Id claimRTId = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get(Label.Claim).getRecordTypeId();
            Id disputeRTId = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get(Label.Dispute).getRecordTypeId();
            Id isrrtid = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get(Label.ISR).getRecordTypeId();
            map<case,string> mapcasesandalerts = new map<case,string>();
            String emailAlertChoosen = '';
            list<task> tasksToInsert = new list<task>();
            for(case newcase:lstCases){
                try{
                    Boolean taskCreationCase = false;                    
                    if(!casRecordSelector.mapCasesTaskforclaims.isempty()){
                        if(casRecordSelector.mapCasesTaskforclaims.containskey(newcase.id)){
                            if(string.isNotBlank(newCase.OwnerId)){
                                if(String.valueOf(newCase.OwnerId).startsWith('005')){
                                    taskCreationCase = true;
                                }
                            }
                        }
                    }
                    if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT){
                        //UTL: Create Task on Claim
                        if(taskCreationCase == true ){
                            task taskInstance = new task();
                            taskInstance.Description = system.label.Claim_Checklist;
                            taskInstance.OwnerId = newcase.ownerid;
                            taskInstance.Priority = 'Normal';
                            taskInstance.Status = 'Not Started';
                            taskInstance.Subject = 'Documents Checklist';
                            taskInstance.Type = 'Other';
                            taskInstance.WhatId = newcase.id;
                            tasksToInsert.add(taskInstance); 
                        }   
                    }
                    
                    else if(casTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                        Case oldCase;
                        if(mapOldCases != null && !mapOldCases.isempty()) {
                            oldCase = mapOldCases.get(newCase.Id);
                        }
                        string EFRProduct= system.Label.EFR_Products;
                        Boolean mslAlertSendNotification = false;
                        if(string.isNotBlank(newCase.Product__c) && string.isNotBlank(newCase.Origin)){
                            if( !((String.valueOf(newCase.Origin).startsWith('ED') || String.valueOf(newCase.Origin).startsWith('EF')) || (String.valueOf(newCase.Product__c).startsWith('E-') || newcase.Product__c.contains(EFRProduct))) ){
                                mslAlertSendNotification = true; 
                            }
                        }
                        
                        if(taskCreationCase && ( newCase.RecordTypeId !=oldcase.RecordTypeId   || newcase.Status !=oldcase.status )){
                            task taskInstance = new task();
                            taskInstance.Description = system.label.Claim_Checklist;
                            taskInstance.OwnerId = newcase.ownerid;
                            taskInstance.Priority = 'Normal';
                            taskInstance.Status = 'Not Started';
                            taskInstance.Subject = 'Documents Checklist';
                            taskInstance.Type = 'Other';
                            taskInstance.WhatId = newcase.id;
                            tasksToInsert.add(taskInstance);
                        }
                        
                        else{
                            if(!casRecordSelector.mapCasesforemailalerts.isempty()){
                                if(casRecordSelector.mapCasesforemailalerts.containskey(newcase.id)){
                                    //NFY: Twill : Notify Customer When Public Case Comment is Added
                                    if(newCase.Delivery_Channel__c  == system.label.Twill  && newCase.RecordTypeId  == externalCaseRTId && BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MAERSKLINE).contains(newCase.Liner_Brand__c)){
                                        General_Key_Value_Configurations__mdt genInstance = General_Key_Value_Configurations__mdt.getInstance('Twill_Case_Comment_Notification');     
                                        if(genInstance!=null){
                                            String emailalertid = genInstance.First_Field_Value__c;
                                            mapcasesandalerts.put(newcase,emailalertid);             
                                        }
                                    }
                                    
                                    
                                    //Maersk : New Public Comment  Added
                                    else if((BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MAERSKLINE).contains(newCase.Liner_Brand__c) && ((newCase.Case_Country__c ==  'Tanzania' && newCase.MLL__c ==  true) || newCase.Case_Country__c <>  'Tanzania'))&& mslAlertSendNotification == True){
                                        General_Key_Value_Configurations__mdt genInstance = General_Key_Value_Configurations__mdt.getInstance('Notify_MSL_Vendor_Customer');     
                                        if(genInstance!=null){
                                            String emailalertid = genInstance.First_Field_Value__c;
                                            mapcasesandalerts.put(newcase,emailalertid); 
                                        }  
                                    }
                                    
                                    
                                    //Send MCC vendor Notification
                                    //Liner Brand = MCC - PH Domestic
                                    else if (BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MCC).contains(newCase.Liner_Brand__c) && newcase.Case_Country__c == 'Philippines' && newcase.Direction__c=='Domestic' ){                   
                                        General_Key_Value_Configurations__mdt genInstance = General_Key_Value_Configurations__mdt.getInstance('Notify_SEA_Vendor_Customer');     
                                        if(genInstance!=null){
                                            String emailalertid = genInstance.First_Field_Value__c;
                                            mapcasesandalerts.put(newcase,emailalertid); 
                                        }  
                                        
                                    }
                                    
                                    //Sealand,Seago,MCC :New Public Comment
                                    else if(BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.Sealand).contains(newCase.Liner_Brand__c) ||BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.Seago).contains(newCase.Liner_Brand__c) || (BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MCC).contains(newCase.Liner_Brand__c) && newCase.Case_Country__c !=  'Philippines' && newcase.Direction__c!='Domestic')){
                                        General_Key_Value_Configurations__mdt genInstance = General_Key_Value_Configurations__mdt.getInstance('Notify_SEA_Vendor_Customer');     
                                        if(genInstance!=null){
                                            String emailalertid = genInstance.First_Field_Value__c;
                                            mapcasesandalerts.put(newcase,emailalertid); 
                                        }  
                                    }
                                    
                                    //Maersk TZ : New Public Comment
                                    else if(BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MAERSKLINE).contains(newCase.Liner_Brand__c) && newCase.Case_Country__c ==  'Tanzania'){
                                        General_Key_Value_Configurations__mdt genInstance = General_Key_Value_Configurations__mdt.getInstance('Notify_MSLTZ_Vendor_Customer');     
                                        if(genInstance!=null){
                                            String emailalertid = genInstance.First_Field_Value__c;
                                            mapcasesandalerts.put(newcase,emailalertid); 
                                        }  
                                    } 
                                    else{}
                                }
                            }                   
                        }
                    }                
                }catch(Exception ex){
                    ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseAfterInsertUpdateManager.taskcreationAndSendEmailAlerts1 '+newcase.casenumber, new list<Exception>{ex}); 
                }
            }
            
            if(!tasksToInsert.isempty()){
                Database.SaveResult[] srList = Database.insert(tasksToInsert, false);
                TriggerExecutionController.skipCaseTrigger(false);
                ErrorLogger.writeErrors('SFDC', 'Task', 'CaseAfterInsertUpdateManager.taskcreationAndSendEmailAlerts2 ', srList, lstCases);
            }
            
            if(!mapcasesandalerts.isempty()){
                CaseAfterInsertUpdateManager.sendEmailAlerts(mapcasesandalerts);
            }
           }catch(Exception ex){
               ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseFieldPopulator.taskcreationAndSendEmailAlerts3 '+lstCases[0].casenumber, new list<Exception>{ex}); 
           }
    }
    
    /** 
* @description |  Generic method during OnAfterUpdate to create task and also if criteria matches to send email alerts |
* @param lstCases accepts the list of Case Records
* @param mapOldCases Accepts key value pair for Id and Case
* @param casTriggerHandler accepts record for type CaseTriggerHandler
* @param casRecordSelector accepts a record of type CaseRecordSelector
*/ 
    public static void sendCaseEscalationSendEmailAlert(list<Case> lstCases){       
        try{ 
            Set<Id> userIdSet = new Set<Id>();
            Map<Id, User> usrMap = new Map<Id, User>();
            Map<case,string> mapCasesandAlerts = new map<case,string>();
            for(Case cs : lstCases){
                userIdSet.add(cs.OwnerId);
            }
            
            if(!userIdSet.isEmpty()){
                usrMap = new Map<Id, User>([Select Id, Email from User Where Id =: userIdSet]);
            }
            if(!usrMap.isEmpty()){
                General_Key_Value_Configurations__mdt genInstance = General_Key_Value_Configurations__mdt.getInstance('Case_Escalation_Email_Notification');     
                String emailalertid = genInstance?.First_Field_Value__c;
                for(Case cs : lstCases){
                    if(usrMap.containsKey(cs.OwnerId)){
                        mapCasesandAlerts.put(cs, emailalertid);    
                    }
                }
            }
            
            if(!mapCasesandAlerts.isempty()){
                CaseAfterInsertUpdateManager.sendEmailAlerts(mapCasesandAlerts);
            }
            
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseAfterInsertUpdateManager.sendCaseEscalationSendEmailAlerts '+lstCases[0].casenumber, new list<Exception>{ex}); 
        }
    }
    
    /** 
* @description |  sendHandshakeEmail for SCM Global BA's
* @param csList accepts the list of Case Records
*/ 
    public static void sendHandshakeEmail(List<Case> csList, Map<String, SCM_Key_Client_Country_Mapping__mdt> scmIndicatorToSCMKCMap, Set<String> templateNames, Set<String> replyToEmailList, Map<Id, Contact> conMap){
        try{
            Map<String, Id> tempNameToTempIdMap = new Map<String, Id>();
            Map<String, OrgWideEmailAddress> replyToEmailToOrgWideIdMap = new Map<String, OrgWideEmailAddress>();
            List<Messaging.SingleEmailMessage> emMsgList = new List<Messaging.SingleEmailMessage>();
            List<EmailMessage> emList = new List<EmailMessage>();
            
            if(!templateNames.isEmpty()){
                for(EmailTemplate em : [Select Id, DeveloperName From EmailTemplate Where DeveloperName =: templateNames]){
                    tempNameToTempIdMap.put(em.DeveloperName, em.Id);
                }
            }
            
            if(!replyToEmailList.isEmpty()){
                for(OrgWideEmailAddress org : [Select Id, Address, DisplayName From OrgWideEmailAddress Where Address =: replyToEmailList]){
                    replyToEmailToOrgWideIdMap.put(org.Address, org);
                }
            }
            
            List<OrgWideEmailAddress> defaultOrgAddList = new List<OrgWideEmailAddress>([Select Id, DisplayName, Address From OrgWideEmailAddress Where Address = 'autoreply1@lns.maersk.com' LIMIT 1]);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            OrgWideEmailAddress orgWideAdd;
            for(Case cs : csList){
                if(String.isBlank(cs.ContactEmail) || (!String.isBlank(cs.ContactEmail) && !conMap.get(cs.ContactId).Auto_Notification_Opt_Out__c)){
                    Messaging.SingleEmailMessage emMsg = new Messaging.SingleEmailMessage();
                    SCM_Key_Client_Country_Mapping__mdt scmKc = (!String.isBlank(cs.SCM_KC_Indicator__c) && scmIndicatorToSCMKCMap.containsKey(cs.SCM_KC_Indicator__c)) ? scmIndicatorToSCMKCMap.get(cs.SCM_KC_Indicator__c) : null;
                    if(scmKc != null){
                        Id templateId = tempNameToTempIdMap.containsKey(scmKc.Template_Unique_Name__c) ? tempNameToTempIdMap.get(scmKc.Template_Unique_Name__c) : null;
                        if(templateId != null){
                            email = Messaging.renderStoredEmailTemplate(templateId, cs.ContactId, cs.Id);
                            emMsg.setSubject(email.getSubject());
                            List<String> toAddressList = new List<String>();
                            if(!String.isBlank(cs.ContactEmail)){
                                toAddressList.add(cs.ContactEmail);
                            }
                            else if(!String.isBlank(cs.SuppliedEmail)){
                                toAddressList.add(cs.SuppliedEmail);
                            }
                            emMsg.setToAddresses(toAddressList);
                            emMsg.setHtmlBody(email.getHtmlBody());
                            emMsg.setWhatId(cs.Id);
                            emMsg.setSaveAsActivity(false);
                            emMsg.setUseSignature(false);
                            orgWideAdd = replyToEmailToOrgWideIdMap.get(scmKc.Reply_To_Email__c);
                            if(orgWideAdd != null){
                                emMsg.setOrgWideEmailAddressId(orgWideAdd.Id);
                            }
                            else if(!defaultOrgAddList.isEmpty()){
                                emMsg.setOrgWideEmailAddressId(defaultOrgAddList[0].Id);
                            }
                            emMsg.setReplyTo(scmKc.Reply_To_Email__c);
                            emMsgList.add(emMsg);
                        }
                    }
                }
            }
            
            if(!emMsgList.isEmpty()) {                
                list<Messaging.SendEmailResult> lstEmailResults = Messaging.sendEmail(emMsgList);
                if(!lstEmailResults[0].success) {
                    ErrorLogger.writeError('SFDC', 'Case', 'CaseAfterInsertUpdateManager.sendHandshakeEmail', '', 'SCM Handshake failed', lstEmailResults[0].errors[0].message);
                }
                else{
                    EmailMessage em = new EmailMessage();
                    em.ParentId = email.getWhatId();
                    em.TextBody = email.getPlainTextBody();
                    em.HtmlBody = email.getHtmlBody();
                    em.Subject = email.getSubject();
                    em.ToAddress = emMsgList[0].getToAddresses()[0];
                    em.Status = '3';
                    em.MessageDate = Datetime.now(); 
                    if(orgWideAdd != null){
                        em.FromName = orgWideAdd.DisplayName;
                        em.FromAddress = orgWideAdd.Address;
                    }
                    else if(!defaultOrgAddList.isEmpty()){
                        em.FromName = defaultOrgAddList[0].DisplayName;
                        em.FromAddress = defaultOrgAddList[0].Address;
                    }
                    emList.add(em);
                }
            }
            
            if(!emList.isEmpty()){
                insert emList;
            }
        }catch(Exception e){
            ErrorLogger.writeErrors('SFDC', 'Case', 'CaseAfterInsertUpdateManager.sendHandshakeEmail', new list<Exception>{e});
        }
    }
    
}