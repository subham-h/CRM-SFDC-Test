/*
Date			   Story			Developer 	Description
23-April-2024		SFSE-14047		Anjali		Test Class Created; To cover Controller class 'AccountOpportunityRenewalCntrl'
*/
@isTest
public class AccountOpportunityRenewalCntrl_Test {
    @isTest
    static void testFetchAccOppData() {
        // Create test data using TestBusinessHelper
        Account clientAcc = TestBusinessHelper.createAccount('Client_Account', true);
        Contact contact = TestBusinessHelper.createContact(clientAcc, 'Customer_Contact', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
        User maerskLineUser = TestBusinessHelper.createUser('Sales', Brand__mdt.getInstance('MaerskLine').MasterLabel, false);
        System.runAs(new User(Id = UserInfo.getUserId())){
            maerskLineUser.Id = null;
            maerskLineUser.CM_Visibility__c='Single Carrier';
            insert maerskLineUser;
        }
        
        // Create opportunities using TestBusinessHelper
        List<String> recordTypes = new List<String>{'ShippingCargoServices','ShippingCargoServices','ShippingCargoServices','Quarterly_Deal'};
        List<Opportunity> lstopp = TestBusinessHelper.createOpportunities(clientAcc, contact, maerskLineUser, recordTypes, BrandUtilities.MAERSKLINE, true);
        System.debug('List AJ Opp:'+lstopp);
        lstopp[0].Renewal_Opportunitity__c=true;
        update lstopp[0];
        // Calling the Apex method with the Test Account Id
        List<AccountOpportunityRenewalCntrl.AccountOpportunityWrapper> result = AccountOpportunityRenewalCntrl.fetchAccOppData(clientAcc.Id,25,0,'StageName','asc');

        // Checking if the result is not null
        System.assertNotEquals(null, result, 'Result should not be null');

        // Verifying the content of the result
        if (!result.isEmpty()) {
            // Verify each wrapper in the result list
            for (Integer i = 0; i < result.size(); i++) {
                AccountOpportunityRenewalCntrl.AccountOpportunityWrapper wrapper = result[i];
                Opportunity opp = lstopp[i]; // Get corresponding Opportunity

                // Verify each field in the wrapper
                System.assertEquals(opp.Id, wrapper.oppId, 'Opportunity Id should match');
                System.assertEquals(opp.Name, wrapper.oppname, 'Opportunity name should match');
                System.assertEquals(opp.AccountId, wrapper.accountId, 'Account Id should match');
                //System.assertEquals(opp.Account_Name__c, wrapper.accname, 'Account Name should match');
                System.assertEquals(opp.StageName, wrapper.StageName, 'Sales Stage should match');
                System.assertEquals(String.valueOf(opp.CloseDate), wrapper.closedate, 'Close Date should match');
            }
        } else {
            System.debug('Result list is empty');
        }
    }
}