/****
* Story Number      Date        Owner                        Description
***********************************************************************************************
* 1.0		 SFSE-10677   29/04/2023     Jothsana/Ramya			Email Handler Class is created for Opportunity Approvals
* 2.0		 SFSE-11132	  26-Jul-2023	 Jothsana@Maersk		Delegated approver logic added
* 3.0		 SFSE-11158	  29-Aug-2023	 Jothsana@Maersk		Rejection Reasons logic is added
*/
global class OpportunityApprovalEmailHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        String Approved  = System.label.Status_Approved;
        String Rejected = System.label.Status_Rejected;
        String NoResponse = system.label.Status_No_Response;
        Id optyId;
        String gateName;
        String status;
        Decimal orderNum;
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        System.debug('result@@@ '+email.plainTextBody);
        try{
            string opportunityId = email.plainTextBody.replaceAll('%2F','/').split('my.salesforce.com/')[1].split('&data')[0];
            opportunityId = opportunityId.substring(0,18);
            //added to remove the new line coming in Test class which is being parsed as string. In original class , it is rich text
            if(opportunityId.contains('\n')){
                opportunityId = opportunityId.split('\n')[0];
            }
            string apInstanceId = email.plainTextBody.split('OR access Approval History link below')[1].replaceAll('%2F','/').split('my.salesforce.com/')[1].split('&data')[0];
            apInstanceId = apInstanceId.substring(0,18);
            string response = email.plainTextBody.split('\n')[0].containsIgnoreCase(Approved) ? Approved : (email.plainTextBody.split('\n')[0].containsIgnoreCase(Rejected) ? Rejected : 'No Action');
                
            string approverComments = email.plainTextBody.split('\n')[1].split('\n')[0];
            
            string approverAddress = email.FromAddress;
            
            List<Approval_History__c> updateApprovalList = new List<Approval_History__c>();
            set<string> setOfUniqueIds = new set<string>();
            Id actualApproverID; 
            
            List<Approval_History__c> approvalHistoryList = [select Id, Name,Reason_for_rejection__c,Action_Taken__c, Gate_Name__c, Status__c, Submission_Order__c, Step_Name__c, key__c,Delegated_approver__r.Email, TargetObjectId__c,Approver_Comments__c, Assigned_To__r.Email,Assigned_To__r.Id,Approved_By__r.Id from Approval_History__c where Status__c = 'Pending' and TargetObjectId__c =: opportunityId];
            if(response != 'No Action'){
                for(Approval_History__c aphRec: approvalHistoryList){
                    if(aphRec.Assigned_To__r.Email == approverAddress && aphRec.Id == apInstanceId){
                        aphRec.Status__c = response;
                        aphRec.Approver_Comments__c = approverComments;
                        if(response.containsIgnoreCase(Rejected)){
                            optyId = aphRec.TargetObjectId__c;
        					gateName = aphRec.Gate_Name__c;
        					status = aphRec.Status__c;
        					orderNum = aphRec.Submission_Order__c;
                        aphRec.Reason_for_rejection__c = 'Others, pls specify(make specifying mandatory)';
                        	if(string.isBlank(aphRec.Approver_Comments__c)){
                                aphRec.Approver_Comments__c = 'Decision via Email-No comments needed';
                            }
                        }
                        aphRec.Action_Date__c = System.today();
                        aphRec.Action_taken__c = 'Email';
                        setOfUniqueIds.add(aphRec.key__c);
                        actualApproverID = aphRec.Approved_By__r.Id;
                        updateApprovalList.add(aphRec);
                        
                    }else if(aphRec.Delegated_approver__r.Email == approverAddress && aphRec.Id == apInstanceId){
                        aphRec.Status__c = response;
                        aphRec.Approver_Comments__c = approverComments;
                        if(response.containsIgnoreCase(Rejected)){
                            optyId = aphRec.TargetObjectId__c;
        					gateName = aphRec.Gate_Name__c;
        					status = aphRec.Status__c;
        					orderNum = aphRec.Submission_Order__c;
                        aphRec.Reason_for_rejection__c = 'Others, pls specify(make specifying mandatory)';
                        	if(string.isBlank(aphRec.Approver_Comments__c)){
                                aphRec.Approver_Comments__c = 'Decision via Email-No comments needed';
                            }
                        }
                        aphRec.Action_Date__c = System.today();
                        aphRec.Action_taken__c = 'Email';
                        aphRec.Approved_By__c = aphRec.Delegated_approver__c;
                        setOfUniqueIds.add(aphRec.key__c);
                        actualApproverID = aphRec.Delegated_approver__c;
                        updateApprovalList.add(aphRec);
                    }
                    
                }
                // To update history record status as 'No Response' with same key
                for(Approval_History__c aphRec: approvalHistoryList){
                    if(setOfUniqueIds.contains(aphRec.key__c) && aphRec.Id != apInstanceId){
                        aphRec.Status__c = 'No Response';
                        aphRec.Action_Date__c = System.today();
                        aphRec.Action_taken__c = 'Email';
                        aphRec.Approved_By__c = actualApproverID;
                        updateApprovalList.add(aphRec);
                        
                    }
                    //To update other pending history record status as 'No response' if response is 'Rejected'
                    else if(response.containsIgnoreCase(Rejected) && !setOfUniqueIds.contains(aphRec.key__c) && actualApproverID != null){
                        aphRec.Status__c = NoResponse;
                        aphRec.Action_Date__c = System.today();
                        aphRec.Action_taken__c = 'Email';
                        aphRec.Approved_By__c = actualApproverID;
                        updateApprovalList.add(aphRec);
                        
                    }}
                
                if(!updateApprovalList.isEmpty()){
                    Database.SaveResult[] srList = Database.update(updateApprovalList, true);
                    ErrorLogger.writeErrors('SFDC', 'Email', 'Messaging.InboundEmailResult', srList, updateApprovalList);
                    if(response.containsIgnoreCase(Rejected)){
                        ApprovalHistoryController.sendRejectNotifications(optyId, status, gateName, orderNum, apInstanceId);
                    }
                    
                }
                
                System.debug('DML Limits #638 '+Limits.getDmlRows());
                TriggerExecutionController.skipAllTriggers(false);
                
                approvalHistoryList = [SELECT id, name FROM Approval_History__c WHERE TargetObjectId__c = :opportunityId AND Status__c = 'Pending'];
                System.debug('@@approvalHistoryList size '+approvalHistoryList.size());
                
                Opportunity oppty = [SELECT Id, Approval_Status__c, StageName, Products_for_Approval__c, Liner_Brand__c, owner.country, Owner_Area_Code__c from Opportunity where id = :opportunityId];
                
                //To update the opportunity based on response
                Opportunity opptyToUpdate = new Opportunity();
                if(approvalHistoryList.size() == 0){
                    
                    List<Approval_Status_Stage_Mapping__mdt> lstOfCustomMetaData = [select Id,Process_name__c,Current_value__c,Next_value__c,StageName__c from Approval_Status_Stage_Mapping__mdt where Current_value__c =: oppty.Approval_Status__c and Action__c=: response ];
                    
                    String approvalStatus =lstOfCustomMetaData[0].Next_value__c;
                    String StageName = lstOfCustomMetaData[0].StageName__c;
                    opptyToUpdate.Id = oppty.Id;
                    opptyToUpdate.Approval_Status__c = approvalStatus;
                    if(StageName!=null){
                        opptyToUpdate.StageName = StageName;
                    }
                    List<Opportunity> lstopptyToUpdate = new List<Opportunity>();
                    lstopptyToUpdate.add(opptyToUpdate);
                    System.debug('DML Limits #654 '+Limits.getDmlRows());
                    
                    TriggerExecutionController.skipAllTriggers(true);
                    if(!lstopptyToUpdate.isEmpty()){
                        Database.SaveResult[] srList = Database.update(lstopptyToUpdate, true);
                        ErrorLogger.writeErrors('SFDC', 'Email', 'Messaging.InboundEmailResult', srList, lstopptyToUpdate);
                    }
                    TriggerExecutionController.skipAllTriggers(false);
                    
                    System.debug('DML Limits #658 '+Limits.getDmlRows());
                }
                
            }}
        catch(Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
            system.debug('Exception cause: '+e.getCause());
            ErrorLogger.writeErrors( 'SFDC', 'Email', 'Messaging.InboundEmailResult', new list<Exception>{e});
        }
        return result;
        
    }
    
}