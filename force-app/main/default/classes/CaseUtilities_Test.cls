/**
* Author   : Nirmal Christopher
* Purpose  : Test Class to cover Case Utilities 
*            
* Revision  Ref Number  Date            Owner                           Description
* --------  ----------  -----------     -------------------             --------------------------------------------------------
* 1.0       #RQ-003805  19-Dec-2016     Nirmal@UST                      Test to cover CaseUtilities 
* 2.0       RQ-009910   18-02-2019      Sreya@Maersk                    Test to Cover DMLOptionsUtility for MyFinance Dispute cases.
 * 3.0       SPI-100     09-06-2022      Ronnie@SF                       Removed brand hardcoding
*/

@isTest
public class CaseUtilities_Test {
    
    // Method covers CaseUtilities & DMLOptionsUtility 
    @isTest
    public static void test_fireAssignmentAndAutoResponse() {
        CaseData_Test.createExternalCases();
        
        Test.startTest();
        CaseUtilities.fireAssignmentAndAutoResponse(new set<Id>{CaseData_Test.lstCases[0].Id});
        Test.stopTest();
    }
    
    //RQ-009910- Method covers  DMLOptionsUtility 
    // Commented This test method as 'fireAutoResponse' method is not present in CaseUtilities class - 30/01/2020 By Avinash Gabale
    /*public static testMethod void test_AutoResponse() {
            CaseData_Test.createMyFinanceDisputecases();
            Test.startTest();
            system.debug('test case'+CaseData_Test.lstCases[0].Id);
            CaseUtilities.fireAutoResponse(new set<Id>{CaseData_Test.lstCases[0].Id});
            Test.stopTest();
    }*/
    
    @isTest
    public static void test_fieldsChanged() {
        list<String> lstFieldAPINames = new list<String>{'Status', 'Subject', 'Type'};
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.createExternalCases();
        
        Test.startTest();
        Boolean bChanged = CaseUtilities.fieldsChanged(CaseData_Test.lstCases[0], CaseData_Test.lstCases[1], lstFieldAPINames);
        System.assertEquals(bChanged, true);
        Test.stopTest();
    }
    
    @isTest
    public static void test_getLinerBrandLogic() {
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.createExternalCases();
        Case caseInstance = CaseData_Test.lstCases[0];
        
        Test.startTest();
        String strResult = CaseUtilities.getLinerBrandLogic(caseInstance);
        System.assertEquals(strResult, BrandUtilities.MAERSKLINE);
        
        caseInstance.MLL__c = true;
        strResult = CaseUtilities.getLinerBrandLogic(caseInstance);
        System.assertEquals(strResult, BrandUtilities.USFLAG);
        
        caseInstance.MLL__c = false;
        /*caseInstance.Liner_Brand__c = BrandUtilities.SAFMARINE;
        strResult = CaseUtilities.getLinerBrandLogic(caseInstance);
        System.assertEquals(strResult, BrandUtilities.SAFMARINE);*/
        
        caseInstance.Liner_Brand__c = BrandUtilities.SEALAND;
        strResult = CaseUtilities.getLinerBrandLogic(caseInstance);
        System.assertEquals(strResult, BrandUtilities.SEALAND);
        
        caseInstance.Liner_Brand__c = BrandUtilities.MCC;
        strResult = CaseUtilities.getLinerBrandLogic(caseInstance);
        System.assertEquals(strResult, BrandUtilities.MCC);
        
        caseInstance.Liner_Brand__c = BrandUtilities.SEAGO;
        strResult = CaseUtilities.getLinerBrandLogic(caseInstance);
        System.assertEquals(strResult, BrandUtilities.SEAGO);
    }
}