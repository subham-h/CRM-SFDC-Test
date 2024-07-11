/*
Date			   Story			Developer 	Description
1-May-2024		SFSE-13827		Anjali		Test Class Created; Test class for AccountBannerRenewalCntrl
*/
@isTest
public class AccountBannerRenewalCntrl_Test {
    @isTest
    static void testGetRenewalCounts() {
        try {
            // Test scenario without exceptions
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
            lstopp[0].CloseDate = Date.today().addDays(5);
            lstopp[1].Renewal_Opportunitity__c=true; 
            update lstopp; 
            AccountBannerRenewalCntrl.getRenewalCounts(clientAcc.Id);
        } catch (Exception ex) {
            // Assert that an exception is caught
            System.assert(false, 'An unexpected exception occurred: ' + ex.getMessage());
        }
    }
}