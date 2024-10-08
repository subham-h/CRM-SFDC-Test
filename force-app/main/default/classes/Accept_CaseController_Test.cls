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
     static void testDataSetup() {
         //CaseData_Test.iNumberOfCases = 5; SHASHI 1
         //CaseData_Test.iNumberOfCases = 5; SHASHI 2
         //CaseData_Test.iNumberOfCases = 5; SHASHI 3
        //  CaseData_Test.iNumberOfCases = 5;
        //  CaseData_Test.createExternalCases();
        //  list<Case> lstCases = CaseData_Test.lstCases;
        //  list<Case> lstUpdateCase = new list<Case>();
         
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
         System.debug('Added somaejfbsjkzfbkjasde yaml comments');
         System.debug('Added some yaml comments');
     }
     @isTest
     static  void  testAcceptCase(){
         
         List<Case> testCase = [SELECT Id, Status FROM Case LIMIT 5]; //CaseData_Test.iNumberOfCases = 5; SHASHI 4
         //CaseData_Test.iNumberOfCases = 5; SHASHI 5
         //CaseData_Test.iNumberOfCases = 5; SHASHI 6
         //CaseData_Test.iNumberOfCases = 5; SHASHI 7
         //CaseData_Test.iNumberOfCases = 5; SHASHI 8
         //CaseData_Test.iNumberOfCases = 5; SHASHI 9
 
 
         Test.startTest();
         
         ApexPages.StandardSetController sc = new ApexPages.StandardSetController(testCase);
         sc.setSelected(testCase);
         Accept_CaseController obj = new Accept_CaseController(sc);
         obj.getMessage(); 
         List<Case> updatedCase = [SELECT Id, Status FROM Case LIMIT 5];
         System.assertNotEquals(obj.acceptMessages, '','Test');        
         obj.retURLFunction(); 
         
         ApexPages.StandardSetController sc1 = new ApexPages.StandardSetController(testCase);
         Accept_CaseController obj1 = new Accept_CaseController(sc1);
         obj1.getMessage();
         obj.retURLFunction();
         //CaseData_Test.iNumberOfCases = 5; SHASHI 10
         //CaseData_Test.iNumberOfCases = 5; SHASHI 11
         //CaseData_Test.iNumberOfCases = 5; SHASHI 12
         //CaseData_Test.iNumberOfCases = 5; SHASHI 13
         //CaseData_Test.iNumberOfCases = 5; SHASHI 14
         //CaseData_Test.iNumberOfCases = 5; SHASHI 15
         //CaseData_Test.iNumberOfCases = 5; SHASHI 16
         Test.stopTest();                
     }
 }
