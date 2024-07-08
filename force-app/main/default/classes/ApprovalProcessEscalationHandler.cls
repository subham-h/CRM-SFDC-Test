/****
* Version  Story Number      Date        Owner                        Description
***********************************************************************************************
* 1.0 		SFSE-9733     13/01/2023    Bharti&Aditi            Apex class for PEP escalation 
* 2.0 		SFSE-10492    22/05/2023	Rama Krishna Jannu		Apex class for PEP escalation & added new logic logic for escalation records 
* 3.0		SFSE-11845	  03-Aug-2023   Jothsana@Maersk			Delegated Approver logic added
* 4.0		SFSE-14118	  11-Mar-2024   Jothsana@Maersk			Removing Maersk Flow(MF1) from OMEB 
*/


public class ApprovalProcessEscalationHandler {
    
    public static Map<Id, Opportunity> opportunitySubmitted;
    public static List<Approval_History__c> pendingappRecords;
    public static List<Approval_History__c> escalationappRecords;
    public static List<Approval_Process_Escalation_Matrix__c> appProcEscList;
    public static List<String> excludeProducts;
    public static EmailTemplate et;
    public static Integer notifSLA;
    public static Integer approverSLA;
    public static Map<string, List<Approval_Process_Escalation_Matrix__c>> mapOfApprovalMatrix;
    public static List<Approval_History__c> lstapprovalhistory;
    public static string ReplyEmailAddress = system.label.Opportunity_Approval_Email_Address;
    
    
    public ApprovalProcessEscalationHandler(){
        opportunitySubmitted = new Map<Id, Opportunity>();
        pendingappRecords = new List<Approval_History__c>();
        escalationappRecords = new List<Approval_History__c>();
        lstapprovalhistory = new List<Approval_History__c>();
        appProcEscList = new List<Approval_Process_Escalation_Matrix__c>();
        mapOfApprovalMatrix =new Map<string, List<Approval_Process_Escalation_Matrix__c>>();
        et= [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where Name='OMEB_EscalateEmail' limit 1];
    }
    
    public void escalate(List<Opportunity> opps){
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Map<Id,Id> mapofapphisMatrx = new Map<Id,Id>();
        Map<Id,Approval_Process_Escalation_Matrix__c> mapofapphisMatrxlist = new Map<Id,Approval_Process_Escalation_Matrix__c>();
        set<Id> appIds = new Set<Id>();
        Map<Id,List<Approval_History__c>> mapofescalationrecords = new Map<Id,List<Approval_History__c>>();
        for(Opportunity opp:opps){
            opportunitySubmitted.put(opp.Id, opp);
        }
        
        
        pendingappRecords = [SELECT TargetObjectId__c, Submitter_Comments__c,createdById,Approval_Step__r.Approval_Process_Name__r.sla__c,Key__c,Approval_Step__r.Escalation_owner__c,Approval_Step__r.Escalation_owner__r.Email,Approval_Step__r.Escalation_owner__r.UserPreferencesReceiveNoNotificationsAsApprover,
                             Step_Name__c,Approval_Step__r.Escalation_owner__r.DelegatedApproverId, Status__c, Name, IsDeleted, Id,CreatedDate,Approved_By__r.Email,Approval_Step__r.Step_Name__c,Submission_Order__c,
                             Approver_Comments__c, Approval_Step__r.Current_owner__r.name,Approval_Step__r.Approval_Process_Name__r.name,Approved_By__r.Name,
                             Approval_Step__r.Approval_Process_Name__r.Gate__c, Action_Date__c,TargetObjectId__r.Products_for_Approval__c,Process_Name__c FROM Approval_History__c
                             WHERE Status__c = 'Pending'  AND TargetObjectId__c IN:opportunitySubmitted.keySet()];
        
        escalationappRecords = [SELECT TargetObjectId__c, Submitter_Comments__c,createdById,Approval_Step__r.Approval_Process_Name__r.sla__c,Key__c,Approval_Step__r.Escalation_owner__c,Approval_Step__r.Escalation_owner__r.Email,Approval_Step__r.Escalation_owner__r.UserPreferencesReceiveNoNotificationsAsApprover,
                                Step_Name__c, Status__c,Approval_Step__r.Escalation_owner__r.DelegatedApproverId, Name, IsDeleted, Id,CreatedDate,Approved_By__r.Email,Approval_Step__r.Step_Name__c,Submission_Order__c,
                                Approver_Comments__c, Approval_Step__r.Current_owner__r.name,Approval_Step__r.Approval_Process_Name__r.name,Approved_By__r.Name,
                                Approval_Step__r.Approval_Process_Name__r.Gate__c, Action_Date__c,TargetObjectId__r.Products_for_Approval__c,Process_Name__c FROM Approval_History__c
                                WHERE Type__c='Escalation' AND Status__c = 'Pending' AND TargetObjectId__c IN:opportunitySubmitted.keySet()];
        system.debug('pending records are'+pendingappRecords);
        
        
        for(Approval_History__c ah : pendingappRecords){
            appIds.add(ah.Approval_Step__c);
        }
        
        if(!escalationappRecords.isEmpty()){
            for(Approval_History__c ah : escalationappRecords){
                if(mapofescalationrecords.containsKey(ah.TargetObjectId__c)){
                    mapofescalationrecords.get(ah.TargetObjectId__c).add(ah);
                }else{
                    mapofescalationrecords.put(ah.TargetObjectId__c,new List<Approval_History__c> {ah});
                }
            }
        }
        
        //Getting data from Approval Process Escalation Matrix 
        appProcEscList = [Select Id, Escalation_owner__c,Step_Name__c,Key__c, Approval_Process_Name__r.name,Process_Name__c, Current_owner__c, Current_owner__r.Name, Current_owner__r.Email, Escalation_Owner__r.Email, Area_code__c, Product_for_approval__c from Approval_Process_Escalation_Matrix__c where Id IN:appIds];
        
        //Mapping Approval Matrix records according to Approval Process Names
        for(Approval_Process_Escalation_Matrix__c appRec :appProcEscList ){
            mapofapphisMatrxlist.put(appRec.Id,appRec);
            
        }
        system.debug('check--2'+mapofapphisMatrxlist);
        
        set<Id> setOfsubmittedIds = new set<Id>();
        for(Approval_History__c pi  : pendingappRecords){
            setOfsubmittedIds.add(pi.createdById);
            mapofapphisMatrx.put(pi.Id,pi.Approval_Step__c);
        }
        Map<Id,User> mapOfUserRecs = new Map<id,User>([select Id, TimeZoneSidKey FROM User where Id In : setOfsubmittedIds ]);
        //Iterating through all the pending approval requests
        for(Approval_History__c pi  : pendingappRecords){
            if(!mapofescalationrecords.containsKey(pi.TargetObjectId__c)){ 
                Integer noOfDaysElapsed = getElapsedDays(pi);
                
                if(Test.isRunningTest()){
                    ApproverSLA = 6;
                    NotifSLA = -1;
                }
                system.debug('noOfDaysElapsed'+noOfDaysElapsed);
                system.debug('noOfDaysElapsed'+ApproverSLA);
                
                String productForApprval = pi.TargetObjectId__r.Products_for_Approval__c;
                String regpattern = 'CL\\d+';
                Pattern rp = pattern.compile(regpattern);
                Matcher m = rp.matcher(productForApprval);
                
                // comparing no. of days elapsed and approver sla and updating approver sla notification date 
                if((!(m.matches())) && !(pi.Step_Name__c.contains(' CL') && !pi.TargetObjectId__r.Products_for_Approval__c.Contains('WD') && !pi.TargetObjectId__r.Products_for_Approval__c.Contains('CS'))){
                    
                    if( noOfDaysElapsed >= pi.Approval_Step__r.Approval_Process_Name__r.sla__c){
                        system.debug('here into');
                        Approval_History__c appHrec = new Approval_History__c();
                        appHrec.Type__c='Escalation';
                        appHrec.Step_Name__c=pi.Step_Name__c;
                        appHrec.TargetObjectId__c =  pi.TargetObjectId__c;
                        appHrec.Status__c = 'Pending';
                        appHrec.Approval_Step__c=pi.Approval_Step__c;
                        appHrec.key__c = pi.key__c;
                        appHrec.SLA__c=pi.Approval_Step__r.Approval_Process_Name__r.sla__c;
                        appHrec.Submission_Order__c = pi.Submission_Order__c;
                        appHrec.Process_Name__c = pi.Approval_Step__r.Approval_Process_Name__r.Name;
                        appHrec.Approved_By__c=pi.Approval_Step__r.Escalation_owner__c;
                        appHrec.Assigned_To__c=pi.Approval_Step__r.Escalation_owner__c;
                        if(pi.Approval_Step__r.Escalation_owner__r.DelegatedApproverId != null){
                            appHrec.Delegated_approver__c = pi.Approval_Step__r.Escalation_owner__r.DelegatedApproverId;
                        }    
                        lstapprovalhistory.add(appHrec);
                        pi.Status__c = 'Pending';
                        lstapprovalhistory.add(pi);
                        
                    }
                }
            }
        }
        try {
            
            if(lstapprovalhistory.size() > 0){
                system.debug('--'+lstapprovalhistory);
                upsert lstapprovalhistory;
            }
            List<Approval_History__c> approverList = [SELECT Id, Approved_By__c,Approved_By__r.UserPreferencesReceiveNoNotificationsAsApprover, TargetObjectId__c, Assigned_To__r.Email,Delegated_Approver__r.Email,Delegated_approver__r.UserPreferencesReceiveNotificationsAsDelegatedApprover, Assigned_To__r.UserPreferencesReceiveNoNotificationsAsApprover FROM Approval_History__c WHERE Id IN : lstapprovalhistory ];
            	   
            for(Approval_History__c ap : approverList){
                   
                if(ap.Assigned_To__r.UserPreferencesReceiveNoNotificationsAsApprover == false){
                    emailList.add(createEmail(ap,et,ap.Assigned_To__r.Email));
                }
                if(ap.Delegated_approver__c != null && ap.Delegated_approver__r.UserPreferencesReceiveNotificationsAsDelegatedApprover == true){
                    emailList.add(createEmail(ap,et,ap.Delegated_Approver__r.Email));
                }}
            if(emailList.size() > 0){
                Messaging.sendEmail(emailList,false);
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            
            
            
        }       
        
    }
    
    
    //Calculating number of working days elapsed since opportunity was submitted for approval
    public Integer getElapsedDays(Approval_History__c pi){
        //Converting DateTime to Date 
        Date piDate =date.newInstance(pi.CreatedDate.year(),pi.CreatedDate.month(),pi.CreatedDate.day());
        Integer noOfDaysElapsed = piDate.daysBetween(Date.today());
        
        System.debug('noOfDaysElapsed '+   noOfDaysElapsed);
        //noOfDaysElapsed now has the total count of all days between submitted date and today
        
        return noOfDaysElapsed;
    }
    
    
    
    // logic to make the time user specific 
    public static DateTime convertToTimeZone(Datetime dt, String locale) {
        Integer msPerHour = 1000 * 60 * 60;
        return dt.addHours(
            TimeZone.getTimeZone(locale).getOffset(dt) / msPerHour
        );
    }
    
    public static Messaging.SingleEmailMessage createEmail(Approval_History__c ap, EmailTemplate  et, string approverEmail){
        set<string>setEmailAddress = new set<String>();
        system.debug('approverEmail@@@@'+approverEmail);
        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
        //  EmailTemplate et2 = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where Name='OMEB_ApprovalHistory' limit 1];
        
        emailMsg.setTemplateId(et.id);
        List<String> toAddresses = new list<String>();//,approverEmail
        toAddresses.add(approverEmail);
        emailMsg.setToAddresses(toAddresses);
        emailMsg.setTargetObjectId(ap.Approved_By__c);
        emailMsg.setWhatId(ap.Id);
        emailMsg.setSaveAsActivity(false);
        emailMsg.setUseSignature(false);
        emailMsg.setTreatTargetObjectAsRecipient(false);
        emailMsg.setReplyTo(ReplyEmailAddress);
        
        return emailMsg;
        
    }
}