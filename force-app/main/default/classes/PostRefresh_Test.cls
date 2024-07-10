/**
 * Description: Test class for all post-refresh related classes
 *
 * Version       Date            Owner                               Ref Number   Description
 ******************************************************************************************************************************************************
 * v1.0          22-Feb-2019     manjunath.c.holekade@maersk.com     RQ-010022 -> testPostRefreshClass for covering "Batch_InsertGeographyRecords" and "Batch_InsertGeographyRecords" classes
 * v2.0          26-Feb-2019     abhinav.ankit@maersk.com            RQ-010163 -> testPostRefreshClass for covering "Batch_EmailMaskingCase" and "Batch_EmailMaskingCase" classes
 *                                                                                testPostRefreshClass for covering "Batch_EmailMaskingContact" and "Batch_EmailMaskingContact" classes
 *                                                                                testPostRefreshClass for covering "Batch_EmailMaskingLead" and "Batch_EmailMaskingLead" classes
 * v3.0          12-Nov-2019     manjunath.c.holekade@maersk.com     RQ-012362 -> Removed references of Account.Commercial_Leader__c and Account.Export_Rep__c                                                                               
 * v4.0          27-Jun-2022     Ronnie@SF                           SPI-100      Removed brand hardcoding
 * ------------------------------------------------------------------------------------------------------------------------------------------------------>
 */
@isTest
public class PostRefresh_Test {
    
    @testSetup static void dataSetup() {
        
        UserDataGeneratorHelper_Test.initializeIntegrationUser();   
        Account  acctObj= new Account();
        acctObj.Name = 'Test Account';
        acctObj.SCV_Code__c = 'SCV12344';   
        acctObj.MSL_Account_Owner__c=UserDataGeneratorHelper_Test.MSLIntegrationUser.Id; 
        //acctObj.SCL_Account_Owner__c=UserDataGeneratorHelper_Test.SCLIntegrationUser.id;
        System.runAs(UserDataGeneratorHelper_Test.integrationUser)
        {
            insert acctObj;
        } 
        
        Contact c = new Contact();
        c.AccountId = acctObj.Id;
        c.FirstName = 'first';
        c.LastName = 'last';
        c.Email = 'Qwerty@gmail.com';
        c.Liner_Brands__c = BrandUtilities.MAERSKLINE;
        insert c;
        
        Lead leadRec = LeadDataGeneration.createLead('firstname', 'lastName', 'TestCompany2', null, BrandUtilities.MAERSK, 'testclassrun123@test.com.play', null, null, 'LinkedIn');
        insert leadRec;
        
        Case caseIterator= new Case();
        caseIterator.SuppliedEmail = 'test@maersk.com';
        caseIterator.City__c = BDAGeographyData_Test.citySterling.Id;
        caseIterator.Country__c = BDAGeographyData_Test.countryUK.Id;
        caseIterator.Case_Channel__c = 'Proactive';
        caseIterator.MLL__c = True;
        caseIterator.Liner_Brand__c = 'Maersk Line';
        caseIterator.Send_Case_Closure__c = 'Yes';
        Insert caseIterator;
    }
    
    static testMethod void testPostRefreshClass() {
        Test.StartTest();
        Test.testSandboxPostCopyScript(new PostRefreshClass(), UserInfo.getOrganizationId(),UserInfo.getOrganizationId(),'Sandbox');   
        Test.StopTest();
    }
}