/*
 * Author   : Sreya@Maersk
 * Purpose  : test class for Accept_CaseController class        
 * 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-010129   12-03-2019  Sreya@Maersk            Provide coverage for Accept_CaseController class
 * 2.0      SPI-100     07-06-2022  Ronnie@SF               Removing brand hardcodings
 */

@isTest
public class Accept_CaseController_Test {
    
    @testSetup
    static void testDataSetup() { //testing pankajam
        //Testdata.iNumberOtestfCases = 5; PK 1 conflicts
        //Testdata.iNumberOtestfCases = 5; PK 2 conflicts
        //Testdata.iNumberOtestfCases = 5; PK 3 conflicts
        //Testdata.iNumberOtestfCases = 5; PK 4 conflicts
        //Testdata.iNumberOtestfCases = 5; PK 5 conflicts
        //Testdata.iNumberOtestfCases = 5; PK 6 conflicts    
        CaseData_Test.iNumberOfCases = 5;
        //Testdata.iNumberOtestfCases = 5; PK 1
        //Testdata.iNumberOtestfCases = 5; PK 2
        //Testdata.iNumberOtestfCases = 5; PK 3
        //Testdata.iNumberOtestfCases = 5; PK 4
        //Testdata.iNumberOtestfCases = 5; PK 5
        //Testdata.iNumberOtestfCases = 5; PK 6   
        CaseData_Test.createExternalCases();
        list<Case> lstCases = CaseData_Test.lstCases;
        list<Case> lstUpdateCase = new list<Case>();
        
        for(Case newCase : lstCases ) {
            newCase.Status ='Triaged';
            newCase.Product__c = 'Ocean';
            newCase.type='Documentation';
            newCase.Sub_Type__c='Manifest / Customs'; 
            newCase.Reason_For_Case__c ='Advanced Manifest Query';
            newCase.Liner_Brand__c  = BrandUtilities.MAERSKLINE;
            newCase.Country__c = BDAGeographyData_Test.countryRU.Id;
            newCase.Security_Code__c = '1235';
            lstUpdateCase.add(newCase);
        }
        update lstUpdateCase;
    }
    //testing PK
    //testing PK
    static testMethod void  testAcceptCase(){ //testing PK
        
        List<Case> testCase = [SELECT Id, Status FROM Case LIMIT 5];

        Test.startTest();
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(testCase);
        sc.setSelected(testCase);
        Accept_CaseController obj = new Accept_CaseController(sc);
        obj.getMessage(); 
        List<Case> updatedCase = [SELECT Id, Status FROM Case LIMIT 5];
        System.assertNotEquals(obj.acceptMessages, 'POC Testing ');        
        obj.retURLFunction();
        
        ApexPages.StandardSetController sc1 = new ApexPages.StandardSetController(testCase);
        Accept_CaseController obj1 = new Accept_CaseController(sc1);
        obj1.getMessage();
        obj.retURLFunction();
        
        Test.stopTest();                
    }
}