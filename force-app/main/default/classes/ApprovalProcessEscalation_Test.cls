/****
* Story Number      Date        Owner                        Description
***********************************************************************************************
*  SFSE-9733        19/01/2023    Bharti&Aditi            Code Created
*/

@isTest
public class ApprovalProcessEscalation_Test {
     @testSetup
    static void loadData(){
        List<opportunity>oppList = new List<opportunity>();
        Id currentApproverId = [SELECT Id FROM user WHERE IsActive = true AND Profile.Name = 'Sales' LIMIT 1][0].Id;
        Id EscalationApproverId = [SELECT Id FROM user WHERE IsActive = true AND Profile.Name = 'Sales' and DelegatedApproverId != null LIMIT 1 OFFSET 1][0].Id;
        String clientRecordTypeID = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Client Account').getRecordTypeId();
        System.debug('Account Record Type >> '+clientRecordTypeID);
        EmailTemplate et = [select id from EmailTemplate limit 1];
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
        opp.CloseDate = System.today()+30;
        opp.StageName = 'Identifying';
        opp.Approval_Status__c = '';
        opp.Estimated_Agreement_Duration__c = 36;
        opp.Requires_IT_Integration__c = 'Yes, I am sure this is required basis my discussion with customer';
        opp.Liner_Brand__c = 'Maersk Line';
        opp.Products_for_Approval__c='CCL2;CS09';
        oppList.add(opp);
        insert opp;
        
        Approval_Process__c ap = New Approval_Process__c();
        ap.Name = 'Pursuit Gate Sales Maersk';
        ap.Sub_Gate__c = 'Sales';
        ap.Active__c = true;
        ap.Gate__c = 'Pursuit';
        ap.Order__c = 4;
        ap.SLA__c = -1;
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
        ahOne.Step_Name__c  = 'Pursuit Sales-Maersk-(United Kingdom, Lifestyle)';
        ahOne.Approval_Step__c  = ape.Id;
        ahOne.Status__c = 'Pending';
        ahOne.TargetObjectId__c = opp.Id;
        ahOne.Approved_By__c = currentApproverId;
        ahOne.Assigned_To__c = currentApproverId;
        aphList.add(ahOne);
        Approval_History__c ahSecond = New Approval_History__c();
        ahSecond.Step_Name__c  = 'Pursuit Sales-Maersk-(United Kingdom, Lifestyle)';
        ahSecond.Approval_Step__c  = ape.Id;
        ahSecond.Status__c = 'Pending';
        ahSecond.TargetObjectId__c = opp.Id;
        ahSecond.Approved_By__c = EscalationApproverId;
        ahSecond.Assigned_To__c = EscalationApproverId;
        aphList.add(ahSecond);
      /*  Approval_History__c ahThird = New Approval_History__c();
        ahThird.Step_Name__c  = 'Pursuit Sales-Maersk-(United Kingdom, Lifestyle)';
        ahThird.Approval_Step__c  = ape.Id;
        ahThird.Type__c='Escalation';
        ahThird.Status__c = 'Pending';
        ahThird.TargetObjectId__c = opp.Id;
        ahThird.Approved_By__c = currentApproverId;
        ahThird.Assigned_To__c = currentApproverId;
        aphList.add(ahThird);*/
        insert aphList;
        
        ApprovalProcessEscalationHandler ape1 = new ApprovalProcessEscalationHandler();
        ape1.escalate(oppList);
        ApprovalProcessEscalationHandler.createEmail(aphList[0],et,'test@gmail.com');
        Datetime myDateTime = Datetime.newInstance(2023, 06, 27);
        ApprovalProcessEscalationHandler.convertToTimeZone(myDateTime,'English');
    }
    
      
    static testMethod void test_BatchOfApprovalProcess(){
        Test.startTest();
        List<Opportunity> optyRecList =[select Id, Products_for_Approval__c, Owner_Area_Code__c, Total_GP_of_OMEB_Products__c from opportunity limit 1];
        system.debug('optyRecList size'+optyRecList.size());
        List<Approval_History__c> aph = [Select TargetObjectId__c, Submitter_Comments__c,createdById,Approval_Step__r.Approval_Process_Name__r.sla__c,Key__c,Approval_Step__r.Escalation_owner__c,Approval_Step__r.Escalation_owner__r.Email,
                             Step_Name__c, Status__c, Name, IsDeleted, Id,CreatedDate,Approved_By__r.Email,Approval_Step__r.Step_Name__c,
                             Approver_Comments__c, Approval_Step__r.Current_owner__r.name,Approval_Step__r.Approval_Process_Name__r.name,Approved_By__r.Name,
                             Approval_Step__r.Approval_Process_Name__r.Gate__c, Action_Date__c,TargetObjectId__r.Products_for_Approval__c FROM Approval_History__c ];
        aph[0].Type__c = 'Escalation';
        update aph;
       
       
        
        
        Test.stopTest();
        
    }
    
    static testMethod void test_BatchOfApprovalProcess2(){
        Test.startTest();
        List<Opportunity> optyRecList =[select Id, Products_for_Approval__c, Owner_Area_Code__c, Total_GP_of_OMEB_Products__c from opportunity limit 1];
        system.debug('optyRecList size'+optyRecList.size());
        List<Approval_History__c> aph = [Select TargetObjectId__c, Submitter_Comments__c,createdById,Approval_Step__r.Approval_Process_Name__r.sla__c,Key__c,Approval_Step__r.Escalation_owner__c,Approval_Step__r.Escalation_owner__r.Email,
                             Step_Name__c, Status__c, Name, IsDeleted, Id,CreatedDate,Approved_By__r.Email,Approval_Step__r.Step_Name__c,
                             Approver_Comments__c, Approval_Step__r.Current_owner__r.name,Approval_Step__r.Approval_Process_Name__r.name,Approved_By__r.Name,
                             Approval_Step__r.Approval_Process_Name__r.Gate__c, Action_Date__c,TargetObjectId__r.Products_for_Approval__c FROM Approval_History__c ];
        
        
        //Database.executeBatch(new Batch_Escalation_ApprovalProcess(null));
        Test.stopTest();
        
    }
     static testMethod void test_BatchOfApprovalProcess3(){
         Test.startTest();
        List<Opportunity> optyRecList =[select Id, Products_for_Approval__c, Owner_Area_Code__c, Total_GP_of_OMEB_Products__c from opportunity limit 1];
         set<Id> optyIds = new Set<Id>{optyRecList[0].Id};
         system.debug('optyRecList size'+optyRecList.size());
        List<Approval_History__c> aph = [Select TargetObjectId__c, Submitter_Comments__c,createdById,Approval_Step__r.Approval_Process_Name__r.sla__c,Key__c,Approval_Step__r.Escalation_owner__c,Approval_Step__r.Escalation_owner__r.Email,
                             Step_Name__c, Status__c, Name, IsDeleted, Id,CreatedDate,Approved_By__r.Email,Approval_Step__r.Step_Name__c,
                             Approver_Comments__c, Approval_Step__r.Current_owner__r.name,Approval_Step__r.Approval_Process_Name__r.name,Approved_By__r.Name,
                             Approval_Step__r.Approval_Process_Name__r.Gate__c, Action_Date__c,TargetObjectId__r.Products_for_Approval__c FROM Approval_History__c ];
       
        Database.executeBatch(new Batch_Escalation_ApprovalProcess(optyIds));
       // Batch_Escalation_ApprovalProcess b = new Batch_Escalation_ApprovalProcess(null);
       // database.executebatch(b,Integer.valueOf(System.Label.BtachSizeForEscalationApprovalClass));
        Test.stopTest();
        
    }
   

}