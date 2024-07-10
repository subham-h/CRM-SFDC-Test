/*  
* Version   Date            Referance               Owner                   Description
* --------  -----------     -------------------     -----------				------------
* 1.0       26-May-2023     SFSE-10705              Vazid@UST               Get the feedback in feedback widget and create feedback response based on the user
																			response
* 2.0       11-Aug-2023     SFSE-11844              Vazid@UST               Added 'createFBInviteRecordLevel' method to create feedback Invite record for record level

*/
public without sharing class FeedbackController {
    
    public class feedbackResultWrapper {
        @AuraEnabled
        public List<Feedback_Data__c> feedbackWithQuesResponse;
        @AuraEnabled
        public List<Feedback_Invite__c> feedbackInviteResponse;
        public feedbackResultWrapper(){
            feedbackWithQuesResponse = new List<Feedback_Data__c>();
            feedbackInviteResponse = new List<Feedback_Invite__c>();
        }
    }
    
    //Get the feedback records based on the functionality
    @AuraEnabled
    public static feedbackResultWrapper getFeedbackData(String functionality, Id recId) {
        system.debug('recId'+recId);
        system.debug('functionality'+functionality);
        
        feedbackResultWrapper wrapResult= new feedbackResultWrapper();
        List<Feedback_Invite__c > feedbackInvitelst = new List<Feedback_Invite__c >();
        //If functionality is blank then get the functionality name based on the recordId
        if(functionality == null){
            
            String sObjName = recId.getSObjectType().getDescribe().getName();
            system.debug('sObjName'+sObjName);
            string whatIdAPIName = 'WhatId__r.'+sObjName+'__c';
            
            string sQuery1 = 'select Id, Name, Feedback__r.Functionality__c, '+whatIdAPIName+' from Feedback_Invite__c WHERE '+whatIdAPIName+' = \'' + String.escapeSingleQuotes(recId)+'\' LIMIT 1';
            feedbackInvitelst = Database.query(sQuery1);
            
            if(!feedbackInvitelst.isEmpty()){
                functionality = feedbackInvitelst[0].Feedback__r.Functionality__c;
            }
        }
        
        List<Feedback_Data__c> feedbackList = [select Id, Overlay_Restriction_Days__c, Header_Text__c, Type__c ,
                                               What_Object__c, Cancel_Button_Label__c, Hide_Confirmation_Toast__c,
                                               ( SELECT Id
                                                , Question_Text__c
                                                , Question_Type__c
                                                , Question_Order__c
                                                , isMandatory__c
                                                , Question_Response_Data_Type__c
                                                FROM Feedback_Questions__r
                                                ORDER BY Question_Order__c)from Feedback_Data__c where isActive__c = true and Functionality__c =:functionality LIMIT 1];
        if(!feedbackList.isEmpty()){
            string feedbackType = feedbackList[0].Type__c;
            string whatObjAPIName = feedbackList[0].What_Object__c+'__c';
            system.debug('whatObjAPIName'+whatObjAPIName);
            
            string sQuery ='';
            if(feedbackType == 'Functionality'){
                sQuery = 'select Id, Name, Feedback__c, Feedback__r.Overlay_Restriction_Days__c, Participant__c, Status__c, Invite_Date__c from Feedback_Invite__c where Feedback__c =\'' + String.escapeSingleQuotes(feedbackList[0].Id)+'\' AND Participant__c=\'' + String.escapeSingleQuotes(UserInfo.getUserId())+'\' AND Status__c != \'Closed\'';
            }else{
                sQuery = 'select Id, Name, Feedback__c, Feedback__r.Overlay_Restriction_Days__c, Participant__c, Status__c, Invite_Date__c from Feedback_Invite__c where Feedback__c =\'' + String.escapeSingleQuotes(feedbackList[0].Id)+'\' AND Participant__c=\'' + String.escapeSingleQuotes(UserInfo.getUserId())+'\' AND WhatId__r.'+whatObjAPIName+ '=\'' + String.escapeSingleQuotes(recId)+'\' AND Status__c != \'Closed\'';
            }
            
            system.debug('sQuery'+sQuery);
            feedbackInvitelst = Database.query(sQuery);
        }
        
        wrapResult.feedbackWithQuesResponse = feedbackList;
        wrapResult.feedbackInviteResponse = feedbackInvitelst;
        return wrapResult;
    }
    
    //Get the feedback & feedback Invite records based on the functionality when Platform event fires to show the widget.
    @AuraEnabled
    public static List<SObject> getFbInvite(String functionality) {

        return [    SELECT Id
                , Header_text__c
                , Overlay_Restriction_Days__c, Cancel_Button_Label__c, Hide_Confirmation_Toast__c
                , ( SELECT Id
                   , Status__c
                   , Invite_Date__c
                   FROM Feedback_Invites__r
                   WHERE Participant__c = :UserInfo.getUserId()
                   AND Status__c != 'Closed')
                FROM Feedback_Data__c 
                WHERE isActive__c = true 
                AND Functionality__c = :functionality 
               ];
    }
    
    //Update feedback Invite record if user cancel the widget.
    @AuraEnabled
    public static Feedback_Invite__c cancelInvite(Feedback_Invite__c inviteData) {//, boolean publishPlatFormEvt, string functionality
        system.debug('inviteData####'+inviteData);
        if(inviteData != null){
            inviteData.Invite_Date__c = system.today();
            Database.upsert(inviteData, true);
        }
        return inviteData;
    }
    
    //Publish platform event
    public static void publishEvent(string strfunctionality){
        Feedback_Event__e event = new Feedback_Event__e();
        event.Functionality__c = strfunctionality ;   
        Database.SaveResult sr = EventBus.publish(event);
        System.debug('In Publish event'+sr);
    }
    
    //Create Feedback Invite record for each participant if criteria match.
    @AuraEnabled
    public static void createFBInvite(string strfunctionality, boolean blnpublishEvent){
        
        system.debug('strfunctionality'+strfunctionality);
        system.debug('blnpublishEvent'+blnpublishEvent);
        
        List<Feedback_Data__c> feedbackList = [select Id, Name, Header_Text__c from Feedback_Data__c where isActive__c = true and Functionality__c =:strfunctionality LIMIT 1];
        List<Feedback_Invite__c> fbInviteTobeUpsert = new List<Feedback_Invite__c>();
        boolean showWidget = false;
        
        if(!feedbackList.isEmpty()){
            List<Feedback_Invite__c > feedbackInvitelst = [select Id, Name, Feedback__c, Feedback__r.Overlay_Restriction_Days__c, Participant__c, Status__c, Invite_Date__c from Feedback_Invite__c where Feedback__c =: feedbackList[0].Id AND Participant__c =: UserInfo.getUserId()];
            system.debug('feedbackInvitelst size'+feedbackInvitelst.size());
            if(!feedbackInvitelst.isEmpty()){
                
                for(Feedback_Invite__c fbInvite : feedbackInvitelst){ 
                    Date startDate = fbInvite.Invite_Date__c;
                    Date endDate = Date.today();
                    Integer days = startDate.daysBetween( endDate );
                    system.debug( 'Days between both dates is ' + days );
                    
                    if(fbInvite.Status__c == 'Cancelled' && days > fbInvite.Feedback__r.Overlay_Restriction_Days__c){
                        Feedback_Invite__c fiRecToUpdate = new Feedback_Invite__c();
                        fiRecToUpdate.Id = fbInvite.Id;
                        fiRecToUpdate.Status__c = 'Invited';
                        fiRecToUpdate.Invite_Date__c = system.today();
                        fbInviteTobeUpsert.add(fiRecToUpdate);
                        showWidget = true;
                    }
                }
                
            }else{
                Feedback_Invite__c fiRecToInsert = new Feedback_Invite__c();
                fiRecToInsert.Feedback__c = feedbackList[0].Id;
                fiRecToInsert.Participant__c = UserInfo.getUserId();
                fiRecToInsert.Status__c = 'Invited';
                fiRecToInsert.Invite_Date__c = system.today();
                fbInviteTobeUpsert.add(fiRecToInsert);
                showWidget = true;
            }
            
            system.debug('fbInviteTobeUpsert size'+fbInviteTobeUpsert.size());
            if(!fbInviteTobeUpsert.isEmpty()){
                Database.upsertResult[] srList = Database.upsert(fbInviteTobeUpsert, false);
            }
            
            if(blnpublishEvent && showWidget){
                system.debug('Fire PE');
                publishEvent(strfunctionality);
            }
        }
    }
    
     //Create Feedback Invite record for each participant & record level if criteria match 
    @AuraEnabled
    public static void createFBInviteRecordLevel(string strfunctionality, boolean blnpublishEvent, string recId){
        
        system.debug('strfunctionality'+strfunctionality);
        system.debug('blnpublishEvent'+blnpublishEvent);
        
        List<Feedback_Data__c> feedbackList = [select Id, Name, Header_Text__c, Type__c , What_Object__c from Feedback_Data__c where isActive__c = true and Functionality__c =:strfunctionality LIMIT 1];
        List<Feedback_Invite__c> fbInviteTobeUpsert = new List<Feedback_Invite__c>();
        boolean showWidget = false;
        
        if(!feedbackList.isEmpty() && recId != null){
            
            string whatObjAPIName = feedbackList[0].What_Object__c+'__c';
            system.debug('whatObjAPIName'+whatObjAPIName);
            List<Feedback_Invite__c > feedbackInvitelst = new List<Feedback_Invite__c >();
            
            string sQuery = 'select Id, Name, Feedback__c, Feedback__r.Overlay_Restriction_Days__c, Participant__c, Status__c, Invite_Date__c from Feedback_Invite__c where Feedback__c =\'' + String.escapeSingleQuotes(feedbackList[0].Id)+'\' AND Participant__c=\'' + String.escapeSingleQuotes(UserInfo.getUserId())+'\' AND WhatId__r.'+whatObjAPIName+ '=\'' + String.escapeSingleQuotes(recId)+'\'';
            
            feedbackInvitelst = Database.query(sQuery);
            
            system.debug('feedbackInvitelst size'+feedbackInvitelst.size());
            if(!feedbackInvitelst.isEmpty()){
                
                for(Feedback_Invite__c fbInvite : feedbackInvitelst){ 
                    Date startDate = fbInvite.Invite_Date__c;
                    Date endDate = Date.today();
                    Integer days = startDate.daysBetween( endDate );
                    system.debug( 'Days between both dates is ' + days );
                    
                    if(fbInvite.Status__c == 'Cancelled' && days > fbInvite.Feedback__r.Overlay_Restriction_Days__c){
                        Feedback_Invite__c fiRecToUpdate = new Feedback_Invite__c();
                        fiRecToUpdate.Id = fbInvite.Id;
                        fiRecToUpdate.Status__c = 'Invited';
                        fiRecToUpdate.Invite_Date__c = system.today();
                        fbInviteTobeUpsert.add(fiRecToUpdate);
                        showWidget = true;
                    }
                }
                
            }else{
                Feedback_Invite__c fiRecToInsert = new Feedback_Invite__c();
                fiRecToInsert.Feedback__c = feedbackList[0].Id;
                fiRecToInsert.Participant__c = UserInfo.getUserId();
                fiRecToInsert.Status__c = 'Invited';
                fiRecToInsert.Invite_Date__c = system.today();
                if(recId != null){
                    fiRecToInsert.WhatId__c = createFBwhatObjRecord(recId,whatObjAPIName);
                }
                fbInviteTobeUpsert.add(fiRecToInsert);
                showWidget = true;
            }
            
            system.debug('fbInviteTobeUpsert size'+fbInviteTobeUpsert.size());
            if(!fbInviteTobeUpsert.isEmpty()){
                Database.upsertResult[] srList = Database.upsert(fbInviteTobeUpsert, false);
            }
            
            if(blnpublishEvent && showWidget){
                system.debug('Fire PE');
                publishEvent(strfunctionality);
            }
        }
    }
    
    public static string createFBwhatObjRecord(Id recordId, string whatfieldAPIName){
        sObject sObj = Schema.getGlobalDescribe().get('Feedback_What_Object__c').newSObject() ;
        sObj.put(whatfieldAPIName , recordId);
        if(sObj != null){
            insert sObj;
        }
        return sObj.Id;
    }
    
    @InvocableMethod(label='Create feedback Invite record')
    public static void createFBInvitefromFlow(List<feedbackInviteRequest> feedInvRequest){
        if(!feedInvRequest.isEmpty()){
            system.debug('strfunctionality'+feedInvRequest[0].strfunctionality);
            system.debug('blnpublishEvent'+feedInvRequest[0].blnpublishEvent);
            createFBInvite(feedInvRequest[0].strfunctionality,feedInvRequest[0].blnpublishEvent);
        }
    }
    
    public class feedbackInviteRequest{
        @InvocableVariable
        public string  strfunctionality;
        @InvocableVariable
        public boolean  blnpublishEvent;
    }
    
    //To capture the feedback response from the UI.
    @AuraEnabled
    public static string saveFBdetails(Id feedbackId, Feedback_Invite__c inviteData, List<Feedback_Question_Response__c> fbQuestionResList) {
        
        system.debug('inviteData###'+inviteData);
        system.debug('fbQuestionResList###'+fbQuestionResList);
        
        string strResponseMessage = 'success';
        Savepoint sp = Database.setSavepoint();
        
        if(inviteData != null && inviteData.Status__c != 'Responded'){
            inviteData.Status__c = 'Responded';
            
            Feedback_Response__c fbResponseToInsert = new Feedback_Response__c(Feedback_Invite__c = inviteData.Id,
                                                                               Completed_Date__c = system.today(),
                                                                               Feedback__c = feedbackId);
            
            try{
                update inviteData;
            }catch(DmlException de){
                strResponseMessage = de.getMessage();
                ErrorLogger.writeError('SFDC', 'Feedback widget', 'FeedbackController.saveFBdetails', de.getTypeName(), de.getMessage(), de.getMessage());
                
            }
            
            if(strResponseMessage == 'success' && fbResponseToInsert != null){
                
                try{
                    insert fbResponseToInsert;
                }catch(DmlException de){
                    Database.RollBack(sp);
                    strResponseMessage = de.getMessage();
                    ErrorLogger.writeError('SFDC', 'Feedback widget', 'FeedbackController.saveFBdetails', de.getTypeName(), de.getMessage(), de.getMessage());
                    
                }
                
                if(strResponseMessage == 'success' && !fbQuestionResList.isEmpty()){
                    for(Feedback_Question_Response__c fbqRec : fbQuestionResList ){
                        fbqRec.Feedback_Response__c = fbResponseToInsert.Id;
                    }
                    try{
                        insert fbQuestionResList;
                    }catch(DmlException de){
                        Database.RollBack(sp);
                        strResponseMessage = de.getMessage();
                        ErrorLogger.writeError('SFDC', 'Feedback widget', 'FeedbackController.saveFBdetails', de.getTypeName(), de.getMessage(), de.getMessage());
                        
                    }
                }
            }
        }
        return strResponseMessage;
    }    
    
}