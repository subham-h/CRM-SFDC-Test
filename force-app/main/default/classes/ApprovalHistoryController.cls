/*
* This controller is used in the Approval History LWC.
* ====================================================================================================================
* Version          Date          Owner          User Story          Description
* ====================================================================================================================
* 1.0          08-May-2023   	Jaya@UST        SFSE - 10676        Approval History Custom related list - LWC
* 2.0          30-May-2023   	Jothsana@IST   	SFSE - 10907        Approval History Custom related list - LWC(Re-Assign,Recall)
* 3.0			03-Aug-2023		Jothsana@Maersk	SFSE - 11845		Delegated Approver logic added
* 4.0          09-Aug-2023     Shilpa@maersk   SFSE - 11084        Action taken field update logic added
* 5.0          24-Aug-2023     Jaya@SUT        SFSE - 11771        Extend Reject Notifications
* 6.0			29-Aug-2023		Jothsana@Maersk	SFSE - 11158		Reject Reasons logic added
*/
public without sharing class ApprovalHistoryController {
    
    public static final String APPROVED = System.label.Status_Approved;
    public static final String REJECTED = System.label.Status_Rejected;
    public static final String PENDING = System.label.Status_Pending;
    public static final String NO_RESPONSE = System.label.Status_No_response;
    public static final String REASSIGNED = System.label.Status_Reassigned;
    public static final String RECALLED = System.label.Status_Recalled;
    public static string ReplyEmailAddress = system.label.Opportunity_Approval_Email_Address;
    
    @AuraEnabled(cacheable=true)
    public static List<Approval_History__c> getApprovalHistory(Id oppId) {
        
        List<Approval_History__c> appHList = [SELECT Id, Step_Name__c, key__c, CreatedDate, Status__c, Type__c, CreatedById, CreatedBy.Name, Assigned_To__c,Assigned_To__r.Name, Approved_By__c,Approved_By__r.Name, 
                                              Submitter_Comments__c, Approver_Comments__c,TargetObjectId__r.Owner.Id,Delegated_approver__c,Reason_for_rejection__c FROM Approval_History__c WHERE TargetObjectId__c =: oppId ORDER BY CreatedDate Desc, Approval_Step__r.Approval_Process_Name__r.Order__c Desc, Step_Name__c ];
        return appHList;
        
        
    }
    @AuraEnabled(cacheable=true)
    public static List<Approval_History__c> getApprovalHistoryPending() {
        
        List<Approval_History__c> appHList = [SELECT TargetObjectId__r.name,SLA__c,Step_Name__c,TargetObjectId__r.Account.name,CreatedBy.Name,id,Name,Status__c,Assigned_To__c,Assigned_To__r.Name,CreatedDate,Reason_for_rejection__c FROM Approval_History__c WHERE Status__c='Pending'  AND Assigned_To__c=:UserInfo.getUserId() ORDER BY CreatedDate Desc];
        System.debug('test' + appHList);
        return appHList;
        
    }
    
    @AuraEnabled
    public static boolean approveRecord(Id recId, String comments,String actionTaken){
        Approval_History__c aphRec = [SELECT Id, Step_Name__c, key__c, TargetObjectId__c, Approved_By__c, Approver_Comments__c FROM Approval_History__c  WHERE Id =: recId LIMIT 1][0];
        Id optyId = aphRec.TargetObjectId__c;
        system.debug( 'Action'+ actionTaken);
        
        Map<Id,Approval_History__c> aphMap = New Map<Id,Approval_History__c>([SELECT Id, Status__c, Key__c, Approver_Comments__c, Approved_By__c,Process_Name__c FROM Approval_History__c WHERE key__c =: aphRec.Key__c]);
        
        List<Approval_History__c> updateAphList = New List<Approval_History__c>();
        for(Id key : aphMap.keySet()){
            if(key == recId){
                Approval_History__c aph  = aphMap.get(key);
                if(aph.Status__c == PENDING){
                    aph.Status__c = APPROVED;
                    aph.Action_Date__c = System.today();
                    aph.Approver_Comments__c = comments;
                    aph.Approved_By__c = UserInfo.getUserId();
                    aph.Action_taken__c = actionTaken == 'handheld' ?'Handheld device': actionTaken == 'Home'?'Home screen via desktop':'History via desktop';
                    
                }
                updateAphList.add(aph);
            }else{
                Approval_History__c aph  = aphMap.get(key);
                if(aph.Status__c == PENDING){
                    aph.Status__c = NO_RESPONSE;
                    aph.Action_Date__c = System.today();
                    aph.Approved_By__c = UserInfo.getUserId();
                    
                }
                updateAphList.add(aph);
            }
        }
        
        if(updateAphList.Size() > 0){
            try{
                
                update updateAphList;
                updateStatusStage(optyId, APPROVED);
            }catch(exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
        
        return true;
    }
    
    @AuraEnabled
    public static boolean rejectRecord(Id recId, String comments,String actionTaken,string RejectionReason){
        Approval_History__c aphRec = [SELECT Id, Step_Name__c, key__c, Gate_Name__c, Status__c, Submission_Order__c, TargetObjectId__c, Approved_By__c, Approver_Comments__c FROM Approval_History__c WHERE Id =: recId LIMIT 1][0];
        system.debug( 'Action'+ actionTaken);
        Id optyId = aphRec.TargetObjectId__c;
        String gateName = aphRec.Gate_Name__c;
        String status = aphRec.Status__c;
        Decimal orderNum = aphRec.Submission_Order__c;
        Id RejaphId = aphRec.Id;
        String stepName = '%'+aphRec.Step_Name__c.split('-')[0]+'%';
        system.debug(actionTaken);
        
        // Map<Id,Approval_History__c> aphMap = New Map<Id,Approval_History__c>([SELECT Id, Status__c, Key__c, Approver_Comments__c, Approved_By__c FROM Approval_History__c WHERE key__c =: aphRec.Key__c]);
        Map<Id, Approval_History__c> rejectMap = New Map<Id, Approval_History__c>([SELECT Id, Status__c, Step_Name__c, Key__c, Approver_Comments__c, Approved_By__c FROM Approval_History__c WHERE Status__c =: PENDING AND TargetObjectId__c =: optyId ]);
        System.debug('Step Name >> '+stepName);
        System.debug('Reject Map >> '+rejectMap.Size());
        List<Approval_History__c> updateAphList = New List<Approval_History__c>();
        for(Id key : rejectMap.keySet()){
            if(key == recId){
                Approval_History__c aph  = rejectMap.get(key);
                if(aph.Status__c == PENDING){
                    aph.Status__c = REJECTED;
                    aph.Action_Date__c = System.today();
                    aph.Approver_Comments__c = comments;
                    aph.Reason_for_rejection__c = RejectionReason;
                    aph.Approved_By__c = userInfo.getUserId();
                    aph.Action_taken__c = actionTaken == 'handheld' ?'Handheld device': actionTaken == 'Home'?'Home screen via desktop':'History via desktop';
                    updateAphList.add(aph);
                }
            }else{
                Approval_History__c aph  = rejectMap.get(key);
                if(aph.Status__c == PENDING){
                    aph.Status__c = NO_RESPONSE;
                    aph.Action_Date__c = System.today();
                    aph.Approved_By__c = UserInfo.getUserId();
                    updateAphList.add(aph);
                }
            }
        }
        
        if(updateAphList.Size() > 0){
            try{
                update updateAphList;
                updateStatusStage(optyId, REJECTED);
                sendRejectNotifications(optyId, status, gateName, orderNum, RejaphId);
            }catch(exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
        return true;
    }
    
    @AuraEnabled
    public static boolean reassignRecord(Id recId, String comments, String assignedTo,String actionTaken){
        Approval_History__c aphRec = [SELECT Id, Step_Name__c, key__c, TargetObjectId__c, Approved_By__c, Approver_Comments__c FROM Approval_History__c WHERE Id =: recId LIMIT 1][0];
        system.debug( 'Action'+ actionTaken);
        Id optyId = aphRec.TargetObjectId__c;
        
        Map<Id,Approval_History__c> aphMap = New Map<Id,Approval_History__c>([SELECT Id, Status__c, Key__c, Approver_Comments__c, Approved_By__c,Assigned_To__r.Id FROM Approval_History__c WHERE key__c =: aphRec.Key__c]);
        
        List<Approval_History__c> updateAphList = New List<Approval_History__c>();
        for(Id key : aphMap.keySet()){
            if(key == recId){
                Approval_History__c aph  = aphMap.get(key);
                if(aph.Status__c == PENDING && aph.Assigned_To__r.id != assignedTo){
                    aph.Status__c = REASSIGNED;
                    aph.Approver_Comments__c = comments;
                    aph.Action_Date__c = System.today();
                    aph.Approved_By__c = assignedTo;
                    aph.Action_taken__c = actionTaken == 'handheld' ?'Handheld device': actionTaken == 'Home'?'Home screen via desktop':'History via desktop';
                    updateAphList.add(aph);
                }
            }
            
        }
        if(updateAphList.Size() > 0){
            try{
                update updateAphList;
                List<Approval_History__c> lstofAPH = [SELECT Id, Step_Name__c,Approval_Step__r.Approval_Process_Name__r.Name, Approval_Step__r.Name, Approved_By__c, Approver_Comments__c, Assigned_To__c, SLA__c, Status__c, Submitter_Comments__c, TargetObjectId__c, key__c,Type__c,Submission_Order__c,Opportunity_Product__c,Process_Name__c,Delegated_approver__c from Approval_History__c where id =: aphRec.Id];
                CreateApprovalHistoryforReassigned(lstofAPH, assignedTo );
            }catch(exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
        return true;
    }
    
    @AuraEnabled
    public static boolean recallRecord(Id recId, String comments){
        Approval_History__c aphRec = [SELECT Id, Step_Name__c, key__c, TargetObjectId__c, Approved_By__c, Approver_Comments__c FROM Approval_History__c WHERE Id =: recId LIMIT 1][0];
        
        Id optyId = aphRec.TargetObjectId__c;
        Map<Id, Approval_History__c> aphMap = New Map<Id, Approval_History__c>([SELECT Id, Status__c, Step_Name__c, Key__c, Approver_Comments__c, Approved_By__c, Is_Action_taken__c FROM Approval_History__c WHERE Status__c =: PENDING AND TargetObjectId__c =: optyId ]);
        
        List<Approval_History__c> updateAphList = New List<Approval_History__c>();
        for(Id key : aphMap.keySet()){
            if(key == recId){
                Approval_History__c aph  = aphMap.get(key);
                if(aph.Status__c == PENDING){
                    aph.Status__c = RECALLED;
                    aph.Approver_Comments__c = comments;
                    aph.Approved_By__c = userInfo.getUserId();
                    aph.Is_Action_taken__c = true;
                    updateAphList.add(aph);
                }
            }else{
                Approval_History__c aph  = aphMap.get(key);
                if(aph.Status__c == PENDING){
                    aph.Status__c = RECALLED;
                    aph.Approved_By__c = UserInfo.getUserId();
                    updateAphList.add(aph);
                }
            }
        }
        
        if(updateAphList.Size() > 0){
            try{
                update updateAphList;
                updateStatusStage(optyId, RECALLED);
            }catch(exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
        return true;
    }
    
    @AuraEnabled
    public static void updateStatusStage(Id recordId, String ahStatus) {
        List<Opportunity> opty = [SELECT Id, Approval_Status__c, StageName FROM Opportunity where id = :recordId];
        List<Approval_History__c> pendingList = [SELECT Id, Status__c FROM  Approval_History__c WHERE Status__c =: 'Pending' AND TargetObjectId__c =: recordId]; 
        Map<String, String> statusStageMap = getNextValue(opty[0].Approval_Status__c, ahStatus);
        if(pendingList.Size() == 0 ){
            if(statusStageMap.containsKey('nextStatus')) { //&& statusStageMap.get('nextStatus') != null)
                opty[0].Approval_Status__c = statusStageMap.get('nextStatus');
                
                if(statusStageMap.containsKey('stageName') && statusStageMap.get('stageName') != null){
                    opty[0].StageName = statusStageMap.get('stageName');
                }
                System.debug('Opty Rec >> '+opty);
                update opty;
            }
        }
    }
    
    @AuraEnabled
    public static Map<String, String> getNextValue(String currentStatus, String ahStatus ){
        Map<String, String> valueStage = New Map<String, String>();
        Map<String, Approval_Status_Stage_Mapping__mdt> cmdtMap = Approval_Status_Stage_Mapping__mdt.getAll();
        for(String key :  cmdtMap.keySet()){
            Approval_Status_Stage_Mapping__mdt cmdt = cmdtMap.get(key);
            if( currentStatus == cmdt.Current_value__c && ahStatus == cmdt.Action__c){
                // if(cmdt.Next_value__c != null && cmdt.Next_value__c != '' ){
                valueStage.put('nextStatus', cmdt.Next_value__c);
                //}
                if(cmdt.StageName__c != null && cmdt.StageName__c != ''){
                    valueStage.put('stageName', cmdt.StageName__c);
                }
            }
        }
        return valueStage;
    }
    
    public static Void CreateApprovalHistoryforReassigned(List<Approval_History__c> lstofReassignedaph, String assignedTo){
        String DelegatedApprover = [select DelegatedApproverId from user where id =: assignedTo limit 1][0].DelegatedApproverId;
        list<Approval_History__c> insertaphList = new list<Approval_History__c>();
        Set<Id> apHistoryResultSuccessIds = new Set<Id>();
        for (Approval_History__c app : lstofReassignedaph){
            Approval_History__c ap = new Approval_History__c();
            ap.Step_Name__c=app.Step_Name__c;
            ap.Submitter_Comments__c = '';
            ap.TargetObjectId__c = app.TargetObjectId__c;
            ap.Status__c = 'Pending';
            ap.Approval_Step__c=app.Approval_Step__c;
            ap.key__c = app.key__c;
            ap.SLA__c=app.SLA__c;
            ap.Submission_Order__c = app.Submission_Order__c;
            ap.Type__c = 'Reassigned';
            ap.Approved_By__c = assignedTo;
            ap.Assigned_To__c = assignedTo;
            ap.Process_Name__c = app.Approval_Step__r.Approval_Process_Name__r.Name;
            if(DelegatedApprover != null){
                ap.Delegated_approver__c = DelegatedApprover;
            }
            insertaphList.add(ap);
        }
        if(insertaphList.Size() > 0){
            try{
                //TriggerExecutionController.skipApprovalHistoryTrigger(true);
                Database.SaveResult[] apHistoryResult = Database.insert(insertaphList, false);
                //TriggerExecutionController.skipApprovalHistoryTrigger(false);
                for (Database.SaveResult sr : apHistoryResult) {
                    if (sr.isSuccess()) {
                        apHistoryResultSuccessIds.add(sr.getId());
                        System.debug('Successfully inserted Approval History: ' + sr.getId());
                    }}
                CustomApprovalProcessHandler.sendEmailAlert(apHistoryResultSuccessIds);
            }catch(exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
    }
    public static void sendRejectNotifications(Id optyId, String status, String gateName, Decimal orderNum, Id RejaphId){
        String templateName = Label.Notify_Reject_Template;
        List<Approval_History__c> aphList = [SELECT Id, Name, Status__c, Gate_Name__c, Assigned_To__c, Assigned_To__r.Email,  Approved_By__r.Email FROM Approval_History__c WHERE TargetObjectId__c =: optyId AND Gate_Name__c =: gateName AND Status__c !=: REJECTED AND Submission_Order__c =: orderNum];
        Approval_History__c aphRejected = [SELECT Id, Name, Status__c, Gate_Name__c, Assigned_To__c, Assigned_To__r.Email,  Approved_By__r.Email FROM Approval_History__c WHERE Id =: RejaphId];
        EmailTemplate et = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where Name=:templateName limit 1];
        
        List<Messaging.SingleEmailMessage> emailList = New List<Messaging.SingleEmailMessage>();
        for(Approval_History__c ap : aphList){
            emailList.add(createEmail(aphRejected, et, ap.Assigned_To__r.Email));
        }
        messaging.sendEmail(emailList);
    }
    
    public static Messaging.SingleEmailMessage createEmail(Approval_History__c ap, EmailTemplate  et, string approverEmail){
        set<string>setEmailAddress = new set<String>();
        system.debug('approverEmail@@@@'+approverEmail);
        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
        emailMsg.setTemplateId(et.id);
        String[] toAddresses = new String[] {approverEmail};//,approverEmail
        emailMsg.setToAddresses(toAddresses);
        emailMsg.setTargetObjectId(ap.Assigned_To__c);
        emailMsg.setWhatId(ap.Id);
        emailMsg.setSaveAsActivity(false);
        emailMsg.setUseSignature(false);
        emailMsg.setTreatTargetObjectAsRecipient(false);
        //emailMsg.setReplyTo(ReplyEmailAddress);
        
        return emailMsg;
    }
}