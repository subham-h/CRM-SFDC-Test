@isTest
public class caseMetricsControllerTest{
     static testMethod void casemetrics() {
        CaseData_Test.createExternalCases(); // create cases
        Case recCase = CaseData_Test.lstCases[0];
        recCase.Time_First_Open__c =234.56;
        recCase.Time_spent_in_Main_Queue_BH__c =234.56;
        recCase.Time_Awaiting_Colleague_Input__c =234.56;
        recCase.Time_Awaiting_Customer_Input__c =234.56;
        recCase.Total_Time_Awaiting_Vendor_Input_BH__c =234.56;
        recCase.Time_In_Progress__c =234.56;
        recCase.Time_New__c =234.56;
        recCase.Time_Triaged__c =234.56;
        update recCase;
        caseMetricsController.fieldDetails(recCase.id);                
    }
}