@isTest
Private class CaseThreadTokenCtrlTest {
    @testSetup
    static void testDataSetup() {
        TriggerExecutionController.skipAllTriggers(true);
        ContactData_Test.createInternalContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email = 'test@maersk.com';
        update conInstance;
        
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.createExternalCases();
        CaseData_Test.conInstance = conInstance;
        list<Case> lstCases = CaseData_Test.lstCases;
        list<Case> lstUpdateCase = new list<Case>();
        General_Settings__c settings = General_Settings__c.getOrgDefaults();
        settings.Case_Email_Survey_Expiry__c = 7;
        upsert settings custSettings__c.Id;
        for(Case newCase : lstCases ) {
            newCase.Status ='Closed - Resolved';
            newCase.Resolution_Summary__c = 'Resolved'; 
            newCase.Send_Case_Closure__c ='No';
            newCase.Case_Closure_Opt_Out_Reason__c  = 'Technical limitations';
            newCase.type='Booking';
            newCase.Sub_Type__c='New Booking Request'; 
            newCase.Reason_For_Case__c = 'Booking Request';
            newCase.Liner_Brand__c  = BrandUtilities.MAERSKLINE;
            newCase.Country__c = BDAGeographyData_Test.countryRU.Id;
            newCase.Security_Code__c = '1235'; 
            newCase.ContactId = conInstance.Id;
            lstUpdateCase.add(newCase);
        }
        update lstUpdateCase;     
        TriggerExecutionController.skipAllTriggers(false);
    }
    @isTest
    public static void testCaseSurvey() {
        
        Case testCase = [SELECT Id, CaseNumber, ContactEmail,ContactId,closeddate, Security_Code__c, ContactMobile FROM Case][0];
        Test.startTest();
        CaseThreadTokenCtrl csTkThCtrlObj=new CaseThreadTokenCtrl();  
        csTkThCtrlObj.caseIdFromComp=testCase.Id;
        System.assertNotEquals(null, csTkThCtrlObj.getThreadId());
        Test.stopTest();
    }
}