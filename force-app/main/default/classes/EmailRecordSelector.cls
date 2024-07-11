/*
* Author   : Manohar@Maersk
* Purpose  : Centralize the record selection process for Email object.
*          Defines the methods which iterate and segregate the Email records for further use.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-2143     24-Mar-2020  Manohar@maersk         Created for implementing CBO (Centralized By Org) trigger architecture.
* 2.0      RQ-2138     20-Apr-2021  Sunilbs@maersk         Added Maps to get related parent and child Cases
* 3.0      SC-2492     20-May-2021  ramadevi@ust           Update Business hours fields after the status is updated upon closure
* 4.0      SC-5414     12-Jan-2022  Saradha@UST            Case trigger optimisation reduced SOQL query
* 5.0      SC-8488     20-July-2023  Vivek@UST             Added region__c ,country__c, Total_Outbound_Emails_minus_Handshake__c,Email_Recommendation_Acceptance__c and BDA code fields to query for email recommendation api call
*/
public class EmailRecordSelector implements RecordSelector {
    
    //To store all relatedCaseIds
    public set<Id> relatedParentIds=new Set<Id>();
    //To store email records
    public List<EmailMessage> emailRecords=new List<EmailMessage>();
    public Map<Id,Case> mapRelatedCases=new Map<Id,Case>();    
    //SC-2138
    public Map<Id,Case> mapRelatedChildCases=new Map<Id,Case>();
    public Map<Id,Case> mapRelatedParentCases=new Map<Id,Case>();
    private TriggerHandler emailTriggerHandler;
    public Map<Id,Id> emailCaseIdMap=new Map<Id,Id>();
    // SC-2492 : Pass the old Case record before updated in Email Trigger
    public Map<Id,Case> oldCaseValue=new Map<Id,Case>();
    public static Boolean stopSCMCollaborationFlow = false;
    
    public EmailRecordSelector(list<EmailMessage> emailRecords, map<Id, EmailMessage> mapOldEmails, TriggerHandler emailTriggerHandler) {
        this.emailTriggerHandler = emailTriggerHandler;
        this.selectRecords(emailRecords, mapOldEmails);
        
        if(emailRecords.size()>0) {
            this.getRelatedRecords(emailRecords);
        }
        
    }
    
    //Get related case records
    public void getRelatedRecords(list<sObject> emails) {
        for(EmailMessage email:(List<EmailMessage>)emails){
            if(email.ParentId != null){
                relatedParentIds.add(email.ParentId); 
            }
        }
        getRelatedCases();
    }
    
    //select email records
    public void selectRecords(list<sObject> emails, map<Id, sObject> mapOldCases) {
        this.emailRecords=(List<EmailMessage>)emails;
        if(emailRecords!=null){
            for(EmailMessage email:emailRecords){
                emailCaseIdMap.put(email.Id,email.ParentId);
            }
        }
    }
    public void getRelatedCases() {
        if(!relatedParentIds.isEmpty()) {
            //SC-2492 - Added few more fields to query for a fix
            //SC-8488 
            mapRelatedCases  = new map<Id, Case>([Select id, Artemis_Id__c, OwnerId, Resolver_Dept__c, CC_Flag__c,Origin,Count_Emails_From_Contact__c,
                                                  SuppliedEmail,Is_Resolved__c,Contact.Email,Count_Emails_To_Internal_Contact__c,New_Mail__c,Count_Emails_To_Contact__c,
                                                  Count_Case_Outbound_Email__c,Total_Outbound_Emails_minus_Handshake__c,Case_Channel__c,Priority,FCR_Post_Closure_Activity_Date__c,Count_Case_Emails__c,
                                                  Status, RecordType.DeveloperName, IsClosed, CreatedDate, ParentId,Product__c, Case_Reopened_Date_Time__c, 
                                                  Case_Reopen_Count__c,Case_Reopened__c,Liner_Brand__c,businessHoursId,Last_Status_Change__c,Age_In_Business_Hours__c,Time_First_Open__c,
                                                  Time_In_Progress__c,Case_Visibility__c,Country__r.name,Region__c,Region__r.BDA_Code__c,Email_Recommendation_Acceptance__c,createdbyId,
                                                  EntitlementId,Direction__c, RecordTypeId,SCV_Code__c,Additional_Teams_Involved__c,First_Queue_Owner_Id__c,CreatedBy.Name, Account.Name 
                                                  FROM Case where Id in :relatedParentIds]);
            for(Case cs: mapRelatedCases.values()){
                Case oldCase = new Case();
                oldCase.Id = cs.Id;
                oldCase.Status = cs.Status;
                oldCase.BusinessHoursId = cs.BusinessHoursId;
                oldCaseValue.put(oldCase.Id, oldCase);
            }
            
            //SC-2138 maps to get related parent and child cases.
            set<id> casesForParent = new set<id>();
            for(Case a :mapRelatedCases.values()){
                if(a.ParentId != null){
                    casesForParent.add(a.ParentId);      
                }
            }
            mapRelatedChildCases =  new map<Id, Case>([Select id, New_Mail__c,Status,RecordTypeId,Liner_Brand__c,EntitlementId from case where ParentId != null AND ParentId in :relatedParentIds]);
            if(!casesForParent.isEmpty()){
                mapRelatedParentCases = new map<Id, Case>([Select id, New_Mail__c,Status,RecordTypeId,Liner_Brand__c,EntitlementId from case where Id in :casesForParent]);    
            }
        }
    }
}