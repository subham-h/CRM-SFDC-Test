/**
* Test class for : AccountDataHelper_Test

* Date         Owner                                        Description
*************************************************************************************************************************************
* 20/05/2016   meghana.gupta@ust-global.com               Code Created
*/

@isTest
private class AccountDataGeneratorHelper_Test {

    static testMethod void AccountDataGeneratorHelper_TestClient(){
        
        if ( UserDataGeneratorHelper_Test.integrationUser == null ){
            
            UserDataGeneratorHelper_Test.initializeIntegrationUser();  
        }
        
        BDA__c recBDA = DataGeneratorHelper1_Test.createBDA('Cluster', null, UserDataGeneratorHelper_Test.integrationuser.id);
        Test.startTest(); 
        
        AccountDataHelper_Test.createClientAccount(); 
        AccountDataHelper_Test.createClientAccount( recBDA.id, 'Active');
        AccountDataHelper_Test.createClientNamedAccount();
        AccountDataHelper_Test.createClntAccountWithMSLUser();
        AccountDataHelper_Test.createInvalidTestAccount(  recBDA.id );
        AccountDataHelper_Test.createClientAccountWithSealandUSer();
               
        Test.stopTest();
    }
    
    static testMethod void AccountDataGeneratorHelper_Test(){
        
        Test.startTest(); 
        
        Account clientAcc1 = AccountDataHelper_Test.createConcernAccount(); 
        Account clientAcc2 = AccountDataHelper_Test.createUnassignedAccount();
        Account clientAcc3 = AccountDataHelper_Test.createDraftAccount();
        Account clientAcc4 = AccountDataHelper_Test.createNonShippingPartyAccount();
        AccountDataHelper_Test.createAccountTeamMember( clientAcc4.id, UserDataGeneratorHelper_Test.integrationUser.id, 'Team Member' );
        //AccountDataHelper_Test.createAccountShare( clientAcc4.id, UserDataGeneratorHelper_Test.integrationUser.id, 'Edit', 'Edit', 'Edit', 'Edit' );
        
       
        Test.stopTest();
    }
}