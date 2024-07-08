/**
* 
* Date         Owner                                                    Description
*************************************************************************************************************************************
* 12/08/2016   meghana.gupta@ust-global.com                Code Created
*/

@isTest
private class LookupController_Test{

    static testmethod void TestLookupController(){ 
        
        Account clientAcc = AccountDataHelper_Test.createClientAccount(); 
        Opportunity mslOppty = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( clientAcc.id, null );
       
        test.startTest();
        
        LookupController.getCurrentValue('Opportunity', mslOppty.id );
        LookupController.getCurrentValue('', mslOppty.id );
        LookupController.getCurrentValue('Opportunity', 'xyz' );
        LookupController.getCurrentValue('Oppty', mslOppty.id );
        
        SObjectType objType = Schema.getGlobalDescribe().get('Opportunity');
        LookupController.getSobjectNameField(objType);
        
        LookupController.lookup('', 'Opportunity', ' LastModifiedDate >= Today ', 'Account', 'Name');
        LookupController.lookup('test', 'Oppty', ' ', 'Account', 'Name');
        
        Id [] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = mslOppty.id;
        Test.setFixedSearchResults( fixedSearchResults );

        LookupController.lookup( mslOppty.Name, 'Opportunity', ' LastModifiedDate >= Today ', 'Account', 'Name');
        LookupController.lookup( 'test', 'Opportunity', '', null, 'StageName');
        
        LookupController.Result aTest = new LookupController.Result('Opportunity', mslOppty.id );
        
        test.stopTest();
    }
    
}