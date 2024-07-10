/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      RQ-007189   21-Feb-2019 Meghana.Gupta@UST       Code created
*/

@isTest
public class ApprovalRequestTrigger_Test {
    @testSetup static void dataSetup() {
        
        CaseData_Test.createExternalCases(); // create cases
        
        // change case status to in progress
        Case recCase = CaseData_Test.lstCases[0];
        recCase.Status = 'In Progress';
        update recCase;
        
        // create exchange rate records
        ExchangeRateData_Test.createExchageRates();        
    }
    
    public static testMethod void test_ApprovalRequestTrigger() {
    
        List<Case> lstCases = [SELECT Id FROM Case LIMIT 1];        
        List<Approval_Request__c> lstARs = new List<Approval_Request__c>();
                 
        Id claimApprovalRTId = StaticFactory.getRecordTypeIdByName('Approval_Request__c', 'D&D Waiver'); // get record type id
        
        for(integer i = 0; i< 3; i++) {
            
            Approval_Request__c recAppRequet = new Approval_Request__c();
            recAppRequet.Approval_Status__c = 'New';
            recAppRequet.Bill_of_Lading_Number__c = '919191919';
            recAppRequet.Requested_Amount_Currency__c = 'INR';
            recAppRequet.Requested_Amount__c = 1000;
            recAppRequet.SFDC_Approver__c = UserInfo.getUserId();
            recAppRequet.Number_of_Extra_Days_Requested__c = 2;
            recAppRequet.RecordTypeId = claimApprovalRTId;
            recAppRequet.Case__c = lstCases[0].Id;
            lstARs.add(recAppRequet);
        }
        lstARs[1].Approved_Amount__c = 900;
        lstARs[1].Approved_Amount_Currency__c = 'INR';
                
        Test.startTest();
        
        // test insert
        insert lstARs;
        
        // test update
        lstARs[0].Approved_Amount__c = 990;
        lstARs[0].Approved_Amount_Currency__c = 'INR';
        update lstARs[0];
        Test.stopTest();
        
        Approval_Request__c rec = [SELECT Converted_Approved_Amount_USD__c FROM Approval_Request__c WHERE id = :lstARs[0].Id];
        system.assert(rec.Converted_Approved_Amount_USD__c != null);
        
    }
}