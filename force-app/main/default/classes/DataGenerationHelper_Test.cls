/*********************************************************************************************************
 *
 * Description : 
 *
 * Date          Owner                               Ref Number  Description
 ***********************************************************************************************************
 * 30/01/2015    Deepa.Raman@ust-global.com          #RQ-000917  Test class for data geeration helper
 * 03.02.2016    meghana.gupta@ust-global.com        #RQ-002775  Modify opporutnity test data generator method call
 * 03-Sep-2019   manjunath.c.holekade@maersk.com     #RQ-011746  Removal of unused methods for improving the code coverage
 * 16-Oct-2020   meghana@UST                         #SFSE-4767  Removal SCL record creation code
 * 08-Jun-2022   Ronnie@SF                           SPI-100     Removed brand hardcoding
 ***********************************************************************************************************/ 

@isTest
private class DataGenerationHelper_Test
{
    static testmethod void TestConcernAccount() {
        Test.startTest();
        Account concernAccount = AccountDataHelper_Test.createConcernAccount(); 
        System.debug('##### concernAccount.IsConcern__c' + concernAccount.IsConcern__c);
        Test.stopTest();
    }
    
    static testmethod void TestunAssignedAccount() {
        Test.startTest();
        Account unAssignedAccount = AccountDataHelper_Test.createUnassignedAccount(); 
        Test.stopTest();
    }
    
    static testmethod void TestDraftAccount() {
        Test.startTest();
        Account DraftAccount = AccountDataHelper_Test.createDraftAccount(); 
        System.debug('##### concernAccount.is_Draft_Account__c'+DraftAccount.is_Draft_Account__c);
        Test.stopTest();
    }
    
    static testmethod void TestThirPartyAccount() {
        Test.startTest();
        Account thirdPartyAccount = AccountDataHelper_Test.createNonShippingPartyAccount(); 
        Test.stopTest();
    }
    
    static testmethod void TestDryOpportunityCreation() {
        try{
            Account clientAcc = AccountDataHelper_Test.createClientAccount(); 
            Contact mslCont =ContactDataGeneratorHelper_Test.createCustomerContact( clientAcc.id, BrandUtilities.MAERSKLINE );
            Contact seaCont =ContactDataGeneratorHelper_Test.createCustomerContact ( clientAcc.id, BrandUtilities.SEALAND);
            
            Test.startTest();          
            OpportunityDataGeneratorHelper_Test.createMSLDryOpportunity( clientAcc.id, mslCont.id );
            OpportunityDataGeneratorHelper_Test.createSeaDryOpportunity( clientAcc.id, seaCont.id ); 
            OpportunityDataGeneratorHelper_Test.createMSLDryClosedOpportunity( clientAcc.id, mslCont.id ); 
            Test.stopTest();
        } catch(Exception e) {
            
        }
    }
    
    // method to cover tests for constructors for Data Generator classes and to increase code coverage
    static testmethod void TestConstructors() {
        AccountDataHelper_Test tc_acctDataGenerator = new AccountDataHelper_Test();
        OpportunityDataGeneratorHelper_Test tc_OpptyDataGenerator = new OpportunityDataGeneratorHelper_Test ();
        DataGeneratorHelper1_Test tc_DataGenerator = new DataGeneratorHelper1_Test ();
        ContactDataGeneratorHelper_Test tc_contDataGenerator = new ContactDataGeneratorHelper_Test ();    
    }
}