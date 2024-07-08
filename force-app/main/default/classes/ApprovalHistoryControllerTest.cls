@isTest
public class ApprovalHistoryControllerTest {
    @testSetup
    static void loadData(){
        
        Id currentApproverId = [SELECT Id FROM user WHERE IsActive = true AND Profile.Name = 'Sales' LIMIT 1][0].Id;
        Id EscalationApproverId = [SELECT Id FROM user WHERE IsActive = true AND Profile.Name = 'Sales' and DelegatedApproverId != null LIMIT 1 OFFSET 1][0].Id;
        String clientRecordTypeID = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Client Account').getRecordTypeId();
        System.debug('Account Record Type >> '+clientRecordTypeID);
        Account acc = New Account();
        acc.Name = 'Test Acc';
        acc.RecordTypeId = clientRecordTypeID;
        acc.Vertical__c = 'Lifestyle';
        //acc.Active__c = true;
        acc.Non_Profit_Customer__c = 'No';
        insert acc;
        
        String scRecordTypeID = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Supply Chain Services').getRecordTypeId();
        Opportunity opp = New Opportunity();
        Opp.Name = 'Test Opty';
        opp.RecordTypeId = scRecordTypeID;
        opp.AccountId = acc.Id;
        opp.Type = 'Acquistion';
        opp.Liner_Brand__c = 'Maersk Line';
        opp.CloseDate = System.today()+30;
        opp.StageName = 'Identifying';
        opp.Approval_Status__c = 'Submitted - Pursuit Gate';
        opp.Estimated_Agreement_Duration__c = 36;
        opp.Requires_IT_Integration__c = 'Yes, I am sure this is required basis my discussion with customer';
        insert opp;
        
        Approval_Process__c ap = New Approval_Process__c();
        ap.Name = 'Pursuit Gate Sales Maersk';
        ap.Sub_Gate__c = 'Sales';
        ap.Active__c = true;
        ap.Gate__c = 'Pursuit';
        ap.Order__c = 4;
        ap.SLA__c = 4;
        insert ap;
            
        Geography__c country = New Geography__c();
        country.Name = 'United Kingdom';
        country.Active__c = true;
        country.Type_Of_Location__c = 'Country';
        insert country;     
        
        Approval_Process_Escalation_Matrix__c ape = New Approval_Process_Escalation_Matrix__c();
        ape.Approval_Process_Name__c = ap.Id;
        ape.Step_Name__c = 'Pursuit Sales-Maersk-(United Kingdom, Lifestyle)';
        ape.Area_code__c = 'UKI';
        ape.Country__c = country.Id;
        ape.Current_owner__c = currentApproverId;
        ape.Escalation_owner__c = EscalationApproverId;
        ape.Gate_Name__c = 'Pursuit';
        ape.Region__c = 'Europe Region';
        ape.Vertical__c = 'LifeStyle';
        insert ape;
        
        List<Approval_History__c> aphList = New List<Approval_History__c>();
        Approval_History__c ahOne = New Approval_History__c();
        ahOne.Step_Name__c  = 'Pursuit Products-LL-(United Kingdom, Lifestyle)';
        ahOne.Approval_Step__c  = ape.Id;
        ahOne.Status__c = 'Pending';
        ahOne.TargetObjectId__c = opp.Id;
        ahOne.Approved_By__c = currentApproverId;
        ahOne.Assigned_To__c = currentApproverId;
        aphList.add(ahOne);
        Approval_History__c ahSecond = New Approval_History__c();
        ahSecond.Step_Name__c  = 'Pursuit Products-LL-(United Kingdom, Lifestyle)';
        ahSecond.Approval_Step__c  = ape.Id;
        ahSecond.Status__c = 'Pending';
        ahSecond.TargetObjectId__c = opp.Id;
        ahSecond.Approved_By__c = EscalationApproverId;
        ahSecond.Assigned_To__c = EscalationApproverId;
        aphList.add(ahSecond);
        insert aphList;
        
    }
    
    @isTest
    public static void approveTest(){
        Id OpportunityId = [SELECT Id FROM Opportunity LIMIT 1][0].Id;
        ApprovalHistoryController.getApprovalHistory(OpportunityId);
        ApprovalHistoryController.getApprovalHistoryPending();
        
        Id ahId = [SELECT Id FROM Approval_History__c LIMIT 1][0].Id;
        ApprovalHistoryController.approveRecord(ahId, 'Test Approved','true');
        
    }
    
    @isTest
    public static void rejectTest(){
        Id ahId = [SELECT Id FROM Approval_History__c LIMIT 1][0].Id;
        ApprovalHistoryController.rejectRecord(ahId, 'Test Rejected','true','Others, pls specify(make specifying mandatory)');
    }
    
    @isTest
    public static void reassignTest(){
        Id ahId = [SELECT Id FROM Approval_History__c LIMIT 1][0].Id;
        string ahassignedTo = [SELECT Assigned_To__c FROM Approval_History__c LIMIT 2][1].Assigned_To__c;
        ApprovalHistoryController.reassignRecord(ahId, 'Test Reassign', ahassignedTo,'true');
    }
    
    @isTest
    public static void recallTest(){
        Id ahId = [SELECT Id FROM Approval_History__c LIMIT 1][0].Id;
        ApprovalHistoryController.recallRecord(ahId, 'Test Recalled');
    }
}