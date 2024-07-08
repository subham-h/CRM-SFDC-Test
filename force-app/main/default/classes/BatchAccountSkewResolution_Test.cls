/**
 * Test class for BatchAccountSkewResolution
 * 
 * Version     Date         Owner                      RQ#            Description
 ******************************************************************************************************  
 * 1.0                                                 #              Code created
 * 2.0         07-06-2022   Ronnie@SF                  SPI-100        Removed brand hardcodings
 */
@isTest
private class BatchAccountSkewResolution_Test {
    
    @testSetup
    static void testDataSetup() {
        
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.createExternalCases();
        List<Case> lstCases = CaseData_Test.lstCases;
        List<Case> lstUpdateCase = new List<Case>();
        
        for (Case newCase : lstCases ) {        
            newCase.type='Booking';
            newCase.Sub_Type__c='New Booking Request'; 
            newCase.Reason_For_Case__c = 'Booking Request';
            newCase.Liner_Brand__c  = BrandUtilities.MAERSKLINE;
            newCase.Country__c = BDAGeographyData_Test.countryRU.Id;
            newCase.Security_Code__c = '1235';
            lstUpdateCase.add(newCase);
        }
        update lstUpdateCase;
        System.debug('lstUpdateCase'+lstUpdateCase);
        
        Account testacc = [SELECT Id, Name FROM Account LIMIT 1];
        Skewed_Account_Records__c SkewAcc = new Skewed_Account_Records__c();
        SkewAcc.Name = testacc.Id;
        SkewAcc.Account_name__c = testacc.Name;
        SkewAcc.Case_count_Limit__c = 12;
        insert SkewAcc;
    }
    
    static testMethod void testBatch() {
        Test.startTest();
        TriggerExecutionController.skipAllTriggers(true);
        BatchAccountSkewResolution testobj = new BatchAccountSkewResolution();
        DataBase.executeBatch(testobj,100);
        TriggerExecutionController.skipAllTriggers(false);
        Test.stopTest();
    }
}